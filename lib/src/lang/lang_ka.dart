import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ka_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ka}
/// Converts numbers to Georgian words (`Lang.KA`).
///
/// Implements [Num2TextBase] for Georgian (ქართული). Handles various numeric inputs.
/// Features:
/// - Cardinal numbers using the Georgian vigesimal (base-20) system under 100.
/// - Correct stem forms for hundreds/thousands (ას/ათას).
/// - Currency formatting (default GEL).
/// - Year formatting with optional AD/BC suffixes (ჩვ. წ./ჩვ. წ.-მდე).
/// - Decimal and negative number handling.
/// - Large numbers (ათასი, მილიონი, etc.).
/// Customizable via [KaOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextKA implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "ნული"; // nuli
  static const String _pointComma = "მძიმე"; // mdzime (comma separator)
  static const String _pointPeriod = "წერტილი"; // ts'ert'ili (period separator)
  static const String _currencySeparatorDefault = " და "; // da (and)
  static const String _thousandStem = "ათას"; // atas (thousand stem)
  static const String _thousand = "ათასი"; // atasi (thousand full form)
  static const String _hundredStem = "ას"; // as (hundred stem)
  static const String _hundred = "ასი"; // asi (hundred full form)
  static const String _yearSuffixAD = " ჩვ. წ."; // chv. ts'. (AD/CE suffix)
  static const String _yearSuffixBC =
      " ჩვ. წ.-მდე"; // chv. ts'.-mde (BC/BCE suffix)
  static const String _infinity = "უსასრულობა"; // usasruloba
  static const String _nan = "არა რიცხვი"; // ara ritskhvi (Not a Number)

  /// Georgian words for numbers 1-19.
  static const Map<int, String> _units = {
    1: "ერთი",
    2: "ორი",
    3: "სამი",
    4: "ოთხი",
    5: "ხუთი",
    6: "ექვსი",
    7: "შვიდი",
    8: "რვა",
    9: "ცხრა",
    10: "ათი",
    11: "თერთმეტი",
    12: "თორმეტი",
    13: "ცამეტი",
    14: "თოთხმეტი",
    15: "თხუთმეტი",
    16: "თექვსმეტი",
    17: "ჩვიდმეტი",
    18: "თვრამეტი",
    19: "ცხრამეტი",
  };

  /// Georgian words for base-20 tens (full form).
  static const Map<int, String> _tens = {
    20: "ოცი",
    40: "ორმოცი",
    60: "სამოცი",
    80: "ოთხმოცი",
  };

  /// Georgian words for base-20 tens (stem form used with -და).
  static const Map<int, String> _tensStems = {
    20: "ოც",
    40: "ორმოც",
    60: "სამოც",
    80: "ოთხმოც",
  };

  /// Georgian prefixes for hundreds (200-900). Combine with _hundred / _hundredStem.
  static const Map<int, String> _hundredsPrefix = {
    2: "ორ",
    3: "სამ",
    4: "ოთხ",
    5: "ხუთ",
    6: "ექვს",
    7: "შვიდ",
    8: "რვა",
    9: "ცხრა",
  };

  /// Georgian scale words (powers of 1000).
  static const List<String> _scaleWords = [
    "",
    _thousand,
    "მილიონი",
    "მილიარდი",
    "ტრილიონი",
    "კვადრილიონი",
    "კვინტილიონი",
    "სექსტილიონი",
    "სეპტილიონი",
  ];

  /// Processes the given [number] into Georgian words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [KaOptions] for customization (currency, year format, decimals, AD/BC).
  /// Defaults apply if [options] is null or not [KaOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or "არა რიცხვი" on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [KaOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Georgian words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final KaOptions kaOptions =
        options is KaOptions ? options : const KaOptions();
    final String errorFallback = fallbackOnError ?? _nan;

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative
            ? '${kaOptions.negativePrefix} $_infinity'
            : _infinity;
      if (number.isNaN) return errorFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    if (decimalValue == Decimal.zero) {
      return kaOptions.currency
          ? "$_zero ${kaOptions.currencyInfo.mainUnitPlural ?? kaOptions.currencyInfo.mainUnitSingular}"
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    if (kaOptions.format == Format.year) {
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), kaOptions);
    } else {
      textResult = kaOptions.currency
          ? _handleCurrency(absValue, kaOptions)
          : _handleStandardNumber(absValue, kaOptions);
      if (isNegative) {
        textResult = "${kaOptions.negativePrefix} $textResult";
      }
    }
    return textResult.replaceAll(RegExp(r'\s+'), ' ').trim(); // Clean spaces
  }

  /// Converts an integer year to Georgian words, optionally adding era suffixes.
  ///
  /// @param year The integer year (negative for BC).
  /// @param options Formatting options ([KaOptions.includeAD]).
  /// @return The year as Georgian words.
  String _handleYearFormat(BigInt year, KaOptions options) {
    final bool isNegative = year < BigInt.zero;
    final BigInt absYear = isNegative ? -year : year;
    String yearText = _convertInteger(absYear);
    if (isNegative)
      yearText += _yearSuffixBC;
    else if (options.includeAD) yearText += _yearSuffixAD;
    return yearText;
  }

  /// Converts a non-negative [Decimal] to Georgian currency words (e.g., Lari, Tetri).
  ///
  /// Uses [KaOptions.currencyInfo]. Rounds if [KaOptions.round] is true.
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Georgian words.
  String _handleCurrency(Decimal absValue, KaOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final Decimal val = options.round ? absValue.round(scale: 2) : absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    final BigInt subVal =
        ((val - val.truncate()) * Decimal.fromInt(100)).truncate().toBigInt();

    String mainPart = '';
    if (mainVal > BigInt.zero) {
      final String name = (mainVal == BigInt.one)
          ? info.mainUnitSingular
          : (info.mainUnitPlural ?? info.mainUnitSingular);
      mainPart = '${_convertInteger(mainVal)} $name';
    }

    String subPart = '';
    if (subVal > BigInt.zero && info.subUnitSingular != null) {
      final String name = (subVal == BigInt.one)
          ? info.subUnitSingular!
          : (info.subUnitPlural ?? info.subUnitSingular!);
      subPart = '${_convertInteger(subVal)} $name';
    }

    if (mainPart.isNotEmpty && subPart.isNotEmpty) {
      final String sep = (info.separator ?? _currencySeparatorDefault).trim();
      return '$mainPart $sep $subPart';
    } else if (mainPart.isNotEmpty)
      return mainPart;
    else if (subPart.isNotEmpty)
      return subPart;
    else
      return '$_zero ${info.mainUnitPlural ?? info.mainUnitSingular}'; // Zero case handled in process, but fallback here.
  }

  /// Converts a non-negative standard [Decimal] number to Georgian words.
  ///
  /// Handles integer and fractional parts. Uses [KaOptions.decimalSeparator].
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Georgian words.
  String _handleStandardNumber(Decimal absValue, KaOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);
    String fractionalWords = (fractionalPart > Decimal.zero)
        ? _convertFractional(absValue, options)
        : '';
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts the fractional part of a decimal to Georgian words, including the separator.
  ///
  /// @param value The full decimal number.
  /// @param options Formatting options ([KaOptions.decimalSeparator]).
  /// @return Fractional part as Georgian words (e.g., " მძიმე ხუთი"), or empty string.
  String _convertFractional(Decimal value, KaOptions options) {
    String sepWord;
    switch (options.decimalSeparator) {
      case DecimalSeparator.period:
      case DecimalSeparator.point:
        sepWord = _pointPeriod;
        break;
      default:
        sepWord = _pointComma;
        break; // Default to comma
    }
    String fracDigits =
        value.toString().split('.').last.replaceAll(RegExp(r'0+$'), '');
    if (fracDigits.isEmpty) return "";
    List<String> digitWords = fracDigits
        .split('')
        .map((d) => (d == '0' ? _zero : _units[int.parse(d)]!))
        .toList();
    return ' $sepWord ${digitWords.join(' ')}';
  }

  /// Converts a non-negative integer ([BigInt]) into Georgian words using scales.
  ///
  /// Handles thousands stem form "ათას".
  ///
  /// @param n Non-negative integer.
  /// @throws ArgumentError if [n] is negative or too large.
  /// @return Integer as Georgian words.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");

    List<String> parts = [];
    BigInt originalN = n;
    BigInt rem = n;
    int scaleIdx = 0;

    while (rem > BigInt.zero) {
      int chunk = (rem % BigInt.from(1000)).toInt();
      rem ~/= BigInt.from(1000);
      if (chunk > 0) {
        String chunkText = _convertChunk(chunk);
        String scalePart = "";
        if (scaleIdx > 0) {
          // Handle scales (thousand, million...)
          if (scaleIdx >= _scaleWords.length)
            throw ArgumentError("Number too large");
          String scaleWord = _scaleWords[scaleIdx];
          if (scaleIdx == 1) {
            // Thousand scale logic
            bool useStem = originalN % BigInt.from(1000) !=
                BigInt.zero; // Check if lower units exist
            String thousandForm = useStem ? _thousandStem : _thousand;
            scalePart =
                (chunk == 1) ? thousandForm : "$chunkText $thousandForm";
          } else {
            // Million, billion, etc.
            scalePart = (chunk == 1)
                ? "${_units[1]!} $scaleWord"
                : "$chunkText $scaleWord";
          }
        } else {
          // Base chunk (0-999)
          scalePart = chunkText;
        }
        parts.insert(0, scalePart); // Prepend to build from largest scale down
      }
      scaleIdx++;
    }
    return parts.join(' ');
  }

  /// Converts an integer between 0 and 999 into Georgian words.
  ///
  /// Handles hundreds stem form "ას". Delegates < 100 to [_convertUnder100].
  ///
  /// @param n Integer chunk (0-999).
  /// @throws ArgumentError if [n] is outside 0-999.
  /// @return Chunk as Georgian words, or empty string if [n] is 0.
  String _convertChunk(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");
    if (n < 100) return _convertUnder100(n);

    int hDigit = n ~/ 100;
    int rem = n % 100;
    String remText = _convertUnder100(rem);
    bool useStem = rem > 0; // Use stem form if remainder exists

    String hText;
    if (hDigit == 1)
      hText = useStem ? _hundredStem : _hundred; // ას or ასი
    else
      hText = useStem
          ? "${_hundredsPrefix[hDigit]!}$_hundredStem"
          : "${_hundredsPrefix[hDigit]!}$_hundred"; // e.g., ორას or ორასი

    return remText.isEmpty ? hText : "$hText $remText";
  }

  /// Converts an integer between 0 and 99 into Georgian words (vigesimal system).
  ///
  /// @param n Integer chunk (0-99).
  /// @throws ArgumentError if [n] is outside 0-99.
  /// @return Chunk as Georgian words, or empty string if [n] is 0.
  String _convertUnder100(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 100) throw ArgumentError("Number must be 0-99: $n");
    if (n <= 19) return _units[n]!; // 1-19
    if (_tens.containsKey(n)) return _tens[n]!; // 20, 40, 60, 80

    int base; // Determine the vigesimal base
    if (n > 80)
      base = 80;
    else if (n > 60)
      base = 60;
    else if (n > 40)
      base = 40;
    else
      base = 20;

    int rem = n - base;
    String baseStem = _tensStems[base]!; // Get stem (e.g., ოც)
    String unitWord = _units[rem]!; // Get unit (1-19)
    return "$baseStemდა$unitWord"; // Combine stem + და + unit (e.g., ოცდაერთი)
  }
}
