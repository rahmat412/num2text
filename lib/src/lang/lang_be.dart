import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/be_options.dart';
import '../utils/utils.dart';

/// {@template num2text_be}
/// Converts numbers to Belarusian words (`Lang.BE`).
///
/// Implements [Num2TextBase] for Belarusian, handling various numeric types.
/// Supports cardinal numbers, decimals, negatives, currency, years, and large numbers (short scale).
/// Adheres to Belarusian grammar for gender and number agreement, including complex declension.
/// Customizable via [BeOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextBE implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "нуль";
  static const String _point = "кропка"; // Decimal separator (.)
  static const String _comma = "коска"; // Decimal separator (,)
  static const String _yearSuffixBC = "да н.э."; // Before our era
  static const String _yearSuffixAD = "н.э."; // Of our era
  static const String _infinity = "Бясконцасць";
  static const String _notANumber = "Не лік"; // Default fallback

  static const List<String> _wordsUnder20 = [
    // Masculine 1/2
    "нуль", "адзін", "два", "тры", "чатыры", "пяць", "шэсць", "сем", "восем",
    "дзевяць", "дзесяць", "адзінаццаць", "дванаццаць", "трынаццаць",
    "чатырнаццаць",
    "пятнаццаць", "шаснаццаць", "семнаццаць", "васемнаццаць", "дзевятнаццаць",
  ];
  static const String _oneFem = "адна";
  static const String _twoFem = "дзве";
  static const List<String> _wordsTens = [
    "",
    "",
    "дваццаць",
    "трыццаць",
    "сорак",
    "пяцьдзясят",
    "шэсцьдзесят",
    "семдзесят",
    "восемдзесят",
    "дзевяноста",
  ];
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

  // Scale words [Singular Nominative, Plural Nominative/Paucal (2-4), Plural Genitive (0, 5+)]
  static const Map<int, List<String>> _scaleWords = {
    1: ["тысяча", "тысячы", "тысяч"], // Thousand (feminine)
    2: ["мільён", "мільёны", "мільёнаў"], // Million (masculine)
    3: ["мільярд", "мільярды", "мільярдаў"], // Billion (masculine)
    4: ["трыльён", "трыльёны", "трыльёнаў"], // Trillion (masculine)
    5: ["квадрыльён", "квадрыльёны", "квадрыльёнаў"], // Quadrillion
    6: ["квінтыльён", "квінтыльёны", "квінтыльёнаў"], // Quintillion
    7: ["секстыльён", "секстыльёны", "секстыльёнаў"], // Sextillion
    8: ["септыльён", "септыльёны", "септыльёнаў"], // Septillion
  };

  // Maps cardinal number words to their ordinal forms (used for years).
  static const Map<String, String> _cardinalToOrdinalMap = {
    "адзін": "першы", "адна": "першая", "два": "другі", "дзве": "другая",
    "тры": "трэці", "чатыры": "чацвёрты", "пяць": "пяты", "шэсць": "шосты",
    "сем": "сёмы", "восем": "восьмы", "дзевяць": "дзявяты",
    "дзесяць": "дзесяты",
    "адзінаццаць": "адзінаццаты", "дванаццаць": "дванаццаты",
    "трынаццаць": "трынаццаты",
    "чатырнаццаць": "чатырнаццаты", "пятнаццаць": "пятнаццаты",
    "шаснаццаць": "шаснаццаты",
    "семнаццаць": "семнаццаты", "васемнаццаць": "васемнаццаты",
    "дзевятнаццаць": "дзевятнаццаты",
    "дваццаць": "дваццаты", "трыццаць": "трыццаты", "сорак": "саракавы",
    "пяцьдзясят": "пяцідзесяты", "шэсцьдзесят": "шасцідзесяты",
    "семдзесят": "сямідзесяты",
    "восемдзесят": "васьмідзесяты", "дзевяноста": "дзевяносты", "сто": "соты",
    "дзвесце": "двухсоты", "трыста": "трохсоты", "чатырыста": "чатырохсоты",
    "пяцьсот": "пяцісоты", "шэсцьсот": "шасцісоты", "семсот": "сямісоты",
    "восемсот": "васьмісоты", "дзевяцьсот": "дзевяцісоты",
    "тысяча": "тысячны", "мільён": "мільённы",
    "мільярд": "мільярдны", // Ordinals for scales
    // Add more scale ordinals if needed
  };

  /// Processes the given [number] into Belarusian words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [BeOptions] for customization (currency, year, decimals, AD/BC).
  /// Defaults apply if [options] is null or not [BeOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or default error string on failure.
  /// {@endtemplate}
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final BeOptions beOptions =
        options is BeOptions ? options : const BeOptions();
    final String errorFallback = fallbackOnError ?? _notANumber;

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Мінус бясконцасць" : _infinity;
      if (number.isNaN) return errorFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    if (decimalValue == Decimal.zero) {
      if (beOptions.currency) {
        final CurrencyInfo info = beOptions.currencyInfo;
        return "$_zero ${info.mainUnitPluralGenitive ?? info.mainUnitPlural ?? info.mainUnitSingular}"; // Zero currency uses genitive plural
      } else if (beOptions.format == Format.year) {
        return "нулявы"; // Zero year is ordinal
      } else {
        return _zero;
      }
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    if (beOptions.format == Format.year) {
      textResult = _handleYearFormat(
          absValue.truncate().toBigInt(), beOptions, isNegative);
    } else {
      textResult = beOptions.currency
          ? _handleCurrency(absValue, beOptions)
          : _handleStandardNumber(absValue, beOptions);
      if (isNegative) {
        textResult = "${beOptions.negativePrefix} $textResult";
      }
    }
    return textResult.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Converts an integer year to Belarusian ordinal words, adding AD/BC suffix if needed.
  String _handleYearFormat(
      BigInt absYearValue, BeOptions options, bool isNegative) {
    String yearText = _convertInteger(
        absYearValue, Gender.masculine); // Use masculine for year ordinal
    yearText = _makeOrdinal(yearText);

    if (isNegative)
      yearText += " $_yearSuffixBC";
    else if (options.includeAD && absYearValue > BigInt.zero)
      yearText += " $_yearSuffixAD";

    return yearText;
  }

  /// Converts a decimal currency value to Belarusian words with declined units.
  String _handleCurrency(Decimal absValue, BeOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final Decimal val = options.round ? absValue.round(scale: 2) : absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    final BigInt subVal = ((val - val.truncate()) * Decimal.fromInt(100))
        .round(scale: 0)
        .toBigInt();

    String mainPart = "";
    if (mainVal > BigInt.zero) {
      // Ruble is masculine
      String mainNumText = _convertInteger(mainVal, Gender.masculine);
      String mainUnit = _getCorrectForm(mainVal, info.mainUnitSingular,
          info.mainUnitPlural2To4, info.mainUnitPluralGenitive);
      mainPart = '$mainNumText $mainUnit'.trim();
    }

    String subPart = "";
    if (subVal > BigInt.zero && info.subUnitSingular != null) {
      // Kopeck is feminine
      String subNumText = _convertInteger(subVal, Gender.feminine);
      String subUnit = _getCorrectForm(subVal, info.subUnitSingular!,
          info.subUnitPlural2To4, info.subUnitPluralGenitive);
      subPart = '$subNumText $subUnit'.trim();
    }

    if (mainPart.isNotEmpty && subPart.isNotEmpty) {
      final String sep =
          info.separator?.trim() ?? ""; // Separator usually omitted or space
      return '$mainPart${sep.isNotEmpty ? " $sep " : " "}$subPart';
    } else if (mainPart.isNotEmpty) {
      return mainPart;
    } else if (subPart.isNotEmpty) {
      return subPart; // Handles 0.xx cases
    } else {
      // Zero case handled in process, this is a fallback
      return "$_zero ${info.mainUnitPluralGenitive ?? info.mainUnitPlural ?? info.mainUnitSingular}";
    }
  }

  /// Converts a standard decimal number to Belarusian words.
  String _handleStandardNumber(Decimal absValue, BeOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    bool useFractionalNaming = options.decimalSeparator ==
        DecimalSeparator.comma; // Default comma implies "цэлая/сотых" style

    // Convert integer part (use masculine for standalone numbers)
    String integerWords = _convertInteger(integerPart, Gender.masculine);
    String fractionalWords = '';

    if (fractionalPart > Decimal.zero && !absValue.isInteger) {
      String separatorWord;
      String fractionalDigits = absValue.toString().split('.').last;

      if (useFractionalNaming) {
        separatorWord = _getCorrectForm(integerPart, "цэлая", "цэлыя", "цэлых");
        final BigInt fractionalValue = BigInt.parse(fractionalDigits);
        final String fractionalNumWords = _convertInteger(fractionalValue,
            Gender.feminine); // Use feminine for suffix agreement
        final String suffix =
            _getFractionalSuffix(fractionalValue, fractionalDigits.length);

        if (suffix.isNotEmpty) {
          fractionalWords = ' $separatorWord $fractionalNumWords $suffix';
        } else {
          useFractionalNaming = false; // Fallback if precision suffix not found
        }
      }

      // Handle digit reading (point/period or fallback from comma)
      if (!useFractionalNaming) {
        separatorWord = (options.decimalSeparator == DecimalSeparator.point ||
                options.decimalSeparator == DecimalSeparator.period)
            ? _point
            : _comma;
        fractionalDigits = fractionalDigits.replaceAll(
            RegExp(r'0+$'), ''); // Trim trailing zeros
        if (fractionalDigits.isNotEmpty) {
          List<String> digitWords = fractionalDigits.split('').map((d) {
            final int? i = int.tryParse(d);
            return (i != null && i >= 0 && i <= 9) ? _wordsUnder20[i] : '?';
          }).toList();
          fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
        }
      }
    }

    // Adjust "one" gender if integer part is 1 and fractional naming is used
    if (integerPart == BigInt.one &&
        useFractionalNaming &&
        fractionalWords.isNotEmpty) {
      integerWords = _oneFem;
    }
    // Adjust "zero" text if integer part is 0
    if (integerPart == BigInt.zero && fractionalWords.isNotEmpty) {
      integerWords = useFractionalNaming
          ? _zero
          : ""; // Omit zero before "кропка/коска" + digits
    }

    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer to Belarusian words, handling gender and declension.
  String _convertInteger(BigInt n, Gender gender) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) throw ArgumentError("Negative input: $n");
    if (n < BigInt.from(1000)) return _convertChunk(n.toInt(), gender);

    final List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleLevel = 0;
    BigInt remaining = n;

    while (remaining > BigInt.zero) {
      final int chunk = (remaining % oneThousand).toInt();
      remaining ~/= oneThousand;

      if (chunk > 0) {
        final List<String>? scaleNames = _scaleWords[scaleLevel];
        // Determine gender for number words based on scale: тысяча (fem), others (masc)
        final Gender chunkGender =
            (scaleLevel == 1) ? Gender.feminine : Gender.masculine;
        // Use context gender only for the lowest chunk (0), otherwise use scale gender
        final Gender numberWordGender =
            (scaleLevel == 0) ? gender : chunkGender;
        String chunkText = _convertChunk(chunk, numberWordGender);

        String scaleWord = "";
        if (scaleLevel > 0 && scaleNames != null) {
          scaleWord = _getCorrectForm(
              BigInt.from(chunk), scaleNames[0], scaleNames[1], scaleNames[2]);
          chunkText = "$chunkText $scaleWord";
        }
        parts.insert(0, chunkText.trim());
      }
      scaleLevel++;
    }
    return parts.join(' ').trim();
  }

  /// Converts an integer 0-999 to Belarusian words, respecting gender for 1 and 2.
  String _convertChunk(int n, Gender gender) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    final List<String> words = [];
    int remainder = n;

    if (remainder >= 100) {
      words.add(_wordsHundreds[remainder ~/ 100]!);
      remainder %= 100;
    }

    if (remainder > 0) {
      if (remainder < 20) {
        if (remainder == 1)
          words.add(gender == Gender.feminine ? _oneFem : _wordsUnder20[1]);
        else if (remainder == 2)
          words.add(gender == Gender.feminine ? _twoFem : _wordsUnder20[2]);
        else
          words.add(_wordsUnder20[remainder]);
      } else {
        words.add(_wordsTens[remainder ~/ 10]);
        final int unitDigit = remainder % 10;
        if (unitDigit > 0) {
          if (unitDigit == 1)
            words.add(gender == Gender.feminine ? _oneFem : _wordsUnder20[1]);
          else if (unitDigit == 2)
            words.add(gender == Gender.feminine ? _twoFem : _wordsUnder20[2]);
          else
            words.add(_wordsUnder20[unitDigit]);
        }
      }
    }
    return words.join(' ');
  }

  /// Selects the correct grammatical form of a noun based on the preceding number.
  /// Follows Belarusian declension rules (1=Nom.Sg, 2-4=Nom.Pl/Paucal, 0/5+=Gen.Pl).
  String _getCorrectForm(BigInt number, String singularForm, String? paucalForm,
      String? pluralGenitiveForm) {
    final String effectivePaucal =
        paucalForm ?? pluralGenitiveForm ?? singularForm;
    final String effectiveGenitive = pluralGenitiveForm ?? singularForm;

    if (number == BigInt.zero) return effectiveGenitive;

    final BigInt absNumber = number.abs();
    final int lastDigit = (absNumber % BigInt.from(10)).toInt();
    final int lastTwoDigits = (absNumber % BigInt.from(100)).toInt();

    if (lastTwoDigits >= 11 && lastTwoDigits <= 19) return effectiveGenitive;
    if (lastDigit == 1) return singularForm;
    if (lastDigit >= 2 && lastDigit <= 4) return effectivePaucal;
    return effectiveGenitive;
  }

  /// Converts the last word of a cardinal number string to its ordinal form.
  String _makeOrdinal(String cardinalText) {
    if (cardinalText.isEmpty) return "";
    final parts = cardinalText.split(' ');
    final lastWord = parts.last;
    final ordinalLastWord =
        _cardinalToOrdinalMap[lastWord] ?? lastWord; // Fallback if not in map
    parts[parts.length - 1] = ordinalLastWord;
    return parts.join(' ');
  }

  /// Gets the appropriate declined suffix for fractional parts (tenths, hundredths, etc.).
  String _getFractionalSuffix(BigInt fractionalValue, int precision) {
    switch (precision) {
      case 1:
        return _getCorrectForm(
            fractionalValue, "дзясятая", "дзясятыя", "дзясятых");
      case 2:
        return _getCorrectForm(fractionalValue, "сотая", "сотыя", "сотых");
      case 3:
        return _getCorrectForm(
            fractionalValue, "тысячная", "тысячныя", "тысячных");
      case 4:
        return _getCorrectForm(fractionalValue, "дзесяцітысячная",
            "дзесяцітысячныя", "дзесяцітысячных");
      case 5:
        return _getCorrectForm(
            fractionalValue, "статысячная", "статысячныя", "статысячных");
      case 6:
        return _getCorrectForm(
            fractionalValue, "мільённая", "мільённыя", "мільённых");
      default:
        return ""; // Unsupported precision
    }
  }
}
