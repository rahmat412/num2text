import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/af_options.dart';
import '../options/base_options.dart';
import '../utils/utils.dart';

/// {@template num2text_af}
/// The Afrikaans language (`Lang.AF`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Afrikaans word representation following standard Afrikaans grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [AfOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (using the long scale common in Afrikaans).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [AfOptions].
/// {@endtemplate}
class Num2TextAF implements Num2TextBase {
  // --- Private constants for Afrikaans words ---

  /// The word for zero.
  static const String _zero = "nul";

  /// The word used for the decimal separator when [DecimalSeparator.period] or [DecimalSeparator.point] is specified.
  static const String _point = "punt";

  /// The word used for the decimal separator when [DecimalSeparator.comma] is specified (default for Afrikaans).
  static const String _comma = "komma";

  /// The conjunction "en" (and), used in numbers like "een-en-twintig" (twenty-one)
  /// and conditionally between hundreds/thousands and smaller units based on [AfOptions.includeAnd].
  static const String _and = "en";

  /// The word for "hundred".
  static const String _hundred = "honderd";

  /// The word for "thousand".
  static const String _thousand = "duisend";

  /// The suffix for years Before Christ (BC/BCE). "v.C." stands for "voor Christus".
  static const String _yearSuffixBC = "v.C.";

  /// The suffix for years Anno Domini (AD/CE). "n.C." stands for "na Christus".
  static const String _yearSuffixAD = "n.C.";

  /// The word for positive infinity.
  static const String _infinity = "Oneindig";

  /// The default error message for non-numeric or invalid input.
  static const String _notANumber = "Nie 'n Nommer nie";

  /// Words for numbers 0-19.
  static const List<String> _wordsUnder20 = [
    "nul", // 0
    "een", // 1
    "twee", // 2
    "drie", // 3
    "vier", // 4
    "vyf", // 5
    "ses", // 6
    "sewe", // 7
    "agt", // 8
    "nege", // 9
    "tien", // 10
    "elf", // 11
    "twaalf", // 12
    "dertien", // 13
    "veertien", // 14
    "vyftien", // 15
    "sestien", // 16
    "sewentien", // 17
    "agtien", // 18
    "negentien", // 19
  ];

  /// Words for tens (20, 30,... 90). Index corresponds to the tens digit (e.g., index 2 is "twintig").
  static const List<String> _wordsTens = [
    "", // 0 (unused)
    "", // 10 (handled by _wordsUnder20)
    "twintig", // 20
    "dertig", // 30
    "veertig", // 40
    "vyftig", // 50
    "sestig", // 60
    "sewentig", // 70
    "tagtig", // 80
    "neëntig", // 90
  ];

  /// Scale words (thousand, million, billion, etc.) following the long scale system common in Afrikaans.
  static const List<String> _scaleWords = [
    "", // 10^0 - Base unit
    _thousand, // 10^3
    "miljoen", // 10^6
    "miljard", // 10^9
    "biljoen", // 10^12
    "biljard", // 10^15
    "triljoen", // 10^18
    "triljard", // 10^21
    "kwadriljoen", // 10^24
    "kwadriljard", // 10^27
    // Further scales (quintillion, etc.) can be added following the long scale pattern.
  ];

  /// Processes the given [number] and converts it into Afrikaans words based on the provided [options].
  ///
  /// - [number]: The number to convert (can be `int`, `double`, `BigInt`, `String`, or `Decimal`).
  /// - [options]: Configuration options (`AfOptions`) for the conversion (e.g., currency, year format).
  ///   If `null` or not an `AfOptions` instance, default Afrikaans options are used.
  /// - [fallbackOnError]: A custom string to return if the input is invalid or conversion fails.
  ///   If `null`, a default Afrikaans error message ([_notANumber]) is used.
  ///
  /// Returns the number represented in Afrikaans words, or an error string if conversion is not possible.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure options are of the correct type or use defaults.
    final AfOptions afOptions =
        options is AfOptions ? options : const AfOptions();
    final String errorMsg = fallbackOnError ?? _notANumber;

    // Handle special double values first.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? "Negatief $_infinity" : _infinity;
      }
      if (number.isNaN) {
        return errorMsg;
      }
    }

    // Normalize the input number to Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // If normalization fails, return error string.
    if (decimalValue == null) {
      return errorMsg;
    }

    // Handle zero specifically.
    if (decimalValue == Decimal.zero) {
      if (afOptions.currency) {
        // Use plural form for zero Rand/cent according to CurrencyInfo (if available).
        return "$_zero ${afOptions.currencyInfo.mainUnitPlural ?? afOptions.currencyInfo.mainUnitSingular}";
      } else {
        // For years or standard numbers, just return "nul".
        return _zero;
      }
    }

    // Determine sign and work with the absolute value.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Branch based on the specified format.
    if (afOptions.format == Format.year) {
      // Years require special handling (BC/AD, specific phrasing for 1100-1999).
      // Year format inherently handles the negative sign for BC years.
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), afOptions);
    } else {
      // Handle currency or standard number formats.
      if (afOptions.currency) {
        textResult = _handleCurrency(absValue, afOptions);
      } else {
        textResult = _handleStandardNumber(absValue, afOptions);
      }
      // Prepend the negative prefix if the original number was negative (and not a year).
      if (isNegative) {
        textResult = "${afOptions.negativePrefix} $textResult";
      }
    }

    return textResult;
  }

  /// Formats an integer as an Afrikaans year string.
  ///
  /// Handles BC/AD suffixes ([_yearSuffixBC] / [_yearSuffixAD]).
  /// Uses special phrasing like "negentienhonderd vier-en-tagtig" for years 1100-1999.
  ///
  /// - [year]: The integer year value.
  /// - [options]: The [AfOptions] containing formatting flags like `includeAD`.
  ///
  /// Returns the year in Afrikaans words.
  String _handleYearFormat(int year, AfOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;
    final BigInt bigAbsYear = BigInt.from(absYear);

    String yearText;

    if (absYear == 0) {
      // Zero year case (rare, handles historical calendars).
      yearText = _zero;
    } else if (absYear >= 1100 && absYear < 2000) {
      // Special case for years like 1984 -> "negentienhonderd vier-en-tagtig"
      final int highPartInt = absYear ~/ 100; // e.g., 19
      final int lowPartInt = absYear % 100; // e.g., 84

      // Convert the "century" part (e.g., 19 -> "negentien").
      // `includeAnd` is irrelevant for this part in year format. `isYearFormat`=true.
      final String highText =
          _convertInteger(BigInt.from(highPartInt), false, true);

      if (lowPartInt == 0) {
        // For years like 1900 -> "negentienhonderd".
        yearText = "$highText$_hundred";
      } else {
        // For years like 1984.
        // Convert the low part (e.g., 84 -> "vier-en-tagtig").
        // `isFinalChunk` is true. `includeAnd` doesn't add 'en' after 'honderd' in year format.
        final String lowText = _convertChunk(lowPartInt, false, true);

        // Standard Afrikaans year format uses a space here, not 'en'.
        final String separator = " ";

        // Construct: "negentienhonderd" + " " + "vier-en-tagtig"
        yearText = "$highText$_hundred$separator$lowText";
      }
    } else {
      // For years outside 1100-1999 (e.g., 1066, 2024).
      // Use standard integer conversion. `includeAnd` has no effect in year format.
      yearText = _convertInteger(bigAbsYear, false, true);
    }

    // Append era suffixes if applicable.
    if (isNegative) {
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD && absYear > 0) {
      // Only add AD suffix if requested via options and year is positive.
      yearText += " $_yearSuffixAD";
    }

    return yearText;
  }

  /// Formats a positive [Decimal] value as Afrikaans currency.
  ///
  /// Uses singular/plural forms from [AfOptions.currencyInfo].
  /// Handles the main unit and subunit.
  /// Uses the separator defined in [CurrencyInfo] or defaults to " en ".
  /// Optionally rounds the value to 2 decimal places if `options.round` is true.
  ///
  /// - [absValue]: The positive decimal value representing the currency amount.
  /// - [options]: The [AfOptions] containing currency settings ([currencyInfo], [round], [includeAnd]).
  ///
  /// Returns the currency value in Afrikaans words.
  String _handleCurrency(Decimal absValue, AfOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2; // Standard for most currencies.
    final Decimal subunitMultiplier =
        Decimal.fromInt(100); // Assumes 100 subunits per main unit.

    // Round the value to the standard currency decimal places if requested.
    final Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main and subunit values.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Calculate subunit value safely.
    final BigInt subunitValue = (fractionalPart.isNegative
            ? Decimal.zero
            : fractionalPart * subunitMultiplier)
        .truncate()
        .toBigInt();

    // Convert the main value (Rand) to words.
    // Pass `includeAnd` from options. `isYearFormat` is false.
    final String mainText =
        _convertInteger(mainValue, options.includeAnd, false);

    // Determine the correct singular/plural form for the main unit (Rand).
    final String mainUnitName = (mainValue == BigInt.one)
        ? currencyInfo.mainUnitSingular
        : (currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular);

    // Initial result string with main value and unit.
    String result = '$mainText $mainUnitName';

    // Add subunit part (cents) if present.
    if (subunitValue > BigInt.zero) {
      // Convert subunit value to words.
      // Pass `includeAnd` from options. `isYearFormat` is false.
      final String subunitText =
          _convertInteger(subunitValue, options.includeAnd, false);

      // Ensure subUnitSingular is defined in CurrencyInfo if subunits exist.
      final String? subUnitSingular = currencyInfo.subUnitSingular;
      if (subUnitSingular == null) {
        // This indicates an issue with the CurrencyInfo setup.
        // In a production app, consider logging this or throwing a more specific error.
        return result; // Return only the main part as subunits cannot be named.
      }

      // Determine the correct singular/plural form for the subunit (cent).
      final String subUnitName = (subunitValue == BigInt.one)
          ? subUnitSingular
          : (currencyInfo.subUnitPlural ?? subUnitSingular);

      // Determine the separator word (e.g., "en") between main and subunits.
      // Use the separator from CurrencyInfo, or default to " en " if null.
      String separator = currencyInfo.separator ?? " $_and ";
      // Ensure the separator has leading/trailing spaces if it's simply "en".
      separator =
          separator.trim() == _and ? " $_and " : " ${separator.trim()} ";

      // Append the separator, subunit value, and subunit name.
      result += '$separator$subunitText $subUnitName';
    }

    return result;
  }

  /// Formats a positive [Decimal] value as a standard Afrikaans number string, including the decimal part if present.
  ///
  /// - [absValue]: The positive decimal value to format.
  /// - [options]: The [AfOptions] containing decimal separator preference ([decimalSeparator]) and other flags like [includeAnd].
  ///
  /// Returns the number in Afrikaans words, potentially including the decimal part (e.g., "twaalf komma vyf").
  String _handleStandardNumber(Decimal absValue, AfOptions options) {
    // Separate integer and fractional parts.
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part to words.
    // If the integer part is zero but there's a fractional part (e.g., 0.5), start with "nul".
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, options.includeAnd, false);

    String fractionalWords = '';
    // Process fractional part only if it's greater than zero.
    if (fractionalPart > Decimal.zero) {
      // Determine the decimal separator word based on options.
      final String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          separatorWord = _point;
          break;
        case DecimalSeparator.comma: // Fallthrough intended
        default: // Default to comma for Afrikaans if null or comma.
          separatorWord = _comma;
          break;
      }

      // Extract the digits after the decimal point.
      // Use toStringAsFixed or similar if specific precision/trailing zero handling is needed.
      // Current approach uses standard toString() behavior.
      final String decimalString = absValue.toString();
      final String fractionalDigits =
          decimalString.contains('.') ? decimalString.split('.').last : '';

      // Convert each digit after the decimal point to its word representation.
      final List<String> digitWords = fractionalDigits.split('').map((digit) {
        final int? digitInt = int.tryParse(digit);
        // Use basic number words (0-9) for individual digits.
        return (digitInt != null && digitInt >= 0 && digitInt <= 9)
            ? _wordsUnder20[digitInt]
            : '?'; // Fallback for unexpected non-digit characters.
      }).toList();

      // If fractional digits exist, construct the fractional part string.
      if (digitWords.isNotEmpty) {
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }
    // Note: The condition `else if (integerPart > BigInt.zero && absValue.scale > 0 && absValue.isInteger)`
    // from the original logic seems unnecessary here. If `absValue.isInteger` is true, `fractionalPart`
    // would be zero, and this block wouldn't be reached. If the intent was to handle numbers input
    // with trailing zeros like `123.0`, the current logic correctly omits the fractional part.

    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a large non-negative integer ([BigInt]) into Afrikaans words.
  ///
  /// Breaks the number into chunks of three digits (0-999) and applies scale words
  /// (thousand, million, etc.) from the long scale.
  /// Handles the conjunction "en" based on the `includeAnd` option and context (not used in year format).
  ///
  /// - [n]: The non-negative integer to convert. Must not be negative.
  /// - [includeAnd]: Whether to potentially include "en" between major scale units (e.g., "duisend en een").
  /// - [isYearFormat]: Indicates if the conversion is for a year. If true, `includeAnd` logic between scales is suppressed.
  ///
  /// Returns the integer represented in Afrikaans words.
  /// Throws [ArgumentError] if `n` is negative or too large for defined scales.
  String _convertInteger(BigInt n, bool includeAnd, bool isYearFormat) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) {
      // Internal function, should only receive non-negative values.
      throw ArgumentError(
          "Internal error: _convertInteger requires non-negative input: $n");
    }

    // Handle numbers less than 1000 directly using _convertChunk.
    if (n < BigInt.from(1000)) {
      // `isFinalChunk` is true as this is the only/lowest chunk.
      return _convertChunk(n.toInt(), includeAnd, true);
    }

    // --- Logic for numbers >= 1000 ---

    final List<String> parts =
        []; // Stores word representations of each 3-digit chunk with its scale.
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex =
        0; // Index into _scaleWords (0=units, 1=thousand, 2=million, etc.)
    BigInt remaining = n;

    // Process the number in chunks of 1000 from right to left (lowest scale first).
    while (remaining > BigInt.zero) {
      // Check if the number exceeds the largest defined scale.
      if (scaleIndex >= _scaleWords.length) {
        throw ArgumentError(
          "Number too large to convert with defined scales (max scale: ${_scaleWords.last}): $n",
        );
      }

      // Extract the current chunk (0-999).
      final BigInt chunkValue = remaining % oneThousand;
      remaining ~/= oneThousand; // Move to the next higher scale chunk.

      if (chunkValue > BigInt.zero) {
        // Convert the non-zero chunk to words.
        // `isFinalChunk` is true only if this is the lowest scale chunk (units/tens/hundreds).
        final bool isFinalChunk = (scaleIndex == 0);
        final String chunkText =
            _convertChunk(chunkValue.toInt(), includeAnd, isFinalChunk);

        // Get the appropriate scale word (e.g., "duisend", "miljoen"). Empty for scale 0.
        final String scaleWord =
            _scaleWords[scaleIndex]; // Safe access due to length check above.

        // Combine chunk text and scale word.
        final String part =
            scaleWord.isNotEmpty ? "$chunkText $scaleWord" : chunkText;
        parts.add(part.trim());
      } else {
        // If a chunk is zero (e.g., in 1,000,500), add an empty placeholder to maintain structure.
        // This prevents issues with spacing and conjunction logic later.
        parts.add("");
      }
      scaleIndex++;
    }

    // --- Combine the processed parts (now in reverse order) with appropriate spacing and conjunctions ---

    String result = "";
    // Iterate from the highest scale part down to the lowest.
    for (int i = parts.length - 1; i >= 0; i--) {
      if (parts[i].isNotEmpty) {
        result += parts[i];

        // Determine if a space or " en " should follow the current part.
        // We only potentially add " en " if this is *not* the last part (i > 0).
        if (i > 0) {
          // Look ahead: Find the scale index of the *next* non-zero chunk below the current one.
          int nextNonZeroChunkScale = -1;
          for (int j = i - 1; j >= 0; j--) {
            if (parts[j].isNotEmpty) {
              nextNonZeroChunkScale = j;
              break;
            }
          }

          // If a non-zero chunk exists below the current one...
          if (nextNonZeroChunkScale != -1) {
            // Calculate the total value represented by all chunks *below* the current scale `i`.
            // This helps determine if the remaining part is small (1-99).
            BigInt valueBelowCurrentScale = n % oneThousand.pow(i);

            // Check conditions for adding " en ":
            // 1. `includeAnd` option must be true.
            // 2. Not formatting a year.
            // 3. The *next* non-zero chunk must be the absolute last one (scale 0).
            // 4. The total value below the current scale must be between 1 and 99.
            final bool addConjunction = includeAnd &&
                !isYearFormat &&
                nextNonZeroChunkScale ==
                    0 && // Next part is the units/tens/hundreds chunk
                valueBelowCurrentScale > BigInt.zero &&
                valueBelowCurrentScale < BigInt.from(100);

            // Add " en " if conditions met, otherwise add a space.
            result += addConjunction ? " $_and " : " ";
          }
        }
      }
    }

    return result.trim();
  }

  /// Converts a number between 0 and 999 into Afrikaans words.
  /// Helper function for [_convertInteger].
  ///
  /// - [n]: The integer chunk (must be 0-999).
  /// - [includeAnd]: Whether the main `includeAnd` option is set. This affects if "en" is added after "honderd" when `isFinalChunk` is true.
  /// - [isFinalChunk]: Whether this chunk represents the lowest part of the overall number (units/tens/hundreds).
  ///
  /// Returns the chunk represented in Afrikaans words.
  /// Throws [ArgumentError] if `n` is outside the 0-999 range.
  String _convertChunk(int n, bool includeAnd, bool isFinalChunk) {
    if (n == 0)
      return ""; // Empty string for zero chunk (handled in _convertInteger).
    if (n < 0 || n >= 1000) {
      // Internal function, should only receive valid chunks.
      throw ArgumentError(
          "Internal error: _convertChunk requires input between 0 and 999: $n");
    }

    final List<String> words = []; // Stores word parts for this chunk.
    int remainder = n;

    // Handle hundreds place.
    if (remainder >= 100) {
      // Add word for the hundreds digit (e.g., "een" for 100, "twee" for 200).
      words.add(_wordsUnder20[remainder ~/ 100]);
      // Add the word "honderd".
      words.add(_hundred);
      remainder %= 100; // Reduce remainder to 0-99.

      // Conditionally add "en" after "honderd" (e.g., "een honderd en een").
      // This specific "en" is added ONLY if:
      // 1. There's a remaining value (1-99).
      // 2. The global `includeAnd` option is enabled.
      // 3. This chunk is the final part of the entire number being converted.
      if (remainder > 0 && includeAnd && isFinalChunk) {
        words.add(_and);
      }
    }

    // Handle tens and units place (remainder 0-99).
    if (remainder > 0) {
      if (remainder < 20) {
        // Numbers 1-19 have unique words from _wordsUnder20.
        words.add(_wordsUnder20[remainder]);
      } else {
        // Numbers 20-99.
        final String tensWord =
            _wordsTens[remainder ~/ 10]; // e.g., "twintig" for 2x.
        final int unit = remainder % 10; // e.g., 1 for 21.

        if (unit == 0) {
          // Exact tens (20, 30, 40, etc.).
          words.add(tensWord);
        } else {
          // Compound tens/units (e.g., 21 -> "een-en-twintig").
          // Structure: unit_word + "-en-" + tens_word
          // The "-en-" here is standard and not controlled by the `includeAnd` option.
          words.add("${_wordsUnder20[unit]}-$_and-$tensWord");
        }
      }
    }

    // Join the parts (e.g., ["een", "honderd", "en", "vyf"]) with spaces.
    return words.join(' ').trim();
  }
}
