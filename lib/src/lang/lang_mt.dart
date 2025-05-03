import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/mt_options.dart';
import '../utils/utils.dart';

/// {@template num2text_mt}
/// Converts numbers to Maltese words (`Lang.MT`).
///
/// Handles cardinals, decimals, negatives, currency, years, and large numbers.
/// Implements Maltese grammar: construct state (e.g., "żewġt elef"),
/// specific hundreds ("mitt", "mitejn"), and joining rules with "u" (and).
/// Customizable via [MtOptions]. Returns fallback string on error.
/// {@endtemplate}
class Num2TextMT implements Num2TextBase {
  // --- Constants ---
  static const String _point = "punt"; // Decimal separator
  static const String _comma = "virgola"; // Decimal separator
  static const String _and = "u"; // "and"
  static const String _yearSuffixBC = "QK"; // Qabel Kristu (BC)
  static const String _yearSuffixAD = "WK"; // Wara Kristu (AD/CE)
  static const String _hundredModified =
      "mija"; // "mitt" becomes "mija" when followed by "u"

  /// Base words (0-19).
  static const List<String> _wordsUnder20 = [
    "żero",
    "wieħed",
    "tnejn",
    "tlieta",
    "erbgħa",
    "ħamsa",
    "sitta",
    "sebgħa",
    "tmienja",
    "disgħa",
    "għaxra",
    "ħdax",
    "tnax",
    "tlettax",
    "erbatax",
    "ħmistax",
    "sittax",
    "sbatax",
    "tmintax",
    "dsatax",
  ];

  /// Tens words (10-90). Index 0 unused.
  static const List<String> _wordsTens = [
    "",
    "għaxra",
    "għoxrin",
    "tletin",
    "erbgħin",
    "ħamsin",
    "sittin",
    "sebgħin",
    "tmenin",
    "disgħin",
  ];

  /// Special hundred forms.
  static const Map<int, String> _wordsHundredsMap = {
    1: "mitt",
    2: "mitejn",
    3: "tliet mitt",
    4: "erba' mitt",
    5: "ħames mitt",
    6: "sitt mitt",
    7: "seba' mitt",
    8: "tmien mitt",
    9: "disa' mitt",
  };

  /// Construct state forms for 2-10 before "elef" (thousand).
  static const Map<int, String> _constructBeforeElef = {
    2: "żewġt",
    3: "tlitt",
    4: "erbat",
    5: "ħamest",
    6: "sitt",
    7: "sebat",
    8: "tmien",
    9: "disat",
    10: "għaxart",
  };

  /// Construct state forms for 2-10 before millions+.
  static const Map<int, String> _constructBeforeMillions = {
    2: "żewġ",
    3: "tliet",
    4: "erba'",
    5: "ħames",
    6: "sitt",
    7: "seba'",
    8: "tmien",
    9: "disa'",
    10: "għaxar",
  };

  /// Scale words (singular/plural). Key is scale level (1=10^3, 2=10^6,...).
  static final Map<int, Map<String, String>> _scaleWords = {
    1: {"singular": "elf", "plural": "elef"},
    2: {"singular": "miljun", "plural": "miljuni"},
    3: {"singular": "biljun", "plural": "biljuni"},
    4: {"singular": "triljun", "plural": "triljuni"},
    5: {"singular": "kwadriljun", "plural": "kwadriljuni"},
    6: {"singular": "kwintiljun", "plural": "kwintiljuni"},
    7: {"singular": "sestiljun", "plural": "sestiljuni"},
    8: {"singular": "settiljun", "plural": "settiljuni"},
  };

  /// Processes the given [number] into Maltese words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [MtOptions] for customization (currency, year, decimals, AD/BC).
  /// Defaults apply if [options] is null or not [MtOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or default error on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [MtOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Maltese words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final MtOptions mtOptions =
        options is MtOptions ? options : const MtOptions();
    final String errorDefault = fallbackOnError ?? "Mhux Numru";

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Infinità Negattiva" : "Infinità";
      if (number.isNaN) return errorDefault;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorDefault;

    if (decimalValue == Decimal.zero) {
      return mtOptions.currency
          ? "${_wordsUnder20[0]} ${mtOptions.currencyInfo.mainUnitSingular}"
          : _wordsUnder20[0];
    }

    int? yearIntValue;
    if (mtOptions.format == Format.year) {
      yearIntValue =
          decimalValue.truncate().toBigInt().toInt(); // Get signed year value
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    if (mtOptions.format == Format.year) {
      textResult = _handleYearFormat(yearIntValue!, mtOptions);
    } else {
      textResult = mtOptions.currency
          ? _handleCurrency(absValue, mtOptions)
          : _handleStandardNumber(absValue, mtOptions);
      if (isNegative) {
        textResult = "${mtOptions.negativePrefix} $textResult";
      }
    }
    return textResult.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Converts an integer year to words, adding era suffixes (WK/QK).
  String _handleYearFormat(int year, MtOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;

    if (absYear == 0) return _wordsUnder20[0]; // Year 0 case

    String yearText =
        _convertInteger(BigInt.from(absYear)); // Years read cardinally

    if (isNegative) {
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD) {
      yearText += " $_yearSuffixAD";
    }
    return yearText;
  }

  /// Converts a non-negative [Decimal] to Maltese currency words.
  /// Handles plurals/construct state for units (e.g., 2-10, 11-19).
  String _handleCurrency(Decimal absValue, MtOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final int decimalPlaces = 2;
    final Decimal subunitMultiplier =
        Decimal.ten.pow(decimalPlaces).toDecimal();
    final Decimal valueToConvert =
        options.round ? absValue.round(scale: decimalPlaces) : absValue;

    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final BigInt subunitValue =
        ((valueToConvert - valueToConvert.truncate()) * subunitMultiplier)
            .truncate()
            .toBigInt();

    String mainTextResult = "";
    if (mainValue > BigInt.zero) {
      int mainInt = mainValue.toInt();
      String numberText = _convertInteger(mainValue);
      String mainUnitName;
      if (mainValue == BigInt.one) {
        mainUnitName = currencyInfo.mainUnitSingular;
        mainTextResult = "$mainUnitName $numberText"; // "ewro wieħed"
      } else {
        mainUnitName =
            currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;
        if (mainInt >= 2 &&
            mainInt <= 10 &&
            _constructBeforeMillions.containsKey(mainInt)) {
          numberText = _constructBeforeMillions[mainInt]!; // "żewġ ewro"
        } else if (mainInt >= 11 && mainInt <= 19) {
          numberText = "$numberText-il"; // "ħdax-il ewro"
        }
        mainTextResult = "$numberText $mainUnitName";
      }
    }

    String subunitTextResult = "";
    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      int subInt = subunitValue.toInt();
      String subunitNumText = _convertInteger(subunitValue);
      String subUnitName;
      if (subunitValue == BigInt.one) {
        subUnitName = currencyInfo.subUnitSingular!;
        subunitTextResult = "$subUnitName $subunitNumText"; // "ċenteżmu wieħed"
      } else {
        if (subInt >= 11 && subInt <= 19) {
          subUnitName = currencyInfo.subUnitSingular!; // Use singular for 11-19
          subunitNumText = "$subunitNumText-il"; // "-il" suffix
        } else {
          subUnitName =
              currencyInfo.subUnitPlural ?? currencyInfo.subUnitSingular!;
          if (subInt >= 2 &&
              subInt <= 10 &&
              _constructBeforeMillions.containsKey(subInt)) {
            subunitNumText =
                _constructBeforeMillions[subInt]!; // Construct state
          }
        }
        subunitTextResult = "$subunitNumText $subUnitName";
      }
    }

    if (mainTextResult.isNotEmpty && subunitTextResult.isNotEmpty) {
      final String separator = ' ${currencyInfo.separator ?? _and} ';
      return '$mainTextResult$separator$subunitTextResult'.trim();
    } else if (mainTextResult.isNotEmpty) {
      return mainTextResult.trim();
    } else if (subunitTextResult.isNotEmpty) {
      return subunitTextResult.trim();
    } else {
      return "${_wordsUnder20[0]} ${currencyInfo.mainUnitSingular}"
          .trim(); // Zero value
    }
  }

  /// Converts a non-negative standard [Decimal] number to Maltese words.
  /// Reads fractional part digit by digit.
  String _handleStandardNumber(Decimal absValue, MtOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _wordsUnder20[0] // "żero" before decimal
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero &&
        absValue.scale > 0 &&
        !absValue.isInteger) {
      String fractionalDigits = absValue.toString().split('.').last;
      if (fractionalDigits.isNotEmpty) {
        String separatorWord =
            (options.decimalSeparator == DecimalSeparator.comma)
                ? _comma
                : _point;
        List<String> digitWords = fractionalDigits
            .split('')
            .map((d) => _wordsUnder20[int.parse(d)])
            .toList();
        if (digitWords.isNotEmpty) {
          fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
        }
      }
    }

    if (integerPart == BigInt.zero && fractionalWords.isEmpty) {
      return _wordsUnder20[0]; // Integer zero
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer ([BigInt]) into Maltese words.
  /// Handles scale words, construct state, and joining rules with "u".
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n == BigInt.zero) return _wordsUnder20[0];
    if (n < BigInt.from(1000)) return _convertChunk(n.toInt());

    List<Map<String, dynamic>> partsList = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleLevel = 0;
    BigInt remaining = n;

    // Deconstruct number into chunks and scales.
    while (remaining > BigInt.zero) {
      int chunk = (remaining % oneThousand).toInt();
      remaining ~/= oneThousand;

      if (chunk > 0) {
        String chunkText = "";
        String scaleWordText = "";

        if (scaleLevel > 0) {
          // Thousands, Millions, etc.
          final scaleInfo = _scaleWords[scaleLevel];
          if (scaleInfo == null)
            throw ArgumentError("Scale $scaleLevel undefined.");

          bool usePluralScale = (chunk >= 2 && chunk <= 10);
          scaleWordText =
              usePluralScale ? scaleInfo["plural"]! : scaleInfo["singular"]!;

          if (chunk == 1)
            chunkText = ""; // Just scale word: "elf", "miljun"
          else if (chunk >= 2 && chunk <= 10) {
            // Use construct state prefixes
            if (scaleLevel == 1 && _constructBeforeElef.containsKey(chunk))
              chunkText = _constructBeforeElef[chunk]!;
            else if (scaleLevel > 1 &&
                _constructBeforeMillions.containsKey(chunk))
              chunkText = _constructBeforeMillions[chunk]!;
            else
              chunkText = _convertChunk(chunk); // Fallback
          } else if (chunk >= 11 && chunk <= 19) {
            chunkText = "${_convertChunk(chunk)}-il"; // Add "-il" suffix
            scaleWordText = scaleInfo["singular"]!; // Scale remains singular
          } else {
            chunkText = _convertChunk(chunk);
            scaleWordText = scaleInfo["singular"]!; // Scale remains singular
          }
          partsList.add({
            "text": "$chunkText $scaleWordText".trim(),
            "scale": scaleLevel,
            "chunkValue": chunk
          });
        } else {
          // Base units chunk (0-999)
          chunkText = _convertChunk(chunk);
          partsList.add(
              {"text": chunkText, "scale": scaleLevel, "chunkValue": chunk});
        }
      }
      scaleLevel++;
    }
    if (partsList.isEmpty) return "";

    // Combine parts with Maltese joining logic.
    StringBuffer finalResult = StringBuffer();
    for (int i = partsList.length - 1; i >= 0; i--) {
      final currentPart = partsList[i];
      finalResult.write(currentPart["text"]);

      if (i > 0) {
        final nextPart = partsList[i - 1];
        final int nextChunkValue = nextPart["chunkValue"];
        final int nextScale = nextPart["scale"];
        String separator = " "; // Default separator

        // Add " u " before units or thousands chunks, or chunks with value 1.
        if (nextChunkValue > 0 &&
            (nextScale == 0 || nextScale == 1 || nextChunkValue == 1)) {
          separator = " $_and ";
        }
        finalResult.write(separator);
      }
    }
    return finalResult.toString().trim();
  }

  /// Converts an integer from 0 to 999 into Maltese words.
  /// Handles special hundred forms and joining with "u".
  String _convertChunk(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    List<String> words = [];
    int remainder = n;
    bool needsAnd = false; // Flag to add "u"

    if (remainder >= 100) {
      String hundredWord = _wordsHundredsMap[remainder ~/ 100]!;
      remainder %= 100;
      // Modify "mitt" to "mija" if followed by non-zero remainder (except for "mitejn").
      if (remainder > 0 && hundredWord.endsWith(" mitt") && n != 200) {
        hundredWord = hundredWord.replaceAll(" mitt", " $_hundredModified");
      }
      words.add(hundredWord);
      if (remainder > 0) needsAnd = true;
    }

    if (remainder > 0) {
      if (needsAnd) words.add(_and); // Add "u" if hundreds preceded.

      if (remainder < 20) {
        words.add(_wordsUnder20[remainder]); // 1-19
      } else {
        // 20-99: unit + "u" + ten (e.g., "wieħed u għoxrin")
        int unit = remainder % 10;
        int tenIndex = remainder ~/ 10;
        if (unit > 0) {
          words.add(_wordsUnder20[unit]);
          words.add(_and);
        }
        words.add(_wordsTens[tenIndex]);
      }
    }
    return words.join(' ');
  }
}
