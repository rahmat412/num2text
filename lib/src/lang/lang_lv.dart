import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/lv_options.dart';
import '../utils/utils.dart';

/// {@template num2text_lv}
/// The Latvian language (Lang.LV) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Latvian word representation following standard Latvian grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [LvOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (standard scale).
/// It handles specific pluralization rules for scale words and the behavior of 'viens' (one).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [LvOptions].
/// {@endtemplate}
///
/// Example usage:
/// ```dart
/// final converter = Num2Text(initialLang: Lang.LV);
/// print(converter.convert(123)); // Output: "viens simts divdesmit trīs"
/// print(converter.convert(1000)); // Output: "viens tūkstotis"
/// print(converter.convert(2000)); // Output: "divi tūkstoši"
/// print(converter.convert(1.5)); // Output: "viens komats pieci"
/// print(converter.convert(1.5, options: const LvOptions(decimalSeparator: DecimalSeparator.point))); // Output: "viens punkts pieci"
/// print(converter.convert(123.45, options: const LvOptions(currency: true))); // Output: "viens simts divdesmit trīs eiro un četrdesmit pieci centi"
/// print(converter.convert(1999, options: const LvOptions(format: Format.year))); // Output: "viens tūkstotis deviņi simti deviņdesmit deviņi"
/// print(converter.convert(-5)); // Output: "mīnus pieci"
/// ```
class Num2TextLV implements Num2TextBase {
  /// The word used for the decimal point when [DecimalSeparator.point] or
  /// [DecimalSeparator.period] is specified.
  static const String _point = "punkts";

  /// The default word used for the decimal separator ([DecimalSeparator.comma]).
  static const String _comma = "komats";

  /// The word used to connect main and subunit currency values.
  static const String _and = "un";

  /// Latvian words for numbers 0 through 19.
  static const List<String> _wordsUnder20 = [
    "nulle", // 0
    "viens", // 1
    "divi", // 2
    "trīs", // 3
    "četri", // 4
    "pieci", // 5
    "seši", // 6
    "septiņi", // 7
    "astoņi", // 8
    "deviņi", // 9
    "desmit", // 10
    "vienpadsmit", // 11
    "divpadsmit", // 12
    "trīspadsmit", // 13
    "četrpadsmit", // 14
    "piecpadsmit", // 15
    "sešpadsmit", // 16
    "septiņpadsmit", // 17
    "astoņpadsmit", // 18
    "deviņpadsmit", // 19
  ];

  /// Latvian words for tens (20, 30, ..., 90). Index corresponds to the tens digit (index 2 = twenty).
  static const List<String> _wordsTens = [
    "", // 0 (unused)
    "", // 10 (handled by _wordsUnder20)
    "divdesmit", // 20
    "trīsdesmit", // 30
    "četrdesmit", // 40
    "piecdesmit", // 50
    "sešdesmit", // 60
    "septiņdesmit", // 70
    "astoņdesmit", // 80
    "deviņdesmit", // 90
  ];

  /// Latvian words for hundreds (100, 200, ..., 900). Index corresponds to the hundreds digit.
  /// Note the plural form for 200+.
  static const List<String> _wordsHundreds = [
    "", // 0 (unused)
    "viens simts", // 100
    "divi simti", // 200
    "trīs simti", // 300
    "četri simti", // 400
    "pieci simti", // 500
    "seši simti", // 600
    "septiņi simti", // 700
    "astoņi simti", // 800
    "deviņi simti", // 900
  ];

  /// Latvian scale words (thousands, millions, etc.).
  /// Maps scale index (1=10^3, 2=10^6, ...) to a list containing
  /// the singular and plural forms.
  static const Map<int, List<String>> _scaleWords = {
    1: ["tūkstotis", "tūkstoši"], // 10^3
    2: ["miljons", "miljoni"], // 10^6
    3: ["miljards", "miljardi"], // 10^9
    4: ["triljons", "triljoni"], // 10^12
    5: ["kvadriljons", "kvadriljoni"], // 10^15
    6: ["kvintiljons", "kvintiljoni"], // 10^18
    7: ["sekstiljons", "sekstiljoni"], // 10^21
    8: ["septiljons", "septiljoni"], // 10^24
    // Add more scales if needed
  };

  /// Converts the given [number] to its Latvian word representation.
  ///
  /// - [number]: The number to convert. Can be an `int`, `double`, `String`, `BigInt`, or `Decimal`.
  /// - [options]: Allows specifying language-specific formatting (e.g., currency, year).
  ///   Uses [LvOptions] for Latvian-specific settings.
  /// - [fallbackOnError]: Provides a custom string to return if conversion fails;
  ///   otherwise, returns a default error message ("Nav skaitlis").
  ///
  /// Handles special double values like `infinity` and `NaN`.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final LvOptions lvOptions =
        options is LvOptions ? options : const LvOptions();
    final String errorFallback = fallbackOnError ?? "Nav skaitlis";

    // Handle special double values immediately
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? "Negatīva bezgalība" : "Bezgalība";
      }
      if (number.isNaN) {
        return errorFallback;
      }
    }

    // Normalize the input number to Decimal for consistent handling
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Handle invalid or null input
    if (decimalValue == null) {
      return errorFallback;
    }

    // Handle zero separately for potential currency formatting
    if (decimalValue == Decimal.zero) {
      if (lvOptions.currency) {
        // Use plural form for zero currency as per convention
        final zeroUnit = lvOptions.currencyInfo.mainUnitPlural ??
            lvOptions.currencyInfo.mainUnitSingular;
        return "${_wordsUnder20[0]} $zeroUnit";
      } else {
        return _wordsUnder20[0]; // "nulle"
      }
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for the core conversion logic
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Apply special formatting based on options
    if (lvOptions.format == Format.year) {
      // Year format does not typically include subunits or decimal parts
      textResult = _handleStandardNumber(absValue.truncate(), lvOptions);
      // Add negative prefix *after* conversion if the original year was negative
      if (isNegative) {
        textResult = "${lvOptions.negativePrefix} $textResult";
      }
      // Note: LvOptions doesn't currently have includeAD, so AD/BC suffixes are not added.
    } else {
      // Handle currency or standard number formats
      if (lvOptions.currency) {
        textResult = _handleCurrency(absValue, lvOptions);
      } else {
        textResult = _handleStandardNumber(absValue, lvOptions);
      }

      // Add negative prefix if the original number was negative
      if (isNegative) {
        textResult = "${lvOptions.negativePrefix} $textResult";
      }
    }

    // Return the final result, trimming any potential leading/trailing whitespace
    return textResult.trim();
  }

  /// Formats the absolute [absValue] as currency according to [options].
  ///
  /// Splits the number into main units and subunits (cents).
  /// Converts both parts to words and joins them using the currency names
  /// and separator defined in [LvOptions.currencyInfo].
  ///
  /// - [absValue]: The absolute (non-negative) decimal value.
  /// - [options]: The Latvian options containing currency details.
  /// Returns the currency representation in words.
  String _handleCurrency(Decimal absValue, LvOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    // Use the absolute value for currency calculation
    final Decimal valueToConvert = absValue;
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    // Calculate the fractional part accurately
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Convert fractional part to subunits (e.g., cents)
    final BigInt subunitValue =
        (fractionalPart * Decimal.fromInt(100)).truncate().toBigInt();

    // Convert the main value to words
    final String mainText = _convertInteger(mainValue);
    // Determine the correct form (singular/plural) of the main unit name
    final String mainUnitName = (mainValue == BigInt.one)
        ? currencyInfo.mainUnitSingular
        : currencyInfo.mainUnitPlural ??
            currencyInfo
                .mainUnitSingular; // Fallback to singular if plural is null

    String result = '$mainText $mainUnitName';

    // Append subunit text if it exists
    if (subunitValue > BigInt.zero) {
      final String subunitText = _convertInteger(subunitValue);
      // Determine the correct form (singular/plural) of the subunit name
      // Assumes plural exists if singular does, and singular is not null
      final String subUnitName = (subunitValue == BigInt.one)
          ? currencyInfo.subUnitSingular!
          : currencyInfo.subUnitPlural ?? currencyInfo.subUnitSingular!;

      // Use the specified separator or the default "un"
      final String separator = currencyInfo.separator ?? _and;
      result += ' $separator $subunitText $subUnitName';
    }

    return result;
  }

  /// Formats the absolute [absValue] as a standard number (integer or decimal).
  ///
  /// Converts the integer part and, if present, the fractional part to words.
  /// Joins the parts using the appropriate decimal separator word ("komats" or "punkts")
  /// based on [options.decimalSeparator].
  ///
  /// - [absValue]: The absolute (non-negative) decimal value.
  /// - [options]: The Latvian options specifying decimal format preferences.
  /// Returns the standard number representation in words.
  String _handleStandardNumber(Decimal absValue, LvOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part to words.
    // If the number is purely fractional (e.g., 0.5), represent the zero.
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _wordsUnder20[0] // "nulle" for numbers like 0.5
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word ("komats" or "punkts")
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.point:
        case DecimalSeparator.period: // Treat period and point the same
          separatorWord = _point;
          break;
        case DecimalSeparator.comma:
        default: // Default to comma
          separatorWord = _comma;
          break;
      }

      // Extract digits after the decimal point using toString() for precision
      // and remove trailing zeros for standard representation (e.g., 1.50 -> "viens komats pieci").
      String fractionalDigits =
          fractionalPart.toString().substring(2); // Remove "0."
      // Remove trailing zeros
      while (fractionalDigits.endsWith('0') && fractionalDigits.length > 1) {
        fractionalDigits =
            fractionalDigits.substring(0, fractionalDigits.length - 1);
      }
      // If only "0" remained, it means the fractional part was .000...
      if (fractionalDigits == "0") {
        fractionalWords = ''; // Don't append anything for zero fraction
      } else {
        // Convert each digit to its word representation
        List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder20[digitInt]
              : '?'; // Use '?' for invalid digits
        }).toList();

        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }
    // else if (integerPart > BigInt.zero && absValue.scale > 0 && absValue.isInteger) {
    //   // This condition was present but empty. It's handled by fractionalPart being zero.
    //   // No action needed if the number like 123.0 is passed.
    // }

    return '$integerWords$fractionalWords';
  }

  /// Converts a non-negative integer [n] to its Latvian word representation.
  ///
  /// Handles numbers from zero up to the limits defined by [_scaleWords].
  /// Breaks the number into chunks of three digits and converts each chunk,
  /// adding the appropriate scale word (tūkstotis, miljons, etc.) with correct pluralization.
  ///
  /// - [n]: The non-negative `BigInt` to convert.
  /// Returns the integer in words.
  /// Throws [ArgumentError] if [n] is negative or exceeds defined scales.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero) {
      // This should not happen as we use absolute value, but guard anyway.
      throw ArgumentError("Integer must be non-negative for conversion: $n");
    }
    if (n == BigInt.zero) return _wordsUnder20[0]; // "nulle"

    // Handle numbers less than 1000 directly
    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt());
    }

    List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0; // 0 = units, 1 = thousands, 2 = millions, ...
    BigInt remaining = n;

    // Process the number in chunks of 1000
    while (remaining > BigInt.zero) {
      // Get the last three digits (0-999)
      BigInt chunk = remaining % oneThousand;
      // Remove the last three digits
      remaining ~/= oneThousand;

      if (chunk > BigInt.zero) {
        // Convert the 3-digit chunk to words
        String chunkText = _convertChunk(chunk.toInt());
        String scaleWord = "";

        // Add scale word if applicable (thousands, millions, etc.)
        if (scaleIndex > 0) {
          List<String>? scaleForms = _scaleWords[scaleIndex];
          if (scaleForms != null) {
            // Use singular form ("tūkstotis") if chunk is 1, plural ("tūkstoši") otherwise.
            scaleWord = (chunk == BigInt.one) ? scaleForms[0] : scaleForms[1];
          } else {
            // Number is too large for defined scales
            throw ArgumentError(
                "Number too large: exceeds defined scale index $scaleIndex");
          }
        }

        // Add the converted chunk and scale word to the parts list
        if (scaleWord.isNotEmpty) {
          parts.add("$chunkText $scaleWord");
        } else {
          // No scale word for the first chunk (0-999)
          parts.add(chunkText);
        }
      }
      scaleIndex++;
    }

    // Join the parts in reverse order (highest scale first)
    return parts.reversed.join(' ');
  }

  /// Converts a three-digit integer chunk ([n], 0-999) to its Latvian word representation.
  ///
  /// Helper function for [_convertInteger].
  ///
  /// - [n]: The integer chunk (0-999) to convert.
  /// Returns the chunk in words, or an empty string if [n] is 0.
  /// Throws [ArgumentError] if [n] is outside the 0-999 range.
  String _convertChunk(int n) {
    if (n == 0) return ""; // Return empty string for zero chunk
    if (n < 0 || n >= 1000) {
      // Should not happen if called correctly from _convertInteger
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }

    List<String> words = [];
    int remainder = n;

    // Handle hundreds place
    if (remainder >= 100) {
      words.add(_wordsHundreds[remainder ~/ 100]);
      remainder %= 100;
    }

    // Handle tens and units place
    if (remainder > 0) {
      if (remainder < 20) {
        // Numbers 1-19 are handled directly
        words.add(_wordsUnder20[remainder]);
      } else {
        // Numbers 20-99
        words.add(_wordsTens[
            remainder ~/ 10]); // Add the tens word (divdesmit, trīsdesmit, ...)
        int unit = remainder % 10;
        if (unit > 0) {
          // Add the units word if non-zero (viens, divi, ...)
          words.add(_wordsUnder20[unit]);
        }
      }
    }

    // Join the parts (e.g., ["viens simts", "divdesmit", "viens"]) with spaces
    return words.join(' ');
  }
}
