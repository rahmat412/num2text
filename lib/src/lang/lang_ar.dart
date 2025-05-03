import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/ar_options.dart';
import '../options/base_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ar}
/// Converts numbers to Arabic words (`Lang.AR`).
///
/// Implements [Num2TextBase] for Arabic, handling various numeric types.
/// Supports cardinal numbers, decimals, negatives, currency, years, and large numbers
/// (up to Septillion using standard short scale names like Milyūn, Milyār).
/// Incorporates Arabic grammatical rules, including gender agreement and polarity
/// (number gender opposing noun gender for 3-10 in counted items).
/// Behavior is customizable via [ArOptions] (e.g., `gender`, `currencyInfo`).
/// Returns a fallback string on error.
/// {@endtemplate}
class Num2TextAR implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "صفر";
  static const String _point = "نقطة"; // Word for decimal point (.).
  static const String _comma = "فاصلة"; // Word for decimal separator (,).
  static const String _and = "و"; // Conjunction "and".
  static const String _yearSuffixBC =
      "ق.م"; // Suffix for Before Christ (Qabl al-Mīlād).
  static const String _yearSuffixAD = "م"; // Suffix for Anno Domini (Mīlādī).
  static const String _infinity = "لانهاية"; // Word for Infinity.
  static const String _negativeInfinity =
      "سالب لانهاية"; // Word for Negative Infinity.
  static const String _notANumber =
      "ليس رقماً"; // Default fallback for invalid input.

  // Number words 0-19 (Masculine forms).
  static const List<String> _wordsUnder20Masc = [
    "صفر",
    "واحد",
    "اثنان",
    "ثلاثة",
    "أربعة",
    "خمسة",
    "ستة",
    "سبعة",
    "ثمانية",
    "تسعة",
    "عشرة",
    "أحد عشر",
    "اثنا عشر",
    "ثلاثة عشر",
    "أربعة عشر",
    "خمسة عشر",
    "ستة عشر",
    "سبعة عشر",
    "ثمانية عشر",
    "تسعة عشر",
  ];
  // Number words 0-19 (Feminine forms).
  static const List<String> _wordsUnder20Fem = [
    "صفر",
    "واحدة",
    "اثنتان",
    "ثلاث",
    "أربع",
    "خمس",
    "ست",
    "سبع",
    "ثمان",
    "تسع",
    "عشر",
    "إحدى عشرة",
    "اثنتا عشرة",
    "ثلاث عشرة",
    "أربع عشرة",
    "خمس عشرة",
    "ست عشرة",
    "سبع عشرة",
    "ثماني عشرة",
    "تسع عشرة",
  ];
  // Tens words (20-90).
  static const List<String> _wordsTens = [
    "",
    "",
    "عشرون",
    "ثلاثون",
    "أربعون",
    "خمسون",
    "ستون",
    "سبعون",
    "ثمانون",
    "تسعون",
  ];
  // Hundreds words.
  static const Map<int, String> _wordsHundreds = {
    1: "مئة",
    2: "مئتان",
    3: "ثلاثمئة",
    4: "أربعمئة",
    5: "خمسمئة",
    6: "ستمئة",
    7: "سبعمئة",
    8: "ثمانمئة",
    9: "تسعمئة",
  };
  // Scale words (Short Scale: Thousand, Million, Billion...) with grammatical forms.
  // s: singular, d: dual, p3_10: plural (for counts 3-10), p11+: form for counts 11+ (accusative singular).
  static const Map<int, Map<String, String>> _scaleForms = {
    1: {
      's': 'ألف',
      'd': 'ألفان',
      'p3_10': 'آلاف',
      'p11+': 'ألفًا'
    }, // 10^3 Thousand
    2: {
      's': 'مليون',
      'd': 'مليونان',
      'p3_10': 'ملايين',
      'p11+': 'مليونًا'
    }, // 10^6 Million
    3: {
      's': 'مليار',
      'd': 'ملياران',
      'p3_10': 'مليارات',
      'p11+': 'مليارًا'
    }, // 10^9 Billion
    4: {
      's': 'تريليون',
      'd': 'تريليونان',
      'p3_10': 'تريليونات',
      'p11+': 'تريليونًا'
    }, // 10^12 Trillion
    5: {
      's': 'كوادريليون',
      'd': 'كوادريليونان',
      'p3_10': 'كوادريليونات',
      'p11+': 'كوادريليونًا'
    }, // 10^15 Quadrillion
    6: {
      's': 'كوينتيليون',
      'd': 'كوينتيليونان',
      'p3_10': 'كوينتيليونات',
      'p11+': 'كوينتيليونًا'
    }, // 10^18 Quintillion
    7: {
      's': 'سكستيليون',
      'd': 'سكستيليونان',
      'p3_10': 'سكستيليونات',
      'p11+': 'سكستيليونًا'
    }, // 10^21 Sextillion
    8: {
      's': 'سبتيليون',
      'd': 'سبتيليونان',
      'p3_10': 'سبتيليونات',
      'p11+': 'سبتيليونًا'
    }, // 10^24 Septillion
  };

  /// Processes the given [number] into Arabic words.
  ///
  /// {@template num2text_process_intro}
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options}
  /// Uses [ArOptions] for customization (currency, year format, gender, decimals, AD/BC).
  /// Defaults apply if [options] is null or not [ArOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or default error string on failure.
  /// {@endtemplate}
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final ArOptions arOptions =
        options is ArOptions ? options : const ArOptions();
    final String errorFallback = fallbackOnError ?? _notANumber;

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _negativeInfinity : _infinity;
      if (number.isNaN) return errorFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    if (decimalValue == Decimal.zero) {
      return arOptions.currency
          // Use default masculine gender for zero currency unit form
          ? "$_zero ${_getCurrencyForm(BigInt.zero, Gender.masculine, arOptions.currencyInfo, true)}"
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    if (arOptions.format == Format.year) {
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), arOptions);
    } else {
      // Determine the effective gender context for the conversion.
      // Currency gender depends on the unit name (e.g., Lira=fem, Riyal=masc). Standard numbers use option gender.
      Gender effectiveGender = arOptions.currency
          ? ((arOptions.currencyInfo.mainUnitSingular == "ليرة")
              ? Gender.feminine
              : Gender.masculine) // Simplified logic based on known currencies
          : arOptions.gender;

      textResult = arOptions.currency
          ? _handleCurrency(absValue, arOptions)
          // Pass the determined context gender to standard number conversion
          : _handleStandardNumber(absValue, arOptions, effectiveGender);

      if (isNegative) {
        textResult = "${arOptions.negativePrefix} $textResult";
      }
    }
    return textResult.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Converts a positive [Decimal] to standard Arabic cardinal words, including decimals.
  ///
  /// Converts integer part via [_convertInteger], passing the contextual [gender].
  /// Appends fractional part read digit-by-digit after the separator ("نقطة" or "فاصلة").
  /// Decimal digits typically use masculine forms.
  ///
  /// @param absValue Positive number.
  /// @param options [ArOptions] for decimal separator word.
  /// @param gender The grammatical gender context ([Gender.masculine] or [Gender.feminine]).
  /// @return Number formatted as Arabic words.
  String _handleStandardNumber(
      Decimal absValue, ArOptions options, Gender gender) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part. applyPolarity=false as it's a standalone number.
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, gender, applyPolarity: false);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero && !absValue.isInteger) {
      String separatorWord =
          (options.decimalSeparator == DecimalSeparator.point ||
                  options.decimalSeparator == DecimalSeparator.period)
              ? _point
              : _comma; // Default is comma.

      // Get fractional digits, remove trailing zeros.
      String decimalString = absValue.toString();
      String fractionalDigits =
          decimalString.contains('.') ? decimalString.split('.').last : '';
      fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      if (fractionalDigits.isNotEmpty) {
        // Convert each digit individually, typically using masculine form.
        List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder20Masc[
                  digitInt] // Digits usually read with masculine words.
              : '?';
        }).toList();
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts an integer year to Arabic words.
  ///
  /// Years are treated as cardinal numbers (masculine, no polarity rule applied).
  /// Appends AD/BC suffixes based on [ArOptions.includeAD].
  ///
  /// @param year The integer year.
  /// @param options Formatting options.
  /// @return The year as Arabic words.
  String _handleYearFormat(int year, ArOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;

    // Convert year as a standard masculine number, no polarity applied.
    String yearText = (absYear == 0)
        ? _zero
        : _convertInteger(BigInt.from(absYear), Gender.masculine,
            applyPolarity: false, isYear: true);

    // Append era suffixes if needed.
    if (isNegative)
      yearText += " $_yearSuffixBC";
    else if (options.includeAD && absYear > 0) yearText += " $_yearSuffixAD";

    return yearText;
  }

  /// Converts a positive [Decimal] value to Arabic currency words.
  ///
  /// Applies grammatical rules: gender polarity (number vs. noun for 3-10),
  /// construct state (dropping final 'n' on duals like مئتا, ألفا).
  /// Uses [ArOptions.currencyInfo] for unit names and rules.
  ///
  /// @param absValue The positive currency amount.
  /// @param options [ArOptions] with currency info and rounding preference.
  /// @return The currency value formatted as Arabic words.
  String _handleCurrency(Decimal absValue, ArOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    final Decimal val = options.round ? absValue.round(scale: 2) : absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    // Subunit calculation assumes 100 subunits per unit.
    final BigInt subVal =
        ((val - val.truncate()) * Decimal.fromInt(100)).truncate().toBigInt();

    if (mainVal == BigInt.zero && subVal == BigInt.zero) {
      // Zero currency uses default masculine form.
      return "$_zero ${_getCurrencyForm(mainVal, Gender.masculine, info, true)}";
    }

    // Determine the grammatical gender of the *nouns* (units).
    Gender mainNounGender = (info.mainUnitSingular == "ليرة")
        ? Gender.feminine
        : Gender.masculine; // e.g., Lira=fem, Riyal=masc
    Gender subNounGender = (info.subUnitSingular == "هللة")
        ? Gender.feminine
        : Gender.masculine; // e.g., Halala=fem, Qirsh=masc

    String mainPart = "";
    if (mainVal > BigInt.zero) {
      String mainUnitName = _getCurrencyForm(mainVal, mainNounGender, info,
          true); // Get correct unit form based on count.
      // Convert the number, applying polarity based on the main noun's gender.
      String numberText =
          _convertInteger(mainVal, mainNounGender, applyPolarity: true).trim();

      // Apply construct state (idaafa) for duals preceding the noun.
      if (numberText == "مئتان")
        numberText = "مئتا"; // Drop ن
      else if (numberText == "ألفان")
        numberText = "ألفا"; // Drop ن
      else if (numberText == "مليونان") numberText = "مليونا"; // Drop ن
      // Add other dual scale forms if needed (e.g., مليار -> مليارا).

      // Handle special cases for 1 and 2, and numbers ending in 1 or 2.
      if (mainVal == BigInt.one) {
        mainPart =
            '$mainUnitName $numberText'; // Noun + Adjective: ريال سعودي واحد
      } else if (mainVal == BigInt.two &&
          mainUnitName == _getDefinedDualForm(info, true)) {
        mainPart =
            mainUnitName; // Use defined dual form directly: ريالان سعوديان
      } else if (mainVal % BigInt.from(100) == BigInt.one &&
          mainVal > BigInt.from(100)) {
        // Special structure for X01: Number(X00) + SingularUnit + "wa" + Number(1)
        BigInt hundredsVal = mainVal - BigInt.one;
        // Convert hundreds part (no polarity), unit gender context.
        String hundredsText =
            _convertInteger(hundredsVal, mainNounGender, applyPolarity: false)
                .trim();
        // Convert the 'one' part (no polarity), unit gender context.
        String oneText =
            _convertInteger(BigInt.one, mainNounGender, applyPolarity: false)
                .trim();
        // Get singular unit name for the hundreds part (e.g., 'ريال').
        String singularUnitName =
            _getCurrencyForm(BigInt.from(100), mainNounGender, info, true);
        mainPart =
            '$hundredsText $singularUnitName $_and$oneText'; // e.g., مئة ريال سعودي وواحد
      } else if (mainVal % BigInt.from(100) == BigInt.two &&
          mainVal > BigInt.from(100)) {
        // Special structure for X02: Number(X00) + SingularUnit + "wa" + Number(2)
        BigInt hundredsVal = mainVal - BigInt.two;
        String hundredsText =
            _convertInteger(hundredsVal, mainNounGender, applyPolarity: false)
                .trim();
        String twoText =
            _convertInteger(BigInt.two, mainNounGender, applyPolarity: false)
                .trim();
        String singularUnitName =
            _getCurrencyForm(BigInt.from(100), mainNounGender, info, true);
        mainPart =
            '$hundredsText $singularUnitName $_and$twoText'; // e.g., مئة ريال سعودي واثنان
      } else {
        // Standard structure: Number + Unit Name
        mainPart = '$numberText $mainUnitName';
      }
    }

    String subPart = "";
    if (subVal > BigInt.zero && info.subUnitSingular != null) {
      String subUnitName = _getCurrencyForm(
          subVal, subNounGender, info, false); // Get correct subunit form.
      // Convert subunit number, applying polarity based on subunit noun's gender.
      String numberText =
          _convertInteger(subVal, subNounGender, applyPolarity: true).trim();

      // Construct state unlikely for standard subunits, but check if needed.

      // Handle special cases for 1 and 2 subunits.
      if (subVal == BigInt.one) {
        subPart = '$subUnitName $numberText'; // Noun + Adjective: هللة واحدة
      } else if (subVal == BigInt.two &&
          subUnitName == _getDefinedDualForm(info, false)) {
        subPart = subUnitName; // Use defined dual form directly: هللتان
      } else {
        // Standard structure: Number + Unit Name
        subPart = '$numberText $subUnitName';
      }
    }

    // Combine main and subunit parts with the separator.
    String result = mainPart.trim();
    if (result.isNotEmpty && subPart.isNotEmpty) {
      String effectiveSeparator = info.separator ?? _and;
      // Ensure separator has spaces.
      if (effectiveSeparator.trim() == _and) {
        result += ' $effectiveSeparator${subPart.trim()}';
      } else {
        result += ' ${effectiveSeparator.trim()} ${subPart.trim()}';
      }
    } else if (subPart.isNotEmpty) {
      result = subPart.trim(); // Only subunit exists.
    }

    return result.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Converts a non-negative integer ([BigInt]) into Arabic words.
  ///
  /// Handles gender agreement and polarity based on the context ([targetNounGender], [applyPolarity]).
  /// Uses short scale (thousand, million, billion...).
  /// `isYear` flag disables specific grammatical features not used for years.
  /// `isCountingScale` flag indicates the number is counting a scale word (e.g., 'three' in 'three million'), affecting internal polarity application.
  ///
  /// @param n Non-negative integer.
  /// @param targetNounGender The gender of the noun being counted (influences number word choice/polarity).
  /// @param applyPolarity If true, applies gender polarity for numbers 3-10 (number gender opposes noun gender). Set false for standalone numbers or years.
  /// @param isYear If true, indicates conversion is for a year (disables some rules).
  /// @param isCountingScale If true, indicates the number counts a scale word (e.g., 'three' million).
  /// @return Integer as Arabic words.
  String _convertInteger(BigInt n, Gender targetNounGender,
      {required bool applyPolarity,
      bool isYear = false,
      bool isCountingScale = false}) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero) throw ArgumentError("Negative input: $n");

    // Determine the required grammatical gender for the *number word itself*.
    Gender numberWordGender =
        targetNounGender; // Default: number matches noun/context.

    // Apply gender polarity rule (number opposes noun gender) for 3-10 when counting things.
    if (applyPolarity &&
        !isCountingScale &&
        n >= BigInt.from(3) &&
        n <= BigInt.from(10)) {
      numberWordGender = (targetNounGender == Gender.masculine)
          ? Gender.feminine
          : Gender.masculine;
    }
    // Adjust gender for standalone numbers (applyPolarity is false).
    else if (!applyPolarity && !isCountingScale) {
      // For standalone 1, 2, 11+, number matches context gender.
      // For standalone 3-10, number is usually masculine (with ة) unless context is feminine.
      if (n >= BigInt.from(3) && n <= BigInt.from(10)) {
        // Use feminine form (no ة) only if context (targetNounGender) is explicitly feminine.
        numberWordGender = (targetNounGender == Gender.feminine)
            ? Gender.feminine
            : Gender.masculine;
      }
      // No change needed for 1, 2, 11+ here, default matching context is correct.
    }
    // Gender determination when counting scale words (isCountingScale=true) is handled below.

    // Select the base word list (masculine or feminine) based on the determined *number word gender*.
    final List<String> baseWords = (numberWordGender == Gender.feminine)
        ? _wordsUnder20Fem
        : _wordsUnder20Masc;

    // --- Conversion Logic ---
    if (n < BigInt.from(100)) {
      // Handle numbers 0-99 using the determined number gender.
      return _convertChunk(n.toInt(), numberWordGender, baseWords);
    }
    if (n < BigInt.from(1000)) {
      // Handle 100-999, passing determined number gender for the chunk, and original noun gender for context.
      return _convertHundredsAndBelow(n.toInt(), numberWordGender, baseWords,
          targetNounGender, applyPolarity);
    }

    // --- Scale Handling (Thousands, Millions, etc.) ---
    List<String> parts = []; // Stores parts like "ثلاثة ملايين", "وخمسمئة ألف".
    BigInt currentN = n; // Remaining value to convert.
    // Process scales from largest to smallest defined.
    List<int> scaleLevels = _scaleForms.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    bool firstPart = true; // Flag to handle adding "و" correctly.

    for (int scaleLevel in scaleLevels) {
      final scaleValue = BigInt.from(10)
          .pow(scaleLevel * 3); // Value of the scale (1000, 1M, 1B...).
      if (currentN >= scaleValue) {
        BigInt count = currentN ~/
            scaleValue; // How many of this scale unit (e.g., 3 for 3 million).
        currentN %= scaleValue; // Update remainder.

        // Determine gender for the *count* number (e.g., the 'three' in 'three million').
        // Scale nouns (million, billion) are masculine. Apply polarity: 3-10 count uses feminine form.
        Gender countWordGender =
            (count >= BigInt.from(3) && count <= BigInt.from(10))
                ? Gender.feminine
                : Gender.masculine;

        // Convert the count number itself. No further polarity needed *inside* this conversion.
        String countText = _convertInteger(count, countWordGender,
            applyPolarity: false, isCountingScale: true);
        // Get the appropriate grammatical form of the scale word based on the count.
        String scaleWord = _getScaleWord(count, scaleLevel);

        // Combine count and scale word, handling special dual cases.
        String combinedPart;
        if (count == BigInt.two && scaleWord.endsWith('ان')) {
          combinedPart =
              scaleWord; // Use the full dual form (e.g., "ألفان", "مليونان").
        } else if (count == BigInt.one &&
            scaleWord == _scaleForms[scaleLevel]!['s']) {
          combinedPart =
              scaleWord; // Just use singular scale word for one (e.g., "ألف", "مليون").
        } else {
          combinedPart =
              "$countText $scaleWord"; // Standard: "CountText ScaleWord".
        }

        // Add "و" before parts after the first one.
        if (!firstPart && combinedPart.isNotEmpty)
          parts.add("$_and$combinedPart");
        else if (combinedPart.isNotEmpty) parts.add(combinedPart);
        firstPart = false;
      }
    }

    // Handle the final remainder (0-999).
    if (currentN > BigInt.zero) {
      // Convert remainder using original target noun gender and polarity flag.
      String remainderText = _convertInteger(currentN, targetNounGender,
          applyPolarity: applyPolarity);
      if (!firstPart && remainderText.isNotEmpty)
        parts.add("$_and$remainderText");
      else if (remainderText.isNotEmpty) parts.add(remainderText);
    }

    // Join all parts with spaces.
    return parts.join(' ').trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Converts hundreds part (100-999) of a number. Helper for [_convertInteger].
  /// Handles combining hundreds word with the conversion of the remainder (0-99).
  /// Determines gender for the remainder part based on context and polarity rules.
  ///
  /// @param n Number between 100-999.
  /// @param numberWordGenderForChunk The pre-determined gender for the number word itself (e.g., for مئة).
  /// @param baseWords The word list matching `numberWordGenderForChunk`.
  /// @param originalTargetNounGender The gender of the noun being counted (context for remainder).
  /// @param applyPolarity Whether polarity rules should apply to the remainder (3-10).
  /// @return Number 100-999 as Arabic words.
  String _convertHundredsAndBelow(
      int n,
      Gender numberWordGenderForChunk,
      List<String> baseWords,
      Gender originalTargetNounGender,
      bool applyPolarity) {
    if (n < 100 || n >= 1000) throw ArgumentError("Input must be 100-999: $n");

    int hundredDigit = n ~/ 100; // 1-9
    int remainder = n % 100; // 0-99
    String hundredWord =
        _wordsHundreds[hundredDigit]!; // "مئة", "مئتان", "ثلاثمئة"...

    if (remainder == 0)
      return hundredWord; // Just the hundred word if no remainder.
    else {
      // Determine the required gender for the *remainder number word* (1-99).
      Gender remainderNumberWordGender =
          originalTargetNounGender; // Default: match noun gender.

      // Apply polarity if requested and remainder is 3-10.
      if (applyPolarity && remainder >= 3 && remainder <= 10) {
        remainderNumberWordGender =
            (originalTargetNounGender == Gender.masculine)
                ? Gender.feminine
                : Gender.masculine;
      }
      // Adjust gender for standalone context (applyPolarity=false).
      else if (!applyPolarity) {
        if (remainder >= 3 && remainder <= 10) {
          // Standalone 3-10: Use feminine form only if context is feminine, else masculine.
          remainderNumberWordGender =
              (originalTargetNounGender == Gender.feminine)
                  ? Gender.feminine
                  : Gender.masculine;
        }
        // No change needed for 1, 2, 11+, default matching context is correct.
      }
      // No change needed if polarity applies but remainder is outside 3-10 range.

      // Select word list based on determined gender for the remainder.
      final List<String> remainderBaseWords =
          (remainderNumberWordGender == Gender.feminine)
              ? _wordsUnder20Fem
              : _wordsUnder20Masc;
      // Convert the remainder (1-99).
      String remainderText = _convertChunk(
          remainder, remainderNumberWordGender, remainderBaseWords);

      // Combine: "HundredWord wa RemainderText".
      return "$hundredWord $_and$remainderText";
    }
  }

  /// Converts an integer from 0 to 99 into Arabic words.
  /// Uses the specified `numberWordGender` and corresponding `baseWords`.
  /// Handles compound numbers (21-99) with the structure "Unit wa Tens".
  ///
  /// @param n Integer 0-99.
  /// @param numberWordGender The required gender for the number word itself.
  /// @param baseWords The word list (_wordsUnder20Masc or _wordsUnder20Fem) matching the gender.
  /// @return Number 0-99 as Arabic words, or empty string if 0.
  String _convertChunk(int n, Gender numberWordGender, List<String> baseWords) {
    if (n < 0 || n >= 100) throw ArgumentError("Input must be 0-99: $n");
    if (n == 0)
      return ""; // Zero part contributes nothing within a larger number.

    if (n < 20)
      return baseWords[n]; // 0-19 have unique words.
    else {
      int tensDigit = n ~/ 10; // 2-9
      int unitDigit = n % 10; // 0-9
      String tensWord = _wordsTens[tensDigit]; // "عشرون", "ثلاثون"...

      if (unitDigit == 0)
        return tensWord; // Pure tens (20, 30...).
      else {
        // Compound numbers (21-99): Unit + "wa" + Tens.
        // Special case for 'one' with feminine numbers (إحدى not واحدة).
        String unitWord =
            (numberWordGender == Gender.feminine && unitDigit == 1)
                ? "إحدى" // Use إحدى for feminine compounds like إحدى وعشرون
                : baseWords[
                    unitDigit]; // Use standard word from the list otherwise.
        return "$unitWord $_and$tensWord"; // e.g., "واحد وعشرون", "إحدى وعشرون"
      }
    }
  }

  /// Selects the correct grammatical form of a scale word (thousand, million, etc.) based on the count.
  /// Uses the definitions in [_scaleForms].
  ///
  /// @param count The number counting the scale unit.
  /// @param scaleLevel The scale level (1=thousand, 2=million...).
  /// @return The appropriate scale word form (singular, dual, plural 3-10, plural 11+).
  String _getScaleWord(BigInt count, int scaleLevel) {
    if (!_scaleForms.containsKey(scaleLevel))
      throw ArgumentError("Scale level $scaleLevel undefined.");
    final forms = _scaleForms[scaleLevel]!; // s, d, p3_10, p11+

    // Simple cases: 1 and 2.
    if (count == BigInt.one) return forms['s']!; // Singular form.
    if (count == BigInt.two) return forms['d']!; // Dual form (e.g., "ألفان").

    // Determine form based on count modulo 100 for numbers >= 3.
    BigInt countMod100 = count % BigInt.from(100);

    // Rule for 3-10: Use p3_10 form. Applies even if count is large (e.g., 103 uses p3_10).
    if (count >= BigInt.from(3) && count <= BigInt.from(10))
      return forms['p3_10']!;

    // Rule for 11-99 (within any hundred): Use p11+ form (accusative singular).
    if (countMod100 >= BigInt.from(11) && countMod100 <= BigInt.from(99))
      return forms['p11+']!;

    // Rules for counts >= 100. Check the last two digits (countMod100).
    if (count >= BigInt.from(100)) {
      if (countMod100 == BigInt.zero)
        return forms['s']!; // 100, 200, etc. take singular.
      if (countMod100 == BigInt.one)
        return forms['s']!; // 101, 201, etc. take singular.
      if (countMod100 == BigInt.two)
        return forms['d']!; // 102, 202, etc. take dual.
      if (countMod100 >= BigInt.from(3) && countMod100 <= BigInt.from(10))
        return forms['p3_10']!; // 103-110, etc. take p3_10.
    }

    // Fallback for any other case (should include numbers ending 11-99 handled above).
    return forms['p11+']!;
  }

  /// Selects the correct grammatical form of a currency unit based on the count.
  /// Contains hardcoded rules for specific known currencies (Lira, Riyal).
  /// Needs expansion for other currencies with complex plurals.
  ///
  /// @param count The number counting the currency unit.
  /// @param targetNounGender The inherent gender of the currency unit (not used by current logic but kept for signature).
  /// @param info The [CurrencyInfo] object.
  /// @param isMainUnit True if getting form for main unit, false for subunit.
  /// @return The appropriate currency unit form (singular, dual, plural).
  String _getCurrencyForm(BigInt count, Gender targetNounGender,
      CurrencyInfo info, bool isMainUnit) {
    // Get base singular/plural from CurrencyInfo.
    String singular =
        isMainUnit ? info.mainUnitSingular : (info.subUnitSingular ?? '?');
    String? plural = isMainUnit ? info.mainUnitPlural : info.subUnitPlural;

    // Initialize specific forms - these will be overridden by hardcoded rules if they match.
    String? dual = plural; // Default dual to plural if not specified.
    String? p3_10 = plural; // Default plural 3-10 to general plural.
    String? p11plus =
        singular; // Default plural 11+ to singular (common pattern).

    // --- Hardcoded rules for known currencies ---
    if (info.mainUnitSingular == "ليرة") {
      // Syrian Lira Example
      if (isMainUnit) {
        singular = "ليرة";
        dual = "ليرتان";
        p3_10 = "ليرات";
        p11plus = "ليرة";
      } else {
        // Subunit: Qirsh
        singular = "قرش";
        dual = "قرشان";
        p3_10 = "قروش";
        p11plus = "قرشًا"; // Note accusative
      }
    } else if (info.mainUnitSingular == "ريال سعودي") {
      // Saudi Riyal Example
      if (isMainUnit) {
        singular = "ريال سعودي";
        dual = "ريالان سعوديان";
        p3_10 = "ريالات سعودية";
        p11plus = "ريالاً سعودياً"; // Note accusative
      } else {
        // Subunit: Halala
        singular = "هللة";
        dual = "هللتان";
        p3_10 = "هللات";
        p11plus = "هللة";
      }
    }
    // Add more 'else if' blocks for other currencies here.

    // --- Apply standard Arabic number agreement rules ---
    if (count == BigInt.one) return singular;
    if (count == BigInt.two)
      return dual ?? plural ?? singular; // Use specific dual if available.

    BigInt countMod100 = count % BigInt.from(100);

    // Rule for 3-10.
    if (count >= BigInt.from(3) && count <= BigInt.from(10))
      return p3_10 ?? plural ?? singular;

    // Rule for 11-99 (within any hundred).
    if (countMod100 >= BigInt.from(11) && countMod100 <= BigInt.from(99))
      return p11plus;

    // Rules for counts >= 100 based on last two digits.
    if (count >= BigInt.from(100)) {
      if (countMod100 == BigInt.zero)
        return singular; // 100, 200 take singular.
      if (countMod100 == BigInt.one) return singular; // 101, 201 take singular.
      if (countMod100 == BigInt.two)
        return dual ?? plural ?? singular; // 102, 202 take dual.
      if (countMod100 >= BigInt.from(3) && countMod100 <= BigInt.from(10))
        return p3_10 ?? plural ?? singular; // 103-110 take p3_10.
    }

    // Fallback to general plural or singular if no specific rule matched.
    return plural ?? singular;
  }

  /// Helper to retrieve the specifically defined dual form for known currencies.
  /// Returns null if no specific dual form is hardcoded for the currency.
  /// Used in _handleCurrency to check for direct dual usage (e.g., ريالان).
  ///
  /// @param info The [CurrencyInfo] object.
  /// @param isMainUnit True if checking main unit, false for subunit.
  /// @return The specific dual form string or null.
  String? _getDefinedDualForm(CurrencyInfo info, bool isMainUnit) {
    if (info.mainUnitSingular == "ليرة") return isMainUnit ? "ليرتان" : "قرشان";
    if (info.mainUnitSingular == "ريال سعودي")
      return isMainUnit ? "ريالان سعوديان" : "هللتان";
    // Add checks for other currencies if specific dual forms exist.
    return null; // Return null if no specific dual form is defined for this currency.
  }
}
