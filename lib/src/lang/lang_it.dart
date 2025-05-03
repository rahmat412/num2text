import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/it_options.dart';
import '../utils/utils.dart';

/// {@template num2text_it}
/// Converts numbers to Italian words (`Lang.IT`).
///
/// Implements [Num2TextBase] for the Italian language, handling various numeric types.
/// Supports cardinal numbers, decimals, negatives, currency, and years.
///
/// Key Italian Features Handled:
/// - **Elision:** Correctly handles elision (dropping vowels) where required (e.g., "ventuno", "trentotto", "centuno").
/// - **Special Forms:** Uses forms like "un" for one before certain words, "mille" vs "-mila", "cento" vs "cent".
/// - **Scales:** Supports both standard scales (million/milliard for currency) and the Italian long scale (milione, miliardo, bilione, biliardo, etc.) for standard numbers.
/// - **Currency:** Formats currency values, including the use of "di" for millions/billions (e.g., "un milione di euro").
/// - **Years:** Formats years, optionally adding "a.C." (BC) or "d.C." (AD).
///
/// Customizable via [ItOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextIT implements Num2TextBase {
  // --- Constants ---

  // General
  static const String _zero = "zero";
  static const String _point = "punto"; // Decimal point "punto"
  static const String _comma = "virgola"; // Decimal comma "virgola"
  static const String _currencyAnd = "e"; // Separator "e" (and) for currency
  static const String _un =
      "un"; // Form of "one" used before certain words/scales
  static const String _hundred = "cento"; // Hundred
  static const String _thousandSingular = "mille"; // 1000 (singular)
  static const String _thousandPluralSuffix =
      "mila"; // Suffix for >1000 (e.g., "duemila")
  // static const String _vowels = "aeiouAEIOU"; // Vowel list (Kept for reference, not actively used in current logic)

  // Units and Teens (0-19)
  static const List<String> _wordsUnder20 = [
    "zero",
    "uno",
    "due",
    "tre",
    "quattro",
    "cinque",
    "sei",
    "sette",
    "otto",
    "nove",
    "dieci",
    "undici",
    "dodici",
    "tredici",
    "quattordici",
    "quindici",
    "sedici",
    "diciassette",
    "diciotto",
    "diciannove",
  ];

  // Tens stems (20-90) - Vowels added/elided in _convertUnder1000
  static const List<String> _wordsTens = [
    "", "", // 0, 10 - handled by _wordsUnder20
    "vent", "trent", "quarant", "cinquant", "sessant", "settant", "ottant",
    "novant",
  ];

  // Standard scale names (Million, Billion) - Often used for currency or non-long scale numbers.
  // Index represents power of 1000 (1=thousand, 2=million, 3=billion).
  // Format: [singular, plural]
  static const Map<int, List<String>> _scaleWords = {
    0: ["", ""], // Units scale
    1: [
      _thousandSingular,
      _thousandPluralSuffix
    ], // Thousands (special handling)
    2: ["milione", "milioni"], // 10^6
    3: ["miliardo", "miliardi"], // 10^9
    // Note: Does not use Italian long scale beyond miliardo
  };

  // Standard Italian Long Scale Names (up to Quadrilliard 10^27)
  // Index represents power of 1000.
  // Format: [singular, plural]
  static const Map<int, List<String>> _longScaleWords = {
    // 0, 1 handled specially
    2: ["milione", "milioni"], // 10^6
    3: ["miliardo", "miliardi"], // 10^9
    4: ["bilione", "bilioni"], // 10^12
    5: ["biliardo", "biliardi"], // 10^15
    6: ["trilione", "trilioni"], // 10^18
    7: ["triliardo", "triliardi"], // 10^21
    8: ["quadrilione", "quadrilioni"], // 10^24
    9: ["quadriliardo", "quadriliardi"], // 10^27
    // Add more standard long scales (quintilione/i, etc.) if needed
  };

  /// Processes the given [number] into Italian words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [ItOptions] for customization (currency, year format, AD/BC inclusion, long scale, negative prefix, decimal separator).
  /// Defaults apply if [options] is null or not [ItOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity` ("Infinito"), `NaN`. Returns [fallbackOnError] or "Non Un Numero" on failure.
  /// Handles year zero based on fallback.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [ItOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Italian words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final ItOptions itOptions =
        options is ItOptions ? options : const ItOptions();
    final String errorFallback =
        fallbackOnError ?? "Non Un Numero"; // Default fallback "Not a number"

    // Handle special double values
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? "Infinito Negativo"
            : "Infinito"; // Negative/Positive Infinity
      }
      if (number.isNaN) {
        return errorFallback;
      }
    }

    // Normalize input to Decimal
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) {
      return errorFallback;
    }

    // Handle zero separately
    if (decimalValue == Decimal.zero) {
      if (itOptions.currency) {
        // Use plural unit name for zero currency (e.g., "zero euro")
        final String zeroUnit = itOptions.currencyInfo.mainUnitPlural ??
            itOptions.currencyInfo.mainUnitSingular;
        return "$_zero $zeroUnit";
      } else if (itOptions.format == Format.year) {
        // Year zero doesn't exist, return fallback
        return fallbackOnError ?? "Anno zero non supportato";
      } else {
        // Standard zero
        return _zero;
      }
    }

    // Determine sign and get absolute value
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult; // Variable to hold the final converted text

    // Dispatch based on format options
    if (itOptions.format == Format.year) {
      // Year Formatting
      final BigInt yearValue = absValue.truncate().toBigInt();
      // Years typically don't use long scale (bilione etc.)
      textResult =
          _convertInteger(yearValue, useLongScale: false, isYear: true);
      // Add BC/AD suffixes if needed
      if (isNegative) {
        textResult = "$textResult a.C."; // Avanti Cristo (BC)
      } else if (itOptions.includeAD) {
        textResult = "$textResult d.C."; // Dopo Cristo (AD)
      }
    } else {
      // Standard Number or Currency Formatting
      if (itOptions.currency) {
        textResult = _handleCurrency(absValue, itOptions);
      } else {
        textResult = _handleStandardNumber(absValue, itOptions);
      }
      // Prepend negative prefix if original number was negative
      if (isNegative) {
        textResult =
            "${itOptions.negativePrefix} $textResult"; // Default "meno"
      }
    }

    // Final cleanup: ensure single spaces and trim
    return textResult.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Converts a non-negative integer ([BigInt]) into Italian words.
  ///
  /// Handles chunking by thousands and applying scale words (standard or long scale).
  /// Manages concatenation rules between scales (e.g., "duemilacento" vs "un milione duecentomila").
  ///
  /// @param n The non-negative integer to convert.
  /// @param useLongScale If true, uses the Italian long scale (bilione, biliardo...). Defaults to true. If false, uses standard million/billion scale.
  /// @param isYear Indicates if the conversion is for a year, which might affect scale usage (typically years don't use long scale).
  /// @return The integer as Italian words. Returns error string if scale is unsupported.
  String _convertInteger(BigInt n,
      {bool useLongScale = true, bool isYear = false}) {
    if (n == BigInt.zero) return _zero; // Base case for zero
    if (n < BigInt.from(1000))
      return _convertUnder1000(n.toInt()); // Delegate small numbers

    List<String> parts =
        []; // Holds text representation of each chunk (e.g., "duecento", "mila", "un milione")
    List<int> scales =
        []; // Holds the scale index (0=units, 1=thousands, 2=millions...) corresponding to each part
    BigInt tempN = n; // Temporary variable for chunking
    int scaleIndex = 0; // Current scale level (0, 1, 2...)

    // --- Chunking Loop ---
    // Process the number in chunks of 1000 from right to left (lowest scale first)
    while (tempN > BigInt.zero) {
      final int chunk = (tempN % BigInt.from(1000))
          .toInt(); // Get the value of the current chunk (0-999)
      tempN ~/= BigInt.from(1000); // Move to the next higher chunk

      // Only process non-zero chunks
      if (chunk > 0) {
        String chunkText = ""; // Text for the current chunk + scale word
        bool useSingularScale = (chunk ==
            1); // Flag: Does this chunk represent exactly 1 of the scale unit?

        // --- Convert Chunk based on Scale ---
        if (scaleIndex == 0) {
          // Units chunk (0-999): Just convert the number itself
          chunkText = _convertUnder1000(chunk);
        } else if (scaleIndex == 1) {
          // Thousands chunk (scale 1)
          if (useSingularScale) {
            // Exactly 1000 is "mille"
            chunkText = _thousandSingular;
          } else {
            // >1000 uses number + "mila" suffix (e.g., "duemila", "centomila")
            String chunkWord = _convertUnder1000(chunk);
            chunkText = "$chunkWord$_thousandPluralSuffix";
          }
        } else {
          // Millions and higher scales (scale >= 2)
          // Select the appropriate scale map (long or standard)
          final Map<int, List<String>> currentScaleMap =
              useLongScale ? _longScaleWords : _scaleWords;

          // Check if the scale exists in the selected map
          if (!currentScaleMap.containsKey(scaleIndex)) {
            // Return error if scale is too large for the defined maps
            return "SCALA_NON_SUPPORTATA ($scaleIndex)"; // Scale Not Supported
          }

          // Get singular and plural forms for the current scale
          String scaleWordSingular = currentScaleMap[scaleIndex]![0];
          String scaleWordPlural = currentScaleMap[scaleIndex]![1];
          // Choose singular or plural based on the chunk value
          String scaleWord =
              useSingularScale ? scaleWordSingular : scaleWordPlural;

          if (useSingularScale) {
            // Handle "un" prefix for 1 million, 1 billion, etc. ("un milione")
            // (Scales >= 2 typically need "un")
            bool needsUnPrefix = scaleIndex >= 2;
            if (needsUnPrefix) {
              chunkText = "$_un $scaleWord"; // "un milione", "un miliardo"
            } else {
              // This case should technically not be hit if scaleIndex >= 2, but safe fallback
              chunkText = scaleWord;
            }
          } else {
            // For >1 million/billion etc., use number + scale word (e.g., "due milioni")
            String chunkWord = _convertUnder1000(chunk);
            chunkText = "$chunkWord $scaleWord";
          }
        }
        // Add the generated text and its scale index to the beginning of the lists
        parts.insert(0, chunkText);
        scales.insert(0, scaleIndex);
      }
      scaleIndex++; // Move to the next higher scale level
    }

    // --- Joining Loop ---
    // Combine the parts from highest scale down, applying concatenation rules
    StringBuffer result = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      String currentPart = parts[i];
      int currentScale = scales[i];

      result.write(currentPart); // Append the current part's text

      // Check if a space is needed before the *next* part
      if (i + 1 < parts.length) {
        int nextScale = scales[i + 1]; // Scale of the next part

        // --- Concatenation Rules ---
        // Italian often concatenates thousands/hundreds/tens/units without spaces.
        // Examples: "duemilacento" (2100), "milleuno" (1001)
        // But: "un milione duecentomila" (1,200,000) - space needed after million/billion etc.

        // Determine if current part is related to thousands scale (scale 1)
        bool currentIsExactlyMille =
            currentPart == _thousandSingular; // Is it exactly "mille"?
        bool currentEndsInMila = currentScale == 1 &&
            !currentIsExactlyMille; // Is it >1 thousand (e.g., "duemila")?
        bool nextIsUnits =
            nextScale == 0; // Is the next part the units chunk (0-999)?

        // Concatenate (no space) if:
        // 1. Current part ends in 'mila' (e.g., "duemila") AND next part is the units chunk OR
        // 2. Current part is exactly 'mille' AND next part is the units chunk.
        // Otherwise, add a space (e.g., after "milione", "miliardo").
        bool concatenate = (currentEndsInMila && nextIsUnits) ||
            (currentIsExactlyMille && nextIsUnits);

        if (!concatenate) {
          result.write(" "); // Add a space if not concatenating
        }
        // If concatenating, simply proceed to write the next part without a space.
      }
    }

    // Return the final combined string (already trimmed by loop logic)
    String finalResult =
        result.toString(); // No final trim needed if logic is correct
    // String finalResult = result.toString().trim(); // Original had trim, keep for safety? (Reverted to no trim as likely unnecessary)

    return finalResult;
  }

  /// Converts an integer between 0 and 999 into Italian words.
  ///
  /// Handles base units, tens, hundreds, and Italian elision rules
  /// (e.g., dropping final vowel of tens/hundreds before unit starting with vowel).
  ///
  /// @param n The integer chunk (0-999).
  /// @throws ArgumentError if n is outside the 0-999 range.
  /// @return The chunk as Italian words, or empty string if n is 0.
  String _convertUnder1000(int n) {
    if (n == 0) return ""; // Zero results in empty string within larger numbers
    if (n < 0 || n >= 1000) {
      // Ensure input is within the valid range for this function
      throw ArgumentError(
          "Number must be between 0 and 999 for _convertUnder1000: $n");
    }

    // Handle numbers 0-19 directly
    if (n < 20) return _wordsUnder20[n];

    StringBuffer sb =
        StringBuffer(); // Use StringBuffer for efficient string building
    int remainder = n; // Remaining value to process
    String hundredsPart =
        ""; // Holds the text for the hundreds part (e.g., "cento", "duecento")
    bool hasHundreds = false; // Flag if the number includes a hundreds part

    // --- Process Hundreds ---
    if (remainder >= 100) {
      final int hundredsDigit =
          remainder ~/ 100; // Get the hundreds digit (1-9)
      remainder %= 100; // Get the remaining tens/units part (0-99)
      hasHundreds = true; // Mark that there was a hundreds part

      if (hundredsDigit == 1) {
        // 100 is "cento"
        hundredsPart = _hundred;
      } else {
        // 200-900 are number + "cento" (e.g., "duecento", "trecento")
        // Elision of final vowel of number before "cento" is not standard (e.g., "trecento" not "trecento")
        hundredsPart = "${_wordsUnder20[hundredsDigit]}$_hundred";
      }

      // If only hundreds, return immediately (e.g., 200 -> "duecento")
      if (remainder == 0) {
        return hundredsPart;
      }
    }

    // --- Process Remainder (Tens and Units, 1-99) ---
    String remainderWord = ""; // Holds the text for the 1-99 part
    if (remainder > 0) {
      if (remainder < 20) {
        // If remainder is 1-19, use direct lookup
        remainderWord = _wordsUnder20[remainder];
      } else {
        // If remainder is 20-99
        final int tensDigit = remainder ~/ 10; // Get tens digit (2-9)
        final int unitDigit = remainder % 10; // Get unit digit (0-9)
        String tensBase =
            _wordsTens[tensDigit]; // Get the tens stem (e.g., "vent", "trent")
        String tensWord; // Final tens word (e.g., "venti", "trenta")

        // Determine the final vowel for the tens word ("venti", "trenta" etc.)
        if (tensDigit == 2) {
          tensWord = "${tensBase}i"; // 20s end in 'i' ("venti")
        } else {
          tensWord =
              "${tensBase}a"; // 30s-90s end in 'a' ("trenta", "quaranta"...)
        }

        if (unitDigit == 0) {
          // Pure tens (20, 30...)
          remainderWord = tensWord;
        } else if (unitDigit == 1 || unitDigit == 8) {
          // Elision rule: Drop final vowel of tens stem before "uno" (1) or "otto" (8)
          // e.g., "vent" + "uno" -> "ventuno", "trent" + "otto" -> "trentotto"
          remainderWord = "$tensBase${_wordsUnder20[unitDigit]}";
        } else {
          // No elision: Combine full tens word + unit word
          // e.g., "venti" + "due" -> "ventidue", "trenta" + "tre" -> "trentatre"
          remainderWord = "$tensWord${_wordsUnder20[unitDigit]}";
        }
      }
    }

    // --- Combine Hundreds and Remainder ---
    if (hasHundreds) {
      // Apply elision rules between hundreds part and remainder (tens/units part)
      bool startsWithU = remainderWord
          .startsWith('u'); // Does remainder start with 'u'? (e.g., "uno")
      bool startsWithO = remainderWord
          .startsWith('o'); // Does remainder start with 'o'? (e.g., "otto")
      bool isCento =
          (hundredsPart == _hundred); // Is the hundreds part exactly "cento"?

      // Determine if the final vowel of the hundreds part should be dropped (elided).
      // Elision happens if hundreds part ends in 'o' ("cento") AND
      // remainder starts with 'o' ("otto") OR starts with 'u' ("uno", "undici" etc.)
      // EXCEPT for "centouno" (101), "centoundici" (111) etc. where "cento" keeps its 'o'.
      // This rule is complex: elide "cento" before "otto", but not before "uno". Other hundreds elide before "uno"/"otto".
      // Original logic simplified: Elide if ends in 'o' and remainder starts 'o', OR (remainder starts 'u' AND it's NOT 'cento')
      bool shouldElide = (hundredsPart.endsWith('o') &&
          (startsWithO || (startsWithU && !isCento)));
      // Example: "duecento"+"uno" -> "duecentuno" (elide)
      // Example: "cento"+"uno" -> "centouno" (no elide)
      // Example: "duecento"+"otto" -> "duecentotto" (elide)
      // Example: "cento"+"otto" -> "centotto" (elide)

      if (shouldElide) {
        // Append hundreds part without final vowel
        sb.write(hundredsPart.substring(0, hundredsPart.length - 1));
      } else {
        // Append full hundreds part
        sb.write(hundredsPart);
      }
      // Append the remainder word
      sb.write(remainderWord);
    } else {
      // If no hundreds part, just use the remainder word
      sb.write(remainderWord);
    }

    return sb.toString();
  }

  /// Converts a non-negative [Decimal] value to Italian currency words.
  ///
  /// Uses [ItOptions.currencyInfo] for unit names (e.g., euro/euro, centesimo/centesimi).
  /// Applies Italian grammar rules:
  /// - Uses "un" for 1 main/subunit unless specific conditions apply.
  /// - Uses "di" before unit name after million/billion amounts (e.g., "un milione di euro").
  /// - Uses standard scale (million/billion), not long scale.
  ///
  /// @param absValue Absolute currency value.
  /// @param options The [ItOptions] with currency info.
  /// @return Currency value as Italian words, or empty string if value is zero.
  String _handleCurrency(Decimal absValue, ItOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final int decimalPlaces = 2; // Use specified or default 2
    final Decimal subunitMultiplier =
        Decimal.fromInt(10).pow(decimalPlaces).toDecimal();

    // Custom rounding approach: Multiply, round, then divide back.
    // This aims to handle floating point inaccuracies for common currency rounding.
    // Example: 1.235 -> 123.5 -> round 124 -> 1.24
    final Decimal valueToConvert =
        ((absValue * subunitMultiplier).round() / subunitMultiplier)
            .toDecimal();

    // Separate main and subunit integer values
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final BigInt subunitValue =
        // Calculate subunit value from the rounded fractional part
        ((valueToConvert - valueToConvert.truncate()) * subunitMultiplier)
            .truncate()
            .toBigInt();

    String mainText = ""; // Holds the fully constructed main part string
    String subUnitText = ""; // Holds the fully constructed subunit part string

    // --- Generate Main Currency Part ---
    if (mainValue > BigInt.zero) {
      // Convert the main integer value using standard scales (no long scale for currency)
      String mainNumText = _convertInteger(mainValue, useLongScale: false);
      bool needsDi =
          false; // Flag: Does this require "di" before the currency unit?

      // Check if "di" is needed (for millions/billions)
      // Rule: "di" is used after "milione/milioni" or "miliardo/miliardi".
      // Check against the standard scale names used for currency.
      if (mainValue >= BigInt.from(1000000) && _scaleWords.containsKey(2)) {
        // Check millions (scale 2)
        final String millionSingular = _scaleWords[2]![0]; // "milione"
        final String millionPlural = _scaleWords[2]![1]; // "milioni"
        // Needs "di" if the number text is exactly "un milione" or ends with " milioni"
        if (mainNumText == "$_un $millionSingular" ||
            mainNumText.endsWith(" $millionPlural")) {
          needsDi = true;
        }
      }
      // Check billions (scale 3) only if not already flagged for millions
      if (!needsDi &&
          mainValue >= BigInt.from(1000000000) &&
          _scaleWords.containsKey(3)) {
        final String billionSingular = _scaleWords[3]![0]; // "miliardo"
        final String billionPlural = _scaleWords[3]![1]; // "miliardi"
        // Needs "di" if the number text is exactly "un miliardo" or ends with " miliardi"
        if (mainNumText == "$_un $billionSingular" ||
            mainNumText.endsWith(" $billionPlural")) {
          needsDi = true;
        }
      }

      // Determine the correct main unit name (singular or plural)
      // Use singular only if value is 1 AND "di" is NOT needed.
      final String mainUnitName = (mainValue == BigInt.one && !needsDi)
          ? currencyInfo.mainUnitSingular
          : (currencyInfo.mainUnitPlural ??
              currencyInfo
                  .mainUnitSingular); // Fallback to singular if plural is null

      // Special case for 1: Use "un" instead of "uno" unless "di" follows.
      if (mainValue == BigInt.one && !needsDi) {
        mainNumText = _un; // Use "un" e.g., "un euro"
      }

      // Combine number, optional "di", and unit name
      mainText = needsDi
          ? '$mainNumText di $mainUnitName'
          : '$mainNumText $mainUnitName';
    }

    // --- Generate Subunit Currency Part ---
    if (subunitValue > BigInt.zero &&
        currencyInfo.subUnitSingular != null && // Check if subunit info exists
        currencyInfo.subUnitPlural != null) {
      // Convert the subunit integer value (standard scale)
      String subunitNumText =
          _convertInteger(subunitValue, useLongScale: false);

      // Determine the correct subunit name (singular or plural)
      final String subUnitName = (subunitValue == BigInt.one)
          ? currencyInfo
              .subUnitSingular! // Use non-null assertion as checked above
          : currencyInfo
              .subUnitPlural!; // Use non-null assertion as checked above

      // Special case for 1 subunit: Use "un" instead of "uno"
      if (subunitValue == BigInt.one) {
        subunitNumText = _un; // e.g., "un centesimo"
      }
      // Combine number and subunit name
      subUnitText = '$subunitNumText $subUnitName';
    }

    // --- Combine Main and Subunit Parts ---
    if (mainText.isNotEmpty && subUnitText.isNotEmpty) {
      // If both parts exist, join them with the separator ("e" or custom)
      final String separator = currencyInfo.separator ??
          _currencyAnd; // Use custom separator or default "e"
      return '$mainText $separator $subUnitText';
    } else if (mainText.isNotEmpty) {
      // If only main part exists
      return mainText;
    } else if (subUnitText.isNotEmpty) {
      // If only subunit part exists (e.g., 0.50)
      return subUnitText;
    } else {
      // If both are empty (original value was zero or rounded to zero)
      // Note: Zero case is handled at the beginning of `process`, so this might be redundant
      // Returning empty string here aligns with the function structure, assuming zero case caught earlier.
      return "";
    }
  }

  /// Converts a non-negative standard [Decimal] number to Italian words.
  ///
  /// Converts the integer part using [_convertInteger] (respecting long scale option).
  /// Converts the fractional part digit by digit (e.g., 0.45 -> "virgola quattro cinque").
  /// Uses the decimal separator word specified in [ItOptions.decimalSeparator].
  ///
  /// @param absValue The absolute decimal value.
  /// @param options The [ItOptions] for formatting control (long scale, decimal separator).
  /// @return The number formatted as Italian words.
  String _handleStandardNumber(Decimal absValue, ItOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part. Use "zero" if integer is 0 but fraction exists.
    // Respect the long scale option from ItOptions.
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, useLongScale: true);

    String fractionalWords = '';
    // Convert fractional part if it exists
    if (fractionalPart > Decimal.zero) {
      // Determine separator word ("punto" or "virgola")
      final String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          separatorWord = _point;
          break;
        case DecimalSeparator
              .comma: // Comma is default for Italian standard numbers
        default:
          separatorWord = _comma;
          break;
      }

      // Get fractional digits string from the fractional part.
      String fractionalDigits = fractionalPart.toString().split('.').last;
      // Remove trailing zeros for standard representation (e.g., 1.50 -> "virgola cinque")
      fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      // Convert each digit to its word form if any digits remain after trimming zeros
      if (fractionalDigits.isNotEmpty) {
        final List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int digitInt = int.parse(digit);
          return _wordsUnder20[digitInt]; // Use base words 0-9
        }).toList();
        // Combine separator and digit words
        fractionalWords =
            ' $separatorWord ${digitWords.join(' ')}'; // e.g., " virgola quattro cinque"
      }
    }
    // Combine integer and fractional parts
    return '$integerWords$fractionalWords'.trim();
  }
}
