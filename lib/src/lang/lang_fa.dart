import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/fa_options.dart';
import '../utils/utils.dart';

/// {@template num2text_fa}
/// Converts numbers to Persian (Farsi) words (`Lang.FA`).
///
/// Implements [Num2TextBase] for Persian, handling cardinal numbers, decimals
/// (digit-by-digit after "ممیز"), negatives, currency (integer part only, e.g., Rial),
/// and years (with AD/BC suffix option). Uses [FaOptions] for customization.
/// {@endtemplate}
class Num2TextFA implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "صفر";
  static const String _point = "ممیز"; // Decimal separator word
  static const String _and = " و "; // Conjunction "and"
  static const String _yearSuffixBC = "پیش از میلاد";
  static const String _yearSuffixAD = "میلادی";
  static const String _defaultNaN = "عدد نیست"; // Default error fallback

  static const List<String> _wordsUnder20 = [
    "صفر",
    "یک",
    "دو",
    "سه",
    "چهار",
    "پنج",
    "شش",
    "هفت",
    "هشت",
    "نه",
    "ده",
    "یازده",
    "دوازده",
    "سیزده",
    "چهارده",
    "پانزده",
    "شانزده",
    "هفده",
    "هجده",
    "نوزده",
  ];
  static const List<String> _wordsTens = [
    "",
    "",
    "بیست",
    "سی",
    "چهل",
    "پنجاه",
    "شصت",
    "هفتاد",
    "هشتاد",
    "نود",
  ];
  static const List<String> _wordsHundreds = [
    "",
    "صد",
    "دویست",
    "سیصد",
    "چهارصد",
    "پانصد",
    "ششصد",
    "هفتصد",
    "هشتصد",
    "نهصد",
  ];
  static const Map<int, String> _scaleWords = {
    // Short scale
    0: "", 1: "هزار", 2: "میلیون", 3: "میلیارد", 4: "تریلیون",
    5: "کوادریلیون", 6: "کوئینتیلیون", 7: "سکستیلیون", 8: "سپتیلیون",
  };

  /// Processes the given [number] into Persian words.
  ///
  /// {@macro num2text_process_intro}
  /// {@template num2text_fa_process_options}
  /// Uses [FaOptions] for customization (currency, year format, decimals, negative prefix, AD/BC).
  /// {@endtemplate}
  /// {@template num2text_fa_process_errors}
  /// Handles `Infinity` ("بی نهایت"), `NaN`. Returns [fallbackOnError] or "عدد نیست" on failure.
  /// {@endtemplate}
  /// @param number The number to convert.
  /// @param options Optional [FaOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Persian words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final FaOptions faOptions =
        options is FaOptions ? options : const FaOptions();
    final String errorMsg = fallbackOnError ?? _defaultNaN;

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "منفی بی نهایت" : "بی نهایت";
      if (number.isNaN) return errorMsg;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorMsg;

    if (decimalValue == Decimal.zero) {
      return faOptions.currency
          ? "$_zero ${faOptions.currencyInfo.mainUnitSingular}"
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    if (faOptions.format == Format.year) {
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), faOptions);
    } else {
      textResult = faOptions.currency
          ? _handleCurrency(absValue, faOptions)
          : _handleStandardNumber(absValue, faOptions);
      if (isNegative) {
        textResult = "${faOptions.negativePrefix} $textResult";
      }
    }
    return textResult.trim();
  }

  /// Converts an integer year to Persian words with optional era suffixes.
  /// Omits "یک" for years 1000-1999 (e.g., "هزار و نهصد").
  /// @param yearValue The integer year.
  /// @param options Persian options for `includeAD`.
  /// @return The year as Persian words.
  String _handleYearFormat(BigInt yearValue, FaOptions options) {
    final bool isNegative = yearValue.isNegative;
    final BigInt absYear = isNegative ? -yearValue : yearValue;
    if (absYear == BigInt.zero) return _zero;

    // Use special year logic in integer conversion if needed.
    String yearText =
        _convertInteger(absYear, isYear: true, originalN: yearValue);

    if (isNegative)
      yearText += " $_yearSuffixBC";
    else if (options.includeAD) yearText += " $_yearSuffixAD";

    return yearText;
  }

  /// Converts a [Decimal] to Persian currency words (integer part only).
  /// Appends the main unit name (e.g., "ریال"). Subunits are ignored.
  /// @param absValue Absolute currency value.
  /// @param options Persian options containing currency info.
  /// @return Currency value (integer part) as Persian words.
  String _handleCurrency(Decimal absValue, FaOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final BigInt mainValue = absValue.truncate().toBigInt();
    final String mainText = _convertInteger(mainValue);
    return '$mainText ${info.mainUnitSingular}';
  }

  /// Converts a standard [Decimal] number to Persian words.
  /// Fractional part read digit-by-digit after "ممیز". Trims trailing zeros.
  /// @param absValue Absolute decimal value.
  /// @param options Persian options (unused here, decimal separator is fixed).
  /// @return Number as Persian words.
  String _handleStandardNumber(Decimal absValue, FaOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      String decStr = absValue.toString();
      int pointIdx = decStr.indexOf('.');
      if (pointIdx != -1) {
        String fracDigits = decStr.substring(pointIdx + 1);
        while (fracDigits.endsWith('0') && fracDigits.length > 1) {
          // Trim trailing zeros
          fracDigits = fracDigits.substring(0, fracDigits.length - 1);
        }
        if (fracDigits.isNotEmpty) {
          final List<String> digitWords = fracDigits.split('').map((d) {
            final int? i = int.tryParse(d);
            return (i != null && i >= 0 && i <= 9) ? _wordsUnder20[i] : '?';
          }).toList();
          fractionalWords =
              ' $_point ${digitWords.join(' ')}'; // " ممیز چهار پنج"
        }
      }
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] into Persian words using scale words.
  /// Handles the special case for years 1000-1999 if `isYear` is true.
  /// @param n Non-negative integer.
  /// @param isYear Flag for year formatting special case.
  /// @param originalN Original year value (needed for year special case).
  /// @throws ArgumentError if n is negative or exceeds defined scales.
  /// @return Integer as Persian words.
  String _convertInteger(BigInt n, {bool isYear = false, BigInt? originalN}) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n < BigInt.from(1000)) return _convertChunk(n.toInt());

    final List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIdx = 0;
    BigInt rem = n;

    while (rem > BigInt.zero) {
      final int chunk = (rem % oneThousand).toInt();
      rem ~/= oneThousand;
      if (chunk > 0) {
        String chunkText = _convertChunk(chunk);
        String scaleWord = "";
        bool isOneThousandChunk = false;

        if (scaleIdx > 0) {
          if (!_scaleWords.containsKey(scaleIdx))
            throw ArgumentError("Number too large");
          scaleWord = _scaleWords[scaleIdx]!;
          isOneThousandChunk = (scaleIdx == 1 && chunk == 1);
        }

        // Special case for years 1000-1999: Omit "یک" before "هزار"
        if (isYear &&
            isOneThousandChunk &&
            rem == BigInt.zero &&
            originalN != null &&
            originalN.abs() >= BigInt.from(1000) &&
            originalN.abs() < BigInt.from(2000)) {
          chunkText = ""; // Clear "یک"
        }

        String currentPart = chunkText;
        if (scaleWord.isNotEmpty) {
          currentPart += (currentPart.isNotEmpty ? " " : "") + scaleWord;
        }
        if (parts.isNotEmpty && currentPart.isNotEmpty) parts.add(_and);
        if (currentPart.isNotEmpty) parts.add(currentPart);
      }
      scaleIdx++;
    }
    return parts.reversed.join('');
  }

  /// Converts an integer from 0 to 999 into Persian words.
  /// Uses " و " as a conjunction between hundreds, tens, and units.
  /// @param n Integer chunk (0-999).
  /// @throws ArgumentError if n is outside 0-999.
  /// @return Chunk as Persian words.
  String _convertChunk(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    final List<String> words = [];
    int rem = n;
    final int hundreds = rem ~/ 100;
    if (hundreds > 0) {
      words.add(_wordsHundreds[hundreds]);
      rem %= 100;
    }
    if (rem > 0) {
      if (words.isNotEmpty) words.add(_and);
      if (rem < 20)
        words.add(_wordsUnder20[rem]);
      else {
        final int tens = rem ~/ 10;
        final int unit = rem % 10;
        words.add(_wordsTens[tens]);
        if (unit > 0) {
          words.add(_and);
          words.add(_wordsUnder20[unit]);
        }
      }
    }
    return words.join('');
  }
}
