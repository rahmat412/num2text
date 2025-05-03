import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/mn_options.dart';
import '../utils/utils.dart';

/// {@template num2text_mn}
/// Converts numbers to Mongolian words (`Lang.MN`).
///
/// Implements [Num2TextBase] for the Mongolian language, handling various numeric types.
/// Supports cardinal numbers, decimals, negatives, currency, and years.
///
/// Key Mongolian Features Handled (based on implementation):
/// - **Vowel Harmony Suffixes:** Implicitly handled by using pre-defined word forms.
/// - **Contextual Number Forms:** Uses different forms of numbers (units, tens, hundreds) depending on whether they stand alone or precede another number/scale word (e.g., "гурван" vs "гурав", "зуун" vs "зуу").
/// - **Scale Words:** Uses standard Mongolian scale words (мянга, сая, тэрбум, etc.).
/// - **Special Cases:** Handles forms like "арван нэг"/"арван нэгэн".
/// - **Currency:** Formats currency values.
/// - **Years:** Formats years, optionally adding "НТӨ" (BC) or "НТ" (AD).
///
/// Customizable via [MnOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextMN implements Num2TextBase {
  // --- Constants ---

  // General & Special Values
  static const String _decimalPointWord = "цэг"; // "tseg" - decimal point
  static const String _decimalCommaWord = "таслал"; // "taslal" - decimal comma
  static const String _zero = "тэг"; // "teg" - zero
  static const String _infinity = "Хязгааргүй"; // "Khyazgaargüi" - Infinity
  static const String _negativeInfinity =
      "Сөрөг Хязгааргүй"; // "Sörög Khyazgaargüi" - Negative Infinity
  static const String _notANumber = "Тоо Биш"; // "Too Bish" - Not a Number
  static const String _yearSuffixBC =
      "НТӨ"; // "NTÖ" - Naiman Tugarig Orosgol (Before Common Era / BC)
  static const String _yearSuffixAD =
      "НТ"; // "NT" - Naiman Tugarig (Common Era / AD)

  // Units (1-9) - Standalone/Base form
  static const List<String> _units = [
    "", // 0 - Index placeholder
    "нэг", // 1 - neg
    "хоёр", // 2 - khoyor
    "гурав", // 3 - gurav
    "дөрөв", // 4 - döröv
    "тав", // 5 - tav
    "зургаа", // 6 - zurgaa
    "долоо", // 7 - doloo
    "найм", // 8 - naim
    "ес", // 9 - yes
  ];

  // Units (3-9) - Modified/Combined form (used before tens, hundreds, scales)
  // Ends with 'н' consonant sound.
  static const Map<int, String> _unitsModified = {
    3: "гурван", // gurvan
    4: "дөрвөн", // dörvön
    5: "таван", // tavan
    6: "зургаан", // zurgaan
    7: "долоон", // doloon
    8: "найман", // naiman
    9: "есөн", // yesön
  };

  // Teens (10-19) - Standalone form
  static const List<String> _teens = [
    "арав", // 10 - arav
    "арван нэг", // 11 - arvan neg
    "арван хоёр", // 12 - arvan khoyor
    "арван гурав", // 13 - arvan gurav
    "арван дөрөв", // 14 - arvan döröv
    "арван тав", // 15 - arvan tav
    "арван зургаа", // 16 - arvan zurgaa
    "арван долоо", // 17 - arvan doloo
    "арван найм", // 18 - arvan naim
    "арван ес", // 19 - arvan yes
  ];

  // Tens (10) - Combined form (used before units or scales potentially)
  static const String _tenCombined = "арван"; // arvan

  // Eleven (11) - Combined/Modified form (used when followed by context like currency/year suffix)
  static const String _elevenCombined = "арван нэгэн"; // arvan negen

  // Tens (10-90) - Standalone form (used when the number ends exactly on the ten)
  static const List<String> _tensStandalone = [
    "", // 0
    "арав", // 10 - arav
    "хорь", // 20 - khor'
    "гуч", // 30 - guch
    "дөч", // 40 - döch
    "тавь", // 50 - tav'
    "жар", // 60 - jar
    "дал", // 70 - dal
    "ная", // 80 - naya
    "ер", // 90 - yer
  ];

  // Tens (10-90) - Combined form (used when followed by a unit 1-9)
  static const List<String> _tensCombined = [
    "", // 0
    "арван", // 10 - arvan (same as _tenCombined)
    "хорин", // 20 - khorin
    "гучин", // 30 - guchin
    "дөчин", // 40 - döchin
    "тавин", // 50 - tavin
    "жаран", // 60 - jaran
    "далан", // 70 - dalan
    "наян", // 80 - nayan
    "ерэн", // 90 - yeren
  ];

  // Hundred (100) - Standalone form
  static const String _hundredStandalone = "зуу"; // zuu

  // Hundred (100) - Combined form (used when followed by tens/units)
  static const String _hundredCombined = "зуун"; // zuun

  // Scale words (Short scale mapping - Мянга, Сая, Тэрбум...)
  // Index represents power of 1000 (1 = 10^3, 2 = 10^6, etc.)
  static const Map<int, String> _scaleWords = {
    1: "мянга", // myanga (thousand)
    2: "сая", // saya (million)
    3: "тэрбум", // terbum (billion)
    4: "их наяд", // ikh nayad (trillion) - Lit. "great myriad"
    5: "квадриллион", // quadrillion (loanword)
    6: "квинтиллион", // quintillion (loanword)
    7: "секстиллион", // sextillion (loanword)
    8: "септиллион", // septillion (loanword)
    // Higher scales could be added if needed
  };

  /// Processes the given [number] into Mongolian words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [MnOptions] for customization (currency, year format, AD/BC inclusion, negative prefix, decimal separator).
  /// Defaults apply if [options] is null or not [MnOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity` ("Хязгааргүй"), `NaN`. Returns [fallbackOnError] or "Тоо Биш" on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [MnOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Mongolian words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure correct options type or use defaults
    final MnOptions mnOptions =
        options is MnOptions ? options : const MnOptions();
    // Determine the error message to use on failure
    final String errorDefault = fallbackOnError ?? _notANumber;
    // Get currency info from options
    final CurrencyInfo currencyInfo = mnOptions.currencyInfo;

    // Handle special double values immediately
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? _negativeInfinity : _infinity;
      }
      if (number.isNaN) return errorDefault;
    }

    // Normalize the input number to Decimal for consistent handling
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null)
      return errorDefault; // Return error if normalization fails

    // Determine sign and get absolute value
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    // Handle the specific case of zero
    if (absValue == Decimal.zero) {
      if (mnOptions.currency) {
        // For currency, use plural unit name (e.g., "тэг төгрөг")
        final currencyName =
            currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;

        // *** Original logic check for 0.XX currency ***
        // Check if the original decimal had fractional digits and subunits are defined.
        // This block attempts to handle cases like 0.50 MNT -> "тавин мөнгө"
        // It recalculates subunit value and calls _handleCurrency if subunits exist.
        // Note: This check might be redundant if _handleCurrency handles zero main value correctly.
        if (decimalValue.scale > 0 && currencyInfo.subUnitSingular != null) {
          final Decimal fractionalPart = decimalValue - decimalValue.truncate();
          // Assuming 100 subunits per main unit for rounding/truncation
          final BigInt subunitValue = (fractionalPart * Decimal.fromInt(100))
              .round(scale: 0)
              .toBigInt();
          if (subunitValue > BigInt.zero) {
            // If non-zero subunits exist, delegate to the main currency handler
            return _handleCurrency(absValue, mnOptions);
          }
        }
        // Otherwise, return zero main units
        return "$_zero $currencyName";
      } else {
        // For non-currency, just return "тэг"
        return _zero;
      }
    }

    // --- Determine Context for Number Form Modification ---
    // Determines if the last word of the number needs the modified form (e.g., "гурван" instead of "гурав").
    // This happens if the number is followed by a currency unit, year suffix (AD/BC), or decimal part.
    String resultText; // Holds the final text result
    bool externalContextFollows =
        false; // Flag: Does context follow the number?
    bool isYearBC = false; // Flag: Is this a BC year?

    if (mnOptions.format == Format.year) {
      // Check original sign for BC/AD determination
      bool originalIsNegative = number is int
          ? number < 0
          : (number is Decimal ? number.isNegative : decimalValue.isNegative);
      isYearBC = originalIsNegative;
      // Context follows if it's BC or if AD suffix is requested
      externalContextFollows = isYearBC || mnOptions.includeAD;
    } else if (mnOptions.currency) {
      // Currency units always provide following context
      externalContextFollows = true;
    } else {
      // For standard numbers, check if there's a non-zero fractional part
      final Decimal fractionalPart = absValue - absValue.truncate();
      if (fractionalPart > Decimal.zero) {
        // More robust check: ensure fractional digits exist after trimming zeros
        String fractionalDigits = absValue.toString().split('.').last;
        if (fractionalDigits.replaceAll(RegExp(r'0+$'), '').isNotEmpty) {
          externalContextFollows = true; // Decimal part provides context
        }
      }
    }

    // --- Convert Based on Type ---
    if (mnOptions.format == Format.year) {
      // Convert year integer part, passing the context flag
      BigInt yearInt = absValue.truncate().toBigInt();
      resultText =
          _convertInteger(yearInt, hasFollowingContext: externalContextFollows);
    } else if (mnOptions.currency) {
      // Handle currency formatting
      resultText = _handleCurrency(absValue, mnOptions);
    } else {
      // Handle standard number (integer + potential decimal)
      resultText =
          _handleStandardNumber(absValue, mnOptions, externalContextFollows);
    }

    // --- Add Suffixes / Prefixes ---
    if (mnOptions.format == Format.year) {
      // Add BC/AD suffixes to the year text
      if (isYearBC) {
        // Special case: "нэг" (1) becomes "нэгэн" before BC suffix
        if (resultText == "нэг") {
          resultText = "нэгэн";
        }
        resultText += " $_yearSuffixBC";
      } else if (mnOptions.includeAD) {
        // Re-convert with context=true to ensure correct form before AD suffix
        BigInt yearInt = absValue.truncate().toBigInt();
        resultText = _convertInteger(yearInt, hasFollowingContext: true);
        resultText += " $_yearSuffixAD";
      }
      // No negative prefix for years (handled by BC/AD)
    } else if (isNegative) {
      // Add negative prefix for non-year numbers
      resultText =
          "${mnOptions.negativePrefix} $resultText"; // Default "хасах" (khasakh)
    }

    // Return the final trimmed result
    return resultText.trim();
  }

  /// Helper to get the correct unit word (1-9) based on context.
  ///
  /// @param digit The unit digit (1-9).
  /// @param needsModification If true, returns the modified form (e.g., "гурван") used before other words.
  ///                        If false, returns the standalone form (e.g., "гурав").
  /// @return The appropriate Mongolian word for the unit digit, or empty string if invalid.
  String _getUnitWord(int digit, {required bool needsModification}) {
    if (digit < 1 || digit > 9) return ""; // Handle invalid digits
    // 1 and 2 don't have distinct modified forms in this implementation's lists
    if (digit == 1 || digit == 2) return _units[digit];
    // Check if the digit has a modified form (3-9)
    bool canBeModified = digit >= 3;
    // Return modified form if needed and possible, otherwise return standard form
    return (needsModification && canBeModified)
        ? (_unitsModified[digit] ??
            _units[digit]) // Use modified if exists, fallback just in case
        : _units[digit]; // Use standard form
  }

  /// Converts a non-negative integer ([BigInt]) into Mongolian words.
  ///
  /// Handles chunking by thousands and applying scale words. Determines if the
  /// final unit word needs modification based on `hasFollowingContext`.
  ///
  /// @param n The non-negative integer to convert.
  /// @param hasFollowingContext If true, the number is followed by other words (currency, year suffix, decimal),
  ///                            requiring the modified form for the final unit/ten/hundred.
  /// @return The integer as Mongolian words.
  String _convertInteger(BigInt n, {required bool hasFollowingContext}) {
    if (n < BigInt.zero)
      throw ArgumentError("Integer must be non-negative: $n");
    if (n == BigInt.zero) return _zero; // Base case: 0

    // Delegate numbers 0-999 to _convertChunk
    if (n < BigInt.from(1000)) {
      // Pass context flag to handle final word modification
      return _convertChunk(n.toInt(),
          needsFinalUnitModification: hasFollowingContext);
    }

    // --- Chunking Logic for numbers >= 1000 ---
    List<String> parts =
        []; // Holds text for each scale part (e.g., "хоёр мянга", "таван зуун жаран нэг")
    final BigInt oneThousand = BigInt.from(1000);
    int scaleLevel = 0; // 0=units, 1=thousands, 2=millions...
    BigInt remaining = n; // Value remaining to be processed

    while (remaining > BigInt.zero) {
      int chunkInt =
          (remaining % oneThousand).toInt(); // Current chunk value (0-999)
      BigInt higherRemaining =
          remaining ~/ oneThousand; // Remaining part for higher scales
      bool isLowestChunk =
          (scaleLevel == 0); // Is this the units/hundreds/tens chunk?
      bool chunkWillHaveScaleWord = (scaleLevel >
          0); // Will a scale word ("мянга", "сая") follow this chunk?

      if (chunkInt > 0) {
        // Only process non-zero chunks
        // --- Determine Modification Context for the Chunk ---
        // Does the last unit/ten/hundred within *this chunk* need modification?
        // 1. Yes, if a scale word follows this chunk (e.g., "гурван" in "гурван мянга").
        bool modifyChunkUnitsForScale = chunkWillHaveScaleWord;
        // 2. Yes, if this is the lowest chunk (units) AND there's external context following the whole number.
        bool modifyChunkUnitsForExternal = hasFollowingContext && isLowestChunk;
        // Final decision: modification is needed if either condition is true.
        bool needsFinalUnitModification =
            modifyChunkUnitsForScale || modifyChunkUnitsForExternal;

        // Convert the 0-999 chunk value using the determined context
        String chunkText = _convertChunk(chunkInt,
            needsFinalUnitModification: needsFinalUnitModification);

        // --- Add Scale Word (if applicable) ---
        String? scaleWord =
            _scaleWords[scaleLevel]; // Get scale word (e.g., "мянга", "сая")
        if (scaleWord != null && scaleLevel > 0) {
          // If a scale word exists, append it to the chunk text
          if (chunkText.isNotEmpty) {
            // Should always be true if chunkInt > 0
            parts.add("$chunkText $scaleWord"); // e.g., "гурван мянга"
          }
          // If chunkText was somehow empty (shouldn't happen), scale word is skipped
        } else if (scaleLevel == 0) {
          // If it's the units chunk (scale 0), just add the chunk text
          parts.add(chunkText);
        }
        // Scales beyond _scaleWords map are currently ignored silently.
      }
      // Move to the next higher scale
      remaining = higherRemaining;
      scaleLevel++;
    }

    // Combine parts from highest scale down, ensuring non-empty parts and single spaces
    return parts.reversed.where((part) => part.isNotEmpty).join(' ');
  }

  /// Converts an integer between 0 and 999 into Mongolian words.
  ///
  /// Handles hundreds, tens, and units, applying contextual modifications
  /// based on `needsFinalUnitModification`.
  ///
  /// @param n The integer chunk (0-999).
  /// @param needsFinalUnitModification If true, the last word component (unit, ten, or hundred)
  ///                                   should use its modified/combined form.
  /// @return The chunk as Mongolian words, or empty string if n is 0.
  String _convertChunk(int n, {required bool needsFinalUnitModification}) {
    if (n == 0) return ""; // Base case
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    List<String> words =
        []; // Holds word parts ("таван", "зуун", "жаран", "нэг")
    int remainder = n; // Remaining value to process
    bool processedUnitsOrTens = false; // Flag if tens or units part was handled

    // Determine if the number has a non-zero part in the 1-99 range
    bool hasUnitsAndTens = (remainder % 100) > 0;

    // --- Process Hundreds ---
    if (remainder >= 100) {
      int hundredDigit = remainder ~/ 100; // Hundreds digit (1-9)
      // Get the unit word for the hundred digit (needs modification, e.g., "гурван")
      String hundredPrefix =
          _getUnitWord(hundredDigit, needsModification: true);
      // Choose hundred word form: "зуун" (combined) if tens/units follow, "зуу" (standalone) otherwise
      String hundredWord =
          hasUnitsAndTens ? _hundredCombined : _hundredStandalone;
      words.add(
          "$hundredPrefix $hundredWord"); // e.g., "гурван зуун" or "гурван зуу"
      remainder %= 100; // Get remaining tens/units (0-99)
    }

    // --- Process Tens and Units ---
    if (remainder > 0) {
      // Process if remainder is 1-99
      processedUnitsOrTens = true; // Mark that this part was processed
      bool hasUnitDigit =
          (remainder % 10) > 0; // Does it have a non-zero unit digit?
      // Determine if the *unit digit* itself needs modification (only if it's the very last part of the whole number)
      bool modifyThisUnit = needsFinalUnitModification;

      if (remainder < 10) {
        // Units 1-9: Get the unit word, applying final modification if needed
        String unitWord =
            _getUnitWord(remainder, needsModification: modifyThisUnit);
        words.add(unitWord);
      } else if (remainder == 11) {
        // Special case for 11: Use combined "арван нэгэн" if final modification needed
        words.add(modifyThisUnit
            ? _elevenCombined
            : _teens[1]); // _teens[1] is "арван нэг"
      } else if (remainder < 20) {
        // Teens 10, 12-19
        if (remainder == 10) {
          // Special case for 10: Use combined "арван" if final modification needed
          words.add(
              modifyThisUnit ? _tenCombined : _teens[0]); // _teens[0] is "арав"
        } else {
          // Other teens (12-19) don't seem to have modified forms in this logic
          words.add(_teens[remainder - 10]); // Index is value - 10
        }
      } else {
        // Tens 20-99
        int tenDigit = remainder ~/ 10; // Tens digit (2-9)
        // Choose tens word form: Combined (e.g., "хорин") if units follow, Standalone (e.g., "хорь") otherwise
        String tenWord =
            hasUnitDigit ? _tensCombined[tenDigit] : _tensStandalone[tenDigit];
        words.add(tenWord);

        if (hasUnitDigit) {
          // If there's a unit digit (1-9)
          int unitDigit = remainder % 10;
          // Get the unit word, applying final modification if it's the end of the whole number
          String unitWord =
              _getUnitWord(unitDigit, needsModification: modifyThisUnit);
          words.add(unitWord); // Add the unit word
        } else {
          // If it ends exactly on a ten (20, 30...) but needs final modification
          // Replace standalone ten (e.g., "хорь") with combined form (e.g., "хорин")
          if (modifyThisUnit) {
            words.removeLast(); // Remove the standalone ten added earlier
            words.add(_tensCombined[tenDigit]); // Add the combined ten form
          }
        }
      }
    }

    // --- Final Modification Check for Hundreds ---
    // If only hundreds were processed (no tens/units) AND final modification is needed
    if (!processedUnitsOrTens &&
        needsFinalUnitModification &&
        words.isNotEmpty) {
      // Check if the last word added was a standalone hundred ("зуу")
      if (words.last.endsWith(_hundredStandalone)) {
        // Replace standalone "зуу" with combined "зуун"
        words.last =
            words.last.replaceFirst(_hundredStandalone, _hundredCombined);
      }
    }

    // Join the collected word parts with spaces
    return words.join(' ');
  }

  /// Converts a non-negative [Decimal] value to Mongolian currency words.
  ///
  /// Uses [MnOptions.currencyInfo] for unit names (e.g., төгрөг/төгрөг, мөнгө/мөнгө).
  /// Applies contextual modification to numbers before units. Handles rounding if specified.
  /// Correctly formats values with zero main units but non-zero subunits (e.g., 0.50).
  ///
  /// @param absValue Absolute currency value.
  /// @param options The [MnOptions] with currency info and rounding flag.
  /// @return Currency value as Mongolian words.
  String _handleCurrency(Decimal absValue, MnOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    // Standard multiplier for currencies with 2 decimal places (e.g., Tugrik/Mungu)
    final Decimal multiplier = Decimal.fromInt(100);

    Decimal valueToConvert = absValue;
    // Apply rounding if specified in options
    if (options.round) {
      // Round to 2 decimal places if subunits exist, otherwise round to 0 decimals.
      valueToConvert =
          absValue.round(scale: currencyInfo.subUnitSingular != null ? 2 : 0);
    }

    // Separate main and subunit integer values from the (potentially rounded) value
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Round the subunit value to the nearest integer (handles potential floating point issues)
    final BigInt subunitValue =
        (fractionalPart * multiplier).round(scale: 0).toBigInt();

    String mainText = ""; // Holds the fully constructed main part string
    // Default to plural main unit name, fallback to singular
    String mainUnitName =
        currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;
    // Check if non-zero subunits exist and are defined
    bool subunitExists =
        subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null;

    // --- Generate Main Currency Part ---
    if (mainValue > BigInt.zero) {
      // Convert main value integer, indicating context follows (the unit name)
      mainText = _convertInteger(mainValue, hasFollowingContext: true);
      // Special modification for 11 before a unit (from original logic)
      if (mainText == "арван нэг") {
        mainText = "арван нэгэн";
      }
      mainText += ' $mainUnitName'; // Append the unit name
    }

    // --- Generate Subunit Currency Part ---
    String subunitText = ""; // Holds the fully constructed subunit part string
    if (subunitExists) {
      String subUnitName = currencyInfo
          .subUnitSingular!; // Get subunit name (non-null checked above)
      // Convert subunit value integer, indicating context follows (the subunit name)
      subunitText = _convertInteger(subunitValue, hasFollowingContext: true);
      // Special modification for 11 before a unit (from original logic)
      if (subunitText == "арван нэг") {
        subunitText = "арван нэгэн";
      }
      subunitText += ' $subUnitName'; // Append the subunit name
    }

    // --- Combine Parts ---
    if (mainText.isNotEmpty && subunitText.isNotEmpty) {
      // If both parts exist, join them using the custom separator or a default space
      final separator =
          currencyInfo.separator; // Get separator from CurrencyInfo
      return separator != null
          ? '$mainText $separator $subunitText'
          : '$mainText $subunitText'; // Use separator or space
    } else if (mainText.isNotEmpty) {
      // Only main part exists
      return mainText;
    } else if (subunitText.isNotEmpty) {
      // Only subunit part exists (handles 0.xx cases)
      return subunitText;
    } else {
      // Value was zero or rounded to zero, and no subunits were generated
      // Re-check subunitText just in case (though redundant if logic above is sound)
      // Return "zero" + main unit name if truly zero.
      if (subunitText.isNotEmpty) {
        // Defensive check
        return subunitText;
      } else {
        return '$_zero $mainUnitName'; // e.g., "тэг төгрөг"
      }
    }
  }

  /// Converts a non-negative standard [Decimal] number to Mongolian words.
  ///
  /// Converts the integer part using [_convertInteger], respecting context for decimals.
  /// Converts the fractional part digit by digit (e.g., 0.45 -> "цэг дөрөв тав").
  /// Uses the decimal separator word specified in [MnOptions.decimalSeparator].
  ///
  /// @param absValue The absolute decimal value.
  /// @param options The [MnOptions] for formatting control (decimal separator).
  /// @param hasFollowingDecimalContext Pre-calculated flag indicating if a non-zero decimal part exists.
  /// @return The number formatted as Mongolian words.
  String _handleStandardNumber(
      Decimal absValue, MnOptions options, bool hasFollowingDecimalContext) {
    final BigInt integerPart = absValue.truncate().toBigInt();

    String integerWords = "";
    // Handle integer part
    if (integerPart == BigInt.zero) {
      // If integer is zero, only output "тэг" if a decimal part follows
      if (hasFollowingDecimalContext) {
        integerWords = _zero;
      } else {
        // If integer is zero and no decimal follows, the number is just zero
        return _zero;
      }
    } else {
      // Convert non-zero integer part, passing context flag
      integerWords = _convertInteger(integerPart,
          hasFollowingContext: hasFollowingDecimalContext);
    }

    // Handle fractional part
    String fractionalWords = '';
    if (hasFollowingDecimalContext) {
      // Only proceed if decimal part exists
      // Determine separator word ("цэг" or "таслал")
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _decimalCommaWord;
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period:
        default: // Default to point for Mongolian standard numbers
          separatorWord = _decimalPointWord;
          break;
      }

      // Get fractional digits string
      String originalFractional = absValue.toString().split('.').last;
      // Remove trailing zeros for standard reading (e.g., 1.50 -> 1.5)
      String speakableFractional =
          originalFractional.replaceAll(RegExp(r'0+$'), '');

      // Convert each remaining digit to its word form
      List<String> digitWords = speakableFractional
          .split('')
          .map((digit) {
            final int digitInt =
                int.tryParse(digit) ?? -1; // Parse digit safely
            if (digitInt == 0) return _zero; // Handle zero digit
            if (digitInt > 0 && digitInt < _units.length)
              return _units[digitInt]; // Use base unit words 1-9
            return ''; // Return empty for invalid characters
          })
          .where((s) =>
              s.isNotEmpty) // Filter out any empty strings from invalid parses
          .toList();

      // Combine separator and digit words if any digits were converted
      if (digitWords.isNotEmpty) {
        fractionalWords =
            ' $separatorWord ${digitWords.join(' ')}'; // e.g., " цэг дөрөв тав"
      }
    }

    // Combine integer and fractional parts
    return '$integerWords$fractionalWords'.trim();
  }
}
