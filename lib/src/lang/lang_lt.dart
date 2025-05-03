import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/lt_options.dart';
import '../utils/utils.dart';

/// {@template num2text_lt}
/// Converts numbers to Lithuanian words (`Lang.LT`).
///
/// Implements [Num2TextBase] for Lithuanian. Handles various numeric inputs,
/// supporting cardinal numbers, currency (with correct declension: Nominative Singular,
/// Nominative Plural, Genitive Plural), year formatting (using ordinals), decimals,
/// negatives, and large numbers. Adheres to Lithuanian grammar rules.
/// Customizable via [LtOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextLT implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "nulis";
  static const String _point = "taškas"; // Decimal separator (.)
  static const String _comma = "kablelis"; // Decimal separator (,)
  static const String _yearSuffixBC = "pr. m. e."; // Prieš mūsų erą (BC)
  static const String _yearSuffixAD = "m. e."; // Mūsų eros (AD)
  static const String _errorDefault =
      "Ne Skaičius"; // Default fallback "Not a Number"

  /// Maps cardinal number words to their ordinal forms (for years).
  static const Map<String, String> _cardinalToOrdinalMap = {
    "vienas": "pirmieji", "du": "antrieji", "trys": "treti",
    "keturi": "ketvirti",
    "penki": "penkti", "šeši": "šešti", "septyni": "septinti",
    "aštuoni": "aštunti",
    "devyni": "devinti", "dešimt": "dešimtieji", "vienuolika": "vienuoliktieji",
    "dvylika": "dvyliktieji", "trylika": "tryliktieji",
    "keturiolika": "keturioliktieji",
    "penkiolika": "penkioliktieji", "šešiolika": "šešioliktieji",
    "septyniolika": "septynioliktieji",
    "aštuoniolika": "aštuonioliktieji", "devyniolika": "devynioliktieji",
    "dvidešimt": "dvidešimtieji", "trisdešimt": "trisdešimtieji",
    "keturiasdešimt": "keturiasdešimtieji",
    "penkiasdešimt": "penkiasdešimtieji", "šešiasdešimt": "šešiasdešimtieji",
    "septyniasdešimt": "septyniasdešimtieji",
    "aštuoniasdešimt": "aštuonioliktieji", // Corrected Aštuoniasdešimt ordinal
    "devyniasdešimt": "devyniasdešimtieji", "šimtas": "šimtieji",
    "tūkstantis": "tūkstantieji",
    "milijonas": "milijoniniai",
    "milijardas": "milijardiniai", // Simplified higher ordinals
    // Add more if precise higher ordinals are needed
  };

  // Base words (Masculine, Nominative)
  static const List<String> _wordsUnder20Masc = [
    "nulis",
    "vienas",
    "du",
    "trys",
    "keturi",
    "penki",
    "šeši",
    "septyni",
    "aštuoni",
    "devyni",
    "dešimt",
    "vienuolika",
    "dvylika",
    "trylika",
    "keturiolika",
    "penkiolika",
    "šešiolika",
    "septyniolika",
    "aštuoniolika",
    "devyniolika",
  ];
  // Feminine Nominative (only 1-9 differ significantly for basic conversion)
  static const List<String> _wordsUnder10Fem = [
    "nulis",
    "viena",
    "dvi",
    "trys",
    "keturios",
    "penkios",
    "šešios",
    "septynios",
    "aštuonios",
    "devynios",
  ];
  static const List<String> _wordsTens = [
    "",
    "",
    "dvidešimt",
    "trisdešimt",
    "keturiasdešimt",
    "penkiasdešimt",
    "šešiasdešimt",
    "septyniasdešimt",
    "aštuoniasdešimt",
    "devyniasdešimt",
  ];
  static const String _hundredSingular = "šimtas"; // Nom. Sg.
  static const String _hundredPlural = "šimtai"; // Nom. Pl.

  // Scale words (Masc.): [singular Nom., plural Nom., plural Gen.]
  static final Map<int, List<String>> _scaleWordsMasc = {
    0: ["", "", ""], // Units < 1000
    1: ["tūkstantis", "tūkstančiai", "tūkstančių"], // Thousand
    2: ["milijonas", "milijonai", "milijonų"], // Million
    3: ["milijardas", "milijardai", "milijardų"], // Billion (10^9)
    4: ["trilijonas", "trilijonai", "trilijonų"], // Trillion (10^12)
    5: ["kvadrilijonas", "kvadrilijonai", "kvadrilijonų"], // etc.
    6: ["kvintilijonas", "kvintilijonai", "kvintilijonų"],
    7: ["sekstilijonas", "sekstilijonai", "sekstilijonų"],
    8: ["septilijonas", "septilijonai", "septilijonų"],
  };

  /// Processes the given [number] into Lithuanian words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [LtOptions] for customization (currency, year format, decimals, AD/BC).
  /// Defaults apply if [options] is null or not [LtOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or default error string on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [LtOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Lithuanian words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final LtOptions ltOptions =
        options is LtOptions ? options : const LtOptions();
    final String errorMsg = fallbackOnError ?? _errorDefault;

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Neigiama Begalybė" : "Begalybė";
      if (number.isNaN) return errorMsg;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorMsg;

    if (decimalValue == Decimal.zero) {
      // Zero currency uses Genitive Plural form (e.g., "nulis eurų").
      return ltOptions.currency
          ? "$_zero ${_getUnitForm(BigInt.zero, ltOptions.currencyInfo, true)}"
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    try {
      if (ltOptions.format == Format.year) {
        textResult = _handleYearFormat(
            absValue.truncate().toBigInt(), isNegative, ltOptions);
      } else if (ltOptions.currency) {
        textResult = _handleCurrency(absValue, ltOptions);
      } else {
        textResult = _handleStandardNumber(absValue, ltOptions);
      }

      if (isNegative && ltOptions.format != Format.year) {
        textResult = "${ltOptions.negativePrefix} $textResult";
      }
    } catch (e) {
      // print("Lithuanian Conversion Error: $e"); // Optional logging
      return errorMsg; // Return default error on failure
    }

    return textResult.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Converts an integer year to Lithuanian ordinal words.
  ///
  /// Applies ordinal suffix or form based on [_cardinalToOrdinalMap].
  /// Appends era suffixes if requested.
  ///
  /// @param year The non-negative integer year.
  /// @param isNegative Whether the original year was negative.
  /// @param options Formatting options.
  /// @return The year as Lithuanian ordinal words.
  String _handleYearFormat(BigInt year, bool isNegative, LtOptions options) {
    assert(year >= BigInt.zero); // Expect non-negative input here

    // Convert year to cardinal form first (masculine).
    String yearWords = _convertInteger(year, Gender.masculine);
    int yearInt = year.toInt(); // For modulo check

    // Apply ordinal ending if year doesn't end in 00.
    if (yearInt % 100 != 0) {
      List<String> wordList = yearWords.split(' ');
      String lastWord = wordList.last;
      String? ordinalLastWord =
          _cardinalToOrdinalMap[lastWord]; // Check specific mappings

      if (ordinalLastWord != null) {
        wordList[wordList.length - 1] = ordinalLastWord;
      } else {
        // Basic fallback rule for ordinalization (may not cover all exceptions)
        if ((lastWord.endsWith('as') || lastWord.endsWith('is')) &&
            lastWord.length > 2) {
          wordList[wordList.length - 1] =
              "${lastWord.substring(0, lastWord.length - 2)}ieji";
        } else if (lastWord.endsWith('i') &&
            lastWord.length > 1 &&
            !lastWord.endsWith('ieji')) {
          wordList[wordList.length - 1] =
              "${lastWord.substring(0, lastWord.length - 1)}ieji";
        } else if (!lastWord.endsWith('ieji')) {
          // Avoid double suffix
          wordList[wordList.length - 1] = "${lastWord}ieji";
        }
      }
      yearWords = wordList.join(' ');
    }
    // else: year ends in 00, keep cardinal form (e.g., "devyniolika šimtų").

    if (isNegative)
      yearWords += " $_yearSuffixBC";
    else if (options.includeAD && year > BigInt.zero)
      yearWords += " $_yearSuffixAD";

    return yearWords;
  }

  /// Converts a non-negative [Decimal] to Lithuanian currency words.
  ///
  /// Uses [LtOptions.currencyInfo] and [_getUnitForm] for correct declension.
  /// Rounds if specified.
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Lithuanian words.
  String _handleCurrency(Decimal absValue, LtOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final Decimal val = options.round ? absValue.round(scale: 2) : absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    final BigInt subVal = ((val - val.truncate()) * Decimal.fromInt(100))
        .round(scale: 0)
        .toBigInt();

    List<String> resultParts = [];

    if (mainVal > BigInt.zero) {
      // Assume masculine gender for Euro/Litas count.
      String mainText = _convertInteger(mainVal, Gender.masculine);
      String mainUnit = _getUnitForm(mainVal, info, true);
      resultParts.add('$mainText $mainUnit');
    }

    if (subVal > BigInt.zero && info.subUnitSingular != null) {
      // Assume masculine gender for Centas count.
      String subText = _convertInteger(subVal, Gender.masculine);
      String subUnit = _getUnitForm(subVal, info, false);
      resultParts.add('$subText $subUnit');
    }

    // Handle zero total value after rounding.
    if (resultParts.isEmpty &&
        mainVal == BigInt.zero &&
        subVal == BigInt.zero) {
      return "$_zero ${_getUnitForm(BigInt.zero, info, true)}";
    }

    // Join parts with space. Lithuanian typically doesn't use a conjunction here.
    return resultParts.join(' ');
  }

  /// Converts a non-negative standard [Decimal] number to Lithuanian words.
  ///
  /// Uses [LtOptions.decimalSeparator]. Fractional part converted digit by digit.
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Lithuanian words.
  String _handleStandardNumber(Decimal absValue, LtOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Use masculine gender for standard number integer part.
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, Gender.masculine);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero && !absValue.isInteger) {
      String sepWord = (options.decimalSeparator == DecimalSeparator.point ||
              options.decimalSeparator == DecimalSeparator.period)
          ? _point
          : _comma;

      // Extract digits, do not trim trailing zeros.
      String fracDigits = absValue.toString().split('.').last;
      List<String> digitWords = fracDigits.split('').map((d) {
        final int? i = int.tryParse(d);
        // Use masculine forms for digits after decimal.
        return (i != null && i < _wordsUnder20Masc.length)
            ? _wordsUnder20Masc[i]
            : '?';
      }).toList();
      fractionalWords = ' $sepWord ${digitWords.join(' ')}';
    }

    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer ([BigInt]) into Lithuanian words.
  ///
  /// Handles scale words (thousand, million, etc.) and number agreement.
  /// Delegates chunks < 1000 to [_convertUnder1000].
  ///
  /// @param n Non-negative integer.
  /// @param gender Grammatical gender context (mainly for the final chunk).
  /// @return Integer as Lithuanian words.
  String _convertInteger(BigInt n, Gender gender) {
    if (n == BigInt.zero) return _zero;
    assert(n > BigInt.zero); // Expect positive input

    if (n < BigInt.from(1000)) {
      return _convertUnder1000(n.toInt(), gender);
    }

    List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0;
    BigInt remaining = n;

    while (remaining > BigInt.zero) {
      if (!_scaleWordsMasc.containsKey(scaleIndex))
        throw ArgumentError("Number too large: $n");

      BigInt chunk = remaining % oneThousand;
      remaining ~/= oneThousand;

      if (chunk > BigInt.zero) {
        String scaleWord = "";
        String chunkText = "";

        if (scaleIndex > 0) {
          final scaleInfo = _scaleWordsMasc[scaleIndex]!;
          // Determine scale word form based on the chunk count.
          scaleWord = _getUnitNameFromForms(
              chunk, scaleInfo[0], scaleInfo[1], scaleInfo[2]);

          // Convert the chunk number itself (masculine for scale counts), unless chunk is 1.
          if (chunk != BigInt.one) {
            chunkText = _convertUnder1000(chunk.toInt(), Gender.masculine);
          }
          // else: chunk is 1, chunkText remains empty, only scaleWord used below.
        } else {
          // Final chunk (0-999), use the provided target gender.
          chunkText = _convertUnder1000(chunk.toInt(), gender);
        }

        // Combine chunk text and scale word.
        String currentPart = chunkText;
        if (scaleWord.isNotEmpty) {
          currentPart =
              chunkText.isNotEmpty ? '$chunkText $scaleWord' : scaleWord;
        }
        parts.add(currentPart);
      }
      scaleIndex++;
    }
    // Join parts from largest scale down.
    return parts.reversed.join(' ');
  }

  /// Converts an integer from 0 to 999 into Lithuanian words.
  ///
  /// Handles hundreds ("šimtas", "šimtai"). Delegates < 100 to [_convertUnder100].
  ///
  /// @param n Integer (0 <= n < 1000).
  /// @param gender Grammatical gender context for the < 100 part.
  /// @return Number as Lithuanian words, or "" if n is 0.
  String _convertUnder1000(int n, Gender gender) {
    if (n == 0) return "";
    assert(n > 0 && n < 1000, "Input must be 1-999");

    if (n < 100) return _convertUnder100(n, gender);

    List<String> words = [];
    int hundredsDigit = n ~/ 100;
    int remainder = n % 100;

    // Handle 100 ("šimtas") vs 200-900 ("du šimtai", etc.).
    if (hundredsDigit == 1) {
      words.add(_hundredSingular);
    } else {
      // Use masculine digit word before "šimtai".
      words.add(_wordsUnder20Masc[hundredsDigit]);
      words.add(_hundredPlural);
    }

    if (remainder > 0) {
      // Convert the remainder using the specified gender.
      words.add(_convertUnder100(remainder, gender));
    }

    return words.join(' ');
  }

  /// Converts an integer from 0 to 99 into Lithuanian words.
  ///
  /// Selects appropriate base words based on [gender].
  ///
  /// @param n Integer (0 <= n < 100).
  /// @param gender Grammatical gender context.
  /// @return Number as Lithuanian words, or "" if n is 0.
  String _convertUnder100(int n, Gender gender) {
    if (n == 0) return "";
    assert(n > 0 && n < 100);

    final List<String> baseWords = _getBaseWords(gender);
    if (n < 20) return baseWords[n];

    int tensDigit = n ~/ 10;
    int unitDigit = n % 10;
    String tensWord = _wordsTens[tensDigit];
    // Combine tens and units with a space.
    return unitDigit == 0 ? tensWord : "$tensWord ${baseWords[unitDigit]}";
  }

  /// Gets the correct grammatical form for a currency unit based on count.
  ///
  /// Uses the Lithuanian declension rules (Nom.Sg, Nom.Pl, Gen.Pl).
  ///
  /// @param count The number determining the form.
  /// @param info Currency details from options.
  /// @param isMainUnit True for main unit, false for subunit.
  /// @return The appropriate currency unit form.
  String _getUnitForm(BigInt count, CurrencyInfo info, bool isMainUnit) {
    String singular =
        isMainUnit ? info.mainUnitSingular : (info.subUnitSingular ?? '?');
    String? pluralNom = isMainUnit ? info.mainUnitPlural : info.subUnitPlural;
    String? pluralGen =
        isMainUnit ? info.mainUnitPluralGenitive : info.subUnitPluralGenitive;
    return _getUnitNameFromForms(count, singular, pluralNom, pluralGen);
  }

  /// Selects the correct noun form based on Lithuanian grammar rules.
  ///
  /// Rules: Ends in 1 (not 11) -> Nom. Sg.; Ends in 2-9 (not 12-19) -> Nom. Pl.; Else -> Gen. Pl.
  ///
  /// @param value The number governing the form.
  /// @param singular Nominative singular form.
  /// @param pluralNom Nominative plural form (optional fallback).
  /// @param pluralGen Genitive plural form (optional fallback).
  /// @return The appropriate noun form.
  String _getUnitNameFromForms(
      BigInt value, String singular, String? pluralNom, String? pluralGen) {
    pluralNom ??= singular; // Fallback if Nom.Pl. is null
    pluralGen ??= pluralNom; // Fallback if Gen.Pl. is null

    if (value == BigInt.zero) return pluralGen; // Rule for 0 -> Gen.Pl.

    int lastTwoDigits = (value % BigInt.from(100)).toInt();
    // Rule for 10-19 (and 0) -> Gen.Pl.
    if (lastTwoDigits >= 10 && lastTwoDigits <= 19) return pluralGen;

    int lastDigit = (value % BigInt.from(10)).toInt();
    if (lastDigit == 0) return pluralGen; // Rule for ends in 0
    if (lastDigit == 1) return singular; // Rule for ends in 1

    // Rule for ends in 2-9 -> Nom.Pl.
    return pluralNom;
  }

  /// Selects the appropriate base word list (0-19) based on gender.
  ///
  /// @param gender Required grammatical gender.
  /// @return Masculine or Feminine word list.
  List<String> _getBaseWords(Gender gender) {
    // Lithuanian gender difference is primarily 1-9. 10-19 are standard.
    // This provides the full Masc list or combines Fem 1-9 with standard 10-19.
    if (gender == Gender.feminine) {
      // Combine _wordsUnder10Fem with the standard 10-19 part from _wordsUnder20Masc
      return List<String>.from(_wordsUnder10Fem)
        ..addAll(_wordsUnder20Masc.sublist(10));
    }
    return _wordsUnder20Masc; // Default to Masculine
  }
}
