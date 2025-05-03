import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/pt_options.dart';
import '../utils/utils.dart';

/// {@template num2text_pt}
/// Converts numbers to Portuguese words (`Lang.PT`).
///
/// Implements [Num2TextBase] for Portuguese, handling various numeric types.
/// Supports cardinal numbers, decimals, negatives, currency, years, and large numbers (short scale).
/// Handles Portuguese specifics like "cem"/"cento" and the conjunction "e".
/// Customizable via [PtOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextPT implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "zero";
  static const String _comma = "vírgula"; // Default decimal separator
  static const String _point = "ponto";
  static const String _and = "e";
  static const String _hundred = "cem"; // For exactly 100
  static const String _yearSuffixBC = "a.C."; // Antes de Cristo
  static const String _yearSuffixAD = "d.C."; // Depois de Cristo
  static const String _infinity = "Infinito";
  static const String _negativeInfinity = "Menos Infinito";
  static const String _notANumber = "Não É Um Número"; // Default NaN fallback

  static const List<String> _wordsUnder20 = [
    "zero",
    "um",
    "dois",
    "três",
    "quatro",
    "cinco",
    "seis",
    "sete",
    "oito",
    "nove",
    "dez",
    "onze",
    "doze",
    "treze",
    "catorze",
    "quinze",
    "dezesseis",
    "dezessete",
    "dezoito",
    "dezenove",
  ];
  static const List<String> _wordsTens = [
    "",
    "",
    "vinte",
    "trinta",
    "quarenta",
    "cinquenta",
    "sessenta",
    "setenta",
    "oitenta",
    "noventa",
  ];
  // Note: 100 is "cem" (handled separately), 101-199 use "cento".
  static const Map<int, String> _wordsHundredsMap = {
    1: "cento",
    2: "duzentos",
    3: "trezentos",
    4: "quatrocentos",
    5: "quinhentos",
    6: "seiscentos",
    7: "setecentos",
    8: "oitocentos",
    9: "novecentos",
  };
  // Scale words (short scale). Forms: [singular, plural]. "mil" is irregular.
  static const List<List<String>> _scaleWords = [
    ["", ""], // Scale 0 (Units)
    ["mil", "mil"], // Scale 1 (Thousands)
    ["milhão", "milhões"], // Scale 2 (Millions)
    ["bilhão", "bilhões"], // Scale 3 (Billions, 10^9)
    ["trilhão", "trilhões"], // Scale 4 (Trillions, 10^12)
    ["quatrilhão", "quatrilhões"], // Scale 5 (Quadrillions, 10^15)
    ["quintilhão", "quintilhões"], // Scale 6 (Quintillions, 10^18)
    ["sextilhão", "sextilhões"], // Scale 7 (Sextillions, 10^21)
    ["septilhão", "septilhões"], // Scale 8 (Septillions, 10^24)
  ];

  /// Processes the given [number] into Portuguese words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [PtOptions] for customization (currency, year, decimals, AD/BC, rounding).
  /// Defaults apply if [options] is null or not [PtOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or "Não É Um Número" on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [PtOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Portuguese words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final PtOptions ptOptions =
        options is PtOptions ? options : const PtOptions();
    final String errorDefault = fallbackOnError ?? _notANumber;

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _negativeInfinity : _infinity;
      if (number.isNaN) return errorDefault;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorDefault;

    if (decimalValue == Decimal.zero) {
      if (ptOptions.currency) {
        final String mainUnit = ptOptions.currencyInfo.mainUnitPlural ??
            ptOptions.currencyInfo.mainUnitSingular;
        return "$_zero $mainUnit"; // e.g., "zero reais"
      } else {
        return _zero;
      }
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    if (ptOptions.format == Format.year) {
      // Year sign handled internally.
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), ptOptions);
    } else {
      textResult = ptOptions.currency
          ? _handleCurrency(absValue, ptOptions)
          : _handleStandardNumber(absValue, ptOptions);
      if (isNegative) {
        textResult = "${ptOptions.negativePrefix} $textResult";
      }
    }

    return textResult.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Converts a [year] (`BigInt`) to Portuguese words, handling AD/BC suffixes.
  ///
  /// @param year The year value (can be negative).
  /// @param options Formatting options (`includeAD`).
  /// @return The year as Portuguese words.
  String _handleYearFormat(BigInt year, PtOptions options) {
    final bool isNegative = year < BigInt.zero;
    final BigInt absYear = isNegative ? -year : year;
    final String yearText = _convertInteger(absYear);

    if (isNegative)
      return "$yearText $_yearSuffixBC";
    else if (options.includeAD && year > BigInt.zero)
      return "$yearText $_yearSuffixAD";
    else
      return yearText;
  }

  /// Converts a non-negative [Decimal] to Portuguese currency words.
  ///
  /// Uses [PtOptions.currencyInfo] for unit names. Rounds if [PtOptions.round] is true.
  /// Separates main and subunits. Handles "de" before units for millions+.
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Portuguese words.
  String _handleCurrency(Decimal absValue, PtOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final Decimal val = options.round ? absValue.round(scale: 2) : absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    final BigInt subVal =
        ((val - val.truncate()) * Decimal.fromInt(100)).truncate().toBigInt();

    List<String> parts = [];

    if (mainVal > BigInt.zero) {
      String mainText = _convertInteger(mainVal);
      String name = (mainVal == BigInt.one)
          ? info.mainUnitSingular
          : (info.mainUnitPlural ?? info.mainUnitSingular);
      // Add "de" for exact millions, billions, etc. (e.g., "um milhão de reais")
      bool needsDe = mainVal >= BigInt.from(1000000) &&
          (mainVal % BigInt.from(1000000)) == BigInt.zero;
      parts.add(needsDe ? '$mainText de $name' : '$mainText $name');
    }

    if (subVal > BigInt.zero && info.subUnitSingular != null) {
      String subText = _convertInteger(subVal);
      String name = (subVal == BigInt.one)
          ? info.subUnitSingular!
          : (info.subUnitPlural ?? info.subUnitSingular!);
      if (parts.isNotEmpty) parts.add(info.separator ?? _and);
      parts.add('$subText $name');
    }

    if (parts.isEmpty) {
      // Handle zero value
      String name = info.mainUnitPlural ?? info.mainUnitSingular;
      return "$_zero $name";
    }

    return parts.join(' ');
  }

  /// Converts a non-negative standard [Decimal] number to Portuguese words.
  ///
  /// Converts integer and fractional parts. Uses [PtOptions.decimalSeparator] word.
  /// Fractional part converted digit by digit.
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Portuguese words.
  String _handleStandardNumber(Decimal absValue, PtOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      String sepWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          sepWord = _point;
          break;
        default:
          sepWord = _comma;
          break; // Default to comma
      }

      String fracDigits = absValue.toString().split('.').last;
      fracDigits =
          fracDigits.replaceAll(RegExp(r'0+$'), ''); // Remove trailing zeros

      if (fracDigits.isNotEmpty) {
        List<String> digitWords = fracDigits.split('').map((d) {
          final int? i = int.tryParse(d);
          return (i != null && i >= 0 && i <= 9) ? _wordsUnder20[i] : '?';
        }).toList();
        fractionalWords = ' $sepWord ${digitWords.join(' ')}';
      }
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] into Portuguese words using short scale.
  ///
  /// Breaks number into chunks of 1000. Applies scale words and "e" conjunction correctly.
  ///
  /// @param n Non-negative integer.
  /// @throws ArgumentError if [n] is negative or too large.
  /// @return Integer as Portuguese words.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.from(1000)) return _convertChunk(n.toInt());

    List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0;
    BigInt rem = n;
    List<int> chunkValues = []; // Store chunk values for 'e' logic

    // Chunk the number and convert parts
    while (rem > BigInt.zero) {
      if (scaleIndex >= _scaleWords.length)
        throw ArgumentError("Number too large");
      int chunk = (rem % oneThousand).toInt();
      chunkValues.add(chunk);
      rem ~/= oneThousand;

      if (chunk > 0) {
        String chunkText = (scaleIndex == 1 && chunk == 1)
            ? ""
            : _convertChunk(chunk); // Omit "um" for "mil"
        String scaleWord = "";
        if (scaleIndex > 0) {
          scaleWord = (scaleIndex > 1 && chunk == 1)
              ? _scaleWords[scaleIndex][0]
              : _scaleWords[scaleIndex][1];
        }
        String combined = chunkText.isEmpty
            ? scaleWord
            : (scaleWord.isEmpty ? chunkText : '$chunkText $scaleWord');
        parts.add(combined.trim());
      } else
        parts.add("");
      scaleIndex++;
    }

    // Assemble with correct 'e' conjunction
    List<String> finalParts = [];
    List<String> revParts = parts.reversed.toList();
    List<int> revChunks = chunkValues.reversed.toList();
    int lastNonZeroIdx = revChunks.lastIndexWhere((v) => v != 0);

    for (int i = 0; i < revParts.length; i++) {
      if (revParts[i].isEmpty) continue;
      finalParts.add(revParts[i]);

      // Check if 'e' is needed before the *last* non-zero chunk
      int nextNonZeroIdx = revParts.indexWhere((p) => p.isNotEmpty, i + 1);
      if (nextNonZeroIdx != -1 && nextNonZeroIdx == lastNonZeroIdx) {
        int lastChunkVal = revChunks[lastNonZeroIdx];
        // Add 'e' if last chunk is < 100 or exactly 100.
        if (lastChunkVal < 100 || lastChunkVal == 100) {
          finalParts.add(_and);
        }
      }
    }
    return finalParts.join(' ');
  }

  /// Converts an integer from 0 to 999 into Portuguese words.
  /// Handles "cem" vs "cento" and "e" conjunctions within the chunk.
  ///
  /// @param n Integer chunk (0-999).
  /// @throws ArgumentError if [n] is outside 0-999.
  /// @return Chunk as Portuguese words, or empty string if [n] is 0.
  String _convertChunk(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");
    if (n == 100) return _hundred; // Special case for exactly 100

    List<String> words = [];
    int rem = n;

    if (rem >= 100) {
      words.add(_wordsHundredsMap[rem ~/ 100]!); // cento, duzentos, etc.
      rem %= 100;
      if (rem > 0) words.add(_and); // "cento e ..."
    }

    if (rem > 0) {
      if (rem < 20)
        words.add(_wordsUnder20[rem]);
      else {
        words.add(_wordsTens[rem ~/ 10]);
        if (rem % 10 > 0) {
          words.add(_and); // "vinte e ..."
          words.add(_wordsUnder20[rem % 10]);
        }
      }
    }
    return words.join(' ');
  }
}
