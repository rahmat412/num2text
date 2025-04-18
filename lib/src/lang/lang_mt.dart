import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/mt_options.dart';
import '../utils/utils.dart';

/// {@template num2text_mt}
/// The Maltese language (Lang.MT) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Maltese word representation following standard Maltese grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [MtOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (standard scale).
/// Includes specific handling for construct state numbers (e.g., "żewġt elef", "tliet mitt") and pluralization rules.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [MtOptions].
/// {@endtemplate}
class Num2TextMT implements Num2TextBase {
  /// The word used for the decimal point when `DecimalSeparator.period` is specified.
  static const String _point = "punt";

  /// The word used for the decimal separator when `DecimalSeparator.comma` is specified.
  static const String _comma = "virgola";

  /// The conjunction word for "and".
  static const String _and = "u";

  /// Suffix for negative years (Before Christ/Qabel Kristu).
  static const String _yearSuffixBC = "QK";

  /// Suffix for positive years (Anno Domini/Wara Kristu), used if `includeAD` is true.
  static const String _yearSuffixAD = "WK";

  /// Direct word representations for numbers 0 through 19.
  static const List<String> _wordsUnder20 = [
    "żero", // 0
    "wieħed", // 1
    "tnejn", // 2
    "tlieta", // 3
    "erbgħa", // 4
    "ħamsa", // 5
    "sitta", // 6
    "sebgħa", // 7
    "tmienja", // 8
    "disgħa", // 9
    "għaxra", // 10
    "ħdax", // 11
    "tnax", // 12
    "tlettax", // 13
    "erbatax", // 14
    "ħmistax", // 15
    "sittax", // 16
    "sbatax", // 17
    "tmintax", // 18
    "dsatax", // 19
  ];

  /// Direct word representations for tens (10, 20, ..., 90). Index 0 is unused.
  static const List<String> _wordsTens = [
    "", // 0 (unused)
    "għaxra", // 10
    "għoxrin", // 20
    "tletin", // 30
    "erbgħin", // 40
    "ħamsin", // 50
    "sittin", // 60
    "sebgħin", // 70
    "tmenin", // 80
    "disgħin", // 90
  ];

  /// Construct state forms for numbers 2-10 when preceding "elef" (thousands).
  /// Example: 2000 is "żewġt elef".
  static const Map<int, String> _constructBeforeElef = {
    2: "żewġt",
    3: "tlitt",
    4: "erbat",
    5: "ħamest",
    6: "sitt",
    7: "sebat",
    8: "tmien",
    9: "disat",
    10: "għaxart",
  };

  /// Construct state forms for numbers 2-10 when preceding million, billion, etc.
  /// Example: 2,000,000 is "żewġ miljuni".
  static const Map<int, String> _constructBeforeMillions = {
    2: "żewġ",
    3: "tliet",
    4: "erba'",
    5: "ħames",
    6: "sitt",
    7: "seba'",
    8: "tmien",
    9: "disa'",
    10: "għaxar",
  };

  /// Word representations for hundreds (100, 200, ..., 900).
  static const Map<int, String> _wordsHundredsMap = {
    1: "mitt", // 100
    2: "mitejn", // 200
    3: "tliet mitt", // 300
    4: "erba' mitt", // 400
    5: "ħames mitt", // 500
    6: "sitt mitt", // 600
    7: "seba' mitt", // 700
    8: "tmien mitt", // 800
    9: "disa' mitt", // 900
  };

  /// Defines the scale words (thousands, millions, etc.) and their singular/plural forms.
  /// Keyed by the scale level (1 = thousands, 2 = millions, ...).
  static final Map<int, Map<String, String>> _scaleWords = {
    1: {"singular": "elf", "plural": "elef"}, // Thousand
    2: {"singular": "miljun", "plural": "miljuni"}, // Million
    3: {
      "singular": "biljun",
      "plural": "biljuni"
    }, // Billion (short scale) / Milliard (long scale)
    4: {"singular": "triljun", "plural": "triljuni"}, // Trillion / Billion
    5: {
      "singular": "kwadriljun",
      "plural": "kwadriljuni"
    }, // Quadrillion / Billiard
    6: {
      "singular": "kwintiljun",
      "plural": "kwintiljuni"
    }, // Quintillion / Trillion
    7: {
      "singular": "sestiljun",
      "plural": "sestiljuni"
    }, // Sextillion / Trilliard
    8: {
      "singular": "settiljun",
      "plural": "settiljuni"
    }, // Septillion / Quadrillion
    // Add more scales if needed
  };

  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Determine options, defaulting to MtOptions if not provided or incorrect type.
    final MtOptions mtOptions =
        options is MtOptions ? options : const MtOptions();

    // Handle special double values first.
    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Infinità Negattiva" : "Infinità";
      if (number.isNaN) return fallbackOnError ?? "Mhux Numru"; // Not a Number
    }

    // Normalize the input number to Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) {
      return fallbackOnError ??
          "Mhux Numru"; // Return fallback if normalization fails.
    }

    // Handle the zero case specifically.
    if (decimalValue == Decimal.zero) {
      // If currency format, add the main unit name.
      return mtOptions.currency
          ? "${_wordsUnder20[0]} ${mtOptions.currencyInfo.mainUnitSingular}" // "żero [unit]"
          : _wordsUnder20[0]; // "żero"
    }

    // Determine sign and use the absolute value for conversion.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    // Delegate based on format option.
    if (mtOptions.format == Format.year) {
      // Year format needs integer part only.
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), mtOptions);
    } else {
      // Handle currency or standard number format.
      if (mtOptions.currency) {
        textResult = _handleCurrency(absValue, mtOptions);
      } else {
        textResult = _handleStandardNumber(absValue, mtOptions);
      }
      // Prepend negative prefix if applicable (and not year format).
      if (isNegative && mtOptions.format != Format.year) {
        textResult = "${mtOptions.negativePrefix} $textResult";
      }
    }
    // Clean up extra spaces before returning.
    return textResult.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Converts an integer year into its Maltese word representation, handling BC/AD suffixes.
  ///
  /// - [year]: The integer year to convert.
  /// - [options]: The Maltese-specific options.
  /// Returns the year in words, potentially with era suffix.
  String _handleYearFormat(int year, MtOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;

    // Convert the absolute year value to words.
    String yearText = _convertInteger(BigInt.from(absYear));

    // Append the appropriate era suffix.
    if (isNegative) {
      yearText += " $_yearSuffixBC"; // Add "QK" for BC years.
    } else if (options.includeAD) {
      yearText += " $_yearSuffixAD"; // Add "WK" for AD years if requested.
    }
    return yearText;
  }

  /// Converts a Decimal value into Maltese currency words.
  ///
  /// - [absValue]: The absolute (non-negative) Decimal value of the currency.
  /// - [options]: The Maltese-specific options, including currency info.
  /// Returns the currency value in words (e.g., "żewġ miljuni ewro u ħamsin ċenteżmu").
  String _handleCurrency(Decimal absValue, MtOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    // Standard currency usually has 2 decimal places for subunits.
    final int decimalPlaces = 2;
    final Decimal subunitMultiplier =
        Decimal.ten.pow(decimalPlaces).toDecimal();

    // Round the value if requested, otherwise use as is.
    final Decimal valueToConvert =
        options.round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate the main unit and subunit values.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).truncate().toBigInt();

    String mainTextResult;
    String mainUnitName;
    String subunitTextResult = "";

    // --- Handle Main Unit ---
    if (mainValue == BigInt.one) {
      // Singular main unit.
      mainUnitName = currencyInfo.mainUnitSingular;
      // Format: "[unit] wieħed"
      mainTextResult = "$mainUnitName ${_convertInteger(mainValue)}";
    } else {
      // Plural or zero main unit.
      mainUnitName =
          currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;
      String numberText;
      int mainInt = mainValue.toInt();
      // Use construct state form for 2-10 before plural unit names like 'miljuni', 'biljuni', etc.
      if (mainInt >= 2 &&
          mainInt <= 10 &&
          _constructBeforeMillions.containsKey(mainInt)) {
        numberText =
            _constructBeforeMillions[mainInt]!; // e.g., "żewġ", "tliet"
      } else {
        // Convert the number normally otherwise.
        numberText = _convertInteger(mainValue);
      }
      // Format: "[number] [plural unit]"
      mainTextResult = "$numberText $mainUnitName";
    }

    // --- Handle Sub Unit ---
    if (subunitValue > BigInt.zero) {
      String subUnitName;
      String subunitNumText;
      int subInt = subunitValue.toInt();

      if (subunitValue == BigInt.one) {
        // Singular subunit.
        subUnitName = currencyInfo.subUnitSingular ?? "";
        // Format: "[subunit] wieħed" or just "wieħed" if subunit name is empty.
        subunitNumText = subUnitName.isNotEmpty
            ? "$subUnitName ${_convertInteger(subunitValue)}"
            : _convertInteger(subunitValue);
      } else {
        // Plural subunit.
        subUnitName =
            currencyInfo.subUnitPlural ?? currencyInfo.subUnitSingular ?? "";
        // Use construct state form for 2-10.
        if (subInt >= 2 &&
            subInt <= 10 &&
            _constructBeforeMillions.containsKey(subInt)) {
          subunitNumText =
              _constructBeforeMillions[subInt]!; // e.g., "żewġ", "tliet"
        } else {
          // Convert number normally.
          subunitNumText = _convertInteger(subunitValue);
        }
        // Format: "[number] [plural subunit]" or just "[number]" if subunit name is empty.
        subunitNumText = subUnitName.isNotEmpty
            ? "$subunitNumText $subUnitName"
            : subunitNumText;
      }
      // Determine the separator (defaults to "u").
      final String separator = currencyInfo.separator ?? _and;
      // Append separator and subunit text.
      subunitTextResult = ' $separator $subunitNumText';
    }
    // Combine main and subunit parts.
    return '$mainTextResult$subunitTextResult';
  }

  /// Converts a standard Decimal number (integer or with fractional part) into words.
  ///
  /// - [absValue]: The absolute (non-negative) Decimal value.
  /// - [options]: The Maltese-specific options.
  /// Returns the number in words (e.g., "mitt u wieħed punt ħamsa").
  String _handleStandardNumber(Decimal absValue, MtOptions options) {
    // Separate integer and fractional parts.
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part to words. Handle case where integer is 0 but fraction exists.
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _wordsUnder20[0] // "żero"
            : _convertInteger(integerPart);

    String fractionalWords = '';
    // If there is a fractional part...
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word based on options ("punt" or "virgola").
      String separatorWord =
          (options.decimalSeparator == DecimalSeparator.comma)
              ? _comma
              : _point;

      // Extract fractional digits as a string.
      String fractionalDigits = "";
      if (absValue.scale > 0 && !absValue.isInteger) {
        fractionalDigits = absValue.toString().split('.').last;
      }

      if (fractionalDigits.isNotEmpty) {
        // Convert each digit after the separator individually.
        List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder20[digitInt] // Use words 0-9
              : '?'; // Placeholder for non-digit characters
        }).toList();

        // Specific cleanup: If using "punt" and the last digit is zero, and removing it doesn't
        // change the value (e.g., 1.50 vs 1.5), remove the trailing "żero".
        if (separatorWord == _point &&
            digitWords.length > 1 &&
            digitWords.last == _wordsUnder20[0]) {
          // Check if truncating the last digit changes the original value.
          var truncatedVal = absValue.truncate(scale: absValue.scale - 1);
          if (truncatedVal == absValue) {
            digitWords.removeLast();
          }
        }
        // Join the digit words with spaces.
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }
    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative BigInt into its Maltese word representation.
  /// Handles large numbers by chunking into thousands and applying scale words.
  ///
  /// - [n]: The non-negative BigInt to convert.
  /// Returns the integer in words.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero)
      throw ArgumentError("Integer must be non-negative: $n");
    if (n == BigInt.zero) return _wordsUnder20[0]; // "żero"
    // Special case for exactly 1000.
    if (n == BigInt.from(1000)) return _scaleWords[1]!["singular"]!; // "elf"
    // Handle numbers less than 1000 directly.
    if (n < BigInt.from(1000)) return _convertChunk(n.toInt());

    List<Map<String, dynamic>> partsList =
        []; // Stores converted chunks and their scale level.
    final BigInt oneThousand = BigInt.from(1000);
    int scaleLevel = 0; // 0: units, 1: thousands, 2: millions, ...
    BigInt remaining = n;

    // Process the number in chunks of 1000 from right to left.
    while (remaining > BigInt.zero) {
      BigInt chunkBigInt = remaining % oneThousand;
      int chunk = chunkBigInt.toInt(); // Current chunk (0-999).
      remaining ~/= oneThousand; // Move to the next chunk.

      if (chunk > 0) {
        String chunkText = "";
        String scaleWordText = "";

        if (scaleLevel > 0) {
          // Handle thousands, millions, etc.
          final scaleInfo = _scaleWords[scaleLevel];
          if (scaleInfo == null)
            throw ArgumentError("Scale level $scaleLevel not defined.");

          // Determine if plural scale word is needed (2-10 elef, 2-10 miljuni, etc.).
          bool usePluralScale = (chunk >= 2 && chunk <= 10);
          scaleWordText =
              usePluralScale ? scaleInfo["plural"]! : scaleInfo["singular"]!;

          if (chunk == 1) {
            // Just use the scale word (e.g., "elf", "miljun").
            chunkText = ""; // Chunk number is implicit.
          } else if (chunk >= 2 && chunk <= 10) {
            // Use construct state form before the scale word.
            chunkText = (scaleLevel == 1)
                ? _constructBeforeElef[
                    chunk]! // "żewġt", "tlitt", ... before "elef"
                : _constructBeforeMillions[
                    chunk]!; // "żewġ", "tliet", ... before "miljuni" etc.
          } else if (chunk >= 11 && chunk <= 19) {
            // Special "-il" suffix for 11-19 before scale words.
            chunkText =
                "${_convertChunk(chunk)}-il"; // "ħdax-il", "tnax-il", ...
            // Use singular scale word even though number > 1.
            scaleWordText = scaleInfo["singular"]!; // "elf", "miljun", ...
          } else {
            // Convert chunk normally.
            chunkText = _convertChunk(chunk);
            // Special case: "mitt elf", not "mitt elef" (use singular scale word).
            if (chunkText == "mitt" && scaleLevel == 1) {
              scaleWordText = scaleInfo["singular"]!;
            }
          }
          // Combine chunk text (if any) and scale word.
          partsList.add({
            "text": "$chunkText $scaleWordText".trim(),
            "scale": scaleLevel
          });
        } else {
          // Handle the units chunk (0-999).
          chunkText = _convertChunk(chunk);
          partsList.add({"text": chunkText, "scale": scaleLevel});
        }
      }
      scaleLevel++; // Increment scale level for the next chunk.
    }

    if (partsList.isEmpty) return ""; // Should not happen if n > 0.

    // Assemble the final string from the parts list, inserting separators.
    StringBuffer finalResult = StringBuffer();
    for (int i = partsList.length - 1; i >= 0; i--) {
      final currentPart = partsList[i];
      final String currentText = currentPart["text"];
      final int currentScale = currentPart["scale"];

      finalResult.write(currentText);

      // Determine separator needed before the next (less significant) part.
      if (i > 0) {
        final nextPart = partsList[i - 1];
        final int nextScale = nextPart["scale"];
        String separator = "";

        // Logic for separators (',' or ' u ') between scale levels.
        if (currentScale >= 2) {
          // Millions or higher
          if (nextScale == 1) {
            // Followed by thousands
            separator = " u ";
          } else if (nextScale == 0) {
            // Followed by units
            separator = " u ";
          } else {
            // Followed by another high scale (e.g., billions followed by millions)
            separator = ", ";
          }
        } else if (currentScale == 1) {
          // Thousands
          if (nextScale == 0) {
            // Followed by units
            // Special case: "ħdax-il elf wieħed" (no 'u'), otherwise use 'u'.
            separator = currentText.contains("-il") ? " " : " u ";
          }
        }

        finalResult.write(separator);
      }
    }
    return finalResult.toString();
  }

  /// Converts a three-digit integer chunk (0-999) into its Maltese word representation.
  ///
  /// - [n]: The integer chunk (0 <= n < 1000).
  /// Returns the chunk in words.
  String _convertChunk(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000)
      throw ArgumentError("Chunk must be between 0 and 999: $n");

    List<String> words = []; // Holds parts of the chunk's word representation.
    int remainder = n;
    bool needsAnd = false; // Flag to add "u" between hundreds and tens/units.

    // Handle hundreds place.
    if (remainder >= 100) {
      words.add(
          _wordsHundredsMap[remainder ~/ 100]!); // Add "mitt", "mitejn", etc.
      remainder %= 100; // Get the remaining part (0-99).
      if (remainder > 0) needsAnd = true; // Need "u" if there's more to come.
    }

    // Handle the remaining part (0-99).
    if (remainder > 0) {
      if (needsAnd) words.add(_and); // Add "u" if needed.
      if (remainder < 20) {
        // Numbers 1-19 are direct lookups.
        words.add(_wordsUnder20[remainder]);
      } else {
        // Numbers 20-99.
        int unit = remainder % 10;
        int tenIndex = remainder ~/ 10;
        if (unit > 0) {
          // Format: "[unit] u [ten]" e.g., "wieħed u tletin" (31)
          words.add(_wordsUnder20[unit]);
          words.add(_and); // Add "u" between unit and ten.
        }
        // Add the ten word ("għoxrin", "tletin", etc.).
        words.add(_wordsTens[tenIndex]);
      }
    }
    // Join the parts with spaces.
    return words.join(' ');
  }
}
