import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ha_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ha}
/// Converts numbers to Hausa words (`Lang.HA`).
///
/// Implements [Num2TextBase] for Hausa, handling various numeric types.
/// Supports cardinal numbers, decimals, negatives, currency, years.
/// Customizable via [HaOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextHA implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "sifili";
  static const String _point = "digo"; // Decimal separator '.'
  static const String _comma = "waƙafi"; // Decimal separator ','
  static const String _and = "da"; // Connector "and"
  static const String _hundred = "ɗari";
  static const String _yearSuffixBC = "BC"; // Common abbreviation used
  static const String _yearSuffixAD = "AD"; // Common abbreviation used
  static const String _infinity = "Madawwami";
  static const String _negativeInfinity = "Korau Madawwami";
  static const String _notANumber = "Ba Lamba Ba";

  // 0-9
  static const List<String> _wordsUnder10 = [
    "sifili",
    "ɗaya",
    "biyu",
    "uku",
    "huɗu",
    "biyar",
    "shida",
    "bakwai",
    "takwas",
    "tara",
  ];
  // 10, 20, ..., 90
  static const List<String> _wordsTens = [
    "",
    "goma",
    "ashirin",
    "talatin",
    "arba'in",
    "hamsin",
    "sittin",
    "saba'in",
    "tamanin",
    "casa'in",
  ];
  // Scale words by index (0=units, 1=thousands...)
  static const Map<int, String> _scaleWords = {
    0: "",
    1: "dubu",
    2: "miliyan",
    3: "biliyan",
    4: "tiriliyan",
    5: "kwadiriliyan",
    6: "kwintiliyan",
    7: "sistiliyan",
    8: "septiliyan",
  };

  /// {@macro num2text_base_process}
  /// Converts the given [number] into Hausa words.
  /// Uses [HaOptions] for customization (currency, year, decimals, AD/BC).
  /// Returns fallback string on error (e.g., "Ba Lamba Ba").
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final HaOptions haOptions =
        options is HaOptions ? options : const HaOptions();
    final String errorFallback = fallbackOnError ?? _notANumber;

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _negativeInfinity : _infinity;
      if (number.isNaN) return errorFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    if (decimalValue == Decimal.zero) {
      if (haOptions.currency) {
        final String unit = haOptions.currencyInfo.mainUnitPlural ??
            haOptions.currencyInfo.mainUnitSingular;
        return "$unit $_zero"; // e.g., "Naira sifili"
      }
      return _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    if (haOptions.format == Format.year) {
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), haOptions);
    } else {
      textResult = haOptions.currency
          ? _handleCurrency(absValue, haOptions)
          : _handleStandardNumber(absValue, haOptions);
      if (isNegative) {
        textResult = "${haOptions.negativePrefix} $textResult";
      }
    }
    return textResult.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Formats an integer year as Hausa words, optionally adding BC/AD.
  String _handleYearFormat(int year, HaOptions options) {
    final bool isNegative = year < 0;
    final BigInt absYearBigInt = BigInt.from(year.abs());
    if (absYearBigInt == BigInt.zero) return _zero;

    String yearText = _convertInteger(absYearBigInt);

    if (isNegative)
      yearText += " $_yearSuffixBC";
    else if (options.includeAD) yearText += " $_yearSuffixAD";

    return yearText;
  }

  /// Formats a non-negative [Decimal] as Hausa currency words.
  String _handleCurrency(Decimal absValue, HaOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final Decimal val = options.round ? absValue.round(scale: 2) : absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    final BigInt subVal = ((val - val.truncate()).abs() * Decimal.parse("100"))
        .truncate()
        .toBigInt();

    String mainPart = "";
    if (mainVal > BigInt.zero) {
      String mainText = _convertInteger(mainVal);
      String mainName =
          info.mainUnitSingular; // Plural name not typically used before number
      mainPart = '$mainName $mainText';
    }

    String subPart = "";
    if (subVal > BigInt.zero && info.subUnitSingular != null) {
      String subText = _convertInteger(subVal);
      String subName = info.subUnitSingular!;
      subPart = '$subName $subText';
    }

    if (mainPart.isNotEmpty && subPart.isNotEmpty) {
      final String sep = info.separator ?? _and;
      return '$mainPart $sep $subPart';
    } else if (mainPart.isNotEmpty)
      return mainPart;
    else if (subPart.isNotEmpty)
      return subPart;
    else {
      // Zero case handled in process, but defensive return
      final String unit = info.mainUnitPlural ?? info.mainUnitSingular;
      return "$unit $_zero";
    }
  }

  /// Formats a non-negative standard [Decimal] number into Hausa words.
  /// Fractional part read digit-by-digit after "digo" or "waƙafi".
  String _handleStandardNumber(Decimal absValue, HaOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      final String sepWord;
      switch (options.decimalSeparator ?? DecimalSeparator.point) {
        case DecimalSeparator.comma:
          sepWord = _comma;
          break;
        default:
          sepWord = _point;
          break;
      }

      String digits = absValue.toString().split('.').last;
      while (digits.endsWith('0') && digits.length > 1) {
        // Trim trailing zeros
        digits = digits.substring(0, digits.length - 1);
      }

      if (digits.isNotEmpty) {
        List<String> digitWords = digits.split('').map((d) {
          final int? i = int.tryParse(d);
          return (i != null && i >= 0 && i < _wordsUnder10.length)
              ? _wordsUnder10[i]
              : '?';
        }).toList();
        fractionalWords = ' $sepWord ${digitWords.join(' ')}';
      }
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] into Hausa words (core logic).
  /// Handles chunks and scale words ("dubu", "miliyan", etc.) with "da" connector.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return ""; // Zero handled by callers
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n < BigInt.from(100)) return _convertUnder100(n.toInt());
    if (n < BigInt.from(1000)) return _convertUnder1000(n.toInt());

    final List<String> parts = []; // Stores word parts for each scale level
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0;
    BigInt remaining = n;

    // Decompose into scale groups (units, thousands, millions...)
    while (remaining > BigInt.zero) {
      if (!_scaleWords.containsKey(scaleIndex))
        throw ArgumentError("Number too large");
      final int chunk = (remaining % oneThousand).toInt();
      remaining ~/= oneThousand;

      if (chunk > 0) {
        String chunkText;
        // Handle "dubu" (1000) vs "dubu [chunk]"
        if (scaleIndex == 1 && chunk == 1)
          chunkText = _scaleWords[1]!; // Just "dubu"
        else if (scaleIndex > 0 && chunk == 1)
          chunkText =
              "${_scaleWords[scaleIndex]!} ${_wordsUnder10[1]}"; // e.g. "miliyan ɗaya"
        else {
          chunkText =
              chunk < 100 ? _convertUnder100(chunk) : _convertUnder1000(chunk);
          if (scaleIndex > 0)
            chunkText =
                "${_scaleWords[scaleIndex]!} $chunkText"; // Prepend scale word
        }
        parts.add(chunkText);
      }
      scaleIndex++;
    }

    // Combine parts from largest scale down, inserting "da" before the last part.
    final StringBuffer buffer = StringBuffer();
    for (int i = parts.length - 1; i >= 0; i--) {
      buffer.write(parts[i]);
      if (i > 0) {
        // Add "da" connector before the last part (unless it's the only part).
        buffer.write(i == 1 ? ' $_and ' : ' ');
      }
    }
    return buffer.toString().trim();
  }

  /// Converts an integer 0-99 into Hausa words.
  /// Handles teens ("sha") and tens+units ("da").
  String _convertUnder100(int n) {
    if (n < 0 || n >= 100) throw ArgumentError("Number must be 0-99: $n");
    if (n == 0) return "";
    if (n < 10) return _wordsUnder10[n];

    final int tens = n ~/ 10;
    final int unit = n % 10;

    if (tens == 1 && unit > 0)
      return "${_wordsTens[1]} sha ${_wordsUnder10[unit]}"; // e.g., goma sha ɗaya
    if (unit == 0) return _wordsTens[tens]; // e.g., ashirin
    return "${_wordsTens[tens]} $_and ${_wordsUnder10[unit]}"; // e.g., ashirin da ɗaya
  }

  /// Converts an integer 100-999 into Hausa words.
  /// Handles "ɗari" and multiples, connecting with "da".
  String _convertUnder1000(int n) {
    if (n < 100 || n >= 1000) throw ArgumentError("Number must be 100-999: $n");
    final int hundreds = n ~/ 100;
    final int rem = n % 100;
    final String hundredsText =
        (hundreds == 1) ? _hundred : "$_hundred ${_wordsUnder10[hundreds]}";

    if (rem == 0) return hundredsText;
    return "$hundredsText $_and ${_convertUnder100(rem)}";
  }
}
