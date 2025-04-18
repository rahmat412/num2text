import 'package:decimal/decimal.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/tk_options.dart';
import '../utils/utils.dart';

class Num2TextTK extends Num2TextBase {
  final String _pointSeparator = "point";
  final String _commaSeparator = "comma";
  final String _andOperator = " "; // Space used as separator

  // For numbers less than 1000 and base words
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
    90: "dogson",
    100: "ýüz",
    // Note: 1000 (müň) is treated as a scale below
  };

  // Using BigInt for keys that exceed int limits
  final Map<BigInt, String> _scaleWords = {
    BigInt.from(1000): "müň",
    BigInt.from(1000000): "million",
    BigInt.from(1000000000): "milliard",
    BigInt.from(1000000000000): "trillion",
    BigInt.from(1000000000000000): "quadrillion",
    BigInt.from(1000000000000000000): "quintillion",
    // Use BigInt.parse for numbers larger than what BigInt.from(int) can handle directly if needed,
    // but these fit within standard int literals parsed by from() okay.
    // Explicitly using parse for clarity on very large numbers:
    BigInt.parse('1000000000000000000000'): "sextillion",
    BigInt.parse('1000000000000000000000000'): "septillion",
    // Add more scales here if needed
  };

  final List<BigInt> _sortedScaleKeys = [];

  Num2TextTK() {
    // Sort scale keys descending
    _sortedScaleKeys.addAll(_scaleWords.keys);
    _sortedScaleKeys.sort((a, b) => b.compareTo(a));
  }

  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final TkOptions tkOptions =
        options is TkOptions ? options : const TkOptions();

    try {
      Decimal? decNum = Utils.normalizeNumber(number);

      if (decNum == null) {
        if (number is double) {
          if (number.isNaN) return fallbackOnError ?? "Not a Number";
          if (number.isInfinite)
            return number.isNegative ? "Negative Infinity" : "Infinity";
        }
        return fallbackOnError ?? "Not a Number";
      }

      if (tkOptions.format == Format.year) {
        return _convertYear(decNum, tkOptions);
      }

      if (tkOptions.currency) {
        // Currency often ignores decimals or uses specific rounding in Turkmen text
        BigInt intPart = decNum
            .truncate()
            .toBigInt(); // Use truncate or round based on desired behavior
        return _convertCurrency(intPart, tkOptions);
      }

      String prefix = "";
      if (decNum.isNegative) {
        prefix = "${tkOptions.negativePrefix} ";
        decNum = decNum.abs();
      }

      if (decNum.scale > 0) {
        // has decimal part
        return prefix + _convertDecimal(decNum, tkOptions);
      } else {
        return prefix + _convertInteger(decNum.toBigInt());
      }
    } catch (e) {
      // In case of unexpected errors during conversion logic
      return fallbackOnError ??
          'Error occurred during conversion. ${e.toString()}';
    }
  }

  String _convertInteger(BigInt number) {
    if (number == BigInt.zero) {
      return _smallWords[0]!;
    }

    List<String> parts = [];
    BigInt remainder = number;

    for (BigInt scaleKey in _sortedScaleKeys) {
      if (remainder >= scaleKey) {
        BigInt count = remainder ~/ scaleKey;
        // Convert the count (which must be < 1000 for the next scale down)
        parts.add(
            "${_convertLessThan1000(count.toInt())} ${_scaleWords[scaleKey]!}");
        remainder %= scaleKey;
      }
    }

    if (remainder > BigInt.zero) {
      // Remainder must be < 1000 here
      parts.add(_convertLessThan1000(remainder.toInt()));
    }

    // Handle cases like 1000 -> "bir müň"
    if (parts.length == 1 &&
        number >= BigInt.from(1000) &&
        _scaleWords.containsKey(number) &&
        number ~/ number == BigInt.one) {
      return "${_smallWords[1]!} ${_scaleWords[number]!}";
    }
    // Handle cases like 1_000_000 -> "bir million"
    if (parts.length == 1 &&
        number >= BigInt.from(1000000) &&
        _scaleWords.containsKey(number) &&
        number ~/ number == BigInt.one) {
      String scaleWord = _scaleWords[number]!;
      // Check if the single part is just the scale word (means count was 1 implicitly)
      if (parts[0] == scaleWord) {
        return "${_smallWords[1]!} $scaleWord";
      }
    }

    return parts.join(_andOperator);
  }

  String _convertLessThan1000(int number) {
    if (number == 0)
      return ""; // Return empty, let the main logic handle joining
    if (number >= 1000)
      throw ArgumentError("Number must be less than 1000: $number");

    List<String> parts = [];
    int remainder = number;

    if (remainder >= 100) {
      int hundreds = remainder ~/ 100;
      // Handle "ýüz" vs "iki ýüz", etc.
      parts.add(
        hundreds == 1
            ? _smallWords[100]!
            : "${_smallWords[hundreds]!} ${_smallWords[100]!}",
      );
      remainder %= 100;
    }

    if (remainder > 0) {
      parts.add(_convertLessThan100(remainder));
    }

    return parts.join(_andOperator);
  }

  String _convertLessThan100(int number) {
    if (number == 0) return "";
    if (number >= 100)
      throw ArgumentError("Number must be less than 100: $number");

    if (_smallWords.containsKey(number)) {
      return _smallWords[number]!;
    }

    int tens = (number ~/ 10) * 10;
    int units = number % 10;

    // Ensure unit is not zero before adding it
    if (units == 0) {
      return _smallWords[tens]!;
    } else {
      return "${_smallWords[tens]!} ${_smallWords[units]!}";
    }
  }

  String _convertDecimal(Decimal number, TkOptions options) {
    BigInt integerPart =
        number.truncate().toBigInt(); // Use truncate for integer part
    String fractionalPartStr = number.toString().split('.').last;

    String integerWords = _convertInteger(integerPart);

    String separatorWord = options.decimalSeparator == DecimalSeparator.point
        ? _pointSeparator
        : _commaSeparator; // Default to comma

    List<String> fractionalWords = [];
    for (int i = 0; i < fractionalPartStr.length; i++) {
      fractionalWords.add(_smallWords[int.parse(fractionalPartStr[i])]!);
    }

    // Handle cases like 123.0 -> just "ýüz ýigrimi üç"
    if (fractionalWords.every((w) => w == _smallWords[0])) {
      return integerWords;
    }

    return "$integerWords $separatorWord ${fractionalWords.join(' ')}";
  }

  // Takes BigInt as currency amount is usually integer after rounding/truncation
  String _convertCurrency(BigInt number, TkOptions options) {
    // Per test cases, only main unit seems needed.
    String integerWords = _convertInteger(number);

    // Turkmen 'manat' doesn't typically change form for plural.
    // Using singular form as it's the same.
    String mainUnit = options.currencyInfo.mainUnitSingular;

    // Handle zero case
    if (number == BigInt.zero) {
      return "${_smallWords[0]!} $mainUnit";
    }
    // Handle one case explicitly if needed, though _convertInteger handles it
    // if (number == BigInt.one) {
    //     return "${_smallWords[1]!} $mainUnit";
    // }

    return "$integerWords $mainUnit";
  }

  String _convertYear(Decimal number, TkOptions options) {
    // Year conversion usually ignores decimals
    BigInt yearNum = number.abs().truncate().toBigInt();
    String yearText = _convertInteger(yearNum);

    if (number.isNegative) {
      // Add space before BC for readability
      return "$yearText BC";
    } else {
      // Add space before AD if included
      return options.includeAD ? "$yearText AD" : yearText;
    }
  }
}
