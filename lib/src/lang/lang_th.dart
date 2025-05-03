import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/th_options.dart';
import '../utils/utils.dart';

/// {@template num2text_th}
/// Converts numbers to Thai words (`Lang.TH`).
///
/// Implements [Num2TextBase] for Thai, handling various numeric types.
/// Supports cardinal numbers, decimals, negatives, currency (default THB), years, and large numbers
/// using "ล้าน" (million) as the recursive scale marker.
/// Customizable via [ThOptions]. Returns a fallback string on error.
///
/// Handles specific Thai grammatical rules like using "เอ็ด" for '1' in the units place
/// (e.g., 11 -> สิบเอ็ด), "ยี่" for '2' in the tens place (e.g., 20 -> ยี่สิบ),
/// and using "หนึ่ง" correctly for standalone '1' values (e.g., 1,000,000 -> หนึ่งล้าน).
/// {@endtemplate}
class Num2TextTH implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "ศูนย์"; // "zero"
  static const String _pointWord = "จุด"; // Decimal separator "." ("point")
  static const String _commaWord = "ลูกน้ำ"; // Decimal separator "," ("comma")
  static const String _unit = ""; // Placeholder for units place (no word)
  static const String _ten = "สิบ"; // "ten"
  static const String _hundred = "ร้อย"; // "hundred"
  static const String _thousand = "พัน"; // "thousand"
  static const String _tenThousand = "หมื่น"; // "ten thousand"
  static const String _hundredThousand = "แสน"; // "hundred thousand"
  static const String _million = "ล้าน"; // "million" - Primary scale marker

  /// Suffix for '1' when it's the *last digit* of a number group greater than 10 (e.g., 11 สิบเอ็ด).
  static const String _oneUnitSuffix = "เอ็ด";

  /// Prefix for '2' when it's in the *tens place* (e.g., 20 ยี่สิบ).
  static const String _twentyPrefix = "ยี่";

  /// Suffix for exact currency amounts (e.g., 10 บาทถ้วน).
  static const String _currencyExactSuffix = "ถ้วน";
  static const String _yearSuffixBC = " ก่อน ค.ศ."; // Suffix for BC/BCE years
  static const String _yearSuffixAD = " ค.ศ."; // Suffix for AD/CE years
  static const String _notANumber = "ไม่ใช่ตัวเลข"; // Default "Not a Number"
  static const String _positiveInfinity = "อนันต์"; // "Infinity"
  static const String _negativeInfinity = "ลบอนันต์"; // "Negative Infinity"

  static const List<String> _digits = [
    "ศูนย์",
    "หนึ่ง",
    "สอง",
    "สาม",
    "สี่",
    "ห้า",
    "หก",
    "เจ็ด",
    "แปด",
    "เก้า"
  ]; // 0-9
  /// Place value words up to 100,000 (used within million segments). Index 0-5 maps to 10^0-10^5.
  static const List<String> _placeValues = [
    _unit,
    _ten,
    _hundred,
    _thousand,
    _tenThousand,
    _hundredThousand
  ];

  static final BigInt _bigIntMillion = BigInt.from(1000000); // 1,000,000

  /// Processes the given [number] into Thai words.
  ///
  /// {@template num2text_process_intro_th}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options_th}
  /// Uses [ThOptions] for customization (currency, year format, decimals, AD/BC, negative prefix).
  /// Defaults apply if [options] is null or not [ThOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors_th}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or default Thai errors on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [ThOptions] settings.
  /// @param fallbackOnError Optional custom error string.
  /// @return The number as Thai words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final ThOptions thOptions =
        options is ThOptions ? options : const ThOptions();
    final String onError = fallbackOnError ?? _notANumber;

    // Handle special non-finite double values first.
    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _negativeInfinity : _positiveInfinity;
      if (number.isNaN) return onError;
    }

    // Normalize input to Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return onError; // Invalid number input.

    // Handle zero separately based on context.
    if (decimalValue == Decimal.zero) {
      if (thOptions.currency)
        return "$_zero${thOptions.currencyInfo.mainUnitSingular}$_currencyExactSuffix"; // e.g., ศูนย์บาทถ้วน
      // For standard numbers or years, zero is just ศูนย์.
      else
        return _zero;
    }

    // Determine sign and work with the absolute value.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = decimalValue.abs();
    String textResult;

    // Delegate to specific handlers based on format options.
    if (thOptions.format == Format.year) {
      // Year formatting handles sign internally.
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), thOptions);
    } else {
      // Handle currency or standard number format for the absolute value.
      textResult = thOptions.currency
          ? _handleCurrency(absValue, thOptions)
          : _handleStandardNumber(absValue, thOptions);
      // Prepend the negative prefix if the original number was negative.
      if (isNegative) {
        textResult = "${thOptions.negativePrefix}$textResult";
      }
    }
    return textResult;
  }

  /// Converts a non-negative [BigInt] into Thai words using million scaling.
  ///
  /// Recursively breaks the number into chunks of 1,000,000 (million).
  /// Appends "ล้าน" (million) for each level of scaling.
  /// Delegates chunks < 1,000,000 to [_convertUpToMillion].
  ///
  /// @param n Non-negative integer.
  /// @param scaleLevel The current recursion level (0 for base, 1 for million, 2 for million*million, etc.).
  /// @throws ArgumentError if [n] is negative.
  /// @return Integer as Thai words. Returns empty string for zero input internally.
  String _convertInteger(BigInt n, {int scaleLevel = 0}) {
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n == BigInt.zero)
      return ""; // Zero is handled by callers or contributes nothing here.

    // Process the number in chunks of one million.
    final BigInt chunk = n % _bigIntMillion; // Current chunk (0 - 999,999).
    final BigInt remaining = n ~/ _bigIntMillion; // Part for higher scales.

    String currentText = "";
    // Convert the current chunk (< 1 million) if it's non-zero.
    if (chunk > BigInt.zero) {
      // Determine if this chunk is part of a larger structure (influences หนึ่ง vs เอ็ด).
      bool isPart = remaining > BigInt.zero || scaleLevel > 0;
      currentText = _convertUpToMillion(chunk, isPartOfLargerNumber: isPart);

      // Append scale markers ("ล้าน", "ล้านล้าน", etc.) if this isn't the base chunk.
      if (scaleLevel > 0) {
        String scaleUnit = List.filled(scaleLevel, _million).join('');
        currentText += scaleUnit;
      }
    }

    String remainingText = "";
    // Recursively convert the remaining part (higher scales).
    if (remaining > BigInt.zero) {
      remainingText = _convertInteger(remaining, scaleLevel: scaleLevel + 1);
    }

    // Combine higher scales and current scale text.
    return '$remainingText$currentText';
  }

  /// Converts an integer between 1 and 999,999 into Thai words.
  ///
  /// Handles digits, place values (สิบ, ร้อย, ..., แสน), and special rules for '1' (เอ็ด) and '2' (ยี่).
  /// Uses [isPartOfLargerNumber] to correctly determine if a trailing '1' should be "เอ็ด" or "หนึ่ง".
  ///
  /// @param n Integer chunk (1 - 999,999).
  /// @param isPartOfLargerNumber True if this chunk is part of a larger number structure
  ///                             (e.g., followed by higher scales, or part of currency/decimal),
  ///                             influencing the choice between "หนึ่ง" and "เอ็ด" for a trailing '1'.
  /// @return Chunk as Thai words. Returns empty string for zero/invalid input.
  String _convertUpToMillion(BigInt n, {required bool isPartOfLargerNumber}) {
    // This function handles chunks strictly less than one million.
    if (n <= BigInt.zero || n >= _bigIntMillion) return "";

    final StringBuffer chunkResult = StringBuffer();
    final String chunkStr = n.toString();
    final int chunkLen = chunkStr.length;

    for (int i = 0; i < chunkLen; i++) {
      final int digit = int.parse(chunkStr[i]);
      // Position from right (0=units, 1=tens, ..., 5=hundred thousands).
      final int place = chunkLen - 1 - i;

      if (digit == 0)
        continue; // Skip zero digits, they don't have explicit words.

      final String digitWord;
      final bool isTensPlace = place == 1;
      final bool isUnitsPlace = place == 0;

      // Apply special rules for digits 1 and 2 based on their place value.
      if (isTensPlace) {
        // Tens place (สิบ)
        if (digit == 1)
          digitWord = ""; // For 10, "สิบ" acts as the digit word.
        else if (digit == 2)
          digitWord = _twentyPrefix; // Use "ยี่" for 20s.
        else
          digitWord = _digits[digit]; // 3-9 use standard digit words.
      } else if (isUnitsPlace) {
        // Units place
        // Use "เอ็ด" for '1' only if it's the last digit AND the number is > 10 within this chunk.
        // The check `chunkLen > 1` ensures "เอ็ด" isn't used for the number 1 itself.
        // The isPartOfLargerNumber flag is NOT needed here; the context is handled by the caller setting up the chunk.
        if (digit == 1 && chunkLen > 1)
          digitWord = _oneUnitSuffix; // Use "เอ็ด".
        else
          digitWord = _digits[
              digit]; // Use standard digits, including "หนึ่ง" for standalone 1.
      } else {
        // Hundreds, thousands, etc. places
        digitWord = _digits[digit]; // Use standard digit words.
      }

      // Append the determined digit word (or prefix like "ยี่").
      chunkResult.write(digitWord);

      // Append the place value word (สิบ, ร้อย, พัน, ...) if applicable.
      if (place > 0 && digitWord.isNotEmpty) {
        // Standard case: digit word + place value (e.g., สาม + ร้อย).
        chunkResult.write(_placeValues[place]);
      } else if (isTensPlace && digit == 1) {
        // Special case for 10 (digit 1, tens place): digitWord was empty, append only place value "สิบ".
        chunkResult.write(_placeValues[place]);
      }
    }
    return chunkResult.toString();
  }

  /// Converts an integer year to Thai words with optional AD/BC suffixes.
  ///
  /// Uses standard integer conversion. Appends era suffixes based on options.
  ///
  /// @param year The integer year.
  /// @param options Formatting options including `includeAD`.
  /// @return The year as Thai words.
  String _handleYearFormat(BigInt year, ThOptions options) {
    final bool isNegative = year < BigInt.zero;
    final BigInt absYear = year.abs();

    if (absYear == BigInt.zero) return _zero; // Year 0 is ศูนย์.

    // Convert the absolute year value using standard integer logic.
    String yearText = _convertInteger(absYear, scaleLevel: 0);

    // Append era suffixes ("ก่อน ค.ศ." or "ค.ศ.") if applicable.
    if (isNegative)
      yearText += _yearSuffixBC;
    else if (options.includeAD) yearText += _yearSuffixAD;

    return yearText;
  }

  /// Converts a non-negative [Decimal] to Thai currency words (Baht/Satang).
  ///
  /// Uses [ThOptions.currencyInfo] for unit names. Rounds if [ThOptions.round] is true.
  /// Separates main (Baht) and subunits (Satang). Appends "ถ้วน" for exact Baht amounts.
  /// Correctly uses "หนึ่ง" for 1 Baht and 1 Satang.
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Thai words.
  String _handleCurrency(Decimal absValue, ThOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2;
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value if requested.
    final Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate integer (Baht) and fractional parts.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart =
        (valueToConvert - valueToConvert.truncate()).abs();
    // Calculate subunit (Satang) value, rounding might handle precision issues.
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round(scale: 0).toBigInt();

    final StringBuffer result = StringBuffer();

    // --- Main Value (Baht) ---
    if (mainValue > BigInt.zero) {
      // Convert Baht amount using standard integer conversion.
      result.write(_convertInteger(mainValue, scaleLevel: 0));
      result.write(currencyInfo.mainUnitSingular); // Append Baht unit name.
    }

    // --- Subunit Value (Satang) ---
    if (subunitValue > BigInt.zero) {
      // Convert Satang amount. `isPartOfLargerNumber` indicates if Baht exists.
      // The context for หนึ่ง/เอ็ด is correctly handled within _convertUpToMillion now.
      result.write(_convertUpToMillion(subunitValue,
          isPartOfLargerNumber: mainValue > BigInt.zero));
      // Append Satang unit name if available.
      if (currencyInfo.subUnitSingular != null) {
        result.write(currencyInfo.subUnitSingular!);
      }
    } else {
      // No subunits (Satang = 0). If there was a Baht value, append "ถ้วน" (exact).
      if (mainValue > BigInt.zero) {
        result.write(_currencyExactSuffix);
      }
    }

    // This check seems redundant as the subunit part is handled above. Removing.
    // if (result.isEmpty && subunitValue > BigInt.zero) { ... }

    // Handle case where value rounds to zero (mostly handled by initial check in 'process').
    if (result.isEmpty &&
        mainValue == BigInt.zero &&
        subunitValue == BigInt.zero) {
      return "$_zero${currencyInfo.mainUnitSingular}$_currencyExactSuffix"; // Defensive: ศูนย์บาทถ้วน.
    }

    return result.toString();
  }

  /// Converts a non-negative standard [Decimal] number to Thai words.
  ///
  /// Converts integer and fractional parts. Uses [ThOptions.decimalSeparator] word ("จุด" or "ลูกน้ำ").
  /// Fractional part converted digit by digit.
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Thai words.
  String _handleStandardNumber(Decimal absValue, ThOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = (absValue - absValue.truncate()).abs();

    String integerWords;
    // Handle integer part.
    if (integerPart == BigInt.zero) {
      // Use "ศูนย์" if integer is 0 but fraction exists (e.g., 0.5).
      // If exactly zero, handled by 'process'.
      integerWords = (fractionalPart > Decimal.zero) ? _zero : _zero;
    } else {
      // Convert non-zero integer part.
      integerWords = _convertInteger(integerPart, scaleLevel: 0);
    }

    String fractionalWords = '';
    // Handle fractional part if it exists.
    if (fractionalPart > Decimal.zero) {
      final String separatorWord;
      // Determine decimal separator word.
      switch (options.decimalSeparator ?? DecimalSeparator.period) {
        case DecimalSeparator.comma:
          separatorWord = _commaWord;
          break; // ลูกน้ำ
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          separatorWord = _pointWord;
          break; // จุด
      }

      // Get fractional digits string from the original decimal value.
      final String fracStr = absValue.toString();
      final int pointIndex = fracStr.indexOf('.');
      if (pointIndex != -1) {
        String digitsStr = fracStr.substring(pointIndex + 1);
        // Trim trailing zeros for standard decimal representation (e.g., 1.50 -> จุดห้า).
        digitsStr = digitsStr.replaceAll(RegExp(r'0+$'), '');

        if (digitsStr.isNotEmpty) {
          // Convert each digit individually.
          final List<String> digitWords = digitsStr.split('').map((digit) {
            final int? digitInt = int.tryParse(digit);
            return (digitInt != null && digitInt >= 0 && digitInt <= 9)
                ? _digits[digitInt]
                : '?';
          }).toList();
          // Combine separator and digit words (no space between digits in Thai decimals).
          fractionalWords = '$separatorWord${digitWords.join()}';
        }
      }
    }

    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords';
  }
}
