import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/pl_options.dart';
import '../utils/utils.dart';

/// {@template num2text_pl}
/// The Polish language (Lang.PL) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Polish word representation following standard Polish grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [PlOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (short scale:
/// tysiąc, milion, miliard, etc.) with complex Polish pluralization rules.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [PlOptions].
/// {@endtemplate}
class Num2TextPL implements Num2TextBase {
  // --- Constants ---

  /// Word for the decimal separator comma (default).
  static const String _comma = "przecinek";

  /// Word for the decimal separator point/period.
  static const String _point = "kropka";

  /// Conjunction used in currency between main and subunits ("and").
  static const String _and = "i";

  /// Word for zero.
  static const String _zero = "zero";

  /// Suffix for BC/BCE years ("przed naszą erą").
  static const String _yearSuffixBC = "p.n.e.";

  /// Suffix for AD/CE years ("naszej ery").
  static const String _yearSuffixAD = "n.e.";

  /// Word for positive infinity.
  static const String _infinity = "nieskończoność";

  /// Word for negative infinity.
  static const String _negativeInfinity = "minus nieskończoność";

  /// Word for Not-a-Number (NaN).
  static const String _notANumber = "nie liczba";

  /// Words for numbers 0 through 19.
  static const List<String> _wordsUnder20 = [
    "zero",
    "jeden",
    "dwa",
    "trzy",
    "cztery",
    "pięć",
    "sześć",
    "siedem",
    "osiem",
    "dziewięć",
    "dziesięć",
    "jedenaście",
    "dwanaście",
    "trzynaście",
    "czternaście",
    "piętnaście",
    "szesnaście",
    "siedemnaście",
    "osiemnaście",
    "dziewiętnaście",
  ];

  /// Words for tens (20, 30, ..., 90). Index corresponds to the tens digit (index 2 = 20).
  static const List<String> _wordsTens = [
    "", // 0 - not used directly
    "dziesięć", // 10 - handled by _wordsUnder20
    "dwadzieścia", // 20
    "trzydzieści", // 30
    "czterdzieści", // 40
    "pięćdziesiąt", // 50
    "sześćdziesiąt", // 60
    "siedemdziesiąt", // 70
    "osiemdziesiąt", // 80
    "dziewięćdziesiąt", // 90
  ];

  /// Words for hundreds (100, 200, ..., 900). Index corresponds to the hundreds digit.
  static const List<String> _wordsHundreds = [
    "", // 0 - not used directly
    "sto", // 100
    "dwieście", // 200
    "trzysta", // 300
    "czterysta", // 400
    "pięćset", // 500
    "sześćset", // 600
    "siedemset", // 700
    "osiemset", // 800
    "dziewięćset", // 900
  ];

  /// Mapping of scale levels (1=thousand, 2=million, ...) to their Polish plural forms.
  /// Each list contains: [singular form (for 1), plural nominative (for 2-4 ends), plural genitive (for 0, 1, 5+ ends)].
  static final Map<int, List<String>> _scaleWords = {
    1: ["tysiąc", "tysiące", "tysięcy"], // Thousand
    2: ["milion", "miliony", "milionów"], // Million
    3: ["miliard", "miliardy", "miliardów"], // Billion (10^9)
    4: ["bilion", "biliony", "bilionów"], // Trillion (10^12)
    5: ["biliard", "biliardy", "biliardów"], // Quadrillion (10^15)
    6: ["trylion", "tryliony", "trylionów"], // Quintillion (10^18)
    7: ["tryliard", "tryliardy", "tryliardów"], // Sextillion (10^21)
    8: ["kwadrylion", "kwadryliony", "kwadrylionów"], // Septillion (10^24)
    // Add more scales if needed, following the pattern
  };

  /// Processes the given number (int, double, BigInt, String, Decimal) and converts it to Polish words.
  ///
  /// - [number]: The number to convert.
  /// - [options]: An optional [PlOptions] object to customize the conversion
  ///            (e.g., currency, year format, negative prefix). Defaults to `const PlOptions()`.
  /// - [fallbackOnError]: An optional string to return if the input `number` is invalid
  ///                    (e.g., null, NaN, non-numeric string). Defaults to [_notANumber].
  ///
  /// Returns the Polish word representation of the number, or the fallback string on error.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have Polish-specific options, falling back to defaults if necessary.
    final PlOptions plOptions =
        options is PlOptions ? options : const PlOptions();
    final String errorFallback = fallbackOnError ?? _notANumber;

    // Handle special double values first.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? _negativeInfinity : _infinity;
      }
      if (number.isNaN) {
        return errorFallback;
      }
    }

    // Normalize the input number to Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Return fallback if normalization fails.
    if (decimalValue == null) {
      return errorFallback;
    }

    // Handle zero separately, considering currency context.
    if (decimalValue == Decimal.zero) {
      if (plOptions.currency) {
        // For currency, zero needs the genitive plural form (e.g., "zero złotych").
        final String mainUnit = plOptions.currencyInfo.mainUnitPluralGenitive ??
            plOptions.currencyInfo.mainUnitSingular;
        return "$_zero $mainUnit";
      } else {
        // For standard numbers and years, just return "zero".
        return _zero;
      }
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for the conversion logic.
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // --- Format-Specific Handling ---

    if (plOptions.format == Format.year) {
      // Handle year formatting.
      // Years are always treated as integers.
      textResult = _convertInteger(absValue.truncate().toBigInt());
      if (isNegative) {
        // Add BC/BCE suffix for negative years.
        textResult += " $_yearSuffixBC";
      } else if (plOptions.includeAD) {
        // Add AD/CE suffix for positive years only if includeAD is true.
        textResult += " $_yearSuffixAD";
      }
    } else if (plOptions.currency) {
      // Handle currency formatting.
      textResult = _handleCurrency(absValue, plOptions);
      if (isNegative) {
        // Add negative prefix if the original number was negative.
        String prefix = plOptions.negativePrefix.trim();
        textResult = "$prefix $textResult";
      }
    } else {
      // Handle standard number formatting (integers and decimals).
      textResult = _handleStandardNumber(absValue, plOptions);
      if (isNegative) {
        // Add negative prefix if the original number was negative.
        String prefix = plOptions.negativePrefix.trim();
        textResult = "$prefix $textResult";
      }
    }

    // Return the final result, trimmed of any leading/trailing whitespace.
    return textResult.trim();
  }

  /// Handles the conversion of a number into currency format (złoty and grosz).
  ///
  /// - [absValue]: The absolute decimal value to convert.
  /// - [options]: The Polish-specific options containing currency info.
  /// Returns the currency string (e.g., "jeden złoty i pięćdziesiąt groszy").
  String _handleCurrency(Decimal absValue, PlOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;

    // Round the value to 2 decimal places for currency.
    final Decimal valueToConvert = absValue.round(scale: 2);

    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart =
        valueToConvert - Decimal.fromBigInt(mainValue);
    // Extract the subunit value (grosz).
    final BigInt subunitValue =
        (fractionalPart * Decimal.fromInt(100)).truncate().toBigInt();

    // Convert the main currency value (złoty).
    String mainText = _convertInteger(mainValue);
    // Get the correct plural form for the main unit.
    String mainUnitName = _getCurrencyForm(
      mainValue,
      currencyInfo.mainUnitSingular,
      currencyInfo.mainUnitPlural2To4 ??
          currencyInfo.mainUnitSingular, // Fallback if null
      currencyInfo.mainUnitPluralGenitive ??
          currencyInfo.mainUnitSingular, // Fallback if null
    );

    String result = '$mainText $mainUnitName';

    // If there are subunits (grosz), convert and append them.
    if (subunitValue > BigInt.zero) {
      // Ensure subunit names are not null before processing.
      final subSingular = currencyInfo.subUnitSingular;
      final subPlural2To4 = currencyInfo.subUnitPlural2To4;
      final subPluralGenitive = currencyInfo.subUnitPluralGenitive;

      if (subSingular != null &&
          subPlural2To4 != null &&
          subPluralGenitive != null) {
        String subunitText = _convertInteger(subunitValue);
        // Get the correct plural form for the subunit.
        String subUnitName = _getCurrencyForm(
          subunitValue,
          subSingular,
          subPlural2To4,
          subPluralGenitive,
        );

        // Join with "i" (and).
        result += ' $_and $subunitText $subUnitName';
      }
    }

    return result;
  }

  /// Handles the conversion of a standard number (integer or decimal).
  ///
  /// - [absValue]: The absolute decimal value to convert.
  /// - [options]: The Polish-specific options containing decimal separator info.
  /// Returns the standard number string (e.g., "sto dwadzieścia trzy przecinek cztery pięć").
  String _handleStandardNumber(Decimal absValue, PlOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - Decimal.fromBigInt(integerPart);

    // Convert the integer part. Handle the case where the number is purely fractional (e.g., 0.5).
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    // If there's a fractional part, convert it.
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word based on options.
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
        case null: // Default to comma
          separatorWord = _comma;
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period: // Treat period and point the same
          separatorWord = _point;
          break;
      }

      // Extract digits after the decimal point.
      String fractionalDigitsStr = absValue.toString().split('.').last;
      // Polish reads decimals digit by digit, often omitting trailing zeros.
      final String cleanedDigits =
          fractionalDigitsStr.replaceAll(RegExp(r'0+$'), '');

      // Convert each digit individually to words.
      if (cleanedDigits.isNotEmpty) {
        List<String> digitWords = cleanedDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          // Use words 0-9 for digits.
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder20[digitInt]
              : '?'; // Fallback for unexpected characters
        }).toList();
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      } else {
        // If removing trailing zeros resulted in empty string, don't add decimal part.
        fractionalWords = '';
      }
    }

    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer (BigInt) into Polish words.
  ///
  /// Handles numbers from zero up to the limits of BigInt, processing them in chunks of 1000
  /// and applying scale words (tysiąc, milion, etc.) with correct pluralization.
  ///
  /// - [n]: The non-negative integer to convert.
  /// Returns the Polish word representation of the integer.
  /// Throws [ArgumentError] if [n] is negative or too large for defined scales.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero) {
      // This function assumes non-negative input as sign is handled externally.
      throw ArgumentError("Integer must be non-negative for conversion: $n");
    }
    if (n == BigInt.zero) return _zero;

    // Handle numbers less than 1000 directly using the chunk converter.
    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt());
    }

    // --- Process numbers >= 1000 ---
    List<String> parts = []; // Stores word parts for each scale level
    final BigInt oneThousand = BigInt.from(1000);
    int scaleLevel = 0; // 0: units/hundreds, 1: thousands, 2: millions, ...
    BigInt remaining = n;

    // Process the number in chunks of 1000 from right to left.
    while (remaining > BigInt.zero) {
      // Get the current chunk (0-999).
      BigInt chunk = remaining % oneThousand;
      // Move to the next chunk for the next iteration.
      remaining ~/= oneThousand;

      if (chunk > BigInt.zero) {
        // Only process non-zero chunks.
        String chunkWords = _convertChunk(chunk.toInt());
        String scaleWordPart = ""; // Words for this scale level

        if (scaleLevel > 0) {
          // Add scale word (tysiąc, milion, etc.) if applicable.
          List<String>? scaleForms = _scaleWords[scaleLevel];
          if (scaleForms != null) {
            // Get the correct plural form of the scale word.
            String scaleWord = _getScaleForm(
                chunk, scaleForms[0], scaleForms[1], scaleForms[2]);

            // Handle the special case of "1" before a scale word (e.g., "jeden tysiąc").
            // Other numbers use the standard chunk conversion (e.g., "dwa tysiące", "pięć tysięcy").
            if (chunk == BigInt.one) {
              // Override chunkWords which would be "jeden"
              scaleWordPart = "jeden $scaleWord";
            } else {
              scaleWordPart = "$chunkWords $scaleWord";
            }
          } else {
            // Scale not found (number too large).
            throw ArgumentError("Number exceeds defined scales: $n");
          }
          // Add the combined chunk and scale words to the parts list.
          parts.add(scaleWordPart);
        } else {
          // For the first chunk (scaleLevel 0), just add the chunk words.
          parts.add(chunkWords);
        }
      }
      scaleLevel++; // Increment scale level for the next chunk.
    }

    // Join the parts in reverse order (highest scale first) with spaces.
    return parts.reversed.where((part) => part.isNotEmpty).join(' ').trim();
  }

  /// Converts a three-digit integer chunk (0-999) into Polish words.
  ///
  /// - [n]: The integer chunk (must be between 0 and 999).
  /// Returns the Polish word representation of the chunk.
  /// Throws [ArgumentError] if [n] is outside the valid range.
  String _convertChunk(int n) {
    if (n == 0) return ""; // Return empty string for zero chunk
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }

    List<String> words = []; // Stores word parts for this chunk
    int remainder = n;

    // Handle hundreds.
    if (remainder >= 100) {
      words.add(_wordsHundreds[remainder ~/ 100]);
      remainder %= 100;
    }

    // Handle tens and units.
    if (remainder > 0) {
      if (remainder < 20) {
        // Numbers 1-19 are handled directly.
        words.add(_wordsUnder20[remainder]);
      } else {
        // Numbers 20-99.
        words.add(_wordsTens[remainder ~/ 10]); // Add the tens word.
        int unit = remainder % 10;
        if (unit > 0) {
          // Add the unit word if it's not zero.
          words.add(_wordsUnder20[unit]);
        }
      }
    }

    // Join the parts (e.g., ["sto", "dwadzieścia", "trzy"]) with spaces.
    return words.join(' ');
  }

  /// Determines the correct Polish plural form for scale words (tysiąc, milion, etc.)
  /// or currency units based on the count.
  ///
  /// Polish Pluralization Rules (simplified for numbers):
  /// - 1: Singular nominative (e.g., "tysiąc", "złoty")
  /// - Ends in 2, 3, 4 (but not 12, 13, 14): Plural nominative (e.g., "tysiące", "złote")
  /// - Ends in 0, 1, 5-9, or 11-19: Plural genitive (e.g., "tysięcy", "złotych")
  ///
  /// - [count]: The number determining the plural form.
  /// - [form1]: The singular nominative form (for count = 1).
  /// - [form2_4]: The plural nominative form (for counts ending in 2, 3, 4, excluding 12, 13, 14).
  /// - [form5plus]: The plural genitive form (for all other counts).
  /// Returns the appropriate plural form string.
  String _getScaleForm(
      BigInt count, String form1, String form2_4, String form5plus) {
    // Rule for 1.
    if (count == BigInt.one) {
      return form1;
    }

    // Check the last two digits for the teens exception (11-19).
    int lastTwoDigits = (count % BigInt.from(100)).toInt();
    if (lastTwoDigits >= 11 && lastTwoDigits <= 19) {
      return form5plus; // Use genitive plural for teens.
    }

    // Check the last digit for other cases.
    int lastDigit = (count % BigInt.from(10)).toInt();

    // Rule for 2, 3, 4 endings (nominative plural).
    if (lastDigit >= 2 && lastDigit <= 4) {
      return form2_4;
    }

    // Rule for 0, 1, 5-9 endings (genitive plural).
    // This covers cases like 0, 5, 6, 7, 8, 9, 10, 20, 21, 25, etc.
    return form5plus;
  }

  /// A convenience wrapper for `_getScaleForm` specifically for currency units.
  /// The grammatical rules are the same.
  ///
  /// - [count]: The number of currency units.
  /// - [form1]: Singular form (e.g., "złoty", "grosz").
  /// - [form2_4]: Plural nominative form (e.g., "złote", "grosze").
  /// - [form5plus]: Plural genitive form (e.g., "złotych", "groszy").
  /// Returns the appropriate currency unit form.
  String _getCurrencyForm(
      BigInt count, String form1, String form2_4, String form5plus) {
    // Delegate to the general scale form logic as the rules are identical.
    return _getScaleForm(count, form1, form2_4, form5plus);
  }
}
