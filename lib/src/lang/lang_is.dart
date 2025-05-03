import 'package:decimal/decimal.dart';

import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/is_options.dart';
import '../utils/utils.dart';

/// {@template num2text_is}
/// Converts numbers to Icelandic words (`Lang.IS`).
///
/// Implements [Num2TextBase] for Icelandic. Handles various numeric types.
/// Supports cardinal numbers with grammatical gender agreement (masculine, feminine, neuter),
/// decimals, negatives, currency (ISK), and year formatting.
/// Uses [IsOptions] for customization (e.g., explicit gender, AD/BC).
/// {@endtemplate}
class Num2TextIS implements Num2TextBase {
  // --- Constants ---
  static const String _og = "og"; // Conjunction "and".
  static const String _zero = "núll";
  static const String _hundred = "hundrað"; // 100 (neuter singular).
  static const String _hundredPlural = "hundruð"; // 200-900 (neuter plural).
  static const String _thousand = "þúsund"; // 1000+ (neuter singular/plural).
  static const String _pointWord = "punktur"; // Decimal separator word "point".
  static const String _commaWord = "komma"; // Decimal separator word "comma".
  static const String _yearSuffixBC = "fyrir Krist"; // Suffix for BC years.
  static const String _yearSuffixAD = "e.Kr."; // Suffix for AD/CE years.

  // Gendered forms for 1-4: [masculine, feminine, neuter].
  static const List<List<String>> _genderedUnder5 = [
    [], // 0 handled by _zero.
    ["einn", "ein", "eitt"], // 1
    ["tveir", "tvær", "tvö"], // 2
    ["þrír", "þrjár", "þrjú"], // 3
    ["fjórir", "fjórar", "fjögur"], // 4
  ];

  // Numbers 5-19 (no gender agreement).
  static const List<String> _wordsUnder20 = [
    "núll",
    "",
    "",
    "",
    "",
    "fimm",
    "sex",
    "sjö",
    "átta",
    "níu",
    "tíu",
    "ellefu",
    "tólf",
    "þrettán",
    "fjórtán",
    "fimmtán",
    "sextán",
    "sautján",
    "átján",
    "nítján",
  ];

  // Tens from 20-90 (no gender agreement).
  static const List<String> _wordsTens = [
    "",
    "",
    "tuttugu",
    "þrjátíu",
    "fjörutíu",
    "fimmtíu",
    "sextíu",
    "sjötíu",
    "áttatíu",
    "níutíu",
  ];

  // Large scale words: [value, singular, plural, gender]. Follows short scale.
  static final List<List<dynamic>> _scaleWords = [
    // Higher scales are rare but included.
    [
      BigInt.parse('1000000000000000000000000'),
      "kvadrilljón",
      "kvadrilljónir",
      Gender.feminine
    ], // 10^24
    [
      BigInt.parse('1000000000000000000000'),
      "trilljarður",
      "trilljarðar",
      Gender.masculine
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
    ], // 10^9
    [BigInt.parse('1000000'), "milljón", "milljónir", Gender.feminine], // 10^6
  ];

  // Default genders used internally in specific contexts.
  static const Gender _defaultGender =
      Gender.masculine; // For standalone integers.
  static const Gender _neuterGender =
      Gender.neuter; // For decimals, years, counting thousands.

  /// Processes the given [number] into Icelandic words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [IsOptions] for customization (currency, year format, decimals, gender, AD/BC).
  /// Determines required gender based on options or context (currency, decimals, standalone integer).
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or "Ekki Tala" on failure.
  /// Catches internal conversion errors and returns a generic Icelandic error message.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [IsOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Icelandic words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final IsOptions isOptions =
        options is IsOptions ? options : const IsOptions();
    final String errorFallback =
        fallbackOnError ?? "Ekki Tala"; // Default "Not a Number".

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Neikvætt Óendanlegt" : "Óendanlegt";
      if (number.isNaN) return errorFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    if (decimalValue == Decimal.zero) {
      // Handle zero separately for currency.
      if (isOptions.currency)
        return "$_zero ${isOptions.currencyInfo.mainUnitPlural ?? isOptions.currencyInfo.mainUnitSingular}";
      return _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    try {
      if (isOptions.format == Format.year) {
        // Year format handles sign internally and uses Neuter gender.
        textResult = _handleYearFormat(
            absValue.truncate().toBigInt(), isOptions, isNegative);
      } else {
        final BigInt integerPart = absValue.truncate().toBigInt();
        final bool hasFractionalPart =
            absValue > Decimal.fromBigInt(integerPart);

        // Determine the target gender for the integer part. Priority order:
        // 1. Explicit gender in options.
        // 2. Currency (Króna is feminine).
        // 3. Decimal number or 0.xxx (neuter).
        // 4. Default standalone integer (masculine).
        Gender targetGender;
        if (isOptions.gender != null) {
          targetGender = isOptions.gender!;
        } else if (isOptions.currency) {
          targetGender = Gender.feminine; // Króna is feminine.
        } else if (hasFractionalPart ||
            (integerPart == BigInt.zero && absValue > Decimal.zero)) {
          targetGender = _neuterGender; // Decimals treated as neuter.
        } else {
          targetGender = _defaultGender; // Default for integers.
        }

        // Convert integer part using the determined gender.
        // Handle case where integer part is 0 but fraction exists (e.g., 0.5).
        String integerText =
            (integerPart == BigInt.zero && absValue > Decimal.zero)
                ? _zero
                : _convertInteger(integerPart, targetGender);

        // Convert fractional part if it exists.
        String fractionalText = hasFractionalPart
            ? _getFractionalPartText(absValue, isOptions)
            : "";

        // Combine parts based on context (currency vs standard number).
        if (isOptions.currency) {
          // Combine integer text with currency unit name (applying gender rules).
          String mainUnitName = (integerPart == BigInt.one)
              ? isOptions.currencyInfo.mainUnitSingular
              : (isOptions.currencyInfo.mainUnitPlural ??
                  isOptions.currencyInfo.mainUnitSingular);
          textResult = '$integerText $mainUnitName';
          // ISK subunits (aurar) are ignored as they are deprecated.
        } else {
          // Standard number formatting.
          if (integerPart == BigInt.zero && fractionalText.isNotEmpty) {
            textResult = '$_zero $fractionalText'; // e.g., "núll komma einn".
          } else if (fractionalText.isNotEmpty) {
            textResult =
                '$integerText $fractionalText'; // e.g., "tveir komma fimm".
          } else {
            textResult = integerText; // Integer only.
          }
        }

        // Prepend negative prefix if necessary.
        if (isNegative) {
          textResult = "${isOptions.negativePrefix} $textResult";
        }
      }
    } catch (e) {
      // Catch potential errors during conversion.
      return fallbackOnError ??
          "Villa við umbreytingu"; // Generic Icelandic error.
    }

    return textResult.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Converts a non-negative [BigInt] into Icelandic words, applying gender.
  ///
  /// Handles large scale words (milljón, milljarður, etc.) and thousands.
  /// Inserts "og" based on Icelandic grammatical rules.
  /// Delegates chunks < 1000 to [_convertChunk].
  ///
  /// @param n The non-negative integer to convert.
  /// @param targetGender The required grammatical gender for the final chunk (1-4).
  /// @return The integer as Icelandic words.
  String _convertInteger(BigInt n, Gender targetGender) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero)
      throw ArgumentError("Negative input to _convertInteger: $n");

    if (n < BigInt.from(1000)) {
      // Handle numbers below 1000 directly.
      return _convertChunk(n.toInt(), targetGender);
    }

    List<String> parts = [];
    BigInt remainder = n;
    bool higherPartProcessed =
        false; // Tracks if a scale word or 'þúsund' was added.

    // Process large scale words (milljón and above).
    for (final scaleInfo in _scaleWords) {
      final BigInt scaleValue = scaleInfo[0] as BigInt;
      if (remainder >= scaleValue) {
        final String singName = scaleInfo[1] as String;
        final String plurName = scaleInfo[2] as String;
        final Gender scaleNounGender = scaleInfo[3] as Gender;

        BigInt count = remainder ~/ scaleValue;
        remainder %= scaleValue;

        // Convert the count part, matching the gender of the scale noun (e.g., milljón is feminine).
        String countText = _convertInteger(count, scaleNounGender);
        String scaleText = (count == BigInt.one) ? singName : plurName;

        parts.add("$countText $scaleText");
        higherPartProcessed = true;
      }
    }

    // Process thousands ("þúsund") - the count before it is always neuter.
    final BigInt thousandValue = BigInt.from(1000);
    if (remainder >= thousandValue || (parts.isEmpty && n >= thousandValue)) {
      // Handle cases like 1000, 2000 or parts like 5,001,000.
      if (remainder >= thousandValue) {
        BigInt count = remainder ~/ thousandValue;
        remainder %= thousandValue;
        // Count before "þúsund" is always neuter.
        String countText = _convertInteger(count, _neuterGender);
        parts.add("$countText $_thousand");
        higherPartProcessed = true;
      }
    }

    // Process final chunk (0-999).
    if (remainder > BigInt.zero) {
      int finalChunkInt = remainder.toInt();
      // Convert the final chunk using the overall target gender passed to the function.
      String chunkText = _convertChunk(finalChunkInt, targetGender);

      // Insert "og" if a higher part was processed and the final chunk is < 100.
      // Icelandic rule: "einn milljón OG einn", "eitt þúsund OG einn", but "eitt þúsund eitt hundrað".
      if (higherPartProcessed && finalChunkInt < 100) {
        parts.add(_og);
      }
      parts.add(chunkText);
    }

    // Join parts, filtering potential empty strings.
    return parts.where((part) => part.isNotEmpty).join(' ');
  }

  /// Converts an integer year value to Icelandic words.
  ///
  /// Applies specific Icelandic formatting rules for years (e.g., 1984, 2000, 2025).
  /// Always uses Neuter gender for year conversion internally. Appends AD/BC suffixes.
  ///
  /// @param yearValue The absolute value of the year as BigInt.
  /// @param options Formatting options.
  /// @param originallyNegative Indicates if the input year was negative (for BC suffix).
  /// @return The year as Icelandic words.
  String _handleYearFormat(
      BigInt yearValue, IsOptions options, bool originallyNegative) {
    final BigInt absYear = yearValue.abs();
    String yearText;

    try {
      // Use int for typical year range checks, fallback to BigInt conversion if too large.
      final int yearInt = absYear.toInt();

      // Apply specific formatting rules based on year ranges. Always uses Neuter gender.
      if (yearInt >= 1100 && yearInt < 2000) {
        // e.g., 1984 -> nítján hundruð og áttatíu og fjögur.
        int highPartInt = yearInt ~/ 100; // 11-19.
        int lowPartInt = yearInt % 100; // 00-99.
        // Use hundrað (sg) for 1100, hundruð (pl) for 1200+.
        String hundredWord = (highPartInt == 11) ? _hundred : _hundredPlural;
        String highPartText = _convertChunk(highPartInt, _neuterGender);
        yearText = "$highPartText $hundredWord";
        if (lowPartInt > 0) {
          // Add "og" before the final part < 100.
          yearText += " $_og ${_convertChunk(lowPartInt, _neuterGender)}";
        }
      } else if (yearInt == 2000) {
        yearText =
            "${_getGenderedWord(2, _neuterGender)} $_thousand"; // "tvö þúsund".
      } else if (yearInt > 2000 && yearInt < 2100) {
        // e.g., 2025 -> tvö þúsund tuttugu og fimm.
        yearText =
            "${_getGenderedWord(2, _neuterGender)} $_thousand"; // "tvö þúsund".
        int lowPartInt = yearInt % 100;
        if (lowPartInt > 0) {
          // Concatenate directly, e.g., "tvö þúsund [og] tuttugu og fimm" (chunk adds internal "og").
          yearText += " ${_convertChunk(lowPartInt, _neuterGender)}";
        }
      } else {
        // Default conversion for other years (e.g., 1066).
        yearText = _convertInteger(absYear, _neuterGender);
      }
    } catch (e) {
      // Fallback for very large years exceeding int limits.
      yearText = _convertInteger(absYear, _neuterGender);
    }

    // Append era suffixes.
    if (originallyNegative) {
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD && absYear > BigInt.zero) {
      yearText += " $_yearSuffixAD";
    }

    return yearText;
  }

  /// Converts the fractional part of a [Decimal] to Icelandic words.
  ///
  /// Uses the separator word ("komma" or "punktur") from [IsOptions].
  /// Reads digits individually, applying Neuter gender.
  ///
  /// @param value The full decimal value.
  /// @param options Formatting options.
  /// @return The fractional part as words (e.g., "komma einn tveir").
  String _getFractionalPartText(Decimal value, IsOptions options) {
    // Extract digits after the decimal point.
    String fractionalDigits = value.toString().split('.').last;
    if (fractionalDigits.isEmpty) return "";

    // Determine separator word based on options (defaulting to comma).
    String separatorWord;
    var separator = options.decimalSeparator ?? DecimalSeparator.comma;
    switch (separator) {
      case DecimalSeparator.comma:
        separatorWord = _commaWord;
        break;
      case DecimalSeparator.point:
      case DecimalSeparator.period:
        separatorWord = _pointWord;
        break;
    }

    // Convert each digit individually using Neuter gender.
    List<String> digitWords = fractionalDigits.split('').map((digit) {
      final int digitInt = int.parse(digit);
      return _getGenderedWord(
          digitInt, _neuterGender); // Digits after comma/point are neuter.
    }).toList();

    return '$separatorWord ${digitWords.join(' ')}';
  }

  /// Converts an integer from 1 to 999 into Icelandic words, applying gender.
  ///
  /// Handles hundreds ("hundrað"/"hundruð") and the insertion of "og"
  /// between hundreds and tens/units, and between tens and units.
  ///
  /// @param n The integer chunk (1-999).
  /// @param gender The required grammatical gender for numbers 1-4 in the chunk.
  /// @return The chunk as Icelandic words.
  String _convertChunk(int n, Gender gender) {
    if (n <= 0 || n >= 1000) return ""; // Should not happen for valid chunks.

    List<String> words = [];
    int remainder = n;
    bool hundredsProcessed = false;

    // Handle hundreds part.
    if (remainder >= 100) {
      int hundredDigit = remainder ~/ 100;
      // Use "hundrað" (neuter sg) for 100, "hundruð" (neuter pl) for 200-900.
      String hundredWord = (hundredDigit == 1) ? _hundred : _hundredPlural;
      // The count (1-9) before hundred(s) is always Neuter.
      words.add(_getGenderedWord(hundredDigit, _neuterGender));
      words.add(hundredWord);
      remainder %= 100;
      hundredsProcessed = true;
    }

    // Handle tens and units part (1-99).
    if (remainder > 0) {
      // Add "og" if hundreds came before.
      if (hundredsProcessed) words.add(_og);

      if (remainder < 20) {
        // Use the target gender for numbers 1-19.
        words.add(_getGenderedWord(remainder, gender));
      } else {
        // Handle 20-99.
        words.add(_wordsTens[remainder ~/ 10]); // Tens word (e.g., "tuttugu").
        int unit = remainder % 10;
        if (unit > 0) {
          // Add "og" between tens and units (e.g., "tuttugu OG einn").
          words.add(_og);
          // Use the target gender for the unit part (1-4).
          words.add(_getGenderedWord(unit, gender));
        }
      }
    }

    return words.join(' ');
  }

  /// Gets the Icelandic word for a number 0-19, applying gender for 1-4.
  ///
  /// @param n The number (0-19).
  /// @param gender The required grammatical gender.
  /// @return The corresponding Icelandic word.
  String _getGenderedWord(int n, Gender gender) {
    if (n == 0) return _zero;

    // Apply gender rules for 1-4.
    if (n >= 1 && n <= 4) {
      int genderIndex;
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
      // Retrieve the gendered form from the list.
      if (n < _genderedUnder5.length &&
          genderIndex < _genderedUnder5[n].length) {
        return _genderedUnder5[n][genderIndex];
      }
    }

    // Return standard word for 5-19 (or if gendered lookup failed).
    if (n >= 0 && n < _wordsUnder20.length && _wordsUnder20[n].isNotEmpty) {
      return _wordsUnder20[n];
    }

    // Fallback for unexpected values.
    return n.toString();
  }
}
