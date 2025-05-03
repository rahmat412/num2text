import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/pl_options.dart';
import '../utils/utils.dart';

/// {@template num2text_pl}
/// Converts numbers to Polish words (`Lang.PL`).
///
/// Implements [Num2TextBase] for Polish (Polski). Handles various numeric inputs
/// via [process].
///
/// Features:
/// - Cardinal numbers following complex Polish grammar and pluralization.
/// - Currency formatting using [PlOptions.currencyInfo] (defaults to PLN - złoty/złote/złotych).
/// - Year formatting (optional n.e./p.n.e. suffixes).
/// - Negative numbers (default prefix "minus").
/// - Decimals (using przecinek or kropka).
/// - Large numbers using the short scale (tysiąc, milion, miliard...) with correct case endings.
///
/// Returns a fallback string on error. Customizable via [PlOptions].
/// {@endtemplate}
class Num2TextPL implements Num2TextBase {
  // --- Constants ---

  /// Decimal separator comma ("przecinek"). Default for Polish.
  static const String _comma = "przecinek";

  /// Decimal separator point/period ("kropka"). Alternative.
  static const String _point = "kropka";

  /// Conjunction "and" ("i"). Used between currency main and subunits.
  static const String _and =
      "i"; // Note: Not typically used within numbers like in English.
  /// Zero ("zero").
  static const String _zero = "zero";

  /// Suffix for BC/BCE years ("przed naszą erą" - Before Common Era).
  static const String _yearSuffixBC = "p.n.e.";

  /// Suffix for AD/CE years ("naszej ery" - Common Era).
  static const String _yearSuffixAD = "n.e.";

  /// Positive infinity ("Nieskończoność").
  static const String _infinity = "Nieskończoność";

  /// Negative infinity ("Minus Nieskończoność").
  static const String _negativeInfinity = "Minus Nieskończoność";

  /// Not a Number ("Nie Liczba").
  static const String _notANumber = "Nie Liczba";

  /// Words for numbers 0-19. Note: "jeden" is masculine nominative. Gender variants exist but are complex to handle universally here.
  static const List<String> _wordsUnder20 = [
    "zero",
    "jeden",
    "dwa",
    "trzy",
    "cztery",
    "pięć",
    "sześć",
    "siedem",
    "osiem",
    "dziewięć",
    "dziesięć",
    "jedenaście",
    "dwanaście",
    "trzynaście",
    "czternaście",
    "piętnaście",
    "szesnaście",
    "siedemnaście",
    "osiemnaście",
    "dziewiętnaście",
  ];

  /// Words for tens (20, 30,... 90). Index corresponds to tens digit (index 2 = 20).
  static const List<String> _wordsTens = [
    "",
    "",
    "dwadzieścia",
    "trzydzieści",
    "czterdzieści",
    "pięćdziesiąt",
    "sześćdziesiąt",
    "siedemdziesiąt",
    "osiemdziesiąt",
    "dziewięćdziesiąt",
  ];

  /// Words for hundreds (100, 200,... 900). Index corresponds to hundreds digit.
  static const List<String> _wordsHundreds = [
    "",
    "sto",
    "dwieście",
    "trzysta",
    "czterysta",
    "pięćset",
    "sześćset",
    "siedemset",
    "osiemset",
    "dziewięćset",
  ];

  /// Scale words (short scale: thousand, million...). Key is power of 1000.
  /// Value is list of forms: [singular nominative (for 1), plural nominative (for 2-4 end), plural genitive (for 0, 1, 5-9 end, teens)].
  static final Map<int, List<String>> _scaleWords = {
    1: ["tysiąc", "tysiące", "tysięcy"], // 10^3
    2: ["milion", "miliony", "milionów"], // 10^6
    3: ["miliard", "miliardy", "miliardów"], // 10^9
    4: ["bilion", "biliony", "bilionów"], // 10^12
    5: ["biliard", "biliardy", "biliardów"], // 10^15
    6: ["trylion", "tryliony", "trylionów"], // 10^18
    7: ["tryliard", "tryliardy", "tryliardów"], // 10^21
    8: ["kwadrylion", "kwadryliony", "kwadrylionów"], // 10^24
    // Add higher scales (kwintylion, etc.) if needed.
  };

  /// Processes the given number into its Polish word representation.
  ///
  /// {@template num2text_process_intro}
  /// Handles `int`, `double`, `BigInt`, `Decimal`, `String`. Normalizes to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [PlOptions] for customization (currency, year format, decimals, AD/BC).
  /// Defaults apply if [options] is null or not [PlOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity` (Nieskończoność), `NaN`. Returns [fallbackOnError] or "Nie Liczba" on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [PlOptions] settings.
  /// @param fallbackOnError Optional error string. Default: "Nie Liczba".
  /// @return The number as Polish words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final PlOptions plOptions =
        options is PlOptions ? options : const PlOptions();
    final String errorFallback = fallbackOnError ?? _notANumber;

    // Handle special double values.
    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _negativeInfinity : _infinity;
      if (number.isNaN) return errorFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    // Handle zero based on context.
    if (decimalValue == Decimal.zero) {
      if (plOptions.currency) {
        // Zero currency requires genitive plural form (e.g., "zero złotych").
        final String mainUnit = plOptions.currencyInfo.mainUnitPluralGenitive ??
            plOptions.currencyInfo
                .mainUnitSingular; // Fallback to singular if genitive is null.
        return "$_zero $mainUnit";
      } else {
        return _zero; // Standard "zero".
      }
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    // Dispatch based on format options.
    if (plOptions.format == Format.year) {
      // Years are treated as integers. Sign handled by suffix addition.
      textResult = _convertInteger(absValue.truncate().toBigInt());
      if (isNegative) {
        textResult += " $_yearSuffixBC"; // Add "p.n.e."
      } else if (plOptions.includeAD) {
        textResult += " $_yearSuffixAD"; // Add "n.e." if requested.
      }
    } else if (plOptions.currency) {
      textResult = _handleCurrency(absValue, plOptions);
      // Prepend negative prefix if original was negative.
      if (isNegative) {
        String prefix =
            plOptions.negativePrefix.trim(); // Ensure no extra spaces.
        textResult = "$prefix $textResult";
      }
    } else {
      // Standard number conversion (integer or decimal).
      textResult = _handleStandardNumber(absValue, plOptions);
      // Prepend negative prefix if original was negative.
      if (isNegative) {
        String prefix = plOptions.negativePrefix.trim();
        textResult = "$prefix $textResult";
      }
    }

    // Return final result, removing any leading/trailing whitespace.
    return textResult.trim();
  }

  /// Formats a non-negative [Decimal] value as Polish currency.
  ///
  /// Handles main units (e.g., złoty) and subunits (e.g., grosz) with correct
  /// Polish pluralization based on [PlOptions.currencyInfo]. Rounds to 2 decimal places.
  ///
  /// @param absValue The absolute decimal value of the currency.
  /// @param options The [PlOptions] with currency info.
  /// @return The currency value formatted as Polish words.
  String _handleCurrency(Decimal absValue, PlOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;

    // Round to 2 decimal places for typical currency.
    final Decimal valueToConvert = absValue.round(scale: 2);

    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart =
        valueToConvert - Decimal.fromBigInt(mainValue);
    // Calculate subunit value (e.g., groszy).
    final BigInt subunitValue =
        (fractionalPart * Decimal.fromInt(100)).truncate().toBigInt();

    String mainPart = '';
    if (mainValue > BigInt.zero) {
      String mainText = _convertInteger(mainValue);
      // Get correct plural form for main unit.
      String mainUnitName = _getCurrencyForm(
        mainValue,
        currencyInfo.mainUnitSingular,
        currencyInfo.mainUnitPlural2To4 ??
            currencyInfo.mainUnitSingular, // Fallback needed
        currencyInfo.mainUnitPluralGenitive ??
            currencyInfo.mainUnitSingular, // Fallback needed
      );
      mainPart = '$mainText $mainUnitName';
    }

    String subunitPart = '';
    // Check if subunit info is fully provided before processing.
    final subSingular = currencyInfo.subUnitSingular;
    final subPlural2To4 = currencyInfo.subUnitPlural2To4;
    final subPluralGenitive = currencyInfo.subUnitPluralGenitive;

    if (subunitValue > BigInt.zero &&
        subSingular != null &&
        subPlural2To4 != null &&
        subPluralGenitive != null) {
      String subunitText = _convertInteger(subunitValue);
      // Get correct plural form for subunit.
      String subUnitName = _getCurrencyForm(
          subunitValue, subSingular, subPlural2To4, subPluralGenitive);
      subunitPart = '$subunitText $subUnitName';
    }

    // Combine main and subunit parts.
    if (mainPart.isNotEmpty && subunitPart.isNotEmpty) {
      // Use "i" ("and") as the separator.
      return '$mainPart $_and $subunitPart';
    } else if (mainPart.isNotEmpty) {
      return mainPart;
    } else if (subunitPart.isNotEmpty) {
      // Handle cases like 0.50 -> "pięćdziesiąt groszy".
      return subunitPart;
    } else {
      // Value was zero after rounding. Return "zero [main unit genitive plural]".
      String mainUnitName = _getCurrencyForm(
        mainValue, // Which is zero here
        currencyInfo.mainUnitSingular,
        currencyInfo.mainUnitPlural2To4 ?? currencyInfo.mainUnitSingular,
        currencyInfo.mainUnitPluralGenitive ?? currencyInfo.mainUnitSingular,
      );
      return '$_zero $mainUnitName'; // e.g., "zero złotych"
    }
  }

  /// Converts a standard (non-currency, non-year) decimal number to Polish words.
  ///
  /// Handles integer and fractional parts. Reads fractional part digit by digit.
  ///
  /// @param absValue The absolute decimal value.
  /// @param options Formatting options (decimal separator).
  /// @return Number as Polish words.
  String _handleStandardNumber(Decimal absValue, PlOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - Decimal.fromBigInt(integerPart);

    // Convert integer part. If integer is 0 but fraction exists, output "zero".
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Determine separator word (default comma).
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          separatorWord = _point;
          break;
        default:
          separatorWord = _comma;
          break;
      }

      // Extract fractional digits.
      String fractionalDigitsStr = absValue.toString().split('.').last;
      // Remove trailing zeros as they are typically not read out.
      final String cleanedDigits =
          fractionalDigitsStr.replaceAll(RegExp(r'0+$'), '');

      // Convert each digit individually if any remain after cleaning.
      if (cleanedDigits.isNotEmpty) {
        List<String> digitWords = cleanedDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          // Use base words 0-9.
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder20[digitInt]
              : '?';
        }).toList();
        // Combine separator and digits.
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
      // If cleanedDigits is empty (e.g., input was 1.500), fractionalWords remains empty.
    }

    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer ([BigInt]) into Polish words.
  ///
  /// Handles numbers from zero up to defined scale limits, processing in chunks of 1000.
  /// Applies scale words (tysiąc, milion, etc.) with correct Polish pluralization.
  ///
  /// @param n The non-negative integer to convert.
  /// @throws ArgumentError if [n] is negative or exceeds defined scales.
  /// @return The integer as Polish words. Returns "zero" if n is 0.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero)
      throw ArgumentError("Integer must be non-negative: $n");
    if (n == BigInt.zero) return _zero; // Handle standalone zero.

    // Handle numbers under 1000 directly.
    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt());
    }

    // --- Process numbers >= 1000 ---
    List<String> parts =
        []; // Stores word parts for each scale level (e.g., "pięć milionów").
    final BigInt oneThousand = BigInt.from(1000);
    int scaleLevel = 0; // 0: units/hundreds, 1: thousands, 2: millions, ...
    BigInt remaining = n;

    // Process the number in chunks of 1000 from right to left.
    while (remaining > BigInt.zero) {
      BigInt chunk = remaining % oneThousand; // Current chunk (0-999).
      remaining ~/= oneThousand; // Move to next higher chunk.

      if (chunk > BigInt.zero) {
        // Convert the non-zero chunk (0-999) to words.
        String chunkWords = _convertChunk(chunk.toInt());
        String scaleWordPart = ""; // Initialize text for this scale level.

        if (scaleLevel > 0) {
          // --- Handle Thousands, Millions, etc. ---
          List<String>? scaleForms = _scaleWords[scaleLevel];
          if (scaleForms == null)
            throw ArgumentError("Number exceeds defined scales: $n");

          // Determine the correct plural form of the scale word (tysiąc/tysiące/tysięcy).
          String scaleWord =
              _getScaleForm(chunk, scaleForms[0], scaleForms[1], scaleForms[2]);

          // Special case: "jeden tysiąc", "jeden milion" (singular scale word).
          // For other numbers, use the converted chunk words + plural scale word.
          if (chunk == BigInt.one) {
            // Grammatically, we need "jeden" + singular scale word, not just the scale word.
            // _convertChunk(1) returns "jeden". So, combine "jeden" and the singular scale form.
            scaleWordPart =
                "jeden ${scaleForms[0]}"; // Corrected: Use form1 (singular)
          } else {
            // e.g., "dwa tysiące", "pięć milionów".
            scaleWordPart = "$chunkWords $scaleWord";
          }
          parts.add(scaleWordPart); // Add the combined chunk+scale part.
        } else {
          // --- Handle Lowest Chunk (0-999) ---
          // No scale word needed, just add the chunk words.
          parts.add(chunkWords);
        }
      }
      scaleLevel++; // Increment scale level for the next chunk.
    }

    // Join the parts in reverse order (highest scale first) with spaces.
    // Filter out any potentially empty parts (shouldn't happen with current logic).
    return parts.reversed.where((part) => part.isNotEmpty).join(' ').trim();
  }

  /// Converts a three-digit integer chunk (0-999) into Polish words.
  ///
  /// @param n The integer chunk (0-999).
  /// @throws ArgumentError if [n] is outside the 0-999 range.
  /// @return The Polish word representation of the chunk, or empty string if n is 0.
  String _convertChunk(int n) {
    if (n == 0) return ""; // Zero contributes nothing within a larger number.
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }

    List<String> words = []; // Stores word parts for this chunk.
    int remainder = n;

    // --- Hundreds place ---
    if (remainder >= 100) {
      words.add(_wordsHundreds[remainder ~/ 100]); // e.g., "sto", "dwieście"
      remainder %= 100;
    }

    // --- Tens and Units place ---
    if (remainder > 0) {
      if (remainder < 20) {
        // Numbers 1-19 have unique words.
        words.add(_wordsUnder20[remainder]);
      } else {
        // Numbers 20-99.
        words.add(_wordsTens[
            remainder ~/ 10]); // Add tens word (e.g., "dwadzieścia").
        int unit = remainder % 10;
        if (unit > 0) {
          // Add unit word if non-zero (e.g., "trzy" for 23).
          words.add(_wordsUnder20[unit]);
        }
      }
    }
    // Join parts with spaces (e.g., "sto dwadzieścia trzy").
    return words.join(' ');
  }

  /// Determines the correct Polish plural form for scale words or currency units.
  ///
  /// Applies Polish grammatical rules based on the number's ending:
  /// - 1: Singular Nominative (form1)
  /// - Ends in 2, 3, 4 (but not 12, 13, 14): Plural Nominative (form2_4)
  /// - Ends in 0, 1, 5-9, or 11-19: Plural Genitive (form5plus)
  ///
  /// @param count The number determining the form.
  /// @param form1 Singular nominative form (e.g., "tysiąc", "złoty").
  /// @param form2_4 Plural nominative form (e.g., "tysiące", "złote").
  /// @param form5plus Plural genitive form (e.g., "tysięcy", "złotych").
  /// @return The appropriate grammatical form string.
  String _getScaleForm(
      BigInt count, String form1, String form2_4, String form5plus) {
    // Handle 1 -> singular nominative.
    if (count == BigInt.one) {
      return form1;
    }

    // Check last two digits for teens exception (11-19) -> plural genitive.
    int lastTwoDigits = (count % BigInt.from(100)).toInt();
    if (lastTwoDigits >= 11 && lastTwoDigits <= 19) {
      return form5plus;
    }

    // Check last digit for other cases.
    int lastDigit = (count % BigInt.from(10)).toInt();
    if (lastDigit >= 2 && lastDigit <= 4) {
      // Ends in 2, 3, 4 -> plural nominative.
      return form2_4;
    }

    // All other endings (0, 1, 5, 6, 7, 8, 9) -> plural genitive.
    return form5plus;
  }

  /// Selects the correct Polish currency unit form based on the count.
  /// Wrapper around [_getScaleForm] as the grammatical rules are identical.
  ///
  /// @param count The number of currency units.
  /// @param form1 Singular form (e.g., "złoty").
  /// @param form2_4 Plural nominative form (e.g., "złote").
  /// @param form5plus Plural genitive form (e.g., "złotych").
  /// @return The appropriate currency unit form.
  String _getCurrencyForm(
      BigInt count, String form1, String form2_4, String form5plus) {
    // Delegate to the general pluralization logic.
    return _getScaleForm(count, form1, form2_4, form5plus);
  }
}
