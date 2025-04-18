import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/it_options.dart';
import '../utils/utils.dart';

/// {@template num2text_it}
/// The Italian language (Lang.IT) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Italian word representation following standard grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [ItOptions.currencyInfo] - defaults to EUR Italian),
/// year formatting ([Format.year]), negative numbers, decimals, large numbers (milione, miliardo), and Italian-specific
/// elision rules (e.g., "ventuno").
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [ItOptions].
/// {@endtemplate}
class Num2TextIT implements Num2TextBase {
  /// The word used for zero in Italian number representations.
  static const String _zero = "zero";

  /// The word for decimal point when using [DecimalSeparator.point] ("punto").
  static const String _point = "punto";

  /// The word used to represent the decimal separator when [DecimalSeparator.comma]
  /// is selected (default). In Italian, this is "virgola".
  static const String _comma = "virgola";

  /// The default separator word used in currency between main and subunits ("e" - and).
  static const String _currencyAnd = "e";

  /// The special form "un" used before masculine nouns starting with a vowel
  /// or in compounds like "un milione", "un euro". Used for 1 in currency and scale words.
  static const String _un = "un";

  /// The word for 100 ("cento").
  static const String _hundred = "cento";

  /// The singular form for 1000 ("mille").
  static const String _thousandSingular = "mille";

  /// The suffix used for multiples of 1000 (e.g., "due" + "mila" -> "duemila").
  static const String _thousandPluralSuffix = "mila";

  /// A string containing vowels used for elision checks (e.g., venti + uno -> ventuno).
  static const String _vowels = "aeiouAEIOU";

  /// Words for numbers 0-19.
  static const List<String> _wordsUnder20 = [
    "zero", // 0
    "uno", // 1
    "due", // 2
    "tre", // 3
    "quattro", // 4
    "cinque", // 5
    "sei", // 6
    "sette", // 7
    "otto", // 8
    "nove", // 9
    "dieci", // 10
    "undici", // 11
    "dodici", // 12
    "tredici", // 13
    "quattordici", // 14
    "quindici", // 15
    "sedici", // 16
    "diciassette", // 17
    "diciotto", // 18
    "diciannove", // 19
  ];

  /// Words for tens (20, 30,... 90). Index corresponds to the tens digit.
  static const List<String> _wordsTens = [
    "", // 0 (placeholder)
    "", // 10 (handled by _wordsUnder20)
    "venti", // 20
    "trenta", // 30
    "quaranta", // 40
    "cinquanta", // 50
    "sessanta", // 60
    "settanta", // 70
    "ottanta", // 80
    "novanta", // 90
  ];

  /// Base words for large number scales (thousand, million, billion).
  /// Index represents the power of 1000 (0: units, 1: thousands, 2: millions, 3: billions).
  /// Value is a list: `[singular form, plural form/suffix]`.
  static const Map<int, List<String>> _scaleWordsBase = {
    0: ["", ""], // Units - no scale word
    1: [
      _thousandSingular,
      _thousandPluralSuffix
    ], // Thousands ("mille", "mila")
    2: ["milione", "milioni"], // Millions
    3: ["miliardo", "miliardi"], // Billions (US scale)
  };

  /// Processes the given [number] into its Italian word representation based on the provided [options].
  ///
  /// - Handles `int`, `double`, `BigInt`, `Decimal`, and `String` inputs.
  /// - Uses `options` (specifically [ItOptions]) to control formatting (currency, year, decimal separator).
  /// - Returns [fallbackOnError] or a default Italian error message if the input is invalid (null, NaN, unparseable string).
  /// - Handles Infinity and NegativeInfinity by returning specific Italian strings.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final ItOptions itOptions =
        options is ItOptions ? options : const ItOptions();

    // Handle special double values first
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? "Infinito negativo" : "Infinito";
      }
      if (number.isNaN) {
        return fallbackOnError ?? "Non un numero"; // "Not a Number"
      }
    }

    // Normalize input to Decimal, handling potential errors
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) {
      return fallbackOnError ?? "Non un numero";
    }

    // Handle zero separately for potential currency formatting
    if (decimalValue == Decimal.zero) {
      if (itOptions.currency) {
        // Use plural form for zero currency amount (e.g., "zero euro")
        final String zeroUnit = itOptions.currencyInfo.mainUnitPlural ??
            itOptions.currencyInfo.mainUnitSingular;
        return "$_zero $zeroUnit";
      } else {
        return _zero;
      }
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for conversion logic
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Dispatch based on format option
    if (itOptions.format == Format.year) {
      // Year format: Convert integer part only.
      textResult = _convertInteger(absValue.truncate().toBigInt());
      // Add negative prefix if the original year was negative (BC/BCE).
      // Note: Does not add AD/CE ("d.C.") suffix by default, controlled by ItOptions.includeAD.
      if (isNegative) {
        textResult =
            "${itOptions.negativePrefix} $textResult"; // "meno ..." for BC years
      }
    } else {
      // Standard or Currency format
      if (itOptions.currency) {
        textResult = _handleCurrency(absValue, itOptions);
      } else {
        textResult = _handleStandardNumber(absValue, itOptions);
      }
      // Add negative prefix for non-year negative numbers.
      if (isNegative) {
        textResult = "${itOptions.negativePrefix} $textResult";
      }
    }

    // Trim potential leading/trailing whitespace
    return textResult.trim();
  }

  /// Formats the absolute [absValue] as Italian currency according to [options].
  ///
  /// - Uses [options.currencyInfo] for unit names (singular/plural).
  /// - Rounds to 2 decimal places if [options.round] is true.
  /// - Handles singular ("un euro", "un centesimo") and plural forms correctly.
  /// - Uses the separator from [options.currencyInfo.separator] or defaults to "e".
  ///
  /// Returns the Italian word representation of the currency amount.
  String _handleCurrency(Decimal absValue, ItOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2; // Standard currency decimal places
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round if requested, otherwise use the value as is
    final Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main unit and subunit values
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).truncate().toBigInt();

    // Convert main value to text, handling the special case for "un"
    String mainText = _convertInteger(mainValue);
    if (mainValue == BigInt.one) {
      mainText = _un; // Use "un" instead of "uno" for currency unit 1
    }

    // Determine the correct main unit name (singular/plural)
    final String mainUnitName = (mainValue == BigInt.one)
        ? currencyInfo.mainUnitSingular
        : (currencyInfo.mainUnitPlural ??
            currencyInfo.mainUnitSingular); // Use plural, fallback to singular

    String result = '$mainText $mainUnitName';

    // Add subunit part if it exists and subunit names are defined
    if (subunitValue > BigInt.zero &&
        currencyInfo.subUnitSingular != null &&
        currencyInfo.subUnitPlural != null) {
      // Convert subunit value to text, handling "un"
      String subunitText = _convertInteger(subunitValue);
      if (subunitValue == BigInt.one) {
        subunitText = _un; // Use "un" for one centesimo
      }

      // Determine the correct subunit name (singular/plural)
      final String subUnitName = (subunitValue == BigInt.one)
          ? currencyInfo.subUnitSingular!
          : currencyInfo.subUnitPlural!;

      // Get the separator word (e.g., "e")
      final String separator = currencyInfo.separator ?? _currencyAnd;

      result += ' $separator $subunitText $subUnitName';
    }
    return result;
  }

  /// Formats the absolute [absValue] as a standard Italian number (cardinal or decimal).
  ///
  /// - Converts the integer part using [_convertInteger].
  /// - If a fractional part exists, converts it digit by digit, separated by the
  ///   word specified by [options.decimalSeparator] ("virgola" or "punto").
  ///
  /// Returns the Italian word representation of the standard number.
  String _handleStandardNumber(Decimal absValue, ItOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part. Handle case where integer is 0 but decimal exists (e.g., 0.5)
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero // "zero"
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Determine the decimal separator word based on options
      final String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.period:
        case DecimalSeparator.point: // Treat point and period the same
          separatorWord = _point; // "punto"
          break;
        case DecimalSeparator.comma:
        default: // Default to comma ("virgola")
          separatorWord = _comma; // "virgola"
          break;
      }

      // Extract fractional digits as a string
      // Remove trailing zeros because Decimal.toString() might include them (e.g., "1.50").
      String fractionalDigits = absValue.toString().split('.').last;
      fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      // Convert each digit after the separator individually if any remain
      if (fractionalDigits.isNotEmpty) {
        final List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          // Use _wordsUnder20 for single digits 0-9
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder20[digitInt]
              : '?'; // Placeholder for unexpected non-digit characters
        }).toList();

        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }

    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] [n] into its Italian word representation.
  ///
  /// - Handles numbers from zero up to arbitrarily large values.
  /// - Uses [_convertUnder1000] for chunks less than 1000.
  /// - Uses [_getScaleWord] to determine scale names (mille, milione, etc.).
  /// - Handles singular/plural forms of scale words and "un" vs "uno".
  /// - Special case: 1000 is "mille", multiples use "mila".
  ///
  /// Returns the Italian word representation of the integer [n].
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _zero;
    // This function assumes non-negative input, checked by the caller.

    // Handle base cases
    if (n < BigInt.from(1000)) {
      return _convertUnder1000(n.toInt());
    }
    if (n == BigInt.from(1000)) {
      return _thousandSingular; // Special case for exactly 1000 ("mille")
    }

    final List<String> parts = [];
    BigInt tempN = n;
    int scaleIndex = 0; // 0: 10^0, 1: 10^3, 2: 10^6, ...

    // Process the number in chunks of 1000
    while (tempN > BigInt.zero) {
      // Get the chunk (0-999) for the current scale
      final int chunk = (tempN % BigInt.from(1000)).toInt();
      tempN ~/= BigInt.from(1000); // Move to the next chunk

      if (chunk > 0) {
        String chunkText;
        // Determine the scale word (e.g., mila, milione, miliardi)
        String scaleWord = _getScaleWord(chunk, scaleIndex);

        // Handle special cases for chunk value 1 at different scales
        if (scaleIndex == 1 && chunk == 1) {
          // For 1000 within a larger number (e.g., 1,001,000)
          chunkText =
              ""; // "mille" is handled implicitly by the scale word logic or combined later
          scaleWord =
              _thousandSingular; // Keep track that it's the "mille" scale
        } else if (scaleIndex >= 2 && chunk == 1) {
          // For "un milione", "un miliardo"
          chunkText = _un; // Use "un"
        } else {
          // Convert the chunk (1-999) itself
          chunkText = _convertUnder1000(chunk);
        }

        String part = chunkText;

        // Append scale words based on rules
        if (scaleIndex == 1) {
          // Thousands scale
          if (chunk > 1) {
            part +=
                _thousandPluralSuffix; // Use "mila" suffix for thousands > 1 (e.g., "duemila")
          } else if (chunk == 1 && scaleWord == _thousandSingular) {
            // Handle the standalone "mille" scale within the number
            part = scaleWord;
          }
        } else if (scaleWord.isNotEmpty) {
          // Append scale words like "milione", "miliardi", handling "un" vs others
          if (chunkText == _un) {
            // Add space for "un milione", "un miliardo"
            part += " $scaleWord";
          } else {
            // Attach directly for cases like "duemilioni", "trecento miliardi"
            // Note: _getScaleWord includes " di " for very large numbers.
            part += scaleWord;
          }
        }
        // Add the composed part to the beginning of the list
        if (part.isNotEmpty) {
          parts.insert(0, part.trim());
        }
      }
      scaleIndex++;
    }

    // Combine parts (highest scale first)
    // Handle potential joining issues like "mille" + "cento" -> "millecento"
    // Simple join works for most cases, but Italian can have complex compounds.
    // The current approach joins with spaces implicitly which might not be perfect for all compounds.
    // A more sophisticated joining logic might be needed for flawless compounding.
    return parts.join(''); // Join without spaces for Italian compounding
  }

  /// Determines the correct Italian scale word (milione, miliardi, etc.) for a given [chunkValue]
  /// at a specific [scaleIndex] (power of 1000).
  ///
  /// - `scaleIndex` 0: units (returns "")
  /// - `scaleIndex` 1: thousands (returns "" - handled by suffix/special case in caller)
  /// - `scaleIndex` 2: millions
  /// - `scaleIndex` 3: billions
  /// - `scaleIndex` 4: trillions (milioni di milioni)
  /// - `scaleIndex` 5: quadrillions (milioni di miliardi)
  /// - etc.
  /// Handles singular ("un milione") vs plural ("due milioni") and the structure
  /// involving "di" for very large numbers (e.g., "milioni di milioni").
  ///
  /// Returns the appropriate Italian scale word as a String.
  String _getScaleWord(int chunkValue, int scaleIndex) {
    // No scale word for units (0) or thousands (1, handled separately)
    if (scaleIndex <= 1) return "";

    // Base scale names from map
    final String milioneSingular = _scaleWordsBase[2]![0]; // "milione"
    final String milioniPlural = _scaleWordsBase[2]![1]; // "milioni"
    final String miliardoSingular = _scaleWordsBase[3]![0]; // "miliardo"
    final String miliardiPlural = _scaleWordsBase[3]![1]; // "miliardi"

    // Calculate the power level (1=million/billion, 2=trillion/quadrillion, etc.)
    // Each pair of scale indices (2/3, 4/5, ...) represents one level of "milione di..."
    final int powerLevel = (scaleIndex - 2) ~/ 2 + 1;

    if (powerLevel == 1) {
      // Simple millions or billions (10^6, 10^9)
      if (scaleIndex == 2) {
        // Millions (10^6)
        return (chunkValue == 1) ? milioneSingular : milioniPlural;
      } else {
        // scaleIndex == 3
        // Billions (10^9)
        return (chunkValue == 1) ? miliardoSingular : miliardiPlural;
      }
    } else {
      // Complex scales involving "di" (10^12, 10^15, ...)
      // Start with the base "milione" or "milioni"
      String scale = (chunkValue == 1) ? milioneSingular : milioniPlural;

      // Add intermediate "di milioni" parts for powers > 1
      // Example: 10^18 (scaleIndex 6, powerLevel 3) needs one "di milioni"
      // Example: 10^24 (scaleIndex 8, powerLevel 4) needs two "di milioni"
      for (int i = 0; i < powerLevel - 2; i++) {
        scale += " di $milioniPlural";
      }

      // Determine the final component ("di milioni" or "di miliardi")
      // Even scaleIndex (4, 6, 8...) ends with "di milioni" (10^12, 10^18, ...)
      // Odd scaleIndex (5, 7, 9...) ends with "di miliardi" (10^15, 10^21, ...)
      final String finalDiPart =
          (scaleIndex % 2 == 0) ? milioniPlural : miliardiPlural;
      scale += " di $finalDiPart";

      return scale;
    }
  }

  /// Converts an integer [n] between 0 and 999 into its Italian word representation.
  ///
  /// - Handles numbers 0-19 directly using [_wordsUnder20].
  /// - Combines tens and units words for 20-99 using [_wordsTens] and [_wordsUnder20].
  /// - Handles hundreds ("cento", "duecento", etc.).
  /// - Applies Italian elision rules: drops the final vowel of tens/hundreds
  ///   when followed by a unit starting with a vowel (specifically 'uno' or 'otto').
  ///   Examples: "venti" + "uno" -> "ventuno"; "cento" + "otto" -> "centotto".
  ///
  /// Returns the Italian word representation of the number between 0 and 999. Returns empty string for 0.
  String _convertUnder1000(int n) {
    if (n == 0)
      return ""; // Return empty string for zero within a larger number
    // Validate input range
    if (n < 0 || n >= 1000) {
      throw ArgumentError(
          "Number must be between 0 and 999 for _convertUnder1000: $n");
    }

    // Numbers less than 20 have unique names
    if (n < 20) return _wordsUnder20[n];

    final List<String> parts = [];
    int remainder = n;

    // Handle hundreds place
    if (remainder >= 100) {
      final int hundredsDigit = remainder ~/ 100;
      String hundredsPart;

      if (hundredsDigit == 1) {
        // "cento"
        hundredsPart = _hundred;
      } else {
        // "duecento", "trecento", ...
        hundredsPart = _wordsUnder20[hundredsDigit] + _hundred;
      }

      // Apply elision for "cento" before "uno" or "otto" in the remainder
      final int tensUnitsPart = remainder % 100;
      if (tensUnitsPart == 1 || tensUnitsPart == 8) {
        // Only apply elision to "cento" (100) itself, not multiples like "duecento"
        if (hundredsDigit == 1) {
          // Drop the final 'o' from "cento" -> "cent"
          hundredsPart = hundredsPart.substring(0, hundredsPart.length - 1);
        }
      }

      parts.add(hundredsPart);
      remainder %= 100; // Move to the remaining tens/units part
    }

    // Handle tens and units place (0-99)
    if (remainder > 0) {
      String tensUnitsWord;
      if (remainder < 20) {
        // 1-19 (already handled if n < 20, but needed here after hundreds)
        tensUnitsWord = _wordsUnder20[remainder];
      } else {
        // 20-99
        final int tensDigit = remainder ~/ 10;
        final int unitDigit = remainder % 10;
        String tensWord = _wordsTens[tensDigit]; // "venti", "trenta", ...

        // Apply elision for tens ending in a vowel before "uno" or "otto"
        if (unitDigit == 1 || unitDigit == 8) {
          if (_vowels.contains(tensWord[tensWord.length - 1])) {
            // Drop final vowel (e.g., "venti" -> "vent", "quaranta" -> "quarant")
            tensWord = tensWord.substring(0, tensWord.length - 1);
          }
        }

        if (unitDigit == 0) {
          // Just the tens word (e.g., "venti")
          tensUnitsWord = tensWord;
        } else {
          // Combine tens (potentially elided) and units (e.g., "vent" + "uno" -> "ventuno")
          tensUnitsWord = tensWord + _wordsUnder20[unitDigit];
        }
      }
      parts.add(tensUnitsWord);
    }

    // Join parts without spaces (e.g., "cent" + "uno" -> "centuno", "venti" + "uno" -> "ventuno")
    return parts.join('');
  }
}
