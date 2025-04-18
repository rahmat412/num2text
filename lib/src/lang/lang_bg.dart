import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/bg_options.dart';
import '../utils/utils.dart';

/// A utility class to hold intermediate results during integer conversion.
/// Stores the integer value of a chunk and its corresponding text representation.
/// Used internally by [_convertInteger] to manage parts of large numbers.
class _ChunkInfo {
  final int value;
  final String text;
  _ChunkInfo(this.value, this.text);
}

/// {@template num2text_bg}
/// The Bulgarian language (`Lang.BG`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Bulgarian word representation, adhering to Bulgarian grammatical rules
/// for gender agreement (masculine, feminine, neuter) and number forms.
///
/// Capabilities include handling cardinal numbers, currency (using [BgOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (short scale names).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [BgOptions].
/// {@endtemplate}
class Num2TextBG implements Num2TextBase {
  // --- Constants ---

  /// The word for zero.
  static const String _zero = "нула";

  /// The conjunction "and" used between hundreds/tens/units and sometimes between chunks.
  static const String _andConjunction = "и";

  /// The default word separating the integer and fractional parts of a decimal number.
  /// Used when `DecimalSeparator.comma` is specified or as default. Translates to "whole and".
  static const String _defaultDecimalSeparatorWord = "цяло и";

  /// The word used for the decimal point when `DecimalSeparator.period` or `DecimalSeparator.point` is specified.
  static const String _pointWord = "точка";

  /// The suffix added to negative years (Before Common Era). Means "преди новата ера".
  static const String _yearSuffixBC = "преди новата ера";

  /// The suffix added to positive years when `includeAD` is true (Common Era). Means "от новата ера".
  static const String _yearSuffixAD = "от новата ера";

  /// Word forms for numbers 0 through 19 (neuter/default form).
  static const List<String> _wordsUnder20 = [
    _zero, // 0
    "едно", // 1 (Neuter/Default form)
    "две", // 2 (Neuter/Feminine form)
    "три", // 3
    "четири", // 4
    "пет", // 5
    "шест", // 6
    "седем", // 7
    "осем", // 8
    "девет", // 9
    "десет", // 10
    "единадесет", // 11
    "дванадесет", // 12
    "тринадесет", // 13
    "четиринадесет", // 14
    "петнадесет", // 15
    "шестнадесет", // 16
    "седемнадесет", // 17
    "осемнадесет", // 18
    "деветнадесет", // 19
  ];

  /// Masculine form for the number 1.
  static const String _masculineOne = "един";

  /// Feminine form for the number 1.
  static const String _feminineOne = "една";

  /// Neuter form for the number 1 (also default/standalone).
  static const String _neuterOne = "едно";

  /// Masculine form for the number 2.
  static const String _masculineTwo = "два";

  /// Feminine form for the number 2.
  static const String _feminineTwo = "две";

  /// Neuter form for the number 2 (same as feminine).
  static const String _neuterTwo = "две";

  /// Word forms for tens (20, 30, ..., 90). Indices 0 and 1 are unused placeholders.
  static const List<String> _wordsTens = [
    "", // 0
    "", // 10 (handled by _wordsUnder20)
    "двадесет", // 20
    "тридесет", // 30
    "четиридесет", // 40
    "петдесет", // 50
    "шестдесет", // 60
    "седемдесет", // 70
    "осемдесет", // 80
    "деветдесет", // 90
  ];

  /// Word forms for hundreds (100, 200, ..., 900). Index 0 is unused placeholder.
  static const List<String> _wordsHundreds = [
    "", // 0
    "сто", // 100
    "двеста", // 200
    "триста", // 300
    "четиристотин", // 400
    "петстотин", // 500
    "шестстотин", // 600
    "седемстотин", // 700
    "осемстотин", // 800
    "деветстотин", // 900
  ];

  /// Scale words for large numbers (thousand, million, etc.).
  /// Maps the exponent (power of 10) to a list containing [singular, plural] forms.
  /// Note the gender implications: хиляда (feminine), милион/милиард/... (masculine).
  static const Map<int, List<String>> _scaleWords = {
    3: ["хиляда", "хиляди"], // Thousand (Feminine)
    6: ["милион", "милиона"], // Million (Masculine)
    9: ["милиард", "милиарда"], // Billion (Masculine)
    12: ["трилион", "трилиона"], // Trillion (Masculine)
    15: ["квадрилион", "квадрилиона"], // Quadrillion (Masculine)
    18: ["квинтилион", "квинтилиона"], // Quintillion (Masculine)
    21: ["секстилион", "секстилиона"], // Sextillion (Masculine)
    24: ["септилион", "септилиона"], // Septillion (Masculine)
    // Add more scales as needed
  };

  // --- Public API Method ---

  /// Converts a given number to its Bulgarian word representation.
  ///
  /// - `number` The number to convert (can be `int`, `double`, `BigInt`, `Decimal`, `String`).
  /// - `options` Optional [BgOptions] to customize formatting (currency, year, etc.).
  /// - `fallbackOnError` A custom string to return if conversion fails (e.g., invalid input).
  /// Returns the word representation of the number or an error/fallback string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final BgOptions bgOptions =
        options is BgOptions ? options : const BgOptions();
    final String errorFallback =
        fallbackOnError ?? "Не е число"; // Default fallback

    // Handle special double values first
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? "Отрицателна безкрайност" : "Безкрайност";
      }
      if (number.isNaN) return errorFallback;
    }

    // Normalize the input number to Decimal
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    // Handle zero separately for clarity and special cases (currency)
    if (decimalValue == Decimal.zero) {
      if (bgOptions.currency) {
        // Get the appropriate plural form for "zero" units (usually plural for BGN)
        final String zeroUnit = bgOptions.currencyInfo.mainUnitPlural ??
            bgOptions.currencyInfo.mainUnitSingular;
        return "$_zero $zeroUnit";
      }
      // For years or standard numbers, zero is just "нула"
      return _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for the core conversion logic
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Delegate based on formatting options
    if (bgOptions.format == Format.year) {
      // Year formatting requires integer input and specific handling.
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), bgOptions);
    } else {
      if (bgOptions.currency) {
        textResult = _handleCurrency(absValue, bgOptions);
      } else {
        textResult = _handleStandardNumber(absValue, bgOptions);
      }
      // Add negative prefix if needed *after* core conversion (unless it's a year).
      if (isNegative) {
        textResult = "${bgOptions.negativePrefix} $textResult";
      }
    }

    // Clean up potential extra spaces
    return textResult.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // --- Private Helper Methods ---

  /// Handles the specific formatting logic for years.
  ///
  /// - `year` The integer year value.
  /// - `options` The [BgOptions] controlling suffixes (AD/BC).
  /// Returns the year formatted as Bulgarian words.
  String _handleYearFormat(int year, BgOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;
    final BigInt bigAbsYear = BigInt.from(absYear);

    // Years are typically treated as neuter numbers in Bulgarian when spoken standalone.
    // The conversion function handles placing "и" correctly for years.
    String yearText = _convertInteger(bigAbsYear, Gender.neuter, true);

    // Add era suffixes if applicable
    if (isNegative) {
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD && absYear > 0) {
      // Only add AD suffix if requested and year is positive
      yearText += " $_yearSuffixAD";
    }
    return yearText;
  }

  /// Handles the formatting logic for currency values.
  ///
  /// - `absValue` The absolute (non-negative) [Decimal] value of the currency.
  /// - `options` The [BgOptions] providing currency info and rounding rules.
  /// Returns the currency value formatted as Bulgarian words.
  String _handleCurrency(Decimal absValue, BgOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    const int decimalPlaces = 2; // Standard currency precision
    final Decimal subunitMultiplier =
        Decimal.fromInt(100); // 100 subunits in main unit

    // Round the value *before* splitting if requested
    final Decimal valueToConvert =
        options.round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate the main unit and subunit values
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    // Calculate fractional part accurately
    final Decimal fractionalPart =
        valueToConvert - Decimal.fromBigInt(mainValue);
    // Use round for robustness
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round().toBigInt();

    // --- Main Unit Conversion ---
    // Main currency unit (лев) is masculine
    final String mainText = _convertInteger(mainValue, Gender.masculine, false);
    String mainUnitName;
    if (mainValue == BigInt.one) {
      // Use singular form for 1
      mainUnitName = currencyInfo.mainUnitSingular;
    } else {
      // Use plural form for 0, 2+ (BGN uses simple plural)
      mainUnitName =
          currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;
    }

    String result = '$mainText $mainUnitName';

    // --- Subunit Conversion (if any) ---
    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      // Subunit (стотинка) is feminine
      final String subunitText =
          _convertInteger(subunitValue, Gender.feminine, false);
      String subUnitName;
      if (subunitValue == BigInt.one) {
        // Use singular form for 1
        subUnitName = currencyInfo.subUnitSingular!;
      } else {
        // Use plural form for 0, 2+
        subUnitName = currencyInfo.subUnitPlural!;
      }
      // Add separator and subunit text. Use default "и" if separator is null.
      result +=
          ' ${currencyInfo.separator ?? _andConjunction} $subunitText $subUnitName';
    }
    return result;
  }

  /// Handles the conversion of standard numbers (integers or decimals).
  /// Removes trailing zeros from the decimal part.
  ///
  /// - `absValue` The absolute (non-negative) [Decimal] value.
  /// - `options` The [BgOptions] providing decimal separator preference.
  /// Returns the number formatted as Bulgarian words.
  String _handleStandardNumber(Decimal absValue, BgOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - Decimal.fromBigInt(integerPart);

    // Convert the integer part (use "нула" if integer is 0 but there's a fractional part)
    // Default gender for standalone numbers is neuter.
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, Gender.neuter, false);

    String fractionalWords = '';
    // Process fractional part only if it exists and the number is not an integer.
    if (fractionalPart > Decimal.zero && !absValue.isInteger) {
      // Convert the fractional part digit by digit
      String decimalString = absValue.toString();
      String fractionalDigits =
          decimalString.contains('.') ? decimalString.split('.').last : '';

      // Important: Remove trailing zeros from the fractional part for correct pronunciation
      fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      if (fractionalDigits.isNotEmpty) {
        // Convert each digit after the decimal point individually
        final List<String> digitWordsList =
            fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          // Digits after decimal point use the default neuter form
          return (digitInt != null &&
                  digitInt >= 0 &&
                  digitInt < _wordsUnder20.length)
              ? _wordsUnder20[digitInt]
              : '?'; // Fallback
        }).toList();

        final String fractionalText = digitWordsList.join(' ');

        // Choose the separator word based on options
        final DecimalSeparator separatorType = options.decimalSeparator ??
            DecimalSeparator.comma; // Default to comma ("цяло и")
        String separatorWord;
        switch (separatorType) {
          case DecimalSeparator.point:
          case DecimalSeparator.period:
            separatorWord = _pointWord;
            break;
          case DecimalSeparator.comma:
            separatorWord = _defaultDecimalSeparatorWord;
            break;
        }
        fractionalWords = ' $separatorWord $fractionalText';
      }
      // If fractionalDigits is empty after removing zeros, fractionalWords remains empty.
    }
    // Note: Case 123.0 is handled correctly as !absValue.isInteger is false.

    return '$integerWords$fractionalWords';
  }

  /// Returns the gender-specific word form for 1 or 2.
  ///
  /// For other numbers under 20, it returns the standard form from [_wordsUnder20].
  /// - `number` The number (expected to be 1 or 2, but handles < 20).
  /// - `gender` The required grammatical [Gender].
  /// Returns the correct word form.
  String _getGenderSpecificWord(int number, Gender gender) {
    if (number == 1) {
      switch (gender) {
        case Gender.masculine:
          return _masculineOne;
        case Gender.feminine:
          return _feminineOne;
        case Gender.neuter:
          return _neuterOne;
      }
    } else if (number == 2) {
      switch (gender) {
        case Gender.masculine:
          return _masculineTwo;
        case Gender.feminine:
          return _feminineTwo;
        case Gender.neuter:
          return _neuterTwo;
      }
    }

    // Fallback for numbers other than 1 or 2 (or if gender logic isn't needed)
    if (number >= 0 && number < _wordsUnder20.length) {
      return _wordsUnder20[number];
    }

    // Should not happen with valid input
    return '?';
  }

  /// Converts a non-negative integer (`BigInt`) into its Bulgarian word representation.
  /// This is the core recursive function that handles chunking and scale words.
  ///
  /// - `n` The non-negative integer to convert.
  /// - `contextGender` The grammatical [Gender] required by the context (e.g., for currency or standalone numbers).
  /// - `isYearContext` Flag indicating if the number represents a year (affects 'и' placement).
  /// Returns the integer as words.
  String _convertInteger(BigInt n, Gender contextGender, bool isYearContext) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) {
      throw ArgumentError(
          "Integer must be non-negative for _convertInteger: $n");
    }

    // Base case: numbers less than 1000 are handled by _convertChunk
    if (n < BigInt.from(1000)) {
      // Pass false for forceMasculineOne as it's not needed here.
      return _convertChunk(n.toInt(), contextGender, false);
    }

    final List<_ChunkInfo> parts =
        []; // Stores results for each chunk (thousands, millions...)
    final BigInt oneThousand = BigInt.from(1000);
    BigInt remaining = n;
    int scalePower = 0; // 0 for units, 3 for thousands, 6 for millions...

    // Process the number in chunks of three digits (right to left)
    while (remaining > BigInt.zero) {
      final int chunkValueInt = (remaining % oneThousand).toInt();
      remaining ~/= oneThousand; // Move to the next chunk

      if (chunkValueInt > 0) {
        Gender chunkGender;
        String scaleWordText = "";
        bool forceMasculineOneForChunk = false;
        bool omitUnitsForSingularThousand = false; // Special case for "хиляда"

        // Determine gender and scale word based on the scale power
        if (scalePower >= 6) {
          // Millions, billions, etc. are masculine
          chunkGender = Gender.masculine;
          if (_scaleWords.containsKey(scalePower)) {
            scaleWordText = chunkValueInt == 1
                ? _scaleWords[scalePower]![0] // Singular form (e.g., "милион")
                : _scaleWords[scalePower]![1]; // Plural form (e.g., "милиона")
          }
          // If the chunk is exactly 1 (e.g., 1,000,000), use "един" instead of "едно"
          if (chunkValueInt == 1) forceMasculineOneForChunk = true;
        } else if (scalePower == 3) {
          // Thousands are feminine ("хиляда", "хиляди")
          chunkGender = Gender.feminine;
          if (_scaleWords.containsKey(scalePower)) {
            scaleWordText = chunkValueInt == 1
                ? _scaleWords[scalePower]![0] // Singular "хиляда"
                : _scaleWords[scalePower]![1]; // Plural "хиляди"
          }
          // Special case: "хиляда" (1000) often omits the "една" part
          if (chunkValueInt == 1 && n >= oneThousand) {
            omitUnitsForSingularThousand = true;
          }
        } else {
          // The last chunk (0-999) uses the context gender
          chunkGender = contextGender;
        }

        // Convert the 3-digit chunk itself using the determined gender
        final String chunkText = omitUnitsForSingularThousand
            ? "" // Omit "една" for "хиляда"
            : _convertChunk(
                chunkValueInt, chunkGender, forceMasculineOneForChunk);

        // Combine chunk text with its scale word (if any)
        final String combinedText = scaleWordText.isEmpty
            ? chunkText
            : (chunkText.isEmpty ? scaleWordText : '$chunkText $scaleWordText');

        if (combinedText.isNotEmpty) {
          // Insert at the beginning to maintain correct order
          parts.insert(0, _ChunkInfo(chunkValueInt, combinedText));
        }
      } else {
        // Insert placeholder for empty chunks if needed for correct 'и' placement later
        if (parts.isNotEmpty && scalePower > 0 && remaining > BigInt.zero) {
          parts.insert(0, _ChunkInfo(0, ""));
        }
      }

      scalePower += 3; // Move to the next scale level
    }

    // Join the processed chunks with appropriate separators (" " or " и ")
    final StringBuffer result = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      final _ChunkInfo currentPart = parts[i];
      if (currentPart.text.isEmpty) continue; // Skip placeholders

      result.write(currentPart.text);

      // Check if a separator is needed before the *next* non-empty part
      int nextPartIndex = -1;
      for (int j = i + 1; j < parts.length; j++) {
        if (parts[j].text.isNotEmpty) {
          nextPartIndex = j;
          break;
        }
      }

      if (nextPartIndex != -1) {
        final _ChunkInfo nextPart = parts[nextPartIndex];
        // Determine if "и" is needed between chunks.
        // Generally needed if the next chunk is < 100, OR
        // in year context if the next chunk is a multiple of 100 (e.g., 1900 = хиляда *и* деветстотин).
        final bool needsAnd = (nextPart.value < 100) ||
            (isYearContext && nextPart.value % 100 == 0);
        result.write(needsAnd ? " $_andConjunction " : " ");
      }
    }

    return result.toString();
  }

  /// Converts a three-digit integer (0-999) into its Bulgarian word representation.
  /// Handles hundreds, tens, units, and the conjunction 'и'.
  ///
  /// - `n` The integer chunk (0-999).
  /// - `gender` The grammatical [Gender] required for 1 and 2 within this chunk.
  /// - `forceMasculineOne` If true, forces the use of "един" for 1, overriding `gender`.
  ///   Used for masculine scale words (милион, милиард).
  /// Returns the chunk as words.
  String _convertChunk(int n, Gender gender, bool forceMasculineOne) {
    if (n == 0) return ""; // Nothing to convert for zero chunk
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }

    final StringBuffer words = StringBuffer();
    int remainder = n;

    // --- Hundreds ---
    if (remainder >= 100) {
      words.write(_wordsHundreds[remainder ~/ 100]);
      remainder %= 100;

      // Add separator if there are remaining tens/units
      if (remainder > 0) {
        // Determine if "и" is needed after hundreds.
        // Needed if the remainder is < 10 (e.g., сто *и* едно) or 11-19 (e.g., сто *и* единадесет),
        // OR if the remainder is a multiple of 10 (e.g. сто и двадесет) - this differs from some languages.
        // Test cases show "сто двадесет", "сто и едно", "сто и единадесет".
        final bool needsAndAfterHundred =
            (remainder < 10 || (remainder >= 11 && remainder < 20));
        words.write(needsAndAfterHundred ? " $_andConjunction " : " ");
      }
    }

    // --- Tens and Units ---
    if (remainder > 0) {
      if (remainder < 20) {
        // Numbers 1-19
        String word;
        if (remainder == 1 && forceMasculineOne) {
          // Special case for "един милион", etc.
          word = _masculineOne;
        } else {
          // Use gender-specific form for 1 or 2, or standard form otherwise
          word = _getGenderSpecificWord(remainder, gender);
        }
        words.write(word);
      } else {
        // Numbers 20-99
        final String tensWord = _wordsTens[
            remainder ~/ 10]; // Get the tens word (двадесет, тридесет...)
        words.write(tensWord);
        final int unit = remainder % 10;
        if (unit > 0) {
          // Add "и" before the unit (e.g., двадесет *и* едно)
          words.write(" $_andConjunction ");

          String unitWord;
          if (unit == 1 && forceMasculineOne) {
            // Apply forceMasculineOne to the unit as well
            unitWord = _masculineOne;
          } else {
            // Get the unit word with correct gender
            unitWord = _getGenderSpecificWord(unit, gender);
          }
          words.write(unitWord);
        }
      }
    }

    return words.toString();
  }
}
