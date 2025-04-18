import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/pt_options.dart';
import '../utils/utils.dart';

/// {@template num2text_pt}
/// The Portuguese language (Lang.PT) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Portuguese word representation following standard Portuguese grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [PtOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (short scale:
/// milhão, bilhão, etc.). It correctly applies rules for "cem" vs "cento" and the conjunction "e".
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [PtOptions].
/// {@endtemplate}
class Num2TextPT implements Num2TextBase {
  /// The word for "zero".
  static const String _zero = "zero";

  /// The word for the decimal separator comma (default in Portuguese).
  static const String _comma = "vírgula";

  /// The word for the alternative decimal separator period/point.
  static const String _point = "ponto";

  /// The conjunction "e" (and).
  static const String _and = "e";

  /// The word for 100 when used alone or as the last chunk.
  static const String _hundred = "cem";

  /// Suffix for years Before Christ (Antes de Cristo).
  static const String _yearSuffixBC = "a.C.";

  /// Suffix for years Anno Domini (Depois de Cristo).
  static const String _yearSuffixAD = "d.C.";

  /// Word for positive infinity.
  static const String _infinity = "Infinito";

  /// Word for negative infinity.
  static const String _negativeInfinity = "Menos Infinito";

  /// Word for Not-a-Number (NaN).
  static const String _notANumber = "Não é um número";

  /// Word representations for numbers 0 through 19.
  static const List<String> _wordsUnder20 = [
    "zero", // 0
    "um", // 1
    "dois", // 2
    "três", // 3
    "quatro", // 4
    "cinco", // 5
    "seis", // 6
    "sete", // 7
    "oito", // 8
    "nove", // 9
    "dez", // 10
    "onze", // 11
    "doze", // 12
    "treze", // 13
    "catorze", // 14
    "quinze", // 15
    "dezesseis", // 16
    "dezessete", // 17
    "dezoito", // 18
    "dezenove", // 19
  ];

  /// Word representations for tens (20, 30, ..., 90).
  /// The index corresponds to the tens digit (e.g., index 2 is "vinte").
  static const List<String> _wordsTens = [
    "", // 0 - unused placeholder
    "", // 1 - unused (covered by _wordsUnder20)
    "vinte", // 20
    "trinta", // 30
    "quarenta", // 40
    "cinquenta", // 50
    "sessenta", // 60
    "setenta", // 70
    "oitenta", // 80
    "noventa", // 90
  ];

  /// Word representations for hundreds (100, 200, ..., 900).
  /// Includes the special base "cento" for 101-199 and "cem" for exactly 100.
  static const Map<int, String> _wordsHundredsMap = {
    100: "cem", // Special case for exactly 100 (handled in _convertChunk)
    1: "cento", // Base for 101-199
    2: "duzentos",
    3: "trezentos",
    4: "quatrocentos",
    5: "quinhentos",
    6: "seiscentos",
    7: "setecentos",
    8: "oitocentos",
    9: "novecentos",
  };

  /// Scale words for large numbers (thousand, million, billion, etc.).
  /// Each inner list contains `[singular, plural]` forms.
  /// The first entry represents units (scale 0), the second thousands (scale 1), etc.
  /// "mil" has the same singular and plural form. Uses short scale (common in Brazil).
  static const List<List<String>> _scaleWords = [
    ["", ""], // Units (scale 0) - No scale word
    ["mil", "mil"], // Thousands (scale 1)
    ["milhão", "milhões"], // Millions (scale 2)
    ["bilhão", "bilhões"], // Billions (scale 3)
    ["trilhão", "trilhões"], // Trillions (scale 4)
    ["quatrilhão", "quatrilhões"], // Quadrillions (scale 5)
    ["quintilhão", "quintilhões"], // Quintillions (scale 6)
    ["sextilhão", "sextilhões"], // Sextillions (scale 7)
    ["septilhão", "septilhões"], // Septillions (scale 8)
    // Add more scales here (e.g., octillion, nonillion) if needed, following the pattern.
  ];

  /// Processes the given [number] and converts it into Portuguese words based on the provided [options].
  ///
  /// This is the main entry point for the Portuguese converter.
  ///
  /// - [number]: The number to convert. Can be `int`, `double`, `BigInt`, `String`,
  ///   or `Decimal`. Non-numeric types or invalid strings will result in an error fallback.
  /// - [options]: An optional `BaseOptions` object. If it's a `PtOptions`, specific
  ///   Portuguese settings (like currency details, year format, negative prefix) are used.
  ///   If null or not a `PtOptions`, default `PtOptions()` are used.
  /// - [fallbackOnError]: A custom string to return if the input `number` is invalid
  ///   (e.g., null, NaN, non-numeric string) or if conversion fails unexpectedly.
  ///   If `null`, default internal error messages like [_notANumber] or [_infinity] are used.
  ///
  /// Returns the Portuguese word representation of the number, or an error string
  /// if the input is invalid or conversion fails.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have Portuguese-specific options, using defaults if necessary.
    final PtOptions ptOptions =
        options is PtOptions ? options : const PtOptions();
    final String errorDefault = fallbackOnError ?? _notANumber;

    // Handle special floating-point values immediately.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? _negativeInfinity : _infinity;
      }
      if (number.isNaN) {
        return errorDefault;
      }
    }

    // Normalize the input number to a Decimal for consistent internal handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // If normalization fails, return fallback.
    if (decimalValue == null) {
      return errorDefault;
    }

    // Handle the special case of zero.
    if (decimalValue == Decimal.zero) {
      // For currency format, zero requires the plural main unit name (e.g., "zero reais").
      if (ptOptions.currency) {
        final String mainUnit = ptOptions.currencyInfo.mainUnitPlural ??
            ptOptions.currencyInfo.mainUnitSingular;
        return "$_zero $mainUnit";
      } else {
        // For standard format, just return "zero".
        return _zero;
      }
    }

    // Determine the sign and work with the absolute value internally.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Delegate processing based on the format specified in options.
    if (ptOptions.format == Format.year) {
      // Handle year formatting. Years are treated as integers. Sign handled internally.
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), ptOptions);
    } else {
      // Handle currency or standard number formatting using the absolute value.
      if (ptOptions.currency) {
        textResult = _handleCurrency(absValue, ptOptions);
      } else {
        textResult = _handleStandardNumber(absValue, ptOptions);
      }

      // If the original number was negative, prepend the negative prefix (unless it was a year).
      if (isNegative) {
        textResult = "${ptOptions.negativePrefix} $textResult";
      }
    }

    // Return the final result, ensuring clean spacing.
    return textResult.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Formats a [year] (as `BigInt`) into Portuguese words, handling BC/AD suffixes.
  ///
  /// Years are treated as integers. The sign determines the BC/AD suffix.
  ///
  /// - [year]: The year value (can be negative for BC/BCE).
  /// - [options]: The `PtOptions` controlling suffix inclusion (`includeAD`).
  ///
  /// Returns the year in words, potentially with "a.C." (for negative years)
  /// or "d.C." (for positive years if `options.includeAD` is true).
  String _handleYearFormat(BigInt year, PtOptions options) {
    final bool isNegative = year < BigInt.zero;
    // Work with the absolute value for conversion to words.
    final BigInt absYear = isNegative ? -year : year;

    // Convert the absolute year value to words using the integer converter.
    final String yearText = _convertInteger(absYear);

    // Append appropriate suffixes based on sign and options.
    if (isNegative) {
      // Always add "a.C." for negative (BC/BCE) years.
      return "$yearText $_yearSuffixBC";
    } else if (options.includeAD && year > BigInt.zero) {
      // Add "d.C." for positive (AD/CE) years only if requested via options.includeAD.
      return "$yearText $_yearSuffixAD";
    } else {
      // No suffix for positive years if includeAD is false, or for year zero.
      return yearText;
    }
  }

  /// Formats a non-negative [absValue] (`Decimal`) as Portuguese currency according to [options].
  ///
  /// Handles separation of main and subunits, rounding, pluralization of unit names,
  /// and the separator word ("e").
  ///
  /// - [absValue]: The non-negative monetary value.
  /// - [options]: The `PtOptions` containing currency info (`currencyInfo`) and rounding rules (`round`).
  ///
  /// Returns the currency value in words (e.g., "um real e cinquenta centavos", "dois euros").
  String _handleCurrency(Decimal absValue, PtOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;

    // Standard currency precision is 2 decimal places for subunits.
    const int decimalPlaces = 2;
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value *before* splitting if requested, otherwise use the original.
    final Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate the integer (main unit) and fractional (subunit) parts.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    // Calculate the subunit value precisely.
    final BigInt subunitValue =
        ((valueToConvert - Decimal.fromBigInt(mainValue)) * subunitMultiplier)
            .truncate()
            .toBigInt();

    final List<String> parts =
        []; // Holds the word parts (main unit, separator, subunit)

    // --- Process the main unit part ---
    if (mainValue > BigInt.zero) {
      final String mainText = _convertInteger(mainValue);
      // Determine singular or plural main unit name.
      final String mainUnitName = (mainValue == BigInt.one)
          ? currencyInfo.mainUnitSingular
          // Use plural if available, otherwise fall back to singular.
          : currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;
      parts.add('$mainText $mainUnitName');
    }

    // --- Process the subunit part ---
    if (subunitValue > BigInt.zero) {
      // Get the subunit name, handling singular/plural.
      final String? subUnitName = (subunitValue == BigInt.one)
          ? currencyInfo.subUnitSingular
          // Use plural if available, otherwise fall back to singular.
          : currencyInfo.subUnitPlural ?? currencyInfo.subUnitSingular;

      // Only add the subunit part if a valid name exists.
      if (subUnitName != null && subUnitName.isNotEmpty) {
        final String subunitText = _convertInteger(subunitValue);
        final String subunitPart = '$subunitText $subUnitName';

        // If there was also a main unit part, add the separator word ("e" or custom).
        if (parts.isNotEmpty) {
          parts.add(currencyInfo.separator ??
              _and); // Default to "e" if no separator specified
        }
        parts.add(subunitPart);
      }
    }

    // If after processing, 'parts' is empty, it means the value was effectively zero
    // (or had only subunits with no defined name). Return zero with plural main unit.
    if (parts.isEmpty) {
      final String mainUnit =
          currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;
      return "$_zero $mainUnit";
    }

    // Join the collected parts with spaces.
    return parts.join(' ');
  }

  /// Formats a non-negative [absValue] (`Decimal`) as a standard Portuguese number,
  /// including handling of the decimal part.
  ///
  /// - [absValue]: The non-negative number.
  /// - [options]: The `PtOptions` controlling the decimal separator word (`decimalSeparator`).
  ///
  /// Returns the number in words (e.g., "cento e vinte e três vírgula quatro cinco seis").
  String _handleStandardNumber(Decimal absValue, PtOptions options) {
    // Separate integer and fractional parts.
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - Decimal.fromBigInt(integerPart);

    // Convert the integer part. Handle the case where integer is zero but fraction exists (e.g., 0.5).
    final String integerWords = (integerPart == BigInt.zero &&
            fractionalPart > Decimal.zero)
        ? _zero // Use "zero" explicitly if integer part is 0 but fraction isn't.
        : _convertInteger(
            integerPart); // Otherwise, convert the integer part normally.

    String fractionalWords = '';

    // Process the fractional part only if it's greater than zero.
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word based on options.
      final String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.point:
        case DecimalSeparator.period: // Treat point and period the same
          separatorWord = _point;
          break;
        case DecimalSeparator.comma:
        default: // Default for Portuguese
          separatorWord = _comma;
          break;
      }

      // Extract the digits after the decimal point from the string representation.
      final String numberStr = absValue.toString();
      final int decimalPointIndex = numberStr.indexOf('.');
      String fractionalDigits = "";
      if (decimalPointIndex != -1) {
        fractionalDigits = numberStr.substring(decimalPointIndex + 1);
        // Remove trailing zeros as they are generally not spoken.
        fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');
      }

      // Convert each digit after the separator to its word representation.
      if (fractionalDigits.isNotEmpty) {
        final List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          // Ensure conversion is valid before looking up the word.
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder20[digitInt] // Get word from our list
              : '?'; // Placeholder for unexpected non-digit characters
        }).toList();
        // Combine separator and digit words.
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      } else {
        // If removing trailing zeros leaves no fractional part, don't add separator.
        fractionalWords = '';
      }
    }

    // Combine integer and fractional parts (if any). Trim whitespace just in case.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer [n] (`BigInt`) into Portuguese words.
  ///
  /// This method chunks the number into groups of three digits (thousands, millions, etc.)
  /// and applies the appropriate scale words ([_scaleWords]) with correct pluralization
  /// and the conjunction "e" according to Portuguese grammatical rules.
  ///
  /// **Portuguese "e" Rule Summary:**
  /// The conjunction "e" is typically used:
  /// 1. Between hundreds and tens/units within a chunk (handled in `_convertChunk`).
  /// 2. Before the *last* non-zero chunk *if* that chunk's value is less than 100 OR exactly 100.
  ///    Examples: "mil e um", "dois milhões e cinquenta", "três bilhões e cem", "mil e cem".
  /// It is *not* used if the last chunk is > 100 (e.g., "dois milhões cento e vinte", "mil duzentos") or
  /// between intermediate scale words (e.g., "um milhão mil", not "um milhão e mil").
  ///
  /// - [n]: The non-negative integer to convert.
  ///
  /// Returns the integer part in Portuguese words.
  /// Throws [ArgumentError] if the number is negative or exceeds the largest defined scale.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero) {
      // Internal function expects non-negative values; sign handled in `process`.
      throw ArgumentError(
          "Integer must be non-negative for _convertInteger: $n");
    }
    if (n == BigInt.zero) return _zero;

    // Numbers less than 1000 are handled directly by the chunk converter.
    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt());
    }

    final List<String> parts =
        []; // Stores word representations of chunks + scales
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0; // 0: units, 1: thousands, 2: millions, ...
    BigInt remaining = n;
    final List<int> chunkValues =
        []; // Stores the numeric value of each chunk for "e" logic

    // --- Step 1: Chunk the number and convert each chunk ---
    while (remaining > BigInt.zero) {
      // Ensure we haven't exceeded the defined scale words.
      if (scaleIndex >= _scaleWords.length) {
        // Safety check if the number is larger than the largest defined scale.
        throw ArgumentError(
            "Number too large (exceeds defined scales: ${_scaleWords.length - 1})");
      }

      // Extract the current chunk (0-999).
      final int chunk = (remaining % oneThousand).toInt();
      chunkValues.add(chunk); // Store numeric value for later use
      remaining ~/= oneThousand; // Move to the next chunk (integer division)

      // Convert the chunk to words if it's not zero.
      if (chunk > 0) {
        String chunkText = _convertChunk(chunk);

        // Special case for "mil": if the chunk is 1 for the thousands scale (scaleIndex 1),
        // omit "um". The result should be "mil", not "um mil".
        if (scaleIndex == 1 && chunk == 1) {
          chunkText =
              ""; // Correct text will come solely from the scale word "mil".
        }

        String scaleWord = "";
        // Get the appropriate scale word (mil, milhão, etc.) if applicable (scale > 0).
        if (scaleIndex > 0) {
          // Use singular scale word for 1 (except "mil"), plural otherwise
          scaleWord = (scaleIndex > 1 && chunk == 1)
              ? _scaleWords[scaleIndex][0] // Singular (e.g., milhão)
              : _scaleWords[scaleIndex][1]; // Plural (e.g., milhões) or "mil"
        }

        // Combine the chunk words and scale word. Handle the "mil" case where chunkText is empty.
        final String combinedPart =
            (chunkText.isNotEmpty && scaleWord.isNotEmpty)
                ? "$chunkText $scaleWord"
                : (chunkText.isEmpty && scaleWord.isNotEmpty)
                    ? scaleWord // Just "mil"
                    : chunkText; // Units chunk
        parts.add(combinedPart.trim());
      } else {
        // Add an empty placeholder if the chunk is zero to maintain correct scale positioning.
        parts.add("");
      }
      scaleIndex++;
    }

    // --- Step 2: Assemble the final string with correct "e" conjunctions ---
    final List<String> finalParts = [];
    // Reverse parts and chunkValues to process from largest scale down to smallest.
    final List<String> reversedParts = parts.reversed.toList();
    final List<int> reversedChunkValues = chunkValues.reversed.toList();

    // Find the index of the *last* chunk (smallest scale) that is not zero.
    final int lastNonZeroChunkIndex =
        reversedChunkValues.lastIndexWhere((v) => v != 0);

    // Iterate through the reversed parts (from largest scale down).
    for (int i = 0; i < reversedParts.length; i++) {
      final String part = reversedParts[i];
      if (part.isEmpty) continue; // Skip zero chunks

      finalParts.add(part); // Add the current part (e.g., "dois milhões")

      // Determine if "e" should be added *after* this part.
      // Find the index of the *next* non-zero part.
      int nextNonZeroIdx = -1;
      for (int j = i + 1; j < reversedParts.length; j++) {
        if (reversedParts[j].isNotEmpty) {
          nextNonZeroIdx = j;
          break;
        }
      }

      // Check if the 'next' non-zero part found is indeed the 'last' non-zero part overall.
      if (nextNonZeroIdx != -1 && nextNonZeroIdx == lastNonZeroChunkIndex) {
        // Get the numeric value of that last non-zero chunk.
        final int lastChunkValue = reversedChunkValues[lastNonZeroChunkIndex];

        // Add "e" only if the last chunk value is < 100 or exactly 100.
        if (lastChunkValue < 100 || lastChunkValue == 100) {
          finalParts.add(_and);
        }
      }
    }

    // Join the final parts with spaces.
    return finalParts.join(' ');
  }

  /// Converts a three-digit integer chunk (0-999) into Portuguese words.
  ///
  /// Handles the specific rules for "cem" vs "cento" and the use of "e"
  /// between hundreds and tens/units, and between tens and units.
  ///
  /// - [n]: The integer chunk (must be between 0 and 999).
  ///
  /// Returns the chunk in words (e.g., "cento e vinte e três", "cem", "trinta e dois").
  /// Returns an empty string for input 0.
  /// Throws [ArgumentError] if [n] is outside the valid range [0, 999].
  String _convertChunk(int n) {
    if (n == 0) return ""; // Represent zero chunk as empty string.
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }

    final List<String> words = []; // Holds word parts for this chunk
    int remainder = n;

    // --- Handle hundreds place ---
    if (remainder >= 100) {
      if (remainder == 100) {
        return _hundred; // Exactly 100 is "cem"
      } else {
        final int hundredDigit = remainder ~/ 100;
        words.add(_wordsHundredsMap[hundredDigit]!); // cento, duzentos, etc.
        remainder %= 100;
        if (remainder > 0) {
          words.add(_and); // Add "e" before remaining tens/units
        }
      }
    }

    // --- Handle tens and units place (remainder is now 0-99) ---
    if (remainder > 0) {
      // Numbers less than 20 have unique names.
      if (remainder < 20) {
        words.add(_wordsUnder20[remainder]); // um to dezenove
      } else {
        // Numbers 20 and above.
        final String tensWord =
            _wordsTens[remainder ~/ 10]; // vinte, trinta, etc.
        words.add(tensWord);
        final int unit = remainder % 10;
        if (unit > 0) {
          words.add(_and); // Add "e" before units digit
          words.add(_wordsUnder20[unit]); // Add the unit word.
        }
      }
    }

    // Join the collected word parts for the chunk.
    return words.join(' ');
  }
}
