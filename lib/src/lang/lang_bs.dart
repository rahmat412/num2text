import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/bs_options.dart';
import '../utils/utils.dart';

/// Internal helper storing grammatical info for Bosnian nouns.
///
/// Required because nouns (scale words, currency units) change form (declension)
/// based on the preceding number according to Bosnian grammar rules.
class _NounInfo {
  /// Nominative Singular: Used for numbers ending in 1 (not 11). e.g., "1 marka".
  final String singular;

  /// Nominative Plural: Used for numbers ending in 2, 3, 4 (not 12, 13, 14). e.g., "2 marke".
  final String nominativePlural;

  /// Genitive Plural: Used for numbers ending in 0, 5-9, or 11-19. e.g., "5 maraka".
  final String genitivePlural;

  /// Grammatical gender ([Gender]): Influences the form of 'one' and 'two'.
  final Gender gender;

  /// Creates grammatical info container for a Bosnian noun.
  const _NounInfo({
    required this.singular,
    required this.nominativePlural,
    required this.genitivePlural,
    required this.gender,
  });
}

/// {@template num2text_bs}
/// Converts numbers into their Bosnian word representations (`Lang.BS`).
///
/// Implements [Num2TextBase] for Bosnian, handling various numeric types.
/// Features include:
/// *   Cardinal number conversion with correct noun declension and gender agreement.
/// *   Currency formatting (default BAM) via [BsOptions.currencyInfo].
/// *   Year formatting with optional era suffixes ("n. e." / "p. n. e.").
/// *   Decimal handling with configurable separators ("zarez" or "tačka").
/// *   Large number conversion using the long scale (milion, milijarda...).
/// *   Customization via [BsOptions].
/// *   Fallback messages for invalid inputs (default "Nije Broj").
/// {@endtemplate}
class Num2TextBS implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "nula";

  /// Default decimal separator "zarez" (comma), used for [DecimalSeparator.comma].
  static const String _defaultDecimalSeparatorWord = "zarez";

  /// Decimal separator "tačka" (point), used for [DecimalSeparator.period] or [DecimalSeparator.point].
  static const String _pointWord = "tačka";

  /// Suffix for BC years ("p. n. e." - Prije nove ere).
  static const String _yearSuffixBC = "p. n. e.";

  /// Suffix for AD years ("n. e." - Nove ere), used if [BsOptions.includeAD] is true.
  static const String _yearSuffixAD = "n. e.";
  static const String _infinity = "Beskonačnost";
  static const String _negativeInfinity = "Negativna Beskonačnost";
  static const String _notANumber = "Nije Broj"; // "Not a number"

  /// Words 0-19 (Masculine/Neuter forms for 1, 2).
  static const List<String> _wordsUnder20 = [
    _zero,
    "jedan",
    "dva",
    "tri",
    "četiri",
    "pet",
    "šest",
    "sedam",
    "osam",
    "devet",
    "deset",
    "jedanaest",
    "dvanaest",
    "trinaest",
    "četrnaest",
    "petnaest",
    "šesnaest",
    "sedamnaest",
    "osamnaest",
    "devetnaest",
  ];

  /// Words 0-19 (Feminine forms for 1, 2).
  static const List<String> _wordsUnder20Feminine = [
    _zero,
    "jedna",
    "dvije",
    "tri",
    "četiri",
    "pet",
    "šest",
    "sedam",
    "osam",
    "devet",
    "deset",
    "jedanaest",
    "dvanaest",
    "trinaest",
    "četrnaest",
    "petnaest",
    "šesnaest",
    "sedamnaest",
    "osamnaest",
    "devetnaest",
  ];

  /// Words for tens (20, 30... 90).
  static const List<String> _wordsTens = [
    "",
    "",
    "dvadeset",
    "trideset",
    "četrdeset",
    "pedeset",
    "šezdeset",
    "sedamdeset",
    "osamdeset",
    "devedeset",
  ];

  /// Words for hundreds (100, 200... 900).
  static const List<String> _wordsHundreds = [
    "",
    "sto",
    "dvjesto",
    "tristo",
    "četiristo",
    "petsto",
    "šeststo",
    "sedamsto",
    "osamsto",
    "devetsto",
  ];

  /// Grammatical info for "hiljada" (thousand - Feminine).
  static const _NounInfo _thousandInfo = _NounInfo(
    singular: "hiljadu", // 1 hiljadu (or often just 'hiljadu')
    nominativePlural: "hiljade", // 2,3,4 hiljade
    genitivePlural: "hiljada", // 0, 5+ hiljada
    gender: Gender.feminine,
  );

  /// Grammatical info for large scale words (long scale).
  /// Key: power of 10 (6=million, 9=milliard, 12=billion...).
  static final Map<int, _NounInfo> _scaleInfoMap = {
    6: const _NounInfo(
        singular: "milion",
        nominativePlural: "miliona",
        genitivePlural: "miliona",
        gender: Gender.masculine), // Million (M)
    9: const _NounInfo(
        singular: "milijarda",
        nominativePlural: "milijarde",
        genitivePlural: "milijardi",
        gender: Gender.feminine), // Milliard (F)
    12: const _NounInfo(
        singular: "bilion",
        nominativePlural: "biliona",
        genitivePlural: "biliona",
        gender: Gender.masculine), // Billion (M)
    15: const _NounInfo(
        singular: "bilijarda",
        nominativePlural: "bilijarde",
        genitivePlural: "bilijardi",
        gender: Gender.feminine), // Billiard (F)
    18: const _NounInfo(
        singular: "trilion",
        nominativePlural: "triliona",
        genitivePlural: "triliona",
        gender: Gender.masculine), // Trillion (M)
    21: const _NounInfo(
        singular: "trilijarda",
        nominativePlural: "trilijarde",
        genitivePlural: "trilijardi",
        gender: Gender.feminine), // Trilliard (F)
    24: const _NounInfo(
        singular: "kvadrilion",
        nominativePlural: "kvadriliona",
        genitivePlural: "kvadriliona",
        gender: Gender.masculine), // Quadrillion (M)
    // Add kvadrilijarda (F), kvintilion (M) etc. as needed
  };

  /// {@macro num2text_base_process}
  ///
  /// Processes the given [number] into Bosnian words.
  ///
  /// @param number The number to convert.
  /// @param options Optional [BsOptions] for customization.
  /// @param fallbackOnError Optional error string (defaults to "Nije Broj").
  /// @return The number as Bosnian words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final BsOptions bsOptions =
        options is BsOptions ? options : const BsOptions();
    final String errorMsg = fallbackOnError ?? _notANumber;

    // Handle non-finite doubles.
    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _negativeInfinity : _infinity;
      if (number.isNaN) return errorMsg;
    }

    // Normalize to Decimal.
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorMsg;

    // Handle zero.
    if (decimalValue == Decimal.zero) {
      if (bsOptions.currency) {
        final info = bsOptions.currencyInfo;
        // Zero amount takes Genitive Plural form of the main unit.
        final mainUnitForm = info.mainUnitPluralGenitive ??
            info.mainUnitPlural2To4 ??
            info.mainUnitSingular;
        return "$_zero $mainUnitForm"; // e.g., "nula maraka"
      }
      return _zero; // "nula"
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    // Dispatch based on format.
    if (bsOptions.format == Format.year) {
      // Year format handles negative internally.
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), bsOptions);
    } else {
      if (bsOptions.currency) {
        textResult = _handleCurrency(absValue, bsOptions);
      } else {
        textResult = _handleStandardNumber(absValue, bsOptions);
      }
      // Prepend negative prefix if needed.
      if (isNegative) textResult = "${bsOptions.negativePrefix} $textResult";
    }

    return textResult;
  }

  /// Selects the grammatically correct declined form of a noun based on the preceding number.
  ///
  /// Applies Bosnian rules:
  /// - Ends in 1 (not 11): singular.
  /// - Ends in 2, 3, 4 (not 12, 13, 14): nominative plural.
  /// - Ends in 0, 5-9, or 11-19: genitive plural.
  ///
  /// @param number The integer determining the noun form.
  /// @param info The [_NounInfo] with the noun's grammatical forms.
  /// @return The correctly declined noun string.
  String _getDeclinedForm(BigInt number, _NounInfo info) {
    if (number == BigInt.zero)
      return info.genitivePlural; // Zero uses Genitive Plural.

    int lastDigit = (number % BigInt.from(10)).toInt();
    int lastTwoDigits = (number % BigInt.from(100)).toInt();

    // Rule for 11-19: Genitive Plural.
    if (lastTwoDigits >= 11 && lastTwoDigits <= 19) return info.genitivePlural;
    // Rule for 1: Singular.
    if (lastDigit == 1) return info.singular;
    // Rule for 2, 3, 4: Nominative Plural.
    if (lastDigit >= 2 && lastDigit <= 4) return info.nominativePlural;
    // Rule for 0, 5-9: Genitive Plural.
    return info.genitivePlural;
  }

  /// Converts an integer chunk (0-999) into Bosnian words, applying gender agreement.
  ///
  /// @param n The chunk (0-999).
  /// @param gender The required [Gender] for 'one' and 'two'. Defaults to masculine/neuter.
  /// @return The chunk as Bosnian words. Returns empty string for 0.
  /// @throws ArgumentError if `n` is outside 0-999.
  String _convertChunk(int n, {Gender gender = Gender.masculine}) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    List<String> words = [];
    int remainder = n;

    // Handle hundreds.
    if (remainder >= 100) {
      words.add(_wordsHundreds[remainder ~/ 100]); // "sto", "dvjesto", ...
      remainder %= 100;
      if (remainder == 0) return words.first; // Exact hundred.
    }

    // Handle tens and units (1-99).
    if (remainder > 0) {
      // Select the correct word list based on gender for 1 & 2.
      final List<String> wordsList =
          gender == Gender.feminine ? _wordsUnder20Feminine : _wordsUnder20;

      if (remainder < 20) {
        // 1-19: Use the gender-appropriate list.
        words.add(wordsList[remainder]);
      } else {
        // 20-99: Combine tens and units.
        words.add(_wordsTens[remainder ~/ 10]); // "dvadeset", "trideset", ...
        int unit = remainder % 10;
        if (unit > 0) {
          // Add unit word using the gender-appropriate list.
          words.add(wordsList[
              unit]); // e.g., "tri" (from either list), "jedna"/"jedan", "dvije"/"dva"
        }
      }
    }
    return words
        .join(' '); // e.g., "sto", "dvadeset", "tri" -> "sto dvadeset tri"
  }

  /// Converts a non-negative integer into full Bosnian words with scales and declension.
  ///
  /// Breaks into 3-digit chunks, converts each using [_convertChunk] with appropriate gender
  /// (determined by scale word), adds declined scale words (hiljada, milion...) using [_getDeclinedForm].
  /// Handles the special case of "1 thousand/million" (omits "jedan/jedna").
  ///
  /// @param n The non-negative integer.
  /// @param gender Gender context for the least significant part if n < 1000. Defaults to masculine.
  /// @return The integer as Bosnian words.
  /// @throws ArgumentError if `n` is negative.
  String _convertInteger(BigInt n, {Gender gender = Gender.masculine}) {
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n == BigInt.zero) return _zero;

    // Handle base case < 1000.
    if (n < BigInt.from(1000)) return _convertChunk(n.toInt(), gender: gender);

    List<String> parts =
        []; // Stores converted parts ("pet hiljada", "dvjesto trideset")
    BigInt remaining = n;
    int scalePowerIndex = 0; // 0=units, 1=thousands, 2=millions,...

    while (remaining > BigInt.zero) {
      int chunk = (remaining % BigInt.from(1000)).toInt(); // Current 3 digits.
      BigInt nextRemaining = remaining ~/ BigInt.from(1000);

      if (chunk > 0) {
        String chunkText;
        String scaleWordForm =
            ""; // The declined scale word (e.g., "hiljade", "miliona").
        _NounInfo? scaleInfo; // Grammatical info for the current scale.
        int currentScalePower =
            scalePowerIndex * 3; // Power of 10 (0, 3, 6...).

        // Find grammatical info for the current scale.
        if (currentScalePower == 3)
          scaleInfo = _thousandInfo;
        else if (currentScalePower > 3)
          scaleInfo = _scaleInfoMap[currentScalePower];

        // Determine gender for _convertChunk: use scale noun's gender if available.
        Gender chunkGender = scaleInfo?.gender ?? gender;
        chunkText = _convertChunk(chunk, gender: chunkGender);

        // Special case: "1 thousand/million/etc." -> omit "jedan/jedna".
        if (chunk == 1 && scaleInfo != null) {
          chunkText = ""; // Remove "jedan"/"jedna".
          scaleWordForm =
              scaleInfo.singular; // Use singular scale word directly.
        } else if (scaleInfo != null) {
          // Get the correctly declined scale word for chunk values 2+.
          scaleWordForm = _getDeclinedForm(BigInt.from(chunk), scaleInfo);
        }

        // Combine chunk text and scale word.
        String part = chunkText;
        if (scaleWordForm.isNotEmpty) {
          if (part.isNotEmpty) part += " ";
          part += scaleWordForm;
        }

        // Add the combined part (e.g., "dvadeset pet hiljada") to the beginning.
        if (part.trim().isNotEmpty) parts.insert(0, part.trim());
      }

      remaining = nextRemaining;
      scalePowerIndex++;
    }
    return parts.join(' '); // Join all scale parts.
  }

  /// Formats an integer year in Bosnian with optional era suffixes.
  ///
  /// Converts the year using masculine/neuter gender and appends "p. n. e." (BC)
  /// or "n. e." (AD) based on sign and [BsOptions.includeAD].
  ///
  /// @param year The integer year.
  /// @param options The [BsOptions].
  /// @return The year as Bosnian words.
  String _handleYearFormat(BigInt year, BsOptions options) {
    if (year == BigInt.zero) return _zero;
    bool isNegative = year < BigInt.zero;
    BigInt absYear = isNegative ? -year : year;

    // Years typically use masculine/neuter gender agreement.
    String yearText = _convertInteger(absYear, gender: Gender.masculine);

    // Append era suffixes.
    if (isNegative)
      yearText += " $_yearSuffixBC";
    else if (options.includeAD) yearText += " $_yearSuffixAD";

    return yearText;
  }

  /// Formats a non-negative [Decimal] as Bosnian currency (default BAM).
  ///
  /// Handles rounding, unit separation (Marka/Fening), gender agreement (F/M),
  /// declension using [_getDeclinedForm], and combining parts with separator.
  ///
  /// @param absValue The absolute currency value.
  /// @param options The [BsOptions] with currency info.
  /// @return The currency value as Bosnian words.
  String _handleCurrency(Decimal absValue, BsOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    const int decimalPlaces = 2;
    final Decimal subunitMultiplier =
        Decimal.fromInt(10).pow(decimalPlaces).toDecimal();

    // Round if requested.
    Decimal valueToConvert =
        options.round ? absValue.round(scale: decimalPlaces) : absValue;

    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart =
        valueToConvert - Decimal.fromBigInt(mainValue);
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).truncate().toBigInt();

    String mainResult = '';
    String subResult = '';

    // Convert main unit part (Marka - Feminine).
    if (mainValue > BigInt.zero) {
      const Gender mainGender = Gender.feminine;
      String mainText = _convertInteger(mainValue, gender: mainGender);
      // Create NounInfo for Marka using forms from CurrencyInfo.
      _NounInfo mainNounInfo = _NounInfo(
        singular: currencyInfo.mainUnitSingular,
        nominativePlural:
            currencyInfo.mainUnitPlural2To4 ?? currencyInfo.mainUnitSingular,
        genitivePlural: currencyInfo.mainUnitPluralGenitive ??
            currencyInfo.mainUnitPlural2To4 ??
            currencyInfo.mainUnitSingular,
        gender: mainGender,
      );
      String mainUnitName = _getDeclinedForm(mainValue, mainNounInfo);
      mainResult = '$mainText $mainUnitName';
    }

    // Convert subunit part (Fening - Masculine).
    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      const Gender subGender = Gender.masculine;
      String subunitText = _convertInteger(subunitValue, gender: subGender);
      // Create NounInfo for Fening. Handle potential nulls in CurrencyInfo.
      _NounInfo subNounInfo = _NounInfo(
        singular: currencyInfo.subUnitSingular!,
        nominativePlural:
            currencyInfo.subUnitPlural2To4 ?? currencyInfo.subUnitSingular!,
        genitivePlural: currencyInfo.subUnitPluralGenitive ??
            currencyInfo.subUnitPlural2To4 ??
            currencyInfo.subUnitSingular!,
        gender: subGender,
      );
      String subUnitName = _getDeclinedForm(subunitValue, subNounInfo);
      subResult = '$subunitText $subUnitName';
    }

    // Combine parts.
    if (mainResult.isNotEmpty && subResult.isNotEmpty) {
      String separator =
          currencyInfo.separator ?? "i"; // Default separator "i" (and).
      return '$mainResult $separator $subResult';
    } else if (mainResult.isNotEmpty) {
      return mainResult;
    } else if (subResult.isNotEmpty) {
      // Handle 0.xx amounts.
      return subResult;
    } else {
      // Handle zero amount (after potential rounding). Use Genitive Plural main unit.
      const Gender mainGender = Gender.feminine;
      _NounInfo mainNounInfo = _NounInfo(
        singular: currencyInfo.mainUnitSingular,
        nominativePlural:
            currencyInfo.mainUnitPlural2To4 ?? currencyInfo.mainUnitSingular,
        genitivePlural: currencyInfo.mainUnitPluralGenitive ??
            currencyInfo.mainUnitPlural2To4 ??
            currencyInfo.mainUnitSingular,
        gender: mainGender,
      );
      String mainUnitName = _getDeclinedForm(BigInt.zero, mainNounInfo);
      return '$_zero $mainUnitName'; // Consistent with zero handling in 'process'.
    }
  }

  /// Converts a non-negative standard [Decimal] number into Bosnian words.
  ///
  /// Handles integer part (default masculine/neuter gender).
  /// Fractional part is read digit-by-digit after the separator ("zarez" or "tačka").
  /// Removes trailing zeros from the fractional part display.
  ///
  /// @param absValue The absolute decimal value.
  /// @param options The [BsOptions] with decimal separator preference.
  /// @return The number as Bosnian words.
  String _handleStandardNumber(Decimal absValue, BsOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - Decimal.fromBigInt(integerPart);

    // Convert integer part (default masculine/neuter). Handle 0.x cases.
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart != Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, gender: Gender.masculine);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Choose separator word.
      String separatorWord =
          (options.decimalSeparator ?? DecimalSeparator.comma) ==
                  DecimalSeparator.comma
              ? _defaultDecimalSeparatorWord // "zarez"
              : _pointWord; // "tačka"

      // Get fractional digits and remove trailing zeros.
      String fractionalString = fractionalPart.toString();
      String fractionalDigits = "";
      int decimalPointIndex = fractionalString.indexOf('.');
      if (decimalPointIndex != -1) {
        fractionalDigits = fractionalString.substring(decimalPointIndex + 1);
        fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');
      }

      if (fractionalDigits.isNotEmpty) {
        // Convert digits to words (using default M/N forms).
        List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder20[digitInt]
              : '?';
        }).toList();
        if (digitWords.isNotEmpty) {
          fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
        }
      }
    }

    // Combine integer and fractional parts.
    if (integerPart == BigInt.zero && fractionalPart == Decimal.zero)
      return _zero; // Safety check.
    return '$integerWords$fractionalWords'.trim();
  }
}
