import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ro_options.dart';
import '../utils/utils.dart';

/// Internal enum representing grammatical gender context for Romanian number words.
enum _GenderContext { masculine, feminine, neuter }

/// {@template num2text_ro}
/// Converts numbers to Romanian words (`Lang.RO`).
///
/// Implements [Num2TextBase] for Romanian, handling various numeric types.
/// Supports cardinal numbers, decimals, negatives, currency, years, and large numbers
/// (million, miliard scale). Applies Romanian grammar (gender agreement "unu"/"una",
/// "doi"/"două"; preposition "de").
/// Customizable via [RoOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextRO implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "zero";
  static const String _virgula =
      "virgulă"; // Decimal comma "," (default separator).
  static const String _punct = "punct"; // Decimal point "." word.
  static const String _si = "și"; // Conjunction "and".
  /// Preposition "of", used before scale words if preceding number ends in 0 or >= 20.
  static const String _de = "de";
  static const String _suta = "sută"; // Singular "hundred".
  static const String _sute = "sute"; // Plural "hundreds".
  static const String _mie = "mie"; // Singular "thousand".
  static const String _mii = "mii"; // Plural "thousands".
  static const String _yearSuffixBC = "î.Hr."; // "înainte de Hristos"
  static const String _yearSuffixAD = "d.Hr."; // "după Hristos"
  static const String _infinity = "Infinit";
  static const String _negativeInfinity = "Infinit Negativ";
  static const String _notANumber = "Nu Este Un Număr"; // Default fallback/NaN.

  /// Base unit words (masculine form). Index 0 unused.
  static const List<String> _unitsMasculine = [
    "",
    "unu",
    "doi",
    "trei",
    "patru",
    "cinci",
    "șase",
    "șapte",
    "opt",
    "nouă"
  ];

  /// Base unit words (feminine form). Index 0 unused.
  static const List<String> _unitsFeminine = [
    "",
    "una",
    "două",
    "trei",
    "patru",
    "cinci",
    "șase",
    "șapte",
    "opt",
    "nouă"
  ];

  /// Base unit words (neuter form - same as masculine). Index 0 unused.
  static const List<String> _unitsNeuter = [
    "",
    "unu",
    "doi",
    "trei",
    "patru",
    "cinci",
    "șase",
    "șapte",
    "opt",
    "nouă"
  ];

  static const List<String> _teens = [
    "zece",
    "unsprezece",
    "doisprezece",
    "treisprezece",
    "paisprezece",
    "cincisprezece",
    "șaisprezece",
    "șaptesprezece",
    "optsprezece",
    "nouăsprezece",
  ];
  static const List<String> _tens = [
    "",
    "",
    "douăzeci",
    "treizeci",
    "patruzeci",
    "cincizeci",
    "șaizeci",
    "șaptezeci",
    "optzeci",
    "nouăzeci",
  ];

  /// Scale words. Index corresponds to power of 1,000,000 (1=million, 2=milliard...).
  /// 's': singular, 'p': plural, 'g': grammatical gender of the noun itself.
  static const List<Map<String, String>> _scaleWords = [
    {
      "s": "",
      "p": "",
      "g": "n"
    }, // Index 0: Placeholder (units/thousands handled differently)
    {"s": "milion", "p": "milioane", "g": "n"}, // Index 1: 10^6 (Neuter)
    {"s": "miliard", "p": "miliarde", "g": "n"}, // Index 2: 10^9 (Neuter)
    {"s": "trilion", "p": "trilioane", "g": "n"}, // Index 3: 10^12 (Neuter)
    {
      "s": "cvadrilion",
      "p": "cvadrilioane",
      "g": "n"
    }, // Index 4: 10^15 (Neuter)
    {
      "s": "cvintilion",
      "p": "cvintilioane",
      "g": "n"
    }, // Index 5: 10^18 (Neuter)
    {"s": "sextilion", "p": "sextilioane", "g": "n"}, // Index 6: 10^21 (Neuter)
    {"s": "septilion", "p": "septilioane", "g": "n"}, // Index 7: 10^24 (Neuter)
  ];

  /// Processes the given [number] into Romanian words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [RoOptions] for customization (currency, year format, decimals, negative prefix, AD/BC).
  /// Defaults apply if [options] is null or not [RoOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or [_notANumber] on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [RoOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Romanian words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final RoOptions roOptions =
        options is RoOptions ? options : const RoOptions();
    final String errorFallback = fallbackOnError ?? _notANumber;

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _negativeInfinity : _infinity;
      if (number.isNaN) return errorFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    if (decimalValue == Decimal.zero) {
      return roOptions.currency
          ? "$_zero ${roOptions.currencyInfo.mainUnitPlural}" // Use plural for zero currency
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    if (roOptions.format == Format.year) {
      // Year conversion handles sign via AD/BC suffixes.
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), roOptions);
    } else {
      textResult = roOptions.currency
          ? _handleCurrency(absValue, roOptions)
          : _handleStandardNumber(absValue, roOptions);
      if (isNegative) {
        String prefix = roOptions.negativePrefix.trim();
        textResult = "$prefix $textResult";
      }
    }

    // Clean up potential double spaces from combining parts.
    return textResult.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Converts a non-negative [Decimal] to Romanian currency words.
  ///
  /// Uses [RoOptions.currencyInfo] for unit names. Rounds if [RoOptions.round] is true.
  /// Applies gender rules ('un leu' vs 'o sută de lei') and preposition 'de'.
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Romanian words.
  String _handleCurrency(Decimal absValue, RoOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final Decimal val = options.round ? absValue.round(scale: 2) : absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    final BigInt subVal = ((val - val.truncate()) * Decimal.fromInt(100))
        .round(scale: 0)
        .toBigInt();

    String mainPart = "";
    if (mainVal > BigInt.zero) {
      String mainText, mainName;
      // Treat main currency unit as masculine for agreement ("un leu", "doi lei").
      if (mainVal == BigInt.one) {
        mainText = "un"; // Masculine 'one'
        mainName = info.mainUnitSingular;
      } else {
        mainText = _convertInteger(mainVal, _GenderContext.masculine);
        mainName = info.mainUnitPlural!;
        if (_needsDePreposition(mainVal)) mainText += " $_de";
      }
      mainPart = '$mainText $mainName';
    }

    String subPart = "";
    if (subVal > BigInt.zero && info.subUnitSingular != null) {
      String subText, subName;
      // Assume subunit is masculine for agreement ("un ban", "doi bani"). Adjust if needed.
      if (subVal == BigInt.one) {
        subText = "un"; // Masculine 'one'
        subName = info.subUnitSingular!;
      } else {
        subText = _convertInteger(subVal, _GenderContext.masculine);
        subName = info.subUnitPlural!;
        if (_needsDePreposition(subVal)) subText += " $_de";
      }
      subPart = '$subText $subName';
    }

    if (mainPart.isNotEmpty && subPart.isNotEmpty) {
      String separator = info.separator ?? _si; // Default separator "și".
      return '$mainPart $separator $subPart';
    } else if (mainPart.isNotEmpty)
      return mainPart;
    else if (subPart.isNotEmpty)
      return subPart; // Handle 0.xx cases
    else
      return "$_zero ${info.mainUnitPlural}"; // Zero case
  }

  /// Converts a [BigInt] year to Romanian words.
  ///
  /// Uses neuter gender for the year number itself. Appends AD/BC suffixes.
  ///
  /// @param year The integer year.
  /// @param options Formatting options.
  /// @return The year as Romanian words.
  String _handleYearFormat(BigInt year, RoOptions options) {
    final bool isNegative = year < BigInt.zero;
    final BigInt absYear = isNegative ? -year : year;
    // Years typically read using neuter/masculine forms.
    String yearText = _convertInteger(absYear, _GenderContext.neuter);

    if (isNegative)
      yearText += " $_yearSuffixBC";
    else if (options.includeAD && absYear > BigInt.zero)
      yearText += " $_yearSuffixAD";

    return yearText;
  }

  /// Converts a non-negative standard [Decimal] number to Romanian words.
  ///
  /// Converts integer and fractional parts. Uses [RoOptions.decimalSeparator] word.
  /// Integer part uses neuter gender. Fractional part converted digit by digit (neuter).
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Romanian words.
  String _handleStandardNumber(Decimal absValue, RoOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    // Use neuter for standalone numbers.
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero // Use "zero" for 0.xxx cases
            : _convertInteger(integerPart, _GenderContext.neuter);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      String sepWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          sepWord = _punct;
          break;
        default:
          sepWord = _virgula;
          break; // Default to comma
      }

      String digitsStr = absValue.toString().split('.').last;
      // Convert each digit using neuter form via _convertDigit.
      List<String> digitWords =
          digitsStr.split('').map((d) => _convertDigit(int.parse(d))).toList();
      fractionalWords =
          ' $sepWord ${digitWords.join(' ')}'; // e.g., " virgulă unu doi"
    }

    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] into Romanian words with gender agreement.
  ///
  /// Handles large numbers by breaking into chunks of 1000. Applies scale words
  /// (mie, milion...) and the preposition "de" correctly based on Romanian grammar.
  ///
  /// @param n The non-negative integer.
  /// @param genderContext The required grammatical [_GenderContext] for the final part
  ///                      of the number (if it's 1 or 2 influencing the word).
  /// @return The integer as Romanian words.
  /// @throws ArgumentError if [n] is negative or too large for defined scales.
  String _convertInteger(BigInt n, _GenderContext genderContext) {
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n == BigInt.zero) return _zero;

    List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleLevel =
        0; // 0: 0-999, 1: thousands, 2: millions (index 1 in _scaleWords), ...
    BigInt remaining = n;

    while (remaining > BigInt.zero) {
      BigInt chunk = remaining % oneThousand;
      remaining ~/= oneThousand;

      if (chunk > BigInt.zero) {
        String chunkText; // Words for the number part (1-999)
        _GenderContext chunkGender; // Gender required *for* the number part
        String scaleWordSingular = "";
        String scaleWordPlural = "";
        _GenderContext scaleNounGender =
            _GenderContext.neuter; // Gender *of* the scale noun

        // Determine scale word and required gender for the number before it.
        if (scaleLevel == 1) {
          // Thousands (mie/mii - feminine noun)
          scaleWordSingular = _mie;
          scaleWordPlural = _mii;
          scaleNounGender = _GenderContext.feminine;
          // Requires feminine numbers before mie/mii (e.g., "o mie", "două mii").
          chunkGender = _GenderContext.feminine;
        } else if (scaleLevel > 1) {
          // Millions, Billions, etc. (neuter nouns)
          int scaleInfoIndex =
              scaleLevel - 1; // _scaleWords index starts at 1 (million)
          if (scaleInfoIndex >= _scaleWords.length)
            throw ArgumentError("Number too large: $n");
          var scaleInfo = _scaleWords[scaleInfoIndex];
          scaleWordSingular = scaleInfo["s"]!;
          scaleWordPlural = scaleInfo["p"]!;
          // All defined scales (milion, miliard...) are neuter.
          scaleNounGender = _GenderContext.neuter;
          // Requires feminine numbers for count > 1 before neuter nouns
          // ("un milion", "două milioane").
          chunkGender = (chunk == BigInt.one)
              ? _GenderContext.neuter
              : _GenderContext.feminine;
        } else {
          // Scale level 0 (last chunk 0-999)
          chunkGender = genderContext; // Use the overall required gender.
        }

        // Convert the chunk number (1-999) using the determined gender.
        chunkText = _convertChunk(chunk.toInt(), chunkGender);

        // Combine chunk text with scale word if applicable.
        if (scaleLevel >= 1) {
          // Handle "one" before scale word explicitly.
          if (chunk == BigInt.one) {
            if (scaleNounGender == _GenderContext.feminine)
              chunkText = "o"; // "o mie"
            else
              chunkText = "un"; // "un milion", "un miliard"
          }
          // Choose singular/plural scale word.
          String scale =
              (chunk == BigInt.one) ? scaleWordSingular : scaleWordPlural;
          // Add preposition "de" if needed.
          if (_needsDePreposition(chunk)) chunkText += " $_de";
          parts.add("$chunkText $scale");
        } else {
          parts.add(chunkText); // Just the number for the last chunk.
        }
      }
      scaleLevel++;
      if (scaleLevel > _scaleWords.length + 1) {
        // Safety break
        throw ArgumentError(
            "Number too large to convert (exceeds defined scales).");
      }
    }

    return parts.reversed.join(' ');
  }

  /// Converts an integer from 0 to 999 into Romanian words with gender agreement.
  ///
  /// Handles hundreds ("o sută", "două sute"), tens ("douăzeci"), teens ("unsprezece"),
  /// and units, applying the correct gender form based on [genderContext].
  /// Includes the conjunction "și" correctly (e.g., "douăzeci și unu").
  ///
  /// @param n Integer chunk (0-999).
  /// @param genderContext The required grammatical [_GenderContext] for units 1 or 2.
  /// @return Chunk as Romanian words, or empty string if [n] is 0.
  /// @throws ArgumentError if [n] is outside 0-999.
  String _convertChunk(int n, _GenderContext genderContext) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    List<String> words = [];
    int remainder = n;

    // Handle hundreds.
    if (remainder >= 100) {
      int hundredDigit = remainder ~/ 100;
      if (hundredDigit == 1)
        words.add("o $_suta"); // "o sută" (feminine 'o')
      else {
        // Requires feminine 'două' for 200, neuter/masculine otherwise.
        _GenderContext hundredGender = (hundredDigit == 2)
            ? _GenderContext.feminine
            : _GenderContext.neuter;
        words.add(
            "${_getUnits(hundredDigit, hundredGender)} $_sute"); // e.g., "două sute", "trei sute"
      }
      remainder %= 100;
    }

    // Handle remaining 0-99 part.
    if (remainder > 0) {
      if (remainder < 10) {
        // Units 1-9
        words.add(_getUnits(remainder, genderContext));
      } else if (remainder < 20) {
        // Teens 10-19
        // Handle gender for 12: "doisprezece" (M/N) vs "douăsprezece" (F).
        if (remainder == 12 && genderContext == _GenderContext.feminine)
          words.add("douăsprezece");
        else
          words.add(_teens[remainder - 10]);
      } else {
        // Tens 20-99
        int tenDigit = remainder ~/ 10;
        words.add(_tens[tenDigit]); // e.g., "douăzeci"
        int unitDigit = remainder % 10;
        if (unitDigit > 0) {
          words.add(_si); // Add "și" before the unit.
          words.add(_getUnits(unitDigit, genderContext)); // e.g., "și unu"
        }
      }
    }

    return words.join(' ');
  }

  /// Checks if the preposition "de" is needed before a scale word (mie, milion...).
  /// Rule: Needed if the preceding number is 0 or ends in 00-19 (relative to 100),
  /// OR if the number is >= 20. Simpler: needed if number is 0 or >= 20, unless ends 01-19.
  /// A more direct check: needed if number is 0 OR (number >= 20 AND number % 100 is 0 or >= 20).
  ///
  /// @param number The number preceding the scale word.
  /// @return True if "de" should be inserted.
  bool _needsDePreposition(BigInt number) {
    if (number == BigInt.zero) return true; // "zero de mii" (though unusual)
    if (number < BigInt.from(20)) return false; // "nouăsprezece mii" (no de)

    // For numbers >= 20:
    // If the number ends in 00 or 20-99 (mod 100), "de" is needed.
    // If the number ends in 01-19 (mod 100), "de" is NOT needed.
    BigInt remainderMod100 = number % BigInt.from(100);
    return remainderMod100 == BigInt.zero || remainderMod100 >= BigInt.from(20);
    // e.g., 20 -> needs de (20 % 100 = 20)
    // e.g., 100 -> needs de (100 % 100 = 0)
    // e.g., 101 -> no de (101 % 100 = 1)
    // e.g., 119 -> no de (119 % 100 = 19)
    // e.g., 120 -> needs de (120 % 100 = 20)
  }

  /// Converts a single digit (0-9) to its Romanian word form (neuter).
  /// Used for decimal parts.
  String _convertDigit(int digit) {
    if (digit == 0) return _zero;
    if (digit > 0 && digit <= 9) return _unitsNeuter[digit];
    return "?"; // Fallback
  }

  /// Gets the Romanian word for a unit digit (1-9) based on gender context.
  String _getUnits(int n, _GenderContext context) {
    if (n <= 0 || n > 9) return "?"; // Only for 1-9
    switch (context) {
      case _GenderContext.feminine:
        return _unitsFeminine[n];
      case _GenderContext.masculine:
        return _unitsMasculine[n];
      case _GenderContext.neuter:
        return _unitsNeuter[n];
    }
  }
}
