import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/sk_options.dart';
import '../utils/utils.dart';

/// {@template num2text_sk}
/// Converts numbers to Slovak words (`Lang.SK`).
///
/// Implements [Num2TextBase] for the Slovak language. Accepts various numeric
/// inputs (`int`, `double`, `BigInt`, `Decimal`, `String`) via its [process] method
/// and returns their Slovak word representation.
///
/// Features:
/// - Handles cardinal numbers, decimals, negatives, currency, and years.
/// - Correctly applies Slovak grammatical gender ([Gender]) and case variations
///   for numbers and associated nouns (like currency units).
/// - Supports large numbers using standard scale names (milión, miliarda, etc.).
///
/// Behavior can be customized using [SkOptions] (e.g., specifying gender,
/// currency details, decimal separator word). Returns a fallback string on error.
/// {@endtemplate}
class Num2TextSK implements Num2TextBase {
  // --- Constants ---

  /// The word for "zero".
  static const String _zero = "nula";

  /// The word for the decimal separator "point" or "period".
  static const String _pointWord = "bod"; // Masculine noun

  /// The word for the decimal separator "comma". Often implies "whole".
  static const String _commaWord = "celá"; // Feminine adjective form

  /// The word for positive infinity.
  static const String _infinity = "Nekonečno";

  /// The word for negative infinity.
  static const String _negativeInfinity = "Mínus nekonečno";

  /// The word for "Not a Number" (NaN).
  static const String _nan = "Nie je číslo";

  /// Units words (1-19) - Default masculine forms for 1 and 2.
  static const List<String> _units = [
    "",
    "jeden",
    "dva",
    "tri",
    "štyri",
    "päť",
    "šesť",
    "sedem",
    "osem",
    "deväť",
    "desať",
    "jedenásť",
    "dvanásť",
    "trinásť",
    "štrnásť",
    "pätnásť",
    "šestnásť",
    "sedemnásť",
    "osemnásť",
    "devätnásť",
  ];

  /// Specific forms for 1 (feminine) and 2 (feminine/neuter).
  static const List<String> _unitsFeminineNeuter = ["", "jedna", "dve"];

  /// Specific form for 1 (neuter).
  static const String _unitNeuter1 = "jedno";

  /// Tens words (20, 30, ..., 90).
  static const List<String> _tens = [
    "",
    "",
    "dvadsať",
    "tridsať",
    "štyridsať",
    "päťdesiat",
    "šesťdesiat",
    "sedemdesiat",
    "osemdesiat",
    "deväťdesiat",
  ];

  /// Hundreds words (100, 200, ..., 900).
  static const List<String> _hundreds = [
    "",
    "sto",
    "dvesto",
    "tristo",
    "štyristo",
    "päťsto",
    "šesťsto",
    "sedemsto",
    "osemsto",
    "deväťsto",
  ];

  // Special combined forms for thousands
  static const String _thousandSingular = "tisíc"; // 1000, 5000, 10000...
  static const String _twoThousand = "dvetisíc"; // 2000
  static const String _threeThousand = "tritisíc"; // 3000
  static const String _fourThousand = "štyritisíc"; // 4000

  /// Scale words (million+) with grammatical forms for number agreement.
  /// Structure: [singular (for 1), nominative plural (for 2-4), genitive plural (for 0, 5+)]
  /// Gender alternates: masculine (milión), feminine (miliarda), masculine (bilión), etc.
  static const List<List<String>> _scales = [
    // 10^6 - milión (masculine)
    ["milión", "milióny", "miliónov"],
    // 10^9 - miliarda (feminine)
    ["miliarda", "miliardy", "miliárd"],
    // 10^12 - bilión (masculine)
    ["bilión", "bilióny", "biliónov"],
    // 10^15 - biliarda (feminine)
    ["biliarda", "biliardy", "biliárd"],
    // 10^18 - trilión (masculine)
    ["trilión", "trilióny", "triliónov"],
    // 10^21 - triliarda (feminine)
    ["triliarda", "triliardy", "triliárd"],
    // 10^24 - kvadrilión (masculine)
    ["kvadrilión", "kvadrilióny", "kvadriliónov"],
    // Add more scales here following the pattern [singular, nom_plural, gen_plural]
  ];

  /// Processes the given [number] into Slovak words.
  ///
  /// This is the main entry point. It normalizes input, handles special values
  /// (Infinity, NaN), detects the sign, and delegates to specific handlers
  /// based on the [options] provided ([SkOptions]).
  ///
  /// @param number The number to convert (e.g., `123`, `45.67`, `BigInt.parse('1000000')`).
  /// @param options Optional [SkOptions] for customization (gender, currency, year format, etc.).
  /// @param fallbackOnError Optional custom string for errors, defaults to "Nie je číslo".
  /// @return The Slovak word representation or an error/fallback string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Establish options and fallback
    final SkOptions skOptions =
        options is SkOptions ? options : const SkOptions();
    final String effectiveFallback = fallbackOnError ?? _nan;

    // Handle special floating point values
    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _negativeInfinity : _infinity;
      if (number.isNaN) return effectiveFallback;
    }

    // Normalize input to Decimal
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return effectiveFallback; // Invalid input

    // Handle zero separately
    if (decimalValue == Decimal.zero) {
      if (skOptions.currency) {
        // Currency: Use genitive plural form for the main unit with zero.
        final String unitName = skOptions.currencyInfo.mainUnitPluralGenitive ??
            skOptions.currencyInfo
                .mainUnitSingular; // Fallback to singular if gen. plural missing
        // Gender for zero itself is context-dependent; using masculine as default for the number word.
        return "${_convertInteger(BigInt.zero, Gender.masculine)} $unitName"; // "nula [jednotiek]"
      } else {
        // Standard number: Return "nula". Gender option rarely affects zero directly.
        return _convertInteger(
            BigInt.zero, skOptions.gender ?? Gender.masculine);
      }
    }

    // Determine sign and work with absolute value
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    // Delegate based on options
    if (skOptions.format == Format.year) {
      if (!absValue.isInteger) return effectiveFallback; // Year must be integer
      // Year formatting handles its own sign/prefix if needed.
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), skOptions);
    } else if (skOptions.currency) {
      textResult = _handleCurrency(absValue, skOptions);
    } else {
      // Standard number: Pass the requested gender.
      textResult = _handleStandardNumber(absValue, skOptions);
    }

    // Prepend negative prefix if needed (but not for years, handled internally)
    if (isNegative && skOptions.format != Format.year) {
      textResult = "${skOptions.negativePrefix} $textResult";
    }

    // Return the final assembled string.
    return textResult;
  }

  /// Formats a year [BigInt] into Slovak words.
  ///
  /// Currently converts the year as a standard masculine cardinal number.
  /// Adds "n. l." (nášho letopočtu - AD/CE) if options require it and year is positive.
  /// Prepends the negative prefix for negative years (BC/BCE).
  ///
  /// @param year The year value.
  /// @param options The [SkOptions] containing format flags (includeAD, negativePrefix).
  /// @return The formatted year string.
  String _handleYearFormat(BigInt year, SkOptions options) {
    final bool isNegative = year < BigInt.zero;
    final BigInt absYear = isNegative ? -year : year;

    // Years are typically read as masculine cardinal numbers.
    String yearText = _convertInteger(absYear, Gender.masculine);

    // Add "n. l." (AD/CE) suffix if requested for positive years.
    if (options.includeAD && !isNegative) {
      yearText += " n. l.";
    }

    // Prepend negative prefix for BC/BCE years.
    if (isNegative) {
      yearText = "${options.negativePrefix} $yearText";
    }

    return yearText;
  }

  /// Converts a non-negative integer ([BigInt]) into Slovak words with gender agreement.
  ///
  /// Handles numbers from zero up to the limits of the defined scales.
  /// Breaks the number into chunks of 1000 and combines them with appropriate
  /// scale words (tisíc, milión, miliarda, etc.), applying grammatical rules.
  ///
  /// @param n The non-negative integer to convert.
  /// @param gender The grammatical [Gender] to apply (affects "jeden/jedna/jedno", "dva/dve").
  ///               For scales, the gender alternates (masculine, feminine, masculine...).
  /// @return The integer as Slovak words.
  /// @throws ArgumentError if input is negative.
  String _convertInteger(BigInt n, Gender gender) {
    if (n < BigInt.zero) {
      // This function handles only non-negative; sign is managed by the caller.
      throw ArgumentError("Negative input to _convertInteger: $n");
    }
    // Base case: Zero
    if (n == BigInt.zero) {
      return _zero;
    }

    // Handle numbers less than 1000 directly using the chunk converter.
    if (n < BigInt.from(1000)) return _convertChunk(n.toInt(), gender);

    // --- Logic for numbers >= 1000 ---
    final List<String> parts = []; // Stores word parts for each scale level
    final BigInt oneThousand = BigInt.from(1000);
    int scaleLevel =
        0; // 0: units chunk, 1: thousands, 2: millions, 3: billions...
    BigInt currentN = n; // Working copy of the number

    // Process the number in chunks of 1000 from right to left (least significant first)
    while (currentN > BigInt.zero) {
      final BigInt chunkValue =
          currentN % oneThousand; // Value of the current 0-999 chunk
      currentN ~/= oneThousand; // Move to the next chunk to the left

      if (chunkValue > BigInt.zero) {
        // Only process non-zero chunks
        String chunkText = ""; // Text for the 0-999 part
        String scaleWord = ""; // Text for the scale unit (tisíc, milión...)
        String currentPart = ""; // Combined text for this scale level

        Gender chunkGender =
            Gender.masculine; // Default gender, may be overridden

        if (scaleLevel == 0) {
          // --- Units Chunk (0-999) ---
          chunkGender =
              gender; // Use the overall requested gender for the lowest chunk
          chunkText = _convertChunk(chunkValue.toInt(), chunkGender);
          currentPart = chunkText;
        } else if (scaleLevel == 1) {
          // --- Thousands Chunk ---
          chunkGender = Gender.masculine; // "tisíc" is masculine
          // Special handling for 1000-4999
          if (chunkValue == BigInt.one) {
            scaleWord = _thousandSingular; // "tisíc"
          } else if (chunkValue == BigInt.two) {
            scaleWord = _twoThousand; // "dvetisíc"
          } else if (chunkValue == BigInt.from(3)) {
            scaleWord = _threeThousand; // "tritisíc"
          } else if (chunkValue == BigInt.from(4)) {
            scaleWord = _fourThousand; // "štyritisíc"
          } else {
            // Handle 5000+ : Convert the chunk number and add "tisíc"
            chunkText = _convertChunk(chunkValue.toInt(), chunkGender);
            scaleWord = _thousandSingular; // Use "tisíc"
            // Determine joining: "päťtisíc" vs "dvadsaťjeden tisíc"
            if (chunkText.contains(' ')) {
              currentPart =
                  "$chunkText $scaleWord"; // Separate if chunk text is complex
            } else {
              currentPart =
                  "$chunkText$scaleWord"; // Join if chunk text is simple (e.g., "päť")
            }
          }
          // If only scaleWord was set (for 1-4 thousand), use it as the part.
          if (chunkText.isEmpty && scaleWord.isNotEmpty) {
            currentPart = scaleWord;
          }
        } else {
          // --- Higher Scales (Millions, Billions, etc.) ---
          final int scaleInfoIndex = scaleLevel - 2; // 0=Million, 1=Billion...
          if (scaleInfoIndex >= 0 && scaleInfoIndex < _scales.length) {
            // Determine gender based on scale (alternating masculine/feminine)
            chunkGender =
                (scaleInfoIndex % 2 == 0) ? Gender.masculine : Gender.feminine;
            // Convert the chunk number according to the scale's gender
            chunkText = _convertChunk(chunkValue.toInt(), chunkGender);
            // Get the correct grammatical form of the scale word (e.g., "milión", "milióny", "miliónov")
            scaleWord = _getScaleForm(chunkValue, scaleInfoIndex);
            // Combine chunk text and scale word (always separated for higher scales)
            if (chunkText.isNotEmpty && scaleWord.isNotEmpty) {
              currentPart = "$chunkText $scaleWord";
            } else {
              // Handle cases like exactly 1 million (chunkText empty) or complex numbers without scales
              currentPart = chunkText.isNotEmpty ? chunkText : scaleWord;
            }
          } else {
            // Fallback if the number is too large for defined scales
            chunkGender = Gender.masculine; // Default gender
            chunkText = _convertChunk(chunkValue.toInt(), chunkGender);
            scaleWord = "[MierkaPrílišVeľká]"; // Placeholder error
            currentPart = "$chunkText $scaleWord";
          }
        }

        // Add the constructed part for this scale level to the beginning of the list
        if (currentPart.isNotEmpty) {
          parts.add(currentPart);
        }
      }
      scaleLevel++; // Move to the next scale level (thousands, millions...)
    }

    // Join the parts in reverse order (highest scale first) with spaces.
    return parts.reversed.join(' ');
  }

  /// Handles conversion of standard decimal numbers.
  ///
  /// Converts the integer and fractional parts separately and combines them
  /// using the appropriate decimal separator word ("bod" or "celá") based on options.
  /// Applies gender to the integer part and determines gender for the fractional part
  /// based on the separator word.
  ///
  /// @param absValue The absolute (non-negative) decimal value.
  /// @param options The [SkOptions] providing gender and decimal separator preferences.
  /// @return The decimal number as Slovak words.
  String _handleStandardNumber(Decimal absValue, SkOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Use the gender specified in options (or default to masculine) for the integer part.
    final Gender integerGender = options.gender ?? Gender.masculine;

    // Convert the integer part, handling the case where it's zero but a fraction exists.
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero // Use "nula" if integer is 0 but fraction exists
            : _convertInteger(integerPart, integerGender);

    String fractionalWords = ''; // Initialize fractional part text
    if (fractionalPart > Decimal.zero) {
      String separatorWord;
      Gender fractionalGender;
      // Determine separator word and associated gender based on options.
      switch (options.decimalSeparator) {
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          separatorWord = _pointWord; // "bod" (masculine)
          fractionalGender = Gender.masculine;
          break;
        case DecimalSeparator.comma:
        default: // Default to comma
          separatorWord =
              _commaWord; // "celá" (feminine - implies "whole numbers")
          fractionalGender = Gender.feminine;
          break;
      }

      // Extract digits after the decimal point.
      String digitsAfterPoint = absValue.toString().split('.').last;

      // Remove trailing zeros for standard reading (e.g., 1.50 -> "1.5").
      while (digitsAfterPoint.endsWith('0') && digitsAfterPoint.length > 1) {
        digitsAfterPoint =
            digitsAfterPoint.substring(0, digitsAfterPoint.length - 1);
      }

      // Process digits if any remain and are not just "0".
      if (digitsAfterPoint.isNotEmpty && digitsAfterPoint != '0') {
        final List<String> digitWords = [];
        // Check if fractional part needs digit-by-digit reading (e.g., "05" -> "nula päť")
        bool hasLeadingZero =
            digitsAfterPoint.length > 1 && digitsAfterPoint.startsWith('0');

        if (hasLeadingZero) {
          // Read each digit individually if there's a leading zero after the point.
          for (int i = 0; i < digitsAfterPoint.length; i++) {
            final int digit = int.parse(digitsAfterPoint[i]);
            digitWords.add(
                digit == 0 ? _zero : _convertChunk(digit, fractionalGender));
          }
          fractionalWords =
              ' $separatorWord ${digitWords.join(' ')}'; // e.g., " bod nula päť"
        } else {
          // Otherwise, convert the fractional part as a whole integer.
          BigInt fractionalInt = BigInt.parse(digitsAfterPoint);
          if (fractionalInt > BigInt.zero) {
            fractionalWords =
                ' $separatorWord ${_convertInteger(fractionalInt, fractionalGender)}'; // e.g., " celá päťdesiatšesť"
          }
        }

        // If fractional part ended up empty (e.g., input was 1.000) and integer was zero, return "nula".
        if (fractionalWords.isEmpty && integerPart == BigInt.zero) {
          return _convertInteger(BigInt.zero, integerGender);
        }
      } else if (integerPart == BigInt.zero) {
        // Handle case where input was like 1.0, 0.0 etc. -> return "nula" if integer was also zero.
        return _convertInteger(BigInt.zero, integerGender);
      }
    } else if (integerPart == BigInt.zero && fractionalPart == Decimal.zero) {
      // Handle exact zero input.
      return _convertInteger(BigInt.zero, integerGender);
    }

    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts an integer between 0 and 999 into Slovak words with gender agreement.
  ///
  /// Handles hundreds, tens, and units, applying the correct gender form for
  /// 1 ("jeden/jedna/jedno") and 2 ("dva/dve").
  ///
  /// @param n The integer chunk (0-999).
  /// @param gender The grammatical [Gender] to apply.
  /// @return The chunk as Slovak words, or empty string if n is 0.
  /// @throws ArgumentError if n is outside the 0-999 range.
  String _convertChunk(int n, Gender gender) {
    if (n == 0) return ""; // Zero contributes nothing within a larger number.
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }

    final List<String> words = []; // Use list to build parts, join at the end
    int remainder = n;

    // Handle hundreds part
    if (remainder >= 100) {
      words.add(_hundreds[remainder ~/ 100]); // Add "sto", "dvesto", etc.
      remainder %= 100; // Get the remaining tens/units
    }

    // Handle tens and units part (remainder 1-99)
    if (remainder > 0) {
      // Add space if hundreds part exists
      if (words.isNotEmpty) {
        words.add(" ");
      }
      if (remainder < 20) {
        // --- Handle 1-19 ---
        if (remainder == 1) {
          // Apply gender to "one"
          words.add(
            (gender == Gender.neuter)
                ? _unitNeuter1 // "jedno"
                : (gender == Gender.feminine
                    ? _unitsFeminineNeuter[1]
                    : _units[1]), // "jedna" or "jeden"
          );
        } else if (remainder == 2) {
          // Apply gender to "two"
          words.add(
            (gender == Gender.feminine || gender == Gender.neuter)
                ? _unitsFeminineNeuter[2] // "dve"
                : _units[2], // "dva"
          );
        } else {
          // 3-19 use the standard masculine form regardless of gender context
          words.add(_units[remainder]);
        }
      } else {
        // --- Handle 20-99 ---
        words.add(_tens[remainder ~/ 10]); // Add "dvadsať", "tridsať", etc.
        final int unit = remainder % 10;
        if (unit > 0) {
          words.add(" "); // Add space before the unit
          // Apply gender rules to the unit part (1 or 2)
          if (unit == 1) {
            words.add(
              (gender == Gender.neuter)
                  ? _unitNeuter1
                  : (gender == Gender.feminine
                      ? _unitsFeminineNeuter[1]
                      : _units[1]),
            );
          } else if (unit == 2) {
            words.add(
              (gender == Gender.feminine || gender == Gender.neuter)
                  ? _unitsFeminineNeuter[2]
                  : _units[2],
            );
          } else {
            // Units 3-9 use standard form
            words.add(_units[unit]);
          }
        }
      }
    }

    // Join the parts ("dvesto", " ", "dvadsať", " ", "jeden") into a single string.
    return words.join('');
  }

  /// Converts a non-negative [Decimal] value into Slovak currency words.
  ///
  /// Handles main units (e.g., Euro - neuter) and subunits (e.g., Cent - masculine),
  /// applying correct grammatical forms based on the count using [_getGrammaticalForm].
  /// Assumes Euro/Cent structure but uses names from [CurrencyInfo].
  ///
  /// @param absValue The absolute decimal value of the currency.
  /// @param options The [SkOptions] containing [CurrencyInfo] and rounding preference.
  /// @return The currency value formatted as Slovak words.
  String _handleCurrency(Decimal absValue, SkOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    const int decimalPlaces = 2; // Standard currency precision
    final Decimal subunitMultiplier =
        Decimal.fromInt(100); // 100 subunits/main unit

    // Round the value if requested
    final Decimal valueToConvert =
        options.round ? absValue.round(scale: decimalPlaces) : absValue;

    // Extract main (integer) and subunit (fractional) parts
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    // Use precise subtraction and rounding for subunit calculation
    final BigInt subunitValue =
        ((valueToConvert - valueToConvert.truncate()) * subunitMultiplier)
            .round()
            .toBigInt();

    String mainText = ""; // Word form of the main value number
    String mainUnitName = ""; // Correct grammatical form of the main unit noun
    String subunitText = ""; // Word form of the subunit value number
    String subUnitName = ""; // Correct grammatical form of the subunit noun

    bool mainPartExists = mainValue > BigInt.zero;
    bool subunitPartExists = subunitValue > BigInt.zero;

    // --- Process Main Unit Part (e.g., Euro) ---
    if (mainPartExists) {
      // Assuming Euro is neuter, convert the number using neuter gender.
      mainText = _convertInteger(mainValue, Gender.neuter);
      // Get the correct grammatical form (singular, nom. plural, gen. plural) of the main unit name.
      mainUnitName = _getGrammaticalForm(
        mainValue,
        currencyInfo.mainUnitSingular, // Form for 1
        currencyInfo.mainUnitPlural2To4 ??
            currencyInfo.mainUnitSingular, // Form for 2-4
        currencyInfo.mainUnitPluralGenitive ??
            currencyInfo.mainUnitSingular, // Form for 0, 5+
      );
    }

    // --- Process Subunit Part (e.g., Cent) ---
    if (subunitPartExists) {
      // Assuming Cent is masculine, convert the number using masculine gender.
      subunitText = _convertInteger(subunitValue, Gender.masculine);
      // Get the correct grammatical form of the subunit name.
      subUnitName = _getGrammaticalForm(
        subunitValue,
        currencyInfo.subUnitSingular ?? "", // Form for 1
        currencyInfo.subUnitPlural2To4 ??
            currencyInfo.subUnitSingular ??
            "", // Form for 2-4
        currencyInfo.subUnitPluralGenitive ??
            currencyInfo.subUnitSingular ??
            "", // Form for 0, 5+
      );
    }

    // --- Handle Zero Amount Explicitly ---
    if (!mainPartExists && !subunitPartExists) {
      // If the value is exactly 0 after rounding.
      mainText = _convertInteger(
          BigInt.zero, Gender.neuter); // "nula" (gender doesn't matter much)
      // Use the genitive plural form for the main unit with zero amount.
      mainUnitName = _getGrammaticalForm(
        BigInt.zero,
        currencyInfo.mainUnitSingular,
        currencyInfo.mainUnitPlural2To4 ?? currencyInfo.mainUnitSingular,
        currencyInfo.mainUnitPluralGenitive ?? currencyInfo.mainUnitSingular,
      );
      return '$mainText $mainUnitName'; // e.g., "nula eur"
    }

    // --- Construct the Final String ---
    final List<String> parts = [];
    if (mainPartExists) {
      parts.add('$mainText $mainUnitName'); // e.g., "jedno euro", "päť eur"
    }
    if (subunitPartExists) {
      // Add separator if both parts exist and separator is defined.
      if (mainPartExists &&
          currencyInfo.separator != null &&
          currencyInfo.separator!.isNotEmpty) {
        parts.add(currencyInfo.separator!); // e.g., "," or "a"
      }
      parts
          .add('$subunitText $subUnitName'); // e.g., "jeden cent", "päť centov"
    }

    return parts.join(' '); // Join parts with spaces
  }

  /// Selects the correct grammatical form of a noun based on the count (Slovak grammar).
  ///
  /// Rules:
  /// - Count 1: Singular form (`sing`).
  /// - Count ends in 2, 3, 4 (but not 12, 13, 14): Nominative Plural (`nomPl`).
  /// - Count 0, ends in 0, 1 (but 1 uses `sing`), 5, 6, 7, 8, 9, or 11-19: Genitive Plural (`genPl`).
  ///
  /// @param count The number determining the form.
  /// @param sing The singular noun form.
  /// @param nomPl The nominative plural form (for counts ending in 2-4, excluding 12-14).
  /// @param genPl The genitive plural form (for counts 0, 5+, 11-19, etc.).
  /// @return The grammatically correct noun form.
  String _getGrammaticalForm(
      BigInt count, String sing, String nomPl, String genPl) {
    final BigInt absCount = count.abs(); // Use absolute value for grammar rules
    if (absCount == BigInt.one) return sing; // Rule for 1

    // Check last two digits for 11-19 exception (uses genitive plural)
    final int lastTwoDigits = (absCount % BigInt.from(100)).toInt();
    if (lastTwoDigits >= 11 && lastTwoDigits <= 19) return genPl;

    // Check last digit for standard rules 2-4 vs 0, 5-9
    final int lastDigit = (absCount % BigInt.from(10)).toInt();
    if (lastDigit >= 2 && lastDigit <= 4) return nomPl; // Rule for 2, 3, 4

    // Default to genitive plural for 0, 5, 6, 7, 8, 9
    return genPl;
  }

  /// Selects the correct grammatical form for large scale words (milión, miliarda...).
  ///
  /// Applies the Slovak number agreement rules using [_getGrammaticalForm] with
  /// the specific forms stored in the [_scales] list.
  ///
  /// @param count The number preceding the scale word (e.g., 3 for "tri milióny").
  /// @param scaleInfoIndex Index into [_scales] (0=million, 1=billion, ...).
  /// @return The correct grammatical form of the scale word. Returns empty if index is invalid.
  String _getScaleForm(BigInt count, int scaleInfoIndex) {
    // Validate index
    if (scaleInfoIndex < 0 || scaleInfoIndex >= _scales.length) return "";
    final List<String> scaleInfo =
        _scales[scaleInfoIndex]; // Get [singular, nomPl, genPl]
    // Apply standard grammatical rules to the scale word forms
    return _getGrammaticalForm(count, scaleInfo[0], scaleInfo[1], scaleInfo[2]);
  }
}
