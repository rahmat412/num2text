import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/sr_options.dart';
import '../utils/utils.dart';

/// {@template num2text_sr}
/// The Serbian language (`Lang.SR`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Serbian word representation following standard Serbian grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [SrOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers
/// (using million/billion scale with distinct forms like 'hiljada', 'miliona').
/// It correctly applies Serbian grammatical rules, including gender agreement and
/// complex pluralization based on the number.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [SrOptions].
/// {@endtemplate}
class Num2TextSR implements Num2TextBase {
  /// Word for zero.
  static const String _zero = "nula";

  /// Word for decimal point ".".
  static const String _pointWord = "tačka";

  /// Word for decimal comma ",".
  static const String _commaWord = "zapeta"; // Sometimes "zarez" is also used.

  /// Words for numbers 0-19 (masculine form, used as default or for masculine nouns).
  static const List<String> _wordsUnder20Masc = [
    "nula", // 0
    "jedan", // 1
    "dva", // 2
    "tri", // 3
    "četiri", // 4
    "pet", // 5
    "šest", // 6
    "sedam", // 7
    "osam", // 8
    "devet", // 9
    "deset", // 10
    "jedanaest", // 11
    "dvanaest", // 12
    "trinaest", // 13
    "četrnaest", // 14
    "petnaest", // 15
    "šesnaest", // 16
    "sedamnaest", // 17
    "osamnaest", // 18
    "devetnaest", // 19
  ];

  /// Feminine form for "one".
  static const String _oneFem = "jedna";

  /// Feminine form for "two".
  static const String _twoFem = "dve";

  /// Words for tens (20-90).
  static const List<String> _wordsTens = [
    "", // 0 (unused)
    "", // 10 (unused)
    "dvadeset", // 20
    "trideset", // 30
    "četrdeset", // 40
    "pedeset", // 50
    "šezdeset", // 60
    "sedamdeset", // 70
    "osamdeset", // 80
    "devedeset", // 90
  ];

  /// Words for hundreds (100-900).
  static const List<String> _wordsHundreds = [
    "", // 0 (unused)
    "sto", // 100
    "dvesta", // 200
    "trista", // 300
    "četiristo", // 400
    "petsto", // 500
    "šeststo", // 600
    "sedamsto", // 700
    "osamsto", // 800
    "devetsto", // 900
  ];

  /// Grammatical forms for "thousand" (hiljada - feminine).
  static const Map<String, String> _thousandForms = {
    "singular":
        "hiljadu", // used with 1 (jednu hiljadu - acc.) but often just "hiljadu"
    "plural2To4": "hiljade", // used with 2, 3, 4 (dve hiljade)
    "genitivePlural": "hiljada", // used with 0, 5+ (pet hiljada)
    "gender": "feminine",
  };

  /// Grammatical forms for "million" (milion - masculine).
  static const Map<String, String> _millionForms = {
    "singular": "milion", // used with 1 (jedan milion)
    "plural2To4":
        "miliona", // used with 2, 3, 4 (dva miliona - gen. sg. form often used for nom. pl.)
    "genitivePlural": "miliona", // used with 0, 5+ (pet miliona)
    "gender": "masculine",
  };

  /// Grammatical forms for "milliard" (milijarda - feminine, 10^9).
  static const Map<String, String> _milliardForms = {
    "singular": "milijarda", // used with 1 (jedna milijarda)
    "plural2To4": "milijarde", // used with 2, 3, 4 (dve milijarde)
    "genitivePlural": "milijardi", // used with 0, 5+ (pet milijardi)
    "gender": "feminine",
  };

  /// Grammatical forms for "billion" (bilion - masculine, 10^12).
  static const Map<String, String> _billionForms = {
    "singular": "bilion",
    "plural2To4": "biliona", // Gen. Sg. form
    "genitivePlural": "biliona", // Gen. Pl. form
    "gender": "masculine",
  };

  /// Grammatical forms for "billiard" (bilijarda - feminine, 10^15).
  static const Map<String, String> _billiardForms = {
    "singular": "bilijarda",
    "plural2To4": "bilijarde",
    "genitivePlural": "bilijardi",
    "gender": "feminine",
  };

  /// Grammatical forms for "trillion" (trilion - masculine, 10^18).
  static const Map<String, String> _trillionForms = {
    "singular": "trilion",
    "plural2To4": "triliona", // Gen. Sg. form
    "genitivePlural": "triliona", // Gen. Pl. form
    "gender": "masculine",
  };

  /// Grammatical forms for "trilliard" (trilijarda - feminine, 10^21).
  static const Map<String, String> _trilliardForms = {
    "singular": "trilijarda",
    "plural2To4": "trilijarde",
    "genitivePlural": "trilijardi",
    "gender": "feminine",
  };

  /// Grammatical forms for "quadrillion" (kvadrilion - masculine, 10^24).
  static const Map<String, String> _quadrillionForms = {
    "singular": "kvadrilion",
    "plural2To4": "kvadriliona", // Gen. Sg. form
    "genitivePlural": "kvadriliona", // Gen. Pl. form
    "gender": "masculine",
  };

  /// List storing the grammatical forms for each scale (thousand, million, etc.).
  /// Index corresponds to the power of 1000 (1 = thousand, 2 = million, ...).
  static const List<Map<String, String>> _scaleWordForms = [
    {}, // Index 0 unused
    _thousandForms, // 10^3
    _millionForms, // 10^6
    _milliardForms, // 10^9
    _billionForms, // 10^12
    _billiardForms, // 10^15
    _trillionForms, // 10^18
    _trilliardForms, // 10^21
    _quadrillionForms, // 10^24
    // Add more scales here if needed
  ];

  /// Processes the given [number] and converts it into Serbian words.
  ///
  /// This is the main entry point for the Serbian conversion.
  /// - Normalizes the input [number].
  /// - Handles special cases like zero, infinity, NaN.
  /// - Manages the negative sign using [SrOptions.negativePrefix].
  /// - Delegates based on [options]: [_handleYearFormat], [_handleCurrency], [_handleStandardNumber].
  /// - Returns the final word representation or fallback error message.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have Serbian-specific options, using defaults if none are provided.
    final SrOptions srOptions =
        options is SrOptions ? options : const SrOptions();

    // Handle special double values before normalization.
    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Minus beskonačnost" : "Beskonačnost";
      if (number.isNaN) return fallbackOnError ?? "Nije broj";
    }

    // Normalize the input number to Decimal for precision.
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null)
      return fallbackOnError ?? "Nije broj"; // Handle normalization failure

    // Handle the specific case of zero.
    if (decimalValue == Decimal.zero) {
      if (srOptions.currency) {
        // For currency, use "nula" and the appropriate plural form (genitive plural for 0).
        return "$_zero ${_getCurrencyPluralForm(BigInt.zero, srOptions.currencyInfo, false)}";
      }
      return _zero; // Otherwise, just "nula".
    }

    // Determine sign and work with the absolute value.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    // Delegate based on the format specified in options.
    if (srOptions.format == Format.year) {
      // Years are treated as integers, handle year formatting.
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), srOptions);
    } else {
      // Handle non-year formats (currency or standard number).
      if (srOptions.currency) {
        textResult = _handleCurrency(absValue, srOptions);
      } else {
        textResult = _handleStandardNumber(absValue, srOptions);
      }
      // Prepend the negative prefix if the original number was negative.
      if (isNegative) textResult = "${srOptions.negativePrefix} $textResult";
    }
    return textResult;
  }

  /// Formats an integer [year] as a Serbian year string.
  ///
  /// Handles negative years by appending "p. n. e." (pre nove ere - BC).
  /// Handles positive years by optionally appending "n. e." (nove ere - AD/CE)
  /// if [options.includeAD] is true. Uses masculine gender for year numbers.
  String _handleYearFormat(int year, SrOptions options) {
    final bool isNegative = year < 0;
    // Use BigInt internally for consistency with _convertInteger.
    final BigInt absYear = BigInt.from(isNegative ? -year : year);

    // Convert the absolute year value using masculine gender.
    String yearText = _convertInteger(absYear, defaultGender: Gender.masculine);

    // Append suffixes for BC/AD.
    if (isNegative) {
      yearText += " p. n. e."; // Append "before our era".
    } else if (options.includeAD) {
      // Renamed includeAD to includeAD internally
      yearText += " n. e."; // Append "our era" if option is set.
    }
    return yearText;
  }

  /// Formats the absolute [absValue] as Serbian currency.
  ///
  /// Uses [CurrencyInfo] from [options]. Optionally rounds.
  /// Converts main and subunit values using [_convertInteger] with appropriate genders.
  /// Selects correct plural forms using [_getCurrencyPluralForm].
  /// Joins parts with the separator from [CurrencyInfo] or "i".
  String _handleCurrency(Decimal absValue, SrOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    final int decimalPlaces = 2; // Standard subunit precision.
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value if requested before separating parts.
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main and subunit values.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).truncate().toBigInt();

    // Convert the main value using masculine gender (typical for Dinar).
    String mainText =
        _convertInteger(mainValue, defaultGender: Gender.masculine);
    // Get the grammatically correct plural form for the main unit.
    String mainUnitName =
        _getCurrencyPluralForm(mainValue, currencyInfo, false);
    String result = '$mainText $mainUnitName'; // e.g., "sto dinara"

    // Add subunit part if it exists.
    if (subunitValue > BigInt.zero) {
      // Convert the subunit value using feminine gender (for Para).
      String subunitText =
          _convertInteger(subunitValue, defaultGender: Gender.feminine);
      // Get the grammatically correct plural form for the subunit.
      String subUnitName =
          _getCurrencyPluralForm(subunitValue, currencyInfo, true);
      // Get the separator word ("i" or custom).
      String separator = currencyInfo.separator ?? "i";
      // Append separator and subunit part.
      result +=
          ' $separator $subunitText $subUnitName'; // e.g., " i pedeset para"
    }
    return result;
  }

  /// Formats the absolute [absValue] as a standard Serbian cardinal number.
  ///
  /// Handles integer and fractional parts. Converts integer part using [_convertInteger].
  /// Converts fractional part digit by digit using masculine forms, joined by spaces,
  /// prefixed by the decimal separator word ("tačka" or "zapeta").
  String _handleStandardNumber(Decimal absValue, SrOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part (use "nula" if integer is 0 but fractional exists).
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, defaultGender: Gender.masculine);

    String fractionalWords = '';
    // Process fractional part if it exists.
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word based on options.
      String separatorWord;
      switch (options.decimalSeparator ?? DecimalSeparator.comma) {
        case DecimalSeparator.comma:
          separatorWord = _commaWord;
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period: // Treat period and point the same.
          separatorWord = _pointWord;
          break;
      }

      // Get fractional digits as string.
      String fractionalDigits = absValue.toString().split('.').last;
      List<String> digitWords = [];
      // Convert each digit character to its word form (using masculine).
      for (var charCode in fractionalDigits.runes) {
        var digitChar = String.fromCharCode(charCode);
        final int? digitInt = int.tryParse(digitChar);
        if (digitInt != null && digitInt >= 0 && digitInt <= 9) {
          digitWords
              .add(_wordsUnder20Masc[digitInt]); // Use masculine digits 0-9
        } else {
          digitWords.add('?'); // Handle unexpected characters
        }
      }
      // Combine separator and digit words.
      fractionalWords =
          ' $separatorWord ${digitWords.join(' ')}'; // e.g., " zapeta pet nula"
    } else if (integerPart > BigInt.zero &&
        absValue.scale > 0 &&
        absValue.isInteger) {
      // This handles cases like Decimal.parse("1.0"), which might have scale but no fractional part.
      // No fractional words needed here.
    }

    return '$integerWords$fractionalWords'.trim();
  }

  /// Determines the correct plural form for a scale word (thousand, million, etc.) based on the [amount].
  ///
  /// Uses Serbian pluralization rules:
  /// - 1: Singular form (often accusative for 'hiljadu', nominative otherwise).
  /// - Ends in 2, 3, 4 (but not 12, 13, 14): Nominative Plural form.
  /// - Ends in 0, 1 (>= 11), 5-9, or 11-19: Genitive Plural form.
  /// [forms] map contains "singular", "plural2To4", "genitivePlural" keys.
  String _getPluralForm(BigInt amount, Map<String, String> forms) {
    // Handle 1 explicitly - usually Nominative Singular for most scales.
    // Note: 'hiljadu' is feminine, 'jednu hiljadu' (Acc.) is grammatically correct,
    // but 'hiljadu' is often used standalone for 1000. This function provides the base form.
    if (amount == BigInt.one) return forms["singular"]!;

    // Get last digit and last two digits for pluralization rules.
    final int lastDigit = (amount % BigInt.from(10)).toInt();
    final int lastTwoDigits = (amount % BigInt.from(100)).toInt();

    // Rule for 11-19: Use Genitive Plural.
    if (lastTwoDigits >= 11 && lastTwoDigits <= 19)
      return forms["genitivePlural"]!;
    // Rule for 2, 3, 4 (not preceded by 1): Use Nominative Plural.
    if (lastDigit >= 2 && lastDigit <= 4) return forms["plural2To4"]!;
    // Rule for 0, 1 (except 1 itself), 5-9: Use Genitive Plural.
    return forms["genitivePlural"]!;
  }

  /// Gets the correct plural form for a currency unit (main or subunit).
  ///
  /// Delegates to [_getPluralForm] after extracting the relevant forms
  /// (singular, plural2To4, genitivePlural) from the [CurrencyInfo] object.
  /// Uses [isSubunit] to determine whether to use main unit or subunit forms.
  String _getCurrencyPluralForm(
      BigInt amount, CurrencyInfo info, bool isSubunit) {
    Map<String, String> forms;
    // Select the correct set of forms based on whether it's a subunit or main unit.
    if (isSubunit) {
      // Ensure subunit forms are provided in CurrencyInfo.
      forms = {
        "singular": info.subUnitSingular!,
        "plural2To4": info.subUnitPlural2To4!,
        "genitivePlural": info.subUnitPluralGenitive!,
      };
    } else {
      // Ensure main unit forms are provided.
      forms = {
        "singular": info.mainUnitSingular,
        "plural2To4": info.mainUnitPlural2To4!,
        "genitivePlural": info.mainUnitPluralGenitive!,
      };
    }
    // Get the correct form based on the amount.
    return _getPluralForm(amount, forms);
  }

  /// Converts a non-negative [BigInt] [n] into its Serbian word representation.
  ///
  /// Breaks the number down by scales (thousand, million, etc.).
  /// Recursively calls itself or [_convertChunk] to convert parts.
  /// Uses [_getPluralForm] to get the correct scale word form.
  /// Determines required gender for the number part based on the scale word's gender.
  String _convertInteger(BigInt n, {Gender defaultGender = Gender.masculine}) {
    if (n < BigInt.zero)
      throw ArgumentError("Integer must be non-negative: $n");
    if (n == BigInt.zero) return _zero; // Base case: Zero
    // Handle numbers less than 1000 directly.
    if (n < BigInt.from(1000))
      return _convertChunk(n.toInt(), gender: defaultGender);

    // Define scales and their corresponding indices in _scaleWordForms.
    final scales = [
      BigInt.parse('1000000000000000000000000'), // Quadrillion 10^24
      BigInt.parse('1000000000000000000000'), // Trilliard   10^21
      BigInt.parse('1000000000000000000'), // Trillion    10^18
      BigInt.parse('1000000000000000'), // Billiard    10^15
      BigInt.parse('1000000000000'), // Billion     10^12
      BigInt.parse('1000000000'), // Milliard    10^9
      BigInt.parse('1000000'), // Million     10^6
      BigInt.from(1000), // Thousand    10^3
    ];
    // Indices match the order in _scaleWordForms (1:thousand, 2:million, ...).
    final scaleInfoIndices = [8, 7, 6, 5, 4, 3, 2, 1];

    List<String> parts = []; // Stores word chunks for each scale.
    BigInt currentRemainder = n; // The part of the number yet to be processed.

    // Iterate through scales from largest to smallest.
    for (int i = 0; i < scales.length; i++) {
      BigInt scaleValue = scales[i];
      int infoIndex = scaleInfoIndices[i];

      // Skip if scale index is invalid (safety check).
      if (infoIndex < 1 || infoIndex >= _scaleWordForms.length) continue;
      Map<String, String> scaleInfo = _scaleWordForms[infoIndex];

      // If the current remainder is large enough for this scale...
      if (currentRemainder >= scaleValue) {
        // Calculate how many times this scale fits.
        BigInt multiplier = currentRemainder ~/ scaleValue;
        // Update the remainder.
        currentRemainder %= scaleValue;

        // Determine the required gender for the multiplier based on the scale word's gender.
        Gender requiredGender = defaultGender; // Start with default
        final scaleGenderStr = scaleInfo["gender"];
        if (scaleGenderStr == "feminine") {
          requiredGender = Gender.feminine;
        } else if (scaleGenderStr == "masculine") {
          requiredGender = Gender.masculine;
        } // Add neuter if needed for future scales.

        String multiplierText;
        // Get the correct plural form of the scale word itself.
        String scaleWord = _getPluralForm(multiplier, scaleInfo);

        // Special case for "one thousand": use just "hiljadu" (singular form).
        if (infoIndex == 1 && multiplier == BigInt.one) {
          multiplierText = ""; // No "jednu" needed typically.
          scaleWord = scaleInfo["singular"]!; // Use "hiljadu".
        } else {
          // Convert the multiplier number part, applying the required gender.
          if (multiplier < BigInt.from(1000)) {
            multiplierText =
                _convertChunk(multiplier.toInt(), gender: requiredGender);
          } else {
            // Recursively call for large multipliers.
            multiplierText =
                _convertInteger(multiplier, defaultGender: requiredGender);
          }
        }

        // Combine multiplier text and scale word.
        String part =
            multiplierText.isEmpty ? scaleWord : "$multiplierText $scaleWord";
        parts.add(part);
      }
    }

    // Convert the final remainder (less than 1000).
    if (currentRemainder > BigInt.zero) {
      parts.add(_convertChunk(currentRemainder.toInt(), gender: defaultGender));
    }

    // Join all parts with spaces.
    return parts.join(' ');
  }

  /// Converts an integer [n] between 0 and 99 into Serbian words, applying [gender].
  ///
  /// Handles numbers 0-19 directly, applying gender for 1 and 2.
  /// Handles 20-99 by combining tens word and unit word (recursive call).
  String _convertUnder100(int n, {required Gender gender}) {
    if (n < 0 || n >= 100) throw ArgumentError("Number must be 0-99: $n");

    // Handle 0-19 directly.
    if (n < 20) {
      // Apply feminine gender specifically for 1 and 2.
      if (n == 1 && gender == Gender.feminine) return _oneFem;
      if (n == 2 && gender == Gender.feminine) return _twoFem;
      // Otherwise, use the default masculine form.
      return _wordsUnder20Masc[n];
    }

    // Handle 20-99.
    String tensWord = _wordsTens[
        n ~/ 10]; // Get the word for the ten (dvadeset, trideset...).
    int unit = n % 10; // Get the unit digit.
    if (unit == 0) return tensWord; // If unit is 0, just return the tens word.

    // If unit is non-zero, recursively call for the unit, applying gender.
    String unitWord = _convertUnder100(unit, gender: gender);
    // Combine tens and unit words with a space.
    return "$tensWord $unitWord"; // e.g., "dvadeset" + " " + "jedan" -> "dvadeset jedan"
  }

  /// Converts an integer [n] between 0 and 999 into Serbian words, applying [gender].
  ///
  /// Handles hundreds place first, then the remaining 0-99 part using [_convertUnder100].
  /// Joins parts with spaces where needed.
  String _convertChunk(int n, {required Gender gender}) {
    if (n == 0) return ""; // Return empty for zero.
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    List<String> words = [];
    int remainder = n;

    // Handle hundreds place.
    if (remainder >= 100) {
      words.add(_wordsHundreds[remainder ~/ 100]); // Add "sto", "dvesta", etc.
      remainder %= 100; // Update remainder to 0-99.
    }

    // Handle remaining 0-99 part.
    if (remainder > 0) {
      // Add a space if there was a hundreds part before.
      // Corrected: Serbian usually doesn't put a space here, e.g., "sto dvadeset", not "sto  dvadeset".
      // if (words.isNotEmpty) words.add(" "); // Removed space addition here.

      // Convert the 0-99 part using the specified gender.
      words.add(_convertUnder100(remainder, gender: gender));
    }

    // Join the parts (hundreds and tens/units) with a space.
    return words
        .join(" "); // Join with space, e.g., "dvesta" + " " + "trideset pet"
  }
}
