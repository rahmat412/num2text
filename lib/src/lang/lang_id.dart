import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/id_options.dart';
import '../utils/utils.dart';

/// {@template num2text_id}
/// The Indonesian language (Lang.ID) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Indonesian (Bahasa Indonesia) word representation following standard grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [IdOptions.currencyInfo] - defaults to IDR),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (up to septillions - short scale).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [IdOptions].
/// {@endtemplate}
class Num2TextID implements Num2TextBase {
  /// The word for zero ("nol").
  static const String _zero = "nol";

  /// The word for the decimal separator when using `DecimalSeparator.period` or `DecimalSeparator.point` ("titik").
  static const String _point = "titik";

  /// The word for the decimal separator when using `DecimalSeparator.comma` (default) ("koma").
  static const String _comma = "koma";

  /// The default conjunction used between main and sub-units in currency format ("dan" - and).
  /// Can be overridden by [CurrencyInfo.separator].
  static const String _currencyAnd = "dan";

  /// The word for ten ("sepuluh").
  static const String _ten = "sepuluh";

  /// The word for eleven ("sebelas").
  static const String _eleven = "sebelas";

  /// The special word for one hundred ("seratus").
  static const String _hundred = "seratus";

  /// The special word for one thousand ("seribu").
  static const String _thousand = "seribu";

  /// Suffix for negative years (Before Christ - Sebelum Masehi).
  static const String _yearSuffixBC = "SM";

  /// Suffix for positive years when [IdOptions.includeAD] is true (Anno Domini - Masehi).
  static const String _yearSuffixAD = "M";

  /// Words for digits 0-9.
  static const List<String> _wordsUnits = [
    "nol", // 0
    "satu", // 1
    "dua", // 2
    "tiga", // 3
    "empat", // 4
    "lima", // 5
    "enam", // 6
    "tujuh", // 7
    "delapan", // 8
    "sembilan", // 9
  ];

  /// Words for tens (20, 30,... 90). Index 0 and 1 are unused.
  static const List<String> _wordsTens = [
    "", // 0 - unused
    "", // 10 - handled specially ("sepuluh", "sebelas", "belas")
    "dua puluh", // 20
    "tiga puluh", // 30
    "empat puluh", // 40
    "lima puluh", // 50
    "enam puluh", // 60
    "tujuh puluh", // 70
    "delapan puluh", // 80
    "sembilan puluh", // 90
  ];

  /// Scale words for thousands, millions, etc. (ribu, juta, miliar, ...).
  static const List<String> _scaleWordsBase = [
    "", // 10^0 - Base case (units)
    "ribu", // 10^3 - Thousand
    "juta", // 10^6 - Million
    "miliar", // 10^9 - Billion (short scale)
    "triliun", // 10^12 - Trillion (short scale)
    "kuadriliun", // 10^15 - Quadrillion (short scale)
    "kuintiliun", // 10^18 - Quintillion (short scale)
    "sekstiliun", // 10^21 - Sextillion (short scale)
    "septiliun", // 10^24 - Septillion (short scale)
    // Add more if needed, following the short scale pattern
  ];

  /// Converts the given [number] into its Indonesian word representation.
  ///
  /// Delegates the conversion process to helper methods based on the provided [options].
  /// Handles various numeric types, special double values (NaN, infinity), and formatting options
  /// like currency, year, and decimal separators.
  ///
  /// - [number]: The number to convert (can be `int`, `double`, `String`, `BigInt`, `Decimal`).
  /// - [options]: Optional [IdOptions] to customize formatting. If null or not [IdOptions], default options are used.
  /// - [fallbackOnError]: An optional custom string to return if the input is invalid or conversion fails.
  ///                    If `null`, default Indonesian error messages are used.
  ///
  /// Returns the word representation of the number in Indonesian, or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure options are of the correct type or use defaults.
    final IdOptions idOptions =
        options is IdOptions ? options : const IdOptions();

    // Handle special double values first.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? "Negatif Tak terhingga" : "Tak terhingga";
      }
      if (number.isNaN) {
        // Use fallback if provided for NaN, otherwise default Indonesian "Not a Number".
        return fallbackOnError ?? "Bukan Angka";
      }
    }

    // Normalize the input number to Decimal for precision and consistency.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // If normalization fails (e.g., invalid string), return error string.
    if (decimalValue == null) {
      return fallbackOnError ?? "Bukan Angka";
    }

    // Handle the specific case of zero.
    if (decimalValue == Decimal.zero) {
      // Return zero with currency unit if requested.
      if (idOptions.currency) {
        // Indonesian uses singular form for zero currency.
        return "$_zero ${idOptions.currencyInfo.mainUnitSingular}";
      } else {
        return _zero;
      }
    }

    // Determine sign and get absolute value.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Delegate based on the format specified in options.
    if (idOptions.format == Format.year) {
      // Handle year formatting (requires integer part).
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), idOptions);
    } else {
      // Handle standard numbers or currency.
      if (idOptions.currency) {
        textResult = _handleCurrency(absValue, idOptions);
      } else {
        textResult = _handleStandardNumber(absValue, idOptions);
      }

      // Add negative prefix if the original number was negative and not a year.
      if (isNegative) {
        textResult = "${idOptions.negativePrefix} $textResult";
      }
    }

    return textResult;
  }

  /// Formats an integer as a year in Indonesian words.
  ///
  /// Handles negative years (BC/SM) and optionally adds AD/M suffix for positive years.
  ///
  /// - [year]: The integer year value.
  /// - [options]: The [IdOptions] controlling the format, particularly `includeAD`.
  ///
  /// Returns the year in words, potentially with "SM" or "M".
  String _handleYearFormat(int year, IdOptions options) {
    final bool isNegative = year < 0;
    // Convert the absolute year value to BigInt for consistency with _convertInteger.
    final BigInt absYearBigInt = BigInt.from(isNegative ? -year : year);

    // Convert the absolute year number to words.
    String yearText = _convertInteger(absYearBigInt);

    // Append era suffixes based on sign and options.
    if (isNegative) {
      yearText += " $_yearSuffixBC"; // Append "SM" for BC years.
    } else if (options.includeAD && year > 0) {
      // Only append "M" for positive AD/CE years if includeAD is true.
      yearText += " $_yearSuffixAD";
    }

    return yearText;
  }

  /// Formats a positive [Decimal] number as Indonesian currency.
  ///
  /// Separates main units (e.g., Rupiah) and sub-units (e.g., Sen).
  /// Uses currency names defined in `options.currencyInfo`.
  /// Optionally rounds the number to 2 decimal places based on `options.round`.
  ///
  /// - [absValue]: The absolute (non-negative) decimal value of the currency.
  /// - [options]: The [IdOptions] containing currency settings.
  ///
  /// Returns the currency value in words (e.g., "seratus rupiah dan lima puluh sen").
  String _handleCurrency(Decimal absValue, IdOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    const int decimalPlaces = 2; // Standard currency decimal places.
    final Decimal subunitMultiplier =
        Decimal.fromInt(100); // 1 main unit = 100 subunits.

    // Round the value if requested, otherwise use the original value.
    final Decimal valueToConvert =
        options.round ? absValue.round(scale: decimalPlaces) : absValue;

    // Extract integer (main unit) and fractional (sub-unit) parts.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).truncate().toBigInt();

    // Convert the main unit value to words.
    final String mainText = _convertInteger(mainValue);

    // Get the appropriate main unit name (singular form for Indonesian Rupiah).
    final String mainUnitName = currencyInfo.mainUnitSingular;

    // Start building the result string.
    String result = '$mainText $mainUnitName';

    // If there are sub-units, add them.
    if (subunitValue > BigInt.zero) {
      // Convert sub-unit value to words.
      final String subunitText = _convertInteger(subunitValue);
      // Get the appropriate sub-unit name (assuming singular, check CurrencyInfo if varies).
      final String subUnitName = currencyInfo.subUnitSingular ??
          ''; // Use empty if subunit singular is null

      // Get the separator word (e.g., "dan").
      final String separator = currencyInfo.separator ?? _currencyAnd;

      // Append the separator and sub-unit part.
      result += ' $separator $subunitText $subUnitName';
    }

    return result;
  }

  /// Formats a standard positive [Decimal] number (non-currency, non-year) into Indonesian words.
  ///
  /// Handles both the integer and fractional parts, connecting them with the appropriate
  /// decimal separator word ("koma" or "titik") based on `options.decimalSeparator`.
  ///
  /// - [absValue]: The absolute (non-negative) decimal value.
  /// - [options]: The [IdOptions] controlling decimal formatting.
  ///
  /// Returns the number in words (e.g., "seratus dua puluh tiga koma empat lima enam").
  String _handleStandardNumber(Decimal absValue, IdOptions options) {
    // Extract integer and fractional parts.
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part to words.
    // If the integer part is zero but there's a fractional part, explicitly include "nol".
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';

    // Process the fractional part if it exists.
    if (fractionalPart > Decimal.zero) {
      // Determine the decimal separator word based on options.
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          separatorWord = _point; // "titik"
          break;
        case DecimalSeparator.comma:
        default: // Default to comma if null or comma.
          separatorWord = _comma; // "koma"
          break;
      }

      // Get the digits after the decimal point as a string.
      // Using absValue.toString() on Decimal preserves precision.
      // Remove trailing zeros.
      String fractionalDigits = absValue.toString().split('.').last;
      fractionalDigits =
          fractionalDigits.replaceAll(RegExp(r'0+$'), ''); // "1.50" -> "5"

      // Convert each digit character to its word representation if any digits remain.
      if (fractionalDigits.isNotEmpty) {
        final List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          // Check if parsing was successful and within 0-9 range.
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnits[digitInt] // Get word from the units list.
              : '?'; // Placeholder for invalid characters (shouldn't happen with Decimal).
        }).toList();

        // Join the digit words with spaces.
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }

    // Combine integer and fractional parts, trimming any leading/trailing space.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] number into Indonesian words.
  ///
  /// Handles large numbers by breaking them into chunks of thousands and applying scale words
  /// (ribu, juta, miliar, etc.). Delegates numbers under 1000 to [_convertUnderThousand].
  /// Includes the special case for "seribu" (one thousand).
  ///
  /// - [n]: The non-negative integer to convert.
  ///
  /// Returns the integer part in words.
  /// Throws [ArgumentError] if [n] is negative or exceeds the defined scale limits.
  String _convertInteger(BigInt n) {
    // Base case: zero.
    if (n == BigInt.zero) return _zero;
    // Ensure input is non-negative (should be handled by caller using absValue, but good practice).
    if (n < BigInt.zero) {
      throw ArgumentError(
          "Integer must be non-negative for internal conversion: $n");
    }

    // Delegate small numbers directly.
    if (n < BigInt.from(1000)) {
      return _convertUnderThousand(n.toInt());
    }

    final List<String> parts = []; // Stores word parts for each scale.
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0; // Index into `_scaleWordsBase`.
    BigInt remaining = n; // The portion of the number left to process.

    // Process the number in chunks of 1000.
    while (remaining > BigInt.zero) {
      // Check if the number exceeds the largest defined scale.
      if (scaleIndex >= _scaleWordsBase.length) {
        throw ArgumentError("Number too large (exceeds defined scales): $n");
      }

      // Get the current chunk (0-999).
      final BigInt chunk = remaining % oneThousand;
      // Update the remaining part for the next iteration.
      remaining ~/= oneThousand;

      // Only process non-zero chunks.
      if (chunk > BigInt.zero) {
        // Convert the chunk (0-999) to words.
        String chunkText = _convertUnderThousand(chunk.toInt());
        String scaleWord = ""; // The scale word (ribu, juta, etc.).

        // Determine the scale word if applicable (not the base scale 0).
        if (scaleIndex > 0) {
          // Special case: "seribu" for 1000.
          if (scaleIndex == 1 && chunk == BigInt.one) {
            scaleWord = _thousand; // "seribu"
            chunkText = ""; // Don't say "satu seribu".
          } else {
            scaleWord = _scaleWordsBase[scaleIndex]; // Get "ribu", "juta", etc.
          }
        }

        // Add the processed chunk and scale word to the parts list.
        if (scaleWord.isNotEmpty) {
          // Combine chunk text and scale word (e.g., "dua ratus ribu", or just "juta").
          // Insert at the beginning to maintain correct order (highest scale first).
          parts.insert(
              0, chunkText.isEmpty ? scaleWord : "$chunkText $scaleWord");
        } else {
          // Base scale (0-999), just add the chunk text.
          parts.insert(0, chunkText);
        }
      }
      scaleIndex++; // Move to the next scale level.
    }

    // Join the parts with spaces.
    return parts.join(' ');
  }

  /// Converts an integer between 0 and 999 into Indonesian words.
  ///
  /// Handles units, teens ("belas"), tens ("puluh"), and hundreds ("ratus").
  /// Includes special cases for "sepuluh" (10), "sebelas" (11), and "seratus" (100).
  ///
  /// - [n]: The integer between 0 and 999.
  ///
  /// Returns the number in words (e.g., "dua ratus tiga puluh empat"). Returns an empty string for 0.
  /// Throws [ArgumentError] if `n` is outside the valid range [0, 999].
  String _convertUnderThousand(int n) {
    // Handle base case: 0 (returns empty string as it's usually part of a larger number or handled by caller).
    if (n == 0) return "";
    // Validate input range.
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Number must be between 0 and 999: $n");
    }

    // Direct lookup for units (1-9).
    if (n < 10) return _wordsUnits[n];
    // Special cases: 10 and 11.
    if (n == 10) return _ten; // "sepuluh"
    if (n == 11) return _eleven; // "sebelas"
    // Handle teens (12-19).
    if (n < 20) return "${_wordsUnits[n % 10]} belas"; // e.g., "dua belas"

    // Use a list to build the words for numbers >= 20.
    final List<String> words = [];
    int remainder = n;

    // Handle hundreds part.
    if (remainder >= 100) {
      final int hundredsDigit = remainder ~/ 100;
      // Special case: "seratus" for 100.
      if (hundredsDigit == 1) {
        words.add(_hundred); // "seratus"
      } else {
        // Standard hundreds (e.g., "dua ratus").
        words.add("${_wordsUnits[hundredsDigit]} ratus");
      }
      remainder %= 100; // Get the remaining part (0-99).
    }

    // Handle the remaining tens and units part (0-99).
    if (remainder > 0) {
      // Add a space if there was a hundreds part.
      if (words.isNotEmpty) words.add(" ");

      // Process the remainder (1-99).
      if (remainder < 10) {
        words.add(_wordsUnits[remainder]); // Units (1-9)
      } else if (remainder == 10) {
        words.add(_ten); // "sepuluh"
      } else if (remainder == 11) {
        words.add(_eleven); // "sebelas"
      } else if (remainder < 20) {
        words.add("${_wordsUnits[remainder % 10]} belas"); // Teens (12-19)
      } else {
        // Tens (20-99).
        words.add(_wordsTens[remainder ~/ 10]); // e.g., "dua puluh"
        final int unit = remainder % 10;
        // Add unit word if present (e.g., "satu" in "dua puluh satu").
        if (unit > 0) {
          words.add(" ");
          words.add(_wordsUnits[unit]);
        }
      }
    }

    // Join the collected word parts.
    return words.join('');
  }
}
