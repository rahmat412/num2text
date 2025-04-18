import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ko_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ko}
/// The Korean language (Lang.KO) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Korean word representation following standard Korean grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [KoOptions.currencyInfo], typically KRW Won),
/// year formatting ([Format.year] with optional BC/AD markers), negative numbers, decimals,
/// and large numbers using the Korean four-digit grouping system (만, 억, 조, etc.).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [KoOptions].
/// {@endtemplate}
class Num2TextKO implements Num2TextBase {
  // --- Constants ---

  /// The Korean word for zero ("영").
  static const String _zero = "영";

  /// The default Korean word for the decimal point ("점").
  static const String _point = "점";

  /// The Korean word for comma, used as an alternative decimal separator ("쉼표").
  static const String _comma = "쉼표";

  /// The Korean word for infinity ("무한대").
  static const String _infinity = "무한대";

  /// The Korean word for negative infinity ("음의 무한대").
  static const String _negativeInfinity = "음의 무한대";

  /// The Korean word for "Not a Number" ("숫자가 아님").
  static const String _nan = "숫자가 아님";

  /// Korean digits 0-9.
  static const List<String> _digits = [
    "영",
    "일",
    "이",
    "삼",
    "사",
    "오",
    "육",
    "칠",
    "팔",
    "구"
  ];

  /// The Korean word for ten ("십").
  static const String _ten = "십";

  /// The Korean word for hundred ("백").
  static const String _hundred = "백";

  /// The Korean word for thousand ("천").
  static const String _thousand = "천";

  /// Korean large number scale units (powers of 10,000), starting from 10^0.
  /// "", "만" (10^4), "억" (10^8), "조" (10^12), "경" (10^16), "해" (10^20), "자" (10^24).
  static const List<String> _largeScaleUnits = [
    "",
    "만",
    "억",
    "조",
    "경",
    "해",
    "자"
  ];

  /// The Korean prefix for AD/CE years ("서기"). Used only when `includeAD` is true.
  static const String _adPrefix = "서기";

  /// The Korean prefix for BC/BCE years ("기원전"). Used for negative years.
  static const String _bcPrefix = "기원전";

  /// The primary currency unit in Korean ("원"). From [KoOptions.currencyInfo].
  // static const String _currencyUnit = "원"; // Removed as it's derived from CurrencyInfo

  /// The factor for large number scaling (10,000).
  static final BigInt _scaleFactor = BigInt.from(10000);

  /// Processes the given [number] and converts it to its Korean text representation.
  ///
  /// - [number]: The number to convert. Can be an `int`, `double`, `BigInt`, `Decimal`, or `String`.
  /// - [options]: Optional [KoOptions] to control formatting (currency, year, decimal separator, etc.).
  ///   If null or not [KoOptions], default options are used.
  /// - [fallbackOnError]: Optional string to return if the input is invalid or conversion fails
  ///   (e.g., null, NaN, non-numeric string). If null, defaults to [_nan].
  ///
  /// Returns the Korean text representation of the number, or the fallback string on error.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final KoOptions koOptions =
        options is KoOptions ? options : const KoOptions();
    final String errorMsg = fallbackOnError ?? _nan;

    // Handle special double values early
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? _negativeInfinity : _infinity;
      }
      if (number.isNaN) {
        return errorMsg;
      }
    }

    // Normalize the input number to Decimal
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Handle invalid or null input
    if (decimalValue == null) {
      return errorMsg;
    }

    // Handle zero separately for simpler logic
    if (decimalValue == Decimal.zero) {
      if (koOptions.currency) {
        // Use the currency unit name from options
        return "$_zero ${koOptions.currencyInfo.mainUnitSingular}";
      }
      // Year zero or standard zero is just "영"
      return _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for conversion logic
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Route to specific handlers based on options
    if (koOptions.format == Format.year) {
      // Year format handles its own sign prefix (BC/AD)
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), koOptions);
    } else {
      if (koOptions.currency) {
        textResult = _handleCurrency(absValue, koOptions);
      } else {
        textResult = _handleStandardNumber(absValue, koOptions);
      }

      // Prepend negative prefix if applicable (and not already handled by year format)
      if (isNegative) {
        textResult = "${koOptions.negativePrefix}$textResult";
      }
    }

    return textResult;
  }

  /// Handles formatting a number as a Korean year.
  ///
  /// - [year]: The integer representation of the year. Can be negative.
  /// - [options]: Provides formatting settings, specifically `includeAD`.
  /// Prepends "기원전" ([_bcPrefix]) for negative years.
  /// Prepends "서기" ([_adPrefix]) for positive years *only* if `options.includeAD` is true.
  ///
  /// Returns the formatted year string.
  String _handleYearFormat(BigInt year, KoOptions options) {
    final bool isNegative = year < BigInt.zero;
    final BigInt absYear = isNegative ? -year : year;

    // Year zero is handled in the main process method.
    if (absYear == BigInt.zero) return _zero;

    String yearText = _convertInteger(absYear);

    String prefix = "";
    if (isNegative) {
      prefix = "$_bcPrefix ";
    } else if (options.includeAD) {
      // AD prefix only for positive years and when explicitly requested.
      prefix = "$_adPrefix ";
    }

    return "$prefix$yearText";
  }

  /// Handles formatting a number as Korean currency (Won by default).
  ///
  /// - [absValue]: The non-negative Decimal value of the currency amount.
  /// - [options]: The [KoOptions] containing currency information ([currencyInfo]).
  /// Converts the integer part of the number and appends the main currency unit name (e.g., "원").
  /// Subunits (like Jeon) are not currently handled as they are rarely used.
  ///
  /// Returns the formatted currency string (e.g., "백이십삼 원").
  String _handleCurrency(Decimal absValue, KoOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final String currencyUnit = currencyInfo.mainUnitSingular;

    // Currency format typically ignores fractional parts in modern Korean usage.
    final BigInt mainValue = absValue.truncate().toBigInt();

    // Zero currency is handled in the main process method.
    if (mainValue == BigInt.zero) return "$_zero $currencyUnit";

    String mainText = _convertInteger(mainValue);

    return "$mainText $currencyUnit";
  }

  /// Handles standard number formatting, including decimals.
  ///
  /// - [absValue]: The non-negative Decimal value.
  /// - [options]: Provides formatting settings like `decimalSeparator`.
  /// Converts the integer part. If there's a fractional part, converts it digit by digit
  /// and joins with the appropriate separator word ("점" or "쉼표").
  ///
  /// Returns the formatted number string (e.g., "백이십삼 점 사오육").
  String _handleStandardNumber(Decimal absValue, KoOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part. Use "영" if the integer part is zero but there's a fractional part.
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';

    // Process fractional part if it exists
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word based on options
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _comma;
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period:
        default: // Default to period/point representation "점"
          separatorWord = _point;
          break;
      }

      // Extract fractional digits as a string using toString().
      String fractionalDigits = absValue.toString().split('.').last;

      // Convert each fractional digit to its Korean word
      List<String> digitWords = fractionalDigits.split('').map((digit) {
        final int? digitInt = int.tryParse(digit);
        // Ensure the digit is valid before looking up in _digits
        return (digitInt != null && digitInt >= 0 && digitInt < _digits.length)
            ? _digits[digitInt]
            : '?'; // Fallback for unexpected characters
      }).toList();

      // Join fractional digits without spaces in Korean (e.g., 점 사오육)
      fractionalWords = ' $separatorWord ${digitWords.join('')}';
    }
    // Integers represented as Decimals (e.g., 123.0) are handled correctly.

    // Combine integer and fractional parts
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] integer to its Korean text representation.
  ///
  /// Handles large numbers by chunking them into groups of 10,000 ([_scaleFactor])
  /// and applying the appropriate scale unit ([_largeScaleUnits]).
  /// Delegates the conversion of chunks under 10,000 to [_convertUnder10000].
  /// Correctly handles omitting "일" before scale units (e.g., 만, 억, 조).
  ///
  /// - [n]: The non-negative integer to convert. Must be non-negative.
  /// Throws [ArgumentError] if the number is too large for the defined scale units.
  /// Returns the Korean text for the integer.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _zero;
    // Precondition: Ensure n is non-negative
    assert(n > BigInt.zero);

    List<String> parts = [];
    BigInt remaining = n;
    int scaleIndex = 0; // 0: base, 1: 만, 2: 억, ...

    // Process the number in chunks of 10,000 (만)
    while (remaining > BigInt.zero) {
      // Check if the number exceeds the largest defined scale unit
      if (scaleIndex >= _largeScaleUnits.length) {
        throw ArgumentError(
          "Number too large to convert (exceeds defined scale: ${_largeScaleUnits.last})",
        );
      }

      // Get the current chunk (0-9999)
      BigInt chunkBigInt = remaining % _scaleFactor;
      // Prepare for the next iteration
      remaining ~/= _scaleFactor;

      // Process the chunk only if it's non-zero. Skip zero chunks entirely.
      if (chunkBigInt > BigInt.zero) {
        int chunk = chunkBigInt.toInt(); // Safe to convert as chunk < 10000
        String chunkText = _convertUnder10000(chunk);
        String scaleWord = _largeScaleUnits[scaleIndex];

        // Omit "일" before scale units (e.g., 1만 is "만", not "일만")
        // This applies only when the chunk is exactly 1 and it's not the base scale (index > 0)
        if (chunk == 1 && scaleIndex > 0) {
          chunkText =
              ""; // Clear "일" representation, leaving only the scale word
        }
        // Combine the (potentially modified) chunk text and the scale word
        parts.add("$chunkText$scaleWord");
      }
      scaleIndex++;
    }

    // Join the parts in reverse order (highest scale unit first) without spaces between them.
    return parts.reversed.join('');
  }

  /// Converts an integer between 0 and 9999 to its Korean text representation.
  ///
  /// Handles thousands ("천"), hundreds ("백"), and tens ("십").
  /// Correctly omits "일" before "천", "백", "십" (e.g., 1111 is "천백십일").
  /// Returns an empty string if n is 0.
  ///
  /// - [n]: The integer to convert (0 <= n < 10000).
  /// Returns the Korean text for the number under 10,000, or "" if n is 0.
  String _convertUnder10000(int n) {
    if (n == 0) return "";
    // Precondition check
    assert(n > 0 && n < 10000);

    List<String> words = [];
    int remainder = n;

    // Thousands place (천)
    int thousandsDigit = remainder ~/ 1000;
    if (thousandsDigit > 0) {
      // Omit "일" if the digit is 1 (e.g., 1000 is 천, 2000 is 이천)
      if (thousandsDigit > 1) {
        words.add(_digits[thousandsDigit]);
      }
      words.add(_thousand);
      remainder %= 1000;
    }

    // Hundreds place (백)
    int hundredsDigit = remainder ~/ 100;
    if (hundredsDigit > 0) {
      // Omit "일" if the digit is 1
      if (hundredsDigit > 1) {
        words.add(_digits[hundredsDigit]);
      }
      words.add(_hundred);
      remainder %= 100;
    }

    // Tens place (십)
    int tensDigit = remainder ~/ 10;
    if (tensDigit > 0) {
      // Omit "일" if the digit is 1
      if (tensDigit > 1) {
        words.add(_digits[tensDigit]);
      }
      words.add(_ten);
      remainder %= 10;
    }

    // Units place (일, 이, ..., 구)
    int unitDigit = remainder;
    if (unitDigit > 0) {
      words.add(_digits[unitDigit]);
    }

    // Join parts without spaces in Korean (e.g., 천백십일)
    return words.join('');
  }
}
