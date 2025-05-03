import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/bg_options.dart';
import '../utils/utils.dart';

/// Internal helper class for assembling large number conversions.
///
/// Stores the integer value, word representation, and scale level (0=units, 1=thousands, etc.)
/// of a three-digit chunk processed by [_convertInteger].
class _ChunkInfo {
  final int value;
  final String text;
  final int scaleLevel;
  _ChunkInfo(this.value, this.text, this.scaleLevel);
}

/// {@template num2text_bg}
/// Converts numbers into their Bulgarian word representations (`Lang.BG`).
///
/// Implements [Num2TextBase] for Bulgarian, handling various numeric types.
/// Features include:
/// *   Cardinal number conversion (positive/negative).
/// *   Decimal handling with appropriate separators ("цяло и" or "точка").
/// *   Currency formatting (default BGN) via [BgOptions.currencyInfo].
/// *   Year formatting with optional era suffixes (AD/BC).
/// *   Correct grammatical gender (masculine, feminine, neuter) for numbers 1 and 2 based on context.
/// *   Bulgarian short scale names (хиляда, милион, милиард).
/// *   Customization via [BgOptions].
/// *   Fallback messages for invalid inputs.
/// {@endtemplate}
class Num2TextBG implements Num2TextBase {
  // --- Constants ---

  static const String _zero = "нула";
  static const String _andConjunction = "и"; // "and"
  /// Default decimal separator word "цяло и" (whole and), used for [DecimalSeparator.comma].
  static const String _defaultDecimalSeparatorWord = "цяло и";

  /// Decimal separator word "точка" (point), used for [DecimalSeparator.period] or [DecimalSeparator.point].
  static const String _pointWord = "точка";

  /// Suffix for BC years ("преди новата ера" - before the new era).
  static const String _yearSuffixBC = "преди новата ера";

  /// Suffix for AD years ("от новата ера" - of the new era), used if [BgOptions.includeAD] is true.
  static const String _yearSuffixAD = "от новата ера";

  /// Words 0-19 (Neuter/Default forms for 1/2). Gender variants handled by [_getGenderSpecificWord].
  static const List<String> _wordsUnder20 = [
    _zero,
    "едно",
    "две",
    "три",
    "четири",
    "пет",
    "шест",
    "седем",
    "осем",
    "девет",
    "десет",
    "единадесет",
    "дванадесет",
    "тринадесет",
    "четиринадесет",
    "петнадесет",
    "шестнадесет",
    "седемнадесет",
    "осемнадесет",
    "деветнадесет",
  ];

  // Gender-specific forms for 1 and 2.
  static const String _masculineOne = "един"; // 1 (M)
  static const String _feminineOne = "една"; // 1 (F)
  static const String _neuterOne = "едно"; // 1 (N)
  static const String _masculineTwo = "два"; // 2 (M)
  static const String _feminineTwo = "две"; // 2 (F)
  static const String _neuterTwo = "две"; // 2 (N) - same as feminine

  /// Words for tens (20, 30... 90).
  static const List<String> _wordsTens = [
    "",
    "",
    "двадесет",
    "тридесет",
    "четиридесет",
    "петдесет",
    "шестдесет",
    "седемдесет",
    "осемдесет",
    "деветдесет",
  ];

  /// Words for hundreds (100, 200... 900).
  static const List<String> _wordsHundreds = [
    "",
    "сто",
    "двеста",
    "триста",
    "четиристотин",
    "петстотин",
    "шестстотин",
    "седемстотин",
    "осемстотин",
    "деветстотин",
  ];

  /// Scale words (short scale). Maps power of 1000 to [singular, plural].
  /// Gender: хиляда (F), милион/милиард/... (M).
  static const Map<int, List<String>> _scaleWords = {
    3: ["хиляда", "хиляди"], // Thousand (F)
    6: ["милион", "милиона"], // Million (M)
    9: ["милиард", "милиарда"], // Billion (M)
    12: ["трилион", "трилиона"], // Trillion (M)
    15: ["квадрилион", "квадрилиона"], // Quadrillion (M)
    18: ["квинтилион", "квинтилиона"], // Quintillion (M)
    21: ["секстилион", "секстилиона"], // Sextillion (M)
    24: ["септилион", "септилиона"], // Septillion (M)
    // Add more scales as needed
  };

  // --- Public API Method ---

  /// {@macro num2text_base_process}
  ///
  /// Processes the given [number] into Bulgarian words.
  ///
  /// @param number The number to convert.
  /// @param options Optional [BgOptions] for customization.
  /// @param fallbackOnError Optional error string (defaults to "Не е число").
  /// @return The number as Bulgarian words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final BgOptions bgOptions =
        options is BgOptions ? options : const BgOptions();
    final String errorFallback =
        fallbackOnError ?? "Не е число"; // "Not a number"

    // Handle non-finite doubles.
    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Отрицателна безкрайност" : "Безкрайност";
      if (number.isNaN) return errorFallback;
    }

    // Normalize to Decimal.
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    // Handle zero.
    if (decimalValue == Decimal.zero) {
      if (bgOptions.currency) {
        final String zeroUnit = bgOptions.currencyInfo.mainUnitPlural ??
            bgOptions.currencyInfo.mainUnitSingular;
        return "$_zero $zeroUnit"; // e.g., "нула лева"
      }
      return _zero; // "нула"
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Dispatch based on format.
    if (bgOptions.format == Format.year) {
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), bgOptions);
    } else {
      if (bgOptions.currency) {
        textResult = _handleCurrency(absValue, bgOptions);
      } else {
        textResult = _handleStandardNumber(absValue, bgOptions);
      }
      // Prepend negative prefix if needed (not for years).
      if (isNegative) {
        textResult = "${bgOptions.negativePrefix} $textResult";
      }
    }

    return textResult.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Converts a non-negative integer into Bulgarian words, handling scales and gender.
  ///
  /// This is the core recursive/iterative logic for large numbers.
  /// It breaks the number into 3-digit chunks, converts them considering the grammatical
  /// gender required by the context (standalone, currency unit, scale word), and
  /// combines them with scale words (хиляда, милион, etc.) and the conjunction "и".
  ///
  /// @param n The non-negative integer to convert.
  /// @param contextGender The grammatical gender required for the number '1' and '2'
  ///                      in the least significant part or determined by the scale word.
  /// @param isYearContext If true, applies specific logic for joining parts in years (currently not distinct).
  /// @return The integer as Bulgarian words.
  /// @throws ArgumentError if `n` is negative.
  String _convertInteger(BigInt n, Gender contextGender, bool isYearContext) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) {
      throw ArgumentError("Input must be non-negative: $n");
    }

    // Handle numbers < 1000 directly.
    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt(), contextGender, false);
    }

    final List<_ChunkInfo> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    BigInt remaining = n;
    int scalePower = 0; // Power of 1000 (0=units, 1=thousands, ...)

    while (remaining > BigInt.zero) {
      final int chunkValueInt = (remaining % oneThousand).toInt();
      remaining ~/= oneThousand;
      int currentScaleLevel =
          scalePower * 3; // Power of 10 (e.g., 3=thousands, 6=millions)

      if (chunkValueInt > 0) {
        Gender chunkGender; // Gender context for this specific chunk.
        String scaleWordText =
            ""; // Text for the scale word (e.g., "хиляди", "милиона").
        bool omitUnitsForSingularThousand =
            false; // Use "хиляда" instead of "една хиляда"?

        // Determine chunk gender and scale word based on the scale level.
        if (currentScaleLevel >= 6) {
          // Millions, Billions, etc. (Masculine)
          chunkGender = Gender.masculine;
          if (_scaleWords.containsKey(currentScaleLevel)) {
            scaleWordText = chunkValueInt == 1
                ? _scaleWords[currentScaleLevel]![0]
                : _scaleWords[currentScaleLevel]![1];
          }
          if (chunkValueInt == 1) {
            // Example: "един милион" - the '1' should be masculine 'един'.
            // forceMasculineOneForChunk seems intended for this, but _convertChunk uses 'gender'.
            // Check if _convertChunk respects forceMasculineOne when gender is masculine.
            // If _convertChunk already handles Gender.masculine correctly, this flag might be redundant.
            // Assuming _convertChunk uses the 'gender' parameter primarily.
          }
        } else if (currentScaleLevel == 3) {
          // Thousands (Feminine)
          chunkGender = Gender.feminine;
          if (_scaleWords.containsKey(currentScaleLevel)) {
            scaleWordText = chunkValueInt == 1
                ? _scaleWords[currentScaleLevel]![0]
                : _scaleWords[currentScaleLevel]![1];
          }
          // Special case: "хиляда" (1000) vs "една хиляда".
          // Typically, "хиляда" is used alone for 1000. "Една хиляда" might imply "one thousand (of something)".
          if (chunkValueInt == 1) {
            omitUnitsForSingularThousand = true; // Omit the "една" part.
          }
        } else {
          // Units chunk (0-999) - use the context gender passed in.
          chunkGender = contextGender;
        }

        // Convert the 0-999 chunk to words, applying the determined gender.
        // Pass false for forceMasculineOne, rely on chunkGender.
        final String chunkText = omitUnitsForSingularThousand
            ? ""
            : _convertChunk(chunkValueInt, chunkGender, false);

        // Combine the chunk text (e.g., "двеста") with the scale word (e.g., "хиляди").
        final String combinedText = scaleWordText.isEmpty
            ? chunkText
            : (chunkText.isEmpty ? scaleWordText : '$chunkText $scaleWordText');

        // Store the processed chunk info.
        if (combinedText.isNotEmpty) {
          parts.insert(0, _ChunkInfo(chunkValueInt, combinedText, scalePower));
        }
      } else {
        // Handle zero chunks (e.g., in 1,000,500) to potentially place separators later.
        // This logic seems complex and might be simplified. Review if it's strictly needed.
        if (parts.isNotEmpty && scalePower > 0 && remaining > BigInt.zero) {
          // parts.insert(0, _ChunkInfo(0, "", scalePower)); // Keep track of zero chunks?
        }
      }
      scalePower++;
    }

    // Assemble the final string from parts, adding conjunctions ("и") where needed.
    // Bulgarian rule: "и" is typically used before the last component if it's < 100
    // (e.g., "хиляда и пет", "двеста и петдесет", "триста двадесет и едно").
    // It's NOT used like English "one hundred AND twenty-three".
    final StringBuffer result = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      final _ChunkInfo currentPart = parts[i];
      if (currentPart.text.isEmpty) continue;

      result.write(currentPart.text);

      // Determine if a conjunction ("и") or space is needed before the next part.
      int nextPartIndex = -1;
      for (int j = i + 1; j < parts.length; j++) {
        if (parts[j].text.isNotEmpty) {
          nextPartIndex = j;
          break;
        }
      }

      if (nextPartIndex != -1) {
        final _ChunkInfo nextPart = parts[nextPartIndex];

        // Add "и" if the *next* part is the final units chunk (scaleLevel 0)
        // AND its value is < 100 or a multiple of 100 (like 100, 200 - unusual case here).
        final bool isNextPartUnitsChunk = (nextPart.scaleLevel == 0);
        // Add "и" before numbers like 1-99, 10, 20, etc. and potentially before 100, 200? (check rule)
        // Rule refined: Add "и" if next part is the last chunk AND (value is < 100 OR value is multiple of 100).
        final bool nextPartValueNeedsAnd =
            (nextPart.value < 100 && nextPart.value > 0) ||
                (nextPart.value % 100 == 0 &&
                    nextPart.value > 0 &&
                    nextPart.value < 1000);

        if (isNextPartUnitsChunk && nextPartValueNeedsAnd) {
          result.write(" $_andConjunction ");
        } else {
          result.write(" "); // Just a space between scales otherwise.
        }
      }
    }

    return result.toString().trim();
  }

  /// Formats an integer as a Bulgarian year with optional era suffixes.
  ///
  /// Converts the year using neuter gender and appends "преди новата ера" (BC)
  /// or "от новата ера" (AD) based on sign and [BgOptions.includeAD].
  ///
  /// @param year The integer year.
  /// @param options The [BgOptions].
  /// @return The year as Bulgarian words.
  String _handleYearFormat(int year, BgOptions options) {
    if (year == 0) return _zero; // Technically no year zero.
    final bool isNegative = year < 0;
    final BigInt bigAbsYear = BigInt.from(isNegative ? -year : year);

    // Years are typically converted using neuter gender.
    String yearText = _convertInteger(bigAbsYear, Gender.neuter, true);

    // Append era suffixes.
    if (isNegative)
      yearText += " $_yearSuffixBC";
    else if (options.includeAD)
      yearText += " $_yearSuffixAD"; // Only add AD if requested.

    return yearText;
  }

  /// Formats a non-negative [Decimal] as Bulgarian currency (Lev/Stotinka).
  ///
  /// Handles rounding, unit separation, gender agreement (Lev=M, Stotinka=F),
  /// singular/plural forms, and joining with "и" (or custom separator).
  ///
  /// @param absValue The absolute currency value.
  /// @param options The [BgOptions] with currency info.
  /// @return The currency value as Bulgarian words.
  String _handleCurrency(Decimal absValue, BgOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    const int decimalPlaces = 2;
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round if requested.
    final Decimal valueToConvert =
        options.round ? absValue.round(scale: decimalPlaces) : absValue;

    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart =
        valueToConvert - Decimal.fromBigInt(mainValue);
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round().toBigInt();

    String mainPartString = "";
    if (mainValue > BigInt.zero) {
      // Main unit (Lev) is masculine.
      final String mainText =
          _convertInteger(mainValue, Gender.masculine, false);
      // Select singular ("лев") or plural ("лева").
      final String mainUnitName = (mainValue == BigInt.one)
          ? currencyInfo.mainUnitSingular
          : (currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular);
      mainPartString = '$mainText $mainUnitName';
    }

    String subunitPartString = "";
    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      // Subunit (Stotinka) is feminine.
      final String subunitText =
          _convertInteger(subunitValue, Gender.feminine, false);
      // Select singular ("стотинка") or plural ("стотинки").
      final String subUnitName = (subunitValue == BigInt.one)
          ? currencyInfo.subUnitSingular!
          : (currencyInfo.subUnitPlural ?? currencyInfo.subUnitSingular!);
      subunitPartString = '$subunitText $subUnitName';
    }

    // Combine parts.
    if (mainPartString.isNotEmpty && subunitPartString.isNotEmpty) {
      final String separator = currencyInfo.separator ?? _andConjunction;
      return '$mainPartString $separator $subunitPartString';
    } else if (mainPartString.isNotEmpty) {
      return mainPartString;
    } else if (subunitPartString.isNotEmpty) {
      // Handle cases like 0.50 -> "петдесет стотинки".
      return subunitPartString;
    } else {
      // Should be handled by zero check in `process`, but fallback for safety.
      final String zeroUnit =
          currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;
      return "$_zero $zeroUnit";
    }
  }

  /// Converts a non-negative standard [Decimal] number into Bulgarian words.
  ///
  /// Handles integer and fractional parts. Integer part uses neuter gender.
  /// Fractional part is read digit-by-digit after the separator word ("цяло и" or "точка").
  /// Removes trailing zeros from the fractional part display.
  ///
  /// @param absValue The absolute decimal value.
  /// @param options The [BgOptions] with decimal separator preference.
  /// @return The number as Bulgarian words.
  String _handleStandardNumber(Decimal absValue, BgOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - Decimal.fromBigInt(integerPart);

    // Integer part uses neuter gender for standard numbers. Handle 0.x cases.
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, Gender.neuter, false);

    String fractionalWords = '';
    // Process fractional part only if non-zero and the number isn't effectively an integer.
    if (fractionalPart > Decimal.zero && !absValue.isInteger) {
      String decimalString = absValue.toString();
      String fractionalDigits =
          decimalString.contains('.') ? decimalString.split('.').last : '';
      fractionalDigits = fractionalDigits.replaceAll(
          RegExp(r'0+$'), ''); // Remove trailing zeros

      if (fractionalDigits.isNotEmpty) {
        // Convert digits to words (using default neuter forms).
        final List<String> digitWordsList =
            fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          return (digitInt != null &&
                  digitInt >= 0 &&
                  digitInt < _wordsUnder20.length)
              ? _wordsUnder20[digitInt]
              : '?';
        }).toList();
        final String fractionalText = digitWordsList.join(' ');

        // Choose separator word based on options.
        final String separatorWord =
            (options.decimalSeparator ?? DecimalSeparator.comma) ==
                    DecimalSeparator.comma
                ? _defaultDecimalSeparatorWord // "цяло и"
                : _pointWord; // "точка"

        fractionalWords = ' $separatorWord $fractionalText';
      }
    }
    return '$integerWords$fractionalWords';
  }

  /// Returns the gender-specific Bulgarian word for 1 or 2.
  ///
  /// @param number The number (expected 1 or 2).
  /// @param gender The required [Gender].
  /// @return The gender-specific word ("един"/"една"/"едно" or "два"/"две").
  ///         Returns the default form for other numbers 0, 3-19.
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
          return _neuterTwo; // Neuter 2 is same as Feminine 2.
      }
    }
    // Fallback for 0, 3-19.
    return (number >= 0 && number < _wordsUnder20.length)
        ? _wordsUnder20[number]
        : '';
  }

  /// Converts an integer chunk (0-999) into Bulgarian words.
  ///
  /// Handles hundreds, tens, units, applying gender to 1/2 and using the conjunction "и"
  /// according to Bulgarian grammar (e.g., "сто и едно", "сто и десет", "сто двадесет и три").
  ///
  /// @param n The integer chunk (0-999).
  /// @param gender The required [Gender] for 1 and 2.
  /// @param forceMasculineOne Currently unused, relies on [gender]. Set to true if needed for specific scale word cases.
  /// @return The chunk as Bulgarian words. Returns empty string for 0.
  /// @throws ArgumentError if `n` is outside 0-999.
  String _convertChunk(int n, Gender gender, bool forceMasculineOne) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    final StringBuffer words = StringBuffer();
    int remainder = n;

    // Handle hundreds.
    if (remainder >= 100) {
      words.write(_wordsHundreds[remainder ~/ 100]); // "сто", "двеста", etc.
      remainder %= 100;
      if (remainder > 0) {
        // Add "и" if needed before tens/units:
        // Rule: Add "и" unless the remainder is like 21-29, 31-39, ... (20+ and not multiple of 10).
        // Add "и" for 1-19, 20, 30, etc.
        final bool needsAndAfterHundred =
            (remainder < 20 || remainder % 10 == 0);
        words.write(needsAndAfterHundred ? " $_andConjunction " : " ");
      }
    }

    // Handle tens and units (0-99).
    if (remainder > 0) {
      if (remainder < 20) {
        // 1-19: use gender-specific word.
        words.write(_getGenderSpecificWord(remainder, gender));
      } else {
        // 20-99:
        final String tensWord = _wordsTens[remainder ~/ 10]; // "двадесет", etc.
        words.write(tensWord);
        final int unit = remainder % 10;
        if (unit > 0) {
          // Add "и" before the unit digit (e.g., "двадесет и три").
          words.write(" $_andConjunction ");
          words.write(_getGenderSpecificWord(
              unit, gender)); // Use gender-specific unit.
        }
      }
    }
    return words.toString();
  }
}
