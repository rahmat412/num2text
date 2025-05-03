import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/mk_options.dart';
import '../utils/utils.dart';

/// {@template num2text_mk}
/// Converts numbers to Macedonian words (`Lang.MK`).
///
/// Implements [Num2TextBase] for Macedonian, handling various numeric inputs.
/// Features include cardinal numbers, currency, year formatting, decimals, negatives,
/// and large numbers. Handles gender agreement for "one"/"two" with feminine scale words (илјада, милијарда).
/// Uses the conjunction "и" (and) according to Macedonian rules.
/// Customizable via [MkOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextMK implements Num2TextBase {
  // --- Constants ---
  static const String _point = "точка"; // Decimal point word
  static const String _comma = "запирка"; // Decimal comma word
  static const String _and = "и"; // Conjunction "and"
  static const String _oneMasculine = "еден";
  static const String _oneFeminine = "една";
  static const String _twoMasculine = "два";
  static const String _twoFeminine = "две";
  static const String _zero = "нула";

  /// Words 0-19. Note: 1/2 have gender variants handled elsewhere.
  static const List<String> _wordsUnder20 = [
    "нула",
    "еден",
    "два",
    "три",
    "четири",
    "пет",
    "шест",
    "седум",
    "осум",
    "девет",
    "десет",
    "единаесет",
    "дванаесет",
    "тринаесет",
    "четиринаесет",
    "петнаесет",
    "шеснаесет",
    "седумнаесет",
    "осумнаесет",
    "деветнаесет",
  ];

  /// Words for tens (20, 30,... 90).
  static const List<String> _wordsTens = [
    "",
    "",
    "дваесет",
    "триесет",
    "четириесет",
    "педесет",
    "шеесет",
    "седумдесет",
    "осумдесет",
    "деведесет",
  ];

  /// Words for hundreds (100, 200,... 900).
  static const List<String> _wordsHundreds = [
    "",
    "сто",
    "двесте",
    "триста",
    "четиристотини",
    "петстотини",
    "шестотини",
    "седумстотини",
    "осумстотини",
    "деветстотини",
  ];

  /// Scale words: [singular, plural, gender ('m'/'f')]. Index = power of 1000.
  static const Map<int, List<String>> _scaleWords = {
    1: ["илјада", "илјади", 'f'], // 10^3
    2: ["милион", "милиони", 'm'], // 10^6
    3: ["милијарда", "милијарди", 'f'], // 10^9
    4: ["билион", "билиони", 'm'], // 10^12
    5: ["билијарда", "билијарди", 'f'], // 10^15
    6: ["трилион", "трилиони", 'm'], // 10^18
    7: ["трилијарда", "трилијарди", 'f'], // 10^21
    8: ["квадрилион", "квадрилиони", 'm'], // 10^24
  };

  /// Processes the given [number] into Macedonian words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [MkOptions] for customization (currency, year format, decimals, AD/BC).
  /// Defaults apply if [options] is null or not [MkOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or "Не Е Број" on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [MkOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Macedonian words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final MkOptions mkOptions =
        options is MkOptions ? options : const MkOptions();
    final String errorFallback = fallbackOnError ?? "Не Е Број";

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Негативна Бесконечност" : "Бесконечност";
      if (number.isNaN) return errorFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    if (decimalValue == Decimal.zero) {
      if (mkOptions.currency) {
        final CurrencyInfo info = mkOptions.currencyInfo;
        return "$_zero ${info.mainUnitPlural ?? info.mainUnitSingular}";
      } else {
        return _zero;
      }
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    if (mkOptions.currency) {
      textResult = _handleCurrency(absValue, mkOptions);
    } else if (mkOptions.format == Format.year) {
      textResult = _handleYear(absValue, isNegative, mkOptions);
    } else {
      textResult = _handleStandardNumber(absValue, mkOptions);
    }

    // Add negative prefix unless it's a year (handled by BC/AD).
    if (isNegative && mkOptions.format != Format.year) {
      textResult = "${mkOptions.negativePrefix} $textResult";
    }

    return textResult.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Converts a non-negative [Decimal] to Macedonian currency words.
  ///
  /// Uses [MkOptions.currencyInfo]. Does not handle specific gender agreement for currency units yet.
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Macedonian words.
  String _handleCurrency(Decimal absValue, MkOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final BigInt mainVal = absValue.truncate().toBigInt();
    final BigInt subVal =
        ((absValue - absValue.truncate()) * Decimal.fromInt(100))
            .round()
            .toBigInt();
    final bool hasSubunits =
        info.subUnitSingular != null && info.subUnitPlural != null;

    if (mainVal == BigInt.zero && subVal == BigInt.zero) {
      return "$_zero ${info.mainUnitPlural ?? info.mainUnitSingular}";
    }

    String mainPart = '';
    if (mainVal > BigInt.zero) {
      // Currently uses default _convertInteger which doesn't adapt 1/2 for currency gender.
      String mainText = _convertInteger(mainVal);
      String mainUnit = (mainVal == BigInt.one)
          ? info.mainUnitSingular
          : (info.mainUnitPlural ?? info.mainUnitSingular);
      mainPart = '$mainText $mainUnit';
    }

    String subPart = '';
    if (hasSubunits && subVal > BigInt.zero) {
      String subText = _convertInteger(subVal);
      String subUnit = (subVal == BigInt.one)
          ? info.subUnitSingular!
          : (info.subUnitPlural ?? info.subUnitSingular!);
      subPart = '$subText $subUnit';
    }

    if (mainPart.isNotEmpty && subPart.isNotEmpty) {
      String sep = info.separator ?? _and;
      return '$mainPart $sep $subPart';
    } else if (mainPart.isNotEmpty)
      return mainPart;
    else if (subPart.isNotEmpty)
      return subPart; // Handle 0.xx cases
    else
      return "$_zero ${info.mainUnitPlural ?? info.mainUnitSingular}"; // Should be unreachable if initial zero check passed
  }

  /// Converts a year value to Macedonian words, adding era suffixes.
  String _handleYear(Decimal absValue, bool isNegative, MkOptions options) {
    BigInt year = absValue.truncate().toBigInt();
    // Years are typically read as standard cardinal numbers.
    String yearText = _convertInteger(year);

    if (isNegative)
      return "$yearText п.н.е."; // Before Common Era
    else
      return options.includeAD ? "$yearText н.е." : yearText; // Common Era
  }

  /// Converts a non-negative standard [Decimal] number to Macedonian words.
  ///
  /// Converts integer and fractional parts. Uses [MkOptions.decimalSeparator] word.
  /// Fractional part converted digit by digit. Trims trailing zeros from fraction.
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Macedonian words.
  String _handleStandardNumber(Decimal absValue, MkOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    String integerWords = _convertInteger(integerPart);

    if (integerPart == BigInt.zero && fractionalPart == Decimal.zero)
      return _zero;
    if (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
      integerWords = _zero;

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      String sepWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          sepWord = _point;
          break;
        default:
          sepWord = _comma;
          break; // Default to comma
      }

      String fracDigits = fractionalPart.toString().substring(2); // Remove "0."
      while (fracDigits.endsWith('0') && fracDigits.length > 1) {
        fracDigits = fracDigits.substring(0, fracDigits.length - 1);
      }

      if (fracDigits.isNotEmpty && fracDigits != '0') {
        List<String> digitWords = fracDigits
            .split('')
            .map((d) => _wordsUnder20[int.tryParse(d) ?? 0])
            .toList();
        fractionalWords = ' $sepWord ${digitWords.join(' ')}';
      }
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts an integer from 0 to 999 into Macedonian words. Returns "" for 0.
  /// Handles the conjunction "и" (and) correctly.
  ///
  /// @param n Integer (0 <= n < 1000).
  /// @return Number as Macedonian words, or "" if n is 0.
  String _convertChunk(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    StringBuffer chunkBuffer = StringBuffer();
    int remainder = n;
    int hundredsDigit = remainder ~/ 100;

    if (hundredsDigit > 0) {
      chunkBuffer.write(_wordsHundreds[hundredsDigit]); // e.g., "сто", "двесте"
      remainder %= 100;
      if (remainder > 0) {
        // Add "и" before tens/units if hundreds exist.
        chunkBuffer.write(' $_and ');
      }
    }

    // Handle tens and units (remainder is now 0-99)
    if (remainder > 0) {
      if (remainder < 20) {
        chunkBuffer.write(_wordsUnder20[remainder]);
      } else {
        chunkBuffer.write(_wordsTens[remainder ~/ 10]); // e.g., "дваесет"
        int unit = remainder % 10;
        if (unit > 0) {
          // Add "и" between tens and units > 0.
          chunkBuffer.write(' $_and ');
          chunkBuffer.write(_wordsUnder20[unit]);
        }
      }
    }

    return chunkBuffer.toString(); // No trim needed due to logic
  }

  /// Converts a non-negative integer ([BigInt]) into Macedonian words.
  ///
  /// Breaks into chunks of 1000, applies scale words with gender agreement for 1/2.
  /// Handles the conjunction "и" between scales based on Macedonian grammar.
  ///
  /// @param n Non-negative integer.
  /// @throws ArgumentError if [n] exceeds defined scales.
  /// @return Integer as Macedonian words.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.from(1000)) return _convertChunk(n.toInt());

    List<_IntegerPart> parts = []; // Store non-zero chunk info
    final BigInt oneThousand = BigInt.from(1000);
    int scaleLevel = 0;
    BigInt remaining = n;

    // Deconstruct into parts/chunks
    do {
      BigInt chunkValue = remaining % oneThousand;
      remaining ~/= oneThousand;
      if (chunkValue > BigInt.zero) {
        String chunkText = _convertChunk(chunkValue.toInt());
        String combinedPartText = chunkText; // Default for scale 0 (units)

        if (scaleLevel > 0) {
          // Handle scales (thousand, million, ...)
          List<String>? scaleInfo = _scaleWords[scaleLevel];
          if (scaleInfo == null) throw ArgumentError("Number too large: $n");

          String scaleSingular = scaleInfo[0];
          String scalePlural = scaleInfo[1];
          String scaleGender = scaleInfo[2]; // 'm' or 'f'
          String scaleWord;

          // Apply gender agreement for 1/2 with feminine scales (илјада, милијарда...)
          if (scaleGender == 'f') {
            if (chunkText == _oneMasculine)
              chunkText = _oneFeminine;
            else if (chunkText.endsWith(" $_oneMasculine"))
              chunkText = chunkText.substring(
                      0, chunkText.length - _oneMasculine.length) +
                  _oneFeminine;
            else if (chunkText == _twoMasculine)
              chunkText = _twoFeminine;
            else if (chunkText.endsWith(" $_twoMasculine"))
              chunkText = chunkText.substring(
                      0, chunkText.length - _twoMasculine.length) +
                  _twoFeminine;
          }

          // Determine scale word form and potentially adjust chunk text
          if (chunkValue == BigInt.one) {
            scaleWord = scaleSingular;
            // For scales > thousand (million+), if count is 1, use "еден/една" not just the scale word.
            // But for "илјада", just use "илјада" (handled by chunkText being empty later).
            if (scaleLevel == 1)
              chunkText = ''; // "илјада" not "една илјада"
            else
              chunkText = (scaleGender == 'f')
                  ? _oneFeminine
                  : _oneMasculine; // "еден милион", "една милијарда"
          } else {
            scaleWord = scalePlural;
          }
          combinedPartText =
              chunkText.isNotEmpty ? "$chunkText $scaleWord" : scaleWord;
        }
        parts.add(_IntegerPart(chunkValue, combinedPartText, scaleLevel));
      }
      scaleLevel++;
    } while (remaining > BigInt.zero);

    // Reconstruct with correct conjunction "и"
    StringBuffer buffer = StringBuffer();
    for (int i = parts.length - 1; i >= 0; i--) {
      buffer.write(parts[i].text);

      // Check if a connector (" " or " и ") is needed before the *next* part
      if (i > 0) {
        BigInt nextChunkValue = parts[i - 1].value;
        // Add "и" if the next chunk is < 100 or is a round hundred (100, 200, .. 900)
        if (nextChunkValue < BigInt.from(100) ||
            (nextChunkValue < BigInt.from(1000) &&
                nextChunkValue % BigInt.from(100) == BigInt.zero)) {
          buffer.write(' $_and ');
        } else {
          buffer.write(' '); // Just a space otherwise
        }
      }
    }
    return buffer.toString();
  }
}

/// Helper class to store chunk value, text, and scale level for reconstruction.
class _IntegerPart {
  final BigInt value;
  final String text;
  final int scaleLevel;
  _IntegerPart(this.value, this.text, this.scaleLevel);
}
