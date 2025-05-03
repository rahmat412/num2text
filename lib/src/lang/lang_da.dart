import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/da_options.dart';
import '../utils/utils.dart';

/// {@template num2text_da}
/// Converts numbers into Danish words (`Lang.DA`).
///
/// Implements [Num2TextBase] for Danish, handling various numeric types.
/// Features:
/// - Correct Danish grammar (vigesimal tens like "halvtreds", "og" conjunction, gender for 'one').
/// - Customizable via [DaOptions] (currency DKK, years, decimals).
/// - Supports large numbers (long scale: million, milliard...).
/// - Returns fallback string on error.
/// {@endtemplate}
class Num2TextDA implements Num2TextBase {
  static const String _zero = "nul";
  static const String _oneNeuter = "et"; // Neuter 'one' (default/thousand)
  static const String _oneCommon =
      "en"; // Common gender 'one' (currency/large scales)
  static const String _andConjunction = "og";
  static const String _defaultDecimalSeparatorWord = "komma";
  static const String _pointWord = "punktum";
  static const String _yearSuffixBC = "f.Kr."; // før Kristus
  static const String _yearSuffixAD = "e.Kr."; // efter Kristus
  static const String _hundred = "hundrede";
  static const String _thousand = "tusind";
  static const String _infinityPositive = "Uendelig";
  static const String _infinityNegative = "Negativ Uendelig";
  static const String _notANumber = "Ikke Et Tal";

  static const List<String> _wordsUnder20 = [
    _zero,
    _oneNeuter,
    "to",
    "tre",
    "fire",
    "fem",
    "seks",
    "syv",
    "otte",
    "ni",
    "ti",
    "elleve",
    "tolv",
    "tretten",
    "fjorten",
    "femten",
    "seksten",
    "sytten",
    "atten",
    "nitten",
  ]; // Index 1 is neuter 'et'

  static const List<String> _wordsTens = [
    // Vigesimal influence >= 50
    "", "", "tyve", "tredive", "fyrre", "halvtreds", "tres", "halvfjerds",
    "firs", "halvfems",
  ];

  /// Scale words, singular (long scale), Key: exponent.
  static const Map<int, String> _scaleWordsSingular = {
    6: "million",
    9: "milliard",
    12: "billion",
    15: "billiard",
    18: "trillion",
    21: "trilliard",
    24: "kvadrillion",
  };

  /// Scale words, plural (long scale), Key: exponent.
  static const Map<int, String> _scaleWordsPlural = {
    6: "millioner",
    9: "milliarder",
    12: "billioner",
    15: "billiarder",
    18: "trillioner",
    21: "trilliarder",
    24: "kvadrillioner",
  };

  /// {@macro num2text_base_process}
  ///
  /// Converts [number] to Danish words using [options].
  /// Uses [fallbackOnError] or "Ikke Et Tal" on failure.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final DaOptions daOptions =
        options is DaOptions ? options : const DaOptions();
    final String errorFallback = fallbackOnError ?? _notANumber;

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _infinityNegative : _infinityPositive;
      if (number.isNaN) return errorFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    if (decimalValue == Decimal.zero) {
      if (daOptions.currency) {
        final String mainUnit = daOptions.currencyInfo.mainUnitPlural ??
            daOptions.currencyInfo.mainUnitSingular;
        return "$_zero $mainUnit"; // e.g., nul kroner
      }
      return _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    if (daOptions.format == Format.year) {
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), daOptions);
    } else if (daOptions.currency) {
      textResult = _handleCurrency(absValue, daOptions);
      if (isNegative) textResult = "${daOptions.negativePrefix} $textResult";
    } else {
      textResult = _handleStandardNumber(absValue, daOptions);
      if (isNegative) textResult = "${daOptions.negativePrefix} $textResult";
    }
    return textResult;
  }

  /// Formats an integer as a Danish calendar year.
  ///
  /// Handles special phrasing for 1100-1999 ("nitten hundrede og...") and AD/BC suffixes.
  /// [year]: Integer year value.
  /// [options]: Formatting options.
  /// Returns the year as Danish words.
  String _handleYearFormat(int year, DaOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;
    if (absYear == 0) return _zero;

    String yearText;
    if (absYear >= 1100 && absYear < 2000) {
      // "nineteen hundred..." style
      final int high = absYear ~/ 100, low = absYear % 100;
      final String highText =
          _convertInteger(BigInt.from(high), false); // Use neuter 'et'
      if (low == 0)
        yearText = "$highText $_hundred";
      else
        yearText =
            "$highText $_hundred $_andConjunction ${_convertInteger(BigInt.from(low), false)}";
    } else {
      yearText =
          _convertInteger(BigInt.from(absYear), false); // Use neuter 'et'
    }

    if (isNegative)
      yearText += " $_yearSuffixBC";
    else if (options.includeAD) yearText += " $_yearSuffixAD";
    return yearText;
  }

  /// Formats a decimal as Danish currency words (DKK default).
  ///
  /// Uses common gender "en krone", neuter "et øre". Rounds if requested.
  /// [absValue]: Absolute decimal currency value.
  /// [options]: Formatting options with [CurrencyInfo].
  /// Returns the currency amount as Danish words.
  String _handleCurrency(Decimal absValue, DaOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final Decimal val = options.round ? absValue.round(scale: 2) : absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    final BigInt subVal =
        ((val - Decimal.fromBigInt(mainVal)) * Decimal.fromInt(100))
            .truncate()
            .toBigInt(); // Use truncate for subunits

    String mainPart = '';
    if (mainVal > BigInt.zero) {
      final String mainText =
          _convertInteger(mainVal, true); // useCommonOne=true for krone
      final String mainName =
          mainVal == BigInt.one ? info.mainUnitSingular : info.mainUnitPlural!;
      mainPart = '$mainText $mainName';
    }

    String subPart = '';
    if (subVal > BigInt.zero) {
      final String subText =
          _convertInteger(subVal, false); // useCommonOne=false for øre
      final String subName =
          subVal == BigInt.one ? info.subUnitSingular! : info.subUnitPlural!;
      subPart = '$subText $subName';
    }

    if (mainPart.isNotEmpty && subPart.isNotEmpty) {
      final String sep = info.separator ?? _andConjunction;
      return '$mainPart $sep $subPart';
    } else {
      return mainPart.isNotEmpty
          ? mainPart
          : subPart; // Return whichever part exists, or empty if zero (handled by caller)
    }
  }

  /// Formats a standard decimal number into Danish words.
  ///
  /// Converts integer and fractional parts. Uses "komma" or "punktum". Fractional part read digit by digit.
  /// [absValue]: Absolute decimal value.
  /// [options]: Formatting options.
  /// Returns the number as Danish words.
  String _handleStandardNumber(Decimal absValue, DaOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - Decimal.fromBigInt(integerPart);

    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, false); // Use neuter 'et'

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
          break;
      }

      String fractionalDigits = fractionalPart
          .toString()
          .split('.')
          .last
          .replaceAll(RegExp(r'0+$'), ''); // Get digits, trim trailing zeros
      if (fractionalDigits.isNotEmpty) {
        final List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? i = int.tryParse(digit);
          return (i != null && i >= 0 && i <= 9)
              ? _wordsUnder20[i]
              : '?'; // Uses neuter 'et' from list
        }).toList();
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer to Danish words, handling scales.
  ///
  /// Uses long scale. Applies gender "en" for scales >= million, "et" for thousand.
  /// [n]: Non-negative integer.
  /// [useCommonOneForFinalChunk]: Uses "en" if the final 0-999 chunk is 1 (for currency).
  /// Returns the integer as Danish words.
  String _convertInteger(BigInt n, bool useCommonOneForFinalChunk) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n < BigInt.from(1000))
      return _convertChunk(n.toInt(), useCommonOneForFinalChunk);

    final List<String> parts = [];
    String lastChunkText = "";
    int lastChunkValue = 0;
    final BigInt oneThousand = BigInt.from(1000);
    int scalePower = 0;
    BigInt remaining = n;

    while (remaining > BigInt.zero) {
      final int chunk = (remaining % oneThousand).toInt();
      remaining ~/= oneThousand;
      if (chunk > 0) {
        if (scalePower == 0) {
          // Last chunk (0-999)
          lastChunkValue = chunk;
          lastChunkText = _convertChunk(chunk, useCommonOneForFinalChunk);
        } else {
          // Higher scales
          final bool chunkUsesCommonOne =
              (scalePower >= 6); // Million+ use 'en'
          final String scaleChunkText =
              _convertChunk(chunk, chunkUsesCommonOne);
          if (scalePower == 3) {
            // Thousand
            parts.add(chunk == 1
                ? "$_oneNeuter $_thousand"
                : "$scaleChunkText $_thousand");
          } else if (_scaleWordsSingular.containsKey(scalePower)) {
            // Million+
            final String sing = _scaleWordsSingular[scalePower]!;
            final String plur = _scaleWordsPlural[scalePower]!;
            parts.add(
                chunk == 1 ? "$_oneCommon $sing" : "$scaleChunkText $plur");
          }
        }
      }
      scalePower += 3;
    }

    final List<String> resultParts =
        parts.isNotEmpty ? parts.reversed.toList() : [];
    // Add "og" before the last chunk if conditions met
    if (resultParts.isNotEmpty && lastChunkValue > 0 && lastChunkValue < 100) {
      resultParts.add(_andConjunction);
    }
    if (lastChunkText.isNotEmpty) resultParts.add(lastChunkText);

    return resultParts.join(' ');
  }

  /// Converts an integer 0-999 to Danish words.
  ///
  /// Handles "og" conjunction and vigesimal tens. Applies gender "en"/"et" based on [useCommonOne].
  /// [n]: Integer chunk (0-999).
  /// [useCommonOne]: If true, uses "en" for 1 (used for currency main unit).
  /// Returns chunk as Danish words, or empty string if [n] is 0.
  /// @throws ArgumentError if [n] is outside 0-999.
  String _convertChunk(int n, bool useCommonOne) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    final List<String> words = [];
    int rem = n;
    bool processedHundreds = false;

    if (rem >= 100) {
      // Hundreds
      words.add(_wordsUnder20[rem ~/ 100]); // Uses neuter 'et' for 100
      words.add(_hundred);
      rem %= 100;
      processedHundreds = true;
    }
    if (rem > 0) {
      // Tens and units
      if (processedHundreds)
        words.add(_andConjunction); // Add "og" after hundreds
      if (rem < 20) {
        String word = _wordsUnder20[rem];
        if (useCommonOne && rem == 1)
          word = _oneCommon; // Override 'et' with 'en' if needed
        words.add(word);
      } else {
        final int unit = rem % 10;
        final String tensWord = _wordsTens[rem ~/ 10];
        if (unit == 0)
          words.add(tensWord);
        else {
          // Danish structure: unit + og + tens (e.g., enogtyve)
          String unitWord = _wordsUnder20[unit];
          // Unit 1 in compounds 21, 31,... *always* uses "en" in standard Danish.
          if (unit == 1) unitWord = _oneCommon;
          words.add("$unitWord$_andConjunction$tensWord");
        }
      }
    }
    return words.join(' ');
  }
}
