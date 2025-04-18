import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/sv_options.dart';
import '../utils/utils.dart';

/// {@template num2text_sv}
/// The Swedish language (`Lang.SV`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Swedish word representation following standard Swedish grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [SvOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (using a standard European scale).
/// It differentiates between "en" and "ett" for the number one based on context (e.g., standard number vs. currency).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [SvOptions].
/// {@endtemplate}
class Num2TextSV implements Num2TextBase {
  // --- Constants for Swedish Words ---
  static const String _zero = "noll";
  static const String _pointWord = "punkt"; // Word for '.' decimal separator
  static const String _commaWord = "komma"; // Word for ',' decimal separator
  static const String _hundred = "hundra";
  static const String _thousand = "tusen";

  // Scale words (long scale variant)
  static const String _millionSingular = "miljon"; // 10^6
  static const String _millionPlural = "miljoner";
  static const String _milliardSingular =
      "miljard"; // 10^9 (Commonly used in Swedish)
  static const String _milliardPlural = "miljarder";
  static const String _billionSingular = "biljon"; // 10^12
  static const String _billionPlural = "biljoner";
  static const String _billiardSingular = "biljard"; // 10^15
  static const String _billiardPlural = "biljarder";
  static const String _trillionSingular = "triljon"; // 10^18
  static const String _trillionPlural = "triljoner";
  static const String _trilliardSingular = "triljard"; // 10^21
  static const String _trilliardPlural = "triljarder";
  static const String _quadrillionSingular = "kvadriljon"; // 10^24
  static const String _quadrillionPlural = "kvadriljoner";

  // Other constants
  static const String _currencyConjunction =
      "och"; // Separator for currency units ("and")
  static const String _yearSuffixBC = "f.Kr."; // före Kristus (BC)
  static const String _yearSuffixAD = "e.Kr."; // efter Kristus (AD/CE)

  // --- Lookup Lists ---
  // Words for numbers 0-19
  static const List<String> _wordsUnder20 = [
    "noll",
    "ett", // Note: 'ett' is neuter/default, 'en' is utrum (common gender)
    "två",
    "tre",
    "fyra",
    "fem",
    "sex",
    "sju",
    "åtta",
    "nio",
    "tio",
    "elva",
    "tolv",
    "tretton",
    "fjorton",
    "femton",
    "sexton",
    "sjutton",
    "arton",
    "nitton",
  ];

  // Words for tens (20, 30, ..., 90)
  static const List<String> _wordsTens = [
    "", // 0 (placeholder)
    "", // 10 (placeholder)
    "tjugo", // 20
    "trettio", // 30
    "fyrtio", // 40
    "femtio", // 50
    "sextio", // 60
    "sjuttio", // 70
    "åttio", // 80
    "nittio", // 90
  ];

  // Scale words mapping for large numbers (singular and plural forms)
  static const List<Map<String, String>> _scaleWords = [
    {"singular": "", "plural": ""}, // 10^0 (Units)
    {"singular": _thousand, "plural": _thousand}, // 10^3 (Thousand)
    {"singular": _millionSingular, "plural": _millionPlural}, // 10^6 (Million)
    {
      "singular": _milliardSingular,
      "plural": _milliardPlural
    }, // 10^9 (Milliard/Billion)
    {
      "singular": _billionSingular,
      "plural": _billionPlural
    }, // 10^12 (Billion/Trillion)
    {
      "singular": _billiardSingular,
      "plural": _billiardPlural
    }, // 10^15 (Billiard/Quadrillion)
    {
      "singular": _trillionSingular,
      "plural": _trillionPlural
    }, // 10^18 (Trillion/Quintillion)
    {
      "singular": _trilliardSingular,
      "plural": _trilliardPlural
    }, // 10^21 (Trilliard/Sextillion)
    {
      "singular": _quadrillionSingular,
      "plural": _quadrillionPlural,
    }, // 10^24 (Quadrillion/Septillion)
  ];

  /// Checks if the scale word at the given index requires the "en" form of 'one'.
  /// Millions, Billions, etc. ("miljon", "biljon") are utrum gender words.
  bool _isScaleUtrum(int scaleIndex) => scaleIndex >= 2;

  /// Processes the given [number] into Swedish words based on the provided [options].
  /// Handles different number types, formats (standard, currency, year),
  /// negativity, and decimal parts.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final SvOptions svOptions =
        options is SvOptions ? options : const SvOptions();

    // Handle special double values early
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? "${svOptions.negativePrefix} Oändlighet"
            : "Oändlighet";
      }
      if (number.isNaN) {
        return fallbackOnError ?? "Inte ett nummer"; // Not a Number
      }
    }

    // Normalize the input number to Decimal for precision
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Handle null/invalid normalization result
    if (decimalValue == null) {
      return fallbackOnError ?? "Inte ett nummer"; // Not a Number
    }

    // Handle zero separately
    if (decimalValue == Decimal.zero) {
      if (svOptions.currency) {
        // e.g., "noll kronor"
        return "$_zero ${svOptions.currencyInfo.mainUnitPlural ?? svOptions.currencyInfo.mainUnitSingular}";
      } else {
        // Year 0 or standard 0 is just "noll"
        return _zero;
      }
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for conversion logic
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    // Branch based on formatting options
    if (svOptions.format == Format.year) {
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), svOptions);
    } else {
      if (svOptions.currency) {
        textResult = _handleCurrency(absValue, svOptions);
      } else {
        textResult = _handleStandardNumber(absValue, svOptions);
      }
      // Prepend negative prefix if necessary (unless it's a BC year, handled in year format)
      if (isNegative) {
        textResult = "${svOptions.negativePrefix} $textResult";
      }
    }

    return textResult;
  }

  /// Converts a year number into Swedish words, handling AD/BC suffixes and specific phrasing.
  String _handleYearFormat(int year, SvOptions options) {
    final bool isNegative = year < 0; // BC year
    final int absYear = isNegative ? -year : year;
    final BigInt bigAbsYear = BigInt.from(absYear);

    String yearText;
    // Year format typically uses "ett" for one
    final bool useEtt = true;
    final bool useEn = false;

    // Special phrasing for years like 1984 ("nittonhundraåttiofyra")
    if (absYear >= 1100 && absYear < 2000) {
      int highPartInt = absYear ~/ 100; // e.g., 19
      int lowPartInt = absYear % 100; // e.g., 84
      String highText = _convertInteger(BigInt.from(highPartInt),
          useEtt: useEtt, useEn: useEn);
      String lowText = _convertInteger(BigInt.from(lowPartInt),
          useEtt: useEtt, useEn: useEn);

      if (lowPartInt == 0) {
        // e.g., "nittonhundra"
        yearText = "$highText$_hundred";
      } else {
        // e.g., "nittonhundraåttiofyra"
        yearText = "$highText$_hundred$lowText";
      }
    }
    // Similar phrasing for 20xx years (e.g., "tjugohundra", "tjugohundrafem")
    else if (absYear >= 2000 && absYear < 2100) {
      int highPartInt = absYear ~/ 100; // e.g., 20
      int lowPartInt = absYear % 100; // e.g., 05
      String highText = _convertInteger(BigInt.from(highPartInt),
          useEtt: useEtt, useEn: useEn);
      String lowText = _convertInteger(BigInt.from(lowPartInt),
          useEtt: useEtt, useEn: useEn);

      if (lowPartInt == 0) {
        // e.g., "tjugohundra" for 2000
        yearText = "$highText$_hundred";
      } else {
        // e.g., "tjugohundrafem" for 2005
        yearText = "$highText$_hundred$lowText";
      }
    }
    // Default conversion for other years
    else {
      yearText = _convertInteger(bigAbsYear, useEtt: useEtt, useEn: useEn);
    }

    // Add suffixes for BC or AD/CE if requested
    if (isNegative) {
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD && absYear > 0) {
      yearText += " $_yearSuffixAD";
    }

    return yearText;
  }

  /// Converts a number into Swedish currency words.
  String _handleCurrency(Decimal absValue, SvOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    final int decimalPlaces = 2; // Standard for most currencies
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round if requested, otherwise use the original value
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Split into main and subunit values
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPartRounded =
        valueToConvert - valueToConvert.truncate();
    final BigInt subunitValue =
        (fractionalPartRounded * subunitMultiplier).truncate().toBigInt();

    // Convert main part, use "en" for 1 krona (utrum noun)
    String mainText = _convertInteger(mainValue, useEtt: false, useEn: true);
    // Determine singular or plural form for the main unit
    String mainUnitName = (mainValue == BigInt.one)
        ? currencyInfo.mainUnitSingular
        : currencyInfo.mainUnitPlural!; // Assume plural is non-null if needed

    String result = '$mainText $mainUnitName';

    // Add subunit part if it exists
    if (subunitValue > BigInt.zero) {
      // Convert subunit part, use "ett" for 1 öre (neuter noun)
      String subunitText =
          _convertInteger(subunitValue, useEtt: true, useEn: false);
      // Determine singular or plural form for the subunit
      String subUnitName = (subunitValue == BigInt.one)
          ? currencyInfo.subUnitSingular! // Assume singular is non-null
          : currencyInfo.subUnitPlural!; // Assume plural is non-null

      // Use the specified separator or default to "och"
      String separator = currencyInfo.separator ?? _currencyConjunction;
      result += ' $separator $subunitText $subUnitName';
    }

    return result;
  }

  /// Converts a standard number (potentially with decimals) into Swedish words.
  String _handleStandardNumber(Decimal absValue, SvOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    final int scale = absValue.scale; // Number of decimal places

    // Use "ett" for 1 in standard numbers (default/neuter context)
    final bool useEtt = true;
    final bool useEn = false;

    // Convert integer part (unless it's zero and there's a fractional part)
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, useEtt: useEtt, useEn: useEn);

    String fractionalWords = '';
    // Handle decimal part if present
    if (scale > 0 && fractionalPart > Decimal.zero) {
      String separatorWord;
      // Choose decimal separator word based on options
      switch (options.decimalSeparator ?? DecimalSeparator.comma) {
        case DecimalSeparator.comma:
          separatorWord = _commaWord;
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          separatorWord = _pointWord;
          break;
      }

      // Get the fractional digits as a string (e.g., "05" for 0.05)
      // Multiply by 10^scale to make it an integer, then convert to string
      Decimal fractionalValueOnly = absValue.remainder(Decimal.one);
      String fractionalDigits =
          (fractionalValueOnly * (Decimal.ten.pow(scale)).toDecimal())
              .truncate()
              .toBigInt()
              .toString()
              .padLeft(scale, '0'); // Pad with leading zeros if necessary

      // Convert each digit individually
      List<String> digitWords = fractionalDigits.split('').map((digit) {
        final int digitInt = int.parse(digit);
        // Use "ett" for digit 1 in the fractional part
        return (digitInt == 1) ? _wordsUnder20[1] : _wordsUnder20[digitInt];
      }).toList();

      fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
    }

    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer [n] into Swedish words.
  /// Breaks the number into chunks of 1000 and applies scale words.
  /// [useEtt]/[useEn] determine the form of 'one' for the least significant chunk if applicable.
  String _convertInteger(BigInt n,
      {required bool useEtt, required bool useEn}) {
    if (n < BigInt.zero) {
      throw ArgumentError("Integer must be non-negative for conversion: $n");
    }
    if (n == BigInt.zero) return _zero;

    // Handle numbers less than 1000 directly
    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt(), useEtt: useEtt, useEn: useEn);
    }

    List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0; // 0: units, 1: thousands, 2: millions, etc.
    BigInt remaining = n;

    // Process the number in chunks of 1000 from right to left
    while (remaining > BigInt.zero) {
      if (scaleIndex >= _scaleWords.length) {
        // Safety check against excessively large numbers
        throw ArgumentError(
          "Number too large to convert (exceeds defined scales: ${_scaleWords.last['singular']})",
        );
      }

      BigInt chunk = remaining % oneThousand; // Get the current chunk (0-999)
      remaining ~/= oneThousand; // Move to the next chunk

      if (chunk > BigInt.zero) {
        final bool chunkIsOne = chunk == BigInt.one;
        bool currentChunkUseEtt = true; // Default form for 'one' within a chunk
        bool currentChunkUseEn = false;

        String scaleWord = "";
        String separator =
            " "; // Default separator between chunk words and scale word

        if (scaleIndex > 0) {
          // If we are dealing with thousands, millions, etc.
          // Get the appropriate singular/plural scale word
          scaleWord = chunkIsOne
              ? _scaleWords[scaleIndex]["singular"]!
              : _scaleWords[scaleIndex]["plural"]!;

          // Special handling for thousands ("ettusen", not "ett tusen")
          if (scaleIndex == 1) {
            // Thousand scale
            separator = ""; // No space before "tusen"
            if (chunkIsOne) {
              // Handle "ettusen" specifically
              parts.add("ettusen");
              continue; // Skip normal chunk processing for "ettusen"
            }
            // For >1 thousand, use "ett" if needed (e.g., "tjugoett tusen")
            currentChunkUseEtt = true;
            currentChunkUseEn = false;
          } else {
            // Million scale and higher
            separator = " ";
            if (chunkIsOne) {
              // Determine if "en" or "ett" is needed based on scale word gender
              if (_isScaleUtrum(scaleIndex)) {
                // e.g., miljon, miljard (utrum)
                currentChunkUseEtt = false;
                currentChunkUseEn = true; // Use "en"
              } else {
                // Should not happen with current scales, but for completeness
                currentChunkUseEtt = true; // Use "ett"
                currentChunkUseEn = false;
              }
            } else {
              // For >1 million/billion etc., use "ett" if needed (e.g., "tjugoett miljoner")
              currentChunkUseEtt = true;
              currentChunkUseEn = false;
            }
          }
        } else {
          // This is the least significant chunk (0-999)
          // Use the gender passed into the function
          currentChunkUseEtt = useEtt;
          currentChunkUseEn = useEn;
          scaleWord = ""; // No scale word for the units chunk
          separator = ""; // No separator needed
        }

        // Convert the current chunk number (1-999) to words
        String currentChunkText = _convertChunk(
          chunk.toInt(),
          useEtt: currentChunkUseEtt,
          useEn: currentChunkUseEn,
        );

        // Add the converted chunk and its scale word (if any) to the parts list
        if (scaleWord.isNotEmpty) {
          parts.add("$currentChunkText$separator$scaleWord".trim());
        } else {
          parts.add(currentChunkText);
        }
      }
      scaleIndex++; // Move to the next scale level
    }

    // Join the parts in reverse order (since we processed right-to-left)
    return parts.reversed.join(' ');
  }

  /// Converts a number between 0 and 99 into Swedish words.
  /// [useEtt]/[useEn] determines the form of 'one'.
  String _convertUnder100(int n, {required bool useEtt, required bool useEn}) {
    if (n < 0 || n >= 100) {
      throw ArgumentError("Number must be between 0 and 99: $n");
    }

    // Special handling for 'one' based on required gender
    if (n == 1) {
      return useEn
          ? "en"
          : (useEtt ? "ett" : "ett"); // Default to "ett" if not specified
    }
    // Use the lookup table for numbers under 20
    if (n < 20) {
      return _wordsUnder20[n];
    } else {
      // Combine tens word and unit word (e.g., "tjugo" + "tre")
      String tensWord = _wordsTens[n ~/ 10];
      int unit = n % 10;
      if (unit == 0) {
        // Just the tens word (e.g., "tjugo")
        return tensWord;
      } else {
        // Units 1-9 are always "ett", "två", etc. within compound numbers like tjugoett
        String unitWord = _convertUnder100(unit, useEtt: true, useEn: false);
        // Note: Swedish often combines tens and units without a space (tjugoett)
        return "$tensWord$unitWord";
      }
    }
  }

  /// Converts a number between 0 and 999 into Swedish words (a "chunk").
  /// [useEtt]/[useEn] determine the form of 'one' if the number is exactly 1.
  String _convertChunk(int n, {required bool useEtt, required bool useEn}) {
    if (n == 0) return ""; // Empty string for zero chunk
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }

    String hundredPart = "";
    int remainder = n;

    // Handle hundreds part (e.g., "etthundra", "tvåhundra")
    if (remainder >= 100) {
      int hundredDigit = remainder ~/ 100;
      // The hundreds digit itself uses "ett" (e.g., "etthundra")
      String digitWord =
          _convertUnder100(hundredDigit, useEtt: true, useEn: false);

      hundredPart = "$digitWord$_hundred";
      remainder %= 100; // Get the remaining part (0-99)
    }

    String under100Part = "";
    // Handle the remaining part (0-99)
    if (remainder > 0) {
      // Pass the required gender for 'one' down to the under-100 conversion
      under100Part = _convertUnder100(remainder, useEtt: useEtt, useEn: useEn);
    }

    // Combine hundreds and the rest (e.g., "etthundra" + "tjugoett")
    // Note: Swedish combines these without spaces (etthundratjugoett)
    return "$hundredPart$under100Part";
  }
}
