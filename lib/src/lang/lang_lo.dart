import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/lo_options.dart';
import '../utils/utils.dart';

/// {@template num2text_lo}
/// The Lao language (Lang.LO) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Lao word representation following standard Lao grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [LoOptions.currencyInfo], typically LAK Kip),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers using Lao scale words (ພັນ, ໝື່ນ, ແສນ, ລ້ານ, ຕື້, etc.).
/// Handles specific Lao rules like "ເອັດ" for unit '1' after tens/scales and "ຊາວ" for '20'.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [LoOptions].
/// {@endtemplate}
class Num2TextLO implements Num2TextBase {
  /// The word for "minus" or negative sign.
  static const String _negative = "ລົບ";

  /// The word for "zero".
  static const String _zero = "ສູນ";

  /// The word for the decimal point ("point").
  static const String _point = "ຈຸດ";

  /// The word for "infinity".
  static const String _infinity = "ອະນັນ";

  /// The word for "not a number".
  static const String _nan = "ບໍ່ແມ່ນຕົວເລກ";

  /// Lao digits 0-9. Note "1" is "ໜຶ່ງ" (neung).
  static const List<String> _digits = [
    "ສູນ", // 0
    "ໜຶ່ງ", // 1 (neung - used standalone or for scales like 100, 1000)
    "ສອງ", // 2
    "ສາມ", // 3
    "ສີ່", // 4
    "ຫ້າ", // 5
    "ຫົກ", // 6
    "ເຈັດ", // 7
    "ແປດ", // 8
    "ເກົ້າ", // 9
  ];

  /// Special form for "one" ("ເອັດ" - et) when used as a unit digit after tens (11, 21, 31...).
  static const String _unitOne = "ເອັດ";

  /// The word for "ten".
  static const String _ten = "ສິບ";

  /// The word for "twenty".
  static const String _twenty = "ຊາວ";

  /// The word for "hundred".
  static const String _hundred = "ຮ້ອຍ";

  /// The word for "thousand".
  static const String _thousand = "ພັນ";

  /// The word for "ten thousand".
  static const String _tenThousand = "ໝື່ນ";

  /// The word for "hundred thousand".
  static const String _hundredThousand = "ແສນ";

  /// The word for "million" (10^6).
  static const String _million = "ລ້ານ";

  /// The word for "billion" (10^9, short scale / milliard, long scale).
  static const String _billion = "ຕື້";

  // --- Large Scale Names ---
  // Lao builds larger scales by combining million/billion units.

  /// Scale name for 10^12 (Trillion).
  static const String _scale12 = "$_million$_million"; // ລ້ານລ້ານ

  /// Scale name for 10^15 (Quadrillion).
  static const String _scale15 = "$_thousand$_million$_million"; // ພັນລ້ານລ້ານ

  /// Scale name for 10^18 (Quintillion).
  static const String _scale18 = "$_million$_million$_million"; // ລ້ານລ້ານລ້ານ

  /// Scale name for 10^21 (Sextillion).
  static const String _scale21 =
      "$_thousand$_million$_million$_million"; // ພັນລ້ານລ້ານລ້ານ

  /// Scale name for 10^24 (Septillion).
  static const String _scale24 =
      "$_million$_million$_million$_million"; // ລ້ານລ້ານລ້ານລ້ານ

  /// Defines the limits and names for number scales, ordered largest to smallest.
  /// Used by `_convertInteger` to handle large number conversion recursively.
  static final List<Map<String, dynamic>> _scales = [
    {
      'limit': BigInt.parse('1000000000000000000000000'),
      'name': _scale24
    }, // 10^24
    {
      'limit': BigInt.parse('1000000000000000000000'),
      'name': _scale21
    }, // 10^21
    {'limit': BigInt.parse('1000000000000000000'), 'name': _scale18}, // 10^18
    {'limit': BigInt.parse('1000000000000000'), 'name': _scale15}, // 10^15
    {'limit': BigInt.parse('1000000000000'), 'name': _scale12}, // 10^12
    {'limit': BigInt.parse('1000000000'), 'name': _billion}, // 10^9
    {'limit': BigInt.parse('1000000'), 'name': _million}, // 10^6
    {'limit': BigInt.from(100000), 'name': _hundredThousand}, // 10^5
    {'limit': BigInt.from(10000), 'name': _tenThousand}, // 10^4
    {'limit': BigInt.from(1000), 'name': _thousand}, // 10^3
    {'limit': BigInt.from(100), 'name': _hundred}, // 10^2
    // Base cases (under 100) are handled directly.
  ];

  /// Processes the given number (int, double, BigInt, String, Decimal) and converts it to Lao words.
  ///
  /// - [number]: The number to convert. Handles various numeric types.
  /// - [options]: Optional [LoOptions] to customize conversion (e.g., currency, format).
  /// - [fallbackOnError]: A custom string to return if conversion fails unexpectedly.
  ///                    If null, a default error message ([_nan]) is used.
  /// Returns the Lao word representation of the number, or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final LoOptions loOptions =
        options is LoOptions ? options : const LoOptions();
    final String errorMsg = fallbackOnError ?? _nan; // Default error message

    // Handle special double values first
    if (number is double) {
      if (number.isInfinite) {
        // Combine negative prefix and infinity word if needed
        return number.isNegative ? "$_negative$_infinity" : _infinity;
      }
      if (number.isNaN) {
        return errorMsg; // Use fallback if provided, else default NaN word
      }
    }

    // Normalize the input to Decimal for consistent handling
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Handle invalid or non-numeric input
    if (decimalValue == null) {
      return errorMsg; // Use fallback if provided, else default NaN word
    }

    // Handle zero separately
    if (decimalValue == Decimal.zero) {
      // Add currency unit if requested
      return loOptions.currency
          ? "$_zero ${loOptions.currencyInfo.mainUnitSingular}"
          : _zero;
    }

    // Determine sign and work with absolute value
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    // Delegate to appropriate handler based on options
    String textResult;
    if (loOptions.currency) {
      textResult = _handleCurrency(absValue, loOptions);
    } else if (loOptions.format == Format.year) {
      // Lao year format doesn't typically use AD/BC markers.
      // Negative years are prefixed with "ລົບ". Positive years are standard numbers.
      textResult = _handleStandardNumber(absValue, loOptions);
    } else {
      textResult = _handleStandardNumber(absValue, loOptions);
    }

    // Prepend negative sign if necessary (applies to standard, currency, and year formats)
    if (isNegative) {
      final String negativePrefix = loOptions.negativePrefix;
      textResult = textResult.isNotEmpty
          ? "$negativePrefix $textResult"
          : negativePrefix;
    }

    return textResult.trim();
  }

  /// Handles the conversion of a number into Lao currency format.
  ///
  /// - [absValue]: The absolute decimal value of the number.
  /// - [options]: The [LoOptions] containing currency settings.
  /// Returns the number formatted as Lao Kip (LAK), ignoring subunits (att).
  String _handleCurrency(Decimal absValue, LoOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    // Lao Kip currency format typically ignores the fractional part (att).
    final BigInt mainValue = absValue.truncate().toBigInt();

    // Handle zero currency value
    if (mainValue == BigInt.zero) {
      return "$_zero ${currencyInfo.mainUnitSingular}";
    }

    // Convert the integer part to words
    String mainText = _convertInteger(mainValue);

    // Append the main currency unit name
    // Lao doesn't usually pluralize currency names in this context.
    return "$mainText ${currencyInfo.mainUnitSingular}";
  }

  /// Handles the conversion of a standard (non-currency) number, including decimals.
  ///
  /// - [absValue]: The absolute decimal value of the number.
  /// - [options]: The [LoOptions] specifying decimal separator preferences (Lao typically uses "ຈຸດ").
  /// Returns the standard Lao word representation of the number.
  String _handleStandardNumber(Decimal absValue, LoOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part. Use "ສູນ" if integer is 0 but decimal exists (e.g., 0.5).
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word (Lao typically uses 'ຈຸດ')
      final String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
        case DecimalSeparator.period:
        case DecimalSeparator.point:
        case null: // Default to period/point word if not specified
          separatorWord = _point; // "ຈຸດ"
          break;
      }

      // Get fractional digits as a string using toString() for reliability.
      String fractionalDigits = absValue.toString().split('.').last;
      // Convert each fractional digit to its word representation
      List<String> digitWords = fractionalDigits.split('').map((digit) {
        final int digitInt = int.parse(digit);
        return _digits[digitInt]; // Use the standard digit words
      }).toList();
      fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
    }
    // Integers represented as decimals (e.g., 123.0) are handled correctly.

    // Combine integer and fractional parts
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts an integer between 0 and 99 into Lao words.
  ///
  /// - [n]: The integer to convert (must be 0 <= n < 100).
  /// - [useEtForOne]: Flag indicating if the unit digit '1' should be rendered as "ເອັດ" (_unitOne).
  ///               This is true when '1' follows a tens place (11, 21...) or a scale word (101...).
  /// Returns the Lao word representation for the number below 100.
  String _convertBelowHundred(int n, {required bool useEtForOne}) {
    if (n == 0) return "";
    // Precondition check
    assert(n > 0 && n < 100);

    if (n == 1) {
      // Use "ເອັດ" if flag is set, otherwise standard "ໜຶ່ງ"
      return useEtForOne ? _unitOne : _digits[1];
    } else if (n < 10) {
      // 2-9
      return _digits[n];
    } else if (n == 10) {
      // 10
      return _ten;
    } else if (n == 11) {
      // 11 (always uses "ເອັດ")
      return "$_ten$_unitOne";
    } else if (n < 20) {
      // 12-19
      return "$_ten${_digits[n % 10]}";
    } else if (n == 20) {
      // 20
      return _twenty;
    } else {
      // 21-99
      int tensDigit = n ~/ 10;
      int unitDigit = n % 10;
      // Use "ຊາວ" for 20s, otherwise construct tens (e.g., "ສາມສິບ" for 30)
      String tensText =
          (tensDigit == 2) ? _twenty : "${_digits[tensDigit]}$_ten";

      if (unitDigit == 0) {
        // 30, 40, ..., 90
        return tensText;
      } else if (unitDigit == 1) {
        // 21, 31, ..., 91 (always use "ເອັດ")
        return "$tensText$_unitOne";
      } else {
        // 22-29, 32-39, ..., 92-99
        return "$tensText${_digits[unitDigit]}";
      }
    }
  }

  /// Converts a non-negative BigInt into Lao words.
  ///
  /// This method handles numbers from zero up to very large scales using recursion
  /// and the defined [_scales]. It applies Lao specific rules for "1" (ໜຶ່ງ/ເອັດ).
  ///
  /// - [n]: The non-negative BigInt to convert.
  /// Returns the Lao word representation of the integer.
  String _convertInteger(BigInt n) {
    // Base case: Zero
    if (n == BigInt.zero) return _zero;
    // Precondition: Ensure non-negative input
    assert(!n.isNegative);

    // Handle numbers below 100 directly
    if (n < BigInt.from(100)) {
      // For standalone <100, '1' is always "ໜຶ່ງ" (useEtForOne: false)
      return _convertBelowHundred(n.toInt(), useEtForOne: false);
    }

    // Iterate through scales from largest to smallest
    for (var scaleInfo in _scales) {
      BigInt limit = scaleInfo['limit'];
      String name = scaleInfo['name']; // e.g., ຮ້ອຍ, ພັນ, ລ້ານ...

      if (n >= limit) {
        BigInt count = n ~/ limit; // How many times the scale fits
        BigInt remainder = n % limit; // The rest of the number

        // Convert the count (multiplier) for the current scale recursively
        String countText = _convertInteger(count);

        // Special case: For scales 100 and above, if the count is exactly 1,
        // use "ໜຶ່ງ" instead of potentially "ເອັດ" from recursion.
        if (count == BigInt.one && limit >= BigInt.from(100)) {
          countText = _digits[1]; // Use "ໜຶ່ງ"
        }

        String remainderText = "";
        if (remainder > BigInt.zero) {
          // Determine if the remainder requires "ເອັດ" for a unit '1'.
          // This happens only if the *entire* remainder is 1.
          bool remainderNeedsEt = (remainder == BigInt.one);

          // Convert the remainder. Pass `remainderNeedsEt` to handle cases like 101, 1001.
          if (remainder < BigInt.from(100)) {
            remainderText = _convertBelowHundred(remainder.toInt(),
                useEtForOne: remainderNeedsEt);
          } else {
            // If remainder is >= 100, recurse normally. The "ເອັດ" rule applies only
            // to the final unit digit within that recursive call's base case if needed.
            remainderText = _convertInteger(remainder);
          }
        }

        // Combine count, scale name, and remainder. Lao often joins these without spaces.
        return "$countText$name$remainderText";
      }
    }

    // Should be unreachable if _scales cover up to 100 and input is handled correctly.
    throw StateError(
        "Exhausted scales processing number $n - check scale definitions.");
  }
}
