import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/sq_options.dart';
import '../utils/utils.dart';

/// {@template num2text_sq}
/// The Albanian language (`Lang.SQ`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Albanian word representation following standard Albanian grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [SqOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (long scale:
/// mijë, milion, miliard, bilion, etc.).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [SqOptions].
/// {@endtemplate}
class Num2TextSQ implements Num2TextBase {
  // --- Linguistic Constants ---

  /// The word for zero.
  static const String _zero = "zero";

  /// The word for the decimal separator when using a period/point.
  static const String _pointWord = "pikë";

  /// The word for the decimal separator when using a comma (default).
  static const String _commaWord = "presje";

  /// The word for "hundred".
  static const String _hundred = "qind";

  /// The standard connector word ("e") used in compound numbers (e.g., "njëzet e një").
  static const String _connector = "e";

  /// A single space character for joining words.
  static const String _space = " ";

  // --- Scale Number Names (Long Scale) ---
  /// The word for "thousand".
  static const String _thousand = "mijë";

  /// The word for "million".
  static const String _million = "milion";

  /// The word for "milliard" (10^9).
  static const String _milliard = "miliard";

  /// The word for "billion" (10^12).
  static const String _billion = "bilion";

  /// The word for "billiard" (10^15).
  static const String _billiard = "biliard";

  /// The word for "trillion" (10^18).
  static const String _trillion = "trilion";

  /// The word for "trilliard" (10^21).
  static const String _trilliard = "triliard";

  /// The word for "quadrillion" (10^24).
  static const String _quadrillion = "katrilion";

  // --- Year Formatting Suffixes ---
  /// Suffix for years Before Christ ("para erës sonë").
  static const String _yearSuffixBC = "p.e.s.";

  /// Suffix for years Anno Domini ("era jonë").
  static const String _yearSuffixAD = "e.s.";

  // --- Special Number Representations ---
  /// Representation for positive infinity.
  static const String _infinity = "Pafundësi";

  /// Representation for negative infinity.
  static const String _negativeInfinity = "Minus pafundësi";

  /// Representation for Not-a-Number (NaN).
  static const String _notANumber = "Nuk është numër";

  /// Words for numbers 0-19.
  static const List<String> _wordsUnder20 = [
    "zero", // 0
    "një", // 1
    "dy", // 2
    "tre", // 3
    "katër", // 4
    "pesë", // 5
    "gjashtë", // 6
    "shtatë", // 7
    "tetë", // 8
    "nëntë", // 9
    "dhjetë", // 10
    "njëmbëdhjetë", // 11
    "dymbëdhjetë", // 12
    "trembëdhjetë", // 13
    "katërmbëdhjetë", // 14
    "pesëmbëdhjetë", // 15
    "gjashtëmbëdhjetë", // 16
    "shtatëmbëdhjetë", // 17
    "tetëmbëdhjetë", // 18
    "nëntëmbëdhjetë", // 19
  ];

  /// Words for tens (20, 30,... 90). Index corresponds to the tens digit (index 2 is "twenty").
  static const List<String> _wordsTens = [
    "", // 0 (unused)
    "", // 1 (unused - handled by _wordsUnder20)
    "njëzet", // 20
    "tridhjetë", // 30
    "dyzet", // 40
    "pesëdhjetë", // 50
    "gjashtëdhjetë", // 60
    "shtatëdhjetë", // 70
    "tetëdhjetë", // 80
    "nëntëdhjetë", // 90
  ];

  /// Scale words (thousand, million, etc.) used for large numbers. Follows the long scale system.
  static const List<String> _scaleWords = [
    "", // 0: Units
    _thousand, // 1: 10^3
    _million, // 2: 10^6
    _milliard, // 3: 10^9
    _billion, // 4: 10^12
    _billiard, // 5: 10^15
    _trillion, // 6: 10^18
    _trilliard, // 7: 10^21
    _quadrillion, // 8: 10^24
    // Add more if needed, ensure they follow the long scale pattern (..., quintillion, quintilliard, ...)
  ];

  /// Processes the given number and converts it to Albanian words based on the provided options.
  ///
  /// - [number]: The number to convert (can be `int`, `double`, `String`, `BigInt`, `Decimal`).
  /// - [options]: An optional `SqOptions` object to customize the conversion (e.g., currency, year format).
  ///              If null or not an `SqOptions` instance, default options are used.
  /// - [fallbackOnError]: An optional string to return if the input `number` is invalid or cannot be processed.
  ///                      If null, a default error message (`_notANumber`) is used.
  ///
  /// Returns the word representation of the number in Albanian, or an error/fallback string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have Albanian-specific options, using defaults if necessary.
    final SqOptions sqOptions =
        options is SqOptions ? options : const SqOptions();
    final String effectiveFallback = fallbackOnError ?? _notANumber;

    // Handle special double values first.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? _negativeInfinity : _infinity;
      }
      if (number.isNaN) {
        return effectiveFallback;
      }
    }

    // Normalize the input number to a Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // If normalization fails, return the fallback or default error message.
    if (decimalValue == null) {
      return effectiveFallback;
    }

    // Handle the specific case of zero.
    if (decimalValue == Decimal.zero) {
      // Currency format for zero might need the plural unit name.
      if (sqOptions.currency) {
        return "$_zero$_space${sqOptions.currencyInfo.mainUnitPlural ?? sqOptions.currencyInfo.mainUnitSingular}";
      } else {
        // Standard zero representation.
        return _zero;
      }
    }

    // Determine sign and get absolute value for conversion.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Branch based on the specified format option.
    if (sqOptions.format == Format.year) {
      // Years require special handling for BC/AD suffixes.
      if (!absValue.isInteger) {
        // Cannot format a non-integer year.
        return effectiveFallback;
      }
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), sqOptions);
    } else {
      // Handle currency or standard number formats.
      if (sqOptions.currency) {
        textResult = _handleCurrency(absValue, sqOptions);
      } else {
        textResult = _handleStandardNumber(absValue, sqOptions);
      }

      // Prepend the negative prefix if the original number was negative.
      if (isNegative) {
        textResult = "${sqOptions.negativePrefix}$_space$textResult";
      }
    }

    return textResult;
  }

  /// Formats an integer as a year, adding BC/AD suffixes as needed.
  ///
  /// - [year]: The integer year value.
  /// - [options]: The `SqOptions` containing formatting preferences.
  ///
  /// Returns the year as words, potentially with "p.e.s." (BC) or "e.s." (AD).
  String _handleYearFormat(int year, SqOptions options) {
    final bool isNegative = year < 0;
    // Convert the absolute value of the year to words.
    final BigInt absYearBigInt = BigInt.from(year.abs());
    String yearText = _convertInteger(absYearBigInt);

    // Append suffixes based on sign and options.
    if (isNegative) {
      // Negative years always get the BC suffix.
      yearText += "$_space$_yearSuffixBC";
    } else if (options.includeAD && year > 0) {
      // Positive years get the AD suffix only if includeAD is true.
      yearText += "$_space$_yearSuffixAD";
    }

    return yearText;
  }

  /// Formats a positive `Decimal` number as currency according to `SqOptions`.
  ///
  /// - [absValue]: The absolute decimal value of the amount.
  /// - [options]: The `SqOptions` containing currency info and rounding rules.
  ///
  /// Returns the currency value as words (e.g., "njëqind lekë e pesëdhjetë qindarka").
  String _handleCurrency(Decimal absValue, SqOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    // Standard currency typically has 2 decimal places for subunits.
    const int decimalPlaces = 2;
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value if requested before splitting into main and subunits.
    final Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Extract the main unit (integer part) and subunit value.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Use round() to avoid potential precision issues in subunit calculation
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round().toBigInt();

    String mainPartString = "";
    if (mainValue > BigInt.zero) {
      // Convert the main value to words.
      final String mainText = _convertInteger(mainValue);
      // Choose singular or plural main unit name.
      final String mainUnitName = (mainValue == BigInt.one)
          ? currencyInfo.mainUnitSingular
          : (currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular);
      mainPartString = '$mainText$_space$mainUnitName';
    }

    String subunitPartString = "";
    if (subunitValue > BigInt.zero) {
      // Convert the subunit value to words.
      final String subunitText = _convertInteger(subunitValue);
      // Choose singular or plural subunit name (fallback to singular if plural missing).
      final String subUnitName = (subunitValue == BigInt.one)
          ? (currencyInfo.subUnitSingular ?? "")
          : (currencyInfo.subUnitPlural ?? currencyInfo.subUnitSingular ?? "");
      // Ensure subunit name is not empty before adding space
      subunitPartString = subUnitName.isNotEmpty
          ? '$subunitText$_space$subUnitName'
          : subunitText;
    }

    // Combine main and subunit parts with the appropriate separator.
    if (mainPartString.isNotEmpty && subunitPartString.isNotEmpty) {
      // Use the provided separator, or default to the connector "e".
      final String separator = currencyInfo.separator ?? _connector;
      return '$mainPartString$_space$separator$_space$subunitPartString';
    } else if (mainPartString.isNotEmpty) {
      return mainPartString;
    } else if (subunitPartString.isNotEmpty) {
      return subunitPartString;
    } else {
      // If both parts are zero (after rounding, or initial value was 0), represent zero main unit.
      return "$_zero$_space${currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular}";
    }
  }

  /// Formats a positive `Decimal` number in standard cardinal form, including decimals.
  ///
  /// - [absValue]: The absolute decimal value of the number.
  /// - [options]: The `SqOptions` controlling decimal separator.
  ///
  /// Returns the number as words (e.g., "njëqind e njëzet e tre presje katër pesë").
  String _handleStandardNumber(Decimal absValue, SqOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part, handling the case where it's zero but there's a fractional part.
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Determine the decimal separator word based on options.
      String separatorWord;
      switch (options.decimalSeparator ?? DecimalSeparator.comma) {
        case DecimalSeparator.comma:
          separatorWord = _commaWord;
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          separatorWord = _pointWord;
          break;
      }

      // Extract fractional digits *after* the decimal point from the string representation.
      final String fractionalString = absValue.toString();
      final String fractionalDigits = fractionalString.contains('.')
          ? fractionalString.split('.').last
          : '';

      // Remove trailing zeros as they are not typically spoken.
      final String significantFractionalDigits =
          fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      // If only zeros were present, don't add the fractional part.
      if (significantFractionalDigits.isNotEmpty) {
        // Convert each digit after the decimal point to its word form.
        final List<String> digitWords =
            significantFractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          return (digitInt != null && digitInt >= 0 && digitInt <= 19)
              ? _wordsUnder20[digitInt]
              : '?'; // Placeholder for error
        }).toList();

        // Combine the digits with spaces.
        fractionalWords =
            '$_space$separatorWord$_space${digitWords.join(_space)}';
      }
    }

    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative `BigInt` into Albanian words.
  ///
  /// This method handles large numbers by breaking them into chunks of 1000
  /// and applying scale words (thousand, million, etc.).
  ///
  /// - [n]: The non-negative integer to convert.
  ///
  /// Returns the integer as words. Throws `ArgumentError` if `n` is negative or too large.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero) {
      // This should ideally be caught earlier, but added as a safeguard.
      throw ArgumentError("Integer must be non-negative: $n");
    }
    if (n == BigInt.zero) return _zero; // Base case: zero

    // Handle numbers less than 1000 directly using the chunk converter.
    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt());
    }

    final List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0;
    BigInt remaining = n;

    // Process the number in chunks of 1000 from right to left.
    while (remaining > BigInt.zero) {
      // Check if the number exceeds the defined scale words.
      if (scaleIndex >= _scaleWords.length) {
        throw ArgumentError(
            "Number too large (exceeds defined scales: ${_scaleWords.last})");
      }

      // Extract the current chunk (0-999).
      final int chunk = (remaining % oneThousand).toInt();
      remaining ~/= oneThousand; // Move to the next chunk.

      if (chunk > 0) {
        // Convert the chunk to words.
        final String chunkText = _convertChunk(chunk);
        final String scaleWord = scaleIndex > 0 ? _scaleWords[scaleIndex] : "";

        String combinedPart;
        if (scaleWord.isNotEmpty) {
          // Special case for "një mijë" (one thousand).
          if (scaleWord == _thousand && chunk == 1) {
            combinedPart = "një$_space$scaleWord";
          } else {
            combinedPart = "$chunkText$_space$scaleWord";
          }
        } else {
          // No scale word for the first chunk (units).
          combinedPart = chunkText;
        }
        parts.add(combinedPart);
      }
      scaleIndex++;
    }

    // Join the parts in reverse order (highest scale first) with the connector.
    // Example: [gjashtë, pesëdhjetë mijë, njëqind milion] -> "njëqind milion e pesëdhjetë mijë e gjashtë"
    return parts.reversed.join("$_space$_connector$_space").trim();
  }

  /// Converts a number between 0 and 99 into Albanian words.
  ///
  /// - [n]: The number to convert (0-99).
  ///
  /// Returns the number as words. Throws `ArgumentError` if `n` is out of range.
  String _convertUnder100(int n) {
    if (n < 0 || n >= 100) {
      throw ArgumentError("Number must be between 0 and 99: $n");
    }

    // Numbers below 20 have unique names.
    if (n < 20) {
      return _wordsUnder20[n];
    } else {
      // Numbers 20 and above are formed by combining tens and units.
      final String tensWord = _wordsTens[n ~/ 10];
      final int unit = n % 10;
      if (unit == 0) {
        // Exact tens (20, 30, etc.).
        return tensWord;
      } else {
        // Combine tens and units (e.g., "njëzet e një").
        return "$tensWord$_space$_connector$_space${_wordsUnder20[unit]}";
      }
    }
  }

  /// Converts a three-digit number (0-999) into Albanian words.
  ///
  /// - [n]: The number chunk to convert.
  ///
  /// Returns the chunk as words. Throws `ArgumentError` if `n` is out of range.
  String _convertChunk(int n) {
    if (n == 0)
      return ""; // Empty string for a zero chunk (handled in _convertInteger).
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }

    // Handle numbers less than 100 using the dedicated helper.
    if (n < 100) {
      return _convertUnder100(n);
    }

    // Handle numbers 100-999.
    final List<String> words = [];
    int remainder = n;

    // Process the hundreds place.
    final int hundredDigit = remainder ~/ 100;
    if (hundredDigit == 1) {
      words.add("njëqind"); // Special case for 100
    } else if (hundredDigit == 2) {
      words.add("dyqind"); // Special case for 200
    } else {
      // Other hundreds (300, 400, etc.)
      // Use the basic unit word + "qind" (e.g., "tre" + "qind" = "treqind")
      words.add("${_wordsUnder20[hundredDigit]}$_hundred");
    }
    remainder %= 100;

    // Process the remaining part (0-99) if it's non-zero.
    if (remainder > 0) {
      words.add(_connector); // Add the connector "e".
      words.add(_convertUnder100(remainder)); // Convert the remainder.
    }

    // Join the parts (e.g., ["njëqind", "e", "njëzet", "e", "tre"]).
    return words.join(_space);
  }
}
