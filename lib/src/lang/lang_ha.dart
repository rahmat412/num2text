import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ha_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ha}
/// The Hausa language (`Lang.HA`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Hausa word representation following standard Hausa grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [HaOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (short scale).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [HaOptions].
/// {@endtemplate}
class Num2TextHA implements Num2TextBase {
  /// Hausa word for zero.
  static const String _zero = "sifili";

  /// Hausa word for the decimal separator represented by a period/point (`.`).
  static const String _point = "digo";

  /// Hausa word for the decimal separator represented by a comma (`,`).
  static const String _comma = "waƙafi";

  /// Hausa word for "and" ("da"), used as a connector.
  static const String _and = "da";

  /// Hausa word for "hundred".
  static const String _hundred = "ɗari";

  /// Suffix for BC years (Before Christ). Using English abbreviation as it's common.
  static const String _yearSuffixBC = "BC";

  /// Suffix for AD years (Anno Domini). Using English abbreviation as it's common.
  static const String _yearSuffixAD = "AD";

  /// Hausa representation of positive infinity.
  static const String _infinity = "Madawwami";

  /// Hausa representation of negative infinity.
  static const String _negativeInfinity = "Korau Madawwami";

  /// Hausa representation of "Not a Number".
  static const String _notANumber = "Ba Lamba Ba";

  /// Hausa words for digits 0-9.
  static const List<String> _wordsUnder10 = [
    "sifili", // 0
    "ɗaya", // 1
    "biyu", // 2
    "uku", // 3
    "huɗu", // 4
    "biyar", // 5
    "shida", // 6
    "bakwai", // 7
    "takwas", // 8
    "tara", // 9
  ];

  /// Hausa words for tens (10, 20, ..., 90). Index corresponds to the tens digit (e.g., index 1 = 10).
  static const List<String> _wordsTens = [
    "", // 0 (placeholder)
    "goma", // 10
    "ashirin", // 20
    "talatin", // 30
    "arba'in", // 40
    "hamsin", // 50
    "sittin", // 60
    "saba'in", // 70
    "tamanin", // 80
    "casa'in", // 90
  ];

  /// Hausa words for scale numbers (thousand, million, etc.).
  /// The key is the scale index (0 for units, 1 for 10^3, 2 for 10^6, etc.).
  static const Map<int, String> _scaleWords = {
    0: "", // Units place (no scale word)
    1: "dubu", // Thousand (10^3)
    2: "miliyan", // Million (10^6)
    3: "biliyan", // Billion (10^9)
    4: "tiriliyan", // Trillion (10^12)
    5: "kwadiriliyan", // Quadrillion (10^15)
    6: "kwintiliyan", // Quintillion (10^18)
    7: "sistiliyan", // Sextillion (10^21)
    8: "septiliyan", // Septillion (10^24)
    // Additional scales can be added here if needed.
  };

  /// Converts the given [number] to Hausa words based on the provided [options].
  ///
  /// [number] The number to convert (int, double, BigInt, String, Decimal).
  /// [options] Hausa-specific options ([HaOptions]). If null or not `HaOptions`, defaults are used.
  /// [fallbackOnError] Custom string to return on conversion failure. Defaults to "Ba Lamba Ba".
  /// Returns the number in Hausa words or a fallback/error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final HaOptions haOptions =
        options is HaOptions ? options : const HaOptions();

    // Handle special double values (infinity, NaN) first.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? _negativeInfinity : _infinity;
      }
      if (number.isNaN) {
        return fallbackOnError ?? _notANumber;
      }
    }

    // Normalize the input number to Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Handle invalid or null input after normalization attempt.
    if (decimalValue == null) {
      return fallbackOnError ?? _notANumber;
    }

    // Handle zero separately, considering currency format.
    if (decimalValue == Decimal.zero) {
      if (haOptions.currency) {
        // For currency, specify the unit even for zero amount. Use plural if available.
        final String unitName = haOptions.currencyInfo.mainUnitPlural ??
            haOptions.currencyInfo.mainUnitSingular;
        return "$unitName $_zero"; // e.g., "Naira sifili"
      } else {
        // Standard zero.
        return _zero;
      }
    }

    // Determine sign and work with the absolute value.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Route to specific handlers based on format options.
    if (haOptions.format == Format.year) {
      // Year formatting handles negativity internally.
      // Ensure year is treated as an integer.
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), haOptions);
    } else if (haOptions.currency) {
      // Currency formatting.
      textResult = _handleCurrency(absValue, haOptions);
    } else {
      // Standard number formatting (integer or decimal).
      textResult = _handleStandardNumber(absValue, haOptions);
    }

    // Add negative prefix if necessary (only for non-year formats).
    if (isNegative && haOptions.format != Format.year) {
      textResult = "${haOptions.negativePrefix} $textResult";
    }

    // Return the final trimmed result.
    return textResult.trim();
  }

  /// Formats an integer [year] as Hausa words, potentially adding era suffixes (BC/AD).
  ///
  /// Handles the BC suffix for negative years and the AD suffix for positive years
  /// if `options.includeAD` is true.
  ///
  /// Parameters:
  ///   [year]: The integer year to format.
  ///   [options]: The [HaOptions] containing formatting preferences like [HaOptions.includeAD].
  ///
  /// Returns the year in Hausa words, with BC/AD suffixes as appropriate.
  String _handleYearFormat(int year, HaOptions options) {
    final bool isNegative = year < 0;
    // Convert the absolute year to words.
    final BigInt absYearBigInt = BigInt.from(year.abs());

    // Handle year zero explicitly.
    if (absYearBigInt == BigInt.zero) return _zero;

    String yearText = _convertInteger(absYearBigInt);

    // Add era suffixes based on the year's sign and options.
    if (isNegative) {
      yearText += " $_yearSuffixBC"; // Always add BC for negative years.
    } else if (options.includeAD) {
      // Only add AD for positive years if includeAD option is true.
      yearText += " $_yearSuffixAD";
    }

    return yearText;
  }

  /// Formats a non-negative [absValue] as Hausa currency words.
  ///
  /// Uses the [CurrencyInfo] provided in [options] for unit names and separator.
  /// Rounds the amount to 2 decimal places if `options.round` is true.
  ///
  /// Parameters:
  ///   [absValue]: The absolute decimal value of the amount.
  ///   [options]: The [HaOptions] containing currency info and rounding preferences.
  ///
  /// Returns the amount formatted as currency in Hausa words.
  String _handleCurrency(Decimal absValue, HaOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces =
        2; // Standard currency typically has 2 decimal places.
    final Decimal subunitMultiplier = Decimal.parse("100");

    // Round the value if requested, otherwise use the precise value.
    final Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main unit and subunit values.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).truncate().toBigInt();

    // Convert main value to words.
    final String mainText = _convertInteger(mainValue);
    // Hausa typically uses the singular form of the currency name after the number.
    final String mainUnitName = currencyInfo.mainUnitSingular;

    String result = '$mainUnitName $mainText'; // e.g., "Naira ɗari"

    // Add subunit part if it exists and a subunit name is provided.
    if (subunitValue > BigInt.zero) {
      final String subunitText = _convertInteger(subunitValue);
      final String? subUnitName =
          currencyInfo.subUnitSingular; // Get subunit name.
      if (subUnitName != null) {
        // Use the provided separator or default to "da".
        final String separator = currencyInfo.separator ?? _and;
        result +=
            ' $separator $subUnitName $subunitText'; // e.g., "... da kobo hamsin"
      }
      // If subUnitName is null, the subunit part is skipped. Consider logging a warning.
    }

    return result;
  }

  /// Formats a non-negative standard number [absValue] (integer or decimal) into Hausa words.
  ///
  /// Uses the `decimalSeparator` option to choose the correct word ("digo" or "waƙafi").
  /// Reads digits after the decimal point individually.
  ///
  /// Parameters:
  ///   [absValue]: The absolute decimal value of the number.
  ///   [options]: The [HaOptions] containing decimal separator preferences.
  ///
  /// Returns the number formatted in Hausa words.
  String _handleStandardNumber(Decimal absValue, HaOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part to words.
    // If the number is purely fractional (e.g., 0.5), use "sifili" for the integer part.
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    // Handle fractional part if it exists.
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word based on options.
      final String separatorWord;
      switch (options.decimalSeparator ?? DecimalSeparator.point) {
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          separatorWord = _point; // "digo"
          break;
        case DecimalSeparator.comma:
          separatorWord = _comma; // "waƙafi"
          break;
      }

      // Extract fractional digits respecting the original scale.
      // Use toString() which might provide more precision than naive extraction.
      final String numberStr = absValue.toString();
      final int decimalPointIndex = numberStr.indexOf('.');
      String fractionalDigits = '';

      if (decimalPointIndex != -1) {
        fractionalDigits = numberStr.substring(decimalPointIndex + 1);
        // Pad with zeros if toString() representation is shorter than the actual scale.
        // e.g., Decimal.parse('1.50') might stringify to '1.5', but scale is 2.
        if (fractionalDigits.length < absValue.scale) {
          fractionalDigits = fractionalDigits.padRight(absValue.scale, '0');
        }
        // Trim trailing zeros for standard number representation (unlike currency).
        fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');
      }

      // If fractional digits remain after trimming zeros, convert them.
      if (fractionalDigits.isNotEmpty) {
        // Convert each fractional digit to its word representation.
        final List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          // Lookup digit words (0-9).
          return (digitInt != null &&
                  digitInt >= 0 &&
                  digitInt < _wordsUnder10.length)
              ? _wordsUnder10[digitInt]
              : '?'; // Fallback for unexpected characters.
        }).toList();

        // Combine separator and digit words.
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
      // If fractionalDigits is empty after trimming (e.g., 123.0), fractionalWords remains empty.
    }

    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] integer [n] into Hausa words.
  ///
  /// This is the core recursive function for handling large integers.
  /// It breaks the number into chunks of three digits (thousands) and applies scale words.
  /// Throws [ArgumentError] if [n] is negative or exceeds the defined scales.
  ///
  /// Parameters:
  ///   [n]: The non-negative integer to convert.
  ///
  /// Returns the integer formatted in Hausa words.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n == BigInt.zero) return _zero;

    // Handle numbers less than 1000 directly using helper functions.
    if (n < BigInt.from(100)) {
      return _convertUnder100(n.toInt());
    }
    if (n < BigInt.from(1000)) {
      return _convertUnder1000(n.toInt());
    }

    final List<String> parts = []; // Stores word parts for each scale.
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0; // 0: units, 1: thousands, 2: millions, etc.
    BigInt remaining = n; // Number part yet to be processed.

    // Process the number in chunks of 1000 from right to left.
    while (remaining > BigInt.zero) {
      // Check if the scale index is supported.
      if (!_scaleWords.containsKey(scaleIndex)) {
        throw ArgumentError(
            "Number too large, scale index $scaleIndex not defined.");
      }

      // Get the current chunk (0-999).
      final int chunk = (remaining % oneThousand).toInt();
      remaining ~/= oneThousand; // Move to the next chunk.

      // If the chunk is non-zero, convert it and add to parts.
      if (chunk > 0) {
        String chunkText;
        // Special handling for '1' in scale positions.
        if (chunk == 1 && scaleIndex == 1) {
          // 1000: Use only the scale word "dubu" later.
          chunkText = "";
        } else if (chunk == 1 && scaleIndex >= 2) {
          // 1 million, 1 billion, etc.: Use "ɗaya" for the chunk.
          chunkText = _wordsUnder10[1];
        } else {
          // Convert the chunk (2-999) to words normally.
          chunkText =
              chunk < 100 ? _convertUnder100(chunk) : _convertUnder1000(chunk);
        }

        // Get the scale word (e.g., "dubu", "miliyan").
        final String scaleWord = _scaleWords[scaleIndex]!;

        // Combine chunk text and scale word based on scale index.
        if (scaleIndex > 0) {
          // Scale words (thousand, million...).
          if (scaleIndex == 1) {
            // Thousands.
            if (chunk == 1) {
              parts.add(scaleWord); // Just "dubu".
            } else {
              parts.add("$scaleWord $chunkText"); // e.g., "dubu biyu".
            }
          } else {
            // Millions and higher. Always include scale word and chunk text.
            parts.add("$scaleWord $chunkText"); // e.g., "miliyan ɗaya".
          }
        } else {
          // Base units chunk (0-999).
          parts.add(chunkText);
        }
      }
      scaleIndex++; // Move to the next scale level.
    }

    // Combine the collected parts in the correct order (reversed) with appropriate connectors.
    final List<String> resultParts = parts.reversed.toList();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < resultParts.length; i++) {
      final String currentPart = resultParts[i];
      if (currentPart.isEmpty)
        continue; // Skip empty parts (like chunk '1' for 1000).

      buffer.write(currentPart);

      final bool isLastPart = i == resultParts.length - 1;
      if (!isLastPart) {
        // Determine if 'da' connector is needed before the final 0-999 chunk.
        final bool needsAndConnector = (n >=
                oneThousand) && // Original number was >= 1000.
            (n % oneThousand >
                BigInt.zero) && // The last 0-999 chunk is non-zero.
            (i ==
                resultParts.length -
                    2); // Currently processing the scale part just before the last chunk.

        buffer.write(
            needsAndConnector ? ' $_and ' : ' '); // Use 'da' or just a space.
      }
    }
    // Clean up potential double spaces and trim.
    return buffer.toString().replaceAll('  ', ' ').trim();
  }

  /// Converts an integer [n] between 0 and 99 into Hausa words.
  ///
  /// Handles the special "sha" connector for teens (11-19) and
  /// the "da" connector for other tens + units combinations.
  ///
  /// Throws [ArgumentError] if [n] is out of the 0-99 range.
  ///
  /// Parameters:
  ///   [n]: The integer between 0 and 99 to convert.
  ///
  /// Returns the number formatted in Hausa words, or an empty string for 0.
  String _convertUnder100(int n) {
    if (n < 0 || n >= 100) throw ArgumentError("Number must be 0-99: $n");
    // Zero part is handled by callers, return empty here to avoid "da sifili".
    if (n == 0) return "";
    if (n < 10) return _wordsUnder10[n]; // 1-9.

    final int tensDigit = n ~/ 10;
    final int unitDigit = n % 10;

    // Handle teens (11-19) using "sha".
    if (tensDigit == 1 && unitDigit > 0) {
      // e.g., "goma sha ɗaya" (11).
      return "${_wordsTens[1]} sha ${_wordsUnder10[unitDigit]}";
    }

    // Handle exact tens (10, 20, ..., 90).
    final String tensWord = _wordsTens[tensDigit];
    if (unitDigit == 0) {
      return tensWord;
    } else {
      // Handle other numbers (21-99 excluding multiples of 10) using "da".
      // e.g., "ashirin da ɗaya" (21).
      return "$tensWord $_and ${_wordsUnder10[unitDigit]}";
    }
  }

  /// Converts an integer [n] between 100 and 999 into Hausa words.
  ///
  /// Handles "ɗari" (100) and multiples, connecting with "da" for the remainder.
  ///
  /// Throws [ArgumentError] if [n] is out of the 100-999 range.
  ///
  /// Parameters:
  ///   [n]: The integer between 100 and 999 to convert.
  ///
  /// Returns the number formatted in Hausa words.
  String _convertUnder1000(int n) {
    if (n < 100 || n >= 1000) throw ArgumentError("Number must be 100-999: $n");

    final int hundredsDigit = n ~/ 100;
    final int remainder = n % 100; // Part 0-99.

    // Construct the hundreds part.
    final String hundredsText;
    if (hundredsDigit == 1) {
      hundredsText = _hundred; // "ɗari".
    } else {
      // e.g., "ɗari biyu" (200).
      hundredsText = "$_hundred ${_wordsUnder10[hundredsDigit]}";
    }

    // Combine with the remainder (0-99) if it exists.
    if (remainder == 0) {
      return hundredsText; // e.g., "ɗari", "ɗari biyu".
    } else {
      final String remainderText = _convertUnder100(remainder);
      // e.g., "ɗari da ɗaya" (101).
      return "$hundredsText $_and $remainderText";
    }
  }
}
