import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/es_options.dart'; // Options specific to Spanish formatting.
import '../utils/utils.dart';

/// {@template num2text_es}
/// The Spanish language (`Lang.ES`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Spanish word representation following standard Spanish grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [EsOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers using the
/// long scale system (billón = 10^12). It handles Spanish grammatical rules, including
/// gender agreement ("un" vs "uno") before `mil` and scale words like `millón`.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [EsOptions].
/// {@endtemplate}
class Num2TextES implements Num2TextBase {
  // --- Constants ---

  /// The word for the number zero.
  static const String _zero = "cero";

  /// The word for the decimal separator when a period (`.`) is used.
  static const String _point = "punto";

  /// The word for the decimal separator when a comma (`,`) is used (default for Spanish).
  static const String _comma = "coma";

  /// The conjunction "y" used between tens and units for numbers 31-99 (e.g., "treinta y uno").
  static const String _and = "y";

  /// The word used to separate the main currency unit from the subunit (e.g., "euros con céntimos").
  /// Defined in [CurrencyInfo.separator], defaults to "con".
  static const String _currencySeparator = "con";

  /// The word for exactly one hundred ("cien").
  static const String _hundredSingular = "cien";

  /// The prefix used for numbers between 101 and 199 ("ciento").
  static const String _hundredPrefix = "ciento";

  /// The word for thousand ("mil"). Note: It doesn't pluralize as "miles" when directly following a number.
  static const String _thousand = "mil";

  /// The suffix for negative years, meaning "Before Christ" ("Antes de Cristo").
  static const String _yearSuffixBC = "a.C.";

  /// The suffix for positive years, meaning "After Christ" ("después de Cristo").
  /// Added only if [EsOptions.includeAD] is true.
  static const String _yearSuffixAD = "d.C.";

  /// Word forms for numbers 0 through 29.
  static const List<String> _wordsUnder30 = [
    "cero", // 0
    "uno", // 1
    "dos", // 2
    "tres", // 3
    "cuatro", // 4
    "cinco", // 5
    "seis", // 6
    "siete", // 7
    "ocho", // 8
    "nueve", // 9
    "diez", // 10
    "once", // 11
    "doce", // 12
    "trece", // 13
    "catorce", // 14
    "quince", // 15
    "dieciséis", // 16
    "diecisiete", // 17
    "dieciocho", // 18
    "diecinueve", // 19
    "veinte", // 20
    "veintiuno", // 21
    "veintidós", // 22
    "veintitrés", // 23
    "veinticuatro", // 24
    "veinticinco", // 25
    "veintiséis", // 26
    "veintisiete", // 27
    "veintiocho", // 28
    "veintinueve", // 29
  ];

  /// Word forms for tens from 30 to 90. Indices 3-9 correspond to 30-90.
  static const List<String> _wordsTens = [
    "", // 0 - Not used directly
    "", // 10 - Covered by _wordsUnder30
    "", // 20 - Covered by _wordsUnder30
    "treinta", // 30
    "cuarenta", // 40
    "cincuenta", // 50
    "sesenta", // 60
    "setenta", // 70
    "ochenta", // 80
    "noventa", // 90
  ];

  /// Word forms for hundreds from 200 to 900. Indices 2-9 correspond to 200-900.
  /// Note: 100 ("cien") and 1xx ("ciento") are handled specially.
  /// These forms agree in gender (e.g., "doscientas" if needed, though this implementation primarily handles masculine/neutral).
  static const List<String> _wordsHundreds = [
    "", // 0 - Not used directly
    "", // 100 - Handled by _hundredSingular / _hundredPrefix
    "doscientos", // 200
    "trescientos", // 300
    "cuatrocientos", // 400
    "quinientos", // 500
    "seiscientos", // 600
    "setecientos", // 700
    "ochocientos", // 800
    "novecientos", // 900
  ];

  /// Defines scale words (thousand, million, billion, etc.) using the **long scale** system.
  /// In the long scale:
  /// - Millón = 10^6
  /// - Billón = 10^12 (a million million)
  /// - Trillón = 10^18 (a million billion)
  /// Key: Scale index (0=units, 1=thousand, 2=million, 3=billion...).
  /// Value: List containing `[singular form, plural form]`.
  static const Map<int, List<String>> _scaleWords = {
    // 0: ["", ""], // Units group - no explicit scale word
    1: [
      "mil",
      "mil"
    ], // Thousands (10^3) - Singular and plural are the same here
    2: ["millón", "millones"], // Millions (10^6)
    3: ["billón", "billones"], // Billions (10^12 - Long Scale)
    4: ["trillón", "trillones"], // Trillions (10^18 - Long Scale)
    5: ["cuatrillón", "cuatrillones"], // Quadrillions (10^24 - Long Scale)
    // Further scales (quintillón, sextillón...) can be added if needed.
  };

  // --- Core Conversion Method ---

  /// {@macro num2text_base_process}
  /// Converts the given [number] into its Spanish word representation.
  ///
  /// Handles `int`, `double`, `BigInt`, `Decimal`, and numeric `String` inputs.
  /// Uses [EsOptions] to customize behavior like currency formatting ([EsOptions.currency], [EsOptions.currencyInfo]),
  /// year formatting ([Format.year]), decimal separator ([EsOptions.decimalSeparator]),
  /// and negative prefix ([EsOptions.negativePrefix]).
  /// If `options` is not an instance of [EsOptions], default settings are used.
  ///
  /// Returns the word representation (e.g., "ciento veintitrés", "menos diez con cincuenta céntimos").
  /// If the input is invalid (`null`, `NaN`, `Infinity`, non-numeric string), it returns
  /// [fallbackOnError] if provided, otherwise a default error message like "No es un número".
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have Spanish-specific options, using defaults if none are provided.
    final EsOptions esOptions =
        options is EsOptions ? options : const EsOptions();

    // Handle special non-finite double values early.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? "Menos Infinito" : "Infinito";
      }
      if (number.isNaN) {
        return fallbackOnError ?? "No es un número"; // Not a Number
      }
    }

    // Normalize the input to a Decimal for precise calculations.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Return error if normalization failed (invalid input type or format).
    if (decimalValue == null) {
      return fallbackOnError ?? "No es un número"; // Invalid input
    }

    // Handle the specific case of zero.
    if (decimalValue == Decimal.zero) {
      if (esOptions.currency) {
        // Currency format usually uses plural for zero amount (e.g., "cero euros").
        final String unitName = esOptions.currencyInfo.mainUnitPlural ??
            esOptions.currencyInfo
                .mainUnitSingular; // Fallback to singular if plural is null.
        return "$_zero $unitName";
      } else {
        return _zero; // Standard "cero". Also covers the rare case of year 0.
      }
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for the core conversion logic.
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // --- Dispatch based on format options ---
    if (esOptions.format == Format.year) {
      // Year format needs the original integer value (positive or negative).
      // Years are treated as cardinal numbers, no "un" shortening.
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), esOptions);
      // Note: Negative sign is handled by appending BC/AD, not the standard negative prefix.
    } else {
      // Handle currency or standard number format for the absolute value.
      if (esOptions.currency) {
        textResult = _handleCurrency(absValue, esOptions);
      } else {
        textResult = _handleStandardNumber(absValue, esOptions);
      }
      // Prepend the negative prefix *only* if it's a standard number or currency, not a year.
      if (isNegative) {
        textResult = "${esOptions.negativePrefix} $textResult";
      }
    }

    return textResult;
  }

  // --- Specific Format Handlers ---

  /// Formats an integer as a calendar year, optionally adding BC/AD suffixes.
  ///
  /// Years are converted as cardinal numbers (no "un" shortening).
  /// [year]: The integer year value (can be negative for BC).
  /// [options]: Spanish options, specifically checks `includeAD`.
  /// Returns the year in words, e.g., "mil novecientos noventa y nueve", "quinientos a.C.".
  String _handleYearFormat(int year, EsOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;

    // Handle year 0, although unusual in standard calendars.
    if (absYear == 0) return _zero; // Or potentially a specific error/message?

    // Convert the absolute year value. Years do not use "un" shortening.
    // Therefore, isScaleContext is set to false.
    String yearText =
        _convertInteger(BigInt.from(absYear), isScaleContext: false);

    // Append era suffixes based on the year's sign and options.
    if (isNegative) {
      yearText += " $_yearSuffixBC"; // Always add "a.C." for negative years.
    } else if (options.includeAD) {
      // Add "d.C." for positive years *only if* requested via options.
      yearText += " $_yearSuffixAD";
    }

    return yearText;
  }

  /// Formats a [Decimal] value as a currency amount in words.
  ///
  /// Handles main units and subunits based on [EsOptions.currencyInfo].
  /// Applies rounding if [EsOptions.round] is true.
  /// Uses "un" shortening before the currency unit if applicable.
  /// [absValue]: The non-negative currency amount.
  /// [options]: Spanish options containing currency details and rounding preference.
  /// Returns the currency amount in words, e.g., "un euro con cincuenta céntimos".
  String _handleCurrency(Decimal absValue, EsOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    // Assume 2 decimal places for subunits (e.g., cents), common for most currencies.
    const int decimalPlaces = 2;
    final Decimal subunitMultiplier =
        Decimal.ten.pow(decimalPlaces).toDecimal(); // 100

    // Apply rounding to the specified decimal places if requested.
    final Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate the integer (main unit) and fractional (subunit) parts.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Calculate the subunit value as an integer (e.g., 0.50 becomes 50).
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).truncate().toBigInt();

    // Convert the main unit integer part to words.
    // Use scale context (true) because the number precedes the currency unit name, requiring "un" shortening if applicable.
    final String mainText = _convertInteger(mainValue, isScaleContext: true);

    // Determine the correct main unit name (singular or plural).
    final String mainUnitName = (mainValue == BigInt.one)
        ? currencyInfo.mainUnitSingular
        : (currencyInfo.mainUnitPlural ??
            currencyInfo
                .mainUnitSingular); // Fallback to singular if plural is null

    // Start building the result string with the main unit part.
    String result = '$mainText $mainUnitName';

    // Add the subunit part if it exists (value > 0) and subunit names are defined.
    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      // Convert the subunit integer part to words.
      // Use scale context (true) as it precedes the subunit name.
      final String subunitText =
          _convertInteger(subunitValue, isScaleContext: true);

      // Determine the correct subunit name (singular or plural).
      final String subUnitName = (subunitValue == BigInt.one)
          ? currencyInfo.subUnitSingular! // Not null asserted above
          : (currencyInfo.subUnitPlural ??
              currencyInfo.subUnitSingular!); // Fallback to singular

      // Get the separator word (e.g., "con") from currency info or use the default.
      final String separator = currencyInfo.separator ?? _currencySeparator;

      // Append the separator and the subunit part.
      result += ' $separator $subunitText $subUnitName';
    }

    return result;
  }

  /// Formats a standard [Decimal] number (non-currency, non-year) into words.
  ///
  /// Handles both the integer and fractional parts.
  /// The fractional part is read digit by digit after the separator word ("coma" or "punto").
  /// Standard numbers typically do not use "un" shortening.
  /// [absValue]: The non-negative number.
  /// [options]: Spanish options, used for `decimalSeparator`.
  /// Returns the number in words, e.g., "ciento veintitrés coma cuatro cinco seis".
  String _handleStandardNumber(Decimal absValue, EsOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part. Use "cero" if integer part is zero but there's a fractional part.
    // Standard numbers usually don't need scale context (false), so "uno" is used.
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero // Handle cases like 0.5 -> "cero coma cinco"
            : _convertInteger(integerPart, isScaleContext: false);

    String fractionalWords = '';
    // Process fractional part only if it's greater than zero.
    if (fractionalPart > Decimal.zero) {
      // Determine the decimal separator word based on options.
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          separatorWord = _point;
          break;
        case DecimalSeparator.comma:
        default: // Default to "coma" for Spanish.
          separatorWord = _comma;
          break;
      }

      // Get the digits after the decimal point from the string representation.
      // Using toString ensures we get the intended digits (e.g., "0.123" -> "123").
      final String fractionalString = absValue.toString();
      final int decimalPointIndex = fractionalString.indexOf('.');
      final String fractionalDigits = (decimalPointIndex != -1)
          ? fractionalString.substring(decimalPointIndex + 1)
          : ''; // Should always have digits if fractionalPart > 0

      // Convert each digit character to its word form.
      final List<String> digitWords =
          fractionalDigits.split('').map((digitChar) {
        final int? digitInt = int.tryParse(digitChar);
        // Map the digit to its word using _wordsUnder30.
        return (digitInt != null && digitInt >= 0 && digitInt <= 9)
            ? _wordsUnder30[digitInt]
            : '?'; // Placeholder for unexpected non-digit characters
      }).toList();

      // Combine the separator word and the individual digit words.
      fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
    }

    // Combine integer and fractional parts. Use trim to avoid leading/trailing spaces.
    return '$integerWords$fractionalWords'.trim();
  }

  // --- Integer Conversion Helpers ---

  /// Converts a non-negative [BigInt] integer into its Spanish word representation.
  /// This is the main recursive function for handling potentially large integers.
  /// It breaks the number down into chunks of millions and uses scale words.
  ///
  /// [n]: The non-negative integer to convert. Must not be negative.
  /// [isScaleContext]: If `true`, indicates that the number precedes a scale word
  /// (`mil`, `millón`, etc.) or a currency unit, triggering the "un"/"veintiún" shortening.
  /// This flag is propagated down to helper methods.
  /// Returns the integer in words, e.g., "un millón doscientos mil trescientos cuarenta y cinco".
  String _convertInteger(BigInt n, {required bool isScaleContext}) {
    if (n == BigInt.zero) return _zero;
    // Ensure input is non-negative as negative sign is handled elsewhere.
    if (n < BigInt.zero) {
      // This should ideally not be reached due to prior checks.
      throw ArgumentError("Input must be non-negative for _convertInteger: $n");
    }

    // Base case: Numbers less than 1000 are handled directly.
    if (n < BigInt.from(1000)) {
      // Pass the scale context down.
      return _convertChunk(n.toInt(), isScaleContext: isScaleContext);
    }

    final List<String> parts = []; // Stores word parts for each scale level.
    BigInt remaining = n;
    // Process the number in chunks of millions (1,000,000) to handle scale words correctly.
    final BigInt oneMillion = BigInt.from(1000000);

    // --- Process the first chunk (0 - 999,999) ---
    // This represents the units and thousands part of the lowest million block.
    final BigInt baseChunk = remaining % oneMillion;
    remaining ~/= oneMillion; // Move to the millions part.

    // Convert the base chunk if it's non-zero OR if it's the only part of the number.
    if (baseChunk > BigInt.zero || n < oneMillion) {
      // Determine if this base chunk itself needs the 'un' shortening.
      // This happens only if:
      // 1. The overall context requires shortening (`isScaleContext` is true).
      // 2. This is the *last* chunk being processed (`remaining` is zero).
      final bool chunkNeedsUn = isScaleContext && remaining == BigInt.zero;
      parts.add(
          _convertGroupOfThousands(baseChunk, isScaleContext: chunkNeedsUn));
    }

    // --- Process subsequent chunks (Millions, Billions, Trillions...) ---
    int scaleIndex = 2; // Start with millions (index 2 in _scaleWords).
    while (remaining > BigInt.zero) {
      // Get the next chunk of up to 999,999 for the current scale level.
      final BigInt scaleChunkValue = remaining % oneMillion;
      remaining ~/= oneMillion; // Move to the next higher scale.

      if (scaleChunkValue > BigInt.zero) {
        // Convert the numeric part of this scale chunk.
        // Always use scale context `true` here because this number precedes
        // a scale word (e.g., "un millón", "doscientos mil billones").
        final String chunkText =
            _convertGroupOfThousands(scaleChunkValue, isScaleContext: true);

        // Get the appropriate scale word (singular or plural).
        if (_scaleWords.containsKey(scaleIndex)) {
          final scaleNames = _scaleWords[scaleIndex]!;
          // Use singular scale word ("millón") if chunk value is 1, plural ("millones") otherwise.
          final String scaleWord =
              (scaleChunkValue == BigInt.one) ? scaleNames[0] : scaleNames[1];
          // Combine the number words and the scale word.
          parts.add("$chunkText $scaleWord");
        } else {
          // Handle scales larger than explicitly defined (e.g., thousands of the previous scale).
          // Example: 10^27 would be "mil cuatrillones" (thousand quadrillion).
          final int prevScaleIndex = scaleIndex - 1;
          if (_scaleWords.containsKey(prevScaleIndex)) {
            final prevScaleNames = _scaleWords[prevScaleIndex]!;
            // Combine with "mil" and the plural of the *previous* defined scale.
            parts.add("$chunkText mil ${prevScaleNames[1]}");
          } else {
            // Safety check for extremely large numbers beyond defined scales.
            throw ArgumentError(
                "Number too large, scale index $scaleIndex not defined.");
          }
        }
      }
      scaleIndex++; // Increment to the next scale (billón, trillón...).
    }

    // Join the parts in reverse order (most significant scale first) with spaces.
    return parts.reversed.join(' ').trim();
  }

  /// Converts a number between 0 and 999,999 into words.
  /// It internally splits the number into a thousands part and a units part (0-999).
  ///
  /// [n]: The number to convert (must be 0 <= n < 1,000,000).
  /// [isScaleContext]: Propagated to `_convertChunk` for the units part *only if*
  /// the thousands part is zero. If there's a thousands part, the units part never needs 'un'.
  /// Returns the number in words, e.g., "doscientos mil trescientos", "mil uno".
  String _convertGroupOfThousands(BigInt n, {required bool isScaleContext}) {
    if (n == BigInt.zero)
      return ""; // Empty for zero within a larger number context.
    if (n < BigInt.zero || n >= BigInt.from(1000000)) {
      throw ArgumentError(
          "Input must be between 0 and 999,999 for _convertGroupOfThousands: $n");
    }

    // Split into thousands and the remaining units (0-999).
    final BigInt unitsPart = n % BigInt.from(1000);
    final BigInt thousandsPart = n ~/ BigInt.from(1000);

    String unitsText = "";
    if (unitsPart > BigInt.zero) {
      // The units part needs 'un' shortening *only if* the overall context requires it
      // AND there is no thousands part preceding it within this group.
      final bool unitsNeedUn = isScaleContext && thousandsPart == BigInt.zero;
      unitsText = _convertChunk(unitsPart.toInt(), isScaleContext: unitsNeedUn);
    }

    String thousandsText = "";
    if (thousandsPart > BigInt.zero) {
      if (thousandsPart == BigInt.one) {
        // Special case: "mil" (not "un mil").
        thousandsText = _thousand;
      } else {
        // Convert the number of thousands (e.g., "doscientos" for 200,000).
        // Always use scale context `true` because this number precedes "mil".
        final String thousandsNumText =
            _convertChunk(thousandsPart.toInt(), isScaleContext: true);
        thousandsText = "$thousandsNumText $_thousand";
      }
    }

    // Combine the thousands and units parts with a space if both exist.
    if (thousandsText.isNotEmpty && unitsText.isNotEmpty) {
      return "$thousandsText $unitsText";
    } else {
      // Otherwise, return whichever part is non-empty.
      return thousandsText.isNotEmpty ? thousandsText : unitsText;
    }
  }

  /// Converts a number between 0 and 999 into its Spanish word representation.
  /// This is the lowest-level chunk conversion.
  ///
  /// [n]: The number to convert (must be 0 <= n < 1000).
  /// [isScaleContext]: If `true`, 'uno' becomes 'un' and 'veintiuno' becomes 'veintiún'.
  /// This applies if this chunk precedes `mil`, a scale word (`millón`), or a currency unit.
  /// Returns the chunk in words, e.g., "ciento veintitrés", "noventa y nueve", "un".
  String _convertChunk(int n, {required bool isScaleContext}) {
    if (n == 0) return ""; // Empty string for zero in this context.
    if (n < 0 || n >= 1000) {
      throw ArgumentError(
          "Input must be between 0 and 999 for _convertChunk: $n");
    }

    // Handle exactly 100 separately ("cien").
    if (n == 100) return _hundredSingular;

    final List<String> words = []; // Stores word parts for this chunk.
    int remainder = n;

    // --- Process Hundreds ---
    final int hundredsDigit = remainder ~/ 100;
    if (hundredsDigit > 0) {
      if (hundredsDigit == 1) {
        // Use "ciento" for 101-199.
        words.add(_hundredPrefix);
      } else {
        // Use specific hundred words ("doscientos", "quinientos", etc.).
        // Gender agreement (e.g., 'doscientas') would be added here if needed based on context.
        words.add(_wordsHundreds[hundredsDigit]);
      }
      remainder %= 100; // Keep track of the remaining tens and units.
    }

    // --- Process Tens and Units (0-99) ---
    if (remainder > 0) {
      // Add a space if there was a hundreds part.
      if (words.isNotEmpty) {
        words.add(" ");
      }

      // Handle numbers less than 30 directly using the lookup table.
      if (remainder < 30) {
        String word = _wordsUnder30[remainder];
        // Apply "un"/"veintiún" shortening if needed based on context.
        if (remainder == 1 && isScaleContext) {
          word = "un"; // Apocope: "uno" -> "un"
        } else if (remainder == 21 && isScaleContext) {
          word = "veintiún"; // Apocope: "veintiuno" -> "veintiún"
        }
        words.add(word);
      } else {
        // Handle numbers 30-99.
        final int tensDigit = remainder ~/ 10;
        final int unitDigit = remainder % 10;

        // Add the tens word (e.g., "treinta", "noventa").
        words.add(_wordsTens[tensDigit]);

        // Add the unit word if present (e.g., for 31, 45), connecting with "y".
        if (unitDigit > 0) {
          words.add(" $_and ");
          String unitWord = _wordsUnder30[unitDigit];
          // Apply "un" shortening if needed for the unit part (only relevant for '1').
          if (unitDigit == 1 && isScaleContext) {
            unitWord = "un"; // Apocope: "uno" -> "un"
          }
          words.add(unitWord);
        }
      }
    }

    // Combine the collected word parts (hundreds, tens, units).
    return words.join();
  }
}
