import 'dart:math'; // Used for min()

import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/hu_options.dart';
import '../utils/utils.dart';

/// {@template num2text_hu}
/// Converts numbers to Hungarian words (`Lang.HU`).
///
/// Implements [Num2TextBase] for Hungarian, handling various numeric types.
/// Follows Hungarian grammar rules, including compounding (joining words without space)
/// and hyphenation for numbers >= 2000. Uses the long scale (millió, milliárd, etc.).
///
/// Supports:
/// - Cardinal numbers with correct compounding/hyphenation.
/// - Currency formatting (typically simple structure, e.g., "száz forint").
/// - Year formatting (with optional AD/BC suffixes).
/// - Decimals (using "egész" or "pont").
/// - Negative numbers.
/// - Large numbers (long scale).
///
/// Customizable via [HuOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextHU implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "nulla";
  static const String _point = "pont"; // Decimal separator "point"
  static const String _comma = "egész"; // Decimal separator "comma" / "whole"
  static const String _thousandSeparator =
      "-"; // Hyphen used after scales for numbers >= 2000
  static const String _yearSuffixBC =
      "i. e."; // "időszámításunk előtt" (before our era)
  static const String _yearSuffixAD =
      "i. sz."; // "időszámításunk szerint" (according to our era)

  // Numbers 0-19 (index 0 empty)
  static const List<String> _wordsUnder20 = [
    "",
    "egy",
    "kettő",
    "három",
    "négy",
    "öt",
    "hat",
    "hét",
    "nyolc",
    "kilenc",
    "tíz",
    "tizenegy",
    "tizenkettő",
    "tizenhárom",
    "tizennégy",
    "tizenöt",
    "tizenhat",
    "tizenhét",
    "tizennyolc",
    "tizenkilenc",
  ];

  // Tens (index 0, 1 empty)
  static const List<String> _wordsTens = [
    "",
    "",
    "húsz",
    "harminc",
    "negyven",
    "ötven",
    "hatvan",
    "hetven",
    "nyolcvan",
    "kilencven",
  ];

  static const String _hundredWord = "száz"; // "hundred"
  static const String _thousandWord = "ezer"; // "thousand"

  // Scale words (Long Scale: 10^6, 10^9, 10^12...)
  static const List<String> _scaleWords = [
    "", // 10^0 (Units)
    _thousandWord, // 10^3
    "millió", // 10^6
    "milliárd", // 10^9
    "billió", // 10^12
    "billiárd", // 10^15
    "trillió", // 10^18
    "trilliárd", // 10^21
    "kvadrillió", // 10^24
    "kvadrilliárd", // 10^27
    "kvintillió", // 10^30
    "kvintilliárd", // 10^33
    "szextillió", // 10^36
    "szextilliárd", // 10^39
  ];

  /// Processes the given [number] into Hungarian words.
  ///
  /// {@template num2text_process_intro_hu}
  /// Normalizes input to [Decimal]. Handles `Infinity`, `NaN`.
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options_hu}
  /// Uses [HuOptions] for customization (currency, year format, decimal separator, AD/BC, negative prefix).
  /// Defaults apply if [options] is null or not [HuOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors_hu}
  /// Returns [fallbackOnError] or "Nem szám" on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [HuOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Hungarian words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final HuOptions huOptions =
        options is HuOptions ? options : const HuOptions();
    const String defaultFallback = "Nem szám"; // "Not a number"

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Negatív végtelen" : "Végtelen";
      if (number.isNaN) return fallbackOnError ?? defaultFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return fallbackOnError ?? defaultFallback;

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    // Handle zero separately.
    if (decimalValue == Decimal.zero) {
      // Zero currency usually includes the main unit name.
      if (huOptions.currency) {
        // Check if subunits exist to let _handleCurrency decide if only subunits show
        if (huOptions.currencyInfo.subUnitSingular != null &&
            absValue.scale > 0) {
          // Fall through to _handleCurrency for potential "nulla [main] X [sub]" or just "X [sub]"
        } else {
          // Otherwise, return "nulla [mainUnit]".
          return "$_zero ${huOptions.currencyInfo.mainUnitSingular}";
        }
      }
      // Standard zero or year zero.
      if (huOptions.format == Format.year || decimalValue.isInteger) {
        return _zero;
      }
      // If it's 0.xyz, fall through to handle via _handleStandardNumber which prepends "nulla".
    }

    String textResult;
    if (huOptions.format == Format.year) {
      // Year formatting handles negativity internally via suffixes.
      textResult = _handleYearFormat(
          absValue.truncate().toBigInt(), isNegative, huOptions);
    } else {
      if (huOptions.currency) {
        textResult = _handleCurrency(absValue, huOptions);
      } else {
        textResult = _handleStandardNumber(absValue, huOptions);
      }
      // Prepend negative prefix if needed.
      if (isNegative) {
        // Avoid double prefix if zero handling already included it (e.g., 0.5 case).
        if (!(decimalValue == Decimal.zero && textResult.startsWith(_zero))) {
          textResult = "${huOptions.negativePrefix} $textResult";
        }
      }
    }

    return textResult.trim();
  }

  /// Converts a non-negative integer ([BigInt]) into Hungarian words.
  ///
  /// Handles Hungarian compounding rules (joining words) and hyphenation for numbers >= 2000.
  /// Uses the long scale (millió, milliárd, etc.).
  ///
  /// @param n The non-negative BigInt number.
  /// @throws ArgumentError If n is negative or exceeds defined scales.
  /// @return The integer as Hungarian words.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero) {
      throw ArgumentError(
          "Internal error: _convertInteger received negative number: $n");
    }
    if (n == BigInt.zero) return _zero;

    // Handle specific cases crucial for compounding/rules.
    if (n == BigInt.from(1000)) return _thousandWord; // "ezer"
    if (n == BigInt.from(2000))
      return "kétezer"; // Special compound form for 2000.

    // Numbers 1001-1999 have special compounding: "ezer" + remainder word.
    if (n > BigInt.from(1000) && n < BigInt.from(2000)) {
      final int remainder = (n % BigInt.from(1000)).toInt();
      // Convert the 1-999 remainder.
      final String remainderText = _convertChunk1To999(remainder);
      // Join directly: "ezer" + "egy" -> "ezeregy", "ezer" + "száz" -> "ezerszáz".
      return "$_thousandWord$remainderText";
    }

    // For numbers >= 2000 or < 1000, use chunking logic.
    final String s = n.toString();
    final int len = s.length;
    // Determine number of 3-digit groups.
    final int numGroups = (len + 2) ~/ 3;
    // Length of the first (leftmost) group (can be 1, 2, or 3 digits).
    final int firstGroupLen = len % 3 == 0 ? 3 : len % 3;

    List<String> parts = []; // Stores converted scale group strings.
    int currentPos = 0; // Current position in the number string.
    // Tracks if the last *non-zero* chunk processed was the units chunk (for hyphenation).
    bool lastChunkWasUnits = false;

    // Iterate through groups from left to right (most significant to least significant).
    for (int groupIndex = 0; groupIndex < numGroups; groupIndex++) {
      final int groupLen = (groupIndex == 0) ? firstGroupLen : 3;
      final int endPos =
          min(currentPos + groupLen, len); // Avoid overshooting string length.
      final String groupStr = s.substring(currentPos, endPos);
      final int groupValue =
          int.parse(groupStr); // Numeric value of the group (1-999).
      currentPos += groupLen;

      // Scale index (0=units, 1=thousands, 2=millions...). Decreases from left to right.
      final int scaleIndex = numGroups - 1 - groupIndex;

      // Skip groups that are zero.
      if (groupValue == 0) {
        continue;
      }

      // If this non-zero group is the units group, mark it for potential hyphenation later.
      lastChunkWasUnits = (scaleIndex == 0);

      // Check if scale is defined.
      if (scaleIndex >= _scaleWords.length) {
        throw ArgumentError(
            "Number too large, scale index $scaleIndex out of bounds.");
      }

      // Convert the current group's value (1-999) to words.
      String currentGroupText = _convertChunk1To999(groupValue);
      // Use a temporary variable for potential 'kettő' -> 'két' transformation.
      String prefixText = currentGroupText;

      if (scaleIndex > 0) {
        // This group is thousands, millions, etc.
        final String scaleWord = _scaleWords[scaleIndex];
        String partToAdd; // The final string for this scale group.
        bool compound =
            false; // Flag to determine if compounding (no space) occurs.

        // Apply Hungarian compounding rules before scale words:
        // Compound if the number part is:
        // - 1 before million+ (egy + millió)
        // - 2 before thousand+ (két + ezer/millió)
        // - 1-999 before thousand (e.g., száz + ezer) -> (handled by 1001-1999 logic earlier, and this catches other cases)
        // - Any number ending in 0 (tíz, húsz, száz, ...) before any scale word.
        if (groupValue == 1 && scaleIndex > 1)
          compound = true;
        else if (groupValue == 2 && scaleIndex >= 1)
          compound = true;
        else if (scaleIndex == 1 && groupValue > 0 /* && groupValue < 1000 */)
          compound = true; // 1ezer-999ezer compound
        else if (groupValue > 0 && groupValue % 10 == 0) compound = true;

        // Apply 'kettő' -> 'két' transformation if needed before the scale word.
        if (groupValue == 2) {
          prefixText = "két"; // Number is exactly 2.
        } else if (prefixText.endsWith("kettő")) {
          // Number ends in 2 (e.g., tizenkettő -> tizenkét).
          prefixText = "${prefixText.substring(0, prefixText.length - 5)}két";
        }

        // Construct the part for this scale.
        if (groupValue == 1 && scaleIndex == 1) {
          // Handle exactly 1000 prefix (e.g., in 5,001,000 -> ötmillió-ezer). Just use "ezer".
          partToAdd = scaleWord;
        } else if (compound) {
          // Compound directly: "két"+"ezer"->"kétezer", "tíz"+"millió"->"tízmillió".
          partToAdd = "$prefixText$scaleWord";
        } else {
          // Separate with space: "három millió", "százhuszonhárom millió".
          partToAdd = "$prefixText $scaleWord";
        }
        parts.add(partToAdd);
      } else {
        // This IS the units part (scaleIndex == 0).
        // Use the original text ('kettő' remains 'kettő' here, e.g., "százkettő").
        parts.add(currentGroupText);
      }
    }

    // If all groups were zero (input was effectively 0).
    if (parts.isEmpty) return _zero;

    // Combine the parts. Apply hyphenation rule:
    // Hyphenate ONLY IF original number >= 2000 AND the last non-zero part was the units group.
    if (n >= BigInt.from(2000) && lastChunkWasUnits && parts.length > 1) {
      // Join scale parts with space, then hyphen, then units part.
      String prefix = parts.sublist(0, parts.length - 1).join(' ');
      return prefix +
          _thousandSeparator +
          parts.last; // e.g., "kétezer-egy", "ötmillió-száz"
    } else {
      // Otherwise, join all parts with spaces.
      return parts.join(' '); // e.g., "ezerötszáz", "százhuszonhárom"
    }
  }

  /// Formats a non-negative [Decimal] value as Hungarian currency.
  ///
  /// Hungarian currency usually uses a simple structure: number + unit name.
  /// Rounding is applied to standard subunit places.
  ///
  /// @param absValue The absolute decimal value of the currency.
  /// @param options The [HuOptions] with currency info.
  /// @return The currency value formatted as Hungarian words.
  String _handleCurrency(Decimal absValue, HuOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    const int decimalPlaces = 2; // Standard subunit precision.
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value to the standard subunit places.
    final Decimal valueToConvert = absValue.round(scale: decimalPlaces);

    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    // Calculate subunit value precisely.
    final BigInt subunitValue =
        ((valueToConvert - mainValue.toDecimal()) * subunitMultiplier)
            .truncate()
            .toBigInt();

    String result = "";

    // Convert main value if > 0.
    if (mainValue > BigInt.zero) {
      String mainText = _convertInteger(mainValue);
      // Hungarian usually uses singular unit name regardless of number.
      String mainUnitName = currencyInfo.mainUnitSingular;
      result = '$mainText $mainUnitName';
    } else if (mainValue == BigInt.zero && subunitValue == BigInt.zero) {
      // Handle exactly 0.00.
      return "$_zero ${currencyInfo.mainUnitSingular}";
    }

    // Convert subunit value if > 0 and defined.
    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      String subunitText = _convertInteger(subunitValue);
      // Use singular subunit name.
      String subUnitName = currencyInfo.subUnitSingular!;
      String subunitPart = '$subunitText $subUnitName';

      // Combine parts.
      if (result.isNotEmpty) {
        // Typically just space-separated in Hungarian: "száz forint ötven fillér".
        result += ' $subunitPart';
      } else {
        // Only subunit part exists (e.g., 0.50).
        result = subunitPart;
      }
    } else if (result.isEmpty && subunitValue == BigInt.zero) {
      // This case means mainValue was 0, subunitValue is 0. Return "nulla [mainUnit]".
      return "$_zero ${currencyInfo.mainUnitSingular}";
    }

    return result;
  }

  /// Formats a non-negative standard [Decimal] number to Hungarian words.
  ///
  /// Converts integer and fractional parts. Uses the decimal separator word ("egész" or "pont")
  /// from [HuOptions]. Fractional part converted digit by digit.
  /// Handles the case where the integer part is zero ("nulla egész...").
  ///
  /// @param absValue Absolute decimal value.
  /// @param options The [HuOptions] for formatting control (decimal separator).
  /// @return Number as Hungarian words.
  String _handleStandardNumber(Decimal absValue, HuOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final int scale = absValue.scale; // Number of digits after decimal.

    // Convert the integer part.
    String integerWords = _convertInteger(integerPart);

    String fractionalWords = '';
    // Process fractional part only if it exists and the number isn't an integer (e.g., 123.0).
    if (scale > 0 && !absValue.isInteger) {
      // Determine separator word ("egész" or "pont"). Default to "egész".
      String separatorWord;
      switch (options.decimalSeparator ?? DecimalSeparator.comma) {
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          separatorWord = _point;
          break;
        case DecimalSeparator.comma:
          separatorWord = _comma;
          break;
      }

      // Get fractional digits string.
      String numberStr = absValue.toString();
      String fractionalDigitsStr =
          numberStr.contains('.') ? numberStr.split('.').last : '';

      // Remove trailing zeros for standard representation.
      fractionalDigitsStr = fractionalDigitsStr.replaceAll(RegExp(r'0+$'), '');

      // Convert remaining digits individually.
      if (fractionalDigitsStr.isNotEmpty) {
        List<String> digitWords = fractionalDigitsStr.split('').map((digit) {
          final int digitInt = int.parse(digit);
          // Use "nulla" for 0, _wordsUnder20 for 1-9.
          return (digitInt == 0 ? _zero : _wordsUnder20[digitInt]);
        }).toList();
        // Combine separator and digit words.
        fractionalWords =
            ' $separatorWord ${digitWords.join(' ')}'; // e.g., " egész öt hat", " pont nulla öt"
      }
    }

    // Combine parts. Handle integer zero case specifically.
    if (integerPart == BigInt.zero && fractionalWords.isNotEmpty) {
      // Prepend "nulla" if integer part is zero but fraction exists.
      return "$_zero$fractionalWords"; // e.g., "nulla egész öt"
    } else {
      // Standard combination or just integer part.
      return '$integerWords$fractionalWords'.trim();
    }
  }

  /// Converts an integer between 1 and 99 into Hungarian words.
  /// Handles compounding (e.g., "huszon-", "harmincegy").
  ///
  /// @param n The integer (1-99).
  /// @return The number as Hungarian text, or empty string if out of range.
  String _convertChunk1To99(int n) {
    if (n <= 0 || n >= 100) return "";

    if (n < 20) return _wordsUnder20[n]; // Direct lookup 1-19.

    final int tensDigit = n ~/ 10;
    final int units = n % 10;
    final String tensWord = _wordsTens[tensDigit]; // "húsz", "harminc", ...

    if (units == 0) {
      return tensWord; // Exact tens: "húsz", "harminc".
    } else {
      // Compound tens:
      if (tensDigit == 2) {
        // Special prefix "huszon" for 21-29.
        return "huszon${_wordsUnder20[units]}"; // "huszonegy", "huszonkettő".
      } else {
        // Other tens compound directly: "harminc"+"egy" -> "harmincegy".
        return "$tensWord${_wordsUnder20[units]}";
      }
    }
  }

  /// Converts an integer between 100 and 999 into Hungarian words.
  /// Handles compounding (e.g., "százegy", "kétszáz").
  ///
  /// @param n The integer (100-999).
  /// @return The number as Hungarian text, or empty string if out of range.
  String _convertChunk100To999(int n) {
    if (n < 100) {
      // Should be handled by caller, but delegate just in case.
      return (n > 0) ? _convertChunk1To99(n) : "";
    }
    if (n >= 1000) return ""; // Out of range.

    final int hundredsDigit = n ~/ 100;
    final int remainder = n % 100; // 0-99 part.

    String hundredsWord;
    if (hundredsDigit == 1) {
      hundredsWord = _hundredWord; // "száz"
    } else {
      // Use "két" for 200, standard digit word otherwise.
      final String hundredsPrefix =
          (hundredsDigit == 2) ? "két" : _wordsUnder20[hundredsDigit];
      hundredsWord = "$hundredsPrefix$_hundredWord"; // "kétszáz", "háromszáz".
    }

    if (remainder == 0) {
      return hundredsWord; // Just "száz", "kétszáz", etc.
    } else {
      // Compound hundreds word and remainder word directly.
      return "$hundredsWord${_convertChunk1To99(remainder)}"; // "százegy", "kétszázötvenhat".
    }
  }

  /// Converts an integer between 1 and 999 into Hungarian words.
  /// Dispatches to the appropriate helper (_convertChunk1To99 or _convertChunk100To999).
  ///
  /// @param n The integer (1-999).
  /// @return The number as Hungarian text, or empty string if 0 or out of range.
  String _convertChunk1To999(int n) {
    if (n <= 0 || n >= 1000) return "";
    if (n < 100) return _convertChunk1To99(n);
    return _convertChunk100To999(n);
  }

  /// Formats a number as a calendar year in Hungarian.
  ///
  /// Appends BC/AD suffixes based on sign and options.
  ///
  /// @param yearValue The absolute value of the year.
  /// @param isOriginalNegative True if the original year was negative.
  /// @param options The Hungarian options (for `includeAD`).
  /// @return The year formatted as Hungarian words.
  String _handleYearFormat(
      BigInt yearValue, bool isOriginalNegative, HuOptions options) {
    // Convert year using standard integer conversion (handles compounding/hyphenation).
    String yearText = _convertInteger(yearValue);

    // Append suffixes.
    if (isOriginalNegative) {
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD && yearValue > BigInt.zero) {
      // Only add AD if requested and year is positive.
      yearText += " $_yearSuffixAD";
    }
    return yearText;
  }
}
