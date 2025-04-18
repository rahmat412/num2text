import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ro_options.dart';
import '../utils/utils.dart';

/// Internal enum to represent grammatical gender context for number conversion.
enum _GenderContext { masculine, feminine, neuter }

/// {@template num2text_ro}
/// The Romanian language (`Lang.RO`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Romanian word representation following standard Romanian grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [RoOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers
/// (using million/milliard scale). It correctly applies Romanian grammatical rules,
/// including gender agreement ("unu"/"una", "doi"/"două") and the use of the
/// preposition "de" before certain scale words.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [RoOptions].
/// {@endtemplate}
class Num2TextRO implements Num2TextBase {
  /// Word for zero.
  static const String _zero = "zero";

  /// Word for minus sign.
  static const String _minus = "minus";

  /// Word for decimal comma ",".
  static const String _virgula = "virgulă";

  /// Word for decimal point ".".
  static const String _punct = "punct";

  /// Conjunction "and".
  static const String _si = "și";

  /// Preposition "of" - used before thousands/millions etc. under certain conditions.
  static const String _de = "de";

  /// Singular form of "hundred".
  static const String _suta = "sută";

  /// Plural form of "hundred".
  static const String _sute = "sute";

  /// Singular form of "thousand".
  static const String _mie = "mie";

  /// Plural form of "thousand".
  static const String _mii = "mii";

  /// Suffix for BC years ("înainte de Hristos").
  static const String _yearSuffixBC = "î.Hr.";

  /// Suffix for AD/CE years ("după Hristos").
  static const String _yearSuffixAD = "d.Hr.";

  /// Word for Infinity.
  static const String _infinity = "Infinit";

  /// Word for Negative Infinity.
  static const String _negativeInfinity = "Infinit negativ";

  /// Word for Not a Number.
  static const String _notANumber = "Nu este un număr";

  /// Masculine forms for digits 1-9. Index 0 is unused.
  static const List<String> _unitsMasculine = [
    "", // 0
    "unu", // 1
    "doi", // 2
    "trei", // 3
    "patru", // 4
    "cinci", // 5
    "șase", // 6
    "șapte", // 7
    "opt", // 8
    "nouă", // 9
  ];

  /// Feminine forms for digits 1-9. Index 0 is unused.
  static const List<String> _unitsFeminine = [
    "", // 0
    "una", // 1
    "două", // 2
    "trei", // 3
    "patru", // 4
    "cinci", // 5
    "șase", // 6
    "șapte", // 7
    "opt", // 8
    "nouă", // 9
  ];

  /// Neuter forms for digits 1-9 (same as masculine). Index 0 is unused.
  static const List<String> _unitsNeuter = [
    "", // 0
    "unu", // 1
    "doi", // 2
    "trei", // 3
    "patru", // 4
    "cinci", // 5
    "șase", // 6
    "șapte", // 7
    "opt", // 8
    "nouă", // 9
  ];

  /// Words for numbers 10-19.
  static const List<String> _teens = [
    "zece", // 10
    "unsprezece", // 11
    "doisprezece", // 12
    "treisprezece", // 13
    "paisprezece", // 14
    "cincisprezece", // 15
    "șaisprezece", // 16
    "șaptesprezece", // 17
    "optsprezece", // 18
    "nouăsprezece", // 19
  ];

  /// Words for tens (20-90). Indices 0 and 1 unused.
  static const List<String> _tens = [
    "", // 0
    "", // 10
    "douăzeci", // 20
    "treizeci", // 30
    "patruzeci", // 40
    "cincizeci", // 50
    "șaizeci", // 60
    "șaptezeci", // 70
    "optzeci", // 80
    "nouăzeci", // 90
  ];

  /// Defines the large number scale words (singular/plural) and their grammatical gender ('g').
  /// Index corresponds to the power of 1,000,000 (1=million, 2=billion(miliard),...).
  /// Gender: 'm' = masculine, 'n' = neuter (although trilion/etc. are often treated as masculine in agreement).
  static const List<Map<String, String>> _scaleWords = [
    // Index 0: Represents units/thousands, handled separately.
    {"s": "", "p": "", "g": "n"}, // Placeholder, not used directly for scales.
    // Index 1: Million (10^6)
    {"s": "milion", "p": "milioane", "g": "n"}, // Neuter noun
    // Index 2: Milliard (10^9)
    {"s": "miliard", "p": "miliarde", "g": "n"}, // Neuter noun
    // Index 3: Trillion (10^12)
    {"s": "trilion", "p": "trilioane", "g": "n"}, // Neuter noun
    // Index 4: Quadrillion (10^15)
    {"s": "cvadrilion", "p": "cvadrilioane", "g": "n"}, // Neuter noun
    // Index 5: Quintillion (10^18)
    {"s": "cvintilion", "p": "cvintilioane", "g": "n"}, // Neuter noun
    // Index 6: Sextillion (10^21)
    {"s": "sextilion", "p": "sextilioane", "g": "n"}, // Neuter noun
    // Index 7: Septillion (10^24)
    {"s": "septilion", "p": "septilioane", "g": "n"}, // Neuter noun
    // Add more scales if needed
  ];

  /// Processes the given [number] and converts it into Romanian words.
  ///
  /// This is the main entry point for the Romanian conversion.
  /// - Normalizes the input [number].
  /// - Handles special cases like zero, infinity, NaN.
  /// - Manages the negative sign using [RoOptions.negativePrefix].
  /// - Delegates based on [options]: [_handleYearFormat], [_handleCurrency], [_handleStandardNumber].
  /// - Returns the final word representation or fallback error message.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have Romanian-specific options, using defaults if none are provided.
    final RoOptions roOptions =
        options is RoOptions ? options : const RoOptions();

    // Handle special double values before normalization.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? _negativeInfinity : _infinity;
      }
      if (number.isNaN) {
        return fallbackOnError ?? _notANumber;
      }
    }

    // Normalize the input number to Decimal for precision.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    if (decimalValue == null) {
      return fallbackOnError ?? _notANumber; // Handle normalization failure
    }

    // Handle the specific case of zero.
    if (decimalValue == Decimal.zero) {
      if (roOptions.currency) {
        // For currency, use "zero" and the plural main unit name.
        return "$_zero ${roOptions.currencyInfo.mainUnitPlural}";
      } else {
        // For years or standard numbers, just return "zero".
        return _zero;
      }
    }

    // Determine sign and work with the absolute value.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    // Delegate based on the format specified in options.
    if (roOptions.format == Format.year) {
      // Handle year formatting (may include BC/AD suffixes).
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), roOptions);
    } else {
      // Handle non-year formats (currency or standard number).
      if (roOptions.currency) {
        textResult = _handleCurrency(absValue, roOptions);
      } else {
        textResult = _handleStandardNumber(absValue, roOptions);
      }
      // Prepend the negative prefix if the original number was negative.
      if (isNegative) {
        // Use "minus" specifically if the prefix is set to that, otherwise use the custom prefix.
        String prefix = (roOptions.negativePrefix.trim() == _minus)
            ? _minus
            : roOptions.negativePrefix.trim();
        textResult = "$prefix $textResult";
      }
    }

    return textResult; // Return the final result.
  }

  /// Formats a [BigInt] [year] as a Romanian year string.
  ///
  /// Handles negative years by appending "î.Hr." (BC).
  /// Handles positive years by optionally appending "d.Hr." (AD/CE) if [options.includeAD] is true.
  /// Uses neuter gender for year numbers.
  String _handleYearFormat(BigInt year, RoOptions options) {
    final bool isNegative = year < BigInt.zero;
    final BigInt absYear = isNegative ? -year : year;

    // Convert the absolute year value using neuter gender.
    String yearText = _convertInteger(absYear, _GenderContext.neuter);

    // Append suffixes for BC/AD.
    if (isNegative) {
      yearText += " $_yearSuffixBC"; // Append "before Christ".
    } else if (options.includeAD && absYear > BigInt.zero) {
      // Renamed includeAD to includeAD internally
      yearText +=
          " $_yearSuffixAD"; // Append "after Christ" if option is set and year > 0.
    }
    return yearText;
  }

  /// Formats the absolute [absValue] as Romanian currency.
  ///
  /// Uses [CurrencyInfo] from [options]. Optionally rounds.
  /// Converts main and subunit values using [_convertInteger] with appropriate genders (usually masculine).
  /// Selects singular/plural forms correctly ("leu"/"lei", "ban"/"bani").
  /// Applies the "de" preposition before units if needed.
  /// Joins parts with the separator from [CurrencyInfo] or "și".
  String _handleCurrency(Decimal absValue, RoOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    final int decimalPlaces = 2; // Standard subunit precision (e.g., bani).
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value if requested before separating parts.
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main and subunit values.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Round subunit value to nearest integer (e.g., 0.5 -> 1).
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round(scale: 0).toBigInt();

    String mainText;
    String mainUnitName;

    // Handle main unit: "un leu" vs "doi lei".
    if (mainValue == BigInt.one) {
      mainText = "un"; // Special form for 1 (masculine).
      mainUnitName = currencyInfo.mainUnitSingular;
    } else {
      // Convert using masculine gender (for Leu).
      mainText = _convertInteger(mainValue, _GenderContext.masculine);
      mainUnitName = currencyInfo.mainUnitPlural!; // Use plural form.
      // Add "de" if grammatically required (e.g., "douăzeci de lei").
      if (_needsDePreposition(mainValue)) {
        mainText += " $_de";
      }
    }

    String result = '$mainText $mainUnitName'; // e.g., "o sută de lei"

    // Add subunit part if it exists.
    if (subunitValue > BigInt.zero) {
      String subunitText;
      String subUnitName;

      // Handle subunit: "un ban" vs "doi bani".
      if (subunitValue == BigInt.one) {
        subunitText = "un"; // Special form for 1 (masculine).
        subUnitName = currencyInfo.subUnitSingular!;
      } else {
        // Convert using masculine gender (for Ban).
        subunitText = _convertInteger(subunitValue, _GenderContext.masculine);
        subUnitName = currencyInfo.subUnitPlural!; // Use plural form.
        // Add "de" if needed (e.g., "douăzeci de bani").
        if (_needsDePreposition(subunitValue)) {
          subunitText += " $_de";
        }
      }

      // Get separator ("și" or custom).
      String separator = " ${currencyInfo.separator ?? _si} ";
      // Append separator and subunit part.
      result +=
          '$separator$subunitText $subUnitName'; // e.g., " și cincizeci de bani"
    }

    return result;
  }

  /// Formats the absolute [absValue] as a standard Romanian cardinal number.
  ///
  /// Handles integer and fractional parts. Converts integer part using [_convertInteger]
  /// (defaults to neuter). Converts fractional part digit by digit using neuter forms,
  /// joined by spaces, prefixed by the decimal separator word ("virgulă" or "punct").
  String _handleStandardNumber(Decimal absValue, RoOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part (use "zero" if integer is 0 but fractional exists).
    // Use neuter gender for standalone numbers.
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, _GenderContext.neuter);

    String fractionalWords = '';
    // Process fractional part if it exists.
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word based on options.
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
        case null: // Default to comma
          separatorWord = _virgula;
          break;
        case DecimalSeparator.period:
        case DecimalSeparator.point: // Treat period and point the same.
          separatorWord = _punct;
          break;
      }

      // Get fractional digits as string.
      String fractionalDigits = absValue.toString().split('.').last;
      // Convert each digit character to its word form (using neuter).
      List<String> digitWords = fractionalDigits.split('').map((digit) {
        final int digitInt = int.parse(digit);
        return _convertDigit(
            digitInt); // Use helper for single digit conversion
      }).toList();
      // Combine separator and digit words.
      fractionalWords =
          ' $separatorWord ${digitWords.join(' ')}'; // e.g., " virgulă cinci zero"
    }

    return '$integerWords$fractionalWords'.trim(); // Combine parts and trim.
  }

  /// Converts a single digit (0-9) integer to its Romanian word form (neuter).
  String _convertDigit(int digit) {
    if (digit >= 0 && digit <= 9) {
      return _unitsNeuter[
          digit]; // Use neuter forms for digits after decimal point.
    }
    return "?"; // Fallback for invalid input.
  }

  /// Converts a non-negative [BigInt] [n] into its Romanian word representation.
  ///
  /// Breaks the number down into chunks of 1000.
  /// Recursively calls [_convertChunk] for each chunk.
  /// Applies the correct scale word (mie, milion, miliard, etc.) based on position.
  /// Manages gender agreement between the chunk number and the scale word.
  /// Applies the "de" preposition where necessary.
  /// [genderContext] specifies the required gender for the final chunk (0-999) if no scale word follows.
  String _convertInteger(BigInt n, _GenderContext genderContext) {
    if (n < BigInt.zero) {
      throw ArgumentError("Integer must be non-negative: $n");
    }
    if (n == BigInt.zero) return _zero; // Base case: Zero.

    List<String> parts = []; // Stores word chunks for each scale.
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0; // 0=units, 1=thousands, 2=millions,...
    BigInt remaining = n;

    // Process the number in chunks of 1000 from right to left.
    while (remaining > BigInt.zero) {
      // Extract the current chunk (0-999).
      BigInt chunk = remaining % oneThousand;
      // Move to the next chunk.
      remaining ~/= oneThousand;

      // Only process non-zero chunks.
      if (chunk > BigInt.zero) {
        String chunkText;
        _GenderContext
            chunkGenderContext; // Gender needed for the number within the chunk.
        String scaleWordSingular = "";
        String scaleWordPlural = "";
        _GenderContext scaleNounGender =
            _GenderContext.neuter; // Gender of the scale noun itself.

        // --- Determine scale words and required gender for the chunk ---
        if (scaleIndex == 1) {
          // Thousand scale ("mie" - feminine noun)
          scaleWordSingular = _mie;
          scaleWordPlural = _mii;
          // The numbers before "mie/mii" are feminine ("o mie", "două mii").
          chunkGenderContext = _GenderContext.feminine;
          scaleNounGender = _GenderContext.feminine;
        } else if (scaleIndex > 1) {
          // Million scale and higher
          int scaleInfoIndex = scaleIndex -
              1; // Adjust index for _scaleWords (starts at million)
          if (scaleInfoIndex < _scaleWords.length) {
            var scaleInfo = _scaleWords[scaleInfoIndex];
            scaleWordSingular = scaleInfo["s"]!;
            scaleWordPlural = scaleInfo["p"]!;
            String genderChar = scaleInfo["g"]!; // Gender of the scale noun

            // Determine scale noun gender.
            if (genderChar == "m") {
              scaleNounGender = _GenderContext.masculine;
            } else if (genderChar == "f") {
              scaleNounGender = _GenderContext.feminine; // If added later
            } else {
              scaleNounGender = _GenderContext.neuter;
            }
            // Determine the gender needed for the number *before* the scale noun.
            // Rule: "un milion" (M/N) vs "două milioane" (F)
            // Rule: "un miliard" (M/N) vs "două miliarde" (F)
            if (scaleNounGender == _GenderContext.masculine ||
                scaleNounGender == _GenderContext.neuter) {
              chunkGenderContext = (chunk == BigInt.one)
                  ? _GenderContext.masculine
                  : _GenderContext.feminine;
            } else {
              // Should not happen with current scales, but for completeness
              chunkGenderContext = (chunk == BigInt.one)
                  ? _GenderContext.feminine
                  : _GenderContext.feminine;
            }
          } else {
            // Safety check if number exceeds defined scales.
            throw ArgumentError(
                "Number too large, scale index $scaleIndex out of bounds.");
          }
        } else {
          // Scale index 0 (units chunk)
          // Use the gender context passed into the function.
          chunkGenderContext = genderContext;
        }

        // --- Convert the chunk and combine with scale word ---
        if (chunk == BigInt.one && scaleIndex >= 1) {
          // Special handling for "one thousand/million/etc."
          if (scaleNounGender == _GenderContext.feminine) {
            // "o mie" (feminine 'one')
            chunkText = "o";
            parts.add("$chunkText $scaleWordSingular");
          } else {
            // "un milion", "un miliard" (masculine/neuter 'one')
            chunkText = "un";
            parts.add("$chunkText $scaleWordSingular");
          }
        } else {
          // Convert the 0-999 chunk using the determined gender context.
          chunkText = _convertChunk(chunk.toInt(), chunkGenderContext);

          if (scaleIndex >= 1) {
            // If it's a scale word (thousand+)
            // Choose singular/plural form of the scale word.
            String scale =
                (chunk > BigInt.one) ? scaleWordPlural : scaleWordSingular;
            // Add preposition "de" if needed (e.g., "douăzeci de mii").
            if (_needsDePreposition(chunk)) {
              chunkText += " $_de";
            }
            // Add the chunk text and the scale word.
            parts.add("$chunkText $scale");
          } else {
            // If it's the last chunk (units), just add the chunk text.
            parts.add(chunkText);
          }
        }
      }
      scaleIndex++; // Move to the next higher scale.

      // Safety check against excessively large numbers.
      if (scaleIndex > _scaleWords.length + 1) {
        // +1 accounts for 'thousand'
        throw ArgumentError(
            "Number too large to convert (exceeds defined scales).");
      }
    }
    // Join the parts in reverse order (largest scale first) with spaces.
    return parts.reversed.join(' ');
  }

  /// Converts an integer [n] between 0 and 999 into Romanian words.
  /// Handles hundreds, tens, and units, applying the correct [genderContext].
  String _convertChunk(int n, _GenderContext genderContext) {
    if (n == 0) return ""; // Return empty for zero.
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }

    List<String> words =
        []; // Stores parts of the chunk (hundreds, tens/units).
    int remainder = n;

    // Handle hundreds place.
    if (remainder >= 100) {
      int hundredDigit = remainder ~/ 100; // Get hundreds digit (1-9).
      if (hundredDigit == 1) {
        // Special case for 100: "o sută".
        words.add("o"); // Feminine 'one'.
        words.add(_suta); // Singular 'hundred'.
      } else if (hundredDigit == 2) {
        // Special case for 200: "două sute".
        words.add("două"); // Feminine 'two'.
        words.add(_sute); // Plural 'hundred'.
      } else {
        // For 300-900: use neuter form of digit + plural "sute".
        words.add(_getUnits(hundredDigit, _GenderContext.neuter));
        words.add(_sute);
      }
      remainder %= 100; // Update remainder to 0-99.
    }

    // Handle remaining tens and units place (0-99).
    if (remainder > 0) {
      if (remainder < 10) {
        // 1-9: Use the appropriate gendered unit form.
        words.add(_getUnits(remainder, genderContext));
      } else if (remainder < 20) {
        // 10-19: Use the direct lookup table.
        words.add(_teens[remainder - 10]);
      } else {
        // 20-99:
        int tenDigit = remainder ~/ 10;
        words.add(_tens[tenDigit]); // Add "douăzeci", "treizeci", etc.
        int unitDigit = remainder % 10;
        if (unitDigit > 0) {
          // If unit is non-zero, add "și" and the unit word with correct gender.
          words.add(_si); // Add "and".
          words.add(_getUnits(unitDigit, genderContext)); // Add gendered unit.
        }
      }
    }

    // Join the parts (e.g., ["o", "sută", "și", "unu"]) with spaces.
    return words.join(' ');
  }

  /// Returns the correct gendered word for a single digit (1-9).
  String _getUnits(int n, _GenderContext context) {
    if (n < 0 || n > 9) return "?"; // Input validation.
    // Select the correct list based on the required gender context.
    switch (context) {
      case _GenderContext.feminine:
        return _unitsFeminine[n];
      case _GenderContext.masculine:
        return _unitsMasculine[n];
      case _GenderContext.neuter:
        return _unitsNeuter[n];
    }
  }

  /// Checks if the preposition "de" is needed before a scale word (mie, milion, etc.).
  ///
  /// Rule: "de" is needed if the preceding number is >= 20 OR if it's exactly 0
  /// (e.g., in "douăzeci de mii", but not "nouăsprezece mii").
  /// This applies when the number ends in 00-19 within the last 100.
  /// Simplified: Needed if number >= 20 and ends in 00-19, or if number is 0 (implies scale word follows 0 count).
  /// Refined Rule: "de" is needed if the number is >= 20 OR if the number ends in 00..19
  /// Correction based on grammar: 'de' is required before 'mii', 'milioane', 'miliarde' etc.
  /// when the preceding number is >= 20, OR when the preceding number is exactly 0.
  /// It is NOT used for numbers 1-19.
  /// Example: 19 mii, 20 de mii, 100 de mii, 101 mii, 120 de mii.
  bool _needsDePreposition(BigInt number) {
    // No preposition needed for 1-19.
    if (number > BigInt.zero && number < BigInt.from(20)) return false;

    // Calculate remainder modulo 100 to check the last two digits.
    BigInt remainderMod100 = number % BigInt.from(100);

    // "de" is needed if the number is >= 20 AND the last two digits are 0.
    // OR if the number is >= 20 AND the last two digits are >= 20.
    // Simplified: "de" is needed if number >= 20 and remainderMod100 is 0 or >= 20.
    return remainderMod100 == BigInt.zero || remainderMod100 >= BigInt.from(20);

    // --- Previous logic (potentially flawed) ---
    // if (number < BigInt.from(20)) return false; // Not needed for 1-19.
    // BigInt remainderMod100 = number % BigInt.from(100);
    // Check if the number ends in 00 up to 19.
    // return remainderMod100 < BigInt.from(20); // Incorrect: this is where 'de' is NOT needed.
  }
}
