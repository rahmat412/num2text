import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/sq_options.dart';
import '../utils/utils.dart';

/// {@template num2text_sq}
/// Converts numbers to Albanian words (`Lang.SQ`).
///
/// Implements [Num2TextBase] for Albanian, handling various numeric types.
/// Supports cardinals, currency ([SqOptions.currencyInfo]), years ([Format.year]),
/// decimals, negatives, and large numbers (long scale: mijë, milion, miliard...).
/// Customizable via [SqOptions]. Returns fallback string on error.
/// {@endtemplate}
class Num2TextSQ implements Num2TextBase {
  // --- Linguistic Constants ---
  static const String _zero = "zero";
  static const String _pointWord = "pikë"; // Decimal separator "."
  static const String _commaWord = "presje"; // Decimal separator ","
  static const String _hundred = "qind";
  static const String _connector =
      "e"; // Connects tens and units (njëzet e një)
  static const String _space = " ";

  // --- Scale Number Names (Long Scale) ---
  static const String _thousand = "mijë";
  static const String _million = "milion";
  static const String _milliard = "miliard"; // 10^9
  static const String _billion = "bilion"; // 10^12
  static const String _billiard = "biliard"; // 10^15
  static const String _trillion = "trilion"; // 10^18
  static const String _trilliard = "triliard"; // 10^21
  static const String _quadrillion = "katrilion"; // 10^24

  // --- Year Suffixes ---
  static const String _yearSuffixBC = "p.e.s."; // BC/BCE
  static const String _yearSuffixAD = "e.s."; // AD/CE

  // --- Special Number Representations ---
  static const String _infinity = "Pafundësi";
  static const String _negativeInfinity = "Minus pafundësi";
  static const String _notANumber = "Nuk është numër"; // Default fallback

  // --- Number Word Lists ---
  static const List<String> _wordsUnder20 = [
    "zero",
    "një",
    "dy",
    "tre",
    "katër",
    "pesë",
    "gjashtë",
    "shtatë",
    "tetë",
    "nëntë",
    "dhjetë",
    "njëmbëdhjetë",
    "dymbëdhjetë",
    "trembëdhjetë",
    "katërmbëdhjetë",
    "pesëmbëdhjetë",
    "gjashtëmbëdhjetë",
    "shtatëmbëdhjetë",
    "tetëmbëdhjetë",
    "nëntëmbëdhjetë",
  ];
  static const List<String> _wordsTens = [
    // 20-90
    "", "", "njëzet", "tridhjetë", "dyzet", "pesëdhjetë", "gjashtëdhjetë",
    "shtatëdhjetë", "tetëdhjetë", "nëntëdhjetë",
  ];
  static const List<String> _scaleWords = [
    // Long scale words
    "", _thousand, _million, _milliard, _billion, _billiard, _trillion,
    _trilliard, _quadrillion,
  ];

  /// Processes the given [number] into Albanian words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [SqOptions] for customization (currency, year format, decimals, AD/BC).
  /// Defaults apply if [options] is null or not [SqOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or default Albanian error string on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [SqOptions] settings.
  /// @param fallbackOnError Optional custom error string.
  /// @return The number as Albanian words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final SqOptions sqOptions =
        options is SqOptions ? options : const SqOptions();
    final String effectiveFallback = fallbackOnError ?? _notANumber;

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _negativeInfinity : _infinity;
      if (number.isNaN) return effectiveFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return effectiveFallback;

    if (decimalValue == Decimal.zero) {
      if (sqOptions.currency) {
        final CurrencyInfo info = sqOptions.currencyInfo;
        // For zero currency, use plural forms if available.
        final String mainUnit = info.mainUnitPlural ?? info.mainUnitSingular;
        final String? subUnit = info.subUnitPlural ?? info.subUnitSingular;
        if (subUnit != null && subUnit.isNotEmpty) {
          // Format like "zero lekë e zero qindarka" if subunit exists.
          return "$_zero$_space$mainUnit$_space${info.separator ?? _connector}$_space$_zero$_space$subUnit";
        } else {
          return "$_zero$_space$mainUnit"; // e.g., "zero lekë"
        }
      } else {
        return _zero; // Standard zero
      }
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    if (sqOptions.format == Format.year) {
      if (!absValue.isInteger) return effectiveFallback;
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), sqOptions);
    } else {
      textResult = sqOptions.currency
          ? _handleCurrency(absValue, sqOptions)
          : _handleStandardNumber(absValue, sqOptions);
      if (isNegative) {
        textResult = "${sqOptions.negativePrefix}$_space$textResult";
      }
    }
    return textResult.trim();
  }

  /// Converts an integer year to Albanian words.
  ///
  /// Appends "p.e.s." (BC) for negative years or "e.s." (AD) if requested via [SqOptions.includeAD].
  ///
  /// @param year The integer year.
  /// @param options Formatting options.
  /// @return The year as Albanian words.
  String _handleYearFormat(int year, SqOptions options) {
    final bool isNegative = year < 0;
    final String yearText = _convertInteger(BigInt.from(year.abs()));

    if (isNegative) {
      return "$yearText$_space$_yearSuffixBC"; // Add BC suffix.
    } else if (options.includeAD && year > 0) {
      return "$yearText$_space$_yearSuffixAD"; // Add AD suffix if requested.
    } else {
      return yearText;
    }
  }

  /// Converts a non-negative [Decimal] value to Albanian currency words.
  ///
  /// Uses [SqOptions.currencyInfo] for unit names. Rounds if [SqOptions.round] is true.
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options including currency info.
  /// @return Currency value as Albanian words.
  String _handleCurrency(Decimal absValue, SqOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final Decimal val = options.round ? absValue.round(scale: 2) : absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    final BigInt subVal =
        ((val - val.truncate()) * Decimal.fromInt(100)).round().toBigInt();

    String mainPart = "";
    if (mainVal > BigInt.zero) {
      final String mainText = _convertInteger(mainVal);
      final String mainUnit = (mainVal == BigInt.one)
          ? info.mainUnitSingular
          : (info.mainUnitPlural ?? info.mainUnitSingular);
      mainPart = '$mainText$_space$mainUnit';
    }

    String subPart = "";
    if (subVal > BigInt.zero && info.subUnitSingular != null) {
      final String subText = _convertInteger(subVal);
      final String subUnit = (subVal == BigInt.one)
          ? info.subUnitSingular!
          : (info.subUnitPlural ?? info.subUnitSingular!);
      subPart = '$subText$_space$subUnit';
    }

    if (mainPart.isNotEmpty && subPart.isNotEmpty) {
      return '$mainPart$_space${info.separator ?? _connector}$_space$subPart';
    } else if (mainPart.isNotEmpty) {
      return mainPart;
    } else if (subPart.isNotEmpty) {
      return subPart; // Handle 0.xx cases
    } else {
      // Represents zero after rounding.
      return "$_zero$_space${info.mainUnitPlural ?? info.mainUnitSingular}";
    }
  }

  /// Converts a non-negative standard [Decimal] number to Albanian words.
  ///
  /// Converts integer and fractional parts. Uses [SqOptions.decimalSeparator] word.
  /// Fractional part converted digit by digit.
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Albanian words.
  String _handleStandardNumber(Decimal absValue, SqOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      String sepWord;
      switch (options.decimalSeparator ?? DecimalSeparator.comma) {
        // Default to comma
        case DecimalSeparator.comma:
          sepWord = _commaWord;
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          sepWord = _pointWord;
          break;
      }

      final String fracStr = absValue.toString().split('.').last;
      final String sigFracDigits =
          fracStr.replaceAll(RegExp(r'0+$'), ''); // Trim trailing zeros

      if (sigFracDigits.isNotEmpty) {
        final List<String> digitWords = sigFracDigits.split('').map((d) {
          final int? i = int.tryParse(d);
          return (i != null && i >= 0 && i <= 19) ? _wordsUnder20[i] : '?';
        }).toList();
        fractionalWords = '$_space$sepWord$_space${digitWords.join(_space)}';
      }
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer ([BigInt]) into Albanian words (long scale).
  ///
  /// Breaks the number into chunks of 1000. Delegates chunks to [_convertChunk].
  /// Joins chunks with the connector " e ". Handles "një mijë" correctly.
  ///
  /// @param n Non-negative integer.
  /// @throws ArgumentError if [n] is negative or too large.
  /// @return Integer as Albanian words.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n == BigInt.zero) return _zero;

    if (n < BigInt.from(1000)) return _convertChunk(n.toInt());

    final List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0;
    BigInt rem = n;

    while (rem > BigInt.zero) {
      if (scaleIndex >= _scaleWords.length)
        throw ArgumentError("Number too large");

      final int chunk = (rem % oneThousand).toInt();
      rem ~/= oneThousand;

      if (chunk > 0) {
        final String chunkText = _convertChunk(chunk);
        final String scaleWord = scaleIndex > 0 ? _scaleWords[scaleIndex] : "";
        String currentPart;
        if (scaleWord.isNotEmpty) {
          // Handle "një mijë" vs "dy mijë", "një milion" vs "dy milion"
          currentPart = (chunk == 1 && scaleWord == _thousand)
              ? "një$_space$scaleWord" // "një mijë"
              : "$chunkText$_space$scaleWord"; // e.g., "dy mijë", "njëzet milion"
        } else {
          currentPart = chunkText; // Units chunk
        }
        parts.add(currentPart);
      }
      scaleIndex++;
    }
    // Join with " e ", e.g., ["një milion", "dyqind mijë", "tre"] -> "një milion e dyqind mijë e tre"
    return parts.reversed.join("$_space$_connector$_space").trim();
  }

  /// Converts an integer from 0 to 99 into Albanian words.
  ///
  /// Handles unique names 0-19 and compound tens (e.g., "njëzet e një").
  ///
  /// @param n Integer 0-99.
  /// @throws ArgumentError if [n] is outside 0-99.
  /// @return Number as Albanian words.
  String _convertUnder100(int n) {
    if (n < 0 || n >= 100) throw ArgumentError("Number must be 0-99: $n");
    if (n < 20) return _wordsUnder20[n];

    final String tensWord = _wordsTens[n ~/ 10];
    final int unit = n % 10;
    return (unit == 0)
        ? tensWord
        : "$tensWord$_space$_connector$_space${_wordsUnder20[unit]}";
  }

  /// Converts an integer from 0 to 999 into Albanian words.
  ///
  /// Handles hundreds ("njëqind", "dyqind", "treqind"...) and delegates 0-99 to [_convertUnder100].
  ///
  /// @param n Integer chunk (0-999).
  /// @throws ArgumentError if [n] is outside 0-999.
  /// @return Chunk as Albanian words, or empty string if [n] is 0.
  String _convertChunk(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");
    if (n < 100) return _convertUnder100(n);

    final List<String> words = [];
    final int hundredDigit = n ~/ 100;
    final int remainder = n % 100;

    // Handle special hundred forms
    if (hundredDigit == 1)
      words.add("njëqind");
    else if (hundredDigit == 2)
      words.add("dyqind");
    else
      words.add("${_wordsUnder20[hundredDigit]}$_hundred"); // e.g., tre + qind

    if (remainder > 0) {
      words.add(_connector); // Add "e" between hundreds and tens/units
      words.add(_convertUnder100(remainder));
    }
    return words.join(_space);
  }
}
