import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/am_options.dart';
import '../options/base_options.dart';
import '../utils/utils.dart';

/// {@template num2text_am}
/// The Amharic language (`Lang.AM`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Amharic word representation following Amharic grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [AmOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (short scale names).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [AmOptions].
/// {@endtemplate}
class Num2TextAM implements Num2TextBase {
  /// Word for "zero".
  static const String _zero = "ዜሮ";

  /// Word for the decimal separator "point".
  static const String _point = "ነጥብ";

  /// Word for the decimal separator "comma".
  static const String _comma = "ኮማ";

  /// Word for "hundred".
  static const String _hundred = "መቶ";

  /// Word for "thousand".
  static const String _thousand = "ሺህ";

  /// Suffix for years Before Christ Era (BC/BCE). Abbreviation for ዓመተ ዓለም (Year of the World).
  static const String _yearSuffixBC = "ዓ.ዓ";

  /// Suffix for years Anno Mundi / Ethiopian Era (AD/CE). Abbreviation for ዓመተ ምሕረት (Year of Mercy).
  static const String _yearSuffixAD = "ዓ.ም";

  /// Word for "infinity".
  static const String _infinity = "ወሰን የሌለው";

  /// Word for "not a number". Used as the default fallback message.
  static const String _notANumber = "ቁጥር አይደለም";

  /// Amharic words for numbers 0 to 19.
  static const List<String> _wordsUnder20 = [
    "ዜሮ", // 0
    "አንድ", // 1
    "ሁለት", // 2
    "ሶስት", // 3
    "አራት", // 4
    "አምስት", // 5
    "ስድስት", // 6
    "ሰባት", // 7
    "ስምንት", // 8
    "ዘጠኝ", // 9
    "አስር", // 10
    "አስራ አንድ", // 11
    "አስራ ሁለት", // 12
    "አስራ ሶስት", // 13
    "አስራ አራት", // 14
    "አስራ አምስት", // 15
    "አስራ ስድስት", // 16
    "አስራ ሰባት", // 17
    "አስራ ስምንት", // 18
    "አስራ ዘጠኝ", // 19
  ];

  /// Amharic words for tens (20, 30, ..., 90). Index corresponds to tens digit (index 2 is 20).
  static const List<String> _wordsTens = [
    "", // 0 (unused placeholder)
    "", // 1 (unused placeholder - covered by _wordsUnder20)
    "ሃያ", // 20
    "ሰላሳ", // 30
    "አርባ", // 40
    "ሃምሳ", // 50
    "ስልሳ", // 60
    "ሰባ", // 70
    "ሰማንያ", // 80
    "ዘጠና", // 90
  ];

  /// Mapping of large number scales (powers of 1000) to their Amharic names.
  /// Uses short scale names (billion=10^9, trillion=10^12).
  static final List<MapEntry<BigInt, String>> _scaleWords = [
    MapEntry(BigInt.from(10).pow(24), "ሴፕቲሊዮን"), // 10^24 Septillion
    MapEntry(BigInt.from(10).pow(21), "ሴክስቲሊዮን"), // 10^21 Sextillion
    MapEntry(BigInt.from(10).pow(18), "ኩንቲሊዮን"), // 10^18 Quintillion
    MapEntry(BigInt.from(10).pow(15), "ኳድሪሊዮን"), // 10^15 Quadrillion
    MapEntry(BigInt.from(10).pow(12), "ትሪሊዮን"), // 10^12 Trillion
    MapEntry(BigInt.from(10).pow(9), "ቢሊዮን"), // 10^9  Billion
    MapEntry(BigInt.from(10).pow(6), "ሚሊዮን"), // 10^6  Million
    MapEntry(BigInt.from(10).pow(3), _thousand), // 10^3  Thousand
  ];

  /// Processes the given [number] and converts it into Amharic words.
  ///
  /// - [number] can be `int`, `double`, `BigInt`, `String`, or `Decimal`.
  /// - [options] allows specifying formatting details like currency, year format,
  ///   negative prefix, etc., using [AmOptions]. If null or not [AmOptions],
  ///   default [AmOptions] are used.
  /// - [fallbackOnError] is the string returned if the input is invalid (e.g., NaN, non-numeric string)
  ///   or if an unexpected error occurs during conversion. If null, a default error message is used.
  ///
  /// Returns the number represented in Amharic words, or the [fallbackOnError] string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have Amharic-specific options, using defaults if necessary.
    final AmOptions amOptions =
        options is AmOptions ? options : const AmOptions();
    final String errorFallback = fallbackOnError ?? _notANumber;

    // Handle special double values directly.
    if (number is double) {
      if (number.isInfinite) {
        // Use the negative prefix from options
        return number.isNegative
            ? "${amOptions.negativePrefix} $_infinity"
            : _infinity;
      }
      if (number.isNaN) {
        return errorFallback;
      }
    }

    // Normalize the input number to Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // If normalization fails, return the fallback error string.
    if (decimalValue == null) {
      return errorFallback;
    }

    // Handle the special case of zero.
    if (decimalValue == Decimal.zero) {
      if (amOptions.currency) {
        // For currency, include the main unit name (e.g., "ዜሮ ብር").
        // ETB doesn't typically pluralize for 0, use singular.
        final String mainUnitName = amOptions.currencyInfo.mainUnitSingular;
        return "$_zero $mainUnitName";
      }
      // For year format or standard numbers, just return "ዜሮ".
      return _zero;
    }

    // Determine sign and work with the absolute value.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Apply specific formatting based on options.
    try {
      if (amOptions.format == Format.year) {
        // Year format handles its own sign logic internally.
        textResult = _handleYearFormat(
            decimalValue.truncate().toBigInt().toInt(), amOptions);
      } else if (amOptions.currency) {
        textResult = _handleCurrency(absValue, amOptions);
        if (isNegative) {
          // Add negative prefix for currency if the original number was negative.
          textResult = "${amOptions.negativePrefix} $textResult";
        }
      } else {
        textResult = _handleStandardNumber(absValue, amOptions);
        if (isNegative) {
          // Add negative prefix for standard numbers.
          textResult = "${amOptions.negativePrefix} $textResult";
        }
      }
    } catch (e) {
      // Catch potential errors during conversion logic.
      // Consider logging the error: print('Amharic conversion error: $e');
      return errorFallback;
    }

    // Clean up potential extra spaces before returning.
    return textResult.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Formats an integer as an Amharic year.
  ///
  /// Handles negative years (BC/ዓ.ዓ) and optionally adds the AD/CE suffix (ዓ.ም)
  /// for positive years based on [options.includeAD].
  ///
  /// - [year] The integer year value.
  /// - [options] The [AmOptions] specifying formatting rules.
  /// Returns the year formatted as Amharic words.
  String _handleYearFormat(int year, AmOptions options) {
    final bool isNegative = year < 0;
    final int absYear =
        year.abs(); // Use abs() for cleaner absolute value calculation.

    // Handle year zero if necessary (though typically not used in BC/AD context).
    if (absYear == 0) {
      return _zero; // Or potentially add era context if required by convention.
    }

    final BigInt bigAbsYear = BigInt.from(absYear);

    // Convert the absolute year value to words.
    String yearText = _convertInteger(bigAbsYear);

    // Append the appropriate era suffix.
    if (isNegative) {
      // BC suffix for negative years.
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD) {
      // AD/CE suffix for positive years if requested.
      yearText += " $_yearSuffixAD";
    }
    return yearText;
  }

  /// Formats a [Decimal] number as Amharic currency.
  ///
  /// Uses the [options.currencyInfo] (defaults to Ethiopian Birr - ETB)
  /// to determine unit names and separators. Handles rounding based on [options.round].
  ///
  /// - [absValue] The absolute (non-negative) decimal value of the currency.
  /// - [options] The [AmOptions] specifying currency details and rounding.
  /// Returns the currency value formatted as Amharic words.
  String _handleCurrency(Decimal absValue, AmOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2; // Standard for most currencies.
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value if requested.
    final Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate the main unit and subunit values.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Use round for robustness against floating point inaccuracies near the boundary.
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round().toBigInt();

    // Convert the main unit value to words.
    // Amharic Birr (ETB) doesn't typically pluralize. Use singular form.
    final String mainText = _convertInteger(mainValue);
    final String mainUnitName =
        currencyInfo.mainUnitSingular; // ETB singular is 'ብር'

    String result = '$mainText $mainUnitName';

    // Add subunit part if it exists.
    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      final String subunitText = _convertInteger(subunitValue);
      // Use singular form for subunits (e.g., "ሳንቲም").
      final String subUnitName =
          currencyInfo.subUnitSingular!; // ETB subunit singular 'ሳንቲም'
      final String separator =
          currencyInfo.separator ?? ""; // ETB separator 'ከ'

      // Append separator (like "ከ") and subunit words.
      if (separator.isNotEmpty) {
        // Ensure correct spacing around separator.
        result += ' $separator$subunitText $subUnitName';
      } else {
        // Fallback if separator is missing (though ETB uses "ከ").
        result += ' $subunitText $subUnitName';
      }
    }

    return result;
  }

  /// Formats a standard [Decimal] number (non-currency, non-year) into Amharic words.
  ///
  /// Handles integer and fractional parts. Uses the decimal separator specified
  /// in [options.decimalSeparator] (defaults to "ነጥብ"). Converts fractional digits individually.
  /// Removes trailing zeros from the fractional part.
  ///
  /// - [absValue] The absolute (non-negative) decimal value.
  /// - [options] The [AmOptions] specifying the decimal separator.
  /// Returns the number formatted as Amharic words.
  String _handleStandardNumber(Decimal absValue, AmOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part, handling the case where it's zero but there's a fractional part.
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    // Process fractional part only if it exists and the number isn't an integer.
    if (fractionalPart > Decimal.zero && !absValue.isInteger) {
      // Determine the decimal separator word.
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _comma;
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period:
        default: // Default to period/point
          separatorWord = _point;
          break;
      }

      // Extract fractional digits as a string.
      final String decimalString = absValue.toString();
      String fractionalDigits =
          decimalString.contains('.') ? decimalString.split('.').last : '';

      // Remove trailing zeros from the fractional part
      fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      // If all fractional digits were zeros, skip adding fractional part.
      if (fractionalDigits.isNotEmpty) {
        // Convert each fractional digit to its Amharic word.
        final List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          // Map digit 0-9 to its word, use '?' for unexpected characters.
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder20[digitInt]
              : '?'; // Error case, should ideally not happen
        }).toList();

        // Join the digit words with spaces and prepend the separator word.
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }
    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords';
  }

  /// Converts a non-negative [BigInt] integer into Amharic words.
  ///
  /// This is the core recursive function for handling large integers.
  /// It breaks the number down into chunks based on scale words (thousands, millions, etc.).
  /// Assumes the input [n] is non-negative.
  ///
  /// - [n] The non-negative integer to convert.
  /// Returns the integer represented as Amharic words.
  String _convertInteger(BigInt n) {
    // Ensure input is non-negative as per method contract.
    assert(n >= BigInt.zero, 'Input to _convertInteger must be non-negative.');

    // Base cases
    if (n == BigInt.zero) return _zero;

    // Handle numbers less than 1000 using the chunk converter.
    if (n < BigInt.from(1000)) {
      // Ensure conversion to int is safe (already checked < 1000)
      return _convertChunk(n.toInt());
    }

    final List<String> parts = [];
    BigInt remaining = n;

    // Iterate through scales (Million, Billion, etc.) from largest to smallest.
    for (final scaleEntry in _scaleWords) {
      final scaleValue = scaleEntry.key;
      final scaleName = scaleEntry.value;

      if (remaining >= scaleValue) {
        // Calculate how many of this scale unit are present.
        final BigInt count = remaining ~/ scaleValue;
        // Update the remainder for the next smaller scale.
        remaining %= scaleValue;

        // Convert the count of this scale unit to words.
        // Use the standard chunk converter for the count (e.g., convert 123 for "123 million").
        final String countText = _convertChunk(count.toInt());

        // Special Amharic rule: "ሺህ" (thousand) instead of "አንድ ሺህ" (one thousand).
        if (count == BigInt.one && scaleName == _thousand) {
          parts.add(scaleName); // Add "ሺህ" directly.
        } else {
          // Combine count text and scale name (e.g., "መቶ ሃያ ሶስት ሚሊዮን").
          parts.add("$countText $scaleName");
        }
      }
    }

    // If there's a remainder less than 1000 after processing all scales, convert it.
    if (remaining > BigInt.zero) {
      // Ensure conversion to int is safe (remaining < 1000)
      parts.add(_convertChunk(remaining.toInt()));
    }

    // Join the parts (e.g., ["መቶ ሃያ ሶስት ሚሊዮን", "አራት መቶ ሃምሳ ስድስት ሺህ", "ሰባት መቶ ሰማንያ ዘጠኝ"]) with spaces.
    return parts.join(' ');
  }

  /// Converts an integer between 0 and 999 (inclusive) into Amharic words.
  ///
  /// - [n] The integer chunk (0-999) to convert.
  /// Returns the chunk represented as Amharic words, or an empty string if [n] is 0.
  /// Throws [ArgumentError] if [n] is outside the valid range 0-999.
  String _convertChunk(int n) {
    if (n == 0)
      return ""; // Return empty string for zero chunk within a larger number.
    if (n < 0 || n >= 1000) {
      // Ensure the input is within the expected range for this helper.
      throw ArgumentError("Chunk must be between 0 and 999 (inclusive): $n");
    }

    final List<String> words = [];
    int remainder = n;

    // Handle hundreds place.
    if (remainder >= 100) {
      final int hundredDigit = remainder ~/ 100;
      // Special Amharic rule: "መቶ" for 100, "ሁለት መቶ" for 200, etc.
      if (hundredDigit > 1) {
        words.add(_wordsUnder20[hundredDigit]); // Add "ሁለት", "ሶስት", etc.
      }
      words.add(_hundred); // Add "መቶ".
      remainder %= 100; // Update remainder.
    }

    // Handle tens and units place (remainder 1-99).
    if (remainder > 0) {
      // Add space between hundreds and tens/units if hundreds part exists.
      if (words.isNotEmpty) {
        // Space is handled by join(' ') later
      }

      if (remainder < 20) {
        // Numbers 1-19 are directly looked up.
        words.add(_wordsUnder20[remainder]);
      } else {
        // Numbers 20-99.
        final int tensDigit = remainder ~/ 10;
        final int unitDigit = remainder % 10;
        words.add(_wordsTens[tensDigit]); // Add "ሃያ", "ሰላሳ", etc.
        if (unitDigit > 0) {
          // Add space between tens and units.
          // Space is handled by join(' ') later.
          // If there's a unit digit, add it (e.g., "ሃያ" + "አንድ").
          words.add(_wordsUnder20[unitDigit]);
        }
      }
    }

    // Join the parts (e.g., ["መቶ", "ሃያ", "አንድ"]) with spaces.
    return words.join(' ');
  }
}
