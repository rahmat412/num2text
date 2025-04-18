import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/hi_options.dart';
import '../utils/utils.dart';

/// {@template num2text_hi}
/// The Hindi language (`Lang.HI`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Hindi word representation following standard Hindi grammar and the
/// Indian numbering system (Lakh, Crore).
///
/// Capabilities include handling cardinal numbers, currency (using [HiOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers
/// according to the Indian scale (Lakh, Crore, Arab, Kharab, etc.).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [HiOptions].
/// {@endtemplate}
class Num2TextHI implements Num2TextBase {
  // --- Private Constants ---

  /// The Hindi word for "zero".
  static const String _zero = "शून्य";

  /// The Hindi word for the decimal point represented by a period/point (`.`).
  static const String _point = "दशमलव";

  /// The Hindi word for the decimal separator represented by a comma (`,`).
  static const String _comma =
      "अल्पविराम"; // Less common for decimals, but supported.

  /// The Hindi word for "and", used as a separator in currency formatting.
  static const String _and = "और";

  /// The Hindi word for "hundred".
  static const String _hundred = "सौ";

  /// The Hindi word for "thousand".
  static const String _thousand = "हज़ार";

  /// The Hindi word for "lakh" (100,000).
  static const String _lakh = "लाख";

  /// The Hindi word for "crore" (10,000,000).
  static const String _crore = "करोड़";

  /// The Hindi word for "arab" (1,000,000,000).
  static const String _arab = "अरब";

  /// The Hindi word for "kharab" (100,000,000,000).
  static const String _kharab = "खरब";

  /// The Hindi word for "neel" (10,000,000,000,000).
  static const String _neel = "नील";

  /// The Hindi word for "padma" (1,000,000,000,000,000).
  static const String _padma = "पद्म";

  /// The Hindi word for "shankh" (100,000,000,000,000,000).
  static const String _shankh = "शंख";

  /// The suffix used for years Before Christ (BC/BCE).
  static const String _yearSuffixBC = "ईसा पूर्व";

  /// The suffix used for years Anno Domini (AD/CE).
  static const String _yearSuffixAD = "ईस्वी";

  /// Precomputed BigInt constant for 100.
  static final BigInt _bigInt100 = BigInt.from(100);

  /// Precomputed BigInt constant for 1000.
  static final BigInt _bigInt1000 = BigInt.from(1000);

  /// A list containing the Hindi words for numbers from 0 to 99.
  static const List<String> _wordsUnder100 = [
    "शून्य", // 0
    "एक", // 1
    "दो", // 2
    "तीन", // 3
    "चार", // 4
    "पाँच", // 5
    "छह", // 6
    "सात", // 7
    "आठ", // 8
    "नौ", // 9
    "दस", // 10
    "ग्यारह", // 11
    "बारह", // 12
    "तेरह", // 13
    "चौदह", // 14
    "पंद्रह", // 15
    "सोलह", // 16
    "सत्रह", // 17
    "अठारह", // 18
    "उन्नीस", // 19
    "बीस", // 20
    "इक्कीस", // 21
    "बाईस", // 22
    "तेईस", // 23
    "चौबीस", // 24
    "पच्चीस", // 25
    "छब्बीस", // 26
    "सत्ताईस", // 27
    "अट्ठाईस", // 28
    "उनतीस", // 29
    "तीस", // 30
    "इकतीस", // 31
    "बत्तीस", // 32
    "तैंतीस", // 33
    "चौंतीस", // 34
    "पैंतीस", // 35
    "छत्तीस", // 36
    "सैंतीस", // 37
    "अड़तीस", // 38
    "उनतालीस", // 39
    "चालीस", // 40
    "इकतालीस", // 41
    "बयालीस", // 42
    "तैंतालीस", // 43
    "चौवालीस", // 44
    "पैंतालीस", // 45
    "छियालीस", // 46
    "सैंतालीस", // 47
    "अड़तालीस", // 48
    "उनचास", // 49
    "पचास", // 50
    "इक्यावन", // 51
    "बावन", // 52
    "तिरपन", // 53
    "चौवन", // 54
    "पचपन", // 55
    "छप्पन", // 56
    "सत्तावन", // 57
    "अट्ठावन", // 58
    "उनसठ", // 59
    "साठ", // 60
    "इकसठ", // 61
    "बासठ", // 62
    "तिरसठ", // 63
    "चौंसठ", // 64
    "पैंसठ", // 65
    "छियासठ", // 66
    "सड़सठ", // 67
    "अड़सठ", // 68
    "उनहत्तर", // 69
    "सत्तर", // 70
    "इकहत्तर", // 71
    "बहत्तर", // 72
    "तिहत्तर", // 73
    "चौहत्तर", // 74
    "पचहत्तर", // 75
    "छिहत्तर", // 76
    "सतहत्तर", // 77
    "अठहत्तर", // 78
    "उनासी", // 79
    "अस्सी", // 80
    "इक्यासी", // 81
    "बयासी", // 82
    "तिरासी", // 83
    "चौरासी", // 84
    "पचासी", // 85
    "छियासी", // 86
    "सत्तासी", // 87
    "अट्ठासी", // 88
    "नवासी", // 89
    "नब्बे", // 90
    "इक्यानबे", // 91
    "बानबे", // 92
    "तिरानबे", // 93
    "चौरानबे", // 94
    "पंचानबे", // 95
    "छियानबे", // 96
    "सत्तानबे", // 97
    "अट्ठानबे", // 98
    "निन्यानवे", // 99
  ];

  /// Processes the given number into its Hindi word representation based on the provided options.
  ///
  /// [number] The number to convert (can be `int`, `double`, `BigInt`, `Decimal`, or `String`).
  /// [options] Optional configuration for the conversion (e.g., currency, year format). Defaults to `HiOptions()`.
  /// [fallbackOnError] A custom string to return if conversion fails. Defaults to a generic Hindi error message ("अमान्य संख्या").
  ///
  /// Returns the Hindi word representation of the number, or the fallback string on error.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have Hindi-specific options, defaulting if necessary.
    final HiOptions hiOptions =
        options is HiOptions ? options : const HiOptions();
    final String defaultFallback =
        "अमान्य संख्या"; // Default fallback message: "Invalid number"

    // Handle special double values early.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? "ऋण अनंत"
            : "अनंत"; // Negative/Positive Infinity
      }
      if (number.isNaN) {
        return fallbackOnError ?? defaultFallback;
      }
    }

    // Normalize the input number to a Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // If normalization fails, return the fallback string.
    if (decimalValue == null) {
      return fallbackOnError ?? defaultFallback;
    }

    // Handle zero separately.
    if (decimalValue == Decimal.zero) {
      if (hiOptions.currency) {
        // For currency, zero needs the plural unit name (e.g., "शून्य रुपये").
        return "$_zero ${hiOptions.currencyInfo.mainUnitPlural}";
      } else {
        // Standard zero.
        return _zero;
      }
    }

    // Determine the sign and get the absolute value.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    // Delegate to the appropriate handler based on format options.
    String textResult;
    if (hiOptions.format == Format.year) {
      // Year formatting handles negativity internally.
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), hiOptions);
    } else {
      // Handle currency or standard number.
      if (hiOptions.currency) {
        textResult = _handleCurrency(absValue, hiOptions);
      } else {
        textResult = _handleStandardNumber(absValue, hiOptions);
      }
      // Add the negative prefix if the original number was negative.
      if (isNegative) {
        textResult = "${hiOptions.negativePrefix} $textResult";
      }
    }

    // Return the final result, trimming any extra whitespace.
    return textResult.trim();
  }

  /// Handles the conversion of a number specifically for year formatting.
  ///
  /// [year] The integer year value.
  /// [options] The Hindi-specific options.
  ///
  /// Returns the year formatted in Hindi words, including BC/AD suffixes if applicable.
  /// - BC suffix ("ईसा पूर्व") is added for negative years.
  /// - AD suffix ("ईस्वी") is added for positive years *only* if `options.includeAD` is true.
  /// - Special case: Years like 1900 are formatted as "उन्नीस सौ".
  String _handleYearFormat(int year, HiOptions options) {
    final bool isNegative = year < 0;
    // Work with the absolute value of the year.
    final int absYear = isNegative ? -year : year;
    final BigInt bigAbsYear = BigInt.from(absYear);

    // Handle year 0 if necessary, although it doesn't exist historically.
    if (absYear == 0) return _zero;

    String yearText;
    // Special handling for years like 1100, 1200, ..., 1900.
    if (absYear >= 1100 && absYear < 2000 && absYear % 100 == 0) {
      final int highPart = absYear ~/ 100;
      // Ensure the high part (11-19) is within the range covered by _wordsUnder100.
      if (highPart > 10 && highPart < 100) {
        yearText = "${_wordsUnder100[highPart]} $_hundred"; // e.g., "उन्नीस सौ"
      } else {
        // Fallback to standard conversion if outside the typical "xx hundred" pattern.
        yearText = _convertInteger(bigAbsYear);
      }
    } else {
      // Standard integer conversion for other years.
      yearText = _convertInteger(bigAbsYear);
    }

    // Append era suffixes based on sign and options.
    if (isNegative) {
      yearText += " $_yearSuffixBC"; // BC for negative years.
    } else if (options.includeAD) {
      // AD only for positive years if option is enabled.
      yearText += " $_yearSuffixAD";
    }

    return yearText;
  }

  /// Handles the conversion of a number into currency format.
  ///
  /// [absValue] The absolute (non-negative) value of the number as a Decimal.
  /// [options] The Hindi-specific options, including currency info and rounding preference.
  ///
  /// Returns the number formatted as Hindi currency (e.g., "एक रुपया और पचास पैसे").
  String _handleCurrency(Decimal absValue, HiOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2; // Standard currency subunit precision.
    final Decimal subunitMultiplier =
        Decimal.fromInt(100); // e.g., 100 paise in a rupee.

    // Round the value if requested, otherwise use the original value.
    final Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate the main unit (integer part) and subunit (fractional part).
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Calculate the value of the subunits (e.g., paise). Rounding might be needed depending on currency.
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).truncate().toBigInt();

    // Convert the main unit value to words.
    final String mainText = _convertInteger(mainValue);
    // Select the correct singular/plural form for the main unit name (e.g., रुपया/रुपये).
    final String mainUnitName = (mainValue == BigInt.one)
        ? currencyInfo.mainUnitSingular
        : currencyInfo.mainUnitPlural!;

    // Start building the result string.
    String result = '$mainText $mainUnitName';

    // If there are subunits, add them to the string.
    if (subunitValue > BigInt.zero) {
      // Check if subunit names are provided.
      if (currencyInfo.subUnitSingular == null ||
          currencyInfo.subUnitPlural == null) {
        // Skip subunit if names are missing. Consider logging.
      } else {
        // Convert the subunit value to words.
        final String subunitText = _convertInteger(subunitValue);
        // Select the correct singular/plural form for the subunit name (e.g., पैसा/पैसे).
        final String subUnitName = (subunitValue == BigInt.one)
            ? currencyInfo.subUnitSingular!
            : currencyInfo.subUnitPlural!;
        // Use the specified separator or default to "और".
        final String separator = currencyInfo.separator ?? _and;

        // Append the subunit part to the result.
        result += ' $separator $subunitText $subUnitName';
      }
    }

    return result;
  }

  /// Handles the conversion of a standard number (integer or decimal).
  ///
  /// [absValue] The absolute (non-negative) value of the number as a Decimal.
  /// [options] The Hindi-specific options, particularly the decimal separator choice.
  ///
  /// Returns the number formatted in Hindi words, including the decimal part if present.
  String _handleStandardNumber(Decimal absValue, HiOptions options) {
    // Separate the integer and fractional parts.
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part to words.
    // If the integer part is zero but there's a fractional part, explicitly say "शून्य".
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    // If there is a fractional part, convert it.
    if (fractionalPart > Decimal.zero) {
      String separatorWord;
      // Choose the correct decimal separator word based on options. Default to period ("दशमलव").
      switch (options.decimalSeparator ?? DecimalSeparator.period) {
        case DecimalSeparator.comma:
          separatorWord = _comma; // "अल्पविराम"
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          separatorWord = _point; // "दशमलव"
          break;
      }

      // Extract the digits after the decimal point.
      // Use toString() for reliable representation.
      final String numberStr = absValue.toString();
      final String fractionalDigits =
          numberStr.contains('.') ? numberStr.split('.').last : '';

      // Trim trailing zeros for standard representation (e.g., 1.50 -> 1.5).
      final String trimmedFractionalDigits =
          fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      // Convert each digit after the decimal point to its word representation if any remain.
      if (trimmedFractionalDigits.isNotEmpty) {
        final List<String> digitWords =
            trimmedFractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          // Look up the word in the _wordsUnder100 list (indices 0-9).
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder100[digitInt]
              : '?'; // Use '?' for any non-digit characters (shouldn't happen).
        }).toList();

        // Combine the separator word and the digit words.
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
      // If trimmedFractionalDigits is empty (e.g., 123.0), fractionalWords remains empty.
    }

    // Combine integer and fractional parts (if any).
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer ([BigInt]) into its Hindi word representation
  /// using the Indian numbering system (Lakh, Crore, etc.).
  ///
  /// [n] The non-negative integer to convert.
  ///
  /// Returns the Hindi word representation of the integer.
  /// Throws [ArgumentError] if the input number is negative.
  /// Throws [StateError] if an internal calculation results in an unexpected state.
  String _convertInteger(BigInt n) {
    // Handle base cases: zero and numbers under 100.
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");

    if (n < _bigInt100) {
      return _wordsUnder100[
          n.toInt()]; // Directly look up in the precomputed list.
    }

    final List<String> parts =
        []; // Stores parts of the number string (e.g., "बारह लाख", "तीन सौ").
    BigInt remaining = n; // The portion of the number yet to be processed.

    // --- Step 1: Handle the first group (0-999) ---
    // The Indian system groups the first three digits differently.
    final int unitsGroup = (remaining % _bigInt1000).toInt();
    remaining ~/= _bigInt1000; // Remove the processed part.

    if (unitsGroup > 0) {
      String unitsText;
      if (unitsGroup < 100) {
        // Numbers 1-99.
        unitsText = _wordsUnder100[unitsGroup];
      } else {
        // Numbers 100-999.
        final int hundredsDigit = unitsGroup ~/ 100;
        final int tensUnitsPart = unitsGroup % 100;
        // Combine hundreds digit word and "सौ".
        final String hundredsText =
            "${_wordsUnder100[hundredsDigit]} $_hundred";
        if (tensUnitsPart > 0) {
          // If there's a non-zero part after hundreds (e.g., 123 -> "एक सौ तेईस").
          unitsText = "$hundredsText ${_wordsUnder100[tensUnitsPart]}";
        } else {
          // If it's exactly hundreds (e.g., 200 -> "दो सौ").
          unitsText = hundredsText;
        }
      }
      parts.add(unitsText); // Add the processed units group text.
    }

    // --- Step 2: Handle subsequent groups (Thousands, Lakhs, Crores, etc.) ---
    // These scales group by hundreds (two digits at a time).
    const List<String> scales = [
      _thousand,
      _lakh,
      _crore,
      _arab,
      _kharab,
      _neel,
      _padma,
      _shankh
    ];
    final BigInt factor =
        _bigInt100; // Grouping factor is 100 for scales after thousand.

    for (final String scaleName in scales) {
      if (remaining == BigInt.zero) break; // Stop if no number left to process.

      // Get the next two digits (0-99).
      final int scalePart = (remaining % factor).toInt();
      remaining ~/= factor; // Remove the processed part.

      if (scalePart > 0) {
        // If this scale group is non-zero.
        if (scalePart >= 100) {
          // This should not happen due to the modulo 100 operation, but acts as a safeguard.
          throw StateError(
              "Internal error: Scale part $scalePart >= 100 for $scaleName");
        }
        // Convert the two-digit number (1-99) for this scale.
        final String scaleAmountText = _wordsUnder100[scalePart];
        // Combine the amount and the scale name (e.g., "बारह लाख").
        final String scaleText = "$scaleAmountText $scaleName";
        // Insert at the beginning as we process from right to left but build left to right.
        parts.insert(0, scaleText);
      }
    }

    // --- Step 3: Handle numbers larger than Shankh ---
    // If there's still a remaining part after processing all defined scales,
    // it means the number is larger than 10^19. Convert the remaining part
    // recursively and append the largest scale name ("शंख").
    // Example: 123 * 10^19 -> "एक सौ तेईस शंख"
    // Example: 12345 * 10^19 -> "बारह हज़ार तीन सौ पैंतालीस शंख" (handled by recursion)
    if (remaining > BigInt.zero) {
      final String remainingText =
          _convertInteger(remaining); // Recursive call.
      // Insert the highest part (representing multiples of 10^19) at the very beginning.
      parts.insert(0, "$remainingText $_shankh");
    }

    // Join all processed parts with spaces.
    return parts.join(" ").trim();
  }
}
