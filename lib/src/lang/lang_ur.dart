import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ur_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ur}
/// The Urdu language (`Lang.UR`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Urdu word representation following standard Urdu grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [UrOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers
/// (using the Indian numbering system: Lakh, Crore, etc.).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [UrOptions].
/// {@endtemplate}
class Num2TextUR implements Num2TextBase {
  /// The word for "negative" used as a prefix for negative numbers. Defined in [UrOptions].
  // static const String _negative = "منفی"; // Default defined in UrOptions

  /// The word for "zero".
  static const String _zero = "صفر";

  /// The word for "hundred".
  static const String _hundred = "سو";

  /// The word for "thousand".
  static const String _thousand = "ہزار";

  /// The word used for the decimal separator when `DecimalSeparator.period` or `DecimalSeparator.point` is specified.
  static const String _decimalPointWord = "اعشاریہ";

  /// The word used for the decimal separator when `DecimalSeparator.comma` is specified.
  static const String _decimalCommaWord =
      "کوما"; // Less common for Urdu decimals

  /// The word for "infinity".
  static const String _infinity = "لامحدود";

  /// The text representation for negative infinity.
  static const String _negativeInfinity =
      "منفی لامحدود"; // Using default "منفی"

  /// The default text returned for non-numeric inputs or NaN, unless a specific fallback is provided.
  static const String _notANumber = "نمبر نہیں ہے";

  /// Scale words for the Indian numbering system (Lakh, Crore, etc.).
  /// Each step represents a multiplication by 100 after the initial 1000.
  static const List<String> _scaleWordsIndian = [
    // Base: 10^3 (Hazar) handled separately
    "لاکھ", // 10^5 (100 * 1000)
    "کروڑ", // 10^7 (100 * Lakh)
    "ارب", // 10^9 (100 * Crore)
    "کھرب", // 10^11 (100 * Arab)
    "نیل", // 10^13 (100 * Kharab)
    "پدم", // 10^15 (100 * Neel)
    "سنکھ", // 10^17 (100 * Padm)
    "مہاسنکھ", // 10^19 (100 * Sankh) - Increasingly less common
    "انک", // 10^21 (100 * Mahasankh) - Rarely used
    "جلد", // 10^23 (100 * Ank) - Rarely used
    // Add more if needed following the pattern (multiply by 100)
  ];

  /// Words for numbers 0 through 19.
  static const List<String> _wordsUnder20 = [
    "صفر", // 0
    "ایک", // 1
    "دو", // 2
    "تین", // 3
    "چار", // 4
    "پانچ", // 5
    "چھ", // 6
    "سات", // 7
    "آٹھ", // 8
    "نو", // 9
    "دس", // 10
    "گیارہ", // 11
    "بارہ", // 12
    "تیرہ", // 13
    "چودہ", // 14
    "پندرہ", // 15
    "سولہ", // 16
    "سترہ", // 17
    "اٹھارہ", // 18
    "انیس", // 19
  ];

  /// Words for compound numbers from 20 to 99.
  /// This map is essential as Urdu has unique words for many numbers in this range.
  static final Map<int, String> _compoundWords = {
    20: "بیس",
    21: "اکیس",
    22: "بائیس",
    23: "تیئس",
    24: "چوبیس",
    25: "پچیس",
    26: "چھبیس",
    27: "ستائیس",
    28: "اٹھائیس",
    29: "انتیس",
    30: "تیس",
    31: "اکتیس",
    32: "بتیس",
    33: "تینتیس",
    34: "چونتیس",
    35: "پینتیس", // Corrected: 35 is پینتیس
    36: "چھتیس",
    37: "سینتیس",
    38: "اڑتیس",
    39: "انتالیس",
    40: "چالیس",
    41: "اکتالیس",
    42: "بیالیس",
    43: "تینتالیس",
    44: "چوالیس",
    45: "پینتالیس",
    46: "چھیالیس",
    47: "سینتالیس",
    48: "اڑتالیس",
    49: "انچاس",
    50: "پچاس",
    51: "اکاون",
    52: "باون",
    53: "ترپن",
    54: "چون", // Short form often used
    55: "پچپن",
    56: "چھپن",
    57: "ستاون",
    58: "اٹھاون",
    59: "انسٹھ",
    60: "ساٹھ",
    61: "اکسٹھ",
    62: "باسٹھ",
    63: "تریسٹھ",
    64: "چونسٹھ",
    65: "پینسٹھ",
    66: "چھیاسٹھ",
    67: "سڑسٹھ",
    68: "اڑسٹھ",
    69: "انہتر",
    70: "ستر",
    71: "اکہتر",
    72: "بہتر",
    73: "تہتر",
    74: "چوہتر",
    75: "پچھتر",
    76: "چھہتر",
    77: "ستتر",
    78: "اٹھتر",
    79: "اناسی",
    80: "اسی",
    81: "اکیاسی",
    82: "بیاسی",
    83: "تراسی",
    84: "چوراسی",
    85: "پچاسی",
    86: "چھیاسی",
    87: "ستاسی",
    88: "اٹھاسی",
    89: "نواسی",
    90: "نوے",
    91: "اکانوے",
    92: "بانوے",
    93: "ترانوے",
    94: "چورانوے",
    95: "پچانوے",
    96: "چھیانوے",
    97: "ستانوے",
    98: "اٹھانوے",
    99: "ننانوے",
  };

  /// Processes the given [number] and converts it into its Urdu word representation.
  ///
  /// [number] can be an `int`, `double`, `BigInt`, `String`, or `Decimal`.
  /// [options] allows specifying language-specific configurations using [UrOptions].
  /// If `options` is null or not an instance of `UrOptions`, default Urdu options are used.
  /// [fallbackOnError] provides a custom string to return if the input is invalid (e.g., non-numeric, NaN).
  /// If `fallbackOnError` is null, a default Urdu error message (`_notANumber`) is used.
  ///
  /// Returns the Urdu text for the number, or the fallback string on error.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final urOptions = options is UrOptions ? options : const UrOptions();
    final fallback = fallbackOnError ?? _notANumber;

    // Handle non-numeric types and special double values early.
    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _negativeInfinity : _infinity;
      if (number.isNaN) return fallback;
    }

    // Normalize the input number to Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return fallback;

    // Handle zero separately for potential currency formatting.
    if (decimalValue == Decimal.zero) {
      if (urOptions.currency) {
        // Use plural form for zero currency according to PKR rules.
        return "$_zero ${urOptions.currencyInfo.mainUnitPlural}"; // e.g., "صفر روپے"
      }
      return _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for core conversion.
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    // Extract the integer part for processing scales.
    final BigInt integerPart = absValue.truncate().toBigInt();

    String textResult;
    // Determine the formatting based on options.
    if (urOptions.format == Format.year) {
      textResult = _handleYearFormat(integerPart, isNegative, urOptions);
    } else if (urOptions.currency) {
      textResult = _handleCurrency(absValue, urOptions);
    } else {
      textResult = _handleStandardNumber(absValue, urOptions, integerPart);
    }

    // Prepend the negative prefix if the original number was negative.
    if (isNegative && urOptions.format != Format.year) {
      // Negative prefix is handled inside _handleYearFormat for years
      final String prefix = urOptions.negativePrefix;
      textResult = textResult.isNotEmpty ? "$prefix $textResult" : prefix;
    }

    // Return the final trimmed result.
    return textResult.trim();
  }

  /// Handles formatting a number specifically as a year.
  ///
  /// Urdu year formatting conventions:
  /// - Years 1100-1999 ending in 00 are read as "[Hundreds] سو" (e.g., 1900 -> "انیس سو").
  /// - Other years are generally read normally.
  /// - Negative years are prefixed with the standard negative word; no specific "BC" term is standard.
  /// - Positive years do *not* automatically get an "AD" suffix unless explicitly configured.
  ///
  /// [yearBigInt] The absolute value of the year as a BigInt.
  /// [isNegative] Indicates if the original year was negative.
  /// [options] The Urdu-specific options.
  /// Returns the formatted year string.
  String _handleYearFormat(
      BigInt yearBigInt, bool isNegative, UrOptions options) {
    int yearInt = 0;
    bool yearIsInIntRange = yearBigInt.isValidInt;

    String yearText;
    if (yearIsInIntRange) {
      yearInt = yearBigInt.toInt();
      // Special case for positive years like 1900, 1800, etc.
      if (!isNegative &&
          yearInt >= 1100 &&
          yearInt < 2000 &&
          yearInt % 100 == 0) {
        final int highPart = yearInt ~/ 100;
        // Convert the "19" part of "1900"
        yearText = "${_convertChunk0to99(highPart)} $_hundred";
      } else {
        // Convert other years normally.
        yearText = _convertIntegerPart(yearBigInt);
      }
    } else {
      // Handle very large years using BigInt conversion.
      yearText = _convertIntegerPart(yearBigInt);
    }

    // Prepend negative prefix for negative years.
    if (isNegative) {
      final String prefix = options.negativePrefix;
      yearText = "$prefix $yearText";
    }
    // Currently, UrOptions does not support includeAD. Add check if implemented.
    // else if (options.includeAD) {
    //   yearText += " عیسوی"; // Example AD suffix
    // }

    return yearText;
  }

  /// Handles formatting a number as currency (PKR - Pakistani Rupee by default).
  ///
  /// Converts the main unit (Rupee) and subunit (Paisa), applying correct singular/plural forms.
  /// Uses the separator defined in [UrOptions.currencyInfo].
  ///
  /// [absValue] The absolute decimal value of the currency amount.
  /// [options] The Urdu-specific options containing currency info.
  /// Returns the formatted currency string (e.g., "ایک سو تیئس روپے اور پینتالیس پیسے").
  String _handleCurrency(Decimal absValue, UrOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    // PKR has 100 Paisa in 1 Rupee.
    final Decimal subunitMultiplier = Decimal.fromInt(100);
    const int decimalPlaces = 2; // Standard for currency

    // Round the value if needed (though not default in UrOptions)
    final Decimal valueToConvert =
        options.round ? absValue.round(scale: decimalPlaces) : absValue;

    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Round subunit value to avoid precision issues (e.g., 1.50 becomes 50).
    final BigInt subunitValue =
        (fractionalPart.abs() * subunitMultiplier).round(scale: 0).toBigInt();

    final String mainText = _convertIntegerPart(mainValue);
    // Determine plural/singular form for Rupee.
    // Use plural ('روپے') for all except 1.
    final String mainUnitName = (mainValue == BigInt.one)
        ? currencyInfo.mainUnitSingular
        : currencyInfo.mainUnitPlural!; // Assuming plural is defined

    String result = '$mainText $mainUnitName';

    // Append subunit part if it exists.
    if (subunitValue > BigInt.zero) {
      final String subunitText = _convertIntegerPart(subunitValue);
      // Determine plural/singular form for Paisa.
      // Use plural ('پیسے') for all except 1.
      final String subUnitName = (subunitValue == BigInt.one)
          ? currencyInfo.subUnitSingular! // Assuming singular is defined
          : currencyInfo.subUnitPlural!; // Assuming plural is defined

      // Get the separator (e.g., " اور ")
      String separator =
          currencyInfo.separator ?? ""; // Default to empty string if null
      if (separator.isNotEmpty) separator = " $separator ";

      result += '$separator$subunitText $subUnitName';
    }
    return result;
  }

  /// Handles standard number formatting including decimals.
  ///
  /// Converts the integer part and the fractional part separately.
  /// The fractional part is read digit by digit after the decimal separator word.
  ///
  /// [absValue] The absolute decimal value of the number.
  /// [options] The Urdu-specific options.
  /// [integerPart] The pre-calculated integer part of the number.
  /// Returns the formatted number string (e.g., "ایک سو تیئس اعشاریہ چار پانچ چھ").
  String _handleStandardNumber(
      Decimal absValue, UrOptions options, BigInt integerPart) {
    // Check for numbers like 0.5 where the integer part needs "صفر".
    final String integerWords =
        (integerPart == BigInt.zero && absValue > Decimal.zero)
            ? _zero
            : _convertIntegerPart(integerPart);

    String fractionalWords = '';
    // Process fractional part only if it's greater than zero.
    final Decimal fractionalPart = (absValue - absValue.truncate()).abs();
    if (fractionalPart > Decimal.zero) {
      String separatorWord;
      // Choose the correct decimal separator word based on options. Default to period.
      switch (options.decimalSeparator ?? DecimalSeparator.period) {
        case DecimalSeparator.comma:
          separatorWord = _decimalCommaWord;
          break;
        // Default to period/point word.
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          separatorWord = _decimalPointWord;
          break;
      }

      // Extract digits after the decimal point. toString() handles representation.
      final String fractionalDigits = absValue.toString().split('.').last;
      // Convert each digit individually to its word representation.
      final List<String> digitWords = fractionalDigits.split('').map((d) {
        final int? digitInt = int.tryParse(d);
        // Look up the digit's word (0-9). Handle zero.
        return (digitInt != null && digitInt >= 0 && digitInt <= 9)
            ? (digitInt == 0 ? _zero : _wordsUnder20[digitInt])
            : '?'; // Fallback for unexpected characters.
      }).toList();
      fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
    }
    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts the integer part of a number using the Indian numbering system.
  ///
  /// Groups the number into chunks:
  /// - First chunk: 0-999
  /// - Second chunk: Represents thousands (0-99)
  /// - Subsequent chunks: Represent Lakhs, Crores, Arabs, etc. (0-99 each)
  ///
  /// [n] The non-negative integer to convert.
  /// Returns the Urdu text for the integer part. Returns "صفر" for 0.
  String _convertIntegerPart(BigInt n) {
    if (n == BigInt.zero) return _zero; // Handle zero input.
    if (n < BigInt.zero) {
      throw ArgumentError("Input to _convertIntegerPart must be non-negative.");
    }

    final BigInt oneHundred = BigInt.from(100);
    final BigInt oneThousand = BigInt.from(1000);
    final List<String> parts =
        []; // Stores word parts (e.g., "دو کروڑ", "پچیس ہزار")
    BigInt remaining = n;

    // 1. Process the base chunk (0-999).
    final int basePart = (remaining % oneThousand).toInt();
    if (basePart > 0) {
      parts.add(_convertChunk0to999(basePart));
    }
    remaining ~/= oneThousand; // Remove the processed part.

    // 2. Process the thousands chunk (0-99), if applicable.
    if (remaining > BigInt.zero) {
      final int thousandPart =
          (remaining % oneHundred).toInt(); // Thousands use chunks of 100
      if (thousandPart > 0) {
        parts.add("${_convertChunk0to99(thousandPart)} $_thousand");
      }
      remaining ~/= oneHundred;
    }

    // 3. Process higher scale chunks (Lakh, Crore, etc.) using chunks of 100.
    int scaleIndex = 0; // Index for _scaleWordsIndian (0=Lakh, 1=Crore, ...)
    while (remaining > BigInt.zero) {
      // Check if the scale word exists.
      if (scaleIndex >= _scaleWordsIndian.length) {
        // If number is too large for defined scales, stop processing scales.
        // Consider adding more scale words or throwing an error for very large numbers.
        // Log error or throw? For now, stop processing.
        break;
      }
      final int chunk = (remaining % oneHundred).toInt();
      if (chunk > 0) {
        final String chunkText = _convertChunk0to99(chunk);
        final String scaleWord = _scaleWordsIndian[scaleIndex];
        parts.add("$chunkText $scaleWord");
      }
      remaining ~/= oneHundred;
      scaleIndex++;
    }

    // Join all parts in reverse order (lowest scale was added first) with spaces.
    return parts.reversed.join(' ');
  }

  /// Converts a number between 0 and 999 into Urdu words.
  ///
  /// Handles hundreds place and the remaining 0-99 part.
  ///
  /// [n] The number to convert (0-999).
  /// Returns the Urdu text for the number. Returns an empty string for 0.
  /// Throws [ArgumentError] if n is outside the 0-999 range.
  String _convertChunk0to999(int n) {
    if (n == 0) return ""; // Zero is handled higher up or as "" in chunks.
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999, got: $n");
    }

    final List<String> words = [];
    int remainder = n;

    // Process hundreds place.
    if (remainder >= 100) {
      // Get the word for the hundreds digit (1-9).
      words.add(_wordsUnder20[remainder ~/ 100]);
      words.add(_hundred);
      remainder %= 100; // Get the remaining 0-99 part.
    }

    // Process the remaining 0-99 part.
    if (remainder > 0) {
      words.add(_convertChunk0to99(remainder));
    }

    // Join parts (e.g., "ایک", "سو", "تیئس").
    return words.join(' ');
  }

  /// Converts a number between 0 and 99 into Urdu words.
  ///
  /// Uses lookup tables [_wordsUnder20] and [_compoundWords] for efficiency.
  ///
  /// [n] The number to convert (0-99).
  /// Returns the Urdu text for the number.
  /// Returns an empty string for 0.
  /// Returns "?" as a fallback if a compound word is missing (should not happen with the current map).
  /// Throws [ArgumentError] if n is outside the 0-99 range.
  String _convertChunk0to99(int n) {
    if (n == 0) return ""; // Zero is typically silent in compound numbers.
    if (n < 0 || n >= 100) {
      throw ArgumentError("Sub-chunk must be between 0 and 99, got: $n");
    }

    // Numbers 0-19 have direct lookup.
    if (n < 20) return _wordsUnder20[n];

    // Numbers 20-99 use the compound words map.
    // Use null-aware operator with fallback "?" in case the map is incomplete.
    return _compoundWords[n] ?? "?";
  }
}
