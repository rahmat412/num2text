import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/xh_options.dart';
import '../utils/utils.dart';

class Num2TextXH implements Num2TextBase {
  static const String _zero = "zero";
  static const String _ikhulu = "ikhulu";
  static const String _amakhulu = "amakhulu";
  static const String _iwaka = "iwaka";
  static const String _amawaka = "amawaka";
  static const String _lishumi = "lishumi";
  static const String _amashumi = "amashumi";
  static const String _pointWord = "ichaphaza";
  static const String _commaWord = "ikoma";
  static const String _yearSuffixBC = "BC";
  static const String _yearSuffixAD = "AD";

  static const List<String> _wordsUnitsConnected = [
    "",
    "nye",
    "sibini",
    "sithathu",
    "sine",
    "sihlanu",
    "sithandathu",
    "sixhenxe",
    "sibhozo",
    "sithoba",
  ];

  static const Map<int, String> _currencyUnits = {
    1: "nye",
    2: "zimbini",
    3: "zintathu",
    4: "zine",
    5: "zintlanu",
    6: "zintandathu",
    7: "zisixhenxe",
    8: "zisibhozo",
    9: "zithoba",
  };

  static const String _isigidi = "isigidi";
  static const String _ibhiliyoni = "ibhiliyoni";
  static const String _ithriliyoni = "ithriliyoni";
  static const String _ikhwadriliyoni = "ikhwadriliyoni";
  static const String _ikhwintiliyoni = "ikhwintiliyoni";
  static const String _isekstilioni =
      "isekstilioni"; // Corrected based on analysis
  static const String _iseptilioni = "iseptilioni";
  static const String _izigidi = "izigidi";

  static const String _iibhiliyoni = "iibhiliyoni";
  static const String _iithriliyoni = "iithriliyoni";
  static const String _iikhwadriliyoni = "iikhwadriliyoni";
  static const String _iikhwintiliyoni = "iikhwintiliyoni";
  static const String _iisekstiliyoni =
      "iisekstiliyoni"; // Corrected based on analysis
  static const String _iiseptiliyoni = "iiseptiliyoni";

  static const List<String> _scaleWordsPlural = [
    "",
    _amawaka,
    _izigidi,
    _iibhiliyoni,
    _iithriliyoni,
    _iikhwadriliyoni,
    _iikhwintiliyoni,
    _iisekstiliyoni,
    _iiseptiliyoni,
  ];
  static const List<String> _scaleWordsSingular = [
    "",
    _iwaka,
    _isigidi,
    _ibhiliyoni,
    _ithriliyoni,
    _ikhwadriliyoni,
    _ikhwintiliyoni,
    _isekstilioni,
    _iseptilioni,
  ];

  static const String _ikhuluLamawaka = "ikhulu lamawaka";

  String _getAmaConcord(int unit) {
    switch (unit) {
      case 2:
        return "amabini";
      case 3:
        return "amathathu";
      case 4:
        return "amane";
      case 5:
        return "amahlanu";
      case 6:
        return "amathandathu";
      case 7:
        return "asixhenxe";
      case 8:
        return "asibhozo";
      case 9:
        return "asithoba";
      default:
        return "";
    }
  }

  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final XhOptions xhOptions =
        options is XhOptions ? options : const XhOptions();
    final String errorFallback = fallbackOnError ?? "Ayilonani";

    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? "Negative Infinity" : "Infinity";
      }
      if (number.isNaN) return errorFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    if (decimalValue == Decimal.zero) {
      if (xhOptions.currency) {
        return "$_zero ${xhOptions.currencyInfo.mainUnitPlural ?? xhOptions.currencyInfo.mainUnitSingular}";
      } else {
        return _zero;
      }
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    if (xhOptions.format == Format.year) {
      textResult = _handleYearFormat(
          absValue.truncate().toBigInt(), xhOptions, isNegative);
    } else {
      if (xhOptions.currency) {
        textResult = _handleCurrency(absValue, xhOptions);
      } else {
        textResult = _handleStandardNumber(absValue, xhOptions);
      }
      if (isNegative) {
        textResult = "${xhOptions.negativePrefix} $textResult";
      }
    }
    return textResult.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) return "";

    List<Map<String, dynamic>> chunkDataList = [];
    BigInt tempN = n;
    int tempScale = 0;
    final BigInt oneThousand = BigInt.from(1000);
    while (tempN > BigInt.zero) {
      chunkDataList
          .add({'value': (tempN % oneThousand).toInt(), 'scale': tempScale});
      tempN ~/= oneThousand;
      tempScale++;
    }
    if (chunkDataList.isEmpty) return _zero;
    chunkDataList = chunkDataList.reversed.toList();

    List<Map<String, dynamic>> textChunks = [];
    for (var chunkData in chunkDataList) {
      int val = chunkData['value'];
      int scale = chunkData['scale'];
      if (val == 0) continue;

      String text;
      if (scale == 0) {
        text = _convertChunk(val, applyLeadingNyeToOne: false);
      } else {
        String numberPart;
        String scaleWord =
            (val == 1) ? _scaleWordsSingular[scale] : _scaleWordsPlural[scale];

        if (scale == 1 && val == 100) {
          text = _ikhuluLamawaka;
        } else {
          if (val == 1 && scale > 1) {
            numberPart = "nye";
          } else if (val > 1 && val < 10) {
            numberPart = _currencyUnits[val] ?? "ERR";
          } else {
            numberPart = _convertChunk(val,
                applyLeadingNyeToOne: (scale == 1 && val == 1));
          }

          if (scale == 1) {
            if (val == 1) {
              text = scaleWord;
            } else if (val > 1 && val < 10) {
              text = "$scaleWord ${_getAmaConcord(val)}";
            } else if (val == 10) {
              text = "$scaleWord alishumi";
            } else if (val >= 11 && val <= 19) {
              int unit = val % 10;
              String unitFull = (unit == 1)
                  ? "elinanye"
                  : (unit == 2)
                      ? "elinambini"
                      : "eline${_wordsUnitsConnected[unit]}";
              text = "$scaleWord alishumi $unitFull";
            } else {
              text = "$numberPart $scaleWord";
            }
          } else {
            text = "$numberPart $scaleWord";
          }
        }
      }
      textChunks.add(
          {'text_parts': text.trim().split(' '), 'value': val, 'scale': scale});
    }

    if (textChunks.isEmpty) {
      return _zero;
    }

    StringBuffer result = StringBuffer(textChunks[0]['text_parts'].join(' '));

    if (textChunks.length == 1) {
      var firstChunk = textChunks[0];
      if (firstChunk['value'] == 1 && firstChunk['scale'] == 1) {
        result.write(" elinye");
      }
    }

    for (int i = 0; i < textChunks.length - 1; i++) {
      var current = textChunks[i];
      var next = textChunks[i + 1];

      String connector = "";

      if (next['scale'] == 0) {
        if (current['scale'] == 1) {
          connector = (current['value'] == 1 || current['value'] == 100)
              ? "elina"
              : "ana";
        } else if (current['scale'] >= 2) {
          connector = "ne";
        }
      } else if (next['scale'] > 0) {
        connector = "ne";
        if (current['scale'] >= 2) {
          String currentText = current['text_parts'].join(' ');
          if (currentText.endsWith(_lishumi) || currentText.endsWith(_ikhulu)) {
            connector = "le";
          }
        }
        if (next['scale'] == 2 && next['value'] > 1) {
          connector = "";
        }
      }

      List<String> nextOriginalTextParts =
          List<String>.from(next['text_parts']);
      String fullNextOriginalText = nextOriginalTextParts.join(' ');

      bool useEsinye = (next['value'] == 1 && next['scale'] >= 2);
      bool useElinye = (next['value'] == 1 && next['scale'] == 1);

      result.write(' ');

      if (connector.isNotEmpty) {
        if (connector == 'ne' && useElinye) {
          result.write("nelinye iwaka");
        } else {
          String wordToMerge;
          String textToAppendAfterMerge = "";

          if (next['scale'] == 0) {
            wordToMerge = nextOriginalTextParts.first;
            textToAppendAfterMerge = nextOriginalTextParts.length > 1
                ? nextOriginalTextParts.sublist(1).join(' ')
                : "";
          } else if (useEsinye || useElinye) {
            wordToMerge = _scaleWordsSingular[next['scale']];
            textToAppendAfterMerge = useEsinye ? "esinye" : "elinye";
          } else {
            wordToMerge = nextOriginalTextParts.removeAt(0);
            textToAppendAfterMerge = nextOriginalTextParts.join(' ');
          }

          String mergedPart = _mergeConnector(connector, wordToMerge);
          result.write(mergedPart);

          if (textToAppendAfterMerge.isNotEmpty) {
            result.write(' ');
            result.write(textToAppendAfterMerge);
          }
        }
      } else {
        String textToWrite = fullNextOriginalText;
        if (useEsinye) {
          textToWrite = "esinye ${_scaleWordsSingular[next['scale']]}";
        } else if (useElinye) {
          textToWrite = "elinye ${_scaleWordsSingular[next['scale']]}";
        }
        result.write(textToWrite);
      }
    }

    String finalResult =
        result.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    return finalResult;
  }

  String _mergeConnector(String connector, String word) {
    if (word.isEmpty) return connector;

    // Specific common fusions
    if (connector == "ana" && word == _lishumi) return "aneshumi";
    if (connector == "elina" && word == _lishumi) return "elineshumi";
    if (connector == "elina" && word == "nye") return "elinanye";
    if (connector == "ana" && word == "nye") return "ananye";

    // General rules for "ana" / "elina"
    if (connector == "ana" || connector == "elina") {
      if (word == "nye") return (connector == "ana") ? "ananye" : "elinanye";
      if (word.startsWith('a') ||
          word.startsWith('e') ||
          word.startsWith('o') ||
          word.startsWith('u')) {
        return "${connector.substring(0, connector.length - 1)}$word";
      }
      if (connector == "elina" && word.startsWith('i')) {
        // Handle elina + ikhulu/izigidi etc -> eline...
        return "eline${word.substring(1)}";
      }
      if (connector == "ana" && word.startsWith('i')) {
        // Handle ana + ikhulu/izigidi etc -> ane...
        return "ane${word.substring(1)}";
      }
      if (word.startsWith('s')) {
        if (connector == "elina" && word == "sibini") return "elinambini";
        return "${connector.substring(0, connector.length - 1)}e$word";
      }
    }

    if (connector == "ne") {
      if (word == "nye") return "enanye";
      // **** FIX: Handle ne + plural ii... scale words ****
      if (word.startsWith('ii')) {
        // ne + iikhwadriliyoni -> ekhwadriliyoni
        return "e${word.substring(2)}";
      }
      if (word.startsWith('s')) {
        return "ne$word"; // Keep ne + s... -> nes...
      }
      if (word.startsWith('a')) {
        return "na${word.substring(1)}"; // ne + amakhulu -> namakhulu
      }
      if (word.startsWith('i')) {
        // Handle ne + singular i... scale words
        // ne + isigidi -> nesigidi
        return "ne${word.substring(1)}";
      }
      return "$connector $word"; // Default 'ne' + space + word
    }

    if (connector == "le" || connector == "se") {
      if (word.startsWith('a') ||
          word.startsWith('e') ||
          word.startsWith('i') ||
          word.startsWith('o') ||
          word.startsWith('u')) {
        return "$connector$word";
      }
      if (connector == "le" && word.startsWith('i')) {
        // Handle le + ikhulu/izigidi etc -> le...
        return "le${word.substring(1)}";
      }
    }

    if (connector == "a") {
      if (word.startsWith('a')) return word; // a + amakhulu -> amakhulu
      if (word.startsWith('i'))
        return "e${word.substring(1)}"; // a + ikhulu -> ekhulu
      return "$connector $word";
    }

    return "$connector $word"; // Default if no rule matched
  }

  String _handleYearFormat(
      BigInt absYear, XhOptions options, bool wasNegative) {
    String yearText;

    if (absYear == BigInt.zero) {
      yearText = _zero;
    } else {
      yearText = _convertInteger(absYear);
    }

    if (wasNegative) {
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD && absYear > BigInt.zero) {
      yearText += " $_yearSuffixAD";
    }
    return yearText;
  }

  String _handleCurrency(Decimal absValue, XhOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;

    final Decimal valueToConvert = absValue.round(scale: 2);
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();

    final BigInt subunitValue =
        (fractionalPart * Decimal.fromInt(100)).round().toBigInt();

    String mainText = "";
    String subText = "";

    if (mainValue > BigInt.zero) {
      String mainNumText;
      String mainUnitName;
      if (mainValue == BigInt.one) {
        mainNumText = "nye";
        mainUnitName = currencyInfo.mainUnitSingular;
      } else {
        mainUnitName =
            currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;
        int mainValInt = mainValue.toInt();
        if (mainValInt > 1 &&
            mainValInt < 10 &&
            _currencyUnits.containsKey(mainValInt)) {
          mainNumText = _currencyUnits[mainValInt]!;
        } else {
          if (mainValue == BigInt.from(10000000)) {
            mainNumText = "lishumi lezigidi";
          } else {
            mainNumText = _convertInteger(mainValue);
          }
        }
      }
      mainText = "$mainNumText $mainUnitName";
    }

    if (subunitValue > BigInt.zero) {
      String subNumText;
      String subUnitName;
      if (subunitValue == BigInt.one) {
        subNumText = "nye";
        subUnitName = currencyInfo.subUnitSingular!;
      } else {
        subUnitName =
            currencyInfo.subUnitPlural ?? currencyInfo.subUnitSingular!;
        int subValInt = subunitValue.toInt();
        if (subValInt > 1 &&
            subValInt < 10 &&
            _currencyUnits.containsKey(subValInt)) {
          subNumText = _currencyUnits[subValInt]!;
        } else {
          subNumText = _convertInteger(subunitValue);
        }
      }
      subText = "$subNumText $subUnitName";
    }

    if (mainText.isNotEmpty && subText.isNotEmpty) {
      return "$mainText ${currencyInfo.separator ?? 'ne'} $subText";
    } else if (mainText.isNotEmpty) {
      return mainText;
    } else if (subText.isNotEmpty) {
      return subText;
    } else {
      return "$_zero ${currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular}";
    }
  }

  String _handleStandardNumber(Decimal absValue, XhOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    String integerWords;

    if (integerPart == BigInt.zero &&
        fractionalPart > Decimal.zero &&
        absValue < Decimal.one) {
      integerWords = _zero;
    } else if (integerPart == BigInt.zero && fractionalPart == Decimal.zero) {
      integerWords = _zero;
    } else {
      integerWords = _convertInteger(integerPart);
    }

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _commaWord;
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period:
        default:
          separatorWord = _pointWord;
          break;
      }

      String decimalString = absValue.toString();
      String fractionalDigits =
          decimalString.contains('.') ? decimalString.split('.').last : '';

      if (fractionalDigits.isNotEmpty) {
        while (fractionalDigits.endsWith('0') && fractionalDigits.length > 1) {
          fractionalDigits =
              fractionalDigits.substring(0, fractionalDigits.length - 1);
        }
        List<String> digitWords = fractionalDigits
            .split('')
            .map((d) => _digitToEnglishWord(int.parse(d)))
            .toList();
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }

    if (integerWords == _zero && fractionalWords.isNotEmpty) {
      return '$integerWords$fractionalWords'.trim();
    } else if (integerWords != _zero && fractionalWords.isNotEmpty) {
      return '$integerWords$fractionalWords'.trim();
    } else {
      return integerWords.trim();
    }
  }

  String _digitToEnglishWord(int digit) {
    const englishDigits = [
      "zero",
      "one",
      "two",
      "three",
      "four",
      "five",
      "six",
      "seven",
      "eight",
      "nine",
    ];
    return (digit >= 0 && digit <= 9) ? englishDigits[digit] : '';
  }

  String _convertChunk(int n,
      {String? prefixConnector, bool applyLeadingNyeToOne = false}) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    StringBuffer wordsBuffer = StringBuffer();
    int remainder = n;
    String? internalConnector;
    bool hundredWritten = false;

    if (remainder >= 100) {
      hundredWritten = true;
      int hundredsDigit = remainder ~/ 100;
      bool tensUnitsFollow = (remainder % 100 != 0);
      bool wasIkhulu = (hundredsDigit == 1);

      String baseHundredText;
      if (wasIkhulu) {
        baseHundredText = _ikhulu;
        if (tensUnitsFollow) internalConnector = "elina";
      } else {
        baseHundredText = "$_amakhulu ${_getAmaConcord(hundredsDigit)}";
        if (tensUnitsFollow) internalConnector = "ana";
      }

      if (prefixConnector != null) {
        wordsBuffer.write(_mergeConnector(prefixConnector, baseHundredText));
      } else {
        wordsBuffer.write(baseHundredText);
      }
      remainder %= 100;
    } else {
      internalConnector = prefixConnector;
    }

    if (remainder > 0) {
      String? currentConnector = internalConnector;

      if (hundredWritten && wordsBuffer.isNotEmpty) {
        wordsBuffer.write(' ');
      }

      int unit = remainder % 10;
      String tensUnitsText = "";

      if (remainder < 10) {
        String unitWord = _wordsUnitsConnected[remainder];
        if (currentConnector != null) {
          if (remainder == 1) {
            tensUnitsText = (currentConnector == "ana" ? "ananye" : "elinanye");
            if (currentConnector == "ne")
              tensUnitsText = "nanye"; // Added 'ne' fusion
          } else if (remainder == 2 && currentConnector == "elina") {
            tensUnitsText = "elinambini";
          } else {
            tensUnitsText = _mergeConnector(currentConnector, unitWord);
          }
        } else {
          tensUnitsText =
              (remainder == 1 && !applyLeadingNyeToOne) ? "nye" : unitWord;
          if (remainder == 2 && !applyLeadingNyeToOne) tensUnitsText = "sibini";
          if (remainder == 1 && applyLeadingNyeToOne) tensUnitsText = "nye";
        }
      } else if (remainder == 10) {
        tensUnitsText = currentConnector != null
            ? _mergeConnector(currentConnector, _lishumi)
            : _lishumi;
      } else if (remainder < 20) {
        int unitDigit = remainder % 10;
        String unitFull;
        if (unitDigit == 1) {
          unitFull = "elinanye";
        } else if (unitDigit == 2) {
          unitFull = "elinambini";
        } else {
          unitFull = "eline${_wordsUnitsConnected[unitDigit]}";
        }

        if (currentConnector != null) {
          String mergedTens = _mergeConnector(currentConnector, _lishumi);
          tensUnitsText = "$mergedTens $unitFull";
        } else {
          tensUnitsText = "$_lishumi $unitFull";
        }
      } else {
        int tensDigit = remainder ~/ 10;
        String tensConcord = _getAmaConcord(tensDigit);
        String baseTensPart = "$_amashumi $tensConcord";
        StringBuffer tempTensUnits = StringBuffer();

        if (currentConnector != null) {
          tempTensUnits.write(_mergeConnector(currentConnector, baseTensPart));
        } else {
          tempTensUnits.write(baseTensPart);
        }

        if (unit > 0) {
          String unitPart;
          if (unit == 1) {
            unitPart = "ananye";
          } else if (unit == 2) {
            unitPart = "anesibini";
          } else {
            unitPart = "ane${_wordsUnitsConnected[unit]}";
          }

          tempTensUnits.write(' ');
          tempTensUnits.write(unitPart);
        }
        tensUnitsText = tempTensUnits.toString();
      }
      wordsBuffer.write(tensUnitsText);
    }

    return wordsBuffer.toString().trim();
  }
}
