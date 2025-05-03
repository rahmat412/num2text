import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/sw_options.dart';
import '../utils/utils.dart';

/// {@template num2text_sw}
/// Converts numbers to Swahili words (`Lang.SW`).
///
/// Implements [Num2TextBase] for Swahili. Handles cardinals, currency, years,
/// decimals, negatives, and large numbers (including "laki").
/// Uses "na" conjunction appropriately. Customizable via [SwOptions].
/// {@endtemplate}
class Num2TextSW implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "sifuri";
  static const String _thousand = "elfu";
  static const String _lakh = "laki"; // 100,000
  static const String _na = "na"; // "and" conjunction
  static const String _point = "pointi"; // For '.'
  static const String _comma = "koma"; // For ','
  static const String _yearSuffixBC = "KK"; // Kabla ya Kristo
  static const String _yearSuffixAD = "BK"; // Baada ya Kristo

  static const List<String> _wordsUnder20 = [
    _zero,
    "moja",
    "mbili",
    "tatu",
    "nne",
    "tano",
    "sita",
    "saba",
    "nane",
    "tisa",
    "kumi",
    "kumi na moja",
    "kumi na mbili",
    "kumi na tatu",
    "kumi na nne",
    "kumi na tano",
    "kumi na sita",
    "kumi na saba",
    "kumi na nane",
    "kumi na tisa",
  ];
  static const List<String> _wordsTens = [
    "",
    "",
    "ishirini",
    "thelathini",
    "arobaini",
    "hamsini",
    "sitini",
    "sabini",
    "themanini",
    "tisini",
  ];
  static const List<String> _wordsHundreds = [
    // Combined form, e.g., "mia moja"
    "", "mia moja", "mia mbili", "mia tatu", "mia nne", "mia tano",
    "mia sita", "mia saba", "mia nane", "mia tisa",
  ];
  static const List<String> _scaleWords = [
    // Index = power of 1000
    "", _thousand, "milioni", "bilioni", "trilioni", "kwadrilioni",
    "kwintilioni", "sekstilioni", "septilioni",
  ];

  static final BigInt _bi1000 = BigInt.from(1000);
  static final BigInt _bi100k = BigInt.from(100000); // Laki
  static final BigInt _bi1M = BigInt.from(1000000);
  static final Decimal _dec100 = Decimal.fromInt(100);

  /// Processes the given [number] into Swahili words.
  ///
  /// Main entry point. Normalizes input, handles special cases (zero, inf, NaN),
  /// manages sign, and delegates to specific handlers based on [SwOptions].
  ///
  /// @param number The number to convert.
  /// @param options Optional [SwOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Swahili words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final SwOptions swOptions =
        options is SwOptions ? options : const SwOptions();
    final String fallback = fallbackOnError ?? "Si Nambari";

    if (number is double) {
      if (number.isInfinite) return number.isNegative ? "Hasi Ukomo" : "Ukomo";
      if (number.isNaN) return fallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return fallback;

    if (decimalValue == Decimal.zero) {
      return swOptions.currency
          ? "${swOptions.currencyInfo.mainUnitSingular} $_zero" // Use singular for zero currency
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    if (swOptions.format == Format.year) {
      textResult = _handleYearFormat(
          absValue.truncate().toBigInt(), isNegative, swOptions);
    } else {
      textResult = swOptions.currency
          ? _handleCurrency(absValue, swOptions)
          : _handleStandardNumber(absValue, swOptions);
      // Apply negative prefix only if not handled by year format
      if (isNegative) {
        textResult = "${swOptions.negativePrefix} $textResult";
      }
    }
    return textResult.trim();
  }

  /// Converts an integer year to Swahili words with optional era suffixes.
  ///
  /// Omits "na" between major scales (e.g., "elfu moja mia tisa").
  /// Appends "KK" (BC) or "BK" (AD).
  ///
  /// @param absYearValue Absolute year value.
  /// @param isOriginalNegative True if original year was negative.
  /// @param options Formatting options.
  /// @return The year as Swahili words.
  String _handleYearFormat(
      BigInt absYearValue, bool isOriginalNegative, SwOptions options) {
    // Years typically omit 'na' between scales.
    String yearText = _convertInteger(absYearValue, includeNa: false);

    if (isOriginalNegative)
      yearText += " $_yearSuffixBC";
    else if (options.includeAD) yearText += " $_yearSuffixAD";

    return yearText;
  }

  /// Converts a non-negative [Decimal] to Swahili currency words.
  ///
  /// Uses [SwOptions.currencyInfo] for units. Rounds if [SwOptions.round].
  /// Includes "na" conjunction.
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Swahili words.
  String _handleCurrency(Decimal absValue, SwOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final Decimal val = options.round ? absValue.round(scale: 2) : absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    final BigInt subVal =
        ((val - val.truncate()) * _dec100).round(scale: 0).toBigInt();

    final StringBuffer buffer = StringBuffer();

    // Handle main part (always include if subunit is zero, or if main value > 0)
    if (mainVal > BigInt.zero || subVal == BigInt.zero) {
      final String mainText = _convertInteger(mainVal, includeNa: true);
      final String mainUnit = (mainVal == BigInt.one)
          ? info.mainUnitSingular
          : (info.mainUnitPlural ?? info.mainUnitSingular);
      buffer.write('$mainUnit $mainText'); // e.g., "shilingi moja"
    }

    // Handle subunit part
    if (subVal > BigInt.zero && info.subUnitSingular != null) {
      if (buffer.isNotEmpty) {
        // Add separator if main part exists
        buffer.write(' ${info.separator ?? _na} ');
      }
      final String subText = _convertInteger(subVal, includeNa: true);
      final String subUnit = (subVal == BigInt.one)
          ? info.subUnitSingular!
          : (info.subUnitPlural ?? info.subUnitSingular!);
      buffer.write('$subUnit $subText'); // e.g., "senti hamsini"
    }

    // Catch exact zero after rounding/processing
    if (buffer.isEmpty && mainVal == BigInt.zero && subVal == BigInt.zero) {
      return "${info.mainUnitPlural ?? info.mainUnitSingular} $_zero";
    }

    return buffer.toString();
  }

  /// Converts a non-negative standard [Decimal] number to Swahili words.
  ///
  /// Handles integer and fractional parts. Uses [SwOptions.decimalSeparator].
  /// Uses "na" for integer part. Fractional digits converted individually.
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Swahili words.
  String _handleStandardNumber(Decimal absValue, SwOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part using standard 'na' rules.
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, includeNa: true);

    if (fractionalPart > Decimal.zero) {
      String sepWord;
      switch (options.decimalSeparator ?? DecimalSeparator.period) {
        // Default point
        case DecimalSeparator.comma:
          sepWord = _comma;
          break;
        default:
          sepWord = _point;
          break; // Point/Period
      }

      String fractionalDigits = absValue.toString().split('.').last;
      List<String> digitWords = fractionalDigits.split('').map((digit) {
        final int d = int.parse(digit);
        return (d >= 0 && d <= 9) ? _wordsUnder20[d] : '?';
      }).toList();

      return '$integerWords $sepWord ${digitWords.join(' ')}';
    } else {
      return integerWords;
    }
  }

  /// Converts a non-negative [BigInt] into Swahili words.
  ///
  /// Breaks number by millions, lakhs, thousands, and remaining chunk.
  /// Uses `includeNa` to control conjunction between scales.
  ///
  /// @param n Non-negative integer.
  /// @param includeNa Whether to include "na" between scales (default true).
  /// @return Integer as Swahili words.
  String _convertInteger(BigInt n, {bool includeNa = true}) {
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n == BigInt.zero)
      return includeNa ? _zero : ""; // Handle zero based on context

    // Use simpler structure for numbers < 1 Million for clarity
    if (n < _bi1M) {
      return _convertUnderMillion(n, includeNa: includeNa);
    }

    // Handle numbers >= 1 Million using scale words
    List<String> parts = [];
    BigInt currentRemainder = n;
    final String separator = includeNa ? ' $_na ' : ' ';

    // Iterate scales from highest down (million, billion, etc.)
    for (int i = _scaleWords.length - 1; i >= 2; i--) {
      // Start from index 2 (million)
      BigInt scalePower = _bi1000.pow(i);
      if (currentRemainder >= scalePower) {
        BigInt chunk = currentRemainder ~/ scalePower;
        currentRemainder %= scalePower;
        // Convert the multiplier part using standard 'na' rules
        String chunkText = _convertUnderMillion(chunk, includeNa: true);
        parts.add('${_scaleWords[i]} $chunkText');
      }
    }

    // Process remaining part (under million)
    if (currentRemainder > BigInt.zero) {
      parts.add(_convertUnderMillion(currentRemainder, includeNa: true));
    }

    return parts.join(separator);
  }

  /// Converts a non-negative integer under 1,000,000 into Swahili words.
  ///
  /// Handles lakhs (100k), thousands, and the final 0-999 chunk.
  ///
  /// @param n Integer (0 <= n < 1,000,000).
  /// @param includeNa Whether to include "na" between parts.
  /// @return Number as Swahili words.
  String _convertUnderMillion(BigInt n, {bool includeNa = true}) {
    if (n < BigInt.zero || n >= _bi1M) {
      throw ArgumentError("Input must be 0 <= n < 1,000,000: $n");
    }
    if (n == BigInt.zero) return ""; // Empty for zero within larger number

    final StringBuffer buffer = StringBuffer();
    BigInt remainder = n;
    final String separator = includeNa ? ' $_na ' : ' ';

    // Handle Lakhs (100k)
    if (remainder >= _bi100k) {
      BigInt lakhs = remainder ~/ _bi100k;
      remainder %= _bi100k;
      // Lakhs prefix uses standard 'na' rules internally
      buffer.write("$_lakh ${_convertUnderMillion(lakhs, includeNa: true)}");
    }

    // Handle Thousands
    if (remainder >= _bi1000) {
      BigInt thousands = remainder ~/ _bi1000;
      remainder %= _bi1000;
      if (buffer.isNotEmpty) buffer.write(separator);
      // Thousands prefix uses standard 'na' rules internally
      buffer.write(
          "$_thousand ${_convertUnderThousand(thousands, includeHundredsTensNa: true)}");
    }

    // Handle final 0-999 chunk
    if (remainder > BigInt.zero) {
      if (buffer.isNotEmpty) buffer.write(separator);
      buffer
          .write(_convertUnderThousand(remainder, includeHundredsTensNa: true));
    }

    return buffer.toString();
  }

  /// Converts an integer from 0 to 999 into Swahili words.
  ///
  /// Handles hundreds, tens, and units, inserting "na" where appropriate.
  ///
  /// @param n Integer chunk (0-999).
  /// @param includeHundredsTensNa Whether to include "na" between hundreds and tens/units.
  /// @return Chunk as Swahili words, or empty string if [n] is 0.
  String _convertUnderThousand(BigInt n, {bool includeHundredsTensNa = true}) {
    if (n < BigInt.zero || n >= _bi1000) {
      throw ArgumentError("Input must be 0 <= n < 1000: $n");
    }
    if (n == BigInt.zero) return ""; // Empty for zero chunk

    int num = n.toInt();
    final StringBuffer buffer = StringBuffer();
    int remainder = num;
    final String separator = includeHundredsTensNa ? ' $_na ' : ' ';

    // Handle hundreds
    if (remainder >= 100) {
      buffer.write(_wordsHundreds[remainder ~/ 100]); // e.g., "mia moja"
      remainder %= 100;
    }

    // Handle tens and units (0-99)
    if (remainder > 0) {
      if (buffer.isNotEmpty) buffer.write(separator);
      if (remainder < 20) {
        buffer.write(_wordsUnder20[remainder]); // 1-19
      } else {
        buffer.write(_wordsTens[remainder ~/ 10]); // 20, 30...
        int unit = remainder % 10;
        if (unit > 0) {
          buffer.write(' $_na '); // Always 'na' between tens and units > 0
          buffer.write(_wordsUnder20[unit]);
        }
      }
    }
    return buffer.toString();
  }
}
