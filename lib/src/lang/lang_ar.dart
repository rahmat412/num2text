import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/ar_options.dart';
import '../options/base_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ar}
/// The Arabic language (Lang.AR) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Arabic word representation following standard Arabic grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [ArOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (using standard Arabic scale).
/// This implementation considers grammatical gender, which is crucial in Arabic.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [ArOptions], particularly the `gender` option.
/// {@endtemplate}
class Num2TextAR implements Num2TextBase {
  // --- Constants for Arabic words and symbols ---
  static const String _zero = "صفر"; // Zero
  static const String _point = "نقطة"; // Decimal point (period) word
  static const String _comma = "فاصلة"; // Decimal point (comma) word
  static const String _and = "و"; // Conjunction "and"
  static const String _yearSuffixBC =
      "ق.م"; // Suffix for BC years (Qabl al-Mīlād)
  static const String _yearSuffixAD = "م"; // Suffix for AD/CE years (Mīlādī)
  static const String _infinity = "لانهاية"; // Infinity
  static const String _negativeInfinity = "سالب لانهاية"; // Negative infinity
  static const String _notANumber = "ليس رقماً"; // Not a Number (NaN)

  // --- Number words (Masculine form) ---
  static const List<String> _wordsUnder20Masc = [
    "صفر", // 0
    "واحد", // 1
    "اثنان", // 2
    "ثلاثة", // 3
    "أربعة", // 4
    "خمسة", // 5
    "ستة", // 6
    "سبعة", // 7
    "ثمانية", // 8
    "تسعة", // 9
    "عشرة", // 10
    "أحد عشر", // 11
    "اثنا عشر", // 12
    "ثلاثة عشر", // 13
    "أربعة عشر", // 14
    "خمسة عشر", // 15
    "ستة عشر", // 16
    "سبعة عشر", // 17
    "ثمانية عشر", // 18
    "تسعة عشر", // 19
  ];

  // --- Number words (Feminine form) ---
  // Note the agreement changes for 1, 2, and 3-10 compared to masculine.
  static const List<String> _wordsUnder20Fem = [
    "صفر", // 0
    "واحدة", // 1
    "اثنتان", // 2
    "ثلاث", // 3
    "أربع", // 4
    "خمس", // 5
    "ست", // 6
    "سبع", // 7
    "ثمان", // 8
    "تسع", // 9
    "عشر", // 10
    "إحدى عشرة", // 11
    "اثنتا عشرة", // 12
    "ثلاث عشرة", // 13
    "أربع عشرة", // 14
    "خمس عشرة", // 15
    "ست عشرة", // 16
    "سبع عشرة", // 17
    "ثماني عشرة", // 18
    "تسع عشرة", // 19
  ];

  // --- Tens words (20-90) ---
  static const List<String> _wordsTens = [
    "", // 0 (unused)
    "", // 10 (handled by under 20 list)
    "عشرون", // 20
    "ثلاثون", // 30
    "أربعون", // 40
    "خمسون", // 50
    "ستون", // 60
    "سبعون", // 70
    "ثمانون", // 80
    "تسعون", // 90
  ];

  // --- Hundreds words ---
  static const Map<int, String> _wordsHundreds = {
    1: "مئة", // 100
    2: "مئتان", // 200
    3: "ثلاثمئة", // 300
    4: "أربعمئة", // 400
    5: "خمسمئة", // 500
    6: "ستمئة", // 600
    7: "سبعمئة", // 700
    8: "ثمانمئة", // 800
    9: "تسعمئة", // 900
  };

  // --- Scale words (Thousands, Millions, etc.) ---
  // Defines singular (s), dual (d), plural 3-10 (p3_10), and plural 11+ (p11+) forms.
  // Arabic uses different noun forms depending on the preceding number.
  static const Map<int, Map<String, String>> _scaleForms = {
    // 10^3
    1: {'s': 'ألف', 'd': 'ألفان', 'p3_10': 'آلاف', 'p11+': 'ألفًا'}, // Thousand
    // 10^6
    2: {
      's': 'مليون',
      'd': 'مليونان',
      'p3_10': 'ملايين',
      'p11+': 'مليونًا'
    }, // Million
    // 10^9
    3: {
      's': 'مليار',
      'd': 'ملياران',
      'p3_10': 'مليارات',
      'p11+': 'مليارًا'
    }, // Billion
    // 10^12
    4: {
      's': 'تريليون',
      'd': 'تريليونان',
      'p3_10': 'تريليونات',
      'p11+': 'تريليونًا'
    }, // Trillion
    // 10^15
    5: {
      's': 'كوادريليون',
      'd': 'كوادريليونان',
      'p3_10': 'كوادريليونات',
      'p11+': 'كوادريليونًا',
    }, // Quadrillion
    // 10^18
    6: {
      's': 'كوينتيليون',
      'd': 'كوينتيليونان',
      'p3_10': 'كوينتيليونات',
      'p11+': 'كوينتيليونًا',
    }, // Quintillion
    // 10^21
    7: {
      's': 'سكستيليون',
      'd': 'سكستيليونان',
      'p3_10': 'سكستيليونات',
      'p11+': 'سكستيليونًا',
    }, // Sextillion
    // 10^24
    8: {
      's': 'سبتيليون',
      'd': 'سبتيليونان',
      'p3_10': 'سبتيليونات',
      'p11+': 'سبتيليونًا',
    }, // Septillion
    // Higher scales can be added here if needed.
  };

  /// Processes the given [number] into Arabic words based on the provided [options].
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have Arabic-specific options, defaulting if necessary.
    final ArOptions arOptions =
        options is ArOptions ? options : const ArOptions();

    // Handle special double values first.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? _negativeInfinity : _infinity;
      }
      if (number.isNaN) {
        return fallbackOnError ??
            _notANumber; // Use fallback or default NaN message.
      }
    }

    // Normalize the input number to Decimal for precision.
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) {
      // If normalization fails (e.g., invalid string), return fallback or default message.
      return fallbackOnError ?? _notANumber;
    }

    // Handle zero separately.
    if (decimalValue == Decimal.zero) {
      if (arOptions.currency) {
        // Zero with currency requires the currency unit name.
        return "$_zero ${_getCurrencyForm(BigInt.zero, arOptions.gender, arOptions.currencyInfo, true)}";
      } else {
        // Just "صفر".
        return _zero;
      }
    }

    // Determine sign and get the absolute value.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    // Route to specific handlers based on options.
    if (arOptions.format == Format.year) {
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), arOptions);
    } else {
      if (arOptions.currency) {
        textResult = _handleCurrency(absValue, arOptions);
      } else {
        textResult = _handleStandardNumber(absValue, arOptions);
      }
      // Prepend negative prefix if applicable.
      if (isNegative) {
        textResult = "${arOptions.negativePrefix} $textResult";
      }
    }

    // Return the final trimmed result.
    return textResult.trim();
  }

  /// Converts an integer year value into Arabic words, handling BC/AD suffixes.
  String _handleYearFormat(int year, ArOptions options) {
    final bool isNegative = year < 0; // BC year
    final int absYear = isNegative ? -year : year;
    final BigInt bigAbsYear = BigInt.from(absYear);

    String yearText;

    if (absYear == 0) {
      // Technically no year 0, but handle the input case.
      yearText = _zero;
    } else {
      // Years are typically treated as masculine numbers.
      yearText = _convertInteger(bigAbsYear, Gender.masculine, true);
    }

    // Add suffixes based on sign and options.
    if (isNegative) {
      // This check seems potentially redundant or incomplete. Kept as is.
      if (absYear == 1 && yearText == _wordsUnder20Masc[1]) {}
      yearText += " $_yearSuffixBC"; // Add BC suffix
    } else if (options.includeAD && absYear > 0) {
      yearText += " $_yearSuffixAD"; // Add AD/CE suffix if requested
    }

    return yearText;
  }

  /// Converts a positive decimal value into Arabic currency words.
  String _handleCurrency(Decimal absValue, ArOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final Gender gender = options.gender; // Default gender from options.
    final bool round = options.round;
    final int decimalPlaces = 2; // Standard currency decimal places.
    final Decimal subunitMultiplier =
        Decimal.fromInt(100); // For converting fraction to subunits.

    // Round the value if requested, otherwise use the original value.
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main and subunit values.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).truncate().toBigInt();

    // Handle zero amount.
    if (mainValue == BigInt.zero && subunitValue == BigInt.zero) {
      // Return "zero" plus the appropriate currency form for zero.
      return "$_zero ${_getCurrencyForm(mainValue, gender, currencyInfo, true)}";
    }

    // Determine gender for the number part, potentially overridden by currency type.
    Gender numberGender = gender;

    // Convert main value to words.
    String mainText = _convertInteger(mainValue, numberGender, false);
    // Get the correct grammatical form of the main currency unit.
    String mainUnitName =
        _getCurrencyForm(mainValue, numberGender, currencyInfo, true);

    // Special handling for specific currencies like 'ليرة' (Lira), which is feminine.
    if (currencyInfo.mainUnitSingular == "ليرة") {
      numberGender = Gender.feminine; // Lira requires feminine number forms.
      mainText = _convertInteger(
          mainValue, numberGender, false); // Reconvert with feminine gender.
      mainUnitName = _getCurrencyForm(
        mainValue,
        numberGender,
        currencyInfo,
        true,
      ); // Get feminine currency form.

      // For 1 or 2 Lira, the number word itself is often omitted ("ليرة واحدة" -> "ليرة").
      if (mainValue == BigInt.one || mainValue == BigInt.two) {
        mainText = "";
      }
    }

    // Combine main value text and unit name.
    String result = (mainText.isNotEmpty && mainUnitName.isNotEmpty)
        ? '$mainText $mainUnitName' // e.g., "خمسة ريالات"
        : (mainText.isEmpty
            ? mainUnitName
            : mainText); // Handles cases like "ليرة" (1 lira)

    // If main value is zero but subunits exist, clear the main part result.
    if (mainValue == BigInt.zero && subunitValue > BigInt.zero) {
      result = "";
    }

    // Handle subunits if they exist.
    if (subunitValue > BigInt.zero) {
      Gender subunitNumberGender;
      String? subUnitSingular = currencyInfo.subUnitSingular;

      // Special gender agreement rules for "هللة" (Halala).
      if (subUnitSingular == "هللة") {
        if (subunitValue == BigInt.one || subunitValue == BigInt.two) {
          subunitNumberGender = Gender.feminine; // 1, 2 هللة agree feminine.
        } else if (subunitValue >= BigInt.from(3) &&
            subunitValue <= BigInt.from(10)) {
          subunitNumberGender =
              Gender.masculine; // 3-10 هللة agree masculine (polarity).
        } else {
          subunitNumberGender = Gender.feminine; // 11+ هللة agree feminine.
        }
      } else {
        // Default subunit gender is masculine unless specified otherwise.
        subunitNumberGender = Gender.masculine;
      }

      // Convert subunit value to words using determined gender.
      String subunitText =
          _convertInteger(subunitValue, subunitNumberGender, false);

      // Get the correct grammatical form of the subunit name (usually treated as masculine).
      String subUnitName =
          _getCurrencyForm(subunitValue, Gender.masculine, currencyInfo, false);

      // Omit number words "one" or "two" for subunits, similar to main units sometimes.
      if (subunitValue == BigInt.one || subunitValue == BigInt.two) {
        subunitText = "";
      }

      // Special override for Lira's subunit (Qirsh).
      if (currencyInfo.mainUnitSingular == "ليرة") {
        subUnitName = _getCurrencyForm(
          subunitValue,
          Gender.masculine, // Qirsh is masculine.
          currencyInfo,
          false, // Indicate it's a subunit.
          forceQirsh: true, // Ensure 'قرش' forms are used.
        );
      }

      // Combine subunit text and name.
      String separator =
          currencyInfo.separator ?? ""; // Separator like "و" (and).
      String subunitPart = (subunitText.isNotEmpty && subUnitName.isNotEmpty)
          ? '$subunitText $subUnitName' // e.g., "خمسة قروش"
          : (subunitText.isEmpty
              ? subUnitName
              : subunitText); // Handles "قرش" (1 qirsh)

      // Append subunit part to the main result with separator if needed.
      if (mainValue > BigInt.zero && separator.isNotEmpty) {
        result += ' $separator$subunitPart'; // e.g., "result و subunitPart"
      } else {
        // Append directly or with a space if result was previously empty.
        result += (result.isEmpty ? '' : ' ') + subunitPart;
      }
    }

    // Final cleanup: trim and normalize spacing.
    return result.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Converts a positive decimal value into standard Arabic number words (non-currency).
  String _handleStandardNumber(Decimal absValue, ArOptions options) {
    // Separate integer and fractional parts.
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Determine gender for the integer part.
    Gender numberGender = options.gender;

    // Convert integer part to words. If integer is zero but fraction exists, write "صفر".
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, numberGender, false);

    String fractionalWords = '';
    // Handle fractional part if it exists.
    if (fractionalPart > Decimal.zero) {
      String separatorWord;
      // Choose the separator word based on options.
      switch (options.decimalSeparator) {
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          separatorWord = _point; // "نقطة"
          break;
        case DecimalSeparator.comma:
        default:
          separatorWord = _comma; // "فاصلة"
          break;
      }

      // Convert fractional part to string and extract digits after the decimal point.
      String decimalString = absValue.toString();
      String fractionalDigits =
          decimalString.contains('.') ? decimalString.split('.').last : '';
      // Remove trailing zeros from the fractional part.
      fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      // If there are significant fractional digits left:
      if (fractionalDigits.isNotEmpty) {
        // Convert each digit individually to its masculine word form.
        List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder20Masc[
                  digitInt] // Use masculine form for digits after point.
              : '?'; // Placeholder for invalid digits.
        }).toList();

        // Combine the digit words with the separator.
        if (digitWords.isNotEmpty) {
          fractionalWords =
              ' $separatorWord ${digitWords.join(' ')}'; // e.g., " فاصلة واحد اثنان"
        }
      } else if (integerPart > BigInt.zero && !absValue.isInteger) {
        // This condition seems potentially redundant or incomplete. Kept as is.
        // It might have been intended to handle cases like "123.00" where the fractional part becomes empty after removing trailing zeros.
      }
    }

    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative BigInt into Arabic words, handling gender and scale.
  /// [isYear] affects some grammatical rules (though less critical in this version).
  String _convertInteger(BigInt n, Gender gender, bool isYear) {
    if (n == BigInt.zero) return _zero;
    // Ensure input is non-negative for internal logic.
    if (n < BigInt.zero)
      throw ArgumentError("Negative input to _convertInteger");

    // Select the base word list (0-19) based on gender.
    final List<String> baseWords =
        (gender == Gender.feminine) ? _wordsUnder20Fem : _wordsUnder20Masc;

    List<String> parts =
        []; // Stores parts of the number string (e.g., "million part", "thousand part").
    BigInt currentN = n; // The remaining number to process.

    // Handle numbers less than 100 directly.
    if (currentN < BigInt.from(100)) {
      return _convertChunk(currentN.toInt(), gender, baseWords);
    }

    // Handle numbers less than 1000 directly.
    if (currentN < BigInt.from(1000)) {
      return _convertHundredsAndBelow(currentN.toInt(), gender, baseWords);
    }

    // Process larger numbers by scale levels (thousands, millions, etc.).
    List<int> scaleLevels = _scaleForms.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Process largest scale first.
    bool firstScalePartProcessed =
        false; // Tracks if we've added the first scale part (to handle adding "و").

    for (int scaleLevel in scaleLevels) {
      // Calculate the value of this scale level (1000, 1_000_000, etc.).
      final scaleValue = BigInt.from(10).pow(scaleLevel * 3);

      if (currentN >= scaleValue) {
        // How many of this scale unit are there?
        BigInt count = currentN ~/ scaleValue;
        // What's the remainder?
        currentN %= scaleValue;

        // Determine the gender for the count itself based on Arabic grammar rules (polarity for 3-10).
        Gender countGender =
            (count >= BigInt.from(3) && count <= BigInt.from(10))
                ? Gender.masculine
                : gender;
        // Convert the count number to words.
        String countText = _convertInteger(count, countGender, isYear);

        // Get the correct grammatical form of the scale word (e.g., "ألف", "آلاف", "ألفًا").
        String scaleWord = _getScaleWord(count, scaleLevel);

        String combinedPart;
        // Special handling for "one" and "two" with scale words.
        if (count == BigInt.one && scaleWord == _scaleForms[scaleLevel]!['s']) {
          combinedPart = scaleWord; // e.g., "ألف" (one thousand)
        } else if (count == BigInt.two &&
            scaleWord == _scaleForms[scaleLevel]!['d']) {
          combinedPart = scaleWord; // e.g., "ألفان" (two thousand)
        } else {
          combinedPart =
              "$countText $scaleWord"; // e.g., "ثلاثة آلاف" (three thousands)
        }

        // Add the combined part to the result list, prepending "و" if it's not the first part.
        if (firstScalePartProcessed) {
          parts.add("$_and$combinedPart"); // Add "و" + part
        } else {
          parts.add(combinedPart); // First part, no "و"
        }
        firstScalePartProcessed = true;
      }
    }

    // Process the remaining part (less than 1000).
    if (currentN > BigInt.zero) {
      String remainderText =
          _convertHundredsAndBelow(currentN.toInt(), gender, baseWords);
      // Add the remainder part, prepending "و" if needed.
      if (firstScalePartProcessed) {
        parts.add("$_and$remainderText");
      } else {
        parts.add(remainderText);
      }
    }

    // Join all parts with spaces.
    return parts.join(' ');
  }

  /// Converts a number between 0 and 999 into Arabic words.
  String _convertHundredsAndBelow(
      int n, Gender gender, List<String> baseWords) {
    if (n < 0 || n >= 1000)
      throw ArgumentError("Number out of range 0-999: $n");
    if (n == 0) return ""; // Nothing to say for zero.
    // Delegate to _convertChunk for numbers under 100.
    if (n < 100) return _convertChunk(n, gender, baseWords);

    String hundredWord;
    int remainder = n;
    int hundredDigit = remainder ~/ 100; // Get the hundreds digit.

    // Get the word for the hundreds place (e.g., "مئة", "مئتان").
    hundredWord = _wordsHundreds[hundredDigit]!;
    remainder %= 100; // Get the remainder (0-99).

    // If there's a remainder, convert it and add it with "و".
    if (remainder > 0) {
      return "$hundredWord $_and${_convertChunk(remainder, gender, baseWords)}"; // e.g., "مئة و خمسة"
    } else {
      // Just the hundreds word.
      return hundredWord; // e.g., "مئة"
    }
  }

  /// Converts a number between 0 and 99 into Arabic words.
  String _convertChunk(int n, Gender gender, List<String> baseWords) {
    if (n < 0 || n >= 100)
      throw ArgumentError("Chunk must be between 0 and 99: $n");
    if (n == 0) return ""; // Nothing to say for zero.

    // Use the pre-defined list for numbers under 20.
    if (n < 20) {
      return baseWords[n];
    } else {
      // For 20 and above:
      int tensDigit = n ~/ 10; // Get the tens digit.
      int unitDigit = n % 10; // Get the unit digit.
      String tensWord = _wordsTens[
          tensDigit]; // Get the word for the tens place (e.g., "عشرون").

      // If it's a round ten (20, 30, etc.).
      if (unitDigit == 0) {
        return tensWord;
      } else {
        // If there's a unit digit (e.g., 21, 35):
        String unitWord;

        // Select the unit word based on gender, with special case for feminine "one".
        if (gender == Gender.feminine) {
          if (unitDigit == 1) {
            unitWord =
                "إحدى"; // Special form for feminine "one" in compounds (e.g., إحدى وعشرون).
          } else {
            unitWord = _wordsUnder20Fem[unitDigit]; // Use feminine words 2-9.
          }
        } else {
          unitWord = _wordsUnder20Masc[unitDigit]; // Use masculine words 1-9.
        }

        // Combine unit, "و", and tens word (reverse order in Arabic).
        return "$unitWord $_and$tensWord"; // e.g., "واحد وعشرون"
      }
    }
  }

  /// Returns the correct grammatical form of a scale word (thousand, million, etc.)
  /// based on the count preceding it.
  String _getScaleWord(BigInt count, int scaleLevel) {
    if (!_scaleForms.containsKey(scaleLevel)) {
      throw ArgumentError("Scale level $scaleLevel not defined.");
    }
    final forms =
        _scaleForms[scaleLevel]!; // Get the map of forms for this scale level.

    // Determine the form based on the count according to Arabic grammar rules.
    if (count == BigInt.one) return forms['s']!; // Singular form for 1.
    if (count == BigInt.two) return forms['d']!; // Dual form for 2.
    if (count >= BigInt.from(3) && count <= BigInt.from(10)) {
      return forms['p3_10']!; // Specific plural for 3-10.
    }
    // For numbers 11 and above, check the last two digits (modulo 100).
    BigInt countMod100 = count % BigInt.from(100);

    // Numbers ending in 11-99 use the accusative singular form (marked as p11+).
    if (countMod100 >= BigInt.from(11) && countMod100 <= BigInt.from(99)) {
      return forms['p11+']!;
    }

    // Default case (e.g., for 101, 201, etc., which technically behave like 1) should ideally use singular,
    // but the logic might simplify here. The current implementation returns singular.
    return forms['s']!;
  }

  /// Returns the correct grammatical form of a currency unit (main or subunit)
  /// based on the count preceding it and the specific currency.
  String _getCurrencyForm(
    BigInt count,
    Gender numberGender, // Note: numberGender isn't consistently used here.
    CurrencyInfo info,
    bool isMainUnit, {
    bool forceQirsh = false, // Special flag for Lira's subunit.
  }) {
    // Get base forms from CurrencyInfo.
    String singular =
        isMainUnit ? info.mainUnitSingular : (info.subUnitSingular ?? '?');
    String? plural =
        isMainUnit ? info.mainUnitPlural : (info.subUnitPlural ?? singular);
    // Placeholders for specific grammatical forms not always present in CurrencyInfo.
    String? dual;
    String? p3_10; // Plural used with numbers 3-10.
    String? p11plus; // Plural (often accusative singular) used with 11+.

    // --- Hardcoded rules for specific currencies ---
    // These override or supplement the generic forms from CurrencyInfo.
    if (info.mainUnitSingular == "ليرة") {
      // Syrian/Lebanese Lira
      if (isMainUnit) {
        singular = "ليرة"; // Singular
        dual = "ليرتان"; // Dual (for 2)
        p3_10 = "ليرات"; // Plural 3-10
        p11plus = "ليرة"; // Accusative singular for 11+
      } else {
        // Subunit: Qirsh
        singular = "قرش"; // Singular
        dual = "قرشان"; // Dual
        p3_10 = "قروش"; // Plural 3-10
        p11plus = "قرشًا"; // Accusative singular for 11+
      }
    } else if (info.mainUnitSingular == "ريال سعودي") {
      // Saudi Riyal
      if (isMainUnit) {
        singular = "ريال سعودي"; // Singular (used for 1, 2, 11+)
        // dual = null; // Dual is same as singular 'ريال'
        p3_10 = "ريالات سعودية"; // Plural 3-10
        p11plus =
            "ريالاً سعوديًا"; // Accusative singular (needed for 11-99 counts)
      } else {
        // Subunit: Halala
        singular = "هللة"; // Singular (used for 1, 11+)
        dual = "هللتان"; // Dual (for 2)
        p3_10 = "هللات"; // Plural 3-10
        p11plus = "هللة"; // Accusative singular (same as singular for Halala)
      }
    }
    // --- End of hardcoded rules ---

    // Apply grammatical rules based on count.
    if (count == BigInt.zero) {
      return plural ??
          singular; // Use plural form for zero, fallback to singular.
    }
    if (count == BigInt.one) return singular; // Use singular form for 1.
    if (count == BigInt.two) {
      // Exception: 2 Riyals uses singular "ريال" not a dual form.
      if (isMainUnit && info.mainUnitSingular == "ريال سعودي") return singular;
      // Otherwise use dual if defined, fallback to plural, then singular.
      return dual ?? plural ?? singular;
    }
    // Use the p3-10 form if defined and count is 3-10, fallback to plural, then singular.
    if (count >= BigInt.from(3) && count <= BigInt.from(10))
      return p3_10 ?? plural ?? singular;
    // Use the p11+ form if defined and count is 11+, fallback to singular.
    // Note: This relies on p11plus being correctly defined (often accusative singular).
    if (count >= BigInt.from(11)) return p11plus ?? singular;

    // Fallback for any uncovered cases (should not happen with non-negative BigInt).
    return singular;
  }
}
