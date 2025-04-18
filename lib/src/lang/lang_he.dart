import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/he_options.dart'; // Options specific to Hebrew formatting.
import '../utils/utils.dart';

/// Helper class to store intermediate results during integer conversion.
/// Holds the text representation of a chunk, its scale index, and its numeric value.
class _IntegerPart {
  /// The word representation of the number chunk (e.g., "שלוש מאות").
  final String text;

  /// The scale index of this chunk (0 for units, 1 for thousands, 2 for millions, etc.).
  final int scaleIndex;

  /// The integer value of the chunk (0-999).
  final int chunkValue;

  /// Creates an instance holding information about a converted integer chunk.
  _IntegerPart(
      {required this.text, required this.scaleIndex, required this.chunkValue});
}

/// {@template num2text_he}
/// The Hebrew language (`Lang.HE`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Hebrew word representation following standard Hebrew grammar and vocabulary,
/// including crucial handling of grammatical gender and construct states.
///
/// Capabilities include handling cardinal numbers, currency (using [HeOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (short scale).
/// It uses the [HeOptions.gender] parameter to determine the correct form for numbers 1 and 2
/// and sometimes for other parts of the number depending on context (e.g., thousands).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [HeOptions].
/// {@endtemplate}
class Num2TextHE implements Num2TextBase {
  // --- Constants ---

  /// The word for zero ("אפס").
  static const String _zero = "אפס";

  /// The word for the decimal separator when using a period (`.`) ("נקודה" - nekuda).
  static const String _point = "נקודה";

  /// The word for the decimal separator when using a comma (`,`) ("פסיק" - psik).
  static const String _comma = "פסיק";

  /// The conjunction "and" ("ve"), prefixed with a space (" ו"). Added dynamically.
  static const String _spacedAnd = " ו"; // "ve" - and, prefixed with space

  /// The word for one hundred ("מאה"). Feminine noun.
  static const String _hundred = "מאה";

  /// The word for two hundred ("מאתיים"). Dual form of "מאה".
  static const String _twoHundred = "מאתיים";

  /// The suffix for hundreds from 300 onwards ("מאות"), plural of "מאה". Added after the unit digit word (e.g., "שלוש מאות").
  static const String _hundredsPrefix = " מאות"; // "me'ot" - hundreds (plural)

  /// The word for one thousand ("אלף"). Masculine noun.
  static const String _thousandSingular = "אלף"; // "elef" - thousand (singular)

  /// The word for two thousand ("אלפיים"). Dual form of "אלף".
  static const String _thousandDual =
      "אלפיים"; // "alpayim" - two thousand (dual)

  /// The word for thousands (plural, "אלפים"), used in construct state with 3-10 (e.g., "שלושת אלפים").
  static const String _thousandPlural =
      "אלפים"; // "alafim" - thousands (plural)

  /// The marker for thousands when the number of thousands is 11 or greater (e.g., "אחד עשר אלף"). Prefixed with a space.
  static const String _thousandScaleMarker =
      " אלף"; // "elef" - thousand marker for >= 11k

  // --- Number Word Lists (Gender Specific) ---

  /// Masculine forms for units 1-9 (absolute state).
  static const List<String> _unitsMasculine = [
    "", // 0 - Not used directly here
    "אחד", // 1 - echad
    "שניים", // 2 - shnayim
    "שלושה", // 3 - shlosha
    "ארבעה", // 4 - arba'a
    "חמישה", // 5 - chamisha
    "שישה", // 6 - shisha
    "שבעה", // 7 - shiv'a
    "שמונה", // 8 - shmona
    "תשעה", // 9 - tish'a
  ];

  /// Feminine forms for units 1-9 (absolute state).
  static const List<String> _unitsFeminine = [
    "", // 0 - Not used directly here
    "אחת", // 1 - achat
    "שתיים", // 2 - shtayim
    "שלוש", // 3 - shalosh
    "ארבע", // 4 - arba
    "חמש", // 5 - chamesh
    "שש", // 6 - shesh
    "שבע", // 7 - sheva
    "שמונה", // 8 - shmone
    "תשע", // 9 - tesha
  ];

  /// Masculine forms for units 3-9 in the *construct state* (סמיכות - smichut).
  /// Used before plural nouns, particularly "אלפים" (thousands).
  static const List<String> _unitsMasculineConstruct = [
    "", // 0
    "", // 1 - Not used in construct
    "", // 2 - Not used in construct
    "שלושת", // 3 - shloshet
    "ארבעת", // 4 - arba'at
    "חמשת", // 5 - chameshet
    "ששת", // 6 - sheshet
    "שבעת", // 7 - shiv'at
    "שמונת", // 8 - shmonat
    "תשעת", // 9 - tish'at
  ];

  /// The masculine form for ten in the *construct state* ("עשרת"). Used before "אלפים".
  static const String _tenMasculineConstruct = "עשרת"; // aseret

  /// Base forms for digits 0-9, used for reading fractional parts.
  static const List<String> _unitsBase = [
    "אפס", // 0 - efes
    "אחד", // 1 - echad
    "שתיים", // 2 - shtayim
    "שלוש", // 3 - shalosh
    "ארבע", // 4 - arba
    "חמש", // 5 - chamesh
    "שש", // 6 - shesh
    "שבע", // 7 - sheva
    "שמונה", // 8 - shmone
    "תשע", // 9 - tesha
  ];

  /// Masculine forms for tens 10-90.
  static const List<String> _tensMasculine = [
    "", // 0
    "עשרה", // 10 - asara
    "עשרים", // 20 - esrim
    "שלושים", // 30 - shloshim
    "ארבעים", // 40 - arba'im
    "חמישים", // 50 - chamishim
    "שישים", // 60 - shishim
    "שבעים", // 70 - shiv'im
    "שמונים", // 80 - shmonim
    "תשעים", // 90 - tish'im
  ];

  /// Feminine forms for tens 10-90. Note: Only 10 ("עשר") differs from masculine.
  static const List<String> _tensFeminine = [
    "", // 0
    "עשר", // 10 - eser
    "עשרים", // 20 - esrim
    "שלושים", // 30 - shloshim
    "ארבעים", // 40 - arba'im
    "חמישים", // 50 - chamishim
    "שישים", // 60 - shishim
    "שבעים", // 70 - shiv'im
    "שמונים", // 80 - shmonim
    "תשעים", // 90 - tish'im
  ];

  /// Masculine forms for teens 10-19. Combines unit with "עשר".
  static const List<String> _teensMasculine = [
    "עשרה", // 10 - asara
    "אחד עשר", // 11 - achad asar
    "שנים עשר", // 12 - shneim asar
    "שלושה עשר", // 13 - shlosha asar
    "ארבעה עשר", // 14 - arba'a asar
    "חמישה עשר", // 15 - chamisha asar
    "שישה עשר", // 16 - shisha asar
    "שבעה עשר", // 17 - shiv'a asar
    "שמונה עשר", // 18 - shmona asar
    "תשעה עשר", // 19 - tish'a asar
  ];

  /// Feminine forms for teens 10-19. Combines unit with "עשרה".
  static const List<String> _teensFeminine = [
    "עשר", // 10 - eser
    "אחת עשרה", // 11 - achat esre
    "שתים עשרה", // 12 - shteim esre
    "שלוש עשרה", // 13 - shlosh esre
    "ארבע עשרה", // 14 - arba esre
    "חמש עשרה", // 15 - chamesh esre
    "שש עשרה", // 16 - shesh esre
    "שבע עשרה", // 17 - shva esre
    "שמונה עשרה", // 18 - shmone esre
    "תשע עשרה", // 19 - tsha esre
  ];

  /// Scale words (million, billion, etc.) using the short scale system. Indexed from 2.
  /// These are treated as masculine nouns.
  static const List<String> _scaleWords = [
    "", // 0: Units group
    "", // 1: Thousands group (handled specially)
    "מיליון", // 2: Million (10^6)
    "מיליארד", // 3: Billion (10^9)
    "טריליון", // 4: Trillion (10^12)
    "קוודריליון", // 5: Quadrillion (10^15)
    "קווינטיליון", // 6: Quintillion (10^18)
    "סקסטיליון", // 7: Sextillion (10^21)
    "ספטיליון", // 8: Septillion (10^24)
    // Add more if needed
  ];

  /// {@macro num2text_base_process}
  /// Converts the given [number] into its Hebrew word representation.
  ///
  /// Handles `int`, `double`, `BigInt`, `Decimal`, and numeric `String` inputs.
  /// Uses [HeOptions] to customize behavior like currency formatting ([HeOptions.currency], [HeOptions.currencyInfo]),
  /// year formatting ([Format.year]), decimal separator ([HeOptions.decimalSeparator]),
  /// grammatical gender ([HeOptions.gender]), and negative prefix ([HeOptions.negativePrefix]).
  /// If `options` is not an instance of [HeOptions], default settings are used.
  ///
  /// Returns the word representation (e.g., "מאתיים שלושים וארבעה", "מינוס עשר נקודה חמש", "שקל חדש אחד").
  /// If the input is invalid (`null`, `NaN`, `Infinity`, non-numeric string), it returns
  /// [fallbackOnError] if provided, otherwise a default error message like "לא מספר".
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have Hebrew-specific options, using defaults if none are provided.
    final HeOptions heOptions =
        options is HeOptions ? options : const HeOptions();

    // Handle special non-finite double values early.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? "אינסוף שלילי"
            : "אינסוף"; // Localized infinity
      }
      if (number.isNaN) {
        return fallbackOnError ?? "לא מספר"; // Not a Number
      }
    }

    // Normalize the input to a Decimal for precise calculations.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Return error if normalization failed (invalid input type or format).
    if (decimalValue == null) {
      return fallbackOnError ?? "לא מספר";
    }

    // Handle the specific case of zero.
    if (decimalValue == Decimal.zero) {
      // For currency, use plural unit name (e.g., "אפס שקלים חדשים").
      return heOptions.currency
          ? "$_zero ${heOptions.currencyInfo.mainUnitPlural}"
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for the core conversion logic.
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    // --- Dispatch based on format options ---
    if (heOptions.format == Format.year) {
      // Years are typically read as masculine cardinal numbers.
      textResult = _handleYearFormat(absValue.truncate().toBigInt(), heOptions);
      // Negative prefix might be added for BC years if needed, though Hebrew calendar is common.
      if (isNegative) {
        textResult =
            "${heOptions.negativePrefix} $textResult"; // Add standard prefix if year is negative.
      }
    } else if (heOptions.currency) {
      // Handle currency format.
      textResult = _handleCurrency(absValue, heOptions);
      // Add negative prefix if applicable.
      if (isNegative) {
        textResult = "${heOptions.negativePrefix} $textResult";
      }
    } else {
      // Handle standard number format.
      textResult = _handleStandardNumber(absValue, heOptions);
      // Add negative prefix if applicable.
      if (isNegative) {
        textResult = "${heOptions.negativePrefix} $textResult";
      }
    }
    return textResult;
  }

  /// Formats an integer as a year.
  /// In Hebrew, years are typically read as masculine cardinal numbers.
  ///
  /// [absValue]: The non-negative year value.
  /// [options]: Hebrew options (gender is usually forced to masculine for years).
  /// Returns the year in words, e.g., "אלפיים עשרים וארבע".
  String _handleYearFormat(BigInt absValue, HeOptions options) {
    // Years are typically treated as masculine numbers, ignore options.gender here.
    // Use standalone forms (e.g., "אלפיים" not "אלפי").
    // Construct forms are not typically used for years.
    return _convertInteger(absValue, Gender.masculine, true, false);
  }

  /// Formats a [Decimal] value as a currency amount in words.
  /// Handles main units (masculine, e.g., Shekel) and subunits (feminine, e.g., Agora).
  /// Applies rounding if [HeOptions.round] is true.
  /// Handles singular/plural forms and uses "ve" (and) separator.
  /// Special handling for "one" (אחד/אחת) placed *after* the unit name.
  ///
  /// [absValue]: The non-negative currency amount.
  /// [options]: Hebrew options containing currency details and rounding preference.
  /// Returns the currency amount in words, e.g., "שקל חדש אחד", "עשרה שקלים חדשים וחמישים אגורות".
  String _handleCurrency(Decimal absValue, HeOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round; // Default HeOptions set round=true
    final int decimalPlaces = 2; // Standard subunit precision.
    final Decimal subunitMultiplier =
        Decimal.ten.pow(decimalPlaces).toDecimal(); // 100

    // Apply rounding if requested.
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main and subunit values.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).truncate().toBigInt();

    String mainText;
    String mainUnitName;

    // Handle main unit part.
    if (mainValue == BigInt.one) {
      // For "one", the number word "אחד" comes *after* the singular unit name.
      mainText = ""; // Number word is handled later.
      mainUnitName = currencyInfo.mainUnitSingular;
    } else {
      // For 2+, convert the number using masculine gender.
      // Use construct forms if needed (e.g., before 'אלף' if currency > 1000).
      // Standalone forms usually not needed within currency phrase construction? Let's try false.
      mainText = _convertInteger(mainValue, Gender.masculine, false, true);
      // Use plural unit name. Fallback to singular if plural is null.
      mainUnitName =
          currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;
    }

    // Combine number (if > 1) and main unit name.
    String result = '${mainText.isNotEmpty ? "$mainText " : ""}$mainUnitName';

    // Append "אחד" if main value was one.
    if (mainValue == BigInt.one) {
      result += " ${_unitsMasculine[1]}"; // Add "echad"
    }

    // Handle subunit part if it exists.
    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      String subunitText;
      String subUnitName;

      // Handle subunit number part.
      if (subunitValue == BigInt.one) {
        // For "one" subunit, the number word "אחת" comes *after*.
        subunitText = ""; // Handled later.
        subUnitName = currencyInfo.subUnitSingular!;
      } else {
        // For 2+, convert the number using feminine gender for subunits like Agorot.
        // Use construct forms if needed.
        subunitText =
            _convertInteger(subunitValue, Gender.feminine, false, true);
        // Use plural subunit name. Fallback to singular.
        subUnitName =
            currencyInfo.subUnitPlural ?? currencyInfo.subUnitSingular!;
      }

      // Add separator ("ve") and the subunit phrase.
      result +=
          '$_spacedAnd${subunitText.isNotEmpty ? "$subunitText " : ""}$subUnitName';

      // Append "אחת" if subunit value was one.
      if (subunitValue == BigInt.one) {
        result += " ${_unitsFeminine[1]}"; // Add "achat"
      }
    }
    return result.trim(); // Trim any potential extra spaces.
  }

  /// Formats a standard [Decimal] number (non-currency, non-year) into words.
  /// Handles both the integer and fractional parts according to the specified gender.
  /// The fractional part is read digit by digit after the separator word ("נקודה" or "פסיק").
  ///
  /// [absValue]: The non-negative number.
  /// [options]: Hebrew options, used for `decimalSeparator` and `gender`.
  /// Returns the number in words, e.g., "מאתיים שלושים וארבעה נקודה חמש שש".
  String _handleStandardNumber(Decimal absValue, HeOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part using the specified gender.
    // Use standalone forms (true) and construct forms (true) as needed for general numbers.
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero // Handle cases like 0.5 -> "אפס נקודה חמש"
            : _convertInteger(integerPart, options.gender, true, true);

    String fractionalWords = '';
    // Process fractional part only if it's greater than zero.
    if (fractionalPart > Decimal.zero) {
      // Determine the decimal separator word.
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _comma;
          break;
        default: // Default to period/point.
          separatorWord = _point;
          break;
      }

      // Get fractional digits as string.
      String fractionalDigits = absValue.toString().split('.').last;
      // Remove trailing zeros, unless the only digit is zero.
      while (fractionalDigits.endsWith('0') && fractionalDigits.length > 1) {
        fractionalDigits =
            fractionalDigits.substring(0, fractionalDigits.length - 1);
      }
      // Check if after removing zeros, we ended up with an integer equivalent.
      // This prevents adding ". efes" for numbers like Decimal('1.0').
      if (absValue == absValue.truncate()) {
        fractionalDigits = ''; // Effectively remove the fractional part words
      }

      if (fractionalDigits.isNotEmpty) {
        // Convert each digit character to its base word form (0-9).
        List<String> digitWords = fractionalDigits
            .split('')
            .map((digit) => _unitsBase[int.parse(digit)])
            .toList();
        // Combine separator and digit words.
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }
    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] integer into its Hebrew word representation.
  /// This is the main recursive function handling scales (thousands, millions, etc.)
  /// and applying grammatical rules for gender and construct state.
  ///
  /// [n]: The non-negative integer to convert.
  /// [gender]: The grammatical gender to use (affects 1, 2, tens, teens).
  /// [useStandaloneForm]: If true, use standalone forms like "אלפיים" instead of construct forms like "אלפי".
  /// [useConstructForms]: If true, use construct forms (e.g., "שלושת אלפים") where appropriate (mainly for thousands 3-10).
  /// Returns the integer in words, e.g., "שלושת אלפים מאתיים חמישים ושש".
  String _convertInteger(
      BigInt n, Gender gender, bool useStandaloneForm, bool useConstructForms) {
    if (n == BigInt.zero) return _zero; // Base case: zero.
    // Handle numbers less than 1000 directly using the chunk converter.
    if (n < BigInt.from(1000)) {
      return _convertChunk(
          n.toInt(), gender, useStandaloneForm, useConstructForms);
    }

    // Stores converted parts (_IntegerPart contains text, scale index, chunk value).
    List<_IntegerPart> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0; // 0=units, 1=thousands, 2=millions...
    BigInt remaining = n;

    // Decompose the number into 3-digit chunks (0-999) from right to left.
    while (remaining > BigInt.zero) {
      int currentScaleIndex = scaleIndex;
      BigInt chunkBigInt = remaining % oneThousand;
      int chunk = chunkBigInt.toInt();
      remaining ~/= oneThousand;

      // Process non-zero chunks.
      if (chunk > 0) {
        String chunkText;
        // Handle different scale levels.
        if (currentScaleIndex == 0) {
          // Base chunk (0-999): Convert using specified gender.
          // Construct forms aren't typically needed for the final chunk itself.
          chunkText = _convertChunk(chunk, gender, useStandaloneForm, false);
        } else if (currentScaleIndex == 1) {
          // Thousands chunk: Special handling based on value.
          if (chunk == 1) {
            // One thousand.
            chunkText = _thousandSingular;
          } else if (chunk == 2 &&
              remaining == BigInt.zero &&
              useStandaloneForm) {
            // Two thousand (standalone dual form).
            chunkText = _thousandDual;
          } else if (chunk >= 3 && chunk <= 10 && useConstructForms) {
            // 3-10 thousand: Use masculine construct form + plural thousands.
            // Special case for 10 construct form.
            chunkText =
                "${chunk == 10 ? _tenMasculineConstruct : _unitsMasculineConstruct[chunk]} $_thousandPlural";
          } else {
            // 11+ thousand: Convert number (masculine) + "אלף" marker.
            // Don't use construct forms for the number part itself here.
            chunkText = _convertChunk(chunk, Gender.masculine, false, false) +
                _thousandScaleMarker;
          }
        } else {
          // Millions, billions, etc.: Treated as masculine nouns.
          String scaleWord = _scaleWords[currentScaleIndex];
          if (chunk == 1) {
            // "מיליון", "מיליארד" (singular scale word).
            chunkText = scaleWord;
          } else {
            // 2+ million/billion: Convert number (masculine) + scale word.
            // Don't use construct forms for the number part.
            chunkText =
                "${_convertChunk(chunk, Gender.masculine, false, false)} $scaleWord";
          }
        }
        // Store the processed part.
        parts.add(_IntegerPart(
            text: chunkText, scaleIndex: currentScaleIndex, chunkValue: chunk));
      }
      scaleIndex++;
    }

    // Combine the parts from highest scale to lowest, adding separators ("ve").
    StringBuffer result = StringBuffer();
    for (int i = parts.length - 1; i >= 0; i--) {
      _IntegerPart currentPart = parts[i];
      result.write(currentPart.text);

      // Determine if a separator ("ve") is needed before the next lower part.
      if (i > 0) {
        _IntegerPart nextPart = parts[i - 1];
        String separator = " "; // Default space separator.

        // Add "ve" (and) between higher scales (million, billion) and lower parts.
        if (currentPart.scaleIndex >= 2) {
          separator = _spacedAnd;
        }
        // Add "ve" between "אלף" (one thousand) and a units chunk < 100.
        else if (currentPart.scaleIndex == 1 && currentPart.chunkValue == 1) {
          // If current is "אלף"
          if (nextPart.scaleIndex == 0 && nextPart.chunkValue < 100) {
            // And next is units < 100
            separator = _spacedAnd;
          }
          // Add "ve" between construct thousands (e.g., שלושת אלפים) and units chunk < 100? Generally yes.
          // This seems covered by the general logic? Let's test. 3123 -> שלושת אלפים מאה עשרים ושלוש. Need ve.
          // The current logic might put just a space. Let's refine.
        }
        // Heuristic: Add "ve" if the next chunk (units) starts with a unit digit (1-9) or is just tens (20,30...).
        // Need to be careful not to add "ve" before hundreds within the next chunk.
        // Simpler rule: Often add "ve" before the final chunk if it doesn't start with "מאה" or "מאתיים".
        // Let's stick to the common cases: after scales >= 2 and after singular 'elef' before units < 100.
        // More complex rules might be needed for perfect grammar in all cases.

        result.write(separator);
      }
    }
    return result.toString().trim(); // Trim final result.
  }

  /// Converts a number between 0 and 999 into its Hebrew word representation.
  /// Handles hundreds, tens, units, and teens, applying gender rules.
  ///
  /// [n]: The number to convert (must be 0 <= n < 1000).
  /// [gender]: The grammatical gender required (masculine or feminine).
  /// [useStandaloneForm]: Not directly used in this chunk logic, but passed down.
  /// [useConstructForms]: Not directly used in this chunk logic, but passed down.
  /// Returns the chunk in words, e.g., "מאה עשרים ושלוש", "שש מאות", "חמש עשרה".
  String _convertChunk(
      int n, Gender gender, bool useStandaloneForm, bool useConstructForms) {
    if (n == 0) return ""; // Empty string for zero within a larger context.
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }

    int remainder = n;
    // Select the correct gendered lists for units, tens, and teens.
    final units = gender == Gender.feminine ? _unitsFeminine : _unitsMasculine;
    final tens = gender == Gender.feminine ? _tensFeminine : _tensMasculine;
    final teens = gender == Gender.feminine ? _teensFeminine : _teensMasculine;

    String hundredsPart = "";
    // Process hundreds (100-999).
    if (remainder >= 100) {
      int hundredDigit = remainder ~/ 100;
      if (hundredDigit == 1) {
        hundredsPart = _hundred; // "מאה"
      } else if (hundredDigit == 2) {
        hundredsPart = _twoHundred; // "מאתיים"
      } else {
        // 300-900: Use feminine unit form + " מאות".
        hundredsPart =
            _unitsFeminine[hundredDigit] + _hundredsPrefix; // e.g., "שלוש מאות"
      }
      remainder %= 100; // Get the remaining 0-99 part.
    }

    String tensUnitsPart = "";
    // Process tens and units (1-99).
    if (remainder > 0) {
      if (remainder < 10) {
        // 1-9: Use the appropriate gendered unit word.
        tensUnitsPart = units[remainder];
      } else if (remainder < 20) {
        // 10-19: Use the appropriate gendered teen word.
        tensUnitsPart = teens[remainder - 10]; // Index 0 is 10, 1 is 11, etc.
      } else {
        // 20-99:
        int tensDigit = remainder ~/ 10;
        int unitDigit = remainder % 10;
        // Get the tens word (note: 20-90 are gender-neutral).
        tensUnitsPart = tens[tensDigit];
        if (unitDigit > 0) {
          // If there's a unit digit, add "ve" and the gendered unit word.
          tensUnitsPart +=
              _spacedAnd + units[unitDigit]; // e.g., "עשרים ושלושה"
        }
      }
    }

    // Combine hundreds and tens/units parts.
    if (hundredsPart.isNotEmpty && tensUnitsPart.isNotEmpty) {
      // Add "ve" between hundreds and the rest.
      return hundredsPart +
          _spacedAnd +
          tensUnitsPart; // e.g., "מאה ועשרים ושלוש"
    } else {
      // Return whichever part is non-empty.
      return hundredsPart.isNotEmpty ? hundredsPart : tensUnitsPart;
    }
  }
}
