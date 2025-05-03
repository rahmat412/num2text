import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ne_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ne}
/// Converts numbers to Nepali words (`Lang.NE`).
///
/// Implements [Num2TextBase] for Nepali, handling various numeric types.
/// Supports cardinal numbers, decimals, negatives, currency, and years.
/// Uses the Nepali numbering system (Lakh, Crore, Arab, Kharb, etc.) with 3,2,2,... grouping.
/// Customizable via [NeOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextNE implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "शून्य"; // "zero"
  static const String _point = "दशमलव"; // Decimal separator "."
  static const String _comma = "अल्पविराम"; // Decimal separator ","
  static const String _hundred = "सय"; // "hundred"
  static const String _yearSuffixAD = "ईस्वी"; // AD/CE suffix
  static const String _yearSuffixBC = "ई.पू."; // BC/BCE suffix
  static const String _infinity = "अनन्त"; // "Infinity"
  static const String _nan = "संख्या होइन"; // "Not a Number"

  /// Pre-defined words for numbers 0-99.
  static const List<String> _wordsUnder100 = [
    "शून्य", "एक", "दुई", "तीन", "चार", "पाँच", "छ", "सात", "आठ", "नौ", "दस",
    "एघार", "बाह्र", "तेह्र", "चौध", "पन्ध्र", "सोह्र", "सत्र", "अठार",
    "उन्नाइस", "बीस",
    "एक्काइस", "बाइस", "तेइस", "चौबीस", "पच्चीस", "छब्बीस", "सत्ताइस",
    "अठ्ठाइस", "उनतीस", "तीस",
    "एकतीस", "बत्तीस", "तेत्तीस", "चौँतीस", "पैँतीस", "छत्तीस", "सैँतीस",
    "अठतीस", "उनचालीस",
    "चालीस",
    "एकचालीस", "बयालीस", "त्रिचालीस", "चवालीस", "पैंतालिस", "छयालीस", "सतचालीस",
    "अठचालीस", "उनचास",
    "पचास",
    "एकाउन्न", "बाउन्न", "त्रिपन्न", "चौवन्न", "पचपन्न", "छपन्न", "सन्ताउन्न",
    "अन्ठाउन्न",
    "उनसाठी", "साठी",
    "एकसट्ठी", "बयसट्ठी", "त्रिसट्ठी", "चौसट्ठी", "पैँसट्ठी", "छयसट्ठी",
    "सड्सठी", "अठसठ्ठी",
    "उनसत्तरी", "सत्तरी",
    "एकहत्तर", "बहत्तर", "त्रिहत्तर", "चौहत्तर", "पचहत्तर", "छयहत्तर",
    "सतहत्तर", "अठहत्तर",
    "उनासी", "असी",
    "एकासी", "बयासी", "त्रियासी", "चौरासी", "पचासी", "छयासी", "सतासी", "अठासी",
    "उनान्नब्बे",
    "नब्बे",
    "एकानब्बे", "बयानब्बे", "त्रियानब्बे", "चौरानब्बे", "पन्चानब्बे",
    "छयानब्बे", "सन्तानब्बे",
    "अन्ठानब्बे", "उनान्सय", // 99
  ];

  // Note: _scales list was removed as it wasn't used in the provided code.
  // The logic in _convertInteger uses a hardcoded list of scale names.

  /// {@macro num2text_base_process}
  /// Converts the given [number] into Nepali words.
  ///
  /// Handles `int`, `double`, `BigInt`, `Decimal`, and numeric `String`.
  /// Uses [NeOptions] for customization (currency, year format, decimals, AD/BC).
  /// Returns [fallbackOnError] or a default error message on failure.
  ///
  /// @param number The number to convert.
  /// @param options Optional [NeOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Nepali words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final NeOptions neOptions =
        options is NeOptions ? options : const NeOptions();
    final String errorFallback = fallbackOnError ?? _nan;

    if (number is double) {
      if (number.isInfinite) {
        String prefix =
            number.isNegative ? ("${neOptions.negativePrefix.trim()} ") : "";
        return "$prefix$_infinity";
      }
      if (number.isNaN) return errorFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    if (decimalValue == Decimal.zero) {
      if (neOptions.currency) {
        // e.g., "शून्य रुपैयाँ"
        return "${_zero.trim()} ${neOptions.currencyInfo.mainUnitSingular.trim()}";
      } else {
        return _zero; // Standard "शून्य"
      }
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    // --- Dispatch based on format ---
    if (neOptions.format == Format.year) {
      // Year format handles negativity (BC suffix) internally.
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), neOptions);
    } else {
      if (neOptions.currency) {
        textResult = _handleCurrency(absValue, neOptions);
      } else {
        textResult = _handleStandardNumber(absValue, neOptions);
      }
      // Apply negative prefix for non-year formats.
      if (isNegative) {
        String prefix = neOptions.negativePrefix.trim();
        textResult = "$prefix $textResult";
      }
    }
    return textResult.trim(); // Ensure no leading/trailing spaces.
  }

  /// Converts an integer year to Nepali words, applying specific rules and suffixes.
  ///
  /// - Years 1100-1999 are formatted like "nineteen hundred ninety-nine".
  /// - Other years use standard cardinal conversion.
  /// - Appends BC/AD suffixes based on sign and options.
  ///
  /// @param year The integer year (can be negative for BC).
  /// @param options Checks `includeAD` option.
  /// @return The year in Nepali words (e.g., "उन्नाइस सय उनान्सय", "पाँच सय ई.पू.").
  String _handleYearFormat(int year, NeOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;

    if (absYear == 0) return _zero; // Year 0 is "शून्य".

    String yearText;
    // Specific handling for years 1100-1999 ("X सय Y").
    if (absYear >= 1100 && absYear < 2000) {
      int hundredsPart = absYear ~/ 100; // e.g., 19
      int remainder = absYear % 100; // e.g., 99
      yearText =
          "${_convertUnder100(hundredsPart)} $_hundred"; // e.g., "उन्नाइस सय"
      if (remainder > 0) {
        yearText += " ${_convertUnder100(remainder)}"; // e.g., " उनान्सय"
      }
    } else {
      // Standard conversion for other years.
      yearText = _convertInteger(BigInt.from(absYear));
    }

    // Append suffixes.
    if (isNegative) {
      yearText += " $_yearSuffixBC"; // Always add "ई.पू." for negative.
    } else if (options.includeAD) {
      yearText += " $_yearSuffixAD"; // Add "ईस्वी" only if option is set.
    }

    return yearText;
  }

  /// Converts a non-negative [BigInt] integer into Nepali words using the 3,2,2,... grouping.
  ///
  /// Processes the number by taking the last 3 digits, then groups of 2 digits for
  /// Hajar, Lakh, Crore, Arab, etc.
  ///
  /// @param n The non-negative integer.
  /// @return The integer as Nepali words.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero) {
      // Internal safeguard; negativity handled in `process`.
      throw ArgumentError(
          "Internal error: Cannot convert negative integer directly.");
    }
    if (n == BigInt.zero) return _zero;

    final List<String> parts = []; // Stores words for each scale part.
    final BigInt thousand = BigInt.from(1000);
    final BigInt hundred = BigInt.from(100);

    // --- Step 1: Handle the last 3 digits (0-999) ---
    final int under1000Part = (n % thousand).toInt();
    if (under1000Part > 0) {
      parts.add(_convertUnder1000(under1000Part));
    }
    n = n ~/ thousand; // Move past the initial 3 digits.

    // --- Step 2: Define scale names (Hajar, Lakh, Crore...) ---
    // Order matches increasing powers with 2-digit grouping (10^3, 10^5, ...).
    final List<String> scaleNames = [
      "हजार", "लाख", "करोड", "अर्ब", "खर्ब", "नील", "पद्म", "शंख", "महाशंख",
      "जल्ध", "मध्य",
      "परार्ध" // Added more scales
    ];
    int scaleIndex = 0;

    // --- Step 3: Process higher scales in groups of 2 digits ---
    while (n > BigInt.zero) {
      final int chunk = (n % hundred).toInt(); // Get the next 2-digit chunk.

      if (chunk > 0) {
        if (scaleIndex >= scaleNames.length) {
          // Safeguard if number exceeds defined scales.
          parts.insert(
              0, _convertUnder100(chunk)); // Add chunk without scale name.
          break;
        }
        final String chunkText =
            _convertUnder100(chunk); // Convert the 2-digit chunk.
        final String scaleName =
            scaleNames[scaleIndex]; // Get the corresponding scale name.
        // Insert "chunkText scaleName" at the beginning to build the result correctly.
        parts.insert(0, "$chunkText $scaleName");
      }

      n = n ~/ hundred; // Move to the next 2 digits.
      scaleIndex++; // Move to the next scale name.
    }

    // --- Step 4: Join parts ---
    // Result is built from highest scale down to the initial under-1000 part.
    return parts.join(" ").trim();
  }

  /// Converts an integer from 0 to 999 into Nepali words.
  /// Handles hundreds correctly (e.g., "एक सय", "दुई सय").
  ///
  /// @param m The integer (0-999).
  /// @return The number as Nepali words. Returns empty string if m is 0.
  String _convertUnder1000(int m) {
    if (m < 0 || m >= 1000) throw ArgumentError("Number must be 0-999: $m");
    if (m == 0) return ""; // Zero within a larger number contributes nothing.

    if (m < 100) {
      return _convertUnder100(m); // Use the direct lookup for 0-99.
    } else {
      final int h = m ~/ 100; // Hundreds digit.
      final int r = m % 100; // Remainder (0-99).
      // Use "एक" for 100, convert digit otherwise.
      final String hundredPrefix =
          (h == 1) ? _wordsUnder100[1] : _convertUnder100(h);
      String text = "$hundredPrefix $_hundred"; // e.g., "एक सय", "दुई सय"
      if (r > 0) {
        text += " ${_convertUnder100(r)}"; // Add remainder if non-zero.
      }
      return text;
    }
  }

  /// Converts a non-negative [Decimal] to Nepali currency words (Rupees and Paisa).
  ///
  /// Uses [NeOptions.currencyInfo]. Rounds to 2 decimal places.
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Nepali words.
  String _handleCurrency(Decimal absValue, NeOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final Decimal subunitMultiplier =
        Decimal.fromInt(100); // 100 Paisa = 1 Rupee.

    // Round to 2 decimal places for currency.
    final Decimal roundedValue = absValue.round(scale: 2);

    final BigInt mainValue = roundedValue.truncate().toBigInt(); // Rupees
    // Calculate paisa carefully after rounding.
    final BigInt subunitValue =
        (roundedValue.remainder(Decimal.one).abs() * subunitMultiplier)
            .round(scale: 0)
            .toBigInt();

    String mainText = "";
    String subUnitText = "";

    // Convert Rupees part.
    if (mainValue > BigInt.zero) {
      // Trim potential spaces from currency unit names.
      mainText =
          "${_convertInteger(mainValue)} ${currencyInfo.mainUnitSingular.trim()}";
    }

    // Convert Paisa part.
    if (subunitValue > BigInt.zero) {
      final subUnitName = currencyInfo.subUnitSingular?.trim() ?? '';
      if (subUnitName.isNotEmpty) {
        subUnitText = "${_convertInteger(subunitValue)} $subUnitName";
      }
    }

    // Combine parts using separator "र" if both exist.
    if (mainText.isNotEmpty && subUnitText.isNotEmpty) {
      final separator =
          currencyInfo.separator?.trim() ?? 'र'; // Default separator "र".
      return "$mainText $separator $subUnitText";
    } else if (mainText.isNotEmpty) {
      return mainText; // Only Rupees.
    } else if (subUnitText.isNotEmpty) {
      return subUnitText; // Only Paisa.
    } else {
      // Case of 0.00 after rounding.
      return "$_zero ${currencyInfo.mainUnitSingular.trim()}";
    }
  }

  /// Converts a non-negative standard [Decimal] number to Nepali words.
  ///
  /// Handles integer and fractional parts. Fractional part read digit by digit.
  /// Removes trailing zeros from the fractional part before converting.
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Used for `decimalSeparator`.
  /// @return Number as Nepali words.
  String _handleStandardNumber(Decimal absValue, NeOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart =
        (absValue - Decimal.fromBigInt(integerPart)).abs();

    // Convert integer part. Use "शून्य" if integer is 0 but fraction exists (e.g., 0.5).
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    // Process fractional part if it exists.
    if (fractionalPart > Decimal.zero) {
      String separatorWord =
          (options.decimalSeparator == DecimalSeparator.comma)
              ? _comma
              : _point; // Default to "दशमलव".

      // Get fractional digits string.
      String fractionalDigits = absValue.toString().split('.').last;

      // Remove trailing zeros (e.g., 1.50 -> 1.5 -> "एक दशमलव पाँच").
      fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      // Convert remaining digits individually.
      if (fractionalDigits.isNotEmpty) {
        List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _convertUnder100(digitInt) // Use lookup for 0-9
              : '?'; // Fallback
        }).toList();
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
      // If removing zeros left nothing, fractionalWords remains empty.
    }

    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts an integer from 0 to 99 into its Nepali word using the lookup table.
  ///
  /// @param n The integer (0-99).
  /// @throws ArgumentError if n is out of range.
  /// @return The corresponding Nepali word.
  String _convertUnder100(int n) {
    if (n < 0 || n >= 100) {
      throw ArgumentError("Number must be between 0 and 99: $n");
    }
    return _wordsUnder100[n];
  }
}
