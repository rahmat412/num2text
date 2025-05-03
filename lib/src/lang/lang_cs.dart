import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/cs_options.dart';
import '../utils/utils.dart';

/// {@template num2text_cs}
/// Converts numbers into Czech words (`Lang.CS`).
///
/// Implements [Num2TextBase] for Czech, handling various numeric types.
/// Features:
/// - Correct Czech grammar (gender agreement for 1/2, number-based noun declension).
/// - Customizable via [CsOptions] (currency, years, decimals, gender).
/// - Supports large numbers (long scale: tisíc, milion, miliarda...).
/// - Returns fallback string on error.
/// {@endtemplate}
class Num2TextCS implements Num2TextBase {
  static const String _zero = "nula";
  static const String _defaultDecimalSeparatorWord = "celá"; // "whole"
  static const String _pointWord = "tečka"; // "dot"
  static const String _yearSuffixBC = "př. n. l."; // Before Common Era
  static const String _yearSuffixAD = "n. l."; // Common Era

  static const List<String> _wordsUnder20 = [
    _zero,
    "jedna",
    "dvě",
    "tři",
    "čtyři",
    "pět",
    "šest",
    "sedm",
    "osm",
    "devět",
    "deset",
    "jedenáct",
    "dvanáct",
    "třináct",
    "čtrnáct",
    "patnáct",
    "šestnáct",
    "sedmnáct",
    "osmnáct",
    "devatenáct",
  ]; // Note: 1/2 are base forms, adjusted by _getDigitWord

  static const List<String> _wordsUnder3Masculine = [_zero, "jeden", "dva"];
  static const List<String> _wordsUnder3Feminine = [_zero, "jedna", "dvě"];
  static const List<String> _wordsUnder3Neuter = [_zero, "jedno", "dvě"];

  static const List<String> _wordsTens = [
    "",
    "",
    "dvacet",
    "třicet",
    "čtyřicet",
    "padesát",
    "šedesát",
    "sedmdesát",
    "osmdesát",
    "devadesát",
  ];
  static const List<String> _wordsHundreds = [
    "",
    "sto",
    "dvě stě",
    "tři sta",
    "čtyři sta",
    "pět set",
    "šest set",
    "sedm set",
    "osm set",
    "devět set",
  ];

  /// Scale words (long scale) and properties [singular, nom_plural, gen_plural, gender].
  static const Map<int, List<dynamic>> _scaleWords = {
    // exponent: [singular, plural_2-4, plural_genitive, gender]
    3: ["tisíc", "tisíce", "tisíc", Gender.masculine], // 10^3
    6: ["milion", "miliony", "milionů", Gender.masculine], // 10^6
    9: ["miliarda", "miliardy", "miliard", Gender.feminine], // 10^9
    12: ["bilion", "biliony", "bilionů", Gender.masculine], // 10^12
    15: ["biliarda", "biliardy", "biliard", Gender.feminine], // 10^15
    18: ["trilion", "triliony", "trilionů", Gender.masculine], // 10^18
    21: ["triliarda", "triliardy", "triliard", Gender.feminine], // 10^21
    24: ["kvadrilion", "kvadriliony", "kvadrilionů", Gender.masculine], // 10^24
  };

  /// {@macro num2text_base_process}
  ///
  /// Converts [number] to Czech words using [options].
  /// Uses [fallbackOnError] or "Není Číslo" on failure.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final CsOptions csOptions =
        options is CsOptions ? options : const CsOptions();
    final String errorMsg = fallbackOnError ?? "Není Číslo";

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Záporné Nekonečno" : "Nekonečno";
      if (number.isNaN) return errorMsg;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorMsg;

    if (decimalValue == Decimal.zero) {
      if (csOptions.currency) {
        final String zeroUnit = csOptions.currencyInfo.mainUnitPluralGenitive ??
            csOptions.currencyInfo.mainUnitSingular;
        return "$_zero $zeroUnit"; // e.g., nula korun českých
      }
      return _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    if (csOptions.format == Format.year) {
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), csOptions);
    } else if (csOptions.currency) {
      textResult = _handleCurrency(absValue, csOptions);
      if (isNegative) textResult = "${csOptions.negativePrefix} $textResult";
    } else {
      textResult = _handleStandardNumber(absValue, csOptions);
      if (isNegative) textResult = "${csOptions.negativePrefix} $textResult";
    }
    return textResult;
  }

  /// Formats an integer as a Czech calendar year.
  ///
  /// Handles AD/BC suffixes and gender for year numbers (rok jedna is feminine).
  /// [year]: Integer year value.
  /// [options]: Formatting options.
  /// Returns the year as Czech words.
  String _handleYearFormat(int year, CsOptions options) {
    final bool isNegative = year < 0;
    final BigInt absYear = BigInt.from(isNegative ? -year : year);

    // Year 1 (rok jedna) uses feminine, others masculine context.
    final Gender yearGender =
        (absYear == BigInt.one) ? Gender.feminine : Gender.masculine;
    String yearText = _convertInteger(absYear, yearGender);

    if (isNegative)
      yearText += " $_yearSuffixBC";
    else if (options.includeAD && absYear > BigInt.zero)
      yearText += " $_yearSuffixAD";
    return yearText;
  }

  /// Formats a decimal as Czech currency words.
  ///
  /// Applies correct declension to number words and unit names based on count.
  /// Handles main units (feminine koruna) and subunits (masculine haléř).
  /// [absValue]: Absolute decimal currency value.
  /// [options]: Formatting options with [CurrencyInfo].
  /// Returns the currency amount as Czech words.
  String _handleCurrency(Decimal absValue, CsOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final Decimal val = options.round ? absValue.round(scale: 2) : absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    final BigInt subVal =
        ((val - Decimal.fromBigInt(mainVal)) * Decimal.fromInt(100))
            .round(scale: 0)
            .toBigInt();

    if (mainVal == BigInt.zero && subVal > BigInt.zero) {
      final String subunitText =
          _convertInteger(subVal, Gender.masculine); // haléř is masculine
      final String subUnitName = _getGrammaticalForm(
          subVal,
          info.subUnitSingular!,
          info.subUnitPlural2To4,
          info.subUnitPluralGenitive);
      return '$subunitText $subUnitName'.trim(); // Only subunit part
    }

    final String mainText =
        _convertInteger(mainVal, Gender.feminine); // koruna is feminine
    final String mainUnitName = _getGrammaticalForm(
        mainVal,
        info.mainUnitSingular,
        info.mainUnitPlural2To4,
        info.mainUnitPluralGenitive);
    String result = '$mainText $mainUnitName'.trim();

    if (subVal > BigInt.zero) {
      final String subunitText = _convertInteger(subVal, Gender.masculine);
      final String subUnitName = _getGrammaticalForm(
          subVal,
          info.subUnitSingular!,
          info.subUnitPlural2To4,
          info.subUnitPluralGenitive);
      result += ' ${info.separator ?? "a"} $subunitText $subUnitName';
    }
    return result;
  }

  /// Gets the correct Czech noun form based on the preceding count.
  ///
  /// Rules: 1 -> singular; 2-4 -> nominative plural; 0, 5+ -> genitive plural (with 11-19 exception).
  /// [number]: The count.
  /// [singular]: Singular noun form.
  /// [plural2To4]: Nominative plural form (optional).
  /// [pluralGenitive]: Genitive plural form (optional).
  /// Returns the appropriate noun form. Defaults to singular if plurals are null.
  String _getGrammaticalForm(BigInt number, String singular, String? plural2To4,
      String? pluralGenitive) {
    if (plural2To4 == null || pluralGenitive == null) return singular;
    BigInt absNum = number.abs();
    if (absNum == BigInt.one) return singular;
    BigInt lastTwo = absNum % BigInt.from(100);
    if (lastTwo >= BigInt.from(11) && lastTwo <= BigInt.from(19))
      return pluralGenitive;
    BigInt last = absNum % BigInt.from(10);
    if (last >= BigInt.two && last <= BigInt.from(4)) return plural2To4;
    return pluralGenitive; // Covers 0, 5-9, 10, 20, etc.
  }

  /// Formats a standard decimal number into Czech words.
  ///
  /// Converts integer and fractional parts, using gender from [options].
  /// Uses "celá" or "tečka" as the decimal separator. Fractional part read digit by digit.
  /// [absValue]: Absolute decimal value.
  /// [options]: Formatting options.
  /// Returns the number as Czech words.
  String _handleStandardNumber(Decimal absValue, CsOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - Decimal.fromBigInt(integerPart);
    final Gender gender = options.gender; // Use specified gender

    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, gender);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          separatorWord = _pointWord;
          break;
        default:
          separatorWord = _defaultDecimalSeparatorWord;
          break; // Default to "celá"
      }

      String fractionalDigits = absValue
          .toString()
          .split('.')
          .last
          .replaceAll(RegExp(r'0+$'), ''); // Get digits, trim trailing zeros

      if (fractionalDigits.isNotEmpty) {
        final List<String> digitWords =
            fractionalDigits.split('').map((digitChar) {
          final int? digitInt = int.tryParse(digitChar);
          return (digitInt != null)
              ? _getDigitWord(digitInt, Gender.feminine)
              : '?'; // Digits after separator usually feminine context
        }).toList();
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer to Czech words with gender agreement.
  ///
  /// Handles scale words ("tisíc", "milion", etc.) with correct declension.
  /// [n]: Non-negative integer.
  /// [gender]: Grammatical gender context for the number 1/2 in the least significant position or before scale words.
  /// Returns the integer as Czech words.
  /// @throws ArgumentError if [n] is negative.
  String _convertInteger(BigInt n, Gender gender) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n < BigInt.from(1000)) return _convertChunk(n.toInt(), gender);

    final List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scalePower = 0;
    BigInt remaining = n;

    while (remaining > BigInt.zero) {
      final int chunkVal = (remaining % oneThousand).toInt();
      remaining ~/= oneThousand;

      if (chunkVal > 0) {
        bool isScaleApplicable =
            scalePower > 0 && _scaleWords.containsKey(scalePower);
        // Determine gender for this chunk: scale word's gender if applicable, else overall gender.
        Gender chunkGender = isScaleApplicable
            ? (_scaleWords[scalePower]![3] as Gender)
            : gender;
        String chunkText = _convertChunk(chunkVal, chunkGender);

        if (isScaleApplicable) {
          final List<dynamic> scaleInfo = _scaleWords[scalePower]!;
          String scaleWord;
          if (chunkVal == 1) {
            scaleWord = scaleInfo[0]; // Singular scale word
            if (scalePower == 3) chunkText = ""; // Omit "jeden" before "tisíc"
          } else if (chunkVal >= 2 && chunkVal <= 4) {
            scaleWord = scaleInfo[1]; // Nominative plural scale word
          } else {
            scaleWord = scaleInfo[2]; // Genitive plural scale word
          }
          parts.add("$chunkText $scaleWord".trim());
        } else {
          parts.add(chunkText); // Lowest chunk (units)
        }
      }
      scalePower += 3;
    }
    return parts.reversed.join(' ').trim();
  }

  /// Converts an integer 0-999 to Czech words with gender.
  ///
  /// Base conversion for three-digit chunks.
  /// [n]: Integer chunk (0-999).
  /// [gender]: Required gender for '1' or '2'.
  /// Returns chunk as Czech words, or empty string if [n] is 0.
  /// @throws ArgumentError if [n] is outside 0-999.
  String _convertChunk(int n, Gender gender) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    final List<String> words = [];
    int rem = n;

    if (rem >= 100) {
      // Hundreds
      words.add(_wordsHundreds[rem ~/ 100]);
      rem %= 100;
    }
    if (rem > 0) {
      // Tens and units
      if (rem < 20)
        words.add(_getDigitWord(rem, gender));
      else {
        final String tens = _wordsTens[rem ~/ 10];
        final int unit = rem % 10;
        if (unit == 0)
          words.add(tens);
        else
          words.add(
              "$tens ${_getDigitWord(unit, gender)}"); // e.g., dvacet jedna
      }
    }
    return words.join(' ');
  }

  /// Gets the Czech word for a digit 0-19, applying gender for 1/2.
  ///
  /// [digit]: Digit value (0-19).
  /// [gender]: Required grammatical gender.
  /// Returns the corresponding Czech word.
  String _getDigitWord(int digit, Gender gender) {
    if (digit < 0 || digit >= 20) return "?";
    if (digit == 1) {
      switch (gender) {
        case Gender.masculine:
          return _wordsUnder3Masculine[1]; // jeden
        case Gender.feminine:
          return _wordsUnder3Feminine[1]; // jedna
        case Gender.neuter:
          return _wordsUnder3Neuter[1]; // jedno
      }
    } else if (digit == 2) {
      switch (gender) {
        case Gender.masculine:
          return _wordsUnder3Masculine[2]; // dva
        case Gender.feminine:
        case Gender.neuter:
          return _wordsUnder3Feminine[2]; // dvě
      }
    } else {
      return _wordsUnder20[digit]; // 0, 3-19 are gender-invariant
    }
  }
}
