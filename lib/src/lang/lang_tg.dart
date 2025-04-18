import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/tg_options.dart';
import '../utils/utils.dart';

/// {@template num2text_tg}
/// The Tajik language (Lang.TG) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Tajik word representation following standard Tajik grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [TgOptions.currencyInfo], defaults to [CurrencyInfo.tjs]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers.
/// Invalid inputs result in a fallback message (defaults to "рақам нест").
///
/// Behavior can be customized using [TgOptions].
/// {@endtemplate}
class Num2TextTG implements Num2TextBase {
  // --- Internal constants ---
  static const String _negative = "минус"; // Word for "minus"
  static const String _zero = "нол"; // Word for "zero"
  static const String _point = "нуқта"; // Word for "point" (decimal separator)
  static const String _comma =
      "вергул"; // Word for "comma" (alternative decimal separator)
  static const String _conjunction =
      "у"; // Conjunction used between number parts (e.g., hundreds AND tens)
  static const String _currencySeparator =
      " ва "; // Separator between main and subunit currency names (e.g., "and")
  static const String _yearSuffixAD =
      " м."; // Suffix for AD/CE years ("милодӣ")
  static const String _yearSuffixBC =
      " п.м."; // Suffix for BC/BCE years ("пеш аз милод")
  static const String _izofatSuffix =
      "и"; // Izofat suffix added before year suffixes

  // Internal fallback messages for non-standard numbers
  static const String _infinityInternal = "беохир"; // Word for "infinity"
  static const String _negativeInfinityInternal =
      "$_negative $_infinityInternal"; // Word for "negative infinity"
  static const String _notANumberInternal =
      "рақам нест"; // Word for "not a number" (NaN)

  // --- Number Words ---
  // Units (1-9)
  static const List<String> _units = [
    "", // Index 0 is unused
    "як", // 1
    "ду", // 2
    "се", // 3
    "чор", // 4
    "панҷ", // 5
    "шаш", // 6
    "ҳафт", // 7
    "ҳашт", // 8
    "нӯҳ", // 9
  ];
  // Teens (10-19)
  static const List<String> _teens = [
    "даҳ", // 10
    "ёздаҳ", // 11
    "дувоздаҳ", // 12
    "сездаҳ", // 13
    "чордаҳ", // 14
    "понздаҳ", // 15
    "шонздаҳ", // 16
    "ҳабдаҳ", // 17
    "ҳаждаҳ", // 18
    "нуздаҳ", // 19
  ];
  // Tens (20, 30... 90)
  static const List<String> _tens = [
    "", // Index 0 is unused
    "", // Index 1 is unused (covered by teens)
    "бист", // 20
    "сӣ", // 30
    "чил", // 40
    "панҷоҳ", // 50
    "шаст", // 60
    "ҳафтод", // 70
    "ҳаштод", // 80
    "навад", // 90
  ];
  // Hundred
  static const String _hundred = "сад"; // 100

  // Scale words (thousand, million, billion, etc.)
  static const List<String> _scaleWords = [
    "", // Base scale (units/hundreds)
    "ҳазор", // 10^3
    "миллион", // 10^6
    "миллиард", // 10^9
    "триллион", // 10^12
    "квадриллион", // 10^15
    "квинтиллион", // 10^18
    "секстиллион", // 10^21
    "септиллион", // 10^24
    // Add more scales if needed
  ];

  /// Processes the given [number] and converts it to Tajik words.
  ///
  /// - [number]: The number to convert (int, double, BigInt, Decimal, String).
  /// - [options]: Optional [TgOptions] for customization (currency, year, etc.).
  /// - [fallbackOnError]: Optional fallback string if conversion fails.
  /// Returns the number in Tajik words or a fallback string on error.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure correct options type or use default
    final TgOptions tgOptions =
        options is TgOptions ? options : const TgOptions();
    // Determine the fallback string for errors
    final String errorFallback = fallbackOnError ?? _notANumberInternal;

    String result;

    // Handle special double values first
    if (number is double) {
      if (number.isInfinite) {
        result =
            number.isNegative ? _negativeInfinityInternal : _infinityInternal;
        // Return title-cased infinity representation
        return result.toTitleCase;
      }
      if (number.isNaN) {
        // Return fallback for NaN
        return errorFallback.toTitleCase;
      }
    }

    // Normalize the input number to Decimal for consistent handling
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // If normalization failed (invalid input), return fallback
    if (decimalValue == null) {
      return errorFallback.toTitleCase;
    }

    // Handle zero separately
    if (decimalValue == Decimal.zero) {
      if (tgOptions.currency) {
        // Format zero for currency
        result = "$_zero ${tgOptions.currencyInfo.mainUnitSingular}";
      } else {
        // Standard zero representation
        result = _zero;
      }
      return result;
    }

    // Determine sign and work with the absolute value
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    // Delegate to specific handlers based on options
    if (tgOptions.format == Format.year) {
      // Convert year using specific logic
      int yearInt =
          decimalValue.truncate().toBigInt().toInt(); // Years are integers
      textResult = _handleYearFormat(yearInt, tgOptions);
    } else {
      if (tgOptions.currency) {
        // Convert currency using currency-specific logic
        textResult = _handleCurrency(absValue, tgOptions);
      } else {
        // Convert standard number (potentially with decimals)
        textResult = _handleStandardNumber(absValue, tgOptions);
      }
      // Prepend negative prefix if necessary
      if (isNegative) {
        textResult = "${tgOptions.negativePrefix} $textResult";
      }
    }

    // Return the final textual representation
    return textResult;
  }

  /// Converts a year integer into Tajik words, handling AD/BC suffixes.
  String _handleYearFormat(int year, TgOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;
    String yearText;

    // Special handling for years between 1000 and 1999 (common phrasing)
    if (absYear > 1000 && absYear < 2000) {
      int remainder = absYear % 1000;
      if (remainder == 0) {
        // For exact thousands like 1000
        yearText = _convertInteger(BigInt.from(absYear), isYear: true);
      } else {
        // Phrasing like "thousand and fifty-six"
        String remainderText = _convertChunk(remainder);
        yearText = "ҳазор$_conjunction $remainderText"; // "ҳазор у [remainder]"
      }
    } else {
      // Standard conversion for other years
      yearText = _convertInteger(BigInt.from(absYear), isYear: true);
    }

    // Add era suffixes if needed
    String suffix = "";
    if (isNegative) {
      suffix = _yearSuffixBC; // BC/BCE
    } else if (options.includeAD && absYear > 0) {
      suffix = _yearSuffixAD; // AD/CE, only if option is enabled
    }

    // Append suffix with Izofat if necessary
    if (suffix.isNotEmpty) {
      // Ensure Izofat suffix "и" is present before the era suffix
      if (!yearText.endsWith(_izofatSuffix)) {
        yearText += _izofatSuffix;
      }
      yearText += suffix;
    }
    return yearText;
  }

  /// Converts a decimal number into Tajik currency words.
  String _handleCurrency(Decimal absValue, TgOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    final int decimalPlaces = 2; // Standard 2 decimal places for subunits
    final Decimal subunitMultiplier =
        Decimal.fromInt(100); // To get subunit value

    // Round the value if specified in options
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main unit and subunit values
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).truncate().toBigInt();

    // Convert main unit value to words
    String mainText = _convertInteger(mainValue);
    String mainUnitName =
        currencyInfo.mainUnitSingular; // Use singular form for simplicity here

    // Combine main value and unit name
    String result = '$mainText $mainUnitName';

    // Add subunit part if it exists
    if (subunitValue > BigInt.zero) {
      String subunitText = _convertInteger(subunitValue);
      String subUnitName =
          currencyInfo.subUnitSingular ?? ""; // Get subunit name
      if (subUnitName.isNotEmpty) {
        // Use the specific currency separator (e.g., " ва ")
        result +=
            ' ${currencyInfo.separator ?? _currencySeparator} $subunitText $subUnitName';
      }
    }
    return result;
  }

  /// Converts a standard decimal number (integer or with fraction) into Tajik words.
  String _handleStandardNumber(Decimal absValue, TgOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part to words
    // Special case: if integer is 0 but fraction exists (e.g., 0.5), start with "нол"
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    // Convert fractional part if it exists
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word based on options
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _comma;
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period:
        default: // Default to point
          separatorWord = _point;
          break;
      }

      // Get the fractional digits as a string
      String fractionalDigits = fractionalPart.toString();
      if (fractionalDigits.contains('.')) {
        // Extract digits after the decimal point
        fractionalDigits = fractionalDigits.split('.').last;
      }

      // Convert each fractional digit to its word representation
      List<String> digitWords = fractionalDigits.split('').map((digit) {
        final int? digitInt = int.tryParse(digit);
        return (digitInt != null && digitInt >= 0 && digitInt <= 9)
            ? (digitInt == 0
                ? _zero
                : _units[digitInt]) // Use "нол" for zero digit
            : '?'; // Fallback for unexpected characters
      }).toList();

      // Add separator word and the digit words
      String separatorPrefix = (integerWords == _zero || integerWords.isEmpty)
          ? ""
          : " "; // Space before separator if integer part exists
      fractionalWords =
          '$separatorPrefix$separatorWord ${digitWords.join(' ')}';
    }
    // This block handles cases like `1.0` where `fractionalPart` is zero but scale > 0.
    // Currently does nothing, but could be used for specific formatting if needed.
    else if (integerPart > BigInt.zero &&
        absValue.scale > 0 &&
        absValue.isInteger) {}

    // Combine integer and fractional parts
    return '$integerWords$fractionalWords'
        .trim(); // Trim potential leading/trailing spaces
  }

  /// Converts a non-negative BigInt into Tajik words.
  ///
  /// - [n]: The non-negative integer to convert.
  /// - [isYear]: Flag indicating if special year handling is needed (e.g., for 1000).
  String _convertInteger(BigInt n, {bool isYear = false}) {
    if (n < BigInt.zero) {
      // This function expects non-negative input internally
      throw ArgumentError("Integer conversion input must be non-negative: $n");
    }

    // Special case: "як ҳазор" (one thousand) for 1000, unless it's a year.
    // Year 1000 might be handled differently depending on context (e.g., "соли ҳазор").
    // The current `_handleYearFormat` calls this, so this condition might need refinement
    // based on specific year phrasing rules.
    if (n == BigInt.from(1000) && !isYear) return "як ҳазор"; // Standard 1000
    if (n == BigInt.from(1000) && isYear)
      return "ҳазор"; // Year 1000 (without "як")

    // Handle numbers less than 1000 directly using _convertChunk
    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt());
    }

    // Process larger numbers by chunks of 1000
    List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex =
        0; // Index into _scaleWords (0: base, 1: thousand, 2: million...)
    BigInt remaining = n;

    while (remaining > BigInt.zero) {
      // Ensure we have a scale word for the current magnitude
      if (scaleIndex >= _scaleWords.length) {
        // Number is too large for the defined scale words
        throw ArgumentError(
            "Number is too large to convert: exceeds ${_scaleWords.last}");
      }

      // Get the current chunk (0-999)
      BigInt chunk = remaining % oneThousand;
      remaining ~/= oneThousand; // Move to the next chunk

      if (chunk > BigInt.zero) {
        // Convert the chunk to words
        String chunkText = _convertChunk(chunk.toInt());
        // Get the corresponding scale word (e.g., "ҳазор", "миллион")
        String scaleWord = scaleIndex > 0 ? _scaleWords[scaleIndex] : "";

        if (scaleWord.isNotEmpty) {
          // Special case: "як ҳазор" instead of just "ҳазор" for 1000
          if (chunk == BigInt.one && scaleIndex == 1) {
            // If chunk is 1 and scale is thousand
            parts.add("як $scaleWord");
          } else {
            parts.add("$chunkText $scaleWord");
          }
        } else {
          // Base chunk (no scale word)
          parts.add(chunkText);
        }
      }
      scaleIndex++;
    }

    // Combine the parts in the correct order (most significant first)
    List<String> reversedParts = parts.reversed.toList();
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < reversedParts.length; i++) {
      buffer.write(reversedParts[i]);
      // Add conjunction "у" between major parts (e.g., "million AND thousand AND units")
      if (i < reversedParts.length - 1) {
        // Ensure proper spacing around the conjunction
        if (!buffer.toString().endsWith(" ")) buffer.write(_conjunction);
        buffer.write(" ");
      }
    }
    return buffer.toString().trim(); // Trim potential trailing space
  }

  /// Converts a number between 0 and 999 into Tajik words.
  String _convertChunk(int n) {
    // Base case: Zero chunk is empty string
    if (n == 0) return "";
    // Internal validation: Ensure chunk is within the expected range
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999, inclusive: $n");
    }

    StringBuffer words = StringBuffer();
    int remainder = n;

    // Handle hundreds place
    if (remainder >= 100) {
      int hundredDigit = remainder ~/ 100;
      if (hundredDigit == 1) {
        // Special case for 100 ("сад")
        words.write(_hundred);
      } else {
        // For 200, 300, etc. ("дусад", "сесад")
        words.write(_units[hundredDigit]); // "ду", "се", ...
        words.write(_hundred); // "сад"
      }
      remainder %= 100; // Get the remaining tens and units
      // Add conjunction "у" if there are tens/units following the hundreds
      if (remainder > 0) {
        words.write(_conjunction);
        words.write(" "); // Space after conjunction
      }
    }

    // Handle tens and units place (0-99)
    if (remainder > 0) {
      if (remainder < 10) {
        // Units 1-9
        words.write(_units[remainder]);
      } else if (remainder < 20) {
        // Teens 10-19
        words.write(_teens[remainder - 10]); // Adjust index for _teens list
      } else {
        // Tens 20-99
        int tenDigit = remainder ~/ 10;
        int unit = remainder % 10;
        words.write(_tens[tenDigit]); // "бист", "сӣ", ...
        // Add conjunction "у" and unit word if unit exists (e.g., "бист у як" for 21)
        if (unit > 0) {
          words.write(_conjunction);
          words.write(" "); // Space after conjunction
          words.write(_units[unit]);
        }
      }
    }

    return words.toString();
  }
}
