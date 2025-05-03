import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/fil_options.dart';
import '../utils/utils.dart';

/// {@template num2text_fil}
/// Converts numbers to Filipino words (`Lang.FIL`).
///
/// Implements [Num2TextBase] for Filipino, handling cardinal numbers, decimals,
/// negatives, currency, and years. Applies linkers (`na`, `-ng`) and the `-'t` ligature.
/// Uses [FilOptions] for customization. Handles specific year formats (e.g., 1900).
/// {@endtemplate}
class Num2TextFIL implements Num2TextBase {
  // --- Constants ---
  static const String _sero = "sero";
  static const String _punto = "punto"; // Decimal separator '.' (default)
  static const String _koma = "koma"; // Decimal separator ','
  static const String _at = "at"; // Conjunction "and"
  static const String _tLigature =
      "'t"; // Ligature for "at" after vowel-ending tens
  static const String _naLinker = "na"; // Linker after consonants (except n)
  static const String _ngLinker =
      "ng"; // Linker suffix after vowels or 'n' (becomes -ng)
  static const String _yearSuffixBC = "BC";
  static const String _yearSuffixAD = "AD";
  static const String _defaultNaN =
      "Hindi Isang Numero"; // Default error fallback

  static const List<String> _wordsUnder20 = [
    _sero,
    "isa",
    "dalawa",
    "tatlo",
    "apat",
    "lima",
    "anim",
    "pito",
    "walo",
    "siyam",
    "sampu",
    "labing-isa",
    "labindalawa",
    "labintatlo",
    "labing-apat",
    "labinlima",
    "labing-anim",
    "labimpito",
    "labing-walo",
    "labinsiyam",
  ];
  // Descriptive forms for 11-19, used in year formatting like "labing siyam na raan".
  static const List<String> _wordsUnder20Descriptive = [
    _sero,
    "isa",
    "dalawa",
    "tatlo",
    "apat",
    "lima",
    "anim",
    "pito",
    "walo",
    "siyam",
    "sampu",
    "labing isa",
    "labing dalawa",
    "labing tatlo",
    "labing apat",
    "labing lima",
    "labing anim",
    "labing pito",
    "labing walo",
    "labing siyam",
  ];
  static const List<String> _wordsTens = [
    "",
    "",
    "dalawampu",
    "tatlumpu",
    "apatnapu",
    "limampu",
    "animnapu",
    "pitumpu",
    "walumpu",
    "siyamnapu",
  ];
  static const String _hundredSingular = "isang daan"; // Exactly 100
  static const String _hundredPluralBase =
      "daan"; // Base for 200+ with -ng linker
  static const String _hundredPluralRaan =
      "raan"; // Used with 'na' linker (e.g., apat na raan)

  static const List<String> _scaleWords = [
    // Short scale
    "", "libo", "milyon", "bilyon", "trilyon", "kuwadrilyon", "kwintilyon",
    "sekstilyon", "septilyon",
  ];

  /// Processes the given [number] into Filipino words.
  ///
  /// {@macro num2text_process_intro}
  /// {@template num2text_fil_process_options}
  /// Uses [FilOptions] for customization (currency, year format, decimals, negative prefix, AD/BC).
  /// {@endtemplate}
  /// {@template num2text_fil_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or "Hindi Isang Numero" on failure.
  /// {@endtemplate}
  /// @param number The number to convert.
  /// @param options Optional [FilOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Filipino words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final FilOptions filOptions =
        options is FilOptions ? options : const FilOptions();
    final String errorFallback = fallbackOnError ?? _defaultNaN;

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative
            ? "Negative Infinity"
            : "Infinity"; // Consider localization?
      if (number.isNaN) return errorFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    if (decimalValue == Decimal.zero) {
      return filOptions.currency
          ? "$_sero ${filOptions.currencyInfo.mainUnitSingular}"
          : _sero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    if (filOptions.format == Format.year) {
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), filOptions);
    } else {
      textResult = filOptions.currency
          ? _handleCurrency(absValue, filOptions)
          : _handleStandardNumber(absValue, filOptions);
      if (isNegative) {
        textResult = "${filOptions.negativePrefix} $textResult";
      }
    }
    return textResult;
  }

  /// Applies the correct Filipino linker (`na` or `-ng`) between a number and noun/scale word.
  /// Handles "isa" -> "isang" and "daan" -> "raan" cases.
  /// @param numberWord The number word (e.g., "dalawa").
  /// @param noun The following word (e.g., "libo").
  /// @return Combined string with linker (e.g., "dalawang libo").
  String _applyNgLinker(String numberWord, String noun) {
    if (numberWord.isEmpty) return noun;
    numberWord = numberWord.trim();
    final String lastChar = numberWord[numberWord.length - 1];
    final vowels = ['a', 'e', 'i', 'o', 'u'];
    final bool useNaLinker = !vowels.contains(lastChar) && lastChar != 'n';
    String modifiedNoun =
        (noun == _hundredPluralBase && useNaLinker) ? _hundredPluralRaan : noun;

    if (useNaLinker)
      return "$numberWord $_naLinker $modifiedNoun"; // e.g., anim na libo
    else {
      if (numberWord == "isa") return "isang $modifiedNoun"; // isang daan
      if (lastChar == 'n')
        return "${numberWord.substring(0, numberWord.length - 1)}$_ngLinker $modifiedNoun"; // milyong
      else
        return "$numberWord$_ngLinker $modifiedNoun"; // dalawang
    }
  }

  /// Converts an integer year to Filipino words with optional era suffixes.
  /// Handles special format for years 1100-1999.
  /// @param year The integer year.
  /// @param options Filipino options for `includeAD`.
  /// @return The year as Filipino words.
  String _handleYearFormat(int year, FilOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;
    String yearText;

    if (absYear == 0)
      yearText = _sero;
    else if (absYear >= 1100 && absYear < 2000) {
      int high = absYear ~/ 100; // e.g., 19
      int low = absYear % 100; // e.g., 99 or 0
      String highText =
          _wordsUnder20Descriptive[high]; // Use descriptive form "labing siyam"
      if (low == 0)
        yearText = _applyNgLinker(
            highText, _hundredPluralBase); // "labing siyam na raan"
      else
        yearText =
            '$highText ${_convertChunk(low)}'; // "labing siyam siyamnapu't siyam"
    } else {
      // Years outside 1100-1999
      yearText = _convertInteger(BigInt.from(absYear), isYear: true);
    }

    if (isNegative)
      yearText += " $_yearSuffixBC";
    else if (options.includeAD && absYear > 0) yearText += " $_yearSuffixAD";

    return yearText;
  }

  /// Converts a [Decimal] to Filipino currency words.
  /// Uses linkers for units. Rounds if `options.round` is true.
  /// @param absValue Absolute currency value.
  /// @param options Filipino options containing currency info.
  /// @return Currency value as Filipino words.
  String _handleCurrency(Decimal absValue, FilOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final Decimal val = options.round ? absValue.round(scale: 2) : absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    final BigInt subVal =
        ((val - val.truncate()) * Decimal.fromInt(100)).truncate().toBigInt();
    String mainText = "";
    if (mainVal > BigInt.zero) {
      mainText =
          _applyNgLinker(_convertInteger(mainVal), info.mainUnitSingular);
    }
    String subText = "";
    if (subVal > BigInt.zero && info.subUnitSingular != null) {
      subText = _applyNgLinker(_convertInteger(subVal), info.subUnitSingular!);
    }

    if (mainVal > BigInt.zero && subVal > BigInt.zero)
      return '$mainText $_at $subText';
    else if (mainVal > BigInt.zero)
      return mainText;
    else if (subVal > BigInt.zero)
      return subText;
    else
      return "$_sero ${info.mainUnitSingular}"; // Zero case
  }

  /// Converts a standard [Decimal] number to Filipino words.
  /// Fractional part read digit-by-digit after "punto" or "koma".
  /// @param absValue Absolute decimal value.
  /// @param options Filipino options for `decimalSeparator`.
  /// @return Number as Filipino words.
  String _handleStandardNumber(Decimal absValue, FilOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _sero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      String sepWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          sepWord = _koma;
          break;
        default:
          sepWord = _punto;
          break; // Default to punto
      }
      String fracDigits = absValue.toString().split('.').last;
      // Ensure correct number of digits based on scale, padding if needed.
      if (fracDigits.length < absValue.scale)
        fracDigits = fracDigits.padRight(absValue.scale, '0');

      if (fracDigits.isNotEmpty) {
        final List<String> digitWords = fracDigits.split('').map((d) {
          final int? i = int.tryParse(d);
          return (i != null && i >= 0 && i <= 9) ? _wordsUnder20[i] : '?';
        }).toList();
        fractionalWords = ' $sepWord ${digitWords.join(' ')}';
      }
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] into Filipino words using scale words and linkers.
  /// Uses "at" before the final units chunk (if < 100) unless `isYear` is true.
  /// @param n Non-negative integer.
  /// @param isYear Flag to suppress "at" before the final chunk for year formatting.
  /// @return Integer as Filipino words.
  String _convertInteger(BigInt n, {bool isYear = false}) {
    if (n == BigInt.zero) return _sero;
    if (n < BigInt.from(1000)) return _convertChunk(n.toInt());

    List<String> parts = [];
    Map<int, int> chunkValues = {}; // Store chunk value by scale index
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIdx = 0;
    BigInt rem = n;
    int highestScale = -1;

    // Decompose into 3-digit chunks.
    while (rem > BigInt.zero) {
      int chunk = (rem % oneThousand).toInt();
      rem ~/= oneThousand;
      if (chunk > 0) {
        chunkValues[scaleIdx] = chunk;
        if (scaleIdx > highestScale) highestScale = scaleIdx;
      }
      scaleIdx++;
    }

    // Reconstruct from highest scale down.
    for (int i = highestScale; i >= 0; i--) {
      if (chunkValues.containsKey(i)) {
        int chunk = chunkValues[i]!;
        String chunkText = _convertChunk(chunk);
        String scaleWord = i > 0 ? _scaleWords[i] : "";
        String combined = scaleWord.isNotEmpty
            ? _applyNgLinker(chunkText, scaleWord)
            : chunkText;
        parts.add(combined);

        // Add "at" before final chunk (units group i=0) if needed.
        bool isNextFinal = (i == 1 && chunkValues.containsKey(0));
        if (isNextFinal) {
          int finalChunk = chunkValues[0]!;
          if (finalChunk > 0 && finalChunk < 100 && !isYear) {
            parts.add(_at);
          }
        }
      }
    }
    return parts.join(' ');
  }

  /// Converts an integer from 0 to 999 into Filipino words.
  /// Handles "daan"/"raan" linkers and the `-'t` ligature.
  /// @param n Integer chunk (0-999).
  /// @return Chunk as Filipino words.
  String _convertChunk(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    List<String> words = [];
    int rem = n;
    if (rem >= 100) {
      int h = rem ~/ 100;
      words.add(h == 1
          ? _hundredSingular
          : _applyNgLinker(_wordsUnder20[h], _hundredPluralBase));
      rem %= 100;
      if (rem > 0) words.add(_at);
    }
    if (rem > 0) {
      if (rem < 20)
        words.add(_wordsUnder20[rem]);
      else {
        String tens = _wordsTens[rem ~/ 10];
        int unit = rem % 10;
        if (unit == 0)
          words.add(tens); // e.g., dalawampu
        else
          words.add(
              "$tens$_tLigature ${_wordsUnder20[unit]}"); // e.g., dalawampu't isa
      }
    }
    return words.join(' ');
  }
}
