import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/xh_options.dart';
import '../utils/utils.dart';

/// {@template num2text_xh}
/// The Xhosa language (Lang.XH) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Xhosa word representation, handling the complex concord system.
///
/// Capabilities include handling cardinal numbers, currency (using [XhOptions.currencyInfo]
/// and applying noun class agreement), year formatting ([Format.year]), negative numbers,
/// decimals (currently outputs English words for digits), and large numbers.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [XhOptions]. Note that Xhosa uses noun class agreement
/// extensively, which affects number words.
/// {@endtemplate}
class Num2TextXH implements Num2TextBase {
  // --- Internal Constants ---

  /// Word for "zero".
  static const String _zero =
      "zero"; // Using loanword, native term might be 'iqanda'?

  /// Word for "hundred".
  static const String _ikhulu = "ikhulu";

  /// Word for "hundreds".
  static const String _amakhulu = "amakhulu";

  /// Word for "thousand" (singular).
  static const String _iwaka = "iwaka";

  /// Word for "thousands" (plural).
  static const String _amawaka = "amawaka";

  /// Word for "ten".
  static const String _lishumi = "lishumi";

  /// Word for "tens".
  static const String _amashumi = "amashumi";

  /// Word for the decimal point ".".
  static const String _pointWord = "ichaphaza";

  /// Word for the decimal comma ",".
  static const String _commaWord = "ikoma"; // Loanword

  /// Suffix for BC/BCE years.
  static const String _yearSuffixBC = "BC"; // Using English abbreviation

  /// Suffix for AD/CE years.
  static const String _yearSuffixAD = "AD"; // Using English abbreviation

  /// Basic stems for units 1-9 when connected/modifying.
  static const List<String> _wordsUnitsConnected = [
    "", // 0
    "nye", // 1
    "sibini", // 2
    "sithathu", // 3
    "sine", // 4
    "sihlanu", // 5
    "sithandathu", // 6
    "sixhenxe", // 7
    "sibhozo", // 8
    "sithoba", // 9
  ];

  /// Scale words (thousands, millions, etc.). Plural forms where applicable.
  static const List<String> _scaleWords = [
    "", // 1000^0
    _amawaka, // 1000^1 (Thousands)
    "million", // 1000^2 (Millions - loanword)
    "billion", // 1000^3 (Billions - loanword)
    "trillion", // 1000^4 (Trillions - loanword)
    "quadrillion", // 1000^5 (Quadrillions - loanword)
    "quintillion", // 1000^6 (Quintillions - loanword)
    "sextillion", // 1000^7 (Sextillions - loanword)
    "septillion", // 1000^8 (Septillions - loanword)
    // Add more scales if needed
  ];

  /// Special term for "one hundred thousand".
  static const String _ikhuluLamawaka = "ikhulu lamawaka";

  /// Helper to get the plural concord prefix (ama-/asi-/...) for units 2-9.
  /// Used primarily for agreeing with plural nouns like 'amakhulu' or 'amawaka'.
  String _getAmaConcord(int unit) {
    switch (unit) {
      case 2:
        return "amabini";
      case 3:
        return "asithathu";
      case 4:
        return "amane";
      case 5:
        return "amahlanu";
      case 6:
        return "asithandathu";
      case 7:
        return "asixhenxe";
      case 8:
        return "asibhozo";
      case 9:
        return "asithoba";
      default:
        return ""; // Should not happen for units 2-9
    }
  }

  /// Processes the given [number] into its Xhosa word representation based on [options].
  ///
  /// - Handles `int`, `double`, `BigInt`, `String`, `Decimal`.
  /// - Uses [fallbackOnError] or a default message for invalid inputs.
  /// - Applies options like currency formatting, year formatting, etc.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final XhOptions xhOptions =
        options is XhOptions ? options : const XhOptions();
    final String errorFallback =
        fallbackOnError ?? "Ayilonani"; // "Not a number"

    // Handle special double values first.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? "Negative Infinity"
            : "Infinity"; // No standard Xhosa term
      }
      if (number.isNaN) return errorFallback;
    }

    // Normalize input to Decimal.
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    // Handle zero case.
    if (decimalValue == Decimal.zero) {
      if (xhOptions.currency) {
        // Get plural main unit name for zero amount.
        return "$_zero ${xhOptions.currencyInfo.mainUnitPlural ?? xhOptions.currencyInfo.mainUnitSingular}";
      } else {
        return _zero;
      }
    }

    // Determine sign and get absolute value.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    // Branch based on formatting options.
    if (xhOptions.format == Format.year) {
      // Handle year formatting.
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), xhOptions);
      // Negative sign is handled by BC suffix in year format.
    } else {
      // Handle currency or standard number formatting.
      if (xhOptions.currency) {
        textResult = _handleCurrency(absValue, xhOptions);
      } else {
        textResult = _handleStandardNumber(absValue, xhOptions);
      }
      // Prepend negative prefix if needed (and not a year).
      if (isNegative) {
        textResult = "${xhOptions.negativePrefix} $textResult";
      }
    }
    return textResult;
  }

  /// Formats an integer as a year in Xhosa.
  ///
  /// - Handles special case for 1900.
  /// - Applies AD/BC suffixes ([_yearSuffixAD], [_yearSuffixBC]) if requested.
  String _handleYearFormat(int year, XhOptions options) {
    final bool isNegative = year < 0; // BC year
    final int absYear = isNegative ? -year : year;
    String yearText;

    // Handle specific phrasing for 1900.
    if (absYear == 1900) {
      yearText = "iwaka elinethoba amakhulu"; // "one thousand nine hundred"
    } else {
      // Convert other years using the standard integer conversion.
      yearText = _convertInteger(BigInt.from(absYear));
    }

    // Append era suffix if needed.
    if (isNegative) {
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD && absYear > 0) {
      // includeAD option controls the AD suffix.
      yearText += " $_yearSuffixAD";
    }
    return yearText;
  }

  /// Formats a [Decimal] value as currency in Xhosa.
  ///
  /// - Uses [options.currencyInfo] for unit names (Rand/cents).
  /// - Applies noun class agreement to the number words based on the currency units.
  /// - Handles singular ("inye") and plural ("zimbini", etc.) forms correctly.
  /// - Uses the separator "ne".
  String _handleCurrency(Decimal absValue, XhOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    // Round to 2 decimal places for currency.
    final Decimal valueToConvert =
        options.round ? absValue.round(scale: 2) : absValue;
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Calculate subunit value (cents).
    final BigInt subunitValue =
        (fractionalPart * Decimal.fromInt(100)).round().toBigInt();

    String mainText = "";
    String subText = "";

    // Process main currency amount (Rand).
    if (mainValue > BigInt.zero) {
      String mainNumText;
      String mainUnitName;
      if (mainValue == BigInt.one) {
        mainNumText = "inye"; // Special form for 'one' Rand.
        mainUnitName = currencyInfo.mainUnitSingular; // "iRandi"
      } else {
        mainUnitName = currencyInfo.mainUnitPlural ??
            currencyInfo.mainUnitSingular; // "iiRandi"
        if (mainValue == BigInt.two) {
          mainNumText = "zimbini"; // Special form for 'two' Rand.
        } else {
          // Convert other numbers normally.
          mainNumText = _convertInteger(mainValue);
        }
      }
      mainText =
          "$mainNumText $mainUnitName"; // e.g., "inye iRandi", "zimbini iiRandi", "zintlanu iiRandi"
    }

    // Process subunit amount (cents).
    if (subunitValue > BigInt.zero) {
      String subNumText;
      String subUnitName;
      if (subunitValue == BigInt.one) {
        subNumText = "inye"; // Special form for 'one' cent.
        subUnitName = currencyInfo.subUnitSingular!; // "isenti"
      } else {
        subUnitName = currencyInfo.subUnitPlural ??
            currencyInfo.subUnitSingular!; // "iisenti"
        if (subunitValue == BigInt.two) {
          subNumText = "zimbini"; // Special form for 'two' cents.
        } else {
          // Convert other numbers normally.
          subNumText = _convertInteger(subunitValue);
        }
      }
      subText =
          "$subNumText $subUnitName"; // e.g., "inye isenti", "zimbini iisenti", "zintlanu iisenti"
    }

    // Combine main and subunit parts.
    if (mainText.isNotEmpty && subText.isNotEmpty) {
      // Use the separator from CurrencyInfo or default to 'ne'.
      return "$mainText ${currencyInfo.separator ?? 'ne'} $subText";
    } else if (mainText.isNotEmpty) {
      return mainText;
    } else if (subText.isNotEmpty) {
      return subText;
    } else {
      // Fallback for zero amount.
      return "$_zero ${currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular}";
    }
  }

  /// Formats a [Decimal] value as a standard cardinal number in Xhosa.
  ///
  /// - Separates integer and fractional parts.
  /// - Uses appropriate decimal separator word ([_pointWord] or [_commaWord]).
  /// - **Note:** Converts fractional digits to *English* words currently.
  String _handleStandardNumber(Decimal absValue, XhOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    String integerWords;
    // Handle case where integer is zero but fraction exists.
    if (integerPart == BigInt.zero && fractionalPart > Decimal.zero) {
      integerWords = _zero;
    } else {
      // Convert integer part using standard Xhosa conversion.
      integerWords = _convertInteger(integerPart);
    }

    String fractionalWords = '';
    // Process fractional part if it exists.
    if (fractionalPart > Decimal.zero) {
      String separatorWord;
      // Determine separator word based on options.
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _commaWord; // "ikoma"
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period:
        default:
          separatorWord = _pointWord; // "ichaphaza"
          break;
      }
      // Extract fractional digits as a string.
      String decimalString = absValue.toString();
      String fractionalDigits =
          decimalString.contains('.') ? decimalString.split('.').last : '';

      if (fractionalDigits.isNotEmpty) {
        // Convert each digit to its English word form (placeholder).
        List<String> digitWords = fractionalDigits
            .split('')
            .map((d) => _digitToEnglishWord(int.parse(d)))
            .toList();
        // Assemble fractional part string (e.g., " ichaphaza one two three").
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }

    // Combine integer and fractional parts.
    if (integerWords == _zero && fractionalWords.isNotEmpty) {
      // e.g., "zero ichaphaza five"
      return '$integerWords$fractionalWords'.trim();
    } else if (integerWords.isNotEmpty) {
      // e.g., "amashumi amabini anesihlanu ichaphaza six"
      return '$integerWords$fractionalWords'.trim();
    } else if (integerWords == _zero && fractionalWords.isEmpty) {
      // e.g., "zero" (for input 0.0)
      return _zero;
    } else {
      // Should typically be covered by the case above, but acts as fallback.
      return integerWords.trim();
    }
  }

  /// Converts a digit (0-9) to its English word equivalent.
  /// **Note:** This is a placeholder for proper Xhosa decimal digit handling.
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
    return (digit >= 0 && digit <= 9) ? englishDigits[digit] : '?';
  }

  /// Converts a non-negative [BigInt] integer into its Xhosa word representation.
  /// This is the main recursive function handling the complex structure.
  String _convertInteger(BigInt n) {
    // Base cases
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero)
      return _convertInteger(
          -n); // Handle negative by converting absolute value

    // Special cases for common numbers
    if (n == BigInt.from(1000)) return "$_iwaka elinye"; // "one thousand"
    if (n == BigInt.from(1001))
      return "iwaka elinanye"; // "one thousand and one"
    if (n == BigInt.from(10000)) return "$_amawaka alishumi"; // "ten thousand"
    if (n == BigInt.from(100000))
      return _ikhuluLamawaka; // "one hundred thousand"

    // --- Chunking Logic ---
    List<Map<String, dynamic>> chunkData =
        []; // Stores {value: int, scale: int} for each chunk
    BigInt tempN = n;
    int tempScale = 0; // 0 = units, 1 = thousands, 2 = millions...
    final BigInt oneThousand = BigInt.from(1000);

    // Break the number into chunks of 1000.
    while (tempN > BigInt.zero) {
      BigInt chunkBigInt = tempN % oneThousand;
      tempN ~/= oneThousand;

      if (chunkBigInt > BigInt.zero) {
        // Store non-zero chunks with their scale level.
        chunkData.add({'value': chunkBigInt.toInt(), 'scale': tempScale});
      }
      tempScale++;
    }

    // Reverse chunks to process from highest scale down.
    chunkData = chunkData.reversed.toList();

    List<String> parts =
        []; // Stores the word representation of each processed chunk.
    String?
        connectorForNextChunk; // Stores special connectors like 'elina', 'ana'.

    // Process each chunk.
    for (int i = 0; i < chunkData.length; i++) {
      int currentChunkValue =
          chunkData[i]['value']; // The 0-999 value of this chunk.
      int currentScale =
          chunkData[i]['scale']; // The scale (0 for units, 1 for thousands...).
      String currentPartText = ""; // The text for this chunk.
      bool isLastChunk = (i == chunkData.length - 1);
      // Look ahead to the next chunk's value if it exists.
      int nextChunkValue = isLastChunk ? 0 : chunkData[i + 1]['value'];

      // Get any connector passed from the previous chunk.
      String? prefixConnector = connectorForNextChunk;
      connectorForNextChunk = null; // Reset connector for the current chunk.

      // Process chunks with scales (thousands, millions, etc.).
      if (currentScale > 0) {
        if (currentScale < _scaleWords.length) {
          String scaleWord =
              _scaleWords[currentScale]; // "amawaka", "million", ...

          // Special handling for thousands (_amawaka).
          if (scaleWord == _amawaka) {
            // Check if the next chunk is a 'hundred' (100-199).
            bool nextIsIkhulu = !isLastChunk &&
                chunkData[i + 1]['scale'] == 0 &&
                nextChunkValue >= 100 &&
                nextChunkValue < 200;
            // Check if the next chunk is small (1-99).
            bool nextIsSmall = !isLastChunk &&
                chunkData[i + 1]['scale'] == 0 &&
                nextChunkValue > 0 &&
                nextChunkValue < 100;

            if (currentChunkValue == 1) {
              // One thousand...
              if (nextIsIkhulu) {
                // e.g., 1100 -> "iwaka" (connector handles 'eli-')
                currentPartText = _iwaka;
                connectorForNextChunk =
                    "SPECIAL_IKHULU"; // Signal to next chunk
              } else {
                // e.g., 1000 -> "iwaka elinye", 1050 -> "iwaka elinye" (connector 'elina')
                currentPartText = "$_iwaka elinye";
                if (nextIsSmall)
                  connectorForNextChunk = "elina"; // Connector for 1001-1099
              }
            } else if (currentChunkValue >= 2 && currentChunkValue <= 9) {
              // 2-9 thousand...
              // e.g., 2000 -> "amawaka amabini", 5050 -> "amawaka amahlanu" (connector 'ana')
              currentPartText =
                  "$_amawaka ${_getAmaConcord(currentChunkValue)}";
              if (nextIsSmall)
                connectorForNextChunk = "ana"; // Connector for 2001-9099
            } else {
              // 10+ thousand...
              // e.g., 25000 -> "amashumi amabini anesihlanu amawaka" (connector 'ana')
              String chunkValueText = _convertChunk(currentChunkValue);
              currentPartText = "$chunkValueText $scaleWord";
              if (nextIsSmall) connectorForNextChunk = "ana";
            }
          } else {
            // Handling for millions, billions, etc. (currently loanwords)
            String rawChunkText = _convertChunk(currentChunkValue);
            if (currentChunkValue == 1) {
              // e.g., "nye million"
              currentPartText = "nye $scaleWord";
            } else {
              // e.g., "zimbini million"
              currentPartText = "$rawChunkText $scaleWord";
            }
          }
        } else {
          // Scale exceeds defined _scaleWords
          String rawChunkText = _convertChunk(currentChunkValue);
          currentPartText = "$rawChunkText [Scale $currentScale]"; // Fallback
        }
      } else {
        // Process the units chunk (0-999).
        if (prefixConnector == "SPECIAL_IKHULU") {
          // Handle connection after 'iwaka' for 1100-1199 range.
          String chunkText = _convertChunk(currentChunkValue);
          if (chunkText.startsWith(_ikhulu)) {
            // Fuse 'iwaka' + 'ikhulu' -> 'iwaka elikhulu'
            currentPartText = "eli${chunkText.substring(1)}";
          } else {
            currentPartText =
                chunkText; // Should not happen if next chunk is 100-199
          }
        } else {
          // Convert the units chunk normally, applying any incoming connector.
          currentPartText = _convertChunk(currentChunkValue,
              prefixConnector: prefixConnector);
        }
      }

      // Add the processed part text if it's not empty.
      if (currentPartText.isNotEmpty) {
        parts.add(currentPartText.trim());
      }
    }

    // Join all parts with spaces.
    return parts.join(' ').trim();
  }

  /// Converts a number between 0 and 999 into its Xhosa word representation.
  /// Handles hundreds, tens, and units, including complex connectors.
  String _convertChunk(int n, {String? prefixConnector}) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    // Ignore the special connector if it was just for 'iwaka elikhulu' fusion.
    if (prefixConnector == "SPECIAL_IKHULU") {
      prefixConnector = null;
    }

    StringBuffer wordsBuffer = StringBuffer();
    int remainder = n;
    String?
        internalConnector; // Connector between hundreds and tens/units ('elina'/'ana').
    bool hundredWritten = false;

    // --- Handle Hundreds ---
    if (remainder >= 100) {
      hundredWritten = true;
      int hundredsDigit = remainder ~/ 100;
      bool tensUnitsFollow =
          (remainder % 100 != 0); // Check if tens/units exist.

      // Apply incoming connector if present (from thousands/millions).
      if (prefixConnector != null) {
        if (hundredsDigit == 1) {
          // One hundred connected...
          // e.g., '... ana' + 100 -> '... anekhulu'
          wordsBuffer
              .write(prefixConnector == "ana" ? "anekhulu" : "elinekhulu");
        } else {
          // 2-9 hundred connected...
          // e.g., '... ana' + 300 -> '... anamakhulu asithathu'
          wordsBuffer.write(
            "$prefixConnector${_amakhulu.substring(1)} ${_getAmaConcord(hundredsDigit)}",
          );
        }
        prefixConnector = null; // Connector used.
      } else {
        // No incoming connector.
        if (hundredsDigit == 1) {
          // 100-199
          wordsBuffer.write(_ikhulu);
          // Set internal connector if tens/units follow.
          if (tensUnitsFollow) internalConnector = "elina";
        } else {
          // 200-999
          wordsBuffer.write("$_amakhulu ${_getAmaConcord(hundredsDigit)}");
          // Set internal connector if tens/units follow.
          if (tensUnitsFollow) internalConnector = "ana";
        }
      }
      remainder %= 100; // Remainder is now 0-99.
    }

    // --- Handle Tens and Units (0-99) ---
    if (remainder > 0) {
      // Use the connector determined above (either from prefix or internal).
      String? currentConnector = prefixConnector ?? internalConnector;

      // Add space after hundreds if both parts exist.
      if (hundredWritten) {
        wordsBuffer.write(' ');
      }

      int unit = remainder % 10;
      String tensUnitsText;

      if (remainder < 10) {
        // 1-9
        String unitWord = _wordsUnitsConnected[remainder];
        if (currentConnector != null) {
          // Fuse connector + unit word (e.g., 'ana' + 'nye' -> 'ananye', 'elina' + 'nye' -> 'elinanye').
          tensUnitsText = (remainder == 1)
              ? (currentConnector == "ana" ? "ananye" : "elinanye")
              : "$currentConnector$unitWord";
        } else {
          tensUnitsText = unitWord; // Standalone unit word
        }
      } else if (remainder == 10) {
        // Exactly 10
        // Fuse connector + 'lishumi' (e.g., 'ana' + 10 -> 'aneshumi').
        tensUnitsText = currentConnector != null
            ? (currentConnector == "ana" ? "aneshumi" : "elineshumi")
            : _lishumi;
      } else if (remainder < 20) {
        // 11-19
        String unitConnected = _wordsUnitsConnected[unit];
        if (unit == 1) unitConnected = "nye"; // Special stem for 11.
        // Base form: "lishumi elinanye", "lishumi elinesibini", ...
        String baseTeenPart =
            "$_lishumi ${(unit == 1 ? 'elinanye' : 'eline$unitConnected')}";
        if (currentConnector != null) {
          // Fuse connector with the 'lishumi' part.
          String fusedTens =
              currentConnector == "ana" ? "aneshumi" : "elineshumi";
          String unitPart = baseTeenPart
              .substring(_lishumi.length)
              .trim(); // Get the 'eline...' part.
          tensUnitsText = "$fusedTens $unitPart"; // e.g., "aneshumi elinanye"
        } else {
          tensUnitsText = baseTeenPart; // e.g., "lishumi elinanye"
        }
      } else {
        // 20-99
        int tensDigit = remainder ~/ 10;
        String tensConcord =
            _getAmaConcord(tensDigit); // Concord for the tens digit.
        // Base form: "amashumi amabini", "amashumi asithathu", ...
        String baseTensPart = "$_amashumi $tensConcord";

        StringBuffer tempTensUnits = StringBuffer();
        if (currentConnector != null) {
          // Fuse connector with 'amashumi'.
          // e.g., 'ana' + 20 -> 'anamashumi amabini'
          tempTensUnits
              .write("$currentConnector${_amashumi.substring(1)} $tensConcord");
        } else {
          tempTensUnits.write(baseTensPart); // e.g., "amashumi amabini"
        }
        // Add units part if present (e.g., for 21, 35).
        if (unit > 0) {
          // Fuse 'ane-' connector with the unit word.
          // e.g., unit 1 -> "ananye", unit 5 -> "anesihlanu"
          String unitPart =
              (unit == 1) ? "ananye" : "ane${_wordsUnitsConnected[unit]}";
          tempTensUnits.write(' ');
          tempTensUnits.write(unitPart); // e.g., " anamashumi amabini ananye"
        }
        tensUnitsText = tempTensUnits.toString();
      }
      // Append the generated tens/units text.
      wordsBuffer.write(tensUnitsText);
    }
    return wordsBuffer.toString();
  }
}
