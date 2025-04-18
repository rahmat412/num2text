import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/sw_options.dart';
import '../utils/utils.dart';

/// {@template num2text_sw}
/// The Swahili language (Lang.SW) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Swahili word representation following standard Swahili grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [SwOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers.
/// Swahili uses a base-10 system with specific words like "laki" (100,000) and the
/// conjunction "na" is used extensively, except potentially between major scales in year formatting.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [SwOptions].
///
/// **Example Usage:**
/// ```dart
/// final converter = Num2Text(initialLang: Lang.SW);
/// print(converter.convert(123)); // Output: mia moja na ishirini na tatu
/// print(converter.convert(150000)); // Output: laki moja na elfu hamsini
/// print(converter.convert(1.5, options: SwOptions(currency: true))); // Output: shilingi moja na senti hamsini
/// print(converter.convert(1900, options: SwOptions(format: Format.year))); // Output: elfu moja mia tisa
/// print(converter.convert(2024, options: SwOptions(format: Format.year))); // Output: elfu mbili ishirini na nne
/// ```
/// {@endtemplate}
class Num2TextSW implements Num2TextBase {
  // --- Private Constants ---

  /// The Swahili word for zero.
  static const String _zero = "sifuri";

  /// The Swahili word for hundred (used as a base for forming hundreds).
  static const String _hundred = "mia";

  /// The Swahili word for thousand.
  static const String _thousand = "elfu";

  /// The Swahili word for one hundred thousand (100,000).
  static const String _lakh = "laki";

  /// The Swahili conjunction "and", used to connect number parts.
  static const String _na = "na";

  /// The default Swahili word for the decimal point.
  static const String _point = "pointi";

  /// The Swahili word for comma (used as an alternative decimal separator).
  static const String _comma = "koma";

  /// The Swahili suffix for BC/BCE years ("Kabla ya Kristo").
  static const String _yearSuffixBC = "KK";

  /// The Swahili suffix for AD/CE years ("Baada ya Kristo").
  static const String _yearSuffixAD = "BK";

  /// Words for numbers 0 through 19.
  static const List<String> _wordsUnder20 = [
    _zero, // 0
    "moja", // 1
    "mbili", // 2
    "tatu", // 3
    "nne", // 4
    "tano", // 5
    "sita", // 6
    "saba", // 7
    "nane", // 8
    "tisa", // 9
    "kumi", // 10
    "kumi na moja", // 11
    "kumi na mbili", // 12
    "kumi na tatu", // 13
    "kumi na nne", // 14
    "kumi na tano", // 15
    "kumi na sita", // 16
    "kumi na saba", // 17
    "kumi na nane", // 18
    "kumi na tisa", // 19
  ];

  /// Words for tens (20, 30, ..., 90). Index corresponds to tens digit (index 2 = 20).
  static const List<String> _wordsTens = [
    "", // 0 (unused)
    "", // 10 (handled by _wordsUnder20)
    "ishirini", // 20
    "thelathini", // 30
    "arobaini", // 40
    "hamsini", // 50
    "sitini", // 60
    "sabini", // 70
    "themanini", // 80
    "tisini", // 90
  ];

  /// Words for hundreds (100, 200, ..., 900). Index corresponds to hundreds digit.
  static const List<String> _wordsHundreds = [
    "", // 0 (unused)
    "$_hundred moja", // 100
    "$_hundred mbili", // 200
    "$_hundred tatu", // 300
    "$_hundred nne", // 400
    "$_hundred tano", // 500
    "$_hundred sita", // 600
    "$_hundred saba", // 700
    "$_hundred nane", // 800
    "$_hundred tisa", // 900
  ];

  /// Scale words (thousand, million, billion, etc.). Index corresponds to power of 1000.
  static const List<String> _scaleWords = [
    "", // 1000^0 (Units - handled separately)
    _thousand, // 1000^1
    "milioni", // 1000^2
    "bilioni", // 1000^3
    "trilioni", // 1000^4
    "kwadrilioni", // 1000^5
    "kwintilioni", // 1000^6
    "sekstilioni", // 1000^7
    "septilioni", // 1000^8
    // Add more scales here if needed
  ];

  /// Constant for BigInt 1000.
  static final BigInt _oneThousand = BigInt.from(1000);

  /// Constant for BigInt 100,000 (Laki).
  static final BigInt _oneLakh = BigInt.from(100000);

  /// Constant for BigInt 1,000,000 (Million).
  static final BigInt _oneMillion = BigInt.from(1000000);

  /// Constant for Decimal 100 (used for currency subunits).
  static final Decimal _decimalOneHundred = Decimal.fromInt(100);

  /// Processes the given number into Swahili words based on the provided options.
  ///
  /// This is the main entry point for the conversion.
  ///
  /// - [number]: The number to convert (can be `int`, `double`, `BigInt`, `Decimal`, or `String`).
  /// - [options]: An optional [SwOptions] object to customize the conversion (e.g., currency, year format). If null or not `SwOptions`, default Swahili options are used.
  /// - [fallbackOnError]: An optional string to return if the input `number` is invalid or cannot be processed. If null, a default error message ("Si nambari") is used.
  ///
  /// Returns:
  ///   The Swahili word representation of the number, or an error/fallback string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final SwOptions swOptions =
        options is SwOptions ? options : const SwOptions();
    final String fallback = fallbackOnError ?? "Si nambari"; // Default fallback

    // Handle special double values first
    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Hasi ukomo" : "Ukomo"; // Use lowercase
      if (number.isNaN) return fallback;
    }

    // Normalize the input number to Decimal
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return fallback;

    // Handle zero separately for clarity and potential currency format
    if (decimalValue == Decimal.zero) {
      if (swOptions.currency) {
        // Ensure mainUnitSingular is used for zero currency.
        return "${swOptions.currencyInfo.mainUnitSingular} $_zero";
      }
      return _zero;
    }

    // Determine sign and use absolute value for core conversion
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Branch based on formatting options
    if (swOptions.format == Format.year) {
      // Year formatting requires integer part only
      textResult = _handleYearFormat(
          absValue.truncate().toBigInt(), isNegative, swOptions);
    } else if (swOptions.currency) {
      // Currency uses standard 'na' usage
      textResult = _handleCurrency(absValue, swOptions);
    } else {
      // Standard numbers use standard 'na' usage
      textResult = _handleStandardNumber(absValue, swOptions);
    }

    // Prepend negative prefix if needed (and not handled by year format)
    if (isNegative && swOptions.format != Format.year) {
      textResult = "${swOptions.negativePrefix} $textResult";
    }

    // Return the final trimmed result
    return textResult.trim();
  }

  /// Formats a number as a Swahili year.
  ///
  /// Handles positive and negative years, adding "KK" (BC/BCE) for negative
  /// years and "BK" (AD/CE) for positive years if `options.includeAD` is true.
  /// Importantly, it typically omits the conjunction "na" between major scales
  /// (e.g., "elfu moja mia tisa" for 1900, not "elfu moja na mia tisa").
  ///
  /// - [absYearValue]: The absolute (non-negative) year value as a BigInt.
  /// - [isOriginalNegative]: Whether the original input year was negative.
  /// - [options]: The Swahili options, specifically checking `includeAD`.
  ///
  /// Returns:
  ///   The formatted year string.
  String _handleYearFormat(
      BigInt absYearValue, bool isOriginalNegative, SwOptions options) {
    // Convert the absolute year value to words, explicitly WITHOUT 'na' between scales
    String yearText = _convertInteger(absYearValue, includeNa: false);

    // Append appropriate suffix based on original sign and options
    if (isOriginalNegative) {
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD) {
      yearText += " $_yearSuffixAD";
    }
    return yearText;
  }

  /// Formats a number as Swahili currency.
  ///
  /// Handles main units (e.g., Shilingi) and subunits (e.g., Senti)
  /// using the details from `options.currencyInfo`. Uses standard Swahili
  /// conjunction ("na") rules.
  ///
  /// - [absValue]: The absolute (non-negative) `Decimal` value of the currency.
  /// - [options]: The Swahili options, providing `currencyInfo` and `round` settings.
  ///
  /// Returns:
  ///   The formatted currency string.
  String _handleCurrency(Decimal absValue, SwOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    const int decimalPlaces = 2; // Standard for most currencies

    // Round the value if requested, otherwise use as is
    final Decimal valueToConvert =
        options.round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main and subunit values
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    // Calculate subunit value carefully from the fractional part
    final BigInt subunitValue =
        ((valueToConvert - valueToConvert.truncate()) * _decimalOneHundred)
            .truncate() // Use truncate, not round, after multiplication
            .toBigInt();

    final StringBuffer buffer = StringBuffer();

    // Add main unit part if greater than zero or if subunit is zero (to handle 0.00 case)
    if (mainValue > BigInt.zero || subunitValue == BigInt.zero) {
      // Convert main part WITH 'na' (standard)
      final String mainText = _convertInteger(mainValue, includeNa: true);
      // Determine pluralization for the main unit (usually invariable in Swahili currency names)
      // Use singular for 1, plural/singular otherwise.
      final String mainUnitName = (mainValue == BigInt.one)
          ? currencyInfo.mainUnitSingular
          : currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;
      buffer.write('$mainUnitName $mainText');
    }

    // Add subunit part if greater than zero
    if (subunitValue > BigInt.zero) {
      // Add separator ("na") if both main and subunit parts exist
      final String separator = currencyInfo.separator ?? _na;
      if (buffer.isNotEmpty && separator.isNotEmpty) {
        buffer.write(' $separator ');
      }

      // Convert subunit part WITH 'na' (standard)
      final String subunitText = _convertInteger(subunitValue, includeNa: true);
      // Ensure subUnitSingular is not null before accessing
      final String defaultSubUnit = currencyInfo.subUnitSingular ?? '';
      // Determine pluralization for the subunit (usually invariable)
      final String subUnitName = (subunitValue == BigInt.one)
          ? defaultSubUnit
          : currencyInfo.subUnitPlural ?? defaultSubUnit;
      buffer.write('$subUnitName $subunitText');
    }

    return buffer.toString();
  }

  /// Handles standard number conversion (integers and decimals).
  ///
  /// Converts the integer part and the fractional part separately and joins them
  /// with the appropriate decimal separator word ("pointi" or "koma").
  /// Uses standard Swahili conjunction ("na") rules for the integer part.
  /// Fractional digits are converted individually.
  ///
  /// - [absValue]: The absolute (non-negative) `Decimal` value.
  /// - [options]: The Swahili options, providing `decimalSeparator`.
  ///
  /// Returns:
  ///   The formatted standard number string.
  String _handleStandardNumber(Decimal absValue, SwOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part WITH 'na' (standard)
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, includeNa: true);

    // Handle fractional part if it exists
    if (fractionalPart > Decimal.zero) {
      final StringBuffer fractionalBuffer = StringBuffer();

      // Determine the separator word based on options
      final String separatorWord;
      switch (options.decimalSeparator ?? DecimalSeparator.period) {
        // Default to period
        case DecimalSeparator.comma:
          separatorWord = _comma;
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          separatorWord = _point;
          break;
      }
      fractionalBuffer.write(' $separatorWord');

      // Get fractional digits as a string
      String fractionalDigits = absValue.toString().split('.').last;

      // Convert each digit individually
      fractionalDigits.split('').forEach((digit) {
        final int digitInt = int.parse(digit);
        // Ensure index is within bounds (0-9)
        fractionalBuffer.write(' ${_wordsUnder20[digitInt]}');
      });
      return '$integerWords${fractionalBuffer.toString()}';
    } else {
      // No fractional part, return only integer words
      return integerWords;
    }
  }

  /// Converts a non-negative integer `BigInt` into Swahili words.
  ///
  /// This function orchestrates the conversion by breaking the number
  /// down into chunks based on Swahili's number system structure
  /// (thousands, lakhs, millions, etc.).
  ///
  /// - [n]: The non-negative `BigInt` to convert.
  /// - [includeNa]: Whether to include the conjunction "na" between major scales
  ///     (lakhs/thousands, millions/lakhs, etc.). Defaults to `true`. Should be
  ///     `false` for year formatting.
  ///
  /// Returns:
  ///   The Swahili word representation of the integer.
  /// Throws [ArgumentError] if `n` is negative or too large for defined scales.
  String _convertInteger(BigInt n, {bool includeNa = true}) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");

    // Handle numbers less than a million using a dedicated helper, passing includeNa
    if (n < _oneMillion) {
      return _convertUnderMillion(n, includeNa: includeNa);
    }

    final StringBuffer buffer = StringBuffer();
    BigInt remainder = n;

    // Determine the highest scale needed (million, billion, etc.)
    int scaleIndex = 0;
    BigInt tempN = n;
    // Calculate the highest scale index (power of 1000)
    while (tempN >= _oneThousand) {
      scaleIndex++;
      tempN ~/= _oneThousand;
    }

    // Check if the scale index is within the supported range
    if (scaleIndex >= _scaleWords.length) {
      throw ArgumentError(
          "Number too large (exceeds defined scales: ${_scaleWords.last})");
    }

    // Iterate down through scales (billion, million, etc., starting from index 2 for million)
    for (int i = scaleIndex; i >= 2; i--) {
      BigInt scalePower = BigInt.from(1000).pow(i);
      BigInt chunk =
          remainder ~/ scalePower; // Number of millions, billions, etc.
      remainder %= scalePower; // Remaining part after this scale

      if (chunk == BigInt.zero) continue; // Skip if this scale chunk is zero

      // Convert the chunk value (which is less than 1M, so use helper)
      String chunkText = _convertUnderMillion(
        chunk,
        includeNa: true,
      ); // Always include 'na' within the chunk factor

      // Add separator BETWEEN scales based on includeNa flag
      if (buffer.isNotEmpty) {
        buffer.write(includeNa ? ' $_na ' : ' ');
      }
      // Add scale word and its converted value
      buffer.write("${_scaleWords[i]} $chunkText");
    }

    // Handle the remaining part (less than a million)
    if (remainder > BigInt.zero) {
      // Add separator BETWEEN last major scale and the under-million part based on includeNa
      if (buffer.isNotEmpty) {
        buffer.write(includeNa ? ' $_na ' : ' ');
      }
      // Convert the remaining part, passing the includeNa flag down
      buffer.write(_convertUnderMillion(remainder, includeNa: includeNa));
    }

    return buffer.toString();
  }

  /// Converts a non-negative integer less than one million (0 to 999,999)
  /// into Swahili words, handling the special "laki" (100,000) case.
  ///
  /// - [n]: The non-negative `BigInt` (0 <= n < 1,000,000).
  /// - [includeNa]: Whether to include "na" between the lakhs/thousands chunk
  ///     and the final under-thousand chunk.
  ///
  /// Returns:
  ///   The Swahili word representation.
  /// Throws [ArgumentError] if `n` is outside the valid range.
  String _convertUnderMillion(BigInt n, {bool includeNa = true}) {
    if (n == BigInt.zero)
      return ""; // Return empty for zero input in this context
    if (n < BigInt.zero || n >= _oneMillion) {
      throw ArgumentError(
          "_convertUnderMillion input must be 0 <= n < 1,000,000: $n");
    }

    final StringBuffer buffer = StringBuffer();
    BigInt remainder = n;

    // Handle "Laki" (100,000s)
    if (remainder >= _oneLakh) {
      BigInt lakhs = remainder ~/ _oneLakh; // Number of lakhs (1-9)
      // Convert the count of lakhs (always < 10, handled by _convertUnderThousand)
      buffer.write("$_lakh ${_convertUnderThousand(lakhs)}");
      remainder %= _oneLakh; // Remaining part after lakhs
    }

    // Handle thousands part (0-99,999)
    if (remainder >= _oneThousand) {
      BigInt thousands =
          remainder ~/ _oneThousand; // Number of thousands (1-99)
      // Add separator BETWEEN lakhs and thousands based on includeNa
      if (buffer.isNotEmpty) {
        buffer.write(includeNa ? ' $_na ' : ' ');
      }
      // Convert thousand count (internal 'na' handled within _convertUnderThousand)
      buffer.write("$_thousand ${_convertUnderThousand(thousands)}");
      remainder %= _oneThousand; // Remaining part after thousands
    }

    // Handle the remaining part (less than 1000)
    if (remainder > BigInt.zero) {
      // Add separator BETWEEN thousands/lakhs and the under-thousand part based on includeNa
      if (buffer.isNotEmpty) {
        buffer.write(includeNa ? ' $_na ' : ' ');
      }
      // Convert remainder (internal 'na' handled within _convertUnderThousand)
      buffer.write(_convertUnderThousand(remainder));
    }

    return buffer.toString();
  }

  /// Converts a non-negative integer less than one thousand (0 to 999)
  /// into Swahili words. Handles the internal connections (e.g., between
  /// hundreds and tens/units) using the standard "na".
  ///
  /// - [n]: The non-negative `BigInt` (0 <= n < 1000).
  ///
  /// Returns:
  ///   The Swahili word representation.
  /// Throws [ArgumentError] if `n` is outside the valid range.
  String _convertUnderThousand(BigInt n) {
    if (n == BigInt.zero) return ""; // Return empty for zero in this context
    if (n < BigInt.zero || n >= _oneThousand) {
      throw ArgumentError(
          "_convertUnderThousand input must be 0 <= n < 1000: $n");
    }

    int num = n.toInt(); // Safe to convert to int as n < 1000
    final StringBuffer buffer = StringBuffer();
    int remainder = num;

    // Handle hundreds
    if (remainder >= 100) {
      buffer.write(_wordsHundreds[remainder ~/ 100]);
      remainder %= 100;
    }

    // Handle tens and units
    if (remainder > 0) {
      // Add "na" if there was a hundreds part
      if (buffer.isNotEmpty) {
        buffer.write(' $_na ');
      }

      if (remainder < 20) {
        // Numbers 1-19
        buffer.write(_wordsUnder20[remainder]);
      } else {
        // Numbers 20-99
        buffer.write(_wordsTens[remainder ~/ 10]);
        int unit = remainder % 10;
        if (unit > 0) {
          // Add "na" before the unit > 0
          buffer.write(' $_na ');
          buffer.write(_wordsUnder20[unit]);
        }
      }
    }

    return buffer.toString();
  }
}
