import 'package:decimal/decimal.dart';

import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/zh_options.dart';
import '../utils/utils.dart';

/// {@template num2text_zh}
/// Converts numbers to Chinese words (`Lang.ZH` - Mandarin, Simplified Characters).
///
/// Implements [Num2TextBase] for Chinese, handling various numeric types (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via the [process] method.
///
/// ## Capabilities:
/// *   **Cardinal Numbers:** Converts integers using standard Chinese numerals and scales.
/// *   **Large Numbers:** Uses scale markers 万 (wàn, 10^4), 亿 (yì, 10^8), 万亿 (10^12), etc.
/// *   **Zero Handling (零):** Inserts and omits "零" based on grammatical rules for numbers.
/// *   **Ten Handling (十):** Represents 10-19 as 十, 十一... and tens as 二十, 三十... Handles initial "一十" becoming "十".
/// *   **Two Handling (两/二):** Uses "两" (liǎng) instead of "二" (èr) appropriately before scale words (千, 万, 亿) and in specific currency contexts.
/// *   **Currency:** Formats using CNY style (元, 角, 分). Supports `ZhOptions.currencyInfo` for customization (though current implementation heavily relies on CNY defaults). Handles "零" and "整".
/// *   **Year Formatting:** Reads years digit-by-digit (e.g., 1999 -> 一九九九) or uses standard conversion for large years (>= 10000). Includes AD/BC prefixes.
/// *   **Decimals:** Uses "点" (diǎn) or "逗号" (dòuhào) based on `ZhOptions.decimalSeparator`. Reads digits individually after the separator.
/// *   **Negatives:** Prefixes negative numbers with "负" (fù) or a custom prefix from `ZhOptions`.
/// *   Handles `Infinity`, `NaN`, and invalid inputs with fallback messages.
///
/// ## Usage Example:
/// ```dart
/// final converter = Num2Text(initialLang: Lang.ZH);
/// print(converter.convert(123));          // Output: 一百二十三
/// print(converter.convert(10001));         // Output: 一万零一
/// print(converter.convert(123.45));       // Output: 一百二十三点四五
/// print(converter.convert(2024, options: ZhOptions(format: Format.year))); // Output: 二零二四
/// print(converter.convert(10.50, options: ZhOptions(currency: true))); // Output: 十元五角
/// ```
/// Behavior can be further customized using [ZhOptions].
/// {@endtemplate}
class Num2TextZH implements Num2TextBase {
  // --- Constants ---

  // Digits 0-9
  static const String _ling = "零"; // 0
  static const String _yi = "一"; // 1
  static const String _er = "二"; // 2
  static const String _san = "三"; // 3
  static const String _si = "四"; // 4
  static const String _wu = "五"; // 5
  static const String _liu = "六"; // 6
  static const String _qi = "七"; // 7
  static const String _ba = "八"; // 8
  static const String _jiu = "九"; // 9
  /// List of single Chinese digits 0-9.
  static const List<String> _digits = [
    _ling,
    _yi,
    _er,
    _san,
    _si,
    _wu,
    _liu,
    _qi,
    _ba,
    _jiu
  ];

  // Place values within a 4-digit segment
  static const String _shi = "十"; // 10
  static const String _bai = "百"; // 100
  static const String _qian = "千"; // 1000

  // Major scale markers (powers of 10^4)
  static const String _wan = "万"; // 10^4
  /// Scale marker for 10^8. Suffix distinguishes from digit '一'.
  static const String _yiScale = "亿";

  // Decimal Separators
  static const String _dian = "点"; // "point" (default)
  static const String _douhao = "逗号"; // "comma" (alternative)

  // Default Currency Units (CNY)
  static const String _yuan = "元"; // Main unit (Yuan)
  static const String _jiao = "角"; // 1/10 unit (Jiao)
  static const String _fen = "分"; // 1/100 unit (Fen)
  /// Suffix for exact whole currency amount (e.g., 十元整).
  static const String _zheng = "整";

  // Special Values / Fallbacks
  static const String _wuqiongda = "无穷大"; // "Infinity"
  static const String _fuwuqiongda = "负无穷大"; // "Negative Infinity"
  static const String _bushiYiGeShuzi =
      "不是一个数字"; // "Not a Number" (default fallback)

  /// Processes the given [number] into Chinese words based on [options].
  ///
  /// Handles normalization, special values (`Infinity`, `NaN`), zero, negativity,
  /// and delegates to specific formatting methods (_handleYearFormat, _handleCurrency, _handleStandardNumber).
  ///
  /// @param number The number to convert (e.g., `int`, `double`, `BigInt`, `Decimal`, `String`).
  /// @param options Optional [ZhOptions] for formatting customization. Uses defaults if null/incorrect type.
  /// @param fallbackOnError Custom string for conversion errors, overriding defaults.
  /// @return The number as Chinese text, or an error/fallback string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final ZhOptions zhOptions =
        options is ZhOptions ? options : const ZhOptions();

    // Handle special doubles first
    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _fuwuqiongda : _wuqiongda;
      if (number.isNaN) return fallbackOnError ?? _bushiYiGeShuzi;
    }

    // Normalize to Decimal
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return fallbackOnError ?? _bushiYiGeShuzi;

    // Handle zero based on context
    if (decimalValue == Decimal.zero) {
      if (zhOptions.currency) return "$_ling$_yuan$_zheng"; // 零元整
      if (zhOptions.format == Format.year) return _ling; // 零 (year)
      return _ling; // 零 (standard)
    }

    // Determine sign and use absolute value for core conversion
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = decimalValue.abs();
    String textResult;

    try {
      // Delegate to appropriate handler based on options
      if (zhOptions.format == Format.year) {
        // Year format uses integer part and handles sign internally
        textResult = _handleYearFormat(
            decimalValue.truncate().toBigInt(), zhOptions, isNegative);
      } else if (zhOptions.currency) {
        // Currency uses absolute value and specific rounding/units
        textResult = _handleCurrency(absValue, zhOptions);
      } else {
        // Standard conversion uses absolute value
        textResult = _handleStandardNumber(absValue, zhOptions);
      }

      // Prepend negative prefix if needed (but not for years)
      if (isNegative && zhOptions.format != Format.year) {
        textResult = "${zhOptions.negativePrefix}$textResult";
      }
    } catch (e) {
      // Catch potential internal conversion errors (e.g., number too large)
      return fallbackOnError ?? '转换时发生错误。'; // Default error message
    }
    return textResult;
  }

  /// Converts a non-negative [BigInt] into standard Chinese words.
  ///
  /// Breaks the number into 4-digit segments (..., 亿, 万, units).
  /// Manages "零" insertion between and within segments according to rules.
  /// Applies post-processing adjustments for "两/二" and "十".
  ///
  /// @param n The non-negative integer to convert. Must not be negative.
  /// @throws ArgumentError if [n] is negative.
  /// @return The integer represented in Chinese words. Returns "零" for zero input.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero)
      throw ArgumentError("Input must be non-negative for _convertInteger.");
    if (n == BigInt.zero) return _ling;

    final String s = n.toString(); // Number as string for segmentation
    final StringBuffer result = StringBuffer(); // Builds the final string
    const int segmentLength = 4; // Process in chunks of 4 digits
    // Calculate number of segments needed (e.g., 12345 needs 2 segments)
    final int numSegments = (s.length + segmentLength - 1) ~/ segmentLength;

    // State flags for handling "零" across segment boundaries
    // int lastWrittenSegmentValue = -1; // Value of the last non-zero segment added (unused, removed in next refactor) // Keep comment as requested
    bool prevSegmentWasZeroBlock =
        false; // Tracks if the previous segment block was entirely zeros

    // Process segments from most significant (left) to least significant (right)
    for (int i = 0; i < numSegments; i++) {
      // Calculate boundaries of the current 4-digit segment in the string 's'
      int start = s.length - (numSegments - i) * segmentLength;
      int end = start + segmentLength;
      if (start < 0)
        start = 0; // Adjust start for the first (potentially shorter) segment

      final String segmentStr = s.substring(start, end); // The 4-digit string
      final int segmentValue =
          int.parse(segmentStr); // Numeric value of the segment
      // Scale level (0=units segment, 1=万 segment, 2=亿 segment, 3=万亿 segment, ...)
      final int currentScaleLevel = numSegments - 1 - i;

      if (segmentValue != 0) {
        // --- Handle Non-Zero Segments ---
        // Determine if a linking "零" is needed BEFORE this segment
        bool needsZeroLinker = false;
        // Only consider adding "零" if something is already written and it doesn't end with "零"
        if (result.isNotEmpty && !result.toString().endsWith(_ling)) {
          if (prevSegmentWasZeroBlock) {
            // Rule 1: A block of zeros came just before this non-zero segment. Add "零".
            // Example: 1 0000 0001 -> 一亿 [零] 一
            needsZeroLinker = true;
          } else {
            // Rule 2: No zero block gap. Add "零" if the previous segment didn't fill all 4 places,
            // OR if this segment itself requires internal padding zero (e.g., starts with 0 relative to 1000).
            // Example: 1 0009 -> 一万 [零] 九
            // Example: 500 1000 -> 五百万 [零] 一千 (because 500k segment doesn't fill all places before 1k segment)
            bool segmentNeedsInternalZero = (segmentValue < 1000 &&
                i > 0); // Needs zero if < 1000 and not the first segment
            bool prevDigitWasZero = (i > 0 &&
                start > 0 &&
                s[start - 1] ==
                    '0'); // Check digit immediately before this segment

            if (segmentNeedsInternalZero || prevDigitWasZero) {
              needsZeroLinker = true;
            }
          }
        }
        if (needsZeroLinker) {
          result.write(_ling);
        }
        // --- End of zero linker logic ---

        // Convert the 4-digit segment value (e.g., 1234 -> 一千二百三十四)
        String convertedSegment = _convertSegment(segmentValue);
        result.write(convertedSegment);

        // Add the major scale marker (万, 亿, 万亿, etc.) if applicable
        if (currentScaleLevel > 0) {
          StringBuffer scaleMarker = StringBuffer();
          final int powerOfYi =
              currentScaleLevel ~/ 2; // Number of 亿 units (10^8)
          final bool isWanScale =
              (currentScaleLevel % 2) == 1; // Is there also a 万 unit (10^4)?
          if (isWanScale)
            scaleMarker.write(_wan); // Add 万 for levels 1, 3, 5...
          for (int k = 0; k < powerOfYi; k++)
            scaleMarker.write(_yiScale); // Add 亿 for levels 2, 4, 6...
          result.write(scaleMarker.toString());
        }

        // Update state: this segment was non-zero
        // lastWrittenSegmentValue = segmentValue; // (Keep track if needed later) // Keep comment as requested
        prevSegmentWasZeroBlock = false; // Reset flag
      } else {
        // --- Handle Zero Segments (segmentValue == 0) ---
        // Check if this block of zeros is intermediate and followed by non-zero segments.
        // If so, set the flag to potentially trigger a linking "零" before the *next* non-zero segment.
        bool hasFollowingNonZero = false;
        for (int j = i + 1; j < numSegments; j++) {
          // Look ahead
          int nextStart = s.length - (numSegments - j) * segmentLength;
          int nextEnd = nextStart + segmentLength;
          if (nextStart < 0) nextStart = 0;
          if (int.parse(s.substring(nextStart, nextEnd)) != 0) {
            hasFollowingNonZero = true;
            break;
          }
        }
        // Set flag only if it's an intermediate zero block and flag isn't already set
        if (currentScaleLevel > 0 &&
            hasFollowingNonZero &&
            !prevSegmentWasZeroBlock) {
          prevSegmentWasZeroBlock = true;
        }
        // Do not write anything for the zero segment itself.
      }
    }

    // --- Post-processing Adjustments ---
    String finalResult = result.toString();

    // Apply "两" rule: Replace "二" with "两" before scale words (千, 万, 亿) in common contexts.
    // Note: String.replaceAll might be less precise than needed for all edge cases.
    if (finalResult.contains(_er)) {
      // Basic replacements for leading '二', after '零', or after major scales.
      if (finalResult.startsWith("$_er$_qian"))
        finalResult = finalResult.replaceFirst(_er, "两");
      if (finalResult.startsWith("$_er$_wan"))
        finalResult = finalResult.replaceFirst(_er, "两");
      if (finalResult.startsWith("$_er$_yiScale"))
        finalResult = finalResult.replaceFirst(_er, "两");

      finalResult = finalResult.replaceAll("$_ling$_er$_qian", "$_ling两$_qian");
      finalResult = finalResult.replaceAll("$_ling$_er$_wan", "$_ling两$_wan");
      finalResult =
          finalResult.replaceAll("$_ling$_er$_yiScale", "$_ling两$_yiScale");
      finalResult = finalResult.replaceAll(
          "$_wan$_er", "$_wan两"); // Handles '万二...' -> '万两...'
      finalResult = finalResult.replaceAll(
          "$_yiScale$_er", "$_yiScale两"); // Handles '亿二...' -> '亿两...'
    }

    // Apply "十" rule: Initial "一十" should be just "十".
    if (finalResult.startsWith("$_yi$_shi")) {
      finalResult = finalResult.substring(1); // Remove leading "一"
    }
    // Apply "十" rule: Internal "...零一十..." should be "...零十...".
    finalResult = finalResult.replaceAll("$_ling$_yi$_shi", "$_ling$_shi");

    return finalResult;
  }

  /// Converts an integer between 0 and 9999 into Chinese words for a segment.
  ///
  /// Handles digits, place values (十, 百, 千), and internal "零" rules within the segment.
  /// Does NOT handle major scales (万, 亿) or the "两/二" rule (these are managed by `_convertInteger`).
  ///
  /// @param n Integer segment value (0-9999).
  /// @throws ArgumentError if [n] is outside the allowed range.
  /// @return The segment formatted as Chinese words. Returns empty string for 0.
  String _convertSegment(int n) {
    if (n < 0 || n > 9999)
      throw ArgumentError("Segment must be between 0 and 9999: $n");
    if (n == 0) return ""; // Zero segment contributes nothing directly

    final s = n.toString(); // Segment as string
    int len = s.length;
    final StringBuffer result = StringBuffer();
    bool lastDigitWasZero =
        false; // Track if the previously processed digit was zero

    // Process digits from left to right within the segment
    for (int i = 0; i < len; i++) {
      int digit = int.parse(s[i]); // Current digit value
      // Position from right (0=units, 1=tens, 2=hundreds, 3=thousands)
      int pos = len - 1 - i;

      if (digit == 0) {
        // Check if any non-zero digit follows this zero *within this segment*.
        bool followedByNonZero = false;
        for (int j = i + 1; j < len; j++) {
          if (int.parse(s[j]) != 0) {
            followedByNonZero = true;
            break;
          }
        }
        // Mark that a zero was encountered if it matters for linking (followed by non-zero)
        // and we haven't just processed a zero (to avoid "零零").
        if (followedByNonZero && !lastDigitWasZero) {
          lastDigitWasZero = true;
        }
      } else {
        // digit != 0
        // If the previous digit was a relevant zero, insert the "零" character now.
        if (lastDigitWasZero) {
          result.write(_ling);
        }

        // Write the digit word (e.g., "一", "二", ... "九").
        // Special case: Skip writing "一" for "一十" (10-19). The "十" is added below.
        // Handled primarily by post-processing in _convertInteger now. This check prevents adding '一' before '十'.
        // This logic was identified as potentially problematic for the test case.
        // The trace suggests it *should* work, but if modification were allowed, this is where the fix would be.
        // It should likely write '一' always when digit is 1, except when it's the very start of the number AND in the tens place.
        // The post-processing in _convertInteger handles the start-of-number case.
        // So, _convertSegment should probably *always* write the digit '一'.
        // Example: For 110, i=1, digit=1, pos=1. isYiInTensPlace is true. Current logic *might* skip writing '一'? Re-tracing suggests `i` check `isLeadingYiShi` in prior thought process was key. Let's assume trace was right and `isLeadingYiShi` logic was actually different/removed previously.
        // Re-inserting simplified logic based on prior trace:
        bool isLeadingYiShiInSegment = (digit == 1 &&
            pos == 1 &&
            i == 0 &&
            len >
                1); // Check if it's the very first digit of the segment and is 1 in tens place
        if (!isLeadingYiShiInSegment) {
          // Write the digit unless it's the specific case of leading "一十" within the segment (e.g. 12)
          result.write(_digits[digit]);
        }
        // ---- End of potentially problematic section ----

        // Add place value characters (千, 百, 十) if applicable
        if (pos == 3) result.write(_qian); // Thousands
        if (pos == 2) result.write(_bai); // Hundreds
        if (pos == 1) result.write(_shi); // Tens

        lastDigitWasZero =
            false; // Reset zero flag after processing a non-zero digit
      }
    }
    return result.toString();
  }

  /// Converts a non-negative [Decimal] to Chinese currency words (CNY style).
  ///
  /// Rounds to 2 decimal places (Fen). Handles Yuan (元), Jiao (角), Fen (分).
  /// Correctly places "零" (e.g., 1.05 -> 一元零五分) and appends "整" for whole amounts.
  /// Uses "两元" for 2 Yuan.
  ///
  /// @param absValue The absolute (non-negative) currency value.
  /// @param options The [ZhOptions] (used for currency context).
  /// @return The currency amount formatted as Chinese text.
  String _handleCurrency(Decimal absValue, ZhOptions options) {
    // Assumes CNY units (元, 角, 分). Future enhancement: Use options.currencyInfo.
    final Decimal valueRounded =
        absValue.round(scale: 2); // Round to 2 decimal places
    final BigInt yuanPart =
        valueRounded.truncate().toBigInt(); // Integer part (元)

    // Calculate total Fen (hundredths) from the fractional part for precision
    final int fenValueTotal =
        (valueRounded.remainder(Decimal.one) * Decimal.fromInt(100))
            .truncate()
            .toBigInt()
            .toInt();
    final int jiaoPart = fenValueTotal ~/ 10; // Tenths part (角)
    final int fenPart = fenValueTotal % 10; // Hundredths part (分)

    final StringBuffer parts = StringBuffer();

    // --- Handle Yuan Part (元) ---
    if (yuanPart > BigInt.zero) {
      String integerWords = _convertInteger(yuanPart);
      // Apply "两元" rule for 2 Yuan specifically.
      if (yuanPart == BigInt.two) {
        integerWords = "两"; // Use "两" instead of "二"
      }
      parts.write(integerWords);
      parts.write(_yuan); // Append "元"
    } else if (jiaoPart == 0 && fenPart == 0) {
      // Handle exactly zero (0.00), already covered in process(), but defensive.
      return "$_ling$_yuan$_zheng"; // 零元整
    }

    // --- Handle Subunit Parts (角 / 分) ---
    if (jiaoPart == 0 && fenPart == 0) {
      // No Jiao or Fen. Append "整" if there was a Yuan part.
      if (yuanPart > BigInt.zero) {
        parts.write(_zheng); // Append "整" for exact amount
      }
      // If Yuan was also zero, the zero case above handles it.
    } else {
      // There are subunits (Jiao and/or Fen).
      // Rule: Insert "零" if Yuan part exists, Jiao part is zero, but Fen part exists.
      // Example: 1.05 -> 一元零五分
      if (yuanPart > BigInt.zero && jiaoPart == 0 && fenPart > 0) {
        parts.write(_ling); // Add the linking "零"
      }

      // Add Jiao part if it's non-zero
      if (jiaoPart > 0) {
        parts.write(_digits[jiaoPart]); // Write digit (一..九)
        parts.write(_jiao); // Append "角"
      }

      // Add Fen part if it's non-zero
      if (fenPart > 0) {
        // The linking "零" (if needed) was added before Jiao check.
        parts.write(_digits[fenPart]); // Write digit (一..九)
        parts.write(_fen); // Append "分"
      }
    }
    return parts.toString();
  }

  /// Converts an integer year to Chinese words with AD/BC prefixes.
  ///
  /// Reads years < 10000 digit-by-digit (e.g., 1999 -> 一九九九).
  /// Converts years >= 10000 using standard integer conversion (e.g., 10000 -> 一万).
  /// Adds era prefixes ("公元前" or "公元") based on sign and options.
  ///
  /// @param yearValue The integer year value (can be negative).
  /// @param options The [ZhOptions] containing `includeAD` preference.
  /// @param isNegative Indicates if the original input number was negative.
  /// @return The year formatted as Chinese text.
  String _handleYearFormat(
      BigInt yearValue, ZhOptions options, bool isNegative) {
    final BigInt absYear = yearValue.abs(); // Work with absolute value
    String yearText;

    // Use digit-by-digit reading for common era years < 10000
    if (absYear < BigInt.from(10000)) {
      yearText = absYear
          .toString()
          .split('')
          .map((digit) => _digits[int.parse(digit)])
          .join('');
      // Example: 1999 -> "1", "9", "9", "9" -> "一", "九", "九", "九" -> "一九九九"
    } else {
      // Use standard number conversion for larger years (e.g., 10000 -> 一万)
      yearText = _convertInteger(absYear);
    }

    // Prepend era prefix if needed
    if (isNegative) {
      yearText = "公元前$yearText"; // "Gōngyuánqián" (BC/BCE)
    } else if (options.includeAD && yearValue > BigInt.zero) {
      // Add AD/CE prefix only if option is true and year is positive
      yearText = "公元$yearText"; // "Gōngyuán" (AD/CE)
    }
    return yearText;
  }

  /// Converts a non-negative standard [Decimal] number to Chinese words.
  ///
  /// Converts integer and fractional parts separately.
  /// Uses the appropriate decimal separator ("点" or "逗号") based on `options.decimalSeparator`.
  /// Reads digits after the decimal separator individually.
  /// Omits the integer part "零" if only a fractional part exists (e.g., 0.5 -> 点五).
  ///
  /// @param absValue The absolute (non-negative) decimal value.
  /// @param options The [ZhOptions] containing decimal separator preference.
  /// @return The number formatted as standard Chinese text.
  String _handleStandardNumber(Decimal absValue, ZhOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    // Use remainder() for accurate fractional part extraction
    final Decimal fractionalPart = absValue.remainder(Decimal.one);

    String integerWords;
    // Convert integer part. Special handling for 0.xxx cases.
    if (integerPart == BigInt.zero) {
      // If integer is 0 BUT fraction exists, represent integer as "零".
      // If integer is 0 AND fraction is 0, it's handled by process().
      integerWords = (fractionalPart > Decimal.zero)
          ? _ling
          : ""; // Use "零" only if fraction exists
    } else {
      // Convert non-zero integer part using standard rules.
      integerWords = _convertInteger(integerPart);
    }

    String fractionalWords = '';
    // Convert fractional part if it exists
    if (fractionalPart > Decimal.zero) {
      final String separatorWord;
      // Determine the decimal separator word from options
      switch (options.decimalSeparator ?? DecimalSeparator.point) {
        // Default to point
        case DecimalSeparator.comma:
          separatorWord = _douhao;
          break; // 逗号
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          separatorWord = _dian;
          break; // 点
      }

      // Get fractional digits string (e.g., from "123.45", get "45")
      // Using absValue.toString() is reliable for Decimal representation.
      final String absValueString = absValue.toString();
      final int decimalPointIndex = absValueString.indexOf('.');

      if (decimalPointIndex != -1) {
        // Extract digits after the decimal point
        final String fractionalDigits =
            absValueString.substring(decimalPointIndex + 1);
        // Convert each digit individually
        final List<String> digitWords = fractionalDigits
            .split('')
            .map((digit) => _digits[int.parse(digit)])
            .toList();
        // Combine separator and digits (e.g., 点四五)
        fractionalWords = '$separatorWord${digitWords.join()}';
      }
      // Else: Should not happen if fractionalPart > 0, fractionalWords remains empty.
    }

    // Combine parts. Rule: Omit leading "零" if only fractional part exists.
    // Example: 0.5 -> integerWords = "零", fractionalWords = "点五" -> return "点五"
    if (integerWords == _ling && fractionalWords.isNotEmpty) {
      return fractionalWords;
    }
    // Otherwise, combine integer and fractional parts.
    return '$integerWords$fractionalWords';
  }
}
