import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/uz_options.dart';
import '../utils/utils.dart';

/// {@template num2text_uz}
/// The Uzbek language (`Lang.UZ`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Uzbek word representation following standard Uzbek grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [UzOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (using standard scale).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [UzOptions].
/// {@endtemplate}
///
/// Example Usage:
/// ```dart
/// final converter = Num2Text(initialLang: Lang.UZ);
/// print(converter.convert(123));       // "bir yuz yigirma uch"
/// print(converter.convert(1001));      // "bir ming bir"
/// print(converter.convert(-50));       // "minus ellik"
/// print(converter.convert(12.99));     // "o'n ikki nuqta to'qqiz to'qqiz"
/// print(converter.convert(12.99, options: UzOptions(decimalSeparator: DecimalSeparator.comma))); // "o'n ikki vergul to'qqiz to'qqiz"
/// print(converter.convert(2024, options: UzOptions(format: Format.year))); // "ikki ming yigirma to'rt"
/// print(converter.convert(1500.50, options: UzOptions(currency: true))); // "bir ming besh yuz soʻm ellik tiyin"
/// ```
class Num2TextUZ implements Num2TextBase {
  /// Word for zero.
  static const String _zero = "nol";

  /// Word for the decimal separator "point" (`.`).
  static const String _point = "nuqta";

  /// Word for the decimal separator "comma" (`,`).
  static const String _comma = "vergul";

  /// Word for "hundred".
  static const String _hundred = "yuz";

  /// Word for "thousand".
  static const String _thousand = "ming";

  /// Default fallback message for invalid inputs like NaN.
  static const String _notANumber = "Raqam emas";

  /// Default message for positive infinity.
  static const String _positiveInfinity = "Cheksizlik";

  /// Default message for negative infinity.
  static const String _negativeInfinity = "Manfiy cheksizlik";

  /// Word representations for numbers 0-9.
  static const List<String> _wordsUnder10 = [
    "nol", // 0
    "bir", // 1
    "ikki", // 2
    "uch", // 3
    "to'rt", // 4
    "besh", // 5
    "olti", // 6
    "yetti", // 7
    "sakkiz", // 8
    "to'qqiz", // 9
  ];

  /// Word representations for tens (10, 20, ... 90). Index corresponds to tens digit (1-9).
  static const List<String> _wordsTens = [
    "", // 0 (unused)
    "o'n", // 10
    "yigirma", // 20
    "o'ttiz", // 30
    "qirq", // 40
    "ellik", // 50
    "oltmish", // 60
    "yetmish", // 70
    "sakson", // 80
    "to'qson", // 90
  ];

  /// Scale words (thousand, million, etc.). Index corresponds to power of 1000 (0=units, 1=thousand, ...).
  static const List<String> _scaleWords = [
    "", // 1000^0 (Units chunk)
    _thousand, // 1000^1
    "million", // 1000^2
    "milliard", // 1000^3
    "trillion", // 1000^4
    "kvadrillion", // 1000^5
    "kvintillion", // 1000^6
    "sekstillion", // 1000^7
    "septillion", // 1000^8
    // Add more scales here if needed (e.g., oktillion, nonillion)
  ];

  /// Converts a number into its Uzbek word representation based on the provided options.
  ///
  /// [number] The number to convert. Can be `int`, `double`, `BigInt`, `Decimal`, or `String`.
  /// [options] Optional [UzOptions] to customize the conversion (e.g., currency, year format).
  /// If `null` or not an `UzOptions` instance, default options are used.
  /// [fallbackOnError] A string to return if the input `number` is invalid (e.g., `NaN`, `null`, non-numeric string).
  /// If `null`, a default error message (`_notANumber`) is used for invalid inputs other than `Infinity`.
  ///
  /// Returns the Uzbek text representation of the number, or an error/fallback string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have Uzbek-specific options, using defaults if necessary.
    final UzOptions uzOptions =
        options is UzOptions ? options : const UzOptions();
    final String onError = fallbackOnError ?? _notANumber;

    // Handle special double values immediately.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? _negativeInfinity : _positiveInfinity;
      }
      if (number.isNaN) {
        // Use fallback for NaN, as it's an invalid number input.
        return onError;
      }
    }

    // Normalize the input number to Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // If normalization fails (invalid input), return the fallback or default error.
    if (decimalValue == null) {
      return onError;
    }

    // Handle the specific case of zero.
    if (decimalValue == Decimal.zero) {
      if (uzOptions.currency) {
        // Currency format for zero: "nol so'm"
        return "$_zero ${uzOptions.currencyInfo.mainUnitSingular}";
      } else {
        // Standard or year format for zero.
        return _zero;
      }
    }

    // Determine sign and get the absolute value for conversion.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Branch based on the requested format.
    if (uzOptions.format == Format.year) {
      // Handle year formatting (includes negative years internally).
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), uzOptions);
    } else {
      // Handle standard number or currency format.
      if (uzOptions.currency) {
        textResult = _handleCurrency(absValue, uzOptions);
      } else {
        textResult = _handleStandardNumber(absValue, uzOptions);
      }

      // Prepend negative prefix if the original number was negative (but not for years).
      if (isNegative) {
        textResult = "${uzOptions.negativePrefix} $textResult";
      }
    }

    return textResult;
  }

  /// Formats a number as an Uzbek year.
  ///
  /// [yearValue] The integer year value (can be negative for BC/BCE).
  /// [options] The [UzOptions] containing formatting rules like `includeAD`.
  ///
  /// Handles negative years by prepending the `negativePrefix` from options.
  /// Appends " milodiy" (AD/CE) for positive years if `options.includeAD` is true.
  /// Returns the formatted year string.
  String _handleYearFormat(BigInt yearValue, UzOptions options) {
    final bool isNegative = yearValue < BigInt.zero;
    // Get the absolute value of the year for word conversion.
    final BigInt absYear = isNegative ? -yearValue : yearValue;

    // Convert the absolute year number to words.
    String yearText = _convertInteger(absYear);

    if (isNegative) {
      // Prepend the negative prefix for BC/BCE years.
      yearText = "${options.negativePrefix} $yearText";
    } else if (options.includeAD && absYear > BigInt.zero) {
      // Append the AD/CE suffix for positive years if requested.
      yearText += " milodiy";
    }

    return yearText;
  }

  /// Formats a number as Uzbek currency (So'm and Tiyin).
  ///
  /// [absValue] The absolute decimal value of the currency amount.
  /// [options] The [UzOptions] containing currency info and rounding rules.
  ///
  /// Uses `options.currencyInfo` for unit names.
  /// Rounds to 2 decimal places if `options.round` is true.
  /// Separates the value into main units (So'm) and subunits (Tiyin).
  /// Returns the formatted currency string.
  String _handleCurrency(Decimal absValue, UzOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    const int decimalPlaces = 2; // Standard currency subunits.
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value if requested, otherwise use the original value.
    final Decimal valueToConvert =
        options.round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate integer (main unit) and fractional (subunit) parts.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Calculate subunit value (multiply fractional part by 100), round for precision.
    final BigInt subunitValue =
        (fractionalPart.abs() * subunitMultiplier).round(scale: 0).toBigInt();

    // Convert the main value to words.
    final String mainText = _convertInteger(mainValue);
    // Get the main unit name (singular form is sufficient as number precedes it).
    final String mainUnitName = currencyInfo.mainUnitSingular;

    // Start building the result string. Add main part only if > 0.
    final List<String> resultParts = [];
    if (mainValue > BigInt.zero) {
      resultParts.add(mainText);
      resultParts.add(mainUnitName);
    }

    // If there are subunits, convert and append them.
    if (subunitValue > BigInt.zero) {
      final String subunitText = _convertInteger(subunitValue);
      // Get the subunit name (assuming singular form is appropriate).
      final String? subUnitName =
          currencyInfo.subUnitSingular; // Nullable check
      if (subUnitName != null) {
        resultParts.add(subunitText);
        resultParts.add(subUnitName);
      }
    }

    // Handle cases like 0.50 (only subunits) or exact 0 (handled in 'process').
    if (mainValue == BigInt.zero && subunitValue > BigInt.zero) {
      // Subunits were already added to resultParts.
    } else if (mainValue == BigInt.zero && subunitValue == BigInt.zero) {
      // Should be handled by 'process', return "nol so'm" defensively.
      return "$_zero ${currencyInfo.mainUnitSingular}";
    }

    return resultParts.join(' ');
  }

  /// Converts a standard decimal number (integer or with fractional part) to words.
  ///
  /// [absValue] The absolute decimal value of the number.
  /// [options] The [UzOptions] containing decimal separator preference.
  ///
  /// Handles integer and decimal parts separately.
  /// Uses the appropriate decimal separator word (`nuqta` or `vergul`).
  /// Converts digits after the decimal point individually.
  /// Returns the formatted number string.
  String _handleStandardNumber(Decimal absValue, UzOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = (absValue - absValue.truncate()).abs();

    // Convert the integer part, handling the case "0.5" -> "nol ..."
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    // Process fractional part only if it's greater than zero.
    if (fractionalPart > Decimal.zero) {
      String separatorWord;
      // Choose the decimal separator word based on options. Default to point.
      switch (options.decimalSeparator ?? DecimalSeparator.point) {
        case DecimalSeparator.comma:
          separatorWord = _comma;
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          separatorWord = _point;
          break;
      }

      // Get the digits after the decimal point as a string.
      // toString() reliably handles decimal representation.
      final String fractionalDigits = absValue.toString().split('.').last;

      // Convert each digit after the decimal point to its word representation.
      final List<String> digitWords = fractionalDigits.split('').map((digit) {
        final int? digitInt = int.tryParse(digit);
        // Map valid digits (0-9) to words, use '?' for unexpected characters.
        return (digitInt != null && digitInt >= 0 && digitInt <= 9)
            ? _wordsUnder10[digitInt] // Handle 0 using _wordsUnder10[0]
            : '?'; // Fallback for safety
      }).toList();

      fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
    }

    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer `BigInt` into its Uzbek word representation.
  ///
  /// [n] The non-negative integer to convert.
  ///
  /// Breaks the number into chunks of three digits (thousands).
  /// Applies scale words (ming, million, etc.).
  /// Uses `_convertChunk` to handle numbers less than 1000.
  /// Throws `ArgumentError` if the number is negative or too large for defined scales.
  /// Returns the integer part as words, or "nol" if n is zero.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero) {
      // This function expects non-negative input; sign is handled elsewhere.
      throw ArgumentError("Integer must be non-negative for conversion: $n");
    }
    if (n == BigInt.zero) return _zero;

    // Delegate smaller numbers directly to the chunk converter.
    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt());
    }

    final List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex =
        0; // Index into _scaleWords (0 = units, 1 = thousands, etc.)
    BigInt remaining = n;

    // Process the number in chunks of 1000, from lowest to highest scale.
    while (remaining > BigInt.zero) {
      // Ensure we haven't exceeded the largest defined scale.
      if (scaleIndex >= _scaleWords.length) {
        // Log or throw an error for very large numbers exceeding defined scales.
        throw ArgumentError(
          "Number too large to convert (exceeds defined scales: ${_scaleWords.last})",
        );
      }

      // Get the current chunk (0-999).
      final BigInt chunkValue = remaining % oneThousand;
      // Move to the next chunk.
      remaining ~/= oneThousand;

      // Convert the chunk to words if it's not zero.
      if (chunkValue > BigInt.zero) {
        final String chunkText = _convertChunk(chunkValue.toInt());
        // Get the appropriate scale word (e.g., "ming", "million").
        final String scaleWord = scaleIndex > 0 ? _scaleWords[scaleIndex] : "";

        // Combine chunk text and scale word.
        if (scaleWord.isNotEmpty) {
          // Add scale word for thousands, millions, etc.
          parts.add("$chunkText $scaleWord");
        } else {
          // No scale word for the units chunk (0-999).
          parts.add(chunkText);
        }
      }
      scaleIndex++;
    }

    // Join the parts in reverse order (highest scale first) with spaces.
    return parts.reversed.join(' ');
  }

  /// Converts an integer between 0 and 999 into its Uzbek word representation.
  ///
  /// [n] The integer chunk (0-999) to convert.
  ///
  /// Handles hundreds, tens, and units places.
  /// Throws `ArgumentError` if `n` is outside the valid range [0, 999].
  /// Returns the word representation of the chunk, or an empty string if n is 0.
  String _convertChunk(int n) {
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }
    if (n == 0) return ""; // An empty chunk doesn't contribute words.

    final List<String> words = [];
    int remainder = n;

    // Handle hundreds place.
    if (remainder >= 100) {
      words.add(_wordsUnder10[remainder ~/ 100]); // e.g., "bir", "ikki"
      words.add(_hundred); // "yuz"
      remainder %= 100;
    }

    // Handle tens and units places (1-99).
    if (remainder > 0) {
      if (remainder < 10) {
        // Numbers 1-9.
        words.add(_wordsUnder10[remainder]);
      } else {
        // Numbers 10-99.
        words.add(_wordsTens[remainder ~/ 10]); // e.g., "o'n", "yigirma"
        final int unit = remainder % 10;
        if (unit > 0) {
          // Add unit word if present (e.g., "bir" in "yigirma bir").
          words.add(_wordsUnder10[unit]);
        }
      }
    }

    // Join the parts (e.g., "bir", "yuz", "yigirma", "bir") with spaces.
    return words.join(' ');
  }
}
