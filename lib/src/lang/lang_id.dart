import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart'; // Currency data
import '../num2text_base.dart'; // Base class
import '../options/base_options.dart'; // Options enums
import '../options/id_options.dart'; // Indonesian options
import '../utils/utils.dart'; // Utils

/// {@template num2text_id}
/// Converts numbers to Indonesian words (Bahasa Indonesia, `Lang.ID`).
///
/// Implements [Num2TextBase] for Indonesian. Handles integers, decimals, currency,
/// years, negatives, and large numbers. Customizable via [IdOptions].
/// {@endtemplate}
class Num2TextID implements Num2TextBase {
  // --- Linguistic Constants ---
  static const String _zero = "nol";
  static const String _point = "titik"; // Decimal separator (period)
  static const String _comma = "koma"; // Decimal separator (comma)
  static const String _currencyAnd = "dan"; // Currency unit separator
  static const String _ten = "sepuluh";
  static const String _eleven = "sebelas";
  static const String _hundred = "seratus"; // Special form for 100
  static const String _thousand = "seribu"; // Special form for 1000
  static const String _yearSuffixBC = "SM"; // Era suffix (BC)
  static const String _yearSuffixAD = "M"; // Era suffix (AD)

  static const List<String> _wordsUnits = [
    "nol", "satu", "dua", "tiga", "empat", "lima", "enam", "tujuh", "delapan",
    "sembilan", // 0-9
  ];
  static const List<String> _wordsTens = [
    "", "", "dua puluh", "tiga puluh", "empat puluh", "lima puluh",
    "enam puluh", "tujuh puluh",
    "delapan puluh", "sembilan puluh", // 0, 10 placeholders; 20-90
  ];

  /// Scale words (powers of 1000).
  static const List<String> _scaleWordsBase = [
    "",
    "ribu",
    "juta",
    "miliar",
    "triliun",
    "kuadriliun",
    "kuintiliun",
    "sekstiliun",
    "septiliun",
  ];

  /// Processes the given [number] into Indonesian words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [IdOptions] for customization (currency, year format, decimals, AD/BC, negative prefix).
  /// Defaults apply if [options] is null or not [IdOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or "Bukan Angka" on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [IdOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Indonesian words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final IdOptions idOptions =
        options is IdOptions ? options : const IdOptions();

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Negatif Tak Terhingga" : "Tak Terhingga";
      if (number.isNaN) return fallbackOnError ?? "Bukan Angka";
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return fallbackOnError ?? "Bukan Angka";

    if (decimalValue == Decimal.zero) {
      // Use singular form for zero currency in Indonesian.
      return idOptions.currency
          ? "$_zero ${idOptions.currencyInfo.mainUnitSingular}"
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    if (idOptions.format == Format.year) {
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), idOptions);
    } else {
      textResult = idOptions.currency
          ? _handleCurrency(absValue, idOptions)
          : _handleStandardNumber(absValue, idOptions);
      if (isNegative) {
        textResult = "${idOptions.negativePrefix} $textResult";
      }
    }
    // Clean potential double spaces introduced by joining parts.
    return textResult.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Formats an integer as an Indonesian year with optional era suffixes.
  ///
  /// @param year The integer year (negative for BC).
  /// @param options Options controlling era suffix display (`includeAD`).
  /// @return The year as Indonesian words.
  String _handleYearFormat(int year, IdOptions options) {
    final bool isNegative = year < 0;
    final BigInt absYearBigInt = BigInt.from(isNegative ? -year : year);
    String yearText = _convertInteger(absYearBigInt);

    if (isNegative)
      yearText += " $_yearSuffixBC"; // Append "SM" for BC
    else if (options.includeAD && year > 0)
      yearText += " $_yearSuffixAD"; // Append "M" only if requested

    return yearText;
  }

  /// Converts a non-negative [Decimal] to Indonesian currency words.
  ///
  /// Uses [IdOptions.currencyInfo]. Rounds if [IdOptions.round] is true.
  /// Assumes 100 subunits per main unit.
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Indonesian words.
  String _handleCurrency(Decimal absValue, IdOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    const int decimalPlaces = 2;
    final Decimal subunitMultiplier = Decimal.fromInt(100);
    final Decimal val =
        options.round ? absValue.round(scale: decimalPlaces) : absValue;

    final BigInt mainVal = val.truncate().toBigInt();
    final Decimal fractionalPart = val - val.truncate();
    // Use truncate for subunits as they usually represent discrete units.
    final BigInt subVal =
        (fractionalPart * subunitMultiplier).truncate().toBigInt();

    final List<String> parts = [];
    if (mainVal > BigInt.zero) {
      parts.add('${_convertInteger(mainVal)} ${info.mainUnitSingular}');
    }

    if (subVal > BigInt.zero && info.subUnitSingular != null) {
      if (parts.isNotEmpty) {
        parts.add(info.separator ??
            _currencyAnd); // Use custom separator or default "dan"
      }
      parts.add('${_convertInteger(subVal)} ${info.subUnitSingular}');
    }

    // Handle case where the value rounds to zero or was initially zero.
    if (parts.isEmpty) {
      return '$_zero ${info.mainUnitSingular}';
    }

    return parts.join(' ');
  }

  /// Converts a non-negative standard [Decimal] number to Indonesian words.
  ///
  /// Handles integer and fractional parts. Uses [IdOptions.decimalSeparator] word.
  /// Fractional part converted digit by digit. Trims trailing zeros.
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Indonesian words.
  String _handleStandardNumber(Decimal absValue, IdOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      String sepWord;
      switch (options.decimalSeparator) {
        // Default to comma handled below
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          sepWord = _point;
          break;
        case DecimalSeparator.comma:
        default:
          sepWord = _comma;
          break;
      }

      String fractionalDigits = absValue.toString().split('.').last;
      fractionalDigits = fractionalDigits.replaceAll(
          RegExp(r'0+$'), ''); // Trim trailing zeros

      if (fractionalDigits.isNotEmpty) {
        final List<String> digitWords = fractionalDigits.split('').map((d) {
          final int? i = int.tryParse(d);
          return (i != null && i >= 0 && i <= 9) ? _wordsUnits[i] : '?';
        }).toList();
        fractionalWords = ' $sepWord ${digitWords.join(' ')}';
      }
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] into Indonesian words using scale words.
  ///
  /// Breaks into chunks of 1000. Delegates chunks < 1000 to [_convertUnderThousand].
  /// Handles special case "seribu" (1000).
  ///
  /// @param n Non-negative integer.
  /// @throws ArgumentError if [n] is negative or exceeds defined scales.
  /// @return Integer as Indonesian words.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n < BigInt.from(1000)) return _convertUnderThousand(n.toInt());

    final List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0;
    BigInt remaining = n;

    while (remaining > BigInt.zero) {
      if (scaleIndex >= _scaleWordsBase.length)
        throw ArgumentError("Number too large: $n");
      final BigInt chunk = remaining % oneThousand;
      remaining ~/= oneThousand;

      if (chunk > BigInt.zero) {
        String chunkText;
        String scaleWord = "";

        if (scaleIndex > 0) {
          // Handle "seribu" (one thousand) vs "ribu" (thousands).
          if (scaleIndex == 1 && chunk == BigInt.one) {
            scaleWord = _thousand; // Use "seribu".
            chunkText = ""; // No "satu" before "seribu".
          } else {
            scaleWord = _scaleWordsBase[scaleIndex]; // Use "ribu", "juta", etc.
            chunkText = _convertUnderThousand(chunk.toInt());
          }
        } else {
          chunkText =
              _convertUnderThousand(chunk.toInt()); // Base chunk (0-999).
        }

        // Add the processed chunk and scale word to the beginning of the list.
        if (scaleWord.isNotEmpty) {
          parts.insert(
              0, chunkText.isEmpty ? scaleWord : "$chunkText $scaleWord");
        } else {
          parts.insert(0, chunkText);
        }
      }
      scaleIndex++;
    }
    return parts.join(' ');
  }

  /// Converts an integer from 0 to 999 into Indonesian words.
  ///
  /// Handles units, teens ("belas"), tens ("puluh"), hundreds ("ratus").
  /// Handles special cases "sepuluh", "sebelas", "seratus".
  ///
  /// @param n Integer chunk (0-999).
  /// @throws ArgumentError if [n] is outside 0-999.
  /// @return Chunk as Indonesian words, or empty string if [n] is 0.
  String _convertUnderThousand(int n) {
    if (n == 0) return ""; // Zero chunk is ignored when joining.
    if (n < 0 || n >= 1000) throw ArgumentError("Input must be 0-999: $n");

    if (n < 10) return _wordsUnits[n];
    if (n == 10) return _ten;
    if (n == 11) return _eleven;
    if (n < 20) return "${_wordsUnits[n % 10]} belas"; // 12-19

    final List<String> words = [];
    int remainder = n;

    if (remainder >= 100) {
      final int hundredsDigit = remainder ~/ 100;
      // Handle "seratus" (100) vs "dua ratus" (200), etc.
      words.add(hundredsDigit == 1
          ? _hundred
          : "${_wordsUnits[hundredsDigit]} ratus");
      remainder %= 100;
    }

    if (remainder > 0) {
      // Add space if hundreds part existed.
      if (words.isNotEmpty) words.add(" ");

      if (remainder < 10)
        words.add(_wordsUnits[remainder]);
      else if (remainder == 10)
        words.add(_ten);
      else if (remainder == 11)
        words.add(_eleven);
      else if (remainder < 20)
        words.add("${_wordsUnits[remainder % 10]} belas");
      else {
        // 20-99
        words.add(_wordsTens[remainder ~/ 10]); // e.g., "dua puluh"
        final int unit = remainder % 10;
        if (unit > 0) {
          words.add(" ");
          words.add(_wordsUnits[unit]); // e.g., "dua puluh satu"
        }
      }
    }
    // Use join('') because spaces are added manually within the logic.
    return words.join('');
  }
}
