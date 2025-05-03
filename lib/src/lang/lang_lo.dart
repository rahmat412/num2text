import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/lo_options.dart';
import '../utils/utils.dart';

/// {@template num2text_lo}
/// Converts numbers to Lao words (`Lang.LO`).
///
/// Implements [Num2TextBase] for Lao. Handles various numeric types.
/// Supports cardinal numbers, decimals, negatives, currency (Kip), years,
/// and large numbers using Lao scales (ພັນ, ໝື່ນ, ແສນ, ລ້ານ, etc.).
/// Handles specific rules like "ເອັດ" for '1' after tens/scales and "ຊາວ" for '20'.
/// Customizable via [LoOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextLO implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "ສູນ";
  static const String _point = "ຈຸດ"; // Default decimal separator word.
  static const String _infinity = "ອະສົງໄຂ";
  static const String _negativeInfinity = "ລົບອະສົງໄຂ";
  static const String _nan =
      "ບໍ່ແມ່ນຕົວເລກ"; // Default "Not a Number" fallback.

  static const List<String> _digits = [
    "ສູນ",
    "ໜຶ່ງ",
    "ສອງ",
    "ສາມ",
    "ສີ່",
    "ຫ້າ",
    "ຫົກ",
    "ເຈັດ",
    "ແປດ",
    "ເກົ້າ",
  ];

  /// Special form "ເອັດ" for '1' as unit digit after tens or scales.
  static const String _unitOne = "ເອັດ";
  static const String _ten = "ສິບ";
  static const String _twenty = "ຊາວ"; // Special word for 20.
  static const String _hundred = "ຮ້ອຍ";
  static const String _thousand = "ພັນ";
  static const String _tenThousand = "ໝື່ນ";
  static const String _hundredThousand = "ແສນ";
  static const String _million = "ລ້ານ";
  static const String _billion = "ຕື້"; // Often 10^9 in modern usage.

  // --- Large Scale Construction ---
  // Lao builds larger scales by combining million/billion units.
  static const String _scale12 = "$_million$_million"; // 10^12 ລ້ານລ້ານ
  static const String _scale15 =
      "$_thousand$_million$_million"; // 10^15 ພັນລ້ານລ້ານ
  static const String _scale18 =
      "$_million$_million$_million"; // 10^18 ລ້ານລ້ານລ້ານ
  static const String _scale21 =
      "$_thousand$_million$_million$_million"; // 10^21 ພັນລ້ານລ້ານລ້ານ
  static const String _scale24 =
      "$_million$_million$_million$_million"; // 10^24 ລ້ານລ້ານລ້ານລ້ານ

  /// Scale definitions for large number processing (largest to smallest).
  static final List<Map<String, dynamic>> _scales = [
    {'limit': BigInt.parse('1000000000000000000000000'), 'name': _scale24},
    {'limit': BigInt.parse('1000000000000000000000'), 'name': _scale21},
    {'limit': BigInt.parse('1000000000000000000'), 'name': _scale18},
    {'limit': BigInt.parse('1000000000000000'), 'name': _scale15},
    {'limit': BigInt.parse('1000000000000'), 'name': _scale12},
    {'limit': BigInt.parse('1000000000'), 'name': _billion},
    {'limit': BigInt.parse('1000000'), 'name': _million},
    {'limit': BigInt.from(100000), 'name': _hundredThousand},
    {'limit': BigInt.from(10000), 'name': _tenThousand},
    {'limit': BigInt.from(1000), 'name': _thousand},
    {'limit': BigInt.from(100), 'name': _hundred},
  ];

  /// Processes the given [number] into Lao words.
  ///
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// Uses [LoOptions] for customization (currency, year, decimals).
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or [_nan] on failure.
  ///
  /// @param number The number to convert.
  /// @param options Optional [LoOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Lao words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final LoOptions loOptions =
        options is LoOptions ? options : const LoOptions();
    final String errorMsg = fallbackOnError ?? _nan;

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _negativeInfinity : _infinity;
      if (number.isNaN) return errorMsg;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorMsg;

    if (decimalValue == Decimal.zero) {
      return loOptions.currency
          ? "$_zero ${loOptions.currencyInfo.mainUnitSingular}"
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    // Lao year format typically doesn't use specific era markers like AD/BC.
    // Negative years are prefixed.
    if (loOptions.currency) {
      textResult = _handleCurrency(absValue, loOptions);
    } else {
      textResult = _handleStandardNumber(absValue, loOptions);
    }

    if (isNegative) {
      textResult = "${loOptions.negativePrefix} $textResult";
    }
    return textResult.trim();
  }

  /// Converts a non-negative [Decimal] to Lao currency words (Kip).
  ///
  /// Uses [LoOptions.currencyInfo]. Ignores fractional parts (Att are rarely used).
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Lao words.
  String _handleCurrency(Decimal absValue, LoOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final BigInt mainValue = absValue.truncate().toBigInt();
    if (mainValue == BigInt.zero)
      return "$_zero ${currencyInfo.mainUnitSingular}"; // Handled by process too.

    String mainText = _convertInteger(mainValue);
    // Lao currency units usually don't change form for plurals.
    return "$mainText ${currencyInfo.mainUnitSingular}";
  }

  /// Converts a non-negative standard [Decimal] number to Lao words.
  ///
  /// Converts integer and fractional parts. Uses the decimal separator word (typically "ຈຸດ").
  /// Fractional part converted digit by digit (e.g., ຈຸດ ຫ້າ).
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Lao words.
  String _handleStandardNumber(Decimal absValue, LoOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Lao predominantly uses "ຈຸດ".
      final String separatorWord = _point;
      String fractionalDigits = absValue.toString().split('.').last;
      List<String> digitWords = fractionalDigits.split('').map((d) {
        final int? i = int.tryParse(d);
        return (i != null && i >= 0 && i < _digits.length) ? _digits[i] : '?';
      }).toList();
      // Join digits with spaces in Lao decimal representation.
      fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts an integer from 0 to 99 into Lao words.
  ///
  /// Applies specific rules for 1 ("ໜຶ່ງ"/"ເອັດ") and 20 ("ຊາວ").
  ///
  /// @param n Integer (0-99).
  /// @param useEtForOne If true, unit digit '1' becomes "ເອັດ" (for 11, 21, etc.).
  /// @return Number as Lao words, or empty string if [n] is 0.
  String _convertBelowHundred(int n, {required bool useEtForOne}) {
    if (n == 0) return "";
    assert(n > 0 && n < 100);

    if (n == 1) return useEtForOne ? _unitOne : _digits[1]; // ໜຶ່ງ vs ເອັດ
    if (n < 10) return _digits[n]; // 2-9
    if (n == 10) return _ten;
    if (n == 11) return "$_ten$_unitOne"; // 11 always uses ເອັດ
    if (n < 20) return "$_ten${_digits[n % 10]}"; // 12-19
    if (n == 20) return _twenty; // ຊາວ

    // 21-99
    int tensDigit = n ~/ 10;
    int unitDigit = n % 10;
    String tensText = (tensDigit == 2)
        ? _twenty
        : "${_digits[tensDigit]}$_ten"; // ຊາວ or [digit]ສິບ

    if (unitDigit == 0) return tensText; // 30, 40,...
    if (unitDigit == 1)
      return "$tensText$_unitOne"; // 21, 31,... always uses ເອັດ
    return "$tensText${_digits[unitDigit]}"; // 22-29, 32-39,...
  }

  /// Converts a non-negative [BigInt] into Lao words using recursive scaling.
  ///
  /// Handles large numbers based on defined [_scales]. Applies Lao rules for "1".
  ///
  /// @param n Non-negative integer.
  /// @return Integer as Lao words.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _zero;
    assert(!n.isNegative);

    if (n < BigInt.from(100)) {
      // For standalone numbers < 100, '1' is always "ໜຶ່ງ".
      return _convertBelowHundred(n.toInt(), useEtForOne: false);
    }

    for (var scaleInfo in _scales) {
      BigInt limit = scaleInfo['limit'];
      String name = scaleInfo['name']; // e.g., ຮ້ອຍ, ພັນ, ລ້ານ...

      if (n >= limit) {
        BigInt count = n ~/ limit;
        BigInt remainder = n % limit;

        // Convert the multiplier for the scale.
        String countText = _convertInteger(count);
        // If count is 1 for scales 100+, ensure it's "ໜຶ່ງ", not "ເອັດ".
        if (count == BigInt.one && limit >= BigInt.from(100)) {
          countText = _digits[1];
        }

        String remainderText = "";
        if (remainder > BigInt.zero) {
          // 'ເອັດ' rule applies only if the entire remainder is 1.
          bool remainderNeedsEt = (remainder == BigInt.one);
          if (remainder < BigInt.from(100)) {
            remainderText = _convertBelowHundred(remainder.toInt(),
                useEtForOne: remainderNeedsEt);
          } else {
            remainderText = _convertInteger(remainder); // Recurse normally.
          }
        }
        // Lao often joins scales without spaces.
        return "$countText$name$remainderText";
      }
    }

    // Should only be reached if base case < 100 wasn't handled.
    throw StateError("Scale processing error for $n");
  }
}
