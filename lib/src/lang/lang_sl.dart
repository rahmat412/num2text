import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/sl_options.dart';
import '../utils/utils.dart';

/// {@template num2text_sl}
/// The Slovenian language (`Lang.SL`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Slovenian word representation following standard Slovenian grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [SlOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (standard scale).
/// It correctly applies grammatical gender and case variations (including dual number) for units and currency.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [SlOptions].
/// {@endtemplate}
class Num2TextSL implements Num2TextBase {
  // --- Constants ---

  /// The word for zero.
  static const String _zero = "nič";

  /// The word for the decimal separator comma (",").
  static const String _vejica = "vejica";

  /// The word for the decimal separator period/point (".").
  static const String _pika = "pika";

  /// The default separator word used between main and subunits in currency.
  static const String _currencySeparator = "in";

  /// The suffix added to positive years when `includeAD` is true ("našega štetja" - AD/CE).
  static const String _yearSuffixAD = "n. št.";

  // --- Word Lists ---

  /// Words for numbers 0-19.
  /// These forms are generally feminine/neuter base forms used for counting.
  /// Gender variations for 1-4 are handled in `_convertChunk`.
  static const List<String> _wordsUnder20 = [
    "nič", // 0
    "ena", // 1 (feminine/neuter base form)
    "dva", // 2 (masculine base form - used for dual agreement)
    "tri", // 3 (feminine/neuter base form)
    "štiri", // 4 (feminine/neuter base form)
    "pet", // 5
    "šest", // 6
    "sedem", // 7
    "osem", // 8
    "devet", // 9
    "deset", // 10
    "enajst", // 11
    "dvanajst", // 12
    "trinajst", // 13
    "štirinajst", // 14
    "petnajst", // 15
    "šestnajst", // 16
    "sedemnajst", // 17
    "osemnajst", // 18
    "devetnajst", // 19
  ];

  /// Words for tens (20, 30, ..., 90). Index corresponds to ten's value / 10.
  static const List<String> _wordsTens = [
    "", // 0 (unused)
    "", // 10 (handled by _wordsUnder20)
    "dvajset", // 20
    "trideset", // 30
    "štirideset", // 40
    "petdeset", // 50
    "šestdeset", // 60
    "sedemdeset", // 70
    "osemdeset", // 80
    "devetdeset", // 90
  ];

  /// Words for hundreds (100, 200, ..., 900). Index corresponds to hundred's value / 100.
  static const List<String> _wordsHundreds = [
    "", // 0 (unused)
    "sto", // 100
    "dvesto", // 200
    "tristo", // 300
    "štiristo", // 400
    "petsto", // 500
    "šeststo", // 600
    "sedemsto", // 700
    "osemsto", // 800
    "devetsto", // 900
  ];

  /// Definitions for large number scales (million, billion, etc.).
  /// Each tuple contains:
  /// - `BigInt`: The value of the scale (10^power).
  /// - `String`: Singular nominative form (e.g., "milijon").
  /// - `String`: Dual nominative form (e.g., "milijona").
  /// - `String`: Plural nominative form for 3, 4 (e.g., "milijoni").
  /// - `String`: Genitive plural form for 0, 5+ (e.g., "milijonov").
  /// - `Gender`: Grammatical gender of the scale word.
  static final List<(BigInt, String, String, String, String, Gender)>
      _scaleWords = [
    (
      BigInt.from(10).pow(6),
      "milijon",
      "milijona",
      "milijoni",
      "milijonov",
      Gender.masculine
    ),
    (
      BigInt.from(10).pow(9),
      "milijarda",
      "milijardi",
      "milijarde",
      "milijard",
      Gender.feminine
    ),
    (
      BigInt.from(10).pow(12),
      "bilijon",
      "bilijona",
      "bilijoni",
      "bilijonov",
      Gender.masculine
    ),
    (
      BigInt.from(10).pow(15),
      "bilijarda",
      "bilijardi",
      "bilijarde",
      "bilijard",
      Gender.feminine
    ),
    (
      BigInt.from(10).pow(18),
      "trilijon",
      "trilijona",
      "trilijoni",
      "trilijonov",
      Gender.masculine
    ),
    (
      BigInt.from(10).pow(21),
      "trilijarda",
      "trilijardi",
      "trilijarde",
      "trilijard",
      Gender.feminine,
    ),
    (
      BigInt.from(10).pow(24),
      "kvadrilijon",
      "kvadrilijona",
      "kvadrilijoni",
      "kvadrilijonov",
      Gender.masculine,
    ),
    (
      BigInt.from(10).pow(27),
      "kvadrilijarda",
      "kvadrilijardi",
      "kvadrilijarde",
      "kvadrilijard",
      Gender.feminine,
    ),
    // Add more scales here if needed following the long scale pattern (Quintillion/Quintilliard)
  ];

  /// Processes the given number into Slovenian words based on the provided options.
  ///
  /// [number] The number to convert (can be `int`, `double`, `String`, `BigInt`, `Decimal`).
  /// [options] Optional `SlOptions` to customize conversion (currency, year format, etc.).
  /// [fallbackOnError] A custom string to return if conversion fails (e.g., invalid input).
  /// Returns the number in Slovenian words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final SlOptions slOptions =
        options is SlOptions ? options : const SlOptions();
    final String effectiveFallback =
        fallbackOnError ?? "Ni število"; // Default fallback

    // Handle special double values directly
    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Minus neskončnost" : "Neskončnost";
      if (number.isNaN) return effectiveFallback;
    }

    // Normalize the input number to Decimal for consistent handling
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) {
      // Return fallback if normalization fails (e.g., non-numeric string)
      return effectiveFallback;
    }

    // Handle zero separately
    if (decimalValue == Decimal.zero) {
      // Special case for currency: "nič evrov"
      if (slOptions.currency) {
        // Currency forms are typically Genitive Plural for 0
        return "$_zero ${_getCurrencyForm(BigInt.zero, Gender.masculine, slOptions.currencyInfo.mainUnitSingular, slOptions.currencyInfo.mainUnitPlural2To4!, slOptions.currencyInfo.mainUnitPluralGenitive!)}";
      }
      return _zero; // Standard zero
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Apply specific format handlers if requested
    if (slOptions.format == Format.year) {
      if (!absValue.isInteger) {
        // Cannot format a non-integer year.
        return effectiveFallback;
      }
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), slOptions);
    } else {
      // Handle standard or currency conversion for the absolute value
      if (slOptions.currency) {
        textResult = _handleCurrency(absValue, slOptions);
      } else {
        textResult = _handleStandardNumber(absValue, slOptions);
      }
      // Prepend negative prefix if the original number was negative
      if (isNegative) {
        textResult = "${slOptions.negativePrefix} $textResult";
      }
    }
    return textResult;
  }

  /// Formats a number as a year according to Slovenian rules.
  ///
  /// [year] The year as a `BigInt`.
  /// [options] The `SlOptions` containing formatting details.
  /// Returns the year in words, potentially with era indicators.
  String _handleYearFormat(BigInt year, SlOptions options) {
    final bool isNegative = year < BigInt.zero;
    final BigInt absYear = isNegative ? -year : year;

    // Convert the absolute year value to words. Years often use feminine/neuter forms for 1/2.
    String yearText = _convertInteger(absYear, Gender.feminine);

    if (isNegative) {
      // BC/BCE years are prefixed with "minus" (or custom prefix).
      // Specific "pr. n. št." (pred našim štetjem - BC/BCE) suffix is less common in number-to-word conversion.
      yearText = "${options.negativePrefix} $yearText";
    } else if (options.includeAD && absYear > BigInt.zero) {
      // Add AD/CE suffix if requested and year is positive.
      yearText += " $_yearSuffixAD";
    }
    return yearText;
  }

  /// Formats a number as currency according to Slovenian rules.
  ///
  /// [absValue] The absolute value of the amount as `Decimal`.
  /// [options] The `SlOptions` containing currency info and rounding rules.
  /// Returns the currency amount in words.
  String _handleCurrency(Decimal absValue, SlOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2; // Standard currency precision

    // Round to 2 decimal places if requested, otherwise use the exact value.
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main unit and subunit values.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    // Use round() to avoid potential precision issues in subunit calculation
    final BigInt subunitValue =
        ((valueToConvert - valueToConvert.truncate()) * Decimal.fromInt(100))
            .round()
            .toBigInt();

    // Determine gender for agreement (Euro/Cent are masculine in Slovenian).
    // This could be parameterized in CurrencyInfo if needed for other currencies.
    const Gender mainGender = Gender.masculine;
    const Gender subGender = Gender.masculine;

    // Convert the main unit value to words.
    String mainText = _convertInteger(mainValue, mainGender);
    // Get the correct grammatical form of the main unit name.
    String mainUnitName = _getCurrencyForm(
      mainValue,
      mainGender,
      currencyInfo.mainUnitSingular,
      currencyInfo
          .mainUnitPlural2To4!, // Slovenian uses dual for 2, plural for 3/4
      currencyInfo.mainUnitPluralGenitive!, // Genitive Plural for 0, 5+
    );
    String result = '$mainText $mainUnitName';

    // Add subunit part if present and defined.
    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      String subunitText = _convertInteger(subunitValue, subGender);
      String subUnitName = _getCurrencyForm(
        subunitValue,
        subGender,
        currencyInfo.subUnitSingular!,
        currencyInfo.subUnitPlural2To4!, // Dual for 2, plural for 3/4
        currencyInfo.subUnitPluralGenitive!, // Genitive Plural for 0, 5+
      );
      // Use the separator from CurrencyInfo or the default ("in").
      String separator = currencyInfo.separator ?? _currencySeparator;
      result += ' $separator $subunitText $subUnitName';
    }
    return result;
  }

  /// Determines the correct grammatical form (declension) of a currency unit name
  /// based on the quantity and gender.
  ///
  /// Slovenian uses complex declension rules:
  /// - Ends in 1 (but not 11): Singular Nominative
  /// - Ends in 2 (but not 12): Dual Nominative
  /// - Ends in 3, 4 (but not 13, 14): Plural Nominative (special masculine form '...i')
  /// - Ends in 0, 5-9, 11-19: Genitive Plural
  ///
  /// [number] The quantity of the currency unit.
  /// [gender] The grammatical gender of the currency unit noun.
  /// [singular] The singular nominative form (e.g., "evro", "cent").
  /// [dualPlural2] The dual nominative form (used for 2) and often base for feminine/neuter 3/4 (e.g., "evra", "centa").
  /// [genitivePlural] The genitive plural form (used for 0, 5+) (e.g., "evrov", "centov").
  /// Returns the correctly declined currency unit name.
  String _getCurrencyForm(
    BigInt number,
    Gender gender,
    String singular,
    String dualPlural2,
    String genitivePlural,
  ) {
    // Handle 0 separately (uses Genitive Plural)
    if (number == BigInt.zero) return genitivePlural;

    // Determine form based on the last two digits
    final BigInt lastTwoDigits =
        (number % BigInt.from(100)).abs(); // Use abs for modulo

    if (lastTwoDigits == BigInt.one) return singular; // 1, 101, etc.
    if (lastTwoDigits == BigInt.two) return dualPlural2; // 2, 102, etc.
    if (lastTwoDigits == BigInt.from(3) || lastTwoDigits == BigInt.from(4)) {
      // 3, 4, 103, 104, etc.
      // Masculine nouns often have a specific Nominative Plural form ending in 'i'
      // (e.g., evro -> evri, cent -> centi).
      if (gender == Gender.masculine) {
        // Attempt to derive the Nominative Plural '...i' form.
        // If genitive plural ends in 'ov', replace with 'i'. Otherwise, append 'i' to singular.
        // This is a heuristic and might need refinement for irregular nouns.
        if (genitivePlural.endsWith("ov")) {
          // e.g., "evrov" -> "evri"
          return "${genitivePlural.substring(0, genitivePlural.length - 2)}i";
        }
        // e.g., if singular was "dolar", genitive "dolarjev", might derive "dolari"
        return "${singular}i";
      }
      // Feminine/Neuter use the dual form for 3/4 as well.
      return dualPlural2;
    }
    // 0, 5-9, 11-19, 100, 105-109, 111-119 etc. use Genitive Plural
    return genitivePlural;
  }

  /// Formats a standard number (potentially with decimals) into words.
  ///
  /// [absValue] The absolute value of the number as `Decimal`.
  /// [options] The `SlOptions` containing decimal separator preference.
  /// Returns the number in words.
  String _handleStandardNumber(Decimal absValue, SlOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part. Use feminine gender as default for standalone numbers.
    // Handle case where integer part is 0 but fractional part exists (e.g., 0.5 -> "nič vejica pet").
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, Gender.feminine);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word based on options.
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.period:
        case DecimalSeparator.point: // Treat point same as period
          separatorWord = _pika;
          break;
        case DecimalSeparator.comma:
        default: // Default to comma
          separatorWord = _vejica;
          break;
      }

      // Convert fractional digits individually.
      String fractionalDigits = absValue.toString().split('.').last;
      // Remove trailing zeros as they are typically not spoken ("one point five", not "one point five zero").
      fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');
      // If all fractional digits were zero, don't add the decimal part.
      if (fractionalDigits.isEmpty) return integerWords;

      final List<String> digitWords = fractionalDigits.split('').map((digit) {
        final int? digitInt = int.tryParse(digit);
        // Use base feminine/neuter forms for decimal digits (e.g., "ena", "dva", "tri", ...).
        return (digitInt != null && digitInt >= 0 && digitInt <= 19)
            ? _wordsUnder20[digitInt]
            : '?'; // Placeholder for unexpected characters
      }).toList();

      fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
    }

    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer (`BigInt`) into Slovenian words.
  ///
  /// This is the core recursive function that handles number scales.
  ///
  /// [n] The non-negative integer to convert.
  /// [gender] The required grammatical gender for the number 1 and 2 in the *lowest* chunk (0-999),
  ///          important for agreement with nouns (e.g., currency, standalone numbers).
  /// Returns the integer in words.
  String _convertInteger(BigInt n, Gender gender) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero)
      throw ArgumentError("Input must be non-negative for _convertInteger: $n");

    final List<String> parts = [];
    BigInt currentN = n;
    int scaleIndex =
        0; // 0: 0-999, 1: thousands, 2: millions, 3: milliards, etc.
    final BigInt thousand = BigInt.from(1000);

    // Process the number in chunks of 1000.
    do {
      final int currentChunkInt = (currentN % thousand).toInt();
      currentN ~/= thousand; // Move to the next chunk

      if (currentChunkInt > 0) {
        String chunkText;
        String scaleWord = "";
        bool omitNumberWord = false; // Flag to omit "en" for "tisoč"
        Gender chunkGender; // Gender required by the scale word or base context

        // Determine the gender needed for this chunk's 1/2 based on scale
        if (scaleIndex == 0) {
          // Base chunk (0-999): use the provided gender context.
          chunkGender = gender;
        } else if (scaleIndex == 1) {
          // Thousands chunk: "tisoč" requires agreement.
          // Use masculine for 1/2 ("en tisoč", "dva tisoč"), feminine for others.
          if (currentChunkInt == 1 || currentChunkInt == 2) {
            chunkGender = Gender.masculine;
          } else {
            chunkGender = Gender.feminine; // e.g., "tri tisoč"
          }
          scaleWord = _getTisocForm(currentChunkInt); // Always "tisoč"
          // Special case: 1000 is "tisoč", not "en tisoč"
          if (currentChunkInt == 1) omitNumberWord = true;
        } else {
          // Higher scales (millions, billions, etc.)
          final int scaleDefIdx = scaleIndex - 2; // Index into _scaleWords
          if (scaleDefIdx < _scaleWords.length) {
            final scaleInfo = _scaleWords[scaleDefIdx];
            chunkGender =
                scaleInfo.$6; // Gender is defined by the scale word itself
            scaleWord = _getScaleForm(
              currentChunkInt,
              scaleInfo.$2, // singular
              scaleInfo.$3, // dual
              scaleInfo.$4, // plural 3/4
              scaleInfo.$5, // genitive plural 5+
            );
            // Special case: 1 million is "en milijon", not "milijon"
            if (currentChunkInt == 1) {
              omitNumberWord =
                  false; // Ensure "en" is kept for scales >= million
            }
          } else {
            // Fallback for scales beyond defined limits
            chunkGender = Gender.feminine; // Assume feminine as default
            scaleWord = "[Neznana skala: $scaleIndex]";
          }
        }

        // Convert the 0-999 chunk number to words with the determined gender.
        chunkText = _convertChunk(currentChunkInt, chunkGender);

        // Apply the "en tisoč" -> "tisoč" rule.
        if (omitNumberWord && scaleIndex == 1 && chunkText == "en") {
          chunkText = ""; // Remove the "en" part
        }

        // Combine the chunk number words and the scale word.
        final String combinedPart = chunkText.isEmpty
            ? scaleWord // Only scale word (e.g., "tisoč" for 1000)
            : (scaleWord.isEmpty
                ? chunkText
                : "$chunkText $scaleWord"); // Combine both

        if (combinedPart.isNotEmpty) {
          parts.add(combinedPart.trim());
        }
      }
      scaleIndex++;
    } while (currentN > BigInt.zero);

    // Join the processed chunks in reverse order (highest scale first).
    return parts.reversed.join(' ').trim();
  }

  /// Converts a number between 0 and 999 into Slovenian words, respecting gender agreement.
  ///
  /// [n] The number chunk (0-999).
  /// [gender] The required grammatical gender for 1, 2, 3, 4 within this chunk.
  ///          Affects forms like "en"/"ena", "dva"/"dve", "tri"/"trije", "štiri"/"štirje".
  /// Returns the chunk number in words.
  String _convertChunk(int n, Gender gender) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000)
      throw ArgumentError("Chunk must be between 0 and 999: $n");

    final List<String> words = [];
    int remainder = n;

    // Handle hundreds
    if (remainder >= 100) {
      words.add(_wordsHundreds[remainder ~/ 100]);
      remainder %= 100;
      // Add space if there are tens/units following
      if (remainder > 0) words.add(" ");
    }

    // Handle tens and units (0-99)
    if (remainder > 0) {
      if (remainder < 20) {
        // Numbers 1-19: Use appropriate gender form for 1-4
        String word;
        if (remainder == 1) {
          // "en" (masculine) vs "ena" (feminine/neuter)
          word = (gender == Gender.masculine) ? "en" : _wordsUnder20[1];
        } else if (remainder == 2) {
          // "dva" (masculine) vs "dve" (feminine/neuter)
          word = (gender == Gender.masculine) ? _wordsUnder20[2] : "dve";
        } else if (remainder == 3) {
          // "trije" (masculine) vs "tri" (feminine/neuter)
          word = (gender == Gender.masculine) ? "trije" : _wordsUnder20[3];
        } else if (remainder == 4) {
          // "štirje" (masculine) vs "štiri" (feminine/neuter)
          word = (gender == Gender.masculine) ? "štirje" : _wordsUnder20[4];
        } else {
          // 5-19: Forms are gender-neutral
          word = _wordsUnder20[remainder];
        }
        words.add(word);
      } else {
        // Numbers 20-99
        final int unit = remainder % 10;
        final int tenIndex = remainder ~/ 10; // Index into _wordsTens

        if (unit == 0) {
          // Exact tens (20, 30, ..., 90)
          words.add(_wordsTens[tenIndex]);
        } else {
          // Compound tens (21-29, 31-39, ..., 91-99)
          // Format: unit + "in" + ten (e.g., "enaindvajset")
          // Unit form is always the base (feminine/neuter like) form for compounds.
          String unitWord = _wordsUnder20[unit];
          words.add("${unitWord}in${_wordsTens[tenIndex]}");
        }
      }
    }
    return words.join('');
  }

  /// Returns the correct form for "tisoč" (thousand).
  /// In Slovenian, "tisoč" does not change form based on the preceding number
  /// within the number-to-word context (unlike million, billion etc.).
  /// It always behaves as if the number preceding it requires the base form.
  /// (e.g., "dva tisoč", "pet tisoč").
  ///
  /// [count] The number of thousands (1-999). (Unused in logic, but required by signature)
  /// Returns "tisoč".
  String _getTisocForm(int count) {
    // "tisoč" is invariable in this context.
    return "tisoč";
  }

  /// Determines the correct grammatical form (declension) of a large scale word (million+)
  /// based on the quantity preceding it.
  ///
  /// Rules are similar to currency:
  /// - Ends in 1 (but not 11): Singular Nominative
  /// - Ends in 2 (but not 12): Dual Nominative
  /// - Ends in 3, 4 (but not 13, 14): Plural Nominative
  /// - Ends in 0, 5-9, 11-19: Genitive Plural
  ///
  /// [count] The quantity of this scale unit (e.g., the number of millions).
  /// [singular] The singular nominative form (e.g., "milijon").
  /// [dual] The dual nominative form (e.g., "milijona").
  /// [plural34] The plural nominative form for 3, 4 (e.g., "milijoni").
  /// [genitivePlural5] The genitive plural form for 0, 5+ (e.g., "milijonov").
  /// Returns the correctly declined scale word.
  String _getScaleForm(
    int count,
    String singular,
    String dual,
    String plural34,
    String genitivePlural5,
  ) {
    // Determine form based on the last two digits of the count
    final int lastTwo = count % 100;

    if (lastTwo == 1) return singular; // 1, 101, etc.
    if (lastTwo == 2) return dual; // 2, 102, etc.
    if (lastTwo == 3 || lastTwo == 4) return plural34; // 3, 4, 103, 104, etc.

    // 0, 5-9, 11-19, 100, 105-109, 111-119 etc. use Genitive Plural
    return genitivePlural5;
  }
}
