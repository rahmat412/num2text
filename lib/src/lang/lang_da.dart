import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/da_options.dart';
import '../utils/utils.dart';

/// {@template num2text_da}
/// The Danish language (Lang.DA) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Danish word representation following Danish grammar and conventions.
///
/// Capabilities include handling cardinal numbers, currency (using [DaOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (short scale: tusind, million, milliard).
/// Special features include vigesimal elements (e.g., "halvtreds" for 50) and the use of "og" (and).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [DaOptions].
/// {@endtemplate}
class Num2TextDA implements Num2TextBase {
  // --- Constants ---

  /// The word for zero.
  static const String _zero = "nul";

  /// The neuter form of 'one'. Used as default and for general counting.
  static const String _oneNeuter = "et";

  /// The common gender form of 'one'. Used for currency main unit (krone) and large scale units (million, milliard, etc.).
  static const String _oneCommon = "en";

  /// The conjunction "and", used in numbers like 21 ("enogtyve") and between hundreds/thousands and smaller units.
  static const String _andConjunction = "og";

  /// Default word for the decimal separator (comma).
  static const String _defaultDecimalSeparatorWord = "komma";

  /// Word for the decimal separator when period/point is specified.
  static const String _pointWord = "punktum";

  /// Suffix for BC/BCE years ("før Kristus").
  static const String _yearSuffixBC = "f.Kr.";

  /// Suffix for AD/CE years ("efter Kristus").
  static const String _yearSuffixAD = "e.Kr.";

  /// Word for hundred.
  static const String _hundred = "hundrede";

  /// Word for thousand.
  static const String _thousand = "tusind";

  /// Word for positive infinity.
  static const String _infinityPositive = "Uendelig";

  /// Word for negative infinity.
  static const String _infinityNegative = "Negativ Uendelig";

  /// Word for "Not a Number".
  static const String _notANumber = "Ikke et tal";

  /// Words for numbers 0-19. Note: Index 1 is the neuter form "et".
  static const List<String> _wordsUnder20 = [
    _zero,
    _oneNeuter, // 1
    "to", // 2
    "tre", // 3
    "fire", // 4
    "fem", // 5
    "seks", // 6
    "syv", // 7
    "otte", // 8
    "ni", // 9
    "ti", // 10
    "elleve", // 11
    "tolv", // 12
    "tretten", // 13
    "fjorten", // 14
    "femten", // 15
    "seksten", // 16
    "sytten", // 17
    "atten", // 18
    "nitten", // 19
  ];

  /// Words for tens (20, 30,... 90). Note the vigesimal influence from 50 onwards.
  static const List<String> _wordsTens = [
    "", // 0 - not used directly
    "", // 10 - handled by _wordsUnder20
    "tyve", // 20
    "tredive", // 30
    "fyrre", // 40
    "halvtreds", // 50 (half-third score)
    "tres", // 60 (threescore)
    "halvfjerds", // 70 (half-fourth score)
    "firs", // 80 (fourscore)
    "halvfems", // 90 (half-fifth score)
  ];

  /// Scale words (singular form). Used for 1 million, 1 milliard, etc.
  static const Map<int, String> _scaleWordsSingular = {
    6: "million",
    9: "milliard",
    12: "billion",
    15: "billiard",
    18: "trillion",
    21: "trilliard",
    24: "kvadrillion",
    // Add more scales if needed
  };

  /// Scale words (plural form). Used for 2+ million, 2+ milliarder, etc.
  static const Map<int, String> _scaleWordsPlural = {
    6: "millioner",
    9: "milliarder",
    12: "billioner",
    15: "billiarder",
    18: "trillioner",
    21: "trilliarder",
    24: "kvadrillioner",
    // Add more scales if needed
  };

  /// {@macro num2text_base_process}
  ///
  /// Supported [options] for Danish:
  /// - [DaOptions.currency]: Formats the number as Danish Krone (DKK).
  /// - [DaOptions.format]: Specifically handles [Format.year].
  /// - [DaOptions.decimalSeparator]: Specifies the word for the decimal point ([DecimalSeparator.comma] or [DecimalSeparator.period]/[DecimalSeparator.point]).
  /// - [DaOptions.negativePrefix]: Word used before negative numbers (defaults to "minus").
  /// - [DaOptions.includeAD]: Adds AD/BC suffix for years.
  /// - [DaOptions.currencyInfo]: Allows specifying custom currency details.
  /// - [DaOptions.round]: Rounds the number before currency conversion.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure options are of the correct type or use defaults.
    final DaOptions daOptions =
        options is DaOptions ? options : const DaOptions();
    final String errorFallback = fallbackOnError ?? _notANumber;

    // Handle special double values first.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? _infinityNegative : _infinityPositive;
      }
      if (number.isNaN) {
        return errorFallback;
      }
    }

    // Normalize the input number to Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Handle null or unparseable input.
    if (decimalValue == null) {
      return errorFallback;
    }

    // Handle zero separately for simplicity and currency formatting.
    if (decimalValue == Decimal.zero) {
      if (daOptions.currency) {
        // Zero currency is "nul kroner" (plural form).
        final String mainUnit = daOptions.currencyInfo.mainUnitPlural ??
            daOptions.currencyInfo.mainUnitSingular;
        return "$_zero $mainUnit";
      } else {
        // Standard zero or year zero.
        return _zero;
      }
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for core conversion logic.
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Delegate to specific handlers based on options.
    if (daOptions.format == Format.year) {
      // Year formatting has special rules.
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), daOptions);
    } else if (daOptions.currency) {
      // Currency formatting involves units and subunits.
      textResult = _handleCurrency(absValue, daOptions);
      // Add negative prefix *after* currency formatting.
      if (isNegative) {
        textResult = "${daOptions.negativePrefix} $textResult";
      }
    } else {
      // Standard number conversion (integer or decimal).
      textResult = _handleStandardNumber(absValue, daOptions);
      // Add negative prefix *after* standard formatting.
      if (isNegative) {
        textResult = "${daOptions.negativePrefix} $textResult";
      }
    }

    return textResult;
  }

  /// Handles formatting for years according to Danish conventions.
  ///
  /// - Years 1100-1999 are often pronounced like "nineteen hundred".
  /// - Adds "f.Kr." (BC) or "e.Kr." (AD) suffixes if requested.
  ///
  /// [year]: The integer year value (can be negative).
  /// [options]: The Danish formatting options.
  /// Returns the year formatted as words.
  String _handleYearFormat(int year, DaOptions options) {
    final bool isNegative = year < 0;
    // Use absolute value for conversion part.
    final int absYear = isNegative ? -year : year;

    if (absYear == 0) {
      // Should technically not happen due to check in `process`, but handle defensively.
      return _zero;
    }

    String yearText;

    // Special rule for years 1100-1999: "X hundred [og Y]"
    if (absYear >= 1100 && absYear < 2000) {
      final int highPartInt = absYear ~/ 100; // e.g., 19 for 1984
      final int lowPartInt = absYear % 100; // e.g., 84 for 1984

      // Convert the "century" part (e.g., "nitten"). Use "et" form for 1.
      final String highText = _convertInteger(BigInt.from(highPartInt), false);

      if (lowPartInt == 0) {
        // e.g., 1900 -> "nitten hundrede"
        yearText = "$highText $_hundred";
      } else {
        // e.g., 1984 -> "nitten hundrede og fireogfirs"
        // Use "et" form for 1 in the low part.
        final String lowText = _convertInteger(BigInt.from(lowPartInt), false);
        yearText = "$highText $_hundred $_andConjunction $lowText";
      }
    } else {
      // Standard conversion for other years. Use "et" form for 1.
      yearText = _convertInteger(BigInt.from(absYear), false);
    }

    // Add suffixes if needed.
    if (isNegative) {
      // Negative years always get the BC suffix.
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD && absYear > 0) {
      // Positive years get the AD suffix only if explicitly requested and not zero.
      yearText += " $_yearSuffixAD";
    }

    return yearText;
  }

  /// Handles formatting for currency values.
  ///
  /// Separates the main unit (kroner) and subunit (øre).
  /// Uses singular/plural forms from [CurrencyInfo].
  /// Applies rounding if specified in [options].
  /// Uses "en krone" for 1 krone.
  ///
  /// [absValue]: The absolute decimal value of the currency.
  /// [options]: The Danish formatting options, including currency info.
  /// Returns the currency value formatted as words.
  String _handleCurrency(Decimal absValue, DaOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    // Danish currency has 2 decimal places (øre).
    const int decimalPlaces = 2;
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value *before* splitting if requested.
    final Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate integer (main unit) and fractional (subunit) parts.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    // Use precise Decimal arithmetic
    final Decimal fractionalPart =
        valueToConvert - Decimal.fromBigInt(mainValue);
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).truncate().toBigInt();

    // Convert the main unit part. Use "en" for 1 krone.
    final String mainText =
        _convertInteger(mainValue, true); // useCommonOne = true for krone

    // Determine the correct main unit name (singular or plural).
    // Assumes CurrencyInfo.dkk provides non-null plural.
    final String mainUnitName = mainValue == BigInt.one
        ? currencyInfo.mainUnitSingular
        : currencyInfo.mainUnitPlural!;

    String result = '$mainText $mainUnitName';

    // Add subunit part if it exists.
    if (subunitValue > BigInt.zero) {
      // Convert the subunit value. Use standard "et" for 1 øre.
      final String subunitText = _convertInteger(
        subunitValue,
        false,
      ); // useCommonOne = false for øre

      // Determine the correct subunit name (singular or plural).
      // Assumes CurrencyInfo.dkk provides non-null singular and plural for subunits.
      final String subUnitName = subunitValue == BigInt.one
          ? currencyInfo.subUnitSingular!
          : currencyInfo.subUnitPlural!;

      // Combine with separator.
      final String separator = currencyInfo.separator ?? _andConjunction;
      result += ' $separator $subunitText $subUnitName';
    }

    return result;
  }

  /// Handles standard number conversion (integers or decimals without special formatting).
  ///
  /// Converts the integer part and the fractional part separately.
  /// Joins fractional digits with the specified decimal separator word.
  /// Trims trailing zeros for decimal representation.
  ///
  /// [absValue]: The absolute decimal value of the number.
  /// [options]: The Danish formatting options.
  /// Returns the number formatted as words.
  String _handleStandardNumber(Decimal absValue, DaOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    // Use precise Decimal subtraction
    final Decimal fractionalPart = absValue - Decimal.fromBigInt(integerPart);

    // Convert the integer part. Use "nul" if integer is zero but there's a fractional part.
    // Use standard "et" for 1.
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, false);

    String fractionalWords = '';
    // Process fractional part only if it's greater than zero.
    if (fractionalPart > Decimal.zero) {
      final String separatorWord;
      // Choose the decimal separator word based on options.
      switch (options.decimalSeparator) {
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          separatorWord = _pointWord;
          break;
        case DecimalSeparator.comma:
        default: // Default to comma for Danish
          separatorWord = _defaultDecimalSeparatorWord;
          break;
      }

      // Get the digits after the decimal point, remove leading '0.'
      String fractionalDigits = fractionalPart.toString();
      if (fractionalDigits.startsWith('0.')) {
        fractionalDigits = fractionalDigits.substring(2);
      } else if (fractionalDigits.contains('.')) {
        // Fallback if format is unexpected
        fractionalDigits = fractionalDigits.split('.').last;
      }
      // Trim trailing zeros
      fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      if (fractionalDigits.isNotEmpty) {
        // Convert each digit individually. Use standard "et" for 1.
        final List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          // Ensure valid digits 0-9 are converted.
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder20[digitInt] // Use standard neuter "et"
              : '?'; // Use '?' for unexpected characters
        }).toList();

        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }
    // No special handling needed for integers represented as decimals (e.g., 123.0).
    // The check `fractionalPart > Decimal.zero` correctly handles this.

    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer into Danish words.
  ///
  /// Handles large numbers by breaking them into chunks of 1000.
  /// Applies scale words (thousand, million, etc.) appropriately.
  /// Uses "en" for scale units (e.g., "en million") and "et" for 1000 ("et tusind").
  ///
  /// [n]: The non-negative integer to convert.
  /// [useCommonOneForFinalChunk]: If true, uses "en" instead of "et" if the final chunk (0-999) is 1. (Used for currency main unit).
  /// Returns the integer formatted as words.
  String _convertInteger(BigInt n, bool useCommonOneForFinalChunk) {
    if (n == BigInt.zero) return _zero;
    // Ensure input is non-negative (internal helper).
    if (n < BigInt.zero) {
      throw ArgumentError(
          "Internal error: _convertInteger called with negative number: $n");
    }

    // Handle numbers less than 1000 directly via _convertChunk.
    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt(), useCommonOneForFinalChunk);
    }

    final List<String> parts = [];
    String lastChunkText = "";
    int lastChunkValue = 0;
    final BigInt oneThousand = BigInt.from(1000);
    int scalePower = 0; // 0 for 10^0, 3 for 10^3, 6 for 10^6, etc.
    BigInt remaining = n;

    // Process the number in chunks of 1000 from right to left.
    while (remaining > BigInt.zero) {
      final int chunk = (remaining % oneThousand).toInt();
      remaining ~/= oneThousand;

      if (chunk > 0) {
        if (scalePower == 0) {
          // This is the last chunk (least significant 0-999 part).
          lastChunkValue = chunk;
          // Determine if "en" should be used for this final chunk (only if it's 1 and requested by currency).
          lastChunkText = _convertChunk(chunk, useCommonOneForFinalChunk);
        } else {
          // This is a higher scale chunk (thousands, millions, etc.).
          // Determine if "en" should be used for this chunk (always for scales >= million if chunk is 1).
          // Thousands scale uses "et".
          final bool chunkUsesCommonOne = (scalePower >= 6);
          final String scaleChunkText =
              _convertChunk(chunk, chunkUsesCommonOne);

          if (scalePower == 3) {
            // Thousands scale. Use "et tusind" for 1000.
            if (chunk == 1) {
              parts.add("$_oneNeuter $_thousand"); // "et tusind"
            } else {
              parts.add("$scaleChunkText $_thousand"); // e.g., "to tusind"
            }
          } else if (scalePower > 3 &&
              _scaleWordsSingular.containsKey(scalePower)) {
            // Higher scales (million, billion, etc.).
            final String scaleWordSingular = _scaleWordsSingular[scalePower]!;
            final String scaleWordPlural = _scaleWordsPlural[scalePower]!;
            if (chunk == 1) {
              // Use "en" for singular scale units (e.g., "en million").
              parts.add("$_oneCommon $scaleWordSingular");
            } else {
              parts.add(
                  "$scaleChunkText $scaleWordPlural"); // e.g., "to millioner"
            }
          }
          // Silently ignore scales larger than defined in _scaleWordsSingular/Plural.
        }
      }
      scalePower += 3;
    }

    // Combine the parts in the correct order (most significant first).
    final List<String> resultParts = [];
    if (parts.isNotEmpty) {
      resultParts.addAll(parts.reversed); // Add higher scale parts first.
    }

    // Add "og" before the last chunk if needed (e.g., "en million og et")
    // only if the last chunk is less than 100.
    if (resultParts.isNotEmpty && lastChunkValue > 0 && lastChunkValue < 100) {
      resultParts.add(_andConjunction);
    }

    // Add the last chunk (0-999 part).
    if (lastChunkText.isNotEmpty) {
      resultParts.add(lastChunkText);
    }

    return resultParts.join(' ');
  }

  /// Converts an integer between 0 and 999 into Danish words.
  ///
  /// This is the core building block for number conversion.
  /// Handles hundreds, tens (including vigesimal forms), and units.
  /// Uses "og" correctly (e.g., "et hundrede og et", "enogtyve").
  ///
  /// [n]: The integer between 0 and 999.
  /// [useCommonOne]: If true, uses "en" instead of "et" when the number is 1.
  /// Returns the chunk formatted as words, or an empty string if n is 0.
  /// Throws [ArgumentError] if n is outside the valid range [0, 999].
  String _convertChunk(int n, bool useCommonOne) {
    if (n == 0) return ""; // Return empty string for zero chunk.
    // Validate input range.
    if (n < 0 || n >= 1000) {
      throw ArgumentError(
          "Internal error: _convertChunk called with value outside [0, 999]: $n");
    }

    final List<String> words = [];
    int remainder = n;
    bool processedHundreds = false;

    // Handle hundreds place.
    if (remainder >= 100) {
      final int hundredsDigit = remainder ~/ 100;
      // Hundreds digit uses standard numbers 1-9 ("et" to "ni"). Use "et" for 100.
      words.add(_wordsUnder20[hundredsDigit]);
      words.add(_hundred);
      remainder %= 100;
      processedHundreds = true;
    }

    // Handle remaining tens and units (0-99).
    if (remainder > 0) {
      // Add "og" after hundreds if there's a non-zero remainder.
      if (processedHundreds) {
        words.add(_andConjunction); // e.g., "et hundrede OG et"
      }

      if (remainder < 20) {
        // Numbers 1-19.
        String word = _wordsUnder20[remainder];
        // Apply common 'one' if needed.
        if (useCommonOne && remainder == 1) {
          word = _oneCommon; // Use "en"
        }
        words.add(word);
      } else {
        // Numbers 20-99.
        final int unit = remainder % 10;
        final int tensDigit = remainder ~/ 10;
        final String tensWord =
            _wordsTens[tensDigit]; // e.g., "tyve", "halvtreds"

        if (unit == 0) {
          // Exact tens (20, 30, ..., 90).
          words.add(tensWord);
        } else {
          // Combined tens and units (e.g., 21, 53).
          // Unit word (1-9).
          String unitWord = _wordsUnder20[unit];
          // Use "en" for the unit '1' in compound numbers like 21, 31,... 91.
          if (unit == 1) {
            unitWord = _oneCommon; // "en"
          }
          // Combine as "unit + og + tens" (e.g., "enogtyve").
          words.add("$unitWord$_andConjunction$tensWord");
        }
      }
    }

    return words.join(' ');
  }
}
