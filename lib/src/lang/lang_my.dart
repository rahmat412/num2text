import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/my_options.dart';
import '../utils/utils.dart';

/// {@template num2text_my}
/// The Burmese language (`Lang.MY`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Burmese word representation following standard Burmese grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [MyOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers
/// incorporating Burmese-specific scales like သိန်း (lakh), သန်း (million), and ကုဋေ (kute),
/// alongside adopted international scale terms.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [MyOptions].
/// {@endtemplate}
class Num2TextMY implements Num2TextBase {
  /// Word for the decimal point ("."). Burmese: "da tha ma".
  static const String _pointWord = "ဒသမ";

  /// Word for the comma (",") separator. Burmese: "kaw mar". Used less commonly for decimals.
  static const String _commaWord = "ကော်မာ";

  /// Word for infinity. Burmese: "a sone ma shi".
  static const String _infinityWord = "အဆုံးမရှိ";

  /// Word for "Not a Number". Burmese: "nan par ma hote par".
  static const String _nanWord = "နံပါတ်မဟုတ်ပါ";

  /// Base digits 0-9 in Burmese words.
  static const List<String> _wordsUnits = [
    "သုည", // 0 - thunya
    "တစ်", // 1 - tit
    "နှစ်", // 2 - hnit
    "သုံး", // 3 - thone
    "လေး", // 4 - lay
    "ငါး", // 5 - nga
    "ခြောက်", // 6 - chauk
    "ခုနစ်", // 7 - khunnit
    "ရှစ်", // 8 - shit
    "ကိုး", // 9 - koe
  ];

  /// Word for ten. Burmese: "hseh". Used when the unit digit is zero (e.g., 20, 30).
  static const String _ten = "ဆယ်";

  /// Connector word for tens. Burmese: "hse". Used when the unit digit is non-zero (e.g., 11, 21).
  static const String _tenConnector = "ဆယ့်";

  /// Word for hundred. Burmese: "yar". Used when tens and units are zero (e.g., 100, 200).
  static const String _hundred = "ရာ";

  /// Connector word for hundreds. Burmese: "yar". Used when tens or units are non-zero (e.g., 101, 110). Note: Same spelling, different usage context.
  static const String _hundredConnector = "ရာ့";

  /// Word for thousand. Burmese: "htaung". Used when lower place values are zero (e.g., 1000, 2000).
  static const String _thousand = "ထောင်";

  /// Connector word for thousands. Burmese: "htaung". Used when lower place values are non-zero (e.g., 1001, 1100). Note: Same spelling, different usage context.
  static const String _thousandConnector = "ထောင့်";

  /// Word for ten thousand (10^4). Burmese: "thaung".
  static const String _tenThousand = "သောင်း";

  /// Word for one hundred thousand (10^5), also known as Lakh. Burmese: "thein".
  static const String _lakh = "သိန်း";

  /// Word for one million (10^6). Burmese: "than".
  static const String _million = "သန်း";

  /// Word for ten million (10^7), also known as Kute/Crore. Burmese: "kute".
  static const String _kute = "ကုဋေ";

  /// Word for one billion (10^9) - using international scale term. Burmese: "bee lee yan".
  static const String _billion = "ဘီလီယံ";

  /// Word for one trillion (10^12) - using international scale term. Burmese: "htree lee yan".
  static const String _trillion = "ထရီလီယံ";

  /// Word for one quadrillion (10^15) - using international scale term. Burmese: "kwar dree lee yan".
  static const String _quadrillion = "ကွာဒရီလီယံ";

  /// Word for one quintillion (10^18) - using international scale term. Burmese: "kwin tee lee yan".
  static const String _quintillion = "ကွင်တီလီယံ";

  /// Word for one sextillion (10^21) - using international scale term. Burmese: "set tee lee yan".
  static const String _sextillion = "ဆက်စတီလီယံ";

  /// Word for one septillion (10^24) - using international scale term. Burmese: "set pa tee lee yan".
  static const String _septillion = "ဆက်ပတီလီယံ";

  /// Defines the large number scales used in Burmese, mapping the numeric value
  /// to its corresponding word representation. Ordered from largest to smallest.
  /// Includes both traditional Burmese units (ကုဋေ, သန်း, သိန်း, သောင်း) and
  /// adopted international units (billion, trillion, etc.).
  static final List<(BigInt, String)> _scales = [
    (BigInt.parse("1000000000000000000000000"), _septillion), // 10^24
    (BigInt.parse("1000000000000000000000"), _sextillion), // 10^21
    (BigInt.parse("1000000000000000000"), _quintillion), // 10^18
    (BigInt.parse("1000000000000000"), _quadrillion), // 10^15
    (BigInt.parse("1000000000000"), _trillion), // 10^12
    (BigInt.parse("1000000000"), _billion), // 10^9
    (BigInt.from(10000000), _kute), // 10^7 (Ten Million / Kute / Crore)
    (BigInt.from(1000000), _million), // 10^6 (Million)
    (BigInt.from(100000), _lakh), // 10^5 (Hundred Thousand / Lakh)
    (BigInt.from(10000), _tenThousand), // 10^4 (Ten Thousand)
    // Thousand (10^3) is handled separately within _convertInteger for connector logic.
  ];

  /// Processes the given [number] and converts it into Burmese words.
  ///
  /// This is the main entry point for the Burmese conversion.
  /// - It normalizes the input [number] (int, double, BigInt, String, Decimal) into a [Decimal].
  /// - Handles special cases like infinity and NaN for doubles.
  /// - Manages the negative sign using [MyOptions.negativePrefix].
  /// - Delegates the core conversion logic to helper methods based on [options]:
  ///   - [_convertInteger] for year format ([Format.year]).
  ///   - [_handleCurrency] if [MyOptions.currency] is true.
  ///   - [_handleStandardNumber] for regular cardinal numbers (including decimals).
  /// - Returns the final word representation or [fallbackOnError] / default error message.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have Burmese-specific options, using defaults if none are provided.
    final MyOptions myOptions =
        options is MyOptions ? options : const MyOptions();

    // Handle special double values before normalization.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? "${myOptions.negativePrefix.trim()} $_infinityWord" // Add negative prefix if needed
            : _infinityWord;
      }
      if (number.isNaN)
        return fallbackOnError ?? _nanWord; // Return fallback or NaN word
    }

    // Normalize the input number to Decimal for precision.
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null)
      return fallbackOnError ?? _nanWord; // Handle normalization failure

    // Handle the specific case of zero.
    if (decimalValue == Decimal.zero) {
      return myOptions.currency
          // For currency, format as "zero [main unit]"
          ? "${_wordsUnits[0]} ${myOptions.currencyInfo.mainUnitSingular}"
          // Otherwise, just return the word for zero ("သုည")
          : _wordsUnits[0];
    }

    // Determine sign and work with the absolute value.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    // Delegate based on the format specified in options.
    if (myOptions.format == Format.year) {
      // Years are treated as integers, convert the integer part.
      textResult = _convertInteger(absValue.truncate().toBigInt());
    } else if (myOptions.currency) {
      // Handle currency formatting.
      textResult = _handleCurrency(absValue, myOptions);
    } else {
      // Handle standard number formatting (potentially with decimals).
      textResult = _handleStandardNumber(absValue, myOptions);
    }

    // Prepend the negative prefix if the original number was negative.
    if (isNegative) {
      textResult = "${myOptions.negativePrefix.trim()} $textResult";
    }
    return textResult;
  }

  /// Formats the absolute [absValue] as Burmese currency.
  ///
  /// Uses the [CurrencyInfo] provided in [options] to get unit names.
  /// Separates the main unit value and the subunit value (assuming 2 decimal places for subunits like Pya).
  /// Converts both parts to words using [_convertInteger] and joins them with unit names.
  String _handleCurrency(Decimal absValue, MyOptions options) {
    final CurrencyInfo ci = options.currencyInfo;
    // Get the integer part for the main currency unit (e.g., Kyat).
    final BigInt mainValue = absValue.truncate().toBigInt();
    // Calculate the subunit value (e.g., Pya) - assumes 100 subunits per main unit.
    final BigInt subunitValue =
        (absValue.remainder(Decimal.one) * Decimal.fromInt(100))
            .truncate()
            .toBigInt();

    // Convert the main value to words.
    String mainText = _convertInteger(mainValue);
    // Start building the result string with main value and unit.
    String result =
        '$mainText ${ci.mainUnitSingular}'; // e.g., "တစ်ရာ ကျပ်" (100 Kyat)

    // If there's a non-zero subunit value, add it.
    if (subunitValue > BigInt.zero) {
      // Convert subunit value to words and add subunit name.
      // Assumes subUnitSingular is never null if subunits exist (defined in CurrencyInfo).
      result +=
          ' ${_convertInteger(subunitValue)} ${ci.subUnitSingular!}'; // e.g., " ငါးဆယ် ပြား" (50 Pya)
    }
    return result;
  }

  /// Formats the absolute [absValue] as a standard Burmese cardinal number, including decimals if present.
  ///
  /// Separates the integer and fractional parts.
  /// Converts the integer part using [_convertInteger].
  /// Converts the fractional part digit by digit, joined by spaces, prefixed by the appropriate decimal separator word ("ဒသမ" or "ကော်မာ").
  /// Trims trailing zeros from the fractional part for cleaner output (e.g., 1.50 -> "one point five").
  String _handleStandardNumber(Decimal absValue, MyOptions options) {
    // Get the integer part of the number.
    final BigInt integerPart = absValue.truncate().toBigInt();
    // Get the fractional part of the number.
    final Decimal fractionalPart = absValue.remainder(Decimal.one);

    // Convert the integer part to words.
    // Handle the special case "0.xxx": if integer is 0 but there's a fractional part, output "သုည".
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _wordsUnits[0] // Use "သုည" for the integer part if it's 0.xxx
            : _convertInteger(
                integerPart); // Otherwise, convert the integer normally.

    String fractionalWords = '';
    // Process the fractional part only if it's greater than zero.
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word ("ဒသမ" or "ကော်မာ") based on options.
      String separatorWord = options.decimalSeparator == DecimalSeparator.comma
          ? _commaWord
          : _pointWord;

      // Get the fractional digits as a string (e.g., from 0.123, get "123").
      String fractionalDigits = fractionalPart.toString().substring(2);

      // Trim trailing zeros (e.g., "50" -> "5", "550" -> "55"), but keep at least one digit ("0" stays "0").
      while (fractionalDigits.endsWith('0') && fractionalDigits.length > 1) {
        fractionalDigits =
            fractionalDigits.substring(0, fractionalDigits.length - 1);
      }

      // Convert each remaining digit after the separator to its word form.
      List<String> digitWords = fractionalDigits
          .split('')
          .map((d) => _wordsUnits[int.parse(d)])
          .toList();

      // Combine the separator word and the spoken digits.
      fractionalWords =
          ' $separatorWord ${digitWords.join(' ')}'; // e.g., " ဒသမ တစ် နှစ် သုံး"
    }

    // Combine integer and fractional parts, trimming any leading/trailing whitespace.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] [n] into its Burmese word representation.
  ///
  /// Handles numbers from zero up to the limits defined in [_scales].
  /// Uses a recursive approach, breaking down the number by the defined scales
  /// (Septillion down to Ten Thousand) and converting chunks using [_convertInteger]
  /// for the count and [_convertUnder1000] for the final remainder.
  /// Handles the thousands place separately to apply the correct connector word ("ထောင်" vs "ထောင့်").
  /// Joins the resulting parts with spaces, respecting connector logic.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _wordsUnits[0]; // Base case: zero
    // Internal consistency check: This function should only receive non-negative numbers.
    if (n < BigInt.zero) {
      throw ArgumentError(
          "Internal error: _convertInteger called with negative number: $n");
    }

    // Handle numbers less than 1000 directly using the dedicated helper function.
    if (n < BigInt.from(1000)) {
      return _convertUnder1000(n.toInt());
    }

    List<String> parts =
        []; // Stores word chunks for each scale (e.g., "five kute", "two thousand")
    BigInt remaining = n; // The portion of the number still to be converted

    // Process large scales iteratively from largest to smallest.
    for (var scaleInfo in _scales) {
      final scaleValue =
          scaleInfo.$1; // Numeric value of the scale (e.g., 10^7 for Kute)
      if (remaining >= scaleValue) {
        // Calculate how many times this scale unit fits into the remaining number.
        BigInt count = remaining ~/ scaleValue;
        // Update the remainder.
        remaining %= scaleValue;
        // Recursively convert the count for this scale unit into words.
        String countText = _convertInteger(count);
        // Get the word for this scale unit (e.g., "ကုဋေ").
        String scaleWord = scaleInfo.$2;

        // Construct the chunk: "count [scaleWord]".
        // Special case: If count is 1 ("တစ်"), omit the space for natural phrasing, e.g., "တစ်ကုဋေ".
        String chunk = (count == BigInt.one && countText == _wordsUnits[1])
            ? '$countText$scaleWord' // "တစ်" directly joined with scale word
            : '$countText $scaleWord'; // Count word, space, then scale word
        parts.add(chunk);
      }
    }

    // Process the thousands place separately to manage the connector word correctly.
    String?
        thousandPart; // Stores the words for the thousands chunk if it exists.
    if (remaining >= BigInt.from(1000)) {
      // Calculate how many thousands fit.
      BigInt thousandCount = remaining ~/ BigInt.from(1000);
      // Find the remainder after removing thousands (this will be < 1000).
      BigInt remainderAfterThousand = remaining % BigInt.from(1000);
      // Update the main remainder for the next step.
      remaining = remainderAfterThousand;

      // Convert the count of thousands into words.
      String countText = _convertInteger(thousandCount);

      // Choose the correct thousand word: "ထောင်" (htaung) or connector "ထောင့်" (htaung).
      // Use the connector "ထောင့်" if there's a non-zero remainder less than 1000 following it.
      String thousandWord = (remainderAfterThousand > BigInt.zero)
          ? _thousandConnector
          : _thousand;

      // Construct the thousands chunk, e.g., "နှစ်ထောင့်" (two thousand-and-...) or "သုံးထောင်" (three thousand).
      thousandPart = '$countText$thousandWord';
      parts.add(thousandPart);
    }

    // Process the final remaining part (which must be less than 1000).
    String? remainderPart; // Stores the words for the < 1000 remainder.
    if (remaining > BigInt.zero) {
      remainderPart = _convertUnder1000(remaining.toInt());
      parts.add(remainderPart);
    }

    // If no parts were generated (shouldn't happen for n > 0), return empty string.
    if (parts.isEmpty) return "";

    // Combine the collected parts with appropriate spacing.
    StringBuffer result = StringBuffer();
    result.write(parts[0]); // Start with the first (largest scale) part.

    for (int i = 1; i < parts.length; i++) {
      String previousPart = parts[i - 1];
      String currentPart = parts[i];

      // Determine if the previous part ended specifically with the thousand connector "ထောင့်".
      // This check is crucial to avoid adding an extra space after "ထောင့်".
      bool previousWasThousandConnector = (thousandPart !=
              null && // Ensure thousandPart was actually processed
          previousPart ==
              thousandPart && // Check if the previous part *is* the thousand part
          thousandPart.endsWith(
              _thousandConnector)); // Check if it used the connector form

      // Add a space separator unless the previous part used the thousand connector.
      if (!previousWasThousandConnector) {
        result.write(' ');
      }

      result.write(currentPart); // Append the current part.
    }

    return result.toString();
  }

  /// Converts an integer [n] between 0 and 999 into its Burmese word representation.
  ///
  /// Handles hundreds, tens, and units places, applying the correct connector words
  /// ("ရာ့" for hundreds, "ဆယ့်" for tens) based on the context.
  String _convertUnder1000(int n) {
    // Input validation: Ensure n is within the expected range [0, 999].
    if (n < 0 || n >= 1000) {
      return (n == 0)
          ? _wordsUnits[0]
          : ""; // Handle 0 or return "" for out of range
    }

    StringBuffer buffer = StringBuffer();
    int remainder = n; // Work with a mutable remainder.

    // --- Handle hundreds place ---
    if (remainder >= 100) {
      int hundredsDigit = remainder ~/ 100; // Get the hundreds digit (1-9).
      remainder %= 100; // Update remainder to the tens and units part (0-99).
      buffer.write(_wordsUnits[
          hundredsDigit]); // Write the digit word, e.g., "တစ်" (one).

      // Append the hundred word ("ရာ") or connector ("ရာ့").
      // Use the connector "ရာ့" if there are non-zero tens/units following it.
      buffer.write(
        remainder > 0 ? _hundredConnector : _hundred,
      ); // e.g., "ရာ့" (for 1xx where xx > 0) or "ရာ" (for 100).
    }

    // --- Handle tens and units place (remainder is now 0-99) ---
    if (remainder > 0) {
      if (remainder < 10) {
        // Case 1: Remainder is 1-9.
        buffer.write(_wordsUnits[
            remainder]); // Just write the unit word, e.g., "ငါး" (five).
      } else if (remainder == 10) {
        // Case 2: Remainder is exactly 10.
        buffer.write("${_wordsUnits[1]}$_ten"); // Write "တစ်ဆယ်" (ten).
      } else if (remainder < 20) {
        // Case 3: Remainder is 11-19.
        // Write "တစ်ဆယ့်" (tit-hse) followed by the unit digit word.
        buffer.write(
          "${_wordsUnits[1]}$_tenConnector${_wordsUnits[remainder % 10]}",
        ); // e.g., "တစ်ဆယ့်သုံး" (thirteen).
      } else {
        // Case 4: Remainder is 20-99.
        int tensDigit = remainder ~/ 10; // Get the tens digit (2-9).
        int unitDigit = remainder % 10; // Get the unit digit (0-9).
        buffer.write(_wordsUnits[
            tensDigit]); // Write the tens digit word, e.g., "နှစ်" (two).

        if (unitDigit == 0) {
          // Subcase 4a: Unit is 0 (20, 30, ..., 90). Append "ဆယ်" (ten).
          buffer.write(_ten); // e.g., completes to "နှစ်ဆယ်" (twenty).
        } else {
          // Subcase 4b: Unit is non-zero (21-29, ..., 91-99). Append connector "ဆယ့်" and the unit word.
          buffer.write(
            "$_tenConnector${_wordsUnits[unitDigit]}",
          ); // e.g., completes to "နှစ်ဆယ့်ငါး" (twenty-five).
        }
      }
    }
    return buffer.toString();
  }
}
