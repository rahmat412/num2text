import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/hr_options.dart';
import '../utils/utils.dart';

/// {@template num2text_hr}
/// Converts numbers to Croatian words (`Lang.HR`).
///
/// Implements [Num2TextBase] for Croatian, handling various numeric types.
/// Pays close attention to Croatian grammar, including number agreement (singular,
/// paucal, plural) for scale words and units.
///
/// Supports:
/// - Cardinal numbers with correct grammatical agreement.
/// - Currency formatting (using `HrOptions.currencyInfo` and grammatical cases).
/// - Year formatting (with optional AD/BC suffixes).
/// - Decimals (using "zarez" or "točka").
/// - Negative numbers.
/// - Large numbers (using short scale with Croatian grammatical forms).
///
/// Customizable via [HrOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextHR implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "nula";
  static const String _point = "točka"; // Decimal separator "point"
  static const String _comma =
      "zarez"; // Decimal separator "comma" (common in HR)
  static const String _and = "i"; // Conjunction "and", used in currency.
  static const String _yearSuffixBC = "prije Krista"; // "before Christ"
  static const String _yearSuffixAD = "nove ere"; // "of the new era"

  // Hundreds (100-900)
  static const List<String> _hundreds = [
    "",
    "sto",
    "dvjesto",
    "tristo",
    "četiristo",
    "petsto",
    "šesto",
    "sedamsto",
    "osamsto",
    "devetsto",
  ];

  // Numbers 0-19 (base forms, masculine/neuter for 1, 2)
  static const List<String> _wordsUnder20 = [
    "nula",
    "jedan",
    "dva",
    "tri",
    "četiri",
    "pet",
    "šest",
    "sedam",
    "osam",
    "devet",
    "deset",
    "jedanaest",
    "dvanaest",
    "trinaest",
    "četrnaest",
    "petnaest",
    "šesnaest",
    "sedamnaest",
    "osamnaest",
    "devetnaest",
  ];

  // Feminine form for "one" (used with feminine nouns like tisuća, milijarda)
  static const String _oneFeminine = "jedna";
  // Feminine form for "two" (used with feminine nouns like tisuća, milijarda)
  static const String _twoFeminine = "dvije";

  // Tens (20-90)
  static const List<String> _wordsTens = [
    "",
    "",
    "dvadeset",
    "trideset",
    "četrdeset",
    "pedeset",
    "šezdeset",
    "sedamdeset",
    "osamdeset",
    "devedeset",
  ];

  /// Defines scale words and their required grammatical forms based on the preceding number.
  /// Index 0: Singular (used with 1, e.g., "jedan milijun"). Assumed Nominative Singular.
  /// Index 1: Paucal (used with 2-4, e.g., "dva milijuna", "tri tisuće"). Assumed Nominative Plural or Genitive Singular.
  /// Index 2: Plural (used with 0, 5+, 11-19, e.g., "pet milijuna"). Assumed Genitive Plural.
  static const Map<int, List<String>> _scaleWords = {
    // Scale Index: [Singular (1), Paucal (2-4), Plural (0, 5+)]
    1: [
      "tisuću",
      "tisuće",
      "tisuća"
    ], // Thousand (fem) - Acc.Sg, Nom.Pl, Gen.Pl
    2: [
      "milijun",
      "milijuna",
      "milijuna"
    ], // Million (masc) - Nom.Sg, Gen.Sg, Gen.Pl
    3: [
      "milijarda",
      "milijarde",
      "milijardi"
    ], // Billion (fem) - Nom.Sg, Gen.Sg, Gen.Pl
    4: [
      "bilijun",
      "bilijuna",
      "bilijuna"
    ], // Trillion (masc) - Nom.Sg, Gen.Sg, Gen.Pl
    5: [
      "bilijarda",
      "bilijarde",
      "bilijardi"
    ], // Quadrillion (fem) - Nom.Sg, Gen.Sg, Gen.Pl
    6: [
      "trilijun",
      "trilijuna",
      "trilijuna"
    ], // Quintillion (masc) - Nom.Sg, Gen.Sg, Gen.Pl
    7: [
      "trilijarda",
      "trilijarde",
      "trilijardi"
    ], // Sextillion (fem) - Nom.Sg, Gen.Sg, Gen.Pl
    8: [
      "kvadrilijun",
      "kvadrilijuna",
      "kvadrilijuna"
    ], // Septillion (masc) - Nom.Sg, Gen.Sg, Gen.Pl
  };

  /// Processes the given [number] into Croatian words.
  ///
  /// {@template num2text_process_intro_hr}
  /// Normalizes input to [Decimal]. Handles `Infinity`, `NaN`.
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options_hr}
  /// Uses [HrOptions] for customization (currency, year format, decimal separator, AD/BC, negative prefix).
  /// Defaults apply if [options] is null or not [HrOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors_hr}
  /// Returns [fallbackOnError] or "Nije broj" on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [HrOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Croatian words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final hrOptions = options is HrOptions ? options : const HrOptions();
    const String defaultFallback = "Nije broj"; // "Not a number"

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Negativna beskonačnost" : "Beskonačnost";
      if (number.isNaN) return fallbackOnError ?? defaultFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return fallbackOnError ?? defaultFallback;

    if (decimalValue == Decimal.zero) {
      if (hrOptions.currency) {
        // Use _getUnitName to find the correct plural (genitive) form for zero units.
        final zeroUnit = _getUnitName(
          BigInt.zero,
          singular: hrOptions.currencyInfo.mainUnitSingular,
          plural: hrOptions.currencyInfo.mainUnitPlural,
          pluralGenitive: hrOptions.currencyInfo.mainUnitPluralGenitive,
        );
        return "$_zero $zeroUnit"; // e.g., "nula eura"
      } else {
        return _zero;
      }
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    if (hrOptions.format == Format.year) {
      // Year formatting handles negativity internally with suffixes.
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), hrOptions);
    } else {
      if (hrOptions.currency) {
        textResult = _handleCurrency(absValue, hrOptions);
      } else {
        textResult = _handleStandardNumber(absValue, hrOptions);
      }
      // Prepend negative prefix if applicable.
      if (isNegative) {
        textResult = "${hrOptions.negativePrefix} $textResult";
      }
    }

    return textResult.trim();
  }

  /// Formats an integer as a Croatian calendar year.
  ///
  /// Appends "prije Krista" for negative years or "nove ere" for positive years
  /// if `options.includeAD` is true.
  ///
  /// @param year The integer year.
  /// @param options The [HrOptions] for formatting control.
  /// @return The year formatted as Croatian words.
  String _handleYearFormat(int year, HrOptions options) {
    if (year == 0)
      return _zero; // Or potentially an error/specific word for year zero.

    final bool isNegative = year < 0;
    final BigInt absYear = BigInt.from(isNegative ? -year : year);

    // Convert the absolute year value using standard integer conversion.
    String yearText = _convertInteger(absYear);

    // Append era suffixes.
    if (isNegative) {
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD) {
      yearText += " $_yearSuffixAD";
    }

    return yearText;
  }

  /// Formats a non-negative [Decimal] value as Croatian currency.
  ///
  /// Applies grammatical agreement rules using `_getUnitName` helper.
  /// Handles rounding based on `options.round`. Uses separator from `CurrencyInfo` or "i".
  ///
  /// @param absValue The absolute decimal value of the currency.
  /// @param options The [HrOptions] with currency info and formatting flags.
  /// @return The currency value formatted as Croatian words.
  String _handleCurrency(Decimal absValue, HrOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2;
    final Decimal subunitMultiplier = Decimal.parse("100");

    // Round or use exact value based on options.
    final Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Use truncate for subunits (rounding typically applies to the whole value).
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).truncate().toBigInt();

    String mainPartText = '';
    if (mainValue > BigInt.zero) {
      // Convert the main number part.
      String mainText = _convertInteger(mainValue);
      // Get the grammatically correct main unit name.
      String mainUnitName = _getUnitName(
        mainValue,
        singular: currencyInfo.mainUnitSingular,
        plural: currencyInfo.mainUnitPlural,
        plural2To4: currencyInfo.mainUnitPlural2To4,
        pluralGenitive: currencyInfo.mainUnitPluralGenitive,
      );
      mainPartText = '$mainText $mainUnitName';
    }

    String subunitPartText = '';
    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      // Convert the subunit number part.
      String subunitText = _convertInteger(subunitValue);
      // Get the grammatically correct subunit name.
      String subUnitName = _getUnitName(
        subunitValue,
        singular:
            currencyInfo.subUnitSingular!, // Assured non-null by check above.
        plural: currencyInfo.subUnitPlural,
        plural2To4: currencyInfo.subUnitPlural2To4,
        pluralGenitive: currencyInfo.subUnitPluralGenitive,
      );
      subunitPartText = '$subunitText $subUnitName';
    }

    // Combine the main and subunit parts.
    if (mainPartText.isNotEmpty && subunitPartText.isNotEmpty) {
      String separator = currencyInfo.separator ??
          _and; // Use custom separator or default "i".
      return '$mainPartText $separator $subunitPartText';
    } else if (mainPartText.isNotEmpty) {
      return mainPartText; // Only main part.
    } else if (subunitPartText.isNotEmpty) {
      return subunitPartText; // Only subunit part (handles 0.xx).
    } else {
      // Both zero (already handled in 'process'), but provide fallback.
      String zeroUnit = _getUnitName(
        BigInt.zero,
        singular: currencyInfo.mainUnitSingular,
        plural: currencyInfo.mainUnitPlural,
        pluralGenitive: currencyInfo.mainUnitPluralGenitive,
      );
      return '$_zero $zeroUnit'; // e.g., "nula eura"
    }
  }

  /// Determines the correct grammatical form (case/number) of a unit name based on the quantity.
  ///
  /// Applies standard Croatian agreement rules:
  /// - Ends in 1 (not 11): Singular (Nominative). Uses `singular`.
  /// - Ends in 2, 3, 4 (not 12-14): Paucal. Uses `plural2To4` or fallback.
  /// - Ends in 0, 5-9, or 11-19: Plural (Genitive). Uses `pluralGenitive` or fallback.
  /// Prioritizes specific forms (`plural2To4`, `pluralGenitive`) if provided.
  ///
  /// @param value The quantity (non-negative BigInt).
  /// @param singular The singular nominative form (for 1, 21, 31...).
  /// @param plural General plural form (fallback).
  /// @param plural2To4 Specific paucal form (for 2-4, 22-24...). Often Nom.Pl or Gen.Sg.
  /// @param pluralGenitive Specific genitive plural form (for 0, 5+, 11-19...).
  /// @return The appropriate unit name string based on the value.
  String _getUnitName(BigInt value,
      {required String singular,
      String? plural,
      String? plural2To4,
      String? pluralGenitive}) {
    // Define fallbacks: specific -> general plural -> singular.
    final paucalFallback = plural2To4 ?? plural ?? singular;
    final pluralFallback = pluralGenitive ?? plural ?? paucalFallback;

    // 0 takes the Genitive Plural form in counting/currency contexts.
    if (value == BigInt.zero) {
      return pluralGenitive ?? pluralFallback;
    }

    // Use absolute value for checks.
    final int lastDigit = (value % BigInt.from(10)).toInt();
    final int lastTwoDigits = (value % BigInt.from(100)).toInt();

    // Paucal check: ends in 2, 3, 4 but NOT 12, 13, 14.
    if (lastDigit >= 2 &&
        lastDigit <= 4 &&
        (lastTwoDigits < 12 || lastTwoDigits > 14)) {
      return plural2To4 ?? paucalFallback;
    }
    // Singular check: ends in 1 but NOT 11.
    else if (lastDigit == 1 && lastTwoDigits != 11) {
      return singular;
    }
    // Plural (Genitive) check: all other cases (ends in 0, 5-9, or 11-19).
    else {
      return pluralGenitive ?? pluralFallback;
    }
  }

  /// Formats a non-negative standard [Decimal] number to Croatian words.
  ///
  /// Converts integer and fractional parts. Uses the decimal separator word
  /// from [HrOptions]. Fractional part converted digit by digit after removing trailing zeros.
  ///
  /// @param absValue Absolute decimal value.
  /// @param options The [HrOptions] for formatting control (decimal separator).
  /// @return Number as Croatian words.
  String _handleStandardNumber(Decimal absValue, HrOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part. Output "nula" if integer is 0 but fraction exists.
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word ("zarez" or "točka"). Default to "zarez".
      String separatorWord;
      switch (options.decimalSeparator ?? DecimalSeparator.comma) {
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          separatorWord = _point;
          break;
        case DecimalSeparator.comma:
          separatorWord = _comma;
          break;
      }

      // Extract fractional digits, remove trailing zeros.
      String fractionalString = absValue.toString();
      String fractionalDigits = fractionalString.contains('.')
          ? fractionalString.split('.').last
          : '';
      // Remove trailing zeros efficiently.
      fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      // Convert remaining digits individually.
      if (fractionalDigits.isNotEmpty) {
        List<String> digitWords = fractionalDigits.split('').map((digit) {
          int digitInt = int.parse(digit);
          return _wordsUnder20[digitInt]; // Digits 0-9 use base words.
        }).toList();
        fractionalWords =
            ' $separatorWord ${digitWords.join(' ')}'; // e.g., " zarez pet šest"
      }
    }

    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer ([BigInt]) into Croatian words.
  ///
  /// Handles large numbers by chunking and applying scale words with correct grammar.
  /// Uses `_getScaleFormIndex` and `_convertChunkFeminineTwo` for grammatical agreement.
  ///
  /// @param n The non-negative BigInt number.
  /// @throws ArgumentError If n is negative or exceeds defined scales.
  /// @return The integer as Croatian words.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");

    // Direct conversion for numbers under 1000.
    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt());
    }

    List<String> parts = []; // Stores word representations of each scale chunk.
    BigInt remaining = n;
    int scaleIndex = 0; // 0: units, 1: thousands, 2: millions, ...

    while (remaining > BigInt.zero) {
      BigInt chunkBigInt = remaining % BigInt.from(1000);
      remaining ~/= BigInt.from(1000);
      int chunkInt = chunkBigInt.toInt(); // Safe as chunk <= 999.

      if (chunkBigInt > BigInt.zero) {
        // Convert the 1-999 chunk first.
        String chunkText = _convertChunk(chunkInt);

        if (scaleIndex > 0) {
          // This is a scale chunk (thousands, millions...).
          if (!_scaleWords.containsKey(scaleIndex)) {
            throw ArgumentError(
                "Number too large, scale index $scaleIndex not defined.");
          }
          final scaleNames =
              _scaleWords[scaleIndex]!; // [singular, paucal, plural]

          // Determine grammatical form based on the chunk value (1, 2-4, 5+).
          int formIndex = _getScaleFormIndex(chunkBigInt);
          String scaleWord =
              scaleNames[formIndex]; // Get the correct scale word form.

          // Special handling for "tisuću" (thousand - scale index 1).
          if (scaleIndex == 1) {
            // Thousands scale.
            if (formIndex == 0) {
              // Chunk is 1 (e.g., 1000).
              chunkText = ""; // "jedan" is omitted before "tisuću".
              scaleWord = scaleNames[0]; // "tisuću" (Accusative Singular).
            } else {
              // Chunk is 2-4 or 5+.
              scaleWord = scaleNames[
                  formIndex]; // "tisuće" (paucal) or "tisuća" (plural).
              // Use feminine "dvije" if chunk is 2, 22, etc. (paucal form), as 'tisuća' is feminine.
              if (formIndex == 1 &&
                  chunkInt % 10 == 2 &&
                  chunkInt % 100 != 12) {
                chunkText = _convertChunkFeminineTwo(chunkInt);
              }
              // For 3, 4, 5+, standard chunkText is correct.
            }
          }
          // Handling for other scales (million, billion...).
          else {
            // Check if the scale noun itself is feminine (Nom. Sg. ends in 'a').
            bool isFeminineScale =
                scaleNames[0].endsWith('a'); // e.g., milijarda, bilijarda.

            if (formIndex == 0) {
              // Chunk is 1 (e.g., 1 million).
              // Use "jedna" if scale is feminine, "jedan" otherwise.
              chunkText = isFeminineScale ? _oneFeminine : _wordsUnder20[1];
            } else if (formIndex == 1) {
              // Chunk is 2-4 (paucal).
              // Use "dvije" if scale is feminine and chunk ends in 2 (not 12).
              if (isFeminineScale &&
                  chunkInt % 10 == 2 &&
                  chunkInt % 100 != 12) {
                chunkText = _convertChunkFeminineTwo(chunkInt);
              }
              // Otherwise, default chunkText ("dva", "tri", "četiri") is fine.
            }
            // For plural form (formIndex == 2), standard chunkText is always correct.
          }
          // Add the potentially modified chunk text and the scale word.
          parts.add("$chunkText $scaleWord".trim());
        } else {
          // Units chunk (scaleIndex == 0): just add its text.
          parts.add(chunkText);
        }
      }
      scaleIndex++;
    }

    // Join parts from highest scale down, separated by spaces.
    return parts.reversed.join(' ').trim();
  }

  /// Converts a chunk (0-999), ensuring 'two' is feminine ('dvije') if needed.
  ///
  /// Used before feminine nouns (tisuća, milijarda). Converts normally, then replaces
  /// a trailing "dva" with "dvije" if the original chunk value ends in 2 (but not 12).
  ///
  /// @param n The integer chunk (0-999).
  /// @return The chunk text, potentially with "dvije" instead of "dva".
  String _convertChunkFeminineTwo(int n) {
    String text = _convertChunk(n); // Get standard conversion.
    // Check if it ends with masculine "dva" AND the original number ends in 2 (not 12).
    if (text.endsWith(_wordsUnder20[2]) && n % 10 == 2 && n % 100 != 12) {
      // Replace trailing "dva" with feminine "dvije".
      return text.substring(0, text.length - _wordsUnder20[2].length) +
          _twoFeminine;
    }
    return text; // Return original if no replacement needed.
  }

  /// Determines the scale word grammatical form index (0=singular, 1=paucal, 2=plural) based on the preceding number chunk.
  ///
  /// @param chunkValue The value (1-999) preceding the scale word.
  /// @return 0, 1, or 2 corresponding to the required form.
  int _getScaleFormIndex(BigInt chunkValue) {
    // Rule application based on Croatian grammar for counting.
    int lastDigit = (chunkValue % BigInt.from(10)).toInt();
    int lastTwoDigits = (chunkValue % BigInt.from(100)).toInt();

    // Singular: ends in 1, but not 11.
    if (lastDigit == 1 && lastTwoDigits != 11) {
      return 0; // Singular
    }
    // Paucal: ends in 2, 3, 4, but not 12, 13, 14.
    else if (lastDigit >= 2 &&
        lastDigit <= 4 &&
        (lastTwoDigits < 12 || lastTwoDigits > 14)) {
      return 1; // Paucal
    }
    // Plural (Genitive): ends in 0, 5-9, or 11-19.
    else {
      return 2; // Plural
    }
  }

  /// Converts an integer between 0 and 999 into Croatian words.
  ///
  /// Handles hundreds, tens, and units straightforwardly.
  ///
  /// @param n The integer chunk (0-999).
  /// @throws ArgumentError If n is outside the valid range.
  /// @return The chunk as Croatian words, or empty string for 0.
  String _convertChunk(int n) {
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");
    if (n == 0) return "";

    if (n < 20) return _wordsUnder20[n]; // Direct lookup for 0-19.

    List<String> words = [];
    int remainder = n;

    // Handle hundreds.
    int hundredsDigit = remainder ~/ 100;
    if (hundredsDigit > 0) {
      words.add(_hundreds[hundredsDigit]); // "sto", "dvjesto", ...
      remainder %= 100;
      // Add space only if tens/units follow.
      if (remainder > 0) {
        words.add(" ");
      }
    }

    // Handle tens and units (remainder is now 0-99).
    if (remainder >= 20) {
      int tensDigit = remainder ~/ 10;
      int unitDigit = remainder % 10;
      words.add(_wordsTens[tensDigit]); // "dvadeset", "trideset", ...
      if (unitDigit > 0) {
        words.add(" "); // Space before unit.
        words.add(_wordsUnder20[unitDigit]); // "jedan", "dva", ...
      }
    } else if (remainder > 0) {
      // Handle remaining 1-19 (e.g., in "sto dvanaest").
      words.add(_wordsUnder20[remainder]);
    }

    // Join parts without extra spaces (spaces were added explicitly).
    return words.join("");
  }
}
