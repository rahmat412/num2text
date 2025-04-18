import 'package:decimal/decimal.dart';

import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ja_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ja}
/// The Japanese language (Lang.JA) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Japanese (日本語) word representation using Kanji numerals.
///
/// Capabilities include handling cardinal numbers, currency (using [JaOptions.currencyInfo] - defaults to JPY),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers following the Japanese
/// system of grouping by powers of ten thousand (万, 億, 兆, etc.). It also handles some common pronunciation
/// irregularities (e.g., 三百 - sanbyaku).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [JaOptions].
/// {@endtemplate}
class Num2TextJA implements Num2TextBase {
  /// The word for zero ("ゼロ"). Katakana is common, though 零 (rei) exists.
  static const String _zero = "ゼロ";

  /// The word for the decimal point (period) ("点" - ten).
  static const String _point = "点";

  /// The word for the decimal point (comma) ("コンマ" - konma, loanword).
  static const String _comma = "コンマ";

  /// The prefix added to positive years when [JaOptions.includeAD] is true ("Western Calendar" - "西暦" - seireki).
  static const String _yearPrefixAD = "西暦";

  /// The prefix added to negative years ("Before Common Era" - "紀元前" - kigenzen).
  static const String _yearPrefixBC = "紀元前";

  /// The suffix added to years ("年" - nen).
  static const String _yearSuffix = "年";

  /// The currency unit (Yen - "円" - en).
  static const String _currencyUnit = "円";

  /// Japanese digits 0-9 using Kanji numerals.
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
  // Pronunciation guide: rei, ichi, ni, san, yon(shi), go, roku, nana(shichi), hachi, kyuu(ku)

  /// The word for ten ("十" - juu).
  static const String _ten = "十";

  /// The word for hundred ("百" - hyaku).
  static const String _hundred = "百";

  /// The word for thousand ("千" - sen).
  static const String _thousand = "千";

  /// Scale units for large numbers, starting from 10^4 (万).
  /// Index corresponds to power of 10000: 0="", 1="万", 2="億", 3="兆", ...
  static const List<String> _largeScaleUnits = [
    "", // 10000^0 (Units up to 9999)
    "万", // 10000^1 = 10^4 (man)
    "億", // 10000^2 = 10^8 (oku)
    "兆", // 10000^3 = 10^12 (chou)
    "京", // 10000^4 = 10^16 (kei)
    "垓", // 10000^5 = 10^20 (gai)
    "秭", // 10000^6 = 10^24 (shi/jo) - Note: Higher scales exist but are less common.
  ];

  /// Pronunciation variants for hundreds (e.g., 300 is sanbyaku, not sanhyaku).
  /// Maps the digit character to the full pronunciation.
  static const Map<String, String> _hundredPronunciation = {
    "三": "三百", // sanbyaku
    "六": "六百", // roppyaku
    "八": "八百", // happyaku
  };

  /// Pronunciation variants for thousands (e.g., 3000 is sanzen, not sansen).
  /// Maps the digit character to the full pronunciation.
  static const Map<String, String> _thousandPronunciation = {
    "三": "三千", // sanzen
    "八": "八千", // hassen
  };

  /// Converts a number to its Japanese cardinal word representation.
  ///
  /// Delegates the conversion process to helper methods based on the provided [options].
  /// Supports various numeric types, special double values (NaN, infinity), and formatting options
  /// like currency, year, and decimal separators.
  ///
  /// - [number] The number to convert (can be `int`, `double`, `BigInt`, `Decimal`, `String`).
  /// - [options] Optional [JaOptions] to customize formatting. Defaults are used if null or not [JaOptions].
  /// - [fallbackOnError] The string to return if conversion fails (e.g., invalid input).
  ///                      Defaults to '非数' (hisū - non-number) if not provided.
  ///
  /// Returns the Japanese word representation of the number, or [fallbackOnError] or a default Japanese error message if conversion fails.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final JaOptions jaOptions =
        options is JaOptions ? options : const JaOptions();
    final String errorFallback =
        fallbackOnError ?? "非数"; // Default "Non-number"

    // Handle special double values first
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? "負の無限大"
            : "無限大"; // Negative/Positive Infinity
      }
      if (number.isNaN) {
        return errorFallback;
      }
    }

    // Normalize the input number to Decimal
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Handle null or unparseable input
    if (decimalValue == null) {
      return errorFallback;
    }

    // Handle zero separately
    if (decimalValue == Decimal.zero) {
      if (jaOptions.currency) {
        return "$_zero$_currencyUnit"; // ゼロ円
      } else if (jaOptions.format == Format.year) {
        // Though year 0 is debated historically, provide a representation
        return "$_zero$_yearSuffix"; // ゼロ年
      } else {
        return _zero; // ゼロ
      }
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for the main conversion logic
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Branch based on formatting options
    if (jaOptions.format == Format.year) {
      // Year formatting requires integer part only
      textResult = _handleYearFormat(
          absValue.truncate().toBigInt(), jaOptions, isNegative);
    } else {
      // Handle currency or standard number format
      if (jaOptions.currency) {
        textResult = _handleCurrency(absValue, jaOptions);
      } else {
        textResult = _handleStandardNumber(absValue, jaOptions);
      }

      // Add negative prefix if necessary (but not for year format)
      if (isNegative) {
        textResult = "${jaOptions.negativePrefix}$textResult";
      }
    }

    return textResult;
  }

  /// Formats a number as a year in Japanese.
  ///
  /// Handles BC/AD prefixes and the year suffix ("年").
  ///
  /// - [absYear] The absolute value of the year (non-negative BigInt).
  /// - [options] The [JaOptions] controlling the format (specifically `includeAD`).
  /// - [isNegative] Boolean indicating if the original year was negative (BC).
  ///
  /// Returns the formatted year string (e.g., "二千二十四年", "西暦二千二十四年", "紀元前百年").
  String _handleYearFormat(BigInt absYear, JaOptions options, bool isNegative) {
    // Convert the absolute year value to words
    String yearText = _convertInteger(absYear);

    if (isNegative) {
      // Add BC prefix and year suffix
      yearText = "$_yearPrefixBC$yearText$_yearSuffix"; // 紀元前...年
    } else {
      // Add optional AD prefix and year suffix
      final String prefix =
          options.includeAD ? _yearPrefixAD : ""; // 西暦 or empty
      yearText = "$prefix$yearText$_yearSuffix"; // (西暦) ... 年
    }

    return yearText;
  }

  /// Formats a number as Japanese Yen currency.
  ///
  /// Converts the integer part of the number and appends the currency unit "円".
  /// Ignores the fractional part as Yen doesn't typically use subunits in text conversion.
  ///
  /// - [absValue] The absolute value of the amount (non-negative Decimal).
  /// - [options] The [JaOptions] (currently unused here but kept for API consistency).
  ///
  /// Returns the formatted currency string (e.g., "百二十三円", "一万円").
  String _handleCurrency(Decimal absValue, JaOptions options) {
    // Convert the integer part (whole Yen)
    final BigInt mainValue = absValue.truncate().toBigInt();
    String mainText = _convertInteger(mainValue);

    // Ensure zero is represented correctly if the integer part is zero but original value wasn't exactly zero
    if (mainText.isEmpty &&
        mainValue == BigInt.zero &&
        absValue > Decimal.zero) {
      // This case is actually handled by the main zero check. If input is 0.xx, it's handled by _handleStandardNumber first.
      // If input is exactly 0, it's handled by the initial zero check.
      // If input is 123.0, mainValue is 123 and mainText is generated.
      // Let's keep the logic simple: convert integer part, append unit.
    } else if (mainValue == BigInt.zero && absValue == Decimal.zero) {
      // Handled by initial zero check
      mainText = _zero;
    } else if (mainText.isEmpty && mainValue == BigInt.zero) {
      mainText = _zero; // If the integer part is zero
    }

    // Append the currency unit
    return "$mainText$_currencyUnit"; // ...円
  }

  /// Formats a number as a standard Japanese cardinal number, potentially including decimals.
  ///
  /// - [absValue] The absolute value of the number (non-negative Decimal).
  /// - [options] The [JaOptions] controlling the decimal separator word.
  ///
  /// Returns the standard number string (e.g., "百二十三", "一点五", "百二十三点四五六").
  String _handleStandardNumber(Decimal absValue, JaOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part
    String integerWords = _convertInteger(integerPart);

    // If the number is purely fractional (e.g., 0.5), represent the zero integer part.
    if (integerPart == BigInt.zero && fractionalPart > Decimal.zero) {
      integerWords = _zero; // ゼロ
    }

    String fractionalWords = '';

    // Process the fractional part if it exists
    if (fractionalPart > Decimal.zero) {
      // Determine the decimal separator word
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _comma; // コンマ
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period:
        default: // Default to point ("点")
          separatorWord = _point; // 点
          break;
      }

      // Get the fractional digits as a string
      String fullString = absValue.toString();
      String fractionalDigits =
          fullString.contains('.') ? fullString.split('.').last : '';

      // Remove trailing zeros from the fractional part (e.g., 1.50 -> 1.5)
      fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      // Convert fractional digits to words if any remain
      if (fractionalDigits.isNotEmpty) {
        final List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          // Map digit character to Japanese digit word
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _digits[digitInt]
              : '?'; // Placeholder
        }).toList();
        // Attach digits directly after the separator (no space)
        fractionalWords = '$separatorWord${digitWords.join('')}'; // e.g., 点四五六
      }
    }

    // Handle the case where the input was exactly zero (already handled earlier, but safe check)
    if (integerWords.isEmpty &&
        fractionalWords.isEmpty &&
        integerPart == BigInt.zero) {
      return _zero; // Should technically not be reached if initial zero check is done
    }

    // Combine integer and fractional parts
    return '$integerWords$fractionalWords';
  }

  /// Converts a non-negative integer [BigInt] into Japanese words using Kanji numerals.
  ///
  /// Groups digits into 4-digit chunks (units, 万, 億, 兆, etc.) based on the Japanese number system.
  /// Converts each chunk (up to 9999) using [_convertUnder10000].
  ///
  /// - [n] The non-negative integer to convert.
  /// Returns the Japanese word representation of the integer.
  /// Returns an empty string if [n] is [BigInt.zero] (zero is typically handled by the caller).
  /// Throws [ArgumentError] if the number exceeds the supported scale units in [_largeScaleUnits].
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero)
      return ""; // Zero is handled separately or as part of decimals/currency

    // Convert chunks under 10000 directly
    if (n < BigInt.from(10000)) {
      return _convertUnder10000(n.toInt());
    }

    final List<String> parts = [];
    BigInt remaining = n;
    int scaleIndex = 0; // 0 for units, 1 for 万, 2 for 億, etc.
    final BigInt tenThousand = BigInt.from(10000);

    // Process the number in chunks of 10000
    while (remaining > BigInt.zero) {
      // Get the least significant chunk of up to 4 digits
      final BigInt chunkBigInt = remaining % tenThousand;
      remaining ~/= tenThousand; // Move to the next chunk
      final int chunk = chunkBigInt.toInt(); // Chunks are always < 10000

      if (chunk > 0) {
        // Determine the scale unit (万, 億, 兆...)
        String scaleWord = "";
        if (scaleIndex > 0) {
          // Scale unit (万, 億, 兆 etc.) is only added for chunks > 0 and scaleIndex > 0
          if (scaleIndex >= _largeScaleUnits.length) {
            // Prevent index out of bounds for very large numbers
            throw ArgumentError(
              "Number too large (exceeds defined scales: ${_largeScaleUnits.last})",
            );
          }
          scaleWord = _largeScaleUnits[scaleIndex];
        }

        // Convert the 1-9999 chunk to words.
        // Note: "一" (ichi) is typically omitted before 十, 百, 千, but *is included* before 万, 億, 兆 if the chunk is exactly 1.
        // _convertUnder10000 handles the omission within the chunk.
        String chunkWords = _convertUnder10000(chunk);

        // Add the converted chunk and its scale word to the parts list (insert at beginning for correct order)
        parts.insert(0, "$chunkWords$scaleWord");
      }
      scaleIndex++;
    }

    // Join the parts (most significant first)
    return parts.join('');
  }

  /// Converts an integer between 1 and 9999 into Japanese words using Kanji numerals.
  ///
  /// Handles thousands, hundreds, tens, and units, including pronunciation variants
  /// and omission of "一" (ichi) before 十, 百, and 千.
  ///
  /// - [n] The integer (1-9999) to convert.
  ///
  /// Returns the Japanese word representation (e.g., "百一", "千百十一", "三千", "六百").
  /// Returns an empty string if `n` is 0.
  /// Throws [ArgumentError] if `n` is not within the range [0, 9999].
  String _convertUnder10000(int n) {
    if (n == 0) return ""; // Return empty for 0 chunk
    if (n < 0 || n >= 10000) {
      throw ArgumentError(
          "Number must be between 0 and 9999 for _convertUnder10000: $n");
    }

    final List<String> words = [];
    int remainder = n;

    // Thousands place (千 - sen)
    final int thousandsDigit = remainder ~/ 1000;
    if (thousandsDigit > 0) {
      if (thousandsDigit > 1) {
        final String digit = _digits[thousandsDigit];
        // Check for pronunciation variants (三千, 八千)
        final String thousandUnit =
            _thousandPronunciation[digit] ?? (digit + _thousand);
        words.add(thousandUnit); // e.g., 二千, 三千 (sanzen)
      } else {
        words.add(_thousand); // 千 (ichi is omitted)
      }
      remainder %= 1000;
    }

    // Hundreds place (百 - hyaku)
    final int hundredsDigit = remainder ~/ 100;
    if (hundredsDigit > 0) {
      if (hundredsDigit > 1) {
        final String digit = _digits[hundredsDigit];
        // Check for pronunciation variants (三百, 六百, 八百)
        final String hundredUnit =
            _hundredPronunciation[digit] ?? (digit + _hundred);
        words.add(hundredUnit); // e.g., 二百, 三百 (sanbyaku)
      } else {
        words.add(_hundred); // 百 (ichi is omitted)
      }
      remainder %= 100;
    }

    // Tens place (十 - juu)
    final int tensDigit = remainder ~/ 10;
    if (tensDigit > 0) {
      if (tensDigit > 1) {
        // Add the digit only if > 1 (e.g., "二" for 20)
        words.add(_digits[tensDigit]);
      }
      // Always add "十"
      words.add(_ten); // e.g., 十 (juu), 二十 (nijuu)
      remainder %= 10;
    }

    // Units place (一 to 九)
    final int unitDigit = remainder;
    if (unitDigit > 0) {
      words.add(_digits[unitDigit]); // e.g., 一, 九
    }

    return words.join('');
  }
}
