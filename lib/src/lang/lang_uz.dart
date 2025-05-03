import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/uz_options.dart';
import '../utils/utils.dart';

/// {@template num2text_uz}
/// Converts numbers to Uzbek words (`Lang.UZ`).
///
/// Implements [Num2TextBase] for Uzbek, handling various numeric types.
/// Supports cardinal numbers, decimals, negatives, currency (default UZS), years, and large numbers.
/// Customizable via [UzOptions]. Returns a fallback string on error.
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
/// print(converter.convert(2024, options: UzOptions(format: Format.year))); // "ikki ming yigirma to'rt" // Note: AD/BC suffixes can be added via options.
/// print(converter.convert(1500.50, options: UzOptions(currency: true))); // "bir ming besh yuz soʻm ellik tiyin"
/// ```
class Num2TextUZ implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "nol"; // "zero"
  static const String _point = "nuqta"; // Decimal separator "." ("point")
  static const String _comma = "vergul"; // Decimal separator "," ("comma")
  static const String _hundred = "yuz"; // "hundred"
  static const String _thousand = "ming"; // "thousand"

  // Default fallback messages
  static const String _notANumber = "Raqam Emas"; // "Not a Number" (Title Case)
  static const String _positiveInfinity = "Cheksizlik"; // "Infinity"
  static const String _negativeInfinity =
      "Manfiy Cheksizlik"; // "Negative Infinity"

  // Number words
  static const List<String> _wordsUnder10 = [
    "nol",
    "bir",
    "ikki",
    "uch",
    "toʻrt",
    "besh",
    "olti",
    "yetti",
    "sakkiz",
    "toʻqqiz"
  ]; // 0-9
  static const List<String> _wordsTens = [
    "",
    "oʻn",
    "yigirma",
    "oʻttiz",
    "qirq",
    "ellik",
    "oltmish",
    "yetmish",
    "sakson",
    "toʻqson"
  ]; // 0, 10, 20...90
  static const List<String> _scaleWords = [
    "",
    _thousand,
    "million",
    "milliard",
    "trillion",
    "kvadrillion",
    "kvintillion",
    "sekstillion",
    "septillion"
  ]; // 10^0, 10^3, 10^6...

  /// Processes the given [number] into Uzbek words.
  ///
  /// {@template num2text_process_intro_uz}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options_uz}
  /// Uses [UzOptions] for customization (currency, year format, decimals, AD/BC, negative prefix).
  /// Defaults apply if [options] is null or not [UzOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors_uz}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or default Uzbek errors on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [UzOptions] settings.
  /// @param fallbackOnError Optional custom error string.
  /// @return The number as Uzbek words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final UzOptions uzOptions =
        options is UzOptions ? options : const UzOptions();
    final String onError = fallbackOnError ?? _notANumber;

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _negativeInfinity : _positiveInfinity;
      if (number.isNaN) return onError;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return onError;

    if (decimalValue == Decimal.zero) {
      // Handle zero based on context
      return uzOptions.currency
          ? "$_zero ${uzOptions.currencyInfo.mainUnitSingular}"
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = decimalValue.abs();
    String textResult;

    // Delegate based on format options
    if (uzOptions.format == Format.year) {
      // Year format uses integer part and handles sign internally
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), uzOptions);
    } else {
      textResult = uzOptions.currency
          ? _handleCurrency(absValue, uzOptions)
          : _handleStandardNumber(absValue, uzOptions);
      // Add negative prefix if necessary (not for years)
      if (isNegative) {
        textResult = "${uzOptions.negativePrefix} $textResult";
      }
    }
    return textResult;
  }

  /// Converts an integer year to Uzbek words with optional AD/BC suffixes.
  ///
  /// Uses standard integer conversion. Appends era suffixes based on options.
  ///
  /// @param yearValue The integer year.
  /// @param options Formatting options.
  /// @return The year as Uzbek words.
  String _handleYearFormat(BigInt yearValue, UzOptions options) {
    final bool isNegative = yearValue < BigInt.zero;
    final BigInt absYear = isNegative ? -yearValue : yearValue;

    // Convert the absolute year value using standard integer conversion
    String yearText = _convertInteger(absYear);

    // Append era suffixes if needed
    if (isNegative) {
      yearText += " miloddan avvalgi"; // "Before Common Era"
    } else if (options.includeAD && absYear > BigInt.zero) {
      yearText += " milodiy"; // "Common Era"
    }

    return yearText;
  }

  /// Converts a non-negative [Decimal] to Uzbek currency words (So'm/Tiyin).
  ///
  /// Uses [UzOptions.currencyInfo] for unit names. Rounds if [UzOptions.round] is true.
  /// Separates main (So'm) and subunits (Tiyin).
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Uzbek words.
  String _handleCurrency(Decimal absValue, UzOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    const int decimalPlaces = 2;
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    final Decimal valueToConvert =
        options.round ? absValue.round(scale: decimalPlaces) : absValue;

    final BigInt mainValue = valueToConvert.truncate().toBigInt(); // So'm
    final Decimal fractionalPart =
        (valueToConvert - valueToConvert.truncate()).abs();
    // Calculate Tiyin value, rounding might be needed for precision
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round(scale: 0).toBigInt();

    final List<String> resultParts = [];

    // Add main value (So'm) part if > 0
    if (mainValue > BigInt.zero) {
      resultParts.add(_convertInteger(mainValue));
      resultParts.add(currencyInfo.mainUnitSingular); // "soʻm"
    }

    // Add subunit value (Tiyin) part if > 0
    if (subunitValue > BigInt.zero) {
      final String? subUnitName =
          currencyInfo.subUnitSingular; // Nullable check for "tiyin"
      if (subUnitName != null) {
        resultParts.add(_convertInteger(subunitValue));
        resultParts.add(subUnitName);
      }
    }

    // Handle case where value is exactly zero (handled in 'process', defensive check)
    if (mainValue == BigInt.zero &&
        subunitValue == BigInt.zero &&
        resultParts.isEmpty) {
      return "$_zero ${currencyInfo.mainUnitSingular}"; // "nol soʻm"
    }

    // Combine parts with spaces
    return resultParts.join(' ');
  }

  /// Converts a non-negative standard [Decimal] number to Uzbek words.
  ///
  /// Converts integer and fractional parts. Uses [UzOptions.decimalSeparator] word ("nuqta" or "vergul").
  /// Fractional part converted digit by digit.
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Uzbek words.
  String _handleStandardNumber(Decimal absValue, UzOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = (absValue - absValue.truncate()).abs();

    // Convert integer part. Use "nol" if integer is 0 but fraction exists (e.g., 0.5).
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    // Process fractional part if it exists
    if (fractionalPart > Decimal.zero) {
      String separatorWord;
      switch (options.decimalSeparator ?? DecimalSeparator.point) {
        case DecimalSeparator.comma:
          separatorWord = _comma;
          break; // vergul
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          separatorWord = _point;
          break; // nuqta
      }

      // Get fractional digits string
      final String fractionalDigits = absValue.toString().split('.').last;

      // Convert each digit individually
      final List<String> digitWords = fractionalDigits.split('').map((digit) {
        final int? digitInt = int.tryParse(digit);
        return (digitInt != null && digitInt >= 0 && digitInt <= 9)
            ? _wordsUnder10[digitInt] // Use standard 0-9 words
            : '?'; // Fallback
      }).toList();

      // Add separator and digit words
      fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
    }

    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] into Uzbek words using scale words.
  ///
  /// Breaks the number into chunks of 1000. Delegates chunks < 1000 to [_convertChunk].
  ///
  /// @param n Non-negative integer.
  /// @throws ArgumentError if [n] is negative or too large for defined scales.
  /// @return Integer as Uzbek words. Returns "nol" for zero input.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n == BigInt.zero) return _zero;

    final List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0;
    BigInt remaining = n;

    do {
      final BigInt chunkValue = remaining % oneThousand;
      remaining ~/= oneThousand;

      if (chunkValue > BigInt.zero) {
        if (scaleIndex >= _scaleWords.length) {
          throw ArgumentError(
              "Number too large (exceeds scale: ${_scaleWords.last})");
        }
        // Convert the 0-999 chunk
        final String chunkText = _convertChunk(chunkValue.toInt());
        // Get the scale word (ming, million, etc.) or empty string for base chunk
        final String scaleWord = scaleIndex > 0 ? _scaleWords[scaleIndex] : "";

        // Combine chunk text and scale word (if applicable)
        String partToAdd =
            scaleWord.isNotEmpty ? "$chunkText $scaleWord" : chunkText;
        parts.add(partToAdd);
      }
      scaleIndex++;
    } while (remaining > BigInt.zero);

    // Combine parts from largest scale down, separated by spaces.
    // Filter out potential empty parts (shouldn't happen with chunkValue > 0 check)
    final nonEmptyParts = parts.where((part) => part.isNotEmpty);
    if (nonEmptyParts.isEmpty) return _zero; // Should be unreachable if n > 0
    return nonEmptyParts.toList().reversed.join(' ');
  }

  /// Converts an integer from 0 to 999 into Uzbek words.
  ///
  /// Handles hundreds, tens, and units places.
  ///
  /// @param n Integer chunk (0-999).
  /// @throws ArgumentError if [n] is outside 0-999.
  /// @return Chunk as Uzbek words, or empty string if [n] is 0.
  String _convertChunk(int n) {
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");
    if (n == 0) return ""; // Zero contributes nothing within a larger number

    final List<String> words = [];
    int remainder = n;

    // Handle hundreds place (e.g., "bir yuz", "ikki yuz")
    if (remainder >= 100) {
      words.add(_wordsUnder10[remainder ~/ 100]); // bir, ikki, ...
      words.add(_hundred); // yuz
      remainder %= 100;
    }

    // Handle tens and units place (1-99)
    if (remainder > 0) {
      if (remainder < 10) {
        // 1-9
        words.add(_wordsUnder10[remainder]);
      } else {
        // 10-99
        words.add(_wordsTens[remainder ~/ 10]); // oʻn, yigirma, ...
        final int unit = remainder % 10;
        if (unit > 0) {
          words.add(_wordsUnder10[
              unit]); // Add unit if present (e.g., "bir" in "yigirma bir")
        }
      }
    }

    // Join parts with spaces
    return words.join(' ');
  }
}
