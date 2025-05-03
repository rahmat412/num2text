import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/sv_options.dart';
import '../utils/utils.dart';

/// {@template num2text_sv}
/// Converts numbers to Swedish words (`Lang.SV`).
///
/// Implements [Num2TextBase] for Swedish. Handles various numeric inputs
/// (`int`, `double`, `BigInt`, `Decimal`, `String`) via the [process] method.
///
/// Features:
/// - Cardinal numbers (e.g., "etthundratjugotre").
/// - Decimals (e.g., "tolv komma fem sex").
/// - Negatives (e.g., "minus tio").
/// - Currency formatting with specific handling for "en krona" vs "ett öre".
/// - Year formatting (e.g., "nittonhundraåttiofyra").
/// - Large numbers using a scale including "miljard" (10^9), "biljon" (10^12), etc.
/// - Differentiates "en" (utrum gender) and "ett" (neuter gender) for '1' based on context.
///
/// Customizable via [SvOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextSV implements Num2TextBase {
  // --- Constants for Swedish Words ---
  static const String _zero = "noll";
  static const String _pointWord = "punkt"; // Word for '.' decimal separator
  static const String _commaWord =
      "komma"; // Word for ',' decimal separator (common in Swedish)
  static const String _hundred = "hundra"; // Hundred
  static const String _thousand = "tusen"; // Thousand

  // --- Scale Words (Long Scale Variant) ---
  // Swedish often uses "miljard" (10^9) where English uses "billion".
  static const String _millionSingular = "miljon"; // 10^6 (utrum gender)
  static const String _millionPlural = "miljoner";
  static const String _milliardSingular = "miljard"; // 10^9 (utrum gender)
  static const String _milliardPlural = "miljarder";
  static const String _billionSingular = "biljon"; // 10^12 (utrum gender)
  static const String _billionPlural = "biljoner";
  static const String _billiardSingular = "biljard"; // 10^15 (utrum gender)
  static const String _billiardPlural = "biljarder";
  static const String _trillionSingular = "triljon"; // 10^18 (utrum gender)
  static const String _trillionPlural = "triljoner";
  static const String _trilliardSingular = "triljard"; // 10^21 (utrum gender)
  static const String _trilliardPlural = "triljarder";
  static const String _quadrillionSingular =
      "kvadriljon"; // 10^24 (utrum gender)
  static const String _quadrillionPlural = "kvadriljoner";

  // --- Other Constants ---
  static const String _yearSuffixBC = "f.Kr."; // "före Kristus" (Before Christ)
  static const String _yearSuffixAD =
      "e.Kr."; // "efter Kristus" (Anno Domini / Common Era)

  // --- Lookup Lists ---

  /// Words for numbers 0-19.
  /// Note: Index 1 is "ett" (neuter/default). "en" (utrum) is handled contextually.
  static const List<String> _wordsUnder20 = [
    "noll",
    "ett",
    "två",
    "tre",
    "fyra",
    "fem",
    "sex",
    "sju",
    "åtta",
    "nio",
    "tio",
    "elva",
    "tolv",
    "tretton",
    "fjorton",
    "femton",
    "sexton",
    "sjutton",
    "arton",
    "nitton",
  ];

  /// Words for tens (20, 30, ..., 90).
  static const List<String> _wordsTens = [
    "",
    "",
    "tjugo",
    "trettio",
    "fyrtio",
    "femtio",
    "sextio",
    "sjuttio",
    "åttio",
    "nittio",
  ];

  /// Scale words mapping for large numbers (powers of 1000).
  /// Provides singular and plural forms for each scale.
  /// Index corresponds to the power of 1000 (e.g., index 2 = 1000^2 = 10^6).
  static const List<Map<String, String>> _scaleWords = [
    {"singular": "", "plural": ""}, // 0: Units (10^0)
    {"singular": _thousand, "plural": _thousand}, // 1: Thousand (10^3)
    {
      "singular": _millionSingular,
      "plural": _millionPlural
    }, // 2: Million (10^6)
    {
      "singular": _milliardSingular,
      "plural": _milliardPlural
    }, // 3: Milliard (10^9)
    {
      "singular": _billionSingular,
      "plural": _billionPlural
    }, // 4: Billion (10^12)
    {
      "singular": _billiardSingular,
      "plural": _billiardPlural
    }, // 5: Billiard (10^15)
    {
      "singular": _trillionSingular,
      "plural": _trillionPlural
    }, // 6: Trillion (10^18)
    {
      "singular": _trilliardSingular,
      "plural": _trilliardPlural
    }, // 7: Trilliard (10^21)
    {
      "singular": _quadrillionSingular,
      "plural": _quadrillionPlural
    }, // 8: Quadrillion (10^24)
  ];

  /// Checks if the scale word at the given index requires the "en" form of 'one'.
  /// Scale words like "miljon", "miljard", etc. (index >= 2) are utrum gender nouns in Swedish,
  /// requiring "en" when preceded directly by the number one (e.g., "en miljon").
  ///
  /// @param scaleIndex The index into `_scaleWords` (0=units, 1=thousand, 2=million...).
  /// @return True if the scale word is utrum gender, false otherwise.
  bool _isScaleUtrum(int scaleIndex) => scaleIndex >= 2;

  /// Processes the given [number] into Swedish words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [SvOptions] for customization (currency, year format, negative prefix, AD/BC, decimal separator).
  /// Defaults apply if [options] is null or not [SvOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or "Inte Ett Nummer" on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [SvOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Swedish words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final SvOptions svOptions =
        options is SvOptions ? options : const SvOptions();
    // Default fallback "Not a number"
    final String errorFallback = fallbackOnError ?? "Inte Ett Nummer";

    // Handle special double values
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? "Minus Oändlighet"
            : "Oändlighet"; // Negative/Positive Infinity
      }
      if (number.isNaN) {
        // Use the determined fallback string
        return errorFallback;
      }
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) {
      // Use the determined fallback string
      return errorFallback;
    }

    // Handle zero separately
    if (decimalValue == Decimal.zero) {
      if (svOptions.currency) {
        // For zero currency, use plural unit name (e.g., "noll kronor")
        // Ensure null safety for plural form.
        return "$_zero ${svOptions.currencyInfo.mainUnitPlural ?? svOptions.currencyInfo.mainUnitSingular}";
      } else {
        return _zero; // Standard "noll"
      }
    }

    // Determine sign and get absolute value for processing
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    // Dispatch to appropriate handler based on options
    String textResult;
    if (svOptions.format == Format.year) {
      // Year formatting handles sign (AD/BC) internally if requested
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), svOptions);
    } else {
      // Handle currency or standard number conversion
      if (svOptions.currency) {
        textResult = _handleCurrency(absValue, svOptions);
      } else {
        textResult = _handleStandardNumber(absValue, svOptions);
      }
      // Prepend negative prefix if applicable (only for non-year formats)
      if (isNegative) {
        textResult = "${svOptions.negativePrefix} $textResult";
      }
    }

    // Return final result (trimming/space normalization happens within sub-functions)
    return textResult;
  }

  /// Converts a non-negative integer ([BigInt]) into Swedish words.
  ///
  /// This is the core recursive logic, handling scales (thousand, million, etc.)
  /// and selecting "en" or "ett" based on context.
  ///
  /// @param n The non-negative integer to convert.
  /// @param useEtt If true, uses "ett" for 1 in the lowest chunk (0-99).
  /// @param useEn If true, uses "en" for 1 in the lowest chunk (0-99).
  ///              Only one of `useEtt` or `useEn` should typically be true. Defaults to "ett".
  /// @return The integer as Swedish words.
  /// @throws ArgumentError if n is negative or exceeds defined scales.
  String _convertInteger(BigInt n,
      {required bool useEtt, required bool useEn}) {
    if (n < BigInt.zero) {
      // Internal function expects non-negative input; sign handled by caller.
      throw ArgumentError("Integer must be non-negative for conversion: $n");
    }
    if (n == BigInt.zero) return _zero; // Base case: zero

    // Delegate chunks less than 1000 directly to _convertChunk
    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt(), useEtt: useEtt, useEn: useEn);
    }

    // --- Chunking Logic for numbers >= 1000 ---
    List<String> parts =
        []; // Stores word parts for each scale (e.g., "fem miljoner", "etthundratjugotre")
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0; // 0=units, 1=thousand, 2=million...
    BigInt remaining = n; // The portion of the number yet to be processed

    while (remaining > BigInt.zero) {
      // Check if number exceeds defined scales
      if (scaleIndex >= _scaleWords.length) {
        throw ArgumentError(
          "Number too large to convert (exceeds defined scales: ${_scaleWords.last['singular']})",
        );
      }

      BigInt chunk = remaining % oneThousand; // Get the current chunk (0-999)
      remaining ~/= oneThousand; // Move to the next higher chunk

      if (chunk > BigInt.zero) {
        // Only process non-zero chunks
        final bool chunkIsOne =
            chunk == BigInt.one; // Is the numeric value of this chunk 1?

        // Determine 'en'/'ett' usage for *this specific chunk* based on scale
        bool currentChunkUseEtt = true; // Default to 'ett'
        bool currentChunkUseEn = false;

        String scaleWord = ""; // The scale word (e.g., "tusen", "miljoner")
        String separator = " "; // Separator between chunk words and scale word

        if (scaleIndex > 0) {
          // If we are processing thousands or higher
          // Get the appropriate singular/plural scale word
          scaleWord = chunkIsOne
              ? _scaleWords[scaleIndex]["singular"]!
              : _scaleWords[scaleIndex]["plural"]!;

          // --- Special handling for thousands (scaleIndex == 1) ---
          if (scaleIndex == 1) {
            // Tusen
            if (chunkIsOne) {
              // Special case: 1000 is "ettusen", not "ett tusen"
              // Add directly to parts and skip the rest of the loop iteration for this chunk.
              parts.add("ettusen");
              scaleIndex++; // Manually increment scaleIndex as 'continue' skips the loop's end
              continue; // Skip standard chunk processing
            }
            // For other thousands (e.g., 2000, 5000, 23000)
            int chunkInt = chunk.toInt();
            // Separator logic (original): Use space only for 2-9 thousand? Seems specific.
            if (chunkInt >= 2 && chunkInt <= 9) {
              separator = " "; // e.g., "två tusen"
            } else {
              separator =
                  ""; // e.g., "tjugotre tusen" (concatenated?) -> Test shows "tjugotretusen" is common
              // Logic here seems to aim for space sometimes, empty other times.
            }
            // Thousands are counted using "ett" (neuter)
            currentChunkUseEtt = true;
            currentChunkUseEn = false;
          }
          // --- Handling for millions and higher (scaleIndex >= 2) ---
          else {
            if (chunkIsOne) {
              // If chunk is 1, use 'en' if scale word is utrum ("en miljon"), else 'ett'
              if (_isScaleUtrum(scaleIndex)) {
                currentChunkUseEtt = false; // Use 'en'
                currentChunkUseEn = true;
              } else {
                currentChunkUseEtt =
                    true; // Use 'ett' (though unlikely for current scales)
                currentChunkUseEn = false;
              }
            } else {
              // If chunk is > 1, the number part uses 'ett' (e.g., "två miljoner")
              currentChunkUseEtt = true;
              currentChunkUseEn = false;
            }
            // Always use space separator for millions+
            separator = " ";
          }
        } else {
          // --- Handling for the units chunk (scaleIndex == 0) ---
          // Use the 'en'/'ett' preference passed into the function
          currentChunkUseEtt = useEtt;
          currentChunkUseEn = useEn;
          scaleWord = ""; // No scale word for units chunk
          separator = ""; // No separator needed
        }

        // Convert the numeric value (0-999) of the chunk into words
        String currentChunkText = _convertChunk(
          chunk.toInt(),
          useEtt: currentChunkUseEtt, // Pass calculated 'en'/'ett' preference
          useEn: currentChunkUseEn,
        );

        // Combine the chunk text and scale word (if any) and add to parts list
        if (scaleWord.isNotEmpty) {
          // Trim potentially redundant spaces if separator logic is complex
          parts.add("$currentChunkText$separator$scaleWord".trim());
        } else {
          // Just add the chunk text if it's the units scale
          parts.add(currentChunkText);
        }
      }
      scaleIndex++; // Move to the next scale for the next iteration
    }

    // Join the parts in reverse order (highest scale first) with spaces
    return parts.reversed.join(' ');
  }

  /// Converts an integer between 0 and 999 into Swedish words.
  /// Handles hundreds and combines with numbers under 100.
  /// Concatenates parts (e.g., "etthundratjugotre").
  ///
  /// @param n The integer chunk (0-999).
  /// @param useEtt Propagated to _convertUnder100 for handling '1'.
  /// @param useEn Propagated to _convertUnder100 for handling '1'.
  /// @return The chunk as Swedish words, or empty string if n is 0.
  /// @throws ArgumentError if n is outside the 0-999 range.
  String _convertChunk(int n, {required bool useEtt, required bool useEn}) {
    if (n == 0) return ""; // Zero chunk contributes nothing
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }

    String hundredPart = "";
    int remainder = n;

    // Handle hundreds part (100-900)
    if (remainder >= 100) {
      int hundredDigit = remainder ~/ 100;
      // The number counting hundreds (1-9) uses 'ett' form.
      String digitWord =
          _convertUnder100(hundredDigit, useEtt: true, useEn: false);
      // Concatenate: "ett" + "hundra" -> "etthundra"
      hundredPart = "$digitWord$_hundred";
      remainder %= 100; // Get the remaining 0-99 part
    }

    // Handle the remaining part (0-99)
    String under100Part = "";
    if (remainder > 0) {
      // Convert the 0-99 part, respecting the original 'en'/'ett' preference
      under100Part = _convertUnder100(remainder, useEtt: useEtt, useEn: useEn);
    }

    // Concatenate hundreds part and the rest (e.g., "etthundra" + "tjugotre")
    return "$hundredPart$under100Part";
  }

  /// Converts an integer between 0 and 99 into Swedish words.
  /// Handles 'en'/'ett' distinction for 1 based on parameters.
  /// Concatenates tens and units (e.g., "tjugo" + "tre" -> "tjugotre").
  ///
  /// @param n The integer (0-99).
  /// @param useEtt If true and n is 1, returns "ett".
  /// @param useEn If true and n is 1, returns "en".
  /// @return The number 0-99 as Swedish words.
  /// @throws ArgumentError if n is outside the 0-99 range.
  String _convertUnder100(int n, {required bool useEtt, required bool useEn}) {
    if (n < 0 || n >= 100) {
      throw ArgumentError("Number must be between 0 and 99: $n");
    }

    // Handle 1 based on flags
    if (n == 1) {
      // Prioritize 'en' if requested, otherwise default to 'ett'
      return useEn ? "en" : (useEtt ? "ett" : "ett");
    }
    // Use direct lookup for 0, 2-19
    if (n < 20) {
      return _wordsUnder20[n];
    } else {
      // Handle 20-99
      String tensWord =
          _wordsTens[n ~/ 10]; // Get the tens word (e.g., "tjugo")
      int unit = n % 10; // Get the unit digit
      if (unit == 0) {
        // If units digit is 0, just return the tens word (e.g., "tjugo")
        return tensWord;
      } else {
        // If units digit > 0, convert it (always uses 'ett' for 1 here) and concatenate
        String unitWord = _convertUnder100(unit, useEtt: true, useEn: false);
        // Concatenate: "tjugo" + "tre" -> "tjugotre"
        return "$tensWord$unitWord";
      }
    }
  }

  /// Converts a non-negative [Decimal] value to Swedish currency words.
  ///
  /// Uses [SvOptions.currencyInfo] for unit names (krona/kronor, öre/ören).
  /// Applies specific Swedish grammar:
  /// - Main unit uses "en" for 1 (e.g., "en krona").
  /// - Subunit uses "ett" for 1 (e.g., "ett öre").
  /// Rounds if [SvOptions.round] is true (implicitly rounds to 2 decimals).
  ///
  /// @param absValue Absolute currency value.
  /// @param options The [SvOptions] with currency info and formatting flags.
  /// @return Currency value as Swedish words.
  String _handleCurrency(Decimal absValue, SvOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round; // Check if rounding is enabled
    final int decimalPlaces = 2; // Standard currency decimal places
    final Decimal subunitMultiplier = Decimal.fromInt(100); // 100 öre per krona

    // Round to 2 decimal places if requested, otherwise use original value
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main (kronor) and subunit (ören) values
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    // Calculate fractional part precisely
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Get subunit value, truncating any further decimals (e.g., 1.999 -> 99 öre)
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).truncate().toBigInt();

    String mainText = ""; // Word representation of the main value
    String mainUnitName = ""; // Singular or plural main unit name
    String separator = ""; // Separator between main and subunit parts
    String result = ""; // Builds the final string

    // --- Generate Main Currency Part ---
    // Only include if the main value is greater than zero
    if (mainValue > BigInt.zero) {
      // Currency main unit (krona) is utrum gender, so use "en" for 1.
      mainText = _convertInteger(mainValue, useEtt: false, useEn: true);
      // Select singular or plural unit name
      mainUnitName = (mainValue == BigInt.one)
          ? currencyInfo.mainUnitSingular
          : currencyInfo.mainUnitPlural!;
      // Combine number and unit name
      result = '$mainText $mainUnitName'; // Initial assignment to result

      // Prepare separator if subunits also exist
      if (subunitValue > BigInt.zero && currencyInfo.separator != null) {
        separator =
            ' ${currencyInfo.separator} '; // Use configured separator (e.g., "och")
      }
    }

    // --- Generate Subunit Currency Part ---
    if (subunitValue > BigInt.zero) {
      // Currency subunit (öre) is neuter gender, so use "ett" for 1.
      String subunitText =
          _convertInteger(subunitValue, useEtt: true, useEn: false);
      // Select singular or plural subunit name
      String subUnitName = (subunitValue == BigInt.one)
          ? currencyInfo.subUnitSingular!
          : currencyInfo.subUnitPlural!;

      // If main part already exists in `result`, prepend the separator
      if (result.isNotEmpty) {
        result += separator; // Add separator (e.g., " och ")
      }
      // Append the subunit part (number + name)
      result += '$subunitText $subUnitName';
    }

    // --- Handle Zero Case ---
    // If both main and subunit values are zero (either initially or after rounding)
    if (mainValue == BigInt.zero && subunitValue == BigInt.zero) {
      // Return "noll" + plural main unit name (e.g., "noll kronor")
      result =
          "$_zero ${currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular}";
    }

    // Trim final result for safety, although logic should prevent leading/trailing spaces
    return result.trim();
  }

  /// Converts a year number into Swedish words.
  /// Handles AD/BC suffixes and specific concatenated phrasing for certain ranges.
  ///
  /// Examples:
  /// - 1984 -> "nittonhundraåttiofyra"
  /// - 2000 -> "tjugohundra"
  /// - 2005 -> "tjugohundrafem"
  /// - 500 BC -> "femhundra f.Kr."
  ///
  /// @param year The integer year.
  /// @param options The [SvOptions] controlling AD/BC suffix inclusion.
  /// @return The year formatted as Swedish words.
  String _handleYearFormat(int year, SvOptions options) {
    final bool isNegative = year < 0; // Check if it's a BC year
    final int absYear = isNegative ? -year : year; // Absolute year value
    final BigInt bigAbsYear =
        BigInt.from(absYear); // Convert to BigInt for _convertInteger

    String yearText; // Holds the final text representation
    // Year format typically uses "ett" for one (neuter context)
    final bool useEtt = true;
    final bool useEn = false;

    // --- Special Phrasing for 1100-1999 ---
    // e.g., 1984 is read as "nitton-hundra-åttiofyra" (nineteen-hundred-eightyfour)
    if (absYear >= 1100 && absYear < 2000) {
      int highPartInt = absYear ~/ 100; // e.g., 19 (nitton)
      int lowPartInt = absYear % 100; // e.g., 84 (åttiofyra)
      // Convert parts separately, using "ett" context
      String highText = _convertInteger(BigInt.from(highPartInt),
          useEtt: useEtt, useEn: useEn);
      String lowText = _convertInteger(BigInt.from(lowPartInt),
          useEtt: useEtt, useEn: useEn);

      if (lowPartInt == 0) {
        // e.g., 1900 -> "nittonhundra" (concatenate high part + "hundra")
        yearText = "$highText$_hundred";
      } else {
        // e.g., 1984 -> "nittonhundraåttiofyra" (concatenate high part + "hundra" + low part)
        yearText = "$highText$_hundred$lowText";
      }
    }
    // --- Special Phrasing for 2000-2099 ---
    // e.g., 2005 is read as "tjugo-hundra-fem" (twenty-hundred-five)
    else if (absYear >= 2000 && absYear < 2100) {
      int highPartInt = absYear ~/ 100; // e.g., 20 (tjugo)
      int lowPartInt = absYear % 100; // e.g., 05 (fem)
      // Convert parts separately, using "ett" context
      String highText = _convertInteger(BigInt.from(highPartInt),
          useEtt: useEtt, useEn: useEn);
      String lowText = _convertInteger(BigInt.from(lowPartInt),
          useEtt: useEtt, useEn: useEn);

      if (lowPartInt == 0) {
        // e.g., 2000 -> "tjugohundra" (concatenate high part + "hundra")
        yearText = "$highText$_hundred";
      } else {
        // e.g., 2005 -> "tjugohundrafem" (concatenate high part + "hundra" + low part)
        yearText = "$highText$_hundred$lowText";
      }
    }
    // --- Default Conversion for Other Years ---
    else {
      // Use standard integer conversion (e.g., 1066 -> "ettusensextiosex")
      yearText = _convertInteger(bigAbsYear, useEtt: useEtt, useEn: useEn);
    }

    // --- Add Era Suffixes (AD/BC) ---
    if (isNegative) {
      // Append BC suffix for negative years
      yearText += " $_yearSuffixBC"; // " f.Kr."
    } else if (options.includeAD && absYear > 0) {
      // Append AD/CE suffix for positive years *only if* requested in options and year is not 0
      yearText += " $_yearSuffixAD"; // " e.Kr."
    }

    return yearText;
  }

  /// Converts a standard number (potentially with decimals) into Swedish words.
  /// Uses "ett" for 1 in the integer part and fractional digits. Reads digits after
  /// the decimal point individually.
  ///
  /// @param absValue The absolute decimal value.
  /// @param options The [SvOptions] controlling decimal separator word.
  /// @return The number formatted as Swedish words.
  String _handleStandardNumber(Decimal absValue, SvOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    final int scale =
        absValue.scale; // Get the number of digits after the decimal point

    // Standard numbers typically use "ett" for 1 (neuter context)
    final bool useEtt = true;
    final bool useEn = false;

    // --- Convert Integer Part ---
    // Use "noll" if integer is 0 but a fractional part exists (e.g., 0.5 -> "noll komma fem")
    // Otherwise, convert the integer part using "ett" context.
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, useEtt: useEtt, useEn: useEn);

    String fractionalWords = ''; // Holds the text for the fractional part

    // --- Convert Fractional Part ---
    // Process only if there are decimal digits and the fractional part is non-zero
    if (scale > 0 && fractionalPart > Decimal.zero) {
      String separatorWord;
      // Choose decimal separator word ("komma" or "punkt") based on options
      switch (options.decimalSeparator ?? DecimalSeparator.comma) {
        // Default to comma
        case DecimalSeparator.comma:
          separatorWord = _commaWord;
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          separatorWord = _pointWord;
          break;
      }

      // --- Extract and Format Fractional Digits ---
      // 1. Get the fractional value only (e.g., 12.345 -> 0.345)
      Decimal fractionalValueOnly = absValue.remainder(Decimal.one);
      // 2. Scale it up to an integer (e.g., 0.345 * 10^3 -> 345)
      BigInt fractionalAsInt =
          (fractionalValueOnly * (Decimal.ten.pow(scale)).toDecimal())
              .truncate() // Remove any potential precision errors after scaling
              .toBigInt();
      // 3. Convert to string (e.g., 345 -> "345")
      String fractionalDigits = fractionalAsInt.toString();
      // 4. Pad with leading zeros if needed (e.g., if original was 12.05, scale=2, fracInt=5, need "05")
      fractionalDigits = fractionalDigits.padLeft(scale, '0');

      // --- Convert Digits to Words ---
      // Convert each digit character to its word representation
      List<String> digitWords = fractionalDigits.split('').map((digit) {
        final int digitInt = int.parse(digit);
        // Use "ett" for the digit '1' in the fractional part
        return (digitInt == 1) ? _wordsUnder20[1] : _wordsUnder20[digitInt];
      }).toList();

      // Combine separator word and digit words
      fractionalWords =
          ' $separatorWord ${digitWords.join(' ')}'; // e.g., " komma tre fyra fem"
    }

    // Combine integer and fractional parts
    return '$integerWords$fractionalWords'.trim();
  }
}
