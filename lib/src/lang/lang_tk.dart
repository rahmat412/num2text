import 'package:decimal/decimal.dart';

// Assuming CurrencyInfo is used via TkOptions
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/tk_options.dart';
import '../utils/utils.dart';

/// {@template num2text_tk}
/// Converts numbers to Turkmen words (`Lang.TK`).
///
/// Implements [Num2TextBase] for the Turkmen language. Handles various numeric types
/// (`int`, `double`, `BigInt`, `Decimal`, `String`) via its [process] method.
///
/// Supports cardinal numbers, currency, years, decimals, and negatives.
/// Uses standard Turkmen scale words (müň, million, milliard, etc.).
/// Customization is available via [TkOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextTK extends Num2TextBase {
  /// Decimal separator "point".
  final String _pointSeparator =
      "point"; // Consider using a Turkmen word like "nokat"?
  /// Decimal separator "comma".
  final String _commaSeparator =
      "comma"; // Consider using a Turkmen word like "otyr"?
  /// Separator between number parts (e.g., "on bäş"). Usually a space.
  final String _andOperator = " ";

  /// Words for 0-10, tens (20-90), and 100.
  final Map<int, String> _smallWords = {
    0: "nol",
    1: "bir",
    2: "iki",
    3: "üç",
    4: "dört",
    5: "bäş",
    6: "alty",
    7: "ýedi",
    8: "sekiz",
    9: "dokuz",
    10: "on",
    20: "ýigrimi",
    30: "otuz",
    40: "kyrk",
    50: "elli",
    60: "altmyş",
    70: "ýetmiş",
    80: "segsen",
    90: "togsan",
    100: "ýüz",
  };

  /// Scale words (thousand, million, etc.). Keys are powers of 1000.
  final Map<BigInt, String> _scaleWords = {
    BigInt.from(1000): "müň",
    BigInt.from(1000000): "million",
    BigInt.from(1000000000): "milliard",
    BigInt.from(1000000000000): "trillion",
    BigInt.from(1000000000000000): "kwadrillion",
    BigInt.from(1000000000000000000): "kwintillion",
    BigInt.parse('1000000000000000000000'): "sekstillion", // 10^21
    BigInt.parse('1000000000000000000000000'): "septillion", // 10^24
  };

  /// Scale keys sorted descending for processing large numbers.
  final List<BigInt> _sortedScaleKeys = [];

  /// Initializes the converter, sorting scale keys.
  Num2TextTK() {
    _sortedScaleKeys.addAll(_scaleWords.keys);
    _sortedScaleKeys.sort((a, b) => b.compareTo(a)); // Sort descending.
  }

  /// Processes the given [number] and converts it to Turkmen words.
  ///
  /// {@template num2text_process_intro}
  /// Handles `int`, `double`, `BigInt`, `Decimal`, `String` inputs by normalizing to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [TkOptions] for customization (currency, year format, decimals, AD/BC, negative prefix).
  /// Defaults apply if [options] is null or not [TkOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or default error messages on failure.
  /// Uses a try-catch block for general conversion errors.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [TkOptions] settings.
  /// @param fallbackOnError Optional custom error string.
  /// @return The number as Turkmen words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final TkOptions tkOptions =
        options is TkOptions ? options : const TkOptions();
    final String errorFallback =
        fallbackOnError ?? "San Däl"; // Default fallback "Not a Number".

    try {
      // Handle special double values.
      if (number is double) {
        if (number.isNaN) return errorFallback;
        if (number.isInfinite) {
          return number.isNegative
              ? "Minus Tükeniksizlik"
              : "Tükeniksizlik"; // Consider consts?
        }
      }

      Decimal? decNum = Utils.normalizeNumber(number);
      if (decNum == null) return errorFallback;

      // Delegate based on options.
      if (tkOptions.format == Format.year) {
        return _convertYear(decNum, tkOptions);
      }
      if (tkOptions.currency) {
        return _convertCurrency(decNum, tkOptions);
      }

      // Handle standard numbers (integer or decimal).
      String prefix = "";
      if (decNum.isNegative) {
        prefix = "${tkOptions.negativePrefix} "; // Add negative prefix.
        decNum = decNum.abs(); // Work with absolute value.
      }

      // Check if it has a fractional part.
      if (decNum.scale > 0 && !decNum.isInteger) {
        return prefix + _convertDecimal(decNum, tkOptions);
      } else {
        // Convert as integer if no fractional part or scale is 0.
        return prefix + _convertInteger(decNum.toBigInt());
      }
    } catch (e) {
      // General conversion error fallback.
      return errorFallback;
    }
  }

  /// Converts an integer year to Turkmen words, handling AD/BC suffixes.
  ///
  /// Uses [TkOptions.includeAD] to control AD suffix inclusion.
  ///
  /// @param number The decimal representation of the year.
  /// @param options Formatting options.
  /// @return The year as Turkmen words.
  String _convertYear(Decimal number, TkOptions options) {
    // Years are integers. Work with absolute value for conversion part.
    BigInt yearNum = number.abs().truncate().toBigInt();
    String yearText = _convertInteger(yearNum);
    String suffix = "";

    // Determine suffix based on original sign and options.
    if (number.isNegative) {
      suffix = " b.e.öň"; // Before Common Era (BC/BCE). Consider const.
    } else if (options.includeAD) {
      suffix = " b.e."; // Common Era (AD/CE). Consider const.
    }

    // Handle year zero specifically.
    if (yearNum == BigInt.zero) {
      return "${_smallWords[0]!}$suffix";
    }

    return "$yearText$suffix";
  }

  /// Converts a [Decimal] value to Turkmen currency words.
  ///
  /// Uses [TkOptions.currencyInfo] for unit names. Rounds to 2 decimal places.
  /// Handles main and subunit parts.
  ///
  /// @param number The currency value.
  /// @param options Formatting options.
  /// @return Currency value as Turkmen words.
  String _convertCurrency(Decimal number, TkOptions options) {
    // Round to 2 decimal places for currency.
    final Decimal roundedNumber = number.round(scale: 2);

    // Determine sign and work with absolute value for conversion.
    if (roundedNumber.isNegative) {
      // Note: original code didn't apply prefix here, but semantically makes sense.
      // Let's assume the caller `process` handles the prefix for currency too.
      // Working with abs value for conversion:
      // roundedNumber = roundedNumber.abs();
    }
    // Sticking to original logic: prefix handled in `process`. Convert abs value.
    final Decimal absRoundedNumber = roundedNumber.abs();

    // Separate integer (main unit) and fractional (subunit) parts.
    BigInt integerPart = absRoundedNumber.truncate().toBigInt();
    // Calculate subunit value (e.g., tenge).
    int fractionalPartInt = ((absRoundedNumber - absRoundedNumber.truncate()) *
            Decimal.fromInt(100))
        .toBigInt()
        .toInt();

    // Convert parts to words.
    String integerWords = _convertInteger(integerPart);
    String fractionalWords = _convertInteger(BigInt.from(fractionalPartInt));

    // Get currency unit names.
    String mainUnit = options
        .currencyInfo.mainUnitSingular; // Assuming singular form is primary.
    String subUnit = options.currencyInfo.subUnitSingular ?? "";

    List<String> parts = [];

    // Add main unit part if non-zero.
    if (integerPart > BigInt.zero) {
      parts.add("$integerWords $mainUnit");
    }

    // Add subunit part if non-zero.
    if (fractionalPartInt > 0) {
      // Original code used _convertInteger, which handles "bir".
      parts.add("$fractionalWords $subUnit");
    }

    // Handle zero amount.
    if (integerPart == BigInt.zero && fractionalPartInt == 0) {
      return "${_smallWords[0]!} $mainUnit"; // "nol [main unit]"
    }

    // Handle only subunit amount (e.g., 0.50).
    if (integerPart == BigInt.zero && fractionalPartInt > 0) {
      return "$fractionalWords $subUnit";
    }

    // Combine main and subunit parts with a space.
    return parts.join(' ');
  }

  /// Converts a non-negative decimal number to Turkmen words.
  ///
  /// Converts integer and fractional parts, separated by "point" or "comma".
  /// Fractional part converted digit by digit.
  ///
  /// @param number Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Turkmen words.
  String _convertDecimal(Decimal number, TkOptions options) {
    BigInt integerPart = number.truncate().toBigInt();
    // Get fractional digits accurately.
    String fractionalPartStr = number.toString().split('.').last;

    // Remove trailing zeros, unless the value is integer like (e.g. "1.0").
    if (fractionalPartStr != '0') {
      fractionalPartStr = fractionalPartStr.replaceAll(RegExp(r'0+$'), '');
    }
    // If after removing trailing zeros nothing is left, or it was just "0", convert as integer.
    if (fractionalPartStr.isEmpty || fractionalPartStr == '0') {
      return _convertInteger(integerPart);
    }

    // Convert integer part.
    String integerWords = _convertInteger(integerPart);

    // Determine decimal separator word.
    String separatorWord;
    switch (options.decimalSeparator) {
      case DecimalSeparator.point:
      case DecimalSeparator.period:
        separatorWord = _pointSeparator;
        break;
      case DecimalSeparator.comma:
      default:
        separatorWord = _commaSeparator;
        break; // Default to comma.
    }

    // Convert fractional part digit by digit.
    List<String> fractionalWords = [];
    for (int i = 0; i < fractionalPartStr.length; i++) {
      fractionalWords.add(_smallWords[int.parse(fractionalPartStr[i])]!);
    }

    // Combine parts.
    return "$integerWords $separatorWord ${fractionalWords.join(' ')}";
  }

  /// Converts a non-negative [BigInt] into Turkmen words using scale words.
  ///
  /// Handles special case for exact scale values (e.g., 1000 -> "bir müň").
  /// Breaks number into chunks based on descending scale keys.
  ///
  /// @param number Non-negative integer.
  /// @return Integer as Turkmen words.
  String _convertInteger(BigInt number) {
    if (number == BigInt.zero) return _smallWords[0]!; // "nol"

    List<String> parts = [];
    BigInt remainder = number;

    // Handle exact scale match like 1000, 1,000,000 etc. -> "bir müň", "bir million".
    if (_scaleWords.containsKey(number) && number >= BigInt.from(1000)) {
      return "${_smallWords[1]!} ${_scaleWords[number]!}";
    }

    // Process by largest scale factors first.
    for (BigInt scaleKey in _sortedScaleKeys) {
      if (remainder >= scaleKey) {
        BigInt count = remainder ~/ scaleKey; // How many of this scale unit.
        remainder %= scaleKey; // Remainder for next lower scale.

        // Convert the count (which is < 1000 for the next scale down).
        String countWords = _convertLessThan1000(count.toInt());

        // Combine count words and scale word.
        // Handle "bir müň" vs "iki müň".
        if (count == BigInt.one && scaleKey >= BigInt.from(1000)) {
          // Use "bir" only for scales >= 1000.
          parts.add("${_smallWords[1]!} ${_scaleWords[scaleKey]!}");
        } else if (count > BigInt.zero) {
          parts.add("$countWords ${_scaleWords[scaleKey]!}");
        }
        // If count is zero for this scale, skip.
      }
    }

    // Convert any remaining part less than 1000.
    if (remainder > BigInt.zero) {
      parts.add(_convertLessThan1000(remainder.toInt()));
    }

    // Join all parts with the defined operator (space).
    return parts.join(_andOperator);
  }

  /// Converts an integer between 0 and 999 into Turkmen words.
  ///
  /// @param number Integer chunk (0-999).
  /// @return Chunk as Turkmen words, or empty string if 0.
  /// @throws ArgumentError if number is outside 0-999.
  String _convertLessThan1000(int number) {
    if (number == 0) return "";
    if (number >= 1000 || number < 0)
      throw ArgumentError("Input must be 0-999: $number");

    List<String> parts = [];
    int remainder = number;

    // Handle hundreds place.
    if (remainder >= 100) {
      int hundreds = remainder ~/ 100;
      // 100 is "ýüz", 200+ is "[digit] ýüz".
      parts.add(
        hundreds == 1
            ? _smallWords[100]!
            : "${_smallWords[hundreds]!} ${_smallWords[100]!}",
      );
      remainder %= 100;
    }

    // Handle remaining part (0-99).
    if (remainder > 0) {
      parts.add(_convertLessThan100(remainder));
    }

    // Join hundreds and tens/units parts.
    return parts.join(_andOperator);
  }

  /// Converts an integer between 0 and 99 into Turkmen words.
  ///
  /// @param number Integer chunk (0-99).
  /// @return Chunk as Turkmen words, or empty string if 0.
  /// @throws ArgumentError if number is outside 0-99.
  String _convertLessThan100(int number) {
    if (number == 0) return "";
    if (number >= 100 || number < 0)
      throw ArgumentError("Input must be 0-99: $number");

    // Direct lookup for 0-10, 20, 30...90.
    if (_smallWords.containsKey(number)) {
      return _smallWords[number]!;
    }

    // Combine tens and units (e.g., "ýigrimi bäş").
    int tens = (number ~/ 10) * 10; // Get the tens part (20, 30...).
    int units = number % 10; // Get the units part (1-9).

    // Should not happen due to check above, but defensively:
    // if (units == 0) return _smallWords[tens]!;

    return "${_smallWords[tens]!} ${_smallWords[units]!}";
  }
}
