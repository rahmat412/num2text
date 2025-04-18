import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/th_options.dart';
import '../utils/utils.dart';

/// {@template num2text_th}
/// The Thai language (`Lang.TH`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Thai word representation following standard Thai grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [ThOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers
/// (using million "ล้าน" as a repeating scale marker).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [ThOptions].
/// {@endtemplate}
class Num2TextTH implements Num2TextBase {
  // --- Constants ---

  /// The Thai word for zero ("ศูนย์").
  static const String _zero = "ศูนย์";

  /// The Thai word for the decimal separator period (`.`) ("จุด").
  static const String _pointWord = "จุด";

  /// The Thai word for the decimal separator comma (`,`) ("ลูกน้ำ").
  static const String _commaWord = "ลูกน้ำ";

  /// Placeholder for the units place (no explicit word is used just for the place).
  static const String _unit = "";

  /// The Thai word for ten ("สิบ").
  static const String _ten = "สิบ";

  /// The Thai word for hundred ("ร้อย").
  static const String _hundred = "ร้อย";

  /// The Thai word for thousand ("พัน").
  static const String _thousand = "พัน";

  /// The Thai word for ten thousand ("หมื่น").
  static const String _tenThousand = "หมื่น";

  /// The Thai word for hundred thousand ("แสน").
  static const String _hundredThousand = "แสน";

  /// The Thai word for million ("ล้าน"). This is the primary scale marker for large numbers.
  static const String _million = "ล้าน";

  /// The Thai suffix for one when it's the last digit of a number greater than 10 ("เอ็ด").
  /// E.g., 11 (สิบเอ็ด), 21 (ยี่สิบเอ็ด), 101 (หนึ่งร้อยเอ็ด).
  static const String _oneUnitSuffix = "เอ็ด";

  /// The Thai prefix for two when it's in the tens place ("ยี่").
  /// E.g., 20 (ยี่สิบ), 21 (ยี่สิบเอ็ด), 200 (สองร้อย).
  static const String _twentyPrefix = "ยี่";

  /// The Thai suffix for exact currency amounts ("ถ้วน").
  /// E.g., 1 Baht exactly is "หนึ่งบาทถ้วน".
  static const String _currencyExactSuffix = "ถ้วน";

  /// The Thai suffix for years Before Christ (BC/BCE) (" ก่อน ค.ศ.").
  static const String _yearSuffixBC = " ก่อน ค.ศ.";

  /// The Thai suffix for years Anno Domini (AD/CE) (" ค.ศ.").
  static const String _yearSuffixAD = " ค.ศ.";

  /// Default fallback message for invalid inputs like NaN.
  static const String _notANumber = "ไม่ใช่ตัวเลข";

  /// Default message for positive infinity.
  static const String _positiveInfinity = "อนันต์";

  /// Default message for negative infinity.
  static const String _negativeInfinity = "ลบอนันต์";

  /// Thai words for digits 0-9.
  static const List<String> _digits = [
    "ศูนย์", // 0
    "หนึ่ง", // 1
    "สอง", // 2
    "สาม", // 3
    "สี่", // 4
    "ห้า", // 5
    "หก", // 6
    "เจ็ด", // 7
    "แปด", // 8
    "เก้า", // 9
  ];

  /// Thai place value words for units, tens, hundreds, thousands, ten thousands, hundred thousands.
  /// Used within the `_convertUpToMillion` method. Index corresponds to the power of 10 (0-5).
  static const List<String> _placeValues = [
    _unit, // 0: Units (10^0)
    _ten, // 1: Tens (10^1)
    _hundred, // 2: Hundreds (10^2)
    _thousand, // 3: Thousands (10^3)
    _tenThousand, // 4: Ten Thousands (10^4)
    _hundredThousand, // 5: Hundred Thousands (10^5)
  ];

  /// BigInt representation of one million (1,000,000). Used for scaling.
  static final BigInt _bigIntMillion = BigInt.from(1000000);

  /// Decimal representation of one. Used for comparisons.
  static final Decimal _decimalOne = Decimal.one;

  // --- Public Interface ---

  /// Converts the given [number] into its Thai word representation.
  ///
  /// [number] can be an `int`, `double`, `BigInt`, `Decimal`, or `String` representing a number.
  /// [options] allows specifying formatting options like currency, year, decimal separator, etc.,
  /// specific to Thai using [ThOptions]. If null or not a [ThOptions] instance, default [ThOptions] are used.
  /// [fallbackOnError] provides a custom string to return if conversion fails (e.g., invalid input).
  /// If null, default error messages (`_notANumber`, `_positiveInfinity`, `_negativeInfinity`) are used.
  ///
  /// Returns the Thai text representation of the number or an error/fallback string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure options are specific to Thai, using defaults if necessary.
    final ThOptions thOptions =
        options is ThOptions ? options : const ThOptions();
    final String onError = fallbackOnError ?? _notANumber;

    // Handle special double values early.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? _negativeInfinity : _positiveInfinity;
      }
      if (number.isNaN) {
        return onError;
      }
    }

    // Normalize the input number to Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Handle null or non-numeric input after normalization.
    if (decimalValue == null) {
      return onError;
    }

    // Handle zero separately for efficiency and specific formats.
    if (decimalValue == Decimal.zero) {
      if (thOptions.currency) {
        // "ศูนย์บาทถ้วน" (Zero Baht exactly)
        return "$_zero${thOptions.currencyInfo.mainUnitSingular}$_currencyExactSuffix";
      } else if (thOptions.format == Format.year) {
        // Year 0 is just "ศูนย์"
        return _zero;
      } else {
        // Standard zero is "ศูนย์"
        return _zero;
      }
    }

    // Determine sign and use absolute value for conversion logic.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = decimalValue.abs();

    String textResult;

    // Dispatch to specific handlers based on format options.
    if (thOptions.format == Format.year) {
      // Year format handles sign internally (BC/AD suffixes).
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), thOptions);
    } else {
      // Handle currency or standard number format for the absolute value.
      if (thOptions.currency) {
        textResult = _handleCurrency(absValue, thOptions);
      } else {
        textResult = _handleStandardNumber(absValue, thOptions);
      }
      // Prepend negative prefix if necessary (but not for years).
      if (isNegative) {
        textResult =
            "${thOptions.negativePrefix}$textResult"; // Note: no space before number
      }
    }

    return textResult;
  }

  // --- Private Helper Methods ---

  /// Formats a [year] (as BigInt) according to Thai year conventions.
  ///
  /// Converts the absolute year value to words.
  /// Appends " ก่อน ค.ศ." for negative years (BC/BCE).
  /// Appends " ค.ศ." for positive years (AD/CE) only if [options.includeAD] is true.
  /// Returns the formatted year string.
  String _handleYearFormat(BigInt year, ThOptions options) {
    final bool isNegative = year < BigInt.zero;
    final BigInt absYear = year.abs();

    // Avoid converting zero if the input was zero (already handled in process).
    if (absYear == BigInt.zero) return _zero;

    // Convert the absolute year number to words.
    String yearText = _convertInteger(absYear);

    // Append appropriate era suffix based on sign and options.
    if (isNegative) {
      yearText += _yearSuffixBC; // " ก่อน ค.ศ."
    } else if (options.includeAD) {
      yearText += _yearSuffixAD; // " ค.ศ."
    }

    return yearText;
  }

  /// Formats an absolute [absValue] (as Decimal) as Thai currency.
  ///
  /// Uses [options.currencyInfo] for unit names (Baht, Satang).
  /// Optionally rounds to 2 decimal places if [options.round] is true.
  /// Separates the main unit (Baht) and subunit (Satang).
  /// Appends "ถ้วน" if the amount has zero Satang.
  /// Handles amounts less than 1 Baht correctly (e.g., "เจ็ดสิบห้าสตางค์").
  /// Returns the formatted currency string.
  String _handleCurrency(Decimal absValue, ThOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2; // Standard for Satang
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value if requested, otherwise use the original value.
    // Use round(scale: decimalPlaces) for correct rounding.
    final Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate integer (main unit) and fractional (subunit) parts.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Calculate subunit value (e.g., 0.75 -> 75 Satang). Use round to handle precision.
    final BigInt subunitValue =
        (fractionalPart.abs() * subunitMultiplier).round(scale: 0).toBigInt();

    final StringBuffer result = StringBuffer();

    // Convert main unit (Baht) if greater than zero.
    if (mainValue > BigInt.zero) {
      result.write(_convertInteger(mainValue));
      result.write(currencyInfo.mainUnitSingular); // Append "บาท"
    }

    // Convert subunit (Satang) if greater than zero.
    if (subunitValue > BigInt.zero) {
      // No space needed before subunit in Thai currency format usually.
      // E.g., "หนึ่งบาทห้าสิบสตางค์"
      result.write(_convertInteger(subunitValue));
      result.write(
          currencyInfo.subUnitSingular!); // Append "สตางค์", assume non-null
    } else {
      // If there's a main value but no subunit value, append "ถ้วน".
      if (mainValue > BigInt.zero) {
        result.write(_currencyExactSuffix); // Append "ถ้วน"
      }
    }

    // Handle cases where only the subunit exists (e.g., 0.75 Baht).
    // This condition ensures we don't double-convert if result already has content.
    if (result.isEmpty && subunitValue > BigInt.zero) {
      result.write(_convertInteger(subunitValue));
      result.write(currencyInfo.subUnitSingular!); // e.g., "เจ็ดสิบห้าสตางค์"
    }

    // Handle zero case (already done in 'process', but defensive check)
    if (result.isEmpty &&
        mainValue == BigInt.zero &&
        subunitValue == BigInt.zero) {
      return "$_zero${currencyInfo.mainUnitSingular}$_currencyExactSuffix"; // "ศูนย์บาทถ้วน"
    }

    return result.toString();
  }

  /// Converts a standard absolute number [absValue] (as Decimal) to Thai words.
  ///
  /// Handles both integer and decimal parts.
  /// Uses [options.decimalSeparator] to choose the separator word ("จุด" or "ลูกน้ำ").
  /// Converts the fractional part digit by digit.
  /// Removes trailing zeros from the fractional part before conversion.
  /// Returns the standard cardinal representation.
  String _handleStandardNumber(Decimal absValue, ThOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    // Use abs() on fractional part in case original number was negative but integer part was 0
    final Decimal fractionalPart = (absValue - absValue.truncate()).abs();

    String integerWords = "";
    if (integerPart > BigInt.zero) {
      integerWords = _convertInteger(integerPart);
    } else if (absValue > Decimal.zero && absValue < _decimalOne) {
      // Handle numbers between 0 and 1 (e.g., 0.5) -> "ศูนย์จุดห้า"
      integerWords = _zero;
    } else if (integerPart == BigInt.zero && fractionalPart == Decimal.zero) {
      // Handle exact zero (already covered in 'process', but defensive)
      return _zero;
    }

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word based on options.
      final String separatorWord;
      switch (options.decimalSeparator ?? DecimalSeparator.period) {
        case DecimalSeparator.comma:
          separatorWord = _commaWord; // "ลูกน้ำ"
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          separatorWord = _pointWord; // "จุด"
          break;
      }

      // Convert fractional part to string. Using absValue ensures correct string.
      final String fracStr = absValue.toString();
      // Find the index of the decimal point.
      final int pointIndex = fracStr.indexOf('.');
      if (pointIndex == -1) {
        // Should not happen if fractionalPart > 0, but safeguard.
        // Potentially log an error or return integerWords only.
      } else {
        String digitsStr = fracStr.substring(pointIndex + 1);
        // Remove trailing zeros as they are typically omitted in spoken Thai decimals.
        // Example: "1.50" -> "1.5" -> "หนึ่งจุดห้า"
        digitsStr = digitsStr.replaceAll(RegExp(r'0+$'), '');

        // If there are significant digits left, convert them one by one.
        if (digitsStr.isNotEmpty) {
          final List<String> digitWords = digitsStr.split('').map((digit) {
            final int? digitInt = int.tryParse(digit);
            // Map digit character to its Thai word.
            return (digitInt != null && digitInt >= 0 && digitInt <= 9)
                ? _digits[digitInt]
                : '?';
          }).toList();
          // Combine separator and digit words. Add space before separator.
          fractionalWords = '$separatorWord${digitWords.join()}';
        }
      }
    }

    // Combine integer and fractional parts. Trim potential leading/trailing space.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer [n] (as BigInt) to Thai words.
  ///
  /// Handles numbers recursively using millions (`ล้าน`) as scale separators.
  /// Delegates conversion of segments smaller than a million to `_convertUpToMillion`.
  /// Returns the Thai word representation of the integer.
  /// Returns an empty string for zero (zero is handled externally by `process`).
  /// Throws ArgumentError if [n] is negative.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero) {
      // This should ideally not be reached due to prior abs() calls.
      throw ArgumentError("Integer must be non-negative for conversion: $n");
    }
    // Base case: Zero converts to an empty string within this helper.
    // The main 'process' method handles the "ศูนย์" output for standalone zero.
    if (n == BigInt.zero) {
      return "";
    }

    // Handle numbers less than a million directly.
    if (n < _bigIntMillion) {
      return _convertUpToMillion(n);
    } else {
      // Recursive step for numbers >= 1 million.
      // Divide the number into millions part and the remainder.
      final BigInt millionsPart = n ~/ _bigIntMillion;
      final BigInt remainderPart = n % _bigIntMillion;

      // Recursively convert the millions part.
      final String millionsText = _convertInteger(millionsPart);
      // Convert the remainder part (which is less than a million).
      final String remainderText = _convertUpToMillion(remainderPart);

      // Combine results: [Millions Text] + "ล้าน" + [Remainder Text]
      // No extra spaces needed.
      return '$millionsText$_million$remainderText';
    }
  }

  /// Converts a non-negative integer [n] (as BigInt, 0 < n < 1,000,000) to Thai words.
  ///
  /// Processes the number digit by digit based on its place value (unit, ten, hundred, etc.).
  /// Applies Thai-specific rules:
  /// - "เอ็ด" for 1 in the units place (if not the only digit in the chunk or larger number).
  /// - "ยี่" for 2 in the tens place.
  /// Returns the Thai word representation for the segment.
  /// Returns an empty string if [n] is zero or >= 1,000,000.
  String _convertUpToMillion(BigInt n) {
    // Validate input range for this helper.
    if (n <= BigInt.zero || n >= _bigIntMillion) {
      return ""; // Handled by _convertInteger or process method.
    }

    final StringBuffer chunkResult = StringBuffer();
    final String chunkStr = n.toString();
    final int chunkLen = chunkStr.length;

    // Iterate through digits from left to right (most significant to least).
    for (int i = 0; i < chunkLen; i++) {
      // Parse digit. Should not fail as chunkStr comes from n.toString().
      final int digit = int.parse(chunkStr[i]);
      // Calculate place value index (0=units, 1=tens, ..., 5=hundred thousands).
      final int place = chunkLen - 1 - i;

      // Skip zero digits as they don't contribute words unless it's the number 0 itself.
      if (digit == 0) {
        continue;
      }

      final String digitWord;
      final bool isTensPlace = place == 1;
      final bool isUnitsPlace = place == 0;

      // Apply special rules for tens and units places.
      if (isTensPlace) {
        // Tens place (หลักสิบ)
        if (digit == 1) {
          digitWord =
              ""; // "สิบ" is added later by place value, no "หนึ่ง" prefix needed.
        } else if (digit == 2) {
          digitWord = _twentyPrefix; // "ยี่" for 20s.
        } else {
          digitWord = _digits[digit]; // Standard digit word (สาม, สี่, ...).
        }
      } else if (isUnitsPlace) {
        // Units place (หลักหน่วย)
        // Use "เอ็ด" for 1 if it's part of a larger number (e.g., 11, 21, 101).
        // Check chunkLen > 1 OR that the number had a millions part handled earlier.
        // This logic works because _convertUpToMillion is only called for remainders < million
        // or for the initial number if < million. The chunkLen > 1 check correctly handles
        // cases like 11, 21, 101, 1101 etc. within the < million range.
        if (digit == 1 && chunkLen > 1) {
          digitWord = _oneUnitSuffix; // "เอ็ด"
        } else {
          digitWord = _digits[digit]; // Standard digit word (หนึ่ง, สอง, ...).
        }
      } else {
        // Hundreds, Thousands, etc.
        digitWord = _digits[digit]; // Standard digit word.
      }

      // Append the determined digit word.
      chunkResult.write(digitWord);

      // Append the place value word (สิบ, ร้อย, พัน, หมื่น, แสน) if applicable.
      if (place > 0) {
        chunkResult.write(_placeValues[place]);
      }
    }
    return chunkResult.toString();
  }
}
