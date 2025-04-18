import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/tr_options.dart';
import '../utils/utils.dart';

/// {@template num2text_tr}
/// The Turkish language (`Lang.TR`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Turkish word representation following standard Turkish grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [TrOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (using standard scale).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [TrOptions].
/// {@endtemplate}
///
/// Example Usage:
/// ```dart
/// final converter = Num2Text(initialLang: Lang.TR);
/// print(converter.convert(123)); // yüz yirmi üç
/// print(converter.convert(123.45)); // yüz yirmi üç virgül dört beş
/// print(converter.convert(1000)); // bin
/// print(converter.convert(1999, options: const TrOptions(format: Format.year))); // bin dokuz yüz doksan dokuz
/// print(converter.convert(150.75, options: const TrOptions(currency: true))); // yüz elli Türk lirası yetmiş beş kuruş
/// ```
class Num2TextTR implements Num2TextBase {
  /// The Turkish word for zero.
  static const String _zero = "sıfır";

  /// The Turkish word for hundred.
  static const String _hundred = "yüz";

  /// The Turkish word for thousand.
  static const String _thousand = "bin";

  /// The Turkish word for the decimal separator comma (",").
  static const String _decimalSeparatorCommaWord = "virgül";

  /// The Turkish word for the decimal separator period/point (".").
  static const String _decimalSeparatorPeriodWord = "nokta";

  /// The separator used between main and sub-currency units (a single space).
  static const String _currencySeparator = " ";

  /// The Turkish word for infinity.
  static const String _infinity = "Sonsuz";

  /// The Turkish word for negative infinity.
  static const String _negativeInfinity = "Negatif Sonsuz";

  /// The Turkish word for Not a Number (NaN) - default fallback.
  static const String _nan = "Sayı Değil";

  /// Turkish words for digits 0-9. Index corresponds to the digit.
  /// Note: Index 0 is empty as zero is handled separately or contextually.
  static const List<String> _units = [
    "", // 0
    "bir", // 1
    "iki", // 2
    "üç", // 3
    "dört", // 4
    "beş", // 5
    "altı", // 6
    "yedi", // 7
    "sekiz", // 8
    "dokuz", // 9
  ];

  /// Turkish words for tens (10, 20, ..., 90). Index corresponds to the tens digit (1-9).
  /// Note: Index 0 is empty.
  static const List<String> _tens = [
    "", // 0
    "on", // 10
    "yirmi", // 20
    "otuz", // 30
    "kırk", // 40
    "elli", // 50
    "altmış", // 60
    "yetmiş", // 70
    "seksen", // 80
    "doksan", // 90
  ];

  /// Turkish scale words (thousand, million, billion, etc.).
  /// The index corresponds to the power of 1000 (0: none, 1: thousand, 2: million, ...).
  static const List<String> _scaleWords = [
    "", // 1000^0
    _thousand, // 1000^1
    "milyon", // 1000^2
    "milyar", // 1000^3
    "trilyon", // 1000^4
    "katrilyon", // 1000^5
    "kentilyon", // 1000^6
    "sekstilyon", // 1000^7
    "septilyon", // 1000^8
    // Add more scales here if needed (e.g., oktilyon, nonilyon)
  ];

  /// Processes the given number for conversion into Turkish words.
  ///
  /// [number] The input number (can be `int`, `double`, `String`, `Decimal`, `BigInt`).
  /// [options] Optional [TrOptions] to customize conversion (e.g., currency, year format).
  /// [fallbackOnError] A custom string to return if conversion fails. If null, defaults to `_nan`.
  /// Returns the Turkish word representation of the number or a fallback string on error.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final TrOptions trOptions =
        options is TrOptions ? options : const TrOptions();
    final String errorFallback = fallbackOnError ?? _nan;

    // Handle special double values first
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? _negativeInfinity : _infinity;
      }
      if (number.isNaN) {
        return errorFallback;
      }
    }

    // Normalize the input number to Decimal
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    if (decimalValue == null) {
      return errorFallback;
    }

    // Handle zero separately
    if (decimalValue == Decimal.zero) {
      // Currency format for zero
      if (trOptions.currency) {
        // Ensure currencyInfo and mainUnitSingular are not null
        final mainUnit = trOptions.currencyInfo.mainUnitSingular;
        return "$_zero $mainUnit"; // e.g., "sıfır Türk lirası"
      } else {
        return _zero; // Standard zero
      }
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for conversion logic
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Branch based on formatting options
    if (trOptions.format == Format.year) {
      // Year format: convert integer part, handle negative prefix if needed.
      // Turkish year format doesn't typically use AD/BC (MS/MÖ) suffixes unless explicitly requested.
      textResult = _convertInteger(absValue.truncate().toBigInt());
      if (isNegative) {
        textResult = "${trOptions.negativePrefix} $textResult";
      }
    } else {
      // Standard or Currency format
      if (trOptions.currency) {
        textResult = _handleCurrency(absValue, trOptions);
      } else {
        textResult = _handleStandardNumber(absValue, trOptions);
      }

      // Add negative prefix if the original number was negative
      if (isNegative) {
        textResult = "${trOptions.negativePrefix} $textResult";
      }
    }

    // Return the final trimmed result
    return textResult.trim();
  }

  /// Handles the conversion of a number into Turkish currency format.
  ///
  /// [absValue] The absolute decimal value of the number.
  /// [options] The [TrOptions] containing currency information and settings.
  /// Returns the number formatted as Turkish currency (e.g., "bir Türk lirası elli kuruş").
  String _handleCurrency(Decimal absValue, TrOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2; // Currency typically has 2 decimal places
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value if specified in options
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main and subunit values
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Round subunit calculation to avoid precision issues (e.g., 0.45 * 100 might be 44.99...)
    final BigInt subunitValue =
        (fractionalPart.abs() * subunitMultiplier).round(scale: 0).toBigInt();

    // Convert main value to words
    String mainText = _convertInteger(mainValue);
    // Get the appropriate currency unit name (singular is generally used after number)
    String mainUnitName = currencyInfo.mainUnitSingular;

    // Start building the result string
    String result = '$mainText $mainUnitName';

    // Add subunit part if it exists
    if (subunitValue > BigInt.zero) {
      // Convert subunit value to words
      String subunitText = _convertInteger(subunitValue);
      // Get subunit name (assuming singular form is sufficient)
      // Use null assertion cautiously, ensure currencyInfo is well-defined.
      String subUnitName = currencyInfo.subUnitSingular!;

      result += '$_currencySeparator$subunitText $subUnitName';
    }

    return result;
  }

  /// Handles the conversion of a standard number (integer or decimal).
  ///
  /// [absValue] The absolute decimal value of the number.
  /// [options] The [TrOptions] containing decimal separator preferences.
  /// Returns the number formatted as standard Turkish words (e.g., "yüz yirmi üç virgül dört beş").
  String _handleStandardNumber(Decimal absValue, TrOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = (absValue - absValue.truncate()).abs();

    // Convert integer part, handle case where integer part is zero but fractional part exists (e.g., 0.5 -> "sıfır")
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    // Process fractional part if it exists
    if (fractionalPart > Decimal.zero) {
      String separatorWord;
      // Determine the decimal separator word based on options
      switch (options.decimalSeparator ?? DecimalSeparator.comma) {
        // Default to comma
        case DecimalSeparator.period:
        case DecimalSeparator.point: // Treat point same as period
          separatorWord = _decimalSeparatorPeriodWord;
          break;
        case DecimalSeparator.comma:
          separatorWord = _decimalSeparatorCommaWord;
          break;
      }

      // Extract fractional digits as a string. Use absValue.toString() to capture trailing zeros if needed,
      // but then remove them as they are not spoken in Turkish decimals.
      String fractionalDigits = absValue.toString().split('.').last;
      // Remove trailing zeros: "1.50" -> "5", "1.05" -> "05"
      // fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), ''); // Reconsider this - "1.05" should be "nokta sıfır beş"

      // Convert each fractional digit to its word representation
      List<String> digitWords = fractionalDigits.split('').map((digit) {
        final int? digitInt = int.tryParse(digit);
        // Handle zero explicitly as _units[0] is ""
        return (digitInt != null && digitInt >= 0 && digitInt <= 9)
            ? (digitInt == 0 ? _zero : _units[digitInt])
            : '?'; // Fallback for non-digits (shouldn't happen with normalized input)
      }).toList();

      // Combine separator and digit words
      fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
    }

    // Combine integer and fractional parts
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer (`BigInt`) into its Turkish word representation.
  ///
  /// [n] The non-negative integer to convert.
  /// Returns the Turkish words for the integer.
  /// Throws [ArgumentError] if the number is too large for the defined `_scaleWords`.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _zero; // Base case for zero

    List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0; // Index for _scaleWords (0: none, 1: thousand, ...)
    BigInt remaining = n;

    // Process the number in chunks of 1000
    while (remaining > BigInt.zero) {
      // Check if the number exceeds the largest defined scale
      if (scaleIndex >= _scaleWords.length) {
        throw ArgumentError(
          "Number too large to convert (exceeds defined scale: ${_scaleWords.last})",
        );
      }

      // Get the current chunk (0-999)
      BigInt chunkBigInt = remaining % oneThousand;
      int chunk = chunkBigInt.toInt(); // Chunks 0-999 fit in standard int
      remaining ~/= oneThousand; // Move to the next chunk

      // Process the chunk only if it's greater than zero
      if (chunk > 0) {
        String chunkText;

        // Special case for 1000: "bin" instead of "bir bin"
        if (scaleIndex == 1 && chunk == 1) {
          chunkText = ""; // Handled by the scale word "bin" itself
        } else {
          // Convert the 0-999 chunk to words
          chunkText = _convertChunk(chunk);
        }

        // Get the appropriate scale word (thousand, million, etc.)
        String scaleWord = scaleIndex > 0 ? _scaleWords[scaleIndex] : "";

        // Combine chunk text and scale word
        if (scaleWord.isNotEmpty) {
          // Add scale word, prefixed by chunk text if chunk wasn't 1000
          parts.add(chunkText.isEmpty ? scaleWord : "$chunkText $scaleWord");
        } else {
          // No scale word (for the 0-999 part)
          parts.add(chunkText);
        }
      }
      scaleIndex++; // Move to the next scale
    }

    // Reverse the parts (since we processed from lowest scale) and join with spaces
    return parts.reversed.join(' ');
  }

  /// Converts a three-digit chunk (0-999) into its Turkish word representation.
  ///
  /// [n] The integer chunk (must be between 0 and 999).
  /// Returns the Turkish words for the chunk. Returns an empty string for 0.
  /// Throws [ArgumentError] if `n` is outside the valid range.
  String _convertChunk(int n) {
    if (n == 0) return ""; // Empty string for zero chunk
    // Validate chunk range
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }

    List<String> words = [];
    int remainder = n;

    // Handle hundreds place
    if (remainder >= 100) {
      int hundredsDigit = remainder ~/ 100;
      // Special case for 100: "yüz" instead of "bir yüz"
      if (hundredsDigit == 1) {
        words.add(_hundred);
      } else {
        // e.g., "iki yüz"
        words.add(_units[hundredsDigit]);
        words.add(_hundred);
      }
      remainder %= 100; // Get the remaining tens and units
    }

    // Handle tens place
    if (remainder >= 10) {
      words.add(_tens[remainder ~/ 10]); // Add "on", "yirmi", etc.
      remainder %= 10; // Get the remaining units digit
    }

    // Handle units place
    if (remainder > 0) {
      words.add(_units[remainder]); // Add "bir", "iki", etc.
    }

    // Join the parts (hundreds, tens, units) with spaces
    return words.join(' ');
  }
}
