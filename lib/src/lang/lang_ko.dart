import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ko_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ko}
/// Converts numbers to Korean words (`Lang.KO`).
///
/// Implements [Num2TextBase] for Korean. Handles various numeric types.
/// Supports cardinal numbers, decimals, negatives, currency (Won), years (with optional AD/BC),
/// and large numbers using the four-digit grouping system (만, 억, 조, etc.).
/// Customizable via [KoOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextKO implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "영";
  static const String _point = "점"; // Default decimal separator word.
  static const String _comma = "쉼표"; // Alternative decimal separator word.
  static const String _infinity = "무한대";
  static const String _negativeInfinity = "음의 무한대";
  static const String _nan = "숫자가 아님"; // Default "Not a Number" fallback.
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
  static const String _ten = "십";
  static const String _hundred = "백";
  static const String _thousand = "천";

  /// Korean large number scale units (powers of 10,000).
  static const List<String> _largeScaleUnits = [
    "",
    "만",
    "억",
    "조",
    "경",
    "해",
    "자"
  ];
  static const String _adPrefix =
      "서기"; // Prefix for AD/CE years (if requested).
  static const String _bcPrefix = "기원전"; // Prefix for BC/BCE years.
  static final BigInt _scaleFactor = BigInt.from(10000); // Grouping factor.

  /// Processes the given [number] into Korean words.
  ///
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// Uses [KoOptions] for customization (currency, year, decimals, AD/BC).
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or [_nan] on failure.
  ///
  /// @param number The number to convert.
  /// @param options Optional [KoOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Korean words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final KoOptions koOptions =
        options is KoOptions ? options : const KoOptions();
    final String errorMsg = fallbackOnError ?? _nan;

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _negativeInfinity : _infinity;
      if (number.isNaN) return errorMsg;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorMsg;

    if (decimalValue == Decimal.zero) {
      return koOptions.currency
          ? "$_zero ${koOptions.currencyInfo.mainUnitSingular}"
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    if (koOptions.format == Format.year) {
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), koOptions);
    } else {
      textResult = koOptions.currency
          ? _handleCurrency(absValue, koOptions)
          : _handleStandardNumber(absValue, koOptions);
      if (isNegative) {
        textResult = "${koOptions.negativePrefix} $textResult";
      }
    }
    return textResult;
  }

  /// Converts an integer year to Korean words.
  ///
  /// Prepends [_bcPrefix] for negative years.
  /// Prepends [_adPrefix] for positive years if [KoOptions.includeAD] is true.
  ///
  /// @param year The integer year value.
  /// @param options Formatting options.
  /// @return The year as Korean words.
  String _handleYearFormat(BigInt year, KoOptions options) {
    final bool isNegative = year < BigInt.zero;
    final BigInt absYear = isNegative ? -year : year;
    if (absYear == BigInt.zero)
      return _zero; // Should be caught by process, but safe check.

    String yearText = _convertInteger(absYear);
    String prefix = "";
    if (isNegative)
      prefix = "$_bcPrefix ";
    else if (options.includeAD) prefix = "$_adPrefix ";

    return "$prefix$yearText";
  }

  /// Converts a non-negative [Decimal] to Korean currency words (Won).
  ///
  /// Uses [KoOptions.currencyInfo]. Ignores fractional parts (Jeon are rarely used).
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Korean words.
  String _handleCurrency(Decimal absValue, KoOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final String currencyUnit = currencyInfo.mainUnitSingular;
    final BigInt mainValue = absValue.truncate().toBigInt();

    if (mainValue == BigInt.zero)
      return "$_zero $currencyUnit"; // Should be caught by process.

    String mainText = _convertInteger(mainValue);
    return "$mainText $currencyUnit";
  }

  /// Converts a non-negative standard [Decimal] number to Korean words.
  ///
  /// Converts integer and fractional parts. Uses [KoOptions.decimalSeparator] word.
  /// Fractional part converted digit by digit (e.g., 점 사오).
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Korean words.
  String _handleStandardNumber(Decimal absValue, KoOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      String sepWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          sepWord = _comma;
          break;
        default:
          sepWord = _point;
          break; // Default to 점
      }
      String fractionalDigits = absValue.toString().split('.').last;
      List<String> digitWords = fractionalDigits.split('').map((d) {
        final int? i = int.tryParse(d);
        return (i != null && i >= 0 && i < _digits.length) ? _digits[i] : '?';
      }).toList();
      // Join digits without spaces in Korean.
      fractionalWords = ' $sepWord ${digitWords.join('')}';
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] into Korean words using four-digit grouping.
  ///
  /// Uses scale units like 만, 억, 조. Delegates chunks under 10,000 to [_convertUnder10000].
  /// Handles omission of "일" before scales (e.g., 만, not 일만).
  ///
  /// @param n Non-negative integer.
  /// @throws ArgumentError if [n] is too large for defined scales.
  /// @return Integer as Korean words.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _zero;
    assert(n > BigInt.zero);

    if (n < _scaleFactor) return _convertUnder10000(n.toInt());

    List<String> parts = [];
    BigInt remaining = n;
    int scaleIndex = 0;

    while (remaining > BigInt.zero) {
      if (scaleIndex >= _largeScaleUnits.length) {
        throw ArgumentError(
            "Number too large (exceeds scale: ${_largeScaleUnits.last})");
      }
      BigInt chunkBigInt = remaining % _scaleFactor;
      remaining ~/= _scaleFactor;

      if (chunkBigInt > BigInt.zero) {
        int chunk = chunkBigInt.toInt();
        String chunkText = _convertUnder10000(chunk);
        String scaleWord = _largeScaleUnits[scaleIndex];

        // Omit the number "일" (1) before certain scales like 만 and 억 when chunk is 1.
        if (chunk == 1 && (scaleIndex == 1 || scaleIndex == 2)) {
          // 만 (1), 억 (2)
          chunkText = ""; // Just use the scale word.
        }
        parts.add("$chunkText$scaleWord");
      }
      scaleIndex++;
    }
    return parts.reversed.join('');
  }

  /// Converts an integer between 0 and 9999 into Korean words.
  ///
  /// Handles 천, 백, 십. Omits leading "일" (e.g., 천백십일, not 일천일백일십일).
  ///
  /// @param n Integer chunk (0-9999).
  /// @return Chunk as Korean words, or empty string if [n] is 0.
  String _convertUnder10000(int n) {
    if (n == 0) return "";
    assert(n > 0 && n < 10000);

    List<String> words = [];
    int remainder = n;

    // Thousands (천)
    int thousands = remainder ~/ 1000;
    if (thousands > 0) {
      if (thousands > 1) words.add(_digits[thousands]); // Add digit if > 1
      words.add(_thousand);
      remainder %= 1000;
    }

    // Hundreds (백)
    int hundreds = remainder ~/ 100;
    if (hundreds > 0) {
      if (hundreds > 1) words.add(_digits[hundreds]);
      words.add(_hundred);
      remainder %= 100;
    }

    // Tens (십)
    int tens = remainder ~/ 10;
    if (tens > 0) {
      if (tens > 1) words.add(_digits[tens]);
      words.add(_ten);
      remainder %= 10;
    }

    // Units
    if (remainder > 0) {
      words.add(_digits[remainder]);
    }

    return words.join('');
  }
}
