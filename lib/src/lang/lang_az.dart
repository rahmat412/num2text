import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/az_options.dart';
import '../options/base_options.dart';
import '../utils/utils.dart';

/// {@template num2text_az}
/// Converts numbers to Azerbaijani words (`Lang.AZ`).
///
/// Implements [Num2TextBase] for Azerbaijani, handling various numeric types.
/// Supports cardinal numbers, decimals, negatives, currency, years, and large numbers (short scale).
/// Azerbaijani conversion is relatively regular, without complex gender/case agreement.
/// Customizable via [AzOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextAZ implements Num2TextBase {
  // --- Constants ---
  static const String _minusCapital =
      "Mənfi"; // Capitalized for Negative Infinity
  static const String _zero = "sıfır";
  static const String _point = "nöqtə"; // Decimal separator (.)
  static const String _comma = "vergül"; // Decimal separator (,)
  static const String _one = "bir";
  static const String _hundred = "yüz";
  static const String _thousand = "min";
  static const String _yearSuffixBC = "e.ə."; // Before our era
  static const String _yearSuffixAD = "e."; // Of our era
  static const String _infinity = "Sonsuzluq";
  static const String _notANumber = "Ədəd Deyil"; // Default fallback

  static const List<String> _wordsUnder20 = [
    "sıfır",
    "bir",
    "iki",
    "üç",
    "dörd",
    "beş",
    "altı",
    "yeddi",
    "səkkiz",
    "doqquz",
    "on",
    "on bir",
    "on iki",
    "on üç",
    "on dörd",
    "on beş",
    "on altı",
    "on yeddi",
    "on səkkiz",
    "on doqquz",
  ];
  static const List<String> _wordsTens = [
    "",
    "",
    "iyirmi",
    "otuz",
    "qırx",
    "əlli",
    "altmış",
    "yetmiş",
    "səksən",
    "doxsan",
  ];
  static const List<String> _scaleWords = [
    // Short scale (powers of 1000)
    "", "min", "milyon", "milyard", "trilyon", "kvadrilyon", "kvintilyon",
    "sekstilyon", "septilyon",
  ];

  /// Processes the given [number] into Azerbaijani words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [AzOptions] for customization (currency, year, decimals, AD/BC).
  /// Defaults apply if [options] is null or not [AzOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or default error string on failure.
  /// {@endtemplate}
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final AzOptions azOptions =
        options is AzOptions ? options : const AzOptions();
    final String errorFallback = fallbackOnError ?? _notANumber;

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "$_minusCapital $_infinity" : _infinity;
      if (number.isNaN) return errorFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    if (decimalValue == Decimal.zero) {
      return azOptions.currency
          ? "$_zero ${azOptions.currencyInfo.mainUnitSingular}"
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    if (azOptions.format == Format.year) {
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), azOptions);
    } else {
      textResult = azOptions.currency
          ? _handleCurrency(absValue, azOptions)
          : _handleStandardNumber(absValue, azOptions);
      if (isNegative) {
        textResult = "${azOptions.negativePrefix} $textResult";
      }
    }
    return textResult.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Converts an integer year to Azerbaijani words, adding AD/BC suffix if needed.
  String _handleYearFormat(int year, AzOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;
    String yearText = _convertInteger(BigInt.from(absYear));

    if (isNegative)
      yearText += " $_yearSuffixBC";
    else if (options.includeAD && absYear > 0) yearText += " $_yearSuffixAD";

    return yearText;
  }

  /// Converts a decimal currency value to Azerbaijani words with units.
  String _handleCurrency(Decimal absValue, AzOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final Decimal val = options.round ? absValue.round(scale: 2) : absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    final BigInt subVal =
        ((val - val.truncate()) * Decimal.fromInt(100)).round().toBigInt();

    String mainPart = "";
    if (mainVal > BigInt.zero) {
      mainPart = '${_convertInteger(mainVal)} ${info.mainUnitSingular}';
    } else if (mainVal == BigInt.zero && subVal == BigInt.zero) {
      return '$_zero ${info.mainUnitSingular}'; // Handle 0.00 case
    }

    String subPart = "";
    if (subVal > BigInt.zero && info.subUnitSingular != null) {
      subPart = '${_convertInteger(subVal)} ${info.subUnitSingular!}';
    }

    if (mainPart.isNotEmpty && subPart.isNotEmpty) {
      return '$mainPart${info.separator ?? " "}$subPart';
    } else {
      return mainPart.isNotEmpty
          ? mainPart
          : subPart; // Return whichever part exists
    }
  }

  /// Converts a standard decimal number to Azerbaijani words.
  String _handleStandardNumber(Decimal absValue, AzOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero && !absValue.isInteger) {
      String separatorWord =
          (options.decimalSeparator == DecimalSeparator.point ||
                  options.decimalSeparator == DecimalSeparator.period)
              ? _point
              : _comma;
      String decimalString = absValue.toString();
      String fractionalDigits =
          decimalString.contains('.') ? decimalString.split('.').last : '';
      fractionalDigits = fractionalDigits.replaceAll(
          RegExp(r'0+$'), ''); // Trim trailing zeros

      if (fractionalDigits.isNotEmpty) {
        List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder20[digitInt]
              : '?';
        }).toList();
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }
    return '$integerWords$fractionalWords';
  }

  /// Converts a non-negative integer to Azerbaijani words.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) throw ArgumentError("Negative input: $n");
    if (n < BigInt.from(1000)) return _convertChunk(n.toInt());

    List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0;
    BigInt remaining = n;

    while (remaining > BigInt.zero) {
      if (scaleIndex >= _scaleWords.length)
        throw ArgumentError("Number too large: $n");
      final int chunk = (remaining % oneThousand).toInt();
      remaining ~/= oneThousand;

      if (chunk > 0) {
        String chunkText = _convertChunk(chunk);
        String scaleWord = scaleIndex > 0 ? _scaleWords[scaleIndex] : "";
        String combinedPart;
        if (scaleWord.isNotEmpty) {
          // Handle "bir min" -> "min"
          if (chunk == 1 && scaleWord == _thousand)
            combinedPart = scaleWord;
          // Handle "bir milyon" etc.
          else if (chunk == 1)
            combinedPart = "$_one $scaleWord";
          else
            combinedPart = "$chunkText $scaleWord";
        } else {
          combinedPart = chunkText;
        }
        parts.insert(0, combinedPart);
      }
      scaleIndex++;
    }
    return parts.join(' ');
  }

  /// Converts an integer 0-999 to Azerbaijani words.
  String _convertChunk(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    List<String> words = [];
    int remainder = n;

    if (remainder >= 100) {
      int hundredDigit = remainder ~/ 100;
      // Add digit only if > 1 (e.g., "iki yüz", not "bir yüz")
      if (hundredDigit > 1) words.add(_wordsUnder20[hundredDigit]);
      words.add(_hundred);
      remainder %= 100;
    }

    if (remainder > 0) {
      if (remainder < 20)
        words.add(_wordsUnder20[remainder]);
      else {
        words.add(_wordsTens[remainder ~/ 10]); // Add tens word
        if (remainder % 10 > 0)
          words.add(_wordsUnder20[remainder % 10]); // Add unit word
      }
    }
    return words.join(' ');
  }
}
