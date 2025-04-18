import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart'; // Dependency for currency data
import '../num2text_base.dart'; // Base class interface
import '../options/base_options.dart'; // Base options & enums
import '../options/hy_options.dart'; // Language-specific options
import '../utils/utils.dart'; // Utilities like normalizeNumber

/// {@template num2text_hy}
/// The Armenian language (`Lang.HY`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Armenian word representation following Armenian grammar rules and conventions.
///
/// Capabilities include handling cardinal numbers, currency (using [HyOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (short scale up to Septillion).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [HyOptions].
/// {@endtemplate}
class Num2TextHY implements Num2TextBase {
  // --- Linguistic Constants ---

  /// Armenian word for "zero".
  static const String _zero = "զրո";

  /// Armenian word for decimal separator when using a comma separator (default).
  /// Translates to "comma".
  static const String _pointComma = "ստորակետ";

  /// Armenian word for decimal separator when using a period/point separator.
  /// Translates to "point" or "dot".
  static const String _pointPeriod = "կետ";

  /// Armenian word for "hundred".
  static const String _hundred = "հարյուր";

  /// Armenian word for "thousand".
  static const String _thousand = "հազար";

  /// Armenian word for "million".
  static const String _million = "միլիոն";

  /// Armenian word for "billion".
  static const String _billion = "միլիարդ";

  /// Armenian word for "trillion".
  static const String _trillion = "տրիլիոն";

  /// Armenian word for "quadrillion".
  static const String _quadrillion = "կվադրիլիոն";

  /// Armenian word for "quintillion".
  static const String _quintillion = "կվինտիլիոն";

  /// Armenian word for "sextillion".
  static const String _sextillion = "սեքստիլիոն";

  /// Armenian word for "septillion".
  static const String _septillion = "սեպտիլիոն";

  /// Armenian suffix for AD/CE years ("թ."). Stands for թվական (t’vakan - year).
  /// Used only when `HyOptions.includeEra` is `true` for positive years.
  static const String _yearSuffixAD = "թ.";

  /// Armenian suffix for BC/BCE years ("մ.թ.ա."). Stands for մեր թվարկությունից առաջ
  /// (mer t’varkut’yunits’ arraj - before our era). Automatically appended to negative years
  /// when `HyOptions.format` is `Format.year`.
  static const String _yearSuffixBC = "մ.թ.ա.";

  /// Armenian separator word ("և" - yev) used between main and subunit currency amounts.
  /// Defined in [CurrencyInfo.amd] and used when `HyOptions.currency` is `true`.
  static const String _currencySeparator = "և";

  /// Armenian words for numbers 0 through 19. Used as building blocks.
  static const List<String> _wordsUnder20 = [
    "զրո", "մեկ", "երկու", "երեք", "չորս", "հինգ", "վեց", "յոթ", "ութ",
    "ինը", // 0-9
    "տասը", "տասնմեկ", "տասներկու", "տասներեք", "տասնչորս", "տասնհինգ", // 10-15
    "տասնվեց", "տասնյոթ", "տասնութ", "տասնինը", // 16-19
  ];

  /// Armenian words for tens (20, 30, ..., 90). Index corresponds to the tens digit (e.g., index 2 = 20).
  static const List<String> _wordsTens = [
    "", // 0 (placeholder)
    "", // 10 (handled by _wordsUnder20)
    "քսան", // 20
    "երեսուն", // 30
    "քառասուն", // 40
    "հիսուն", // 50
    "վաթսուն", // 60
    "յոթանասուն", // 70
    "ութսուն", // 80
    "իննսուն", // 90
  ];

  /// Armenian scale words (thousand, million, billion, etc.). Index corresponds to the power of 1000.
  /// `_scaleWords[0]` is empty, `_scaleWords[1]` is "thousand", `_scaleWords[2]` is "million", etc.
  static const List<String> _scaleWords = [
    "", // 1000^0 (Units place)
    _thousand, // 1000^1
    _million, // 1000^2
    _billion, // 1000^3
    _trillion, // 1000^4
    _quadrillion, // 1000^5
    _quintillion, // 1000^6
    _sextillion, // 1000^7
    _septillion, // 1000^8
  ];

  /// Processes the given [number] and converts it into its Armenian word representation.
  ///
  /// This is the main entry point for the Armenian conversion logic.
  ///
  /// [number] The number to convert. Can be an `int`, `double`, `BigInt`, `Decimal`,
  ///   or a `String` representation of a number.
  /// [options] An optional [BaseOptions] object. If it's an instance of [HyOptions],
  ///   language-specific settings like currency format (`currency`), year format (`format`),
  ///   era inclusion (`includeEra`), negative prefix (`negativePrefix`), and decimal
  ///   separator (`decimalSeparator`) are applied. If `null` or not `HyOptions`,
  ///   default [HyOptions] are used.
  /// [fallbackOnError] A custom string to return if the input [number] is invalid
  ///   (e.g., `null`, `NaN`, non-numeric string). If `null`, a default Armenian
  ///   error message ("Թիվ չէ") is used.
  ///
  /// Returns the number represented in Armenian words according to the specified options,
  /// or the fallback string if an error occurs during processing or validation.
  /// Handles special numeric values like `infinity` and `NaN`.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure correct options type or use defaults for Armenian.
    final HyOptions hyOptions =
        options is HyOptions ? options : const HyOptions();
    // Define the default fallback error message for Armenian.
    const String defaultFallback = "Թիվ չէ"; // "Not a number"

    // Handle special double values directly for clearer error messages.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? "Բացասական անվերջություն"
            : "Անվերջություն"; // "Negative Infinity", "Infinity"
      }
      if (number.isNaN) {
        return fallbackOnError ?? defaultFallback;
      }
    }

    // Normalize the input number to Decimal for consistent precision and handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // If normalization fails (invalid input), return the fallback string.
    if (decimalValue == null) {
      return fallbackOnError ?? defaultFallback;
    }

    // Handle the special case of zero.
    if (decimalValue == Decimal.zero) {
      // Return "zero dram" if currency format is requested.
      if (hyOptions.currency) {
        return "$_zero ${hyOptions.currencyInfo.mainUnitSingular}";
      }
      // Otherwise, just return "zero".
      return _zero;
    }

    // Determine if the number is negative and get its absolute value for conversion.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Delegate to specific handlers based on the format option.
    if (hyOptions.format == Format.year) {
      // Year formatting requires the integer part of the number. Negativity handled internally.
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), hyOptions);
    } else {
      // Handle currency or standard number formats for the absolute value.
      if (hyOptions.currency) {
        textResult = _handleCurrency(absValue, hyOptions);
      } else {
        textResult = _handleStandardNumber(absValue, hyOptions);
      }
      // Prepend the negative prefix if the original number was negative for non-year formats.
      if (isNegative) {
        textResult = "${hyOptions.negativePrefix} $textResult";
      }
    }

    return textResult.trim(); // Ensure no trailing spaces.
  }

  /// Formats an integer as an Armenian year, handling BC/AD suffixes.
  ///
  /// [year] The integer representing the year (can be negative for BC/BCE).
  /// [options] The [HyOptions] containing formatting rules, specifically `includeEra`.
  ///
  /// Converts the absolute value of the year to words.
  /// Appends the BC suffix ("մ.թ.ա.") if the year is negative.
  /// Appends the AD suffix ("թ.") if the year is positive AND `options.includeEra` is true.
  /// Returns the formatted year string.
  String _handleYearFormat(int year, HyOptions options) {
    final bool isNegative = year < 0;
    // Use absolute value for word conversion.
    final int absYear = isNegative ? -year : year;

    // Handle year 0 input.
    if (absYear == 0) return _zero;

    // Convert the absolute year value to words using the integer converter.
    final String yearText = _convertInteger(BigInt.from(absYear));

    // Append suffixes based on the sign and options.
    if (isNegative) {
      // Negative years always get the BC suffix, regardless of includeEra.
      return "$yearText $_yearSuffixBC";
    } else if (options.includeEra) {
      // Positive years get the AD suffix *only* if includeEra is explicitly true.
      return "$yearText $_yearSuffixAD";
    } else {
      // Positive years have no suffix by default.
      return yearText;
    }
  }

  /// Formats a positive [Decimal] value as an Armenian currency amount (e.g., Dram and Luma).
  ///
  /// [absValue] The absolute (non-negative) decimal value of the currency amount.
  /// [options] The [HyOptions] containing currency information (`currencyInfo`).
  ///
  /// Separates the value into main units (integer part) and subunits (fractional part).
  /// Converts both parts to words. Rounds the subunit value to the nearest whole number.
  /// Combines the parts using the currency names and separator specified in `options.currencyInfo`.
  /// Example: 123.45 -> "հարյուր քսաներեք դրամ և քառասունհինգ լումա".
  /// Returns the currency amount in Armenian words.
  String _handleCurrency(Decimal absValue, HyOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    // Armenian Dram (AMD) typically has 100 luma.
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Separate main unit (integer part) and fractional part.
    final BigInt mainValue = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Calculate and round the subunit value (e.g., luma). Rounding is typical for currency.
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round().toBigInt();

    // Convert the main value to words and get the main unit name.
    // Note: Armenian currency format generally uses the singular form for the main unit after the number.
    final String mainText = _convertInteger(mainValue);
    final String mainUnitName = currencyInfo.mainUnitSingular;
    String result = '$mainText $mainUnitName';

    // If there's a non-zero subunit value, convert and append it.
    if (subunitValue > BigInt.zero) {
      final String subunitText = _convertInteger(subunitValue);
      // Use singular subunit name, default to empty string if not defined.
      final String subUnitName = currencyInfo.subUnitSingular ?? '';
      // Use the currency-specific separator or the default Armenian one ("և").
      final String separator = currencyInfo.separator ?? _currencySeparator;
      // Combine main part, separator, and subunit part.
      result += ' $separator $subunitText $subUnitName';
    }

    return result;
  }

  /// Formats a positive [Decimal] value as a standard Armenian number, including decimals.
  ///
  /// [absValue] The absolute (non-negative) decimal value to convert.
  /// [options] The [HyOptions] specifying the decimal separator word (`decimalSeparator`).
  ///
  /// Converts the integer and fractional parts separately.
  /// Uses the appropriate decimal separator word ("ստորակետ" for comma, "կետ" for period/point)
  /// based on `options.decimalSeparator`. Defaults to "ստորակետ".
  /// Fractional digits are converted individually (e.g., 0.45 -> "չորս հինգ").
  /// Trims trailing zeros from the fractional part (e.g., 1.50 -> "մեկ ստորակետ հինգ").
  /// Returns the number in Armenian words.
  String _handleStandardNumber(Decimal absValue, HyOptions options) {
    // Separate integer and fractional parts.
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part. Handle the case where integer is 0 but fraction exists (e.g., 0.5).
    String integerWords = (integerPart == BigInt.zero &&
            fractionalPart > Decimal.zero)
        ? _zero // Output "zero" before the decimal part (e.g., "zero point five").
        : _convertInteger(integerPart);

    String fractionalWords = '';
    // Process fractional part only if it's greater than zero.
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word based on options, defaulting to comma ("ստորակետ").
      String separatorWord;
      switch (options.decimalSeparator ?? DecimalSeparator.comma) {
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          separatorWord = _pointPeriod; // "կետ"
          break;
        case DecimalSeparator.comma:
          separatorWord = _pointComma; // "ստորակետ"
          break;
      }

      // Get fractional digits as a string. Use toString() for potentially variable precision.
      String fractionalString = absValue.toString();
      // Extract digits after the decimal point.
      String fractionalDigits =
          fractionalString.substring(fractionalString.indexOf('.') + 1);

      // Trim trailing zeros for correct standard representation (e.g., 1.50 -> 1.5 -> "հինգ").
      fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      // Convert each remaining fractional digit to its word representation.
      if (fractionalDigits.isNotEmpty) {
        final List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int digitInt = int.parse(digit);
          // Ensure digit is within the valid range for _wordsUnder20.
          return (digitInt >= 0 && digitInt < _wordsUnder20.length)
              ? _wordsUnder20[digitInt]
              : '?'; // Use '?' for unexpected non-digit characters.
        }).toList();
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
      // If fractionalDigits is empty after trimming (e.g. 123.0), fractionalWords remains empty.
    }

    // Combine integer and fractional parts (if any) and trim potential whitespace.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] integer into Armenian words.
  ///
  /// [n] The non-negative integer to convert.
  ///
  /// Handles numbers from zero up to the maximum supported scale (septillion).
  /// Breaks the number into chunks of 1000 (e.g., 1,234,567 -> 567, 234, 1).
  /// Converts each chunk using `_convertChunk` and applies the appropriate scale word
  /// (thousand, million, etc.) from `_scaleWords`.
  /// Handles the special Armenian case where "one thousand" is "հազար", not "մեկ հազար".
  /// Throws [ArgumentError] if the number is negative or exceeds the supported scale limit.
  /// Returns the integer represented in Armenian words.
  String _convertInteger(BigInt n) {
    // Ensure input is non-negative as negativity is handled before calling this.
    if (n < BigInt.zero) {
      throw ArgumentError(
          "Internal error: _convertInteger received negative number: $n");
    }
    if (n == BigInt.zero) return _zero;

    // Optimization: Check for exact scale values (e.g., 1000 -> "հազար", 1_000_000 -> "միլիոն").
    // Start from largest scale downwards.
    if (n >= BigInt.from(1000)) {
      for (int i = _scaleWords.length - 1; i >= 1; i--) {
        final BigInt scaleValue = BigInt.from(1000).pow(i);
        if (n == scaleValue) {
          return _scaleWords[i];
        }
      }
    }

    final List<String> parts = []; // Stores word parts for each scale chunk.
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0; // Index into _scaleWords (0 = none, 1 = thousand, etc.)
    BigInt remaining = n; // The part of the number yet to be processed.

    // Process the number in chunks of three digits (0-999) from right to left.
    while (remaining > BigInt.zero) {
      // Check if the number exceeds the maximum supported scale.
      if (scaleIndex >= _scaleWords.length) {
        throw ArgumentError(
          "Number too large to convert: $n. Exceeds maximum scale (${_scaleWords.last}).",
        );
      }

      // Get the current chunk (0-999).
      final BigInt chunkBigInt = remaining % oneThousand;
      // Safe conversion as chunk is guaranteed to be <= 999.
      final int chunk = chunkBigInt.toInt();
      // Prepare for the next iteration (integer division).
      remaining ~/= oneThousand;

      // Convert the chunk to words if it's non-zero.
      if (chunk > 0) {
        final String chunkText = _convertChunk(chunk);
        final String scaleWord = _scaleWords[scaleIndex];

        // Append the scale word if applicable (i.e., not the base chunk, scaleIndex > 0).
        if (scaleWord.isNotEmpty) {
          // Special Armenian case: 1000 is "հազար", 1_000_000 is "միլիոն", etc.
          // If the chunk is exactly 1 and it's a scale chunk (scaleIndex > 0),
          // use only the scale word.
          if (chunk == 1 && scaleIndex > 0) {
            parts.add(scaleWord);
          } else {
            // Standard case: Append scale word after chunk text (e.g., "երկու հազար").
            parts.add("$chunkText $scaleWord");
          }
        } else {
          // Base chunk (0-999) has no scale word, just add its text.
          parts.add(chunkText);
        }
      }
      // Move to the next scale level (thousand, million, etc.).
      scaleIndex++;
    }

    // Join the parts in reverse order (highest scale first) with spaces and trim.
    return parts.reversed.join(' ').trim();
  }

  /// Converts a number chunk (an integer between 0 and 999) into Armenian words.
  ///
  /// [n] The integer chunk (must be between 0 and 999 inclusive).
  ///
  /// Handles hundreds, tens, and units within the chunk according to Armenian rules.
  /// Uses `_wordsUnder20`, `_wordsTens`, `_hundred`, and `_fuseTensUnits`.
  /// Throws [ArgumentError] if the input is outside the valid range [0, 999].
  /// Returns the chunk represented in Armenian words, or an empty string if [n] is 0.
  String _convertChunk(int n) {
    // Return empty string for zero chunk (avoids extra spaces when joining parts).
    if (n == 0) return "";
    // Validate input range.
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999 inclusive: $n");
    }

    final List<String> words = []; // Stores parts like ["հարյուր", "քսանմեկ"]
    int remainder = n;

    // --- Handle hundreds place ---
    if (remainder >= 100) {
      final int hundredDigit = remainder ~/ 100;
      // Special case for 100 ("հարյուր") vs 200+ ("երկու հարյուր", etc.).
      if (hundredDigit == 1) {
        words.add(_hundred);
      } else {
        // Add the digit word (e.g., "երկու") before "hundred".
        words.add(_wordsUnder20[hundredDigit]);
        words.add(_hundred);
      }
      remainder %= 100; // Get the remaining tens and units (0-99).
    }

    // --- Handle tens and units place ---
    if (remainder > 0) {
      if (remainder < 20) {
        // Numbers 1-19 are directly from the list _wordsUnder20.
        words.add(_wordsUnder20[remainder]);
      } else {
        // Numbers 20-99 require combining tens and units words.
        final int tensDigit = remainder ~/ 10;
        final int unitDigit = remainder % 10;
        // Delegate to _fuseTensUnits for specific Armenian compound number rules (e.g., "քսանմեկ").
        words.add(_fuseTensUnits(tensDigit, unitDigit));
      }
    }

    // Join the parts (e.g., "հարյուր", "քսան", "մեկ") with spaces.
    return words.join(' ');
  }

  /// Combines tens and units digits (for numbers 20-99) into specific Armenian words.
  ///
  /// [tensDigit] The tens digit (must be 2-9).
  /// [unitDigit] The units digit (must be 0-9).
  ///
  /// Applies specific Armenian combination rules where the standard pattern
  /// (tens word + units word) is modified or concatenated directly. For example:
  /// - 20 + 1 -> "քսանմեկ" (not "քսան մեկ")
  /// - 30 + 1 -> "երեսունմեկ"
  /// - 90 + 9 -> "իննսունինը"
  /// - 32 -> "երեսուներկու" (concatenated)
  /// Returns the combined word representation for the number [tensDigit * 10 + unitDigit].
  String _fuseTensUnits(int tensDigit, int unitDigit) {
    // If unit is zero, just return the tens word (e.g., "քսան" for 20).
    if (unitDigit == 0) {
      // Ensure tensDigit is within the valid range for _wordsTens.
      return (tensDigit >= 2 && tensDigit < _wordsTens.length)
          ? _wordsTens[tensDigit]
          : '';
    }

    // Safeguard: This function should only be called for tensDigit >= 2.
    if (tensDigit < 2 || tensDigit >= _wordsTens.length) {
      // This indicates an internal logic error if hit.
      // Fallback to _wordsUnder20 if possible as a very rough approximation.
      final int value = tensDigit * 10 + unitDigit;
      return (value >= 0 && value < _wordsUnder20.length)
          ? _wordsUnder20[value]
          : '';
    }

    // Get the base words for tens and units.
    final String tensWord = _wordsTens[tensDigit];
    final String unitWord = _wordsUnder20[unitDigit];

    // Apply specific Armenian combination rules based on tens and units digits.
    // In Armenian, tens and units are often directly concatenated or slightly modified.
    // Most combinations just concatenate `tensWord + unitWord`.
    // Special cases (like 21 needing to be "քսանմեկ") are handled below.

    // Example cases demonstrating direct concatenation or slight modification:
    // 21: "քսան" + "մեկ" -> "քսանմեկ"
    // 32: "երեսուն" + "երկու" -> "երեսուներկու"
    // 99: "իննսուն" + "ինը" -> "իննսունինը" (special case)

    // Handle the special case for 99 explicitly.
    if (tensDigit == 9 && unitDigit == 9) {
      return "իննսունինը";
    }

    // For all other combinations 21-98 (excluding 99), concatenate directly.
    return tensWord + unitWord;
  }
}
