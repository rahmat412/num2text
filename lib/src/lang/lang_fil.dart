import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/fil_options.dart'; // Options specific to Filipino formatting.
import '../utils/utils.dart';

/// {@template num2text_fil}
/// The Filipino language (`Lang.FIL`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Filipino word representation following standard Filipino grammar and vocabulary,
/// including the use of linkers (`na`, `-ng`) and ligatures (`-'t`).
///
/// Capabilities include handling cardinal numbers, currency (using [FilOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (short scale).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [FilOptions].
/// {@endtemplate}
class Num2TextFIL implements Num2TextBase {
  // --- Constants ---

  /// The word for zero ("sero").
  static const String _sero = "sero";

  /// The word for the decimal separator when using a period (`.`).
  static const String _punto = "punto";

  /// The word for the decimal separator when using a comma (`,`).
  static const String _koma = "koma";

  /// The conjunction "at" (and), used between hundreds and tens/units, and sometimes before the final group.
  static const String _at = "at";

  /// The ligature "-'t", a contraction of "at" (and), used after tens ending in a vowel (e.g., "dalawampu't isa" for 21).
  static const String _tLigature = "'t";

  /// The linker "na", used after numbers ending in a consonant (except 'n') before the noun/scale word.
  static const String _naLinker = "na";

  /// The linker "-ng", appended to numbers ending in a vowel or 'n' before the noun/scale word.
  /// (e.g., "dalawang libo", "isang milyon").
  static const String _ngLinker = "ng";

  /// The suffix for negative years ("Before Christ").
  static const String _yearSuffixBC = "BC";

  /// The suffix for positive years ("Anno Domini"). Added only if [FilOptions.includeAD] is true.
  static const String _yearSuffixAD = "AD";

  /// Default error message for invalid number input if no fallback is provided.
  static const String _defaultNaN = "Hindi isang Numero"; // "Not a Number"

  /// Word forms for numbers 0 through 19.
  static const List<String> _wordsUnder20 = [
    _sero, // 0
    "isa", // 1
    "dalawa", // 2
    "tatlo", // 3
    "apat", // 4
    "lima", // 5
    "anim", // 6
    "pito", // 7
    "walo", // 8
    "siyam", // 9
    "sampu", // 10
    "labing-isa", // 11
    "labing-dalawa", // 12
    "labing-tatlo", // 13
    "labing-apat", // 14
    "labinlima", // 15 (Common spelling variant)
    "labing-anim", // 16
    "labimpito", // 17 (Common spelling variant)
    "labing-walo", // 18
    "labinsiyam", // 19 (Common spelling variant)
  ];

  /// Alternative descriptive forms for 11-19, used specifically for year formatting (e.g., "labing siyam na raan" for 1900).
  static const List<String> _wordsUnder20Descriptive = [
    _sero, // 0
    "isa", // 1
    "dalawa", // 2
    "tatlo", // 3
    "apat", // 4
    "lima", // 5
    "anim", // 6
    "pito", // 7
    "walo", // 8
    "siyam", // 9
    "sampu", // 10
    "labing isa", // 11
    "labing dalawa", // 12
    "labing tatlo", // 13
    "labing apat", // 14
    "labing lima", // 15
    "labing anim", // 16
    "labing pito", // 17
    "labing walo", // 18
    "labing siyam", // 19
  ];

  /// Word forms for tens from 20 to 90. Indices 2-9 correspond to 20-90.
  static const List<String> _wordsTens = [
    "", // 0 - Not used directly
    "", // 10 - Covered by _wordsUnder20
    "dalawampu", // 20
    "tatlumpu", // 30
    "apatnapu", // 40
    "limampu", // 50
    "animnapu", // 60
    "pitumpu", // 70
    "walumpu", // 80
    "siyamnapu", // 90
  ];

  /// The word for exactly one hundred ("isang daan"). Uses the linker rules.
  static const String _hundredSingular = "isang daan";

  /// The base word for hundred ("daan"), used when forming plurals (e.g., "dalawang daan").
  static const String _hundredPluralBase = "daan";

  /// The modified form "raan", used after a number word ending in a consonant (except 'n') via the "na" linker (e.g., "apat na raan").
  static const String _hundredPluralRaan = "raan";

  /// Scale words (thousand, million, billion, etc.) using the short scale system.
  /// Index corresponds to the scale (0=units, 1=thousand, 2=million...).
  static const List<String> _scaleWords = [
    "", // 0: Units group
    "libo", // 1: Thousands (10^3)
    "milyon", // 2: Millions (10^6)
    "bilyon", // 3: Billions (10^9)
    "trilyon", // 4: Trillions (10^12)
    "kuwadrilyon", // 5: Quadrillions (10^15)
    "kwintilyon", // 6: Quintillions (10^18)
    "sekstilyon", // 7: Sextillions (10^21)
    "septilyon", // 8: Septillions (10^24)
    // Add more if needed (oktilyon, nonilyon...)
  ];

  /// {@macro num2text_base_process}
  /// Converts the given [number] into its Filipino word representation.
  ///
  /// Handles `int`, `double`, `BigInt`, `Decimal`, and numeric `String` inputs.
  /// Uses [FilOptions] to customize behavior like currency formatting ([FilOptions.currency], [FilOptions.currencyInfo]),
  /// year formatting ([Format.year]), decimal separator ([FilOptions.decimalSeparator]),
  /// and negative prefix ([FilOptions.negativePrefix]).
  /// If `options` is not an instance of [FilOptions], default settings are used.
  ///
  /// Returns the word representation (e.g., "isang daan dalawampu't tatlo", "negatibong sampu punto lima").
  /// If the input is invalid (`null`, `NaN`, `Infinity`, non-numeric string), it returns
  /// [fallbackOnError] if provided, otherwise a default error message like "Hindi isang Numero".
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have Filipino-specific options, using defaults if none are provided.
    final FilOptions filOptions =
        options is FilOptions ? options : const FilOptions();
    // Use the provided fallback or the default Filipino error message.
    final String errorFallback = fallbackOnError ?? _defaultNaN;

    // Handle special non-finite double values early.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? "Negative Infinity"
            : "Infinity"; // Consider localizing?
      }
      if (number.isNaN) return errorFallback;
    }

    // Normalize the input to a Decimal for precise calculations.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Return error if normalization failed (invalid input type or format).
    if (decimalValue == null) return errorFallback;

    // Handle the specific case of zero.
    if (decimalValue == Decimal.zero) {
      if (filOptions.currency) {
        // Currency format for zero (e.g., "sero piso").
        return "$_sero ${filOptions.currencyInfo.mainUnitSingular}";
      }
      // For years or standard numbers, zero is just "sero".
      return _sero;
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for the core conversion logic.
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // --- Dispatch based on format options ---
    if (filOptions.format == Format.year) {
      // Year format needs the original integer value (positive or negative).
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), filOptions);
      // Note: Negative sign is handled by appending BC/AD, not the standard negative prefix.
    } else {
      // Handle currency or standard number format for the absolute value.
      if (filOptions.currency) {
        textResult = _handleCurrency(absValue, filOptions);
      } else {
        textResult = _handleStandardNumber(absValue, filOptions);
      }
      // Prepend the negative prefix *only* if it's a standard number or currency, not a year.
      if (isNegative) {
        textResult = "${filOptions.negativePrefix} $textResult";
      }
    }
    return textResult;
  }

  /// Applies the correct Filipino linker (`na` or `-ng`) between a number word and the following noun/scale word.
  /// Handles special cases like "isa" -> "isang" and consonant-ending words modifying "daan" -> "raan".
  ///
  /// [numberWord]: The word representation of the number (e.g., "dalawa", "apat").
  /// [noun]: The word following the number (e.g., "libo", "daan", "piso").
  /// Returns the combined string with the correct linker, e.g., "dalawang libo", "apat na raan", "isang piso".
  String _applyNgLinker(String numberWord, String noun) {
    // If the number word is empty (e.g., for 0), just return the noun.
    if (numberWord.isEmpty) return noun;
    numberWord =
        numberWord.trim(); // Ensure no leading/trailing spaces affect logic.

    // Get the last character of the number word to determine the linker.
    final String lastChar = numberWord[numberWord.length - 1];
    final vowels = ['a', 'e', 'i', 'o', 'u'];

    // Determine if the "na" linker is needed: used after consonants *except* 'n'.
    final bool useNaLinker = !vowels.contains(lastChar) && lastChar != 'n';

    // Handle the special case where "daan" becomes "raan" after the "na" linker.
    String modifiedNoun = noun;
    if (noun == _hundredPluralBase && useNaLinker) {
      modifiedNoun = _hundredPluralRaan; // e.g., "apat na raan"
    }

    if (useNaLinker) {
      // Use the "na" linker.
      return "$numberWord $_naLinker $modifiedNoun"; // e.g., "anim na libo"
    } else {
      // Use the "-ng" linker.
      if (numberWord == "isa") {
        // Special case for "isa" which becomes "isang".
        return "isang $modifiedNoun"; // e.g., "isang daan", "isang milyon"
      }
      if (lastChar == 'n') {
        // If the number ends in 'n', remove the 'n' and add "-ng".
        return "${numberWord.substring(0, numberWord.length - 1)}$_ngLinker $modifiedNoun"; // e.g., "siyam(n) na + ng -> siyam na + ng -> siyam + ng -> siyamng" (though 'siyam' ends in 'm', handled by first case) - This logic applies more to potential future words. Let's check 'milyon' -> 'milyong'. Yes, this is correct.
      } else {
        // If the number ends in a vowel, append "-ng".
        return "$numberWord$_ngLinker $modifiedNoun"; // e.g., "dalawa + ng -> dalawang", "limampu + ng -> limampung"
      }
    }
  }

  /// Formats an integer as a calendar year, optionally adding BC/AD suffixes.
  /// Includes special handling for years like 1900 ("labing siyam na raan").
  ///
  /// [year]: The integer year value (can be negative for BC).
  /// [options]: Filipino options, specifically checks `includeAD`.
  /// Returns the year in words, e.g., "isang libo siyam na raan siyamnapu't siyam", "limang daan BC".
  String _handleYearFormat(int year, FilOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;

    String yearText;

    if (absYear == 0) {
      // Handle year 0.
      yearText = _sero;
    } else if (absYear >= 1100 && absYear < 2000 && absYear % 100 == 0) {
      // Special case for hundreds between 1100 and 1900 (e.g., 1900 -> "labing siyam na raan").
      int highPartInt = absYear ~/ 100; // Get the "19" part of 1900.
      // Use the descriptive form for 11-19 (e.g., "labing siyam").
      String highText = (highPartInt >= 11 && highPartInt <= 19)
          ? _wordsUnder20Descriptive[highPartInt]
          : _convertInteger(
              BigInt.from(highPartInt)); // Fallback for unexpected cases.
      // Apply the linker before "daan" (which becomes "raan").
      yearText = _applyNgLinker(highText, _hundredPluralBase);
    } else {
      // Default conversion for other years. Pass `isYear=true` to adjust linking if needed.
      yearText = _convertInteger(BigInt.from(absYear), isYear: true);
    }

    // Append era suffixes based on the year's sign and options.
    if (isNegative) {
      yearText += " $_yearSuffixBC"; // Always add "BC" for negative years.
    } else if (options.includeAD && absYear > 0) {
      // Add "AD" for positive years *only if* requested via options.
      yearText += " $_yearSuffixAD";
    }

    return yearText;
  }

  /// Formats a [Decimal] value as a currency amount in words.
  /// Handles main units and subunits based on [FilOptions.currencyInfo].
  /// Applies rounding if [FilOptions.round] is true.
  /// Uses Filipino linkers (`-ng`, `na`) when connecting numbers to currency units.
  ///
  /// [absValue]: The non-negative currency amount.
  /// [options]: Filipino options containing currency details and rounding preference.
  /// Returns the currency amount in words, e.g., "isang piso", "dalawang piso at limampung sentimo".
  String _handleCurrency(Decimal absValue, FilOptions options) {
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
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).truncate().toBigInt();

    String mainText;
    if (mainValue == BigInt.zero) {
      // Handle zero main unit value.
      mainText = "$_sero ${currencyInfo.mainUnitSingular}";
    } else {
      // Convert the main unit integer part to words.
      String mainNumText = _convertInteger(mainValue);
      // Apply the correct linker before the main currency unit name.
      mainText = _applyNgLinker(mainNumText, currencyInfo.mainUnitSingular);
    }

    String subunitText = "";
    // Process subunit part only if it exists and a singular subunit name is provided.
    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      // Convert the subunit integer part to words.
      String subNumText = _convertInteger(subunitValue);
      // Apply the correct linker before the subunit name.
      subunitText = _applyNgLinker(subNumText, currencyInfo.subUnitSingular!);
    }

    // Combine main and subunit parts with "at" if subunits exist.
    if (subunitValue > BigInt.zero && subunitText.isNotEmpty) {
      // Note: CurrencyInfo.separator is not used here; Filipino uses "at".
      return '$mainText $_at $subunitText';
    } else {
      // Return only the main part if no subunits.
      return mainText;
    }
  }

  /// Formats a standard [Decimal] number (non-currency, non-year) into words.
  /// Handles both the integer and fractional parts.
  /// The fractional part is read digit by digit after the separator word ("punto" or "koma").
  ///
  /// [absValue]: The non-negative number.
  /// [options]: Filipino options, used for `decimalSeparator`.
  /// Returns the number in words, e.g., "isang daan dalawampu't tatlo punto apat lima anim".
  String _handleStandardNumber(Decimal absValue, FilOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part. Use "sero" if integer is zero but there's a fractional part.
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _sero // Handle cases like 0.5 -> "sero punto lima"
            : _convertInteger(integerPart);

    String fractionalWords = '';
    // Process fractional part only if it's greater than zero.
    if (fractionalPart > Decimal.zero) {
      // Determine the decimal separator word based on options.
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _koma;
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period:
        default: // Default to "punto" for Filipino.
          separatorWord = _punto;
          break;
      }

      // Get the digits after the decimal point from the string representation.
      String fractionalDigits = absValue.toString().split('.').last;

      // Handle cases where toString() might omit trailing zeros (e.g., 1.50 -> "1.5")
      // but the scale indicates they should be present.
      if (fractionalDigits.length < absValue.scale) {
        fractionalDigits = fractionalDigits.padRight(absValue.scale, '0');
      }

      // Convert each digit character to its word form.
      List<String> digitWords = fractionalDigits.split('').map((digitChar) {
        final int? digitInt = int.tryParse(digitChar);
        // Map the digit to its word using _wordsUnder20.
        return (digitInt != null && digitInt >= 0 && digitInt <= 9)
            ? _wordsUnder20[digitInt]
            : '?'; // Placeholder for unexpected non-digit characters
      }).toList();

      // Include fractional part only if it contains non-zero digits or if it's explicitly zero (e.g., 1.0 -> "isa punto sero").
      // This check prevents adding ". sero sero" for integers represented as Decimals with scale.
      // Simplified: Always add if fractionalPart > 0.
      // if (digitWords.isNotEmpty && digitWords.any((w) => w != _sero && w != '?')) { // Check if any digit is non-zero
      //   fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      // } else if (digitWords.isNotEmpty && digitWords.every((w) => w == _sero)) { // Check if all digits are zero
      //   // Optionally include explicit zeros if desired, e.g., "punto sero sero"
      //    fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      // }
      if (digitWords.isNotEmpty) {
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }
    // This else-if block seems intended to handle cases like Decimal('1.0') but might be redundant or incorrect.
    // Standard handling above should cover .0 cases if fractionalPart > Decimal.zero is false.
    // else if (integerPart != BigInt.zero && absValue.scale > 0 && absValue.isInteger) {
    //   // This condition seems difficult to meet correctly.
    //   // If absValue.isInteger is true, fractionalPart should be zero.
    // }

    // Combine integer and fractional parts. Use trim to avoid leading/trailing spaces.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] integer into its Filipino word representation.
  /// Handles large numbers by breaking them into chunks of thousands and applying scale words.
  /// Incorporates Filipino grammatical rules like linkers and the use of "at".
  ///
  /// [n]: The non-negative integer to convert. Must not be negative.
  /// [isYear]: Optional flag (defaults to false). If true, may adjust linking rules (currently used to suppress 'at' before final chunk < 10).
  /// Returns the integer in words, e.g., "isang milyon dalawang daan tatlumpu't apat na libo lima".
  String _convertInteger(BigInt n, {bool isYear = false}) {
    if (n == BigInt.zero) return _sero; // Base case: zero.
    // Handle numbers less than 1000 directly.
    if (n < BigInt.from(1000)) return _convertChunk(n.toInt());

    List<String> parts = []; // Stores word parts for each scale level.
    // Stores the non-zero value of each 3-digit chunk, keyed by scale index.
    Map<int, int> chunkValues = {};
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0; // 0=units, 1=thousands, 2=millions...
    BigInt remaining = n;
    int highestScale =
        -1; // Track the highest scale index with a non-zero chunk.

    // Decompose the number into 3-digit chunks (0-999) and store non-zero chunks by scale.
    while (remaining > BigInt.zero) {
      BigInt chunkBigInt = remaining % oneThousand;
      int chunk = chunkBigInt.toInt();
      remaining ~/= oneThousand; // Move to the next higher chunk.
      if (chunk > 0) {
        // Store the value of this chunk at its scale index.
        chunkValues[scaleIndex] = chunk;
        // Keep track of the highest scale encountered.
        if (scaleIndex > highestScale) highestScale = scaleIndex;
      }
      scaleIndex++;
    }

    // Reconstruct the number word from the highest scale down.
    for (int i = highestScale; i >= 0; i--) {
      if (chunkValues.containsKey(i)) {
        // Get the value of the chunk for the current scale.
        int currentChunkValue = chunkValues[i]!;
        // Convert this 3-digit chunk to words.
        String chunkText = _convertChunk(currentChunkValue);
        // Get the scale word (libo, milyon, etc.) if applicable (i > 0).
        String scaleWord = i > 0 ? _scaleWords[i] : "";

        // Combine the chunk text and scale word using the appropriate linker.
        String combinedPart = scaleWord.isNotEmpty
            ? _applyNgLinker(chunkText, scaleWord)
            : chunkText;
        parts.add(combinedPart);

        // Special rule: Add "at" before the *final* chunk (units group, i=0)
        // IF the final chunk value is less than 10 AND it's not a year conversion.
        // This handles cases like "isang libo AT lima" (1005).
        bool isNextChunkFinalUnits =
            (i > 0 && chunkValues.containsKey(i - 1) && (i - 1 == 0));
        if (isNextChunkFinalUnits) {
          int finalChunkValue =
              chunkValues[0]!; // Get value of the 0-999 chunk.
          // Add 'at' if the final chunk is 1-9 and it's not a year.
          if (finalChunkValue > 0 && finalChunkValue < 10 && !isYear) {
            parts.add(_at);
          }
        }
      }
    }
    // Join all processed parts with spaces.
    return parts.join(' ');
  }

  /// Converts a number between 0 and 999 into its Filipino word representation.
  /// This is the base unit for integer conversion, handling hundreds, tens, and units.
  /// Includes rules for "at" (and) and the "-'t" ligature.
  ///
  /// [n]: The number to convert (must be 0 <= n < 1000).
  /// Returns the chunk in words, e.g., "isang daan", "dalawampu't isa", "tatlong daan at lima".
  String _convertChunk(int n) {
    if (n == 0)
      return ""; // Empty string for zero within a larger number context.
    if (n < 0 || n >= 1000)
      throw ArgumentError("Chunk must be between 0 and 999: $n");

    List<String> words = []; // Stores word parts for this chunk.
    int remainder = n;

    // --- Process Hundreds ---
    if (remainder >= 100) {
      int hundredDigit = remainder ~/ 100; // Get the hundreds digit (1-9).
      words.add(
        hundredDigit == 1
            // Special case for 100: "isang daan".
            ? _hundredSingular
            // For 200-900: Apply linker between the digit word and "daan"/"raan".
            // e.g., _applyNgLinker("dalawa", "daan") -> "dalawang daan"
            // e.g., _applyNgLinker("apat", "daan") -> "apat na raan"
            : _applyNgLinker(_wordsUnder20[hundredDigit], _hundredPluralBase),
      );
      remainder %= 100; // Get the remaining tens and units.

      // Add "at" (and) if there's a non-zero remainder after the hundreds.
      if (remainder > 0) {
        words.add(_at);
      }
    }

    // --- Process Tens and Units (0-99) ---
    if (remainder > 0) {
      // Handle numbers less than 20 directly.
      if (remainder < 20) {
        words.add(_wordsUnder20[remainder]);
      } else {
        // Handle numbers 20-99.
        String tensWord = _wordsTens[
            remainder ~/ 10]; // Get the tens word (e.g., "dalawampu").
        int unit = remainder % 10; // Get the unit digit.

        if (unit == 0) {
          // If it's an exact multiple of 10 (20, 30, ...), just use the tens word.
          words.add(tensWord);
        } else {
          // If there's a unit digit (21-29, 31-39, ...), combine tens and units.
          // Use the "-'t" ligature after tens ending in a vowel.
          // e.g., "dalawampu" + "'t" + " " + "isa" -> "dalawampu't isa"
          words.add("$tensWord$_tLigature ${_wordsUnder20[unit]}");
        }
      }
    }

    // Combine the collected word parts (hundreds, "at", tens/units).
    return words.join(' ');
  }
}
