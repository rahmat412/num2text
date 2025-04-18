import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/kk_options.dart';
import '../utils/utils.dart';

/// {@template num2text_kk}
/// The Kazakh language (Lang.KK) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Kazakh word representation following standard Kazakh grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [KkOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers using the short scale.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [KkOptions].
/// {@endtemplate}
class Num2TextKK implements Num2TextBase {
  /// The word for zero.
  static const String _zero = "нөл";

  /// The word for the decimal separator "point" (default).
  static const String _point = "нүкте";

  /// The word for the decimal separator "comma".
  static const String _comma = "үтір";

  /// The separator used between main and subunit currency values if not specified in [CurrencyInfo].
  static const String _currencySeparator = " ";

  /// The word for "hundred".
  static const String _hundred = "жүз";

  /// Words for digits 0-9.
  static const List<String> _wordsUnits = [
    "нөл", // 0 - Note: _zero is used directly for the number 0 in most contexts
    "бір", // 1
    "екі", // 2
    "үш", // 3
    "төрт", // 4
    "бес", // 5
    "алты", // 6
    "жеті", // 7
    "сегіз", // 8
    "тоғыз", // 9
  ];

  /// Words for tens (10, 20, ..., 90). Index corresponds to the tens digit.
  static const List<String> _wordsTens = [
    "", // 0 - Placeholder, not used directly
    "он", // 10
    "жиырма", // 20
    "отыз", // 30
    "қырық", // 40
    "елу", // 50
    "алпыс", // 60
    "жетпіс", // 70
    "сексен", // 80
    "тоқсан", // 90
  ];

  /// Scale words (thousand, million, etc.). Index corresponds to the power of 1000.
  static const List<String> _scaleWords = [
    "", // 1000^0 - Units/Hundreds/Tens
    "мың", // 1000^1 - Thousand
    "миллион", // 1000^2 - Million
    "миллиард", // 1000^3 - Billion
    "триллион", // 1000^4 - Trillion
    "квадриллион", // 1000^5 - Quadrillion
    "квинтиллион", // 1000^6 - Quintillion
    "секстиллион", // 1000^7 - Sextillion
    "септиллион", // 1000^8 - Septillion
    // Add more scales if needed
  ];

  /// Processes the given [number] into Kazakh text based on the provided [options].
  ///
  /// - [number]: The number to convert. Can be `int`, `double`, `BigInt`, `Decimal`, or `String`.
  /// - [options]: Optional [KkOptions] to control formatting (currency, year, decimal separator, etc.).
  ///   If null or not [KkOptions], default options are used.
  /// - [fallbackOnError]: Optional string to return if conversion fails (e.g., for `null` or invalid input).
  ///   If null, language-specific defaults are used for errors (e.g., "Сан емес", "Шексіздік").
  ///
  /// Returns the Kazakh text representation of the number or [fallbackOnError]/default error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final KkOptions kkOptions =
        options is KkOptions ? options : const KkOptions();
    // Default error message for non-numeric or invalid input
    final String errorDefault = fallbackOnError ?? "Сан емес";

    // Handle special double values immediately
    if (number is double) {
      if (number.isInfinite) {
        // Return language-specific words for infinity
        return number.isNegative ? "Теріс шексіздік" : "Шексіздік";
      }
      if (number.isNaN) {
        // Return the fallback message for NaN
        return errorDefault;
      }
    }

    // Normalize the input number to Decimal for precision
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Return fallback message if normalization fails
    if (decimalValue == null) {
      return errorDefault;
    }

    // Handle zero separately
    if (decimalValue == Decimal.zero) {
      if (kkOptions.currency) {
        // Format zero currency (e.g., "нөл теңге")
        return "$_zero ${kkOptions.currencyInfo.mainUnitSingular}";
      } else {
        // Return standard word for zero
        return _zero;
      }
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for the main conversion logic
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Apply specific formatting based on options
    if (kkOptions.format == Format.year) {
      // Year format uses integer part only, handles negative sign explicitly internally.
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), kkOptions);
    } else {
      // Handle standard numbers or currency
      if (kkOptions.currency) {
        textResult = _handleCurrency(absValue, kkOptions);
      } else {
        textResult = _handleStandardNumber(absValue, kkOptions);
      }

      // Add negative prefix if needed (only for non-year formats here)
      if (isNegative) {
        textResult = "${kkOptions.negativePrefix} $textResult";
      }
    }

    // Return the final trimmed result
    return textResult.trim();
  }

  /// Handles the specific formatting for years ([Format.year]).
  ///
  /// Converts the integer year value to words.
  /// Adds the negative prefix from [options] if the year is negative.
  /// Note: Does not currently add AD/BC suffixes like "б.з.б." or "ж." based on `includeAD`,
  /// but this could be extended if needed.
  ///
  /// - [year]: The year to convert (can be negative).
  /// - [options]: The [KkOptions] containing formatting preferences like `negativePrefix`.
  /// Returns the year formatted as Kazakh words.
  String _handleYearFormat(int year, KkOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;
    // Use BigInt for consistency with the integer conversion method
    final BigInt bigAbsYear = BigInt.from(absYear);

    // Convert the absolute year value to words
    String yearText = _convertInteger(bigAbsYear);

    // Prepend the negative prefix if the original year was negative
    if (isNegative) {
      yearText = "${options.negativePrefix} $yearText";
    }
    // Placeholder comment: Logic to add AD/BC suffixes based on options.includeAD and sign could go here.

    return yearText;
  }

  /// Handles the specific formatting for currency values ([KkOptions.currency] is true).
  ///
  /// Separates the number into main units (integer part) and subunits (fractional part).
  /// Converts both parts to words.
  /// Appends the appropriate currency unit names from [KkOptions.currencyInfo].
  /// Uses the separator from [KkOptions.currencyInfo] or a default space.
  /// Rounds the value to 2 decimal places if [KkOptions.round] is true.
  ///
  /// - [absValue]: The non-negative decimal value of the currency amount.
  /// - [options]: The [KkOptions] containing currency details and rounding options.
  /// Returns the currency amount formatted as Kazakh words.
  String _handleCurrency(Decimal absValue, KkOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2; // Standard currency subunit precision
    final Decimal subunitMultiplier =
        Decimal.ten.pow(decimalPlaces).toDecimal();

    // Round the value if specified, otherwise use the original value
    final Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Extract integer (main unit) and fractional (subunit) parts
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Round subunit calculation to avoid potential precision issues
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round().toBigInt();

    // Convert the main unit value to words
    final String mainText = _convertInteger(mainValue);

    // Get the main unit name (Kazakh currency usually uses singular form for Tenge)
    final String mainUnitName = currencyInfo.mainUnitSingular;

    // Start building the result string
    String result = '$mainText $mainUnitName';

    // Add subunit part if it exists
    if (subunitValue > BigInt.zero) {
      final String subunitText = _convertInteger(subunitValue);
      // Get the subunit name (assuming singular for Tiyn)
      // Assert non-null as subunits are defined for default KZT
      final String subUnitName = currencyInfo.subUnitSingular!;

      // Get the separator word (e.g., " ") or use default space
      final String separator = currencyInfo.separator ?? _currencySeparator;
      // Append separator, subunit value in words, and subunit name
      result += '$separator$subunitText $subUnitName';
    }

    return result;
  }

  /// Handles standard number formatting (integers and decimals).
  ///
  /// Converts the integer part to words.
  /// If there's a fractional part, converts it digit by digit after the appropriate separator word (_point or _comma).
  ///
  /// - [absValue]: The non-negative decimal value of the number.
  /// - [options]: The [KkOptions] containing decimal separator preferences.
  /// Returns the number formatted as standard Kazakh words.
  String _handleStandardNumber(Decimal absValue, KkOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part. Use "нөл" if integer is 0 but decimal exists (e.g., 0.5).
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';

    // Process fractional part if it's greater than zero
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word based on options
      final String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _comma; // "үтір"
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period:
        default: // Default to period/point representation
          separatorWord = _point; // "нүкте"
          break;
      }

      // Extract digits after the decimal point from the string representation.
      // This handles the scale correctly.
      final String fractionalDigits = absValue.toString().split('.').last;
      // Convert each digit to its word representation
      final List<String> digitWords = fractionalDigits.split('').map((digit) {
        final int? digitInt = int.tryParse(digit);
        // Use unit word or '?' if parsing fails or digit is out of range
        return (digitInt != null &&
                digitInt >= 0 &&
                digitInt < _wordsUnits.length)
            ? _wordsUnits[digitInt]
            : '?';
      }).toList();
      // Combine separator and digit words
      fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
    }
    // Integers represented as Decimals (e.g., 123.0) are handled correctly:
    // fractionalPart will be zero, so no fractionalWords are added.

    // Combine integer and fractional parts
    return '$integerWords$fractionalWords';
  }

  /// Converts a non-negative [BigInt] integer into its Kazakh word representation.
  ///
  /// Handles numbers by breaking them into chunks of 1000 and applying scale words.
  /// Delegates chunks under 1000 to [_convertUnder1000].
  /// Throws [ArgumentError] if the number is too large for the defined scales.
  ///
  /// - [n]: The non-negative integer to convert.
  /// Returns the integer formatted as Kazakh words.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _zero;
    // This function assumes non-negative input as negativity is handled higher up.
    assert(n > BigInt.zero);

    // Handle numbers less than 1000 directly
    if (n < BigInt.from(1000)) {
      return _convertUnder1000(n.toInt());
    }

    final List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0; // 0: units, 1: thousands, 2: millions...
    BigInt remaining = n;

    // Process the number in chunks of 1000 (thousands, millions, etc.)
    while (remaining > BigInt.zero) {
      // Ensure we have a scale word defined for this magnitude
      if (scaleIndex >= _scaleWords.length) {
        throw ArgumentError(
          "Number too large to convert (exceeds defined scale: ${_scaleWords.last})",
        );
      }

      // Get the current chunk (0-999)
      final BigInt chunk = remaining % oneThousand;
      remaining ~/= oneThousand; // Move to the next chunk

      // Convert the chunk to words if it's not zero
      if (chunk > BigInt.zero) {
        final String chunkText = _convertUnder1000(chunk.toInt());
        // Get the scale word (e.g., "мың", "миллион"), empty for the lowest chunk
        final String scaleWord = scaleIndex > 0 ? _scaleWords[scaleIndex] : "";

        // Add the chunk text and scale word (if applicable) to the parts list
        if (scaleWord.isNotEmpty) {
          parts.add("$chunkText $scaleWord");
        } else {
          // The first chunk (least significant 0-999) doesn't have a scale word
          parts.add(chunkText);
        }
      }
      scaleIndex++;
    }

    // Join the parts in reverse order (most significant first) with spaces
    return parts.reversed.join(' ');
  }

  /// Converts a non-negative integer under 1000 into its Kazakh word representation.
  ///
  /// Handles hundreds place and delegates numbers under 100 to [_convertUnder100].
  /// Returns an empty string for 0, as zero chunks are handled by the caller.
  ///
  /// - [n]: The integer to convert (0 <= n < 1000).
  /// Returns the number formatted as Kazakh words, or "" if n is 0.
  String _convertUnder1000(int n) {
    // Base case: zero chunk returns empty string
    if (n == 0) return "";
    // Precondition check
    assert(n > 0 && n < 1000);

    // Delegate numbers less than 100
    if (n < 100) return _convertUnder100(n);

    final List<String> words = [];
    int remainder = n;

    // Handle hundreds place
    final int hundredsDigit = remainder ~/ 100;
    // Note: hundredsDigit will be > 0 because n >= 100
    // Use "бір" for 100, otherwise use the corresponding unit word (екі, үш, etc.)
    words.add(hundredsDigit == 1 ? _wordsUnits[1] : _wordsUnits[hundredsDigit]);
    words.add(_hundred); // "жүз"
    remainder %= 100;

    // Handle the remaining part (0-99) if it's non-zero
    if (remainder > 0) {
      words.add(_convertUnder100(remainder));
    }

    // Join the parts (e.g., "бір жүз" + " " + "жиырма бес")
    return words.join(' ');
  }

  /// Converts a non-negative integer under 100 into its Kazakh word representation.
  ///
  /// Handles tens and units places. Returns an empty string for 0.
  ///
  /// - [n]: The integer to convert (0 <= n < 100).
  /// Returns the number formatted as Kazakh words, or "" if n is 0.
  String _convertUnder100(int n) {
    // Precondition check
    assert(n >= 0 && n < 100);
    // Base case: zero returns empty string
    if (n == 0) return "";

    // Handle units directly (1-9)
    if (n < 10) return _wordsUnits[n];

    // Handle tens and units (10-99)
    final int tensDigit = n ~/ 10;
    final int unitDigit = n % 10;

    final String tensWord = _wordsTens[tensDigit]; // e.g., "он", "жиырма"

    // If it's a round ten (10, 20, 30, etc.)
    if (unitDigit == 0) {
      return tensWord;
    } else {
      // Combine tens word and unit word (e.g., "жиырма" + " " + "бес")
      return "$tensWord ${_wordsUnits[unitDigit]}";
    }
  }
}
