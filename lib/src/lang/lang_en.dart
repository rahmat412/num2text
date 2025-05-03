import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/en_options.dart';
import '../utils/utils.dart';

/// {@template num2text_en}
/// Converts numbers to English words (`Lang.EN`).
///
/// Implements [Num2TextBase] for English, handling various numeric types.
/// Supports cardinal numbers, decimals, negatives, currency, years, and large numbers (short scale).
/// Customizable via [EnOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextEN implements Num2TextBase {
  // --- Constants ---
  static const String _hundred = "hundred";
  static const String _zero = "zero";
  static const String _point = "point";
  static const String _comma = "comma";
  static const String _and = "and";
  static const String _currencyConjunction =
      " and "; // Separator for currency units.
  static const String _yearSuffixBC = "BC";
  static const String _yearSuffixAD = "AD";

  static const List<String> _wordsUnder20 = [
    "zero",
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
    "ten",
    "eleven",
    "twelve",
    "thirteen",
    "fourteen",
    "fifteen",
    "sixteen",
    "seventeen",
    "eighteen",
    "nineteen",
  ];
  static const List<String> _wordsTens = [
    "",
    "",
    "twenty",
    "thirty",
    "forty",
    "fifty",
    "sixty",
    "seventy",
    "eighty",
    "ninety",
  ];
  static const List<String> _scaleWords = [
    // Short scale (powers of 1000)
    "", "thousand", "million", "billion", "trillion", "quadrillion",
    "quintillion", "sextillion", "septillion", "octillion", "nonillion",
    "decillion", "undecillion", "duodecillion", "tredecillion",
    "quattuordecillion", "quindecillion",
  ];

  /// Processes the given [number] into English words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [EnOptions] for customization (currency, year format, decimals, 'and', AD/BC, rounding).
  /// Defaults apply if [options] is null or not [EnOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or "Not A Number" on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [EnOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as English words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final EnOptions enOptions =
        options is EnOptions ? options : const EnOptions();
    final String errorFallback = fallbackOnError ?? "Not A Number";

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Negative Infinity" : "Infinity";
      if (number.isNaN) return errorFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    if (decimalValue == Decimal.zero) {
      return enOptions.currency
          ? "$_zero ${enOptions.currencyInfo.mainUnitPlural ?? enOptions.currencyInfo.mainUnitSingular}"
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    if (enOptions.format == Format.year) {
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), enOptions);
    } else {
      textResult = enOptions.currency
          ? _handleCurrency(absValue, enOptions)
          : _handleStandardNumber(absValue, enOptions);
      if (isNegative) {
        textResult = "${enOptions.negativePrefix} $textResult";
      }
    }

    return textResult.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Converts an integer year to English words following common conventions.
  ///
  /// Handles 1100-1999, 2000-2009, 2010-2099 specifically. Appends AD/BC if requested.
  /// Uses [EnOptions.includeAnd] for 2000-2009 range.
  ///
  /// @param year The integer year.
  /// @param options Formatting options ([EnOptions]).
  /// @return The year as English words.
  String _handleYearFormat(int year, EnOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;
    String yearText;

    if (absYear == 0)
      yearText = _zero;
    else if (absYear >= 1100 && absYear < 2000) {
      final int high = absYear ~/ 100, low = absYear % 100;
      final String highText = _convertInteger(BigInt.from(high), false);
      if (low == 0)
        yearText = "$highText $_hundred"; // e.g., nineteen hundred
      else {
        final String lowText =
            _convertInteger(BigInt.from(low), options.includeAnd);
        if (low < 10 && options.includeAnd)
          yearText =
              "$highText $_hundred $_and $lowText"; // e.g., nineteen hundred and five
        else if (low < 10 && !options.includeAnd)
          yearText =
              "$highText $_hundred $lowText"; // e.g., nineteen hundred five
        else
          yearText = "$highText $lowText"; // e.g., nineteen eighty-four
      }
    } else if (absYear >= 2000 && absYear < 2010) {
      final int low = absYear % 100;
      if (low == 0)
        yearText = _convertInteger(
            BigInt.from(absYear), options.includeAnd); // two thousand
      else {
        final String highText =
            _convertInteger(BigInt.from(2000), false); // two thousand
        final String lowText = _convertInteger(BigInt.from(low), false); // five
        final String connector = options.includeAnd ? " $_and " : " ";
        yearText = "$highText$connector$lowText"; // two thousand (and) five
      }
    } else if (absYear >= 2010 && absYear < 2100) {
      // e.g., twenty twenty-four
      final String highText =
          _convertInteger(BigInt.from(absYear ~/ 100), false);
      final String lowText = _convertInteger(BigInt.from(absYear % 100), false);
      yearText = "$highText $lowText";
    } else {
      // Default conversion for other years
      yearText = _convertInteger(BigInt.from(absYear), options.includeAnd);
    }

    if (isNegative)
      yearText += " $_yearSuffixBC";
    else if (options.includeAD && absYear > 0) yearText += " $_yearSuffixAD";

    return yearText;
  }

  /// Converts a non-negative [Decimal] to English currency words.
  ///
  /// Uses [EnOptions.currencyInfo] for unit names. Rounds if [EnOptions.round] is true.
  /// Separates main and subunits (e.g., dollars, cents).
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options ([EnOptions]).
  /// @return Currency value as English words.
  String _handleCurrency(Decimal absValue, EnOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final Decimal val = options.round ? absValue.round(scale: 2) : absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    final BigInt subVal =
        ((val - Decimal.fromBigInt(mainVal)) * Decimal.fromInt(100))
            .round(scale: 0)
            .toBigInt();

    String mainPart = '';
    if (mainVal > BigInt.zero) {
      final String name = (mainVal == BigInt.one)
          ? info.mainUnitSingular
          : (info.mainUnitPlural ?? info.mainUnitSingular);
      mainPart = '${_convertInteger(mainVal, options.includeAnd)} $name';
    }

    String subPart = '';
    if (subVal > BigInt.zero && info.subUnitSingular != null) {
      final String name = (subVal == BigInt.one)
          ? info.subUnitSingular!
          : (info.subUnitPlural ?? info.subUnitSingular!);
      subPart =
          '${_convertInteger(subVal, false)} $name'; // 'and' typically not used in subunit number
    }

    if (mainPart.isNotEmpty && subPart.isNotEmpty) {
      final String sep = info.separator?.isNotEmpty ?? false
          ? ' ${info.separator!} '
          : _currencyConjunction;
      return '$mainPart$sep$subPart';
    } else if (mainPart.isNotEmpty)
      return mainPart;
    else if (subPart.isNotEmpty)
      return subPart; // Handle 0.xx cases
    else
      return "${_wordsUnder20[0]} ${info.mainUnitPlural ?? info.mainUnitSingular}"; // Zero case
  }

  /// Converts a non-negative standard [Decimal] number (non-integer) to English words.
  ///
  /// Converts integer and fractional parts. Uses [EnOptions.decimalSeparator] word.
  /// Fractional part converted digit by digit.
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options ([EnOptions]).
  /// @return Number as English words.
  String _handleStandardNumber(Decimal absValue, EnOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, options.includeAnd);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      String sepWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          sepWord = _comma;
          break;
        default:
          sepWord = _point;
          break; // Default to point/period
      }

      final String fullStr = absValue.toString();
      final int pointIdx = fullStr.indexOf('.');
      if (pointIdx != -1) {
        String fracDigits = fullStr.substring(pointIdx + 1);
        while (fracDigits.endsWith('0') && fracDigits.length > 1) {
          // Trim trailing zeros
          fracDigits = fracDigits.substring(0, fracDigits.length - 1);
        }
        final List<String> digitWords = fracDigits.split('').map((d) {
          final int? i = int.tryParse(d);
          return (i != null && i >= 0 && i <= 9) ? _wordsUnder20[i] : '?';
        }).toList();
        fractionalWords = ' $sepWord ${digitWords.join(' ')}';
      }
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer ([BigInt]) into English words using short scale.
  ///
  /// Breaks the number into chunks of 1000. Delegates chunks to [_convertChunk].
  ///
  /// @param n Non-negative integer.
  /// @param includeAnd Whether to use "and" within chunks (passed to [_convertChunk]).
  /// @throws ArgumentError if [n] is negative or too large.
  /// @return Integer as English words.
  String _convertInteger(BigInt n, bool includeAnd) {
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.from(1000)) return _convertChunk(n.toInt(), includeAnd);

    final List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIdx = 0;
    BigInt rem = n;

    while (rem > BigInt.zero) {
      if (scaleIdx >= _scaleWords.length)
        throw ArgumentError("Number too large");
      final BigInt chunk = rem % oneThousand;
      rem ~/= oneThousand;
      if (chunk > BigInt.zero) {
        final String chunkText = _convertChunk(chunk.toInt(), includeAnd);
        final String scaleWord = scaleIdx > 0 ? _scaleWords[scaleIdx] : "";
        parts.add(scaleWord.isEmpty ? chunkText : '$chunkText $scaleWord');
      }
      scaleIdx++;
    }
    return parts.reversed.join(' ').trim();
  }

  /// Converts an integer from 0 to 999 into English words.
  ///
  /// Handles hundreds, tens, units. Uses [includeAnd] for British style.
  /// Hyphenates compounds (e.g., "twenty-one").
  ///
  /// @param n Integer chunk (0-999).
  /// @param includeAnd Whether to include "and" after hundreds.
  /// @throws ArgumentError if [n] is outside 0-999.
  /// @return Chunk as English words, or empty string if [n] is 0.
  String _convertChunk(int n, bool includeAnd) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    final List<String> words = [];
    int rem = n;

    if (rem >= 100) {
      words.add(_wordsUnder20[rem ~/ 100]);
      words.add(_hundred);
      rem %= 100;
      if (rem > 0 && includeAnd) words.add(_and);
    }

    if (rem > 0) {
      if (rem < 20)
        words.add(_wordsUnder20[rem]);
      else {
        final String tens = _wordsTens[rem ~/ 10];
        final int unit = rem % 10;
        words.add(unit == 0 ? tens : "$tens-${_wordsUnder20[unit]}");
      }
    }
    return words.join(' ');
  }
}
