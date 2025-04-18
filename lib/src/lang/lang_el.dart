/// Contains the Greek (EL) implementation of the Num2TextBase interface.
library; // Ensures dart analyze treats this as a library file

import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/el_options.dart';
import '../utils/utils.dart'; // For normalizeNumber and extensions

/// {@template num2text_el}
/// The Greek language (Lang.EL) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Greek word representation following Greek grammar, including gender agreement
/// (e.g., feminine "χιλιάδες") and special forms ("εκατόν").
///
/// Capabilities include handling cardinal numbers, currency (using [ElOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (short scale: χίλια, εκατομμύριο, δισεκατομμύριο).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [ElOptions].
/// {@endtemplate}
class Num2TextEL implements Num2TextBase {
  // --- Constant Definitions ---

  /// The Greek word for zero.
  static const String _zero = "μηδέν";

  /// The Greek word for the decimal separator when using a period/point.
  static const String _point = "τελεία";

  /// The Greek word for the decimal separator when using a comma (default).
  static const String _comma = "κόμμα";

  /// The Greek word for "and", used as a separator in currency.
  static const String _and = "και";

  /// The Greek word for one hundred (used when followed by zero, e.g., 100, 200...).
  static const String _hundredSingular = "εκατό";

  /// The prefix form of one hundred (used when followed by non-zero units/tens, e.g., 101, 123...).
  static const String _hundredSingularPrefix = "εκατόν";

  /// The Greek word for one thousand (singular/neuter form).
  static const String _thousandSingular = "χίλια";

  /// The Greek word for thousands (plural/feminine form).
  static const String _thousandPlural = "χιλιάδες";

  /// Suffix for years Before Christ (BC/BCE).
  static const String _yearSuffixBC = "π.Χ.";

  /// Suffix for years Anno Domini (AD/CE).
  static const String _yearSuffixAD = "μ.Χ.";

  /// Word for positive infinity.
  static const String _infinityPositive = "Άπειρο";

  /// Word for negative infinity.
  static const String _infinityNegative = "Αρνητικό Άπειρο";

  /// Word for "Not a Number".
  static const String _notANumber = "Μη αριθμός";

  /// Greek words for numbers 0-19 (neuter/default form).
  static const List<String> _wordsUnder20 = [
    "μηδέν", // 0
    "ένα", // 1
    "δύο", // 2
    "τρία", // 3
    "τέσσερα", // 4
    "πέντε", // 5
    "έξι", // 6
    "επτά", // 7
    "οκτώ", // 8
    "εννέα", // 9
    "δέκα", // 10
    "έντεκα", // 11
    "δώδεκα", // 12
    "δεκατρία", // 13
    "δεκατέσσερα", // 14
    "δεκαπέντε", // 15
    "δεκαέξι", // 16
    "δεκαεπτά", // 17
    "δεκαοκτώ", // 18
    "δεκαεννέα", // 19
  ];

  /// Specific feminine forms for numbers 1, 3, and 4, used in contexts
  /// like counting thousands ("χιλιάδες" is feminine).
  static const Map<int, String> _wordsUnder20Feminine = {
    1: "μία", // one (f)
    3: "τρεις", // three (f)
    4: "τέσσερις", // four (f)
  };

  /// Greek words for tens (20, 30,... 90).
  static const List<String> _wordsTens = [
    "", // 0 (placeholder)
    "", // 10 (handled by _wordsUnder20)
    "είκοσι", // 20
    "τριάντα", // 30
    "σαράντα", // 40
    "πενήντα", // 50
    "εξήντα", // 60
    "εβδομήντα", // 70
    "ογδόντα", // 80
    "ενενήντα", // 90
  ];

  /// Greek words for hundreds (100, 200,... 900) in neuter form.
  static const List<String> _wordsHundredsNeuter = [
    "", // 0 (placeholder)
    "εκατό", // 100 (special handling via _hundredSingular/_hundredSingularPrefix)
    "διακόσια", // 200
    "τριακόσια", // 300
    "τετρακόσια", // 400
    "πεντακόσια", // 500
    "εξακόσια", // 600
    "επτακόσια", // 700
    "οκτακόσια", // 800
    "εννιακόσια", // 900
  ];

  /// Greek words for hundreds (100, 200,... 900) in feminine form.
  /// Used when modifying feminine nouns like "χιλιάδες".
  static const List<String> _wordsHundredsFeminine = [
    "", // 0 (placeholder)
    "εκατό", // 100 (same as neuter)
    "διακόσιες", // 200 (f)
    "τριακόσιες", // 300 (f)
    "τετρακόσιες", // 400 (f)
    "πεντακόσιες", // 500 (f)
    "εξακόσιες", // 600 (f)
    "επτακόσιες", // 700 (f)
    "οκτακόσιες", // 800 (f)
    "εννιακόσιες", // 900 (f)
  ];

  /// Defines the names for large number scales (thousands, millions, etc.).
  /// Key: Scale index (1=thousand, 2=million, 3=billion...).
  /// Each entry contains:
  /// - `[0]`: Singular form (neuter, except thousands)
  /// - `[1]`: Plural form (neuter, except thousands)
  /// - `[2]`: Boolean indicating if the plural form requires feminine agreement
  ///          for the preceding number (only true for "χιλιάδες").
  static const Map<int, List<dynamic>> _scaleWords = {
    0: ["", "", false], // Base case (no scale)
    1: [
      _thousandSingular,
      _thousandPlural,
      true
    ], // Thousand (χίλια/χιλιάδες - feminine plural)
    2: ["εκατομμύριο", "εκατομμύρια", false], // Million (neuter)
    3: ["δισεκατομμύριο", "δισεκατομμύρια", false], // Billion (neuter)
    4: ["τρισεκατομμύριο", "τρισεκατομμύρια", false], // Trillion (neuter)
    5: [
      "τετράκις εκατομμύριο",
      "τετράκις εκατομμύρια",
      false
    ], // Quadrillion (neuter)
    6: [
      "πεντάκις εκατομμύριο",
      "πεντάκις εκατομμύρια",
      false
    ], // Quintillion (neuter)
    7: [
      "εξάκις εκατομμύριο",
      "εξάκις εκατομμύρια",
      false
    ], // Sextillion (neuter)
    8: [
      "επτάκις εκατομμύριο",
      "επτάκις εκατομμύρια",
      false
    ], // Septillion (neuter)
    // Add more scales as needed following the pattern.
  };

  /// {@macro num2text_base_process}
  ///
  /// [number]: The number to convert. Can be `int`, `double`, `BigInt`, `Decimal`, or a `String` parsable to a number.
  /// [options]: An optional [ElOptions] object to customize the conversion (e.g., currency, year format). Defaults to `const ElOptions()`.
  /// [fallbackOnError]: A custom string to return if the input [number] is invalid (e.g., `null`, `NaN`, unparsable string). If not provided, defaults to "Μη αριθμός".
  ///
  /// Returns the number converted to Greek words, or the [fallbackOnError] string if conversion fails.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure correct options type or use default.
    final ElOptions elOptions =
        options is ElOptions ? options : const ElOptions();
    final String errorFallback =
        fallbackOnError ?? _notANumber; // Default Greek error message

    // Handle special double values first.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? _infinityNegative : _infinityPositive;
      }
      if (number.isNaN) {
        return errorFallback;
      }
    }

    // Normalize the input number to Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // If normalization fails (invalid input), return the fallback string.
    if (decimalValue == null) {
      return errorFallback;
    }

    // Handle zero separately for simplicity.
    if (decimalValue == Decimal.zero) {
      if (elOptions.currency) {
        // Zero currency format (e.g., "μηδέν ευρώ").
        // Use plural form for zero currency units if available, otherwise singular.
        return "$_zero ${elOptions.currencyInfo.mainUnitPlural ?? elOptions.currencyInfo.mainUnitSingular}";
      } else {
        // Standard zero.
        return _zero;
      }
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for the core conversion logic.
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    // Branch based on the specified format.
    if (elOptions.format == Format.year) {
      // Handle year formatting (includes BC/AD logic).
      // Years are treated as integers.
      textResult = _handleYearFormat(
        decimalValue.truncate().toBigInt().toInt(),
        elOptions,
        isNegative,
      );
    } else {
      // Handle currency or standard number formatting.
      if (elOptions.currency) {
        textResult = _handleCurrency(absValue, elOptions);
      } else {
        // Use isInteger check for standard numbers like 123.0
        if (absValue.isInteger) {
          textResult = _convertInteger(
            absValue.toBigInt(),
            isFeminine: false,
            isThousandPluralOverride: false,
          );
        } else {
          textResult = _handleStandardNumber(absValue, elOptions);
        }
      }
      // Prepend the negative prefix if the original number was negative AND it's not year format.
      if (isNegative) {
        textResult = "${elOptions.negativePrefix} $textResult";
      }
    }

    return textResult;
  }

  /// Formats an integer as a year in Greek.
  ///
  /// Handles BC/AD suffixes based on the sign of the year and the `includeAD` option.
  /// Note: Greek uses "π.Χ." (p.Ch.) for BC and "μ.Χ." (m.Ch.) for AD.
  ///
  /// [yearValue]: The integer year value (absolute).
  /// [options]: The [ElOptions] containing formatting flags like `includeAD`.
  /// [isNegativeYear]: Indicates if the original year was negative (BC).
  ///
  /// Returns the year formatted as Greek words with appropriate suffixes.
  String _handleYearFormat(
      int yearValue, ElOptions options, bool isNegativeYear) {
    // Work with the absolute value for conversion.
    final int absYear = yearValue.abs(); // Use abs() for clarity
    final BigInt bigAbsYear = BigInt.from(absYear);

    if (absYear == 0) return _zero; // Year zero is just "zero".

    // Convert the absolute year value to words.
    // Special handling for year 2000 and above to use "χιλιάδες".
    String yearText = _convertInteger(
      bigAbsYear,
      isFeminine: false, // Base is neuter
      // Force "χιλιάδες" plural form for years 2000+
      isThousandPluralOverride: absYear >= 2000,
    );

    // Append suffixes based on sign and options.
    if (isNegativeYear) {
      yearText += " $_yearSuffixBC"; // Append BC suffix for negative years.
    } else if (options.includeAD && absYear > 0) {
      // Append AD suffix only for positive years and if option is enabled.
      yearText += " $_yearSuffixAD";
    }

    return yearText;
  }

  /// Formats a [Decimal] value as currency in Greek.
  ///
  /// Uses the [CurrencyInfo] provided in the [options] to determine unit names,
  /// separator, and pluralization rules. Handles rounding if specified.
  ///
  /// [absValue]: The absolute (non-negative) decimal value of the currency.
  /// [options]: The [ElOptions] containing currency settings (`currencyInfo`, `round`).
  ///
  /// Returns the currency value formatted as Greek words.
  String _handleCurrency(Decimal absValue, ElOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2; // Standard currency subunit precision.
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value if requested, otherwise use the original value.
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate integer (main unit) and fractional (subunit) parts.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    // Use precise Decimal subtraction for fractional part.
    final Decimal fractionalPart =
        valueToConvert - Decimal.fromBigInt(mainValue);

    // Calculate the subunit value (e.g., cents). Round to handle potential precision issues.
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round(scale: 0).toBigInt();

    // Convert the main unit value to words.
    String mainText = _convertInteger(
      mainValue,
      isFeminine: false, // Currency main units (e.g., euro) are usually neuter.
      isThousandPluralOverride:
          false, // Standard thousand handling for currency.
    );

    // Determine the correct singular/plural form for the main unit.
    // Use plural for 0 as well if defined.
    String mainUnitName = (mainValue == BigInt.one)
        ? currencyInfo.mainUnitSingular
        : (currencyInfo.mainUnitPlural ??
            currencyInfo
                .mainUnitSingular); // Fallback to singular if plural is null.

    // Start building the result string.
    String result = '$mainText $mainUnitName';

    // If there's a subunit value, convert and append it.
    if (subunitValue > BigInt.zero) {
      // Convert the subunit value to words.
      String subunitText = _convertInteger(
        subunitValue,
        isFeminine:
            false, // Subunits (e.g., λεπτό/λεπτά) gender handled by singular/plural fields.
        isThousandPluralOverride: false,
      );

      String subUnitName = "";
      // Check if subunit information is defined.
      if (currencyInfo.subUnitSingular != null) {
        // Determine the correct singular/plural form for the subunit.
        // Use plural for values > 1 if available.
        subUnitName = (subunitValue == BigInt.one)
            ? currencyInfo.subUnitSingular!
            : (currencyInfo.subUnitPlural ??
                currencyInfo.subUnitSingular!); // Fallback.
      }

      // Use the specified separator or default to "και" (and).
      String separator = currencyInfo.separator ?? _and;

      // Append the subunit part if a name is available.
      if (subUnitName.isNotEmpty) {
        result += ' $separator $subunitText $subUnitName';
      }
    }

    return result;
  }

  /// Formats a non-integer [Decimal] value as a standard cardinal number in Greek.
  /// Assumes `absValue.isInteger` was checked before calling this.
  ///
  /// Handles integer and fractional parts, using the specified decimal separator word.
  /// Trims trailing zeros from the fractional part representation (e.g., 1.50 becomes "ένα κόμμα πέντε").
  ///
  /// [absValue]: The absolute (non-negative) non-integer decimal value.
  /// [options]: The [ElOptions] containing decimal separator preference.
  ///
  /// Returns the number formatted as Greek words.
  String _handleStandardNumber(Decimal absValue, ElOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    // Use precise subtraction
    final Decimal fractionalPart = absValue - Decimal.fromBigInt(integerPart);

    // Convert the integer part. Handle 0.x cases where integer part is zero.
    String integerWords = (integerPart == BigInt.zero)
        ? _zero
        : _convertInteger(integerPart,
            isFeminine: false, isThousandPluralOverride: false);

    String fractionalWords = '';
    // Check if there is a fractional part (should be true if isInteger check failed)
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word based on options.
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          separatorWord = _point;
          break;
        case DecimalSeparator.comma:
        default: // Default to comma
          separatorWord = _comma;
          break;
      }

      // Convert fractional part to string, removing leading "0."
      String fractionalStr = fractionalPart.toString();
      if (fractionalStr.startsWith('0.')) {
        fractionalStr = fractionalStr.substring(2);
      } else if (fractionalStr.contains('.')) {
        // Fallback for unexpected formats, take part after '.'
        fractionalStr = fractionalStr.split('.').last;
      }

      // Trim trailing zeros ONLY for standard number format (e.g., 1.50 -> "5")
      fractionalStr = fractionalStr.replaceAll(RegExp(r'0+$'), '');

      // If all digits were zeros or string became empty, no fractional words needed.
      if (fractionalStr.isNotEmpty) {
        // Convert each remaining digit individually to words.
        List<String> digitWords = fractionalStr.split('').map((digit) {
          // Ensure it's a digit before parsing
          if (RegExp(r'^[0-9]$').hasMatch(digit)) {
            final int digitInt = int.parse(digit);
            return _wordsUnder20[
                digitInt]; // Use standard neuter form for digits
          }
          return '?'; // Handle unexpected characters
        }).toList();

        // Only add the separator and fractional words if there are valid digits.
        if (digitWords.isNotEmpty && !digitWords.contains('?')) {
          fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
        }
      }
    }

    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] number into Greek words, handling scales (thousands, millions, etc.).
  ///
  /// [n]: The non-negative BigInt number to convert.
  /// [isFeminine]: Indicates if the context requires feminine agreement (primarily for numbers modifying "χιλιάδες").
  /// [isThousandPluralOverride]: Flag used specifically for year formatting to force "χιλιάδες" even for 1000 when year >= 2000.
  ///
  /// Returns the integer part of the number as Greek words.
  /// Throws [ArgumentError] if the number is negative or too large for defined scales.
  String _convertInteger(
    BigInt n, {
    required bool isFeminine,
    required bool isThousandPluralOverride,
  }) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");

    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt(), isFeminine: isFeminine);
    }

    List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0;
    BigInt remaining = n;

    while (remaining > BigInt.zero) {
      BigInt chunkBigInt = remaining % oneThousand;
      remaining ~/= oneThousand;
      int chunk = chunkBigInt.toInt();

      if (chunk > 0) {
        bool scaleRequiresFeminine = false;
        if (scaleIndex > 0 && _scaleWords.containsKey(scaleIndex)) {
          scaleRequiresFeminine = _scaleWords[scaleIndex]![2] as bool;
        }

        // If the scale itself requires feminine (only thousands), the chunk needs feminine agreement.
        bool chunkNeedsFeminine = scaleRequiresFeminine;

        String chunkText = _convertChunk(chunk, isFeminine: chunkNeedsFeminine);

        String scaleWord = "";
        if (scaleIndex > 0) {
          if (!_scaleWords.containsKey(scaleIndex)) {
            throw ArgumentError(
                "Number too large, scale index $scaleIndex not defined.");
          }
          final scaleNames = _scaleWords[scaleIndex]!;
          final String singularScale = scaleNames[0] as String;
          final String pluralScale = scaleNames[1] as String;

          // --- Handle Thousands (scaleIndex == 1) ---
          if (scaleIndex == 1) {
            if (chunk == 1) {
              // 1000: Use "χίλια" unless year >= 2000 or higher scales remain.
              scaleWord = isThousandPluralOverride || remaining > BigInt.zero
                  ? pluralScale // "χιλιάδες"
                  : singularScale; // "χίλια"
              // Omit "ένα"/"μία" before "χίλια"/"χιλιάδες"
              chunkText = "";
            } else {
              // 2000, 3000, etc.: Use "χιλιάδες"
              scaleWord = pluralScale;
              // chunkText was already converted with feminine context
            }
          }
          // --- Handle Millions and higher (scaleIndex > 1) ---
          else {
            scaleWord = (chunk == 1) ? singularScale : pluralScale;
            // Ensure "ένα" (neuter) for "one million", etc., overriding feminine context.
            if (chunk == 1) {
              chunkText = _convertChunk(1, isFeminine: false);
            }
            // else chunkText already calculated correctly (non-feminine context)
          }
        }

        String part = "";
        if (chunkText.isNotEmpty && scaleWord.isNotEmpty) {
          part = "$chunkText $scaleWord";
        } else if (chunkText.isNotEmpty) {
          part = chunkText;
        } else if (scaleWord.isNotEmpty) {
          part = scaleWord;
        }

        if (part.isNotEmpty) {
          parts.add(part);
        }
      }
      scaleIndex++;
    }

    // Join parts in reverse order and clean up potential double spaces.
    return parts.reversed.join(' ').replaceAll('  ', ' ').trim();
  }

  /// Converts a number chunk (0-999) into Greek words.
  ///
  /// [numberChunk]: The integer between 0 and 999 to convert.
  /// [isFeminine]: Indicates if the context requires feminine agreement (for 1, 3, 4).
  ///
  /// Returns the chunk number as Greek words.
  /// Throws [ArgumentError] if the number is outside the 0-999 range.
  String _convertChunk(int numberChunk, {required bool isFeminine}) {
    if (numberChunk == 0) return ""; // Zero chunk is empty string in context.
    if (numberChunk < 0 || numberChunk >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $numberChunk");
    }

    List<String> words = []; // Stores word parts for the chunk.
    int currentRemainder =
        numberChunk; // Use a local variable for remainder calculation

    // --- Handle Hundreds ---
    int hundredsDigit = currentRemainder ~/ 100;
    if (hundredsDigit > 0) {
      // Need the remainder *after* hundreds for the 100 vs 101 check
      int remainderAfterHundreds = currentRemainder % 100;
      if (hundredsDigit == 1) {
        // Special case for 100: use "εκατό" if followed by zero, "εκατόν" otherwise.
        words.add(remainderAfterHundreds == 0
            ? _hundredSingular
            : _hundredSingularPrefix);
      } else {
        // For 200-900, use the appropriate form based on feminine context.
        words.add(
          isFeminine
              ? _wordsHundredsFeminine[hundredsDigit]
              : _wordsHundredsNeuter[hundredsDigit],
        );
      }
      currentRemainder =
          remainderAfterHundreds; // Update remainder for tens/units.
    }

    // --- Handle Tens and Units ---
    if (currentRemainder > 0) {
      if (currentRemainder < 20) {
        // Numbers 1-19: Use direct lookup, applying feminine form if needed.
        String word =
            isFeminine && _wordsUnder20Feminine.containsKey(currentRemainder)
                ? _wordsUnder20Feminine[currentRemainder]!
                : _wordsUnder20[currentRemainder];
        words.add(word);
      } else {
        // Numbers 20-99: Combine tens word and unit word.
        int tensDigit = currentRemainder ~/ 10;
        int unitDigit = currentRemainder % 10;
        words.add(_wordsTens[tensDigit]); // Add the tens word (e.g., "είκοσι").
        if (unitDigit > 0) {
          // If there's a unit digit, add its word, applying feminine form if needed.
          String unitWord =
              isFeminine && _wordsUnder20Feminine.containsKey(unitDigit)
                  ? _wordsUnder20Feminine[unitDigit]!
                  : _wordsUnder20[unitDigit];
          words.add(unitWord);
        }
      }
    }

    // Join the collected words for the chunk with spaces.
    return words.join(' ');
  }
}
