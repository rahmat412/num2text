import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/km_options.dart';
import '../utils/utils.dart';

/// {@template num2text_km}
/// Converts numbers to Khmer words (`Lang.KM`).
///
/// Implements [Num2TextBase] for Khmer. Handles various numeric inputs.
/// Features:
/// - Cardinal numbers using specific Khmer scale words (រយ, ពាន់, ម៉ឺន, សែន, លាន).
/// - Compositional handling of large numbers (e.g., លានលាន).
/// - Currency formatting (default KHR).
/// - Year formatting with optional AD/BC suffixes (គ.ស./មុន គ.ស.).
/// - Decimal and negative number handling.
/// Customizable via [KmOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextKM implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "សូន្យ";
  static const String _point = "ចុច"; // Default decimal separator word (.)
  static const String _comma = "ក្បៀស"; // Comma decimal separator word (,)

  /// Khmer words for digits 0-9.
  static const List<String> _digits = [
    "សូន្យ",
    "មួយ",
    "ពីរ",
    "បី",
    "បួន",
    "ប្រាំ",
    "ប្រាំមួយ",
    "ប្រាំពីរ",
    "ប្រាំបី",
    "ប្រាំបួន",
  ];

  static const String _ten = "ដប់"; // 10
  static const String _hundred = "រយ"; // 100
  static const String _thousand = "ពាន់"; // 1,000
  static const String _tenThousand = "ម៉ឺន"; // 10,000
  static const String _hundredThousand = "សែន"; // 100,000
  static const String _million = "លាន"; // 1,000,000
  static const String _yearSuffixBC = "មុន គ.ស."; // Before Common Era
  static const String _yearSuffixAD = "គ.ស."; // Common Era

  /// Maps large scale powers (exponent of 10) to Khmer words.
  /// Larger numbers are built compositionally (e.g., លានលាន).
  static const Map<int, String> _scales = {
    24: "$_million$_million$_million$_million", // 10^24 ~Septillion
    21: "$_thousand$_million$_million$_million", // 10^21 ~Sextillion
    18: "$_million$_million$_million", // 10^18 ~Quintillion
    15: "$_thousand$_million$_million", // 10^15 ~Quadrillion
    12: "$_million$_million", // 10^12 ~Trillion
    9: "$_thousand$_million", // 10^9 ~Billion
    6: _million, // 10^6 Million
  };
  // Pre-sort powers descending for efficient processing.
  static final List<int> _sortedPowers = _scales.keys.toList()
    ..sort((a, b) => b.compareTo(a));
  // Pre-calculate BigInt units for scales.
  static final Map<int, BigInt> _scaleUnits = {
    for (var p in _scales.keys) p: BigInt.parse('1${'0' * p}'),
  };

  /// Processes the given [number] into Khmer words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [KmOptions] for customization (currency, year format, decimals, AD/BC).
  /// Defaults apply if [options] is null or not [KmOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or "មិនមែនជាលេខ" on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [KmOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Khmer words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final KmOptions kmOptions =
        options is KmOptions ? options : const KmOptions();
    final String errorMsg = fallbackOnError ?? "មិនមែនជាលេខ";

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "អនន្តអវិជ្ជមាន" : "អនន្ត";
      if (number.isNaN) return errorMsg;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorMsg;

    // Handle zero specifically for different contexts
    if (decimalValue == Decimal.zero) {
      if (kmOptions.currency) {
        // Only return "zero [unit]" if value is exactly 0.00
        final Decimal fractionalPart = decimalValue - decimalValue.truncate();
        if (fractionalPart == Decimal.zero)
          return "$_zero ${kmOptions.currencyInfo.mainUnitSingular}";
        // Let _handleCurrency process 0.xx values
      } else {
        return _zero; // Standard zero or year zero
      }
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    if (kmOptions.format == Format.year) {
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), kmOptions);
    } else {
      textResult = kmOptions.currency
          ? _handleCurrency(absValue, kmOptions)
          : _handleStandardNumber(absValue, kmOptions);
      if (isNegative) {
        textResult = "${kmOptions.negativePrefix} $textResult";
      }
    }
    return textResult.trim();
  }

  /// Converts an integer year to Khmer words, optionally adding era suffixes.
  ///
  /// @param year The integer year (negative for BC).
  /// @param options Formatting options ([KmOptions.includeAD]).
  /// @return The year as Khmer words.
  String _handleYearFormat(BigInt year, KmOptions options) {
    final bool isNegative = year < BigInt.zero;
    final BigInt absYear = isNegative ? -year : year;
    if (absYear == BigInt.zero) return _zero; // Handle year zero if needed
    String yearText = _convertInteger(absYear);
    if (isNegative)
      yearText += " $_yearSuffixBC";
    else if (options.includeAD) yearText += " $_yearSuffixAD";
    return yearText;
  }

  /// Converts a non-negative [Decimal] to Khmer currency words (e.g., Riel, Sen).
  ///
  /// Uses [KmOptions.currencyInfo]. Rounds to 2 decimal places.
  /// Uses singular unit names, common in Khmer currency expressions.
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Khmer words.
  String _handleCurrency(Decimal absValue, KmOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final Decimal val = absValue.round(scale: 2); // Round for currency
    final BigInt mainVal = val.truncate().toBigInt();
    final BigInt subVal =
        ((val - val.truncate()) * Decimal.fromInt(100)).truncate().toBigInt();

    String mainText = "";
    if (mainVal > BigInt.zero) {
      // Always use singular main unit name in Khmer currency context
      mainText = "${_convertInteger(mainVal)} ${info.mainUnitSingular}";
    } else if (subVal == BigInt.zero && val == Decimal.zero) {
      // Handles exactly 0.00 after rounding
      return "$_zero ${info.mainUnitSingular}";
    }

    String subText = '';
    if (subVal > BigInt.zero && info.subUnitSingular != null) {
      // Always use singular subunit name
      subText = "${_convertUnder1000(subVal.toInt())} ${info.subUnitSingular!}";
    }

    // Combine parts with a space (no special separator typically used)
    return (mainText +
            (mainText.isNotEmpty && subText.isNotEmpty ? " " : "") +
            subText)
        .trim();
  }

  /// Converts a non-negative standard [Decimal] number to Khmer words.
  ///
  /// Handles integer and fractional parts. Uses [KmOptions.decimalSeparator].
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Khmer words.
  String _handleStandardNumber(Decimal absValue, KmOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      final String sepWord =
          (options.decimalSeparator == DecimalSeparator.comma)
              ? _comma
              : _point;
      final String fracDigits =
          absValue.toString().split('.').last; // Get digits after point
      final List<String> digitWords = fracDigits.split('').map((d) {
        final int? i = int.tryParse(d);
        return (i != null && i >= 0 && i < _digits.length) ? _digits[i] : '?';
      }).toList();
      fractionalWords = ' $sepWord ${digitWords.join(' ')}';
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer ([BigInt]) into Khmer words using scales.
  ///
  /// Handles numbers >= 1,000,000 using defined scales and composition.
  /// Delegates numbers < 1,000,000 to [_convertUnderMillion].
  ///
  /// @param n Non-negative integer.
  /// @return Integer as Khmer words.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _zero;
    assert(!n.isNegative);
    if (n < BigInt.from(1000000)) return _convertUnderMillion(n.toInt());

    List<String> parts = [];
    BigInt rem = n;

    // Iterate through scales from largest to smallest
    for (int power in _sortedPowers) {
      BigInt scaleUnit = _scaleUnits[power]!;
      String scaleWord = _scales[power]!;
      if (rem >= scaleUnit) {
        BigInt chunk = rem ~/ scaleUnit;
        rem %= scaleUnit;
        // Convert the chunk multiplier (which might itself be large)
        String chunkText = (chunk < BigInt.from(1000000))
            ? _convertUnderMillion(chunk.toInt())
            : _convertInteger(
                chunk); // Recursive call for very large multipliers
        parts.add("$chunkText$scaleWord"); // Combine multiplier and scale word
      }
    }

    // Add any remaining part less than a million
    if (rem > BigInt.zero) {
      parts.add(_convertUnderMillion(rem.toInt()));
    }
    return parts.join(' '); // Join scale parts with spaces
  }

  /// Converts an integer between 0 and 999,999 into Khmer words.
  ///
  /// Handles សែន (100k), ម៉ឺន (10k), ពាន់ (1k), and delegates < 1000 to [_convertUnder1000].
  /// Note: Joins parts without spaces, following Khmer convention for numbers < 1M.
  ///
  /// @param n Integer chunk (0-999,999).
  /// @return Chunk as Khmer words, or empty string if [n] is 0.
  String _convertUnderMillion(int n) {
    if (n == 0) return "";
    assert(n > 0 && n < 1000000);

    List<String> words = [];
    int rem = n;

    int hundredThousands = rem ~/ 100000; // សែន
    if (hundredThousands > 0) {
      words.add(_digits[hundredThousands] + _hundredThousand);
      rem %= 100000;
    }
    int tenThousands = rem ~/ 10000; // ម៉ឺន
    if (tenThousands > 0) {
      words.add(_digits[tenThousands] + _tenThousand);
      rem %= 10000;
    }
    int thousands = rem ~/ 1000; // ពាន់
    if (thousands > 0) {
      words.add(_digits[thousands] + _thousand);
      rem %= 1000;
    }
    if (rem > 0) {
      // Remainder < 1000
      words.add(_convertUnder1000(rem));
    }
    // Join without spaces for numbers under 1 million
    return words.join('');
  }

  /// Converts an integer between 0 and 999 into Khmer words.
  ///
  /// Handles hundreds (រយ) and delegates < 100 to [_convertUnder100].
  /// Joins parts without spaces.
  ///
  /// @param n Integer chunk (0-999).
  /// @return Chunk as Khmer words, or empty string if [n] is 0.
  String _convertUnder1000(int n) {
    if (n == 0) return "";
    assert(n > 0 && n < 1000);

    List<String> words = [];
    int rem = n;
    int hundreds = rem ~/ 100; // រយ
    if (hundreds > 0) {
      words.add(_digits[hundreds] + _hundred);
      rem %= 100;
    }
    if (rem > 0) {
      // Remainder < 100
      words.add(_convertUnder100(rem));
    }
    // Join without spaces
    return words.join('');
  }

  /// Converts an integer between 0 and 99 into Khmer words.
  /// Handles tens (ដប់, ម្ភៃ, សាមសិប etc.) and units.
  /// Joins parts without spaces.
  ///
  /// @param n Integer chunk (0-99).
  /// @return Chunk as Khmer words, or empty string if [n] is 0.
  String _convertUnder100(int n) {
    if (n == 0) return "";
    assert(n > 0 && n < 100);

    if (n < 10) return _digits[n]; // 1-9

    List<String> words = [];
    int tensDigit = n ~/ 10;
    int unitDigit = n % 10;

    String tensWord;
    switch (tensDigit) {
      case 1:
        tensWord = _ten;
        break; // ដប់ (10-19)
      case 2:
        tensWord = "ម្ភៃ";
        break; // Special word for 20
      case 3:
        tensWord = "សាមសិប";
        break;
      case 4:
        tensWord = "សែសិប";
        break;
      case 5:
        tensWord = "ហាសិប";
        break;
      case 6:
        tensWord = "ហុកសិប";
        break;
      case 7:
        tensWord = "ចិតសិប";
        break;
      case 8:
        tensWord = "ប៉ែតសិប";
        break;
      case 9:
        tensWord = "កៅសិប";
        break;
      default:
        tensWord = "";
        break; // Should not happen
    }
    words.add(tensWord);

    if (unitDigit > 0) {
      words.add(_digits[unitDigit]); // Append unit digit word
    }

    // Join without spaces
    return words.join('');
  }
}
