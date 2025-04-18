import 'package:decimal/decimal.dart';

import '../num2text_base.dart'; // Base class contract.
import '../options/base_options.dart'; // Base options and enums like Gender, Format.
import '../options/is_options.dart'; // Icelandic-specific options.
import '../utils/utils.dart'; // Utilities like number normalization.

/// {@template num2text_is}
/// The Icelandic language (`Lang.IS`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Icelandic word representation following standard Icelandic grammar and vocabulary,
/// including handling of grammatical gender for numbers 1-4.
///
/// Capabilities include handling cardinal numbers, currency (using [IsOptions.currencyInfo] - note: subunits are deprecated),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers using a system similar to the long scale.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [IsOptions].
/// {@endtemplate}
class Num2TextIS implements Num2TextBase {
  // --- Constants ---

  /// The conjunction "og" (and).
  static const String _og = "og";

  /// The word for zero ("núll").
  static const String _zero = "núll";

  /// The word for hundred ("hundrað"). Neuter noun.
  static const String _hundred = "hundrað";

  /// The word for thousand ("þúsund"). Neuter noun.
  static const String _thousand = "þúsund";

  /// The word for the decimal separator when using a period (`.`).
  static const String _pointWord = "punktur";

  /// The word for the decimal separator when using a comma (`,`).
  static const String _commaWord = "komma";

  /// The suffix for negative years ("fyrir Krist" - Before Christ).
  static const String _yearSuffixBC = "fyrir Krist";

  /// The suffix for positive years ("eftir Krist" - After Christ). Added only if [IsOptions.includeAD] is true.
  static const String _yearSuffixAD = "e.Kr.";

  /// Gendered forms for numbers 1 through 4.
  /// Inner list order: [Masculine, Feminine, Neuter].
  static const List<List<String>> _genderedUnder5 = [
    [], // 0 - Not used
    ["einn", "ein", "eitt"], // 1
    ["tveir", "tvær", "tvö"], // 2
    ["þrír", "þrjár", "þrjú"], // 3
    ["fjórir", "fjórar", "fjögur"], // 4
  ];

  /// Word forms for numbers 0 and 5 through 19. Numbers 1-4 are handled by `_genderedUnder5`.
  /// These numbers (5-19) do not change form based on gender.
  static const List<String> _wordsUnder20 = [
    "núll", // 0
    "", // 1 - Handled by _genderedUnder5
    "", // 2 - Handled by _genderedUnder5
    "", // 3 - Handled by _genderedUnder5
    "", // 4 - Handled by _genderedUnder5
    "fimm", // 5
    "sex", // 6
    "sjö", // 7
    "átta", // 8
    "níu", // 9
    "tíu", // 10
    "ellefu", // 11
    "tólf", // 12
    "þrettán", // 13
    "fjórtán", // 14
    "fimmtán", // 15
    "sextán", // 16
    "sautján", // 17
    "átján", // 18
    "nítján", // 19
  ];

  /// Word forms for tens from 20 to 90. Index corresponds to the tens digit (index 2 = 20, index 9 = 90).
  static const List<String> _wordsTens = [
    "", // 0
    "", // 10 - Covered by _wordsUnder20
    "tuttugu", // 20
    "þrjátíu", // 30
    "fjörutíu", // 40
    "fimmtíu", // 50
    "sextíu", // 60
    "sjötíu", // 70
    "áttatíu", // 80
    "níutíu", // 90
  ];

  /// Defines scale words (million, billion, etc.) using a system similar to long scale, including intermediate terms.
  /// Each entry: `[Scale Value (BigInt), Singular Form, Plural Form, Grammatical Gender]`.
  /// Ordered from highest scale downwards for processing.
  static final List<List<dynamic>> _scaleWords = [
    // Value              Singular          Plural            Gender
    [
      BigInt.parse('1000000000000000000000000'),
      "kvadrilljón",
      "kvadrilljónir",
      Gender.feminine,
    ], // 10^24
    [
      BigInt.parse('1000000000000000000000'),
      "trilljarður",
      "trilljarðar",
      Gender.masculine,
    ], // 10^21
    [
      BigInt.parse('1000000000000000000'),
      "trilljón",
      "trilljónir",
      Gender.feminine
    ], // 10^18
    [
      BigInt.parse('1000000000000000'),
      "billjarður",
      "billjarðar",
      Gender.masculine
    ], // 10^15
    [
      BigInt.parse('1000000000000'),
      "billjón",
      "billjónir",
      Gender.feminine
    ], // 10^12
    [
      BigInt.parse('1000000000'),
      "milljarður",
      "milljarðar",
      Gender.masculine
    ], // 10^9 (Milliard)
    [
      BigInt.parse('1000000'),
      "milljón",
      "milljónir",
      Gender.feminine
    ], // 10^6 (Million)
  ];

  /// Default gender for standalone numbers (often masculine, but context can override).
  static const Gender _defaultGender = Gender.masculine;

  /// Neuter gender, commonly used for abstract counting, years, thousands, hundreds.
  static const Gender _neuterGender = Gender.neuter;

  /// {@macro num2text_base_process}
  /// Converts the given [number] into its Icelandic word representation.
  ///
  /// Handles `int`, `double`, `BigInt`, `Decimal`, and numeric `String` inputs.
  /// Uses [IsOptions] to customize behavior like currency formatting ([IsOptions.currency], [IsOptions.currencyInfo]),
  /// year formatting ([Format.year]), decimal separator ([IsOptions.decimalSeparator]),
  /// and negative prefix ([IsOptions.negativePrefix]).
  /// If `options` is not an instance of [IsOptions], default settings are used.
  ///
  /// Returns the word representation (e.g., "hundrað tuttugu og þrír", "mínus tíu komma fimm", "ein milljón").
  /// If the input is invalid (`null`, `NaN`, `Infinity`, non-numeric string), it returns
  /// [fallbackOnError] if provided, otherwise a default error message like "Ekki tala".
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have Icelandic-specific options, using defaults if none are provided.
    final IsOptions isOptions =
        options is IsOptions ? options : const IsOptions();

    // Handle special non-finite double values early.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? "Neikvætt Óendanlegt"
            : "Óendanlegt"; // Localized infinity
      }
      if (number.isNaN) return fallbackOnError ?? "Ekki tala"; // Not a Number
    }

    // Normalize the input to a Decimal for precise calculations.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Return error if normalization failed (invalid input type or format).
    if (decimalValue == null) return fallbackOnError ?? "Ekki tala";

    // Handle the specific case of zero.
    if (decimalValue == Decimal.zero) {
      if (isOptions.currency) {
        // Currency format for zero (e.g., "núll krónur"). Use plural.
        return "$_zero ${isOptions.currencyInfo.mainUnitPlural ?? isOptions.currencyInfo.mainUnitSingular}";
      }
      // Standard "núll". Also covers year 0.
      return _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for the core conversion logic.
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    try {
      // --- Dispatch based on format options ---
      if (isOptions.format == Format.year) {
        // Year format needs the original integer value and negativity flag.
        textResult = _handleYearFormat(
            absValue.truncate().toBigInt(), isOptions, isNegative);
        // Note: Year format handles BC/AD suffixes internally, so negative prefix is not added here.
      } else {
        // Handle currency or standard number format.
        final BigInt integerPart = absValue.truncate().toBigInt();
        // Check if there's a non-zero fractional part.
        final bool hasFractionalPart =
            absValue > Decimal.fromBigInt(integerPart);

        // Determine the required grammatical gender for the integer part.
        Gender integerGender;
        if (isOptions.currency) {
          // Currency: Króna is feminine.
          integerGender = Gender.feminine;
        } else if (hasFractionalPart ||
            (integerPart == BigInt.zero && absValue > Decimal.zero)) {
          // Standard number with fraction or starting 0.something: Use neuter.
          integerGender = _neuterGender;
        } else {
          // Standard integer: Use default gender (masculine unless context dictates otherwise).
          integerGender = _defaultGender;
        }

        // Convert the integer part using the determined gender.
        String integerText =
            (integerPart == BigInt.zero && absValue > Decimal.zero)
                ? _zero // Handle 0.5 -> "núll komma..."
                : _convertInteger(integerPart, integerGender);

        // Convert the fractional part if it exists.
        String fractionalText = hasFractionalPart
            ? _getFractionalPartText(absValue, isOptions)
            : "";

        // Combine integer and fractional parts based on context.
        if (isOptions.currency) {
          // Currency: Combine number + unit name.
          String mainUnitName = (integerPart == BigInt.one)
              ? isOptions.currencyInfo.mainUnitSingular // Singular form for 1.
              // Plural form for 0, 2+. Fallback to singular if plural is null.
              : (isOptions.currencyInfo.mainUnitPlural ??
                  isOptions.currencyInfo.mainUnitSingular);
          textResult = '$integerText $mainUnitName';
          // Note: Icelandic currency (ISK) has no official subunits in circulation.
          // Fractional part handling for currency is omitted here.
        } else {
          // Standard number: Combine integer and fractional parts.
          if (integerPart == BigInt.zero && fractionalText.isNotEmpty) {
            // Case: 0.5 -> "núll komma fimm"
            textResult = '$_zero $fractionalText';
          } else if (fractionalText.isNotEmpty) {
            // Case: 123.45 -> "hundrað tuttugu og þrír komma fjórir fimm"
            textResult = '$integerText $fractionalText';
          } else {
            // Case: 123 -> "hundrað tuttugu og þrír"
            textResult = integerText;
          }
        }

        // Prepend the negative prefix if applicable (not for years).
        if (isNegative) {
          textResult = "${isOptions.negativePrefix} $textResult";
        }
      }
    } catch (e) {
      // Catch potential errors during conversion (e.g., very large numbers).
      // Consider logging the error: print('Icelandic conversion error: $e');
      return fallbackOnError ??
          "Villa við umbreytingu."; // Generic error message.
    }

    // Clean up potential extra spaces before returning.
    return textResult.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Formats an integer as a calendar year, optionally adding BC/AD suffixes.
  /// Includes special handling for years 1100-1999 ("X hundrað og Y") and 2000-2099 ("tvö þúsund Y").
  /// Years use the neuter gender.
  ///
  /// [yearValue]: The non-negative year value as BigInt.
  /// [options]: Icelandic options, checks `includeAD`.
  /// [originallyNegative]: Flag indicating if the original year was negative (BC).
  /// Returns the year in words, e.g., "nítján hundrað níutíu og níu", "tvö þúsund og fimm", "hundrað fyrir Krist".
  String _handleYearFormat(
      BigInt yearValue, IsOptions options, bool originallyNegative) {
    final BigInt absYear =
        yearValue.abs(); // Already non-negative, but ensures consistency.
    String yearText;

    // Handle special cases for BC years 1 and 100, as they don't fit the general pattern well.
    if (originallyNegative) {
      if (absYear == BigInt.one) {
        return "${_getGenderedWord(1, _neuterGender)} $_yearSuffixBC"; // "eitt fyrir Krist"
      }
      if (absYear == BigInt.from(100))
        return "$_hundred $_yearSuffixBC"; // "hundrað fyrir Krist"
    }

    int yearInt;
    try {
      // Attempt to convert to int for optimized year formatting logic.
      yearInt = absYear.toInt();
    } catch (e) {
      // If year is too large for int, fall back to general integer conversion.
      yearText = _convertInteger(absYear, _neuterGender);
      // Append suffixes based on original sign and options.
      if (originallyNegative) {
        yearText += " $_yearSuffixBC";
      } else if (options.includeAD) {
        yearText += " $_yearSuffixAD";
      }
      return yearText;
    }

    // Special formatting for common year ranges (uses neuter gender).
    if (yearInt >= 1100 && yearInt < 2000) {
      // Format years 1100-1999 as "X hundred and Y".
      int highPartInt = yearInt ~/ 100; // e.g., 19 for 1999
      int lowPartInt = yearInt % 100; // e.g., 99 for 1999
      // Convert the "19" part (neuter).
      yearText = "${_convertChunk(highPartInt, _neuterGender)} $_hundred";
      if (lowPartInt > 0) {
        // Add "og" and the remaining 0-99 part (neuter).
        yearText += " $_og ${_convertChunk(lowPartInt, _neuterGender)}";
      }
    } else if (absYear == BigInt.from(2000)) {
      // Exactly 2000.
      yearText =
          "${_getGenderedWord(2, _neuterGender)} $_thousand"; // "tvö þúsund"
    } else if (yearInt > 2000 && yearInt < 2100) {
      // Format years 2001-2099 as "two thousand (and) Y".
      yearText =
          "${_getGenderedWord(2, _neuterGender)} $_thousand"; // "tvö þúsund"
      int lowPartInt = yearInt % 100; // Get the 01-99 part.
      if (lowPartInt > 0) {
        // Add the remaining 1-99 part (neuter). Note: Icelandic often omits 'og' here.
        yearText += " ${_convertChunk(lowPartInt, _neuterGender)}";
      }
    } else {
      // Default conversion for other years (e.g., < 1100 or >= 2100).
      yearText = _convertInteger(absYear, _neuterGender);
    }

    // Append suffixes based on original sign and options (excluding the special BC cases handled above).
    if (!originallyNegative && options.includeAD && absYear > BigInt.zero) {
      yearText += " $_yearSuffixAD";
    } else if (originallyNegative &&
        !(absYear == BigInt.one || absYear == BigInt.from(100))) {
      // Add BC suffix if originally negative and not the special cases 1 or 100 BC.
      yearText += " $_yearSuffixBC";
    }

    return yearText;
  }

  /// Converts the fractional part of a [Decimal] value to words.
  /// Reads digits individually after the separator word ("komma" or "punktur").
  /// Fractional digits use the neuter gender.
  ///
  /// [value]: The Decimal number containing the fractional part.
  /// [options]: Icelandic options, used for `decimalSeparator`.
  /// Returns the fractional part in words, e.g., "komma fjórir fimm". Returns empty string if no fractional part.
  String _getFractionalPartText(Decimal value, IsOptions options) {
    // Extract digits after the decimal point.
    String fractionalDigits = value.toString().split('.').last;
    if (fractionalDigits.isEmpty) return ""; // No fractional part.

    // Determine the separator word based on options.
    String separatorWord;
    var separator =
        options.decimalSeparator ?? DecimalSeparator.comma; // Default to comma.
    switch (separator) {
      case DecimalSeparator.comma:
        separatorWord = _commaWord;
        break;
      case DecimalSeparator.point:
      case DecimalSeparator.period:
        separatorWord = _pointWord;
        break;
    }

    // Convert each digit character to its neuter word form.
    List<String> digitWords = fractionalDigits.split('').map((digit) {
      final int digitInt = int.parse(digit);
      // Use _getGenderedWord to get the neuter form for digits 0-4, or the standard word.
      return _getGenderedWord(digitInt, _neuterGender);
    }).toList();

    // Combine separator and digit words.
    return '$separatorWord ${digitWords.join(' ')}';
  }

  /// Converts a non-negative [BigInt] integer into its Icelandic word representation.
  /// This handles large numbers by iterating through defined scales (million, milljarður, etc.)
  /// and recursively converting the count for each scale. Uses grammatical gender appropriate for the scale noun.
  ///
  /// [n]: The non-negative integer to convert. Must not be negative.
  /// [targetGender]: The required grammatical gender for the *final* 0-999 chunk of the number.
  /// Returns the integer in words, e.g., "ein milljón tvö hundruð og þrjátíu þúsund og fjögur hundruð og fimmtíu".
  String _convertInteger(BigInt n, Gender targetGender) {
    if (n == BigInt.zero) return _zero; // Base case: zero.
    // Ensure input is non-negative.
    if (n < BigInt.zero)
      throw ArgumentError("Negative input to _convertInteger: $n");

    List<String> parts = []; // Stores word parts for each scale level.
    BigInt remainder = n;
    bool higherPartProcessed =
        false; // Flag to track if we need "og" before the final chunk.

    // Process large scale words (milljón, milljarður, etc.) from highest to lowest.
    for (final scaleInfo in _scaleWords) {
      final BigInt scaleValue = scaleInfo[0] as BigInt; // Value (e.g., 10^6)

      if (remainder >= scaleValue) {
        final String singName =
            scaleInfo[1] as String; // Singular name (e.g., "milljón")
        final String plurName =
            scaleInfo[2] as String; // Plural name (e.g., "milljónir")
        final Gender scaleNounGender =
            scaleInfo[3] as Gender; // Gender of the scale noun

        // Calculate how many of this scale unit are present.
        BigInt count = remainder ~/ scaleValue;
        remainder %= scaleValue; // Update the remainder.

        // Recursively convert the count, matching the gender of the scale noun.
        String countText = _convertInteger(count, scaleNounGender);
        // Choose singular or plural scale noun based on the count.
        String scaleText = (count == BigInt.one) ? singName : plurName;

        // Combine the count and the scale noun.
        parts.add("$countText $scaleText");
        higherPartProcessed =
            true; // Mark that a higher scale part was processed.
      }
    }

    // Process thousands.
    final BigInt thousandValue = BigInt.from(1000);
    if (remainder >= thousandValue) {
      BigInt count = remainder ~/ thousandValue; // Number of thousands.
      remainder %= thousandValue; // Update remainder (0-999).

      // Convert the count of thousands (uses neuter gender for "þúsund").
      String countText = _convertInteger(count, _neuterGender);
      parts.add("$countText $_thousand"); // Combine count and "þúsund".
      higherPartProcessed = true; // Mark that thousands were processed.
    }

    // Process the final remainder (0-999).
    if (remainder > BigInt.zero) {
      int finalChunkInt = remainder.toInt(); // Convert the final chunk to int.
      // Convert the 0-999 chunk using the target gender passed to this function.
      String chunkText = _convertChunk(finalChunkInt, targetGender);

      // Add "og" (and) if a higher part was processed AND the final chunk is less than 100.
      // Icelandic rule: "hundrað og einn", "þúsund og tveir", but "hundrað tuttugu og þrír" (og within chunk).
      if (higherPartProcessed && finalChunkInt < 100) {
        parts.add(_og);
      }
      parts.add(chunkText); // Add the final chunk text.
    }

    // Join all parts with spaces, filtering out any potentially empty strings.
    return parts.where((part) => part.isNotEmpty).join(' ');
  }

  /// Converts a number between 1 and 999 into its Icelandic word representation.
  /// Handles hundreds, tens, units, and the use of "og" (and). Uses gender for numbers 1-4.
  ///
  /// [n]: The number to convert (must be 1 <= n < 1000).
  /// [gender]: The required grammatical gender for the units part (1-4).
  /// Returns the chunk in words, e.g., "hundrað", "tuttugu og einn", "fjögur hundruð og fimmtíu".
  String _convertChunk(int n, Gender gender) {
    // Returns empty for 0, as it's handled elsewhere or implicitly.
    if (n <= 0 || n >= 1000) return "";

    List<String> words = []; // Stores word parts for this chunk.
    int remainder = n;
    bool hundredsProcessed = false; // Flag to track if "og" is needed.

    // Process hundreds.
    if (remainder >= 100) {
      int hundredDigit = remainder ~/ 100; // Get the hundreds digit (1-9).
      // Convert the digit (1-9) using neuter gender (for "hundrað").
      words.add(_getGenderedWord(hundredDigit, _neuterGender));
      words.add(_hundred); // Add "hundrað".
      remainder %= 100; // Update remainder (0-99).
      hundredsProcessed = true; // Mark that hundreds were processed.
    }

    // Process tens and units (1-99).
    if (remainder > 0) {
      // Add "og" (and) if hundreds were processed.
      if (hundredsProcessed) words.add(_og);

      // Handle 1-19 directly.
      if (remainder < 20) {
        // Get the word (gendered for 1-4, standard for 5-19) using the target gender.
        words.add(_getGenderedWord(remainder, gender));
      } else {
        // Handle 20-99.
        words.add(_wordsTens[
            remainder ~/ 10]); // Add the tens word (e.g., "tuttugu").
        int unit = remainder % 10; // Get the unit digit.
        if (unit > 0) {
          words.add(_og); // Add "og" between tens and units.
          // Get the unit word (gendered for 1-4) using the target gender.
          words.add(_getGenderedWord(unit, gender));
        }
      }
    }

    // Combine the collected parts.
    return words.join(' ');
  }

  /// Returns the correct Icelandic word for a number 0-19, applying gender for 1-4.
  ///
  /// [n]: The number (0-19).
  /// [gender]: The required grammatical gender.
  /// Returns the word form (e.g., "einn", "ein", "eitt", "fimm"). Returns the number as string if out of range.
  String _getGenderedWord(int n, Gender gender) {
    if (n == 0) return _zero;

    // Use the specific gendered list for 1-4.
    if (n >= 1 && n <= 4) {
      int genderIndex;
      // Map the Gender enum to the index in _genderedUnder5 lists.
      switch (gender) {
        case Gender.masculine:
          genderIndex = 0;
          break;
        case Gender.feminine:
          genderIndex = 1;
          break;
        case Gender.neuter:
          genderIndex = 2;
          break;
      }
      // Perform bounds check before accessing the list.
      if (n < _genderedUnder5.length &&
          genderIndex < _genderedUnder5[n].length) {
        return _genderedUnder5[n][genderIndex];
      }
    }

    // Use the standard list for 5-19 (and potentially 0 if called directly).
    if (n >= 0 && n < _wordsUnder20.length && _wordsUnder20[n].isNotEmpty) {
      return _wordsUnder20[n];
    }

    // Fallback for unexpected values (should not happen for digits 0-9).
    return n.toString();
  }
}
