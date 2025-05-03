import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ta_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ta}
/// Converts numbers to Tamil words (`Lang.TA`).
///
/// Implements [Num2TextBase] for Tamil. Handles various numeric types.
/// Supports cardinal numbers, decimals, negatives, currency, years.
/// Uses the Indian numbering system (Lakh, Crore) and Tamil combining forms/sandhi.
/// Customizable via [TaOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextTA implements Num2TextBase {
  // --- Constants ---
  static const String _pointWordDefault = "புள்ளி"; // Default for "."
  static const String _commaWord = "காற்புள்ளி"; // For ","
  static const String _zero = "பூஜ்ஜியம்";
  static const String _infinity = "முடிவிலி";
  static const String _negativeInfinityPrefix = "எதிர்மறை";
  static const String _nan = "எண் அல்ல"; // Not a Number
  static const String _yearSuffixAD = "கி.பி."; // After Christ
  static const String _yearSuffixBC = "கி.மு."; // Before Christ
  static const String _currencySeparator =
      "மற்றும்"; // Default "and" for currency
  static const String _oneAdjectival =
      "ஒரு"; // Adjectival "one" (e.g., ஒரு ரூபாய்)

  /// Words for 0-19.
  static const List<String> _wordsUnder20 = [
    _zero,
    "ஒன்று",
    "இரண்டு",
    "மூன்று",
    "நான்கு",
    "ஐந்து",
    "ஆறு",
    "ஏழு",
    "எட்டு",
    "ஒன்பது",
    "பத்து",
    "பதினொன்று",
    "பன்னிரண்டு",
    "பதின்மூன்று",
    "பதினான்கு",
    "பதினைந்து",
    "பதினாறு",
    "பதினேழு",
    "பதினெட்டு",
    "பத்தொன்பது",
  ];

  /// Words for exact tens (20, 30,... 90).
  static const List<String> _wordsTens = [
    "",
    "",
    "இருபது",
    "முப்பது",
    "நாற்பது",
    "ஐம்பது",
    "அறுபது",
    "எழுபது",
    "எண்பது",
    "தொண்ணூறு",
  ];

  /// Combining forms for tens (20+, 30+,... 90+) used before units.
  static const List<String> _wordsTensCombining = [
    "",
    "",
    "இருபத்தி",
    "முப்பத்தி",
    "நாற்பத்தி",
    "ஐம்பத்தி",
    "அறுபத்தி",
    "எழுபத்தி",
    "எண்பத்தி",
    "தொண்ணூற்றி",
  ];

  static const String _hundred = "நூறு";

  /// Words for exact hundreds (100, 200,... 900).
  static const Map<int, String> _hundredsMap = {
    1: _hundred,
    2: "இருநூறு",
    3: "முந்நூறு",
    4: "நானூறு",
    5: "ஐந்நூறு",
    6: "அறுநூறு",
    7: "எழுநூறு",
    8: "எண்ணூறு",
    9: "தொள்ளாயிரம்",
  };

  /// Combining forms for hundreds (100+, 200+,... 900+) used before tens/units.
  static const Map<int, String> _hundredsCombiningMap = {
    1: "நூற்றி",
    2: "இருநூற்று",
    3: "முந்நூற்று",
    4: "நானூற்று",
    5: "ஐந்நூற்று",
    6: "அறுநூற்று",
    7: "எழுநூற்று",
    8: "எண்ணூற்று",
    9: "தொள்ளாயிரத்து",
  };

  static const String _thousand = "ஆயிரம்";

  /// Combining suffix for 1000 before units/tens (but not hundreds).
  static const String _thousandCombiningOneSuffix = "ஆயிரத்தி";

  /// General combining suffix for 1000+ before hundreds.
  static const String _thousandCombiningGeneralSuffix = "ஆயிரத்து";

  static const String _lakh = "லட்சம்"; // 100,000
  static const String _lakhCombining = "லட்சத்து"; // Combining form for Lakh

  static const String _crore = "கோடி"; // 10,000,000
  static const String _croreCombining = "கோடியே"; // Combining form for Crore

  static final BigInt _bigZero = BigInt.zero;
  static final BigInt _bigOne = BigInt.one;
  static final BigInt _big100 = BigInt.from(100);
  static final BigInt _big1000 = BigInt.from(1000);
  static final BigInt _big100000 = BigInt.from(100000); // Lakh
  static final BigInt _big10000000 = BigInt.from(10000000); // Crore

  /// Processes the given [number] into Tamil words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [TaOptions] for customization (currency, year format, decimals, AD/BC).
  /// Defaults apply if [options] is null or not [TaOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or default Tamil error message on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [TaOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Tamil words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final TaOptions taOptions =
        options is TaOptions ? options : const TaOptions();

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative
            ? "$_negativeInfinityPrefix $_infinity"
            : _infinity;
      if (number.isNaN) return fallbackOnError ?? _nan;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return fallbackOnError ?? _nan;

    if (decimalValue == Decimal.zero) {
      if (taOptions.currency) {
        final String mainUnit = taOptions.currencyInfo.mainUnitPlural ??
            taOptions.currencyInfo.mainUnitSingular;
        return "$_zero $mainUnit";
      }
      return _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    if (taOptions.format == Format.year) {
      // Years typically don't use fractional parts.
      textResult = _convertInteger(absValue.truncate().toBigInt());
      if (isNegative)
        textResult += " $_yearSuffixBC";
      else if (taOptions.includeAD) textResult += " $_yearSuffixAD";
    } else {
      textResult = taOptions.currency
          ? _handleCurrency(absValue, taOptions)
          : _handleStandardNumber(absValue, taOptions);
      if (isNegative) textResult = "${taOptions.negativePrefix} $textResult";
    }

    return textResult.trim();
  }

  /// Converts a non-negative [Decimal] to Tamil currency words.
  ///
  /// Uses [TaOptions.currencyInfo] for unit names. Handles main and subunits.
  /// Uses the adjectival form "ஒரு" for one unit/subunit.
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Tamil words.
  String _handleCurrency(Decimal absValue, TaOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final Decimal subunitMultiplier =
        Decimal.fromInt(100); // Assuming 100 subunits
    final Decimal valueToConvert =
        absValue; // Rounding not explicitly handled by options/tests
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round(scale: 0).toBigInt();

    String mainText = "";
    String mainUnitName = "";
    String result = "";

    if (mainValue > _bigZero) {
      mainText =
          (mainValue == _bigOne) ? _oneAdjectival : _convertInteger(mainValue);
      mainUnitName = (mainValue == _bigOne)
          ? currencyInfo.mainUnitSingular
          : (currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular);
      result = '$mainText $mainUnitName';
    }

    if (subunitValue > _bigZero && currencyInfo.subUnitSingular != null) {
      String subunitText = (subunitValue == _bigOne)
          ? _oneAdjectival
          : _convertInteger(subunitValue);
      String subUnitName = (subunitValue == _bigOne)
          ? currencyInfo.subUnitSingular!
          : (currencyInfo.subUnitPlural ?? currencyInfo.subUnitSingular!);

      if (result.isNotEmpty) {
        final String separator = currencyInfo.separator ?? _currencySeparator;
        result += ' $separator $subunitText $subUnitName';
      } else {
        result = '$subunitText $subUnitName';
      }
    } else if (result.isEmpty) {
      // Handles case where input was exactly 0.00
      final String mainUnit =
          currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;
      return "$_zero $mainUnit";
    }

    return result;
  }

  /// Converts a non-negative standard [Decimal] number to Tamil words.
  ///
  /// Handles integer and fractional parts. Uses [TaOptions.decimalSeparator] word.
  /// Fractional part converted digit by digit, trimming trailing zeros.
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Tamil words.
  String _handleStandardNumber(Decimal absValue, TaOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Special case for exactly 1000.
    if (integerPart == _big1000 && fractionalPart == Decimal.zero)
      return _thousand;

    String integerWords =
        (integerPart == _bigZero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _commaWord;
          break;
        default:
          separatorWord = _pointWordDefault;
          break;
      }
      String fractionalDigits = absValue.toString().split('.').last;

      // Trim trailing zeros for standard decimal representation.
      int lastNonZero = fractionalDigits.length - 1;
      while (lastNonZero >= 0 && fractionalDigits[lastNonZero] == '0') {
        lastNonZero--;
      }

      if (lastNonZero >= 0) {
        fractionalDigits = fractionalDigits.substring(0, lastNonZero + 1);
        List<String> digitWords = fractionalDigits.split('').map((d) {
          final int? i = int.tryParse(d);
          return (i != null && i >= 0 && i <= 9) ? _wordsUnder20[i] : '?';
        }).toList();
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    } else if (integerPart > _bigZero &&
        absValue.scale > 0 &&
        absValue.isInteger) {
      // Handles cases like Decimal("1.0") - no fractional part needed.
    }

    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] into Tamil words using the Indian numbering system.
  /// Handles crores, lakhs, thousands, hundreds, tens, and units with appropriate combining forms.
  ///
  /// @param n The non-negative integer to convert.
  /// @return The integer as Tamil words.
  String _convertInteger(BigInt n) {
    if (n < _bigZero) throw ArgumentError("Input must be non-negative: $n");
    if (n == _bigZero) return _zero; // Return "பூஜ்ஜியம்" for standalone zero

    // Handle numbers below 1 Crore directly for efficiency.
    if (n < _big10000000) {
      return _convertBelowCrore(n);
    }

    // Handle numbers involving Crores recursively.
    List<Map<String, dynamic>> segments = [];
    BigInt currentN = n;
    int croreLevel = 0;

    // Break down the number into segments of Crores.
    while (currentN > _bigZero) {
      BigInt segmentValue =
          currentN % _big10000000; // Value below the next Crore level
      currentN ~/= _big10000000; // Move to the next Crore level
      String segmentWords =
          segmentValue > _bigZero ? _convertBelowCrore(segmentValue) : "";
      segments.add(
          {'level': croreLevel, 'value': segmentValue, 'words': segmentWords});
      croreLevel++;
    }

    // Combine the Crore segments.
    List<String> resultParts = [];
    for (int i = segments.length - 1; i >= 0; i--) {
      var segment = segments[i];
      BigInt value = segment['value'];
      String words = segment['words'];
      int level = segment['level'];

      if (value == _bigZero) continue; // Skip empty segments

      String partForLevel;
      // Use adjectival "ஒரு" for "one crore", "one crore crore", etc.
      if (value == _bigOne && level > 0) {
        partForLevel = _oneAdjectival;
      } else {
        partForLevel = words; // Words for the segment value itself
      }

      if (level > 0) {
        // Add "Crore" suffixes
        String scaleSuffix =
            List.filled(level, _crore).join(' '); // கோடி, கோடி கோடி, etc.
        partForLevel += (partForLevel.isNotEmpty ? " " : "") + scaleSuffix;
      }

      // Check if there are lower non-zero segments to apply the combining form "கோடியே".
      bool lowerNonZeroExists = false;
      for (int j = i - 1; j >= 0; j--) {
        if (segments[j]['value'] > _bigZero) {
          lowerNonZeroExists = true;
          break;
        }
      }

      // Apply combining form "கோடியே" if needed.
      if (lowerNonZeroExists && level > 0 && partForLevel.endsWith(_crore)) {
        partForLevel =
            partForLevel.substring(0, partForLevel.length - _crore.length) +
                _croreCombining;
      }

      if (partForLevel.isNotEmpty) {
        resultParts.add(partForLevel);
      }
    }

    return resultParts.join(' ');
  }

  /// Converts a number below 1 Crore (0 to 9,999,999) into Tamil words.
  /// Handles lakhs, thousands, and the remaining part below 1000.
  ///
  /// @param n The integer below 1 Crore.
  /// @return The number as Tamil words, or empty string if n is 0.
  String _convertBelowCrore(BigInt n) {
    if (n >= _big10000000 || n < _bigZero)
      throw ArgumentError("Input must be 0 to 9,999,999: $n");
    if (n == _bigZero) return "";

    List<String> parts = [];
    BigInt remaining = n;

    // 1. Lakhs (0-99)
    BigInt lakhs = remaining ~/ _big100000;
    remaining %= _big100000;
    if (lakhs > _bigZero) {
      String lakhCountWords = _convertBelowHundred(lakhs.toInt());
      bool needsCombiningLakh = remaining > _bigZero;
      String lakhSuffix = needsCombiningLakh ? _lakhCombining : _lakh;
      String lakhWords = (lakhs == _bigOne)
          ? "$_oneAdjectival $lakhSuffix"
          : "$lakhCountWords $lakhSuffix";
      parts.add(lakhWords);
    }

    // 2. Thousands (0-99)
    BigInt thousands = remaining ~/ _big1000;
    remaining %= _big1000;
    if (thousands > _bigZero) {
      String thousandCountWords = _convertBelowHundred(thousands.toInt());
      bool needsCombiningThousand = remaining > _bigZero;
      String thousandSuffix;
      String thousandWords;

      if (thousands == _bigOne) {
        // Handle "one thousand..." case
        if (needsCombiningThousand) {
          // Use "ஆயிரத்தி" before units/tens, "ஆயிரத்து" before hundreds.
          thousandSuffix = (remaining < _big100)
              ? _thousandCombiningOneSuffix
              : _thousandCombiningGeneralSuffix;
          thousandWords =
              thousandSuffix; // Just the combining suffix for "one thousand..."
        } else {
          thousandWords = _thousand; // "ஆயிரம்"
        }
      } else {
        // Handle "two thousand...", "twenty thousand..." etc.
        thousandSuffix = needsCombiningThousand
            ? _thousandCombiningGeneralSuffix
            : _thousand;
        // Apply sandhi (joining rules) between the count and the thousand word/suffix.
        thousandWords =
            _applySandhiToThousand(thousandCountWords, thousandSuffix);
      }
      parts.add(thousandWords);
    }

    // 3. Remainder below 1000 (0-999)
    if (remaining > _bigZero) {
      parts.add(_convertBelowThousand(remaining.toInt()));
    }

    return parts.where((part) => part.isNotEmpty).join(' ');
  }

  /// Applies Tamil sandhi (joining rules) when a number word precedes "ஆயிரம்" or its combining forms.
  ///
  /// @param countText The word(s) for the number preceding thousand (e.g., "ஐந்து", "நாற்பத்தி ஐந்து").
  /// @param thousandSuffix The thousand word or suffix ("ஆயிரம்" or "ஆயிரத்து").
  /// @return The combined string with sandhi applied.
  String _applySandhiToThousand(String countText, String thousandSuffix) {
    List<String> countParts = countText.split(' ');
    String lastWord = countParts.last; // Word immediately before thousand
    String firstPart = countParts.length > 1
        ? '${countParts.first} '
        : ''; // Tens part, if any

    // Determine the remainder of the suffix (e.g., "யிரம்" from "ஆயிரம்").
    String suffixRemainder =
        thousandSuffix.substring(1); // Assumes starts with 'ஆ'

    // Map of base number words to their roots when combining with a vowel (like 'ஆ').
    const Map<String, String> sandhiRoots = {
      "ஒன்று": "ஓரா",
      "இரண்டு": "இரண்டா",
      "மூன்று": "மூவா",
      "நான்கு": "நான்கா",
      "ஐந்து": "ஐயா",
      "ஆறு": "ஆறா",
      "ஏழு": "ஏழா",
      "எட்டு": "எண்ணா",
      "ஒன்பது": "ஒன்பதா",
      "பத்து": "பத்தா",
      "பதினொன்று": "பதினோறா",
      "பன்னிரண்டு": "பன்னிரண்டா",
      "இருபது": "இருபதா",
      "முப்பது": "முப்பதா",
      "நாற்பது": "நாற்பதா",
      "ஐம்பது": "ஐம்பதா",
      "அறுபது": "அறுபதா",
      "எழுபது": "எழுபதா",
      "எண்பது": "எண்பதா",
      "தொண்ணூறு": "தொண்ணூறா",
      "நூறு": "நூறா",
    };

    // Specific rule: ஐம்பது + ஆயிரம் = ஐம்பதாயிரம்
    if (lastWord == "ஐம்பது" && thousandSuffix == _thousand)
      return "$firstPartஐம்பதாயிரம்";
    // Apply general sandhi rule if a root exists.
    if (sandhiRoots.containsKey(lastWord)) {
      return firstPart + sandhiRoots[lastWord]! + suffixRemainder;
    }
    // Default: No specific sandhi, just join with space.
    return "$countText $thousandSuffix";
  }

  /// Converts an integer between 0 and 999 into Tamil words.
  /// Handles hundreds and the 0-99 part using [_convertBelowHundred].
  /// Uses appropriate combining forms for hundreds.
  ///
  /// @param n Integer 0-999.
  /// @return Tamil words for the number, or empty string if n is 0.
  String _convertBelowThousand(int n) {
    if (n == 0) return "";
    if (n < 0 || n > 999) throw ArgumentError("Input must be 0-999: $n");

    List<String> words = [];
    int hundredDigit = n ~/ 100;
    int remainder = n % 100;

    if (hundredDigit > 0) {
      // Use exact hundreds word if no remainder, combining form otherwise.
      words.add(remainder == 0
          ? _hundredsMap[hundredDigit]!
          : _hundredsCombiningMap[hundredDigit]!);
    }
    if (remainder > 0) {
      words.add(_convertBelowHundred(remainder));
    }
    return words.join(' ');
  }

  /// Converts an integer between 0 and 99 into Tamil words.
  /// Handles 0-19 directly, uses combining forms for 20-99.
  ///
  /// @param n Integer 0-99.
  /// @return Tamil words for the number, or empty string if n is 0.
  String _convertBelowHundred(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 100) throw ArgumentError("Input must be 0-99: $n");

    if (n < 20) return _wordsUnder20[n];

    int tenDigit = n ~/ 10;
    int unitDigit = n % 10;

    if (unitDigit == 0) {
      return _wordsTens[tenDigit]; // Exact tens word (e.g., "இருபது")
    } else {
      // Combining tens form + unit word (e.g., "இருபத்தி" + " " + "ஒன்று")
      return "${_wordsTensCombining[tenDigit]} ${_wordsUnder20[unitDigit]}";
    }
  }
}
