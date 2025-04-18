import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ky_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ky}
/// The Kyrgyz language (Lang.KY) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Kyrgyz word representation following standard Kyrgyz grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [KyOptions.currencyInfo]),
/// year formatting ([Format.year] with optional BC/AD markers), negative numbers, decimals,
/// and large numbers using the short scale.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [KyOptions].
/// {@endtemplate}
class Num2TextKY implements Num2TextBase {
  /// The Kyrgyz word for zero ("нөл").
  static const String _zero = "нөл";

  /// The Kyrgyz word used for the decimal separator when [DecimalSeparator.period] or [DecimalSeparator.point] is specified ("точка").
  static const String _point = "точка";

  /// The Kyrgyz word used for the decimal separator when [DecimalSeparator.comma] is specified ("үтүр").
  static const String _comma = "үтүр";

  /// The default separator between currency units (main and subunit) if not provided in [CurrencyInfo].
  static const String _currencySeparator = " ";

  /// The Kyrgyz word for hundred ("жүз").
  static const String _hundred = "жүз";

  /// The suffix added to negative years (Before Common Era - "б.з.ч.").
  static const String _yearSuffixBCE = "б.з.ч.";

  /// The suffix added to positive years when `includeAD` is true (Common Era - "б.з.").
  static const String _yearSuffixAD = "б.з.";

  /// Kyrgyz words for digits 0 through 9.
  static const List<String> _wordsUnits = [
    "нөл", // 0
    "бир", // 1
    "эки", // 2
    "үч", // 3
    "төрт", // 4
    "беш", // 5
    "алты", // 6
    "жети", // 7
    "сегиз", // 8
    "тогуз", // 9
  ];

  /// Kyrgyz words for tens (10, 20, ..., 90). Index corresponds to tens digit (index 1 = 10, index 2 = 20, etc.).
  static const List<String> _wordsTens = [
    "", // 0 (placeholder)
    "он", // 10
    "жыйырма", // 20
    "отуз", // 30
    "кырк", // 40
    "элүү", // 50
    "алтымыш", // 60
    "жетимиш", // 70
    "сексен", // 80
    "токсон", // 90
  ];

  /// Kyrgyz scale words (thousand, million, billion, etc.). Index corresponds to the power of 1000 (index 1 = 1000^1, index 2 = 1000^2, etc.).
  static const List<String> _scaleWords = [
    "", // 1000^0 - Base units
    "миң", // 1000^1 - Thousand
    "миллион", // 1000^2 - Million
    "миллиард", // 1000^3 - Billion
    "триллион", // 1000^4 - Trillion
    "квадриллион", // 1000^5 - Quadrillion
    "квинтиллион", // 1000^6 - Quintillion
    "секстиллион", // 1000^7 - Sextillion
    "септиллион", // 1000^8 - Septillion
    // Add more scale words here if needed
  ];

  /// Processes the given [number] and converts it into its Kyrgyz word representation.
  ///
  /// - [number]: The number to convert (can be `int`, `double`, `BigInt`, `String`, or `Decimal`).
  /// - [options]: Optional [KyOptions] to customize the conversion (e.g., currency, year format). If null or not `KyOptions`, default options are used.
  /// - [fallbackOnError]: Optional string to return if the input is invalid or conversion fails. If null, language-specific defaults are used for errors.
  ///
  /// Returns the word representation of the number in Kyrgyz, or a fallback string on error.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final KyOptions kyOptions =
        options is KyOptions ? options : const KyOptions();
    final String errorDefault =
        fallbackOnError ?? "Сан эмес"; // Default error message

    // Handle special double values immediately.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? "Терс чексиздик" : "Чексиздик";
      }
      if (number.isNaN) {
        return errorDefault; // Use fallback for NaN
      }
    }

    // Normalize the input number to Decimal.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Handle invalid or null input.
    if (decimalValue == null) {
      return errorDefault; // Use fallback for other errors
    }

    // Handle zero separately for currency and year formats.
    if (decimalValue == Decimal.zero) {
      if (kyOptions.currency) {
        // Example: "нөл сом"
        return "$_zero ${kyOptions.currencyInfo.mainUnitSingular}";
      } else {
        // Standard zero or year zero.
        return _zero;
      }
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Branch based on formatting options.
    if (kyOptions.format == Format.year) {
      // Year formatting requires integer input and handles sign internally.
      textResult = _handleYearFormat(
          absValue.truncate().toBigInt().toInt(), kyOptions, isNegative);
    } else {
      // Handle currency or standard number format.
      if (kyOptions.currency) {
        textResult = _handleCurrency(absValue, kyOptions);
      } else {
        textResult = _handleStandardNumber(absValue, kyOptions);
      }

      // Prepend negative prefix if necessary (only for non-year formats here).
      if (isNegative) {
        textResult = "${kyOptions.negativePrefix} $textResult";
      }
    }

    // Return the final trimmed result.
    return textResult.trim();
  }

  /// Formats a number as a year in Kyrgyz.
  ///
  /// - [yearValue]: The absolute (non-negative) value of the year.
  /// - [options]: The [KyOptions] containing formatting preferences, especially `includeAD`.
  /// - [isNegative]: Indicates if the original year was negative (BC/BCE).
  ///
  /// Returns the year formatted as Kyrgyz words, potentially with era suffixes.
  String _handleYearFormat(int yearValue, KyOptions options, bool isNegative) {
    // Convert the absolute year value to words.
    // Use BigInt for consistency with integer conversion logic.
    final BigInt bigAbsYear = BigInt.from(yearValue);
    String yearText = _convertInteger(bigAbsYear);

    // Append era suffixes based on sign and options.
    if (isNegative) {
      // Always append BCE suffix for negative years.
      yearText += " $_yearSuffixBCE";
    } else if (options.includeAD) {
      // Append AD/CE suffix only for positive years *if* includeAD is true.
      yearText += " $_yearSuffixAD";
    }

    return yearText;
  }

  /// Formats a non-negative number as currency in Kyrgyz.
  ///
  /// - [absValue]: The absolute (non-negative) value of the amount.
  /// - [options]: The [KyOptions] containing currency details ([currencyInfo]) and rounding preferences ([round]).
  ///
  /// Returns the amount formatted as Kyrgyz currency words (e.g., "бир жүз сом элүү тыйын").
  String _handleCurrency(Decimal absValue, KyOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    // Kyrgyz Som (KGS) typically has 2 decimal places for tyiyn.
    const int decimalPlaces = 2;
    final Decimal subunitMultiplier =
        Decimal.ten.pow(decimalPlaces).toDecimal();

    // Round the value if specified.
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main and subunit values.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Round subunit calculation for precision
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round().toBigInt();

    // Convert the main unit value to words.
    String mainText = _convertInteger(mainValue);
    // Determine the correct plural form (Kyrgyz generally uses singular for currency units).
    String mainUnitName = currencyInfo.mainUnitSingular;

    String result = '$mainText $mainUnitName';

    // Add subunit part if it exists.
    if (subunitValue > BigInt.zero) {
      // Convert subunit value to words.
      String subunitText = _convertInteger(subunitValue);
      // Get subunit name (singular form used).
      // Assert non-null as Kyrgyz currency info defines subunits.
      String subUnitName = currencyInfo.subUnitSingular!;
      // Get separator word (defaults to space).
      String separator = currencyInfo.separator ?? _currencySeparator;

      result += '$separator$subunitText $subUnitName';
    }

    return result;
  }

  /// Converts a non-negative standard number (integer or decimal) to Kyrgyz words.
  ///
  /// - [absValue]: The absolute (non-negative) value of the number.
  /// - [options]: The [KyOptions] containing decimal separator preferences.
  ///
  /// Returns the number formatted as standard Kyrgyz words.
  String _handleStandardNumber(Decimal absValue, KyOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part. Use "нөл" if integer is 0 but decimal exists (e.g., 0.5).
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero // Example: 0.5 -> "нөл точка беш"
            : _convertInteger(integerPart);

    String fractionalWords = '';

    // Convert fractional part if it exists.
    if (fractionalPart > Decimal.zero) {
      // Determine the decimal separator word based on options.
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _comma; // "үтүр"
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period:
        default: // Default to point for Kyrgyz
          separatorWord = _point; // "точка"
          break;
      }

      // Extract fractional digits as a string from the standard decimal representation.
      String fractionalDigits = absValue.toString().split('.').last;

      // Convert each digit after the decimal point to its word representation.
      List<String> digitWords = fractionalDigits.split('').map((digit) {
        final int? digitInt = int.tryParse(digit);
        // Ensure the digit is valid (0-9).
        return (digitInt != null &&
                digitInt >= 0 &&
                digitInt < _wordsUnits.length)
            ? _wordsUnits[digitInt]
            : '?'; // Placeholder for unexpected characters
      }).toList();

      fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
    }
    // Integers represented as decimals (e.g., 123.0) are handled correctly.

    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer [n] into its Kyrgyz word representation using scale words.
  ///
  /// Throws [ArgumentError] if the number is negative or too large for the defined scale words.
  ///
  /// - [n]: The non-negative integer to convert.
  /// Returns the integer formatted as Kyrgyz words.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _zero;
    // Precondition: Ensure non-negative input
    assert(n > BigInt.zero);

    // Handle numbers less than 1000 directly.
    if (n < BigInt.from(1000)) {
      return _convertUnder1000(n.toInt());
    }

    List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex =
        0; // Index for _scaleWords (0 = none, 1 = thousand, 2 = million, etc.)
    BigInt remaining = n;

    // Process the number in chunks of 1000.
    while (remaining > BigInt.zero) {
      // Check if the number exceeds the defined scale words.
      if (scaleIndex >= _scaleWords.length) {
        throw ArgumentError(
          "Number too large to convert (exceeds defined scale: ${_scaleWords.last})",
        );
      }

      // Get the chunk (0-999) for the current scale.
      BigInt chunk = remaining % oneThousand;
      // Move to the next chunk.
      remaining ~/= oneThousand;

      // Convert the chunk to words if it's not zero.
      if (chunk > BigInt.zero) {
        String chunkText = _convertUnder1000(chunk.toInt());
        // Get the appropriate scale word (миң, миллион, etc.). Empty for the base chunk.
        String scaleWord = (scaleIndex > 0) ? _scaleWords[scaleIndex] : "";

        // Add the chunk text and scale word (if applicable) to the parts list.
        if (scaleWord.isNotEmpty) {
          parts.add("$chunkText $scaleWord");
        } else {
          parts.add(chunkText); // No scale word for the lowest chunk (0-999)
        }
      }
      scaleIndex++;
    }

    // Combine the parts in reverse order (highest scale first) with spaces.
    return parts.reversed.join(' ');
  }

  /// Converts a number between 0 and 999 into its Kyrgyz word representation.
  /// Returns an empty string for 0.
  ///
  /// Throws [ArgumentError] if the number is outside the valid range.
  ///
  /// - [n]: The integer to convert (0 <= n < 1000).
  /// Returns the number formatted as Kyrgyz words, or "" if n is 0.
  String _convertUnder1000(int n) {
    if (n == 0) return ""; // Return empty string for zero chunk.
    // Precondition check
    assert(n > 0 && n < 1000);

    // Handle numbers less than 100 directly.
    if (n < 100) return _convertUnder100(n);

    List<String> words = [];
    int remainder = n;

    // Handle hundreds place.
    int hundredsDigit = remainder ~/ 100;
    // Note: hundredsDigit > 0 because n >= 100
    // Add the digit word (e.g., "бир") and the word for hundred ("жүз").
    words.add(_wordsUnits[hundredsDigit]);
    words.add(_hundred);
    remainder %= 100;

    // Handle the remaining part (0-99) if non-zero.
    if (remainder > 0) {
      words.add(_convertUnder100(remainder));
    }

    return words.join(' ');
  }

  /// Converts a number between 0 and 99 into its Kyrgyz word representation.
  /// Returns an empty string for 0.
  ///
  /// Throws [ArgumentError] if the number is outside the valid range.
  ///
  /// - [n]: The integer to convert (0 <= n < 100).
  /// Returns the number formatted as Kyrgyz words, or "" if n is 0.
  String _convertUnder100(int n) {
    // Precondition check
    assert(n >= 0 && n < 100);
    if (n == 0) return ""; // Return empty string for zero.

    // Handle units directly (1-9).
    if (n < 10) return _wordsUnits[n];

    // Handle tens and units (10-99).
    int tensDigit = n ~/ 10;
    int unitDigit = n % 10;

    String tensWord = _wordsTens[tensDigit]; // e.g., "он", "жыйырма"

    if (unitDigit == 0) {
      // Exact tens (10, 20, ..., 90).
      return tensWord;
    } else {
      // Combine tens and units (e.g., "жыйырма бир").
      return "$tensWord ${_wordsUnits[unitDigit]}";
    }
  }
}
