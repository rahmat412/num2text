import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/es_options.dart';
import '../utils/utils.dart';

/// {@template num2text_es}
/// Converts numbers to Spanish words (`Lang.ES`).
///
/// Implements [Num2TextBase] for Spanish, handling various numeric types.
/// Features:
/// - Cardinal numbers (e.g., "ciento veintitrés").
/// - Decimal numbers (e.g., "cuarenta y cinco coma seis").
/// - Negative numbers (e.g., "menos diez").
/// - Currency formatting (e.g., "un euro con cincuenta céntimos").
/// - Year formatting (e.g., "mil novecientos noventa y nueve").
/// - Large numbers using the **long scale** (billón = 10^12).
/// - Spanish grammatical rules: gender agreement ("un"/"uno"), conjunction "y".
///
/// Customizable via [EsOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextES implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "cero";
  static const String _point = "punto"; // Decimal separator (.)
  static const String _comma =
      "coma"; // Decimal separator (,) - Spanish default
  static const String _and = "y"; // Conjunction (e.g., "treinta y uno")
  static const String _currencySeparator =
      "con"; // Default currency subunit separator
  static const String _hundredSingular = "cien"; // Exactly 100
  static const String _hundredPrefix = "ciento"; // Prefix for 101-199
  static const String _thousand =
      "mil"; // Thousand (doesn't pluralize as 'miles' here)
  static const String _yearSuffixBC = "a.C."; // Antes de Cristo (BC)
  static const String _yearSuffixAD = "d.C."; // después de Cristo (AD)

  /// Words for 0-29 (direct lookup).
  static const List<String> _wordsUnder30 = [
    "cero",
    "uno",
    "dos",
    "tres",
    "cuatro",
    "cinco",
    "seis",
    "siete",
    "ocho",
    "nueve",
    "diez",
    "once",
    "doce",
    "trece",
    "catorce",
    "quince",
    "dieciséis",
    "diecisiete",
    "dieciocho",
    "diecinueve",
    "veinte",
    "veintiuno",
    "veintidós",
    "veintitrés",
    "veinticuatro",
    "veinticinco",
    "veintiséis",
    "veintisiete",
    "veintiocho",
    "veintinueve",
  ];

  /// Words for 30, 40, ..., 90. Index 3 = treinta.
  static const List<String> _wordsTens = [
    "",
    "",
    "",
    "treinta",
    "cuarenta",
    "cincuenta",
    "sesenta",
    "setenta",
    "ochenta",
    "noventa",
  ];

  /// Words for 200, 300, ..., 900. Index 2 = doscientos. (100 handled separately)
  static const List<String> _wordsHundreds = [
    "",
    "",
    "doscientos",
    "trescientos",
    "cuatrocientos",
    "quinientos",
    "seiscientos",
    "setecientos",
    "ochocientos",
    "novecientos",
  ];

  /// Scale words (long scale system: millón=10^6, billón=10^12).
  /// Key: Scale index (power of 1,000,000 starting from index 2).
  /// Value: [Singular form, Plural form].
  static const Map<int, List<String>> _scaleWords = {
    // Index 0: units (no word)
    1: ["mil", "mil"], // Thousands (10^3) - handled specially
    2: ["millón", "millones"], // Millions (10^6)
    3: ["billón", "billones"], // Billions (10^12)
    4: ["trillón", "trillones"], // Trillions (10^18)
    5: ["cuatrillón", "cuatrillones"], // Quadrillions (10^24)
  };

  /// {@macro num2text_base_process}
  /// Converts [number] to Spanish words using [options].
  /// Handles `int`, `double`, `BigInt`, `Decimal`, numeric `String`.
  /// Returns Spanish text or [fallbackOnError] (default "No Es Un Número").
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final EsOptions esOptions =
        options is EsOptions ? options : const EsOptions();
    const String defaultError = "No Es Un Número";

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Menos Infinito" : "Infinito";
      if (number.isNaN) return fallbackOnError ?? defaultError;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return fallbackOnError ?? defaultError;

    if (decimalValue == Decimal.zero) {
      if (esOptions.currency) {
        final String unitName = esOptions.currencyInfo.mainUnitPlural ??
            esOptions.currencyInfo.mainUnitSingular;
        return "$_zero $unitName"; // e.g., "cero euros"
      }
      return _zero; // Standard "cero"
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    if (esOptions.format == Format.year) {
      // Year format handles negativity via BC/AD suffixes.
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), esOptions);
    } else {
      textResult = esOptions.currency
          ? _handleCurrency(absValue, esOptions)
          : _handleStandardNumber(absValue, esOptions);
      if (isNegative) {
        textResult =
            "${esOptions.negativePrefix} $textResult"; // Prepend "menos" etc.
      }
    }
    return textResult.trim(); // Clean up spaces
  }

  /// Converts an integer year to Spanish words, optionally adding BC/AD.
  ///
  /// Years use cardinal numbers (no "un" shortening).
  ///
  /// @param year The integer year (negative for BC).
  /// @param options Checks `includeAD` option.
  /// @return The year as Spanish words (e.g., "mil novecientos noventa y nueve").
  String _handleYearFormat(int year, EsOptions options) {
    if (year == 0) return _zero; // Handle year 0 numerically.

    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;

    // Years are read as standard numbers, no scale context needed (uses "uno", not "un").
    String yearText =
        _convertInteger(BigInt.from(absYear), isScaleContext: false);

    if (isNegative)
      yearText += " $_yearSuffixBC"; // Append "a.C."
    else if (options.includeAD)
      yearText += " $_yearSuffixAD"; // Append "d.C." if requested.

    return yearText;
  }

  /// Converts a non-negative [Decimal] to Spanish currency words.
  ///
  /// Uses [EsOptions.currencyInfo]. Rounds if [EsOptions.round].
  /// Applies "un" shortening before currency units. Handles main/subunits.
  /// If only subunits exist (e.g., 0.50), returns only the subunit part.
  ///
  /// @param absValue The absolute currency value.
  /// @param options Contains currency details and flags.
  /// @return Currency value as Spanish words (e.g., "un euro con cincuenta céntimos").
  String _handleCurrency(Decimal absValue, EsOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    const int decimalPlaces = 2;
    final Decimal subunitMultiplier =
        Decimal.ten.pow(decimalPlaces).toDecimal();

    final Decimal val =
        options.round ? absValue.round(scale: decimalPlaces) : absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    final BigInt subVal =
        ((val - Decimal.fromBigInt(mainVal)) * subunitMultiplier)
            .round(scale: 0)
            .toBigInt();

    String mainPart = '';
    if (mainVal > BigInt.zero) {
      // Use scale context true for potential 'un' before unit name.
      final String mainText = _convertInteger(mainVal, isScaleContext: true);
      final String mainUnit = (mainVal == BigInt.one)
          ? info.mainUnitSingular
          : (info.mainUnitPlural ?? info.mainUnitSingular);
      mainPart = '$mainText $mainUnit';
    }

    String subPart = '';
    if (subVal > BigInt.zero && info.subUnitSingular != null) {
      // Use scale context true for potential 'un' before subunit name.
      final String subText = _convertInteger(subVal, isScaleContext: true);
      final String subUnit = (subVal == BigInt.one)
          ? info.subUnitSingular!
          : (info.subUnitPlural ?? info.subUnitSingular!);
      subPart = '$subText $subUnit';
    }

    if (mainPart.isNotEmpty && subPart.isNotEmpty) {
      final String sep = info.separator ?? _currencySeparator; // Default "con"
      return '$mainPart $sep $subPart';
    } else if (mainPart.isNotEmpty)
      return mainPart;
    else if (subPart.isNotEmpty)
      return subPart; // Handle 0.xx case
    else
      return "$_zero ${info.mainUnitPlural ?? info.mainUnitSingular}"; // Zero case
  }

  /// Converts a non-negative standard [Decimal] number to Spanish words.
  ///
  /// Handles integer and fractional parts. Fractional part read digit by digit.
  /// Standard numbers generally don't use "un" shortening.
  ///
  /// @param absValue The absolute decimal value.
  /// @param options Used for `decimalSeparator`.
  /// @return Number as Spanish words (e.g., "ciento veintitrés coma cuatro cinco").
  String _handleStandardNumber(Decimal absValue, EsOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Use "cero" if integer is 0 but fraction exists. No scale context (use "uno").
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, isScaleContext: false);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      String sepWord; // Determine separator word.
      switch (options.decimalSeparator) {
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          sepWord = _point;
          break;
        default:
          sepWord = _comma;
          break; // Default "coma"
      }

      final String fracDigits = absValue.toString().split('.').last;
      final List<String> digitWords = fracDigits.split('').map((d) {
        final int? i = int.tryParse(d);
        return (i != null && i >= 0 && i <= 9) ? _wordsUnder30[i] : '?';
      }).toList();

      if (digitWords.isNotEmpty) {
        fractionalWords = ' $sepWord ${digitWords.join(' ')}';
      }
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a number from 0 to 999,999 into Spanish words.
  /// Helper for `_convertInteger` to handle the chunk within a million scale block.
  ///
  /// @param n The number (0-999,999).
  /// @param isScaleContext Propagated to `_convertChunk` for potential "un" shortening.
  /// @return The number chunk as Spanish words (e.g., "doscientos treinta mil cuatrocientos cincuenta y uno").
  String _convertGroupOfThousands(BigInt n, {required bool isScaleContext}) {
    if (n == BigInt.zero) return "";
    if (n < BigInt.zero || n >= BigInt.from(1000000)) {
      throw ArgumentError("Input must be 0-999,999: $n");
    }

    final BigInt unitsPart = n % BigInt.from(1000); // 0-999
    final BigInt thousandsPart = n ~/ BigInt.from(1000); // 0-999

    String unitsText = "";
    if (unitsPart > BigInt.zero) {
      // `isScaleContext` only matters if this is the final chunk overall.
      unitsText =
          _convertChunk(unitsPart.toInt(), isScaleContext: isScaleContext);
    }

    String thousandsText = "";
    if (thousandsPart > BigInt.zero) {
      if (thousandsPart == BigInt.one) {
        // Exactly 1000 is just "mil".
        thousandsText = _thousand;
      } else {
        // Numbers 2000+ require the number before "mil".
        // This preceding number *always* needs scale context for potential "un".
        final String thousandsNumText =
            _convertChunk(thousandsPart.toInt(), isScaleContext: true);
        thousandsText = "$thousandsNumText $_thousand";
      }
    }

    // Combine thousands and units parts.
    if (thousandsText.isNotEmpty && unitsText.isNotEmpty) {
      return "$thousandsText $unitsText";
    } else {
      return thousandsText.isNotEmpty ? thousandsText : unitsText;
    }
  }

  /// Converts a non-negative [BigInt] integer into Spanish words using the long scale.
  /// Main recursive function, breaks number into million-based chunks.
  ///
  /// @param n Non-negative integer.
  /// @param isScaleContext If true, the number precedes a scale word or currency unit, requiring "un"/"veintiún".
  /// @return Integer as Spanish words.
  String _convertInteger(BigInt n, {required bool isScaleContext}) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt(), isScaleContext: isScaleContext);
    }

    final List<String> parts = [];
    BigInt remaining = n;
    final BigInt oneMillion = BigInt.from(1000000);

    // Process the lowest chunk (0-999,999).
    final BigInt baseChunk = remaining % oneMillion;
    remaining ~/= oneMillion;

    if (baseChunk > BigInt.zero || n < oneMillion) {
      // Needs 'un' shortening only if overall context requires it AND this is the last chunk.
      final bool chunkNeedsUn = isScaleContext && remaining == BigInt.zero;
      parts.add(
          _convertGroupOfThousands(baseChunk, isScaleContext: chunkNeedsUn));
    }

    // Process higher scales (Millions, Billions...).
    int scaleIndex = 2; // Start at millions.
    while (remaining > BigInt.zero) {
      final BigInt scaleChunkValue = remaining % oneMillion;
      remaining ~/= oneMillion;

      if (scaleChunkValue > BigInt.zero) {
        // Number part always needs scale context true as it precedes a scale word.
        final String chunkText =
            _convertGroupOfThousands(scaleChunkValue, isScaleContext: true);

        if (_scaleWords.containsKey(scaleIndex)) {
          final scaleNames = _scaleWords[scaleIndex]!; // [singular, plural]
          final String scaleWord =
              (scaleChunkValue == BigInt.one) ? scaleNames[0] : scaleNames[1];
          parts.add("$chunkText $scaleWord");
        } else {
          // Handle scales beyond defined limits (e.g., thousands of the previous scale).
          final int prevScaleIndex = scaleIndex - 1;
          if (_scaleWords.containsKey(prevScaleIndex)) {
            final prevScaleNames = _scaleWords[prevScaleIndex]!;
            // e.g., "mil cuatrillones"
            parts.add("$chunkText mil ${prevScaleNames[1]}");
          } else {
            throw ArgumentError(
                "Number too large, scale index $scaleIndex not defined.");
          }
        }
      }
      scaleIndex++; // Move to next scale (billón, trillón...).
    }

    // Join parts from highest scale down.
    return parts.reversed.join(' ').trim();
  }

  /// Converts a number between 0 and 999 into Spanish words. Lowest level conversion.
  /// Applies 'un'/'veintiún' shortening if `isScaleContext` is true.
  ///
  /// @param n The number (0-999).
  /// @param isScaleContext If true, applies shortening ("uno" -> "un", "veintiuno" -> "veintiún").
  /// @return The chunk as Spanish words (e.g., "ciento veintitrés", "un"). Returns "" for 0.
  String _convertChunk(int n, {required bool isScaleContext}) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");
    if (n == 100) return _hundredSingular; // "cien"

    final List<String> words = [];
    int remainder = n;

    // Hundreds part
    final int hundredsDigit = remainder ~/ 100;
    if (hundredsDigit > 0) {
      words.add(hundredsDigit == 1
          ? _hundredPrefix
          : _wordsHundreds[hundredsDigit]); // "ciento" or "doscientos"...
      remainder %= 100;
      if (remainder > 0) words.add(" "); // Add space if tens/units follow
    }

    // Tens and units part (0-99)
    if (remainder > 0) {
      if (remainder < 30) {
        String word = _wordsUnder30[remainder];
        // Apply shortening ("apócope") if context requires it.
        if (remainder == 1 && isScaleContext)
          word = "un";
        else if (remainder == 21 && isScaleContext) word = "veintiún";
        words.add(word);
      } else {
        // 30-99
        final int tensDigit = remainder ~/ 10;
        final int unitDigit = remainder % 10;
        words.add(_wordsTens[tensDigit]); // "treinta", "cuarenta"...
        if (unitDigit > 0) {
          words.add(" $_and "); // " y "
          String unitWord = _wordsUnder30[unitDigit];
          // Apply shortening only to '1' in this range.
          if (unitDigit == 1 && isScaleContext) unitWord = "un";
          words.add(unitWord);
        }
      }
    }
    return words
        .join(); // Join parts ("ciento", " ", "veinti", " ", "y", " ", "uno")
  }
}
