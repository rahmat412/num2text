import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/my_options.dart';
import '../utils/utils.dart';

/// {@template num2text_my}
/// Converts numbers to Burmese words (`Lang.MY`).
///
/// Implements [Num2TextBase] for Burmese, handling various numeric types.
/// Supports cardinal numbers, decimals, negatives, and currency.
/// Uses the traditional Burmese numbering system (သောင်း, သိန်း, သန်း, ကုဋေ)
/// and standard international scales (ဘီလီယံ, ထရီလီယံ, etc.) for larger numbers.
/// Features Burmese connectors (e.g., ဆယ့်, ရာ့, ထောင့်).
/// Customizable via [MyOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextMY implements Num2TextBase {
  // --- Constants ---
  static const String _pointWord = "ဒသမ"; // Decimal separator "."
  static const String _commaWord = "ကော်မာ"; // Decimal separator ","
  static const String _infinityWord = "အဆုံးမရှိ"; // "Infinity"
  static const String _nanWord = "နံပါတ်မဟုတ်ပါ"; // "Not a Number"

  /// Digits 0-9.
  static const List<String> _wordsUnits = [
    "သုည",
    "တစ်",
    "နှစ်",
    "သုံး",
    "လေး",
    "ငါး",
    "ခြောက်",
    "ခုနစ်",
    "ရှစ်",
    "ကိုး",
  ];

  // --- Scale Words and Connectors ---
  static const String _ten = "ဆယ်"; // Ten (standalone)
  static const String _tenConnector =
      "ဆယ့်"; // Ten (connecting form, e.g., ဆယ့်တစ်)
  static const String _hundred = "ရာ"; // Hundred (standalone)
  static const String _hundredConnector =
      "ရာ့"; // Hundred (connecting form, e.g., တစ်ရာ့ငါးဆယ်)
  static const String _thousand = "ထောင်"; // Thousand (standalone)
  static const String _thousandConnector =
      "ထောင့်"; // Thousand (connecting form)
  static const String _tenThousand = "သောင်း"; // Ten Thousand (standalone)
  static const String _tenThousandConnector =
      "သောင်း့"; // Ten Thousand (connecting form)
  static const String _lakh = "သိန်း"; // Lakh / Hundred Thousand (10^5)
  static const String _million =
      "သန်း"; // Million (10^6) - Used alongside သိန်း
  static const String _kute = "ကုဋေ"; // Kute / Ten Million (10^7)
  static const String _billion = "ဘီလီယံ"; // Billion (10^9)
  static const String _trillion = "ထရီလီယံ"; // Trillion (10^12)
  static const String _quadrillion = "ကွာဒရီလီယံ"; // Quadrillion (10^15)
  static const String _quintillion = "ကွင်တီလီယံ"; // Quintillion (10^18)
  static const String _sextillion = "ဆက်စတီလီယံ"; // Sextillion (10^21)
  static const String _septillion = "ဆက်ပတီလီယံ"; // Septillion (10^24)

  /// Defines Burmese and international scales, ordered largest to smallest for processing.
  /// Tuple: (Scale Value, Scale Name)
  static final List<(BigInt, String)> _scales = [
    (BigInt.parse("1000000000000000000000000"), _septillion),
    (BigInt.parse("1000000000000000000000"), _sextillion),
    (BigInt.parse("1000000000000000000"), _quintillion),
    (BigInt.parse("1000000000000000"), _quadrillion),
    (BigInt.parse("1000000000000"), _trillion),
    (BigInt.parse("1000000000"), _billion),
    (BigInt.from(10000000), _kute), // 10^7
    (BigInt.from(1000000), _million), // 10^6
    (BigInt.from(100000), _lakh), // 10^5
    (BigInt.from(10000), _tenThousand), // 10^4
    // Thousand (10^3) is handled separately after these scales.
  ];

  /// {@macro num2text_base_process}
  /// Converts the given [number] into Burmese words.
  ///
  /// Handles `int`, `double`, `BigInt`, `Decimal`, and numeric `String`.
  /// Uses [MyOptions] for customization (currency, decimals, negative prefix).
  /// Returns [fallbackOnError] or a default error message on failure.
  ///
  /// @param number The number to convert.
  /// @param options Optional [MyOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Burmese words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final MyOptions myOptions =
        options is MyOptions ? options : const MyOptions();
    final String errorWord = fallbackOnError ?? _nanWord;

    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? "${myOptions.negativePrefix.trim()} $_infinityWord"
            : _infinityWord;
      }
      if (number.isNaN) return errorWord;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorWord;

    // Handle zero.
    if (decimalValue == Decimal.zero) {
      return myOptions.currency
          ? "${_wordsUnits[0]} ${myOptions.currencyInfo.mainUnitSingular}" // e.g., "သုည ကျပ်"
          : _wordsUnits[0]; // "သုည"
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    // Dispatch based on format. Year format is not specifically handled, treated as cardinal.
    if (myOptions.currency) {
      textResult = _handleCurrency(absValue, myOptions);
    } else {
      textResult = _handleStandardNumber(absValue, myOptions);
    }

    // Apply negative prefix if needed.
    // Avoid prefixing if the result is zero (e.g., -0.001 rounding to 0).
    if (isNegative && textResult != _wordsUnits[0]) {
      textResult = "${myOptions.negativePrefix.trim()} $textResult";
    }
    // Handle cases like -0.1 rounding to 0 kyat - should be "သုည ကျပ်".
    else if (isNegative && textResult == _wordsUnits[0] && myOptions.currency) {
      return "${_wordsUnits[0]} ${myOptions.currencyInfo.mainUnitSingular}";
    }

    return textResult;
  }

  /// Converts a non-negative [BigInt] integer into Burmese words.
  ///
  /// Uses Burmese/international scales and connectors.
  ///
  /// @param n The non-negative integer.
  /// @return The integer as Burmese words.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _wordsUnits[0];
    if (n < BigInt.zero) {
      // Internal safeguard; negativity is handled in `process`.
      throw ArgumentError(
          "Internal error: _convertInteger called with negative number: $n");
    }

    // Handle numbers under 1000 directly.
    if (n < BigInt.from(1000)) {
      return _convertUnder1000(n.toInt());
    }

    List<String> parts =
        []; // Stores parts like "တစ်ကုဋေ", "ငါးသန်း", "ခြောက်ရာ့သုံးဆယ်"
    BigInt currentN = n;
    final BigInt thousandValue = BigInt.from(1000);
    // Scales requiring space after the count (Billion+). Others join directly.
    final List<String> spaceAfterCountScales = [
      _billion,
      _trillion,
      _quadrillion,
      _quintillion,
      _sextillion,
      _septillion
    ];

    // Process defined scales (Kute, Million, Lakh, Ten Thousand, etc.)
    for (var (scaleValue, scaleWord) in _scales) {
      if (currentN >= scaleValue) {
        BigInt count = currentN ~/ scaleValue; // How many of this scale?
        BigInt remainderAfterScale =
            currentN % scaleValue; // Remainder for next steps.

        String countText =
            _convertInteger(count); // Recursively convert the count.
        String actualScaleWord = scaleWord;
        bool useConnector = false;

        // Use connector form for Ten Thousand if there's a remainder.
        if (scaleWord == _tenThousand && remainderAfterScale > BigInt.zero) {
          actualScaleWord = _tenThousandConnector;
          useConnector = true;
        }

        // Assemble the chunk for this scale.
        String chunk;
        if (useConnector) {
          chunk = '$countText$actualScaleWord'; // Connectors join directly.
        } else if (spaceAfterCountScales.contains(actualScaleWord)) {
          chunk =
              '$countText $actualScaleWord'; // Billion+ scales need a space.
        } else {
          chunk =
              '$countText$actualScaleWord'; // Lakh, Million, Kute join directly.
        }
        parts.add(chunk);

        currentN = remainderAfterScale; // Update remaining number.
      }
    }

    // Process Thousands separately after larger scales.
    if (currentN >= thousandValue) {
      BigInt thousandCount = currentN ~/ thousandValue;
      BigInt remainderAfterThousand = currentN % thousandValue;

      String countText =
          _convertInteger(thousandCount); // Convert the count of thousands.
      // Use connector form if there's a remainder under 1000.
      String thousandWord = (remainderAfterThousand > BigInt.zero)
          ? _thousandConnector
          : _thousand;

      // Thousand always joins directly to its count.
      String chunk = '$countText$thousandWord';
      parts.add(chunk);

      currentN = remainderAfterThousand; // Update remaining number (0-999).
    }

    // Process the final remainder (0-999).
    if (currentN > BigInt.zero) {
      parts.add(_convertUnder1000(currentN.toInt()));
    }

    // Join all parts with spaces.
    String result = parts.join(' ');

    // Final cleanup: Remove spaces potentially added *after* connectors by join(' ').
    // Example: "တစ်ထောင့် ငါးရာ" should become "တစ်ထောင့်ငါးရာ".
    result = result.replaceAll('$_hundredConnector ', _hundredConnector);
    result = result.replaceAll('$_thousandConnector ', _thousandConnector);
    result =
        result.replaceAll('$_tenThousandConnector ', _tenThousandConnector);
    result = result.replaceAll('$_tenConnector ', _tenConnector);

    return result.trim();
  }

  /// Converts an integer from 1 to 999 into Burmese words.
  /// Handles hundreds, tens, units, and connectors.
  ///
  /// @param n The integer (1-999).
  /// @return The number as Burmese words. Returns empty string if n <= 0.
  String _convertUnder1000(int n) {
    if (n <= 0 || n >= 1000) return ""; // Handle 0 or out of range.

    StringBuffer buffer = StringBuffer();
    int remainder = n;

    // --- Hundreds ---
    if (remainder >= 100) {
      int hundredsDigit = remainder ~/ 100;
      int hundredRem = remainder % 100;
      buffer.write(_wordsUnits[hundredsDigit]); // e.g., "တစ်"
      // Use connector if remainder exists, standalone otherwise.
      buffer.write(
          hundredRem > 0 ? _hundredConnector : _hundred); // e.g., "ရာ့" or "ရာ"
      remainder %= 100; // Update remainder (0-99).
    }

    // --- Tens and Units ---
    if (remainder > 0) {
      // Space is handled by the caller (_convertInteger) between major parts.

      if (remainder < 10) {
        buffer.write(_wordsUnits[remainder]); // 1-9
      } else if (remainder == 10) {
        // Burmese often uses "တစ်ဆယ်" for 10.
        buffer.write("${_wordsUnits[1]}$_ten");
      } else if (remainder < 20) {
        // 11-19: Use ten connector form "တစ်ဆယ့်..."
        buffer.write(
            "${_wordsUnits[1]}$_tenConnector${_wordsUnits[remainder % 10]}");
      } else {
        // 20-99
        int tensDigit = remainder ~/ 10;
        int unitDigit = remainder % 10;
        buffer.write(_wordsUnits[tensDigit]); // e.g., "နှစ်" for 20s

        if (unitDigit == 0) {
          buffer.write(_ten); // e.g., "နှစ်ဆယ်" for 20
        } else {
          // Use connector form for tens, then unit. e.g., "နှစ်ဆယ့်ခုနစ်" for 27.
          buffer.write("$_tenConnector${_wordsUnits[unitDigit]}");
        }
      }
    }
    return buffer.toString();
  }

  /// Converts a non-negative [Decimal] to Burmese currency words.
  ///
  /// Uses [MyOptions.currencyInfo]. Assumes Kyat and Pya (100 pyas = 1 kyat).
  /// Rounds to 2 decimal places.
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Burmese words.
  String _handleCurrency(Decimal absValue, MyOptions options) {
    final CurrencyInfo ci = options.currencyInfo;

    // Round to 2 decimal places for Pya.
    final Decimal roundedValue = absValue.round(scale: 2);
    final BigInt mainValue = roundedValue.truncate().toBigInt(); // Kyat
    // Calculate subunit value (Pya) carefully after rounding.
    final BigInt subunitValue =
        (roundedValue.remainder(Decimal.one).abs() * Decimal.fromInt(100))
            .truncate()
            .toBigInt();

    // Handle zero amount after rounding.
    if (mainValue == BigInt.zero && subunitValue == BigInt.zero) {
      return "${_wordsUnits[0]} ${ci.mainUnitSingular}"; // "သုည ကျပ်"
    }

    String mainPart = '';
    String subPart = '';

    // --- Main Unit (Kyat) ---
    if (mainValue > BigInt.zero) {
      mainPart = '${_convertInteger(mainValue)} ${ci.mainUnitSingular}';
    }

    // --- Subunit (Pya) ---
    if (subunitValue > BigInt.zero) {
      // Ensure subunit name exists.
      if (ci.subUnitSingular != null && ci.subUnitSingular!.isNotEmpty) {
        subPart = '${_convertInteger(subunitValue)} ${ci.subUnitSingular!}';
      }
    }

    // --- Combine Parts ---
    if (mainPart.isNotEmpty && subPart.isNotEmpty) {
      // Use custom separator if provided, otherwise default to a space.
      String separator =
          ci.separator?.isNotEmpty ?? false ? ' ${ci.separator!} ' : ' ';
      return '$mainPart$separator$subPart';
    } else if (mainPart.isNotEmpty) {
      return mainPart; // Only Kyat.
    } else {
      // Only Pya (handles cases like 0.50 Kyat).
      return subPart;
    }
  }

  /// Converts a non-negative standard [Decimal] number to Burmese words.
  ///
  /// Handles integer and fractional parts. Fractional part read digit by digit.
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Used for `decimalSeparator`.
  /// @return Number as Burmese words.
  String _handleStandardNumber(Decimal absValue, MyOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue.remainder(Decimal.one).abs();

    // Convert integer part. Use "သုည" if integer is 0 but fraction exists (e.g., 0.5).
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _wordsUnits[0]
            : _convertInteger(integerPart);

    String fractionalWords = '';
    // Process fractional part if it exists.
    if (fractionalPart > Decimal.zero) {
      String separatorWord =
          (options.decimalSeparator == DecimalSeparator.comma)
              ? _commaWord
              : _pointWord; // Default to "ဒသမ".

      // Get fractional digits string representation.
      // toString() is usually sufficient. Using toStringAsFixed might add too many zeros.
      String fractionalDigits = absValue.toString().split('.').last;

      // Remove trailing zeros as they are typically not spoken.
      while (fractionalDigits.endsWith('0') && fractionalDigits.length > 1) {
        fractionalDigits =
            fractionalDigits.substring(0, fractionalDigits.length - 1);
      }

      // Convert remaining digits individually.
      if (fractionalDigits.isNotEmpty) {
        List<String> digitWords = fractionalDigits.split('').map((d) {
          return _wordsUnits[int.parse(d)];
        }).toList();
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }

    return '$integerWords$fractionalWords'.trim();
  }
}
