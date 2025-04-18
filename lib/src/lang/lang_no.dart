import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/no_options.dart';
import '../utils/utils.dart';

/// {@template num2text_no}
/// The Norwegian language (Lang.NO) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Norwegian word representation following standard Norwegian grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [NoOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (long scale).
/// It also handles grammatical gender ('en' vs 'ett') based on [NoOptions.gender].
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [NoOptions].
/// {@endtemplate}
class Num2TextNO implements Num2TextBase {
  /// Decimal point word.
  static const String _point = "punktum";

  /// Comma word (used as decimal separator).
  static const String _comma = "komma";

  /// Conjunction word "and".
  static const String _and = "og";

  /// Suffix for BC years (før Kristus).
  static const String _yearSuffixBC = "f.Kr.";

  /// Suffix for AD years (etter Kristus).
  static const String _yearSuffixAD = "e.Kr.";

  /// Number words for 0-19. Note: Index 1 ("en") is the common gender form.
  static const List<String> _wordsUnder20 = [
    "null", // 0
    "en", // 1 (common gender)
    "to", // 2
    "tre", // 3
    "fire", // 4
    "fem", // 5
    "seks", // 6
    "sju", // 7
    "åtte", // 8
    "ni", // 9
    "ti", // 10
    "elleve", // 11
    "tolv", // 12
    "tretten", // 13
    "fjorten", // 14
    "femten", // 15
    "seksten", // 16
    "sytten", // 17
    "atten", // 18
    "nitten", // 19
  ];

  /// Neuter form for "one".
  static const String _oneNeuter = "ett";

  /// Common gender form for "one".
  static const String _oneCommon = "en";

  /// Number words for tens (20, 30,... 90). Index corresponds to tens digit.
  static const List<String> _wordsTens = [
    "", // 0 (unused)
    "", // 10 (handled by _wordsUnder20)
    "tjue", // 20
    "tretti", // 30
    "førti", // 40
    "femti", // 50
    "seksti", // 60
    "sytti", // 70
    "åtti", // 80
    "nitti", // 90
  ];

  /// Word for "hundred".
  static const String _hundred = "hundre";

  /// Word for "thousand".
  static const String _thousand = "tusen";

  /// Scale words (million, billion, etc.) using the long scale system.
  /// Map key is the exponent of 1000 (e.g., 2 for 1000^2 = million).
  /// Value is a list: [singular form, plural form].
  static const Map<int, List<String>> _scaleWords = {
    2: ["million", "millioner"], // 10^6
    3: ["milliard", "milliarder"], // 10^9
    4: ["billion", "billioner"], // 10^12
    5: ["billiard", "billiarder"], // 10^15
    6: ["trillion", "trillioner"], // 10^18
    7: ["trilliard", "trilliarder"], // 10^21
    8: ["kvadrillion", "kvadrillioner"], // 10^24
    // Add more scales if needed
  };

  /// Processes the given [number] into its Norwegian word representation.
  ///
  /// - [number]: The number to convert (int, double, BigInt, Decimal, String).
  /// - [options]: Optional [NoOptions] for customization (currency, year, gender, etc.).
  /// - [fallbackOnError]: Optional string to return on conversion errors.
  /// Returns the number in words, or an error/fallback string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure options are of the correct type or use defaults.
    final NoOptions noOptions =
        options is NoOptions ? options : const NoOptions();

    // Handle specific double values (infinity, NaN).
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? "Negativ uendelig" : "Uendelig";
      }
      if (number.isNaN) {
        return fallbackOnError ?? "Ikke et tall"; // "Not a number"
      }
    }

    // Normalize the input number to Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) {
      return fallbackOnError ?? "Ikke et tall"; // "Not a number"
    }

    // Handle zero separately.
    if (decimalValue == Decimal.zero) {
      if (noOptions.currency) {
        // Zero currency amount (e.g., "null kroner").
        return "${_wordsUnder20[0]} ${noOptions.currencyInfo.mainUnitPlural ?? noOptions.currencyInfo.mainUnitSingular}";
      } else {
        return _wordsUnder20[0]; // "null"
      }
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    // Delegate based on the format specified in options.
    if (noOptions.format == Format.year) {
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), noOptions);
    } else {
      // Handle standard number or currency.
      if (noOptions.currency) {
        textResult = _handleCurrency(absValue, noOptions);
      } else {
        textResult = _handleStandardNumber(absValue, noOptions);
      }
      // Prepend negative prefix if needed.
      if (isNegative) {
        String prefix = noOptions.negativePrefix;
        textResult = prefix + (prefix.endsWith(' ') ? '' : ' ') + textResult;
      }
    }
    return textResult;
  }

  /// Converts a year integer into its Norwegian word representation.
  /// Handles BC/AD suffixes and specific year formatting conventions.
  /// - [year]: The integer year value.
  /// - [options]: The [NoOptions] containing formatting rules.
  /// Returns the year in words.
  String _handleYearFormat(int year, NoOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;
    final BigInt bigAbsYear = BigInt.from(absYear);

    String yearText;

    // Special handling for centuries like "atten hundre" (1800).
    if (absYear >= 1100 && absYear <= 1900 && absYear % 100 == 0) {
      int highPartInt = absYear ~/ 100;
      // Use masculine for the century number (e.g., "atten").
      String highText = _convertChunk(highPartInt, gender: Gender.masculine);
      yearText = "$highText $_hundred";
    } else {
      // Default year conversion, use masculine gender for the number.
      yearText = _convertInteger(bigAbsYear, gender: Gender.masculine);
    }

    // Add BC/AD suffixes if applicable.
    if (isNegative) {
      // Handle "ett år f.Kr." vs "en år f.Kr." if needed, though 'ett' is uncommon here.
      // Currently assumes the number before the suffix doesn't need gender agreement.
      if (absYear == 1) {
        yearText = _oneCommon; // "en f.Kr."
      }
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD && absYear > 0) {
      yearText += " $_yearSuffixAD";
    }

    return yearText;
  }

  /// Converts a Decimal value into Norwegian currency words.
  /// Handles main units and subunits based on [NoOptions.currencyInfo].
  /// - [absValue]: The absolute (non-negative) Decimal value of the currency.
  /// - [options]: The [NoOptions] containing currency info and rounding rules.
  /// Returns the currency amount in words.
  String _handleCurrency(Decimal absValue, NoOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    final int decimalPlaces = 2; // Standard for most currencies
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value if specified.
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main unit and subunit values.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round(scale: 0).toBigInt();

    // Determine the correct main unit name (singular/plural).
    String mainUnitName = (mainValue == BigInt.one)
        ? currencyInfo.mainUnitSingular
        : currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;

    // Convert the main value to words (typically masculine for currency amounts).
    String mainText = _convertInteger(mainValue, gender: Gender.masculine);

    String result = '$mainText $mainUnitName';

    // Add subunit part if it exists.
    if (subunitValue > BigInt.zero) {
      // Subunit value conversion often uses neuter gender (e.g., "ett øre").
      String subunitText = _convertInteger(subunitValue, gender: Gender.neuter);
      String subUnitName = currencyInfo.subUnitSingular ?? "";
      if (subUnitName.isNotEmpty) {
        // Use the specified separator or default to "og".
        String separator = currencyInfo.separator ?? _and;
        result += ' $separator $subunitText $subUnitName';
      }
    }
    return result;
  }

  /// Converts a standard (non-currency, non-year) Decimal number to words.
  /// Handles integer and fractional parts.
  /// - [absValue]: The absolute (non-negative) Decimal value.
  /// - [options]: The [NoOptions] containing gender and decimal separator preferences.
  /// Returns the number in words.
  String _handleStandardNumber(Decimal absValue, NoOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Use the gender specified in options for the integer part.
    Gender integerGender = options.gender;

    String integerWords;
    if (integerPart == BigInt.zero && fractionalPart > Decimal.zero) {
      // Handle cases like 0.5 -> "null komma fem".
      integerWords = _wordsUnder20[0];
    } else {
      integerWords = _convertInteger(integerPart, gender: integerGender);
    }

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Determine the decimal separator word.
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          separatorWord = _point;
          break;
        case DecimalSeparator.comma:
        default: // Default to comma for Norwegian
          separatorWord = _comma;
          break;
      }

      // Extract fractional digits as a string.
      String fractionalDigits = absValue.toString().split('.').last;

      // Remove trailing zeros from the fractional part representation.
      while (fractionalDigits.length > 1 && fractionalDigits.endsWith('0')) {
        fractionalDigits =
            fractionalDigits.substring(0, fractionalDigits.length - 1);
      }

      // Convert each fractional digit to words.
      if (fractionalDigits.isNotEmpty) {
        List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int digitInt = int.parse(digit);
          // Use common gender "en" for digit 1 in decimals, others use standard form.
          return digitInt == 1 ? _oneCommon : _wordsUnder20[digitInt];
        }).toList();
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    } // An empty else if block was here, removed as it had no effect.

    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative BigInt into Norwegian words.
  /// Handles large numbers using scale words and appropriate gender.
  /// - [n]: The non-negative BigInt to convert.
  /// - [gender]: The target [Gender] for the number 'one'.
  /// Returns the integer in words.
  String _convertInteger(BigInt n, {required Gender gender}) {
    if (n == BigInt.zero) return _wordsUnder20[0];
    if (n == BigInt.one)
      return gender == Gender.neuter ? _oneNeuter : _oneCommon;

    List<String> parts = [];
    BigInt currentN = n;
    final BigInt oneThousand = BigInt.from(1000);
    int scaleLevel = 0; // 0: <1000, 1: thousands, 2: millions, etc.
    int lastChunkValue = 0; // Store the value of the last chunk (< 1000).

    while (currentN > BigInt.zero) {
      // Process the number in chunks of 1000.
      int chunkInt = (currentN % oneThousand).toInt();
      currentN ~/= oneThousand;

      if (chunkInt > 0) {
        String chunkText;
        bool chunkIsOne = chunkInt == 1;

        if (scaleLevel == 0) {
          // This is the last chunk (0-999).
          lastChunkValue = chunkInt;
          // Determine gender for this chunk: use specified gender if n < 1000, else masculine.
          Gender chunkGender = (n < oneThousand) ? gender : Gender.masculine;
          chunkText = _convertChunk(chunkInt, gender: chunkGender);
          parts.add(chunkText);
        } else {
          // This chunk belongs to a higher scale (thousands, millions, etc.).
          String scaleWord;
          Gender
              chunkGender; // Gender for the number *preceding* the scale word.

          if (scaleLevel == 1) {
            // Thousands scale ("tusen").
            scaleWord = _thousand;
            // "tusen" is neuter, so the preceding number uses neuter 'one'.
            chunkGender = Gender.neuter;
          } else {
            // Higher scales (million, milliard, etc.).
            List<String>? scaleForms = _scaleWords[scaleLevel];
            if (scaleForms == null)
              throw ArgumentError("Number too large to convert: $n");
            // Select singular or plural scale word.
            scaleWord = chunkIsOne ? scaleForms[0] : scaleForms[1];
            // Assume masculine gender for numbers preceding million+.
            chunkGender = Gender.masculine;
          }
          // Convert the chunk number with the appropriate gender.
          chunkText = _convertChunk(chunkInt, gender: chunkGender);
          parts.add("$chunkText $scaleWord");
        }
      }
      scaleLevel++;
    }

    // Assemble the parts in the correct order.
    List<String> orderedParts = parts.reversed.toList();

    // Insert "og" before the last part if it's between 1 and 99.
    // e.g., "to tusen og femti", "en million og tjueen"
    if (orderedParts.length > 1 && lastChunkValue > 0 && lastChunkValue < 100) {
      orderedParts.insert(orderedParts.length - 1, _and);
    }

    return orderedParts.join(' ');
  }

  /// Converts a number between 0 and 999 into Norwegian words.
  /// - [n]: The integer chunk (0-999).
  /// - [gender]: The target [Gender] for the number 'one' within this chunk.
  /// Returns the chunk number in words.
  String _convertChunk(int n, {required Gender gender}) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000)
      throw ArgumentError("Chunk must be between 0 and 999: $n");

    // Handle 'one' based on the required gender.
    if (n == 1) return gender == Gender.neuter ? _oneNeuter : _oneCommon;

    List<String> words = [];
    int remainder = n;
    bool precededByHundred = false; // Flag if "hundre" was just added.

    // Handle hundreds place.
    if (remainder >= 100) {
      int hundredsDigit = remainder ~/ 100;
      // Use neuter 'one' for "ett hundre".
      words.add(hundredsDigit == 1 ? _oneNeuter : _wordsUnder20[hundredsDigit]);
      words.add(_hundred);
      remainder %= 100;
      if (remainder > 0) {
        // Add "og" between hundreds and tens/units.
        words.add(_and);
        precededByHundred = true;
      }
    }

    // Handle tens and units place (0-99).
    if (remainder > 0) {
      if (remainder < 20) {
        // Numbers 1-19.
        // Determine gender for 'one': if after "hundre og", use masculine, else use specified gender.
        Gender unitGender = precededByHundred ? Gender.masculine : gender;
        words.add(
          remainder == 1
              ? (unitGender == Gender.neuter ? _oneNeuter : _oneCommon)
              : _wordsUnder20[remainder],
        );
      } else {
        // Numbers 20-99.
        String tensWord = _wordsTens[remainder ~/ 10];
        int unit = remainder % 10;
        if (unit == 0) {
          words.add(tensWord);
        } else {
          // Combine tens and units (e.g., "tjueen", "trettito").
          // Always use common gender "en" for the unit '1' in compounds like tjueen.
          String unitWord = (unit == 1) ? _oneCommon : _wordsUnder20[unit];
          words.add("$tensWord$unitWord"); // No space between tens and units.
        }
      }
    }

    return words.join(' ');
  }
}
