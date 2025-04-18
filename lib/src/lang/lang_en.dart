import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/en_options.dart';
import '../utils/utils.dart';

/// {@template num2text_en}
/// The English language (`Lang.EN`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their English word representation following standard English grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [EnOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (short scale).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [EnOptions].
/// {@endtemplate}
class Num2TextEN implements Num2TextBase {
  // --- Constants for English number words ---

  /// The word for "hundred".
  static const String _hundred = "hundred";

  /// The word for "zero".
  static const String _zero = "zero";

  /// The default word for the decimal separator ("point").
  static const String _point = "point";

  /// The alternative word for the decimal separator ("comma").
  static const String _comma = "comma";

  /// The word "and", used optionally between hundreds and tens/units (British English style).
  static const String _and = "and";

  /// The conjunction used between main and sub-units in currency formatting (" and ").
  /// Note the surrounding spaces for correct formatting.
  static const String _currencyConjunction = " and ";

  /// The suffix for years Before Christ (BC).
  static const String _yearSuffixBC = "BC";

  /// The suffix for years Anno Domini (AD) or Common Era (CE).
  static const String _yearSuffixAD =
      "AD"; // Adjusted from "AD" to standard "AD" for clarity

  /// Words for numbers 0 through 19.
  static const List<String> _wordsUnder20 = [
    "zero",
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
    "ten",
    "eleven",
    "twelve",
    "thirteen",
    "fourteen",
    "fifteen",
    "sixteen",
    "seventeen",
    "eighteen",
    "nineteen",
  ];

  /// Words for tens (20, 30, ..., 90). Index corresponds to the tens digit (e.g., index 2 = "twenty").
  static const List<String> _wordsTens = [
    "", // 0 (placeholder)
    "", // 1 (placeholder)
    "twenty",
    "thirty",
    "forty",
    "fifty",
    "sixty",
    "seventy",
    "eighty",
    "ninety",
  ];

  /// Scale words (thousand, million, billion, etc.) using the short scale system.
  /// Index corresponds to the power of 1000 (e.g., index 1 = 1000^1 = thousand).
  static const List<String> _scaleWords = [
    "", // 1000^0 (units)
    "thousand",
    "million",
    "billion",
    "trillion",
    "quadrillion",
    "quintillion",
    "sextillion",
    "septillion",
    "octillion", // Added more scales
    "nonillion",
    "decillion",
    "undecillion",
    "duodecillion",
    "tredecillion",
    "quattuordecillion",
    "quindecillion",
  ];

  /// Processes the given [number] and converts it into its English word representation.
  ///
  /// {@template num2text_process_intro}
  /// Handles various numeric types (`int`, `double`, `BigInt`, `Decimal`, `String`)
  /// by first normalizing them to a [Decimal] using [Utils.normalizeNumber].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// The [options] parameter, if provided and of type [EnOptions], allows customization:
  /// - `currency`: Formats the number as currency using [EnOptions.currencyInfo].
  /// - `format`: Applies specific formatting (e.g., [Format.year]).
  /// - `decimalSeparator`: Specifies the word for the decimal point ([DecimalSeparator.period] (default "point"), [DecimalSeparator.comma]/"comma", etc.).
  /// - `negativePrefix`: Sets the prefix for negative numbers (default "minus").
  /// - `includeAnd`: Uses British English style ("one hundred and one") if true.
  /// - `includeAD`: Adds era suffixes ("AD"/"BC") for years if `format` is [Format.year].
  /// - `round`: Rounds the number before conversion (mainly for currency).
  /// If `options` is null or not an [EnOptions] instance, default English options are used.
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles special double values:
  /// - `double.infinity` -> "Infinity"
  /// - `double.negativeInfinity` -> "Negative Infinity"
  /// - `double.nan` -> Returns [fallbackOnError] ?? "Not a Number".
  /// For null input or non-numeric types, returns [fallbackOnError] ?? "Not a Number".
  /// {@endtemplate}
  ///
  /// @param number The number to convert (e.g., `123`, `45.67`, `BigInt.parse('1000000')`).
  /// @param options Optional language-specific settings ([EnOptions]).
  /// @param fallbackOnError Optional custom string to return on conversion errors.
  /// @return The English word representation of the number, or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have the correct options type or use defaults.
    final EnOptions enOptions =
        options is EnOptions ? options : const EnOptions();
    final String errorFallback =
        fallbackOnError ?? "Not a Number"; // Default error message

    // Handle special double values early.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? "Negative Infinity" : "Infinity";
      }
      if (number.isNaN) {
        return errorFallback;
      }
    }

    // Normalize the input number to Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // If normalization fails, return the fallback string.
    if (decimalValue == null) {
      return errorFallback;
    }

    // Handle the specific case of zero.
    if (decimalValue == Decimal.zero) {
      if (enOptions.currency) {
        // Zero currency needs the plural unit name (e.g., "zero dollars").
        return "$_zero ${enOptions.currencyInfo.mainUnitPlural ?? enOptions.currencyInfo.mainUnitSingular}";
      } else {
        // Zero is just "zero" for standard numbers and years.
        return _zero;
      }
    }

    // Determine sign and get the absolute value for processing.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Dispatch to specialized handlers based on format options.
    if (enOptions.format == Format.year) {
      // Year formatting handles its own sign (BC/AD).
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), enOptions);
    } else {
      // Handle currency or standard number conversion for the absolute value.
      if (enOptions.currency) {
        textResult = _handleCurrency(absValue, enOptions);
      } else {
        textResult = _handleStandardNumber(absValue, enOptions);
      }

      // Prepend the negative prefix if the original number was negative.
      if (isNegative) {
        textResult = "${enOptions.negativePrefix} $textResult";
      }
    }

    // Clean up potential double spaces before returning
    return textResult.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Handles formatting a number as a calendar year.
  ///
  /// Implements common English conventions for reading years:
  /// - 1100-1999: Read as pairs of digits (e.g., 1984 -> "nineteen eighty-four", 1900 -> "nineteen hundred").
  /// - 2000-2009: Read as "two thousand (and) X" (e.g., 2005 -> "two thousand five" or "two thousand and five").
  /// - 2010-2099: Read as pairs of digits (e.g., 2024 -> "twenty twenty-four").
  /// - Other years: Read as standard cardinal numbers.
  /// - Negative years are suffixed with "BC".
  /// - Positive years are suffixed with "AD" only if [EnOptions.includeAD] is true.
  /// - The use of "and" (for 2000-2009) depends on [EnOptions.includeAnd].
  ///
  /// @param year The integer representation of the year.
  /// @param options The [EnOptions] to use for formatting (specifically `includeAD` and `includeAnd`).
  /// @return The year formatted as English words.
  String _handleYearFormat(int year, EnOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;

    String yearText;

    if (absYear == 0) {
      // While year 0 doesn't exist in Gregorian/Julian calendars, handle it numerically.
      yearText = _zero;
    } else if (absYear >= 1100 && absYear < 2000) {
      // Handle years like 19xx, 18xx, etc.
      final int highPartInt = absYear ~/ 100; // e.g., 19
      final int lowPartInt = absYear % 100; // e.g., 84 or 00
      // Convert the century part (e.g., "nineteen")
      final String highText = _convertInteger(BigInt.from(highPartInt), false);

      if (lowPartInt == 0) {
        // e.g., 1900 -> "nineteen hundred"
        yearText = "$highText $_hundred";
      } else {
        // e.g., 1984 -> "nineteen eighty-four"
        // e.g., 1905 -> "nineteen hundred and five" or "nineteen hundred five"
        // For years, "and" is usually only inserted if the last part is < 10 and includeAnd is true.
        // American English typically says "nineteen oh five". British might say "nineteen hundred and five".
        // The current implementation doesn't produce "oh".
        final String lowText =
            _convertInteger(BigInt.from(lowPartInt), options.includeAnd);

        if (lowPartInt < 10 && options.includeAnd) {
          // Common British reading for 1905
          yearText = "$highText $_hundred $_and $lowText";
        } else if (lowPartInt < 10 && !options.includeAnd) {
          // Common US reading for 1905 might be "nineteen oh five" or "nineteen five".
          // Current logic results in "nineteen hundred five", matching some interpretations.
          yearText = "$highText $_hundred $lowText";
        } else {
          // For years like 1984, "and" is not typically used before "eighty-four".
          yearText = "$highText $lowText"; // e.g., "nineteen eighty-four"
        }
      }
    } else if (absYear >= 2000 && absYear < 2010) {
      // Handle years like 200x
      final int lowPartInt = absYear % 100; // e.g., 5 for 2005
      if (lowPartInt == 0) {
        // 2000 -> "two thousand"
        yearText = _convertInteger(BigInt.from(absYear), options.includeAnd);
      } else {
        // e.g., 2005 -> "two thousand (and) five"
        final String highText =
            _convertInteger(BigInt.from(2000), false); // "two thousand"
        final String lowText =
            _convertInteger(BigInt.from(lowPartInt), false); // "five"
        final String connector = options.includeAnd ? " $_and " : " ";
        yearText = "$highText$connector$lowText";
      }
    } else if (absYear >= 2010 && absYear < 2100) {
      // Handle years like 20xx where xx >= 10
      // e.g., 2024 -> "twenty twenty-four"
      final int highPartInt = absYear ~/ 100; // e.g., 20
      final int lowPartInt = absYear % 100; // e.g., 24
      // Convert parts independently, "and" is not used here.
      final String highText =
          _convertInteger(BigInt.from(highPartInt), false); // "twenty"
      final String lowText =
          _convertInteger(BigInt.from(lowPartInt), false); // "twenty-four"
      yearText = "$highText $lowText";
    } else {
      // Default to standard number conversion for other years (e.g., 1066, 2150).
      // Use includeAnd based on options for consistency.
      yearText = _convertInteger(BigInt.from(absYear), options.includeAnd);
    }

    // Append era suffixes.
    if (isNegative) {
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD && absYear > 0) {
      // Only add AD if requested and year is not 0.
      yearText += " $_yearSuffixAD";
    }

    return yearText;
  }

  /// Handles formatting a number as a currency value.
  ///
  /// Separates the number into main units (e.g., dollars) and subunits (e.g., cents).
  /// Uses singular/plural forms from [EnOptions.currencyInfo].
  /// Joins main and subunits with " and " (or the separator from [CurrencyInfo]).
  /// Optionally rounds the number to 2 decimal places if [EnOptions.round] is true.
  ///
  /// @param absValue The absolute (non-negative) decimal value of the currency.
  /// @param options The [EnOptions] containing currency info and rounding preference.
  /// @return The currency value formatted as English words.
  String _handleCurrency(Decimal absValue, EnOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2; // Standard for most currencies
    final Decimal subunitMultiplier =
        Decimal.fromInt(100); // Assuming 100 subunits per main unit

    // Round the value if requested, otherwise use as is.
    final Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main and subunit values.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Calculate subunit value carefully from the fractional part.
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).truncate().toBigInt();

    // Convert the main value to words. 'includeAnd' is determined by EnOptions for the overall number.
    final String mainText = _convertInteger(mainValue, options.includeAnd);
    // Determine the correct unit name (singular or plural).
    final String mainUnitName = (mainValue == BigInt.one)
        ? currencyInfo.mainUnitSingular
        : currencyInfo.mainUnitPlural ??
            currencyInfo
                .mainUnitSingular; // Fallback to singular if plural is null

    String result = '$mainText $mainUnitName';

    // Add subunit part if it exists.
    if (subunitValue > BigInt.zero) {
      // Convert subunit value to words.
      final String subunitText =
          _convertInteger(subunitValue, options.includeAnd);
      // Determine the correct subunit name.
      final String subUnitName;
      if (subunitValue == BigInt.one) {
        subUnitName = currencyInfo.subUnitSingular ??
            ''; // Handle potentially missing subunit name
      } else {
        subUnitName =
            currencyInfo.subUnitPlural ?? currencyInfo.subUnitSingular ?? '';
      }

      // Get the separator from CurrencyInfo or default to " and ".
      final String separator = currencyInfo.separator?.isNotEmpty ?? false
          ? ' ${currencyInfo.separator!} '
          : _currencyConjunction;

      // Append the subunit part only if a subunit name exists.
      if (subUnitName.isNotEmpty) {
        result += '$separator$subunitText $subUnitName';
      }
    }

    return result;
  }

  /// Handles formatting a standard cardinal number, including decimals.
  ///
  /// Converts the integer part using [_convertInteger].
  /// Converts the fractional part digit by digit (e.g., 0.45 -> "point four five").
  /// Uses the decimal separator word specified in [EnOptions.decimalSeparator].
  ///
  /// @param absValue The absolute (non-negative) decimal value of the number.
  /// @param options The [EnOptions] containing decimal separator and 'includeAnd' preference.
  /// @return The number formatted as English words.
  String _handleStandardNumber(Decimal absValue, EnOptions options) {
    // Separate integer and fractional parts.
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part. Use "zero" if integer is 0 but fraction exists.
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, options.includeAnd);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word based on options.
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _comma;
          break;
        case DecimalSeparator.point: // Treat point and period the same
        case DecimalSeparator.period:
        default: // Default to period/point
          separatorWord = _point;
          break;
      }

      // Get the digits after the decimal point as a string.
      // Use toString() and split to handle the fractional part accurately.
      // Note: Decimal.toString() might produce scientific notation for very large/small scales,
      // but that's less likely for typical inputs handled here.
      final String fullString = absValue.toString();
      final int pointIndex = fullString.indexOf('.');
      if (pointIndex != -1) {
        String fractionalDigits = fullString.substring(pointIndex + 1);
        // Trim trailing zeros for standard representation (e.g., 1.50 -> "one point five").
        while (fractionalDigits.endsWith('0') && fractionalDigits.length > 1) {
          fractionalDigits =
              fractionalDigits.substring(0, fractionalDigits.length - 1);
        }

        // Convert each digit individually to its word representation.
        final List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          // Ensure the digit is valid (0-9).
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder20[digitInt]
              : '?'; // Placeholder for unexpected characters
        }).toList();

        // Combine separator and digit words.
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }

    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'
        .trim(); // Trim potential leading/trailing space
  }

  /// Converts a non-negative integer ([BigInt]) into its English word representation.
  ///
  /// Uses a chunking algorithm based on powers of 1000 (thousand, million, billion, etc.).
  /// Delegates chunks of 0-999 to [_convertChunk].
  /// The `includeAnd` flag is passed down to [_convertChunk] for potential use within chunks.
  ///
  /// @param n The non-negative integer to convert.
  /// @param includeAnd Whether to include "and" between hundreds and tens/units within chunks (British style).
  /// @throws ArgumentError if [n] is negative or too large for defined scales.
  /// @return The integer as English words.
  String _convertInteger(BigInt n, bool includeAnd) {
    if (n < BigInt.zero) {
      // This function expects non-negative input; sign is handled higher up.
      throw ArgumentError("Integer must be non-negative for conversion: $n");
    }
    if (n == BigInt.zero) return _zero;

    // Handle numbers less than 1000 directly.
    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt(), includeAnd);
    }

    final List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0; // 0=units, 1=thousand, 2=million, ...
    BigInt remaining = n;

    // Process the number in chunks of 1000 from right to left.
    while (remaining > BigInt.zero) {
      // Check if the number exceeds the defined scale words.
      if (scaleIndex >= _scaleWords.length) {
        throw ArgumentError(
          "Number too large to convert (exceeds defined scale: ${_scaleWords.last}, index: $scaleIndex)",
        );
      }

      // Get the current chunk (0-999).
      final BigInt chunk = remaining % oneThousand;
      // Move to the next chunk.
      remaining ~/= oneThousand;

      // If the chunk is non-zero, convert it and add the scale word.
      if (chunk > BigInt.zero) {
        // Convert the 0-999 chunk.
        final String chunkText = _convertChunk(chunk.toInt(), includeAnd);
        // Get the appropriate scale word (e.g., "thousand", "million").
        final String scaleWord = scaleIndex > 0 ? _scaleWords[scaleIndex] : "";

        // Combine chunk text and scale word.
        String currentPart = chunkText;
        if (scaleWord.isNotEmpty) {
          currentPart += " $scaleWord";
        }
        parts.add(currentPart);
      }
      scaleIndex++;
    }

    // Join the parts in reverse order (highest scale first), ensuring single spaces.
    return parts.reversed.join(' ').trim();
  }

  /// Converts an integer between 0 and 999 (inclusive) into its English word representation.
  ///
  /// Handles hundreds, tens, and units, including the optional "and"
  /// for British English style if [includeAnd] is true. Hyphenates
  /// compound numbers like "twenty-one".
  ///
  /// @param n The integer chunk (0-999) to convert.
  /// @param includeAnd Whether to include "and" between hundreds and tens/units (e.g., "one hundred and twenty-three").
  /// @throws ArgumentError if [n] is outside the 0-999 range.
  /// @return The chunk as English words, or an empty string if [n] is 0.
  String _convertChunk(int n, bool includeAnd) {
    if (n == 0) {
      return ""; // Zero is handled specially or results in empty string within larger numbers.
    }
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }

    final List<String> words = [];
    int remainder = n;

    // Handle hundreds part.
    if (remainder >= 100) {
      words.add(_wordsUnder20[remainder ~/ 100]); // e.g., "one", "two"
      words.add(_hundred);
      remainder %= 100;

      // Add "and" if needed (British style) and there's a remaining part.
      if (remainder > 0 && includeAnd) {
        words.add(_and);
      }
    }

    // Handle tens and units part (0-99).
    if (remainder > 0) {
      if (remainder < 20) {
        // Numbers 1-19 are unique words.
        words.add(_wordsUnder20[remainder]);
      } else {
        // Numbers 20-99.
        final String tensWord =
            _wordsTens[remainder ~/ 10]; // e.g., "twenty", "thirty"
        final int unit = remainder % 10;

        if (unit == 0) {
          // Pure tens (e.g., 20, 30).
          words.add(tensWord);
        } else {
          // Compound tens-units (e.g., 21, 35), hyphenated.
          words.add("$tensWord-${_wordsUnder20[unit]}");
        }
      }
    }

    // Join the parts ("one", "hundred", ["and"], "twenty-three") with spaces.
    return words.join(' ');
  }
}
