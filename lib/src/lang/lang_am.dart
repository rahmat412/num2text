import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/am_options.dart';
import '../options/base_options.dart';
import '../utils/utils.dart';

/// {@template num2text_am}
/// Converts numbers to Amharic words (`Lang.AM`).
///
/// Implements [Num2TextBase] for Amharic, handling various numeric types.
/// Supports cardinals, decimals, negatives, currency (default ETB), years (inc. ዓ.ዓ/ዓ.ም),
/// and large numbers (short scale). Customizable via [AmOptions].
/// {@endtemplate}
class Num2TextAM implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "ዜሮ";
  static const String _point = "ነጥብ"; // Decimal separator (period)
  static const String _comma = "ኮማ"; // Decimal separator (comma)
  static const String _hundred = "መቶ";
  static const String _thousand = "ሺህ";
  static const String _yearSuffixBC = "ዓ.ዓ"; // ዓመተ ዓለም (BC)
  static const String _yearSuffixAD = "ዓ.ም"; // ዓመተ ምሕረት (AD/CE)
  static const String _infinity = "ወሰን የሌለው";
  static const String _notANumber = "ቁጥር አይደለም";

  static const List<String> _wordsUnder20 = [
    "ዜሮ",
    "አንድ",
    "ሁለት",
    "ሶስት",
    "አራት",
    "አምስት",
    "ስድስት",
    "ሰባት",
    "ስምንት",
    "ዘጠኝ",
    "አስር",
    "አስራ አንድ",
    "አስራ ሁለት",
    "አስራ ሶስት",
    "አስራ አራት",
    "አስራ አምስት",
    "አስራ ስድስት",
    "አስራ ሰባት",
    "አስራ ስምንት",
    "አስራ ዘጠኝ",
  ];
  static const List<String> _wordsTens = [
    "",
    "",
    "ሃያ",
    "ሰላሳ",
    "አርባ",
    "ሃምሳ",
    "ስልሳ",
    "ሰባ",
    "ሰማንያ",
    "ዘጠና",
  ];
  // Short scale mapping (largest to smallest for processing)
  static final List<MapEntry<BigInt, String>> _scaleWords = [
    MapEntry(BigInt.from(10).pow(24), "ሴፕቲሊዮን"), // 10^24
    MapEntry(BigInt.from(10).pow(21), "ሴክስቲሊዮን"), // 10^21
    MapEntry(BigInt.from(10).pow(18), "ኩንቲሊዮን"), // 10^18
    MapEntry(BigInt.from(10).pow(15), "ኳድሪሊዮን"), // 10^15
    MapEntry(BigInt.from(10).pow(12), "ትሪሊዮን"), // 10^12
    MapEntry(BigInt.from(10).pow(9), "ቢሊዮን"), // 10^9
    MapEntry(BigInt.from(10).pow(6), "ሚሊዮን"), // 10^6
    MapEntry(BigInt.from(10).pow(3), _thousand), // 10^3
  ];

  /// Processes the given [number] into Amharic words.
  ///
  /// Normalizes input, handles edge cases, determines sign, delegates based on [AmOptions].
  ///
  /// @param number Input value.
  /// @param options [AmOptions] for customization.
  /// @param fallbackOnError Custom error string.
  /// @return Number as Amharic words or an error message.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final AmOptions amOptions =
        options is AmOptions ? options : const AmOptions();
    final String errorFallback = fallbackOnError ?? _notANumber;

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative
            ? "${amOptions.negativePrefix} $_infinity"
            : _infinity;
      if (number.isNaN) return errorFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    if (decimalValue == Decimal.zero) {
      // Currency: "ዜሮ ብር", Other: "ዜሮ"
      return amOptions.currency
          ? "$_zero ${amOptions.currencyInfo.mainUnitSingular}"
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    try {
      if (amOptions.format == Format.year) {
        // Year handles sign internally (BC/AD)
        textResult = _handleYearFormat(
            decimalValue.truncate().toBigInt().toInt(), amOptions);
      } else {
        textResult = amOptions.currency
            ? _handleCurrency(absValue, amOptions)
            : _handleStandardNumber(absValue, amOptions);
        // Prepend negative prefix if needed
        if (isNegative) {
          textResult = "${amOptions.negativePrefix} $textResult";
        }
      }
    } catch (e) {
      // Catch internal conversion errors
      // print('Amharic conversion error: $e'); // Optional logging
      return errorFallback;
    }
    // Clean up spaces
    return textResult.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Converts an integer year into Amharic words, handling era suffixes.
  ///
  /// Appends "ዓ.ዓ" (BC) for negative years, or "ዓ.ም" (AD/CE) for positive
  /// years if [options.includeAD] is true.
  ///
  /// @param year Integer year value.
  /// @param options [AmOptions] for `includeAD` flag.
  /// @return Year as Amharic words.
  String _handleYearFormat(int year, AmOptions options) {
    final bool isNegative = year < 0;
    final int absYear = year.abs();
    if (absYear == 0) return _zero; // Handle year 0 if it arises

    final String yearText = _convertInteger(BigInt.from(absYear));

    if (isNegative)
      return "$yearText $_yearSuffixBC";
    else if (options.includeAD)
      return "$yearText $_yearSuffixAD";
    else
      return yearText;
  }

  /// Converts a non-negative [Decimal] value to Amharic currency words.
  ///
  /// Uses [AmOptions.currencyInfo] (default ETB). Rounds if specified.
  /// Uses singular unit names (common in Amharic).
  ///
  /// @param absValue Positive currency amount.
  /// @param options [AmOptions] for currency settings.
  /// @return Currency value as Amharic words.
  String _handleCurrency(Decimal absValue, AmOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final Decimal val = options.round ? absValue.round(scale: 2) : absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    final BigInt subVal = ((val - val.truncate()) * Decimal.fromInt(100))
        .round(scale: 0)
        .toBigInt();

    if (mainVal == BigInt.zero && subVal == BigInt.zero) {
      return '$_zero ${info.mainUnitSingular}'; // e.g., "ዜሮ ብር"
    }

    String mainPart = '';
    if (mainVal > BigInt.zero) {
      mainPart = '${_convertInteger(mainVal)} ${info.mainUnitSingular}';
    }

    String subPart = '';
    if (subVal > BigInt.zero && info.subUnitSingular != null) {
      subPart = '${_convertInteger(subVal)} ${info.subUnitSingular!}';
    }

    if (mainPart.isNotEmpty && subPart.isNotEmpty) {
      final String sep = info.separator ?? ""; // e.g., "ከ" for ETB
      return sep.isNotEmpty ? '$mainPart $sep$subPart' : '$mainPart $subPart';
    } else {
      return mainPart.isNotEmpty
          ? mainPart
          : subPart; // Return whichever part exists
    }
  }

  /// Converts a non-negative standard [Decimal] number to Amharic words.
  ///
  /// Converts integer and fractional parts. Reads fractional digits individually
  /// after the separator word (e.g., "ነጥብ"). Removes trailing fractional zeros.
  ///
  /// @param absValue Positive number.
  /// @param options [AmOptions] for `decimalSeparator`.
  /// @return Number as Amharic words.
  String _handleStandardNumber(Decimal absValue, AmOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero && !absValue.isInteger) {
      final String sepWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          sepWord = _comma;
          break;
        default:
          sepWord = _point;
          break; // Default "ነጥብ"
      }

      String fracDigits =
          absValue.toString().split('.').last.replaceAll(RegExp(r'0+$'), '');
      if (fracDigits.isNotEmpty) {
        final List<String> digitWords = fracDigits.split('').map((d) {
          final int? i = int.tryParse(d);
          return (i != null && i >= 0 && i <= 9) ? _wordsUnder20[i] : '?';
        }).toList();
        fractionalWords =
            ' $sepWord ${digitWords.join(' ')}'; // e.g., " ነጥብ አራት አምስት"
      }
    }
    return '$integerWords$fractionalWords';
  }

  /// Converts a non-negative integer ([BigInt]) into Amharic words (short scale).
  ///
  /// Processes the number from largest scale down. Delegates chunks < 1000 to [_convertChunk].
  ///
  /// @param n Non-negative integer.
  /// @return Integer as Amharic words.
  String _convertInteger(BigInt n) {
    assert(n >= BigInt.zero, 'Input must be non-negative.');
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.from(1000)) return _convertChunk(n.toInt());

    final List<String> parts = [];
    BigInt remaining = n;

    // Process using the pre-defined scale map (largest first)
    for (final scaleEntry in _scaleWords) {
      final scaleValue = scaleEntry.key;
      final scaleName = scaleEntry.value;

      if (remaining >= scaleValue) {
        final BigInt count = remaining ~/ scaleValue;
        remaining %= scaleValue;
        // Convert the count for this scale (e.g., "two" for "two million")
        // Special case: "አንድ ሺህ" (one thousand) is typically just "ሺህ" when part of larger number,
        // but handled naturally here as _convertChunk(1) is "አንድ".
        // We need "አንድ መቶ" but just "መቶ" for 100, handled in _convertChunk.
        final String countText = _convertChunk(count.toInt());
        parts.add("$countText $scaleName");
      }
    }
    // Add the final remaining part (0-999) if any
    if (remaining > BigInt.zero) {
      parts.add(_convertChunk(remaining.toInt()));
    }

    return parts.join(' ');
  }

  /// Converts an integer from 0 to 999 into Amharic words.
  ///
  /// Handles hundreds ("መቶ"), tens, units. Returns empty string for 0.
  /// Special rule: 100 is "መቶ", but 200+ is "digit መቶ" (e.g., "ሁለት መቶ").
  ///
  /// @param n Integer chunk (0-999).
  /// @return Chunk as Amharic words, or empty string if n is 0.
  /// @throws ArgumentError if n is outside 0-999.
  String _convertChunk(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    final List<String> words = [];
    int remainder = n;

    if (remainder >= 100) {
      final int hundredDigit = remainder ~/ 100;
      // Add digit word only if > 1 (e.g., "ሁለት መቶ", not "አንድ መቶ")
      if (hundredDigit > 1) {
        words.add(_wordsUnder20[hundredDigit]);
      }
      words.add(_hundred); // "መቶ"
      remainder %= 100;
    }

    if (remainder > 0) {
      if (remainder < 20) {
        words.add(_wordsUnder20[remainder]); // 1-19
      } else {
        final int tensDigit = remainder ~/ 10;
        final int unitDigit = remainder % 10;
        words.add(_wordsTens[tensDigit]); // ሃያ, ሰላሳ...
        if (unitDigit > 0) {
          words.add(_wordsUnder20[unitDigit]); // Add unit word if needed
        }
      }
    }
    return words.join(' ');
  }
}
