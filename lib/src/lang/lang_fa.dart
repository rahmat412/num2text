import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/fa_options.dart';
import '../utils/utils.dart';

/// {@template num2text_fa}
/// The Persian (Farsi) language (`Lang.FA`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Persian word representation following standard Persian grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [FaOptions.currencyInfo],
/// typically only main units like Rial), year formatting ([Format.year]), negative numbers,
/// decimals (digit-by-digit after "ممیز"), and large numbers.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [FaOptions].
/// {@endtemplate}
class Num2TextFA implements Num2TextBase {
  /// The Persian word for zero: "صفر".
  static const String _zero = "صفر";

  /// The Persian word for the decimal point/separator: "ممیز".
  static const String _point = "ممیز";

  /// The Persian conjunction "and" used between number components: " و ".
  /// Note: Includes spaces for proper formatting.
  static const String _and = " و ";

  /// Suffix for years Before Christ (BC/BCE): "پیش از میلاد".
  static const String _yearSuffixBC = "پیش از میلاد";

  /// Suffix for years Anno Domini (AD/CE): "میلادی".
  static const String _yearSuffixAD = "میلادی";

  /// Persian words for numbers 0 through 19.
  static const List<String> _wordsUnder20 = [
    "صفر", // 0
    "یک", // 1
    "دو", // 2
    "سه", // 3
    "چهار", // 4
    "پنج", // 5
    "شش", // 6
    "هفت", // 7
    "هشت", // 8
    "نه", // 9
    "ده", // 10
    "یازده", // 11
    "دوازده", // 12
    "سیزده", // 13
    "چهارده", // 14
    "پانزده", // 15
    "شانزده", // 16
    "هفده", // 17
    "هجده", // 18
    "نوزده", // 19
  ];

  /// Persian words for tens (20, 30, ..., 90). Index corresponds to tens digit (e.g., index 2 = 20).
  static const List<String> _wordsTens = [
    "", // 0 (placeholder)
    "", // 1 (placeholder, 10 is in _wordsUnder20)
    "بیست", // 20
    "سی", // 30
    "چهل", // 40
    "پنجاه", // 50
    "شصت", // 60
    "هفتاد", // 70
    "هشتاد", // 80
    "نود", // 90
  ];

  /// Persian words for hundreds (100, 200, ..., 900). Index corresponds to hundreds digit (e.g., index 1 = 100).
  static const List<String> _wordsHundreds = [
    "", // 0 (placeholder)
    "صد", // 100
    "دویست", // 200
    "سیصد", // 300
    "چهارصد", // 400
    "پانصد", // 500
    "ششصد", // 600
    "هفتصد", // 700
    "هشتصد", // 800
    "نهصد", // 900
  ];

  /// Persian scale words (thousand, million, billion, etc.). Key is the scale index (power of 1000).
  static const Map<int, String> _scaleWords = {
    0: "", // Units place
    1: "هزار", // Thousand (10^3)
    2: "میلیون", // Million (10^6)
    3: "میلیارد", // Billion (10^9) - Note: Persian uses short scale billion
    4: "تریلیون", // Trillion (10^12)
    5: "کوادریلیون", // Quadrillion (10^15)
    6: "کوئینتیلیون", // Quintillion (10^18)
    7: "سکستیلیون", // Sextillion (10^21)
    8: "سپتیلیون", // Septillion (10^24)
    // Add more scales here if needed (e.g., Octillion, Nonillion)
  };

  /// Processes the given [number] and converts it into Persian words.
  ///
  /// {@macro num2text_process_intro}
  ///
  /// {@template num2text_fa_process_options}
  /// The [options] parameter, if provided and of type [FaOptions], allows customization:
  /// - `currency`: Formats the number as currency using [FaOptions.currencyInfo] (mainly integer part).
  /// - `format`: Applies specific formatting (e.g., [Format.year]).
  /// - `decimalSeparator`: Specifies the word for the decimal point (defaults to "ممیز").
  /// - `negativePrefix`: Sets the prefix for negative numbers (default "منفی").
  /// - `includeAD`: Adds era suffixes ("میلادی"/"پیش از میلاد") for years if `format` is [Format.year].
  /// - `round`: Rounds the number before conversion (mainly for currency).
  /// If `options` is null or not an [FaOptions] instance, default Persian options are used.
  /// {@endtemplate}
  ///
  /// {@template num2text_fa_process_errors}
  /// Handles special double values:
  /// - `double.infinity` -> "بی نهایت"
  /// - `double.negativeInfinity` -> "منفی بی نهایت"
  /// - `double.nan` -> Returns [fallbackOnError] ?? "عدد نیست".
  /// For null input or non-numeric types, returns [fallbackOnError] ?? "عدد نیست".
  /// {@endtemplate}
  ///
  /// @param number The number to convert (e.g., `123`, `45.67`, `BigInt.parse('1000000')`).
  /// @param options Optional language-specific settings ([FaOptions]).
  /// @param fallbackOnError Optional custom string to return on conversion errors.
  /// @return The Persian word representation of the number, or an error string.
  ///
  /// Example:
  /// ```dart
  /// process(123.45, null, null); // Output: صد و بیست و سه ممیز چهار پنج
  /// process(500, FaOptions(currency: true), null); // Output: پانصد ریال
  /// process(1999, FaOptions(format: Format.year, includeAD: true), null); // Output: هزار و نهصد و نود و نه میلادی
  /// ```
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have Persian-specific options, using defaults if none provided.
    final FaOptions faOptions =
        options is FaOptions ? options : const FaOptions();
    final String errorMsg =
        fallbackOnError ?? "عدد نیست"; // Default error message

    // Handle special double values first
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? "منفی بی نهایت" : "بی نهایت";
      }
      if (number.isNaN) {
        return errorMsg;
      }
    }

    // Normalize the input number to a Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // If normalization fails, return the error message.
    if (decimalValue == null) {
      return errorMsg;
    }

    // Handle zero separately.
    if (decimalValue == Decimal.zero) {
      // Special case for currency zero
      if (faOptions.currency) {
        return "$_zero ${faOptions.currencyInfo.mainUnitSingular}";
      } else {
        return _zero;
      }
    }

    // Determine sign and get the absolute value.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Handle different formatting options.
    if (faOptions.format == Format.year) {
      // Year formatting only considers the integer part.
      final BigInt yearValue = decimalValue.truncate().toBigInt();
      textResult = _handleYearFormat(yearValue, faOptions);
    } else if (faOptions.currency) {
      // Currency formatting.
      textResult = _handleCurrency(absValue, faOptions);
      // Add negative prefix if needed for currency.
      if (isNegative) {
        textResult = "${faOptions.negativePrefix} $textResult";
      }
    } else {
      // Standard number formatting (integers and decimals).
      textResult = _handleStandardNumber(absValue, faOptions);
      // Add negative prefix if needed for standard numbers.
      if (isNegative) {
        textResult = "${faOptions.negativePrefix} $textResult";
      }
    }

    // Return the final result, trimming any extra whitespace.
    return textResult.trim();
  }

  /// Formats a [yearValue] (integer) as a Persian year string.
  ///
  /// Handles BC/AD suffixes based on the sign of the year and the `includeAD` option.
  /// Years between `1000` and `1999` (inclusive) have a special format where `"یک"` is omitted
  /// before `"هزار"` (e.g., 1900 is `"هزار و نهصد"`, not `"یک هزار و نهصد"`).
  ///
  /// @param yearValue The integer year value.
  /// @param options The Persian options.
  /// @return The formatted year string.
  String _handleYearFormat(BigInt yearValue, FaOptions options) {
    final bool isNegative = yearValue.isNegative;
    final BigInt absYear = isNegative ? -yearValue : yearValue;

    if (absYear == BigInt.zero) {
      // Although unlikely for a year, handle zero case.
      return _zero;
    }

    // Convert the absolute year value to words, passing the original value
    // to handle the 1000-1999 special case.
    String yearText =
        _convertInteger(absYear, isYear: true, originalN: yearValue);

    // Append the appropriate era suffix.
    if (isNegative) {
      yearText += " $_yearSuffixBC"; // "پیش از میلاد"
    } else if (options.includeAD) {
      yearText += " $_yearSuffixAD"; // "میلادی"
    }

    return yearText;
  }

  /// Formats an absolute [absValue] as Persian currency.
  ///
  /// Uses the `currencyInfo` from the provided [options].
  /// **Note:** This implementation currently only converts the integer part
  /// and appends the main currency unit name (e.g., `"ریال"`). Subunits are ignored
  /// based on the common usage and definition for IRR.
  ///
  /// Example: `_handleCurrency(Decimal.parse("123.45"), options)` -> `"صد و بیست و سه ریال"`
  ///
  /// @param absValue The absolute decimal currency value.
  /// @param options The Persian options containing currency info.
  /// @return The formatted currency string (integer part + main unit).
  String _handleCurrency(Decimal absValue, FaOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    // Get the integer part for the main currency value.
    final BigInt mainValue = absValue.truncate().toBigInt();

    // Convert the integer part to words.
    final String mainText = _convertInteger(mainValue);
    // Get the singular main unit name (e.g., "ریال").
    final String mainUnitName = currencyInfo.mainUnitSingular;

    // Combine the number words and the currency name.
    // Example: "صد و بیست و سه ریال"
    return '$mainText $mainUnitName';
  }

  /// Formats an absolute [absValue] as a standard Persian number (integer or decimal).
  ///
  /// Handles the integer and fractional parts separately.
  /// Decimals are pronounced digit by digit after `"ممیز"`.
  /// Ignores the `decimalSeparator` option in [options] as Persian typically uses `"ممیز"`.
  /// Trims trailing zeros from the decimal part (e.g., 1.50 becomes "یک ممیز پنج").
  ///
  /// Example: `_handleStandardNumber(Decimal.parse("0.45"), options)` -> `"صفر ممیز چهار پنج"`
  ///
  /// @param absValue The absolute decimal value.
  /// @param options The Persian options.
  /// @return The formatted number string.
  String _handleStandardNumber(Decimal absValue, FaOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part. If the number is purely fractional (e.g., 0.5),
    // the integer part is "صفر".
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    // Process the fractional part if it exists.
    if (fractionalPart > Decimal.zero) {
      // Use the standard Persian decimal separator word.
      final String separatorWord = _point; // "ممیز"

      // Get the fractional digits as a string.
      String decimalString = absValue.toString();
      String fractionalDigits = "";
      final int decimalPointIndex = decimalString.indexOf('.');
      if (decimalPointIndex != -1) {
        fractionalDigits = decimalString.substring(decimalPointIndex + 1);
      }
      // Remove insignificant trailing zeros (e.g., "1.50" -> "1.5").
      while (fractionalDigits.endsWith('0') && fractionalDigits.length > 1) {
        fractionalDigits =
            fractionalDigits.substring(0, fractionalDigits.length - 1);
      }

      // If there are still digits after removing trailing zeros...
      if (fractionalDigits.isNotEmpty) {
        // Convert each digit individually to its word representation.
        final List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          // Use words 0-9 for digits. Handle potential parse errors.
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder20[digitInt]
              : '?'; // Fallback for unexpected characters
        }).toList();
        // Join the digit words with spaces after the separator word.
        // Example: ".45" -> " ممیز چهار پنج"
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }

    // Combine integer and fractional parts.
    // Example: "صد و بیست و سه ممیز چهار پنج"
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer [n] into Persian words.
  ///
  /// Uses a chunking approach, processing the number in groups of three digits (thousands).
  /// @param n The non-negative integer to convert.
  /// @param isYear Indicates if the number is being formatted as a year, triggering special
  ///        logic for `1000`-`1999` (requires [originalN] to be passed).
  /// @param originalN The original year value (including sign) needed for the `1000`-`1999` check.
  /// @throws ArgumentError if the number is too large for defined scales or input is negative.
  /// @return The integer as Persian words.
  ///
  /// Example: `_convertInteger(BigInt.from(12345))` -> `"دوازده هزار و سیصد و چهل و پنج"`
  String _convertInteger(BigInt n, {bool isYear = false, BigInt? originalN}) {
    // Base case: zero.
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) {
      // Sign should be handled before calling this.
      throw ArgumentError("Input must be non-negative for _convertInteger: $n");
    }

    // Handle numbers less than 1000 directly.
    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt());
    }

    final List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0; // 0: units, 1: thousands, 2: millions, etc.
    BigInt remaining = n;

    // Process the number in chunks of 1000.
    while (remaining > BigInt.zero) {
      // Extract the current chunk (0-999).
      final BigInt chunkBigInt = remaining % oneThousand;
      final int chunk = chunkBigInt.toInt();
      remaining ~/= oneThousand; // Move to the next chunk.

      // Only process non-zero chunks.
      if (chunk > 0) {
        String chunkText = _convertChunk(chunk); // Convert the 0-999 part.
        String scaleWord = "";
        bool isOneThousandChunk = false;

        // Determine the scale word (هزار, میلیون, etc.) if applicable.
        if (scaleIndex > 0) {
          if (!_scaleWords.containsKey(scaleIndex)) {
            // Safety check for very large numbers beyond defined scales.
            throw ArgumentError(
                "Number too large, scale index $scaleIndex not defined.");
          }
          scaleWord = _scaleWords[scaleIndex]!;
          // Check if this chunk represents exactly "one thousand".
          isOneThousandChunk = (scaleIndex == 1 && chunk == 1);
        }

        // Special case for years 1000-1999: Omit "یک" before "هزار".
        // Example: 1900 -> "هزار و نهصد" (not "یک هزار و نهصد").
        if (isYear &&
            isOneThousandChunk && // Is it the "one thousand" chunk?
            remaining == BigInt.zero && // Is it the most significant chunk?
            originalN != null && // Original year value provided?
            originalN.abs() >=
                BigInt.from(1000) && // Original year magnitude >= 1000?
            originalN.abs() < BigInt.from(2000)) {
          // Original year magnitude < 2000?
          // If all conditions met, clear the "یک" part.
          chunkText = "";
        }

        // Combine the chunk words and the scale word.
        String currentPart = chunkText;
        if (scaleWord.isNotEmpty) {
          // Add space only if chunkText is not empty (e.g., for "هزار" vs "دو هزار").
          currentPart += (currentPart.isNotEmpty ? " " : "") + scaleWord;
        }

        // Add the conjunction " و " between scale parts if needed.
        // Don't add 'و' if the current part is empty (e.g., after omitting "یک" in "هزار")
        if (parts.isNotEmpty && currentPart.isNotEmpty) {
          parts.add(_and);
        }

        // Add the processed part to the list if it's not empty.
        if (currentPart.isNotEmpty) {
          parts.add(currentPart);
        }
      }
      scaleIndex++; // Move to the next scale level.
    }

    // Reverse the parts (since we processed from lowest scale) and join them.
    // No extra space needed as _and includes spaces.
    return parts.reversed.join('');
  }

  /// Converts a number chunk (`0`-`999`) into Persian words.
  ///
  /// @param n The integer chunk (0-999) to convert.
  /// @throws ArgumentError if [n] is outside the valid range.
  /// @return The Persian word representation of the chunk.
  ///
  /// Example: `_convertChunk(345)` -> `"سیصد و چهل و پنج"`
  String _convertChunk(int n) {
    // Handle zero chunk (results in empty string).
    if (n == 0) return "";
    // Validate input range.
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999, but was: $n");
    }

    final List<String> words = [];
    int remainder = n;

    // Process hundreds place.
    final int hundredsDigit = remainder ~/ 100;
    if (hundredsDigit > 0) {
      words.add(_wordsHundreds[hundredsDigit]); // e.g., "صد", "دویست"
      remainder %= 100; // Get the remaining part (0-99).
    }

    // Process the remaining part (0-99).
    if (remainder > 0) {
      // Add " و " if hundreds were present and there's more.
      if (words.isNotEmpty) {
        words.add(_and);
      }
      // Handle numbers less than 20 directly.
      if (remainder < 20) {
        words.add(_wordsUnder20[remainder]); // e.g., "یک", "یازده"
      } else {
        // Handle numbers 20-99.
        final int tensDigit = remainder ~/ 10;
        final int unitDigit = remainder % 10;
        words.add(_wordsTens[tensDigit]); // e.g., "بیست", "سی"
        // Add units digit if present.
        if (unitDigit > 0) {
          words.add(_and); // Add " و " between tens and units.
          words.add(_wordsUnder20[unitDigit]); // e.g., "یک", "نه"
        }
      }
    }

    // Join the parts. _and already includes spaces, so direct join is fine.
    return words.join('');
  }
}
