import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/he_options.dart';
import '../utils/utils.dart';

/// Helper class to store intermediate results during integer conversion.
/// Holds the text representation of a scale chunk (e.g., "three hundred", "five thousand"),
/// its scale index (0=units, 1=thousands, 2=millions, etc.), and the numeric value of the chunk (0-999).
class _IntegerPart {
  final String text;
  final int scaleIndex;
  final int chunkValue;
  _IntegerPart(
      {required this.text, required this.scaleIndex, required this.chunkValue});
}

/// {@template num2text_he}
/// Converts numbers to Hebrew words (`Lang.HE`).
///
/// Implements [Num2TextBase] for Hebrew, handling various numeric types.
/// Supports cardinal numbers, decimals, negatives, currency, and years.
///
/// Key Hebrew Features Handled:
/// - **Gender:** Numbers 1-19 and higher scale counts agree in gender with the noun being counted (configurable via [HeOptions.gender]).
/// - **Construct State:** Uses construct forms for numbers preceding nouns (e.g., "shnei" for 2, "shloshet" for 3 before a masculine noun). Particularly relevant for currency and scales > 1.
/// - **Special Forms:** Handles unique forms like "me'a" (100), "matayim" (200), "elef" (1000), "alpayim" (2000).
/// - **Conjunctions:** Uses the Hebrew conjunction "ve" (ו) appropriately between number parts.
///
/// Customizable via [HeOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextHE implements Num2TextBase {
  // --- Constants ---

  // General
  static const String _zero = "אפס"; // Zero
  static const String _point = "נקודה"; // Decimal point "nekuda"
  static const String _comma = "פסיק"; // Decimal comma "psik"
  static const String _spacedAnd =
      " ו"; // Conjunction "ve" (and) with leading space

  // Hundreds
  static const String _hundred = "מאה"; // 100 (me'a) - Feminine
  static const String _twoHundred = "מאתיים"; // 200 (matayim) - Dual form
  static const String _hundredsPrefix =
      " מאות"; // Suffix for 300-900 (me'ot) - Plural

  // Thousands
  static const String _thousandSingular =
      "אלף"; // 1000 (elef) - Masculine singular
  static const String _thousandDual =
      "אלפיים"; // 2000 (alpayim) - Masculine dual
  static const String _thousandPlural =
      "אלפים"; // Suffix for 3000-10000 construct form (alafim)
  static const String _thousandScaleMarker =
      " אלף"; // Suffix for standard thousands > 2 (elef)

  // Construct state forms for 2
  static const String _twoMasculineConstruct =
      "שני"; // "shnei" (two - masc construct)
  static const String _twoFeminineConstruct =
      "שתי"; // "shtei" (two - fem construct)

  // Masculine units (1-9) - Standalone/Counted form
  static const List<String> _unitsMasculine = [
    "",
    "אחד",
    "שניים",
    "שלושה",
    "ארבעה",
    "חמישה",
    "שישה",
    "שבעה",
    "שמונה",
    "תשעה",
  ];

  // Feminine units (1-9) - Standalone/Counted form
  static const List<String> _unitsFeminine = [
    "", "אחת", "שתיים", "שלוש", "ארבע", "חמש", "שש", "שבע", "שמונֶה", "תשע",
    // Note: "שמונה" (shmoneh) is technically the base/feminine construct,
    // but seems intended here for standalone feminine based on tests. Masculine is "שמונה" (shmonah).
  ];

  // Masculine units (3-9) - Construct state (used before masculine nouns like 'alafim')
  static const List<String> _unitsMasculineConstruct = [
    "",
    "",
    "",
    "שלושת",
    "ארבעת",
    "חמשת",
    "ששת",
    "שבעת",
    "שמונת",
    "תשעת",
  ];

  // Construct state for 10 (masculine)
  static const String _tenMasculineConstruct = "עשרת"; // "aseret"

  // Base units (0-9) - Used for reading decimal digits (often uses feminine/base forms)
  static const List<String> _unitsBase = [
    "אפס",
    "אחד",
    "שתיים",
    "שלוש",
    "ארבע",
    "חמש",
    "שש",
    "שבע",
    "שמונה",
    "תשע",
  ];

  // Masculine tens (10-90)
  static const List<String> _tensMasculine = [
    "",
    "עשרה",
    "עשרים",
    "שלושים",
    "ארבעים",
    "חמישים",
    "שישים",
    "שבעים",
    "שמונים",
    "תשעים",
  ];

  // Feminine tens (10-90)
  static const List<String> _tensFeminine = [
    "",
    "עשר",
    "עשרים",
    "שלושים",
    "ארבעים",
    "חמישים",
    "שישים",
    "שבעים",
    "שמונים",
    "תשעים",
  ];

  // Masculine teens (10-19)
  static const List<String> _teensMasculine = [
    "עשרה",
    "אחד עשר",
    "שנים עשר",
    "שלושה עשר",
    "ארבעה עשר",
    "חמישה עשר",
    "שישה עשר",
    "שבעה עשר",
    "שמונה עשר",
    "תשעה עשר",
  ];

  // Feminine teens (10-19)
  static const List<String> _teensFeminine = [
    "עשר",
    "אחת עשרה",
    "שתים עשרה",
    "שלוש עשרה",
    "ארבע עשרה",
    "חמש עשרה",
    "שש עשרה",
    "שבע עשרה",
    "שמונה עשרה",
    "תשע עשרה",
  ];

  // Scale words (Short scale: Million, Billion, etc.) - Treated as Masculine nouns
  // Thousands (scale 1) are handled specially by _convertInteger.
  static const List<String> _scaleWords = [
    "", // 0: Units
    "", // 1: Thousands (handled specially)
    "מיליון", // 2: 10^6 Million
    "מיליארד", // 3: 10^9 Billion
    "טריליון", // 4: 10^12 Trillion
    "קוודריליון", // 5: 10^15 Quadrillion
    "קווינטיליון", // 6: 10^18 Quintillion
    "סקסטיליון", // 7: 10^21 Sextillion
    "ספטיליון", // 8: 10^24 Septillion
    // Add more if needed
  ];

  /// Processes the given [number] into Hebrew words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [HeOptions] for customization (currency, year format, gender, negative prefix, decimal separator).
  /// Defaults apply if [options] is null or not [HeOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity` ("אינסוף"), `NaN`. Returns [fallbackOnError] or "לא מספר" on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [HeOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Hebrew words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final HeOptions heOptions =
        options is HeOptions ? options : const HeOptions();
    final String errorFallback =
        fallbackOnError ?? "לא מספר"; // Default fallback "Not a number"

    // Handle special double values
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? "אינסוף שלילי"
            : "אינסוף"; // Negative/Positive Infinity
      }
      if (number.isNaN) {
        return errorFallback;
      }
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) {
      return errorFallback;
    }

    // Handle zero separately
    if (decimalValue == Decimal.zero) {
      if (heOptions.currency && heOptions.currencyInfo.mainUnitPlural != null) {
        // For currency, use plural unit name (e.g., "אפס שקלים")
        return "$_zero ${heOptions.currencyInfo.mainUnitPlural}";
      }
      return _zero; // Default "אפס"
    }

    // Determine sign and get absolute value for processing
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    // Dispatch to appropriate handler based on options
    String textResult;
    if (heOptions.format == Format.year) {
      textResult = _handleYearFormat(absValue.truncate().toBigInt(), heOptions);
    } else if (heOptions.currency) {
      textResult = _handleCurrency(absValue, heOptions);
    } else {
      textResult = _handleStandardNumber(absValue, heOptions);
    }

    // Prepend negative prefix if necessary
    if (isNegative) {
      textResult = "${heOptions.negativePrefix} $textResult";
    }

    // Return final result (trimming/space normalization happens within sub-functions)
    return textResult;
  }

  /// Converts a non-negative integer ([BigInt]) into Hebrew words.
  ///
  /// This is the core conversion logic, handling scales (thousands, millions, etc.)
  /// and applying Hebrew grammatical rules for gender and construct state.
  ///
  /// @param n The non-negative integer to convert.
  /// @param gender The grammatical gender ([Gender.masculine] or [Gender.feminine]) required for the number,
  ///               primarily affecting the 1-19 range in the units chunk (scale 0). Higher scale counts often default to masculine.
  /// @param useStandaloneForm Determines if standalone forms like "alpayim" (2000) should be used. Often true for simple numbers, false within currency.
  /// @param useConstructForms Determines if construct forms like "shloshet alafim" (3000) should be used. Relevant for scales.
  /// @return The integer as Hebrew words, or an empty string if n is zero.
  String _convertInteger(
      BigInt n, Gender gender, bool useStandaloneForm, bool useConstructForms) {
    if (n == BigInt.zero) {
      // Zero is handled by the caller or results in empty string within larger numbers.
      return "";
    }
    if (n < BigInt.from(1000)) {
      // Delegate numbers 0-999 to _convertChunk.
      // The requested gender and construct state apply directly here.
      // Pass useConstructFormForTwo based on useStandaloneForm (inverting logic?)
      return _convertChunk(
          n.toInt(), gender, !useStandaloneForm, useConstructForms);
    }

    // --- Chunking Logic ---
    // Break the number into chunks of 1000 (units, thousands, millions...).
    // Process chunks from lowest scale (units) to highest, storing results in `parts`.
    List<_IntegerPart> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0;
    BigInt remaining = n;

    // This loop seems redundant or potentially incorrect for calculating initial scale index?
    // It modifies initialN but doesn't use the result directly for scaleIndex.
    BigInt initialN = n;
    while (initialN > BigInt.zero) {
      BigInt tempRemaining = initialN ~/ oneThousand;
      initialN = tempRemaining;
    }

    // Reset scaleIndex and remaining to process the number chunk by chunk
    scaleIndex = 0;
    remaining = n;

    while (remaining > BigInt.zero) {
      int currentScaleIndex = scaleIndex;
      BigInt chunkBigInt = remaining % oneThousand;
      int chunk = chunkBigInt.toInt(); // The value of the current chunk (0-999)
      BigInt currentRemaining =
          remaining ~/ oneThousand; // Renamed from original for clarity

      if (chunk > 0) {
        // Only process non-zero chunks
        String chunkText = "";
        // Determine the gender for the *number* counting this scale.
        // Hebrew grammar rules:
        // - The units chunk (0-999) uses the explicitly requested `gender`.
        // - Thousands count (scale 1) is inherently masculine (אלף, אלפיים, X אלפים).
        // - Higher scales (million+) are treated as masculine nouns, so their counts use masculine forms (שני מיליון, שלושה מיליון).
        Gender numberPartGender = Gender.masculine; // Default to masculine
        if (currentScaleIndex == 0) {
          // Only the units chunk (0-999) respects the overall requested gender.
          numberPartGender = gender;
        }
        // Construct forms (3k-10k) and higher scales (million+) are treated as masculine counts.

        // Convert the chunk based on its scale index
        if (currentScaleIndex == 0) {
          // Units chunk (0-999): Use requested gender. Construct forms rarely relevant here.
          // Pass false for construct forms as they are handled by specific scale logic below.
          chunkText = _convertChunk(chunk, numberPartGender, false, false);
        } else if (currentScaleIndex == 1) {
          // Thousands chunk (scale index 1)
          if (chunk == 1) {
            chunkText = _thousandSingular; // "אלף" (1000)
          } else if (chunk == 2 &&
              currentRemaining == BigInt.zero &&
              useStandaloneForm) {
            // Use "alpayim" only if it's exactly 2000 and standalone form is requested.
            chunkText = _thousandDual; // "אלפיים" (2000)
          } else if (chunk >= 3 && chunk <= 10 && useConstructForms) {
            // Use construct form for 3000-10000 if requested (e.g., "shloshet alafim")
            // Check specifically for 10 to use "aseret" construct.
            chunkText =
                "${chunk == 10 ? _tenMasculineConstruct : _unitsMasculineConstruct[chunk]} $_thousandPlural";
          } else {
            // Regular thousands (e.g., 2000 within larger number, 11000, 25000 etc.)
            // The number counting the thousands MUST be masculine.
            bool useStandaloneTwo = chunk == 2; // Use "shnayim" if chunk is 2
            // Force Masculine gender for the number part counting thousands.
            String baseChunkText =
                _convertChunk(chunk, Gender.masculine, useStandaloneTwo, false);
            chunkText = baseChunkText +
                _thousandScaleMarker; // Append " אלף" (e.g., שניים אלף, עשרים וחמישה אלף)
          }
        } else if (currentScaleIndex < _scaleWords.length) {
          // Millions and higher scales
          String scaleWord = _scaleWords[currentScaleIndex]; // e.g., "מיליון"
          if (chunk == 1) {
            chunkText = scaleWord; // e.g., "מיליון" (no explicit "one")
          } else if (chunk == 2) {
            // Use masculine construct "shnei" for 2 million, etc.
            chunkText =
                "$_twoMasculineConstruct $scaleWord"; // e.g., "שני מיליון"
          } else {
            // Use masculine number count for 3+ million, etc.
            // Force masculine gender for the number part counting the scale.
            String baseChunkText =
                _convertChunk(chunk, Gender.masculine, false, false);
            chunkText = "$baseChunkText $scaleWord"; // e.g., "שלושה מיליון"
          }
        } else {
          // Fallback for scales beyond implemented words (should ideally throw or log)
          // Use masculine count for safety.
          String chunkNumText =
              _convertChunk(chunk, Gender.masculine, false, false);
          chunkText = '$chunkNumText [Scale $currentScaleIndex]'; // Placeholder
        }
        // Store the processed chunk text and its info
        parts.add(_IntegerPart(
            text: chunkText, scaleIndex: currentScaleIndex, chunkValue: chunk));
      }
      // Move to the next higher scale
      remaining = currentRemaining;
      scaleIndex++;
    }

    // --- Joining Logic ---
    // Combine the processed parts from highest scale down, adding conjunctions ("ve") correctly.
    StringBuffer result = StringBuffer();
    for (int i = parts.length - 1; i >= 0; i--) {
      _IntegerPart currentPart = parts[i];
      result.write(currentPart.text); // Add the text for the current scale

      // Determine if a connector ("ve" or space) is needed before the *next* (lower scale) part.
      if (i > 0) {
        _IntegerPart nextPart =
            parts[i - 1]; // The next part to be added (lower scale)
        bool addVe = true; // Default assumption: add "ve"

        // *** ORIGINAL Rule from user code: Only omit 've' after singular 'אלף' (1000) when followed by hundreds ***
        // This rule seems to be the one passing the tests.
        bool isSingularThousand = currentPart.scaleIndex == 1 &&
            currentPart.chunkValue == 1; // Is current part "אלף"?
        bool nextChunkIsUnitsScale =
            nextPart.scaleIndex == 0; // Is next part the 0-999 chunk?
        // Check if the next chunk's value is purely hundreds (100-999)
        bool nextChunkIsHundreds = nextChunkIsUnitsScale &&
            nextPart.chunkValue >= 100 &&
            nextPart.chunkValue < 1000;

        if (isSingularThousand && nextChunkIsHundreds) {
          // If current is "אלף" and next is 100-999, omit "ve".
          // Examples matching tests:
          // 1110: "אלף" (current) + "מאה ועשרה" (next) -> no "ve" -> "אלף מאה ועשרה"
          // 1999: "אלף" (current) + "תשע מאות..." (next) -> no "ve" -> "אלף תשע מאות..."
          addVe = false;
        }
        // Otherwise (e.g., after "alpayim", after "million", or before units/tens only), add "ve".

        result.write(addVe
            ? _spacedAnd
            : " "); // Add "ve" or just a space based on the rule
      }
    }
    // Final cleanup: trim and ensure single spaces
    return result.toString().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Converts an integer between 0 and 999 into Hebrew words.
  ///
  /// Handles hundreds, tens, and units according to the specified gender.
  /// Also handles construct state for the number 2 if requested.
  ///
  /// @param n The integer chunk (0-999).
  /// @param gender The grammatical gender for units/tens/teens.
  /// @param useConstructFormForTwo If true, uses "shnei"/"shtei" for 2 instead of "shnayim"/"shtayim".
  /// @param useConstructFormsFor3To10 This parameter seems unused in the current logic.
  /// @return The chunk as Hebrew words, or empty string if n is 0. Returns error string if n is out of range.
  String _convertChunk(int n, Gender gender, bool useConstructFormForTwo,
      bool useConstructFormsFor3To10 /* unused */) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) {
      // Should not happen if called correctly, but provides safety.
      return "[Error: Chunk $n out of range]";
    }

    int remainder = n;
    // Select the correct gendered arrays for units, tens, teens
    final units = gender == Gender.feminine ? _unitsFeminine : _unitsMasculine;
    final tens = gender == Gender.feminine ? _tensFeminine : _tensMasculine;
    final teens = gender == Gender.feminine ? _teensFeminine : _teensMasculine;

    String hundredsPart = "";
    // Flag to control adding "ve" after hundreds.
    // "ve" is added after 100 ("me'a") and 200 ("matayim") if tens/units follow.
    // "ve" is *not* automatically added after 300-900 ("X me'ot").
    bool addVeAfterHundreds = false;

    // Handle hundreds part (100-900)
    if (remainder >= 100) {
      int hundredDigit = remainder ~/ 100;
      if (hundredDigit == 1) {
        hundredsPart = _hundred; // "מאה"
        addVeAfterHundreds = true; // Add 've' after מאה if tens/units follow
      } else if (hundredDigit == 2) {
        hundredsPart = _twoHundred; // "מאתיים"
        addVeAfterHundreds = true; // Add 've' after מאתיים if tens/units follow
      } else {
        // 300-900: Use Feminine base unit + "me'ot" (e.g., "shalosh me'ot")
        // Note: Hebrew uses feminine form to count the feminine noun "me'ot" (hundreds).
        // Special case for 8: use base form "shmoneh".
        String digitWord =
            (hundredDigit == 8) ? _unitsBase[8] : _unitsFeminine[hundredDigit];
        hundredsPart = digitWord + _hundredsPrefix; // e.g., "שלוש מאות"
        addVeAfterHundreds = false; // NO automatic 've' after X מאות (X>=3)
      }
      remainder %= 100; // Get the remaining tens/units part
    }

    // Handle tens and units part (1-99)
    String tensUnitsPart = "";
    if (remainder > 0) {
      if (remainder < 10) {
        // Units 1-9
        if (remainder == 2 && useConstructFormForTwo) {
          // Use construct "shnei"/"shtei" if requested
          tensUnitsPart = (gender == Gender.feminine)
              ? _twoFeminineConstruct
              : _twoMasculineConstruct;
        } else {
          tensUnitsPart = units[remainder]; // Use standard unit word
        }
      } else if (remainder < 20) {
        // Teens 10-19
        tensUnitsPart = teens[remainder - 10]; // Index is value - 10
      } else {
        // Tens 20-99
        int tensDigit = remainder ~/ 10;
        int unitDigit = remainder % 10;
        tensUnitsPart = tens[tensDigit]; // Get the tens word (e.g., "esrim")
        if (unitDigit > 0) {
          // If there's a unit digit, add "ve" and the unit word
          String unitWord;
          // Use construct form for unit 2 if requested *within tens*
          if (unitDigit == 2 && useConstructFormForTwo) {
            unitWord = (gender == Gender.feminine)
                ? _twoFeminineConstruct
                : _twoMasculineConstruct;
          } else {
            unitWord = units[unitDigit]; // Use standard unit word
          }
          tensUnitsPart += _spacedAnd + unitWord; // e.g., "עשרים וחמש"
        }
      }
    }

    // Combine hundreds and tens/units parts
    if (hundredsPart.isNotEmpty && tensUnitsPart.isNotEmpty) {
      // Determine connector: use "ve" only if flag is set (for 100, 200), otherwise use space.
      String connector = addVeAfterHundreds ? _spacedAnd : " ";
      return hundredsPart + connector + tensUnitsPart;
    } else {
      // If either part is empty, just return the non-empty part.
      return hundredsPart.isNotEmpty ? hundredsPart : tensUnitsPart;
    }
  }

  /// Handles formatting a number as a calendar year in Hebrew.
  ///
  /// Typically, years are read as standard masculine numbers.
  /// Uses standalone forms (like "alpayim" for 2000) and avoids construct forms for 3k-10k.
  /// Example: 1984 -> "elef תשע מאות שמונים וארבע" (literally "thousand nine hundred eighty and four") - Masculine assumed
  /// Example: 2023 -> "alpayim esrim ve-shalosh" (standalone 2000 + masculine 23)
  ///
  /// @param absValue The absolute (non-negative) year value.
  /// @param options The [HeOptions] (gender is usually ignored/defaults to masculine).
  /// @return The year formatted as Hebrew words.
  String _handleYearFormat(BigInt absValue, HeOptions options) {
    // Years typically use masculine, standalone forms, and no construct for 3k-10k range.
    return _convertInteger(absValue, Gender.masculine, true, false);
  }

  /// Converts a non-negative [Decimal] value to Hebrew currency words.
  ///
  /// **Note:** This function contains the original logic provided, which may
  /// have issues leading to test failures (e.g., duplication of subunit parts).
  /// The comments describe the *intended* behavior based on the code structure.
  ///
  /// Uses [HeOptions.currencyInfo] for unit names (e.g., שקל/שקלים, אגורה/אגורות).
  /// Attempts to apply Hebrew grammar:
  /// - Main unit count often uses masculine forms (שני שקלים, שלושה שקלים).
  /// - Subunit count often uses feminine forms (חמש אגורות, עשרים אגורות).
  /// - Handles special cases for 1 and 2 (e.g., "שקל אחד", "שני שקלים").
  /// Rounds if [HeOptions.round] is true.
  ///
  /// @param absValue Absolute currency value.
  /// @param options The [HeOptions] with currency info and formatting flags.
  /// @return Currency value as Hebrew words (potentially incorrect due to original logic).
  String _handleCurrency(Decimal absValue, HeOptions options) {
    // --- Setup ---
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    final int decimalPlaces = 2;
    final Decimal subunitMultiplier =
        Decimal.ten.pow(decimalPlaces).toDecimal();

    // Round if requested
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main and subunit values
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Use truncate for subunits (e.g., 1.999 should be 99 subunits, not 100)
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).truncate().toBigInt();

    // --- Process Main Part ---
    String mainText = ""; // Number words for main value
    String mainUnitName = ""; // Unit name (singular/plural)
    bool mainValueProcessed =
        false; // Flag to track if main value part was generated

    if (mainValue > BigInt.zero) {
      mainValueProcessed = true; // Mark that we have a main value
      // Special handling for 1 and 2
      if (mainValue == BigInt.one) {
        // For 1, typically just the singular unit name. "echad" added later.
        mainText = ""; // No number word needed here
        mainUnitName = currencyInfo.mainUnitSingular;
      } else if (mainValue == BigInt.from(2)) {
        // For 2, use masculine construct "shnei" + plural unit name (e.g., "שני שקלים")
        mainText = _twoMasculineConstruct; // "שני"
        mainUnitName =
            currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;
      } else {
        // For 3+, use masculine count + plural unit name (e.g., "שלושה שקלים")
        mainText = _convertInteger(mainValue, Gender.masculine, false, true);
        mainUnitName =
            currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;
      }
    }

    // Combine the main number text and unit name - THIS INITIALIZES `result`
    // `result` now holds the beginning of the main part (or just the unit name if mainValue is 1)
    String result = (mainText.isNotEmpty ? "$mainText " : "") + mainUnitName;

    // Special handling for main value 1: append "אחד" after the singular unit name
    if (mainValue == BigInt.one) {
      result += " ${_unitsMasculine[1]}"; // Appends " אחד" to `result`
    }

    // --- Process Subunit Part ---
    String subunitPart =
        ""; // This variable will hold the fully constructed subunit part string

    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      String subunitText = ""; // Number words for subunit value
      String subUnitName = ""; // Subunit name (singular/plural)

      // Special handling for 1 and 2
      if (subunitValue == BigInt.one) {
        // For 1, typically just the singular unit name. "achat" added later.
        subunitText = ""; // No number word needed here
        subUnitName = currencyInfo.subUnitSingular!;
      } else if (subunitValue == BigInt.from(2)) {
        // For 2, use feminine construct "shtei" + plural unit name (e.g., "שתי אגורות")
        subunitText = _twoFeminineConstruct; // "שתי"
        subUnitName =
            currencyInfo.subUnitPlural ?? currencyInfo.subUnitSingular!;
      } else {
        // For 3+, use feminine count + plural unit name (e.g., "חמש אגורות")
        subunitText =
            _convertInteger(subunitValue, Gender.feminine, false, false);
        subUnitName =
            currencyInfo.subUnitPlural ?? currencyInfo.subUnitSingular!;
      }

      // Combine the subunit number text and unit name into `subunitPart`
      subunitPart =
          (subunitText.isNotEmpty ? "$subunitText " : "") + subUnitName;

      // Special handling for subunit value 1: append "אחת" after the singular subunit name
      if (subunitValue == BigInt.one) {
        subunitPart +=
            " ${_unitsFeminine[1]}"; // Appends " אחת" to `subunitPart`
      }
    }

    // --- Combine Main and Subunit Parts --- (Original Potentially Flawed Logic)
    if (mainValueProcessed && subunitPart.isNotEmpty) {
      // *** ORIGINAL LOGIC ***
      // If both parts exist, this appends the separator and the *entire* subunitPart
      // onto the `result` string, which already contains the main part.
      // This likely causes the duplication seen in the test failure.
      // It does not check for custom separators defined in CurrencyInfo.
      result += _spacedAnd + subunitPart;
    } else if (!mainValueProcessed && subunitPart.isNotEmpty) {
      // If only subunit part exists (e.g., 0.50)
      // This assignment correctly sets `result` to the subunit part.
      result = subunitPart;
    } else if (mainValue == BigInt.zero && subunitValue == BigInt.zero) {
      // Handle case where input was 0 or rounded to 0 - Returns here.
      return "$_zero ${currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular}";
    }

    // Defensive check (from original code) - unclear if truly necessary with logic above
    if (result.trim().isEmpty &&
        mainValue == BigInt.zero &&
        subunitValue == BigInt.zero) {
      return "$_zero ${currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular}";
    }

    return result.trim(); // Trim final result
  }

  /// Converts a non-negative standard [Decimal] number to Hebrew words.
  ///
  /// Converts the integer part using [_convertInteger] respecting [HeOptions.gender].
  /// Converts the fractional part digit by digit using base forms (e.g., 0.45 -> "נקודה ארבע חמש").
  /// Uses the decimal separator word specified in [HeOptions.decimalSeparator].
  ///
  /// @param absValue The absolute decimal value.
  /// @param options The [HeOptions] for formatting control (gender, decimal separator).
  /// @return The number formatted as Hebrew words.
  String _handleStandardNumber(Decimal absValue, HeOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part, respecting gender. Use standalone and construct forms as appropriate for standard numbers.
    // Use "אפס" if integer is 0 but a fraction exists.
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, options.gender, true, true);

    String fractionalWords = '';
    // Convert fractional part if it exists
    if (fractionalPart > Decimal.zero) {
      // Determine separator word ("נקודה" or "פסיק")
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _comma;
          break;
        case DecimalSeparator.period:
        case DecimalSeparator.point:
        default:
          separatorWord = _point;
          break;
      }

      // Get fractional digits string, trim trailing zeros for standard representation (e.g., 1.50 -> 1.5)
      String fractionalDigits = absValue.toString().split('.').last;
      while (fractionalDigits.endsWith('0') && fractionalDigits.length > 1) {
        fractionalDigits =
            fractionalDigits.substring(0, fractionalDigits.length - 1);
      }

      // Convert each digit to its base word form
      if (fractionalDigits.isNotEmpty) {
        List<String> digitWords = fractionalDigits
            .split('')
            .map((digit) =>
                _unitsBase[int.parse(digit)]) // Use _unitsBase for digits 0-9
            .toList();
        fractionalWords =
            ' $separatorWord ${digitWords.join(' ')}'; // e.g., " נקודה ארבע חמש"
      }
    }

    // Ensure integerWords is "אפס" if integer part was zero initially but fraction exists
    // (This check might be redundant if the initial assignment handled it, but safe to keep)
    if (integerPart == BigInt.zero &&
        integerWords.isEmpty &&
        fractionalWords.isNotEmpty) {
      integerWords = _zero;
    }

    // Combine integer and fractional parts
    return '$integerWords$fractionalWords'.trim();
  }
}
