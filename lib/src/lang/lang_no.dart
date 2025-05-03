import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/no_options.dart';
import '../utils/utils.dart';

/// {@template num2text_no}
/// Converts numbers to Norwegian (Bokmål) words (`Lang.NO`).
///
/// Implements [Num2TextBase] for Norwegian, handling various numeric types.
/// Supports cardinal numbers, decimals, negatives, currency, years, and large numbers (long scale).
/// Handles grammatical gender ('en'/'ett') based on context or [NoOptions.gender].
///
/// Customizable via [NoOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextNO implements Num2TextBase {
  // --- Constants ---

  /// Decimal point word ("period").
  static const String _point = "punktum";

  /// Comma word (often used as decimal separator in Norwegian).
  static const String _comma = "komma";

  /// Conjunction word "og" ("and").
  static const String _and = "og";

  /// Suffix for BC years ("før Kristus" - Before Christ).
  static const String _yearSuffixBC = "f.Kr.";

  /// Suffix for AD years ("etter Kristus" - After Christ).
  static const String _yearSuffixAD = "e.Kr.";

  /// Number words for 0-19. Note: Index 1 ("en") is the common/masculine gender form.
  static const List<String> _wordsUnder20 = [
    "null", // 0
    "en", // 1 (common/masculine)
    "to", // 2
    "tre", // 3
    "fire", // 4
    "fem", // 5
    "seks", // 6
    "sju", // 7 (common colloquial form, sometimes 'syv')
    "åtte", // 8
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

  /// Neuter form for "one".
  static const String _oneNeuter = "ett";

  /// Common/masculine form for "one".
  static const String _oneCommon = "en";

  /// Number words for tens (20, 30,... 90). Index corresponds to tens digit.
  static const List<String> _wordsTens = [
    "", // 0 (unused)
    "", // 10 (handled by _wordsUnder20)
    "tjue", // 20
    "tretti", // 30
    "førti", // 40
    "femti", // 50
    "seksti", // 60
    "sytti", // 70
    "åtti", // 80
    "nitti", // 90
  ];

  /// Word for "hundred".
  static const String _hundred = "hundre";

  /// Word for "thousand".
  static const String _thousand = "tusen";

  /// Scale words (million, billion, etc.) using the **long scale** system.
  /// Map key is the exponent of 1000 (e.g., 2 for 1000^2 = million).
  /// Value is a list: [singular form, plural form].
  static const Map<int, List<String>> _scaleWords = {
    // Scale 1 (thousand) handled separately.
    2: ["million", "millioner"], // 10^6 Million
    3: ["milliard", "milliarder"], // 10^9 Billion (1000 Million)
    4: ["billion", "billioner"], // 10^12 Trillion (Million Million)
    5: ["billiard", "billiarder"], // 10^15 Quadrillion (1000 Billion)
    6: ["trillion", "trillioner"], // 10^18 Quintillion (Million Trillion)
    7: ["trilliard", "trilliarder"], // 10^21 Sextillion (1000 Trillion)
    8: [
      "kvadrillion",
      "kvadrillioner"
    ], // 10^24 Septillion (Million Quadrillion)
    // Add more long scales (kvadrilliard, etc.) if needed
  };

  /// Processes the given [number] into its Norwegian word representation.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [NoOptions] for customization (currency, year format, gender, AD/BC inclusion, negative prefix, decimal separator).
  /// Defaults apply if [options] is null or not [NoOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity` ("Uendelig"), `NaN`. Returns [fallbackOnError] or "Ikke Et Tall" on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [NoOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Norwegian words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure correct options type or use defaults
    final NoOptions noOptions =
        options is NoOptions ? options : const NoOptions();
    // Determine the error message to use on failure
    final String fallback =
        fallbackOnError ?? "Ikke Et Tall"; // Default "Not a number"

    // Handle special double values immediately
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? "Negativ Uendelig"
            : "Uendelig"; // Negative/Positive Infinity
      }
      if (number.isNaN) {
        return fallback;
      }
    }

    // Normalize the input number to Decimal for consistent handling
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) {
      return fallback; // Use fallback for any normalization error
    }

    // Handle the specific case of zero
    if (decimalValue == Decimal.zero) {
      if (noOptions.currency) {
        // For currency, use "null" + plural main unit (e.g., "null kroner")
        final CurrencyInfo currencyInfo = noOptions.currencyInfo;
        return "${_wordsUnder20[0]} ${currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular}";
      } else {
        // For non-currency, just return "null"
        return _wordsUnder20[0];
      }
    }

    // Determine sign and get absolute value
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult; // Variable to hold the final converted text

    // Dispatch based on format options
    if (noOptions.format == Format.year) {
      // Year Formatting
      if (isNegative) {
        // Pass the negative year value to the handler for BC processing
        // Note: Year formatting inherently handles the sign via BC/AD suffixes
        int yearInt = absValue.truncate().toBigInt().toInt();
        textResult = _handleYearFormat(-yearInt, noOptions);
      } else {
        // Pass positive year value
        textResult = _handleYearFormat(
            absValue.truncate().toBigInt().toInt(), noOptions);
      }
    } else {
      // Standard Number or Currency Formatting
      if (noOptions.currency) {
        textResult = _handleCurrency(absValue, noOptions);
      } else {
        textResult = _handleStandardNumber(absValue, noOptions);
      }
      // Prepend negative prefix if original number was negative
      if (isNegative) {
        String prefix = noOptions.negativePrefix; // Default "minus"
        // Add prefix, ensuring a single space follows it
        textResult = prefix + (prefix.endsWith(' ') ? '' : ' ') + textResult;
      }
    }
    // Final result is usually trimmed within helper functions, but trim here for safety.
    // Note: Original code didn't trim here, but seems harmless. Reverted to original lack of trim.
    // return textResult.trim();
    return textResult;
  }

  /// Converts a non-negative integer ([BigInt]) into Norwegian words.
  ///
  /// Handles chunking by thousands, applying scale words (long scale), and inserting "og" (and) correctly.
  /// Manages gender for 'one' based on scale context ('ett tusen', 'en million').
  ///
  /// @param n The non-negative integer to convert.
  /// @param gender The target [Gender] for the number 'one' if the entire number is just '1'.
  ///               Gender within chunks is determined by scale context.
  /// @return The integer as Norwegian words.
  /// @throws ArgumentError if the number is too large for the defined scales.
  String _convertInteger(BigInt n, {required Gender gender}) {
    if (n == BigInt.zero) return _wordsUnder20[0]; // Base case: 0
    // Handle 1 based on the overall requested gender if the number itself is just 1
    if (n == BigInt.one) {
      return gender == Gender.neuter ? _oneNeuter : _oneCommon;
    }

    // --- Chunking Logic ---
    // Stores data for each non-zero chunk: [scaleLevel, chunkValue, chunkTextWithScale]
    List<List<dynamic>> chunkData = [];
    BigInt currentN = n; // Value remaining to process
    final BigInt oneThousand = BigInt.from(1000);
    int scaleLevel = 0; // 0=units, 1=thousands, 2=millions...

    // Process the number in chunks of 1000 from right to left (lowest scale first)
    while (currentN > BigInt.zero) {
      int chunkInt =
          (currentN % oneThousand).toInt(); // Current chunk value (0-999)
      currentN ~/= oneThousand; // Move to the next higher chunk

      // Only process non-zero chunks
      if (chunkInt > 0) {
        String chunkText; // Text for the number part of the chunk (1-999)
        bool chunkIsOne = chunkInt == 1; // Is the chunk value exactly 1?

        if (scaleLevel == 0) {
          // --- Units Chunk (0-999) ---
          // Determine gender for 'one' within this final chunk.
          // If the whole number was < 1000, use the requested overall 'gender'.
          // Otherwise (if part of a larger number), default to masculine 'en'.
          Gender chunkGender = (n < oneThousand) ? gender : Gender.masculine;
          chunkText = _convertChunk(chunkInt, gender: chunkGender);
          // Store scale level, value, and text (no scale word for units chunk)
          chunkData.add([scaleLevel, chunkInt, chunkText]);
        } else {
          // --- Higher Scale Chunks (Thousands, Millions...) ---
          String
              scaleWord; // The word for the current scale (e.g., "tusen", "millioner")
          Gender
              chunkGender; // Gender to use for 'one' when counting this scale

          if (scaleLevel == 1) {
            // Thousands scale (scale 1)
            scaleWord = _thousand; // "tusen"
            // Norwegian uses neuter 'ett' for 'one thousand': "ett tusen"
            chunkGender = Gender.neuter;
          } else {
            // Millions and higher scales (scale >= 2)
            List<String>? scaleForms =
                _scaleWords[scaleLevel]; // Get [singular, plural] forms
            if (scaleForms == null)
              throw ArgumentError("Number too large for defined scales: $n");
            // Choose singular or plural scale word based on chunk value
            scaleWord = chunkIsOne ? scaleForms[0] : scaleForms[1];
            // Norwegian uses common/masculine 'en' for 'one million', 'one billion': "en million"
            chunkGender = Gender.masculine;
          }
          // Convert the chunk's number part (1-999) using the determined gender for 'one'
          chunkText = _convertChunk(chunkInt, gender: chunkGender);
          // Store scale level, value, and combined text (number + scale word)
          chunkData.add([scaleLevel, chunkInt, "$chunkText $scaleWord"]);
        }
      }
      scaleLevel++; // Move to the next higher scale level
    }

    // --- Joining Logic ---
    // Reverse the list to process from highest scale down
    List<List<dynamic>> orderedChunkData = chunkData.reversed.toList();
    StringBuffer result =
        StringBuffer(); // Use StringBuffer for efficient joining

    for (int i = 0; i < orderedChunkData.length; i++) {
      result
          .write(orderedChunkData[i][2]); // Write the text of the current chunk

      // Check if "og" (and) or a space is needed before the *next* chunk
      if (i < orderedChunkData.length - 1) {
        int nextChunkScale =
            orderedChunkData[i + 1][0]; // Scale of the next chunk
        int nextChunkValue =
            orderedChunkData[i + 1][1]; // Value of the next chunk

        bool addOg = false; // Flag: should "og" be added?

        // --- "og" Insertion Rules (based on original code) ---
        // Rule 1: Add "og" if the next chunk is the units chunk (scale 0) AND its value is between 1 and 99.
        // Example: 123 -> "ett hundre og tjue-tre" (og before 23)
        // Example: 1001 -> "ett tusen og en" (og before 1)
        // Example: 1100 -> "ett tusen ett hundre" (no og before 100)
        if (nextChunkScale == 0 && nextChunkValue > 0 && nextChunkValue < 100) {
          addOg = true;
        }
        // Rule 2: Add "og" if the next chunk represents a higher scale (tusen, million...) AND its value is exactly 1.
        // Example: 1,001,000 -> "en million og ett tusen" (og before "ett tusen") - Requires verification if this rule is standard Norwegian.
        // Example: 2,001,000 -> "to millioner ett tusen" (no og before "ett tusen")
        // This rule seems less common in standard writing but is present in the original logic.
        else if (nextChunkScale > 0 && nextChunkValue == 1) {
          addOg = true;
        }

        // Append " og " or just a space based on the flag
        if (addOg) {
          result.write(" $_and ");
        } else {
          result.write(" "); // Default separator is a space
        }
      }
    }
    // Final result string
    return result.toString();
  }

  /// Handles formatting a number as a calendar year in Norwegian.
  ///
  /// Uses "XX hundre og YY" format for years 1100-1999.
  /// Other years use standard integer conversion (typically masculine gender).
  /// Appends BC/AD suffixes if needed.
  ///
  /// @param year The integer year (can be negative for BC).
  /// @param options The [NoOptions] for AD suffix control.
  /// @return The year formatted as Norwegian words.
  String _handleYearFormat(int year, NoOptions options) {
    final bool isNegative = year < 0; // Is it a BC year?
    final int absYear = isNegative ? -year : year; // Absolute year value
    final BigInt bigAbsYear =
        BigInt.from(absYear); // BigInt for standard conversion

    String yearText; // Holds the final text for the year number

    // --- Special Formatting for 1100-1999 ---
    // Format like "nitten hundre og åttifire" (1984)
    if (absYear >= 1100 && absYear < 2000) {
      int highPartInt = absYear ~/ 100; // Century part (e.g., 19)
      int lowPartInt = absYear % 100; // Remainder part (e.g., 84 or 00)
      // Use masculine gender for the century number (e.g., "atten", "nitten")
      String highText = _convertChunk(highPartInt, gender: Gender.masculine);
      yearText = "$highText $_hundred"; // e.g., "nitten hundre"
      // If there's a remainder (e.g., 84 in 1984), add "og" and the remainder text
      if (lowPartInt > 0) {
        // Use masculine gender for the remainder part as well (consistent with year reading)
        String lowText = _convertChunk(lowPartInt, gender: Gender.masculine);
        yearText += " $_and $lowText"; // e.g., " og åttifire"
      }
    } else {
      // --- Default Year Conversion ---
      // For other years, use standard integer conversion.
      // Years are typically read using masculine gender forms (e.g., "to tusen og tjuefire").
      yearText = _convertInteger(bigAbsYear, gender: Gender.masculine);
    }

    // --- Add Suffixes ---
    if (isNegative) {
      // BC years: Use common gender "en" if the year number was 1 (special case for "år én f.Kr.")
      if (absYear == 1) {
        yearText = _oneCommon;
      }
      yearText += " $_yearSuffixBC"; // Append "f.Kr."
    } else if (options.includeAD && absYear > 0) {
      // AD years: Append "e.Kr." only if requested and year is positive
      yearText += " $_yearSuffixAD";
    }

    return yearText;
  }

  /// Converts a non-negative [Decimal] value to Norwegian currency words.
  ///
  /// Uses [NoOptions.currencyInfo] for unit names (e.g., krone/kroner, øre/øre).
  /// Applies Norwegian grammar:
  /// - Main unit counts typically use masculine gender ("en krone", "to kroner").
  /// - Subunit counts typically use neuter gender ("ett øre", "to øre").
  /// Rounds if [NoOptions.round] is true.
  ///
  /// @param absValue Absolute currency value.
  /// @param options The [NoOptions] with currency info and rounding flag.
  /// @return Currency value as Norwegian words.
  String _handleCurrency(Decimal absValue, NoOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    final int decimalPlaces = 2;
    final Decimal subunitMultiplier =
        Decimal.fromInt(10).pow(decimalPlaces).toDecimal(); // 100

    // Round if requested
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main and subunit integer values
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Round subunit value to nearest integer (handles float issues)
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round(scale: 0).toBigInt();

    String mainText = ""; // Holds the fully constructed main part string
    // --- Generate Main Currency Part ---
    if (mainValue > BigInt.zero) {
      // Determine main unit name (singular or plural)
      String mainUnitName = (mainValue == BigInt.one)
          ? currencyInfo.mainUnitSingular
          : currencyInfo.mainUnitPlural ??
              currencyInfo.mainUnitSingular; // Fallback if plural is null
      // Convert main value using masculine gender (e.g., "en krone", "to kroner")
      mainText =
          '${_convertInteger(mainValue, gender: Gender.masculine)} $mainUnitName';
    }

    String subunitText = ""; // Holds the fully constructed subunit part string
    // --- Generate Subunit Currency Part ---
    if (subunitValue > BigInt.zero) {
      // Get subunit name (assuming singular form is usually used, e.g., "øre")
      String subUnitName =
          currencyInfo.subUnitSingular ?? ""; // Fallback to empty if undefined
      if (subUnitName.isNotEmpty) {
        // Convert subunit value using neuter gender (e.g., "ett øre", "to øre")
        subunitText =
            '${_convertInteger(subunitValue, gender: Gender.neuter)} $subUnitName';
      }
      // If subUnitName is empty/null, the subunit part is not generated.
    }

    // --- Combine Parts ---
    if (mainText.isNotEmpty && subunitText.isNotEmpty) {
      // If both parts exist, join with separator ("og" or custom)
      String separator = currencyInfo.separator ??
          _and; // Use custom separator or default "og"
      return '$mainText $separator $subunitText';
    } else if (mainText.isNotEmpty) {
      // Only main part exists
      return mainText;
    } else if (subunitText.isNotEmpty) {
      // Only subunit part exists (e.g., 0.50 -> "femti øre")
      return subunitText;
    } else {
      // Value was zero or rounded to zero.
      // Zero case is handled in `process`, this is a fallback.
      return "${_wordsUnder20[0]} ${currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular}";
    }
  }

  /// Converts a standard (non-currency, non-year) Decimal number to words.
  /// Handles integer and fractional parts, respecting gender options.
  ///
  /// @param absValue The absolute (non-negative) Decimal value.
  /// @param options The [NoOptions] containing gender and decimal separator preferences.
  /// @return The number formatted as Norwegian words.
  String _handleStandardNumber(Decimal absValue, NoOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Use the gender specified in options for the integer part (affects 'one').
    Gender integerGender = options.gender;

    String integerWords;
    // --- Convert Integer Part ---
    if (integerPart == BigInt.zero && fractionalPart > Decimal.zero) {
      // Handle cases like 0.5 -> "null komma fem". Output "null" for the integer part.
      integerWords = _wordsUnder20[0];
    } else {
      // Convert non-zero integer part using the specified gender
      integerWords = _convertInteger(integerPart, gender: integerGender);
    }

    // --- Convert Fractional Part ---
    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Determine the decimal separator word ("punktum" or "komma").
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          separatorWord = _point;
          break;
        case DecimalSeparator.comma: // Comma is common in Norwegian usage
        default:
          separatorWord = _comma;
          break;
      }

      // Extract fractional digits as a string from the original absolute value.
      String fractionalDigits = absValue.toString().split('.').last;

      // Remove trailing zeros for standard representation (e.g., 1.50 -> 1.5).
      while (fractionalDigits.length > 1 && fractionalDigits.endsWith('0')) {
        fractionalDigits =
            fractionalDigits.substring(0, fractionalDigits.length - 1);
      }

      // Convert each remaining fractional digit to words.
      if (fractionalDigits.isNotEmpty) {
        List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int digitInt = int.parse(digit);
          // For reading digits after decimal point, use common/masculine "en" for 1.
          return digitInt == 1 ? _oneCommon : _wordsUnder20[digitInt];
        }).toList();
        // Combine separator and digit words
        fractionalWords =
            ' $separatorWord ${digitWords.join(' ')}'; // e.g., " komma fem en"
      }
    }
    // Original code had an empty else block here, removed.

    // Combine integer and fractional parts
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts an integer between 0 and 999 into Norwegian words.
  /// Handles hundreds, tens, units, and gender for 'one'.
  ///
  /// @param n The integer chunk (0-999).
  /// @param gender The target [Gender] for the number 'one' if it appears as a standalone unit (1)
  ///               or as the count for hundreds (100). Gender for 'one' in compounds (e.g., 21) is fixed.
  /// @return The chunk number in words, or empty string if n is 0.
  /// @throws ArgumentError if n is outside the 0-999 range.
  String _convertChunk(int n, {required Gender gender}) {
    if (n == 0) return ""; // Base case
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }

    // Handle 'one' based on the required gender if the chunk itself is 1.
    if (n == 1) return gender == Gender.neuter ? _oneNeuter : _oneCommon;

    List<String> words =
        []; // Holds word parts ("ett", "hundre", "og", "tjueen")
    int remainder = n; // Remaining value to process
    // Flag: Was the previous part "hundre og"? Used to determine gender for unit 1.
    bool precededByHundred = false;

    // --- Process Hundreds Place ---
    if (remainder >= 100) {
      int hundredsDigit = remainder ~/ 100; // Hundreds digit (1-9)
      // Norwegian uses neuter 'ett' for 'one hundred': "ett hundre".
      words.add(hundredsDigit == 1 ? _oneNeuter : _wordsUnder20[hundredsDigit]);
      words.add(_hundred); // Add "hundre"
      remainder %= 100; // Get remaining tens/units (0-99)
      if (remainder > 0) {
        // If tens/units follow, add "og" (and).
        words.add(_and);
        precededByHundred =
            true; // Mark that "hundre og" precedes the remainder
      }
    }

    // --- Process Tens and Units Place (0-99) ---
    if (remainder > 0) {
      // Process if remainder is 1-99
      if (remainder < 20) {
        // Numbers 1-19
        // Determine gender for 'one' (if remainder is 1):
        // If it follows "hundre og", use masculine "en".
        // Otherwise (if it's 1-19 standalone), use the function's input 'gender'.
        Gender unitGender = precededByHundred ? Gender.masculine : gender;
        words.add(
          remainder == 1
              ? (unitGender == Gender.neuter
                  ? _oneNeuter
                  : _oneCommon) // Choose correct form of 'one'
              : _wordsUnder20[remainder], // Use standard word for 2-19
        );
      } else {
        // Numbers 20-99
        String tensWord =
            _wordsTens[remainder ~/ 10]; // Get tens word (e.g., "tjue")
        int unit = remainder % 10; // Get unit digit (0-9)
        if (unit == 0) {
          // Pure tens (20, 30...)
          words.add(tensWord);
        } else {
          // Compound tens-units (e.g., 21, 32)
          // Combine tens word and unit word directly without space.
          // Always use common/masculine gender "en" for the unit '1' in compounds (e.g., "tjueen").
          String unitWord = (unit == 1) ? _oneCommon : _wordsUnder20[unit];
          words.add("$tensWord$unitWord"); // e.g., "tjueen", "trettito"
        }
      }
    }

    // Join the collected word parts with spaces
    return words.join(' ');
  }
}
