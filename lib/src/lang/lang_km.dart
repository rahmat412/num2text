import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/km_options.dart';
import '../utils/utils.dart';

/// {@template num2text_km}
/// The Khmer language (Lang.KM) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Khmer word representation following standard Khmer grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [KmOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers
/// (using specific Khmer scale words like ម៉ឺន, សែន, លាន, etc.).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [KmOptions].
/// {@endtemplate}
class Num2TextKM implements Num2TextBase {
  /// The Khmer word for zero ("0").
  static const String _zero = "សូន្យ";

  /// The default Khmer word for the decimal point (".").
  static const String _point = "ចុច";

  /// The Khmer word for the comma decimal separator (",").
  static const String _comma = "ក្បៀស";

  /// Khmer words for digits 0 through 9.
  static const List<String> _digits = [
    "សូន្យ", // 0
    "មួយ", // 1
    "ពីរ", // 2
    "បី", // 3
    "បួន", // 4
    "ប្រាំ", // 5
    "ប្រាំមួយ", // 6
    "ប្រាំពីរ", // 7
    "ប្រាំបី", // 8
    "ប្រាំបួន", // 9
  ];

  /// Khmer word for ten ("10").
  static const String _ten = "ដប់";

  /// Khmer word for hundred ("100").
  static const String _hundred = "រយ";

  /// Khmer word for thousand ("1,000").
  static const String _thousand = "ពាន់";

  /// Khmer word for ten thousand ("10,000").
  static const String _tenThousand = "ម៉ឺន";

  /// Khmer word for hundred thousand ("100,000").
  static const String _hundredThousand = "សែន";

  /// Khmer word for million ("1,000,000").
  static const String _million = "លាន";

  /// Suffix for years Before Common Era (BC/BCE). "ម.គ.ស" (មុនគ្រិស្តសករាជ).
  static const String _yearSuffixBC = "ម.គ.ស";

  /// Suffix for years in the Common Era (AD/CE). "គ.ស" (គ្រិស្តសករាជ).
  static const String _yearSuffixAD = "គ.ស";

  /// Maps large number scale powers (exponent of 10) to their Khmer word representation.
  /// Note: Khmer often builds very large numbers compositionally.
  static const Map<int, String> _scales = {
    24: "លានលានលានលាន", // 10^24 Quadrillion (short scale) ~ Septillion (long scale)
    21: "ពាន់លានលានលាន", // 10^21 Sextillion
    18: "លានលានលាន", // 10^18 Quintillion
    15: "ពាន់លានលាន", // 10^15 Quadrillion
    12: "លានលាន", // 10^12 Trillion
    9: "ពាន់លាន", // 10^9 Billion (short scale) / Milliard (long scale)
    6: _million, // 10^6 Million
    // Scales below 1,000,000 are handled by specific words or composition
  };

  /// Pre-calculated BigInt values for each scale power for efficient calculation.
  static final Map<int, BigInt> _scaleUnits = {
    for (var p in _scales.keys) p: BigInt.parse('1${'0' * p}'),
  };

  /// A sorted list of scale powers (descending) for processing large numbers.
  static final List<int> _sortedPowers = _scales.keys.toList()
    ..sort((a, b) => b.compareTo(a));

  /// Processes the given [number] and converts it into Khmer words based on the provided [options].
  ///
  /// - [number]: The number to convert. Can be `int`, `double`, `String`, `BigInt`, or `Decimal`.
  /// - [options]: Optional [KmOptions] to customize the conversion (e.g., currency, year format).
  ///              If null or not [KmOptions], default options are used.
  /// - [fallbackOnError]: An optional string to return if the input is invalid (e.g., `null`, `NaN`, non-numeric string).
  ///                      If null, a default Khmer error message ("មិនមែនជាលេខ") is used.
  ///
  /// Returns the Khmer word representation of the number, or an error string if conversion fails.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final kmOptions = options is KmOptions ? options : const KmOptions();
    final errorMsg = fallbackOnError ?? "មិនមែនជាលេខ"; // "Not a number"

    // Handle special double values first
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? "អវិជ្ជមានភាពមិនចេះចប់" // "Negative infinity"
            : "ភាពមិនចេះចប់"; // "Infinity"
      }
      if (number.isNaN) return errorMsg; // "NaN"
    }

    // Normalize the input number to Decimal for consistent handling
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorMsg;

    // Handle zero separately
    if (decimalValue == Decimal.zero) {
      return kmOptions.currency
          ? "$_zero ${kmOptions.currencyInfo.mainUnitSingular}"
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for the main conversion logic
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Apply specific formatting based on options
    if (kmOptions.format == Format.year) {
      // Year formatting handles negativity internally (BC/AD suffix)
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), kmOptions);
    } else {
      // Handle currency or standard number format
      if (kmOptions.currency) {
        textResult = _handleCurrency(absValue, kmOptions);
      } else {
        textResult = _handleStandardNumber(absValue, kmOptions);
      }

      // Prepend negative prefix if necessary (only for non-year formats here)
      if (isNegative) {
        textResult = "${kmOptions.negativePrefix} $textResult";
      }
    }

    return textResult.trim();
  }

  /// Formats a number as a year in Khmer.
  ///
  /// - [year]: The year as a [BigInt]. Can be negative.
  /// - [options]: The [KmOptions] containing formatting preferences (e.g., `includeAD`).
  ///
  /// Handles negative years by appending the BC/BCE suffix (`ម.គ.ស`).
  /// Appends the AD/CE suffix (`គ.ស`) for positive years only if `options.includeAD` is true.
  /// Returns the formatted year string.
  String _handleYearFormat(BigInt year, KmOptions options) {
    final bool isNegative = year < BigInt.zero;
    final BigInt absYear = isNegative ? -year : year;

    // Handle year zero (though rare in standard calendars)
    if (absYear == BigInt.zero) return _zero;

    // Convert the absolute year value to words
    String yearText = _convertInteger(absYear);

    // Append era suffix based on sign and options
    if (isNegative) {
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD) {
      // Only add AD suffix for positive years if includeAD is true
      yearText += " $_yearSuffixAD";
    }
    return yearText;
  }

  /// Formats a number as currency in Khmer.
  ///
  /// - [absValue]: The absolute value of the currency amount as a [Decimal].
  /// - [options]: The [KmOptions] containing currency information ([currencyInfo]).
  ///
  /// Currently, this implementation only handles the main currency unit (e.g., Riel)
  /// and truncates any subunits (e.g., Sen), based on common usage and test cases.
  /// Returns the formatted currency string (e.g., "មួយរយម្ភៃបី រៀល").
  String _handleCurrency(Decimal absValue, KmOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;

    // Get the main currency unit name (singular form is generally used after numbers in Khmer)
    final String unitSingular = currencyInfo.mainUnitSingular;

    // Truncate to get the main unit value (ignore subunits like Sen)
    final BigInt mainValue = absValue.truncate().toBigInt();

    // Handle zero currency case
    if (mainValue == BigInt.zero) {
      // Even for zero, append the currency unit
      return "$_zero $unitSingular";
    }

    // Convert the main value to words
    String mainText = _convertInteger(mainValue);

    // Combine value and unit name
    return "$mainText $unitSingular";
  }

  /// Handles standard number conversion (integer and fractional parts).
  ///
  /// - [absValue]: The non-negative decimal value of the number.
  /// - [options]: The [KmOptions] specifying decimal separator preferences.
  /// Returns the number formatted as standard Khmer words.
  String _handleStandardNumber(Decimal absValue, KmOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part. Use "សូន្យ" if integer is 0 but decimal exists (e.g., 0.5).
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word based on options
      final String separatorWord =
          (options.decimalSeparator == DecimalSeparator.comma)
              ? _comma
              : _point;

      // Get the fractional part as a string. Using toString() preserves scale.
      final String fractionalString = absValue.toString().split('.').last;

      // Convert each digit after the separator individually
      final List<String> digitWords = fractionalString.split('').map((d) {
        final int? digitInt = int.tryParse(d);
        // Use digit word or '?' for unexpected characters
        return (digitInt != null && digitInt >= 0 && digitInt < _digits.length)
            ? _digits[digitInt]
            : '?';
      }).toList();

      fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
    }
    // Integers represented as Decimals (e.g., 123.0) are handled: fractionalPart is zero.

    // Combine integer and fractional parts
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] integer into Khmer words.
  ///
  /// Handles numbers from zero up to very large scales defined in `_scales`.
  /// Uses recursion and scale mapping for large numbers.
  ///
  /// - [n]: The non-negative integer to convert.
  /// Returns the integer formatted as Khmer words.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _zero;
    // Precondition check: Ensure non-negative input
    assert(!n.isNegative);

    // Handle numbers less than 1,000 directly
    if (n < BigInt.from(1000)) {
      return _convertUnder1000(n.toInt());
    }

    // Handle larger numbers using scale words
    List<String> parts = [];
    BigInt remainder = n;

    // Iterate through defined scales from largest to smallest
    for (int power in _sortedPowers) {
      BigInt scaleUnit = _scaleUnits[power]!;
      String scaleWord = _scales[power]!;

      if (remainder >= scaleUnit) {
        // Determine how many chunks of this scale fit
        BigInt chunk = remainder ~/ scaleUnit;
        // Update the remainder for the next iteration
        remainder %= scaleUnit;

        // Convert the chunk value (multiplier) to words recursively
        String chunkText = _convertInteger(chunk);

        // Combine chunk text and scale word. Khmer often joins number and scale word.
        parts.add("$chunkText$scaleWord");
      }
    }

    // Convert any remaining part (less than the smallest defined scale, which is 1,000,000)
    if (remainder > BigInt.zero) {
      // The remainder will be less than 1,000,000 here.
      // Convert it using the dedicated helper for numbers under a million.
      parts.add(_convertUnderMillion(remainder.toInt()));
    }

    // Join all parts with spaces
    return parts.join(' ');
  }

  /// Converts an integer between 0 and 999,999 into Khmer words.
  /// Helper for `_convertInteger` to handle the part below one million.
  ///
  /// - [n]: The integer to convert (0 <= n < 1,000,000).
  /// Returns the number formatted as Khmer words, or "" if n is 0.
  String _convertUnderMillion(int n) {
    if (n == 0) return "";
    // Precondition check
    assert(n > 0 && n < 1000000);

    List<String> words = [];
    int remainder = n;

    // Handle Hundred Thousands (សែន - 100,000)
    int hundredThousands = remainder ~/ 100000;
    if (hundredThousands > 0) {
      // Combine digit and scale word (e.g., មួយសែន)
      words.add(_digits[hundredThousands] + _hundredThousand);
      remainder %= 100000;
    }

    // Handle Ten Thousands (ម៉ឺន - 10,000)
    int tenThousands = remainder ~/ 10000;
    if (tenThousands > 0) {
      // Combine digit and scale word (e.g., ពីរម៉ឺន)
      words.add(_digits[tenThousands] + _tenThousand);
      remainder %= 10000;
    }

    // Handle Thousands (ពាន់ - 1,000)
    int thousands = remainder ~/ 1000;
    if (thousands > 0) {
      // Combine digit and scale word (e.g., បីពាន់)
      words.add(_digits[thousands] + _thousand);
      remainder %= 1000;
    }

    // Handle the remaining part under 1000
    if (remainder > 0) {
      words.add(_convertUnder1000(remainder));
    }

    // Join the parts with spaces
    return words.join(' ');
  }

  /// Converts an integer between 0 and 999 into Khmer words.
  ///
  /// This is the base case for smaller integer conversions.
  /// Returns an empty string if n is 0.
  ///
  /// - [n]: The integer to convert (0 <= n < 1000).
  /// Returns the number formatted as Khmer words, or "" if n is 0.
  String _convertUnder1000(int n) {
    if (n == 0)
      return ""; // Return empty string, zero is handled by the caller if needed
    // Precondition check
    assert(n > 0 && n < 1000);

    List<String> words = [];
    int remainder = n;

    // Handle Hundreds (រយ - 100)
    int hundredsDigit = remainder ~/ 100;
    if (hundredsDigit > 0) {
      // Combine digit and scale word (e.g., មួយរយ)
      words.add(_digits[hundredsDigit] + _hundred);
      remainder %= 100;
    }

    // Handle Tens and Units (1-99)
    if (remainder > 0) {
      if (remainder < 10) {
        // Units only (1-9)
        words.add(_digits[remainder]);
      } else {
        // Tens (10-99)
        int tensDigit = remainder ~/ 10;
        int unitDigit = remainder % 10;

        String tensWord;
        switch (tensDigit) {
          case 1: // 10-19
            tensWord = _ten; // ដប់
            break;
          case 2: // 20-29
            tensWord = "ម្ភៃ"; // Special word for 20
            break;
          case 3: // 30-39
            tensWord = "សាមសិប";
            break;
          case 4: // 40-49
            tensWord = "សែសិប";
            break;
          case 5: // 50-59
            tensWord = "ហាសិប";
            break;
          case 6: // 60-69
            tensWord = "ហុកសិប";
            break;
          case 7: // 70-79
            tensWord = "ចិតសិប";
            break;
          case 8: // 80-89
            tensWord = "ប៉ែតសិប";
            break;
          case 9: // 90-99
            tensWord = "កៅសិប";
            break;
          default:
            tensWord = ""; // Should not happen
            break;
        }
        words.add(tensWord);

        // Add unit digit if present (e.g., for ដប់មួយ, ម្ភៃបី, etc.)
        if (unitDigit > 0) {
          // Append the unit digit word directly
          words.add(_digits[unitDigit]);
        }
      }
    }

    // Join parts. Khmer often concatenates number words without spaces for numbers under 1000.
    // e.g., 123 -> មួយរយ + ម្ភៃ + បី -> មួយរយម្ភៃបី
    return words.join('');
  }
}
