// ignore_for_file: constant_identifier_names

import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/zu_options.dart';
import '../utils/utils.dart';

/// Represents relevant Zulu noun classes used for grammatical agreement with numbers.
///
/// S = Singular, P = Plural. Numbers correspond to standard Bantu noun class numbering.
enum _NounClass {
  /// Class 5 singular (e.g., i(li)-bhiliyoni)
  cl5_S,

  /// Class 6 plural (e.g., ama-bhiliyoni, ama-shumi)
  cl6_P,

  /// Class 7 singular (e.g., isi-gidi, isenti)
  cl7_S,

  /// Class 8 plural (e.g., izi-gidi)
  cl8_P,

  /// Class 9 singular (e.g., in-kulungwane)
  cl9_S,

  /// Class 10 plural (e.g., izin-kulungwane)
  cl10_P,

  /// Indicates no specific noun class agreement is needed or known.
  unknown,
}

/// {@template num2text_zu}
/// The Zulu language (`Lang.ZU`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Zulu word representation, adhering to Zulu's complex grammatical agreement rules
/// based on noun classes.
///
/// Capabilities include handling cardinal numbers, currency (using [ZuOptions.currencyInfo]
/// and applying noun class agreement), year formatting ([Format.year]), negative numbers,
/// decimals (spoken digit by digit), and large numbers using standard scale names
/// (thousand, million, etc.) with appropriate noun class prefixes. Invalid inputs result
/// in a fallback message.
///
/// Behavior can be customized using [ZuOptions].
/// {@endtemplate}
class Num2TextZU implements Num2TextBase {
  /// The word for zero.
  static const String _zero =
      "zero"; // Using English "zero" as standard loanword

  /// The word for the decimal separator when `DecimalSeparator.period` is used.
  static const String _pointWord = "iphoyinti"; // Loanword for "point"

  /// The word for the decimal separator when `DecimalSeparator.comma` is used.
  static const String _commaWord = "ikhefu"; // "comma" or "pause"

  /// Suffix added for negative years (Before Christ).
  static const String _yearSuffixBC = "BC"; // Standard abbreviation

  /// Suffix added for positive years (Anno Domini / Common Era) if `includeAD` is true.
  static const String _yearSuffixAD = "AD"; // Standard abbreviation

  /// Base number words (1-9) without noun class agreement.
  static const Map<int, String> _fullBaseNumbers = {
    1: "nye", // Stem for 'one'
    2: "bili", // Stem for 'two'
    3: "thathu", // Stem for 'three'
    4: "ne", // Stem for 'four'
    5: "hlanu", // Stem for 'five'
    6: "sithupha", // Full word for 'six'
    7: "khombisa", // Full word for 'seven'
    8: "shiyagalombili", // Full word for 'eight'
    9: "shiyagalolunye", // Full word for 'nine'
  };

  /// Stems for the number 'one' requiring agreement with specific noun classes.
  static const Map<_NounClass, String> _oneStems = {
    _NounClass.cl5_S: "lodwa", // e.g., iRandi elilodwa
    _NounClass.cl6_P:
        "wodwa", // e.g., amashumi awodwa (?) - Less common usage needed
    _NounClass.cl7_S: "sodwa", // e.g., isenti elisodwa
    _NounClass.cl8_P:
        "zodwa", // e.g., izigidi ezizodwa (?) - Less common usage needed
    _NounClass.cl9_S: "yodwa", // e.g., inkulungwane eyodwa
    _NounClass.cl10_P:
        "zodwa", // e.g., izinkulungwane ezizodwa (?) - Less common usage needed
    _NounClass.unknown: "dwa", // Fallback/unagreed stem
  };

  /// Words for tens (10-90). Note that 20-90 are plural forms based on 'amashumi' (class 6).
  static const Map<int, String> _tens = {
    10: "lishumi", // Class 5 singular 'ten'
    20: "amashumi amabili", // 'Tens that are two'
    30: "amashumi amathathu", // 'Tens that are three'
    40: "amashumi amane", // 'Tens that are four'
    50: "amashumi amahlanu", // 'Tens that are five'
    60: "amashumi ayisithupha", // 'Tens that are six'
    70: "amashumi ayisikhombisa", // 'Tens that are seven'
    80: "amashumi ayisishiyagalombili", // 'Tens that are eight'
    90: "amashumi ayisishiyagalolunye", // 'Tens that are nine'
  };

  /// The word for one hundred (class 5 singular).
  static const String _hundred = "ikhulu";

  /// Defines large number scale units (thousand, million, etc.) with their
  /// singular/plural forms and associated noun classes for agreement.
  static const Map<int, _ScaleInfo> _scales = {
    3: _ScaleInfo(
      "inkulungwane",
      _NounClass.cl9_S,
      "izinkulungwane",
      _NounClass.cl10_P,
    ), // Thousand
    6: _ScaleInfo(
        "isigidi", _NounClass.cl7_S, "izigidi", _NounClass.cl8_P), // Million
    9: _ScaleInfo(
      "ibhiliyoni",
      _NounClass.cl5_S,
      "amabhiliyoni",
      _NounClass.cl6_P,
    ), // Billion (Loanword)
    12: _ScaleInfo(
      "ithriliyoni",
      _NounClass.cl5_S,
      "amathriliyoni",
      _NounClass.cl6_P,
    ), // Trillion (Loanword)
    15: _ScaleInfo(
      "ikhwadriliyoni",
      _NounClass.cl5_S,
      "amakhwadriliyoni",
      _NounClass.cl6_P,
    ), // Quadrillion (Loanword)
    18: _ScaleInfo(
      "ikhwintiliyoni",
      _NounClass.cl5_S,
      "amakhwintiliyoni",
      _NounClass.cl6_P,
    ), // Quintillion (Loanword)
    21: _ScaleInfo(
      "isekstiliyoni",
      _NounClass.cl7_S,
      "amasekstiliyoni",
      _NounClass.cl6_P,
    ), // Sextillion (Loanword - Note class change)
    // Add higher scales if needed, following loanword patterns and assigning classes.
  };

  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have Zulu-specific options, using defaults if none are provided.
    final ZuOptions zuOptions =
        options is ZuOptions ? options : const ZuOptions();

    // Handle special double values immediately.
    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Negative Infinity" : "Infinity";
      if (number.isNaN)
        return fallbackOnError ?? "Not a Number"; // Use fallback if available
    }

    // Normalize the input number to Decimal for precision.
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    // If normalization fails, return fallback or a default error.
    if (decimalValue == null) return fallbackOnError ?? "Not a Number";

    // Handle the edge case of zero.
    if (decimalValue == Decimal.zero) {
      // Special handling for zero currency.
      if (zuOptions.currency) {
        // e.g., "zero amaRandi"
        return "$_zero ${_getCurrencyUnitName(BigInt.zero, false, zuOptions.currencyInfo)}";
      }
      // For years or standard numbers, just return "zero".
      if (zuOptions.format == Format.year) return _zero;
      return _zero;
    }

    // Determine sign and get absolute value.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    // Check format options.
    final bool isCurrency = zuOptions.currency;
    final bool isYear = zuOptions.format == Format.year;

    // Delegate to specific handlers based on format.
    if (isYear) {
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), zuOptions);
    } else if (isCurrency) {
      textResult = _handleCurrency(absValue, zuOptions);
    } else {
      textResult = _handleStandardNumber(absValue, zuOptions);
    }

    // Prepend the negative prefix if needed (and not formatting as a year).
    if (isNegative && !isYear) {
      String prefix = zuOptions.negativePrefix;
      // Add space only if the prefix doesn't already end with one or isn't just "-".
      textResult = prefix.endsWith(" ") || prefix == "-"
          ? "$prefix$textResult"
          : "$prefix $textResult";
    }

    // Clean up multiple spaces and trim leading/trailing whitespace.
    return textResult.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Converts a year integer into its Zulu word representation, handling BC/AD suffixes.
  ///
  /// - [year]: The year value (can be negative for BC).
  /// - [options]: Zulu options, used for the `includeAD` flag.
  /// Returns the year in words (e.g., "inkulungwane namakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesithupha AD").
  String _handleYearFormat(BigInt year, ZuOptions options) {
    final bool isNegative = year < BigInt.zero;
    final BigInt absYear = isNegative ? -year : year;

    // Convert the absolute year value using the standard integer converter.
    String yearText = _convertIntegerStandard(absYear);

    // Append suffixes based on sign and options.
    if (isNegative) {
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD && absYear > BigInt.zero) {
      // Only add AD suffix if option is enabled and year is positive.
      yearText += " $_yearSuffixAD";
    }
    return yearText;
  }

  /// Converts a non-negative Decimal value into Zulu currency words.
  ///
  /// Handles main units and subunits, applying noun class agreement and joining particles.
  /// - [absValue]: The absolute decimal value of the currency amount.
  /// - [options]: Zulu options containing currency info, rounding preference.
  /// Returns the currency value in words (e.g., "iRandi elilodwa nesenti elisodwa").
  String _handleCurrency(Decimal absValue, ZuOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2; // Standard for most currencies
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value if requested, otherwise use the original absolute value.
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate into main unit and subunit integer values.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round().toBigInt();

    String mainText = "";
    String subText = "";

    // Process main unit part if greater than zero.
    if (mainValue > BigInt.zero) {
      // Get the correct unit name (singular/plural).
      String mainUnitName =
          _getCurrencyUnitName(mainValue, false, currencyInfo);
      // Determine the noun class of the main unit.
      _NounClass mainClass = _getCurrencyUnitClass(mainValue, false);
      // Get the standard number text (without agreement).
      String standardMainNumText = _convertIntegerStandard(mainValue);
      // Apply agreement prefix based on the main unit's class.
      String agreedMainNumText = _getAgreedNumberForm(
        mainValue.toInt(), // Agreement logic works with int for now
        mainClass,
        standardMainNumText,
      );
      // Combine unit name and agreed number (e.g., "amaRandi amabili").
      mainText = "$mainUnitName $agreedMainNumText";
    }

    // Process subunit part if greater than zero.
    if (subunitValue > BigInt.zero) {
      // Get the correct subunit name (singular/plural).
      String subUnitName =
          _getCurrencyUnitName(subunitValue, true, currencyInfo);

      // Special case: "one cent" is often "isenti elisodwa".
      if (_isSubunitSingularSpecial(
          subunitValue, true, currencyInfo, subUnitName)) {
        subText = "isenti elisodwa";
      } else {
        // Determine the noun class of the subunit.
        _NounClass subClass = _getCurrencyUnitClass(subunitValue, true);
        // Get standard number text.
        String standardSubNumText = _convertIntegerStandard(subunitValue);
        // Apply agreement prefix based on the subunit's class.
        String agreedSubNumText = _getAgreedNumberForm(
          subunitValue.toInt(), // Agreement logic works with int for now
          subClass,
          standardSubNumText,
        );
        // Combine subunit name and agreed number (e.g., "amasenti angamashumi amahlanu").
        subText = "$subUnitName $agreedSubNumText";
      }
    }

    // Combine main and subunit text.
    if (mainText.isNotEmpty && subText.isNotEmpty) {
      // Determine the joining particle based on the start of the subunit text.
      String separator = currencyInfo.separator ??
          _determineJoinParticle(subText.split(' ').first);
      // Apply the particle correctly (handles vowel coalescence).
      return '$mainText ${_applyParticle(separator, subText)}';
    } else {
      // Return only the non-empty part, or zero if both are empty.
      return mainText.isNotEmpty
          ? mainText
          : subText.isNotEmpty
              ? subText
              // Default to "zero [main unit plural]" if amount was zero.
              : "$_zero ${_getCurrencyUnitName(BigInt.zero, false, currencyInfo)}";
    }
  }

  /// Checks for the special case of "one cent" which uses a specific phrase.
  ///
  /// Returns `true` if the amount is 1 and the subunit is specifically "isenti".
  bool _isSubunitSingularSpecial(
    BigInt amount,
    bool checkSubunit,
    CurrencyInfo info,
    String subunitName,
  ) {
    // This handles cases like ZAR where "1 Rand and 1 cent" is "iRandi elilodwa nesenti elisodwa".
    return checkSubunit &&
        amount == BigInt.one &&
        subunitName == info.subUnitSingular &&
        info.subUnitSingular == "isenti";
  }

  /// Converts a non-negative Decimal value into standard Zulu words (no currency/year logic).
  ///
  /// Handles integer and fractional parts separately. Fractional part is read digit by digit.
  /// - [absValue]: The absolute decimal value.
  /// - [options]: Zulu options containing decimal separator preference.
  /// Returns the number in words (e.g., "ikhulu namashumi amabili nantathu iphoyinti ne hlanu").
  String _handleStandardNumber(Decimal absValue, ZuOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part using the standard converter.
    // If the integer part is zero but there's a fractional part, start with "zero".
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertIntegerStandard(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word ("iphoyinti" or "ikhefu").
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _commaWord;
          break;
        case DecimalSeparator.period:
        case DecimalSeparator.point: // Treat point and period the same
        default: // Default to period/point
          separatorWord = _pointWord;
          break;
      }
      // Extract digits after the decimal point.
      String fractionalDigits = fractionalPart.toString();
      fractionalDigits =
          fractionalDigits.substring(fractionalDigits.indexOf('.') + 1);

      // Convert each digit to its English word equivalent (Zulu doesn't typically spell out digits).
      List<String> digitWords = fractionalDigits.split('').map((digit) {
        final int? digitInt = int.tryParse(digit);
        return (digitInt != null && digitInt >= 0 && digitInt <= 9)
            ? const [
                // Using English names for digits after point
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
              ][digitInt]
            : '?'; // Placeholder for non-digit characters
      }).toList();

      fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
    }
    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Applies the correct noun class agreement prefix to a standard number word.
  ///
  /// - [number]: The integer value (used to determine prefix rules).
  /// - [targetClass]: The noun class of the noun the number modifies.
  /// - [standardText]: The pre-generated standard word form of the number (sometimes ignored, e.g., for 'one').
  /// Returns the number word with the correct agreement prefix (e.g., "bili" -> "amabili" for class 6).
  String _getAgreedNumberForm(
      int number, _NounClass targetClass, String standardText) {
    // If no specific class, return the standard form.
    if (targetClass == _NounClass.unknown) return standardText;

    // Special handling for 'one' which uses different stems based on class.
    if (number == 1) {
      String prefix =
          _getConcordPrefix(1, targetClass, useCurrencyConcord: true);
      String stem = _oneStems[targetClass] ?? _oneStems[_NounClass.unknown]!;
      return _applyPrefix(prefix, stem);
    }

    // For other numbers, get the appropriate prefix and apply it to the standard text.
    String prefix =
        _getConcordPrefix(number, targetClass, useCurrencyConcord: true);
    return _applyPrefix(prefix, standardText);
  }

  /// Converts a non-negative BigInt into standard Zulu words without specific noun agreement.
  ///
  /// Handles numbers from zero up to the defined scales (e.g., Sextillion).
  /// Uses recursive calls for scale chunks and joins parts with appropriate particles.
  /// - [n]: The non-negative integer to convert.
  /// Returns the number in standard Zulu words.
  String _convertIntegerStandard(BigInt n) {
    if (n == BigInt.zero) return _zero;
    // This function assumes non-negative input.
    if (n < BigInt.zero)
      throw ArgumentError("Integer must be non-negative: $n");

    // Handle numbers below 1000 directly.
    if (n < BigInt.from(1000)) {
      return _convertBelow1000Standard(n.toInt());
    }

    List<String> scaleParts = [];
    BigInt remaining = n;
    // Process scales from largest to smallest.
    List<int> sortedScales = _scales.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    for (int power in sortedScales) {
      if (remaining == BigInt.zero) break; // Stop if number is fully processed.
      BigInt scaleValue = BigInt.from(10).pow(power);

      if (remaining >= scaleValue) {
        // How many of this scale unit are there?
        BigInt chunkCount = remaining ~/ scaleValue;
        // What's left after removing this scale chunk?
        remaining %= scaleValue;

        if (chunkCount > BigInt.zero) {
          _ScaleInfo scaleInfo = _scales[power]!;
          bool isSingularScaleCount = chunkCount == BigInt.one;
          // Get the correct scale word (singular/plural).
          String scaleWord =
              isSingularScaleCount ? scaleInfo.singular : scaleInfo.plural;
          // Get the noun class of the scale word.
          _NounClass scaleClass = isSingularScaleCount
              ? scaleInfo.singularClass
              : scaleInfo.pluralClass;

          String countWord;
          // Special case: "one thousand" is just "inkulungwane".
          if (isSingularScaleCount && power == 3) {
            countWord = "";
            // Special case: Other singular scales use the agreed form of 'one'.
          } else if (isSingularScaleCount && power > 3) {
            // e.g., "isigidi esisodwa" (one million)
            countWord = _getAgreedNumberForm(
              1,
              scaleClass,
              "ignored",
            ); // Standard text ignored for 'one'
          } else {
            // Convert the count of this scale unit recursively.
            String standardCountText = _convertIntegerStandard(chunkCount);
            // Apply agreement based on the scale word's class.
            // e.g., "izigidi ezimbili" (two million) - 'ezimbili' agrees with 'izigidi' (cl 8)
            countWord = _getAgreedNumberForm(
                chunkCount.toInt(), scaleClass, standardCountText);
          }

          // Combine scale word and its count.
          String scaleText =
              countWord.isEmpty ? scaleWord : "$scaleWord $countWord";
          scaleParts.add(scaleText);
        }
      }
    }

    // Convert the remaining part (below 1000).
    String below1000Text = "";
    if (remaining > BigInt.zero) {
      below1000Text = _convertBelow1000Standard(remaining.toInt());
    }

    // Join all parts (scales and below-1000) with appropriate particles.
    List<String> finalParts = [];
    if (scaleParts.isNotEmpty) {
      finalParts.add(scaleParts[0]); // Add the largest scale part first.
      for (int i = 1; i < scaleParts.length; i++) {
        // Determine particle based on the *next* scale part.
        String particle = _determineJoinParticle(scaleParts[i]);
        finalParts.add(_applyParticle(particle, scaleParts[i]));
      }
    }
    if (below1000Text.isNotEmpty) {
      if (finalParts.isNotEmpty) {
        // Determine particle based on the below-1000 part.
        String particle = _determineJoinParticle(below1000Text);
        finalParts.add(_applyParticle(particle, below1000Text));
      } else {
        // If no scale parts, just add the below-1000 part.
        finalParts.add(below1000Text);
      }
    }
    return finalParts.join(' ');
  }

  /// Converts an integer between 0 and 999 into standard Zulu words (no specific agreement).
  ///
  /// Handles hundreds, tens (including 11-19), and units, joining them with particles.
  /// - [n]: The integer between 0 and 999.
  /// Returns the number in standard Zulu words.
  String _convertBelow1000Standard(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000)
      throw ArgumentError("Number must be between 0 and 999: $n");

    String? hundredsPart;
    int remainder = n;

    // Process hundreds.
    if (remainder >= 100) {
      int hundredCount = remainder ~/ 100;
      remainder %= 100;

      if (hundredCount == 1) {
        // "one hundred" is just "ikhulu"
        hundredsPart = _hundred;
      } else {
        // e.g., "two hundred" is "amakhulu amabili"
        // The count agrees with "amakhulu" (class 6 plural).
        String countWord =
            _getNumberWordStandard(hundredCount, _NounClass.cl6_P);
        hundredsPart = "amakhulu $countWord";
      }
    }

    String? tensUnitsText;
    // Process remaining tens and units.
    if (remainder > 0) {
      if (remainder < 10) {
        // Simple units 1-9.
        tensUnitsText = _getNumberWordStandard(remainder, _NounClass.unknown);
      } else if (remainder == 10) {
        // "ten"
        tensUnitsText = _getNumberWordStandard(10, _NounClass.unknown);
      } else if (remainder < 20) {
        // Numbers 11-19: "lishumi" + particle + unit.
        String tensPart = _tens[10]!; // "lishumi"
        String unitWord = _fullBaseNumbers[remainder % 10]!;
        String particle = _determineJoinParticle(unitWord);
        tensUnitsText =
            "$tensPart ${_applyParticle(particle, unitWord)}"; // e.g., "lishumi nanye" (11)
      } else {
        // Numbers 20-99.
        int tenVal = (remainder ~/ 10) * 10; // e.g., 20, 30...
        int unitVal = remainder % 10; // e.g., 1, 2...

        // Get the base word for the tens (e.g., "amashumi amabili").
        // The tens count agrees with "amashumi" (class 6 plural).
        String baseTensWord = _getNumberWordStandard(tenVal, _NounClass.cl6_P);

        if (unitVal == 0) {
          // Just the tens word if no units (e.g., "amashumi amabili").
          tensUnitsText = baseTensWord;
        } else {
          // Tens + particle + unit.
          String unitWord = _fullBaseNumbers[unitVal]!;
          String particle = _determineJoinParticle(unitWord);
          // e.g., "amashumi amabili nanye" (21)
          tensUnitsText = "$baseTensWord ${_applyParticle(particle, unitWord)}";
        }
      }
    }

    // Combine hundreds and tens/units parts.
    if (hundredsPart != null && tensUnitsText != null) {
      // e.g., "ikhulu" + particle + "nanye" -> "ikhulu nanye" (101)
      String particle = _determineJoinParticle(tensUnitsText);
      return "$hundredsPart ${_applyParticle(particle, tensUnitsText)}";
    } else {
      // Return whichever part is not null, or empty string if n was 0 initially (caught earlier).
      return hundredsPart ?? tensUnitsText ?? "";
    }
  }

  /// Gets the standard word for a number, potentially applying internal agreement rules.
  ///
  /// This is used internally by `_convertBelow1000Standard` where counts of hundreds
  /// or tens need agreement with "amakhulu" or "amashumi" (both Class 6 Plural).
  /// - [number]: The integer number.
  /// - [internalTargetClass]: The class to agree with (often `_NounClass.cl6_P`).
  /// Returns the standard number word, possibly with cl6 agreement applied.
  String _getNumberWordStandard(int number, _NounClass internalTargetClass) {
    // Apply specific prefixes for numbers 2-9 when agreeing with Class 6 Plural nouns
    // (like 'amakhulu', 'amashumi').
    if (internalTargetClass == _NounClass.cl6_P) {
      if (number >= 2 && number <= 5) {
        String prefix = "ama"; // a- + ma-
        String base = _fullBaseNumbers[number]!;
        return _applyPrefix(prefix, base); // e.g., ama + bili -> amabili
      }
      if (number >= 6 && number <= 9) {
        String prefix = "ayi"; // a- + yi-
        String base = _fullBaseNumbers[number]!;
        return _applyPrefix(
            prefix, base); // e.g., ayi + sithupha -> ayisithupha
      }
      // Handle tens agreeing with cl6_P (recursive call essentially)
      if (number >= 20 && number <= 90 && number % 10 == 0) {
        int count = number ~/ 10;
        // Get the agreed form for the count (e.g., 'amabili' for 2)
        String countWord = _getNumberWordStandard(count, _NounClass.cl6_P);
        return "amashumi $countWord"; // e.g., "amashumi amabili" (20)
      }
    }

    // Fallback to base numbers or tens if no specific cl6 agreement needed here.
    if (_fullBaseNumbers.containsKey(number)) {
      return _fullBaseNumbers[number]!;
    }
    if (number == 10) {
      return _tens[10]!;
    }
    if (number == 100) {
      return _hundred;
    }
    if (_tens.containsKey(number)) {
      return _tens[number]!;
    }

    // If not a base number/ten, assume it's a compound number below 1000
    // and convert it standardly (should not happen if called correctly).
    // This might indicate a logic path needing review if reached often.
    return _convertBelow1000Standard(number);
  }

  /// Converts an integer between 0 and 999, applying agreement based on a target class.
  ///
  /// Similar to `_convertBelow1000Standard` but intended for contexts where the
  /// entire resulting phrase needs to agree with an external noun.
  /// Note: The implementation currently seems very similar to `_convertBelow1000Standard`
  /// and might need refinement if distinct agreement behaviour is needed at this level.
  /// The `useCurrencyConcord` flag seems misplaced here.
  ///
  /// - [n]: The integer between 0 and 999.
  /// - [targetClass]: The external noun class to agree with (impact might be limited in current impl).
  /// - [useCurrencyConcord]: Flag indicating if currency-specific concord rules apply (likely should be handled higher up).
  /// Returns the number in words, potentially with agreement.
  String _convertBelow1000(int n, _NounClass targetClass,
      {required bool useCurrencyConcord}) {
    // This function mirrors _convertBelow1000Standard closely.
    // The primary difference *should* be how _getNumberWordWithAgreement is called,
    // but its current usage seems identical to _getNumberWordStandard in effect.
    if (n == 0) return "";
    if (n < 0 || n >= 1000)
      throw ArgumentError("Number must be between 0 and 999: $n");

    String? hundredsPart;
    int remainder = n;

    if (remainder >= 100) {
      int hundredCount = remainder ~/ 100;
      remainder %= 100;

      if (hundredCount == 1) {
        hundredsPart = _hundred;
      } else {
        // Calls _getNumberWordWithAgreement - crucial difference *in theory*
        String countWord = _getNumberWordWithAgreement(
          hundredCount,
          _NounClass.cl6_P, // Agrees with 'amakhulu'
          useCurrencyConcord: false, // Concord setting passed down
        );
        hundredsPart = "amakhulu $countWord";
      }
    }

    String? tensUnitsText;
    if (remainder > 0) {
      if (remainder < 10) {
        tensUnitsText = _getNumberWordWithAgreement(
          remainder,
          _NounClass.unknown, // No specific internal target class for units
          useCurrencyConcord: useCurrencyConcord, // Pass down concord setting
        );
      } else if (remainder == 10) {
        tensUnitsText = _getNumberWordWithAgreement(
          10,
          _NounClass.unknown,
          useCurrencyConcord: useCurrencyConcord,
        );
      } else if (remainder < 20) {
        // 11-19
        String tensPart = _tens[10]!;
        String unitWord = _fullBaseNumbers[remainder % 10]!;
        String particle = _determineJoinParticle(unitWord);
        tensUnitsText = "$tensPart ${_applyParticle(particle, unitWord)}";
      } else {
        // 20-99
        int tenVal = (remainder ~/ 10) * 10;
        int unitVal = remainder % 10;
        // Get tens word (e.g., "amashumi amabili") - internal agreement handled
        String baseTensWord = _getNumberWordWithAgreement(
          tenVal,
          _NounClass.cl6_P, // Agrees with 'amashumi'
          useCurrencyConcord: useCurrencyConcord,
        );

        if (unitVal == 0) {
          tensUnitsText = baseTensWord;
        } else {
          String unitWord = _fullBaseNumbers[unitVal]!;
          String particle = _determineJoinParticle(unitWord);
          tensUnitsText = "$baseTensWord ${_applyParticle(particle, unitWord)}";
        }
      }
    }

    // Combine parts
    if (hundredsPart != null && tensUnitsText != null) {
      String particle = _determineJoinParticle(tensUnitsText);
      return "$hundredsPart ${_applyParticle(particle, tensUnitsText)}";
    } else {
      return hundredsPart ?? tensUnitsText ?? "";
    }
  }

  /// Gets the word for a number, applying agreement based on the target noun class.
  ///
  /// This is the main function for getting number words when agreement is needed (e.g., for currency).
  /// It handles 'one' specially using stems and prefixes, and falls back to base/tens words
  /// or the `_convertBelow1000` function for compound numbers.
  ///
  /// - [number]: The integer number.
  /// - [targetClass]: The noun class to agree with.
  /// - [useCurrencyConcord]: Flag indicating if currency-specific concord rules apply.
  /// Returns the number word with agreement applied.
  String _getNumberWordWithAgreement(
    int number,
    _NounClass targetClass, {
    required bool useCurrencyConcord,
  }) {
    // Special handling for 'one' with agreement.
    if (number == 1 &&
        useCurrencyConcord &&
        targetClass != _NounClass.unknown) {
      String prefix =
          _getConcordPrefix(1, targetClass, useCurrencyConcord: true);
      String stem = _oneStems[targetClass] ?? _oneStems[_NounClass.unknown]!;
      return _applyPrefix(prefix, stem); // e.g., eli + lodwa -> elilodwa
    }

    // Use base numbers or tens directly if available (agreement handled by prefix later).
    if (_fullBaseNumbers.containsKey(number)) {
      return _fullBaseNumbers[number]!; // Returns the stem/base form
    }
    if (number == 10) {
      return _tens[10]!; // "lishumi"
    }
    if (number == 100) {
      return _hundred; // "ikhulu"
    }
    if (_tens.containsKey(number)) {
      return _tens[number]!; // e.g., "amashumi amabili"
    }

    // For compound numbers below 1000 needing agreement, use _convertBelow1000.
    // Pass _NounClass.unknown as internal target, agreement applied externally via _getAgreedNumberForm.
    return _convertBelow1000(number, _NounClass.unknown,
        useCurrencyConcord: useCurrencyConcord);
  }

  /// Determines the correct joining particle ('na', 'ne', 'no', 'nan') based on the *following* word.
  ///
  /// This particle links number components (e.g., hundreds *and* tens, tens *and* units).
  /// The choice depends on the initial vowel/consonant or specific forms of the next word.
  /// Handles complex Zulu phonological rules.
  ///
  /// - [nextWord]: The first word of the component that follows the particle.
  /// Returns the appropriate particle string.
  String _determineJoinParticle(String nextWord) {
    nextWord = nextWord.trim();
    if (nextWord.isEmpty) return "na"; // Default particle

    // Get the first significant word part for analysis.
    String firstSignificantWord = nextWord.split(' ').first;
    String checkWord = firstSignificantWord;

    // Simplify prefixes for vowel checking (e.g., 'amabili' -> check 'bili')
    if ((checkWord.startsWith("ama") || checkWord.startsWith("izin")) &&
        nextWord.contains(" ")) {
      // If it's like "amashumi amabili", check the second word "amabili"
      var parts = nextWord.split(' ');
      if (parts.length > 1) {
        checkWord = parts[1];
      }
    } else if (checkWord.startsWith("ayi")) {
      // Concord prefix ayi- + C -> check a + C
      checkWord = "a${checkWord.substring(3)}";
    } else if (checkWord.startsWith(
          "esi",
        ) || // Concord prefixes esi-, eli-, eyi- + C -> check e + C
        checkWord.startsWith("eli") ||
        checkWord.startsWith("eyi")) {
      checkWord = "e${checkWord.substring(3)}";
    } else if (checkWord
            .startsWith("ezim") || // Concord prefixes eziN- + C -> check e + C
        checkWord.startsWith("ezin") ||
        checkWord.startsWith("ezine")) {
      checkWord =
          "e${checkWord.substring(checkWord.startsWith("ezine") ? 4 : 3)}";
    }

    // Check the effective first letter (lowercase).
    String firstLetterLower =
        checkWord.isNotEmpty ? checkWord[0].toLowerCase() : "";

    // Special cases for 'nan'.
    if (firstSignificantWord == "thathu" || firstSignificantWord == "hlanu")
      return "nan";

    // Vowel-based rules.
    if (firstLetterLower == 'a') return "na"; // na + a... -> na...
    if (firstLetterLower == 'i' || firstLetterLower == 'e')
      return "ne"; // ne + i/e... -> ne...
    if (firstLetterLower == 'u' || firstLetterLower == 'o')
      return "no"; // no + u/o... -> no...

    // Specific word rule.
    if (firstSignificantWord == "lishumi")
      return "ne"; // Usually 'ne' before 'lishumi'

    // Default particle.
    return "na";
  }

  /// Applies the determined joining particle to the following text component.
  ///
  /// Handles vowel coalescence (e.g., na + amashumi -> namashumi) and specific word fusions.
  ///
  /// - [particle]: The particle determined by `_determineJoinParticle` ('na', 'ne', 'no', 'nan').
  /// - [text]: The text component following the particle.
  /// Returns the text component with the particle correctly prepended/merged.
  String _applyParticle(String particle, String text) {
    text = text.trim();
    if (text.isEmpty) return "";
    String firstWord = text.split(' ').first;

    // Handle 'nan' particle (less common, specific fusion).
    if (particle == "nan" && firstWord == "hlanu")
      return "nanhlanu"; // nan + hlanu -> nanhlanu
    if (particle == "nan" && firstWord == "thathu")
      return "nanthathu"; // nan + thathu -> nanthathu
    if (particle == "nan")
      return "nan $text"; // Default 'nan' if no specific fusion

    // Get the first letter of the following word for vowel checks.
    String originalFirstLetterLower =
        firstWord.isNotEmpty ? firstWord[0].toLowerCase() : "";

    // Handle 'ne' particle.
    if (particle == "ne") {
      // Specific fusion: ne + lishumi -> nelishumi
      if (firstWord == "lishumi") {
        return "ne$text"; // Note: Standard rule often gives nelishumi, check texts
      }
      // Vowel coalescence: ne + i... -> ne..., ne + e... -> ne...
      if (originalFirstLetterLower == 'i' || originalFirstLetterLower == 'e') {
        // Combine particle and text, dropping the vowel from text.
        return "ne${text.substring(1)}";
      }
      // Default 'ne' application (usually before consonants).
      return "ne$text"; // Changed from space to no space, check examples
    }
    // Handle 'no' particle.
    else if (particle == "no") {
      // Vowel coalescence: no + u... -> no..., no + o... -> no...
      if (originalFirstLetterLower == 'u' || originalFirstLetterLower == 'o') {
        // Combine particle and text, dropping the vowel from text. Requires space check.
        return "no ${text.substring(1)}"; // Keep space here? check examples: no + okubi -> nokubi?
      }
      // Default 'no' application.
      return "no $text";
    }
    // Handle 'na' particle.
    else if (particle == "na") {
      // Vowel coalescence: na + a... -> na...
      if (originalFirstLetterLower == 'a') {
        // Combine particle and text, dropping the vowel from text.
        return "na${text.substring(1)}"; // e.g., na + amakhulu -> namakhulu
      } else {
        // Specific word fusions/changes with 'na' (often becomes 'ne').
        // These seem like exceptions where 'na' changes to 'ne' before certain consonants.
        if (text == "shiyagalolunye") return "nesishiyagalolunye";
        if (text == "shiyagalombili") return "neshiyagalombili";
        if (text == "sithupha") return "nesithupha";
        if (text == "nye") return "nanye"; // na + nye -> nanye

        // Default 'na' application (usually before consonants i,e,u,o).
        return "na$text"; // Changed from space to no space, check examples
      }
    }

    // Fallback if particle wasn't handled (shouldn't happen).
    return "$particle $text";
  }

  /// Gets the appropriate currency unit name based on amount and whether it's a subunit.
  ///
  /// Uses the singular/plural forms provided in the `CurrencyInfo`.
  /// - [amount]: The integer amount of the unit.
  /// - [isSubunit]: `true` if getting the subunit name, `false` for main unit.
  /// - [info]: The `CurrencyInfo` object containing the names.
  /// Returns the correct currency unit name (e.g., "iRandi", "amaRandi", "isenti", "amasenti").
  String _getCurrencyUnitName(
      BigInt amount, bool isSubunit, CurrencyInfo info) {
    bool isSingular = amount == BigInt.one;
    if (isSubunit) {
      // Ensure subunit names are provided before accessing.
      return isSingular ? info.subUnitSingular! : info.subUnitPlural!;
    } else {
      // Ensure main unit names are provided.
      return isSingular ? info.mainUnitSingular : info.mainUnitPlural!;
    }
  }

  /// Determines the noun class of a currency unit based on amount and type (main/subunit).
  ///
  /// This is specific to ZAR (Rand/cent) as defined in `CurrencyInfo.zarZu`.
  /// - [amount]: The integer amount.
  /// - [isSubunit]: `true` for subunit, `false` for main unit.
  /// Returns the corresponding `_NounClass`.
  _NounClass _getCurrencyUnitClass(BigInt amount, bool isSubunit) {
    // This logic assumes ZAR (Rand/cent) classes:
    // Rand: cl 5 (iRandi) singular, cl 6 (amaRandi) plural
    // Cent: cl 7 (isenti) singular, cl 6 (amasenti) plural
    bool isSingular = amount == BigInt.one;
    if (isSubunit) {
      return isSingular
          ? _NounClass.cl7_S
          : _NounClass.cl6_P; // isenti / amasenti
    } else {
      return isSingular
          ? _NounClass.cl5_S
          : _NounClass.cl6_P; // iRandi / amaRandi
    }
  }

  /// Determines the correct concord prefix for a number agreeing with a specific noun class.
  ///
  /// This implements the complex rules of Zulu number agreement.
  /// The prefix changes based on the number (1, 2-5, 6-9, 10s, 100s) and the target noun class.
  /// - [number]: The integer value.
  /// - [targetClass]: The noun class the number needs to agree with.
  /// - [useCurrencyConcord]: Flag to indicate if currency-specific rules apply (often more explicit concords).
  /// Returns the string prefix (e.g., "ama", "ayi", "esi", "eli", "ezi", "e", "") or an empty string if no prefix applies.
  String _getConcordPrefix(int number, _NounClass targetClass,
      {required bool useCurrencyConcord}) {
    // If not using specific concords or class is unknown, usually no prefix needed at this stage.
    // However, internal agreement for standard 2-9, 20-90 with cl6 needs handling.
    if (!useCurrencyConcord || targetClass == _NounClass.unknown) {
      // Keep logic for internal standard agreement with cl6 (handled in _getNumberWordStandard)
      if (targetClass == _NounClass.cl6_P && number >= 2 && number <= 9) {
        // Handled inside _getNumberWordStandard
      } else if (targetClass == _NounClass.cl6_P &&
          number >= 20 &&
          number <= 90 &&
          number % 10 == 0) {
        // Handled inside _getNumberWordStandard
      } else {
        // Otherwise, no prefix applied here for standard conversion.
        return "";
      }
    }

    int numForPrefix = number; // Use the number directly for prefix rules

    // --- Prefixes based on number range and target class ---

    // Hundreds (>= 100)
    if (numForPrefix >= 100) {
      switch (targetClass) {
        case _NounClass.cl6_P: // e.g., amakhulu anga- / ayi-
          // Prefix for 100-199 might differ from 200+ depending on analysis
          return (number >= 100 && number < 200)
              ? "ayi"
              : "anga"; // Tentative rule

        case _NounClass.cl8_P: // e.g., izigidi ezinga- / eziyi-
        case _NounClass.cl10_P: // e.g., izinkulungwane ezinga- / eziyi-
          return (number >= 100 && number < 200)
              ? "eziyi"
              : "ezinga"; // Tentative rule
        case _NounClass.cl5_S:
          return "eli"; // e.g., ikhulu eli...
        case _NounClass.cl7_S:
          return "esi"; // e.g., isigidi esi...
        case _NounClass.cl9_S:
          return "e"; // e.g., inkulungwane e...
        default:
          return ""; // No prefix for other classes with hundreds? Needs check.
      }
    }

    // Tens (>= 20)
    if (numForPrefix >= 20) {
      switch (targetClass) {
        case _NounClass.cl6_P:
          return "anga"; // e.g., amashumi anga...
        case _NounClass.cl8_P:
          return "ezinga"; // e.g., izigidi ezinga...
        case _NounClass.cl10_P:
          return "ezinga"; // e.g., izinkulungwane ezinga...
        default:
          return ""; // No prefix for singulars with 20+? Needs check.
      }
    }

    // Teens / Ten (>= 10)
    if (numForPrefix >= 10) {
      switch (targetClass) {
        case _NounClass.cl6_P:
          return "ayi"; // e.g., amashumi ayi... (lishumi ?)
        case _NounClass.cl8_P:
          return "eziyi"; // e.g., izigidi eziyi...
        case _NounClass.cl10_P:
          return "eziyi"; // e.g., izinkulungwane eziyi...
        case _NounClass.cl5_S:
          return "eli"; // e.g., ishumi eli...
        case _NounClass.cl7_S:
          return "esi"; // e.g., ishumi esi...
        case _NounClass.cl9_S:
          return "e"; // e.g., ishumi e...
        default:
          return "";
      }
    }

    // Units (1-9)
    switch (numForPrefix) {
      case 1:
        // Prefix for 'one' depends heavily on class (forms like eli-, esi-, ezi-, e-).
        switch (targetClass) {
          case _NounClass.cl5_S:
            return "eli"; // -> elilodwa
          case _NounClass.cl6_P:
            return ""; // No prefix needed? ama(Randi) + nye -> ? Check usage. Often implicit?
          case _NounClass.cl7_S:
            return "esi"; // -> esisodwa
          case _NounClass.cl8_P:
            return "ezi"; // -> ezizodwa
          case _NounClass.cl9_S:
            return "e"; // -> eyodwa
          case _NounClass.cl10_P:
            return "ezi"; // -> ezizodwa
          default:
            return "";
        }
      case 2: // bili
      case 3: // thathu
      case 5: // hlanu
        // Prefixes for 2, 3, 5
        switch (targetClass) {
          case _NounClass.cl6_P:
            return "ama"; // -> amabili, amathathu, amahlanu
          case _NounClass.cl8_P:
          case _NounClass.cl10_P:
            // Nasal assimilation/change: ezi + bili -> ezimbili; ezi + thathu -> ezintathu; ezi + hlanu -> ezinhlanu
            return (numForPrefix == 2) ? "ezim" : "ezin";
          default:
            return ""; // No prefix for singular classes?
        }
      case 4: // ne
        // Prefixes for 4
        switch (targetClass) {
          case _NounClass.cl6_P:
            return "ama"; // -> amane
          case _NounClass.cl8_P:
          case _NounClass.cl10_P:
            return "ezine"; // ezi + ne -> ezine
          default:
            return "";
        }
      case 6: // sithupha
      case 7: // khombisa
      case 8: // shiyagalombili
      case 9: // shiyagalolunye
        // Prefixes for 6, 7, 8, 9 (often relative construction with -yi-)
        switch (targetClass) {
          case _NounClass.cl6_P:
            return "ayi"; // -> ayisithupha, ayisikhombisa, ...
          case _NounClass.cl8_P:
          case _NounClass.cl10_P:
            return "eziyi"; // -> eziyisithupha, eziyisikhombisa, ...
          default:
            return "";
        }
    }
    // Fallback: no prefix.
    return "";
  }

  /// Applies a concord prefix to a base number word, handling vowel coalescence and fusions.
  ///
  /// - [prefix]: The concord prefix (e.g., "ama", "ayi", "eli").
  /// - [baseWord]: The standard number word (e.g., "bili", "sithupha", "ikhulu").
  /// Returns the combined word with prefix correctly applied (e.g., "amabili", "ayisithupha", "elikhulu").
  String _applyPrefix(String prefix, String baseWord) {
    if (prefix.isEmpty) return baseWord; // No prefix, return base word as is.

    baseWord = baseWord.trim();
    var words = baseWord.split(' ');
    String firstWord = words[0]; // Word to apply prefix to
    // Keep the rest of the phrase if baseWord was multi-word (e.g., "amashumi amabili")
    String restOfWords =
        words.length > 1 ? ' ${words.sublist(1).join(' ')}' : '';

    // --- Specific Prefix + Word Fusions ---
    // These handle common, sometimes irregular, combinations. Order might matter.
    if (prefix == "eziyi" && firstWord == "ikhulu")
      return "eziyikhulu$restOfWords";
    if (prefix == "ezinga" && firstWord == "amakhulu")
      return "ezingamakhulu$restOfWords";
    if (prefix == "eziyi" && firstWord == "lishumi")
      return "eziyishumi$restOfWords";
    if (prefix == "ezim" && firstWord == "bili") {
      return "ezimbili$restOfWords"; // ezi + bili -> ezimbili
    }
    if (prefix == "ezin" && firstWord == "thathu") {
      return "ezintathu$restOfWords"; // ezi + thathu -> ezintathu
    }
    if (prefix == "ezin" && firstWord == "hlanu") {
      return "ezinhlanu$restOfWords"; // ezi + hlanu -> ezinhlanu
    }
    if (prefix == "ezine" && firstWord == "ne")
      return "ezine$restOfWords"; // ezi + ne -> ezine
    if (prefix == "ayi" && firstWord == "shiyagalolunye") {
      return "ayisishiyagalolunye$restOfWords"; // ayi + shiya... -> ayisishiya...
    }
    if (prefix == "ayi" && firstWord == "shiyagalombili") {
      return "ayisishiyagalombili$restOfWords"; // ayi + shiya... -> ayisishiya...
    }
    if (prefix == "ayi" && firstWord == "khombisa") {
      return "ayisikhombisa$restOfWords"; // ayi + khombisa -> ayisikhombisa
    }
    if (prefix == "ayi" && firstWord == "sithupha") {
      return "ayisithupha$restOfWords"; // ayi + sithupha -> ayisithupha
    }
    if (prefix == "anga" && firstWord == "amashumi") {
      return "angamashumi$restOfWords"; // anga + amashumi -> angamashumi
    }
    if (prefix == "ezinga" && firstWord == "amashumi") {
      return "ezingamashumi$restOfWords"; // ezinga + amashumi -> ezingamashumi
    }
    if (prefix == "ayi" && firstWord == "ikhulu") {
      return "ayikhulu$restOfWords"; // ayi + ikhulu -> ayikhulu
    }
    if (prefix == "eli" && firstWord == "ikhulu") {
      return "elikhulu$restOfWords"; // eli + ikhulu -> elikhulu
    }
    if (prefix == "esi" && firstWord == "ikhulu") {
      return "esikhulu$restOfWords"; // esi + ikhulu -> esikhulu
    }
    if (prefix == "e" && firstWord == "ikhulu") {
      return "elikhulu$restOfWords"; // e + ikhulu -> elikhulu (class 9?)
    }
    if (prefix == "ayi" && firstWord == "amakhulu") {
      return "angamakhulu$restOfWords"; // ayi + amakhulu -> angamakhulu (?) - Check concord
    }

    // --- General Vowel Coalescence Rules ---
    String modifiedFirstWord;
    // Prefix ends in 'i', word starts with 'i' or 'e' -> prefix + word[1:]
    if (prefix.endsWith("i") &&
        (firstWord.startsWith("i") || firstWord.startsWith("e"))) {
      modifiedFirstWord = prefix + firstWord.substring(1);
    } else if (prefix.endsWith("a") && firstWord.startsWith("a")) {
      modifiedFirstWord =
          prefix + firstWord.substring(1); // e.g., ama + a... -> ama...
      // Prefix ends in 'u', word starts with 'u' -> prefix + word[1:] (Less common with numbers?)
    } else if (prefix.endsWith("u") && firstWord.startsWith("u")) {
      modifiedFirstWord = prefix + firstWord.substring(1);
      // Default: No coalescence, just concatenate prefix and word.
    } else {
      modifiedFirstWord = prefix + firstWord;
    }
    // Return the modified first word plus any remaining parts of the base word phrase.
    return modifiedFirstWord + restOfWords;
  }
}

/// Helper class to store information about large number scales (thousand, million, etc.).
///
/// Contains the singular and plural forms of the scale name and their corresponding noun classes.
class _ScaleInfo {
  /// The singular form of the scale name (e.g., "inkulungwane").
  final String singular;

  /// The noun class of the singular form.
  final _NounClass singularClass;

  /// The plural form of the scale name (e.g., "izinkulungwane").
  final String plural;

  /// The noun class of the plural form.
  final _NounClass pluralClass;

  /// Creates a const instance holding scale information.
  const _ScaleInfo(
      this.singular, this.singularClass, this.plural, this.pluralClass);
}
