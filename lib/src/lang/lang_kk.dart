import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/kk_options.dart';
import '../utils/utils.dart';

/// {@template num2text_kk}
/// Converts numbers to Kazakh words (`Lang.KK`).
///
/// Implements [Num2TextBase] for Kazakh. Handles various numeric inputs.
/// Features:
/// - Cardinal numbers.
/// - Currency formatting (default KZT).
/// - Year formatting (prepends negative prefix).
/// - Decimal and negative number handling.
/// - Large numbers using short scale (мың, миллион, etc.).
/// Customizable via [KkOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextKK implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "нөл";
  static const String _point = "нүкте"; // Default decimal separator word
  static const String _comma = "үтір"; // Comma decimal separator word
  static const String _currencySeparator =
      " "; // Default currency unit separator
  static const String _hundred = "жүз";

  /// Kazakh words for digits 0-9.
  static const List<String> _wordsUnits = [
    "нөл",
    "бір",
    "екі",
    "үш",
    "төрт",
    "бес",
    "алты",
    "жеті",
    "сегіз",
    "тоғыз",
  ];

  /// Kazakh words for tens (10-90).
  static const List<String> _wordsTens = [
    "",
    "он",
    "жиырма",
    "отыз",
    "қырық",
    "елу",
    "алпыс",
    "жетпіс",
    "сексен",
    "тоқсан",
  ];

  /// Kazakh scale words (powers of 1000).
  static const List<String> _scaleWords = [
    "",
    "мың",
    "миллион",
    "миллиард",
    "триллион",
    "квадриллион",
    "квинтиллион",
    "секстиллион",
    "септиллион",
  ];

  /// Processes the given [number] into Kazakh words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [KkOptions] for customization (currency, year format, decimals).
  /// Defaults apply if [options] is null or not [KkOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or "Сан емес" on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [KkOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Kazakh words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final KkOptions kkOptions =
        options is KkOptions ? options : const KkOptions();
    final String errorDefault = fallbackOnError ?? "Сан емес";

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Теріс шексіздік" : "Шексіздік";
      if (number.isNaN) return errorDefault;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorDefault;

    if (decimalValue == Decimal.zero) {
      return kkOptions.currency
          ? "$_zero ${kkOptions.currencyInfo.mainUnitSingular}"
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    if (kkOptions.format == Format.year) {
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), kkOptions);
    } else {
      textResult = kkOptions.currency
          ? _handleCurrency(absValue, kkOptions)
          : _handleStandardNumber(absValue, kkOptions);
      if (isNegative) {
        textResult = "${kkOptions.negativePrefix} $textResult";
      }
    }
    return textResult.trim();
  }

  /// Converts an integer year to Kazakh words, prepending negative prefix if needed.
  /// Optionally adds " ж." (year suffix) if [KkOptions.includeAD] is true.
  ///
  /// @param year The integer year (negative allowed).
  /// @param options Formatting options ([KkOptions.negativePrefix], [KkOptions.includeAD]).
  /// @return The year as Kazakh words.
  String _handleYearFormat(int year, KkOptions options) {
    final bool isNegative = year < 0;
    final BigInt absYear = BigInt.from(isNegative ? -year : year);
    String yearText = _convertInteger(absYear);
    if (isNegative) {
      yearText = "${options.negativePrefix} $yearText";
    } else if (options.includeAD) {
      yearText += " ж."; // Add year suffix if requested
    }
    return yearText;
  }

  /// Converts a non-negative [Decimal] to Kazakh currency words (e.g., Tenge, Tiyn).
  ///
  /// Uses [KkOptions.currencyInfo]. Rounds if [KkOptions.round] is true.
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Kazakh words.
  String _handleCurrency(Decimal absValue, KkOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final Decimal val = options.round ? absValue.round(scale: 2) : absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    final BigInt subVal = ((val - val.truncate()) * Decimal.fromInt(100))
        .round()
        .toBigInt(); // Assumes 100 subunits

    String mainPart = '';
    if (mainVal > BigInt.zero) {
      mainPart =
          '${_convertInteger(mainVal)} ${info.mainUnitSingular}'; // Assumes singular form is sufficient
    }

    String subPart = '';
    if (subVal > BigInt.zero && info.subUnitSingular != null) {
      subPart =
          '${_convertInteger(subVal)} ${info.subUnitSingular!}'; // Assumes singular form is sufficient
    }

    if (mainPart.isNotEmpty && subPart.isNotEmpty) {
      final String sep = info.separator ?? _currencySeparator;
      return '$mainPart$sep$subPart';
    } else if (mainPart.isNotEmpty)
      return mainPart;
    else if (subPart.isNotEmpty)
      return subPart;
    else
      return '$_zero ${info.mainUnitSingular}'; // Zero case
  }

  /// Converts a non-negative standard [Decimal] number to Kazakh words.
  ///
  /// Handles integer and fractional parts. Uses [KkOptions.decimalSeparator].
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Kazakh words.
  String _handleStandardNumber(Decimal absValue, KkOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      final String sepWord =
          (options.decimalSeparator == DecimalSeparator.comma)
              ? _comma
              : _point;
      final String fracDigits =
          absValue.toString().split('.').last; // Get digits after point
      final List<String> digitWords = fracDigits.split('').map((d) {
        final int? i = int.tryParse(d);
        return (i != null && i >= 0 && i < _wordsUnits.length)
            ? _wordsUnits[i]
            : '?';
      }).toList();
      fractionalWords = ' $sepWord ${digitWords.join(' ')}';
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer ([BigInt]) into Kazakh words using scales.
  ///
  /// @param n Non-negative integer.
  /// @throws ArgumentError if [n] is too large.
  /// @return Integer as Kazakh words.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _zero;
    assert(n > BigInt.zero);
    if (n < BigInt.from(1000)) return _convertUnder1000(n.toInt());

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
        final String chunkText = _convertUnder1000(chunk.toInt());
        final String scaleWord = scaleIdx > 0 ? _scaleWords[scaleIdx] : "";
        parts.add(scaleWord.isNotEmpty ? "$chunkText $scaleWord" : chunkText);
      }
      scaleIdx++;
    }
    return parts.reversed.join(' ');
  }

  /// Converts an integer between 0 and 999 into Kazakh words.
  ///
  /// @param n Integer chunk (0-999).
  /// @return Chunk as Kazakh words, or empty string if [n] is 0.
  String _convertUnder1000(int n) {
    if (n == 0) return "";
    assert(n > 0 && n < 1000);
    if (n < 100) return _convertUnder100(n);

    final List<String> words = [];
    int rem = n;
    final int hDigit = rem ~/ 100;
    // Use "бір" for 1 hundred, otherwise the digit word
    words.add(hDigit == 1 ? _wordsUnits[1] : _wordsUnits[hDigit]);
    words.add(_hundred);
    rem %= 100;
    if (rem > 0) {
      words.add(_convertUnder100(rem));
    }
    return words.join(' ');
  }

  /// Converts an integer between 0 and 99 into Kazakh words.
  ///
  /// @param n Integer chunk (0-99).
  /// @return Chunk as Kazakh words, or empty string if [n] is 0.
  String _convertUnder100(int n) {
    assert(n >= 0 && n < 100);
    if (n == 0) return "";
    if (n < 10) return _wordsUnits[n];

    final int tensDigit = n ~/ 10;
    final int unitDigit = n % 10;
    final String tensWord = _wordsTens[tensDigit];
    return unitDigit == 0 ? tensWord : "$tensWord ${_wordsUnits[unitDigit]}";
  }
}
