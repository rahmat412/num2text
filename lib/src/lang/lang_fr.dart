import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/fr_options.dart'; // Options specific to French formatting.
import '../utils/utils.dart';

/// {@template num2text_fr}
/// The French language (`Lang.FR`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their French word representation following standard French grammar and vocabulary,
/// including rules for hyphens, "et un", and number agreement (e.g., plurals for "vingt", "cent").
///
/// Capabilities include handling cardinal numbers, currency (using [FrOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers using the
/// short scale system (but including "milliard").
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [FrOptions].
/// {@endtemplate}
class Num2TextFR implements Num2TextBase {
  // --- Constants ---

  /// The word for zero ("zéro").
  static const String _zero = "zéro";

  /// The word for the decimal separator when using a period (`.`).
  static const String _point = "point";

  /// The word for the decimal separator when using a comma (`,`) (standard in French).
  static const String _comma = "virgule";

  /// The conjunction "et" (and), specifically used for "vingt-et-un", "trente-et-un", etc., up to "soixante-et-onze".
  static const String _and = "et";

  /// The hyphen "-", used to connect parts of compound numbers (e.g., "vingt-trois", "quatre-vingt-dix").
  static const String _hyphen = "-";

  /// The word for hundred ("cent"). It takes an 's' in the plural when terminal and preceded by a multiplier > 1 (e.g., "deux cents").
  static const String _hundred = "cent";

  /// The word for thousand ("mille"). It is invariable (never takes an 's').
  static const String _thousand = "mille";

  /// The suffix for negative years, "avant Jésus-Christ" (Before Jesus Christ).
  static const String _yearSuffixBC = "av. J.-C.";

  /// The suffix for positive years, "après Jésus-Christ" (After Jesus Christ). Added only if [FrOptions.includeAD] is true.
  static const String _yearSuffixAD = "ap. J.-C.";

  /// Word forms for numbers 0 through 16. French handles 17-19 compositionally ("dix-sept", etc.).
  static const List<String> _wordsUnder20 = [
    "zéro", // 0
    "un", // 1
    "deux", // 2
    "trois", // 3
    "quatre", // 4
    "cinq", // 5
    "six", // 6
    "sept", // 7
    "huit", // 8
    "neuf", // 9
    "dix", // 10
    "onze", // 11
    "douze", // 12
    "treize", // 13
    "quatorze", // 14
    "quinze", // 15
    "seize", // 16
  ];

  /// Word forms for tens: 10, 20, 30, 40, 50, 60.
  /// French handles 70, 80, 90 compositionally ("soixante-dix", "quatre-vingt", "quatre-vingt-dix").
  /// Index corresponds to the tens digit (index 1 = 10, index 6 = 60).
  static const List<String> _wordsTens = [
    "", // 0 - Not used directly
    "dix", // 10
    "vingt", // 20 (takes 's' in "quatre-vingts" when terminal)
    "trente", // 30
    "quarante", // 40
    "cinquante", // 50
    "soixante", // 60
  ];

  /// Defines scale words (million, milliard, billion, etc.) by their exponent (10^exponent).
  /// This map uses the short scale system extended with "milliard".
  /// Key: Exponent (e.g., 6 for 10^6).
  /// Value: List containing `[singular form, plural form]`.
  static const Map<int, List<String>> _scaleWordsByExponent = {
    6: ["million", "millions"], // 10^6
    9: ["milliard", "milliards"], // 10^9 (common in French/European usage)
    12: ["billion", "billions"], // 10^12 (short scale)
    15: [
      "billiard",
      "billiards"
    ], // 10^15 (intermediate term, less common in pure short scale)
    18: ["trillion", "trillions"], // 10^18 (short scale)
    21: ["trilliard", "trilliards"], // 10^21 (intermediate term)
    24: ["quadrillion", "quadrillions"], // 10^24 (short scale)
    // Can be extended further (quadrilliard, quintillion, etc.)
  };

  /// Pre-computed map of scale words indexed by their group position (0=units, 1=thousands, 2=millions, 3=milliards...).
  /// This is derived from `_scaleWordsByExponent` for easier lookup during conversion.
  static final Map<int, List<String>> _scaleWordsByIndex = {
    1: [_thousand, _thousand], // Thousands (group 1) - invariable "mille"
    // Dynamically populate from the exponent map: index = exponent / 3
    for (var entry in _scaleWordsByExponent.entries)
      (entry.key ~/ 3): entry.value,
  };

  /// {@macro num2text_base_process}
  /// Converts the given [number] into its French word representation.
  ///
  /// Handles `int`, `double`, `BigInt`, `Decimal`, and numeric `String` inputs.
  /// Uses [FrOptions] to customize behavior like currency formatting ([FrOptions.currency], [FrOptions.currencyInfo]),
  /// year formatting ([Format.year]), decimal separator ([FrOptions.decimalSeparator]),
  /// and negative prefix ([FrOptions.negativePrefix]).
  /// If `options` is not an instance of [FrOptions], default settings are used.
  ///
  /// Returns the word representation (e.g., "cent vingt-trois", "moins dix virgule cinq", "un million").
  /// If the input is invalid (`null`, `NaN`, `Infinity`, non-numeric string), it returns
  /// [fallbackOnError] if provided, otherwise a default error message like "N'est pas un nombre".
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have French-specific options, using defaults if none are provided.
    final FrOptions frOptions =
        options is FrOptions ? options : const FrOptions();

    // Handle special non-finite double values early.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? "Moins l'infini"
            : "Infini"; // Localized infinity
      }
      if (number.isNaN)
        return fallbackOnError ?? "N'est pas un nombre"; // Not a Number
    }

    // Normalize the input to a Decimal for precise calculations.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Return error if normalization failed (invalid input type or format).
    if (decimalValue == null) return fallbackOnError ?? "N'est pas un nombre";

    // Handle the specific case of zero.
    if (decimalValue == Decimal.zero) {
      if (frOptions.currency) {
        // Currency format for zero (e.g., "zéro euro"). Assumes singular currency unit for zero.
        return "$_zero ${frOptions.currencyInfo.mainUnitSingular}";
      }
      // Standard "zéro". Also covers year 0.
      return _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for the core conversion logic.
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    // --- Dispatch based on format options ---
    if (frOptions.format == Format.year) {
      // Year format needs the original integer value (positive or negative).
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), frOptions);
      // Note: Negative sign is handled by appending BC/AD, not the standard negative prefix.
    } else {
      // Handle currency or standard number format for the absolute value.
      if (frOptions.currency) {
        textResult = _handleCurrency(absValue, frOptions);
      } else {
        textResult = _handleStandardNumber(absValue, frOptions);
      }
      // Prepend the negative prefix *only* if it's a standard number or currency, not a year.
      if (isNegative) {
        textResult = "${frOptions.negativePrefix} $textResult";
      }
    }

    // Clean up potential extra spaces before returning.
    return textResult.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Formats an integer as a calendar year, optionally adding BC/AD suffixes.
  /// Years are converted as cardinal numbers.
  ///
  /// [year]: The integer year value (can be negative for BC).
  /// [options]: French options, specifically checks `includeAD`.
  /// Returns the year in words, e.g., "mille neuf cent quatre-vingt-dix-neuf", "cinq cents av. J.-C.".
  String _handleYearFormat(int year, FrOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;

    // Handle year 0.
    if (absYear == 0) return _zero;

    // Convert the absolute year value as a standard integer.
    String yearText = _convertInteger(BigInt.from(absYear));

    // Append era suffixes based on the year's sign and options.
    if (isNegative) {
      yearText +=
          " $_yearSuffixBC"; // Always add "av. J.-C." for negative years.
    } else if (options.includeAD) {
      // Add "ap. J.-C." for positive years *only if* requested via options.
      // Note: absYear > 0 check is implicit as year 0 is handled above.
      yearText += " $_yearSuffixAD";
    }
    return yearText;
  }

  /// Formats a [Decimal] value as a currency amount in words.
  /// Handles main units and subunits based on [FrOptions.currencyInfo].
  /// Applies rounding if [FrOptions.round] is true.
  /// Handles pluralization of currency units.
  ///
  /// [absValue]: The non-negative currency amount.
  /// [options]: French options containing currency details and rounding preference.
  /// Returns the currency amount in words, e.g., "un euro et cinquante centimes", "deux euros".
  String _handleCurrency(Decimal absValue, FrOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    // Assume 2 decimal places for subunits (e.g., cents), common for most currencies.
    final int decimalPlaces = 2;
    final Decimal subunitMultiplier =
        Decimal.ten.pow(decimalPlaces).toDecimal(); // 100

    // Apply rounding to the specified decimal places if requested.
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate the integer (main unit) and fractional (subunit) parts.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Calculate the subunit value as an integer (e.g., 0.50 becomes 50).
    // Use abs() on fractional part in case of rounding artifacts near zero.
    final BigInt subunitValue =
        (fractionalPart.abs() * subunitMultiplier).truncate().toBigInt();

    // Convert the main unit integer part to words.
    String mainText = _convertInteger(mainValue);

    // Determine the correct main unit name (singular or plural).
    // Use absolute value for comparison as mainValue could be negative if original input was.
    String mainUnitName = (mainValue.abs() == BigInt.one)
        ? currencyInfo.mainUnitSingular
        // Use null-aware operator and fallback, though CurrencyInfo expects non-null plurals usually.
        : (currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular);

    // Start building the result string with the main unit part.
    String result = '$mainText $mainUnitName';

    // Add the subunit part if it exists (value > 0) and subunit names are defined.
    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      // Convert the subunit integer part to words.
      String subunitText = _convertInteger(subunitValue);
      // Determine the correct subunit name (singular or plural).
      String subUnitName = (subunitValue.abs() == BigInt.one)
          ? currencyInfo.subUnitSingular!
          : (currencyInfo.subUnitPlural ?? currencyInfo.subUnitSingular!);

      // Get the separator word (e.g., "et") from currency info or use the default.
      String separator =
          currencyInfo.separator ?? _and; // Default to "et" if not provided.
      // Ensure separator has spaces around it.
      if (!separator.startsWith(' ')) separator = ' $separator';
      if (!separator.endsWith(' ')) separator = '$separator ';

      // Append the separator and the subunit part.
      result += '$separator$subunitText $subUnitName';
    }
    return result;
  }

  /// Formats a standard [Decimal] number (non-currency, non-year) into words.
  /// Handles both the integer and fractional parts.
  /// The fractional part is read digit by digit after the separator word ("virgule" or "point").
  ///
  /// [absValue]: The non-negative number.
  /// [options]: French options, used for `decimalSeparator`.
  /// Returns the number in words, e.g., "cent vingt-trois virgule quatre cinq six".
  String _handleStandardNumber(Decimal absValue, FrOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part. Use "zéro" if integer is zero but there's a fractional part.
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero // Handle cases like 0.5 -> "zéro virgule cinq"
            : _convertInteger(integerPart);

    String fractionalWords = '';
    // Process fractional part only if it's greater than zero.
    if (fractionalPart > Decimal.zero) {
      // Determine the decimal separator word based on options.
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          separatorWord = _point;
          break;
        case DecimalSeparator.comma:
        default: // Default to "virgule" for French.
          separatorWord = _comma;
          break;
      }

      // Get the fractional part as a string.
      String fractionalString = fractionalPart.toString(); // e.g., "0.123"
      // Extract digits after the "0.".
      String digits = fractionalString.substring(2);

      // Remove trailing zeros unless it's just "0". This prevents "un virgule cinq zéro".
      while (digits.endsWith('0') && digits.length > 1) {
        digits = digits.substring(0, digits.length - 1);
      }
      // Ensure we have at least one digit if fractionalPart was > 0.
      if (digits.isEmpty) digits = "0";

      // Convert each digit character to its word form.
      List<String> digitWords = digits.split('').map((digitChar) {
        final int? digitInt = int.tryParse(digitChar);
        // Map the digit to its word using _wordsUnder20.
        return (digitInt != null && digitInt >= 0 && digitInt <= 9)
            ? _wordsUnder20[digitInt]
            : '?'; // Placeholder for unexpected non-digit characters
      }).toList();

      // Add space before separator unless the integer part was zero.
      String prefixSpace =
          (integerPart == BigInt.zero && integerWords == _zero) ? "" : " ";
      // Combine the separator word and the individual digit words.
      fractionalWords = '$prefixSpace$separatorWord ${digitWords.join(' ')}';
    }
    // This else-if block seems intended to handle cases like Decimal('1.0') but might be redundant or incorrect.
    // Standard handling above should cover .0 cases if fractionalPart > Decimal.zero is false.
    // else if (integerPart > BigInt.zero && absValue.scale > 0 && absValue.isInteger) {
    // Handle cases like 1.0 -> "un virgule zéro"? Usually not desired.
    // }

    // Combine integer and fractional parts. Use trim to avoid leading/trailing spaces.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] integer into its French word representation.
  /// This is the main recursive function, breaking the number into 3-digit chunks
  /// and applying scale words (mille, million, milliard, etc.).
  ///
  /// [n]: The non-negative integer to convert. Must not be negative.
  /// Returns the integer in words, e.g., "un million deux cent mille trois cent quarante-cinq".
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _zero; // Base case: zero.
    // Ensure input is non-negative as negative sign is handled elsewhere.
    if (n < BigInt.zero) {
      throw ArgumentError("Input must be non-negative for _convertInteger: $n");
    }

    // Handle numbers less than 1000 directly using the chunk converter.
    if (n < BigInt.from(1000)) {
      // The lowest chunk is considered terminal for pluralization rules ('s' on cent/vingt).
      return _convertChunk(n.toInt(), isTerminalChunk: true);
    }

    List<String> parts =
        []; // Stores word parts for each scale level (thousands, millions...).
    BigInt remaining = n;
    final BigInt thousand = BigInt.from(1000);
    int groupIndex = 0; // 0=units chunk, 1=thousands chunk, 2=millions chunk...
    bool isLowestGroup =
        true; // Flag to track if we are processing the lowest (0-999) group.

    // Process the number in chunks of 1000 from right to left.
    while (remaining > BigInt.zero) {
      // Get the current 3-digit chunk (0-999).
      int chunkValue = (remaining % thousand).toInt();
      remaining ~/= thousand; // Move to the next higher chunk.

      // Only process non-zero chunks.
      if (chunkValue > 0) {
        // Determine if this chunk is the terminal one (the rightmost non-zero chunk).
        // This affects pluralization of "cent" and "vingt".
        bool isTerminal = isLowestGroup;
        // Convert the 3-digit chunk to words.
        String chunkText =
            _convertChunk(chunkValue, isTerminalChunk: isTerminal);

        // Determine the scale word (mille, million, etc.) for this group index.
        String? scaleWord;
        if (groupIndex > 0) {
          // Skip scale word for the base units group (index 0).
          if (_scaleWordsByIndex.containsKey(groupIndex)) {
            final scaleNames = _scaleWordsByIndex[groupIndex]!;
            // Use plural scale word (millions, milliards) if chunk > 1, except for invariable "mille".
            bool usePluralScale =
                chunkValue > 1 && groupIndex != 1; // groupIndex 1 is "mille"
            scaleWord = usePluralScale ? scaleNames[1] : scaleNames[0];

            // Special cases for '1' before scale words:
            if (groupIndex == 1 && chunkValue == 1) {
              // "mille" (not "un mille"). The chunk text "un" is omitted.
              chunkText = "";
            } else if (chunkValue == 1 && groupIndex > 1) {
              // "un million", "un milliard". Keep "un" as the chunk text.
              chunkText = "un";
            }
          } else {
            // Safety warning for extremely large numbers beyond defined scales.
            return "Scale index $groupIndex not defined for number $n";
          }
        }

        // Combine the chunk text and its scale word.
        String currentPart = chunkText;
        if (scaleWord != null && scaleWord.isNotEmpty) {
          // Add a space if needed (e.g., between "deux" and "millions").
          currentPart += (chunkText.isNotEmpty ? " " : "") + scaleWord;
        }
        parts.add(
            currentPart.trim()); // Add the complete part for this scale level.
        isLowestGroup =
            false; // Once a non-zero chunk is processed, subsequent ones are not the lowest.
      }
      // If the lowest group (0-999) was zero, but higher groups exist (e.g., for 1000, 2000000),
      // we still need to move to the next group index. This was handled implicitly before,
      // but adding a check for clarity or edge cases might be useful.
      // else if (groupIndex == 0 && parts.isEmpty && n >= thousand) {
      // Case like 1000: chunkValue is 0, remaining becomes 1. Need to process groupIndex 1.
      // The logic works correctly as is because the loop continues based on 'remaining'.
      // }
      groupIndex++;
    }
    // Join the parts in reverse order (highest scale first) with spaces.
    return parts.reversed.join(' ').trim();
  }

  /// Converts a number between 0 and 999 into its French word representation.
  /// Handles French complexities like 70-79, 90-99, hyphens, "et un", and plural 's' on "cent" and "vingt".
  ///
  /// [n]: The number to convert (must be 0 <= n < 1000).
  /// [isTerminalChunk]: True if this is the rightmost non-zero chunk of the entire number.
  /// This determines if "cent" or "vingt" should take a plural 's'.
  /// Returns the chunk in words, e.g., "cent", "vingt-et-un", "soixante-douze", "quatre-vingts".
  String _convertChunk(int n, {required bool isTerminalChunk}) {
    if (n == 0) return ""; // Empty string for zero in this context.
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }

    List<String> words = []; // Stores word parts for this chunk.
    int remainder = n;

    // --- Process Hundreds ---
    int hundredsDigit = remainder ~/ 100;
    if (hundredsDigit > 0) {
      // Determine if "cent" needs a plural 's'.
      // Condition: multiplier > 1 AND it's the end of the number (remainder is 0) AND it's the terminal chunk.
      bool centNeedsS =
          hundredsDigit > 1 && (remainder % 100 == 0) && isTerminalChunk;
      String centWord =
          _hundred + (centNeedsS ? "s" : ""); // Add 's' if needed.

      if (hundredsDigit == 1) {
        // "cent" (never "un cent").
        words.add(_hundred);
      } else {
        // "deux cents", "trois cent", etc.
        // Convert the multiplier (2-9). It's not terminal itself.
        words.add(_convertChunk(hundredsDigit, isTerminalChunk: false));
        words.add(" "); // Space before "cent(s)".
        words.add(centWord);
      }
      remainder %= 100; // Keep track of the remaining tens and units.
    }

    // --- Process Tens and Units (0-99) ---
    if (remainder > 0) {
      // Add a space if there was a hundreds part.
      if (words.isNotEmpty) words.add(" ");

      // Handle numbers 0-16 directly.
      if (remainder < 17) {
        words.add(_wordsUnder20[remainder]);
      }
      // Handle 17-19: dix-sept, dix-huit, dix-neuf.
      else if (remainder < 20) {
        words.add(_wordsTens[1]); // "dix"
        words.add(_hyphen);
        words.add(_wordsUnder20[remainder % 10]); // Add 7, 8, or 9 part.
      }
      // Handle 20-69.
      else if (remainder < 70) {
        int tensDigit = remainder ~/ 10;
        int unitDigit = remainder % 10;
        words.add(_wordsTens[tensDigit]); // Add "vingt", "trente", etc.
        if (unitDigit > 0) {
          // Handle "et un" (e.g., "vingt-et-un").
          if (unitDigit == 1) {
            words.add(" $_and "); // Add " et ".
            words.add(_wordsUnder20[unitDigit]); // Add "un".
          } else {
            // Add hyphen and the unit (e.g., "vingt-deux").
            words.add(_hyphen);
            words.add(_wordsUnder20[unitDigit]);
          }
        }
        // Plural 's' for vingt? No, only in "quatre-vingts".
      }
      // Handle 70-79 (soixante-dix...).
      else if (remainder < 80) {
        int unitPart = remainder - 60; // The part added to sixty (10-19).
        words.add(_wordsTens[6]); // Add "soixante".
        // Handle "soixante-et-onze" (71).
        if (unitPart == 11) {
          words.add(" $_and "); // Add " et ".
          words.add(_wordsUnder20[11]); // Add "onze".
        } else {
          // Add hyphen and the 10-19 part (e.g., "soixante-douze").
          words.add(_hyphen);
          if (unitPart < 17) {
            // 10, 12-16
            words.add(_wordsUnder20[unitPart]);
          } else {
            // 17-19: decompose further into "dix-sept", etc.
            words.add(_wordsTens[1]); // "dix"
            words.add(_hyphen);
            words.add(_wordsUnder20[unitPart % 10]); // Add 7, 8, or 9 part.
          }
        }
      }
      // Handle 80-99 (quatre-vingt...).
      else {
        // remainder >= 80
        // Base "quatre-vingt".
        String baseQuatreVingt =
            "quatre$_hyphen${_wordsTens[2]}"; // "quatre-vingt"

        // Handle exactly 80.
        if (remainder == 80) {
          // Determine if "vingt" needs a plural 's'.
          // Condition: It's exactly 80 AND it's the terminal chunk.
          bool quatreVingtNeedsS = isTerminalChunk;
          words.add(baseQuatreVingt +
              (quatreVingtNeedsS ? "s" : "")); // Add 's' if needed.
        } else {
          // Handle 81-99. Add "quatre-vingt" (without 's').
          words.add(baseQuatreVingt);
          words.add(_hyphen);
          int unitPart = remainder - 80; // The part added to eighty (1-19).
          // Convert the 1-19 part recursively (it's < 1000).
          // Pass false for isTerminalChunk as this part isn't terminal itself.
          words.add(_convertChunk(unitPart, isTerminalChunk: false));
          // Note: The recursive call handles 91 ("quatre-vingt-onze") correctly.
        }
      }
    }
    // Combine the collected word parts for the chunk.
    return words.join();
  }
}
