import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/hr_options.dart';
import '../utils/utils.dart';

/// {@template num2text_hr}
/// The Croatian language (`Lang.HR`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Croatian word representation following Croatian grammar rules, including
/// case and number agreement for scale words.
///
/// Capabilities include handling cardinal numbers, currency (using [HrOptions.currencyInfo],
/// typically Euro for modern usage), year formatting ([Format.year]), negative numbers,
/// decimals, and large numbers (short scale with Croatian grammar).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [HrOptions].
/// {@endtemplate}
class Num2TextHR implements Num2TextBase {
  /// The word for zero.
  static const String _zero = "nula";

  /// The word for the decimal separator when using [DecimalSeparator.period] or [DecimalSeparator.point].
  static const String _point = "točka";

  /// The word for the decimal separator when using [DecimalSeparator.comma] (default).
  static const String _comma = "zarez";

  /// The conjunction "and", used primarily in currency formatting between main and subunits.
  static const String _and = "i";

  /// Suffix added to negative years when using [Format.year]. Translates to "before Christ".
  static const String _yearSuffixBC = "prije Krista";

  /// Suffix added to positive years when using [Format.year] and the `includeAD` option is true.
  /// Translates to "of the new era".
  static const String _yearSuffixAD = "nove ere";

  /// Base words for hundreds (100, 200, ..., 900). Index corresponds to the digit.
  static const List<String> _hundreds = [
    "", // 0 hundred (unused directly)
    "sto", // 100
    "dvjesto", // 200
    "tristo", // 300
    "četiristo", // 400
    "petsto", // 500
    "šesto", // 600
    "sedamsto", // 700
    "osamsto", // 800
    "devetsto", // 900
  ];

  /// Base words for numbers 0 through 19. Note: "jedan" and "dva" are masculine/neuter forms.
  static const List<String> _wordsUnder20 = [
    "nula", // 0
    "jedan", // 1 (masculine/neuter)
    "dva", // 2 (masculine/neuter)
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

  /// Feminine form for "one". Used with feminine nouns like 'tisuća', 'milijarda'.
  static const String _oneFeminine = "jedna";

  /// Feminine form for "two". Used with feminine nouns like 'tisuća', 'milijarda'.
  static const String _twoFeminine = "dvije";

  /// Base words for tens (10, 20, ..., 90). Index corresponds to the tens digit.
  static const List<String> _wordsTens = [
    "", // 0 tens (unused)
    "deset", // 10 (also in _wordsUnder20)
    "dvadeset", // 20
    "trideset", // 30
    "četrdeset", // 40
    "pedeset", // 50
    "šezdeset", // 60
    "sedamdeset", // 70
    "osamdeset", // 80
    "devedeset", // 90
  ];

  /// Defines scale words (thousand, million, etc.) and their required grammatical forms.
  /// Croatian requires different forms based on the preceding number:
  /// - Index 0: Singular form (used with 1, e.g., "jedan milijun").
  /// - Index 1: Paucal form (used with 2, 3, 4, e.g., "dva milijuna", "tri tisuće").
  /// - Index 2: Plural form (Genitive Plural) (used with 0, 5+, 11-19, e.g., "pet milijuna", "dvanaest tisuća").
  /// Special handling applies to 'tisuću' (1000).
  static const Map<int, List<String>> _scaleWords = {
    // Scale Index: [Singular (1), Paucal (2-4), Plural (0, 5+)]
    1: ["tisuću", "tisuće", "tisuća"], // Thousand (feminine)
    2: ["milijun", "milijuna", "milijuna"], // Million (masculine)
    3: ["milijarda", "milijarde", "milijardi"], // Billion (feminine)
    4: ["bilijun", "bilijuna", "bilijuna"], // Trillion (masculine)
    5: ["bilijarda", "bilijarde", "bilijardi"], // Quadrillion (feminine)
    6: ["trilijun", "trilijuna", "trilijuna"], // Quintillion (masculine)
    7: ["trilijarda", "trilijarde", "trilijardi"], // Sextillion (feminine)
    8: [
      "kvadrilijun",
      "kvadrilijuna",
      "kvadrilijuna"
    ], // Septillion (masculine)
    // Additional scales can be added here following the pattern.
  };

  /// Processes the given number into Croatian words based on the provided options.
  ///
  /// [number] The number to convert (can be int, double, BigInt, String, Decimal).
  /// [options] Optional [HrOptions] to control formatting (currency, year, decimals, etc.).
  /// If null or not an instance of [HrOptions], default options are used.
  /// [fallbackOnError] A custom string to return if conversion fails (e.g., invalid input).
  /// If null, default Croatian error message ("Nije broj") is used.
  /// Returns the number converted to Croatian words, or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Use provided HrOptions or default if none/invalid provided.
    final hrOptions = options is HrOptions ? options : const HrOptions();
    const String defaultFallback = "Nije broj"; // "Not a number"

    // Handle special double values first.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? "Negativna beskonačnost"
            : "Beskonačnost"; // Negative/Positive Infinity
      }
      if (number.isNaN) {
        return fallbackOnError ?? defaultFallback;
      }
    }

    // Normalize the input number to Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // If normalization fails, return error string.
    if (decimalValue == null) {
      return fallbackOnError ?? defaultFallback;
    }

    // Handle zero specifically.
    if (decimalValue == Decimal.zero) {
      // Currency format requires the unit name even for zero.
      if (hrOptions.currency) {
        // Default to plural genitive form for zero units (common practice).
        final zeroUnit = hrOptions
                .currencyInfo.mainUnitPlural ?? // Use plural form if available
            hrOptions.currencyInfo.mainUnitSingular; // Fallback to singular
        return "$_zero $zeroUnit"; // e.g., "nula eura"
      } else {
        // Standard zero.
        return _zero;
      }
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for conversion logic.
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    // Delegate to specific handlers based on options.
    if (hrOptions.format == Format.year) {
      // Year format handles negativity internally.
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), hrOptions);
    } else {
      // Handle currency or standard number.
      if (hrOptions.currency) {
        textResult = _handleCurrency(absValue, hrOptions);
      } else {
        textResult = _handleStandardNumber(absValue, hrOptions);
      }
      // Add negative prefix if applicable *after* conversion for non-year formats.
      if (isNegative) {
        textResult = "${hrOptions.negativePrefix} $textResult";
      }
    }

    // Return the final result, trimming any extra whitespace.
    return textResult.trim();
  }

  /// Formats an integer as a Croatian year.
  ///
  /// Handles negative years by appending the BC suffix ("prije Krista").
  /// Optionally handles positive years by appending the AD suffix ("nove ere")
  /// if `options.includeAD` is true.
  ///
  /// [year] The integer year to format.
  /// [options] The [HrOptions] containing formatting flags like `includeAD`.
  /// Returns the year formatted as Croatian words.
  String _handleYearFormat(int year, HrOptions options) {
    if (year == 0) return _zero; // Handle year 0 input.

    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;
    final BigInt bigAbsYear = BigInt.from(absYear);

    // Convert the absolute year value to words.
    String yearText = _convertInteger(bigAbsYear);

    // Append appropriate era suffix based on sign and options.
    if (isNegative) {
      yearText += " $_yearSuffixBC"; // Always add BC for negative years.
    } else if (options.includeAD) {
      // Only add AD suffix for positive years if requested.
      yearText += " $_yearSuffixAD";
    }

    return yearText;
  }

  /// Formats a positive Decimal number as Croatian currency.
  ///
  /// Uses the `currencyInfo` from the options to determine unit names and separator.
  /// Applies Croatian grammatical rules for unit name agreement based on the quantity.
  /// Handles rounding or exact subunit conversion based on `options.round`.
  ///
  /// [absValue] The absolute Decimal value of the currency amount.
  /// [options] The [HrOptions] containing currency info and rounding rules.
  /// Returns the currency amount formatted as Croatian words.
  String _handleCurrency(Decimal absValue, HrOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2; // Standard currency subunit precision.
    final Decimal subunitMultiplier = Decimal.parse("100");

    // Round the value if requested, otherwise use the exact value.
    final Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main and subunit values.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Use truncate for subunits; rounding usually applies to the total amount.
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).truncate().toBigInt();

    // Convert the main value to words.
    String mainText = _convertInteger(mainValue);

    // Determine the correct grammatical form for the main unit name.
    String mainUnitName = _getUnitName(
      mainValue,
      singular: currencyInfo.mainUnitSingular,
      paucal: currencyInfo
          .mainUnitPlural, // Using plural form for paucal as common fallback
      plural: currencyInfo.mainUnitPlural, // Plural form
    );

    String result = '$mainText $mainUnitName';

    // Add subunit part if it exists and subunit info is available.
    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      // Convert subunit value to words.
      String subunitText = _convertInteger(subunitValue);

      // Determine the correct grammatical form for the subunit name.
      String subUnitName = _getUnitName(
        subunitValue,
        singular: currencyInfo.subUnitSingular!,
        paucal: currencyInfo
            .subUnitPlural, // Fallback to plural if specific paucal not given
        plural: currencyInfo.subUnitPlural,
      );

      // Use the specified separator or default to "i".
      String separator = currencyInfo.separator ?? _and;
      result += ' $separator $subunitText $subUnitName';
    }

    return result;
  }

  /// Helper function to determine the correct grammatical form of a unit name based on quantity.
  ///
  /// Applies standard Croatian agreement rules:
  /// - Ends in 1 (but not 11): Singular (Nominative)
  /// - Ends in 2, 3, 4 (but not 12, 13, 14): Paucal (Nominative/Accusative Plural)
  /// - Ends in 0, 5-9, or 11-19: Plural (Genitive Plural)
  ///
  /// [value] The quantity determining the form.
  /// [singular] The singular nominative form of the unit name (for 1).
  /// [paucal] The paucal form (for 2-4). Optional; defaults to `plural`.
  /// [plural] The plural genitive form (for 0, 5+). Optional; defaults to `paucal` or `singular`.
  /// Returns the appropriate unit name string.
  String _getUnitName(BigInt value,
      {required String singular, String? paucal, String? plural}) {
    // Define fallbacks: paucal uses plural if null, plural uses paucal if null, both fallback to singular.
    final paucalForm = paucal ?? plural ?? singular;
    final pluralForm = plural ?? paucalForm;

    // Simple case for 1.
    if (value == BigInt.one) {
      return singular;
    }

    // Get last digit and last two digits for grammatical checks.
    int lastDigit = (value % BigInt.from(10)).toInt();
    int lastTwoDigits = (value % BigInt.from(100)).toInt();

    // Check for paucal: ends in 2, 3, 4 but not 12, 13, 14.
    if (lastDigit >= 2 &&
        lastDigit <= 4 &&
        (lastTwoDigits < 12 || lastTwoDigits > 14)) {
      return paucalForm;
    } else {
      // Otherwise (0, 5-9, 11-19), use plural (genitive) form.
      return pluralForm;
    }
  }

  /// Formats a positive Decimal number with potential fractional part into Croatian words.
  ///
  /// Converts the integer part and the fractional part separately.
  /// Uses the decimal separator word specified in `options.decimalSeparator`.
  /// Converts fractional digits individually. Removes trailing zeros from the decimal part.
  ///
  /// [absValue] The absolute Decimal value to convert.
  /// [options] The [HrOptions] containing decimal separator preference.
  /// Returns the number formatted as Croatian words.
  String _handleStandardNumber(Decimal absValue, HrOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part. If integer part is zero but there's a fraction, output "nula".
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word based on options.
      String separatorWord;
      switch (options.decimalSeparator ?? DecimalSeparator.comma) {
        // Default to comma
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          separatorWord = _point; // "točka"
          break;
        case DecimalSeparator.comma:
          separatorWord = _comma; // "zarez"
          break;
      }

      // Extract fractional digits, removing trailing zeros.
      String fractionalString = absValue.toString();
      String fractionalDigits = fractionalString.contains('.')
          ? fractionalString.split('.').last
          : '';
      fractionalDigits = fractionalDigits.replaceAll(
          RegExp(r'0+$'), ''); // Remove trailing zeros

      // Convert each remaining fractional digit to its word representation.
      if (fractionalDigits.isNotEmpty) {
        List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          // Use wordsUnder20 for single digits 0-9.
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder20[digitInt]
              : '?'; // Fallback for non-digit characters
        }).toList();
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }

    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer ([BigInt]) into Croatian words.
  ///
  /// Handles large numbers by breaking them into chunks of three digits (thousands, millions, etc.)
  /// and applying the correct scale words with appropriate grammatical agreement based on the chunk value.
  ///
  /// [n] The non-negative BigInt number to convert.
  /// Throws [ArgumentError] if the number is negative or exceeds defined scales.
  /// Returns the integer converted to Croatian words.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");

    // Handle numbers less than 1000 directly.
    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt());
    }

    List<String> parts = []; // Stores word representations of each scale chunk.
    BigInt remaining = n; // The part of the number yet to be converted.
    int scaleIndex = 0; // 0: units chunk, 1: thousands, 2: millions, etc.

    while (remaining > BigInt.zero) {
      // Process the number in chunks of 1000 from right to left.
      BigInt chunkBigInt = remaining % BigInt.from(1000);
      remaining ~/= BigInt.from(1000); // Move to the next chunk.
      int chunkInt = chunkBigInt.toInt(); // Safe conversion as chunk <= 999.

      if (chunkBigInt > BigInt.zero) {
        // Convert the current chunk (1-999) to words initially.
        String chunkText = _convertChunk(chunkInt);

        if (scaleIndex > 0) {
          // This is a scale chunk (thousands, millions...).
          // Ensure the scale index is defined.
          if (!_scaleWords.containsKey(scaleIndex)) {
            throw ArgumentError(
                "Number too large, scale index $scaleIndex not defined.");
          }
          final scaleNames =
              _scaleWords[scaleIndex]!; // [singular, paucal, plural]

          // Determine the correct grammatical form index based on the chunk value.
          int formIndex = _getScaleFormIndex(chunkBigInt);

          String scaleWord;
          // Special handling for "tisuću" (thousand - scale index 1).
          if (scaleIndex == 1) {
            if (formIndex == 0) {
              // Chunk is 1 (e.g., 1000).
              scaleWord = scaleNames[0]; // "tisuću".
              chunkText = ""; // "jedan" is omitted before "tisuću".
            } else {
              // Chunk is 2-4 or 5+.
              scaleWord = scaleNames[formIndex]; // "tisuće" or "tisuća".
              // Use feminine "dvije" for 2000, 22000, etc., as 'tisuća' is feminine.
              if (formIndex == 1 &&
                  chunkInt % 10 == 2 &&
                  chunkInt % 100 != 12) {
                chunkText = _convertChunkFeminineTwo(chunkInt);
              }
              // For other paucal (3, 4) or plural (5+) numbers, the standard chunkText is correct.
            }
          }
          // Handling for other scales (million, billion, etc.).
          else {
            scaleWord =
                scaleNames[formIndex]; // Get the correct scale word form.
            // Check if the scale noun itself is feminine (ends in 'a').
            bool isFeminineScale =
                scaleNames[0].endsWith('a'); // e.g., milijarda, bilijarda.

            if (formIndex == 0) {
              // Chunk is 1 (e.g., 1,000,000). Use feminine "jedna" if scale is feminine.
              chunkText = isFeminineScale
                  ? _oneFeminine
                  : _wordsUnder20[1]; // Use "jedan" otherwise.
            } else if (formIndex == 1) {
              // Chunk is 2-4. Use feminine "dvije" if scale is feminine and chunk ends in 2 (not 12).
              if (isFeminineScale &&
                  chunkInt % 10 == 2 &&
                  chunkInt % 100 != 12) {
                chunkText = _convertChunkFeminineTwo(chunkInt);
              }
              // Otherwise, the default chunkText (using "dva", "tri", "četiri") is correct.
            }
            // No change needed for formIndex == 2 (plural) chunkText.
          }

          // Add the potentially modified chunk text and the scale word.
          parts.add("$chunkText $scaleWord".trim());
        } else {
          // If it's the first (units) chunk (scaleIndex == 0), just add its text.
          parts.add(chunkText);
        }
      }
      // Increment scale index for the next chunk.
      scaleIndex++;
    }

    // Join the parts in reverse order (scales processed from lowest to highest).
    return parts.reversed.join(' ').trim();
  }

  /// Converts a number chunk (0-999) ensuring 'two' is feminine ('dvije') if the context requires it.
  ///
  /// This is used when a feminine scale word follows (like 'tisuća', 'milijarda').
  /// It converts the chunk normally using `_convertChunk`, then checks if the result
  /// ends with 'dva' under the correct conditions (original chunk ends in 2, not 12)
  /// and replaces it with 'dvije'.
  ///
  /// [n] The integer chunk (0-999).
  /// Returns the chunk text, potentially modified to use "dvije".
  String _convertChunkFeminineTwo(int n) {
    String text = _convertChunk(n); // Get the standard conversion.
    // Check if the converted chunk ends with the masculine/neuter form "dva".
    if (text.endsWith(_wordsUnder20[2])) {
      // Also ensure the original number actually ends in 2 (and isn't 12)
      // to avoid incorrectly changing words like "dvadeset" or the end of "dvanaest".
      if (n % 10 == 2 && n % 100 != 12) {
        // Replace the trailing "dva" with "dvije".
        return text.substring(0, text.length - _wordsUnder20[2].length) +
            _twoFeminine;
      }
    }
    // Return the original chunk text if no replacement was needed.
    return text;
  }

  /// Determines the grammatical form index (singular, paucal, plural) for scale words based on the number.
  ///
  /// Returns:
  /// - 0: Singular form (for numbers ending in 1, excluding 11).
  /// - 1: Paucal form (for numbers ending in 2, 3, 4, excluding 12, 13, 14).
  /// - 2: Plural form (for numbers ending in 0, 5-9, or 11-19).
  ///
  /// [chunkValue] The numeric value (1-999) of the chunk preceding the scale word.
  int _getScaleFormIndex(BigInt chunkValue) {
    // Handle 1 specifically for singular.
    if (chunkValue == BigInt.one) {
      return 0; // Singular
    }

    // Get last digit and last two digits for checks.
    int lastDigit = (chunkValue % BigInt.from(10)).toInt();
    int lastTwoDigits = (chunkValue % BigInt.from(100)).toInt();

    // Check for paucal: ends in 2, 3, 4 but exclude teens 12, 13, 14.
    if (lastDigit >= 2 &&
        lastDigit <= 4 &&
        (lastTwoDigits < 12 || lastTwoDigits > 14)) {
      return 1; // Paucal
    }
    // Check for singular: ends in 1 but exclude teen 11.
    // Note: BigInt.one case handled above, so this covers 21, 31, ..., 91, 101, etc.
    else if (lastDigit == 1 && lastTwoDigits != 11) {
      return 0; // Singular
    }
    // Otherwise, it's plural (ends in 0, 5-9, or 11-19).
    else {
      return 2; // Plural (Genitive)
    }
  }

  /// Converts a number between 0 and 999 into Croatian words.
  ///
  /// [n] The integer chunk (0-999).
  /// Throws [ArgumentError] if n is outside the valid range.
  /// Returns the chunk converted to Croatian words, or empty string for 0.
  String _convertChunk(int n) {
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }
    if (n == 0) return ""; // Return empty for zero chunk.

    // Handle numbers under 20 directly from the list.
    if (n < 20) return _wordsUnder20[n];

    List<String> words = [];
    int remainder = n;

    // Handle hundreds place.
    int hundredsDigit = remainder ~/ 100;
    if (hundredsDigit > 0) {
      words.add(_hundreds[hundredsDigit]); // Add "sto", "dvjesto", etc.
      remainder %= 100; // Get the remaining 0-99 part.
      // Add space if there are remaining tens/units to follow.
      if (remainder > 0) {
        words.add(" ");
      }
    }

    // Handle tens and units place (remainder is now 0-99).
    if (remainder >= 20) {
      int tensDigit = remainder ~/ 10;
      int unitDigit = remainder % 10;
      words.add(_wordsTens[tensDigit]); // Add "dvadeset", "trideset", etc.
      if (unitDigit > 0) {
        words.add(" "); // Add space before the unit.
        words
            .add(_wordsUnder20[unitDigit]); // Add "jedan", "dva", ..., "devet".
      }
    } else if (remainder > 0) {
      // Handle remaining 1-19.
      words.add(_wordsUnder20[remainder]);
    }

    // Join the parts (e.g., ["sto", " ", "dvadeset", " ", "tri"] -> "sto dvadeset tri").
    return words.join("");
  }
}
