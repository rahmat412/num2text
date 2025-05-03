import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ur_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ur}
/// Converts numbers to Urdu words (`Lang.UR`).
///
/// Implements [Num2TextBase] for Urdu. Handles `int`, `double`, `BigInt`, `Decimal`, `String`.
/// Supports cardinal numbers, decimals, negatives, currency (PKR default), years,
/// and the Indian numbering system (Lakh, Crore, etc.).
/// Customizable via [UrOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextUR implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "صفر";
  static const String _hundred = "سو";
  static const String _thousand = "ہزار";
  static const String _decimalPointWord = "اعشاریہ"; // For '.'
  static const String _decimalCommaWord = "کوما"; // For ',' (less common)
  static const String _infinity = "لامحدود";
  static const String _negativeInfinity = "منفی لامحدود";
  static const String _notANumber = "نمبر نہیں ہے";

  /// Scale words for the Indian numbering system (Lakh, Crore, etc.).
  /// Starts after thousand (10^3). Each step multiplies by 100.
  static const List<String> _scaleWordsIndian = [
    "لاکھ", // 10^5
    "کروڑ", // 10^7
    "ارب", // 10^9
    "کھرب", // 10^11
    "نیل", // 10^13
    "پدم", // 10^15
    "سنکھ", // 10^17
    "مہاسنکھ", // 10^19 (Rare)
    "انک", // 10^21 (Rare)
    "جلد", // 10^23 (Rare)
  ];

  /// Words for numbers 0-19.
  static const List<String> _wordsUnder20 = [
    "صفر",
    "ایک",
    "دو",
    "تین",
    "چار",
    "پانچ",
    "چھ",
    "سات",
    "آٹھ",
    "نو",
    "دس",
    "گیارہ",
    "بارہ",
    "تیرہ",
    "چودہ",
    "پندرہ",
    "سولہ",
    "سترہ",
    "اٹھارہ",
    "انیس",
  ];

  /// Unique words for compound numbers 20-99 in Urdu.
  static final Map<int, String> _compoundWords = {
    20: "بیس",
    21: "اکیس",
    22: "بائیس",
    23: "تیئس",
    24: "چوبیس",
    25: "پچیس",
    26: "چھبیس",
    27: "ستائیس",
    28: "اٹھائیس",
    29: "انتیس",
    30: "تیس",
    31: "اکتیس",
    32: "بتیس",
    33: "تینتیس",
    34: "چونتیس",
    35: "پینتیس",
    36: "چھتیس",
    37: "سینتیس",
    38: "اڑتیس",
    39: "انتالیس",
    40: "چالیس",
    41: "اکتالیس",
    42: "بیالیس",
    43: "تینتالیس",
    44: "چوالیس",
    45: "پینتالیس",
    46: "چھیالیس",
    47: "سینتالیس",
    48: "اڑتالیس",
    49: "انچاس",
    50: "پچاس",
    51: "اکاون",
    52: "باون",
    53: "ترپن",
    54: "چون",
    55: "پچپن",
    56: "چھپن",
    57: "ستاون",
    58: "اٹھاون",
    59: "انسٹھ",
    60: "ساٹھ",
    61: "اکسٹھ",
    62: "باسٹھ",
    63: "تریسٹھ",
    64: "چونسٹھ",
    65: "پینسٹھ",
    66: "چھیاسٹھ",
    67: "سڑسٹھ",
    68: "اڑسٹھ",
    69: "انہتر",
    70: "ستر",
    71: "اکہتر",
    72: "بہتر",
    73: "تہتر",
    74: "چوہتر",
    75: "پچھتر",
    76: "چھہتر",
    77: "ستتر",
    78: "اٹھتر",
    79: "اناسی",
    80: "اسی",
    81: "اکیاسی",
    82: "بیاسی",
    83: "تراسی",
    84: "چوراسی",
    85: "پچاسی",
    86: "چھیاسی",
    87: "ستاسی",
    88: "اٹھاسی",
    89: "نواسی",
    90: "نوے",
    91: "اکانوے",
    92: "بانوے",
    93: "ترانوے",
    94: "چورانوے",
    95: "پچانوے",
    96: "چھیانوے",
    97: "ستانوے",
    98: "اٹھانوے",
    99: "ننانوے",
  };

  /// Processes the given [number] into Urdu words.
  ///
  /// {@template num2text_process_intro_ur}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options_ur}
  /// Uses [UrOptions] for customization (currency, year format, decimals, AD/BC, rounding).
  /// Defaults apply if [options] is null or not [UrOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors_ur}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or default Urdu error message on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [UrOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Urdu words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final urOptions = options is UrOptions ? options : const UrOptions();
    final fallback = fallbackOnError ?? _notANumber;

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _negativeInfinity : _infinity;
      if (number.isNaN) return fallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return fallback;

    if (decimalValue == Decimal.zero) {
      return urOptions.currency
          ? "$_zero ${urOptions.currencyInfo.mainUnitPlural}" // Uses plural for zero currency
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    final BigInt integerPart =
        absValue.truncate().toBigInt(); // Pre-calculate for reuse

    String textResult;
    if (urOptions.format == Format.year) {
      textResult = _handleYearFormat(integerPart, isNegative, urOptions);
    } else if (urOptions.currency) {
      textResult = _handleCurrency(absValue, urOptions);
    } else {
      textResult = _handleStandardNumber(absValue, urOptions, integerPart);
    }

    // Prepend negative prefix if needed (handled within year format).
    if (isNegative && urOptions.format != Format.year) {
      textResult = "${urOptions.negativePrefix} $textResult";
    }

    return textResult.trim();
  }

  /// Converts an integer year to Urdu words, optionally adding era suffixes.
  /// Handles specific Urdu year formatting for 1100-1999 range.
  ///
  /// @param yearBigInt The integer part of the year.
  /// @param isNegative True if the original year was negative (BC).
  /// @param options Formatting options, including `includeAD`.
  /// @return The year as Urdu words.
  String _handleYearFormat(
      BigInt yearBigInt, bool isNegative, UrOptions options) {
    String yearText;
    // Use faster int conversion if possible.
    if (yearBigInt.isValidInt) {
      final int yearInt = yearBigInt.toInt();
      // Special format for years like 1999 -> "انیس سو ننانوے"
      if (!isNegative && yearInt >= 1100 && yearInt < 2000) {
        final int highPart = yearInt ~/ 100; // e.g., 19
        final int lowPart = yearInt % 100; // e.g., 99
        yearText = _convertChunk0to99(highPart); // "انیس"
        yearText += " $_hundred"; // " سو "
        if (lowPart > 0) {
          yearText += " ${_convertChunk0to99(lowPart)}"; // " ننانوے"
        }
      } else {
        // Convert other years normally.
        yearText = _convertIntegerPart(yearBigInt);
      }
    } else {
      // Handle years outside int range using BigInt logic.
      yearText = _convertIntegerPart(yearBigInt);
    }

    // Append era suffixes.
    if (isNegative) {
      yearText += " قبل مسیح"; // BC
    } else if (options.includeAD) {
      yearText += " عیسوی"; // AD
    }
    return yearText;
  }

  /// Converts a non-negative [Decimal] to Urdu currency words.
  /// Uses [UrOptions.currencyInfo] for unit names (Rupee/Paisa). Rounds if specified.
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Urdu words.
  String _handleCurrency(Decimal absValue, UrOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final Decimal val = options.round ? absValue.round(scale: 2) : absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    final BigInt subVal = ((val - val.truncate()).abs() * Decimal.fromInt(100))
        .round(scale: 0)
        .toBigInt();

    String mainPart = "";
    if (mainVal > BigInt.zero) {
      final String name = (mainVal == BigInt.one)
          ? info.mainUnitSingular
          : info.mainUnitPlural!;
      mainPart = '${_convertIntegerPart(mainVal)} $name';
    }

    String subPart = "";
    if (subVal > BigInt.zero && info.subUnitSingular != null) {
      final String name =
          (subVal == BigInt.one) ? info.subUnitSingular! : info.subUnitPlural!;
      subPart = '${_convertIntegerPart(subVal)} $name';
    }

    if (mainPart.isNotEmpty && subPart.isNotEmpty) {
      String sep = info.separator ?? "";
      if (sep.isNotEmpty) sep = " $sep ";
      return '$mainPart$sep$subPart';
    } else if (mainPart.isNotEmpty) {
      return mainPart;
    } else if (subPart.isNotEmpty) {
      return subPart; // Only subunits (e.g., "پچاس پیسے")
    } else {
      // Zero value after potential rounding.
      return "$_zero ${info.mainUnitPlural!}";
    }
  }

  /// Converts a non-negative standard [Decimal] number to Urdu words.
  /// Converts integer and fractional parts. Uses [UrOptions.decimalSeparator] word.
  /// Fractional part converted digit by digit.
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @param integerPart Pre-calculated integer part.
  /// @return Number as Urdu words.
  String _handleStandardNumber(
      Decimal absValue, UrOptions options, BigInt integerPart) {
    // Use "zero" for integer part if it's 0 but a fraction exists (e.g., 0.5).
    final String integerWords =
        (integerPart == BigInt.zero && absValue > Decimal.zero)
            ? _zero
            : _convertIntegerPart(integerPart);

    String fractionalWords = '';
    final Decimal fractionalPart = (absValue - absValue.truncate()).abs();
    if (fractionalPart > Decimal.zero) {
      String sepWord;
      switch (options.decimalSeparator ?? DecimalSeparator.period) {
        // Default to period
        case DecimalSeparator.comma:
          sepWord = _decimalCommaWord;
          break;
        default:
          sepWord = _decimalPointWord;
          break;
      }

      final String fracDigits = absValue.toString().split('.').last;
      final List<String> digitWords = fracDigits.split('').map((d) {
        final int? i = int.tryParse(d);
        // Convert digits 0-9.
        return (i != null && i >= 0 && i <= 9) ? _wordsUnder20[i] : '?';
      }).toList();
      fractionalWords = ' $sepWord ${digitWords.join(' ')}';
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer using the Indian numbering system (Lakh, Crore).
  /// Groups into chunks (999, then 99, then 99 for scales).
  ///
  /// @param n Non-negative integer.
  /// @return Integer as Urdu words. Returns "صفر" for 0.
  String _convertIntegerPart(BigInt n) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");

    final BigInt hundred = BigInt.from(100);
    final BigInt thousand = BigInt.from(1000);
    final List<String> parts = [];
    BigInt rem = n;

    // 1. Process base chunk (0-999).
    final int baseChunk = (rem % thousand).toInt();
    if (baseChunk > 0) parts.add(_convertChunk0to999(baseChunk));
    rem ~/= thousand;

    // 2. Process thousands chunk (0-99).
    if (rem > BigInt.zero) {
      final int thousandChunk =
          (rem % hundred).toInt(); // Thousands chunk is 0-99
      if (thousandChunk > 0)
        parts.add("${_convertChunk0to99(thousandChunk)} $_thousand");
      rem ~/= hundred;
    }

    // 3. Process higher scale chunks (Lakh, Crore...) using chunks of 100.
    int scaleIdx = 0;
    while (rem > BigInt.zero) {
      if (scaleIdx >= _scaleWordsIndian.length)
        break; // Stop if number exceeds defined scales
      final int chunk = (rem % hundred).toInt();
      if (chunk > 0) {
        parts
            .add("${_convertChunk0to99(chunk)} ${_scaleWordsIndian[scaleIdx]}");
      }
      rem ~/= hundred;
      scaleIdx++;
    }

    // Join parts from highest scale down (lowest added first).
    return parts.reversed.join(' ');
  }

  /// Converts an integer from 0 to 999 into Urdu words.
  /// Handles hundreds place and the remaining 0-99 part.
  ///
  /// @param n Number (0-999).
  /// @return Urdu text. Returns empty string for 0.
  /// @throws ArgumentError if n is outside 0-999.
  String _convertChunk0to999(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    final List<String> words = [];
    int rem = n;

    // Hundreds part.
    if (rem >= 100) {
      words.add(_wordsUnder20[rem ~/ 100]); // Word for 1-9
      words.add(_hundred);
      rem %= 100;
    }
    // Remaining 0-99 part.
    if (rem > 0) {
      words.add(_convertChunk0to99(rem));
    }
    return words.join(' ');
  }

  /// Converts an integer from 0 to 99 into Urdu words using lookup tables.
  ///
  /// @param n Number (0-99).
  /// @return Urdu text. Returns empty string for 0.
  /// @throws ArgumentError if n is outside 0-99.
  String _convertChunk0to99(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 100) throw ArgumentError("Sub-chunk must be 0-99: $n");
    if (n < 20) return _wordsUnder20[n];
    return _compoundWords[n] ?? "?"; // Lookup in compound map
  }
}
