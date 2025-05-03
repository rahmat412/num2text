import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ru_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ru}
/// Converts numbers to Russian words (`Lang.RU`).
///
/// Implements [Num2TextBase] for Russian, handling various numeric types.
/// Supports cardinal numbers, decimals, negatives, currency, years (ordinal), and large numbers.
/// Correctly applies grammatical gender (masculine/feminine) and case (nominative/genitive) variations.
/// Customizable via [RuOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextRU implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "ноль";
  static const String _point = "запятая"; // Default decimal separator word
  static const String _pointAlt = "точка"; // Alternative decimal separator word
  static const String _infinity = "Бесконечность";
  static const String _negativeInfinity = "Минус бесконечность";
  static const String _defaultNaN = "Не Число";
  static const String _yearSuffixBC = "до н. э."; // Before Common Era
  static const String _yearSuffixAD = "н. э."; // Common Era

  // --- Number Words (Nominative Case) ---

  /// Units (1-19) in masculine form (used as default and for masculine contexts).
  static const List<String> _wordsUnitsMasc = [
    "",
    "один",
    "два",
    "три",
    "четыре",
    "пять",
    "шесть",
    "семь",
    "восемь",
    "девять",
    "десять",
    "одиннадцать",
    "двенадцать",
    "тринадцать",
    "четырнадцать",
    "пятнадцать",
    "шестнадцать",
    "семнадцать",
    "восемнадцать",
    "девятнадцать",
  ];

  /// Units (1-19) in feminine form (only 1 and 2 differ: "одна", "две").
  /// Used for thousands scale and feminine currency/units.
  static const List<String> _wordsUnitsFem = [
    "",
    "одна",
    "две",
    "три",
    "четыре",
    "пять",
    "шесть",
    "семь",
    "восемь",
    "девять",
    "десять",
    "одиннадцать",
    "двенадцать",
    "тринадцать",
    "четырнадцать",
    "пятнадцать",
    "шестнадцать",
    "семнадцать",
    "восемнадцать",
    "девятнадцать",
  ];

  /// Tens (20, 30, ..., 90).
  static const List<String> _wordsTens = [
    "",
    "",
    "двадцать",
    "тридцать",
    "сорок",
    "пятьдесят",
    "шестьдесят",
    "семьдесят",
    "восемьдесят",
    "девяносто",
  ];

  /// Hundreds (100, 200, ..., 900).
  static const List<String> _wordsHundreds = [
    "",
    "сто",
    "двести",
    "триста",
    "четыреста",
    "пятьсот",
    "шестьсот",
    "семьсот",
    "восемьсот",
    "девятьсот",
  ];

  /// Scale words (thousand, million, etc.) with grammatical forms.
  /// Key: scale index (1=10^3, 2=10^6, ...).
  /// Value: List [form for 1 (nom. sing.), form for 2-4 (gen. sing.), form for 0/5+ (gen. pl.)].
  static final Map<int, List<String>> _scaleWords = {
    1: ["тысяча", "тысячи", "тысяч"], // Feminine
    2: ["миллион", "миллиона", "миллионов"], // Masculine
    3: ["миллиард", "миллиарда", "миллиардов"], // Masculine
    4: ["триллион", "триллиона", "триллионов"], // Masculine
    5: ["квадриллион", "квадриллиона", "квадриллионов"], // Masculine
    6: ["квинтиллион", "квинтиллиона", "квинтиллионов"], // Masculine
    7: ["секстиллион", "секстиллиона", "секстиллионов"], // Masculine
    8: ["септиллион", "септиллиона", "септиллионов"], // Masculine
  };

  // --- Ordinal Number Words (for Years) ---
  // Masculine, Nominative Case

  /// Ordinal units (1st to 19th).
  static const Map<int, String> _ordinalUnits = {
    1: "первый",
    2: "второй",
    3: "третий",
    4: "четвёртый",
    5: "пятый",
    6: "шестой",
    7: "седьмой",
    8: "восьмой",
    9: "девятый",
    10: "десятый",
    11: "одиннадцатый",
    12: "двенадцатый",
    13: "тринадцатый",
    14: "четырнадцатый",
    15: "пятнадцатый",
    16: "шестнадцатый",
    17: "семнадцатый",
    18: "восемнадцатый",
    19: "девятнадцатый",
  };

  /// Ordinal tens (20th, 30th, ..., 90th).
  static const Map<int, String> _ordinalTens = {
    2: "двадцатый",
    3: "тридцатый",
    4: "сороковой",
    5: "пятидесятый",
    6: "шестидесятый",
    7: "семидесятый",
    8: "восьмидесятый",
    9: "девяностый",
  };

  /// Ordinal hundreds (100th, 200th, ..., 900th).
  static const Map<int, String> _ordinalHundreds = {
    1: "сотый",
    2: "двухсотый",
    3: "трёхсотый",
    4: "четырёхсотый",
    5: "пятисотый",
    6: "шестисотый",
    7: "семисотый",
    8: "восьмисотый",
    9: "девятисотый",
  };

  /// Ordinal scales (thousandth, millionth, etc.).
  static const Map<int, String> _ordinalScales = {
    1: "тысячный",
    2: "миллионный",
    3: "миллиардный",
    4: "триллионный",
    5: "квадриллионный",
    6: "квинтиллионный",
    7: "секстиллионный",
    8: "септиллионный",
  };

  /// Processes the given number into Russian words.
  ///
  /// {@macro num2text_process_intro}
  /// {@macro num2text_process_options}
  /// Uses [RuOptions] for customization (currency, year format, gender, decimals, AD/BC).
  /// {@macro num2text_process_errors}
  ///
  /// @param number The number to convert.
  /// @param options Optional [RuOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Russian words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final RuOptions ruOptions =
        options is RuOptions ? options : const RuOptions();
    final String effectiveFallback = fallbackOnError ?? _defaultNaN;

    // Handle special double values.
    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _negativeInfinity : _infinity;
      if (number.isNaN) return effectiveFallback;
    }

    // Normalize input.
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return effectiveFallback;

    // Handle zero.
    if (decimalValue == Decimal.zero) {
      if (ruOptions.currency) {
        final CurrencyInfo ci = ruOptions.currencyInfo;
        // Zero currency uses genitive plural forms.
        final String mainUnit =
            ci.mainUnitPluralGenitive ?? ci.mainUnitSingular;
        final String subUnit =
            ci.subUnitPluralGenitive ?? ci.subUnitSingular ?? '';
        // Return "ноль рублей ноль копеек" or similar.
        return subUnit.isEmpty
            ? "$_zero $mainUnit"
            : "$_zero $mainUnit $_zero $subUnit";
      } else {
        return _zero; // Standard "ноль".
      }
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Delegate based on format.
    if (ruOptions.format == Format.year) {
      if (!decimalValue.isInteger)
        return effectiveFallback; // Years must be integers.
      // Year formatting handles its own sign (BC/AD).
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), ruOptions);
    } else {
      if (ruOptions.currency) {
        textResult = _handleCurrency(absValue, ruOptions);
      } else {
        // Standard number conversion uses masculine gender by default if not specified.
        textResult = _handleStandardNumber(absValue, ruOptions);
      }
      // Prepend negative prefix if needed.
      if (isNegative) {
        textResult = "${ruOptions.negativePrefix} $textResult";
      }
    }
    // Clean up potential double spaces.
    return textResult.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Converts a non-negative standard [Decimal] number to Russian words.
  ///
  /// Converts integer and fractional parts. Uses the decimal separator word from [RuOptions].
  /// Fractional part is converted digit by digit. Assumes masculine gender for fractional part digits.
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Russian words.
  String _handleStandardNumber(Decimal absValue, RuOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part, using specified gender (default masculine). "ноль" if 0 and fraction exists.
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, Gender.masculine);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Determine separator word.
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          separatorWord = _pointAlt;
          break;
        case DecimalSeparator.comma:
        default:
          separatorWord = _point;
          break;
      }

      // Get fractional digits as string.
      final String fullString = absValue.toString();
      final String fractionalDigits =
          fullString.contains('.') ? fullString.split('.').last : '';

      if (fractionalDigits.isNotEmpty) {
        // Convert each digit individually (using masculine forms).
        final List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          if (digitInt == 0) return _zero;
          return (digitInt != null &&
                  digitInt > 0 &&
                  digitInt < _wordsUnitsMasc.length)
              ? _wordsUnitsMasc[digitInt]
              : '?'; // Error placeholder.
        }).toList();

        final String digitsText = digitWords.join(' ').trim();
        if (digitsText.isNotEmpty) {
          fractionalWords = ' $separatorWord $digitsText';
        }
        // Handle case like 0.0 -> return "ноль"
        else if (integerPart == BigInt.zero && digitsText.isEmpty) {
          return _zero;
        }
        // Handle case like 1.0 -> return integer part only
        else if (integerPart > BigInt.zero && digitsText.isEmpty) {
          return integerWords;
        }
      } else if (integerPart > BigInt.zero) {
        // Handle case like "1." where split gives empty fractionalDigits
        return integerWords;
      }
    }

    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a cardinal number [n] to its Russian ordinal form (masculine, nominative).
  /// Used primarily for year formatting.
  ///
  /// @param n The positive integer to convert.
  /// @return The ordinal representation (e.g., "тысяча девятьсот восемьдесят четвёртый").
  String _convertToOrdinal(BigInt n) {
    if (n <= BigInt.zero)
      return _zero; // Or handle error? Zero ordinal is unusual.

    // Handle exact scale numbers first (тысячный, миллионный).
    if (n == BigInt.from(1000) && _ordinalScales.containsKey(1))
      return _ordinalScales[1]!;
    for (int scaleIndex = 8; scaleIndex >= 2; scaleIndex--) {
      BigInt scaleValue = BigInt.from(10).pow(scaleIndex * 3);
      if (n == scaleValue && _ordinalScales.containsKey(scaleIndex)) {
        return _ordinalScales[scaleIndex]!;
      }
    }
    // Handle exact hundreds.
    if (n % BigInt.from(100) == BigInt.zero && n < BigInt.from(1000)) {
      int hundredDigit = (n ~/ BigInt.from(100)).toInt();
      if (_ordinalHundreds.containsKey(hundredDigit))
        return _ordinalHundreds[hundredDigit]!;
    }

    // General case: Convert cardinal, then make last word ordinal.
    String cardinalText = _convertInteger(n, Gender.masculine);
    List<String> parts = cardinalText.split(' ');
    if (parts.isEmpty) return cardinalText; // Should not happen for n > 0.

    String lastWord = parts.last;
    bool found = false;

    // Try replacing last word with ordinal unit.
    for (int i = 1; i < _wordsUnitsMasc.length; ++i) {
      // Check both masculine and feminine forms for 1, 2 as cardinal might use feminine for thousand.
      if (_wordsUnitsMasc[i] == lastWord ||
          (i <= 2 && _wordsUnitsFem[i] == lastWord)) {
        if (_ordinalUnits.containsKey(i)) {
          parts[parts.length - 1] = _ordinalUnits[i]!;
          found = true;
          break;
        }
      }
    }
    // Try replacing last word with ordinal ten.
    if (!found) {
      for (int i = 2; i < _wordsTens.length; ++i) {
        if (_wordsTens[i] == lastWord && _ordinalTens.containsKey(i)) {
          parts[parts.length - 1] = _ordinalTens[i]!;
          found = true;
          break;
        }
      }
    }
    // Try replacing last word with ordinal hundred.
    if (!found) {
      for (int i = 1; i < _wordsHundreds.length; ++i) {
        if (_wordsHundreds[i] == lastWord && _ordinalHundreds.containsKey(i)) {
          parts[parts.length - 1] = _ordinalHundreds[i]!;
          found = true;
          break;
        }
      }
    }
    // Try replacing last word with ordinal scale (less common, but for consistency).
    if (!found) {
      for (var entry in _scaleWords.entries) {
        int scaleIndex = entry.key;
        List<String> forms = entry.value;
        // Check if last word matches any form of a scale word.
        if (forms.contains(lastWord) &&
            _ordinalScales.containsKey(scaleIndex)) {
          // If number is simple like "один миллион", return "миллионный".
          if (parts.length == 2 &&
              (parts.first == _wordsUnitsMasc[1] ||
                  parts.first == _wordsUnitsFem[1])) {
            return _ordinalScales[scaleIndex]!;
          }
          // Otherwise, just replace the last part (e.g., "два миллиона" -> "два миллионный" - unusual).
          parts[parts.length - 1] = _ordinalScales[scaleIndex]!;
          // found = true; // Let subsequent logic handle 'один' removal if needed.
          break;
        }
      }
    }

    String result = parts.join(' ');

    // Specific adjustment for years 1000-1999 like "тысяча девятьсот..."
    // Remove the feminine "одна " prefix if present.
    if (n >= BigInt.from(1000) && n < BigInt.from(2000)) {
      if (result.startsWith("одна тысяча ")) {
        result = result.substring("одна ".length); // -> "тысяча ..."
      } else if (result == "одна тысячный") {
        // Handle "одна тысячный" -> "тысячный"
        result = _ordinalScales[1]!;
      }
    }

    // Final check for cases like "один миллионный" -> "миллионный"
    if (result.startsWith("один ") &&
        parts.length == 2 &&
        _ordinalScales.containsValue(parts[1])) {
      result = parts[1];
    }

    return result;
  }

  /// Converts a [year] into its Russian ordinal word representation for calendar years.
  ///
  /// Appends era suffixes ("н. э." or "до н. э.") based on the sign and [RuOptions.includeAD].
  ///
  /// @param year The integer year (can be negative).
  /// @param options Formatting options.
  /// @return The year formatted as Russian ordinal words.
  String _handleYearFormat(BigInt year, RuOptions options) {
    final bool isNegative = year < BigInt.zero;
    final BigInt absYear = isNegative ? -year : year;

    // Year 0 doesn't exist in Gregorian/Julian, but handle numerically.
    if (absYear == BigInt.zero) return _zero;

    String yearText = _convertToOrdinal(absYear); // Convert to ordinal form.

    // Append era suffixes.
    if (isNegative) {
      yearText += " $_yearSuffixBC"; // "до н. э." for BC/BCE.
    } else if (options.includeAD) {
      yearText += " $_yearSuffixAD"; // "н. э." for AD/CE if requested.
    }

    return yearText;
  }

  /// Converts a non-negative [Decimal] value to Russian currency words.
  ///
  /// Uses [RuOptions.currencyInfo] for unit names and grammatical forms.
  /// Rounds if [RuOptions.round] is true. Handles main and subunits (e.g., rubles, kopecks).
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Russian words.
  String _handleCurrency(Decimal absValue, RuOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2;
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round or truncate value. Truncate after potential rounding to ensure fixed decimals.
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;
    valueToConvert = valueToConvert.truncate(scale: decimalPlaces);

    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Round subunit calculation to avoid precision issues (e.g., 0.4999...).
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round().toBigInt();

    List<String> resultParts = [];

    // --- Main Unit Part ---
    // Include main part if > 0, OR if subunits are 0 (to show "5 рублей", not just "5").
    if (mainValue > BigInt.zero || subunitValue == BigInt.zero) {
      // Convert main value using masculine gender (e.g., for Ruble).
      final String mainText = _convertInteger(mainValue, Gender.masculine);
      // Get correct grammatical form for the main unit.
      final String mainUnitName = _getCaseForm(
        mainValue,
        currencyInfo.mainUnitSingular, // Form for 1.
        currencyInfo.mainUnitPlural2To4!, // Form for 2-4.
        currencyInfo.mainUnitPluralGenitive!, // Form for 0, 5+.
      );
      resultParts.add('$mainText $mainUnitName');
    }

    // --- Subunit Part ---
    // Include subunit part only if > 0.
    if (subunitValue > BigInt.zero) {
      // Convert subunit value using feminine gender (e.g., for Kopeck).
      final String subunitText = _convertInteger(subunitValue, Gender.feminine);
      // Get correct grammatical form for the subunit.
      final String subUnitName = _getCaseForm(
        subunitValue,
        currencyInfo.subUnitSingular!, // Form for 1.
        currencyInfo.subUnitPlural2To4!, // Form for 2-4.
        currencyInfo.subUnitPluralGenitive!, // Form for 0, 5+.
      );
      resultParts.add('$subunitText $subUnitName');
    }
    // Case: 0.00 RUB -> Handled in `process`. If reached here (e.g., rounding 0.00x),
    // the `if (mainValue > BigInt.zero || subunitValue == BigInt.zero)` block
    // should correctly produce "ноль рублей". We don't need to add "ноль копеек" explicitly here.

    return resultParts.join(' ');
  }

  /// Converts a non-negative integer [n] into Russian words, respecting grammatical [gender].
  ///
  /// Handles large numbers by processing in chunks of 1000. Applies correct gender/case
  /// for scale words (тысяча - fem, миллион - masc, etc.).
  ///
  /// @param n The non-negative integer to convert.
  /// @param gender The grammatical gender context (affects 1/2 in the final chunk).
  /// @throws ArgumentError if [n] is negative or exceeds defined scales.
  /// @return Integer as Russian words.
  String _convertInteger(BigInt n, Gender gender) {
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n == BigInt.zero) return _zero;

    List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0; // 0: units, 1: thousands, 2: millions,...
    BigInt remaining = n;

    while (remaining > BigInt.zero) {
      BigInt chunk = remaining % oneThousand;
      remaining ~/= oneThousand;

      if (chunk > BigInt.zero) {
        // Determine gender for this chunk's conversion.
        // Thousands scale (index 1) uses Feminine for "одна/две тысячи".
        // Other scales (million, billion) use Masculine.
        // Base chunk (index 0) uses the specified `gender`.
        Gender chunkGender =
            (scaleIndex == 1) ? Gender.feminine : Gender.masculine;
        if (scaleIndex == 0) chunkGender = gender;

        String chunkText = _convertChunk(chunk.toInt(), chunkGender);
        String scaleWordText = "";

        if (scaleIndex > 0) {
          // Add scale word if applicable.
          if (!_scaleWords.containsKey(scaleIndex)) {
            throw ArgumentError(
                "Number too large, scale index $scaleIndex not defined.");
          }
          final scaleForms = _scaleWords[scaleIndex]!;
          // Get the correct grammatical form (case) of the scale word.
          scaleWordText =
              _getCaseForm(chunk, scaleForms[0], scaleForms[1], scaleForms[2]);
        }

        // Combine chunk text and scale word.
        parts.add(
            scaleWordText.isNotEmpty ? "$chunkText $scaleWordText" : chunkText);
      }
      scaleIndex++;
    }
    // Join parts from largest scale down.
    return parts.reversed.join(' ');
  }

  /// Converts an integer chunk (0-999) into Russian words, respecting [gender].
  ///
  /// Gender affects the words for 1 ("один"/"одна") and 2 ("два"/"две").
  ///
  /// @param n Integer chunk (0-999).
  /// @param gender Grammatical gender context.
  /// @throws ArgumentError if [n] is outside 0-999.
  /// @return Chunk as Russian words, or empty string if [n] is 0.
  String _convertChunk(int n, Gender gender) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    List<String> words = [];
    int remainder = n;

    // Hundreds.
    if (remainder >= 100) {
      words.add(_wordsHundreds[remainder ~/ 100]);
      remainder %= 100;
    }

    // Tens and Units (1-99).
    if (remainder > 0) {
      if (remainder < 20) {
        // 1-19
        // Select correct gender form for 1 and 2.
        if (remainder == 1)
          words.add(gender == Gender.feminine
              ? _wordsUnitsFem[1]
              : _wordsUnitsMasc[1]);
        else if (remainder == 2)
          words.add(gender == Gender.feminine
              ? _wordsUnitsFem[2]
              : _wordsUnitsMasc[2]);
        else
          words
              .add(_wordsUnitsMasc[remainder]); // 3-19 use masculine form here.
      } else {
        // 20-99
        words.add(_wordsTens[remainder ~/ 10]); // Add tens word.
        int unit = remainder % 10;
        if (unit > 0) {
          // Add unit word if non-zero.
          if (unit == 1)
            words.add(gender == Gender.feminine
                ? _wordsUnitsFem[1]
                : _wordsUnitsMasc[1]);
          else if (unit == 2)
            words.add(gender == Gender.feminine
                ? _wordsUnitsFem[2]
                : _wordsUnitsMasc[2]);
          else
            words.add(_wordsUnitsMasc[unit]); // 3-9 use masculine form.
        }
      }
    }
    return words.join(' ');
  }

  /// Selects the correct grammatical case form based on Russian rules for number agreement.
  ///
  /// - Ends in 1 (but not 11): Nominative Singular ([form1]).
  /// - Ends in 2, 3, 4 (but not 12, 13, 14): Genitive Singular ([form2_4]).
  /// - Ends in 0, 5-9, or 11-19: Genitive Plural ([form5]).
  ///
  /// @param number The number determining the case.
  /// @param form1 Noun form for 1 (e.g., "рубль", "тысяча").
  /// @param form2_4 Noun form for 2-4 (e.g., "рубля", "тысячи").
  /// @param form5 Noun form for 0, 5+ (e.g., "рублей", "тысяч").
  /// @return The grammatically correct noun form.
  String _getCaseForm(
      BigInt number, String form1, String form2_4, String form5) {
    final BigInt absNumber = number.abs();
    final BigInt lastTwoDigits = absNumber % BigInt.from(100);

    // Check 11-19 exception first (always uses genitive plural).
    if (lastTwoDigits >= BigInt.from(11) && lastTwoDigits <= BigInt.from(19)) {
      return form5;
    }

    // Check last digit for standard rules.
    final BigInt lastDigit = absNumber % BigInt.from(10);
    if (lastDigit == BigInt.one) return form1; // Ends in 1.
    if (lastDigit >= BigInt.two && lastDigit <= BigInt.from(4))
      return form2_4; // Ends in 2, 3, 4.
    return form5; // Ends in 0, 5, 6, 7, 8, 9.
  }
}
