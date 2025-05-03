import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/bn_options.dart';
import '../utils/utils.dart';

/// {@template num2text_bn}
/// Converts numbers into their Bengali word representations (`Lang.BN`).
///
/// Implements [Num2TextBase] for Bengali, handling various numeric types.
/// Features include:
/// *   Cardinal number conversion (positive/negative).
/// *   Uses the Indian numbering system (Lakh, Crore).
/// *   Decimal handling with appropriate separators ("দশমিক" or "কমা").
/// *   Currency formatting (default BDT - Taka/Paisa) via [BnOptions.currencyInfo].
/// *   Year formatting with optional era suffixes (BC/AD).
/// *   Customization via [BnOptions].
/// *   Fallback messages for invalid inputs.
/// {@endtemplate}
class Num2TextBN implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "শূন্য"; // Zero
  static const String _hundred =
      "শ"; // Hundred suffix (e.g., একশ - one hundred)
  static const String _thousand = "হাজার"; // Thousand
  static const String _lakh = "লক্ষ"; // Lakh (100,000)
  static const String _crore = "কোটি"; // Crore (10,000,000)
  /// Default decimal separator "দশমিক" (decimal/point).
  static const String _defaultDecimalSeparatorWord = "দশমিক";

  /// Decimal separator "কমা" (comma).
  static const String _commaWord = "কমা";

  /// Suffix for BC years ("খ্রিস্টপূর্ব" - Before Christ).
  static const String _yearSuffixBC = "খ্রিস্টপূর্ব";

  /// Suffix for AD years ("খ্রিস্টাব্দ" - Anno Domini), used if [BnOptions.includeAD] is true.
  static const String _yearSuffixAD = "খ্রিস্টাব্দ";
  static const String _infinity = "অসীম"; // Infinity
  static const String _negativeInfinityPrefix =
      "ঋণাত্মক "; // Negative prefix for infinity
  static const String _notANumber = "সংখ্যা নয়"; // "Not a number"

  /// Words for numbers 0-99.
  static const List<String> _wordsUnder100 = [
    _zero, "এক", "দুই", "তিন", "চার", "পাঁচ", "ছয়", "সাত", "আট", "নয়", // 0-9
    "দশ", "এগারো", "বারো", "তেরো", "চৌদ্দ", "পনেরো", "ষোলো", "সতেরো", "আঠারো",
    "উনিশ", // 10-19
    "বিশ", "একুশ", "বাইশ", "তেইশ", "চব্বিশ", "পঁচিশ", "ছাব্বিশ", "সাতাশ",
    "আঠاش",
    "উনত্রিশ", // 20-29
    "ত্রিশ", "একত্রিশ", "বত্রিশ", "তেত্রিশ", "চৌত্রিশ", "পঁয়ত্রিশ", "ছত্রিশ",
    "সাঁইত্রিশ",
    "আটত্রিশ", "উনচল্লিশ", // 30-39
    "চল্লিশ", "একচল্লিশ", "বিয়াল্লিশ", "তেতাল্লিশ", "চুয়াল্লিশ",
    "পঁয়তাল্লিশ", "ছেচল্লিশ",
    "সাতচল্লিশ", "আটচল্লিশ", "উনপঞ্চাশ", // 40-49
    "পঞ্চাশ", "একান্ন", "বায়ান্ন", "তিপ্পান্ন", "চুয়ান্ন", "পঞ্চান্ন",
    "ছাপ্পান্ন", "সাতান্ন",
    "আটান্ন", "উনষাট", // 50-59
    "ষাট", "একষট্টি", "বাষট্টি", "তেষট্টি", "চৌষট্টি", "পঁয়ষট্টি", "ছেষট্টি",
    "সাতষট্টি",
    "আটষট্টি", "উনসত্তর", // 60-69
    "সত্তর", "একাত্তর", "বাহাত্তর", "তিয়াত্তর", "চুয়াত্তর", "পঁচাত্তর",
    "ছিয়াত্তর", "সাতাত্তর",
    "আটাত্তর", "উনআশি", // 70-79
    "আশি", "একাশি", "বিরাশি", "তিরাশি", "চুরাশি", "পঁচাশি", "ছিয়াশি", "সাতাশি",
    "আটাশি",
    "উননব্বই", // 80-89
    "নব্বই", "একানব্বই", "বিরানব্বই", "তিরানব্বই", "চুরানব্বই", "পঁচানব্বই",
    "ছিয়ানব্বই",
    "সাতানব্বই", "আটানব্বই", "নিরানব্বই", // 90-99
  ];

  /// {@macro num2text_base_process}
  ///
  /// Processes the given [number] into Bengali words.
  ///
  /// @param number The number to convert.
  /// @param options Optional [BnOptions] for customization.
  /// @param fallbackOnError Optional error string (defaults to "সংখ্যা নয়").
  /// @return The number as Bengali words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final bnOptions = options is BnOptions ? options : const BnOptions();
    final String errorMsg = fallbackOnError ?? _notANumber;

    // Handle non-finite doubles.
    if (number is double) {
      if (number.isInfinite)
        return number.isNegative
            ? (_negativeInfinityPrefix + _infinity)
            : _infinity;
      if (number.isNaN) return errorMsg;
    }

    // Normalize to Decimal.
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorMsg;

    final bool isNegative = decimalValue.isNegative;

    // Handle zero.
    if (decimalValue == Decimal.zero) {
      if (bnOptions.currency) {
        final unit = bnOptions.currencyInfo.mainUnitPlural ??
            bnOptions.currencyInfo.mainUnitSingular;
        return "$_zero $unit"; // e.g., "শূন্য টাকা"
      }
      return _zero; // "শূন্য"
    }

    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    // Dispatch based on format.
    if (bnOptions.format == Format.year) {
      // Year conversion handles negative sign internally via isOriginalNegative.
      textResult = _handleYearFormat(
        decimalValue.truncate().toBigInt().toInt(),
        isNegative, // Pass the original sign.
        bnOptions,
      );
    } else if (bnOptions.currency) {
      textResult = _handleCurrency(absValue, bnOptions);
      // Add negative prefix if needed for currency.
      if (isNegative) textResult = "${bnOptions.negativePrefix} $textResult";
    } else {
      textResult = _handleStandardNumber(absValue, bnOptions);
      // Add negative prefix if needed for standard numbers.
      if (isNegative) textResult = "${bnOptions.negativePrefix} $textResult";
    }

    return textResult;
  }

  /// Formats an integer as a Bengali year with optional era suffixes.
  ///
  /// Handles the 1100-1999 range specially (e.g., 1984 -> "উনিশ শ চুরাশি").
  /// Appends "খ্রিস্টপূর্ব" (BC) or "খ্রিস্টাব্দ" (AD) based on sign and [BnOptions.includeAD].
  ///
  /// @param yearInt The integer year.
  /// @param isOriginalNegative Whether the original number was negative (for BC suffix).
  /// @param options The [BnOptions].
  /// @return The year as Bengali words.
  String _handleYearFormat(
      int yearInt, bool isOriginalNegative, BnOptions options) {
    // Use absolute value for conversion, use original sign for suffix.
    final int absYear = isOriginalNegative ? -yearInt : yearInt;
    if (absYear == 0) return _zero; // Handle year 0 case.
    final BigInt bigAbsYear = BigInt.from(absYear);

    String yearText;
    // Special handling for years like 19xx, 18xx.
    if (absYear >= 1100 && absYear < 2000) {
      int hundredsPartInt = absYear ~/ 100; // e.g., 19
      int remainder = absYear % 100; // e.g., 84 or 0
      // Convert the "19" part, no hundreds handling needed here.
      yearText =
          "${_convertChunk(hundredsPartInt, handleHundreds: false)}$_hundred"; // "উনিশ" + "শ"
      if (remainder > 0) {
        // Convert the "84" part.
        yearText +=
            " ${_convertChunk(remainder, handleHundreds: false)}"; // " চুরাশি"
      }
      // Result: "উনিশ শ চুরাশি"
    } else {
      // For other years, use the standard integer conversion.
      yearText = _convertInteger(bigAbsYear);
    }

    // Append era suffixes.
    if (isOriginalNegative)
      yearText += " $_yearSuffixBC";
    else if (options.includeAD) yearText += " $_yearSuffixAD";

    return yearText;
  }

  /// Formats a non-negative [Decimal] as Bengali currency (Taka/Paisa).
  ///
  /// Handles rounding, unit separation, uses basic singular/plural forms from
  /// [CurrencyInfo], and combines parts.
  ///
  /// @param absValue The absolute currency value.
  /// @param options The [BnOptions] with currency info.
  /// @return The currency value as Bengali words.
  String _handleCurrency(Decimal absValue, BnOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    const int decimalPlaces = 2;
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round if requested.
    Decimal valueToConvert =
        options.round ? absValue.round(scale: decimalPlaces) : absValue;

    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart =
        valueToConvert - Decimal.fromBigInt(mainValue);
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round(scale: 0).toBigInt();

    String mainText = "";
    String mainUnitName = "";
    if (mainValue > BigInt.zero) {
      mainText = _convertInteger(mainValue);
      // Taka usually uses same form for singular/plural. Use plural if available.
      mainUnitName =
          currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;
    }
    // Note: Zero Taka case handled in 'process' or by the final join logic.

    String subunitText = "";
    String subUnitName = "";
    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      subunitText = _convertInteger(subunitValue);
      // Paisa usually uses same form. Use plural if available.
      subUnitName = currencyInfo.subUnitPlural ?? currencyInfo.subUnitSingular!;
    }

    // Combine parts.
    List<String> resultParts = [];
    if (mainText.isNotEmpty && mainUnitName.isNotEmpty)
      resultParts.add('$mainText $mainUnitName');
    if (subunitText.isNotEmpty && subUnitName.isNotEmpty)
      resultParts.add('$subunitText $subUnitName');

    // Handle the case where the input was 0.00 or rounded to it.
    if (resultParts.isEmpty &&
        mainValue == BigInt.zero &&
        subunitValue == BigInt.zero) {
      final unit = currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;
      return "$_zero $unit"; // Ensure zero amount is represented correctly.
    }

    return resultParts.join(' ').trim(); // Join with space.
  }

  /// Converts a non-negative standard [Decimal] number into Bengali words.
  ///
  /// Handles integer part using [_convertInteger].
  /// Fractional part is read digit-by-digit after the separator ("দশমিক" or "কমা").
  /// Removes trailing zeros from the fractional part display.
  ///
  /// @param absValue The absolute decimal value.
  /// @param options The [BnOptions] with decimal separator preference.
  /// @return The number as Bengali words.
  String _handleStandardNumber(Decimal absValue, BnOptions options) {
    // Handle integers directly.
    if (absValue.scale == 0 || absValue == absValue.truncate()) {
      return _convertInteger(absValue.truncate().toBigInt());
    }

    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - Decimal.fromBigInt(integerPart);

    // Convert integer part. Handle 0.x cases.
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Choose separator word.
      String separatorWord =
          (options.decimalSeparator ?? DecimalSeparator.period) ==
                  DecimalSeparator.comma
              ? _commaWord
              : _defaultDecimalSeparatorWord; // Default to "দশমিক"

      // Get fractional digits and remove trailing zeros.
      String fractionalDigits = absValue.toString().split('.').last;
      fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      if (fractionalDigits.isNotEmpty) {
        // Convert digits to words.
        List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder100[digitInt]
              : '?';
        }).toList();
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer into Bengali words using the Indian numbering system (Crore).
  ///
  /// Recursively handles Crore (10^7) scale, delegating numbers below Crore to [_convertBelowCrore].
  ///
  /// @param n The non-negative integer to convert.
  /// @return The integer as Bengali words. Returns empty string for negative input.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) return ""; // Sign handled elsewhere.

    final BigInt croreValue = BigInt.from(10000000);

    if (n < croreValue) {
      return _convertBelowCrore(n); // Handle numbers less than 1 Crore.
    } else {
      // Handle numbers >= 1 Crore.
      BigInt crores = n ~/ croreValue; // Number of Crores.
      BigInt remainder = n % croreValue; // Remainder less than 1 Crore.

      // Recursively convert the Crore part.
      String croresText = _convertInteger(crores);
      String remainderText = "";
      if (remainder > BigInt.zero) {
        // Convert the remainder if it's non-zero.
        remainderText = _convertBelowCrore(remainder);
      }

      // Combine parts.
      if (remainderText.isEmpty) {
        return "$croresText $_crore"; // e.g., "এক কোটি"
      } else {
        return "$croresText $_crore $remainderText"; // e.g., "এক কোটি পাঁচ লক্ষ"
      }
    }
  }

  /// Converts a non-negative integer below 1 Crore (10,000,000) into Bengali words.
  ///
  /// Handles Lakh (10^5) and Thousand (10^3) scales, delegating the final 0-999 part to [_convertChunk].
  ///
  /// @param n The non-negative integer (0 <= n < 10,000,000).
  /// @return The number as Bengali words. Returns empty string for 0 or invalid input.
  String _convertBelowCrore(BigInt n) {
    if (n <= BigInt.zero) return "";
    if (n >= BigInt.from(10000000)) return ""; // Safety check.

    final BigInt lakhValue = BigInt.from(100000);
    final BigInt thousandValue = BigInt.from(1000);

    List<String> parts = [];
    BigInt current = n;

    // Handle Lakhs place.
    if (current >= lakhValue) {
      BigInt lakhs = current ~/ lakhValue;
      current %= lakhValue;
      // Convert the Lakh count (0-99) using _convertChunk.
      parts
          .add("${_convertChunk(lakhs.toInt(), handleHundreds: false)} $_lakh");
    }
    // Handle Thousands place.
    if (current >= thousandValue) {
      BigInt thousands = current ~/ thousandValue;
      current %= thousandValue;
      // Convert the Thousand count (0-99) using _convertChunk.
      parts.add(
          "${_convertChunk(thousands.toInt(), handleHundreds: false)} $_thousand");
    }
    // Handle the remaining part (0-999).
    if (current > BigInt.zero) {
      // Convert the final 0-999 chunk, including hundreds if present.
      parts.add(_convertChunk(current.toInt(), handleHundreds: true));
    }
    return parts.join(' ');
  }

  /// Converts an integer chunk (0-999) into Bengali words.
  ///
  /// @param n The chunk (0 <= n <= 999).
  /// @param handleHundreds If true, process the hundreds place (e.g., for the final chunk 0-999).
  ///                     If false, treat `n` as 0-99 (e.g., for Lakh/Thousand counts).
  /// @return The chunk as Bengali words. Returns empty string for 0 or invalid input.
  String _convertChunk(int n, {bool handleHundreds = false}) {
    if (n == 0) return "";
    if (n < 0 || n > 999) return ""; // Invalid input.

    // Numbers 0-99 are directly available.
    if (n < 100) return _wordsUnder100[n];

    // Handle numbers 100-999 only if handleHundreds is true.
    if (handleHundreds) {
      int hundredsDigit = n ~/ 100; // 1-9
      int remainder = n % 100; // 0-99

      // Construct the hundreds part (e.g., "এক" + "শ", "দুই" + "শ").
      String hundredsPart = _wordsUnder100[hundredsDigit] + _hundred;
      // Apply specific forms if needed (optional, check if current logic is standard).
      // Example explicit forms (already handled by simple concatenation in original):
      // if (hundredsDigit == 2) hundredsPart = "দুই$_hundred";
      // else if (hundredsDigit == 3) hundredsPart = "তিন$_hundred"; ... etc.

      // Combine with remainder if non-zero.
      if (remainder == 0) {
        return hundredsPart; // e.g., "একশ"
      } else {
        return "$hundredsPart ${_wordsUnder100[remainder]}"; // e.g., "একশ পাঁচ"
      }
    } else {
      // If handleHundreds is false, we shouldn't have received n >= 100.
      // This path implies n was intended as 0-99, handled above.
      return ""; // Or maybe throw error? Return empty for robustness.
    }
  }
}
