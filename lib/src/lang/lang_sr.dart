import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/sr_options.dart';
import '../utils/utils.dart';

/// {@template num2text_sr}
/// Converts numbers to Serbian words (`Lang.SR`).
///
/// Implements [Num2TextBase] for Serbian (Latin or Cyrillic script context dependent on locale).
/// Handles cardinals, currency, years, decimals, negatives, and large numbers.
/// Applies Serbian grammar (gender, plurals). Customizable via [SrOptions].
/// {@endtemplate}
class Num2TextSR implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "nula";
  static const String _pointWord = "tačka"; // For '.'
  static const String _commaWord = "zapeta"; // For ',' (or "zarez")

  static const List<String> _wordsUnder20Masc = [
    "nula",
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
  static const String _oneFem = "jedna";
  static const String _twoFem = "dve";

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
  static const List<String> _wordsHundreds = [
    "",
    "sto",
    "dvesta",
    "trista",
    "četiristo",
    "petsto",
    "šeststo",
    "sedamsto",
    "osamsto",
    "devetsto",
  ];

  // Scale word forms (index corresponds to _scaleWordForms index)
  static const Map<String, String> _thousandForms = {
    // F, 10^3
    "singular": "hiljadu", "plural2To4": "hiljade", "genitivePlural": "hiljada",
    "gender": "feminine",
  };
  static const Map<String, String> _millionForms = {
    // M, 10^6
    "singular": "milion", "plural2To4": "miliona", "genitivePlural": "miliona",
    "gender": "masculine",
  };
  static const Map<String, String> _milliardForms = {
    // F, 10^9
    "singular": "milijarda", "plural2To4": "milijarde",
    "genitivePlural": "milijardi",
    "gender": "feminine",
  };
  static const Map<String, String> _billionForms = {
    // M, 10^12
    "singular": "bilion", "plural2To4": "biliona", "genitivePlural": "biliona",
    "gender": "masculine",
  };
  static const Map<String, String> _billiardForms = {
    // F, 10^15
    "singular": "bilijarda", "plural2To4": "bilijarde",
    "genitivePlural": "bilijardi",
    "gender": "feminine",
  };
  static const Map<String, String> _trillionForms = {
    // M, 10^18
    "singular": "trilion", "plural2To4": "triliona",
    "genitivePlural": "triliona",
    "gender": "masculine",
  };
  static const Map<String, String> _trilliardForms = {
    // F, 10^21
    "singular": "trilijarda", "plural2To4": "trilijarde",
    "genitivePlural": "trilijardi",
    "gender": "feminine",
  };
  static const Map<String, String> _quadrillionForms = {
    // M, 10^24
    "singular": "kvadrilion", "plural2To4": "kvadriliona",
    "genitivePlural": "kvadriliona",
    "gender": "masculine",
  };

  // List storing scale forms (index = power of 1000)
  static const List<Map<String, String>> _scaleWordForms = [
    {},
    _thousandForms,
    _millionForms,
    _milliardForms,
    _billionForms,
    _billiardForms,
    _trillionForms,
    _trilliardForms,
    _quadrillionForms,
  ];

  /// Processes the given [number] into Serbian words.
  ///
  /// Main entry point. Normalizes input, handles special cases (zero, inf, NaN),
  /// manages sign, and delegates to specific handlers based on [SrOptions].
  ///
  /// @param number The number to convert.
  /// @param options Optional [SrOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Serbian words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final SrOptions srOptions =
        options is SrOptions ? options : const SrOptions();
    final String fallback = fallbackOnError ?? "Nije broj";

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Minus beskonačnost" : "Beskonačnost";
      if (number.isNaN) return fallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return fallback;

    if (decimalValue == Decimal.zero) {
      return srOptions.currency
          ? "$_zero ${_getCurrencyPluralForm(BigInt.zero, srOptions.currencyInfo, false)}" // Use gen. pl. for 0
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    if (srOptions.format == Format.year) {
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), srOptions);
    } else {
      textResult = srOptions.currency
          ? _handleCurrency(absValue, srOptions)
          : _handleStandardNumber(absValue, srOptions);
      if (isNegative) {
        textResult = "${srOptions.negativePrefix} $textResult";
      }
    }
    return textResult.trim(); // Ensure trimming at the end
  }

  /// Converts an integer year to Serbian words with optional era suffixes.
  ///
  /// Appends "p. n. e." (BC) for negative years or "n. e." (AD) if [SrOptions.includeAD].
  ///
  /// @param year The integer year.
  /// @param options Formatting options.
  /// @return The year as Serbian words.
  String _handleYearFormat(int year, SrOptions options) {
    final bool isNegative = year < 0;
    final BigInt absYear = BigInt.from(isNegative ? -year : year);
    // Years are typically read using masculine forms.
    String yearText = _convertInteger(absYear, defaultGender: Gender.masculine);

    if (isNegative)
      yearText += " p. n. e.";
    else if (options.includeAD) yearText += " n. e.";

    return yearText;
  }

  /// Converts a non-negative [Decimal] to Serbian currency words.
  ///
  /// Uses [SrOptions.currencyInfo] for units and separator. Rounds if [SrOptions.round].
  /// Applies appropriate gender and plural forms.
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Serbian words.
  String _handleCurrency(Decimal absValue, SrOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final Decimal val = options.round ? absValue.round(scale: 2) : absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    final BigInt subVal =
        ((val - val.truncate()) * Decimal.fromInt(100)).truncate().toBigInt();

    List<String> parts = [];

    if (mainVal > BigInt.zero) {
      // Dinar is masculine.
      String mainText =
          _convertInteger(mainVal, defaultGender: Gender.masculine);
      String mainUnitName = _getCurrencyPluralForm(mainVal, info, false);
      parts.add('$mainText $mainUnitName');
    }

    if (subVal > BigInt.zero && info.subUnitSingular != null) {
      // Check if subunit exists
      // Para is feminine.
      String subText = _convertInteger(subVal, defaultGender: Gender.feminine);
      String subUnitName = _getCurrencyPluralForm(subVal, info, true);
      if (parts.isNotEmpty) {
        parts.add(
            info.separator ?? "i"); // Use provided separator or default "i"
      }
      parts.add('$subText $subUnitName');
    }

    // Case for exactly zero amount (already handled in process, but defensive check)
    if (parts.isEmpty && mainVal == BigInt.zero && subVal == BigInt.zero) {
      return "$_zero ${_getCurrencyPluralForm(BigInt.zero, info, false)}";
    }

    return parts.join(' ');
  }

  /// Converts a non-negative standard [Decimal] number to Serbian words.
  ///
  /// Handles integer and fractional parts. Uses [SrOptions.decimalSeparator].
  /// Fractional part converted digit by digit (masculine forms).
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Serbian words.
  String _handleStandardNumber(Decimal absValue, SrOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Use masculine as default for standard numbers.
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, defaultGender: Gender.masculine);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      String sepWord;
      switch (options.decimalSeparator ?? DecimalSeparator.comma) {
        // Default to comma
        case DecimalSeparator.comma:
          sepWord = _commaWord;
          break;
        default:
          sepWord = _pointWord;
          break; // Point/Period
      }

      String fractionalDigits = absValue.toString().split('.').last;
      List<String> digitWords = fractionalDigits.runes.map((rune) {
        final int? digit = int.tryParse(String.fromCharCode(rune));
        // Use masculine forms for digits after decimal point.
        return (digit != null && digit >= 0 && digit <= 9)
            ? _wordsUnder20Masc[digit]
            : '?';
      }).toList();
      fractionalWords = ' $sepWord ${digitWords.join(' ')}';
    }

    return '$integerWords$fractionalWords'.trim();
  }

  /// Selects the correct plural form for a currency unit based on the amount.
  ///
  /// @param amount The quantity of the unit.
  /// @param info The [CurrencyInfo] containing the forms.
  /// @param isSubunit True if querying for the subunit, false for the main unit.
  /// @return The appropriate currency unit name string.
  String _getCurrencyPluralForm(
      BigInt amount, CurrencyInfo info, bool isSubunit) {
    Map<String, String> forms;
    if (isSubunit) {
      if (info.subUnitSingular == null ||
          info.subUnitPlural2To4 == null ||
          info.subUnitPluralGenitive == null) {
        throw ArgumentError(
            "Subunit forms missing in CurrencyInfo for Serbian.");
      }
      forms = {
        "singular": info.subUnitSingular!,
        "plural2To4": info.subUnitPlural2To4!,
        "genitivePlural": info.subUnitPluralGenitive!,
      };
    } else {
      if (info.mainUnitPlural2To4 == null ||
          info.mainUnitPluralGenitive == null) {
        throw ArgumentError(
            "Main unit plural forms missing in CurrencyInfo for Serbian.");
      }
      forms = {
        "singular": info.mainUnitSingular,
        "plural2To4": info.mainUnitPlural2To4!,
        "genitivePlural": info.mainUnitPluralGenitive!,
      };
    }
    return _getPluralForm(amount, forms);
  }

  /// Core logic for determining the correct plural form based on Serbian rules.
  ///
  /// Uses the last one or two digits of the [amount].
  /// Applies rules for 1, 2-4, 11-19, and other cases (0, 5-9, ends in 0).
  ///
  /// @param amount The quantity determining the form.
  /// @param forms A map containing "singular", "plural2To4", "genitivePlural" keys.
  /// @return The selected word form string.
  String _getPluralForm(BigInt amount, Map<String, String> forms) {
    // Make amount non-negative for calculations. Zero uses genitive plural.
    final BigInt absAmount = amount.abs();
    final int lastDigit = (absAmount % BigInt.from(10)).toInt();
    final int lastTwoDigits = (absAmount % BigInt.from(100)).toInt();

    if (lastTwoDigits >= 11 && lastTwoDigits <= 19)
      return forms["genitivePlural"]!;
    if (lastDigit == 1) return forms["singular"]!;
    if (lastDigit >= 2 && lastDigit <= 4) return forms["plural2To4"]!;
    // Includes 0, 5, 6, 7, 8, 9, 10
    return forms["genitivePlural"]!;
  }

  /// Converts a non-negative [BigInt] into Serbian words, applying gender.
  ///
  /// Breaks number into scales (thousand, million...). Calls [_convertChunk] or recurses.
  /// Determines required gender based on scale word. Uses [_getPluralForm] for scale words.
  ///
  /// @param n Non-negative integer.
  /// @param defaultGender Default grammatical gender if no specific scale applies.
  /// @return Integer as Serbian words.
  String _convertInteger(BigInt n, {Gender defaultGender = Gender.masculine}) {
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.from(1000))
      return _convertChunk(n.toInt(), gender: defaultGender);

    _scaleWordForms.map((_) => BigInt.zero).toList(); // Placeholder sizes
    final scaleValues = [
      BigInt.one,
      BigInt.from(1000),
      BigInt.parse('1000000'),
      BigInt.parse('1000000000'),
      BigInt.parse('1000000000000'),
      BigInt.parse('1000000000000000'),
      BigInt.parse('1000000000000000000'),
      BigInt.parse('1000000000000000000000'),
      BigInt.parse('1000000000000000000000000'),
    ];

    List<String> parts = [];
    BigInt currentRemainder = n;

    for (int i = _scaleWordForms.length - 1; i >= 1; i--) {
      // Iterate scales downwards
      final scaleValue = scaleValues[i];
      final scaleInfo = _scaleWordForms[i];

      if (currentRemainder >= scaleValue) {
        BigInt multiplier = currentRemainder ~/ scaleValue;
        currentRemainder %= scaleValue;

        Gender requiredGender = defaultGender;
        if (scaleInfo["gender"] == "feminine")
          requiredGender = Gender.feminine;
        else if (scaleInfo["gender"] == "masculine")
          requiredGender = Gender.masculine;

        String multiplierText;
        String scaleWord = _getPluralForm(multiplier, scaleInfo);

        // Special case for 1000: "hiljadu" not "jedna hiljada"
        if (i == 1 && multiplier == BigInt.one) {
          multiplierText = "";
          scaleWord = scaleInfo["singular"]!; // Use accusative "hiljadu"
        } else {
          multiplierText =
              _convertInteger(multiplier, defaultGender: requiredGender);
        }

        parts.add(
            multiplierText.isEmpty ? scaleWord : "$multiplierText $scaleWord");
      }
    }

    // Handle the final remainder < 1000
    if (currentRemainder > BigInt.zero) {
      parts.add(_convertChunk(currentRemainder.toInt(), gender: defaultGender));
    }

    return parts.join(' ');
  }

  /// Converts an integer from 0 to 999 into Serbian words, applying [gender].
  ///
  /// Handles hundreds place, then calls [_convertUnder100] for the rest.
  ///
  /// @param n Integer chunk (0-999).
  /// @param gender Grammatical gender to apply.
  /// @return Chunk as Serbian words, or empty string if [n] is 0.
  String _convertChunk(int n, {required Gender gender}) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    List<String> words = [];
    int remainder = n;

    if (remainder >= 100) {
      words.add(_wordsHundreds[remainder ~/ 100]);
      remainder %= 100;
    }

    if (remainder > 0) {
      // Convert 0-99 part with gender. Serbian combines hundreds and tens/units with space.
      words.add(_convertUnder100(remainder, gender: gender));
    }

    return words.join(' ');
  }

  /// Converts an integer from 0 to 99 into Serbian words, applying [gender].
  ///
  /// Handles 0-19 directly (with gender for 1, 2). Combines tens and units for 20-99.
  ///
  /// @param n Integer (0-99).
  /// @param gender Grammatical gender to apply.
  /// @return Number as Serbian words.
  String _convertUnder100(int n, {required Gender gender}) {
    if (n < 0 || n >= 100) throw ArgumentError("Number must be 0-99: $n");

    if (n < 20) {
      if (n == 1 && gender == Gender.feminine) return _oneFem;
      if (n == 2 && gender == Gender.feminine) return _twoFem;
      return _wordsUnder20Masc[n]; // Default to masculine
    }

    String tensWord = _wordsTens[n ~/ 10];
    int unit = n % 10;
    if (unit == 0) return tensWord;

    // Recursively call for unit, applying gender.
    String unitWord = _convertUnder100(unit, gender: gender);
    return "$tensWord $unitWord"; // e.g., "dvadeset jedan"
  }
}
