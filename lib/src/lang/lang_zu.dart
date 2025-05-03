// ignore_for_file: constant_identifier_names

import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/zu_options.dart';
import '../utils/utils.dart';

enum _NounClass {
  cl5_S,
  cl6_P,
  cl7_S,
  cl8_P,
  cl9_S,
  cl10_P,
  unknown,
}

class Num2TextZU implements Num2TextBase {
  static const String _zero = "qanda";
  static const String _pointWord = "iphoyinti";
  static const String _commaWord = "ukhefana";
  static const String _yearSuffixBC = "BC";
  static const String _yearSuffixAD = "AD";

  static const Map<int, String> _fullBaseNumbers = {
    1: "nye",
    2: "bili",
    3: "thathu",
    4: "ne",
    5: "hlanu",
    6: "sithupha",
    7: "khombisa",
    8: "shiyagalombili",
    9: "shiyagalolunye",
  };

  static const Map<_NounClass, String> _oneStems = {
    _NounClass.cl5_S: "lodwa",
    _NounClass.cl6_P: "odwa",
    _NounClass.cl7_S: "sodwa",
    _NounClass.cl8_P: "zodwa",
    _NounClass.cl9_S: "yodwa",
    _NounClass.cl10_P: "zodwa",
    _NounClass.unknown: "dwa",
  };

  static const Map<int, String> _tens = {
    10: "lishumi",
    20: "amashumi amabili",
    30: "amashumi amathathu",
    40: "amashumi amane",
    50: "amashumi amahlanu",
    60: "amashumi ayisithupha",
    70: "amashumi ayisikhombisa",
    80: "amashumi ayisishiyagalombili",
    90: "amashumi ayisishiyagalolunye",
  };

  static const String _hundred = "ikhulu";

  static const Map<int, _ScaleInfo> _scales = {
    3: _ScaleInfo(
      "inkulungwane",
      _NounClass.cl9_S,
      "izinkulungwane",
      _NounClass.cl10_P,
    ),
    6: _ScaleInfo("isigidi", _NounClass.cl7_S, "izigidi", _NounClass.cl8_P),
    9: _ScaleInfo(
      "ibhiliyoni",
      _NounClass.cl5_S,
      "amabhiliyoni",
      _NounClass.cl6_P,
    ),
    12: _ScaleInfo(
      "ithriliyoni",
      _NounClass.cl5_S,
      "amathriliyoni",
      _NounClass.cl6_P,
    ),
    15: _ScaleInfo(
      "ikhwadriliyoni",
      _NounClass.cl5_S,
      "amakhwadriliyoni",
      _NounClass.cl6_P,
    ),
    18: _ScaleInfo(
      "ikhwintiliyoni",
      _NounClass.cl5_S,
      "amakhwintiliyoni",
      _NounClass.cl6_P,
    ),
    21: _ScaleInfo(
      "isekstiliyoni",
      _NounClass.cl7_S,
      "amasekstiliyoni",
      _NounClass.cl6_P,
    ),
    24: _ScaleInfo(
        "iseptiliyoni", _NounClass.cl7_S, "amaseptiliyoni", _NounClass.cl6_P),
  };

  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final ZuOptions zuOptions =
        options is ZuOptions ? options : const ZuOptions();

    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? "Okubi Okungapheli" : "Okungapheli";
      }
      if (number.isNaN) {
        return fallbackOnError ?? "Akulona Inani";
      }
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return fallbackOnError ?? "Akulona Inani";

    if (decimalValue == Decimal.zero) {
      if (zuOptions.currency) {
        return "$_zero ${_getCurrencyUnitName(BigInt.zero, false, zuOptions.currencyInfo)}";
      }
      if (zuOptions.format == Format.year) return _zero;
      return _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    final bool isCurrency = zuOptions.currency;
    final bool isYear = zuOptions.format == Format.year;

    if (isYear) {
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), zuOptions);
    } else if (isCurrency) {
      textResult = _handleCurrency(absValue, zuOptions);
    } else {
      textResult = _handleStandardNumber(absValue, zuOptions);
    }

    if (isNegative && !isYear) {
      String prefix = zuOptions.negativePrefix;
      textResult = prefix.endsWith(" ") || prefix == "-"
          ? "$prefix$textResult"
          : "$prefix $textResult";
    }

    return textResult.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _handleCurrency(Decimal absValue, ZuOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2;
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round().toBigInt();

    String mainText = "";
    String subText = "";

    if (mainValue > BigInt.zero) {
      if (mainValue >= BigInt.from(10).pow(6)) {
        // Case 1: Main value is a scale number (million+)
        // Convert the number using standard scale conversion.
        String standardAmountWords = _convertIntegerStandard(mainValue);
        // Append the plural currency unit name.
        mainText = "$standardAmountWords ${currencyInfo.mainUnitPlural!}";
      } else {
        // Case 2: Main value is below a million
        // Determine the currency noun (singular/plural) and its class.
        String mainUnitName =
            _getCurrencyUnitName(mainValue, false, currencyInfo);
        _NounClass mainClass = _getCurrencyUnitClass(mainValue, false);

        // Get the number word, agreed with the currency noun.
        String agreedMainNumText = _getAgreedNumberForm(
          mainValue,
          mainClass,
        );
        // Combine: Currency Noun + Agreed Number Word
        mainText = "$mainUnitName $agreedMainNumText";
      }
    }

    if (subunitValue > BigInt.zero) {
      String subUnitName =
          _getCurrencyUnitName(subunitValue, true, currencyInfo);

      if (_isSubunitSingularSpecial(
          subunitValue, true, currencyInfo, subUnitName)) {
        subText = "isenti elilodwa";
      } else {
        _NounClass subClass = _getCurrencyUnitClass(subunitValue, true);
        String agreedSubNumText = _getAgreedNumberForm(
          subunitValue,
          subClass,
        );
        subText = "$subUnitName $agreedSubNumText";
      }
    }

    if (mainText.isNotEmpty && subText.isNotEmpty) {
      String particle = currencyInfo.separator ??
          _determineJoinParticle(subText.split(' ').first);
      return '$mainText ${_applyParticle(particle, subText)}';
    } else {
      return mainText.isNotEmpty
          ? mainText
          : subText.isNotEmpty
              ? subText
              : "$_zero ${_getCurrencyUnitName(BigInt.zero, false, currencyInfo)}";
    }
  }

  String _getAgreedNumberForm(BigInt number, _NounClass targetClass) {
    if (targetClass == _NounClass.unknown) {
      return _convertIntegerStandard(number);
    }

    if (number == BigInt.one) {
      String prefix =
          _getConcordPrefix(1, targetClass, useCurrencyConcord: true);
      String stem = _oneStems[targetClass] ?? _oneStems[_NounClass.unknown]!;
      return _applyPrefix(prefix, stem);
    }

    // For numbers > 1, get the standard word and apply prefix based on target class.
    // Assuming this is used for amounts < 1,000,000 in currency context.
    // We need to handle the prefix application carefully for numbers > 99 (like 123).
    // Based on test 123 (`amaRandi ayikhulu namashumi...`), the agreement seems
    // applied to the structure built by _convertBelow1000Standard.
    String standardText = _convertIntegerStandard(
        number); // Will call _convertBelow1000Standard for < 1000

    // Use the integer value for prefix determination logic, assuming it's < 1M.
    int numInt = number.toInt();
    String prefix =
        _getConcordPrefix(numInt, targetClass, useCurrencyConcord: true);

    return _applyPrefix(prefix, standardText);
  }

  String _convertIntegerStandard(BigInt n) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) {
      throw ArgumentError("Integer must be non-negative: $n");
    }

    if (n < BigInt.from(1000)) {
      return _convertBelow1000Standard(n.toInt());
    }

    List<String> scaleParts = [];
    BigInt remaining = n;
    List<int> sortedScales = _scales.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    for (int power in sortedScales) {
      if (remaining == BigInt.zero) break;
      BigInt scaleValue = BigInt.from(10).pow(power);

      if (remaining >= scaleValue) {
        BigInt chunkCount = remaining ~/ scaleValue;
        remaining %= scaleValue;

        if (chunkCount > BigInt.zero) {
          _ScaleInfo scaleInfo = _scales[power]!;
          bool isSingularScaleCount = chunkCount == BigInt.one;
          String scaleWord =
              isSingularScaleCount ? scaleInfo.singular : scaleInfo.plural;
          _NounClass scaleClass = isSingularScaleCount
              ? scaleInfo.singularClass
              : scaleInfo.pluralClass;

          String countWord;
          // Special case: "one thousand" is just "inkulungwane", not "eyodwa inkulungwane".
          if (isSingularScaleCount && power == 3) {
            countWord = ""; // Explicitly empty for "one thousand"
          } else {
            // For any other count (including "one" of other scales), get the agreed form.
            countWord = _getAgreedNumberForm(chunkCount, scaleClass);
          }

          // Combine scale word and its count. Order is Scale Word + Count Word when countWord is not empty.
          String scaleText =
              countWord.isEmpty ? scaleWord : "$scaleWord $countWord";
          scaleParts.add(scaleText);
        }
      }
    }

    String below1000Text = "";
    if (remaining > BigInt.zero) {
      below1000Text = _convertBelow1000Standard(remaining.toInt());
    }

    List<String> finalParts = [];
    if (scaleParts.isNotEmpty) {
      finalParts.add(scaleParts[0]);
      for (int i = 1; i < scaleParts.length; i++) {
        String particle = _determineJoinParticle(scaleParts[i]);
        finalParts.add(_applyParticle(particle, scaleParts[i]));
      }
    }
    if (below1000Text.isNotEmpty) {
      if (finalParts.isNotEmpty) {
        String particle = _determineJoinParticle(below1000Text);
        finalParts.add(_applyParticle(particle, below1000Text));
      } else {
        finalParts.add(below1000Text);
      }
    }
    return finalParts.join(' ');
  }

  String _convertBelow1000Standard(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Number must be between 0 and 999: $n");
    }

    String? hundredsPart;
    int remainder = n;

    if (remainder >= 100) {
      int hundredCount = remainder ~/ 100;
      remainder %= 100;

      if (hundredCount == 1) {
        hundredsPart = _hundred; // e.g., "ikhulu"
      } else {
        // Get the agreed form of the number counting 'amakhulu' (cl6_P)
        String countWord =
            _getNumberWordStandard(hundredCount, _NounClass.cl6_P);
        // Corrected order: noun first, then number agreement
        hundredsPart = "amakhulu $countWord"; // e.g., "amakhulu amabili"
      }
    }

    String? tensUnitsText;
    if (remainder > 0) {
      if (remainder < 10) {
        // Simple units 1-9 (no internal agreement needed here)
        tensUnitsText = _getNumberWordStandard(remainder, _NounClass.unknown);
      } else if (remainder == 10) {
        // Ten (no internal agreement needed here)
        tensUnitsText = _getNumberWordStandard(10, _NounClass.unknown);
      } else if (remainder < 20) {
        // Numbers 11-19: "lishumi" + particle + unit
        String tensPart = _tens[10]!; // "lishumi"
        String unitWord = _fullBaseNumbers[remainder % 10]!;
        String particle = _determineJoinParticle(unitWord);
        // Apply particle (handles vowel coalescence etc.)
        tensUnitsText =
            "$tensPart ${_applyParticle(particle, unitWord)}"; // e.g., "lishumi nanye"
      } else {
        // Numbers 20-99
        int tenVal = (remainder ~/ 10) * 10; // e.g., 20, 30...
        int unitVal = remainder % 10; // e.g., 1, 2...

        // Get the base word for the tens (e.g., "amashumi amabili")
        // This call handles the internal agreement of the count with 'amashumi'
        String baseTensWord = _getNumberWordStandard(tenVal, _NounClass.cl6_P);

        if (unitVal == 0) {
          // Just the tens word if no units (e.g., "amashumi amabili")
          tensUnitsText = baseTensWord;
        } else {
          // Tens + particle + unit
          String unitWord = _fullBaseNumbers[unitVal]!;
          String particle = _determineJoinParticle(unitWord);
          // Apply particle
          tensUnitsText =
              "$baseTensWord ${_applyParticle(particle, unitWord)}"; // e.g., "amashumi amabili nanye"
        }
      }
    }

    // Combine hundreds and tens/units parts with the correct particle
    if (hundredsPart != null && tensUnitsText != null) {
      String particle = _determineJoinParticle(tensUnitsText);
      return "$hundredsPart ${_applyParticle(particle, tensUnitsText)}"; // e.g., "ikhulu nanye"
    } else {
      // Return whichever part is not null, or empty string if n was 0 initially
      return hundredsPart ?? tensUnitsText ?? "";
    }
  }

  String _getNumberWordStandard(int number, _NounClass internalTargetClass) {
    // Apply specific prefixes for numbers 2-9 when agreeing with Class 6 Plural nouns
    // (like 'amakhulu', 'amashumi'). This is for *internal* agreement within the number word.
    if (internalTargetClass == _NounClass.cl6_P) {
      if (number >= 2 && number <= 5) {
        String prefix = "ama"; // a- + ma-
        String base = _fullBaseNumbers[number]!;
        return _applyPrefix(prefix, base); // e.g., ama + bili -> amabili
      }
      if (number >= 6 && number <= 9) {
        String prefix = "ayi"; // a- + yi-
        String base = _fullBaseNumbers[number]!;
        return _applyPrefix(
            prefix, base); // e.g., ayi + sithupha -> ayisithupha
      }
      // Handle tens agreeing with cl6_P (e.g., for hundreds like "200" -> "amakhulu amabili")
      if (number >= 20 && number <= 90 && number % 10 == 0) {
        int count = number ~/ 10;
        // Get the agreed form for the count (e.g., 'amabili' for 2)
        String countWord = _getNumberWordStandard(count, _NounClass.cl6_P);
        // Corrected order: noun first, then number agreement
        return "amashumi $countWord"; // e.g., "amashumi amabili" (20)
      }
    }

    // Fallback to base numbers or tens if no specific cl6 agreement needed here
    // or if the target class wasn't cl6_P.
    if (_fullBaseNumbers.containsKey(number)) {
      return _fullBaseNumbers[number]!;
    }
    if (_tens.containsKey(number)) {
      // This includes the standard tens forms like "amashumi amabili"
      // which are already correct for standalone use or when agreement is handled externally.
      return _tens[number]!;
    }
    if (number == 100) {
      return _hundred;
    }

    // If not a base number/ten/hundred, assume it's a compound number below 1000
    // and convert it standardly. This path shouldn't be hit if called correctly
    // from _convertBelow1000Standard.
    return _convertBelow1000Standard(number);
  }

  String _applyParticle(String particle, String text) {
    text = text.trim();
    if (text.isEmpty) return "";
    String firstWord = text.split(' ').first;
    var words = text.split(' ');
    String restOfText =
        words.length > 1 ? ' ${words.sublist(1).join(' ')}' : '';

    if (particle == "nan") {
      if (firstWord == "hlanu") return "nanhlanu$restOfText";
      if (firstWord == "thathu") return "nanthathu$restOfText";
      return "nan $text";
    }

    String originalFirstLetterLower =
        firstWord.isNotEmpty ? firstWord[0].toLowerCase() : "";

    if (particle == "ne") {
      if (firstWord == "lishumi") return "nelishumi$restOfText";
      if (firstWord == "sithupha") return "nesithupha$restOfText";
      if (firstWord == "khombisa") return "nesikhombisa$restOfText";
      if (firstWord == "shiyagalombili") return "nesishiyagalombili$restOfText";
      if (firstWord == "shiyagalolunye") return "nesishiyagalolunye$restOfText";
      if (originalFirstLetterLower == 'i' || originalFirstLetterLower == 'e') {
        return "ne${text.substring(1)}";
      }
      return "ne $text";
    } else if (particle == "no") {
      if (originalFirstLetterLower == 'u' || originalFirstLetterLower == 'o') {
        return "no${text.substring(1)}";
      }
      return "no $text";
    } else if (particle == "na") {
      // Specific fusions/changes with 'na' that are not simple na+vowel coalescence
      if (firstWord == "nye") return "nanye$restOfText";
      if (firstWord == "bili") return "nambili$restOfText";
      if (firstWord == "thathu")
        return "nanthathu$restOfText"; // Specific fusion nanthathu
      if (firstWord == "ne") return "nane$restOfText";

      // General Vowel coalescence: na + a... -> na...
      // This rule covers amashumi, amakhulu, amabhiliyoni, amathriliyoni, etc.
      if (originalFirstLetterLower == 'a') {
        return "na${text.substring(1)}";
      }

      // Default 'na' application (before consonants or unhandled vowels). Needs space.
      // This should be the last check for the 'na' particle.
      return "na $text";
    }

    // Fallback if particle wasn't handled (shouldn't happen).
    return "$particle $text";
  }

  String _handleStandardNumber(Decimal absValue, ZuOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertIntegerStandard(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _commaWord;
          break;
        case DecimalSeparator.period:
        case DecimalSeparator.point:
        default:
          separatorWord = _pointWord;
          break;
      }
      String fractionalDigits = fractionalPart.toString();
      // Ensure we get the part AFTER the decimal point, handling potential leading zeros in the fractional part string
      int decimalPointIndex = fractionalDigits.indexOf('.');
      if (decimalPointIndex == -1) {
        // This case should ideally not happen if fractionalPart > Decimal.zero
        fractionalDigits = '';
      } else {
        fractionalDigits = fractionalDigits.substring(decimalPointIndex + 1);
      }

      List<String> digitWords = fractionalDigits.split('').map((digit) {
        final int? digitInt = int.tryParse(digit);
        if (digitInt == null || digitInt < 0 || digitInt > 9) {
          return '?'; // Placeholder for non-digit characters
        }
        // Use correct Zulu words for each digit 0-9 after the decimal point
        switch (digitInt) {
          case 0:
            return _zero; // qanda
          case 1:
            return _fullBaseNumbers[1]!; // nye
          case 2:
            return _fullBaseNumbers[2]!; // bili
          case 3:
            return _fullBaseNumbers[3]!; // thathu
          case 4:
            return "kane"; // Specific form for 4 after decimal
          case 5:
            return _fullBaseNumbers[5]!; // hlanu
          case 6:
            return _fullBaseNumbers[6]!; // sithupha
          case 7:
            return _fullBaseNumbers[7]!; // khombisa
          case 8:
            return _fullBaseNumbers[8]!; // shiyagalombili
          case 9:
            return _fullBaseNumbers[9]!; // shiyagalolunye
          default:
            return '?'; // Should not be reached
        }
      }).toList();

      fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
    }
    return '$integerWords$fractionalWords'.trim();
  }

  String _handleYearFormat(BigInt year, ZuOptions options) {
    final bool isNegative = year < BigInt.zero;
    final BigInt absYear = isNegative ? -year : year;

    String yearText = _convertIntegerStandard(absYear);

    if (isNegative) {
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD && absYear > BigInt.zero) {
      yearText += " $_yearSuffixAD";
    }
    return yearText;
  }

  _NounClass _getCurrencyUnitClass(BigInt amount, bool isSubunit) {
    bool isSingular = amount == BigInt.one;
    if (isSubunit) {
      // Cent: cl 7 (isenti) singular, cl 6 (amasenti) plural
      return isSingular ? _NounClass.cl7_S : _NounClass.cl6_P;
    } else {
      // Rand: cl 5 (iRandi) singular, cl 6 (amaRandi) plural
      return isSingular ? _NounClass.cl5_S : _NounClass.cl6_P;
    }
  }

  bool _isSubunitSingularSpecial(
    BigInt amount,
    bool checkSubunit,
    CurrencyInfo info,
    String subunitName,
  ) {
    return checkSubunit &&
        amount == BigInt.one &&
        subunitName == info.subUnitSingular &&
        info.subUnitSingular == "isenti";
  }

  String _determineJoinParticle(String nextWord) {
    nextWord = nextWord.trim();
    if (nextWord.isEmpty) return "na";

    String firstSignificantWord = nextWord.split(' ').first;
    String checkWord = firstSignificantWord;

    String firstLetterLower =
        checkWord.isNotEmpty ? checkWord[0].toLowerCase() : "";

    if (firstSignificantWord == "thathu" || firstSignificantWord == "ne") {
      return "na";
    }
    if (firstSignificantWord == "hlanu") {
      return "nan";
    }

    if (firstLetterLower == 'a') return "na";
    if (firstLetterLower == 'i' || firstLetterLower == 'e') return "ne";
    if (firstLetterLower == 'u' || firstLetterLower == 'o') return "no";

    if (firstSignificantWord == "lishumi") return "ne";
    if (firstSignificantWord == "nye") return "na";
    if (firstSignificantWord == "bili") return "na";
    if (firstSignificantWord == "sithupha") return "ne";
    if (firstSignificantWord == "khombisa") return "ne";
    if (firstSignificantWord == "shiyagalombili") return "ne";
    if (firstSignificantWord == "shiyagalolunye") return "ne";

    return "na";
  }

  String _getCurrencyUnitName(
      BigInt amount, bool isSubunit, CurrencyInfo info) {
    bool isSingular = amount == BigInt.one;
    if (isSubunit) {
      return isSingular ? info.subUnitSingular! : info.subUnitPlural!;
    } else {
      return isSingular ? info.mainUnitSingular : info.mainUnitPlural!;
    }
  }

  String _getConcordPrefix(int number, _NounClass targetClass,
      {required bool useCurrencyConcord}) {
    if (!useCurrencyConcord || targetClass == _NounClass.unknown) {
      return "";
    }

    int numForPrefix = number;

    // Hundreds (>= 100)
    if (numForPrefix >= 100) {
      switch (targetClass) {
        case _NounClass.cl6_P:
          return (number >= 100 && number < 200) ? "ayi" : "anga";
        case _NounClass.cl8_P:
        case _NounClass.cl10_P:
          return (number >= 100 && number < 200) ? "eziyi" : "ezinga";
        case _NounClass.cl5_S:
          return "eli";
        case _NounClass.cl7_S:
          return "esi";
        case _NounClass.cl9_S:
          return "e";
        default:
          return "";
      }
    }

    // Tens (>= 20)
    if (numForPrefix >= 20) {
      switch (targetClass) {
        case _NounClass.cl6_P:
          return "anga";
        case _NounClass.cl8_P:
        case _NounClass.cl10_P:
          return "ezinga";
        default:
          return "";
      }
    }

    // Teens / Ten (>= 10)
    if (numForPrefix >= 10) {
      switch (targetClass) {
        case _NounClass.cl6_P:
          return "ayi";
        case _NounClass.cl8_P:
        case _NounClass.cl10_P:
          return "eziyi";
        case _NounClass.cl5_S:
          return "eli";
        case _NounClass.cl7_S:
          return "esi";
        case _NounClass.cl9_S:
          return "e";
        default:
          return "";
      }
    }

    // Units (1-9)
    switch (numForPrefix) {
      case 1:
        switch (targetClass) {
          case _NounClass.cl5_S:
            return "eli";
          case _NounClass.cl6_P:
            return "a";
          case _NounClass.cl7_S:
            return "esi";
          case _NounClass.cl8_P:
            return "ezi";
          case _NounClass.cl9_S:
            return "e";
          case _NounClass.cl10_P:
            return "ezi";
          default:
            return "";
        }
      case 2:
      case 3:
      case 5:
        switch (targetClass) {
          case _NounClass.cl6_P:
            return "ama";
          case _NounClass.cl8_P:
          case _NounClass.cl10_P:
            return (numForPrefix == 2) ? "ezim" : "ezin";
          default:
            return "";
        }
      case 4:
        switch (targetClass) {
          case _NounClass.cl6_P:
            return "ama";
          case _NounClass.cl8_P:
          case _NounClass.cl10_P:
            return "ezine";
          default:
            return "";
        }
      case 6:
      case 7:
      case 8:
      case 9:
        switch (targetClass) {
          case _NounClass.cl6_P:
            return "ayi";
          case _NounClass.cl8_P:
          case _NounClass.cl10_P:
            return "eziyi";
          default:
            return "";
        }
    }
    return "";
  }

  String _applyPrefix(String prefix, String baseWord) {
    if (prefix.isEmpty) return baseWord;

    baseWord = baseWord.trim();
    var words = baseWord.split(' ');
    String firstWord = words[0];
    String restOfWords =
        words.length > 1 ? ' ${words.sublist(1).join(' ')}' : '';

    // Specific fusions
    if (prefix == "ayi" && firstWord == "lishumi") {
      return "ayishumi$restOfWords"; // Added fusion rule for ayi + lishumi -> ayishumi
    }
    if (prefix == "ezim" && firstWord == "bili") return "ezimbili$restOfWords";
    if (prefix == "ezin" && firstWord == "thathu")
      return "ezintathu$restOfWords";
    if (prefix == "ezin" && firstWord == "hlanu")
      return "ezinhlanu$restOfWords";
    if (prefix == "ezine" && firstWord == "ne") return "ezine$restOfWords";
    if (prefix == "ayi" && firstWord == "shiyagalolunye")
      return "ayisishiyagalolunye$restOfWords";
    if (prefix == "ayi" && firstWord == "shiyagalombili")
      return "ayisishiyagalombili$restOfWords";
    if (prefix == "ayi" && firstWord == "khombisa")
      return "ayisikhombisa$restOfWords";
    if (prefix == "ayi" && firstWord == "sithupha")
      return "ayisithupha$restOfWords";
    if (prefix == "anga" && firstWord == "amashumi")
      return "angamashumi$restOfWords";
    if (prefix == "ezinga" && firstWord == "amashumi")
      return "ezingamashumi$restOfWords";
    if (prefix == "a" && firstWord == "nye") return "anye$restOfWords";
    if (prefix == "eli" && firstWord == "lodwa") return "elilodwa$restOfWords";
    if (prefix == "esi" && firstWord == "sodwa") return "esisodwa$restOfWords";
    if (prefix == "e" && firstWord == "yodwa") return "eyodwa$restOfWords";
    if (prefix == "ezi" && firstWord == "zodwa") return "ezizodwa$restOfWords";
    if (prefix == "eziyi" && firstWord == "ikhulu")
      return "eziyikhulu$restOfWords";
    if (prefix == "ezinga" && firstWord == "amakhulu")
      return "ezingamakhulu$restOfWords";
    if (prefix == "eziyi" && firstWord == "lishumi") {
      return "eziyishumi$restOfWords"; // Possibly already covered by general, but specific is safer
    }

    // Generic vowel rules
    String modifiedFirstWord;
    if (prefix.endsWith("i") &&
        (firstWord.startsWith("i") || firstWord.startsWith("e"))) {
      modifiedFirstWord = prefix.substring(0, prefix.length - 1) + firstWord;
    } else if (prefix.endsWith("a") && firstWord.startsWith("a")) {
      modifiedFirstWord = prefix.substring(0, prefix.length - 1) + firstWord;
    } else if (prefix.endsWith("a") && firstWord.startsWith("i")) {
      modifiedFirstWord =
          "${prefix.substring(0, prefix.length - 1)}e${firstWord.substring(1)}";
    } else if (prefix.endsWith("a") && firstWord.startsWith("o")) {
      modifiedFirstWord =
          "${prefix.substring(0, prefix.length - 1)}o${firstWord.substring(1)}";
    } else if (prefix.endsWith("a") && firstWord.startsWith("u")) {
      modifiedFirstWord =
          "${prefix.substring(0, prefix.length - 1)}o${firstWord.substring(1)}";
    } else {
      modifiedFirstWord = prefix + firstWord;
    }

    return modifiedFirstWord + restOfWords;
  }
}

class _ScaleInfo {
  final String singular;
  final _NounClass singularClass;
  final String plural;
  final _NounClass pluralClass;

  const _ScaleInfo(
      this.singular, this.singularClass, this.plural, this.pluralClass);
}
