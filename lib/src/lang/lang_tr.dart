import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/tr_options.dart';
import '../utils/utils.dart';

/// {@template num2text_tr}
/// Converts numbers to Turkish words (`Lang.TR`).
///
/// Implements [Num2TextBase] for the Turkish language. Handles various numeric types
/// (`int`, `double`, `BigInt`, `Decimal`, `String`) via its [process] method.
///
/// Supports cardinal numbers, currency, years, decimals, and negatives.
/// Handles special cases like "bin" (1000) vs "bir bin".
/// Customization is available via [TrOptions]. Returns a fallback string on error.
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
/// {@endtemplate}
class Num2TextTR implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "sıfır";
  static const String _hundred = "yüz";
  static const String _thousand = "bin";
  static const String _decimalSeparatorCommaWord =
      "virgül"; // Comma ',' separator.
  static const String _decimalSeparatorPeriodWord =
      "nokta"; // Period '.' separator.
  /// Separator for currency units (space).
  static const String _currencySeparator = " ";
  static const String _infinity = "Sonsuz";
  static const String _negativeInfinity = "Negatif Sonsuz";

  /// Default fallback for NaN or errors.
  static const String _nan = "Sayı Değil";

  /// Digits 1-9. Index 0 is unused.
  static const List<String> _units = [
    "",
    "bir",
    "iki",
    "üç",
    "dört",
    "beş",
    "altı",
    "yedi",
    "sekiz",
    "dokuz"
  ];

  /// Tens 10-90. Index 0 is unused, Index 1 = 10.
  static const List<String> _tens = [
    "",
    "on",
    "yirmi",
    "otuz",
    "kırk",
    "elli",
    "altmış",
    "yetmiş",
    "seksen",
    "doksan"
  ];

  /// Scale words (thousand, million, etc.). Index corresponds to power of 1000.
  static const List<String> _scaleWords = [
    "",
    _thousand,
    "milyon",
    "milyar",
    "trilyon",
    "katrilyon",
    "kentilyon",
    "sekstilyon",
    "septilyon"
  ];

  /// Processes the given [number] and converts it to Turkish words.
  ///
  /// {@template num2text_process_intro}
  /// Handles `int`, `double`, `BigInt`, `Decimal`, `String` inputs by normalizing to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [TrOptions] for customization (currency, year format, decimals, AD/BC, negative prefix).
  /// Defaults apply if [options] is null or not [TrOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or default error messages on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [TrOptions] settings.
  /// @param fallbackOnError Optional custom error string.
  /// @return The number as Turkish words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final TrOptions trOptions =
        options is TrOptions ? options : const TrOptions();
    final String errorFallback = fallbackOnError ?? _nan;

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _negativeInfinity : _infinity;
      if (number.isNaN) return errorFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    // Handle zero based on context.
    if (decimalValue == Decimal.zero) {
      if (trOptions.currency)
        return "$_zero ${trOptions.currencyInfo.mainUnitSingular}";
      return _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    // Delegate based on options.
    if (trOptions.format == Format.year) {
      final BigInt yearValue = absValue.truncate().toBigInt();
      textResult = _convertInteger(yearValue);
      // Append year suffixes based on original sign and options.
      if (isNegative) {
        textResult = "$textResult MÖ"; // Before Christ. Consider const.
      } else if (trOptions.includeAD) {
        textResult = "$textResult MS"; // Anno Domini. Consider const.
      }
    } else {
      if (trOptions.currency) {
        textResult = _handleCurrency(absValue, trOptions);
      } else {
        textResult = _handleStandardNumber(absValue, trOptions);
      }
      // Prepend negative prefix if needed.
      if (isNegative) {
        textResult = "${trOptions.negativePrefix} $textResult";
      }
    }

    return textResult.trim(); // Trim potential extra spaces.
  }

  /// Converts a non-negative [Decimal] value to Turkish currency words.
  ///
  /// Uses [TrOptions.currencyInfo] for unit names. Rounds if [TrOptions.round] is true.
  /// Separates main and subunits (e.g., Lira, Kuruş).
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Turkish words.
  String _handleCurrency(Decimal absValue, TrOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2;
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round if specified.
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main and subunit values.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    final BigInt subunitValue =
        (fractionalPart.abs() * subunitMultiplier).round(scale: 0).toBigInt();

    String mainPart = "";
    // Convert main part if non-zero.
    if (mainValue > BigInt.zero) {
      String mainText = _convertInteger(mainValue);
      String mainUnitName =
          currencyInfo.mainUnitSingular; // Turkish uses singular form.
      mainPart = '$mainText $mainUnitName';
    }

    String subunitPart = "";
    // Convert subunit part if non-zero.
    if (subunitValue > BigInt.zero) {
      String subunitText = _convertInteger(subunitValue);
      // Ensure subunit name is provided.
      String subUnitName = currencyInfo.subUnitSingular ?? "";
      subunitPart = '$subunitText $subUnitName';
    }

    // Combine parts.
    if (mainPart.isNotEmpty && subunitPart.isNotEmpty) {
      // Use space as separator.
      return '$mainPart$_currencySeparator$subunitPart';
    } else if (mainPart.isNotEmpty) {
      return mainPart;
    } else if (subunitPart.isNotEmpty) {
      // Handle cases like 0.75 -> "yetmiş beş kuruş"
      return subunitPart;
    } else {
      // Should be covered by initial zero check, but as fallback.
      return "$_zero ${currencyInfo.mainUnitSingular}";
    }
  }

  /// Converts a non-negative standard [Decimal] number to Turkish words.
  ///
  /// Converts integer and fractional parts. Uses [TrOptions.decimalSeparator] word.
  /// Fractional part converted digit by digit, using "sıfır" for 0.
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Turkish words.
  String _handleStandardNumber(Decimal absValue, TrOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = (absValue - absValue.truncate()).abs();

    // Convert integer part. Use "sıfır" if integer is 0 but fraction exists (e.g., 0.5).
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    // Convert fractional part if it exists.
    if (fractionalPart > Decimal.zero) {
      String separatorWord;
      // Determine separator word (default comma).
      switch (options.decimalSeparator ?? DecimalSeparator.comma) {
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          separatorWord = _decimalSeparatorPeriodWord;
          break;
        case DecimalSeparator.comma:
          separatorWord = _decimalSeparatorCommaWord;
          break;
      }

      // Get fractional digits string.
      String fractionalDigits = absValue.toString().split('.').last;
      // Don't remove trailing zeros here, as "1.50" -> "bir virgül beş sıfır" might be desired
      // depending on context, though "bir virgül beş" is more common.
      // The original code implicitly keeps them via digit-by-digit mapping.

      // Convert each fractional digit.
      List<String> digitWords = fractionalDigits.split('').map((digit) {
        final int? digitInt = int.tryParse(digit);
        if (digitInt != null && digitInt >= 0 && digitInt <= 9) {
          // Use "sıfır" for 0, as _units[0] is empty.
          return digitInt == 0 ? _zero : _units[digitInt];
        }
        return '?'; // Fallback.
      }).toList();

      // Combine separator and digit words.
      fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
    }

    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] into Turkish words using scale words.
  ///
  /// Breaks number into chunks of 1000. Handles "bin" (1000) vs "bir bin".
  ///
  /// @param n Non-negative integer.
  /// @throws ArgumentError if [n] is too large for defined scales.
  /// @return Integer as Turkish words.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _zero;

    List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0; // 0: base, 1: thousand, ...
    BigInt remaining = n;

    while (remaining > BigInt.zero) {
      if (scaleIndex >= _scaleWords.length) {
        throw ArgumentError(
            "Number too large (exceeds scale: ${_scaleWords.last})");
      }

      BigInt chunkBigInt = remaining % oneThousand;
      int chunk = chunkBigInt.toInt(); // 0-999 fits in int.
      remaining ~/= oneThousand;

      if (chunk > 0) {
        String chunkText;
        // Special case: 1000 is "bin", not "bir bin".
        if (scaleIndex == 1 && chunk == 1) {
          chunkText = ""; // The scale word "bin" itself is sufficient.
        } else {
          // Convert the 0-999 chunk.
          chunkText = _convertChunk(chunk);
        }

        // Get scale word (e.g., "bin", "milyon").
        String scaleWord = scaleIndex > 0 ? _scaleWords[scaleIndex] : "";

        String currentPart = chunkText;
        if (scaleWord.isNotEmpty) {
          // If chunkText is empty (case 1000), just use scaleWord. Otherwise combine.
          currentPart = chunkText.isEmpty ? scaleWord : "$chunkText $scaleWord";
        }
        parts.add(currentPart);
      }
      scaleIndex++;
    }

    // Join parts from highest scale down.
    return parts.reversed.join(' ');
  }

  /// Converts an integer between 0 and 999 into Turkish words.
  ///
  /// Handles hundreds, tens, and units. Special case for 100 ("yüz").
  ///
  /// @param n Integer chunk (0-999).
  /// @return Chunk as Turkish words, or empty string if 0.
  /// @throws ArgumentError if n is outside 0-999.
  String _convertChunk(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    List<String> words = [];
    int remainder = n;

    // Handle hundreds.
    if (remainder >= 100) {
      int hundredsDigit = remainder ~/ 100;
      // 100 is "yüz", 200+ is "[digit] yüz".
      if (hundredsDigit == 1) {
        words.add(_hundred);
      } else {
        words.add(_units[hundredsDigit]);
        words.add(_hundred);
      }
      remainder %= 100;
    }

    // Handle tens.
    if (remainder >= 10) {
      words.add(_tens[remainder ~/ 10]); // "on", "yirmi", ...
      remainder %= 10;
    }

    // Handle units.
    if (remainder > 0) {
      words.add(_units[remainder]); // "bir", "iki", ...
    }

    // Join parts with space.
    return words.join(' ');
  }
}
