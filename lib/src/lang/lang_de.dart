import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/de_options.dart';
import '../utils/utils.dart';

/// Internal helper for German scale words (Million, Milliarde...).
class _ScaleInfo {
  final String singular;
  final String plural;
  final bool isFeminine; // Affects "ein"/"eine" before scale word
  const _ScaleInfo(this.singular, this.plural, this.isFeminine);
}

/// {@template num2text_de}
/// Converts numbers into German words (`Lang.DE`).
///
/// Implements [Num2TextBase] for German, handling various numeric types.
/// Features:
/// - Correct German grammar ("einundzwanzig", "ein"/"eine"/"eins" handling).
/// - Customizable via [DeOptions] (currency EUR, years, decimals).
/// - Supports large numbers (long scale: Million, Milliarde...).
/// - Returns fallback string on error.
/// {@endtemplate}
class Num2TextDE implements Num2TextBase {
  static const String _zero = "null";
  static const String _hundred = "hundert";
  static const String _thousand = "tausend";
  static const String _oneSingular = "ein"; // Attributive 'one' (non-feminine)
  static const String _oneFeminine = "eine"; // Attributive 'one' (feminine)
  static const String _oneStandalone = "eins"; // Standalone 'one'
  static const String _point = "Punkt";
  static const String _comma = "Komma";
  static const String _and = "und";
  static const String _yearSuffixBC = "v. Chr."; // vor Christus
  static const String _yearSuffixAD = "n. Chr."; // nach Christus
  static const String _infinityPositive = "Unendlich";
  static const String _infinityNegative = "Negativ Unendlich";
  static const String _notANumber = "Keine Zahl";

  static const List<String> _wordsUnder20 = [
    // Index 1 is "eins"
    "null", "eins", "zwei", "drei", "vier", "fünf", "sechs", "sieben", "acht",
    "neun",
    "zehn", "elf", "zwölf", "dreizehn", "vierzehn", "fünfzehn", "sechzehn",
    "siebzehn", "achtzehn", "neunzehn",
  ];
  static const List<String> _wordsTens = [
    "",
    "",
    "zwanzig",
    "dreißig",
    "vierzig",
    "fünfzig",
    "sechzig",
    "siebzig",
    "achtzig",
    "neunzig",
  ];

  /// Scale words (long scale). Key: exponent. Value: [_ScaleInfo].
  static const Map<int, _ScaleInfo> _scaleWords = {
    6: _ScaleInfo("Million", "Millionen", true), // Feminine
    9: _ScaleInfo("Milliarde", "Milliarden", true),
    12: _ScaleInfo("Billion", "Billionen", true),
    15: _ScaleInfo("Billiarde", "Billiarden", true),
    18: _ScaleInfo("Trillion", "Trillionen", true),
    21: _ScaleInfo("Trilliarde", "Trilliarden", true),
    24: _ScaleInfo("Quadrillion", "Quadrillionen", true),
  };
  static final List<int> _sortedScalePowers = _scaleWords.keys.toList()
    ..sort((a, b) => b.compareTo(a)); // Descending

  /// {@macro num2text_base_process}
  ///
  /// Converts [number] to German words using [options].
  /// Uses [fallbackOnError] or "Keine Zahl" on failure.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final DeOptions deOptions =
        options is DeOptions ? options : const DeOptions();
    final String errorMsg = fallbackOnError ?? _notANumber;

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _infinityNegative : _infinityPositive;
      if (number.isNaN) return errorMsg;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorMsg;

    if (decimalValue == Decimal.zero) {
      if (deOptions.currency) {
        final String zeroUnit = deOptions.currencyInfo.mainUnitPlural ??
            deOptions.currencyInfo.mainUnitSingular;
        return "$_zero $zeroUnit"; // e.g., null Euro
      }
      return _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    if (deOptions.format == Format.year) {
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), deOptions);
    } else if (deOptions.currency) {
      textResult = _handleCurrency(absValue, deOptions);
      if (isNegative) textResult = "${deOptions.negativePrefix} $textResult";
    } else {
      textResult = _handleStandardNumber(absValue, deOptions);
      if (isNegative) textResult = "${deOptions.negativePrefix} $textResult";
    }
    return textResult;
  }

  /// Formats an integer as a German calendar year.
  ///
  /// Handles special phrasing for 1100-1999 ("neunzehnhundert...") and AD/BC suffixes.
  /// [year]: Integer year value.
  /// [options]: Formatting options.
  /// Returns the year as German words.
  String _handleYearFormat(int year, DeOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;
    if (absYear == 0) return _zero;

    String yearText;
    if (absYear >= 1100 && absYear < 2000) {
      // "neunzehnhundert..." style
      final int high = absYear ~/ 100, low = absYear % 100;
      // High part (e.g., 19) never uses "eins".
      final String highText =
          _convertInteger(BigInt.from(high), standaloneOneApplies: false);
      if (low == 0)
        yearText = "$highText$_hundred";
      else {
        // Low part (e.g., 84) might use "eins".
        final String lowText =
            _convertInteger(BigInt.from(low), standaloneOneApplies: true);
        yearText = "$highText$_hundred$lowText";
      }
    } else {
      // Standard conversion, might use "eins".
      yearText =
          _convertInteger(BigInt.from(absYear), standaloneOneApplies: true);
    }

    if (isNegative)
      yearText += " $_yearSuffixBC";
    else if (options.includeAD && absYear > 0) yearText += " $_yearSuffixAD";
    return yearText;
  }

  /// Formats a decimal as German currency words (EUR default).
  ///
  /// Uses "ein Euro", "ein Cent" (not "eins"). Rounds if requested.
  /// [absValue]: Absolute decimal currency value.
  /// [options]: Formatting options with [CurrencyInfo].
  /// Returns the currency amount as German words.
  String _handleCurrency(Decimal absValue, DeOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final Decimal val = options.round ? absValue.round(scale: 2) : absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    final BigInt subVal =
        ((val - Decimal.fromBigInt(mainVal)) * Decimal.fromInt(100))
            .round(scale: 0)
            .toBigInt();

    // Handle 0.xx Euro -> "xx Cent"
    if (mainVal == BigInt.zero && subVal > BigInt.zero) {
      final String subText =
          _convertInteger(subVal, standaloneOneApplies: false); // "ein Cent"
      final String subName = subVal == BigInt.one
          ? info.subUnitSingular!
          : (info.subUnitPlural ?? info.subUnitSingular!);
      return '$subText $subName';
    }
    // Handle 0.00 Euro -> "null Euro"
    if (mainVal == BigInt.zero && subVal == BigInt.zero) {
      final String mainName = info.mainUnitPlural ?? info.mainUnitSingular;
      return "$_zero $mainName";
    }

    final List<String> parts = [];
    final String mainText =
        _convertInteger(mainVal, standaloneOneApplies: false); // "ein Euro"
    final String mainName = mainVal == BigInt.one
        ? info.mainUnitSingular
        : (info.mainUnitPlural ?? info.mainUnitSingular);
    parts.add('$mainText $mainName');

    if (subVal > BigInt.zero) {
      final String subText =
          _convertInteger(subVal, standaloneOneApplies: false); // "ein Cent"
      final String subName = subVal == BigInt.one
          ? info.subUnitSingular!
          : (info.subUnitPlural ?? info.subUnitSingular!);
      parts.add(info.separator ?? _and); // Add separator "und" or custom
      parts.add('$subText $subName');
    }
    return parts.join(' ');
  }

  /// Formats a standard decimal number into German words.
  ///
  /// Converts integer and fractional parts. Uses "Komma" or "Punkt". Fractional part read digit by digit (using "eins").
  /// [absValue]: Absolute decimal value.
  /// [options]: Formatting options.
  /// Returns the number as German words.
  String _handleStandardNumber(Decimal absValue, DeOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    // Integer part might end in standalone "eins".
    final bool useStandaloneOne = _isStandaloneOne(integerPart);
    final String integerWords = (integerPart == BigInt.zero &&
            absValue != Decimal.zero)
        ? _zero
        : _convertInteger(integerPart, standaloneOneApplies: useStandaloneOne);

    String fractionalWords = '';
    if (!absValue.isInteger) {
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          separatorWord = _point;
          break;
        default:
          separatorWord = _comma;
          break;
      }

      String digitsStr = absValue
          .toString()
          .split('.')
          .last
          .replaceAll(RegExp(r'0+$'), ''); // Get digits, trim trailing zeros
      if (digitsStr.isNotEmpty) {
        final List<String> digitWords = digitsStr.split('').map((digit) {
          final int? i = int.tryParse(digit);
          // Digits after separator always use standalone "eins" for 1.
          return (i != null && i >= 0 && i <= 9) ? _wordsUnder20[i] : '?';
        }).toList();
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Checks if '1' should be "eins" (standalone).
  /// True if number is 1 or ends in 1, unless it's part of 11 or "einund...".
  /// [n]: The integer to check.
  bool _isStandaloneOne(BigInt n) {
    if (n <= BigInt.zero) return false;
    if (n == BigInt.one) return true;
    final BigInt lastDigit = n % BigInt.from(10);
    if (lastDigit != BigInt.one) return false;
    final BigInt tensUnits = n % BigInt.from(100);
    if (tensUnits == BigInt.from(11)) return false; // elf
    if (tensUnits > BigInt.from(20)) return false; // einund...
    return true; // e.g., 101, 1001
  }

  /// Converts a non-negative integer to German words, handling scales.
  ///
  /// Uses long scale. Distinguishes "ein"/"eine"/"eins" based on context.
  /// [n]: Non-negative integer.
  /// [standaloneOneApplies]: If true, the least significant '1' uses "eins".
  /// Returns the integer as German words.
  /// @throws ArgumentError if [n] is negative.
  String _convertInteger(BigInt n, {required bool standaloneOneApplies}) {
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n == BigInt.zero) return _zero;
    if (n == BigInt.one)
      return standaloneOneApplies ? _oneStandalone : _oneSingular;
    if (n < BigInt.from(1000000))
      return _convertUnderMillion(n.toInt(),
          standaloneOneApplies: standaloneOneApplies);

    final List<String> resultParts = [];
    BigInt remaining = n;
    bool firstSegment = true;

    for (final int power in _sortedScalePowers) {
      final BigInt scaleDivisor = BigInt.from(10).pow(power);
      if (remaining >= scaleDivisor) {
        final BigInt count = remaining ~/ scaleDivisor;
        final _ScaleInfo scaleInfo = _scaleWords[power]!;
        // Determine 'one' form before scale word
        final String countText = (count == BigInt.one)
            ? (scaleInfo.isFeminine ? _oneFeminine : _oneSingular)
            // Count before scale never ends in standalone 'eins'
            : _convertInteger(count, standaloneOneApplies: false);
        final String scaleWord =
            (count == BigInt.one) ? scaleInfo.singular : scaleInfo.plural;

        if (!firstSegment) resultParts.add(" ");
        resultParts.add("$countText $scaleWord");
        firstSegment = false;
        remaining %= scaleDivisor;
      }
    }

    if (remaining > BigInt.zero) {
      // Remaining part < 1 Million
      if (!firstSegment) resultParts.add(" ");
      // Final part might need standalone 'eins'
      resultParts.add(_convertUnderMillion(remaining.toInt(),
          standaloneOneApplies: standaloneOneApplies));
    }
    return resultParts.join('');
  }

  /// Converts integer 0 to 999,999 to German words. Helper for [_convertInteger].
  ///
  /// [n]: Integer (0 <= n < 1,000,000).
  /// [standaloneOneApplies]: If true, final '1' uses "eins".
  String _convertUnderMillion(int n, {required bool standaloneOneApplies}) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000000)
      throw ArgumentError("Input must be 0-999,999: $n");
    if (n == 1) return standaloneOneApplies ? _oneStandalone : _oneSingular;

    final List<String> parts = [];
    int rem = n;
    if (rem >= 1000) {
      // Thousands part
      final int thousands = rem ~/ 1000;
      // Part before "tausend" never ends in standalone "eins".
      parts.add(_convertChunk(thousands, standaloneOneApplies: false));
      parts.add(_thousand);
      rem %= 1000;
    }
    if (rem > 0) {
      // 0-999 part
      // This is the final part, apply the original standalone rule.
      parts.add(_convertChunk(rem, standaloneOneApplies: standaloneOneApplies));
    }
    return parts.join(''); // No space needed, concatenation works
  }

  /// Converts integer 0-999 to German words ("einundzwanzig" structure).
  ///
  /// Base conversion for chunks. Handles "ein"/"eins".
  /// [n]: Integer chunk (0-999).
  /// [standaloneOneApplies]: If true, final '1' uses "eins".
  String _convertChunk(int n, {required bool standaloneOneApplies}) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");
    if (n == 1) return standaloneOneApplies ? _oneStandalone : _oneSingular;

    final List<String> words = [];
    int rem = n;

    if (rem >= 100) {
      // Hundreds
      // Use "ein" for 100
      words.add(rem ~/ 100 == 1 ? _oneSingular : _wordsUnder20[rem ~/ 100]);
      words.add(_hundred);
      rem %= 100;
    }
    if (rem > 0) {
      // Tens and units
      if (rem == 1)
        words.add(standaloneOneApplies ? _oneStandalone : _oneSingular);
      else if (rem < 20)
        words.add(_wordsUnder20[rem]);
      else {
        // 20-99 structure: unit + und + ten
        final int unit = rem % 10;
        final String tens = _wordsTens[rem ~/ 10];
        if (unit > 0) {
          // Unit in "einund..." always uses "ein".
          words.add(unit == 1 ? _oneSingular : _wordsUnder20[unit]);
          words.add(_and);
        }
        words.add(tens);
      }
    }
    return words.join(''); // Concatenate parts
  }
}
