import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/af_options.dart';
import '../options/base_options.dart';
import '../utils/utils.dart';

/// {@template num2text_af}
/// Converts numbers to Afrikaans words (`Lang.AF`).
///
/// Implements [Num2TextBase] for Afrikaans, handling various numeric types.
/// Supports cardinal numbers, decimals, negatives, currency (default ZAR), years,
/// and large numbers (long scale: Miljoen 10^6, Miljard 10^9, Biljoen 10^12, etc.).
/// Customizable via [AfOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextAF implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "nul";
  static const String _point = "punt"; // Decimal separator word (.)
  static const String _comma = "komma"; // Decimal separator word (,)
  static const String _and = "en"; // Conjunction "en"
  static const String _hundred = "honderd";
  static const String _thousand = "duisend";
  static const String _yearSuffixBC = "v.C."; // Suffix voor Christus (BC)
  static const String _yearSuffixAD = "n.C."; // Suffix na Christus (AD)
  static const String _infinity = "Oneindig";
  static const String _notANumber =
      "Nie 'n Nommer Nie"; // Default error message

  /// Number words 0-19.
  static const List<String> _wordsUnder20 = [
    "nul",
    "een",
    "twee",
    "drie",
    "vier",
    "vyf",
    "ses",
    "sewe",
    "agt",
    "nege",
    "tien",
    "elf",
    "twaalf",
    "dertien",
    "veertien",
    "vyftien",
    "sestien",
    "sewentien",
    "agtien",
    "negentien",
  ];

  /// Words for tens (20, 30,... 90). Index corresponds to tens digit.
  static const List<String> _wordsTens = [
    "",
    "",
    "twintig",
    "dertig",
    "veertig",
    "vyftig",
    "sestig",
    "sewentig",
    "tagtig",
    "neëntig",
  ];

  /// Scale words using the long scale (common in Afrikaans).
  /// Index corresponds to steps of 1000 (0=units, 1=10^3, 2=10^6, 3=10^9,...).
  static const List<String> _scaleWords = [
    "", // 10^0
    _thousand, // 10^3
    "miljoen", // 10^6 Million
    "miljard", // 10^9 Milliard (Thousand Million)
    "biljoen", // 10^12 Billion
    "biljard", // 10^15
    "triljoen", // 10^18
    "triljard", // 10^21
    "kwadriljoen", // 10^24
    "kwadriljard", // 10^27
  ];

  /// Processes the given [number] into Afrikaans words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Applies formatting based on [AfOptions] (currency, year, decimals, AD/BC, rounding).
  /// Uses defaults if [options] is null or not [AfOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or default error on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [AfOptions] settings.
  /// @param fallbackOnError Optional custom error string.
  /// @return The number as Afrikaans words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final AfOptions afOptions =
        options is AfOptions ? options : const AfOptions();
    final String errorMsg = fallbackOnError ?? _notANumber;

    // Handle non-finite doubles early.
    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Negatief $_infinity" : _infinity;
      if (number.isNaN) return errorMsg;
    }

    // Normalize to Decimal for precision.
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorMsg; // Handle invalid input.

    // Handle zero specifically.
    if (decimalValue == Decimal.zero) {
      return afOptions.currency
          ? "$_zero ${afOptions.currencyInfo.mainUnitPlural ?? afOptions.currencyInfo.mainUnitSingular}" // Use plural currency unit for 0.
          : _zero;
    }

    // Process the absolute value and handle sign separately.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    // Delegate based on format options.
    if (afOptions.format == Format.year) {
      // Year formatting handles its own sign (BC/AD).
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), afOptions);
    } else {
      // Convert currency or standard number.
      textResult = afOptions.currency
          ? _handleCurrency(absValue, afOptions)
          : _handleStandardNumber(absValue, afOptions);
      // Add negative prefix if needed.
      if (isNegative) {
        textResult = "${afOptions.negativePrefix} $textResult";
      }
    }
    // Ensure single spaces and remove leading/trailing whitespace.
    return textResult.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Converts an integer year to Afrikaans words, handling common phrasing.
  ///
  /// Implements pair reading for years like 1984 ("negentien vier-en-tagtig")
  /// and centuries like 1900 ("negentien honderd") within a typical range (1100-2099).
  /// Uses standard conversion for years outside this range.
  /// Appends AD/BC suffixes based on [AfOptions.includeAD].
  ///
  /// @param year The integer year.
  /// @param options Formatting options.
  /// @return The year as Afrikaans words.
  String _handleYearFormat(int year, AfOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;
    String yearText;

    // Threshold for switching from pair reading to standard conversion.
    const int pairReadingThreshold = 2100;

    if (absYear == 0) {
      yearText = _zero;
    } else if (absYear < 1000) {
      // Years < 1000: standard conversion, no 'en' between major parts.
      yearText = _convertInteger(BigInt.from(absYear), false);
    } else if (absYear == 1000) {
      yearText = "een duisend"; // Specific phrasing.
    } else if (absYear == 2000) {
      yearText = "twee duisend"; // Specific phrasing.
    } else if (absYear > 2000 && absYear < 2010) {
      // Years 2001-2009: standard conversion, includes 'en'.
      yearText = _convertInteger(BigInt.from(absYear), true);
    } else if (absYear >= pairReadingThreshold) {
      // Years >= threshold: standard conversion, no 'en' between major parts.
      yearText = _convertInteger(BigInt.from(absYear), false);
    } else if (absYear % 100 == 0 && absYear >= 1100) {
      // Centuries within pair-reading range (e.g., 1100, 1900).
      final int highPartInt = absYear ~/ 100; // e.g., 11, 19.
      final String highText =
          _convertChunk(highPartInt, false); // Convert century number.
      yearText =
          "$highText $_hundred"; // e.g., "elf honderd", "negentien honderd".
    } else if (absYear >= 1001) {
      // Non-centuries within pair-reading range (e.g., 1984, 1101, 2023).
      final int highPartInt = absYear ~/ 100; // e.g., 19, 11, 20.
      final int lowPartInt = absYear % 100; // e.g., 84, 01, 23.
      final String highText =
          _convertChunk(highPartInt, false); // Convert first pair part.
      final String lowText = _convertChunk(
          lowPartInt, true); // Convert second pair part (uses 'en' internally).
      yearText =
          "$highText $lowText"; // Combine parts, e.g., "negentien vier-en-tagtig".
    } else {
      // Fallback (should not be needed with current logic).
      yearText = _convertInteger(BigInt.from(absYear), false);
    }

    // Add era suffixes if requested.
    if (isNegative) {
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD && absYear > 0) {
      yearText += " $_yearSuffixAD";
    }

    return yearText.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Converts a non-negative integer ([BigInt]) into Afrikaans words (long scale).
  ///
  /// Breaks the number into chunks of 1000. Converts chunks via [_convertChunk].
  /// Adds scale words ("duisend", "miljoen", "miljard", etc.).
  /// The `useStandardEnRules` parameter controls the insertion of "en"
  /// *between* major parts (e.g., before the final 1-99 part).
  ///
  /// @param n Non-negative integer.
  /// @param useStandardEnRules If true, inserts "en" according to standard rules.
  /// @throws ArgumentError if [n] is negative or exceeds defined scales.
  /// @return Integer as Afrikaans words.
  String _convertInteger(BigInt n, bool useStandardEnRules) {
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n == BigInt.zero) return _zero;

    final BigInt oneThousand = BigInt.from(1000);
    if (n < oneThousand) {
      // Numbers 0-999 handled by _convertChunk.
      return _convertChunk(n.toInt(), useStandardEnRules);
    }

    List<String> parts = []; // Stores converted chunks with scale words.
    int scaleIndex =
        0; // Tracks the current scale level (0=units, 1=thousand, ...).
    BigInt remaining = n; // Remaining value to process.

    // Process the number in chunks of 1000 from right to left.
    while (remaining > BigInt.zero) {
      if (scaleIndex >= _scaleWords.length)
        throw ArgumentError("Number too large: $n");

      final BigInt chunkValue =
          remaining % oneThousand; // Current chunk (0-999).
      remaining ~/= oneThousand; // Update remaining value.

      if (chunkValue > BigInt.zero) {
        // Convert the non-zero chunk (0-999).
        // Pass 'useStandardEnRules' down to handle 'en' *within* the chunk (e.g., "honderd en een").
        final String chunkText =
            _convertChunk(chunkValue.toInt(), useStandardEnRules);
        final String scaleWord =
            _scaleWords[scaleIndex]; // Get scale word (e.g., "miljoen").
        // Combine chunk text and scale word.
        final String part =
            scaleWord.isNotEmpty ? "$chunkText $scaleWord" : chunkText;
        parts.insert(
            0, part); // Add to the beginning to maintain correct order.
      }
      scaleIndex++; // Move to the next scale level.
    }

    // Join the parts, inserting " en " between major components where applicable.
    String result = "";
    for (int i = 0; i < parts.length; i++) {
      result += parts[i];
      // Check if 'en' is needed before the *next* part.
      if (i < parts.length - 1) {
        final BigInt lastChunkValue =
            n % oneThousand; // Original number's last chunk (0-999).
        final bool isBeforeLastPart =
            (i == parts.length - 2); // Is this the second-to-last part?
        final bool lastChunkIsSmall = lastChunkValue > BigInt.zero &&
            lastChunkValue < BigInt.from(100); // Is the last chunk 1-99?

        // Add " en " between major parts (e.g., "...duisend en vyftig")
        // only if standard 'en' rules are enabled AND this is right before the last part AND that last part is 1-99.
        if (useStandardEnRules && isBeforeLastPart && lastChunkIsSmall) {
          result += " $_and ";
        } else {
          result += " "; // Default separator between parts is a space.
        }
      }
    }
    return result.trim();
  }

  /// Converts an integer from 0 to 999 into Afrikaans words.
  ///
  /// Handles hundreds ("honderd"), tens, and units. Formats 24 as "vier-en-twintig".
  /// Correctly omits "een" for 100 ("honderd").
  /// Uses `useStandardEnRules` to insert "en" between hundreds and a remainder of 1-99.
  ///
  /// @param n Integer chunk (0-999).
  /// @param useStandardEnRules If true, inserts "en" after hundreds if remainder is 1-99.
  /// @return Chunk as Afrikaans words, or empty string if [n] is 0.
  String _convertChunk(int n, bool useStandardEnRules) {
    if (n == 0) return ""; // Zero contributes nothing within a larger number.
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    List<String> words = []; // Stores word components.
    int remainder = n; // Value remaining to be converted.

    // Handle hundreds part.
    if (remainder >= 100) {
      // Add digit word only if > 1 (e.g., "twee", "drie", ... but not "een" for 100).
      if (remainder ~/ 100 > 1) {
        words.add(_wordsUnder20[remainder ~/ 100]);
      }
      words.add(_hundred); // Always add "honderd".
      remainder %= 100; // Update remainder to 0-99.

      // Add "en" after "honderd" if rules apply AND there is a non-zero remainder (1-99).
      if (useStandardEnRules && remainder > 0) {
        words.add(_and);
      }
    }

    // Handle remaining part (1-99).
    if (remainder > 0) {
      if (remainder < 20) {
        // Numbers 1-19 are direct lookups.
        words.add(_wordsUnder20[remainder]);
      } else {
        // Numbers 20-99.
        final String tensWord = _wordsTens[remainder ~/ 10]; // e.g., "twintig".
        final int unit = remainder % 10;
        if (unit == 0) {
          // Pure tens (20, 30,...).
          words.add(tensWord);
        } else {
          // Compound numbers (21-99), format as "Unit-en-Tens".
          // "en" is always used in this hyphenated form.
          words.add(
              "${_wordsUnder20[unit]}-$_and-$tensWord"); // e.g., "vier-en-tagtig".
        }
      }
    }
    return words.join(' '); // Combine parts with spaces.
  }

  /// Converts a positive [Decimal] value to Afrikaans currency words.
  ///
  /// Uses [AfOptions.currencyInfo] for unit names/separator. Rounds if specified.
  /// Applies standard cardinal number rules (including "en").
  ///
  /// @param absValue Positive currency amount.
  /// @param options [AfOptions] for currency settings.
  /// @return Currency value as Afrikaans words.
  String _handleCurrency(Decimal absValue, AfOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    // Round to 2 decimal places if requested.
    final Decimal val = options.round ? absValue.round(scale: 2) : absValue;
    final BigInt mainVal =
        val.truncate().toBigInt(); // Integer part (e.g., Rand).
    // Calculate subunit value (e.g., cents).
    final BigInt subVal = ((val - val.truncate()) * Decimal.fromInt(100))
        .round(scale: 0)
        .toBigInt();

    String mainPart = "";
    // Convert main currency amount if > 0.
    if (mainVal > BigInt.zero) {
      // Use standard conversion rules (includes 'en').
      final String mainText = _convertInteger(mainVal, true);
      // Select singular/plural unit name.
      final String name = (mainVal == BigInt.one)
          ? info.mainUnitSingular
          : (info.mainUnitPlural ??
              info.mainUnitSingular); // Fallback to singular if plural is null.
      mainPart = '$mainText $name';
    }

    String subPart = "";
    // Convert subunit amount if > 0 and subunit is defined.
    if (subVal > BigInt.zero && info.subUnitSingular != null) {
      // Use standard conversion rules (includes 'en').
      final String subText = _convertInteger(subVal, true);
      // Select singular/plural subunit name.
      final String name = (subVal == BigInt.one)
          ? info.subUnitSingular! // Assert non-null as checked above.
          : (info.subUnitPlural ?? info.subUnitSingular!); // Fallback.
      subPart = '$subText $name';
    }

    // Combine main and subunit parts.
    if (mainPart.isNotEmpty && subPart.isNotEmpty) {
      // Use currency separator from options or default to " en ".
      String sep = info.separator ?? _and;
      sep = sep.trim() == _and
          ? " $_and "
          : " ${sep.trim()} "; // Ensure spaces around separator.
      return '$mainPart$sep$subPart';
    } else if (mainPart.isNotEmpty) {
      return mainPart; // Only main part.
    } else if (subPart.isNotEmpty) {
      return subPart; // Only subunit part (e.g., "vyftig sent").
    } else {
      // Value was zero or rounded to zero.
      return "$_zero ${info.mainUnitPlural ?? info.mainUnitSingular}";
    }
  }

  /// Converts a positive [Decimal] to standard Afrikaans cardinal words, including decimals.
  ///
  /// Converts integer part using standard rules (incl. "en"). Appends fractional
  /// part read digit by digit after the separator ("komma" or "punt") from [AfOptions].
  /// Removes trailing fractional zeros.
  ///
  /// @param absValue The positive number.
  /// @param options [AfOptions] for decimal separator word.
  /// @return The number formatted as Afrikaans words.
  String _handleStandardNumber(Decimal absValue, AfOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part using standard rules (includes 'en').
    // If integer is 0 but fraction exists, start with "nul".
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, true);

    String fractionalWords = '';
    // Process fractional part if it exists.
    if (fractionalPart > Decimal.zero && !absValue.isInteger) {
      // Determine separator word based on options.
      final String sepWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          sepWord = _point;
          break;
        default:
          sepWord = _comma;
          break; // Default is comma.
      }

      // Get fractional digits from string, remove trailing zeros.
      final String fracDigits =
          absValue.toString().split('.').last.replaceAll(RegExp(r'0+$'), '');
      // If digits remain after trimming zeros...
      if (fracDigits.isNotEmpty) {
        // Convert each digit to its word form.
        final List<String> digitWords = fracDigits.split('').map((d) {
          final int? i = int.tryParse(d);
          return (i != null && i >= 0 && i <= 9)
              ? _wordsUnder20[i]
              : '?'; // Lookup digit word.
        }).toList();
        // Combine separator and digit words.
        fractionalWords = ' $sepWord ${digitWords.join(' ')}';
      }
    }
    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }
}
