import 'package:decimal/decimal.dart';

import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ja_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ja}
/// Converts numbers to Japanese words (`Lang.JA`) using Kanji numerals.
///
/// Implements [Num2TextBase] for Japanese (日本語). It handles various numeric
/// inputs via [process] and converts them into standard Japanese representations.
///
/// Features:
/// - Cardinal numbers using Kanji numerals (一, 二, 三...).
/// - Currency formatting (defaulting to Yen 円). Customizable via [JaOptions].
/// - Year formatting (年 suffix, optional 西暦/紀元前 prefixes).
/// - Negative numbers (using configurable prefix, default "マイナス").
/// - Decimals (using 点 or コンマ).
/// - Large numbers grouped by powers of 10,000 (万, 億, 兆...).
/// - Handles common pronunciation irregularities (e.g., 三百 - sanbyaku).
///
/// Returns a fallback string on error. Behavior customizable via [JaOptions].
/// {@endtemplate}
class Num2TextJA implements Num2TextBase {
  // --- Constants ---

  /// Zero ("ゼロ"). Katakana is common. 零 (rei) also exists but is less frequent in casual number reading.
  static const String _zero = "ゼロ";

  /// Decimal point separator ("点" - ten).
  static const String _point = "点";

  /// Alternative decimal separator ("コンマ" - konma, loanword).
  static const String _comma = "コンマ";

  /// Prefix for positive years if `includeAD` is true ("Western Calendar" - "西暦" - seireki).
  static const String _yearPrefixAD = "西暦";

  /// Prefix for negative years ("Before Common Era" - "紀元前" - kigenzen).
  static const String _yearPrefixBC = "紀元前";

  /// Suffix for years ("年" - nen).
  static const String _yearSuffix = "年";

  /// Default currency unit (Yen - "円" - en).
  static const String _currencyUnit =
      "円"; // Usually defined in CurrencyInfo, but hardcoded here.

  /// Kanji numerals for digits 0-9.
  static const List<String> _digits = [
    "零",
    "一",
    "二",
    "三",
    "四",
    "五",
    "六",
    "七",
    "八",
    "九"
  ];
  // Pronunciation guide: 0:rei, 1:ichi, 2:ni, 3:san, 4:yon/shi, 5:go, 6:roku, 7:nana/shichi, 8:hachi, 9:kyuu/ku

  /// Ten ("十" - juu).
  static const String _ten = "十";

  /// Hundred ("百" - hyaku).
  static const String _hundred = "百";

  /// Thousand ("千" - sen).
  static const String _thousand = "千";

  /// Scale units for large numbers (powers of 10,000). Index is power.
  static const List<String> _largeScaleUnits = [
    "", // 10^0  (Units up to 9999)
    "万", // 10^4  (man)
    "億", // 10^8  (oku)
    "兆", // 10^12 (chou)
    "京", // 10^16 (kei)
    "垓", // 10^20 (gai)
    "秭", // 10^24 (shi/jo) - Note: Pronunciation can vary.
    "穣", // 10^28 (jō)
    // Further units exist but become increasingly rare: 溝 (kō), 澗 (kan), 正 (sei)...
  ];

  /// Pronunciation variants for hundreds (e.g., 300 = 三百 sanbyaku). Maps digit character to full Kanji representation.
  static const Map<String, String> _hundredPronunciation = {
    "三": "三百", // sanbyaku (not sanhyaku)
    "六": "六百", // roppyaku (not rokuhyaku)
    "八": "八百", // happyaku (not hachihyaku)
  };

  /// Pronunciation variants for thousands (e.g., 3000 = 三千 sanzen). Maps digit character to full Kanji representation.
  static const Map<String, String> _thousandPronunciation = {
    "三": "三千", // sanzen (not sansen)
    "八": "八千", // hassen (not hachisen)
  };

  /// Processes the given [number] into its Japanese word representation using Kanji.
  ///
  /// {@template num2text_process_intro}
  /// Handles `int`, `double`, `BigInt`, `Decimal`, `String`. Normalizes to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [JaOptions] for customization (currency, year format, decimals, AD/BC).
  /// Defaults apply if [options] is null or not [JaOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity` (無限大), `NaN`. Returns [fallbackOnError] or "非数" (hisū) on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [JaOptions] settings.
  /// @param fallbackOnError Optional error string. Default: "非数".
  /// @return The number as Japanese Kanji words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final JaOptions jaOptions =
        options is JaOptions ? options : const JaOptions();
    final String errorFallback =
        fallbackOnError ?? "非数"; // Default "Non-number"

    // Handle special double values.
    if (number is double) {
      if (number.isInfinite) return number.isNegative ? "負の無限大" : "無限大";
      if (number.isNaN) return errorFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    // Handle zero based on context.
    if (decimalValue == Decimal.zero) {
      if (jaOptions.currency) return "$_zero$_currencyUnit"; // ゼロ円
      if (jaOptions.format == Format.year) return "$_zero$_yearSuffix"; // ゼロ年
      return _zero; // ゼロ
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Dispatch based on format options.
    if (jaOptions.format == Format.year) {
      // Year conversion uses the integer part. Sign handled within the method.
      textResult = _handleYearFormat(
          absValue.truncate().toBigInt(), jaOptions, isNegative);
    } else {
      // Handle currency or standard number.
      textResult = jaOptions.currency
          ? _handleCurrency(absValue, jaOptions)
          : _handleStandardNumber(absValue, jaOptions);
      // Prepend negative prefix if needed (handled separately from year prefixes).
      if (isNegative) {
        textResult = "${jaOptions.negativePrefix}$textResult";
      }
    }

    return textResult; // No trimming needed as Japanese doesn't use spaces.
  }

  /// Converts a standard (non-currency, non-year) decimal number to Japanese Kanji words.
  ///
  /// Handles integer and fractional parts, using the specified decimal separator.
  /// Uses "〇" (maru) for zero digits after the decimal point.
  ///
  /// @param absValue The absolute decimal value.
  /// @param options Formatting options (specifically `decimalSeparator`).
  /// @return Number as Japanese Kanji words.
  String _handleStandardNumber(Decimal absValue, JaOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part, handling case where it's zero but fraction exists (e.g., 0.5).
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero // Use Katakana "ゼロ" for 0 before decimal point
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _comma;
          break;
        default:
          separatorWord = _point;
          break; // Default to "点"
      }

      // Extract fractional digits.
      String fullString = absValue.toString();
      String fractionalDigits =
          fullString.contains('.') ? fullString.split('.').last : '';
      // Remove trailing zeros as they are usually not read out.
      fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      if (fractionalDigits.isNotEmpty) {
        // Convert each digit after the decimal point.
        final List<String> digitWords = fractionalDigits.split('').map((digit) {
          if (digit == '0') {
            // Use "〇" (maru) for zero after decimal point, common practice.
            // "零" (rei) is also possible but less common here.
            return "〇";
          }
          final int? digitInt = int.tryParse(digit);
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _digits[digitInt]
              : '?';
        }).toList();
        // Combine separator and digits. No spaces in Japanese.
        fractionalWords = '$separatorWord${digitWords.join('')}';
      }
    }

    // Handle the case where the input was exactly zero (already handled in `process`).
    // This check handles potential scenarios if called directly, ensuring "ゼロ" is returned.
    if (integerWords.isEmpty &&
        fractionalWords.isEmpty &&
        integerPart == BigInt.zero) {
      return _zero;
    }

    // Combine integer and fractional parts. No spaces.
    return '$integerWords$fractionalWords';
  }

  /// Converts a non-negative integer ([BigInt]) into Japanese Kanji words.
  ///
  /// Uses a chunking algorithm based on powers of 10,000 (万, 億, 兆...).
  /// Delegates chunks of 0-9999 to [_convertUnder10000].
  ///
  /// @param n The non-negative integer to convert.
  /// @throws ArgumentError if [n] is negative or exceeds defined scales.
  /// @return The integer as Japanese Kanji words, or empty string if n is 0.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero)
      return ""; // Zero is handled by caller or returns empty within larger numbers.

    // Handle numbers less than 10,000 directly.
    if (n < BigInt.from(10000)) {
      return _convertUnder10000(n.toInt());
    }

    // Determine the largest scale unit needed.
    int maxScaleIndex = 0;
    BigInt powerOf10k = BigInt.one;
    // Find the highest power of 10000 that fits into n.
    while (powerOf10k <= n ~/ BigInt.from(10000)) {
      powerOf10k *= BigInt.from(10000);
      maxScaleIndex++;
    }

    if (maxScaleIndex >= _largeScaleUnits.length) {
      throw ArgumentError(
          "Number too large (exceeds defined scales: ${_largeScaleUnits.last})");
    }

    List<String> parts = []; // Stores Kanji parts for each scale.
    BigInt remainingN = n;

    // Iterate from the largest scale down to units.
    for (int i = maxScaleIndex; i >= 0; i--) {
      // Calculate the divisor for the current scale (10000^i).
      BigInt divisor = BigInt.from(10000).pow(i);
      // Get the chunk value for this scale (0-9999).
      BigInt chunk = remainingN ~/ divisor;

      if (chunk > BigInt.zero) {
        // Convert the 0-9999 chunk to Kanji.
        String chunkWords = _convertUnder10000(chunk.toInt());
        // Get the scale word (万, 億, etc.). Empty for units (i=0).
        String scaleWord = (i > 0) ? _largeScaleUnits[i] : "";
        // Combine chunk and scale word (e.g., "千二百三十四万").
        parts.add("$chunkWords$scaleWord");
        // Update the remainder for the next smaller scale.
        remainingN %= divisor;
      }
    }
    // Join all parts together (no spaces).
    return parts.join('');
  }

  /// Converts an integer between 0 and 9999 into Japanese Kanji words.
  ///
  /// Handles thousands, hundreds, tens, and units place values.
  /// Omits '一' (ichi) before 十, 百, 千 unless it's the only digit.
  /// Applies pronunciation rules for 百 and 千.
  ///
  /// @param n The integer chunk (0-9999).
  /// @throws ArgumentError if n is outside the 0-9999 range.
  /// @return The chunk as Japanese Kanji words, or empty string if n is 0.
  String _convertUnder10000(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 10000) {
      throw ArgumentError(
          "Number must be between 0 and 9999 for _convertUnder10000: $n");
    }

    final StringBuffer words = StringBuffer();
    int remainder = n;

    // --- Thousands place (千 sen) ---
    final int thousandsDigit = remainder ~/ 1000;
    if (thousandsDigit > 0) {
      if (thousandsDigit > 1) {
        // Handle pronunciation variants (e.g., 三千 sanzen, 八千 hassen).
        final String digitKanji = _digits[thousandsDigit];
        words.write(
            _thousandPronunciation[digitKanji] ?? (digitKanji + _thousand));
      } else {
        // For 1000, just write 千 (sen), not 一千 (issen).
        words.write(_thousand);
      }
      remainder %= 1000;
    }

    // --- Hundreds place (百 hyaku) ---
    final int hundredsDigit = remainder ~/ 100;
    if (hundredsDigit > 0) {
      if (hundredsDigit > 1) {
        // Handle pronunciation variants (e.g., 三百 sanbyaku, 六百 roppyaku).
        final String digitKanji = _digits[hundredsDigit];
        words.write(
            _hundredPronunciation[digitKanji] ?? (digitKanji + _hundred));
      } else {
        // For 100, just write 百 (hyaku), not 一百 (ippyaku).
        words.write(_hundred);
      }
      remainder %= 100;
    }

    // --- Tens place (十 juu) ---
    final int tensDigit = remainder ~/ 10;
    if (tensDigit > 0) {
      if (tensDigit > 1) {
        // Write the digit (e.g., 二 for 20) before 十.
        words.write(_digits[tensDigit]);
      }
      // Write 十 (juu). For 10, this is the only character needed (no preceding 一).
      words.write(_ten);
      remainder %= 10;
    }

    // --- Units place (一 ichi to 九 kyuu) ---
    final int unitDigit = remainder;
    if (unitDigit > 0) {
      words.write(_digits[unitDigit]);
    }

    return words.toString();
  }

  /// Formats a number as a year in Japanese (e.g., "二千二十四年").
  ///
  /// Appends the year suffix "年" (nen).
  /// Optionally prepends "西暦" (seireki - AD) or "紀元前" (kigenzen - BC).
  ///
  /// @param absYear The absolute value of the year (non-negative BigInt).
  /// @param options The [JaOptions] controlling AD/BC inclusion.
  /// @param isNegative True if the original year was negative (BC).
  /// @return The formatted year string.
  String _handleYearFormat(BigInt absYear, JaOptions options, bool isNegative) {
    // Convert the absolute year value to Kanji words.
    String yearText = _convertInteger(absYear);

    if (isNegative) {
      // Format as BC: 紀元前...年 (Kigenzen ... nen).
      yearText = "$_yearPrefixBC$yearText$_yearSuffix";
    } else {
      // Format as AD/CE: (西暦)...年 ([Seireki] ... nen).
      final String prefix = options.includeAD ? _yearPrefixAD : "";
      yearText = "$prefix$yearText$_yearSuffix";
    }

    return yearText;
  }

  /// Formats a number as Japanese Yen currency (e.g., "百二十三円").
  ///
  /// Converts the integer part and appends "円" (en).
  /// Ignores the fractional part (Yen typically isn't written with subunits like sen).
  ///
  /// @param absValue The absolute value of the amount (non-negative Decimal).
  /// @param options The [JaOptions] (currently unused but kept for API consistency).
  /// @return The formatted currency string.
  String _handleCurrency(Decimal absValue, JaOptions options) {
    // Currency conversion typically uses only the integer part for Yen.
    final BigInt mainValue = absValue.truncate().toBigInt();
    String mainText;

    if (mainValue == BigInt.zero) {
      // Use Katakana zero for currency amount zero.
      mainText = _zero;
    } else {
      mainText = _convertInteger(mainValue);
    }

    // Append the currency unit.
    return "$mainText$_currencyUnit";
  }
}
