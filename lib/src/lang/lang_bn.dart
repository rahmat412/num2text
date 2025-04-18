import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/bn_options.dart';
import '../utils/utils.dart';

/// {@template num2text_bn}
/// The Bengali language (Lang.BN) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Bengali word representation following standard Bengali grammar and the
/// Indian numbering system (Lakh, Crore).
///
/// Capabilities include handling cardinal numbers, currency (using [BnOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (Lakh, Crore).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [BnOptions].
/// {@endtemplate}
class Num2TextBN implements Num2TextBase {
  // --- Constants for Bengali Number Words ---

  /// The word for zero ("শূন্য").
  static const String zero = "শূন্য";

  /// The word for hundred ("শ"). Used as a suffix (e.g., "একশ" - one hundred).
  static const String hundred = "শ";

  /// The word for thousand ("হাজার").
  static const String thousand = "হাজার";

  /// The word for lakh (100,000 - "লক্ষ"). Part of the Indian numbering system.
  static const String lakh = "লক্ষ";

  /// The word for crore (10,000,000 - "কোটি"). Part of the Indian numbering system.
  static const String crore = "কোটি";

  /// The default word for the decimal separator ("দশমিক"). Used for `.` or `point`.
  static const String defaultDecimalSeparatorWord = "দশমিক";

  /// The word for the decimal separator when specified as comma ("কমা").
  static const String commaWord = "কমা";

  /// The suffix for years BC/BCE ("খ্রিস্টপূর্ব").
  static const String yearSuffixBC = "খ্রিস্টপূর্ব";

  /// The suffix for years AD/CE ("খ্রিস্টাব্দ").
  static const String yearSuffixAD = "খ্রিস্টাব্দ";

  /// The word for infinity ("অসীম").
  static const String infinity = "অসীম";

  /// The prefix for negative infinity ("ঋণাত্মক "). Note the trailing space.
  static const String negativeInfinityPrefix = "ঋণাত্মক ";

  /// The word for "Not a Number" ("সংখ্যা নয়").
  static const String notANumber = "সংখ্যা নয়";

  /// Predefined list of Bengali words for numbers 0 through 99.
  static const List<String> wordsUnder100 = [
    zero, // 0
    "এক", // 1
    "দুই", // 2
    "তিন", // 3
    "চার", // 4
    "পাঁচ", // 5
    "ছয়", // 6
    "সাত", // 7
    "আট", // 8
    "নয়", // 9
    "দশ", // 10
    "এগারো", // 11
    "বারো", // 12
    "তেরো", // 13
    "চৌদ্দ", // 14
    "পনেরো", // 15
    "ষোলো", // 16
    "সতেরো", // 17
    "আঠারো", // 18
    "উনিশ", // 19
    "বিশ", // 20
    "একুশ", // 21
    "বাইশ", // 22
    "তেইশ", // 23
    "চব্বিশ", // 24
    "পঁচিশ", // 25
    "ছাব্বিশ", // 26
    "সাতাশ", // 27
    "আঠাশ", // 28
    "উনত্রিশ", // 29
    "ত্রিশ", // 30
    "একত্রিশ", // 31
    "বত্রিশ", // 32
    "তেত্রিশ", // 33
    "চৌত্রিশ", // 34
    "পঁয়ত্রিশ", // 35
    "ছত্রিশ", // 36
    "সাঁইত্রিশ", // 37
    "আটত্রিশ", // 38
    "উনচল্লিশ", // 39
    "চল্লিশ", // 40
    "একচল্লিশ", // 41
    "বিয়াল্লিশ", // 42
    "তেতাল্লিশ", // 43
    "চুয়াল্লিশ", // 44
    "পঁয়তাল্লিশ", // 45
    "ছেচল্লিশ", // 46
    "সাতচল্লিশ", // 47
    "আটচল্লিশ", // 48
    "উনপঞ্চাশ", // 49
    "পঞ্চাশ", // 50
    "একান্ন", // 51
    "বায়ান্ন", // 52
    "তিপ্পান্ন", // 53
    "চুয়ান্ন", // 54
    "পঞ্চান্ন", // 55
    "ছাপ্পান্ন", // 56
    "সাতান্ন", // 57
    "আটান্ন", // 58
    "উনষাট", // 59
    "ষাট", // 60
    "একষট্টি", // 61
    "বাষট্টি", // 62
    "তেষট্টি", // 63
    "চৌষট্টি", // 64
    "পঁয়ষট্টি", // 65
    "ছেষট্টি", // 66
    "সাতষট্টি", // 67
    "আটষট্টি", // 68
    "উনসত্তর", // 69
    "সত্তর", // 70
    "একাত্তর", // 71
    "বাহাত্তর", // 72
    "তিয়াত্তর", // 73
    "চুয়াত্তর", // 74
    "পঁচাত্তর", // 75
    "ছিয়াত্তর", // 76
    "সাতাত্তর", // 77
    "আটাত্তর", // 78
    "উনআশি", // 79
    "আশি", // 80
    "একাশি", // 81
    "বিরাশি", // 82
    "তিরাশি", // 83
    "চুরাশি", // 84
    "পঁচাশি", // 85
    "ছিয়াশি", // 86
    "সাতাশি", // 87
    "আটাশি", // 88
    "উননব্বই", // 89
    "নব্বই", // 90
    "একানব্বই", // 91
    "বিরানব্বই", // 92
    "তিরানব্বই", // 93
    "চুরানব্বই", // 94
    "পঁচানব্বই", // 95
    "ছিয়ানব্বই", // 96
    "সাতানব্বই", // 97
    "আটানব্বই", // 98
    "নিরানব্বই", // 99
  ];

  /// {@macro num2text_base_process}
  ///
  /// [number]: The number to convert (e.g., `123`, `123.45`, `BigInt.from(100000)`).
  /// [options]: Optional [BnOptions] for customization (currency, year, etc.).
  /// [fallbackOnError]: Optional custom string to return on error.
  /// Returns the number as Bengali words or a fallback string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have BnOptions, defaulting if necessary.
    final bnOptions = options is BnOptions ? options : const BnOptions();
    final String errorMsg = fallbackOnError ?? notANumber;

    // Handle special double values first.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? (negativeInfinityPrefix + infinity)
            : infinity;
      }
      if (number.isNaN) {
        return errorMsg;
      }
    }

    // Normalize the input number to Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // If normalization fails, return fallback or default error message.
    if (decimalValue == null) {
      return errorMsg;
    }

    // Capture the sign before handling zero or taking the absolute value.
    final bool isNegative = decimalValue.isNegative;

    // Handle the special case of zero.
    if (decimalValue == Decimal.zero) {
      if (bnOptions.currency) {
        // Use plural/singular form for zero currency. Default to mainUnitSingular if plural is null.
        final unit = bnOptions.currencyInfo.mainUnitPlural ??
            bnOptions.currencyInfo.mainUnitSingular;
        return "$zero $unit";
      } else {
        // For years or standard numbers, just return "zero".
        return zero;
      }
    }

    // Work with the absolute value for the main conversion logic.
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Route to specific handlers based on options.
    if (bnOptions.format == Format.year) {
      // Year format handles negative internally by using isNegative flag.
      textResult = _handleYearFormat(
        decimalValue
            .truncate()
            .toBigInt()
            .toInt(), // Safe for typical year ranges
        isNegative,
        bnOptions,
      );
    } else if (bnOptions.currency) {
      textResult = _handleCurrency(absValue, bnOptions);
      // Add negative prefix here if applicable for currency
      if (isNegative) {
        textResult = "${bnOptions.negativePrefix} $textResult";
      }
    } else {
      textResult = _handleStandardNumber(absValue, bnOptions);
      // Add negative prefix here if applicable for standard numbers
      if (isNegative) {
        textResult = "${bnOptions.negativePrefix} $textResult";
      }
    }

    return textResult;
  }

  /// Handles the conversion of a number into the year format.
  ///
  /// [yearInt]: The integer year value (truncated from original).
  /// [isOriginalNegative]: Whether the original number before truncation was negative.
  /// [options]: The [BnOptions] containing formatting rules like `includeAD`.
  /// Returns the year formatted as Bengali words, potentially with BC/AD suffixes.
  String _handleYearFormat(
      int yearInt, bool isOriginalNegative, BnOptions options) {
    // Determine the absolute year value from the integer part.
    final int absYear = isOriginalNegative ? -yearInt : yearInt;
    // Use BigInt for the conversion logic as _convertInteger expects BigInt.
    final BigInt bigAbsYear = BigInt.from(absYear);

    String yearText;
    // Special case for years like 1100, 1200, ..., 1900 (e.g., "উনিশশ" for 1900).
    // Check against the absolute integer value.
    if (absYear >= 1100 && absYear < 2000 && absYear % 100 == 0) {
      // Convert the hundreds part (11-19). handleHundreds: false is correct here.
      yearText =
          "${_convertChunk(absYear ~/ 100, handleHundreds: false)}$hundred";
    } else {
      // Standard conversion for other years using the absolute BigInt value.
      yearText = _convertInteger(bigAbsYear);
    }

    // Add suffixes based on the original sign and options.
    // Suffix depends on the sign of the *original* number.
    if (isOriginalNegative) {
      yearText += " $yearSuffixBC";
    } else if (options.includeAD && absYear > 0) {
      // Only add AD suffix if requested AND the year is positive.
      yearText += " $yearSuffixAD";
    }

    return yearText;
  }

  /// Handles the conversion of a number into currency format (Taka and Paisa).
  ///
  /// [absValue]: The absolute [Decimal] value of the amount.
  /// [options]: The [BnOptions] specifying currency info ([CurrencyInfo]) and rounding rules.
  /// Returns the amount formatted as Bengali currency words.
  String _handleCurrency(Decimal absValue, BnOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round; // Check if rounding is requested
    const int decimalPlaces = 2; // Standard for currency subunits
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value if specified before splitting.
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate the main unit (Taka) and subunit (Paisa).
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    // Use precise Decimal arithmetic for fractional part.
    final Decimal fractionalPart =
        valueToConvert - Decimal.fromBigInt(mainValue);
    // Calculate the subunit value (ensure rounding for precision).
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round(scale: 0).toBigInt();

    // Convert the main value to words.
    String mainText = _convertInteger(mainValue);
    // Determine the correct unit name (singular/plural). Use plural as default if available.
    String mainUnitName = mainValue == BigInt.one
        ? currencyInfo.mainUnitSingular
        : currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;

    // Start building the result string.
    String result = '$mainText $mainUnitName';

    // Add the subunit part if it's greater than zero.
    if (subunitValue > BigInt.zero) {
      // Convert subunit value to words.
      String subunitText = _convertInteger(subunitValue);
      // Determine the correct subunit name. Handle null safety. Use plural as default.
      String? subUnitName = subunitValue == BigInt.one
          ? currencyInfo.subUnitSingular
          : currencyInfo.subUnitPlural ?? currencyInfo.subUnitSingular;

      // Append the subunit part if the name is available.
      if (subUnitName != null && subUnitName.isNotEmpty) {
        result += ' $subunitText $subUnitName';
      }
    }

    return result;
  }

  /// Handles the conversion of a standard number (integer or decimal).
  ///
  /// [absValue]: The absolute [Decimal] value of the number.
  /// [options]: The [BnOptions] specifying decimal separator ([DecimalSeparator]) preferences.
  /// Returns the number formatted as standard Bengali words.
  String _handleStandardNumber(Decimal absValue, BnOptions options) {
    // Check if the number is effectively an integer (no fractional part).
    if (absValue.scale == 0 || absValue == absValue.truncate()) {
      return _convertInteger(absValue.truncate().toBigInt());
    }

    // Separate integer and fractional parts.
    final BigInt integerPart = absValue.truncate().toBigInt();
    // Use precise Decimal subtraction.
    final Decimal fractionalPart = absValue - Decimal.fromBigInt(integerPart);

    // Convert the integer part. Use "zero" if the integer part is 0 but there's a fractional part (e.g., 0.5).
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? zero
            : _convertInteger(integerPart);

    String fractionalWords = '';

    // Process the fractional part if it exists.
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word based on options.
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = commaWord;
          break;
        case DecimalSeparator.period:
        case DecimalSeparator.point:
        default: // Default to period/point word
          separatorWord = defaultDecimalSeparatorWord;
          break;
      }

      // Get the digits after the decimal point as a string.
      // toString() is needed here, not scale, to handle things like 0.05 correctly.
      String fractionalDigits = absValue.toString().split('.').last;
      // Trim trailing zeros for standard number format.
      fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      // If trimming left an empty string (e.g., 1.500 -> 1.5 -> "5"), proceed.
      // If trimming resulted in empty string (e.g., 1.0 -> ""), don't add fractional part.
      if (fractionalDigits.isNotEmpty) {
        // Convert each digit to its Bengali word representation.
        List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          // Use predefined words for digits 0-9. Handle potential parsing errors gracefully.
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? wordsUnder100[digitInt]
              : '?'; // Fallback for non-digit characters
        }).toList();

        // Combine separator and digit words. Ensure space separation.
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }

    // Combine integer and fractional parts, trimming any extra space if fractional part was empty.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer ([BigInt]) into Bengali words using the Indian numbering system.
  ///
  /// Handles scales: Crore (10^7), Lakh (10^5), Thousand (10^3), Hundred (10^2).
  ///
  /// [n]: The non-negative [BigInt] to convert.
  /// Returns the integer represented in Bengali words.
  String _convertInteger(BigInt n) {
    // Base cases.
    if (n == BigInt.zero) return zero;
    if (n < BigInt.zero)
      return ""; // Should not happen with absolute values, but defensive.

    // Handle numbers under 100 directly using the lookup table.
    if (n < BigInt.from(100)) {
      // Convert to int safely as it's < 100.
      return _convertChunk(n.toInt());
    }

    List<String> parts = [];
    BigInt remaining = n;
    // Define the scale values for the Indian numbering system.
    final BigInt croreValue = BigInt.from(10000000);
    final BigInt lakhValue = BigInt.from(100000);
    final BigInt thousandValue = BigInt.from(1000);
    // Hundred is handled within _convertChunk

    // Process Crores (10^7).
    if (remaining >= croreValue) {
      BigInt crores = remaining ~/ croreValue;
      remaining %= croreValue;
      // Recursively convert the crore part and add the scale name.
      parts.add(_convertInteger(crores));
      parts.add(crore);
    }

    // Process Lakhs (10^5).
    if (remaining >= lakhValue) {
      BigInt lakhs = remaining ~/ lakhValue;
      remaining %= lakhValue;
      // Convert lakhs part (0-99). Ensure conversion to int is safe.
      parts.add(
          _convertChunk(lakhs.toInt())); // handleHundreds defaults to false
      parts.add(lakh);
    }

    // Process Thousands (10^3).
    if (remaining >= thousandValue) {
      BigInt thousands = remaining ~/ thousandValue;
      remaining %= thousandValue;
      // Convert thousands part (0-99). Ensure conversion to int is safe.
      parts.add(
          _convertChunk(thousands.toInt())); // handleHundreds defaults to false
      parts.add(thousand);
    }

    // Process the remaining part (0-999).
    if (remaining > BigInt.zero) {
      // Convert the final chunk, handling hundreds within it. Ensure conversion to int is safe.
      parts.add(_convertChunk(remaining.toInt(), handleHundreds: true));
    }

    // Join the parts with spaces, filtering out any empty strings (though unlikely).
    return parts.where((part) => part.isNotEmpty).join(' ');
  }

  /// Converts a number chunk (0-999) into Bengali words.
  ///
  /// [n]: The integer chunk to convert (must be 0 <= n <= 999).
  /// [handleHundreds]: If true, explicitly converts the hundreds place (e.g., "একশ এক").
  ///   If false (default), treats n as a number 0-99 (used for Lakhs/Thousands).
  /// Returns the chunk represented in Bengali words, or an empty string for 0 or invalid input.
  String _convertChunk(int n, {bool handleHundreds = false}) {
    if (n == 0) return "";
    // Validate input range. Although internal calls should be safe.
    if (n < 0 || n > 999) {
      // Return empty or error string in production? Returning empty for robustness.
      return "";
    }

    // Direct lookup for numbers under 100.
    if (n < 100) {
      return wordsUnder100[n];
    }

    // Handle numbers 100-999 only if handleHundreds is true.
    if (handleHundreds) {
      int hundredsDigit = n ~/ 100;
      int remainder = n % 100;

      // Combine hundreds digit word with "শ".
      // Ensure hundredsDigit is within bounds (1-9).
      // For 100, 200, etc., use specific words if available (e.g., দুইশ), otherwise construct.
      String hundredsPart;
      if (hundredsDigit == 1) {
        hundredsPart =
            wordsUnder100[hundredsDigit] + hundred; // "এক" + "শ" = "একশ"
      } else if (hundredsDigit == 2) {
        hundredsPart = "দুই$hundred"; // "দুইশ"
      } else if (hundredsDigit == 3) {
        hundredsPart = "তিন$hundred"; // "তিনশ"
      } else if (hundredsDigit == 4) {
        hundredsPart = "চার$hundred"; // "চারশ"
      } else if (hundredsDigit == 5) {
        hundredsPart = "পাঁচ$hundred"; // "পাঁচশ"
      } else if (hundredsDigit == 6) {
        hundredsPart = "ছয়$hundred"; // "ছয়শ"
      } else if (hundredsDigit == 7) {
        hundredsPart = "সাত$hundred"; // "সাতশ"
      } else if (hundredsDigit == 8) {
        hundredsPart = "আট$hundred"; // "আটশ"
      } else if (hundredsDigit == 9) {
        hundredsPart = "নয়$hundred"; // "নয়শ"
      } else {
        // Fallback, should not happen for 1-9
        hundredsPart = wordsUnder100[hundredsDigit] + hundred;
      }

      // If there's no remainder, return just the hundreds part.
      if (remainder == 0) {
        return hundredsPart;
      } else {
        // Otherwise, add the remainder part (1-99).
        return "$hundredsPart ${wordsUnder100[remainder]}"; // e.g., "একশ এক"
      }
    } else {
      // If handleHundreds is false, but n >= 100, this indicates an invalid call state
      // (should only be called with n < 100 for lakhs/thousands).
      // Return empty string for robustness, as this path shouldn't be reached normally.
      return "";
    }
  }
}
