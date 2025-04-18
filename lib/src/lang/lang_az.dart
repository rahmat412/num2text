import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/az_options.dart';
import '../options/base_options.dart';
import '../utils/utils.dart';

/// {@template num2text_az}
/// The Azerbaijani language (`Lang.AZ`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Azerbaijani word representation following Azerbaijani grammar and vocabulary.
/// Azerbaijani number words are generally agglutinative and do not have complex declension or gender agreement.
///
/// Capabilities include handling cardinal numbers, currency (using [AzOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (short scale).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [AzOptions].
/// {@endtemplate}
class Num2TextAZ implements Num2TextBase {
  /// The word for "Minus" when capitalized (used for negative infinity).
  static const String _minusCapital = "Mənfi";

  /// The word for "zero".
  static const String _zero = "sıfır";

  /// The word for the decimal separator "point".
  static const String _point = "nöqtə";

  /// The word for the decimal separator "comma".
  static const String _comma = "vergül";

  /// The word for "one".
  static const String _one = "bir";

  /// The word for "hundred".
  static const String _hundred = "yüz";

  /// The word for "thousand".
  static const String _thousand = "min";

  /// The suffix for years BC (Before Christ). Means "eramızdan əvvəl" (before our era).
  static const String _yearSuffixBC = "eramızdan əvvəl";

  /// The suffix for years AD (Anno Christi / Common Era). Means "eramızın" (of our era).
  static const String _yearSuffixAD = "eramızın";

  /// The word for "Infinity".
  static const String _infinity = "Sonsuzluq";

  /// The phrase for "Not a Number". Used as the default fallback message.
  static const String _notANumber = "Ədəd Deyil";

  /// Word representations for numbers 0 through 19.
  static const List<String> _wordsUnder20 = [
    "sıfır", // 0
    "bir", // 1
    "iki", // 2
    "üç", // 3
    "dörd", // 4
    "beş", // 5
    "altı", // 6
    "yeddi", // 7
    "səkkiz", // 8
    "doqquz", // 9
    "on", // 10
    "on bir", // 11
    "on iki", // 12
    "on üç", // 13
    "on dörd", // 14
    "on beş", // 15
    "on altı", // 16
    "on yeddi", // 17
    "on səkkiz", // 18
    "on doqquz", // 19
  ];

  /// Word representations for tens (20, 30, ..., 90). Index corresponds to tens digit (e.g., index 2 is "iyirmi").
  static const List<String> _wordsTens = [
    "", // 0 (unused placeholder)
    "", // 1 (unused placeholder - handled by _wordsUnder20)
    "iyirmi", // 20
    "otuz", // 30
    "qırx", // 40
    "əlli", // 50
    "altmış", // 60
    "yetmiş", // 70
    "səksən", // 80
    "doxsan", // 90
  ];

  /// Names of scale numbers (thousand, million, billion, etc.). Index corresponds to the power of 1000.
  static const List<String> _scaleWords = [
    "", // 1000^0 (Units - placeholder)
    "min", // 1000^1 (Thousand)
    "milyon", // 1000^2 (Million)
    "milyard", // 1000^3 (Billion)
    "trilyon", // 1000^4 (Trillion)
    "kvadrilyon", // 1000^5 (Quadrillion)
    "kvintilyon", // 1000^6 (Quintillion)
    "sekstilyon", // 1000^7 (Sextillion)
    "septilyon", // 1000^8 (Septillion)
    // Add more scales if needed
  ];

  /// Converts a number into its Azerbaijani word representation.
  ///
  /// - [number] The number to convert. Can be [int], [double], [String], [BigInt], or [Decimal].
  /// - [options] Optional [AzOptions] to customize the conversion (e.g., currency, year format).
  /// - [fallbackOnError] A string to return if the conversion fails (e.g., invalid input). If null, uses the default error message.
  ///
  /// Returns the word representation of the number in Azerbaijani, or [fallbackOnError]/error message if conversion fails.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure options are of the correct type or use defaults.
    final AzOptions azOptions =
        options is AzOptions ? options : const AzOptions();
    final String errorFallback = fallbackOnError ?? _notANumber;

    // Handle special double values directly.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? "$_minusCapital $_infinity" : _infinity;
      }
      if (number.isNaN) {
        return errorFallback;
      }
    }

    // Normalize the input number to Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // If normalization fails, return fallback or default error.
    if (decimalValue == null) {
      return errorFallback;
    }

    // Handle zero separately.
    if (decimalValue == Decimal.zero) {
      if (azOptions.currency) {
        // Use singular form for currency name (pluralization is simple).
        return "$_zero ${azOptions.currencyInfo.mainUnitSingular}";
      } else {
        // Year zero or standard zero.
        return _zero;
      }
    }

    // Determine sign and use absolute value for core conversion.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    // Delegate to specific handlers based on format options.
    if (azOptions.format == Format.year) {
      // Year format requires integer conversion.
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), azOptions);
    } else {
      if (azOptions.currency) {
        textResult = _handleCurrency(absValue, azOptions);
      } else {
        textResult = _handleStandardNumber(absValue, azOptions);
      }
      // Add negative prefix if the original number was negative.
      if (isNegative) {
        textResult = "${azOptions.negativePrefix} $textResult";
      }
    }

    // Return the final result, trimming any leading/trailing whitespace.
    return textResult.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Handles the specific formatting for years (including AD/BC suffixes).
  ///
  /// - [year] The integer year value (can be negative for BC).
  /// - [options] The [AzOptions] containing formatting flags like [includeAD].
  /// Returns the year represented in Azerbaijani words.
  String _handleYearFormat(int year, AzOptions options) {
    final bool isNegative = year < 0;
    // Convert to positive for word generation.
    final int absYear = isNegative ? -year : year;
    final BigInt bigAbsYear = BigInt.from(absYear);

    // Get the word representation of the absolute year value.
    String yearText = _convertInteger(bigAbsYear);

    // Add appropriate suffix based on sign and options.
    if (isNegative) {
      yearText += " $_yearSuffixBC"; // "eramızdan əvvəl" for BC
    } else if (options.includeAD && absYear > 0) {
      yearText += " $_yearSuffixAD"; // "eramızın" for AD (if requested)
    }
    return yearText;
  }

  /// Handles the specific formatting for currency values.
  ///
  /// - [absValue] The absolute decimal value of the currency amount.
  /// - [options] The [AzOptions] containing currency info and rounding settings.
  /// Returns the currency amount represented in Azerbaijani words.
  String _handleCurrency(Decimal absValue, AzOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2; // Standard currency subunit precision
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value if specified in options.
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main unit (integer) and subunit (fractional) parts.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    final BigInt subunitValue = (fractionalPart * subunitMultiplier)
        .round()
        .toBigInt(); // Use round for robustness

    // Convert the main unit value to words.
    String mainText = _convertInteger(mainValue);
    // Use the singular form for the main unit name (pluralization rules are simple for AZN).
    String mainUnitName = currencyInfo.mainUnitSingular;

    // Start building the result string.
    String result = '$mainText $mainUnitName';

    // If there's a subunit value, convert and append it.
    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      String subunitText = _convertInteger(subunitValue);
      // Use singular subunit name.
      String subUnitName = currencyInfo.subUnitSingular!;
      // Use the defined separator or a default space.
      String separator = currencyInfo.separator ?? " ";
      result += '$separator$subunitText $subUnitName';
    }

    return result;
  }

  /// Handles standard number formatting, including decimals.
  /// Removes trailing zeros from the decimal part for natural reading.
  ///
  /// - [absValue] The absolute decimal value of the number.
  /// - [options] The [AzOptions] containing decimal separator preference.
  /// Returns the number represented in Azerbaijani words.
  String _handleStandardNumber(Decimal absValue, AzOptions options) {
    // Separate integer and fractional parts.
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part to words.
    // If the number is purely fractional (e.g., 0.5), the integer part should be "sıfır".
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    // Process fractional part only if it's greater than zero and the number is not an integer.
    if (fractionalPart > Decimal.zero && !absValue.isInteger) {
      // Determine the separator word based on options.
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          separatorWord = _point; // "nöqtə"
          break;
        case DecimalSeparator.comma:
        default: // Default to comma if null or comma specified
          separatorWord = _comma; // "vergül"
          break;
      }

      // Extract fractional digits as a string.
      String decimalString = absValue.toString();
      String fractionalDigits =
          decimalString.contains('.') ? decimalString.split('.').last : '';

      // Remove trailing zeros for natural reading (e.g., 1.50 -> "beş").
      fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      // Convert each remaining fractional digit to its word representation.
      if (fractionalDigits.isNotEmpty) {
        List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          // Check if parsing was successful and within 0-9 range.
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder20[digitInt] // Use words 0-9
              : '?'; // Placeholder for unexpected characters
        }).toList();

        // Append the fractional part words if any digits were converted.
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
      // If fractionalDigits becomes empty after removing trailing zeros, fractionalWords remains empty.
    }
    // Note: Case 123.0 handled correctly as fractionalPart > 0 fails.

    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords';
  }

  /// Converts a non-negative integer ([BigInt]) into Azerbaijani words.
  ///
  /// Handles numbers by breaking them into chunks of thousands and applying scale words.
  /// Special handling for "bir min" (one thousand) -> "min".
  /// - [n] The non-negative integer to convert.
  /// Returns the integer represented in Azerbaijani words.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero)
      throw ArgumentError("Negative input to _convertInteger: $n");

    // Handle numbers less than 1000 directly.
    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt());
    }

    List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0; // 0: units, 1: thousands, 2: millions, ...
    BigInt remaining = n;

    // Process the number in chunks of 1000 (right to left).
    while (remaining > BigInt.zero) {
      // Ensure we have a scale word defined for this magnitude.
      if (scaleIndex >= _scaleWords.length) {
        throw ArgumentError("Number too large (exceeds defined scales): $n");
      }

      // Get the current chunk (0-999).
      final int chunk = (remaining % oneThousand).toInt();
      remaining ~/= oneThousand; // Move to the next chunk

      // If the chunk is non-zero, convert it and add the scale word.
      if (chunk > 0) {
        String chunkText = _convertChunk(chunk);
        String scaleWord = scaleIndex > 0 ? _scaleWords[scaleIndex] : "";

        String combinedPart;
        if (scaleWord.isNotEmpty) {
          // Special handling for "one thousand" -> "min" (not "bir min")
          if (chunk == 1 && scaleWord == _thousand) {
            combinedPart = scaleWord; // Just "min"
          }
          // For other scales, "one" is explicitly stated (e.g., "bir milyon").
          else if (chunk == 1 && scaleWord != _thousand) {
            combinedPart =
                "$_one $scaleWord"; // "bir milyon", "bir milyard", etc.
          } else {
            // Standard case: "iki min", "yüz iyirmi üç milyon", etc.
            combinedPart = "$chunkText $scaleWord";
          }
        } else {
          // This is the least significant chunk (0-999), no scale word needed.
          combinedPart = chunkText;
        }
        // Insert combined part at the beginning.
        parts.insert(0, combinedPart);
      } else if (remaining > BigInt.zero) {
        // Insert placeholder for zero chunk if higher scales exist, to maintain correct spacing logic implicitly.
        parts.insert(0, "");
      }
      // Move to the next scale level (thousands, millions, etc.).
      scaleIndex++;
    }

    // Join the parts with spaces. Filter out any empty placeholders inserted earlier.
    return parts.where((part) => part.isNotEmpty).join(' ');
  }

  /// Converts a number between 0 and 999 into Azerbaijani words.
  ///
  /// - [n] The integer chunk (0-999) to convert.
  /// Returns the chunk represented in Azerbaijani words, or an empty string if `n` is 0.
  String _convertChunk(int n) {
    if (n == 0)
      return ""; // Empty string for zero chunk within a larger number.
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }

    List<String> words = [];
    int remainder = n;

    // Handle hundreds place.
    if (remainder >= 100) {
      int hundredDigit = remainder ~/ 100;
      // "yüz" for 100, "iki yüz" for 200, etc.
      if (hundredDigit > 1) {
        words.add(_wordsUnder20[hundredDigit]); // "iki", "üç", ...
      }
      words.add(_hundred); // "yüz"
      remainder %= 100; // Get the remaining part (0-99)
    }

    // Handle the remaining part (0-99).
    if (remainder > 0) {
      if (remainder < 20) {
        // Numbers 1-19 are directly mapped.
        words.add(_wordsUnder20[remainder]);
      } else {
        // Numbers 20-99.
        int tensDigit = remainder ~/ 10;
        int unitDigit = remainder % 10;
        words.add(_wordsTens[tensDigit]); // "iyirmi", "otuz", ...
        if (unitDigit > 0) {
          // Add unit word if present (e.g., "bir" in "iyirmi bir").
          words.add(_wordsUnder20[unitDigit]);
        }
      }
    }

    // Join the parts (e.g., ["iki", "yüz", "iyirmi", "bir"]) with spaces.
    return words.join(' ');
  }
}
