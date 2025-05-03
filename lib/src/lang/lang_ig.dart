import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ig_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ig}
/// Converts numbers to Igbo words (`Lang.IG`).
///
/// Implements [Num2TextBase] for the Igbo language. Handles various numeric
/// types, converting them into Igbo word representation based on Igbo grammar
/// and the number system (including grouping by thousands, millions, etc.).
///
/// Features:
/// - Cardinal numbers (e.g., "narị iri abụọ na atọ" for 123).
/// - Currency formatting (defaults to NGN - Naira/Kobo in Igbo).
/// - Year formatting (including BC/AD suffixes).
/// - Negative numbers (prefix "mwepu").
/// - Decimals (using "ntụpọ" or "rikoma").
/// - Large numbers using scales like "puku" (thousand), "nde" (million), "ijeri" (billion).
/// - Uses the conjunction "na" (and) extensively.
///
/// Customization is available via [IgOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextIG implements Num2TextBase {
  // --- Constants ---

  /// Conjunction "na" (and), used to connect number parts.
  static const String _na = "na";
  static const String _zero = "efu";
  static const String _point = "ntụpọ"; // Decimal point
  static const String _comma = "rikoma"; // Decimal comma
  static const String _yearSuffixBC = "BC"; // Before Christ
  static const String _yearSuffixAD = "AD"; // Anno Domini / Mgbe Kraịst
  static const String _infinity = "Anwụ Anwụ"; // Infinity
  static const String _notANumber = "Abụghị Ọnụọgụ"; // Not a Number

  /// Words for numbers 0-19.
  static const List<String> _wordsUnder20 = [
    "efu",
    "otu",
    "abụọ",
    "atọ",
    "anọ",
    "ise",
    "isii",
    "asaa",
    "asatọ",
    "itoolu",
    "iri",
    "iri na otu",
    "iri na abụọ",
    "iri na atọ",
    "iri na anọ",
    "iri na ise",
    "iri na isii",
    "iri na asaa",
    "iri na asatọ",
    "iri na itoolu",
  ];

  /// Words for tens (20, 30,..., 90).
  static const List<String> _wordsTens = [
    "",
    "",
    "iri abụọ",
    "iri atọ",
    "iri anọ",
    "iri ise",
    "iri isii",
    "iri asaa",
    "iri asatọ",
    "iri itoolu",
  ];

  static const String _hundred = "narị";
  static const String _thousand = "puku";
  static const String _million = "nde";
  static const String _billion = "ijeri";

  /// Names for number scales (thousand, million, billion...). Follows Igbo pattern.
  static const List<String> _scaleNames = [
    "", // 10^0 (Units)
    _thousand, // 10^3
    _million, // 10^6
    _billion, // 10^9
    "$_thousand $_billion", // 10^12 (Trillion - puku ijeri)
    "$_million $_billion", // 10^15 (Quadrillion - nde ijeri)
    "$_billion $_billion", // 10^18 (Quintillion - ijeri ijeri)
    "$_thousand $_billion $_billion", // 10^21 (Sextillion - puku ijeri ijeri)
    "$_million $_billion $_billion", // 10^24 (Septillion - nde ijeri ijeri)
    // Further scales can be added following this compound pattern.
  ];

  /// Processes the given [number] into Igbo words.
  ///
  /// {@macro num2text_base_process_intro}
  /// {@macro num2text_base_process_options}
  /// Uses [IgOptions] for customization (currency, year format, decimals, AD/BC).
  /// {@macro num2text_base_process_errors}
  /// Returns [fallbackOnError] or Igbo default "Abụghị Ọnụọgụ" on failure.
  ///
  /// @param number The number to convert.
  /// @param options Optional [IgOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Igbo words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final IgOptions igOptions =
        options is IgOptions ? options : const IgOptions();
    final String errorFallback = fallbackOnError ?? _notANumber;

    if (number is double) {
      if (number.isInfinite) {
        // Handle infinity with optional negative prefix capitalization.
        return number.isNegative
            ? "${_capitalize(igOptions.negativePrefix)} $_infinity"
            : _infinity;
      }
      if (number.isNaN) return errorFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    if (decimalValue == Decimal.zero) {
      // Zero requires singular main unit for currency.
      return igOptions.currency
          ? "$_zero ${igOptions.currencyInfo.mainUnitSingular}"
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    // Dispatch based on format options.
    if (igOptions.format == Format.year) {
      // Years are handled as integers, BC/AD suffix added here.
      textResult =
          _convertInteger(absValue.truncate().toBigInt(), isTopLevel: true);
      if (isNegative)
        textResult += " $_yearSuffixBC";
      else if (igOptions.includeAD) textResult += " $_yearSuffixAD";
    } else if (igOptions.currency) {
      // Currency formatting handles main and subunits.
      textResult = _handleCurrency(absValue, igOptions);
      if (isNegative) textResult = "${igOptions.negativePrefix} $textResult";
    } else {
      // Standard number: check for decimals.
      final bool hasDecimal = absValue.truncate() != absValue;
      if (hasDecimal) {
        textResult = _handleStandardNumberWithDecimal(absValue, igOptions);
      } else {
        textResult =
            _convertInteger(absValue.truncate().toBigInt(), isTopLevel: true);
      }
      if (isNegative) textResult = "${igOptions.negativePrefix} $textResult";
    }

    return textResult.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Converts a non-negative [BigInt] into Igbo words.
  ///
  /// Handles large numbers recursively using scale names (_scaleNames).
  /// Uses the conjunction "na" to connect parts.
  ///
  /// The [isTopLevel] flag influences how `1 * scale` numbers are handled:
  /// - Top Level (e.g., 1000): "puku" (no "otu")
  /// - Not Top Level (e.g., within 5,001,000): "puku otu"
  ///
  /// @param n The non-negative integer.
  /// @param isTopLevel Indicates if this is the outermost call or a recursive call for a remainder.
  /// @return The integer as Igbo words.
  String _convertInteger(BigInt n, {bool isTopLevel = true}) {
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n == BigInt.zero) return _zero;

    // Handle numbers below 1000 directly.
    if (n < BigInt.from(1000)) return _convertUnder1000(n.toInt());

    // Find the largest applicable scale.
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0;
    for (int i = _scaleNames.length - 1; i > 0; i--) {
      BigInt scaleValue = oneThousand.pow(i);
      if (n >= scaleValue) {
        scaleIndex = i;
        break;
      }
    }

    // Should not happen if n >= 1000, but defensive check.
    if (scaleIndex == 0) return _convertUnder1000(n.toInt());
    if (scaleIndex >= _scaleNames.length)
      throw ArgumentError("Number $n too large.");

    // Calculate the multiplier (chunk) and remainder for the current scale.
    BigInt currentScaleValue = oneThousand.pow(scaleIndex);
    final BigInt chunk = n ~/ currentScaleValue;
    final BigInt remainder = n % currentScaleValue;

    String chunkText;
    // Igbo grammar differs for scale multiplier '1'.
    if (chunk == BigInt.one) {
      // Case: Multiplier is 1 (e.g., 1000, 1001, 1,000,000)
      if (isTopLevel && remainder == BigInt.zero) {
        // Exactly 1000, 1M, 1B etc. -> "puku", "nde", "ijeri" (No "otu")
        chunkText = _scaleNames[scaleIndex];
      } else {
        // Remainder exists (e.g., 1001) OR this is a recursive call for a scale of 1.
        if (!isTopLevel) {
          // Recursive call (e.g., processing 1000 within 5,001,000) needs explicit "otu".
          chunkText =
              "${_scaleNames[scaleIndex]} ${_convertUnder1000(1)}"; // "puku otu"
        } else {
          // Top level with remainder (e.g., 1001): Just use scale name; remainder handled next.
          chunkText = _scaleNames[scaleIndex]; // "puku"
        }
      }
    } else {
      // Case: Multiplier > 1 (e.g., 5000 -> "puku ise")
      String multiplierText = _convertInteger(chunk,
          isTopLevel: false); // Recursively convert multiplier
      chunkText = "${_scaleNames[scaleIndex]} $multiplierText";
    }

    // Append the remainder if it exists.
    if (remainder > BigInt.zero) {
      String remainderText = _convertInteger(remainder,
          isTopLevel: false); // Recursively convert remainder
      return "$chunkText $_na $remainderText";
    } else {
      return chunkText;
    }
  }

  /// Converts a non-negative [Decimal] value to Igbo currency words.
  ///
  /// Uses [IgOptions.currencyInfo]. Handles main units (e.g., Naira) and
  /// subunits (e.g., Kobo). Rounds if [IgOptions.round] is true.
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Igbo words.
  String _handleCurrency(Decimal absValue, IgOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final bool round = options.round;
    final Decimal val = round
        ? absValue.round(scale: 2)
        : absValue; // Standard 2 decimal places

    final BigInt mainVal = val.truncate().toBigInt();
    // Calculate subunit value precisely.
    final BigInt subVal =
        ((val - val.truncate()) * Decimal.fromInt(100)).truncate().toBigInt();

    String mainText = "";
    // Generate main unit part only if main value > 0 OR if there are no subunits.
    if (mainVal > BigInt.zero || subVal == BigInt.zero) {
      mainText = _convertInteger(mainVal, isTopLevel: true);
    }

    String mainUnitName = info
        .mainUnitSingular; // Plural usually not distinct in Igbo numbers? Defaulting singular.
    String subUnitName = info.subUnitSingular ?? "";

    List<String> parts = [];
    if (mainText.isNotEmpty) {
      parts.add("$mainText $mainUnitName");
    }

    // Add subunit part if value > 0 and subunit name exists.
    if (subVal > BigInt.zero && subUnitName.isNotEmpty) {
      String subunitText = _convertInteger(subVal, isTopLevel: true);
      String separator =
          info.separator ?? _na; // Use "na" as default separator.
      if (parts.isNotEmpty) {
        parts.add(separator);
      }
      parts.add("$subunitText $subUnitName");
    }

    // Handle edge case: 0 main units, >0 subunits (e.g., 0.50 Kobo)
    if (mainVal == BigInt.zero &&
        subVal > BigInt.zero &&
        subUnitName.isNotEmpty) {
      String subunitText = _convertInteger(subVal, isTopLevel: true);
      return "$subunitText $subUnitName";
    }
    // Handle edge case: 0 main units and 0 subunits (return "zero [main unit]")
    if (mainVal == BigInt.zero && subVal == BigInt.zero) {
      return "$_zero $mainUnitName";
    }

    return parts.join(' ');
  }

  /// Converts a non-negative standard [Decimal] number with a fractional part to Igbo words.
  ///
  /// Uses [IgOptions.decimalSeparator]. Fractional part is read digit by digit.
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Igbo words.
  String _handleStandardNumberWithDecimal(Decimal absValue, IgOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();

    // Convert integer part, handle case where integer is 0 (e.g., 0.5).
    String integerWords = (integerPart == BigInt.zero)
        ? _zero
        : _convertInteger(integerPart, isTopLevel: true);

    String fractionalWords = '';
    // Determine separator word.
    String separatorWord;
    switch (options.decimalSeparator) {
      case DecimalSeparator.comma:
        separatorWord = _comma;
        break;
      case DecimalSeparator.point:
      case DecimalSeparator.period:
      default:
        separatorWord = _point;
        break;
    }

    // Extract digits after the decimal point.
    String fractionalDigits = absValue.toString().split('.').last;
    // Remove trailing zeros as they are typically not read out.
    fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');

    if (fractionalDigits.isNotEmpty) {
      // Convert each digit individually.
      List<String> digitWords = fractionalDigits.split('').map((digit) {
        final int digitInt = int.parse(digit);
        return _wordsUnder20[digitInt]; // Use base words 0-9.
      }).toList();
      fractionalWords = '$separatorWord ${digitWords.join(' ')}';
    }

    // Combine integer and fractional parts.
    return '$integerWords $fractionalWords'.trim();
  }

  /// Converts an integer between 0 and 999 into Igbo words.
  ///
  /// Handles hundreds, tens, and units using the conjunction "na".
  ///
  /// @param n Integer chunk (0-999).
  /// @return Chunk as Igbo words. Returns "efu" if n is 0.
  /// @throws ArgumentError if n is outside 0-999.
  String _convertUnder1000(int n) {
    if (n < 0 || n >= 1000) throw ArgumentError("Input must be 0-999: $n");
    if (n == 0) return _zero; // Handle zero explicitly.

    List<String> words = [];
    int remainder = n;

    // Handle hundreds.
    if (remainder >= 100) {
      int hundredMultiplier = remainder ~/ 100;
      if (hundredMultiplier == 1) {
        words.add(_hundred); // "narị"
      } else {
        // "narị [multiplier]" e.g., "narị abụọ" for 200.
        words.add("$_hundred ${_wordsUnder20[hundredMultiplier]}");
      }
      remainder %= 100;
      // Add connector "na" if there's more to come.
      if (remainder > 0) {
        words.add(_na);
      }
    }

    // Handle tens and units (1-99).
    if (remainder > 0) {
      if (remainder < 20) {
        words.add(_wordsUnder20[remainder]); // Use pre-defined words 1-19.
      } else {
        int tensDigit = remainder ~/ 10;
        int unitDigit = remainder % 10;
        words.add(_wordsTens[tensDigit]); // e.g., "iri abụọ"
        if (unitDigit > 0) {
          // Add connector "na" and unit word if needed.
          words.add(_na);
          words.add(_wordsUnder20[unitDigit]);
        }
      }
    }

    return words.join(' ');
  }

  /// Capitalizes the first letter of a string. Helper function.
  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
