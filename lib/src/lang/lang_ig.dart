import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ig_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ig}
/// The Igbo language (Lang.IG) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Igbo word representation following Igbo grammar and number system rules.
///
/// Capabilities include handling cardinal numbers, currency (using [IgOptions.currencyInfo] - defaults to NGN Igbo terms),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers using Igbo scale words
/// (puku, nde, ijeri, etc.). The conjunction "na" is used extensively.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [IgOptions].
/// {@endtemplate}
class Num2TextIG implements Num2TextBase {
  /// The conjunction "na" (and), used to connect number parts.
  static const String _na = "na";

  /// The word for zero.
  static const String _zero = "efu";

  /// The word for the decimal point/period separator ("ntụpọ").
  static const String _point = "ntụpọ";

  /// The word for the decimal comma separator ("rikoma").
  static const String _comma = "rikoma";

  /// Suffix for negative years (BC - Before Christ).
  static const String _yearSuffixBC = "BC";

  /// Suffix for positive years (AD - Anno Domini / Mgbe Kraịst).
  /// Added only if [IgOptions.includeAD] is true.
  static const String _yearSuffixAD = "AD";

  /// Word for infinity ("Anwụ Anwụ").
  static const String _infinity = "Anwụ Anwụ";

  /// Word for "Not a Number" ("Abụghị Ọnụọgụ").
  static const String _notANumber = "Abụghị Ọnụọgụ";

  /// Words for numbers 0 through 19.
  static const List<String> _wordsUnder20 = [
    "efu", // 0
    "otu", // 1
    "abụọ", // 2
    "atọ", // 3
    "anọ", // 4
    "ise", // 5
    "isii", // 6
    "asaa", // 7
    "asatọ", // 8
    "itoolu", // 9
    "iri", // 10
    "iri na otu", // 11
    "iri na abụọ", // 12
    "iri na atọ", // 13
    "iri na anọ", // 14
    "iri na ise", // 15
    "iri na isii", // 16
    "iri na asaa", // 17
    "iri na asatọ", // 18
    "iri na itoolu", // 19
  ];

  /// Words for tens (20, 30, ..., 90). Index 0 and 1 are unused.
  static const List<String> _wordsTens = [
    "", // 0 (unused)
    "", // 10 (handled by _wordsUnder20)
    "iri abụọ", // 20
    "iri atọ", // 30
    "iri anọ", // 40
    "iri ise", // 50
    "iri isii", // 60
    "iri asaa", // 70
    "iri asatọ", // 80
    "iri itoolu", // 90
  ];

  /// The word for hundred ("narị").
  static const String _hundred = "narị";

  /// The word for thousand ("puku").
  static const String _thousand = "puku";

  /// The word for million ("nde").
  static const String _million = "nde";

  /// The word for billion ("ijeri").
  static const String _billion = "ijeri";

  /// Names for number scales (thousand, million, billion, etc.).
  /// Follows a pattern combining base scales. Index 0 is for units (no scale name).
  /// Note: The exact representation for very large numbers can sometimes vary,
  /// this implementation follows a common pattern.
  static const List<String> _scaleNames = [
    "", // 10^0
    _thousand, // 10^3
    _million, // 10^6
    _billion, // 10^9
    "$_thousand $_billion", // 10^12 - Trillion (puku ijeri)
    "$_million $_billion", // 10^15 - Quadrillion (nde ijeri)
    "$_billion $_billion", // 10^18 - Quintillion (ijeri ijeri)
    "$_thousand $_billion $_billion", // 10^21 - Sextillion (puku ijeri ijeri)
    "$_million $_billion $_billion", // 10^24 - Septillion (nde ijeri ijeri)
    // Add more scales here if needed, following the pattern.
    // e.g., "$_billion $_billion $_billion" for 10^27 (Octillion - ijeri ijeri ijeri)
  ];

  /// Capitalizes the first letter of a string.
  ///
  /// Used for capitalizing the negative prefix in case of negative infinity.
  /// - [s]: The string to capitalize.
  /// Returns the capitalized string.
  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s.substring(0, 1).toUpperCase() + s.substring(1);
  }

  /// Converts the given number into its Igbo word representation.
  ///
  /// Delegates the conversion process to helper methods based on the provided [options].
  /// Handles various numeric types, special double values (NaN, infinity), and formatting options
  /// like currency, year, and decimal separators.
  ///
  /// - [number] The number to convert (can be `int`, `double`, `BigInt`, `Decimal`, `String`).
  /// - [options] Optional [IgOptions] to customize formatting. If null or not [IgOptions], default options are used.
  /// - [fallbackOnError] A custom string to return if conversion fails (e.g., for invalid input).
  /// Returns the number in Igbo words, or `fallbackOnError` or a default Igbo error message if conversion fails.
  /// Handles `double.infinity` and `double.nan` as special cases.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final IgOptions igOptions =
        options is IgOptions ? options : const IgOptions();
    final String errorFallback = fallbackOnError ?? _notANumber;

    // Handle special double values first
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? "${_capitalize(igOptions.negativePrefix)} $_infinity" // "Mwepu Anwụ Anwụ"
            : _infinity; // "Anwụ Anwụ"
      }
      if (number.isNaN) {
        return errorFallback;
      }
    }

    // Normalize the input number to Decimal
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) {
      return errorFallback;
    }

    // Handle zero separately
    if (decimalValue == Decimal.zero) {
      if (igOptions.currency) {
        // e.g., "efu Naira" (assuming singular for zero amount)
        return "$_zero ${igOptions.currencyInfo.mainUnitSingular}";
      } else {
        return _zero;
      }
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for conversion logic
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // --- Year Formatting ---
    if (igOptions.format == Format.year) {
      // Years are treated as integers
      final BigInt yearValue = absValue.truncate().toBigInt();
      textResult = _convertInteger(yearValue);

      if (isNegative) {
        textResult += " $_yearSuffixBC"; // Always add BC for negative years
      } else if (igOptions.includeAD) {
        textResult +=
            " $_yearSuffixAD"; // Add AD for positive years only if requested
      }
    }
    // --- Currency Formatting ---
    else if (igOptions.currency) {
      textResult = _handleCurrency(absValue, igOptions);
      // Add negative prefix after currency conversion if needed
      if (isNegative) {
        textResult = "${igOptions.negativePrefix} $textResult";
      }
    }
    // --- Standard Number Formatting (Integer or Decimal) ---
    else {
      // Check if there's a fractional part
      final bool hasDecimal = absValue.truncate() != absValue;

      if (hasDecimal) {
        textResult = _handleStandardNumberWithDecimal(absValue, igOptions);
      } else {
        // Pure integer conversion
        textResult = _convertInteger(absValue.truncate().toBigInt());
      }

      // Add negative prefix after standard number conversion if needed
      if (isNegative) {
        textResult = "${igOptions.negativePrefix} $textResult";
      }
    }

    return textResult;
  }

  /// Formats a number as Igbo currency (e.g., Naira and Kobo).
  ///
  /// - [absValue] The absolute decimal value of the currency amount.
  /// - [options] The [IgOptions] containing currency info and rounding rules.
  /// Returns the formatted currency string in Igbo.
  String _handleCurrency(Decimal absValue, IgOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2; // Standard currency decimal places
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value if requested, otherwise use as is
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main unit and subunit values
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).truncate().toBigInt();

    // Convert main value to words
    String mainText = (mainValue == BigInt.zero && subunitValue > BigInt.zero)
        ? "" // Don't say "efu Naira" if there are Kobo
        : (mainValue == BigInt.zero ? _zero : _convertInteger(mainValue));

    // Get currency unit names
    String mainUnitName = currencyInfo.mainUnitSingular; // e.g., Naira
    String subUnitName = currencyInfo.subUnitSingular ?? ""; // e.g., Kobo

    // Build the result string
    List<String> parts = [];
    if (mainText.isNotEmpty) {
      parts.add("$mainText $mainUnitName");
    }

    // Add subunit part if applicable
    if (subunitValue > BigInt.zero) {
      String subunitText = _convertInteger(subunitValue);
      String separator = currencyInfo.separator ?? _na;
      // Add separator only if main part exists
      if (parts.isNotEmpty) {
        parts.add(separator);
      }
      parts.add("$subunitText $subUnitName");
    }

    // Handle case where only main unit is zero (e.g., 0.50 -> "iri ise Kobo")
    if (mainValue == BigInt.zero && subunitValue > BigInt.zero) {
      String subunitText = _convertInteger(subunitValue);
      return "$subunitText $subUnitName";
    } else if (mainValue == BigInt.zero && subunitValue == BigInt.zero) {
      return "$_zero $mainUnitName"; // Return "efu Naira" for 0.00
    }

    return parts.join(' ');
  }

  /// Handles standard number conversion including decimal parts.
  ///
  /// - [absValue] The absolute decimal value of the number.
  /// - [options] The [IgOptions] containing decimal separator preference.
  /// Returns the number string including the fractional part in Igbo words.
  String _handleStandardNumberWithDecimal(Decimal absValue, IgOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part
    String integerWords = (integerPart == BigInt.zero &&
            fractionalPart > Decimal.zero)
        ? _zero // Use "efu" if integer is zero but decimal exists (e.g., 0.5)
        : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Determine the decimal separator word
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _comma; // rikoma
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period:
        default:
          separatorWord = _point; // ntụpọ
          break;
      }

      // Get fractional digits as a string, remove trailing zeros
      String fractionalDigits = absValue.toString().split('.').last;
      fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      // Convert each digit after the decimal point to words
      if (fractionalDigits.isNotEmpty) {
        List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int digitInt =
              int.parse(digit); // Assume valid digits after normalization
          return _wordsUnder20[digitInt];
        }).toList();
        // Combine separator and digit words
        fractionalWords = '$separatorWord ${digitWords.join(' ')}';
      }
    }

    // Combine integer and fractional parts
    if (fractionalWords.isNotEmpty) {
      // Avoid double spaces if integerWords is empty (which shouldn't happen here due to zero handling)
      return integerWords.isEmpty
          ? fractionalWords.trim()
          : '$integerWords $fractionalWords';
    } else {
      // Should only happen if the fractional part was effectively zero after removing trailing zeros
      return integerWords;
    }
  }

  /// Converts a non-negative integer (up to the largest defined scale) to Igbo words.
  ///
  /// Uses a recursive approach based on number scales (puku, nde, ijeri).
  /// Handles the combination of multipliers and scale words according to Igbo grammar.
  ///
  /// - [n] The non-negative BigInt to convert.
  /// Returns the integer in Igbo words.
  /// Throws [ArgumentError] if `n` is negative or exceeds defined scale limits.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero) {
      // This should not happen if called after taking absValue
      throw ArgumentError(
          "Input must be non-negative for internal conversion: $n");
    }
    if (n == BigInt.zero) return _zero;

    // Handle numbers under 1000 directly
    if (n < BigInt.from(1000)) {
      return _convertUnder1000(n.toInt());
    }

    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0;
    BigInt scaleValue = BigInt.one; // Start with base unit

    // Find the largest applicable scale
    while (scaleIndex + 1 < _scaleNames.length &&
        n >= oneThousand.pow(scaleIndex + 1)) {
      scaleIndex++;
      scaleValue = oneThousand.pow(scaleIndex);
    }

    if (scaleIndex == 0) {
      // Should be handled by the n < 1000 check, but safe fallback
      return _convertUnder1000(n.toInt());
    }
    if (scaleIndex >= _scaleNames.length) {
      throw ArgumentError("Number $n is too large for defined scales.");
    }

    final BigInt chunk = n ~/ scaleValue; // The multiplier for this scale
    final BigInt remainder = n % scaleValue; // The rest of the number

    // Convert the chunk (multiplier)
    String chunkText;
    // Special case for 1 at scales > 0 (puku, nde, ijeri) - implicit "one"
    if (chunk == BigInt.one && scaleIndex > 0) {
      chunkText =
          _scaleNames[scaleIndex]; // Just use the scale word (e.g., "puku")
    } else {
      // Convert the multiplier number itself
      String multiplierText = _convertInteger(chunk);
      // Combine multiplier and scale word based on Igbo grammar
      if (scaleIndex == 1) {
        // Thousands (puku)
        // Scale word first, then multiplier: "puku [multiplier]"
        chunkText = "${_scaleNames[scaleIndex]} $multiplierText";
      } else {
        // Millions (nde) and higher
        // Multiplier first, then scale word: "[multiplier] [scale]"
        chunkText = "$multiplierText ${_scaleNames[scaleIndex]}";
      }
    }

    // Convert the remainder if it exists
    if (remainder > BigInt.zero) {
      String remainderText = _convertInteger(remainder);
      // Join chunk and remainder with "na"
      return "$chunkText $_na $remainderText";
    } else {
      // No remainder, just return the chunk part
      return chunkText;
    }
  }

  /// Converts a non-negative integer less than 1000 to Igbo words.
  ///
  /// - [n] The integer between 0 and 999.
  /// Returns the number in Igbo words.
  /// Throws [ArgumentError] if `n` is outside the valid range [0, 999].
  String _convertUnder1000(int n) {
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Input must be between 0 and 999: $n");
    }
    // Zero should ideally be handled before calling, but return if passed
    if (n == 0) return _zero;

    List<String> words = [];
    int remainder = n;

    // Handle hundreds place
    if (remainder >= 100) {
      int hundredMultiplier = remainder ~/ 100;
      if (hundredMultiplier == 1) {
        // "narị" for 100
        words.add(_hundred);
      } else {
        // "narị [multiplier]" for 200, 300, etc.
        // Note: _wordsUnder20 handles 2 to 9
        words.add("$_hundred ${_wordsUnder20[hundredMultiplier]}");
      }
      remainder %= 100;
      // Add "na" if there's a remaining tens/units part
      if (remainder > 0) {
        words.add(_na);
      }
    }

    // Handle tens and units place
    if (remainder > 0) {
      if (remainder < 20) {
        // Numbers 1-19
        words.add(_wordsUnder20[remainder]);
      } else {
        // Numbers 20-99
        int tensDigit = remainder ~/ 10;
        int unitDigit = remainder % 10;
        words
            .add(_wordsTens[tensDigit]); // Add the tens word (e.g., "iri abụọ")
        if (unitDigit > 0) {
          // Add "na" and the unit word if unit is non-zero
          words.add(_na);
          words.add(_wordsUnder20[unitDigit]);
        }
      }
    }

    // Join the parts with spaces
    return words.join(' ');
  }
}
