import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/bs_options.dart';
import '../utils/utils.dart';

/// Internal helper class to store grammatical information for nouns
/// (like scale words or currency units) that change form based on the preceding number.
class _NounInfo {
  /// The singular form of the noun (used for number 1, except when ending in 11).
  final String singular;

  /// The nominative plural form (typically used for numbers ending in 2, 3, 4, except 12, 13, 14).
  final String nominativePlural;

  /// The genitive plural form (used for numbers ending in 0, 5-9, or 11-19).
  final String genitivePlural;

  /// The grammatical gender of the noun, influencing the form of numbers 1 and 2 preceding it.
  final Gender gender;

  /// Creates a noun information holder.
  const _NounInfo({
    required this.singular,
    required this.nominativePlural,
    required this.genitivePlural,
    required this.gender,
  });
}

/// {@template num2text_bs}
/// The Bosnian language (Lang.BS) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Bosnian word representation following standard Bosnian grammar, including
/// complex noun declension and gender agreement rules.
///
/// Capabilities include handling cardinal numbers, currency (using [BsOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (long scale: milion, milijarda).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [BsOptions].
/// {@endtemplate}
class Num2TextBS implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "nula";
  static const String _defaultDecimalSeparatorWord = "zarez"; // comma
  static const String _pointWord = "tačka"; // period/point
  static const String _yearSuffixBC =
      "p. n. e."; // Prije nove ere (Before Common Era)
  static const String _yearSuffixAD = "n. e."; // Nove ere (Common Era)
  static const String _infinity = "Beskonačnost";
  static const String _negativeInfinity = "Negativna beskonačnost";
  static const String _notANumber = "Nije broj";

  /// Words for numbers 0-19 (masculine/neuter default forms).
  static const List<String> _wordsUnder20 = [
    _zero, // 0
    "jedan", // 1 (masculine)
    "dva", // 2 (masculine/neuter)
    "tri", // 3
    "četiri", // 4
    "pet", // 5
    "šest", // 6
    "sedam", // 7
    "osam", // 8
    "devet", // 9
    "deset", // 10
    "jedanaest", // 11
    "dvanaest", // 12
    "trinaest", // 13
    "četrnaest", // 14
    "petnaest", // 15
    "šesnaest", // 16
    "sedamnaest", // 17
    "osamnaest", // 18
    "devetnaest", // 19
  ];

  /// Words for numbers 0-19 (feminine specific forms for 1 and 2).
  static const List<String> _wordsUnder20Feminine = [
    _zero, // 0
    "jedna", // 1 (feminine)
    "dvije", // 2 (feminine)
    "tri", // 3
    "četiri", // 4
    "pet", // 5
    "šest", // 6
    "sedam", // 7
    "osam", // 8
    "devet", // 9
    "deset", // 10
    "jedanaest", // 11
    "dvanaest", // 12
    "trinaest", // 13
    "četrnaest", // 14
    "petnaest", // 15
    "šesnaest", // 16
    "sedamnaest", // 17
    "osamnaest", // 18
    "devetnaest", // 19
  ];

  /// Words for tens (20, 30,... 90). Index corresponds to the tens digit (index 2 = 20).
  static const List<String> _wordsTens = [
    "", // 0 - not used
    "", // 10 - handled by _wordsUnder20
    "dvadeset", // 20
    "trideset", // 30
    "četrdeset", // 40
    "pedeset", // 50
    "šezdeset", // 60
    "sedamdeset", // 70
    "osamdeset", // 80
    "devedeset", // 90
  ];

  /// Words for hundreds (100, 200,... 900). Index corresponds to the hundreds digit.
  static const List<String> _wordsHundreds = [
    "", // 0 - not used
    "sto", // 100
    "dvjesto", // 200
    "tristo", // 300
    "četiristo", // 400
    "petsto", // 500
    "šeststo", // 600
    "sedamsto", // 700
    "osamsto", // 800
    "devetsto", // 900
  ];

  /// Grammatical information for the word "thousand".
  static const _NounInfo _thousandInfo = _NounInfo(
    singular: "hiljadu", // 1 hiljadu
    nominativePlural: "hiljade", // 2, 3, 4 hiljade
    genitivePlural: "hiljada", // 0, 5+ hiljada
    gender: Gender.feminine, // Requires "jedna", "dvije"
  );

  /// Grammatical information for large scale number words (long scale).
  /// Keys are the power of 10 (e.g., 6 for million, 9 for billion/milliard).
  static final Map<int, _NounInfo> _scaleInfoMap = {
    6: const _NounInfo(
      singular: "milion", // 1 milion
      nominativePlural:
          "miliona", // 2, 3, 4 miliona (Gen.Sg. form often used for Nom.Pl.)
      genitivePlural: "miliona", // 0, 5+ miliona (Gen.Pl.)
      gender: Gender.masculine, // Requires "jedan", "dva"
    ),
    9: const _NounInfo(
      singular: "milijarda", // 1 milijarda
      nominativePlural: "milijarde", // 2, 3, 4 milijarde
      genitivePlural: "milijardi", // 0, 5+ milijardi
      gender: Gender.feminine, // Requires "jedna", "dvije"
    ),
    12: const _NounInfo(
      singular: "bilion",
      nominativePlural: "biliona",
      genitivePlural: "biliona",
      gender: Gender.masculine,
    ),
    15: const _NounInfo(
      singular: "bilijarda",
      nominativePlural: "bilijarde",
      genitivePlural: "bilijardi",
      gender: Gender.feminine,
    ),
    18: const _NounInfo(
      singular: "trilion",
      nominativePlural: "triliona",
      genitivePlural: "triliona",
      gender: Gender.masculine,
    ),
    21: const _NounInfo(
      singular: "trilijarda",
      nominativePlural: "trilijarde",
      genitivePlural: "trilijardi",
      gender: Gender.feminine,
    ),
    24: const _NounInfo(
      singular: "kvadrilion",
      nominativePlural: "kvadriliona",
      genitivePlural: "kvadriliona",
      gender: Gender.masculine,
    ),
    // Add more scales here if needed (kvadrilijarda, kvintilion, etc.) following the pattern.
  };

  /// {@macro num2text_base_process}
  ///
  /// [number]: The number input (int, double, BigInt, String, Decimal).
  /// [options]: Optional [BsOptions] to customize formatting (currency, year, etc.).
  /// [fallbackOnError]: Custom string to return on conversion error, overriding the default.
  /// Returns the number converted to Bosnian words, or an error/fallback string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final BsOptions bsOptions =
        options is BsOptions ? options : const BsOptions();
    final String errorMsg = fallbackOnError ?? _notANumber;

    // Handle special double values first
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? _negativeInfinity : _infinity;
      }
      if (number.isNaN) {
        return errorMsg;
      }
    }

    // Normalize the input to Decimal
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) {
      return errorMsg;
    }

    // Handle zero separately for potential currency formatting
    if (decimalValue == Decimal.zero) {
      if (bsOptions.currency) {
        final info = bsOptions.currencyInfo;
        // For zero amount, use the genitive plural form of the currency unit
        final mainUnitForm = info.mainUnitPluralGenitive ??
            info.mainUnitPlural ??
            info.mainUnitSingular;
        return "$_zero $mainUnitForm";
      }
      return _zero;
    }

    // Determine sign and use absolute value for core conversion
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Apply specific format handlers if requested
    if (bsOptions.format == Format.year) {
      // Year format requires integer input and handles sign internally (BC/AD)
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), bsOptions);
    } else {
      if (bsOptions.currency) {
        textResult = _handleCurrency(absValue, bsOptions);
      } else {
        textResult = _handleStandardNumber(absValue, bsOptions);
      }
      // Add negative prefix if needed (and not handled by year format)
      if (isNegative) {
        textResult = "${bsOptions.negativePrefix} $textResult";
      }
    }

    return textResult;
  }

  /// Determines the correct grammatical form (declension) of a noun based on the preceding number.
  ///
  /// Bosnian nouns change form depending on the number they follow:
  /// - Ends in 1 (but not 11): Singular form.
  /// - Ends in 2, 3, 4 (but not 12, 13, 14): Nominative Plural form.
  /// - Ends in 0, 5-9, or 11-19: Genitive Plural form.
  ///
  /// [number]: The number determining the noun form.
  /// [info]: The [_NounInfo] containing the different forms of the noun.
  /// Returns the correctly declined noun string.
  String _getDeclinedForm(BigInt number, _NounInfo info) {
    final String singular = info.singular;
    final String nomPlural = info.nominativePlural;
    final String genPlural = info.genitivePlural;

    // Handle zero explicitly if needed (usually takes Gen. Pl.)
    if (number == BigInt.zero) {
      return genPlural;
    }

    // Get last digit and last two digits for declension rules
    int lastDigit = (number % BigInt.from(10)).toInt();
    int lastTwoDigits = (number % BigInt.from(100)).toInt();

    // Rule for 11-19: Genitive Plural
    if (lastTwoDigits >= 11 && lastTwoDigits <= 19) {
      return genPlural;
    }

    // Rule for 1: Singular
    if (lastDigit == 1) {
      return singular;
    }

    // Rule for 2-4: Nominative Plural
    if (lastDigit >= 2 && lastDigit <= 4) {
      return nomPlural;
    }

    // Default rule (0, 5-9): Genitive Plural
    return genPlural;
  }

  /// Converts a number chunk (0-999) into Bosnian words.
  ///
  /// [n]: The integer chunk to convert (must be 0-999).
  /// [gender]: The grammatical gender required for the numbers "one" and "two"
  ///          if they appear in this chunk (defaults to [Gender.masculine]).
  /// Returns the word representation of the chunk.
  /// Throws [ArgumentError] if `n` is outside the 0-999 range.
  String _convertChunk(int n, {Gender gender = Gender.masculine}) {
    if (n < 0 || n >= 1000) {
      // This should ideally not be reached due to logic in _convertInteger
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }
    if (n == 0) return ""; // Handle zero chunk explicitly

    List<String> words = [];
    int remainder = n;

    // --- Hundreds ---
    if (remainder >= 100) {
      words.add(_wordsHundreds[remainder ~/ 100]);
      remainder %= 100;
      if (remainder == 0) {
        // If exactly N hundred, stop here (e.g., "sto", "dvjesto")
        return words.first;
      }
    }

    // --- Tens and Units ---
    if (remainder > 0) {
      if (remainder < 20) {
        // Numbers 1-19
        // Use gender-specific forms for 1 and 2
        if (remainder == 1 || remainder == 2) {
          words.add(
            gender == Gender.feminine
                ? _wordsUnder20Feminine[remainder]
                : _wordsUnder20[remainder],
          );
        } else {
          words.add(_wordsUnder20[remainder]);
        }
      } else {
        // Numbers 20-99
        words.add(_wordsTens[remainder ~/ 10]);
        int unit = remainder % 10;
        if (unit > 0) {
          // Use gender-specific forms for 1 and 2
          if (unit == 1 || unit == 2) {
            words.add(
              gender == Gender.feminine
                  ? _wordsUnder20Feminine[unit]
                  : _wordsUnder20[unit],
            );
          } else {
            words.add(_wordsUnder20[unit]);
          }
        }
      }
    }

    return words.join(' ');
  }

  /// Converts a non-negative integer ([BigInt]) into Bosnian words.
  ///
  /// Handles numbers from zero up to the limits defined by [_scaleInfoMap].
  /// Uses [_convertChunk] for processing 3-digit groups and applies scale words
  /// with correct declension using [_getDeclinedForm].
  ///
  /// [n]: The non-negative integer to convert.
  /// [gender]: The grammatical gender to apply to the least significant chunk if `n < 1000`,
  ///          otherwise gender is determined by the scale words. Defaults to [Gender.masculine].
  /// Returns the word representation of the integer.
  /// Throws [ArgumentError] if `n` is negative.
  String _convertInteger(BigInt n, {Gender gender = Gender.masculine}) {
    if (n < BigInt.zero) {
      // Should be handled by the main process method, but added as safeguard
      throw ArgumentError("Input must be non-negative for _convertInteger.");
    }
    if (n == BigInt.zero) return _zero;

    // Handle numbers less than 1000 directly
    if (n < BigInt.from(1000)) {
      return _convertChunk(n.toInt(), gender: gender);
    }

    List<String> parts = [];
    BigInt remaining = n;
    // Power of 1000 (0 for units, 3 for thousands, 6 for millions, etc.)
    int scalePowerIndex = 0;

    while (remaining > BigInt.zero) {
      // Extract the last 3 digits (chunk)
      int chunk = (remaining % BigInt.from(1000)).toInt();
      // Prepare for the next iteration
      BigInt nextRemaining = remaining ~/ BigInt.from(1000);

      if (chunk > 0) {
        String chunkText;
        String scaleWordForm = "";
        _NounInfo? scaleInfo;
        int currentScalePower = scalePowerIndex * 3; // e.g., 0, 3, 6, 9...

        // Determine the scale noun info (thousand, million, billion, etc.)
        if (currentScalePower == 3) {
          scaleInfo = _thousandInfo;
        } else if (currentScalePower > 3 &&
            _scaleInfoMap.containsKey(currentScalePower)) {
          scaleInfo = _scaleInfoMap[currentScalePower]!;
        }

        // Convert the chunk, applying gender based on the scale noun
        // Default to the passed 'gender' if no scale noun or scale noun is masculine/neuter.
        // Override with feminine only if the scale noun requires it (e.g., hiljada, milijarda).
        Gender chunkGender = scaleInfo?.gender ?? gender;
        chunkText = _convertChunk(chunk, gender: chunkGender);

        // Handle special case: exactly 1 thousand/million/etc. (e.g., "hiljadu", not "jedna hiljadu")
        // Use scale singular form directly, omit "jedan/jedna".
        bool isExactPowerOfOne =
            (chunk == 1 && currentScalePower >= 3 && scaleInfo != null);
        if (isExactPowerOfOne) {
          chunkText = ""; // Don't say "jedan/jedna"
          scaleWordForm = scaleInfo.singular;
        } else if (scaleInfo != null) {
          // Get the declined form of the scale word based on the chunk value
          scaleWordForm = _getDeclinedForm(BigInt.from(chunk), scaleInfo);
        }

        // Combine chunk text and scale word
        String part = chunkText;
        if (scaleWordForm.isNotEmpty) {
          if (part.isNotEmpty) {
            part += " ";
          }
          part += scaleWordForm;
        }

        // Add the processed part to the beginning of the list
        if (part.trim().isNotEmpty) {
          parts.insert(0, part.trim());
        }
      }

      remaining = nextRemaining;
      scalePowerIndex++;
    }

    // Join the parts with spaces
    return parts.join(' ');
  }

  /// Formats a number as a year in Bosnian.
  ///
  /// [year]: The year value ([BigInt]).
  /// [options]: The [BsOptions] containing formatting preferences (e.g., `includeAD`).
  /// Returns the year converted to words, potentially with era suffixes (n.e. / p.n.e.).
  String _handleYearFormat(BigInt year, BsOptions options) {
    bool isNegative = year < BigInt.zero;
    BigInt absYear = isNegative ? -year : year;

    // Convert the absolute year value to words. Gender is usually masculine for years.
    String yearText = _convertInteger(absYear, gender: Gender.masculine);

    // Add era suffixes if needed
    if (isNegative) {
      // Always add "p. n. e." for negative years (BC/BCE)
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD && year > BigInt.zero) {
      // Add "n. e." for positive years (AD/CE) only if option is enabled and year > 0
      yearText += " $_yearSuffixAD";
    }

    return yearText;
  }

  /// Formats a number as Bosnian currency (BAM).
  ///
  /// [absValue]: The non-negative [Decimal] amount.
  /// [options]: The [BsOptions] containing currency info and rounding preference.
  /// Returns the currency amount converted to words, including main units (marka)
  /// and subunits (fening) with correct declension.
  String _handleCurrency(Decimal absValue, BsOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2; // BAM has 2 decimal places (fening)
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value *before* splitting if requested
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main value (marka) and subunit value (fening)
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    // Use precise Decimal arithmetic for fractional part
    final Decimal fractionalPart =
        valueToConvert - Decimal.fromBigInt(mainValue);
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).truncate().toBigInt();

    // --- Main Unit (Konvertibilna Marka - Feminine) ---
    const Gender mainGender = Gender.feminine;
    String mainText = _convertInteger(mainValue, gender: mainGender);

    // Define noun info for the main unit (using BAM specifics)
    _NounInfo mainNounInfo = _NounInfo(
      singular: currencyInfo.mainUnitSingular, // "konvertibilna marka"
      nominativePlural: currencyInfo.mainUnitPlural2To4 ??
          currencyInfo.mainUnitSingular, // "konvertibilne marke"
      genitivePlural: currencyInfo.mainUnitPluralGenitive ??
          currencyInfo.mainUnitPlural2To4 ??
          currencyInfo.mainUnitSingular, // "konvertibilnih maraka"
      gender: mainGender,
    );
    String mainUnitName = _getDeclinedForm(mainValue, mainNounInfo);
    String result = '$mainText $mainUnitName';

    // --- Sub Unit (Fening - Masculine) ---
    if (subunitValue > BigInt.zero) {
      const Gender subGender = Gender.masculine;
      String subunitText = _convertInteger(subunitValue, gender: subGender);

      // Define noun info for the subunit (using BAM specifics)
      _NounInfo subNounInfo = _NounInfo(
        singular: currencyInfo.subUnitSingular ?? "", // "fening"
        nominativePlural: currencyInfo.subUnitPlural2To4 ??
            currencyInfo.subUnitSingular ??
            "", // "feninga" (Gen.Sg often used)
        genitivePlural: currencyInfo.subUnitPluralGenitive ??
            currencyInfo.subUnitPlural2To4 ??
            currencyInfo.subUnitSingular ??
            "", // "feninga"
        gender: subGender,
      );

      // Only add subunit part if subunit is defined in CurrencyInfo
      if (subNounInfo.singular.isNotEmpty) {
        String subUnitName = _getDeclinedForm(subunitValue, subNounInfo);
        String separator =
            currencyInfo.separator ?? "i"; // Default separator "i" (and)
        result += ' $separator $subunitText $subUnitName';
      }
    }

    return result;
  }

  /// Converts a standard number ([Decimal]), potentially including a fractional part,
  /// into Bosnian words.
  ///
  /// [absValue]: The non-negative [Decimal] number to convert.
  /// [options]: The [BsOptions] specifying the decimal separator word.
  /// Returns the number converted to words, with the fractional part read digit by digit.
  String _handleStandardNumber(Decimal absValue, BsOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    // Use precise Decimal subtraction
    final Decimal fractionalPart = absValue - Decimal.fromBigInt(integerPart);

    // Convert the integer part (use masculine as default for standalone numbers)
    // Handle the case where the integer part is 0 but there's a fractional part.
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart != Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, gender: Gender.masculine);

    String fractionalWords = '';
    if (fractionalPart != Decimal.zero) {
      // Determine the decimal separator word based on options
      String separatorWord;
      switch (options.decimalSeparator ?? DecimalSeparator.comma) {
        case DecimalSeparator.comma:
          separatorWord = _defaultDecimalSeparatorWord;
          break;
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          separatorWord = _pointWord;
          break;
      }

      // Extract fractional digits as a string, removing leading "0."
      String fractionalString = fractionalPart.toString();
      String fractionalDigits = "";
      int decimalPointIndex = fractionalString.indexOf('.');
      if (decimalPointIndex != -1) {
        fractionalDigits = fractionalString.substring(decimalPointIndex + 1);
      }
      // Trim trailing zeros for standard format
      fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      // Convert each digit after the separator individually
      if (fractionalDigits.isNotEmpty) {
        List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          // Use masculine/neuter form for digits 0-9
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder20[digitInt]
              : '?';
        }).toList();

        if (digitWords.isNotEmpty) {
          fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
        }
      }
    }

    // Combine integer and fractional parts
    if (integerPart == BigInt.zero && fractionalPart == Decimal.zero) {
      // Should have been caught earlier, but safe fallback
      return _zero;
    } else {
      return '$integerWords$fractionalWords'.trim();
    }
  }
}
