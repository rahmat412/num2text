import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/cs_options.dart';
import '../utils/utils.dart';

/// {@template num2text_cs}
/// The Czech language (Lang.CS) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Czech word representation following standard Czech grammar, including
/// grammatical gender agreement (masculine, feminine, neuter) and number declension.
///
/// Capabilities include handling cardinal numbers, currency (using [CsOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (short scale: tisíc, milion, miliarda).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [CsOptions].
/// {@endtemplate}
class Num2TextCS implements Num2TextBase {
  /// The word for zero.
  static const String _zero = "nula";

  /// The default word used to separate the integer and fractional parts of a decimal number ("whole").
  static const String _defaultDecimalSeparatorWord = "celá";

  /// The word used for the decimal point when [DecimalSeparator.period] or [DecimalSeparator.point] is specified ("dot").
  static const String _pointWord = "tečka";

  /// The suffix appended to negative years (Before Christ / před naším letopočtem).
  static const String _yearSuffixBC = "př. n. l.";

  /// The suffix appended to positive years when `includeAD` is true (Anno Domini / našeho letopočtu).
  static const String _yearSuffixAD = "n. l.";

  /// Words for numbers 0-19 (using feminine/neuter form for 1 and 2 as a common default).
  static const List<String> _wordsUnder20 = [
    _zero, // 0
    "jedna", // 1 (feminine/neuter default)
    "dvě", // 2 (feminine/neuter default)
    "tři", // 3
    "čtyři", // 4
    "pět", // 5
    "šest", // 6
    "sedm", // 7
    "osm", // 8
    "devět", // 9
    "deset", // 10
    "jedenáct", // 11
    "dvanáct", // 12
    "třináct", // 13
    "čtrnáct", // 14
    "patnáct", // 15
    "šestnáct", // 16
    "sedmnáct", // 17
    "osmnáct", // 18
    "devatenáct", // 19
  ];

  /// Masculine forms for 0, 1, 2.
  static const List<String> _wordsUnder3Masculine = [_zero, "jeden", "dva"];

  /// Feminine forms for 0, 1, 2.
  static const List<String> _wordsUnder3Feminine = [_zero, "jedna", "dvě"];

  /// Neuter forms for 0, 1, 2.
  static const List<String> _wordsUnder3Neuter = [_zero, "jedno", "dvě"];

  /// Words for tens (20, 30,... 90). Index corresponds to the tens digit (index 2 is "dvacet").
  static const List<String> _wordsTens = [
    "", // 0 (unused)
    "", // 1 (covered by _wordsUnder20)
    "dvacet", // 20
    "třicet", // 30
    "čtyřicet", // 40
    "padesát", // 50
    "šedesát", // 60
    "sedmdesát", // 70
    "osmdesát", // 80
    "devadesát", // 90
  ];

  /// Words for hundreds (100, 200,... 900). Index corresponds to the hundreds digit (index 1 is "sto").
  static const List<String> _wordsHundreds = [
    "", // 0 (unused)
    "sto", // 100
    "dvě stě", // 200
    "tři sta", // 300
    "čtyři sta", // 400
    "pět set", // 500
    "šest set", // 600
    "sedm set", // 700
    "osm set", // 800
    "devět set", // 900
  ];

  /// Defines scale words (thousand, million, etc.) and their grammatical forms.
  /// Key: exponent of 10 (3 for thousand, 6 for million, etc.)
  /// Value: List containing:
  ///   [0]: Singular form (used for 1) - e.g., "tisíc"
  ///   [1]: Plural form (used for 2-4) - e.g., "tisíce"
  ///   [2]: Genitive plural form (used for 0, 5+) - e.g., "tisíc"
  ///   [3]: Grammatical [Gender] of the scale word itself, affecting the preceding number (1 or 2).
  static const Map<int, List<dynamic>> _scaleWords = {
    3: ["tisíc", "tisíce", "tisíc", Gender.masculine], // Thousand (10^3)
    6: ["milion", "miliony", "milionů", Gender.masculine], // Million (10^6)
    9: [
      "miliarda",
      "miliardy",
      "miliard",
      Gender.feminine
    ], // Billion (short scale, 10^9)
    12: [
      "bilion",
      "biliony",
      "bilionů",
      Gender.masculine
    ], // Trillion (short scale, 10^12)
    15: [
      "biliarda",
      "biliardy",
      "biliard",
      Gender.feminine
    ], // Quadrillion (short scale, 10^15)
    18: [
      "trilion",
      "triliony",
      "trilionů",
      Gender.masculine
    ], // Quintillion (short scale, 10^18)
    21: [
      "triliarda",
      "triliardy",
      "triliard",
      Gender.feminine
    ], // Sextillion (short scale, 10^21)
    24: [
      "kvadrilion",
      "kvadriliony",
      "kvadrilionů",
      Gender.masculine,
    ], // Septillion (short scale, 10^24)
    // Add more scales as needed following the pattern
  };

  /// {@macro num2text_base_process}
  ///
  /// [number]: The number to convert (e.g., `123`, `123.45`, `BigInt.from(1000000)`).
  /// [options]: Optional [CsOptions] to control formatting (e.g., currency, year, gender).
  /// [fallbackOnError]: Optional string to return if the input is invalid or conversion fails.
  /// Returns the number converted to Czech words, or an error/fallback string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure options are of the correct type or use default.
    final CsOptions csOptions =
        options is CsOptions ? options : const CsOptions();
    final String errorMsg = fallbackOnError ?? "Není číslo"; // Default fallback

    // Handle special double values first
    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Záporné nekonečno" : "Nekonečno";
      if (number.isNaN) return errorMsg;
    }

    // Normalize input to Decimal for consistent handling
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null)
      return errorMsg; // Handle null, non-numeric strings, etc.

    // Handle zero separately
    if (decimalValue == Decimal.zero) {
      // Special case for currency: "nula [currency name genitive plural]"
      if (csOptions.currency) {
        // Ensure pluralGenitive exists, fallback to singular if not (though CZK defines it)
        final String zeroCurrencyForm =
            csOptions.currencyInfo.mainUnitPluralGenitive ??
                csOptions.currencyInfo.mainUnitSingular;
        return "$_zero $zeroCurrencyForm";
      }
      // Year format zero is just "nula"
      if (csOptions.format == Format.year) return _zero;
      // Standard zero
      return _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for core conversion
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Route to specific handlers based on options
    if (csOptions.format == Format.year) {
      // Year format uses the integer part and handles sign internally
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), csOptions);
    } else if (csOptions.currency) {
      // Currency format
      textResult = _handleCurrency(absValue, csOptions);
      // Apply negative prefix if applicable *after* currency formatting
      if (isNegative) {
        textResult = "${csOptions.negativePrefix} $textResult";
      }
    } else {
      // Standard number format (integer or decimal)
      textResult = _handleStandardNumber(absValue, csOptions);
      // Apply negative prefix if applicable
      if (isNegative) {
        textResult = "${csOptions.negativePrefix} $textResult";
      }
    }

    return textResult;
  }

  /// Handles formatting a number as a year.
  ///
  /// [year]: The integer year value.
  /// [options]: The [CsOptions] containing formatting flags like `includeAD`.
  /// Returns the year converted to Czech words with appropriate era suffixes.
  String _handleYearFormat(int year, CsOptions options) {
    final bool isNegative = year < 0;
    final int absYearInt = isNegative ? -year : year;
    final BigInt absYear = BigInt.from(absYearInt);

    // Determine gender for the number part of the year.
    // Year 1 is feminine ("jedna př. n. l."), others are masculine.
    final Gender yearGender =
        (absYearInt == 1) ? Gender.feminine : Gender.masculine;
    String yearText = _convertInteger(absYear, yearGender);

    // Append era suffixes
    if (isNegative) {
      yearText += " $_yearSuffixBC"; // Add BC suffix for negative years
    } else if (options.includeAD && absYearInt > 0) {
      // Add AD/CE suffix only for positive years AND if includeAD is true
      yearText += " $_yearSuffixAD";
    }
    return yearText;
  }

  /// Handles formatting a number as currency (specifically CZK based on default options).
  ///
  /// [absValue]: The absolute decimal value of the currency amount.
  /// [options]: The [CsOptions] specifying currency mode and details.
  /// Returns the currency amount converted to Czech words with main and subunits.
  String _handleCurrency(Decimal absValue, CsOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    // Rounding option exists but tests imply no rounding for CZK currency display.
    final bool round = options.round;
    final int decimalPlaces = 2; // Standard for currency subunits like haléře
    final Decimal subunitMultiplier =
        Decimal.fromInt(100); // 100 haléřů in 1 koruna

    // Determine the value to convert, applying rounding if specified.
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main unit and subunit values
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    // Use precise Decimal arithmetic for fractional part
    final Decimal fractionalPart =
        valueToConvert - Decimal.fromBigInt(mainValue);
    // Calculate subunit value precisely, rounding to nearest whole subunit
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round(scale: 0).toBigInt();

    // Convert the main integer part (koruny) - use feminine gender for 'koruna'.
    final String mainText = _convertInteger(mainValue, Gender.feminine);
    // Get the correct grammatical form for the main unit (koruna/koruny/korun)
    final String mainUnitName = _getGrammaticalForm(
      mainValue,
      currencyInfo.mainUnitSingular,
      currencyInfo.mainUnitPlural2To4,
      currencyInfo.mainUnitPluralGenitive,
    );

    String result =
        '$mainText $mainUnitName'.trim(); // Combine number and unit name

    // Add subunit part if it exists
    if (subunitValue > BigInt.zero) {
      // Convert the subunit integer part (haléře) - use masculine gender for 'haléř'.
      final String subunitText =
          _convertInteger(subunitValue, Gender.masculine);
      // Get the correct grammatical form for the subunit (haléř/haléře/haléřů)
      // Use assertions assuming CurrencyInfo.czk provides non-null subunit details
      final String subUnitName = _getGrammaticalForm(
        subunitValue,
        currencyInfo.subUnitSingular!, // Assumed non-null for CZK
        currencyInfo.subUnitPlural2To4, // Assumed non-null for CZK
        currencyInfo.subUnitPluralGenitive, // Assumed non-null for CZK
      );
      // Combine with separator ("a")
      result += ' ${currencyInfo.separator ?? "a"} $subunitText $subUnitName';
    }
    return result;
  }

  /// Selects the correct grammatical form of a noun based on the preceding number.
  ///
  /// Czech nouns change form depending on the count:
  /// - 1: Singular form
  /// - 2-4: Plural form (nominative/accusative)
  /// - 0, 5+: Genitive Plural form
  ///
  /// [number]: The count determining the grammatical form.
  /// [singular]: The singular form of the noun.
  /// [plural2To4]: The plural form used for counts 2, 3, 4.
  /// [pluralGenitive]: The genitive plural form used for counts 0, 5+.
  /// Returns the grammatically correct noun form. Returns singular if plural forms are null.
  String _getGrammaticalForm(
    BigInt number,
    String singular,
    String? plural2To4,
    String? pluralGenitive,
  ) {
    // If specific plural forms are not provided, always return the singular form.
    if (plural2To4 == null || pluralGenitive == null) return singular;

    BigInt absNumber = number.abs();

    if (absNumber == BigInt.one) return singular;
    // Check for 2-4 range directly
    if (absNumber >= BigInt.two && absNumber <= BigInt.from(4))
      return plural2To4;
    // All other cases (0, 5+) use the genitive plural
    return pluralGenitive;
  }

  /// Handles formatting a standard number (integer or decimal).
  ///
  /// [absValue]: The absolute decimal value.
  /// [options]: The [CsOptions] specifying gender and decimal separator.
  /// Returns the number converted to Czech words.
  String _handleStandardNumber(Decimal absValue, CsOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    // Use precise Decimal subtraction
    final Decimal fractionalPart = absValue - Decimal.fromBigInt(integerPart);

    // Determine the gender for the integer part from options, default if not specified.
    // Note: CsOptions defaults gender to feminine.
    final Gender integerGender = options.gender;

    // Convert the integer part, respecting the provided gender.
    // If integer part is zero but there's a fractional part, output "nula".
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, integerGender);

    String fractionalWords = '';
    // Process fractional part if it exists
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word based on options
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          separatorWord = _pointWord; // "tečka"
          break;
        case DecimalSeparator.comma:
        default: // Default to comma behaviour ("celá")
          separatorWord = _defaultDecimalSeparatorWord;
          break;
      }

      // Convert each digit after the decimal point individually
      // Use .toString() to get the fractional part reliably
      String fractionalDigits = absValue.toString().split('.').last;
      // Trim trailing zeros for standard format
      fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      if (fractionalDigits.isNotEmpty) {
        final List<String> digitWords =
            fractionalDigits.split('').map((digitChar) {
          // Parse the digit and convert using feminine gender (standard for digits after comma/point)
          final int? digitInt = int.tryParse(digitChar);
          // Default to feminine for digits after decimal point.
          return (digitInt != null)
              ? _getDigitWord(digitInt, Gender.feminine)
              : '?';
        }).toList();

        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }

    // Combine integer and fractional parts
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer ([BigInt]) into Czech words.
  ///
  /// Handles numbers from zero up to the limits of [BigInt], processing them in chunks of thousands.
  /// Applies scale words (tisíc, milion, etc.) with correct grammatical forms.
  ///
  /// [n]: The non-negative integer to convert.
  /// [gender]: The grammatical [Gender] to apply to the number 1 or 2 if it appears as the final unit or at the start of a chunk affecting a scale word.
  /// Returns the integer converted to Czech words.
  /// @example _convertInteger(BigInt.from(1234), Gender.feminine) -> "tisíc dvě stě třicet čtyři"
  /// @throws ArgumentError if [n] is negative.
  String _convertInteger(BigInt n, Gender gender) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) {
      // This function expects non-negative input; sign should be handled by the caller.
      throw ArgumentError(
          "Integer must be non-negative for _convertInteger: $n");
    }

    // Handle numbers less than 1000 directly
    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt(), gender);
    }

    final List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndexPower =
        0; // Tracks the scale (0=units, 3=thousands, 6=millions...)
    BigInt remaining = n;

    // Process the number in chunks of three digits (thousands)
    while (remaining > BigInt.zero) {
      // Get the current chunk (0-999)
      final BigInt chunk = remaining % oneThousand;
      // Move to the next chunk
      remaining ~/= oneThousand;

      if (chunk > BigInt.zero) {
        // Determine the gender for this chunk. Usually the overall gender,
        // but for scales (million, miliarda), the scale word's gender dictates the form of 1/2 before it.
        Gender chunkGender = gender; // Default to overall gender
        bool isScaleWord =
            scaleIndexPower > 0 && _scaleWords.containsKey(scaleIndexPower);
        if (isScaleWord) {
          // The gender of the scale word (e.g., milion is masc, miliarda is fem)
          chunkGender = _scaleWords[scaleIndexPower]![3] as Gender;
        }

        // Convert the 0-999 chunk to words using the appropriate gender
        String chunkText = _convertChunk(chunk.toInt(), chunkGender);

        // If this chunk corresponds to a scale (thousands, millions, etc.)
        if (isScaleWord) {
          final List<dynamic> scaleInfo = _scaleWords[scaleIndexPower]!;
          final String singularForm = scaleInfo[0] as String;
          final String plural2To4Form = scaleInfo[1] as String;
          final String genitiveForm = scaleInfo[2] as String;

          String scaleWord;
          // Determine the correct grammatical form of the scale word based on the chunk value
          if (chunk == BigInt.one) {
            scaleWord = singularForm;
            // Special case for "tisíc": "jeden tisíc" becomes just "tisíc"
            if (scaleIndexPower == 3) {
              chunkText = ""; // Omit the "jeden" part as per original logic
            }
          } else if (chunk >= BigInt.two && chunk <= BigInt.from(4)) {
            scaleWord = plural2To4Form;
          } else {
            scaleWord = genitiveForm;
          }
          // Combine the chunk text (if any) and the scale word
          parts.add("$chunkText $scaleWord".trim());
        } else {
          // This is the lowest chunk (0-999 part of the number)
          parts.add(chunkText);
        }
      }
      scaleIndexPower += 3; // Move to the next scale level
    }

    // Join the parts in reverse order (millions then thousands then units)
    return parts.reversed.join(' ').trim();
  }

  /// Converts a number between 0 and 999 into Czech words.
  ///
  /// [n]: The integer chunk (0-999) to convert.
  /// [gender]: The grammatical [Gender] to apply for 1 or 2.
  /// Returns the chunk converted to Czech words.
  /// @throws ArgumentError if [n] is outside the 0-999 range.
  String _convertChunk(int n, Gender gender) {
    if (n == 0)
      return ""; // Return empty for zero chunks within a larger number
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }

    final List<String> words = [];
    int remainder = n;

    // Handle hundreds place
    if (remainder >= 100) {
      words.add(_wordsHundreds[remainder ~/ 100]);
      remainder %= 100;
    }

    // Handle tens and units place
    if (remainder > 0) {
      // If hundreds were present, add a space before tens/units. `join` handles this.
      if (remainder < 20) {
        // Numbers 1-19 are unique words
        words.add(_getDigitWord(remainder, gender));
      } else {
        // Numbers 20-99
        final String tensWord = _wordsTens[remainder ~/ 10];
        final int unit = remainder % 10;
        if (unit == 0) {
          // Exact tens (20, 30, etc.)
          words.add(tensWord);
        } else {
          // Compound tens (21, 35, etc.)
          final String unitWord = _getDigitWord(unit, gender);
          words.add(
              "$tensWord $unitWord"); // Combine tens and units with a space
        }
      }
    }
    // Join the parts (e.g., "sto" and "dvacet jedna")
    return words.join(' ');
  }

  /// Gets the word for a single digit (0-19), applying the correct grammatical [Gender] for 1 and 2.
  ///
  /// [digit]: The digit (0-19).
  /// [gender]: The grammatical [Gender] required.
  /// Returns the word for the digit, adjusted for gender if necessary, or "?" if out of range.
  String _getDigitWord(int digit, Gender gender) {
    // Ensure digit is within the handled range
    if (digit < 0 || digit >= 20)
      return "?"; // Should not happen with proper chunking

    // Apply gender rules specifically for 1 and 2
    if (digit == 1) {
      switch (gender) {
        case Gender.masculine:
          return _wordsUnder3Masculine[1]; // "jeden"
        case Gender.feminine:
          return _wordsUnder3Feminine[1]; // "jedna"
        case Gender.neuter:
          return _wordsUnder3Neuter[1]; // "jedno"
      }
    } else if (digit == 2) {
      switch (gender) {
        case Gender.masculine:
          return _wordsUnder3Masculine[2]; // "dva"
        case Gender.feminine:
        case Gender.neuter:
          // Feminine and Neuter share the same form for 2
          return _wordsUnder3Feminine[2]; // "dvě"
      }
    } else {
      // For digits 0, 3-19, gender doesn't change the word
      return _wordsUnder20[digit];
    }
  }
}
