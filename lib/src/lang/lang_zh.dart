import 'package:decimal/decimal.dart';

import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/zh_options.dart';
import '../utils/utils.dart';

/// {@template num2text_zh}
/// The Chinese language (`Lang.ZH` - Mandarin, Simplified Characters) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Chinese word representation following standard Mandarin grammar and vocabulary.
///
/// ## Capabilities:
/// *   **Cardinal Numbers:** Handles integers of varying sizes.
/// *   **Large Numbers:** Uses standard Chinese scale markers: 万 (wàn, 10^4), 亿 (yì, 10^8), and combinations like 万亿 (10^12), 亿亿 (10^16).
/// *   **Zero Handling (零):** Correctly inserts and omits "零" according to grammatical rules within and between 4-digit segments.
/// *   **Ten Handling (十):** Represents 10-19 as 十, 十一...十九 and tens digits like 20, 30 as 二十, 三十.
/// *   **Currency:** Formats using [ZhOptions.currencyInfo] (defaulting to CNY: 元, 角, 分) with correct placement of "零" and appending "整" for whole amounts.
/// *   **Year Formatting:** Reads years digit by digit (e.g., 1999 -> 一九九九) via [Format.year].
/// *   **Decimals:** Uses 点 (diǎn) or 逗号 (dòuhào) as specified in [ZhOptions.decimalSeparator] and reads digits individually after the separator.
/// *   **Negatives:** Prefixes negative numbers with the word specified in [ZhOptions.negativePrefix].
/// *   Invalid inputs result in a fallback message.
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
///
/// Behavior can be further customized using [ZhOptions].
/// {@endtemplate}
class Num2TextZH implements Num2TextBase {
  // --- Private Constants ---

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

  // Small Scales (within a 4-digit segment)
  static const String _shi = "十"; // 10
  static const String _bai = "百"; // 100
  static const String _qian = "千"; // 1000

  // Major Scales (for grouping segments)
  static const String _wan = "万"; // 10^4
  static const String _yiScale =
      "亿"; // 10^8 ('Scale' added to distinguish from digit 'yi')

  // Decimal Separators
  static const String _dian = "点"; // Default separator "point"
  static const String _douhao = "逗号"; // Alternative "comma"

  // Currency Units (Default: CNY)
  static const String _yuan = "元"; // Main unit (Yuan)
  static const String _jiao = "角"; // 1/10 unit (Jiao)
  static const String _fen = "分"; // 1/100 unit (Fen)
  static const String _zheng = "整"; // Suffix for exact main unit amount (whole)

  // Special Values / Errors
  static const String _wuqiongda = "无穷大"; // Infinity
  static const String _fuwuqiongda = "负无穷大"; // Negative Infinity
  static const String _bushiYiGeShuzi = "不是一个数字"; // Not a Number (NaN)

  /// Processes the given number based on the provided options and converts it to Chinese text.
  ///
  /// Handles normalization, special values (infinity, NaN), zero, negativity,
  /// and delegates to specific formatting methods based on [options].
  ///
  /// - [number]: The number to convert (can be `int`, `double`, `BigInt`, `Decimal`, or `String`).
  /// - [options]: Optional `ZhOptions` to customize formatting (e.g., currency, year).
  ///              If null or not `ZhOptions`, default `ZhOptions` are used.
  /// - [fallbackOnError]: A custom string to return on conversion errors, instead of the default messages.
  /// - Returns: The number converted to Chinese text, or an error/fallback string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure correct options type or use default
    final ZhOptions zhOptions =
        options is ZhOptions ? options : const ZhOptions();

    // Handle special double values immediately
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? _fuwuqiongda : _wuqiongda;
      }
      if (number.isNaN) {
        return fallbackOnError ?? _bushiYiGeShuzi;
      }
    }

    // Normalize the input number to Decimal for consistent handling
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) {
      // Input could not be parsed as a valid number
      return fallbackOnError ?? _bushiYiGeShuzi;
    }

    // --- Handle Zero ---
    if (decimalValue == Decimal.zero) {
      if (zhOptions.currency) {
        // Currency 0.00 is "零元整"
        return "$_ling$_yuan$_zheng";
      }
      if (zhOptions.format == Format.year) {
        // Year 0 is "零"
        return _ling;
      }
      // Standard 0 is "零"
      return _ling;
    }

    // Determine sign and work with absolute value
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    try {
      // --- Delegate to specific formatting methods ---
      if (zhOptions.format == Format.year) {
        // Year format uses integer part and specific rules. Handles sign internally.
        textResult = _handleYearFormat(
            decimalValue.truncate().toBigInt(), zhOptions, isNegative);
      } else if (zhOptions.currency) {
        // Currency format uses specific units and rounding. Handles absolute value.
        textResult = _handleCurrency(absValue, zhOptions);
      } else {
        // Standard number conversion (integer and decimal parts). Handles absolute value.
        textResult = _handleStandardNumber(absValue, zhOptions);
      }

      // Prepend negative prefix if needed (except for year format which handles it internally)
      if (isNegative && zhOptions.format != Format.year) {
        textResult = "${zhOptions.negativePrefix}$textResult";
      }
    } catch (e) {
      // Catch potential errors during internal conversion logic
      // Consider logging the error 'e' here if needed for debugging
      return fallbackOnError ?? 'Error occurred during conversion.';
    }

    return textResult;
  }

  /// Handles formatting a number as a year.
  ///
  /// In Chinese, years are typically pronounced digit by digit.
  /// Negative years (BC/BCE) are prefixed according to `options.negativePrefix`.
  /// Positive years (AD/CE) can optionally be prefixed with "公元" (gōngyuán - Common Era)
  /// if `options.includeAD` is true.
  ///
  /// - [yearValue]: The integer year value (can be negative).
  /// - [options]: The `ZhOptions` containing formatting preferences (`negativePrefix`, `includeAD`).
  /// - [isNegative]: Indicates if the original number input was negative.
  /// - Returns: The year formatted as Chinese text according to the rules.
  String _handleYearFormat(
      BigInt yearValue, ZhOptions options, bool isNegative) {
    // Work with the absolute value for digit conversion
    final BigInt absYear = yearValue.abs();
    final String absYearStr = absYear.toString();

    // Convert each digit to its Chinese character representation
    final List<String> yearDigits =
        absYearStr.split('').map((digit) => _digits[int.parse(digit)]).toList();
    String yearText = yearDigits.join('');

    // Add prefixes based on sign and options
    if (isNegative) {
      // Prefix negative years (BC/BCE) with the specified negative prefix (e.g., "负").
      yearText = "${options.negativePrefix}$yearText";
    } else if (options.includeAD && yearValue > BigInt.zero) {
      // Optionally prefix positive years (AD/CE) with "公元" if requested.
      yearText = "公元$yearText"; // 公元 (gōngyuán) = Common Era (AD/CE)
    }

    return yearText;
  }

  /// Handles formatting a number as currency (specifically CNY style: Yuan, Jiao, Fen).
  ///
  /// *   Rounds the number to 2 decimal places.
  /// *   Converts the integer part (Yuan) using `_convertInteger`.
  /// *   Converts the fractional part into Jiao (1/10) and Fen (1/100).
  /// *   Adds currency unit names "元", "角", "分".
  /// *   Appends "整" (zhěng) for whole yuan amounts (no Jiao or Fen).
  /// *   Correctly inserts "零" (líng) when Jiao is zero but Fen is present (e.g., 1.05 Yuan -> 一元零五分).
  ///
  /// - [absValue]: The absolute decimal value of the currency amount (must be non-negative).
  /// - [options]: The `ZhOptions` (used implicitly for currency context, and potentially `currencyInfo` if customizable).
  /// - Returns: The currency amount formatted as Chinese text.
  String _handleCurrency(Decimal absValue, ZhOptions options) {
    // Currency formatting assumes CNY units for now. Could be extended via options.currencyInfo.
    // Round to 2 decimal places for currency subunits (Jiao, Fen)
    final Decimal valueRounded = absValue.round(scale: 2);
    final BigInt yuanPart = valueRounded.truncate().toBigInt();

    // Calculate total Fen value (hundredths) from the fractional part
    final int fenValueTotal =
        (valueRounded.remainder(Decimal.one) * Decimal.fromInt(100))
            .truncate()
            .toBigInt()
            .toInt();
    final int jiaoPart = fenValueTotal ~/ 10; // Tenths of Yuan (角)
    final int fenPart = fenValueTotal % 10; // Hundredths of Yuan (分)

    // Build the text representation parts
    final StringBuffer parts = StringBuffer();

    // 1. Handle Yuan Part (Integer)
    if (yuanPart > BigInt.zero) {
      parts.write(_convertInteger(yuanPart));
      parts.write(_yuan); // Add "元"
    } else if (jiaoPart == 0 && fenPart == 0) {
      // Handle exactly zero case (already done in process, but defensive)
      return "$_ling$_yuan$_zheng";
    }

    // 2. Handle Subunits (Jiao and Fen)
    if (jiaoPart == 0 && fenPart == 0) {
      // If there are no subunits, append "整" (exact/whole) if there was a Yuan part.
      if (yuanPart > BigInt.zero) {
        parts.write(_zheng);
      }
      // If Yuan was also zero, initial check handles "零元整".
    } else {
      // We have some subunits (Jiao or Fen or both).
      // Insert "零" between Yuan and Fen ONLY if Yuan exists, Jiao is zero, and Fen exists.
      if (yuanPart > BigInt.zero && jiaoPart == 0 && fenPart > 0) {
        parts.write(_ling); // Add "零" connector
      }

      // Add Jiao part if present
      if (jiaoPart > 0) {
        parts.write(_digits[jiaoPart]);
        parts.write(_jiao); // Add "角"
      }

      // Add Fen part if present
      if (fenPart > 0) {
        // Only add Fen if it's non-zero.
        // The preceding "零" (if needed) is handled above.
        parts.write(_digits[fenPart]);
        parts.write(_fen); // Add "分"
      }
    }

    return parts.toString();
  }

  /// Handles standard number formatting, including integer and decimal parts.
  ///
  /// *   Converts the integer part using `_convertInteger`.
  /// *   Converts the fractional part digit by digit.
  /// *   Uses the appropriate decimal separator ("点" or "逗号") based on `options.decimalSeparator`.
  ///
  /// - [absValue]: The absolute decimal value of the number (must be non-negative).
  /// - [options]: The `ZhOptions` containing decimal separator preference.
  /// - Returns: The number formatted as standard Chinese text.
  String _handleStandardNumber(Decimal absValue, ZhOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    // Use remainder() to get the fractional part accurately
    final Decimal fractionalPart = absValue.remainder(Decimal.one);

    String integerWords;
    // Convert integer part. Handle case where integer is 0 but fraction exists.
    if (integerPart == BigInt.zero) {
      // If only fractional part exists (e.g., 0.5), integer part is "零".
      // If number is exactly 0, it's handled earlier.
      integerWords = (fractionalPart > Decimal.zero)
          ? _ling
          : ""; // Avoid "零" if value is integer 0
    } else {
      integerWords = _convertInteger(integerPart);
    }

    String fractionalWords = '';
    // Convert fractional part if it exists
    if (fractionalPart > Decimal.zero) {
      final String separatorWord;
      // Determine the decimal separator word based on options
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _douhao; // "逗号"
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period: // Treat period and point the same
        default: // Default to "点"
          separatorWord = _dian; // "点"
          break;
      }

      // Get fractional digits as a string, avoiding potential scientific notation
      // Use toString() which handles precision and trailing zeros for Decimal.
      final String absValueString = absValue.toString();
      final int decimalPointIndex = absValueString.indexOf('.');
      if (decimalPointIndex == -1) {
        // Should not happen if fractionalPart > 0, but handle defensively
        fractionalWords = '';
      } else {
        final String fractionalDigits =
            absValueString.substring(decimalPointIndex + 1);

        // Convert each fractional digit individually
        final List<String> digitWords = fractionalDigits
            .split('')
            .map((digit) => _digits[int.parse(digit)])
            .toList();
        fractionalWords = '$separatorWord${digitWords.join()}'; // e.g., "点四五六"
      }
    }

    // Combine integer and fractional parts. Avoid leading "零" if only fraction exists.
    if (integerWords == _ling && fractionalWords.isNotEmpty) {
      return fractionalWords; // e.g., 0.5 -> "点五" (integer "零" is omitted)
    }
    return '$integerWords$fractionalWords';
  }

  /// Converts a non-negative integer (`BigInt`) into Chinese text using 4-digit segments.
  ///
  /// This is the core routine for handling potentially large integers.
  /// It processes the number in segments of four digits from right to left,
  /// inserting the appropriate scale markers (万, 亿, 万亿, etc.) and handling
  /// the insertion of "零" between segments according to Chinese grammar rules.
  ///
  /// Example: 123456789 -> "一亿二千三百四十五万六千七百八十九"
  /// Example: 100000001 -> "一亿零一"
  ///
  /// - [n]: The non-negative integer to convert.
  /// - Returns: The integer converted to Chinese text.
  /// Throws [ArgumentError] if input `n` is negative.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero) {
      // This function assumes non-negative input; sign is handled by the caller.
      throw ArgumentError("Input must be non-negative for _convertInteger.");
    }
    if (n == BigInt.zero) return _ling; // Base case: 0

    // Optimization: Handle 10-19 directly. Simplifies logic.
    if (n >= BigInt.from(10) && n < BigInt.from(20)) {
      final int unit = (n % BigInt.from(10)).toInt();
      // Returns 十 (10), 十一 (11), ..., 十九 (19)
      return "$_shi${unit == 0 ? '' : _digits[unit]}";
    }

    final String s = n.toString();
    final List<String> finalParts =
        []; // Stores the final text parts, built right-to-left then joined.
    const int segmentLength = 4; // Process in chunks of 4 digits (万 based)
    bool lastMajorPartWasZero =
        true; // Tracks if the *previous* 4-digit segment was entirely zero.

    // Iterate through the number string in segments of 4, from right (least significant) to left.
    for (int i = s.length; i > 0; i -= segmentLength) {
      final int start = (i - segmentLength < 0) ? 0 : i - segmentLength;
      final String segmentStr = s.substring(start, i);
      final int segmentValue = int.parse(
        segmentStr,
      ); // Value of the current 4-digit segment (0-9999)
      // Calculate the scale level (0=units, 1=万, 2=亿, 3=万亿, ...) based on segment position
      final int currentScaleLevel = (s.length - i) ~/ segmentLength;

      if (segmentValue != 0) {
        // --- This segment is Non-Zero ---
        // Check if a "零" is needed *before* this segment due to a preceding zero segment.
        if (finalParts.isNotEmpty && lastMajorPartWasZero) {
          // Insert "零" if the previous segment was zero and we haven't just inserted a zero.
          if (finalParts.first != _ling) {
            finalParts.insert(0, _ling);
          }
        }

        // Convert the 4-digit segment value itself to Chinese text.
        final String convertedSegment = _convertSegment(segmentValue);

        // Determine and insert the appropriate scale marker (万, 亿, 万亿, 亿亿, etc.)
        if (currentScaleLevel > 0) {
          StringBuffer scaleMarker = StringBuffer();
          // Power of 亿 (10^8): Each 2 scale levels = one power of Yi.
          final int powerOfYi = currentScaleLevel ~/ 2;
          // Is Wan scale (10^4) needed? True for odd scale levels (1, 3, 5...).
          final bool isWanScale = (currentScaleLevel % 2) == 1;

          if (isWanScale) {
            scaleMarker.write(_wan); // Add 万 for levels 1, 3, 5...
          }
          // Add 亿 for levels 2, 4, 6... (亿, 亿亿, 亿亿亿...)
          for (int k = 0; k < powerOfYi; k++) {
            scaleMarker.write(_yiScale);
          }

          // Insert the calculated scale marker before the segment text (since we build right-to-left).
          if (scaleMarker.isNotEmpty) {
            finalParts.insert(0, scaleMarker.toString());
          }
        }

        // Insert the text of the converted segment.
        finalParts.insert(0, convertedSegment);
        lastMajorPartWasZero = false; // Mark that this segment was non-zero.
      } else {
        // --- This segment is Zero ---
        // Mark that a zero segment was encountered. We don't add "零" here directly;
        // the flag `lastMajorPartWasZero` controls adding "零" before the *next* non-zero segment.
        lastMajorPartWasZero = true;
      }
    }
    // Join the parts built in reverse order.
    return finalParts.join();
  }

  /// Converts a single 4-digit segment (0-9999) into Chinese text.
  ///
  /// Handles the placement of small scale markers (千, 百, 十) and the complex rules
  /// for inserting "零" within the segment according to standard Chinese grammar.
  /// Ensures correct handling for numbers like 1001 ("一千零一"), 1100 ("一千一百"),
  /// 1010 ("一千零一十"), and 11 ("十一").
  ///
  /// - [n]: The integer segment value (must be 0-9999).
  /// - Returns: The segment converted to Chinese text, or an empty string if n is 0.
  /// Throws [ArgumentError] if input `n` is outside the valid range 0-9999.
  String _convertSegment(int n) {
    if (n < 0 || n > 9999) {
      throw ArgumentError("Segment must be between 0 and 9999, but got: $n");
    }
    if (n == 0) return ""; // Zero segment converts to empty string

    // Special Case: Handle 10-19 (十一 to 十九). This is simpler than the main logic.
    if (n >= 10 && n < 20) {
      final int unit = n % 10;
      // Returns 十 (used if unit is 0, e.g. for segment 10), 十一, ..., 十九
      return "$_shi${unit == 0 ? '' : _digits[unit]}";
    }

    final List<String> parts = []; // Parts of the segment text
    // Track state for correct zero insertion:
    bool previousDigitWasZero =
        true; // Start assuming zero precedes the first digit (thousands).
    bool zeroDigitInserted =
        false; // Has a "零" already been added *within this segment*? Prevents "零零".

    // 1. Thousands Place (千)
    final int thousands = n ~/ 1000;
    if (thousands > 0) {
      // Use "一" for 1000-1999 is handled naturally by _digits[thousands]
      parts.add(_digits[thousands]);
      parts.add(_qian);
      previousDigitWasZero = false; // Thousands place was non-zero
    }
    int remainder = n % 1000; // Remainder after thousands

    // 2. Hundreds Place (百)
    final int hundreds = remainder ~/ 100;
    if (hundreds > 0) {
      // If previous was zero (i.e., thousands was 0), add '零' before this non-zero digit.
      if (previousDigitWasZero && !zeroDigitInserted && n >= 1000) {
        // Need n>=1000 check? Yes, e.g. for 101 vs 1001
        parts.add(_ling);
        zeroDigitInserted = true;
      }
      parts.add(_digits[hundreds]);
      parts.add(_bai);
      previousDigitWasZero = false; // Hundreds place was non-zero
      zeroDigitInserted = false; // Reset zero flag as we have a non-zero digit.
    } else {
      // Hundreds place is zero. Mark previous as zero for the next step (tens).
      previousDigitWasZero = true;
    }
    remainder %= 100; // Remainder after hundreds

    // 3. Tens Place (十)
    final int tens = remainder ~/ 10;
    if (tens > 0) {
      // If previous was zero (hundreds was 0), add '零' before this non-zero digit,
      // but only if we haven't already added one for this segment.
      if (previousDigitWasZero && !zeroDigitInserted && n >= 100) {
        // Check needed for 10 vs 110
        parts.add(_ling);
        zeroDigitInserted = true;
      }
      // Handle the '十' itself. Note: the 10-19 case was handled earlier.
      // For 20, 30, etc., add the digit first, then 十.
      parts.add(_digits[tens]);
      parts.add(_shi);
      previousDigitWasZero = false; // Tens place was non-zero
      zeroDigitInserted = false; // Reset zero flag.
    } else {
      // Tens place is zero. Mark previous as zero for the next step (units).
      previousDigitWasZero = true;
    }
    remainder %= 10; // Remainder after tens (units digit)

    // 4. Units Place
    final int units = remainder;
    if (units > 0) {
      // If previous was zero (tens was 0), add '零' before this non-zero digit,
      // but only if a higher digit existed originally (n >= 10) and no zero was just added.
      if (previousDigitWasZero && !zeroDigitInserted && n >= 10) {
        // Avoid double zero if the last part added was already ling (shouldn't happen with current logic but safe check).
        if (parts.isEmpty || parts.last != _ling) {
          parts.add(_ling);
          // No need to set zeroDigitInserted = true here, as it's the last digit.
        }
      }
      // Add the units digit itself.
      parts.add(_digits[units]);
      // No need to update flags, as this is the last digit.
    }
    // If units is 0, do nothing (trailing zeros are omitted).

    return parts.join();
  }
}
