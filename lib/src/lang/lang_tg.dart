import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/tg_options.dart';
import '../utils/utils.dart';

/// {@template num2text_tg}
/// Converts numbers to Tajik words (`Lang.TG`).
///
/// Implements [Num2TextBase] for Tajik, handling various numeric types.
/// Supports cardinal numbers, decimals, negatives, currency (default TJS), years, and large numbers.
/// Correctly handles the Tajik conjunction "у" (e.g., "бисту", "саду").
/// Customizable via [TgOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextTG implements Num2TextBase {
  // --- Internal Constants ---
  static const String _negative = "минус"; // "minus"
  static const String _zero = "нол"; // "zero"
  static const String _point = "нуқта"; // Decimal separator "point"
  static const String _comma = "вергул"; // Decimal separator "comma"
  /// Conjunction "and" - often attaches to the previous word in Tajik.
  static const String _conjunction = "у";
  static const String _currencySeparator =
      " ва "; // Currency main/subunit separator "and"
  static const String _yearSuffixAD =
      " м."; // Suffix for AD/CE years ("милодӣ")
  static const String _yearSuffixBC =
      " п.м."; // Suffix for BC/BCE years ("пеш аз милод")
  /// Izofat suffix, added before year suffixes when grammatically required.
  static const String _izofatSuffix = "и";

  // Default fallback messages
  static const String _infinityInternal = "беохир"; // "infinity"
  static const String _negativeInfinityInternal =
      "$_negative $_infinityInternal"; // "negative infinity"
  static const String _notANumberInternal = "рақам нест"; // "not a number"

  // --- Number Words ---
  static const List<String> _units = [
    "",
    "як",
    "ду",
    "се",
    "чор",
    "панҷ",
    "шаш",
    "ҳафт",
    "ҳашт",
    "нӯҳ"
  ]; // 1-9
  static const List<String> _teens = [
    "даҳ",
    "ёздаҳ",
    "дувоздаҳ",
    "сездаҳ",
    "чордаҳ",
    "понздаҳ",
    "шонздаҳ",
    "ҳабдаҳ",
    "ҳаждаҳ",
    "нуздаҳ"
  ]; // 10-19
  static const List<String> _tens = [
    "",
    "",
    "бист",
    "сӣ",
    "чил",
    "панҷоҳ",
    "шаст",
    "ҳафтод",
    "ҳаштод",
    "навад"
  ]; // 20, 30...90
  static const String _hundred = "сад"; // 100
  static const List<String> _scaleWords = [
    "",
    "ҳазор",
    "миллион",
    "миллиард",
    "триллион",
    "квадриллион",
    "квинтиллион",
    "секстиллион",
    "септиллион"
  ]; // 10^3, 10^6...

  /// Processes the given [number] into Tajik words.
  /// {@template num2text_process_intro_tg}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  /// {@template num2text_process_options_tg}
  /// Uses [TgOptions] for customization (currency, year format, decimals, AD/BC).
  /// Defaults apply if [options] is null or not [TgOptions].
  /// {@endtemplate}
  /// {@template num2text_process_errors_tg}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or default Tajik errors on failure.
  /// Applies title case to error messages like "Рақам Нест".
  /// {@endtemplate}
  /// @param number The number to convert.
  /// @param options Optional [TgOptions] settings.
  /// @param fallbackOnError Optional custom error string.
  /// @return The number as Tajik words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final TgOptions tgOptions =
        options is TgOptions ? options : const TgOptions();
    final String errorFallback = fallbackOnError ?? _notANumberInternal;
    String result;

    if (number is double) {
      if (number.isInfinite) {
        result =
            number.isNegative ? _negativeInfinityInternal : _infinityInternal;
        return result.toTitleCase; // Apply title case for infinity outputs
      }
      if (number.isNaN) {
        return errorFallback.toTitleCase; // Apply title case for NaN fallback
      }
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) {
      return errorFallback.toTitleCase; // Apply title case for general fallback
    }

    if (decimalValue == Decimal.zero) {
      result = tgOptions.currency
          ? "$_zero ${tgOptions.currencyInfo.mainUnitSingular}"
          : _zero;
      return result;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    if (tgOptions.format == Format.year) {
      int yearInt = decimalValue.truncate().toBigInt().toInt();
      textResult = _handleYearFormat(yearInt, tgOptions);
    } else {
      textResult = tgOptions.currency
          ? _handleCurrency(absValue, tgOptions)
          : _handleStandardNumber(absValue, tgOptions);
      if (isNegative) {
        textResult = "${tgOptions.negativePrefix} $textResult";
      }
    }
    return textResult;
  }

  /// Converts a non-negative [Decimal] to Tajik currency words.
  /// (Comments remain the same as previous correct version)
  String _handleCurrency(Decimal absValue, TgOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2;
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    final BigInt subunitValue =
        (fractionalPart.abs() * subunitMultiplier).truncate().toBigInt();

    String result = "";
    String? subunitPart;

    if (subunitValue > BigInt.zero) {
      String subunitText = _convertInteger(subunitValue);
      String? subUnitName = currencyInfo.subUnitSingular;
      if (subUnitName != null && subUnitName.isNotEmpty) {
        subunitPart = '$subunitText $subUnitName';
      }
    }

    if (mainValue > BigInt.zero) {
      String mainText = _convertInteger(mainValue);
      String mainUnitName = currencyInfo.mainUnitSingular;
      result = '$mainText $mainUnitName';

      if (subunitPart != null) {
        String separatorText =
            (currencyInfo.separator ?? _currencySeparator).trim();
        result += ' $separatorText $subunitPart';
      }
    } else if (subunitPart != null) {
      result = subunitPart;
    } else {
      result = "$_zero ${currencyInfo.mainUnitSingular}";
    }
    return result;
  }

  /// Converts a non-negative standard [Decimal] number to Tajik words.
  /// (Comments remain the same as previous correct version)
  String _handleStandardNumber(Decimal absValue, TgOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = (absValue - absValue.truncate()).abs();

    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      String separatorWord;
      switch (options.decimalSeparator ?? DecimalSeparator.point) {
        case DecimalSeparator.comma:
          separatorWord = _comma;
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          separatorWord = _point;
          break;
      }

      String fractionalDigits = absValue.toString().split('.').last;
      List<String> digitWords = fractionalDigits.split('').map((digit) {
        final int? digitInt = int.tryParse(digit);
        return (digitInt != null && digitInt >= 0 && digitInt <= 9)
            ? (digitInt == 0 ? "сифр" : _units[digitInt])
            : '?';
      }).toList();

      String separatorPrefix =
          (integerWords == _zero || integerWords.isEmpty) ? "" : " ";
      fractionalWords =
          '$separatorPrefix$separatorWord ${digitWords.join(' ')}';
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts an integer year to Tajik words with AD/BC suffixes.
  /// (Comments remain the same as previous correct version)
  String _handleYearFormat(int year, TgOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;
    String yearText;

    if (absYear > 1000 && absYear < 2000) {
      int remainder = absYear % 1000;
      if (remainder == 0) {
        yearText = _convertInteger(BigInt.from(absYear), isYear: true);
      } else {
        String remainderText = _convertChunk(remainder);
        // Attach conjunction directly for years like "ҳазору ..."
        yearText = "${_scaleWords[1]}$_conjunction $remainderText";
      }
    } else {
      yearText = _convertInteger(BigInt.from(absYear), isYear: true);
    }

    String suffix = "";
    if (isNegative)
      suffix = _yearSuffixBC;
    else if (options.includeAD && absYear > 0) suffix = _yearSuffixAD;

    if (suffix.isNotEmpty) {
      if (!yearText.endsWith(_izofatSuffix)) {
        yearText += _izofatSuffix;
      }
      yearText += suffix;
    }
    return yearText;
  }

  /// Converts a non-negative [BigInt] into Tajik words using scale words.
  /// Correctly joins parts with attached "у" or spaces as needed.
  /// (Comments updated slightly for clarity on joining logic)
  String _convertInteger(BigInt n, {bool isYear = false}) {
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n == BigInt.from(1000))
      return isYear ? _scaleWords[1] : "${_units[1]} ${_scaleWords[1]}";
    if (n < BigInt.from(1000)) return _convertChunk(n.toInt());

    List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0;
    BigInt remaining = n;

    while (remaining > BigInt.zero) {
      if (scaleIndex >= _scaleWords.length)
        throw ArgumentError("Number too large: exceeds ${_scaleWords.last}");

      BigInt chunk = remaining % oneThousand;
      remaining ~/= oneThousand;

      if (chunk > BigInt.zero) {
        String chunkText = _convertChunk(chunk.toInt());
        String scaleWord = scaleIndex > 0 ? _scaleWords[scaleIndex] : "";
        String partToAdd;

        if (scaleWord.isNotEmpty) {
          if (chunk == BigInt.one && scaleIndex == 1) {
            partToAdd = "${_units[1]} $scaleWord"; // "як ҳазор"
          } else {
            partToAdd = "$chunkText $scaleWord";
          }
        } else {
          partToAdd = chunkText;
        }
        parts.add(partToAdd);
      }
      scaleIndex++;
    }

    // Combine parts from largest scale down.
    // Apply Tajik conjunction rules: attach 'у' if previous part allows, else use space ' у '.
    List<String> reversedParts = parts.reversed.toList();
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < reversedParts.length; i++) {
      String currentPart = reversedParts[i];
      buffer.write(currentPart);

      // Check if conjunction 'у' should be attached or spaced for the *next* part
      if (i < reversedParts.length - 1) {
        // Simple rule: always use space before 'у' between major scales for now.
        // More complex rules might check vowel endings. Sticking to spaced ' у ' between scales.
        // The conjunction within chunks (_convertChunk) handles attachment.
        buffer.write(" $_conjunction ");
      }
    }
    // The previous loop joined major scales with " у ". Now, let's refine based on tests.
    // Tests expect "у" attached within chunks AND between scales.
    // Let's rebuild using direct attachment logic primarily.

    StringBuffer finalBuffer = StringBuffer();
    for (int i = 0; i < reversedParts.length; i++) {
      finalBuffer.write(reversedParts[i]);
      if (i < reversedParts.length - 1) {
        // Attach 'у' directly without leading space, add trailing space for next word.
        finalBuffer.write("$_conjunction ");
      }
    }

    // Trim any potential final space if the last part ended with one.
    return finalBuffer.toString().trim();
  }

  /// Converts an integer from 0 to 999 into Tajik words.
  /// Correctly attaches the conjunction "у".
  /// (Comments updated slightly for clarity on joining logic)
  String _convertChunk(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    // Use a list to build parts, then join carefully
    List<String> wordsList = [];
    int remainder = n;

    // Handle hundreds
    if (remainder >= 100) {
      int hundredDigit = remainder ~/ 100;
      if (hundredDigit == 1)
        wordsList.add(_hundred); // "сад"
      else
        wordsList
            .add("${_units[hundredDigit]}$_hundred"); // "дусад", "сесад", ...
      remainder %= 100;
    }

    // Handle tens and units (0-99)
    String tensUnitsPart = "";
    if (remainder > 0) {
      if (remainder < 10)
        tensUnitsPart = _units[remainder]; // 1-9
      else if (remainder < 20)
        tensUnitsPart = _teens[remainder - 10]; // 10-19
      else {
        // 20-99
        int tenDigit = remainder ~/ 10;
        int unit = remainder % 10;
        tensUnitsPart = _tens[tenDigit]; // "бист", "сӣ", ...
        if (unit > 0) {
          // Attach 'у' directly to the tens word
          tensUnitsPart += "$_conjunction ${_units[unit]}"; // e.g., "бисту як"
        }
      }
    }

    // Combine hundreds and tens/units part
    if (wordsList.isNotEmpty && tensUnitsPart.isNotEmpty) {
      // Attach 'у' directly to the hundreds part
      return "${wordsList.join(' ')}$_conjunction $tensUnitsPart"; // e.g., "саду як"
    } else if (tensUnitsPart.isNotEmpty) {
      return tensUnitsPart; // Only tens/units exist
    } else {
      return wordsList.join(' '); // Only hundreds exist
    }
  }
}
