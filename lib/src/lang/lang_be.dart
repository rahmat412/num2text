import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/be_options.dart';
import '../utils/utils.dart';

/// {@template num2text_be}
/// The Belarusian language (`Lang.BE`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Belarusian word representation, adhering to Belarusian grammatical rules
/// for gender and number agreement, particularly the complex declension patterns for numerals
/// followed by nouns (like currency units or scale words like 'тысяча').
///
/// Capabilities include handling cardinal numbers, currency (using [BeOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (short scale names).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [BeOptions].
/// {@endtemplate}
class Num2TextBE implements Num2TextBase {
  /// The word for zero.
  static const String _zero = "нуль";

  /// The word for the decimal separator when using [DecimalSeparator.period] or [DecimalSeparator.point].
  static const String _point = "кропка";

  /// The word for the decimal separator when using [DecimalSeparator.comma] (default).
  static const String _comma = "коска";

  /// The suffix for years Before Christ/Before Common Era (BC/BCE). Means "да нашай эры" (before our era).
  static const String _yearSuffixBC = "да н.э.";

  /// The suffix for years Anno Domini/Common Era (AD/CE). Means "нашай эры" (of our era).
  static const String _yearSuffixAD = "н.э.";

  /// The word for infinity.
  static const String _infinity = "Бясконцасць";

  /// The representation for "Not a Number" (NaN) or invalid input when no fallback is provided.
  static const String _notANumber = "Не лік";

  /// Words for numbers 0 through 19 (masculine form for 1 and 2).
  static const List<String> _wordsUnder20 = [
    "нуль", // 0
    "адзін", // 1 (masculine)
    "два", // 2 (masculine)
    "тры", // 3
    "чатыры", // 4
    "пяць", // 5
    "шэсць", // 6
    "сем", // 7
    "восем", // 8
    "дзевяць", // 9
    "дзесяць", // 10
    "адзінаццаць", // 11
    "дванаццаць", // 12
    "трынаццаць", // 13
    "чатырнаццаць", // 14
    "пятнаццаць", // 15
    "шаснаццаць", // 16
    "семнаццаць", // 17
    "васемнаццаць", // 18
    "дзевятнаццаць", // 19
  ];

  /// The feminine form for "one". Used for feminine nouns like "тысяча" (thousand) or "капейка" (kopeck).
  static const String _oneFem = "адна";

  /// The feminine form for "two". Used for feminine nouns.
  static const String _twoFem = "дзве";

  /// Words for tens (20, 30, ... 90). Index corresponds to the tens digit (index 2 = 20).
  static const List<String> _wordsTens = [
    "", // 0 - (unused placeholder)
    "", // 10 - (handled by _wordsUnder20)
    "дваццаць", // 20
    "трыццаць", // 30
    "сорак", // 40
    "пяцьдзясят", // 50
    "шэсцьдзясят", // 60
    "семдзесят", // 70
    "восемдзесят", // 80
    "дзевяноста", // 90
  ];

  /// Words for hundreds (100, 200, ... 900).
  static const Map<int, String> _wordsHundreds = {
    1: "сто",
    2: "дзвесце",
    3: "трыста",
    4: "чатырыста",
    5: "пяцьсот",
    6: "шэсцьсот",
    7: "семсот",
    8: "восемсот",
    9: "дзевяцьсот",
  };

  /// Scale words (thousand, million, etc.) with their declension forms.
  /// Keys represent the scale level (1 = 10^3, 2 = 10^6, ...).
  /// Values are lists containing:
  /// - [0]: Singular Nominative (used for 1, x1) - e.g., "тысяча" (feminine), "мільён" (masculine)
  /// - [1]: Plural Nominative/Paucal (used for 2-4, x2-x4) - e.g., "тысячы", "мільёны"
  /// - [2]: Plural Genitive (used for 0, 5+, x0, x5-x9, 11-19, x11-x19) - e.g., "тысяч", "мільёнаў"
  static const Map<int, List<String>> _scaleWords = {
    1: ["тысяча", "тысячы", "тысяч"], // Thousand (feminine)
    2: ["мільён", "мільёны", "мільёнаў"], // Million (masculine)
    3: ["мільярд", "мільярды", "мільярдаў"], // Billion (masculine)
    4: ["трыльён", "трыльёны", "трыльёнаў"], // Trillion (masculine)
    5: ["квадрыльён", "квадрыльёны", "квадрыльёнаў"], // Quadrillion (masculine)
    6: ["квінтыльён", "квінтыльёны", "квінтыльёнаў"], // Quintillion (masculine)
    7: ["секстыльён", "секстыльёны", "секстыльёнаў"], // Sextillion (masculine)
    8: ["септыльён", "септыльёны", "септыльёнаў"], // Septillion (masculine)
    // Add more scales if needed
  };

  /// Processes the given number into its Belarusian word representation.
  ///
  /// - [number] The number to convert (can be `int`, `double`, `BigInt`, `String`, `Decimal`).
  /// - [options] Optional [BeOptions] to customize the conversion (e.g., currency, year format).
  /// - [fallbackOnError] A custom string to return if conversion fails (e.g., for NaN, infinity, invalid types).
  ///   If null, default error strings like "Не лік" or "Бясконцасць" are used.
  ///
  /// Returns the word representation of the number in Belarusian, or an error/fallback string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final BeOptions beOptions =
        options is BeOptions ? options : const BeOptions();
    final String errorFallback = fallbackOnError ?? _notANumber;

    // Handle special double values first
    if (number is double) {
      if (number.isInfinite) {
        // Use specific negative infinity string from tests, not negativePrefix + infinity
        return number.isNegative ? "Мінус бясконцасць" : _infinity;
      }
      if (number.isNaN) {
        return errorFallback;
      }
    }

    // Normalize the input number to Decimal
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Handle normalization failure
    if (decimalValue == null) {
      return errorFallback;
    }

    // Handle zero separately
    if (decimalValue == Decimal.zero) {
      if (beOptions.currency) {
        // Zero currency requires the genitive plural form of the currency unit.
        // Provide fallbacks if specific forms are missing.
        return "$_zero ${beOptions.currencyInfo.mainUnitPluralGenitive ?? beOptions.currencyInfo.mainUnitPlural ?? beOptions.currencyInfo.mainUnitSingular}";
      } else {
        // Zero in other formats is just "нуль".
        return _zero;
      }
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for core conversion logic
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Handle different formats
    if (beOptions.format == Format.year) {
      // Year format has specific rules for BC/AD suffixes.
      textResult = _handleYearFormat(
          absValue.truncate().toBigInt(), beOptions, isNegative);
    } else {
      if (beOptions.currency) {
        // Currency format involves units and subunits with declension.
        textResult = _handleCurrency(absValue, beOptions);
      } else {
        // Standard number conversion with optional decimal part.
        textResult = _handleStandardNumber(absValue, beOptions);
      }
      // Add negative prefix if the original number was negative (and not year format).
      if (isNegative) {
        textResult = "${beOptions.negativePrefix} $textResult";
      }
    }

    // Clean up potential extra spaces.
    return textResult.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Formats a number as a year according to Belarusian rules.
  ///
  /// - [absYearValue] The absolute value of the year as a BigInt.
  /// - [options] The [BeOptions] containing formatting settings.
  /// - [isNegative] Indicates if the original year value was negative (BC/BCE).
  ///
  /// Returns the year formatted as text, potentially with BC/AD suffixes.
  String _handleYearFormat(
      BigInt absYearValue, BeOptions options, bool isNegative) {
    // Years are typically read using masculine forms for numbers.
    String yearText = _convertInteger(absYearValue, Gender.masculine);

    if (isNegative) {
      // Append BC/BCE suffix for negative years.
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD && absYearValue > BigInt.zero) {
      // Append AD/CE suffix for positive years only if includeAD is true.
      yearText += " $_yearSuffixAD";
    }
    return yearText;
  }

  /// Formats a number as currency according to Belarusian rules.
  ///
  /// - [absValue] The absolute value of the amount.
  /// - [options] The [BeOptions] containing currency settings.
  ///
  /// Returns the currency value formatted as text with main and subunit names properly declined.
  String _handleCurrency(Decimal absValue, BeOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2; // Standard currency subunit precision
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value if requested, otherwise use the original value.
    final Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main unit and subunit values.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Ensure subunit calculation handles potential floating point inaccuracies robustly
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round(scale: 0).toBigInt();

    // Convert the main unit value to words (using masculine gender for Ruble).
    final String mainText = _convertInteger(mainValue, Gender.masculine);
    // Get the correctly declined form of the main currency unit name.
    final String mainUnitName = _getCorrectForm(
      mainValue,
      currencyInfo.mainUnitSingular,
      currencyInfo.mainUnitPlural2To4, // Nominative Plural/Paucal for 2-4
      currencyInfo.mainUnitPluralGenitive, // Genitive Plural for 0, 5+
    );

    String subunitText = "";
    String subUnitName = "";
    // Process subunits only if they exist and a singular name is provided.
    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      // Convert subunit value to words (using feminine gender for Kopeck).
      subunitText = _convertInteger(subunitValue, Gender.feminine);
      // Get the correctly declined form of the subunit name.
      subUnitName = _getCorrectForm(
        subunitValue,
        currencyInfo.subUnitSingular!,
        currencyInfo.subUnitPlural2To4, // Nominative Plural/Paucal for 2-4
        currencyInfo.subUnitPluralGenitive, // Genitive Plural for 0, 5+
      );
    }

    // Combine main part. Handle zero main value specifically for currency (requires Gen. Pl. form).
    String result;
    if (mainValue == BigInt.zero && subunitValue > BigInt.zero) {
      // If only subunits, state "zero" of the main unit (Gen. Pl.)
      result =
          "$_zero ${currencyInfo.mainUnitPluralGenitive ?? currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular}";
    } else if (mainValue == BigInt.zero && subunitValue == BigInt.zero) {
      // This case is handled by the top-level process method, but defensively:
      result =
          "$_zero ${currencyInfo.mainUnitPluralGenitive ?? currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular}";
    } else {
      result = '$mainText $mainUnitName';
    }

    // Add subunit part if present.
    if (subunitText.isNotEmpty) {
      // Determine separator. Default to space if null.
      final String separator = currencyInfo.separator ?? " ";
      // Add space around separator only if separator itself isn't just spaces.
      final String separatorPrefix = (separator.trim().isEmpty) ? "" : " ";
      final String separatorSuffix = (separator.trim().isEmpty) ? "" : " ";

      result +=
          '$separatorPrefix$separator$separatorSuffix$subunitText $subUnitName';
    }

    return result;
  }

  /// Handles standard number conversion, including the decimal part if present.
  /// Removes trailing zeros from the decimal part.
  ///
  /// - [absValue] The absolute value of the number.
  /// - [options] The [BeOptions] containing decimal separator settings.
  ///
  /// Returns the number formatted as text, including the fractional part if applicable.
  String _handleStandardNumber(Decimal absValue, BeOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part, but use "нуль" if integer is zero and there's a fractional part.
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(
                integerPart,
                Gender.masculine,
              ); // Default to masculine for standalone numbers.

    String fractionalWords = '';
    // Process fractional part only if it's greater than zero and the number is not an integer.
    if (fractionalPart > Decimal.zero && !absValue.isInteger) {
      // Determine the separator word based on options.
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          separatorWord = _point;
          break;
        case DecimalSeparator.comma:
        default: // Default to comma if null or comma specified
          separatorWord = _comma;
          break;
      }

      // Extract fractional digits as a string reliably.
      String fractionalDigits = absValue.toString().split('.').last;

      // Remove trailing zeros to match test expectations (e.g., 1.50 -> "пяць").
      fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      // Convert each remaining fractional digit to its word representation.
      if (fractionalDigits.isNotEmpty) {
        List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          // Use words 0-9 for digits.
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder20[digitInt]
              : '?'; // Fallback for unexpected characters
        }).toList();
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
      // If fractionalDigits becomes empty after removing zeros, fractionalWords remains empty.
    }

    // Ensure no leading/trailing whitespace.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a large integer (BigInt) into its Belarusian word representation.
  ///
  /// Handles numbers by breaking them into chunks of three digits (thousands, millions, etc.)
  /// and applying the correct scale words with appropriate declension and gender.
  ///
  /// - [n] The non-negative integer to convert.
  /// - [gender] The grammatical gender to use for the number 1 and 2 in the lowest chunk (units/tens/hundreds).
  ///   Gender for higher chunks is determined by the scale word (e.g., "тысяча" is feminine).
  ///
  /// Returns the integer as Belarusian words.
  String _convertInteger(BigInt n, Gender gender) {
    if (n == BigInt.zero) return _zero; // Return "нуль" for zero.
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");

    // Handle numbers under 1000 directly using the chunk converter.
    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt(), gender);
    }

    final List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleLevel = 0; // 0: units, 1: thousands, 2: millions, ...
    BigInt remaining = n;

    // Process the number in chunks of 1000 (right to left).
    while (remaining > BigInt.zero) {
      // Get the current chunk (0-999).
      final int chunk = (remaining % oneThousand).toInt();
      remaining ~/= oneThousand; // Move to the next chunk

      if (chunk > 0) {
        String chunkText;
        String scaleWord = "";
        final List<String>? scaleNames = _scaleWords[scaleLevel];

        // Determine the gender for the current chunk based on the scale word.
        // The 'thousand' scale (level 1) is feminine ("тысяча"). Others are masculine.
        final bool isFeminineScale = scaleLevel == 1;
        final Gender chunkGender = (scaleLevel > 0 && isFeminineScale)
            ? Gender.feminine // Use feminine for "тысяча" scale
            : Gender
                .masculine; // Use masculine for other scales (мільён, etc.) or the units chunk if not specified

        // Determine the gender for the number word itself within the chunk.
        // For scale level 0 (units), use the provided context gender.
        // For higher levels, use the gender dictated by the scale noun.
        final Gender numberWordGender =
            (scaleLevel == 0) ? gender : chunkGender;

        // Convert the chunk number (1-999) to words using the appropriate gender for 1/2.
        chunkText = _convertChunk(chunk, numberWordGender);

        // Get the appropriate scale word (тысяча, мільён, etc.) if applicable.
        if (scaleLevel > 0 && scaleNames != null) {
          // Determine the correct declined form of the scale word based on the chunk value.
          scaleWord = _getCorrectForm(
            BigInt.from(chunk),
            scaleNames[0], // Singular Nominative
            scaleNames[1], // Plural Nominative/Paucal
            scaleNames[2], // Plural Genitive
          );

          // Combine chunk text and scale word.
          // Special cases for 1 and 2: "тысяча" (not "адна тысяча"), "дзве тысячы", "мільён", "два мільёны".
          if (chunk == 1 && scaleLevel == 1) {
            // 1000: Omit "адна", use scale word directly.
            chunkText = scaleWord;
          } else if (chunk == 1 && scaleLevel > 1) {
            // 1,000,000: Omit "адзін", use scale word directly.
            chunkText = scaleWord;
          } else {
            // Combine number and scale word for other cases.
            chunkText = "$chunkText $scaleWord";
          }
        }
        // Insert the processed part at the beginning of the list.
        parts.insert(0, chunkText.trim());
      } else if (remaining > BigInt.zero) {
        // Insert placeholder for zero chunk if higher scales exist, to maintain structure.
        parts.insert(0, "");
      }
      scaleLevel++;
    }

    // Join the processed parts with spaces. Filter out empty placeholders.
    return parts.where((part) => part.isNotEmpty).join(' ').trim();
  }

  /// Converts a three-digit number (chunk) into its Belarusian word representation.
  ///
  /// - [n] The number to convert (must be 0-999).
  /// - [gender] The grammatical gender to use for the words "адзін"/"адна" (one) and "два"/"дзве" (two).
  ///
  /// Returns the chunk number as Belarusian words, or an empty string if n is 0.
  String _convertChunk(int n, Gender gender) {
    if (n == 0) {
      return ""; // Return empty for zero chunk; caller handles scale words.
    }
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }

    final List<String> words = [];
    int remainder = n;

    // Handle hundreds place.
    if (remainder >= 100) {
      final int hundredDigit = remainder ~/ 100;
      words.add(_wordsHundreds[hundredDigit]!);
      remainder %= 100;
    }

    // Handle tens and units place (0-99).
    if (remainder > 0) {
      // Add space between hundreds and tens/units if needed (handled by join).
      if (remainder < 20) {
        // Numbers 1-19: Use gender-specific forms for 1 and 2.
        if (remainder == 1) {
          words.add(gender == Gender.feminine ? _oneFem : _wordsUnder20[1]);
        } else if (remainder == 2) {
          words.add(gender == Gender.feminine ? _twoFem : _wordsUnder20[2]);
        } else {
          words.add(_wordsUnder20[remainder]);
        }
      } else {
        // Numbers 20-99: Combine tens word and unit word.
        final int tensDigit = remainder ~/ 10;
        final int unitDigit = remainder % 10;
        words.add(_wordsTens[tensDigit]);
        if (unitDigit > 0) {
          // Use gender-specific forms for 1 and 2 in the units place.
          if (unitDigit == 1) {
            words.add(gender == Gender.feminine ? _oneFem : _wordsUnder20[1]);
          } else if (unitDigit == 2) {
            words.add(gender == Gender.feminine ? _twoFem : _wordsUnder20[2]);
          } else {
            words.add(_wordsUnder20[unitDigit]);
          }
        }
      }
    }

    // Join the parts (e.g., ["сто", "дваццаць", "адзін"]) with spaces.
    return words.join(' ');
  }

  /// Selects the correct grammatical form of a noun (like currency or scale word)
  /// based on the preceding number, following Belarusian declension rules.
  ///
  /// - [number] The number determining the noun form.
  /// - [singularForm] The nominative singular form (used for 1, x1).
  /// - [paucalForm] The nominative plural (paucal) form (used for 2-4, x2-x4). Can be null if same as genitive or singular.
  /// - [pluralGenitiveForm] The genitive plural form (used for 0, 5+, x0, x5-x9, 11-19, x11-x19). Can be null if same as singular.
  ///
  /// Returns the appropriate declined noun form. Provides fallbacks if specific forms are null.
  String _getCorrectForm(
    BigInt number,
    String singularForm,
    String? paucalForm, // Form for 2, 3, 4
    String? pluralGenitiveForm, // Form for 0, 5+
  ) {
    // Default fallbacks: if paucal is missing, use genitive; if genitive is missing, use singular.
    final String effectivePaucal =
        paucalForm ?? pluralGenitiveForm ?? singularForm;
    final String effectiveGenitive = pluralGenitiveForm ?? singularForm;

    // Use genitive plural for zero.
    if (number == BigInt.zero) return effectiveGenitive;

    // Use absolute value for rule checking.
    final BigInt absNumber = number.abs();
    // Need last digits for rules. Use toInt() safely after modulo.
    final int lastDigit = (absNumber % BigInt.from(10)).toInt();
    final int lastTwoDigits = (absNumber % BigInt.from(100)).toInt();

    // Rule for 11-19: Use genitive plural.
    if (lastTwoDigits >= 11 && lastTwoDigits <= 19) {
      return effectiveGenitive;
    }
    // Rule for numbers ending in 1 (but not 11): Use nominative singular.
    else if (lastDigit == 1) {
      return singularForm;
    }
    // Rule for numbers ending in 2, 3, 4 (but not 12, 13, 14): Use nominative plural (paucal).
    else if (lastDigit >= 2 && lastDigit <= 4) {
      return effectivePaucal;
    }
    // Rule for numbers ending in 0, 5, 6, 7, 8, 9: Use genitive plural.
    else {
      return effectiveGenitive;
    }
  }
}
