/// Contains the Greek (EL) implementation of the Num2TextBase interface.
library; // Ensures dart analyze treats this as a library file

import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/el_options.dart';
import '../utils/utils.dart'; // For normalizeNumber and extensions

/// {@template num2text_el}
/// Converts numbers into their Greek word representations (`Lang.EL`).
///
/// Implements [Num2TextBase] for Greek, handling various numeric types.
/// Features include:
/// *   Cardinal number conversion (positive/negative).
/// *   Correct grammatical gender agreement (e.g., feminine "χιλιάδες").
/// *   Special forms like "εκατόν" before vowels/certain consonants.
/// *   Decimal handling with configurable separators ("κόμμα" or "τελεία").
/// *   Currency formatting (default EUR) via [ElOptions.currencyInfo].
/// *   Year formatting with optional era suffixes (π.Χ./μ.Χ.).
/// *   Large number conversion using the short scale (χίλια, εκατομμύριο...).
/// *   Customization via [ElOptions].
/// *   Fallback messages for invalid inputs (default "Μη Αριθμός").
/// {@endtemplate}
class Num2TextEL implements Num2TextBase {
  // --- Constant Definitions ---

  static const String _zero = "μηδέν"; // Zero
  /// Decimal separator "τελεία" (point).
  static const String _point = "τελεία";

  /// Default decimal separator "κόμμα" (comma).
  static const String _comma = "κόμμα";

  /// Conjunction "και" (and), used as currency separator.
  static const String _and = "και";

  /// "εκατό" (100), used when standing alone or followed by zero remainder.
  static const String _hundredSingular = "εκατό";

  /// "εκατόν" (100), prefix form used before non-zero remainder.
  static const String _hundredSingularPrefix = "εκατόν";

  /// "χίλια" (1000), singular/neuter form.
  static const String _thousandSingular = "χίλια";

  /// "χιλιάδες" (thousands), plural/feminine form.
  static const String _thousandPlural = "χιλιάδες";

  /// Suffix for BC years ("π.Χ." - Πρό Χριστού).
  static const String _yearSuffixBC = "π.Χ.";

  /// Suffix for AD years ("μ.Χ." - Μετά Χριστόν), used if [ElOptions.includeAD] is true.
  static const String _yearSuffixAD = "μ.Χ.";
  static const String _infinityPositive = "Άπειρο"; // Positive Infinity
  static const String _infinityNegative =
      "Αρνητικό Άπειρο"; // Negative Infinity
  static const String _notANumber = "Μη Αριθμός"; // "Not a Number"

  /// Words 0-19 (Neuter/Default forms).
  static const List<String> _wordsUnder20 = [
    _zero,
    "ένα",
    "δύο",
    "τρία",
    "τέσσερα",
    "πέντε",
    "έξι",
    "επτά",
    "οκτώ",
    "εννέα",
    "δέκα",
    "έντεκα",
    "δώδεκα",
    "δεκατρία",
    "δεκατέσσερα",
    "δεκαπέντε",
    "δεκαέξι",
    "δεκαεπτά",
    "δεκαοκτώ",
    "δεκαεννέα",
  ];

  /// Specific feminine forms for 1, 3, 4 (used with feminine nouns like "χιλιάδες").
  static const Map<int, String> _wordsUnder20Feminine = {
    1: "μία",
    3: "τρεις",
    4: "τέσσερις",
  };

  /// Words for tens (20, 30... 90).
  static const List<String> _wordsTens = [
    "",
    "",
    "είκοσι",
    "τριάντα",
    "σαράντα",
    "πενήντα",
    "εξήντα",
    "εβδομήντα",
    "ογδόντα",
    "ενενήντα",
  ];

  /// Words for hundreds (100-900) - Neuter forms.
  static const List<String> _wordsHundredsNeuter = [
    "", // 0 - Placeholder
    "εκατό", // 100 (Special handling)
    "διακόσια", "τριακόσια", "τετρακόσια", "πεντακόσια", "εξακόσια",
    "επτακόσια", "οκτακόσια", "εννιακόσια", // 200-900 (N)
  ];

  /// Words for hundreds (100-900) - Feminine forms (used with e.g., "χιλιάδες").
  static const List<String> _wordsHundredsFeminine = [
    "", // 0 - Placeholder
    "εκατό", // 100 (Same)
    "διακόσιες", "τριακόσιες", "τετρακόσιες", "πεντακόσιες", "εξακόσιες",
    "επτακόσιες", "οκτακόσιες", "εννιακόσιες", // 200-900 (F)
  ];

  /// Scale words (short scale). Key: scale index (1=thousand, 2=million...).
  /// Value: `[singular, plural, requiresFeminineAgreement]`
  static const Map<int, List<dynamic>> _scaleWords = {
    0: ["", "", false], // Base case
    1: [
      _thousandSingular,
      _thousandPlural,
      true
    ], // Thousand (N/F) - Plural is Feminine
    2: ["εκατομμύριο", "εκατομμύρια", false], // Million (N)
    3: ["δισεκατομμύριο", "δισεκατομμύρια", false], // Billion (N)
    4: ["τρισεκατομμύριο", "τρισεκατομμύρια", false], // Trillion (N)
    5: [
      "τετράκις εκατομμύριο",
      "τετράκις εκατομμύρια",
      false
    ], // Quadrillion (N)
    6: [
      "πεντάκις εκατομμύριο",
      "πεντάκις εκατομμύρια",
      false
    ], // Quintillion (N)
    7: ["εξάκις εκατομμύριο", "εξάκις εκατομμύρια", false], // Sextillion (N)
    8: ["επτάκις εκατομμύριο", "επτάκις εκατομμύρια", false], // Septillion (N)
    // Add more scales if needed
  };

  /// {@macro num2text_base_process}
  ///
  /// Processes the given [number] into Greek words.
  ///
  /// @param number The number to convert.
  /// @param options Optional [ElOptions] for customization.
  /// @param fallbackOnError Optional error string (defaults to "Μη Αριθμός").
  /// @return The number as Greek words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final ElOptions elOptions =
        options is ElOptions ? options : const ElOptions();
    final String errorFallback = fallbackOnError ?? _notANumber;

    // Handle non-finite doubles.
    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _infinityNegative : _infinityPositive;
      if (number.isNaN) return errorFallback;
    }

    // Normalize to Decimal.
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    // Handle zero.
    if (decimalValue == Decimal.zero) {
      if (elOptions.currency) {
        final unit = elOptions.currencyInfo.mainUnitPlural ??
            elOptions.currencyInfo.mainUnitSingular;
        return "$_zero $unit"; // e.g., "μηδέν ευρώ"
      }
      return _zero; // "μηδέν"
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    // Dispatch based on format.
    if (elOptions.format == Format.year) {
      // Year conversion handles negative sign internally.
      textResult = _handleYearFormat(
        decimalValue.truncate().toBigInt().toInt(),
        elOptions,
        isNegative, // Pass original sign for suffix logic.
      );
    } else {
      if (elOptions.currency) {
        textResult = _handleCurrency(absValue, elOptions);
      } else {
        // Check if it's an integer after normalization (e.g., 123.0).
        if (absValue.isInteger) {
          textResult = _convertInteger(absValue.toBigInt(),
              isFeminine: false, isThousandPluralOverride: false);
        } else {
          textResult = _handleStandardNumber(absValue, elOptions);
        }
      }
      // Prepend negative prefix if needed (and not already handled by year format).
      if (isNegative) textResult = "${elOptions.negativePrefix} $textResult";
    }

    // Final cleanup (multiple spaces might occur during assembly).
    return textResult.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Converts a non-negative integer into Greek words, handling scales and gender.
  ///
  /// Breaks the number into 3-digit chunks, converts them using [_convertChunk]
  /// with appropriate gender (feminine for thousands scale), adds scale words,
  /// and combines them.
  ///
  /// @param n The non-negative integer.
  /// @param isFeminine Contextual gender requirement (primarily for thousands).
  /// @param isThousandPluralOverride Forces "χιλιάδες" for 1000 (used in years >= 2000).
  /// @return The integer as Greek words.
  /// @throws ArgumentError if `n` is negative or too large for defined scales.
  String _convertInteger(
    BigInt n, {
    required bool
        isFeminine, // Should the lowest chunk potentially use feminine 1,3,4?
    required bool isThousandPluralOverride, // Force plural "χιλιάδες" for 1000?
  }) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");

    // Handle base case < 1000.
    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt(), isFeminine: isFeminine);
    }

    List<String> parts =
        []; // Stores converted parts ("πέντε χιλιάδες", "διακόσια τριάντα")
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0; // 0=units, 1=thousands, 2=millions,...
    BigInt remaining = n;

    while (remaining > BigInt.zero) {
      int chunk = (remaining % oneThousand).toInt(); // Current 3 digits.
      remaining ~/= oneThousand;

      if (chunk > 0) {
        // Determine if the current scale requires feminine agreement for the preceding number.
        bool scaleRequiresFeminine = false;
        if (scaleIndex > 0 && _scaleWords.containsKey(scaleIndex)) {
          // Check the boolean flag in _scaleWords definition.
          scaleRequiresFeminine =
              _scaleWords[scaleIndex]![2] as bool; // Only true for thousands.
        }

        // Convert the chunk, applying feminine forms if the scale requires it.
        String chunkText =
            _convertChunk(chunk, isFeminine: scaleRequiresFeminine);

        String scaleWord =
            ""; // The scale word itself (e.g., "χιλιάδες", "εκατομμύριο").
        if (scaleIndex > 0) {
          // If we are beyond the units scale.
          if (!_scaleWords.containsKey(scaleIndex)) {
            throw ArgumentError(
                "Number too large, scale index $scaleIndex not defined.");
          }
          final scaleInfo = _scaleWords[scaleIndex]!;
          final String singularScale = scaleInfo[0] as String;
          final String pluralScale = scaleInfo[1] as String;

          // Special handling for Thousands (scaleIndex 1).
          if (scaleIndex == 1) {
            if (chunk == 1) {
              // For 1000: Use "χιλιάδες" if overridden (years>=2000), else "χίλια".
              // Omit the "ένα"/"μία" part.
              scaleWord =
                  isThousandPluralOverride ? pluralScale : singularScale;
              chunkText = ""; // Remove the "ένα"/"μία" from chunkText.
            } else {
              // For 2000, 3000, etc.: Always use plural "χιλιάδες".
              scaleWord = pluralScale;
            }
          } else {
            // For Millions, Billions, etc. (scaleIndex > 1).
            // Use singular scale word if chunk is 1, plural otherwise.
            scaleWord = (chunk == 1) ? singularScale : pluralScale;
            // Keep the "ένα" for "ένα εκατομμύριο" etc. if chunk is 1.
            // If chunk is 1, ensure it's neuter "ένα" not feminine "μία".
            if (chunk == 1) {
              chunkText =
                  _convertChunk(1, isFeminine: false); // Force neuter 'ένα'.
            }
          }
        }

        // Combine chunk text and scale word.
        String part = "";
        if (chunkText.isNotEmpty && scaleWord.isNotEmpty)
          part = "$chunkText $scaleWord";
        else if (chunkText.isNotEmpty)
          part = chunkText;
        else if (scaleWord.isNotEmpty) part = scaleWord;

        // Add the combined part to the beginning of the list.
        if (part.isNotEmpty) parts.add(part);
      }
      scaleIndex++;
    }

    // Join parts from largest scale down, cleaning up spaces.
    return parts.reversed.join(' ');
  }

  /// Formats an integer year in Greek with optional era suffixes.
  ///
  /// Converts the year value. Uses plural "χιλιάδες" for years >= 2000.
  /// Appends "π.Χ." (BC) or "μ.Χ." (AD) based on sign and [ElOptions.includeAD].
  ///
  /// @param yearValue The integer year.
  /// @param options The [ElOptions].
  /// @param isNegativeYear Whether the original number was negative (for BC suffix).
  /// @return The year as Greek words.
  String _handleYearFormat(
      int yearValue, ElOptions options, bool isNegativeYear) {
    if (yearValue == 0) return _zero;
    final int absYear = yearValue.abs();
    final BigInt bigAbsYear = BigInt.from(absYear);

    // Convert year value. Years generally use neuter forms, but force plural
    // 'χιλιάδες' for years 2000 and above for common pronunciation.
    String yearText = _convertInteger(
      bigAbsYear,
      isFeminine: false, // Base is neuter.
      isThousandPluralOverride:
          absYear >= 2000, // Force plural thousands for >= 2000.
    );

    // Append era suffixes.
    if (isNegativeYear)
      yearText += " $_yearSuffixBC";
    else if (options.includeAD)
      yearText += " $_yearSuffixAD"; // Only add AD if requested.

    return yearText;
  }

  /// Formats a non-negative [Decimal] as Greek currency (Euro/Lepta).
  ///
  /// Handles rounding, unit separation, uses basic singular/plural forms from
  /// [CurrencyInfo], and combines parts with "και" (or custom separator).
  /// Assumes main/sub units are Neuter unless specified otherwise via options.
  ///
  /// @param absValue The absolute currency value.
  /// @param options The [ElOptions] with currency info.
  /// @return The currency value as Greek words.
  String _handleCurrency(Decimal absValue, ElOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    const int decimalPlaces = 2;
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round if requested.
    Decimal valueToConvert =
        options.round ? absValue.round(scale: decimalPlaces) : absValue;

    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert -
        Decimal.fromInt(
            mainValue.toInt()); // Ensure compatibility if using `toInt()`
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round(scale: 0).toBigInt();

    String mainPart = '';
    String subunitPart = '';

    // Convert main unit part (e.g., Euro - Neuter).
    if (mainValue > BigInt.zero) {
      // Assume Neuter gender unless specified otherwise.
      String mainText = _convertInteger(mainValue,
          isFeminine: false, isThousandPluralOverride: false);
      // Use plural form if value != 1. Fallback to singular if plural is null.
      String mainUnitName = (mainValue == BigInt.one)
          ? currencyInfo.mainUnitSingular
          : (currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular);
      mainPart = '$mainText $mainUnitName';
    }

    // Convert subunit part (e.g., Lepta - Neuter).
    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      // Assume Neuter gender.
      String subunitText = _convertInteger(subunitValue,
          isFeminine: false, isThousandPluralOverride: false);
      // Use plural form if value != 1. Fallback to singular.
      String subUnitName = (subunitValue == BigInt.one)
          ? currencyInfo.subUnitSingular!
          : (currencyInfo.subUnitPlural ?? currencyInfo.subUnitSingular!);
      subunitPart = '$subunitText $subUnitName';
    }

    // Combine parts.
    if (mainPart.isNotEmpty && subunitPart.isNotEmpty) {
      String separator =
          currencyInfo.separator ?? _and; // Default separator "και".
      return '$mainPart $separator $subunitPart';
    } else if (mainPart.isNotEmpty) {
      return mainPart;
    } else if (subunitPart.isNotEmpty) {
      // Handle 0.xx amounts.
      return subunitPart;
    } else {
      // Handle zero amount (after potential rounding). Use plural main unit.
      return "$_zero ${currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular}";
    }
  }

  /// Converts a non-negative standard non-integer [Decimal] number into Greek words.
  ///
  /// Handles integer part (default neuter). Fractional part is read digit-by-digit
  /// after the separator ("κόμμα" or "τελεία"). Removes trailing zeros from display.
  /// Assumes `absValue.isInteger` was checked before calling.
  ///
  /// @param absValue The absolute non-integer decimal value.
  /// @param options The [ElOptions] with decimal separator preference.
  /// @return The number as Greek words.
  String _handleStandardNumber(Decimal absValue, ElOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart =
        absValue - Decimal.fromInt(integerPart.toInt()); // Ensure compatibility

    // Convert integer part (Neuter default). Handle 0.x cases.
    String integerWords = (integerPart == BigInt.zero)
        ? _zero
        : _convertInteger(integerPart,
            isFeminine: false, isThousandPluralOverride: false);

    String fractionalWords = '';
    // Fractional part should be > 0 here because isInteger check failed earlier.
    if (fractionalPart > Decimal.zero) {
      // Choose separator word.
      String separatorWord =
          (options.decimalSeparator ?? DecimalSeparator.comma) ==
                  DecimalSeparator.comma
              ? _comma // "κόμμα"
              : _point; // "τελεία"

      // Get fractional digits string, remove leading "0.", remove trailing zeros.
      String fractionalStr = fractionalPart.toString();
      if (fractionalStr.startsWith('0.'))
        fractionalStr = fractionalStr.substring(2);
      else if (fractionalStr.contains('.'))
        fractionalStr = fractionalStr.split('.').last;
      fractionalStr = fractionalStr.replaceAll(RegExp(r'0+$'), '');

      if (fractionalStr.isNotEmpty) {
        // Convert digits to words (using default neuter forms).
        List<String> digitWords = fractionalStr.split('').map((digit) {
          if (RegExp(r'^[0-9]$').hasMatch(digit)) {
            return _wordsUnder20[int.parse(digit)];
          }
          return '?'; // Should not happen with valid Decimal.
        }).toList();

        if (digitWords.isNotEmpty && !digitWords.contains('?')) {
          fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
        }
      }
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts an integer chunk (0-999) into Greek words, applying gender if required.
  ///
  /// Handles hundreds (including "εκατόν" form), tens, and units (1-19).
  /// Uses feminine forms for 1, 3, 4 if `isFeminine` is true.
  ///
  /// @param numberChunk The chunk (0-999).
  /// @param isFeminine If true, uses feminine forms for 1, 3, 4.
  /// @return The chunk as Greek words. Returns empty string for 0.
  /// @throws ArgumentError if `numberChunk` is outside 0-999.
  String _convertChunk(int numberChunk, {required bool isFeminine}) {
    if (numberChunk == 0) return "";
    if (numberChunk < 0 || numberChunk >= 1000) {
      throw ArgumentError("Chunk must be 0-999: $numberChunk");
    }

    List<String> words = [];
    int currentRemainder = numberChunk;

    // Handle hundreds.
    int hundredsDigit = currentRemainder ~/ 100;
    if (hundredsDigit > 0) {
      int remainderAfterHundreds = currentRemainder % 100;
      if (hundredsDigit == 1) {
        // Use "εκατόν" if followed by non-zero remainder, else "εκατό".
        words.add(remainderAfterHundreds == 0
            ? _hundredSingular
            : _hundredSingularPrefix);
      } else {
        // Use appropriate gendered form for 200-900.
        words.add(isFeminine
            ? _wordsHundredsFeminine[hundredsDigit]
            : _wordsHundredsNeuter[hundredsDigit]);
      }
      currentRemainder = remainderAfterHundreds; // Update remainder.
    }

    // Handle tens and units (1-99).
    if (currentRemainder > 0) {
      if (currentRemainder < 20) {
        // 1-19: Use feminine map if needed, else default list.
        String word =
            isFeminine && _wordsUnder20Feminine.containsKey(currentRemainder)
                ? _wordsUnder20Feminine[currentRemainder]!
                : _wordsUnder20[currentRemainder];
        words.add(word);
      } else {
        // 20-99: Combine tens and units.
        int tensDigit = currentRemainder ~/ 10;
        int unitDigit = currentRemainder % 10;
        words.add(_wordsTens[tensDigit]); // Tens word (e.g., "είκοσι").
        if (unitDigit > 0) {
          // Unit word: Apply feminine if needed.
          String unitWord =
              isFeminine && _wordsUnder20Feminine.containsKey(unitDigit)
                  ? _wordsUnder20Feminine[unitDigit]!
                  : _wordsUnder20[unitDigit];
          words.add(unitWord);
        }
      }
    }
    return words.join(' '); // Join parts ("διακόσια", "τριάντα", "πέντε").
  }
}
