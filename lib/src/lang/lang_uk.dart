import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/uk_options.dart';
import '../utils/utils.dart';

class _ScaleInfo {
  final String nomSg;
  final String nomPl;
  final String genPl;
  final Gender gender;

  const _ScaleInfo({
    required this.nomSg,
    required this.nomPl,
    required this.genPl,
    required this.gender,
  });
}

/// {@template num2text_uk}
/// Converts numbers to Ukrainian words (`Lang.UK`).
///
/// Implements [Num2TextBase] for the Ukrainian language. Handles various numeric inputs
/// and converts them according to standard Ukrainian grammatical rules, including:
/// - Cardinal numbers with gender agreement.
/// - Currency formatting with correct noun declension.
/// - Year formatting.
/// - Decimal numbers.
/// - Negative numbers.
/// - Large numbers using scale words (тисяча, мільйон, etc.).
///
/// Customization is available via [UkOptions] (e.g., specifying gender, currency details, AD/BC suffixes).
/// Returns a fallback string on error.
/// {@endtemplate}
class Num2TextUK implements Num2TextBase {
  /// Holds grammatical information for scale words (thousand, million, etc.).
  /// Includes singular/plural nominative forms, genitive plural, and grammatical gender.

  // --- Constants ---
  static const String _zero = "нуль";
  static const String _commaWord = "кома"; // Word for "," decimal separator
  static const String _periodWord = "крапка"; // Word for "." decimal separator
  static const String _yearSuffixAD =
      "н.е."; // "нашої ери" (Anno Domini / Common Era)
  static const String _yearSuffixBC =
      "до н.е."; // "до нашої ери" (Before Christ / Before Common Era)
  static const String _infinity = "Нескінченність";
  static const String _negativeInfinity = "Негативна Нескінченність";
  static const String _notANumber = "Не Число"; // Default fallback for NaN etc.

  // --- Number Words (Units, Teens, Tens, Hundreds) ---

  /// Units 1-9 (Masculine form)
  static const List<String> _unitsMasculine = [
    "",
    "один",
    "два",
    "три",
    "чотири",
    "п'ять",
    "шість",
    "сім",
    "вісім",
    "дев'ять",
  ];

  /// Units 1-9 (Feminine form - used for "одна тисяча")
  static const List<String> _unitsFeminine = [
    "",
    "одна",
    "дві",
    "три",
    "чотири",
    "п'ять",
    "шість",
    "сім",
    "вісім",
    "дев'ять",
  ];

  /// Units 1-9 (Neuter form)
  static const List<String> _unitsNeuter = [
    "",
    "одне",
    "два",
    "три",
    "чотири",
    "п'ять",
    "шість",
    "сім",
    "вісім",
    "дев'ять",
  ];

  /// Numbers 10-19
  static const List<String> _teens = [
    "десять",
    "одинадцять",
    "дванадцять",
    "тринадцять",
    "чотирнадцять",
    "п'ятнадцять",
    "шістнадцять",
    "сімнадцять",
    "вісімнадцять",
    "дев'ятнадцять",
  ];

  /// Tens 20-90
  static const List<String> _tens = [
    "",
    "",
    "двадцять",
    "тридцять",
    "сорок",
    "п'ятдесят",
    "шістдесят",
    "сімдесят",
    "вісімдесят",
    "дев'яносто",
  ];

  /// Hundreds 100-900
  static const List<String> _hundreds = [
    "",
    "сто",
    "двісті",
    "триста",
    "чотириста",
    "п'ятсот",
    "шістсот",
    "сімсот",
    "вісімсот",
    "дев'ятсот",
  ];

  /// Scale words map. Key is the power of 1000 (1=thousand, 2=million, ...).
  static final Map<int, _ScaleInfo> _scaleWords = {
    1: _ScaleInfo(
        nomSg: "тисяча",
        nomPl: "тисячі",
        genPl: "тисяч",
        gender: Gender.feminine),
    2: _ScaleInfo(
        nomSg: "мільйон",
        nomPl: "мільйони",
        genPl: "мільйонів",
        gender: Gender.masculine),
    3: _ScaleInfo(
        nomSg: "мільярд",
        nomPl: "мільярди",
        genPl: "мільярдів",
        gender: Gender.masculine),
    4: _ScaleInfo(
        nomSg: "трильйон",
        nomPl: "трильйони",
        genPl: "трильйонів",
        gender: Gender.masculine),
    5: _ScaleInfo(
        nomSg: "квадрильйон",
        nomPl: "квадрильйони",
        genPl: "квадрильйонів",
        gender: Gender.masculine),
    6: _ScaleInfo(
        nomSg: "квінтильйон",
        nomPl: "квінтильйони",
        genPl: "квінтильйонів",
        gender: Gender.masculine),
    7: _ScaleInfo(
        nomSg: "секстильйон",
        nomPl: "секстильйони",
        genPl: "секстильйонів",
        gender: Gender.masculine),
    8: _ScaleInfo(
        nomSg: "септильйон",
        nomPl: "септильйони",
        genPl: "септильйонів",
        gender: Gender.masculine),
  };

  /// Processes the given [number] into Ukrainian words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options_uk}
  /// Uses [UkOptions] for customization:
  /// - `currency`: Formats as currency with correct declension.
  /// - `format`: Applies specific formatting (e.g., [Format.year]).
  /// - `gender`: Specifies grammatical gender for number agreement (default Masculine).
  /// - `decimalSeparator`: Word for decimal point (default Comma).
  /// - `negativePrefix`: Prefix for negative numbers (default "мінус").
  /// - `includeAD`: Adds era suffixes (н.е./до н.е.) for years.
  /// - `round`: Rounds currency values.
  /// Defaults apply if [options] is null or not [UkOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or "Не Число" on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [UkOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Ukrainian words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final UkOptions ukOptions =
        options is UkOptions ? options : const UkOptions();
    final String onError = fallbackOnError ?? _notANumber;

    // Handle special doubles
    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _negativeInfinity : _infinity;
      if (number.isNaN) return onError;
    }

    // Normalize and check input
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return onError;

    // Handle zero
    if (decimalValue == Decimal.zero) {
      if (ukOptions.currency) {
        // Use Genitive Plural for zero amount currency ("нуль гривень")
        return "$_zero ${_getNounForm(BigInt.zero, ukOptions.currencyInfo.mainUnitSingular, ukOptions.currencyInfo.mainUnitPlural2To4!, ukOptions.currencyInfo.mainUnitPluralGenitive!)}";
      } else {
        return _zero;
      }
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Delegate based on format
    if (ukOptions.format == Format.year) {
      // Year format handles sign internally (BC/AD)
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), ukOptions);
    } else if (ukOptions.currency) {
      textResult = _handleCurrency(absValue, ukOptions);
    } else {
      textResult = _handleStandardNumber(absValue, ukOptions);
    }

    // Add negative prefix if needed (but not for years)
    if (isNegative && ukOptions.format != Format.year) {
      textResult = "${ukOptions.negativePrefix} $textResult";
    }

    // Clean up extra spaces before returning
    return textResult.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Converts a non-negative integer ([BigInt]) into Ukrainian words, applying gender agreement.
  ///
  /// Handles large numbers by breaking them into chunks based on scale words (thousand, million, etc.).
  /// The [chunkGender] parameter determines the grammatical gender agreement for the final chunk (0-999)
  /// and influences the form of 'one'/'two' when preceding scale words like 'тисяча'.
  /// Delegates chunks of 0-999 to [_convertChunk].
  /// Special rule: Omits "один" before "мільйон", "мільярд", etc. (but not before "тисяча").
  ///
  /// @param n The non-negative integer to convert.
  /// @param chunkGender The target grammatical gender for the number words.
  /// @throws ArgumentError if [n] is negative or too large for defined scales.
  /// @return The integer as Ukrainian words.
  String _convertInteger(BigInt n, Gender chunkGender) {
    if (n == BigInt.zero)
      return ""; // Zero is handled by caller or results in empty string within larger number.
    if (n < BigInt.zero)
      throw ArgumentError("Negative numbers handled by caller.");

    // Rule 2: Handle exact scale powers (1 million, 1 billion, etc.) - omit "один"
    // Start check from scale 2 (million) upwards.
    for (int scaleIndex =
            _scaleWords.keys.fold(0, (max, k) => k > max ? k : max);
        scaleIndex >= 2;
        scaleIndex--) {
      if (_scaleWords.containsKey(scaleIndex)) {
        final BigInt scalePower = BigInt.from(1000).pow(scaleIndex);
        if (n == scalePower) {
          return _scaleWords[scaleIndex]!.nomSg; // e.g., "мільйон", "мільярд"
        }
      }
    }
    // Note: Rule 1 (exactly 1000 -> "одна тисяча") handled by loop below.

    // Base case: numbers less than 1000
    if (n < BigInt.from(1000)) return _convertChunk(n.toInt(), chunkGender);

    final List<String> parts = [];
    BigInt remaining = n;
    final BigInt oneThousand = BigInt.from(1000);
    // Calculate the highest relevant scale index for the number.
    int maxScale = 0;
    if (n >= oneThousand) {
      final int highestDefinedScale =
          _scaleWords.keys.fold(0, (max, k) => k > max ? k : max);
      // Find the highest scale index <= number's magnitude
      for (int i = highestDefinedScale; i >= 1; i--) {
        if (n >= oneThousand.pow(i)) {
          maxScale = i;
          break;
        }
      }
    }

    // Iterate through scales from highest down to thousand.
    for (int i = maxScale; i >= 1; i--) {
      final BigInt scaleDivisor = oneThousand.pow(i);
      if (remaining >= scaleDivisor) {
        final BigInt chunkBigInt = remaining ~/ scaleDivisor;
        remaining %= scaleDivisor; // Update remainder for next lower scale

        if (chunkBigInt > BigInt.zero) {
          final _ScaleInfo scaleInfo = _scaleWords[i]!;

          // Determine gender agreement for the number part counting the scale word.
          // Special case: Use Feminine 'одна'/'дві' for 1 or 2 before 'тисяча' (scale index 1).
          // Otherwise, use the gender of the scale word itself (e.g., Masculine for 'мільйон').
          final Gender genderForChunkNumber = (i == 1 &&
                  (chunkBigInt == BigInt.one || chunkBigInt == BigInt.two))
              ? Gender.feminine
              : scaleInfo.gender;

          // Convert the count (e.g., "сто двадцять три") using the determined gender.
          final String chunkText = _convertInteger(chunkBigInt,
              genderForChunkNumber); // Recursive call for count > 999 unlikely but possible

          // Get the correct grammatical form of the scale word based on the count.
          final String scaleNoun = _getNounForm(
              chunkBigInt, scaleInfo.nomSg, scaleInfo.nomPl, scaleInfo.genPl);

          parts.add("$chunkText $scaleNoun".trim());
        }
      }
    }

    // Handle the final 0-999 chunk (if any) using the overall requested gender.
    if (remaining > BigInt.zero) {
      parts.add(_convertChunk(remaining.toInt(), chunkGender));
    }

    // Join the parts (e.g., "сто двадцять три мільйони п'ятсот тисяч шістсот").
    return parts.join(' ').trim();
  }

  /// Converts a standard non-currency, non-year [Decimal] number to Ukrainian words.
  ///
  /// Handles integer and fractional parts separately.
  /// Applies grammatical gender agreement using [UkOptions.gender].
  /// Converts the fractional part digit by digit after the separator word.
  ///
  /// @param absValue The absolute decimal value.
  /// @param options Formatting options including gender and decimal separator.
  /// @return Number as Ukrainian words.
  String _handleStandardNumber(Decimal absValue, UkOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = (absValue - absValue.truncate()).abs();

    // Determine the gender to use for integer conversion (default masculine if not specified).
    final Gender effectiveGender = options.gender ?? Gender.masculine;

    // Convert the integer part, using "нуль" if it's 0 but a fraction exists.
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, effectiveGender);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Convert fractional part if it exists.
      fractionalWords = _getFractionalWords(absValue, options);
    }

    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts an integer between 0 and 999 into Ukrainian words with gender agreement.
  ///
  /// Handles hundreds, tens, teens, and units. Uses the correct gender form for 1 and 2.
  ///
  /// @param n The integer chunk (0-999).
  /// @param gender The target grammatical gender.
  /// @throws ArgumentError if [n] is outside the 0-999 range.
  /// @return The chunk as Ukrainian words, or empty string if [n] is 0.
  String _convertChunk(int n, Gender gender) {
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk value must be between 0 and 999, but was $n.");
    }
    if (n == 0) return "";

    final List<String> words = [];
    int remainder = n;

    // Handle hundreds place
    if (remainder >= 100) {
      words.add(_hundreds[remainder ~/ 100]);
      remainder %= 100;
    }

    // Handle tens and units place (1-99)
    if (remainder > 0) {
      if (remainder < 10) {
        // Units 1-9: Select the correct gendered form.
        final units = (gender == Gender.feminine)
            ? _unitsFeminine
            : (gender == Gender.neuter ? _unitsNeuter : _unitsMasculine);
        words.add(units[remainder]);
      } else if (remainder < 20) {
        // Teens 10-19: No gender variation needed.
        words.add(_teens[remainder - 10]);
      } else {
        // Tens 20-99
        words.add(_tens[remainder ~/ 10]); // e.g., "двадцять", "тридцять"
        final int unit = remainder % 10;
        if (unit > 0) {
          // Add unit if present, selecting the correct gendered form.
          final units = (gender == Gender.feminine)
              ? _unitsFeminine
              : (gender == Gender.neuter ? _unitsNeuter : _unitsMasculine);
          words.add(units[unit]);
        }
      }
    }

    return words.join(' ');
  }

  /// Converts an integer to Ukrainian words following year conventions.
  ///
  /// Standard conversion for most years, but handles common ranges:
  /// - 1000: "тисяча"
  /// - 1xxx: "тисяча [remainder]"
  /// - 2xxx: "дві тисячі [remainder]"
  /// Appends AD/BC suffixes if requested via [UkOptions.includeAD].
  /// Uses masculine gender agreement for year numbers.
  ///
  /// @param year The integer year.
  /// @param options Formatting options.
  /// @return The year as Ukrainian words.
  String _handleYearFormat(BigInt year, UkOptions options) {
    final bool isNegative = year < BigInt.zero;
    final BigInt absYear = isNegative ? -year : year;
    String yearText = '';

    if (absYear == BigInt.zero)
      yearText = _zero;
    // Specific handling for 1000-2999 range often read differently.
    else if (absYear == BigInt.from(1000))
      yearText = _scaleWords[1]!.nomSg; // "тисяча"
    else if (absYear > BigInt.from(1000) && absYear < BigInt.from(2000)) {
      // e.g., 1999 -> "тисяча дев'ятсот дев'яносто дев'ять"
      yearText = _scaleWords[1]!.nomSg; // "тисяча"
      final BigInt remainder = absYear % BigInt.from(1000);
      // Remainder uses Masculine gender for years.
      yearText += " ${_convertChunk(remainder.toInt(), Gender.masculine)}";
    } else if (absYear >= BigInt.from(2000) && absYear < BigInt.from(3000)) {
      // e.g., 2024 -> "дві тисячі двадцять чотири"
      yearText =
          "${_unitsFeminine[2]} ${_scaleWords[1]!.nomPl}"; // "дві тисячі"
      final BigInt remainder = absYear % BigInt.from(1000);
      if (remainder > BigInt.zero) {
        // Remainder uses Masculine gender for years.
        yearText += " ${_convertChunk(remainder.toInt(), Gender.masculine)}";
      }
    } else {
      // Default: Treat other years as standard numbers (masculine gender).
      yearText = _convertInteger(absYear, Gender.masculine);
    }

    // Append era suffixes if needed.
    if (isNegative)
      yearText += " $_yearSuffixBC";
    else if (options.includeAD && absYear > BigInt.zero)
      yearText += " $_yearSuffixAD";

    return yearText.trim();
  }

  /// Converts a non-negative [Decimal] to Ukrainian currency words.
  ///
  /// Uses [UkOptions.currencyInfo] for unit names and declension rules.
  /// Rounds if [UkOptions.round] is true. Separates main and subunits.
  /// Applies correct noun forms using [_getNounForm].
  /// Main currency amount uses feminine agreement (common practice).
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options with currency info.
  /// @return Currency value as Ukrainian words.
  String _handleCurrency(Decimal absValue, UkOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final Decimal valueToConvert =
        options.round ? absValue.round(scale: 2) : absValue;

    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final BigInt subunitValue =
        ((valueToConvert - valueToConvert.truncate()).abs() *
                Decimal.fromInt(100))
            .round(scale: 0)
            .toBigInt();

    final List<String> resultParts = [];

    // Process main currency part (if > 0 or if it's exactly zero)
    if (mainValue > BigInt.zero ||
        (mainValue == BigInt.zero && subunitValue == BigInt.zero)) {
      // Convert the main amount number itself using feminine gender agreement.
      final String mainText = _convertInteger(mainValue, Gender.feminine);
      // Determine the correct form of the main currency noun (e.g., гривня, гривні, гривень).
      final String mainUnitName = _getNounForm(
          mainValue, // Use the full main value for declension rule check
          currencyInfo.mainUnitSingular,
          currencyInfo.mainUnitPlural2To4!,
          currencyInfo.mainUnitPluralGenitive!);
      // Add number words (or "нуль") and the declined noun.
      resultParts.add(mainText.isNotEmpty ? mainText : _zero);
      resultParts.add(mainUnitName);
    }

    // Process subunit part (if > 0)
    if (subunitValue > BigInt.zero) {
      // Add separator if main part also exists.
      if (currencyInfo.separator != null && mainValue > BigInt.zero) {
        resultParts.add(currencyInfo.separator!);
      }
      // Convert subunit amount (feminine agreement).
      final String subunitText = _convertInteger(subunitValue, Gender.feminine);
      // Determine correct form of the subunit noun.
      final String subUnitName = _getNounForm(
        subunitValue,
        currencyInfo.subUnitSingular!,
        currencyInfo.subUnitPlural2To4!,
        currencyInfo.subUnitPluralGenitive!,
      );
      // Add number words and declined subunit noun.
      if (subunitText.isNotEmpty) {
        // Avoid adding empty string if subunit was 0 somehow
        resultParts.add(subunitText);
        resultParts.add(subUnitName);
      }
    }

    // Join non-empty parts. Handle cases like 0.50 or exact 0.00.
    final nonEmptyParts = resultParts.where((s) => s.isNotEmpty).toList();
    if (nonEmptyParts.isEmpty) {
      // Should only happen if input was 0 and subunits were 0 after rounding.
      return "$_zero ${_getNounForm(BigInt.zero, currencyInfo.mainUnitSingular, currencyInfo.mainUnitPlural2To4!, currencyInfo.mainUnitPluralGenitive!)}";
    }
    return nonEmptyParts.join(' ');
  }

  /// Converts the fractional part of a decimal number to words.
  ///
  /// Uses the decimal separator specified in [UkOptions].
  /// Reads digits individually after the separator, using masculine form for digits.
  ///
  /// @param absValue The absolute decimal value (used to extract fractional digits).
  /// @param options Formatting options with decimal separator preference.
  /// @return Fractional part as Ukrainian words, preceded by a space and the separator word.
  String _getFractionalWords(Decimal absValue, UkOptions options) {
    // Determine separator word.
    final String separatorWord;
    switch (options.decimalSeparator ?? DecimalSeparator.comma) {
      // Default to comma
      case DecimalSeparator.comma:
        separatorWord = _commaWord;
        break;
      case DecimalSeparator.period:
      case DecimalSeparator.point:
        separatorWord = _periodWord;
        break;
    }

    // Extract fractional digits as a string.
    final String absValueString = absValue.toString();
    final int decimalIndex = absValueString.indexOf('.');
    if (decimalIndex == -1) return ''; // No fractional part
    final String fractionalDigits = absValueString.substring(decimalIndex + 1);
    if (fractionalDigits.isEmpty) return '';

    // Convert each digit to its word (using masculine form, standard for digits).
    final List<String> digitWords = fractionalDigits.split('').map((digit) {
      final int? digitInt = int.tryParse(digit);
      if (digitInt == null || digitInt < 0 || digitInt > 9)
        return '?'; // Invalid char
      return (digitInt == 0) ? _zero : _unitsMasculine[digitInt];
    }).toList();

    return ' $separatorWord ${digitWords.join(' ')}';
  }

  /// Selects the correct grammatical form of a noun based on the preceding number.
  ///
  /// Follows standard Ukrainian declension rules for numerals:
  /// - Ends in 1 (but not 11): Nominative Singular (`nomSg`)
  /// - Ends in 2, 3, 4 (but not 12, 13, 14): Nominative Plural (`nomPl`)
  /// - Ends in 0, 5-9, or 11-19: Genitive Plural (`genPl`)
  ///
  /// @param number The number governing the noun form.
  /// @param nomSg Nominative singular form of the noun.
  /// @param nomPl Nominative plural form (used for 2, 3, 4).
  /// @param genPl Genitive plural form (used for 0, 5-19).
  /// @return The correctly declined noun form.
  String _getNounForm(BigInt number, String nomSg, String nomPl, String genPl) {
    final BigInt absNumber = number.abs();
    // Check the last two digits for teens (11-19), which always take Genitive Plural.
    final BigInt lastTwoDigits = absNumber % BigInt.from(100);
    if (lastTwoDigits >= BigInt.from(11) && lastTwoDigits <= BigInt.from(19)) {
      return genPl;
    }

    // If not a teen, check the last digit.
    final int lastDigit = (absNumber % BigInt.from(10)).toInt();
    if (lastDigit == 1) return nomSg; // Ends in 1 -> Nominative Singular
    if (lastDigit >= 2 && lastDigit <= 4)
      return nomPl; // Ends in 2, 3, 4 -> Nominative Plural

    // Ends in 0, 5, 6, 7, 8, 9 -> Genitive Plural
    return genPl;
  }
}
