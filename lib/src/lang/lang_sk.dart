import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/sk_options.dart';
import '../utils/utils.dart';

/// {@template num2text_sk}
/// The Slovak language (`Lang.SK`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Slovak word representation following standard Slovak grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [SkOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (standard scale).
/// It correctly applies grammatical gender and case variations for units and currency.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [SkOptions].
/// {@endtemplate}
class Num2TextSK implements Num2TextBase {
  /// The word for zero.
  static const String _zero = "nula";

  /// The word for the decimal separator when using [DecimalSeparator.point] or [DecimalSeparator.period].
  static const String _pointWord = "bod";

  /// The word for the decimal separator when using [DecimalSeparator.comma].
  static const String _commaWord = "celá";

  /// The word for positive infinity.
  static const String _infinity = "Nekonečno";

  /// The word for negative infinity.
  static const String _negativeInfinity = "Mínus nekonečno";

  /// The word for "Not a Number" (NaN).
  static const String _nan = "Nie je číslo";

  /// Units words (0-19) for masculine gender (default). Index 0 is unused.
  static const List<String> _units = [
    "", // 0 index placeholder
    "jeden", // 1
    "dva", // 2
    "tri", // 3
    "štyri", // 4
    "päť", // 5
    "šesť", // 6
    "sedem", // 7
    "osem", // 8
    "deväť", // 9
    "desať", // 10
    "jedenásť", // 11
    "dvanásť", // 12
    "trinásť", // 13
    "štrnásť", // 14
    "pätnásť", // 15
    "šestnásť", // 16
    "sedemnásť", // 17
    "osemnásť", // 18
    "devätnásť", // 19
  ];

  /// Units words for 1 and 2 for feminine and neuter genders.
  /// Index 0 is placeholder, 1 is feminine "jedna", 2 is feminine/neuter "dve".
  static const List<String> _unitsFeminineNeuter = ["", "jedna", "dve"];

  /// Unit word for 1 for neuter gender ("jedno").
  static const String _unitNeuter1 = "jedno";

  /// Tens words (20, 30, ... 90). Index 0 and 1 are unused.
  static const List<String> _tens = [
    "", // 0
    "", // 1 (covered by _units)
    "dvadsať", // 20
    "tridsať", // 30
    "štyridsať", // 40
    "päťdesiat", // 50
    "šesťdesiat", // 60
    "sedemdesiat", // 70
    "osemdesiat", // 80
    "deväťdesiat", // 90
  ];

  /// Hundreds words (100, 200, ... 900). Index 0 is unused.
  static const List<String> _hundreds = [
    "", // 0
    "sto", // 100
    "dvesto", // 200
    "tristo", // 300
    "štyristo", // 400
    "päťsto", // 500
    "šesťsto", // 600
    "sedemsto", // 700
    "osemsto", // 800
    "deväťsto", // 900
  ];

  /// Special form for "one thousand".
  static const String _thousandSingular = "tisíc";

  /// Special form for "two thousand".
  static const String _twoThousand = "dvetisíc";

  /// Special form for "three thousand".
  static const String _threeThousand = "tritisíc";

  /// Special form for "four thousand".
  static const String _fourThousand = "štyritisíc";

  /// Scale words (million, billion, etc.) with grammatical forms.
  /// Each inner list contains: [singular (1), nominative plural (2-4), genitive plural (0, 5+)]
  static const List<List<String>> _scales = [
    // 10^6
    ["milión", "milióny", "miliónov"],
    // 10^9
    ["miliarda", "miliardy", "miliárd"],
    // 10^12
    ["bilión", "bilióny", "biliónov"],
    // 10^15
    ["biliarda", "biliardy", "biliárd"],
    // 10^18
    ["trilión", "trilióny", "triliónov"],
    // 10^21
    ["triliarda", "triliardy", "triliárd"],
    // 10^24
    ["kvadrilión", "kvadrilióny", "kvadriliónov"],
    // Add more scales here if needed following the pattern
  ];

  /// Processes the given number according to the specified options.
  ///
  /// This is the main entry point for the Slovak converter.
  /// It handles normalization, special number cases (infinity, NaN),
  /// negative numbers, and delegates to specific handlers based on the
  /// [options] (currency, year, standard).
  ///
  /// Parameters:
  /// - `number`: The number to convert (can be `int`, `double`, `BigInt`, `Decimal`, or `String`).
  /// - `options`: [BaseOptions] (usually [SkOptions]) specifying formatting details.
  /// - `fallbackOnError`: A custom string to return on conversion errors, instead of the default error messages.
  ///
  /// Returns:
  /// The word representation of the number in Slovak, or an error/fallback string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have Slovak-specific options, defaulting if none are provided.
    final SkOptions skOptions =
        options is SkOptions ? options : const SkOptions();
    final String effectiveFallback = fallbackOnError ?? _nan;

    // Handle special double values first.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? _negativeInfinity : _infinity;
      }
      if (number.isNaN) return effectiveFallback;
    }

    // Normalize the input number to Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return effectiveFallback; // Handle invalid input

    // Handle zero separately, considering currency format.
    if (decimalValue == Decimal.zero) {
      if (skOptions.currency) {
        // Use genitive plural for zero currency, defaulting to singular if not defined.
        final String unitName = skOptions.currencyInfo.mainUnitPluralGenitive ??
            skOptions.currencyInfo.mainUnitSingular;
        return "$_zero $unitName";
      } else {
        return _zero; // Just "nula" for standard zero.
      }
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for conversion logic.
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    // Delegate to specific handlers based on options.
    if (skOptions.format == Format.year) {
      if (!absValue.isInteger) {
        // Cannot format a non-integer year.
        return effectiveFallback;
      }
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), skOptions);
    } else if (skOptions.currency) {
      textResult = _handleCurrency(absValue, skOptions);
    } else {
      textResult = _handleStandardNumber(absValue, skOptions);
    }

    // Prepend the negative prefix if necessary (but not for years, handled in _handleYearFormat).
    if (isNegative && skOptions.format != Format.year) {
      textResult = "${skOptions.negativePrefix} $textResult";
    }
    return textResult;
  }

  /// Handles formatting a number as a year.
  ///
  /// Converts the integer part of the year to words.
  /// If the year is negative, it prepends the negative prefix specified in [options].
  /// Does not add BC/AD (pred n.l./n.l.) suffixes based on current logic.
  ///
  /// Parameters:
  /// - `year`: The year as a [BigInt].
  /// - `options`: The [SkOptions] containing the negative prefix.
  ///
  /// Returns:
  /// The year represented in Slovak words.
  String _handleYearFormat(BigInt year, SkOptions options) {
    final bool isNegative = year < BigInt.zero;
    final BigInt absYear = isNegative ? -year : year;
    // Years are typically treated as masculine cardinal numbers.
    String yearText = _convertInteger(absYear, Gender.masculine);

    if (isNegative) {
      // Prepend negative prefix if the original year was negative.
      yearText = "${options.negativePrefix} $yearText";
    }
    // No AD/BC suffix logic implemented here based on original code/tests.
    return yearText;
  }

  /// Handles formatting a number as currency.
  ///
  /// Separates the number into main and subunit values.
  /// Converts both parts to words, applying appropriate grammatical forms
  /// (singular, nominative plural, genitive plural) to the currency unit names
  /// based on the count. Uses gender rules: neuter for main unit (Euro), masculine for subunit (Cent).
  /// Optionally rounds the number to 2 decimal places.
  ///
  /// Parameters:
  /// - `absValue`: The absolute value of the currency amount as [Decimal].
  /// - `options`: The [SkOptions] containing currency info, rounding preference, and separator.
  ///
  /// Returns:
  /// The currency amount represented in Slovak words.
  String _handleCurrency(Decimal absValue, SkOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    const int decimalPlaces = 2; // Standard currency precision
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value if requested in options.
    final Decimal valueToConvert =
        options.round ? absValue.round(scale: decimalPlaces) : absValue;

    // Extract integer (main) and fractional (subunit) parts.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Round subunit value to handle potential precision issues.
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round().toBigInt();

    // Convert main value to words (using neuter for Euro: "jedno euro").
    final String mainText = _convertInteger(mainValue, Gender.neuter);
    // Get the correct grammatical form for the main unit name.
    final String mainUnitName = _getGrammaticalForm(
      mainValue,
      currencyInfo.mainUnitSingular,
      currencyInfo.mainUnitPlural2To4 ??
          currencyInfo.mainUnitSingular, // Fallback
      currencyInfo.mainUnitPluralGenitive ??
          currencyInfo.mainUnitSingular, // Fallback
    );

    // Start building the result string.
    String result = '$mainText $mainUnitName';

    // Add subunit part if it's greater than zero.
    if (subunitValue > BigInt.zero) {
      // Convert subunit value to words (using masculine for Cent: "jeden cent").
      final String subunitText =
          _convertInteger(subunitValue, Gender.masculine);
      // Get the correct grammatical form for the subunit name.
      final String subUnitName = _getGrammaticalForm(
        subunitValue,
        currencyInfo.subUnitSingular ?? "", // Fallback
        currencyInfo.subUnitPlural2To4 ?? "", // Fallback
        currencyInfo.subUnitPluralGenitive ?? "", // Fallback
      );
      // Use the separator defined in currencyInfo (e.g., "a").
      final String separator =
          currencyInfo.separator ?? ""; // Default to empty string

      // Append the subunit part to the result.
      result += ' $separator $subunitText $subUnitName';
    }
    return result;
  }

  /// Handles formatting a standard number (integer or decimal).
  ///
  /// Converts the integer part and the fractional part separately.
  /// Joins them using the appropriate decimal separator word ("celá" or "bod")
  /// based on [options.decimalSeparator]. Applies correct gender for fractional part conversion
  /// ("celá" -> feminine, "bod" -> masculine).
  ///
  /// Parameters:
  /// - `absValue`: The absolute value of the number as [Decimal].
  /// - `options`: The [SkOptions] specifying the decimal separator preference.
  ///
  /// Returns:
  /// The number represented in Slovak words.
  String _handleStandardNumber(Decimal absValue, SkOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part. If integer is zero but decimal exists, use "nula".
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(
                integerPart, Gender.masculine); // Default to masculine

    String fractionalWords = '';
    // Process fractional part only if it's non-zero.
    if (fractionalPart > Decimal.zero) {
      String separatorWord;
      Gender fractionalGender;
      // Determine separator word and gender based on options.
      switch (options.decimalSeparator) {
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          separatorWord = _pointWord;
          fractionalGender = Gender.masculine; // "bod" implies masculine count
          break;
        case DecimalSeparator.comma:
        default: // Default to comma ("celá")
          separatorWord = _commaWord;
          fractionalGender = Gender.feminine; // "celá" implies feminine count
          break;
      }

      // Convert the fractional part to an integer for word conversion.
      final int scale = absValue.scale;
      // Use Decimal power to avoid potential double precision issues.
      final Decimal scaleMultiplier =
          Decimal.fromInt(10).pow(scale < 0 ? 0 : scale).toDecimal();
      final BigInt fractionalInt =
          (fractionalPart * scaleMultiplier).truncate().toBigInt();

      // Only add decimal part if it results in a non-zero integer.
      if (fractionalInt > BigInt.zero) {
        // Convert fractional integer using the determined gender.
        final String fractionalNumText =
            _convertInteger(fractionalInt, fractionalGender);
        fractionalWords = ' $separatorWord $fractionalNumText';
      } else if (integerPart == BigInt.zero) {
        // If integer was zero and fractional part rounds to zero (e.g., 0.00), return "nula".
        return _zero;
      }
    } else if (integerPart == BigInt.zero && fractionalPart == Decimal.zero) {
      // Explicitly handle the case where the input was exactly zero.
      return _zero;
    }

    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Selects the correct grammatical form of a noun based on the count.
  ///
  /// Implements Slovak grammar rules for number agreement:
  /// - Count 1: Singular form (`sing`)
  /// - Count 2-4 (except 12-14): Nominative Plural form (`nomPl`)
  /// - Count 0, 5+, 11-19: Genitive Plural form (`genPl`)
  ///
  /// Parameters:
  /// - `count`: The number determining the form.
  /// - `sing`: The singular form of the noun.
  /// - `nomPl`: The nominative plural form (for counts 2-4).
  /// - `genPl`: The genitive plural form (for counts 0, 5+).
  ///
  /// Returns:
  /// The grammatically correct form of the noun.
  String _getGrammaticalForm(
      BigInt count, String sing, String nomPl, String genPl) {
    final BigInt absCount = count.abs();
    if (absCount == BigInt.one) return sing; // Rule for 1

    // Check last two digits first for exceptions (11-19)
    final int lastTwoDigits = (absCount % BigInt.from(100)).toInt();
    if (lastTwoDigits >= 11 && lastTwoDigits <= 19)
      return genPl; // Rule for 11-19

    // Check last digit for standard rules
    final int lastDigit = (absCount % BigInt.from(10)).toInt();
    if (lastDigit >= 2 && lastDigit <= 4) return nomPl; // Rule for 2, 3, 4

    return genPl; // Rule for 0, 5, 6, 7, 8, 9
  }

  /// Selects the correct grammatical form for a scale word (million, billion, etc.).
  ///
  /// Uses [_getGrammaticalForm] with the appropriate forms from the [_scales] list.
  ///
  /// Parameters:
  /// - `count`: The number of this scale unit (e.g., 3 for "tri milióny").
  /// - `scaleInfoIndex`: The index into the [_scales] list (0 for million, 1 for billion, etc.).
  ///
  /// Returns:
  /// The correct grammatical form of the scale word, or an empty string if index is invalid.
  String _getScaleForm(BigInt count, int scaleInfoIndex) {
    if (scaleInfoIndex < 0 || scaleInfoIndex >= _scales.length) return "";
    final List<String> scaleInfo = _scales[scaleInfoIndex];
    return _getGrammaticalForm(count, scaleInfo[0], scaleInfo[1], scaleInfo[2]);
  }

  /// Removes spaces from a string. Used specifically for thousand compounds.
  ///
  /// Example: "dvadsať " -> "dvadsať", for creating "dvadsaťtisíc".
  String _removeSpaces(String text) {
    return text.replaceAll(" ", "");
  }

  /// Converts a non-negative integer to Slovak words.
  ///
  /// Handles large numbers by processing them in chunks of three digits (thousands).
  /// Applies scale words (tisíc, milión, miliarda, etc.) with correct grammatical forms.
  /// Handles special Slovak forms for thousands (dvetisíc, tritisíc, štyritisíc, Xtisíc).
  ///
  /// Parameters:
  /// - `n`: The non-negative integer to convert.
  /// - `gender`: The grammatical gender to apply to the least significant chunk (0-999),
  ///   important for agreement with 'jeden'/'jedna'/'jedno' and 'dva'/'dve'.
  ///
  /// Returns:
  /// The integer represented in Slovak words.
  /// Throws [ArgumentError] if `n` is negative.
  String _convertInteger(BigInt n, Gender gender) {
    if (n < BigInt.zero) {
      // This function should only handle non-negative numbers.
      throw ArgumentError("Negative input to _convertInteger: $n");
    }
    if (n == BigInt.zero) return _zero;

    // Handle numbers less than 1000 directly using _convertChunk.
    if (n < BigInt.from(1000)) return _convertChunk(n.toInt(), gender);

    final List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleLevel =
        0; // 0: units, 1: thousands, 2: millions, 3: billions, etc.
    BigInt currentN = n;

    // Process the number in chunks of 1000 from right to left.
    while (currentN > BigInt.zero) {
      final BigInt chunkValue = currentN % oneThousand;
      currentN ~/= oneThousand; // Move to the next chunk leftwards

      if (chunkValue > BigInt.zero) {
        String chunkText = "";
        String scaleWord = "";
        Gender chunkGender =
            Gender.masculine; // Default gender for higher chunks

        if (scaleLevel == 0) {
          // The least significant chunk (0-999) uses the provided gender.
          chunkGender = gender;
          chunkText = _convertChunk(chunkValue.toInt(), chunkGender);
        } else if (scaleLevel == 1) {
          // Special handling for thousands scale.
          chunkGender = Gender.masculine; // Thousands scale itself is masculine

          // Handle special forms 1000, 2000, 3000, 4000 explicitly.
          if (chunkValue == BigInt.one) {
            scaleWord = _thousandSingular;
            // No preceding number needed for "tisíc".
          } else if (chunkValue == BigInt.two) {
            scaleWord = _twoThousand;
          } else if (chunkValue == BigInt.from(3)) {
            scaleWord = _threeThousand;
          } else if (chunkValue == BigInt.from(4)) {
            scaleWord = _fourThousand;
          } else {
            // For 5000+, create compound form like "päťtisíc", "dvadsaťtisíc".
            final String tempChunkText =
                _convertChunk(chunkValue.toInt(), chunkGender);
            // Combine the number word (with spaces removed) and "tisíc".
            scaleWord = "${_removeSpaces(tempChunkText)}tisíc";
          }
          // chunkText remains empty as the number is part of the scaleWord.
        } else {
          // Handling for millions and higher scales.
          final int scaleInfoIndex = scaleLevel - 2; // Index into _scales array
          if (scaleInfoIndex >= 0 && scaleInfoIndex < _scales.length) {
            // Determine gender based on scale (milión=masc, miliarda=fem, bilión=masc...)
            chunkGender =
                (scaleInfoIndex % 2 == 0) ? Gender.masculine : Gender.feminine;
            // Convert the chunk number (e.g., "sto dvadsať tri" for 123 million).
            chunkText = _convertChunk(chunkValue.toInt(), chunkGender);
            // Get the correct scale word form (e.g., "milióny").
            scaleWord = _getScaleForm(chunkValue, scaleInfoIndex);
          } else {
            // Fallback for scales beyond the defined _scales list.
            chunkText = _convertChunk(chunkValue.toInt(), Gender.masculine);
            scaleWord =
                "[MierkaPrílišVeľká]"; // Placeholder for unsupported large scales
          }
        }

        // Combine the chunk text and scale word (if available).
        String combinedPart;
        if (chunkText.isNotEmpty && scaleWord.isNotEmpty) {
          combinedPart = "$chunkText $scaleWord";
        } else {
          // Use whichever part is not empty.
          combinedPart = chunkText.isNotEmpty ? chunkText : scaleWord;
        }

        // Add the processed part to the list if it's not empty.
        if (combinedPart.isNotEmpty) {
          parts.add(combinedPart);
        }
      }
      scaleLevel++; // Increment scale level for the next chunk.
    }

    // Join the parts in reverse order (since we processed right-to-left) with spaces.
    return parts.reversed.join(' ');
  }

  /// Converts a three-digit number (0-999) to Slovak words.
  ///
  /// Handles hundreds, tens, and units, applying grammatical gender rules
  /// for 'one' and 'two'.
  ///
  /// Parameters:
  /// - `n`: The integer chunk (0-999).
  /// - `gender`: The grammatical gender required for this chunk, affecting
  ///   the forms of 'one' ('jeden'/'jedna'/'jedno') and 'two' ('dva'/'dve').
  ///
  /// Returns:
  /// The number chunk represented in Slovak words, or an empty string for 0.
  /// Throws [ArgumentError] if `n` is outside the 0-999 range.
  String _convertChunk(int n, Gender gender) {
    if (n == 0) return ""; // No words for zero chunk.
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }

    final List<String> words = [];
    int remainder = n;

    // Process hundreds place.
    if (remainder >= 100) {
      words.add(_hundreds[remainder ~/ 100]);
      remainder %= 100;
      if (remainder > 0) {
        // Add space if there are tens/units following.
        words.add(" ");
      }
    }

    // Process tens and units place (0-99).
    if (remainder > 0) {
      if (remainder < 20) {
        // Numbers 1-19 use the _units list directly, applying gender for 1 and 2.
        if (remainder == 1) {
          words.add(
            (gender == Gender.neuter)
                ? _unitNeuter1 // "jedno"
                : (gender == Gender.feminine
                    ? _unitsFeminineNeuter[1] // "jedna"
                    : _units[1]), // "jeden" (masculine default)
          );
        } else if (remainder == 2) {
          words.add(
            (gender == Gender.feminine || gender == Gender.neuter)
                ? _unitsFeminineNeuter[2] // "dve"
                : _units[2], // "dva" (masculine default)
          );
        } else {
          // 3-19 use standard masculine forms from _units.
          words.add(_units[remainder]);
        }
      } else {
        // Numbers 20-99.
        words.add(_tens[
            remainder ~/ 10]); // Add the ten's word (dvadsať, tridsať, etc.).
        final int unit = remainder % 10;
        if (unit > 0) {
          // Add space before the unit word.
          words.add(" ");
          // Apply gender rules for units 1 and 2 within tens (e.g., dvadsať jeden/jedna/jedno).
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
            // Units 3-9 use standard forms.
            words.add(_units[unit]);
          }
        }
      }
    }

    // Join the collected words (hundreds, tens, units) into a single string.
    return words.join('');
  }
}
