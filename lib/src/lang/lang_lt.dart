import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/lt_options.dart';
import '../utils/utils.dart';

/// {@template num2text_lt}
/// The Lithuanian language (Lang.LT) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Lithuanian word representation following standard Lithuanian grammar and vocabulary,
/// paying close attention to number agreement (declension).
///
/// Capabilities include handling cardinal numbers, currency (using [LtOptions.currencyInfo], applying correct grammatical cases),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers using the short scale.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [LtOptions].
/// {@endtemplate}
class Num2TextLT implements Num2TextBase {
  /// The Lithuanian word for zero.
  static const String _zero = "nulis";

  /// The Lithuanian word for a decimal point (period).
  static const String _point = "taškas";

  /// The Lithuanian word for a decimal comma.
  static const String _comma = "kablelis";

  /// Lithuanian words for numbers 0-19 (masculine nominative form).
  /// Used as the default for cardinal numbers and scale counts.
  static const List<String> _wordsUnder20Masc = [
    "nulis", // 0
    "vienas", // 1
    "du", // 2
    "trys", // 3
    "keturi", // 4
    "penki", // 5
    "šeši", // 6
    "septyni", // 7
    "aštuoni", // 8
    "devyni", // 9
    "dešimt", // 10
    "vienuolika", // 11
    "dvylika", // 12
    "trylika", // 13
    "keturiolika", // 14
    "penkiolika", // 15
    "šešiolika", // 16
    "septyniolika", // 17
    "aštuoniolika", // 18
    "devyniolika", // 19
  ];

  /// Lithuanian words for numbers 0-9 (feminine nominative form).
  /// Used when the context requires feminine agreement (not extensively used in this implementation).
  static const List<String> _wordsUnder20Fem = [
    "nulis", // 0
    "viena", // 1
    "dvi", // 2
    "trys", // 3 (same as masculine)
    "keturios", // 4
    "penkios", // 5
    "šešios", // 6
    "septynios", // 7
    "aštuonios", // 8
    "devynios", // 9
    // Note: 10-19 use the standard forms (_wordsUnder20Masc) regardless of gender context usually.
  ];

  /// Lithuanian words for tens (20, 30,... 90).
  static const List<String> _wordsTens = [
    "", // 0 (unused placeholder)
    "dešimt", // 10 (handled by _wordsUnder20Masc)
    "dvidešimt", // 20
    "trisdešimt", // 30
    "keturiasdešimt", // 40
    "penkiasdešimt", // 50
    "šešiasdešimt", // 60
    "septyniasdešimt", // 70
    "aštuoniasdešimt", // 80
    "devyniasdešimt", // 90
  ];

  /// Lithuanian word for "hundred" (singular nominative).
  static const String _hundredSingular = "šimtas";

  /// Lithuanian word for "hundreds" (plural nominative).
  static const String _hundredPlural = "šimtai";

  /// Lithuanian scale words (thousands, millions, etc.) with their grammatical forms.
  /// Keys are scale indices (0: units, 1: thousands, 2: millions, ...).
  /// Values are maps containing:
  /// - 'singular': Nominative singular form (used with count ending in 1, excluding 11).
  /// - 'plural_nom': Nominative plural form (used with count ending in 2-9, excluding 12-19).
  /// - 'plural_gen': Genitive plural form (used with count ending in 0 or 10-19).
  static const Map<int, Map<String, String>> _scaleWordsMasc = {
    0: {
      'singular': '',
      'plural_nom': '',
      'plural_gen': ''
    }, // Base case (units < 1000)
    1: {
      'singular': 'tūkstantis',
      'plural_nom': 'tūkstančiai',
      'plural_gen': 'tūkstančių'
    },
    2: {
      'singular': 'milijonas',
      'plural_nom': 'milijonai',
      'plural_gen': 'milijonų'
    },
    3: {
      'singular': 'milijardas',
      'plural_nom': 'milijardai',
      'plural_gen': 'milijardų'
    },
    4: {
      'singular': 'trilijonas',
      'plural_nom': 'trilijonai',
      'plural_gen': 'trilijonų'
    },
    5: {
      'singular': 'kvadrilijonas',
      'plural_nom': 'kvadrilijonai',
      'plural_gen': 'kvadrilijonų'
    },
    6: {
      'singular': 'kvintilijonas',
      'plural_nom': 'kvintilijonai',
      'plural_gen': 'kvintilijonų'
    },
    7: {
      'singular': 'sekstilijonas',
      'plural_nom': 'sekstilijonai',
      'plural_gen': 'sekstilijonų'
    },
    8: {
      'singular': 'septilijonas',
      'plural_nom': 'septilijonai',
      'plural_gen': 'septilijonų'
    },
    // Add more scales as needed
  };

  /// Processes the given number (int, double, BigInt, Decimal, String) and converts it to Lithuanian words.
  ///
  /// - [number]: The number to convert. Handles various numeric types.
  /// - [options]: An optional `LtOptions` object to customize conversion (e.g., currency, year format, decimal separator).
  /// - [fallbackOnError]: An optional string to return if conversion fails (e.g., invalid input).
  ///   If not provided, internal defaults like "Ne skaičius" (Not a number) are used.
  /// Returns the number formatted as Lithuanian words, or an error/fallback string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final LtOptions ltOptions =
        options is LtOptions ? options : const LtOptions();
    final String errorMsg =
        fallbackOnError ?? "Ne skaičius"; // Default error message

    // Handle special double values first
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? "Neigiama begalybė" : "Begalybė";
      }
      if (number.isNaN) {
        return errorMsg;
      }
    }

    // Normalize the input number to Decimal for consistent handling
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Handle invalid or null input
    if (decimalValue == null) {
      return errorMsg;
    }

    // Handle zero separately
    if (decimalValue == Decimal.zero) {
      // Currency format requires the unit name even for zero
      if (ltOptions.currency) {
        // Lithuanian uses genitive plural for zero count
        // Fallback logic ensures a name is used even if specific forms are missing
        return "$_zero ${ltOptions.currencyInfo.mainUnitPluralGenitive ?? ltOptions.currencyInfo.mainUnitPlural ?? ltOptions.currencyInfo.mainUnitSingular}";
      } else {
        return _zero;
      }
    }

    // Determine sign and use absolute value for core conversion
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Route to specific handlers based on options
    if (ltOptions.format == Format.year) {
      // Year format: Convert the absolute integer part.
      textResult = _handleYearFormat(absValue.truncate().toBigInt(), ltOptions);
    } else if (ltOptions.currency) {
      // Currency format involves main and sub-units with grammatical agreement
      textResult = _handleCurrency(absValue, ltOptions);
    } else {
      // Standard number conversion (integer and decimal parts)
      textResult = _handleStandardNumber(absValue, ltOptions);
    }

    // Prepend negative prefix if the original number was negative.
    // This applies regardless of the format (standard, currency, or year).
    if (isNegative) {
      textResult = "${ltOptions.negativePrefix} $textResult";
    }

    // Return the final trimmed result
    return textResult.trim();
  }

  /// Handles the specific formatting for years.
  ///
  /// Converts the absolute value of the year to words using the standard masculine form.
  /// The negative prefix is handled by the main `process` method.
  /// Lithuanian year conversion in this context doesn't typically add era suffixes (AD/BC).
  ///
  /// - [year]: The absolute value of the year as a BigInt.
  /// - [options]: The LtOptions object (currently unused in this specific method).
  /// Returns the absolute year formatted as Lithuanian words.
  String _handleYearFormat(BigInt year, LtOptions options) {
    // Convert the absolute year value using standard integer conversion (masculine).
    // The negative prefix is handled in the calling `process` method.
    return _convertInteger(year, Gender.masculine);
  }

  /// Handles the formatting of numbers as currency (Euro by default for LT).
  ///
  /// Converts the number into main units (e.g., "eurai") and subunits (e.g., "centai"),
  /// applying correct Lithuanian grammatical forms based on the quantity.
  ///
  /// - [absValue]: The absolute decimal value of the currency amount.
  /// - [options]: The LtOptions containing currency settings ([currencyInfo], [round]).
  /// Returns the currency amount formatted as Lithuanian words.
  String _handleCurrency(Decimal absValue, LtOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2; // Standard for Euro
    final Decimal subunitMultiplier = Decimal.fromInt(100); // 1 Euro = 100 Cent

    // Round the value if requested, otherwise use as is
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main and subunit values
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Ensure subunit calculation rounds correctly to avoid precision errors
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round().toBigInt();

    // Convert the main unit value to words (masculine assumed for Euro)
    String mainText = _convertInteger(mainValue, Gender.masculine);
    // Get the grammatically correct name for the main unit (euras/eurai/eurų)
    String mainUnitName = _getUnitName(
      mainValue,
      currencyInfo.mainUnitSingular,
      currencyInfo.mainUnitPlural, // Nominative Plural (2-9)
      currencyInfo.mainUnitPluralGenitive, // Genitive Plural (0, 10-19)
    );

    List<String> resultParts = ['$mainText $mainUnitName'];

    // Add subunit part if it exists
    if (subunitValue > BigInt.zero) {
      // Convert subunit value to words (masculine assumed for Cent)
      String subunitText = _convertInteger(subunitValue, Gender.masculine);
      // Get the grammatically correct name for the subunit (centas/centai/centų)
      // Ensure subunit names exist in CurrencyInfo, provide fallback if needed
      String subUnitName = _getUnitName(
        subunitValue,
        currencyInfo.subUnitSingular ??
            '', // Fallback to empty if singular missing
        currencyInfo.subUnitPlural, // Nominative Plural
        currencyInfo.subUnitPluralGenitive, // Genitive Plural
      );

      // Avoid adding part if subunit name is missing
      if (subUnitName.isNotEmpty) {
        // Lithuanian doesn't typically use a conjunction like "ir" (and) here.
        // Just concatenate with space.
        resultParts.add('$subunitText $subUnitName');
      }
    }

    return resultParts.join(' '); // Join parts with space
  }

  /// Determines the correct grammatical form (case and number) of a noun (unit/scale word) based on the preceding number.
  ///
  /// Implements Lithuanian grammar rules for number agreement:
  /// - Ends in 1 (but not 11): Nominative Singular (e.g., "vienas euras")
  /// - Ends in 2-9 (but not 12-19): Nominative Plural (e.g., "du eurai")
  /// - Ends in 0 or 10-19: Genitive Plural (e.g., "nuliz eurų", "dešimt eurų")
  ///
  /// - [value]: The number determining the grammatical form.
  /// - [singular]: The nominative singular form of the noun.
  /// - [pluralNom]: The nominative plural form of the noun (optional, falls back to singular).
  /// - [pluralGen]: The genitive plural form of the noun (optional, falls back to pluralNom).
  /// Returns the appropriate noun form as a string.
  String _getUnitName(
      BigInt value, String singular, String? pluralNom, String? pluralGen) {
    // Ensure fallbacks if specific forms are missing
    pluralNom ??= singular;
    pluralGen ??=
        pluralNom; // Fallback chain: Genitive -> Nominative Plural -> Singular

    // Rule for 0: Genitive Plural
    if (value == BigInt.zero) {
      return pluralGen;
    }

    // Check last two digits for 10-19 exception
    int lastTwo = (value % BigInt.from(100)).toInt();
    if (lastTwo >= 10 && lastTwo <= 19) {
      return pluralGen; // Rule for 10-19: Genitive Plural
    }

    // Check last digit for other rules
    int lastDigit = (value % BigInt.from(10)).toInt();
    switch (lastDigit) {
      case 0:
        return pluralGen; // Rule for ends in 0: Genitive Plural
      case 1:
        return singular; // Rule for ends in 1: Nominative Singular
      default: // Covers 2-9
        return pluralNom; // Rule for ends in 2-9: Nominative Plural
    }
  }

  /// Handles standard number conversion, including integer and fractional parts.
  ///
  /// - [absValue]: The absolute decimal value to convert.
  /// - [options]: The LtOptions object, used for decimal separator choice.
  /// Returns the number formatted as Lithuanian words.
  String _handleStandardNumber(Decimal absValue, LtOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part, handling case "0.5" -> "nulis kablelis penki"
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(
                integerPart,
                Gender.masculine,
              ); // Assume masculine for general numbers

    String fractionalWords = '';
    // Check if there's a fractional part to convert
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word based on options
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.point:
          separatorWord = _point; // "taškas"
          break;
        case DecimalSeparator.period: // Treat period as point
          separatorWord = _point;
          break;
        case DecimalSeparator.comma:
        default: // Default to comma if null or comma
          separatorWord = _comma; // "kablelis"
          break;
      }

      // Convert fractional digits individually
      // Note: This reads digits like "point four five six", not "point four hundred fifty-six"
      String fractionalDigits = absValue.toString().split('.').last;
      List<String> digitWords = fractionalDigits.split('').map((digit) {
        final int? digitInt = int.tryParse(digit);
        // Use masculine form for digits after decimal point
        return (digitInt != null &&
                digitInt >= 0 &&
                digitInt < _wordsUnder20Masc.length)
            ? _wordsUnder20Masc[digitInt]
            : '?'; // Fallback for non-digit chars
      }).toList();
      fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
    }
    // No special handling needed for trailing ".0" - `fractionalPart` will be zero.

    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer (BigInt) into Lithuanian words.
  ///
  /// Handles large numbers by breaking them into chunks of thousands and applying scale words
  /// with correct grammatical agreement.
  ///
  /// - [n]: The non-negative integer to convert.
  /// - [gender]: The grammatical gender context (primarily affects "vienas/viena", "du/dvi").
  ///          Defaults to masculine in most calls within this implementation.
  /// Throws [ArgumentError] if the number is too large for the defined scales.
  /// Returns the integer as Lithuanian words.
  String _convertInteger(BigInt n, Gender gender) {
    if (n == BigInt.zero) return _zero;
    // Precondition: Ensure input is non-negative
    assert(n > BigInt.zero);

    // Handle numbers under 1000 directly
    if (n < BigInt.from(1000)) {
      return _convertUnder1000(n.toInt(), gender);
    }

    // Process larger numbers in chunks of 1000
    List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0; // 0: units, 1: thousands, 2: millions, ...
    BigInt remaining = n;

    while (remaining > BigInt.zero) {
      // Ensure the scale is defined
      if (!_scaleWordsMasc.containsKey(scaleIndex)) {
        throw ArgumentError(
          "Number too large: exceeds defined scale index $scaleIndex for value $n",
        );
      }

      // Get the current chunk (0-999)
      BigInt chunk = remaining % oneThousand;
      remaining ~/= oneThousand; // Move to the next chunk

      if (chunk > BigInt.zero) {
        // Convert the chunk (0-999) to words. Masculine is used for scale counts.
        String chunkText = _convertUnder1000(chunk.toInt(), Gender.masculine);

        String scaleWord = "";
        // Add scale word (tūkstantis, milijonas, etc.) if applicable (scaleIndex > 0)
        if (scaleIndex > 0) {
          final scaleInfo = _scaleWordsMasc[scaleIndex]!;
          // Get the grammatically correct form of the scale word based on the chunk value
          scaleWord = _getUnitName(
            chunk, // The number governing the scale word's form
            scaleInfo['singular']!,
            scaleInfo['plural_nom'],
            scaleInfo['plural_gen'],
          );
        }

        // Combine chunk text and scale word
        if (scaleWord.isNotEmpty) {
          parts.add("$chunkText $scaleWord");
        } else {
          // Only for scaleIndex 0 (units < 1000)
          parts.add(chunkText);
        }
      }
      scaleIndex++; // Move to the next scale (thousands, millions, ...)
    }

    // Join the parts in reverse order (largest scale first)
    return parts.reversed.join(' ');
  }

  /// Converts an integer between 0 and 999 into Lithuanian words.
  /// Returns an empty string for 0.
  ///
  /// - [n]: The integer to convert (0 <= n < 1000).
  /// - [gender]: The grammatical gender context.
  /// Returns the number as Lithuanian words, or "" if n is 0.
  String _convertUnder1000(int n, Gender gender) {
    if (n == 0) return "";
    // Precondition check
    assert(n > 0 && n < 1000);

    // Delegate numbers under 100
    if (n < 100) return _convertUnder100(n, gender);

    List<String> words = [];
    int remainder = n;

    // Handle hundreds part
    int hundredsDigit = remainder ~/ 100;
    // Note: hundredsDigit > 0 since n >= 100
    // Use masculine "vienas" for "one hundred" count
    words.add(_wordsUnder20Masc[hundredsDigit]);
    // Add "šimtas" (100) or "šimtai" (200-900)
    words.add((hundredsDigit == 1) ? _hundredSingular : _hundredPlural);
    remainder %= 100; // Get the remainder (0-99)

    // Handle the remainder (0-99) if non-zero
    if (remainder > 0) {
      words.add(_convertUnder100(remainder, gender));
    }

    return words.join(' ');
  }

  /// Converts an integer between 0 and 99 into Lithuanian words.
  /// Returns an empty string for 0.
  ///
  /// - [n]: The integer to convert (0 <= n < 100).
  /// - [gender]: The grammatical gender context (affects 1 vs viena, 2 vs dvi, etc.).
  /// Returns the number as Lithuanian words, or "" if n is 0.
  String _convertUnder100(int n, Gender gender) {
    if (n == 0) return "";
    // Precondition check
    assert(n > 0 && n < 100);

    // Get the correct list of words (masculine/feminine) for 0-19 based on gender
    final List<String> wordsUnder20 = _getWordsUnder20(gender);

    // Numbers under 20 are directly looked up
    if (n < 20) return wordsUnder20[n];

    // Numbers 20 and above
    int tensDigit = n ~/ 10; // 2 for 2x, 3 for 3x, etc.
    int unitDigit = n % 10; // 0-9

    String tensWord = _wordsTens[tensDigit]; // e.g., "dvidešimt"

    // If it's a round ten (20, 30, ...), return the tens word directly
    if (unitDigit == 0) {
      return tensWord;
    } else {
      // Combine tens word and unit word (e.g., "dvidešimt" + " " + "vienas")
      // Use the gender-appropriate word for the unit digit.
      return "$tensWord ${wordsUnder20[unitDigit]}";
    }
  }

  /// Selects the appropriate list of words for 0-19 based on gender.
  /// Defaults to masculine if gender is not feminine.
  ///
  /// - [gender]: The required grammatical gender.
  /// Returns the list `_wordsUnder20Masc` or `_wordsUnder20Fem`.
  List<String> _getWordsUnder20(Gender gender) {
    // Note: _wordsUnder20Fem only defines 0-9 differently. 10-19 typically use masculine forms.
    // This implementation mostly defaults to masculine.
    return gender == Gender.feminine ? _wordsUnder20Fem : _wordsUnder20Masc;
  }
}
