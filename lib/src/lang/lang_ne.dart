import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ne_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ne}
/// The Nepali language (Lang.NE) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Nepali word representation following standard Nepali grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [NeOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers using the
/// Nepali numbering system (Lakh, Crore, Arab, Kharb, Neel, Padma, Shankh).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [NeOptions].
/// {@endtemplate}
class Num2TextNE implements Num2TextBase {
  // --- Core Vocabulary ---

  /// The Nepali word for zero ("शून्य").
  static const String _zero = "शून्य";

  /// The default word for the decimal separator ("दशमलव", for period/point).
  static const String _point = "दशमलव";

  /// The word for the decimal separator when comma is specified ("अल्पविराम").
  static const String _comma = "अल्पविराम";

  /// The Nepali word for hundred ("सय").
  static const String _hundred = "सय";

  // --- Special Values & Suffixes ---

  /// Suffix for years AD/CE ("ईस्वी"). Added when `includeAD` is true for positive years.
  static const String _yearSuffixAD = "ईस्वी";

  /// Suffix for years BC/BCE ("ई.पू."). Added automatically for negative years in year format.
  static const String _yearSuffixBC = "ई.पू.";

  /// Word for infinity ("अनन्त").
  static const String _infinity = "अनन्त";

  /// Word for Not a Number ("संख्या होइन").
  static const String _nan = "संख्या होइन";

  /// List of Nepali words for numbers 0 through 99.
  static const List<String> _wordsUnder100 = [
    "शून्य",
    "एक",
    "दुई",
    "तीन",
    "चार",
    "पाँच",
    "छ",
    "सात",
    "आठ",
    "नौ",
    "दस",
    "एघार",
    "बाह्र",
    "तेह्र",
    "चौध",
    "पन्ध्र",
    "सोह्र",
    "सत्र",
    "अठार",
    "उन्नाइस",
    "बीस",
    "एक्काइस",
    "बाइस",
    "तेइस",
    "चौबीस",
    "पच्चीस",
    "छब्बीस",
    "सत्ताइस",
    "अठ्ठाइस",
    "उनतीस",
    "तीस",
    "एकतीस",
    "बत्तीस",
    "तेत्तीस",
    "चौँतीस",
    "पैँतीस",
    "छत्तीस",
    "सैँतीस",
    "अठतीस",
    "उनचालीस",
    "चालीस",
    "एकचालीस",
    "बयालीस",
    "त्रिचालीस",
    "चवालीस",
    "पैंतालिस",
    "छयालीस",
    "सतचालीस",
    "अठचालीस",
    "उनचास",
    "पचास",
    "एकाउन्न",
    "बाउन्न",
    "त्रिपन्न",
    "चौवन्न",
    "पचपन्न",
    "छपन्न",
    "सन्ताउन्न",
    "अन्ठाउन्न",
    "उनसाठी",
    "साठी",
    "एकसट्ठी",
    "बयसट्ठी",
    "त्रिसट्ठी",
    "चौसट्ठी",
    "पैँसट्ठी",
    "छयसट्ठी",
    "सड्सठी",
    "अठसट्ठी",
    "उनसत्तरी",
    "सत्तरी",
    "एकहत्तर",
    "बहत्तर",
    "त्रिहत्तर",
    "चौहत्तर",
    "पचहत्तर",
    "छयहत्तर",
    "सतहत्तर",
    "अठहत्तर",
    "उनासी",
    "असी",
    "एकासी",
    "बयासी",
    "त्रियासी",
    "चौरासी",
    "पचासी",
    "छयासी",
    "सतासी",
    "अठासी",
    "उनान्नब्बे",
    "नब्बे",
    "एकानब्बे",
    "बयानब्बे",
    "त्रियानब्बे",
    "चौरानब्बे",
    "पन्चानब्बे",
    "छयानब्बे",
    "सन्तानब्बे",
    "अन्ठानब्बे",
    "उनान्सय", // 99
  ];

  /// Defines the scale levels (thousand, lakh, crore, etc.) used in the Nepali numbering system.
  /// Each map contains the power of 10 and the corresponding Nepali name.
  /// Ordered from largest to smallest power for processing.
  static const List<Map<String, dynamic>> _scales = [
    {'power': 17, 'name': "शंख"}, // Shankh (10^17)
    {'power': 15, 'name': "पद्म"}, // Padma (10^15)
    {'power': 13, 'name': "नील"}, // Neel (10^13)
    {'power': 11, 'name': "खर्ब"}, // Kharb (10^11)
    {'power': 9, 'name': "अर्ब"}, // Arab (10^9)
    {'power': 7, 'name': "करोड"}, // Crore (10^7)
    {'power': 5, 'name': "लाख"}, // Lakh (10^5)
    {'power': 3, 'name': "हजार"}, // Thousand (10^3)
    // Note: Hundred (power 2) is handled separately within _convertInteger.
  ];

  /// Processes the given number (int, double, BigInt, String, Decimal) and returns its Nepali word representation.
  ///
  /// - [number]: The number to convert. Handles various numeric types.
  /// - [options]: Optional [NeOptions] to customize conversion (e.g., currency, year format).
  /// - [fallbackOnError]: A custom string to return if conversion fails (e.g., for invalid input).
  ///   If null, a default error message ([_nan]) is used.
  ///
  /// Returns the number in Nepali words, or an error string if conversion is not possible.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final NeOptions neOptions =
        options is NeOptions ? options : const NeOptions();
    final String errorFallback = fallbackOnError ?? _nan;

    // Handle special double values immediately
    if (number is double) {
      if (number.isInfinite) {
        String prefix = "";
        if (number.isNegative) {
          prefix = neOptions.negativePrefix;
          // Ensure space after prefix if needed.
          if (prefix.isNotEmpty && !prefix.endsWith(' ')) prefix += ' ';
        }
        return "$prefix$_infinity";
      }
      if (number.isNaN) {
        return errorFallback;
      }
    }

    // Normalize the input number to Decimal
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Handle normalization failure (invalid input)
    if (decimalValue == null) {
      return errorFallback;
    }

    // Handle zero separately for clarity and specific formats
    if (decimalValue == Decimal.zero) {
      if (neOptions.currency) {
        final currencyInfo = neOptions.currencyInfo;
        // Ensure units are trimmed if they have leading/trailing spaces
        return "${_zero.trim()} ${currencyInfo.mainUnitSingular.trim()}";
      } else {
        // Year format doesn't need special handling for zero, unlike BC/AD
        return _zero;
      }
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // --- Format-Specific Handling ---
    if (neOptions.format == Format.year) {
      // Year format handles negativity internally with suffixes
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), neOptions);
    } else {
      // Handle currency or standard number format
      if (neOptions.currency) {
        textResult = _handleCurrency(absValue, neOptions);
      } else {
        textResult = _handleStandardNumber(absValue, neOptions);
      }
      // Apply negative prefix if needed for non-year formats
      if (isNegative) {
        String prefix = neOptions.negativePrefix;
        // Ensure a space after the prefix if it doesn't have one
        if (prefix.isNotEmpty && !prefix.endsWith(' ')) prefix += ' ';
        textResult = "$prefix$textResult";
      }
    }

    return textResult;
  }

  /// Handles the conversion of a number when [Format.year] is specified.
  ///
  /// - [year]: The integer year value.
  /// - [options]: The [NeOptions] containing formatting details like `includeAD`.
  ///
  /// Returns the year in Nepali words, applying BC/AD suffixes as required.
  String _handleYearFormat(int year, NeOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;

    if (absYear == 0) {
      // While process() handles general zero, year 0 might be technically possible though uncommon.
      return _zero;
    }

    String yearText;
    // Special case for "X hundred" years like 1900 -> "उन्नाइस सय"
    if (absYear >= 1100 && absYear < 2000 && absYear % 100 == 0) {
      yearText = "${_convertUnder100(absYear ~/ 100)} $_hundred";
    } else {
      // Convert the absolute year value using the standard integer conversion
      yearText = _convertInteger(BigInt.from(absYear));
    }

    // Append suffixes based on sign and options
    if (isNegative) {
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD) {
      // Only add AD/CE suffix for positive years if explicitly requested
      yearText += " $_yearSuffixAD";
    }

    return yearText;
  }

  /// Handles the conversion of a number into currency format (NPR).
  ///
  /// - [absValue]: The absolute (non-negative) [Decimal] value of the amount.
  /// - [options]: The [NeOptions] containing currency details ([currencyInfo]).
  ///
  /// Returns the amount in Nepali words, including main ("रुपैयाँ") and subunit ("पैसा") parts.
  String _handleCurrency(Decimal absValue, NeOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    // Nepalese Rupee has 100 paisa
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round to 2 decimal places for currency.
    final Decimal roundedValue = absValue.round(scale: 2);

    // Split the value into main (Rupee) and subunit (Paisa) parts
    final BigInt mainValue = roundedValue.truncate().toBigInt();
    // Calculate fractional part carefully to avoid precision issues after rounding.
    final Decimal fractionalPart =
        (roundedValue - Decimal.fromBigInt(mainValue)).abs();
    // Calculate the subunit value as an integer.
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round(scale: 0).toBigInt();

    String mainText = "";
    String subUnitText = "";

    // Convert the main (Rupee) part if it's greater than zero
    if (mainValue > BigInt.zero) {
      // Assumes CurrencyInfo provides trimmed unit names
      mainText =
          "${_convertInteger(mainValue)} ${currencyInfo.mainUnitSingular.trim()}";
    }

    // Convert the subunit (Paisa) part if it's greater than zero
    if (subunitValue > BigInt.zero) {
      // Ensure subUnitSingular is not null before accessing
      final subUnitName = currencyInfo.subUnitSingular ?? '';
      if (subUnitName.isNotEmpty) {
        subUnitText = "${_convertInteger(subunitValue)} ${subUnitName.trim()}";
      }
    }

    // Combine the parts with the separator ("र") if both exist
    if (mainText.isNotEmpty && subUnitText.isNotEmpty) {
      final separator =
          currencyInfo.separator?.trim() ?? ''; // Default to empty if null
      return "$mainText $separator $subUnitText";
    } else if (mainText.isNotEmpty) {
      return mainText; // Only main part
    } else if (subUnitText.isNotEmpty) {
      return subUnitText; // Only subunit part
    } else {
      // Should only happen if input was 0.00, handled in `process`, but safe fallback.
      return "$_zero ${currencyInfo.mainUnitSingular.trim()}";
    }
  }

  /// Handles the conversion of a standard number (integer or decimal).
  ///
  /// - [absValue]: The absolute (non-negative) [Decimal] value of the number.
  /// - [options]: The [NeOptions] containing decimal separator preference.
  ///
  /// Returns the number in Nepali words, including the decimal part if present.
  String _handleStandardNumber(Decimal absValue, NeOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    // Calculate fractional part carefully
    final Decimal fractionalPart =
        (absValue - Decimal.fromBigInt(integerPart)).abs();

    String integerWords;
    // Handle case like 0.5 -> "शून्य दशमलव पाँच"
    if (integerPart == BigInt.zero && fractionalPart > Decimal.zero) {
      integerWords = _zero;
    } else {
      // Convert the integer part using the main integer conversion logic
      integerWords = _convertInteger(integerPart);
    }

    String fractionalWords = '';
    // Convert the fractional part if it exists
    if (fractionalPart > Decimal.zero) {
      // Determine the correct decimal separator word
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _comma;
          break;
        case DecimalSeparator.period:
        case DecimalSeparator.point: // Treat point same as period
        default: // Default to period
          separatorWord = _point;
          break;
      }

      // Get the digits after the decimal point as a string
      // `toString()` usually gives the most accurate representation including trailing zeros if significant.
      final String absString = absValue.toString();
      final int decimalPointIndex = absString.indexOf('.');
      String fractionalDigits = "";
      if (decimalPointIndex != -1) {
        fractionalDigits = absString.substring(decimalPointIndex + 1);
        // Nepali generally doesn't read trailing zeros, so remove them.
        // Example: 1.50 -> "एक दशमलव पाँच"
        fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');
      }

      // Convert each digit individually
      if (fractionalDigits.isNotEmpty) {
        List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          // Look up the word for the digit (0-9)
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder100[digitInt]
              : '?'; // Fallback for unexpected characters
        }).toList();

        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      } else {
        // If removing trailing zeros leaves no fractional digits, the number is effectively an integer.
        // No need to add separator or digits.
        fractionalWords = '';
      }
    }

    // Combine integer and fractional parts
    return integerWords + fractionalWords;
  }

  /// Converts a non-negative integer ([BigInt]) into its Nepali word representation.
  /// This is the core recursive function handling scales (Lakh, Crore, etc.).
  ///
  /// - [n]: The non-negative integer to convert.
  ///
  /// Returns the integer in Nepali words. Throws [ArgumentError] if input is negative.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero) {
      // This function should only be called with non-negative numbers.
      throw ArgumentError(
        "Cannot convert negative integer directly. Use process() for negative numbers.",
      );
    }
    if (n == BigInt.zero) return _zero;

    // Base case: Handle numbers less than 100 directly
    if (n < BigInt.from(100)) {
      return _convertUnder100(n.toInt());
    }

    BigInt remaining = n;
    final List<String> parts = [];

    // --- Process Scales (Crore, Lakh, Thousand, etc.) ---
    for (final scale in _scales) {
      final int power = scale['power'];
      final String name = scale['name'];
      final BigInt powerOf10 = BigInt.from(10).pow(power);

      if (remaining >= powerOf10) {
        // Calculate how many of this scale unit are present
        // For Lakh and Crore, the count is modulo 100, otherwise it's the full quotient.
        BigInt count;
        if (power == 5 || power == 7) {
          // Lakh (10^5) and Crore (10^7) work in pairs (like Indian numbering system)
          // But the _scales are processed individually. We need the amount *of this scale*.
          // Example: 12345678 -> 1 Crore, 23 Lakh, 45 Thousand, 678
          // When processing Crore (power 7): remaining = 12345678, count = 12345678 / 10^7 = 1
          // When processing Lakh (power 5): remaining = 2345678, count = 2345678 / 10^5 = 23
          // When processing Thousand (power 3): remaining = 45678, count = 45678 / 10^3 = 45
          count = remaining ~/ powerOf10;
        } else {
          // For other scales (Arab, Kharb, etc.), the count is also the full quotient.
          count = remaining ~/ powerOf10;
        }

        // Update the remainder
        remaining %= powerOf10;

        // Recursively convert the count for this scale
        String countText = _convertInteger(count);
        parts.add("$countText $name");
      }
    }

    // --- Process Remainder (0-999) ---
    if (remaining > BigInt.zero) {
      String remainderText;
      // Handle hundreds part if present
      if (remaining >= BigInt.from(100)) {
        int hundredCount = (remaining ~/ BigInt.from(100)).toInt();
        // Use "ek" for one hundred.
        remainderText =
            "${(hundredCount == 1) ? _wordsUnder100[1] : _convertUnder100(hundredCount)} $_hundred";
        BigInt lastTwo = remaining % BigInt.from(100);
        // Handle tens/units part if present
        if (lastTwo > BigInt.zero) {
          remainderText += " ${_convertUnder100(lastTwo.toInt())}";
        }
      } else {
        // Handle numbers 1-99
        remainderText = _convertUnder100(remaining.toInt());
      }
      parts.add(remainderText);
    }

    // Join all parts with spaces
    return parts.join(" ");
  }

  /// Converts an integer between 0 and 99 into its Nepali word representation.
  ///
  /// - [n]: The integer to convert (must be >= 0 and < 100).
  ///
  /// Returns the corresponding Nepali word from the [_wordsUnder100] list.
  /// Throws [ArgumentError] if the number is out of the valid range.
  String _convertUnder100(int n) {
    if (n < 0 || n >= 100) {
      throw ArgumentError("Number must be between 0 and 99 (inclusive): $n");
    }
    return _wordsUnder100[n];
  }
}
