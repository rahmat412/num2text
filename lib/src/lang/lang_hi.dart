import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/hi_options.dart';
import '../utils/utils.dart';

/// {@template num2text_hi}
/// Converts numbers to Hindi words (`Lang.HI`).
///
/// Implements [Num2TextBase] for Hindi using the Indian numbering system (Lakh, Crore).
/// Handles cardinals, decimals, negatives, currency, years, and large numbers.
/// Customizable via [HiOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextHI implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "शून्य";
  static const String _point = "दशमलव";
  static const String _comma =
      "अल्पविराम"; // Less common decimal separator word
  static const String _and = "और"; // Currency separator
  static const String _hundred = "सौ";
  static const String _thousand = "हज़ार";
  static const String _lakh = "लाख"; // 10^5
  static const String _crore = "करोड़"; // 10^7
  static const String _arab = "अरब"; // 10^9
  static const String _kharab = "खरब"; // 10^11
  static const String _neel = "नील"; // 10^13
  static const String _padma = "पद्म"; // 10^15
  static const String _shankh = "शंख"; // 10^17
  static const String _yearSuffixBC = "ईसा पूर्व";
  static const String _yearSuffixAD = "ईस्वी";

  static final BigInt _bigInt100 = BigInt.from(100);
  static final BigInt _bigInt1000 = BigInt.from(1000);

  /// Words for numbers 0 to 99.
  static const List<String> _wordsUnder100 = [
    "शून्य",
    "एक",
    "दो",
    "तीन",
    "चार",
    "पाँच",
    "छह",
    "सात",
    "आठ",
    "नौ",
    "दस",
    "ग्यारह",
    "बारह",
    "तेरह",
    "चौदह",
    "पंद्रह",
    "सोलह",
    "सत्रह",
    "अठारह",
    "उन्नीस",
    "बीस",
    "इक्कीस",
    "बाईस",
    "तेईस",
    "चौबीस",
    "पच्चीस",
    "छब्बीस",
    "सत्ताईस",
    "अट्ठाईस",
    "उनतीस",
    "तीस",
    "इकतीस",
    "बत्तीस",
    "तैंतीस",
    "चौंतीस",
    "पैंतीस",
    "छत्तीस",
    "सैंतीस",
    "अड़तीस",
    "उनतालीस",
    "चालीस",
    "इकतालीस",
    "बयालीस",
    "तैंतालीस",
    "चौवालीस",
    "पैंतालीस",
    "छियालीस",
    "सैंतालीस",
    "अड़तालीस",
    "उनचास",
    "पचास",
    "इक्यावन",
    "बावन",
    "तिरपन",
    "चौवन",
    "पचपन",
    "छप्पन",
    "सत्तावन",
    "अट्ठावन",
    "उनसठ",
    "साठ",
    "इकसठ",
    "बासठ",
    "तिरसठ",
    "चौंसठ",
    "पैंसठ",
    "छियासठ",
    "सड़सठ",
    "अड़सठ",
    "उनहत्तर",
    "सत्तर",
    "इकहत्तर",
    "बहत्तर",
    "तिहत्तर",
    "चौहत्तर",
    "पचहत्तर",
    "छिहत्तर",
    "सतहत्तर",
    "अठहत्तर",
    "उन्यासी",
    "अस्सी",
    "इक्यासी",
    "बयासी",
    "तिरासी",
    "चौरासी",
    "पचासी",
    "छियासी",
    "सतासी",
    "अट्ठासी",
    "नवासी",
    "नब्बे",
    "इक्यानबे",
    "बानबे",
    "तिरानबे",
    "चौरानबे",
    "पंचानबे",
    "छियानवे",
    "सत्तानबे",
    "अठ्ठानवे",
    "निन्यानवे",
  ];

  /// Processes the given number into Hindi words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [HiOptions] for customization (currency, year format, decimals, AD/BC, rounding).
  /// Defaults apply if [options] is null or not [HiOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or "अमान्य संख्या" on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [HiOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Hindi words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final HiOptions hiOptions =
        options is HiOptions ? options : const HiOptions();
    final String defaultFallback = "अमान्य संख्या";

    if (number is double) {
      if (number.isInfinite) return number.isNegative ? "ऋण अनंत" : "अनंत";
      if (number.isNaN) return fallbackOnError ?? defaultFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return fallbackOnError ?? defaultFallback;

    if (decimalValue == Decimal.zero) {
      if (hiOptions.currency) {
        final String unit = hiOptions.currencyInfo.mainUnitPlural ??
            hiOptions.currencyInfo.mainUnitSingular;
        return "$_zero $unit";
      } else {
        return _zero;
      }
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    if (hiOptions.format == Format.year) {
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), hiOptions);
    } else {
      textResult = hiOptions.currency
          ? _handleCurrency(absValue, hiOptions)
          : _handleStandardNumber(absValue, hiOptions);
      if (isNegative) {
        textResult = "${hiOptions.negativePrefix} $textResult";
      }
    }
    return textResult.trim();
  }

  /// Converts an integer to Hindi words for calendar years.
  ///
  /// Appends BC/AD suffixes based on sign and [HiOptions.includeAD].
  /// Handles special cases like 1900 -> "उन्नीस सौ".
  ///
  /// @param year The integer year.
  /// @param options Formatting options.
  /// @return The year as Hindi words.
  String _handleYearFormat(int year, HiOptions options) {
    if (year == 0) return _zero;
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;
    final BigInt bigAbsYear = BigInt.from(absYear);

    String yearText;
    if (absYear >= 1100 && absYear < 2000 && absYear % 100 == 0) {
      final int highPart = absYear ~/ 100;
      yearText = (highPart > 10 && highPart < 100)
          ? "${_wordsUnder100[highPart]} $_hundred" // e.g., उन्नीस सौ
          : _convertInteger(bigAbsYear); // Fallback
    } else {
      yearText = _convertInteger(bigAbsYear);
    }

    if (isNegative)
      yearText += " $_yearSuffixBC";
    else if (options.includeAD) yearText += " $_yearSuffixAD";

    return yearText;
  }

  /// Converts a non-negative [Decimal] to Hindi currency words.
  ///
  /// Uses [HiOptions.currencyInfo] for unit names ("रुपया"/"रुपये", "पैसा"/"पैसे").
  /// Rounds if [HiOptions.round] is true. Separates main and subunits.
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Hindi words.
  String _handleCurrency(Decimal absValue, HiOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final Decimal val = options.round ? absValue.round(scale: 2) : absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    final BigInt subVal = ((val - mainVal.toDecimal()) * Decimal.fromInt(100))
        .round(scale: 0)
        .toBigInt();

    String mainText = "";
    String mainUnit = "";
    if (mainVal > BigInt.zero) {
      mainText = _convertInteger(mainVal);
      mainUnit = (mainVal == BigInt.one)
          ? info.mainUnitSingular
          : (info.mainUnitPlural ?? info.mainUnitSingular);
    } else if (mainVal == BigInt.zero && subVal == BigInt.zero) {
      // Handle 0.00
      mainText = _zero;
      mainUnit = info.mainUnitPlural ?? info.mainUnitSingular;
    }

    String subText = "";
    String subUnit = "";
    String sep = "";
    if (subVal > BigInt.zero &&
        info.subUnitSingular != null &&
        info.subUnitPlural != null) {
      subText = _convertInteger(subVal);
      subUnit =
          (subVal == BigInt.one) ? info.subUnitSingular! : info.subUnitPlural!;
      if (mainVal > BigInt.zero) {
        sep = info.separator ?? _and;
      }
    }

    if (mainVal == BigInt.zero && subVal > BigInt.zero) {
      return '$subText $subUnit'.trim(); // Handle 0.xx case
    }

    List<String> parts = [];
    if (mainText.isNotEmpty) parts.addAll([mainText, mainUnit]);
    if (sep.isNotEmpty) parts.add(sep);
    if (subText.isNotEmpty) parts.addAll([subText, subUnit]);

    return parts.join(" ").trim();
  }

  /// Converts a non-negative standard [Decimal] number to Hindi words.
  ///
  /// Converts integer and fractional parts. Uses [HiOptions.decimalSeparator] word ("दशमलव").
  /// Fractional part converted digit by digit.
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Hindi words.
  String _handleStandardNumber(Decimal absValue, HiOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - integerPart.toDecimal();
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      String sepWord;
      switch (options.decimalSeparator ?? DecimalSeparator.period) {
        case DecimalSeparator.comma:
          sepWord = _comma;
          break;
        default:
          sepWord = _point;
          break;
      }

      String fracDigits =
          absValue.toString().split('.').last.replaceAll(RegExp(r'0+$'), '');
      if (fracDigits.isNotEmpty) {
        final List<String> digitWords = fracDigits.split('').map((d) {
          final int? i = int.tryParse(d);
          return (i != null && i >= 0 && i <= 9) ? _wordsUnder100[i] : '?';
        }).toList();
        fractionalWords = ' $sepWord ${digitWords.join(' ')}';
      }
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] into Hindi words using the Indian numbering system.
  ///
  /// Recursive function handling scales: Thousand, Lakh, Crore, Arab, Kharab, Neel, Padma, Shankh.
  ///
  /// @param n Non-negative integer.
  /// @throws ArgumentError if [n] is negative.
  /// @return Integer as Hindi words.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n == BigInt.zero) return _zero;
    if (n < _bigInt100) return _convertTensUnits(n.toInt());
    if (n < _bigInt1000) return _convertHundredsTensUnits(n.toInt());

    final List<(BigInt, String)> scales = [
      (BigInt.parse('100000000000000000'), _shankh), // 10^17
      (BigInt.parse('1000000000000000'), _padma), // 10^15
      (BigInt.parse('10000000000000'), _neel), // 10^13
      (BigInt.parse('100000000000'), _kharab), // 10^11
      (BigInt.parse('1000000000'), _arab), // 10^9
      (BigInt.parse('10000000'), _crore), // 10^7
      (BigInt.parse('100000'), _lakh), // 10^5
      (_bigInt1000, _thousand), // 10^3
    ];

    List<String> parts = [];
    BigInt rem = n;
    for (final (power, name) in scales) {
      if (rem >= power) {
        final BigInt amount = rem ~/ power;
        parts.add('${_convertInteger(amount)} $name'); // Recursive call
        rem %= power;
      }
    }
    if (rem > BigInt.zero) {
      parts.add(_convertHundredsTensUnits(rem.toInt()));
    }
    return parts.join(" ").trim();
  }

  /// Converts an integer between 0 and 999 into Hindi words.
  ///
  /// Uses [_convertTensUnits] for numbers below 100. Handles hundreds place.
  ///
  /// @param n Integer 0-999.
  /// @return Chunk as Hindi words.
  String _convertHundredsTensUnits(int n) {
    if (n < 0 || n > 999) return "";
    if (n < 100) return _convertTensUnits(n);

    final int hundreds = n ~/ 100;
    final int remainder = n % 100;
    final String hText = "${_wordsUnder100[hundreds]} $_hundred";
    return remainder > 0 ? "$hText ${_convertTensUnits(remainder)}" : hText;
  }

  /// Converts an integer between 0 and 99 into Hindi words using lookup table.
  ///
  /// @param n Integer 0-99.
  /// @return Number as Hindi words.
  String _convertTensUnits(int n) {
    if (n < 0 || n > 99) return "";
    return _wordsUnder100[n];
  }
}
