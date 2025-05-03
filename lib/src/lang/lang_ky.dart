import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ky_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ky}
/// Converts numbers to Kyrgyz words (`Lang.KY`).
///
/// Implements [Num2TextBase] for Kyrgyz. Handles various numeric types.
/// Supports cardinal numbers, decimals, negatives, currency (Som), years (with optional AD/BC),
/// and large numbers using the short scale (миң, миллион, etc.).
/// Customizable via [KyOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextKY implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "нөл";
  static const String _point =
      "точка"; // Decimal separator word for period/point.
  static const String _comma = "үтүр"; // Decimal separator word for comma.
  static const String _currencySeparator =
      " "; // Default separator for currency units.
  static const String _hundred = "жүз";
  static const String _yearSuffixBCE = "б.з.ч."; // Before Common Era suffix.
  static const String _yearSuffixAD =
      "б.з."; // Common Era suffix (if requested).
  static const String _infinity = "Чексиздик";
  static const String _negativeInfinity = "Терс Чексиздик";
  static const String _nan = "Сан Эмес"; // Default "Not a Number" fallback.

  static const List<String> _wordsUnits = [
    "нөл",
    "бир",
    "эки",
    "үч",
    "төрт",
    "беш",
    "алты",
    "жети",
    "сегиз",
    "тогуз",
  ];
  static const List<String> _wordsTens = [
    "",
    "он",
    "жыйырма",
    "отуз",
    "кырк",
    "элүү",
    "алтымыш",
    "жетимиш",
    "сексен",
    "токсон",
  ];

  /// Scale words (short scale system, powers of 1000).
  static const List<String> _scaleWords = [
    "",
    "миң",
    "миллион",
    "миллиард",
    "триллион",
    "квадриллион",
    "квинтиллион",
    "секстиллион",
    "септиллион",
  ];

  /// Processes the given [number] into Kyrgyz words.
  ///
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// Uses [KyOptions] for customization (currency, year, decimals, AD/BC).
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or [_nan] on failure.
  ///
  /// @param number The number to convert.
  /// @param options Optional [KyOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Kyrgyz words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final KyOptions kyOptions =
        options is KyOptions ? options : const KyOptions();
    final String errorMsg = fallbackOnError ?? _nan;

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _negativeInfinity : _infinity;
      if (number.isNaN) return errorMsg;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorMsg;

    if (decimalValue == Decimal.zero) {
      return kyOptions.currency
          ? "$_zero ${kyOptions.currencyInfo.mainUnitSingular}"
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    if (kyOptions.format == Format.year) {
      // Pass isNegative to year handler for BC/AD logic.
      textResult = _handleYearFormat(
          absValue.truncate().toBigInt().toInt(), kyOptions, isNegative);
    } else {
      textResult = kyOptions.currency
          ? _handleCurrency(absValue, kyOptions)
          : _handleStandardNumber(absValue, kyOptions);
      if (isNegative) {
        textResult = "${kyOptions.negativePrefix} $textResult";
      }
    }
    return textResult.trim();
  }

  /// Converts a non-negative [Decimal] to Kyrgyz currency words (Som).
  ///
  /// Uses [KyOptions.currencyInfo]. Rounds if [KyOptions.round] is true.
  /// Separates main (Som) and subunits (Tyiyn).
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Kyrgyz words.
  String _handleCurrency(Decimal absValue, KyOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    const int decimalPlaces = 2; // Assuming 2 decimal places for subunits.
    final Decimal val =
        options.round ? absValue.round(scale: decimalPlaces) : absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    final BigInt subVal =
        ((val - val.truncate()) * Decimal.ten.pow(decimalPlaces).toDecimal())
            .round()
            .toBigInt();

    String mainPart = '';
    if (mainVal > BigInt.zero ||
        (mainVal == BigInt.zero && subVal == BigInt.zero)) {
      // Include main part if > 0 OR if both are zero (to show "нөл сом").
      mainPart = '${_convertInteger(mainVal)} ${info.mainUnitSingular}';
    }

    String subPart = '';
    if (subVal > BigInt.zero && info.subUnitSingular != null) {
      subPart = '${_convertInteger(subVal)} ${info.subUnitSingular}';
    }

    if (mainPart.isNotEmpty && subPart.isNotEmpty) {
      return '$mainPart${info.separator ?? _currencySeparator}$subPart';
    } else {
      return mainPart.isNotEmpty
          ? mainPart
          : subPart; // Return whichever part exists, or mainPart if both zero.
    }
  }

  /// Converts an integer year to Kyrgyz words.
  ///
  /// Appends [_yearSuffixBCE] for negative years.
  /// Appends [_yearSuffixAD] for positive years if [KyOptions.includeAD] is true.
  ///
  /// @param yearValue The absolute integer year value.
  /// @param options Formatting options.
  /// @param isNegative Indicates if the original year was negative.
  /// @return The year as Kyrgyz words.
  String _handleYearFormat(int yearValue, KyOptions options, bool isNegative) {
    // Year 0 is handled in process().
    String yearText = _convertInteger(BigInt.from(yearValue));
    if (isNegative)
      yearText += " $_yearSuffixBCE";
    else if (options.includeAD) yearText += " $_yearSuffixAD";
    return yearText;
  }

  /// Converts a non-negative standard [Decimal] number to Kyrgyz words.
  ///
  /// Converts integer and fractional parts. Uses [KyOptions.decimalSeparator] word.
  /// Fractional part converted digit by digit (e.g., точка беш).
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Kyrgyz words.
  String _handleStandardNumber(Decimal absValue, KyOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      String sepWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          sepWord = _comma;
          break;
        default:
          sepWord = _point;
          break; // Default to точка
      }
      String fractionalDigits = absValue.toString().split('.').last;
      List<String> digitWords = fractionalDigits.split('').map((d) {
        final int? i = int.tryParse(d);
        return (i != null && i >= 0 && i < _wordsUnits.length)
            ? _wordsUnits[i]
            : '?';
      }).toList();
      // Join digits with spaces in Kyrgyz.
      fractionalWords = ' $sepWord ${digitWords.join(' ')}';
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] into Kyrgyz words using short scale.
  ///
  /// Breaks the number into chunks of 1000. Delegates chunks to [_convertUnder1000].
  ///
  /// @param n Non-negative integer.
  /// @throws ArgumentError if [n] is too large for defined scales.
  /// @return Integer as Kyrgyz words.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _zero;
    assert(n > BigInt.zero);

    if (n < BigInt.from(1000)) return _convertUnder1000(n.toInt());

    List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0;
    BigInt remaining = n;

    while (remaining > BigInt.zero) {
      if (scaleIndex >= _scaleWords.length) {
        throw ArgumentError(
            "Number too large (exceeds scale: ${_scaleWords.last})");
      }
      BigInt chunk = remaining % oneThousand;
      remaining ~/= oneThousand;

      if (chunk > BigInt.zero) {
        String chunkText = _convertUnder1000(chunk.toInt());
        String scaleWord = (scaleIndex > 0) ? _scaleWords[scaleIndex] : "";
        parts.add(scaleWord.isNotEmpty ? "$chunkText $scaleWord" : chunkText);
      }
      scaleIndex++;
    }
    return parts.reversed.join(' ');
  }

  /// Converts an integer between 0 and 999 into Kyrgyz words.
  ///
  /// @param n Integer chunk (0-999).
  /// @return Chunk as Kyrgyz words, or empty string if [n] is 0.
  String _convertUnder1000(int n) {
    if (n == 0) return "";
    assert(n > 0 && n < 1000);

    if (n < 100) return _convertUnder100(n);

    List<String> words = [];
    int hundreds = n ~/ 100;
    int remainder = n % 100;

    words.add(_wordsUnits[hundreds]);
    words.add(_hundred);
    if (remainder > 0) {
      words.add(_convertUnder100(remainder));
    }
    return words.join(' ');
  }

  /// Converts an integer between 0 and 99 into Kyrgyz words.
  ///
  /// @param n Integer (0-99).
  /// @return Number as Kyrgyz words, or empty string if [n] is 0.
  String _convertUnder100(int n) {
    assert(n >= 0 && n < 100);
    if (n == 0) return "";
    if (n < 10) return _wordsUnits[n];

    int tens = n ~/ 10;
    int units = n % 10;
    String tensWord = _wordsTens[tens];

    return units == 0 ? tensWord : "$tensWord ${_wordsUnits[units]}";
  }
}
