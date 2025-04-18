import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/uk_options.dart';
import '../utils/utils.dart';

/// Stores information about large number scale units (thousand, million, etc.)
/// including their singular, plural, and genitive plural forms, and grammatical gender.
/// Used for correct grammatical agreement in Ukrainian.
class _ScaleInfo {
  /// The nominative singular form (e.g., "тисяча", "мільйон"). Used with 1 (except 11).
  final String nomSg;

  /// The nominative plural form used for counts ending in 2, 3, 4 (excluding 12, 13, 14)
  /// (e.g., "тисячі", "мільйони").
  final String nomPl;

  /// The genitive plural form used for counts ending in 0, 1 (for 11), 5-9, and 11-19
  /// (e.g., "тисяч", "мільйонів").
  final String genPl;

  /// The grammatical gender of the scale unit, affecting agreement of numbers 1 and 2
  /// preceding the scale word (e.g., "одна тисяча" vs "один мільйон").
  final Gender gender;

  const _ScaleInfo({
    required this.nomSg,
    required this.nomPl,
    required this.genPl,
    required this.gender,
  });
}

/// {@template num2text_uk}
/// The Ukrainian language (`Lang.UK`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Ukrainian word representation following standard Ukrainian grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [UkOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (using standard scale).
/// Features include correct grammatical declension and gender agreement for numerals and nouns.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [UkOptions].
/// {@endtemplate}
class Num2TextUK implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "нуль";
  static const String _comma = "кома"; // Decimal separator word for comma
  static const String _period =
      "крапка"; // Decimal separator word for period/point
  static const String _yearSuffixAD =
      "н.е."; // Suffix for AD/CE years ("нашої ери")
  static const String _yearSuffixBC =
      "до н.е."; // Suffix for BC/BCE years ("до нашої ери")
  static const String _infinity = "Нескінченність"; // Word for Infinity
  static const String _negativeInfinity =
      "Негативна нескінченність"; // Word for -Infinity
  static const String _notANumber =
      "Не число"; // Default fallback for invalid input

  // --- Number Words ---

  /// Units (1-9) in masculine/neuter form. Index corresponds to the number.
  static const List<String> _unitsMasculine = [
    "", // 0 is handled separately
    "один", // 1
    "два", // 2
    "три", // 3
    "чотири", // 4
    "п'ять", // 5
    "шість", // 6
    "сім", // 7
    "вісім", // 8
    "дев'ять", // 9
  ];

  /// Units (1-9) in feminine form. Index corresponds to the number. Used for feminine nouns.
  static const List<String> _unitsFeminine = [
    "", // 0
    "одна", // 1
    "дві", // 2
    "три", // 3 (same as masculine)
    "чотири", // 4 (same as masculine)
    "п'ять", // 5 (same as masculine)
    "шість", // 6 (same as masculine)
    "сім", // 7 (same as masculine)
    "вісім", // 8 (same as masculine)
    "дев'ять", // 9 (same as masculine)
  ];

  /// Teens (10-19). Index corresponds to `number - 10`.
  static const List<String> _teens = [
    "десять", // 10
    "одинадцять", // 11
    "дванадцять", // 12
    "тринадцять", // 13
    "чотирнадцять", // 14
    "п'ятнадцять", // 15
    "шістнадцять", // 16
    "сімнадцять", // 17
    "вісімнадцять", // 18
    "дев'ятнадцять", // 19
  ];

  /// Tens (20, 30,... 90). Index corresponds to `number / 10`. Index 0 and 1 are unused.
  static const List<String> _tens = [
    "", // 0
    "", // 10 (handled by teens)
    "двадцять", // 20
    "тридцять", // 30
    "сорок", // 40
    "п'ятдесят", // 50
    "шістдесят", // 60
    "сімдесят", // 70
    "вісімдесят", // 80
    "дев'яносто", // 90
  ];

  /// Hundreds (100, 200,... 900). Index corresponds to `number / 100`. Index 0 is unused.
  static const List<String> _hundreds = [
    "", // 0
    "сто", // 100
    "двісті", // 200
    "триста", // 300
    "чотириста", // 400
    "п'ятсот", // 500
    "шістсот", // 600
    "сімсот", // 700
    "вісімсот", // 800
    "дев'ятсот", // 900
  ];

  /// Scale words (thousand, million, etc.) with their grammatical properties.
  /// Key: scale exponent (1 for 10^3, 2 for 10^6, etc.).
  static final Map<int, _ScaleInfo> _scaleWords = {
    1: const _ScaleInfo(
      nomSg: "тисяча",
      nomPl: "тисячі",
      genPl: "тисяч",
      gender: Gender.feminine,
    ), // Thousand
    2: const _ScaleInfo(
      nomSg: "мільйон",
      nomPl: "мільйони",
      genPl: "мільйонів",
      gender: Gender.masculine,
    ), // Million
    3: const _ScaleInfo(
      nomSg: "мільярд",
      nomPl: "мільярди",
      genPl: "мільярдів",
      gender: Gender.masculine,
    ), // Billion
    4: const _ScaleInfo(
      nomSg: "трильйон",
      nomPl: "трильйони",
      genPl: "трильйонів",
      gender: Gender.masculine,
    ), // Trillion
    5: const _ScaleInfo(
      nomSg: "квадрильйон",
      nomPl: "квадрильйони",
      genPl: "квадрильйонів",
      gender: Gender.masculine,
    ), // Quadrillion
    6: const _ScaleInfo(
      nomSg: "квінтильйон",
      nomPl: "квінтильйони",
      genPl: "квінтильйонів",
      gender: Gender.masculine,
    ), // Quintillion
    7: const _ScaleInfo(
      nomSg: "секстильйон",
      nomPl: "секстильйони",
      genPl: "секстильйонів",
      gender: Gender.masculine,
    ), // Sextillion
    8: const _ScaleInfo(
      nomSg: "септильйон",
      nomPl: "септильйони",
      genPl: "септильйонів",
      gender: Gender.masculine,
    ), // Septillion
    // Add more scales here if needed (e.g., октильйон, нонільйон)
  };

  /// Processes the given [number] into its Ukrainian word representation based on the provided [options].
  ///
  /// - [number]: The number to convert (can be `int`, `double`, `BigInt`, `String`, `Decimal`).
  /// - [options]: An optional `UkOptions` instance to control formatting (currency, year, etc.).
  ///   If null or not `UkOptions`, default options are used.
  /// - [fallbackOnError]: A custom string to return if conversion fails (e.g., invalid input).
  ///   If null, a default error message (`_notANumber`) is used.
  ///
  /// Returns the word representation of the number, or an error/fallback string.
  /// Handles special double values: `Infinity` -> "Нескінченність", `-Infinity` -> "Негативна нескінченність",
  /// `NaN` -> fallback string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final UkOptions ukOptions =
        options is UkOptions ? options : const UkOptions();
    final String onError = fallbackOnError ?? _notANumber;

    // Handle special double values first
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? _negativeInfinity : _infinity;
      }
      if (number.isNaN) {
        return onError;
      }
    }

    // Normalize the input number to Decimal for consistent handling
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    if (decimalValue == null) {
      return onError; // Input could not be normalized (e.g., invalid string, unsupported type)
    }

    // Handle zero separately
    if (decimalValue == Decimal.zero) {
      if (ukOptions.currency) {
        // For currency "0", return "нуль" + genitive plural of the main unit
        // Ensure currencyInfo fields are not null when used.
        return "$_zero ${_getNounForm(BigInt.zero, ukOptions.currencyInfo.mainUnitSingular, ukOptions.currencyInfo.mainUnitPlural2To4!, ukOptions.currencyInfo.mainUnitPluralGenitive!)}";
      } else {
        return _zero;
      }
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for conversion logic
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Apply specific formatting based on options
    if (ukOptions.format == Format.year) {
      // Year formatting handles negativity internally (BC/AD)
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), ukOptions);
    } else {
      // Handle currency or standard number formatting
      if (ukOptions.currency) {
        textResult = _handleCurrency(absValue, ukOptions);
      } else {
        textResult = _handleStandardNumber(absValue, ukOptions);
      }
      // Prepend negative prefix if the original number was negative
      if (isNegative) {
        textResult = "${ukOptions.negativePrefix} $textResult";
      }
    }

    return textResult;
  }

  /// Formats a number as a year according to Ukrainian conventions.
  ///
  /// - [year]: The year as a BigInt.
  /// - [options]: `UkOptions` to check for `includeAD`.
  ///
  /// Handles BC/BCE years by appending "до н.е.".
  /// Appends "н.е." for AD/CE years only if `options.includeAD` is true and the year is positive.
  /// Uses special phrasing for years 1000-2999 ("тисяча ...", "дві тисячі ...").
  String _handleYearFormat(BigInt year, UkOptions options) {
    final bool isNegative = year < BigInt.zero;
    final BigInt absYear = isNegative ? -year : year;

    String yearText;
    final bool canUseInt =
        absYear.isValidInt; // Check if it fits in standard int

    if (absYear == BigInt.zero) {
      // While year 0 doesn't technically exist in Gregorian, handle it if passed.
      yearText = _zero;
    } else if (canUseInt) {
      final int yearInt = absYear.toInt();
      if (yearInt >= 1000 && yearInt < 2000) {
        // Special case for 1xxx years: "тисяча [hundreds/tens/units]"
        // Years are typically treated as masculine for the chunk part.
        yearText =
            "тисяча ${_convertChunk(yearInt % 1000, Gender.masculine)}".trim();
      } else if (yearInt >= 2000 && yearInt < 3000) {
        // Special case for 2xxx years: "дві тисячі [hundreds/tens/units]"
        yearText =
            "дві тисячі ${_convertChunk(yearInt % 1000, Gender.masculine)}"
                .trim();
      } else {
        // Default conversion for other years within int range (uses masculine for years)
        yearText = _convertInteger(absYear, Gender.masculine);
      }
    } else {
      // Default conversion for years outside int range (e.g., very large years)
      yearText = _convertInteger(absYear, Gender.masculine);
    }

    // Append era suffixes
    if (isNegative) {
      yearText += " $_yearSuffixBC"; // Always add "до н.е." for negative years
    } else if (options.includeAD && absYear > BigInt.zero) {
      // Add "н.е." only for positive years and if includeAD is true
      yearText += " $_yearSuffixAD";
    }

    return yearText;
  }

  /// Formats a number as currency (Ukrainian Hryvnia - UAH).
  ///
  /// - [absValue]: The absolute monetary value as a Decimal.
  /// - [options]: `UkOptions` containing currency info and rounding preference.
  ///
  /// Converts the main unit (hryvnia) and subunit (kopiyka), applying correct
  /// noun forms based on the number. Uses feminine gender for currency units.
  String _handleCurrency(Decimal absValue, UkOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2; // Currency typically has 2 decimal places
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value if requested, otherwise use the original value
    final Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main and subunit values
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Calculate subunit value, ensuring correct rounding
    final BigInt subunitValue =
        (fractionalPart.abs() * subunitMultiplier).round(scale: 0).toBigInt();

    // Convert main value and get the correct noun form (гривня/гривні/гривень)
    // Currency units (Hryvnia, Kopiyka) are feminine.
    final String mainText = _convertInteger(mainValue, Gender.feminine);
    final String mainUnitName = _getNounForm(
      mainValue,
      currencyInfo.mainUnitSingular,
      currencyInfo
          .mainUnitPlural2To4!, // Assumes non-null based on UAH definition
      currencyInfo.mainUnitPluralGenitive!, // Assumes non-null
    );

    final List<String> resultParts = [];
    // Add main part only if value > 0
    if (mainValue > BigInt.zero) {
      resultParts.add(mainText);
      resultParts.add(mainUnitName);
    }

    // Add subunit part if it exists
    if (subunitValue > BigInt.zero) {
      // Convert subunit value and get the correct noun form (копійка/копійки/копійок)
      final String subunitText = _convertInteger(subunitValue, Gender.feminine);
      final String subUnitName = _getNounForm(
        subunitValue,
        currencyInfo.subUnitSingular!, // Assumes non-null
        currencyInfo.subUnitPlural2To4!, // Assumes non-null
        currencyInfo.subUnitPluralGenitive!, // Assumes non-null
      );
      resultParts.add(subunitText);
      resultParts.add(subUnitName);
    }

    // Handle case where only main unit is zero (e.g., 0.50 UAH)
    if (mainValue == BigInt.zero && subunitValue > BigInt.zero) {
      // Subunit already added above.
    } else if (mainValue == BigInt.zero && subunitValue == BigInt.zero) {
      // Handle exact zero currency (should be caught by 'process', but defensive)
      return "$_zero ${_getNounForm(BigInt.zero, currencyInfo.mainUnitSingular, currencyInfo.mainUnitPlural2To4!, currencyInfo.mainUnitPluralGenitive!)}";
    }

    // Join non-empty parts with spaces
    return resultParts.where((s) => s.isNotEmpty).join(' ');
  }

  /// Formats a standard number (integer or decimal).
  ///
  /// - [absValue]: The absolute value of the number as a Decimal.
  /// - [options]: `UkOptions` containing decimal separator preference.
  ///
  /// Converts the integer and fractional parts separately.
  /// Determines the gender for the integer part based on specific rules when decimals are present.
  String _handleStandardNumber(Decimal absValue, UkOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = (absValue - absValue.truncate()).abs();

    // Determine gender for the integer part:
    // Use feminine for 1 or 2 when followed by a decimal part (e.g., "одна кома п'ять").
    // Otherwise, use masculine as the default.
    final Gender integerGender = (fractionalPart > Decimal.zero &&
            (integerPart == BigInt.one || integerPart == BigInt.two))
        ? Gender.feminine
        : Gender.masculine;

    // Convert the integer part. If integer is 0 but there's a fractional part, represent 0 as "нуль".
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, integerGender);

    String fractionalWords = '';
    // Convert the fractional part if it exists
    if (fractionalPart > Decimal.zero) {
      // Choose the decimal separator word based on options
      final String separatorWord;
      switch (options.decimalSeparator ?? DecimalSeparator.comma) {
        // Default to comma
        case DecimalSeparator.comma:
          separatorWord = _comma;
          break;
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          separatorWord = _period;
          break;
      }

      // Get the digits after the decimal point as a string
      // Using absValue.toString() reliably gets the decimal part.
      final String fractionalDigits = absValue.toString().split('.').last;

      // Convert each digit individually using masculine form
      final List<String> digitWords = fractionalDigits.split('').map((digit) {
        final int? digitInt = int.tryParse(digit);
        // Ensure digit is valid (0-9) and get the masculine word.
        return (digitInt != null && digitInt >= 0 && digitInt <= 9)
            ? (digitInt == 0
                ? _zero
                : _unitsMasculine[
                    digitInt]) // Use masculine form for digits after decimal, handle 0
            : '?'; // Placeholder for unexpected characters
      }).toList();

      // Combine separator and digit words
      fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
    }

    // Combine integer and fractional parts, trimming any leading/trailing space
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a large non-negative integer (`BigInt`) into its Ukrainian word representation.
  ///
  /// - [n]: The non-negative integer to convert.
  /// - [gender]: The grammatical gender to use for the final chunk (units/tens/hundreds),
  ///   affecting "один/одна" and "два/дві".
  ///
  /// Breaks the number into chunks of 1000 and converts each, applying scale words
  /// (thousand, million, etc.) with correct noun forms and gender agreement.
  /// Returns an empty string if `n` is zero.
  String _convertInteger(BigInt n, Gender gender) {
    if (n == BigInt.zero) {
      return ""; // Empty string for zero in integer context (handled elsewhere if needed)
    }
    if (n < BigInt.zero) {
      // This should ideally not be reached as negativity is handled before calling
      throw ArgumentError(
          "Negative numbers must be handled before _convertInteger.");
    }

    // Base case: numbers less than 1000 are handled by _convertChunk
    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt(), gender);
    }

    final List<String> parts = [];
    BigInt remaining = n;
    final BigInt oneThousand = BigInt.from(1000);

    // Determine the highest scale needed
    final int maxScale = _scaleWords.keys.isNotEmpty
        ? _scaleWords.keys.reduce((a, b) => a > b ? a : b)
        : 0;

    // Iterate through scales from highest to lowest (trillion, billion, million, thousand)
    for (int i = maxScale; i >= 1; i--) {
      final BigInt scaleDivisor = oneThousand.pow(i); // 1000^i

      if (remaining >= scaleDivisor) {
        // Calculate how many of this scale unit are present
        final BigInt chunkBigInt = remaining ~/ scaleDivisor;
        // Update the remainder
        remaining %= scaleDivisor;

        if (chunkBigInt > BigInt.zero) {
          final _ScaleInfo? scaleInfo = _scaleWords[i];
          if (scaleInfo == null) {
            // Should not happen if scale iteration is correct.
            throw StateError("Scale info missing for scale index $i");
          }

          // Convert the chunk number, using the gender of the scale word
          final String chunkText =
              _convertChunk(chunkBigInt.toInt(), scaleInfo.gender);

          // Get the correct noun form of the scale word (e.g., мільйон/мільйони/мільйонів)
          final String scaleNoun = _getNounForm(
            chunkBigInt,
            scaleInfo.nomSg,
            scaleInfo.nomPl,
            scaleInfo.genPl,
          );
          parts.add("$chunkText $scaleNoun");
        }
      }
    }

    // Convert the remaining part (less than 1000) using the originally requested gender
    if (remaining > BigInt.zero) {
      parts.add(_convertChunk(remaining.toInt(), gender));
    }

    return parts.join(' ');
  }

  /// Converts a number chunk (0-999) into its Ukrainian word representation.
  ///
  /// - [n]: The number chunk (0 <= n < 1000).
  /// - [gender]: The grammatical gender to apply to units 1 and 2 (`один`/`одна`, `два`/`дві`).
  ///
  /// Handles hundreds, tens, teens, and units according to Ukrainian rules.
  String _convertChunk(int n, Gender gender) {
    if (n == 0) return ""; // Empty string for zero within a larger number
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk value must be between 0 and 999, but was $n.");
    }

    final List<String> words = [];
    int remainder = n;

    // Handle hundreds
    if (remainder >= 100) {
      words.add(_hundreds[remainder ~/ 100]);
      remainder %= 100;
    }

    // Handle tens, teens, and units
    if (remainder > 0) {
      if (remainder < 10) {
        // Units 1-9: Use gender-specific form
        words.add(
          (gender == Gender.feminine)
              ? _unitsFeminine[remainder]
              : _unitsMasculine[remainder],
        );
      } else if (remainder < 20) {
        // Teens 10-19
        words.add(_teens[remainder - 10]);
      } else {
        // Tens 20-90
        words.add(_tens[remainder ~/ 10]);
        final int unit = remainder % 10;
        if (unit > 0) {
          // Add unit 1-9 after tens: Use gender-specific form.
          words.add((gender == Gender.feminine)
              ? _unitsFeminine[unit]
              : _unitsMasculine[unit]);
        }
      }
    }

    return words.join(' ');
  }

  /// Selects the correct Ukrainian noun form based on the governing number.
  ///
  /// - [number]: The number determining the noun form.
  /// - [nomSg]: The nominative singular form (used for 1, x1, xx1, ... except 11).
  /// - [nomPl]: The nominative plural form (used for 2-4, x2-x4, ... except 12-14).
  /// - [genPl]: The genitive plural form (used for 0, 5-19, x0, x5-x9, ...).
  ///
  /// Implements standard Slavic declension rules for numerals.
  String _getNounForm(BigInt number, String nomSg, String nomPl, String genPl) {
    // Handle 0 explicitly -> genitive plural
    if (number == BigInt.zero) {
      return genPl;
    }

    // Rules are based on the last one or two digits.
    final BigInt absNumber =
        number.abs(); // Use absolute value for declension rules
    final BigInt lastTwoDigits = absNumber % BigInt.from(100);

    // Check for teens (11-19) -> genitive plural
    if (lastTwoDigits >= BigInt.from(11) && lastTwoDigits <= BigInt.from(19)) {
      return genPl;
    }

    // Check the last digit
    final int lastDigit = (absNumber % BigInt.from(10)).toInt();

    if (lastDigit == 1) {
      return nomSg; // Nominative singular for numbers ending in 1 (except 11)
    } else if (lastDigit >= 2 && lastDigit <= 4) {
      return nomPl; // Nominative plural for numbers ending in 2, 3, 4 (except 12, 13, 14)
    } else {
      // Genitive plural for numbers ending in 0, 5, 6, 7, 8, 9 and for 11-19 (handled above)
      return genPl;
    }
  }
}
