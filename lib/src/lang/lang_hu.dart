import 'dart:math';

import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/hu_options.dart';
import '../utils/utils.dart';

/// {@template num2text_hu}
/// The Hungarian language (`Lang.HU`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Hungarian word representation following Hungarian grammar rules, including
/// specific compounding for numbers under 2000 and long scale usage.
///
/// Capabilities include handling cardinal numbers, currency (using [HuOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (long scale).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [HuOptions].
/// {@endtemplate}
class Num2TextHU implements Num2TextBase {
  // --- Private Constants ---

  /// The word for zero.
  static const String _zero = "nulla";

  /// The word used for the decimal separator when using `DecimalSeparator.period` or `DecimalSeparator.point`.
  static const String _point = "pont";

  /// The word used for the decimal separator when using `DecimalSeparator.comma` (default).
  /// Also means "whole" or "integer".
  static const String _comma = "egész";

  /// The separator used between thousands and lower units for numbers >= 2000.
  static const String _thousandSeparator = "-";

  /// The suffix for years Before Christ (Before Common Era).
  static const String _yearSuffixBC =
      "i.e."; // időszámításunk előtt (before our era)

  /// The suffix for years Anno Domini (Common Era).
  static const String _yearSuffixAD =
      "i.sz."; // időszámításunk szerint (according to our era)

  /// Words for numbers 0-19. Note: index 0 is empty as "nulla" is handled separately.
  static const List<String> _wordsUnder20 = [
    "", // 0 (placeholder)
    "egy", // 1
    "kettő", // 2
    "három", // 3
    "négy", // 4
    "öt", // 5
    "hat", // 6
    "hét", // 7
    "nyolc", // 8
    "kilenc", // 9
    "tíz", // 10
    "tizenegy", // 11
    "tizenkettő", // 12
    "tizenhárom", // 13
    "tizennégy", // 14
    "tizenöt", // 15
    "tizenhat", // 16
    "tizenhét", // 17
    "tizennyolc", // 18
    "tizenkilenc", // 19
  ];

  /// Words for tens (10, 20, ..., 90). Note: index 0 and 1 are empty/covered by _wordsUnder20.
  static const List<String> _wordsTens = [
    "", // 0 (placeholder)
    "", // 10 (use _wordsUnder20[10])
    "húsz", // 20
    "harminc", // 30
    "negyven", // 40
    "ötven", // 50
    "hatvan", // 60
    "hetven", // 70
    "nyolcvan", // 80
    "kilencven", // 90
  ];

  /// The word for "hundred".
  static const String _hundredWord = "száz";

  /// The word for "thousand". Used as a scale name and within numbers like 1000, 2000 etc.
  static const String _thousandWord = "ezer";

  /// Scale words for large numbers (thousand, million, billion, etc.).
  /// Follows the long scale system (alternating -ió and -iárd suffixes).
  static const List<String> _scaleWords = [
    "", // 10^0 (Units - no scale word)
    _thousandWord, // 10^3
    "millió", // 10^6
    "milliárd", // 10^9
    "billió", // 10^12
    "billiárd", // 10^15
    "trillió", // 10^18
    "trilliárd", // 10^21
    "kvadrillió", // 10^24
    "kvadrilliárd", // 10^27
    "kvintillió", // 10^30
    "kvintilliárd", // 10^33
    "szextillió", // 10^36
    "szextilliárd", // 10^39
    // Add more scales as needed, following the pattern:
    // septillió, septilliárd, oktillió, oktilliárd, etc.
  ];

  /// Processes the given number into its Hungarian word representation.
  ///
  /// [number] The number to convert (can be `int`, `double`, `BigInt`, `Decimal`, or `String`).
  /// [options] Optional [HuOptions] to customize formatting (currency, year, decimal separator, etc.). Defaults to `HuOptions()`.
  /// [fallbackOnError] Optional string to return if conversion fails (e.g., invalid input). Defaults to "Nem szám".
  /// Returns the word representation of the number in Hungarian, or a fallback string on error.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final HuOptions huOptions =
        options is HuOptions ? options : const HuOptions();
    const String defaultFallback = "Nem szám"; // "Not a number"

    // Handle special double values directly (cannot be normalized to Decimal).
    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Negatív végtelen" : "Végtelen";
      if (number.isNaN) return fallbackOnError ?? defaultFallback;
    }

    // Normalize input to Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Handle normalization failures (null, NaN, invalid strings).
    if (decimalValue == null) {
      return fallbackOnError ?? defaultFallback;
    }

    // Handle zero separately.
    if (decimalValue == Decimal.zero) {
      if (huOptions.currency) {
        // "nulla forint" etc.
        return "$_zero ${huOptions.currencyInfo.mainUnitSingular}";
      }
      if (huOptions.format == Format.year) {
        // Year 0 is just "nulla".
        return _zero;
      }
      // For "0.0" or "0.00", handle as standard number to include decimal part if needed.
      if (decimalValue.scale > 0 && !decimalValue.isInteger) {
        return _handleStandardNumber(
            decimalValue, huOptions); // e.g., "nulla egész nulla"
      }
      // Otherwise (integer zero), just return "nulla".
      return _zero;
    }

    // Determine sign and use absolute value for core conversion.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Delegate based on formatting options.
    if (huOptions.format == Format.year) {
      // Years require special handling (BC/AD suffixes, negativity handled internally).
      textResult = _handleYearFormat(
          absValue.truncate().toBigInt(), isNegative, huOptions);
    } else {
      // Handle currency or standard number format.
      if (huOptions.currency) {
        textResult = _handleCurrency(absValue, huOptions);
      } else {
        textResult = _handleStandardNumber(absValue, huOptions);
      }

      // Prepend negative prefix if applicable for non-year formats.
      if (isNegative) {
        textResult = "${huOptions.negativePrefix} $textResult";
      }
    }
    return textResult.trim(); // Ensure no trailing spaces.
  }

  /// Formats a number as a year, adding BC/AD suffixes.
  ///
  /// [yearValue] The absolute value of the year (as BigInt).
  /// [isOriginalNegative] True if the original input year was negative (BC/BCE).
  /// [options] The Hungarian formatting options.
  /// Returns the year formatted as text with appropriate suffixes.
  String _handleYearFormat(
      BigInt yearValue, bool isOriginalNegative, HuOptions options) {
    // Convert the year integer part to words.
    String yearText = _convertInteger(yearValue);

    // Add suffixes based on sign and options.
    if (isOriginalNegative) {
      // Negative years always get the BC suffix.
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD && yearValue > BigInt.zero) {
      // Positive years get the AD suffix only if includeAD is true.
      yearText += " $_yearSuffixAD";
    }
    return yearText;
  }

  /// Formats a number as currency according to Hungarian conventions.
  ///
  /// [absValue] The absolute value of the number (as Decimal).
  /// [options] The Hungarian formatting options, including currency info.
  /// Returns the number formatted as currency text (e.g., "száz forint ötven fillér").
  String _handleCurrency(Decimal absValue, HuOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    const int decimalPlaces = 2; // Standard subunit precision.
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Currency is typically rounded to standard subunit places.
    final Decimal valueToConvert = absValue.round(scale: decimalPlaces);

    // Separate main unit and subunit values.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    // Calculate subunit value (e.g., 0.45 * 100 = 45).
    final BigInt subunitValue =
        ((valueToConvert - mainValue.toDecimal()) * subunitMultiplier)
            .truncate()
            .toBigInt();

    // Convert main value to words.
    String mainText = _convertInteger(mainValue);
    // Get the appropriate currency unit name (always singular in Hungarian after numbers).
    String mainUnitName = currencyInfo.mainUnitSingular;

    // Combine main value text and unit name.
    String result = '$mainText $mainUnitName';

    // Add subunit part if it exists and is defined in CurrencyInfo.
    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      String subunitText = _convertInteger(subunitValue);
      String subUnitName =
          currencyInfo.subUnitSingular!; // Assumes singular form is sufficient.
      // Append subunit text and name (no explicit separator like "and" in Hungarian).
      result += ' $subunitText $subUnitName';
    }
    return result;
  }

  /// Handles standard number formatting, including integers and decimals.
  ///
  /// [absValue] The absolute value of the number (as Decimal).
  /// [options] The Hungarian formatting options, especially `decimalSeparator`.
  /// Returns the number formatted as text, potentially including a decimal part.
  String _handleStandardNumber(Decimal absValue, HuOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final int scale = absValue.scale; // Number of digits after decimal point.

    // Convert the integer part to words.
    String integerWords = _convertInteger(integerPart);

    String fractionalWords = '';
    // Process fractional part only if it exists (scale > 0 and not an integer like 123.0).
    if (scale > 0 && !absValue.isInteger) {
      // Determine the decimal separator word based on options. Default to comma ("egész").
      String separatorWord;
      switch (options.decimalSeparator ?? DecimalSeparator.comma) {
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          separatorWord = _point; // "pont"
          break;
        case DecimalSeparator.comma:
          separatorWord = _comma; // "egész"
          break;
      }

      // Extract fractional digits as a string.
      String numberStr = absValue.toString();
      // Ensure we handle cases like "0.5" correctly by splitting at '.'.
      String fractionalDigitsStr =
          numberStr.contains('.') ? numberStr.split('.').last : '';

      // Trim trailing zeros for standard display (e.g., 1.50 -> "öt").
      fractionalDigitsStr = fractionalDigitsStr.replaceAll(RegExp(r'0+$'), '');

      // Convert each fractional digit to its word representation if any remain.
      if (fractionalDigitsStr.isNotEmpty) {
        List<String> digitWords = fractionalDigitsStr.split('').map((digit) {
          final int digitInt = int.parse(digit);
          // Digits after decimal point are read individually.
          // Use _wordsUnder20 for 1-9, _zero for 0.
          return (digitInt == 0 ? _zero : _wordsUnder20[digitInt]);
        }).toList();

        // Construct the fractional part string (e.g., " egész öt hat" or " pont nulla öt").
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }

    // Combine integer and fractional parts.
    // Handle the special case where the integer part was zero.
    if (integerPart == BigInt.zero && fractionalWords.isNotEmpty) {
      return "$_zero$fractionalWords"; // e.g., "nulla egész öt" (starts with "nulla")
    } else {
      return '$integerWords$fractionalWords'
          .trim(); // e.g., "százhuszonhárom egész öt" or just "százhuszonhárom"
    }
  }

  /// Converts a non-negative integer (BigInt) into its Hungarian word representation.
  /// Handles large numbers using scale words and applies hyphenation rules.
  ///
  /// [n] The non-negative integer to convert.
  /// Returns the integer as Hungarian text. Throws ArgumentError for negative input or unsupported scale.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero) {
      throw ArgumentError(
          "Internal error: _convertInteger received negative number: $n");
    }
    if (n == BigInt.zero) return _zero;

    final String s = n.toString();
    final int len = s.length;

    // Determine number of groups of three digits (e.g., 123,456,789 -> 3 groups).
    final int numGroups = (len + 2) ~/ 3;
    // Determine length of the first group (1, 2, or 3 digits).
    final int firstGroupLen = len % 3 == 0 ? 3 : len % 3;

    List<String> parts =
        []; // Stores word parts for each group (e.g., "százhuszonhárom", "ezer").
    int currentPos = 0; // Current position in the number string.

    // Process the number in groups of three digits from left to right.
    for (int groupIndex = 0; groupIndex < numGroups; groupIndex++) {
      final int groupLen = (groupIndex == 0) ? firstGroupLen : 3;
      // Calculate end position, ensuring it doesn't exceed string length.
      final int endPos = min(currentPos + groupLen, len);

      final String groupStr = s.substring(currentPos, endPos);
      final int groupValue = int.parse(groupStr);
      currentPos += groupLen; // Move position for the next group.

      // Skip groups of zeros (e.g., in 1,000,001).
      if (groupValue == 0) continue;

      // Determine the scale index (0 for units, 1 for thousands, 2 for millions, etc.).
      final int scaleIndex = numGroups - 1 - groupIndex;

      // Check if the scale is supported.
      if (scaleIndex >= _scaleWords.length) {
        throw ArgumentError(
          "Number too large, scale index $scaleIndex is out of bounds for defined _scaleWords.",
        );
      }

      // Convert the 1-999 group value to words.
      String groupText = _convertChunk1To999(groupValue);

      // Append scale word if applicable (not the units group, scaleIndex > 0).
      if (scaleIndex > 0) {
        final String scaleWord = _scaleWords[scaleIndex];

        // Special handling for "one thousand", "one million", etc.
        if (groupValue == 1) {
          if (scaleIndex == 1) {
            // Just "ezer" (thousand), not "egyezer".
            parts.add(scaleWord);
          } else {
            // "egymillió", "egymilliárd", etc. (Prefix "egy" to scale word).
            parts.add("egy$scaleWord");
          }
        } else {
          // Handle numbers like 2000 ("kétezer") vs 3000 ("háromezer").
          if (scaleIndex == 1 && groupValue == 2) {
            // Special case for 2000: use "két" instead of "kettő".
            groupText = "két";
          }

          // Combine group text and scale word.
          // Add space for scales larger than thousand (e.g., "kettő millió").
          // No space for thousands (e.g., "kétezer", "háromezer"). Concatenate directly.
          parts.add(scaleIndex == 1
              ? "$groupText$scaleWord"
              : "$groupText $scaleWord");
        }
      } else {
        // This is the last group (units place 1-999), just add its text.
        parts.add(groupText);
      }
    }

    // If all groups were zero (should be handled by the initial n==0 check), return zero.
    if (parts.isEmpty) return _zero;

    // --- Combine the parts with correct spacing/hyphenation ---

    // Simple case: only one part (e.g., "százhuszonhárom" or "egymillió").
    if (parts.length == 1) {
      return parts[0];
    }

    // Hungarian hyphenation rule: Use a hyphen before the last group (1-999)
    // if the number is >= 2000 AND the last group is non-zero.
    bool applyHyphen = false;
    if (n >= BigInt.from(2000) && parts.length > 1) {
      // Check if the last group value (units 1-999) is greater than zero.
      // Get last 1-3 digits.
      final String lastGroupStr = s.substring(max(0, len - 3));
      final int lastGroupValue = int.parse(lastGroupStr);
      if (lastGroupValue > 0) {
        applyHyphen = true;
      }
    }

    if (applyHyphen) {
      // Join all parts except the last with spaces.
      String prefix = parts.sublist(0, parts.length - 1).join(' ');
      // Combine: prefix + hyphen + last_part.
      return prefix + _thousandSeparator + parts.last;
    } else {
      // No hyphen needed. Join with spaces, but handle 1001-1999 case without space after "ezer".
      // Example: 1101 -> "ezerszázegy"
      if (n > BigInt.from(1000) &&
          n < BigInt.from(2000) &&
          parts.length == 2 && // Consists of "ezer" and the 1-999 part.
          parts[0] == _thousandWord) {
        return parts[0] + parts[1]; // Concatenate directly: "ezer" + "százegy".
      } else {
        // Join all other cases with spaces.
        return parts.join(' ');
      }
    }
  }

  /// Converts a number between 1 and 99 into its Hungarian word representation.
  ///
  /// [n] The integer between 1 and 99.
  /// Returns the number as Hungarian text, or an empty string if out of range.
  String _convertChunk1To99(int n) {
    if (n <= 0 || n >= 100) return ""; // Handle invalid input range.

    // Numbers 1-19 have unique words.
    if (n < 20) return _wordsUnder20[n];

    // Numbers 20, 30, ..., 90.
    final int tensDigit = n ~/ 10;
    final int units = n % 10;
    final String tensWord = _wordsTens[tensDigit];

    if (units == 0) {
      // Exact tens (20, 30, etc.).
      return tensWord;
    } else {
      // Compound tens (21, 34, etc.).
      // Special prefix "huszon" for 21-29.
      if (tensDigit == 2) {
        return "huszon${_wordsUnder20[units]}"; // "huszonegy", "huszonkettő", etc.
      } else {
        // Other tens: combine tens word and units word directly (no space).
        return "$tensWord${_wordsUnder20[units]}"; // "harmincegy", "negyvenkettő", etc.
      }
    }
  }

  /// Converts a number between 100 and 999 into its Hungarian word representation.
  /// Also handles numbers 1-99 by delegating.
  ///
  /// [n] The integer between 1 and 999.
  /// Returns the number as Hungarian text, or an empty string if out of range (e.g., 0 or >= 1000).
  String _convertChunk100To999(int n) {
    // Delegate to _convertChunk1To99 for numbers below 100.
    if (n < 100) {
      if (n > 0) return _convertChunk1To99(n);
      return ""; // Return empty for 0 or negative.
    }
    if (n >= 1000) return ""; // Out of range for this helper.

    final int hundredsDigit = n ~/ 100;
    final int remainder = n % 100; // The part between 0-99.

    String hundredsWord;
    // Special case for 100 ("száz") vs 200 ("kétszáz"), 300 ("háromszáz"), etc.
    if (hundredsDigit == 1) {
      hundredsWord = _hundredWord; // "száz".
    } else {
      // Use "két" for 200, otherwise use the standard digit word.
      final String hundredsPrefix =
          (hundredsDigit == 2) ? "két" : _wordsUnder20[hundredsDigit];
      hundredsWord =
          "$hundredsPrefix$_hundredWord"; // "kétszáz", "háromszáz", etc.
    }

    // If there's no remainder, return just the hundreds word.
    if (remainder == 0) {
      return hundredsWord;
    } else {
      // Combine hundreds word and the word for the remainder (1-99) directly (no space).
      return "$hundredsWord${_convertChunk1To99(remainder)}"; // "százegy", "kétszázötvenhat".
    }
  }

  /// Converts a number between 1 and 999 into its Hungarian word representation.
  /// This acts as a dispatcher to the appropriate helper based on the number's range.
  ///
  /// [n] The integer between 1 and 999.
  /// Returns the number as Hungarian text, or an empty string if 0 or out of range.
  String _convertChunk1To999(int n) {
    if (n <= 0 || n >= 1000) return "";
    if (n < 100) return _convertChunk1To99(n);
    return _convertChunk100To999(n); // Handles 100-999.
  }
}
