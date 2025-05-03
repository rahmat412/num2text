import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart'; // Currency data
import '../num2text_base.dart'; // Base class
import '../options/base_options.dart'; // Options enums
import '../options/hy_options.dart'; // Armenian options
import '../utils/utils.dart'; // Utils

/// {@template num2text_hy}
/// Converts numbers to Armenian words (`Lang.HY`).
///
/// Implements [Num2TextBase] for Armenian. Handles integers, decimals, currency,
/// years, negatives, and large numbers. Customizable via [HyOptions].
/// {@endtemplate}
class Num2TextHY implements Num2TextBase {
  // --- Linguistic Constants ---
  static const String _zero = "զրո";
  static const String _pointComma = "ստորակետ"; // Decimal separator (comma)
  static const String _pointPeriod = "կետ"; // Decimal separator (period)
  static const String _hundred = "հարյուր";
  static const String _thousand = "հազար";
  static const String _million = "միլիոն";
  static const String _billion = "միլիարդ";
  static const String _trillion = "տրիլիոն";
  static const String _quadrillion = "կվադրիլիոն";
  static const String _quintillion = "կվինտիլիոն";
  static const String _sextillion = "սեքստիլիոն";
  static const String _septillion = "սեպտիլիոն";
  static const String _yearSuffixAD = "թ."; // Era suffix (AD/CE)
  static const String _yearSuffixBC = "մ.թ.ա."; // Era suffix (BC/BCE)
  static const String _currencySeparator = "և"; // Currency unit separator

  static const List<String> _wordsUnder20 = [
    "զրո", "մեկ", "երկու", "երեք", "չորս", "հինգ", "վեց", "յոթ", "ութ",
    "ինը", // 0-9
    "տասը", "տասնմեկ", "տասներկու", "տասներեք", "տասնչորս", "տասնհինգ", // 10-15
    "տասնվեց", "տասնյոթ", "տասնութ", "տասնինը", // 16-19
  ];
  static const List<String> _wordsTens = [
    "", "", "քսան", "երեսուն", "քառասուն", "հիսուն", "վաթսուն", "յոթանասուն",
    "ութսուն",
    "իննսուն", // 0, 10 placeholders; 20-90
  ];

  /// Scale words (powers of 1000).
  static const List<String> _scaleWords = [
    "",
    _thousand,
    _million,
    _billion,
    _trillion,
    _quadrillion,
    _quintillion,
    _sextillion,
    _septillion,
  ];

  /// Processes the given [number] into Armenian words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [HyOptions] for customization (currency, year format, decimals, era, negative prefix).
  /// Defaults apply if [options] is null or not [HyOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or "Թիվ չէ" on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [HyOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Armenian words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final HyOptions hyOptions =
        options is HyOptions ? options : const HyOptions();
    const String defaultFallback = "Թիվ չէ"; // "Not a number"

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Բացասական անվերջություն" : "Անվերջություն";
      if (number.isNaN) return fallbackOnError ?? defaultFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return fallbackOnError ?? defaultFallback;

    if (decimalValue == Decimal.zero) {
      return hyOptions.currency
          ? "$_zero ${hyOptions.currencyInfo.mainUnitSingular}"
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    if (hyOptions.format == Format.year) {
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), hyOptions);
    } else {
      textResult = hyOptions.currency
          ? _handleCurrency(absValue, hyOptions)
          : _handleStandardNumber(absValue, hyOptions);
      if (isNegative) {
        textResult = "${hyOptions.negativePrefix} $textResult";
      }
    }
    return textResult.trim();
  }

  /// Formats an integer as an Armenian year with optional era suffixes.
  ///
  /// @param year The integer year (negative for BC).
  /// @param options Options controlling era suffix display (`includeEra`).
  /// @return The year as Armenian words.
  String _handleYearFormat(int year, HyOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;
    if (absYear == 0) return _zero; // Year zero case

    final String yearText = _convertInteger(BigInt.from(absYear));

    if (isNegative)
      return "$yearText $_yearSuffixBC"; // Always add BC suffix if negative
    if (options.includeEra)
      return "$yearText $_yearSuffixAD"; // Add AD only if requested
    return yearText; // No suffix for positive years by default
  }

  /// Converts a non-negative [Decimal] to Armenian currency words.
  ///
  /// Uses [HyOptions.currencyInfo] for unit names and separator.
  /// Assumes 100 subunits per main unit. Does not round implicitly.
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Armenian words.
  String _handleCurrency(Decimal absValue, HyOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    final BigInt mainVal = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    // Round subunit value to handle potential floating point inaccuracies near subunit boundaries.
    final BigInt subVal =
        (fractionalPart * subunitMultiplier).round().toBigInt();

    String mainPart = "";
    if (mainVal > BigInt.zero) {
      mainPart = '${_convertInteger(mainVal)} ${info.mainUnitSingular}';
    }

    String subPart = "";
    if (subVal > BigInt.zero && info.subUnitSingular != null) {
      subPart = '${_convertInteger(subVal)} ${info.subUnitSingular}';
    }

    if (mainPart.isNotEmpty && subPart.isNotEmpty) {
      final String sep = info.separator ?? _currencySeparator;
      return '$mainPart $sep $subPart';
    } else if (mainPart.isNotEmpty)
      return mainPart;
    else if (subPart.isNotEmpty)
      return subPart; // Handle 0.xx cases
    else
      return '$_zero ${info.mainUnitSingular}'; // Zero case
  }

  /// Converts a non-negative standard [Decimal] number to Armenian words.
  ///
  /// Handles integer and fractional parts. Uses [HyOptions.decimalSeparator] word.
  /// Fractional part converted digit by digit. Trims trailing zeros.
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Armenian words.
  String _handleStandardNumber(Decimal absValue, HyOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      String sepWord;
      switch (options.decimalSeparator ?? DecimalSeparator.comma) {
        // Default to comma
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          sepWord = _pointPeriod;
          break;
        case DecimalSeparator.comma:
          sepWord = _pointComma;
          break;
      }

      String fractionalDigits = absValue.toString().split('.').last;
      fractionalDigits = fractionalDigits.replaceAll(
          RegExp(r'0+$'), ''); // Trim trailing zeros

      if (fractionalDigits.isNotEmpty) {
        final List<String> digitWords = fractionalDigits.split('').map((d) {
          final int i = int.parse(d);
          return (i >= 0 && i < _wordsUnder20.length) ? _wordsUnder20[i] : '?';
        }).toList();
        fractionalWords = ' $sepWord ${digitWords.join(' ')}';
      }
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] into Armenian words using scale words.
  ///
  /// Breaks the number into chunks of 1000. Delegates chunks to [_convertChunk].
  /// Special handling for exact scale values (e.g., 1000 -> "հազար").
  /// Special handling for "one thousand" (avoids saying "մեկ հազար").
  ///
  /// @param n Non-negative integer.
  /// @throws ArgumentError if [n] is negative or exceeds defined scales.
  /// @return Integer as Armenian words.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n == BigInt.zero) return _zero;

    // Optimization: Check for exact scale values first (1000, 1M, etc.)
    if (n >= BigInt.from(1000)) {
      for (int i = _scaleWords.length - 1; i >= 1; i--) {
        final BigInt scaleValue = BigInt.from(1000).pow(i);
        if (n == scaleValue)
          return _scaleWords[i]; // Return "հազար", "միլիոն", etc. directly
      }
    }

    final List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0;
    BigInt remaining = n;

    while (remaining > BigInt.zero) {
      if (scaleIndex >= _scaleWords.length)
        throw ArgumentError("Number too large: $n");
      final BigInt chunkBigInt = remaining % oneThousand;
      final int chunk = chunkBigInt.toInt(); // Chunk is 0-999
      remaining ~/= oneThousand;

      if (chunk > 0) {
        final String chunkText = _convertChunk(chunk);
        final String scaleWord = _scaleWords[scaleIndex];
        String currentPart;

        if (scaleWord.isNotEmpty) {
          // Special case: Avoid "մեկ հազար", just use "հազար".
          if (chunk == 1 && scaleWord == _thousand) {
            currentPart = scaleWord;
          } else {
            currentPart = "$chunkText $scaleWord";
          }
        } else {
          currentPart = chunkText; // Base chunk (0-999)
        }
        parts.add(currentPart);
      }
      scaleIndex++;
    }
    // Join parts from largest scale down ("million thousand unit")
    return parts.reversed.join(' ').trim();
  }

  /// Converts an integer from 0 to 999 into Armenian words.
  ///
  /// Handles hundreds, tens, units. Delegates tens+units to [_fuseTensUnits].
  ///
  /// @param n Integer chunk (0-999).
  /// @throws ArgumentError if [n] is outside 0-999.
  /// @return Chunk as Armenian words, or empty string if [n] is 0.
  String _convertChunk(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    final List<String> words = [];
    int remainder = n;

    if (remainder >= 100) {
      final int hundredDigit = remainder ~/ 100;
      // Handle "հարյուր" (100) vs "երկու հարյուր" (200), etc.
      if (hundredDigit == 1)
        words.add(_hundred);
      else
        words.add("${_wordsUnder20[hundredDigit]} $_hundred");
      remainder %= 100;
    }

    if (remainder > 0) {
      if (remainder < 20)
        words.add(_wordsUnder20[remainder]);
      else
        words.add(_fuseTensUnits(remainder ~/ 10, remainder % 10));
    }
    return words.join(' ');
  }

  /// Combines Armenian tens and units words (for 20-99).
  ///
  /// Applies specific concatenation rules (e.g., "քսան" + "մեկ" -> "քսանմեկ").
  ///
  /// @param tensDigit The tens digit (2-9).
  /// @param unitDigit The units digit (0-9).
  /// @return The combined word for the number.
  String _fuseTensUnits(int tensDigit, int unitDigit) {
    if (unitDigit == 0) {
      // Pure tens (20, 30...)
      return (tensDigit >= 2 && tensDigit < _wordsTens.length)
          ? _wordsTens[tensDigit]
          : '';
    }
    if (tensDigit < 2 || tensDigit >= _wordsTens.length)
      return ''; // Invalid tens digit

    final String tensWord = _wordsTens[tensDigit];
    final String unitWord = _wordsUnder20[unitDigit];

    // Armenian often concatenates tens and units directly. Handle special cases if any.
    if (tensDigit == 9 && unitDigit == 9)
      return "իննսունինը"; // Special case for 99

    return tensWord +
        unitWord; // Standard concatenation (e.g., "քսանմեկ", "երեսուներկու")
  }
}
