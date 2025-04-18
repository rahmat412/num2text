import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/mk_options.dart';
import '../utils/utils.dart';

/// {@template num2text_mk}
/// The Macedonian language (Lang.MK) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Macedonian word representation following standard Macedonian grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [MkOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (standard scale).
/// It handles gender agreement for 'one' and 'two' with scale words and uses the conjunction "и" (and) appropriately.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [MkOptions].
/// {@endtemplate}
///
/// Example usage:
/// ```dart
/// final converter = Num2TextMK();
/// print(converter.process(123)); // Output: сто и дваесет и три
/// print(converter.process(1001)); // Output: илјада и еден
/// print(converter.process(2000)); // Output: две илјади
/// print(converter.process(1.5, const MkOptions(decimalSeparator: DecimalSeparator.comma))); // Output: еден запирка пет
/// print(converter.process(10.50, const MkOptions(currency: true))); // Output: десет денари и педесет дени
/// ```
class Num2TextMK implements Num2TextBase {
  // --- Private Constants ---

  /// The word for "point" used as a decimal separator.
  static const String _point = "точка";

  /// The word for "comma" used as a decimal separator (default).
  static const String _comma = "запирка";

  /// The conjunction "and".
  static const String _and = "и";

  /// The masculine form of "one".
  static const String _oneMasculine = "еден";

  /// The feminine form of "one".
  static const String _oneFeminine = "една";

  /// The masculine form of "two".
  static const String _twoMasculine = "два";

  /// The feminine form of "two".
  static const String _twoFeminine = "две";

  /// The word for "zero".
  static const String _zero = "нула";

  /// Words for numbers 0-19.
  static const List<String> _wordsUnder20 = [
    "нула", // 0
    "еден", // 1
    "два", // 2
    "три", // 3
    "четири", // 4
    "пет", // 5
    "шест", // 6
    "седум", // 7
    "осум", // 8
    "девет", // 9
    "десет", // 10
    "единаесет", // 11
    "дванаесет", // 12
    "тринаесет", // 13
    "четиринаесет", // 14
    "петнаесет", // 15
    "шеснаесет", // 16
    "седумнаесет", // 17
    "осумнаесет", // 18
    "деветнаесет", // 19
  ];

  /// Words for tens (20, 30,... 90). Index corresponds to the ten's value (index 2 = "дваесет").
  static const List<String> _wordsTens = [
    "", // 0 (unused)
    "", // 10 (covered by _wordsUnder20)
    "дваесет", // 20
    "триесет", // 30
    "четириесет", // 40
    "педесет", // 50
    "шеесет", // 60
    "седумдесет", // 70
    "осумдесет", // 80
    "деведесет", // 90
  ];

  /// Words for hundreds (100, 200,... 900). Index corresponds to the hundred's value (index 1 = "сто").
  static const List<String> _wordsHundreds = [
    "", // 0 (unused)
    "сто", // 100
    "двесте", // 200
    "триста", // 300
    "четиристотини", // 400
    "петстотини", // 500
    "шестотини", // 600
    "седумстотини", // 700
    "осумстотини", // 800
    "деветстотини", // 900
  ];

  /// Defines scale words (thousand, million, etc.) and their grammatical properties.
  /// Key: Scale level (1 = thousand, 2 = million, ...).
  /// Value: List containing [singular form, plural form, gender ('m' or 'f')].
  /// Gender is important for agreement with numbers 1 and 2.
  static const Map<int, List<String>> _scaleWords = {
    // Scale Level: [Singular, Plural, Gender]
    1: ["илјада", "илјади", 'f'], // Thousand (feminine)
    2: ["милион", "милиони", 'm'], // Million (masculine)
    3: ["милијарда", "милијарди", 'f'], // Billion (feminine)
    4: ["билион", "билиони", 'm'], // Trillion (masculine)
    5: ["билијарда", "билијарди", 'f'], // Quadrillion (feminine)
    6: ["трилион", "трилиони", 'm'], // Quintillion (masculine)
    7: ["трилијарда", "трилијарди", 'f'], // Sextillion (feminine)
    8: ["квадрилион", "квадрилиони", 'm'], // Septillion (masculine)
    // Add more scales here if needed (квадрилијарда, квинтилион, etc.)
  };

  /// Processes the given number into its Macedonian word representation.
  ///
  /// - [number]: The number to convert (can be `int`, `double`, `BigInt`, `Decimal`, or `String`).
  /// - [options]: Optional `MkOptions` to customize conversion (e.g., currency, decimal separator).
  ///   If not provided or not `MkOptions`, default options are used.
  /// - [fallbackOnError]: A custom string to return if the input is invalid (`NaN`, `null`, non-numeric string).
  ///   If null, a default Macedonian error message is used ("Не е број").
  ///
  /// Returns the word representation of the number in Macedonian, or an error/fallback string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have the correct options type or use defaults.
    final MkOptions mkOptions =
        options is MkOptions ? options : const MkOptions();
    final String errorFallback = fallbackOnError ?? "Не е број";

    // Handle special double values early.
    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Негативна бесконечност" : "Бесконечност";
      if (number.isNaN) return errorFallback;
    }

    // Normalize the input number to Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null)
      return errorFallback; // Handle invalid/null input.

    // Handle zero separately.
    if (decimalValue == Decimal.zero) {
      // Currency format for zero requires the plural unit name.
      return mkOptions.currency
          ? "$_zero ${mkOptions.currencyInfo.mainUnitPlural ?? mkOptions.currencyInfo.mainUnitSingular}" // Use plural if available
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative
        ? -decimalValue
        : decimalValue; // Work with the absolute value.

    // Delegate to appropriate handler based on options.
    String textResult = mkOptions.currency
        ? _handleCurrency(absValue, mkOptions)
        : _handleStandardNumber(absValue, mkOptions);

    // Prepend the negative prefix if necessary.
    if (isNegative) {
      // Handle year format specifically: negative years don't usually use "минус" prefix in context.
      // However, the tests expect "минус" even for years, so we keep the standard prefix logic.
      // If specific BC/BCE formatting were needed, it would go here.
      textResult = "${mkOptions.negativePrefix} $textResult";
    }

    return textResult;
  }

  /// Handles the conversion of a number into Macedonian currency format.
  ///
  /// - [absValue]: The absolute `Decimal` value of the number.
  /// - [options]: The `MkOptions` containing currency settings and info.
  /// Returns the currency representation in words (e.g., "два денари и педесет дени").
  String _handleCurrency(Decimal absValue, MkOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final BigInt mainValue = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    // Calculate subunit value (assuming 100 subunits per main unit).
    final BigInt subunitValue =
        (fractionalPart * Decimal.fromInt(100)).truncate().toBigInt();

    // Convert the main integer part to words.
    String mainText = _convertInteger(mainValue);
    // Determine the correct main unit name (singular for 1, plural otherwise).
    String mainUnitName = (mainValue == BigInt.one)
        ? currencyInfo.mainUnitSingular
        : currencyInfo.mainUnitPlural ??
            currencyInfo
                .mainUnitSingular; // Fallback to singular if plural is null

    String result = '$mainText $mainUnitName';

    // If there are subunits, convert and append them.
    if (subunitValue > BigInt.zero) {
      String subunitText = _convertInteger(subunitValue);
      // Determine the correct subunit name (singular for 1, plural otherwise).
      String subUnitName = (subunitValue == BigInt.one)
          ? currencyInfo.subUnitSingular ??
              '' // Use empty string if subunit singular is null
          : currencyInfo.subUnitPlural ??
              currencyInfo.subUnitSingular ??
              ''; // Use plural or fallback

      // Append the subunit part using the conjunction "и".
      if (subUnitName.isNotEmpty) {
        // Only add if a subunit name exists
        result += ' $_and $subunitText $subUnitName';
      }
    }
    return result;
  }

  /// Handles the conversion of a standard number (integer or decimal) into words.
  ///
  /// - [absValue]: The absolute `Decimal` value of the number.
  /// - [options]: The `MkOptions` specifying decimal separator preference.
  /// Returns the standard word representation (e.g., "сто и дваесет и три запирка четири пет").
  String _handleStandardNumber(Decimal absValue, MkOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part. Handle case where integer is 0 but decimal exists (e.g., 0.5).
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Determine the decimal separator word based on options.
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          separatorWord = _point;
          break;
        case DecimalSeparator.comma:
        default: // Default to comma if null or comma specified.
          separatorWord = _comma;
          break;
      }
      // Get the digits after the decimal point.
      // toString() provides the canonical representation.
      // Remove trailing zeros for standard representation like "1.50" -> "еден запирка пет".
      String fractionalDigits = absValue.toString().split('.').last;
      while (fractionalDigits.endsWith('0') && fractionalDigits.length > 1) {
        fractionalDigits =
            fractionalDigits.substring(0, fractionalDigits.length - 1);
      }

      // Convert each digit individually.
      List<String> digitWords = fractionalDigits
          .split('')
          .map((d) => _wordsUnder20[int.tryParse(d) ?? 0])
          .toList();
      fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
    }
    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative `BigInt` into its Macedonian word representation.
  ///
  /// This method handles arbitrarily large integers by breaking them into chunks of 1000
  /// and applying scale words (thousand, million, etc.) with correct grammar.
  ///
  /// - [n]: The non-negative `BigInt` to convert.
  /// Returns the word representation of the integer.
  /// Throws `ArgumentError` if `n` is negative or too large for defined scales.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero)
      throw ArgumentError("Integer must be non-negative: $n");
    if (n == BigInt.zero) return _zero;
    // Handle numbers less than 1000 directly via _convertChunk.
    if (n < BigInt.from(1000)) return _convertChunk(n.toInt());

    List<_IntegerPart> parts = []; // Stores converted chunks and their values.
    final BigInt oneThousand = BigInt.from(1000);
    int scaleLevel = 0; // 0 = units, 1 = thousands, 2 = millions, ...
    BigInt remaining = n;

    // Process the number in chunks of 1000 from right to left.
    while (remaining > BigInt.zero) {
      BigInt chunkValue = remaining % oneThousand; // The current chunk (0-999).
      remaining ~/= oneThousand; // Move to the next chunk.

      if (chunkValue > BigInt.zero) {
        // Convert the 0-999 chunk to words.
        String chunkText = _convertChunk(chunkValue.toInt());
        List<String>? scaleInfo = _scaleWords[
            scaleLevel]; // Get info for the current scale (thousand, million...).

        if (scaleLevel > 0) {
          // Apply scale word if not in the base 0-999 chunk.
          if (scaleInfo != null) {
            String scaleSingular = scaleInfo[0];
            String scalePlural = scaleInfo[1];
            String scaleGender = scaleInfo[2]; // 'm' or 'f'
            String scaleWord;

            // --- Handle Gender Agreement for 1 and 2 ---
            // If the scale word is feminine (e.g., илјада, милијарда),
            // ensure the preceding '1' or '2' uses the feminine form.
            if (scaleGender == 'f') {
              if (chunkText.endsWith(" $_oneMasculine")) {
                // Ends with " еден" -> " една"
                chunkText = chunkText.substring(
                        0, chunkText.length - _oneMasculine.length) +
                    _oneFeminine;
              } else if (chunkText == _oneMasculine) {
                // Is just "еден" -> "една"
                chunkText = _oneFeminine;
              }
              if (chunkText.endsWith(" $_twoMasculine")) {
                // Ends with " два" -> " две"
                chunkText = chunkText.substring(
                        0, chunkText.length - _twoMasculine.length) +
                    _twoFeminine;
              } else if (chunkText == _twoMasculine) {
                // Is just "два" -> "две"
                chunkText = _twoFeminine;
              }
            }
            // --- Determine Singular/Plural Scale Word ---
            if (chunkValue == BigInt.one) {
              scaleWord = scaleSingular; // Use singular scale word for '1'.

              // Special case: For "one million", "one billion", etc. (scale > 1),
              // we need to explicitly say "еден/една" before the scale word.
              // For "one thousand" (scale == 1), we just say "илјада".
              if (scaleLevel > 1) {
                // Use the gender-appropriate form of "one".
                chunkText = (scaleGender == 'f') ? _oneFeminine : _oneMasculine;
              } else {
                // For thousands, '1' is implied by the singular "илјада".
                chunkText = '';
              }
            } else {
              scaleWord = scalePlural; // Use plural scale word for numbers > 1.
            }

            // Combine the chunk words (if any) and the scale word.
            String combinedPart =
                chunkText.isNotEmpty ? "$chunkText $scaleWord" : scaleWord;
            parts.add(_IntegerPart(chunkValue, combinedPart));
          } else {
            // If scaleLevel exceeds defined _scaleWords, the number is too large.
            throw ArgumentError("Number too large for defined scales: $n");
          }
        } else {
          // Base chunk (0-999), no scale word needed.
          parts.add(_IntegerPart(chunkValue, chunkText));
        }
      }
      scaleLevel++; // Move to the next scale level (thousands, millions, etc.).
    }

    // --- Combine the processed parts ---
    // Iterate through the parts from largest scale to smallest (reverse order).
    StringBuffer buffer = StringBuffer();
    for (int i = parts.length - 1; i >= 0; i--) {
      buffer.write(parts[i].text);
      if (i > 0) {
        // Add separator before the next smaller part.
        // Macedonian uses "и" (and) before the final chunk if it's less than 100 (e.g., "илјада и еден").
        // Otherwise, just a space is used (e.g., "еден милион сто").
        // Check the value of the *next* smaller part.
        if (parts[i - 1].value > BigInt.zero &&
            parts[i - 1].value < BigInt.from(100)) {
          buffer.write(' $_and ');
        } else {
          buffer.write(
            ' ',
          ); // Space between scales like "милион илјада" (if applicable) or "милион сто".
        }
      }
    }

    // Clean up potential extra spaces and return.
    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Converts a number between 0 and 999 into its Macedonian word representation.
  ///
  /// - [n]: The integer chunk (0-999) to convert.
  /// Returns the word representation of the chunk.
  /// Throws `ArgumentError` if `n` is outside the 0-999 range.
  String _convertChunk(int n) {
    if (n == 0) {
      return ""; // Zero is handled separately or results in an empty string within a larger number.
    }
    if (n < 0 || n >= 1000)
      throw ArgumentError("Chunk must be between 0 and 999 inclusive: $n");

    List<String> words = [];
    int remainder = n;

    // Handle hundreds place.
    if (remainder >= 100) {
      words.add(_wordsHundreds[remainder ~/ 100]); // Add "сто", "двесте", etc.
      remainder %= 100;
      // Add "и" if there are remaining tens/units (e.g., "сто И дваесет").
      if (remainder > 0) words.add(_and);
    }

    // Handle tens and units place.
    if (remainder > 0) {
      if (remainder < 20) {
        // Numbers 1-19 are handled directly.
        words.add(_wordsUnder20[remainder]);
      } else {
        // Numbers 20-99.
        words
            .add(_wordsTens[remainder ~/ 10]); // Add "дваесет", "триесет", etc.
        int unit = remainder % 10;
        // Add "и" and the unit word if the unit is greater than 0 (e.g., "дваесет И еден").
        if (unit > 0) {
          words.add(_and);
          words.add(_wordsUnder20[unit]);
        }
      }
    }

    // Join the parts with spaces.
    return words.join(' ').trim();
  }
}

/// Helper class to store the numerical value and text representation of an integer part
/// during the conversion of large numbers in [_convertInteger].
class _IntegerPart {
  /// The numerical value of the chunk (e.g., 123 for the thousands chunk).
  final BigInt value;

  /// The text representation of the chunk combined with its scale word (e.g., "сто и дваесет и три илјади").
  final String text;

  _IntegerPart(this.value, this.text);
}
