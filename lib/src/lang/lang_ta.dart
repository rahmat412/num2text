import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ta_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ta}
/// The Tamil language (`Lang.TA`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Tamil word representation following standard Tamil grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [TaOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers using the
/// Indian numbering system (Lakh, Crore). It uses specific Tamil combining forms for numbers.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [TaOptions].
/// {@endtemplate}
class Num2TextTA implements Num2TextBase {
  /// Default word for decimal point ".". Tamil: "puḷḷi".
  static const String _pointWordDefault = "புள்ளி";

  /// Word for decimal comma ",". Tamil: "kāṟpuḷḷi".
  static const String _commaWord = "காற்புள்ளி";

  /// Word for zero. Tamil: "pūjjiyam".
  static const String _zero = "பூஜ்ஜியம்";

  /// Word for infinity. Tamil: "muṭivili".
  static const String _infinity = "முடிவிலி";

  /// Prefix for negative infinity. Tamil: "etirmaṟai".
  static const String _negativeInfinityPrefix = "எதிர்மறை";

  /// Word for "Not a Number". Tamil: "eṇ alla".
  static const String _nan = "எண் அல்ல";

  /// Suffix for AD/CE years. Tamil: "ki.pi." (kīṟistu piṟaku).
  static const String _yearSuffixAD = "கி.பி.";

  /// Suffix for BC years. Tamil: "ki.mu." (kīṟistu mun).
  static const String _yearSuffixBC = "கி.மு.";

  /// Default separator for currency. Tamil: "maṟṟum" (and).
  static const String _currencySeparator = "மற்றும்";

  /// Adjectival form of "one", used before nouns (like currency units). Tamil: "oru".
  static const String _oneAdjectival = "ஒரு";

  /// Map from Tamil number words (0-19) back to integers, used internally for combining logic.
  static final Map<String, int> _wordsToNumMap = {
    for (int i = 0; i < _wordsUnder20.length; i++) _wordsUnder20[i]: i,
    // Add other specific words if needed for reverse lookup
  };

  /// Words for numbers 0-19.
  static const List<String> _wordsUnder20 = [
    _zero, // 0
    "ஒன்று", // 1 - oṉṟu
    "இரண்டு", // 2 - iraṇṭu
    "மூன்று", // 3 - mūṉṟu
    "நான்கு", // 4 - nāṉku
    "ஐந்து", // 5 - aintu
    "ஆறு", // 6 - āṟu
    "ஏழு", // 7 - ēḻu
    "எட்டு", // 8 - eṭṭu
    "ஒன்பது", // 9 - oṉpatu
    "பத்து", // 10 - pattu
    "பதினொன்று", // 11 - patiṉoṉṟu
    "பன்னிரண்டு", // 12 - paṉṉiraṇṭu
    "பதிமூன்று", // 13 - patimūṉṟu
    "பதினான்கு", // 14 - patiṉāṉku
    "பதினைந்து", // 15 - patiṉaintu
    "பதினாறு", // 16 - patiṉāṟu
    "பதினேழு", // 17 - patiṉēḻu
    "பதினெட்டு", // 18 - patiṉeṭṭu
    "பத்தொன்பது", // 19 - pattoṉpatu
  ];

  /// Words for exact tens (20, 30,... 90).
  static const List<String> _wordsTens = [
    "", // 0 (unused)
    "", // 10 (unused)
    "இருபது", // 20 - irupatu
    "முப்பது", // 30 - muppatu
    "நாற்பது", // 40 - nāṟpatu
    "ஐம்பது", // 50 - aimpatu
    "அறுபது", // 60 - aṟupatu
    "எழுபது", // 70 - eḻupatu
    "எண்பது", // 80 - eṇpatu
    "தொண்ணூறு", // 90 - toṇṇūṟu
  ];

  /// Combining forms for tens (used before non-zero units).
  static const List<String> _wordsTensCombining = [
    "", // 0 (unused)
    "", // 10 (unused)
    "இருபத்தி", // 20+ - irupatti
    "முப்பத்தி", // 30+ - muppatti
    "நாற்பத்தி", // 40+ - nāṟpatti
    "ஐம்பத்தி", // 50+ - aimpatti
    "அறுபத்தி", // 60+ - aṟupatti
    "எழுபத்தி", // 70+ - eḻupatti
    "எண்பத்தி", // 80+ - eṇpatti
    "தொண்ணூற்றி", // 90+ - toṇṇūṟṟi
  ];

  /// Word for hundred. Tamil: "nūṟu".
  static const String _hundred = "நூறு";

  /// Words for exact hundreds (100, 200,... 900).
  static const Map<int, String> _hundredsMap = {
    1: _hundred, // 100
    2: "இருநூறு", // 200 - irunūṟu
    3: "முந்நூறு", // 300 - munnūṟu
    4: "நானூறு", // 400 - nānūṟu
    5: "ஐந்நூறு", // 500 - ainnūṟu
    6: "அறுநூறு", // 600 - aṟunūṟu
    7: "எழுநூறு", // 700 - eḻunūṟu
    8: "எண்ணூறு", // 800 - eṇṇūṟu
    9: "தொள்ளாயிரம்", // 900 - toḷḷāyiram
  };

  /// Combining forms for hundreds (used before non-zero tens/units).
  static const Map<int, String> _hundredsCombiningMap = {
    1: "நூற்றி", // 100+ - nūṟṟi
    2: "இருநூற்று", // 200+ - irunūṟṟu
    3: "முந்நூற்று", // 300+ - munnūṟṟu
    4: "நானூற்று", // 400+ - nānūṟṟu
    5: "ஐந்நூற்று", // 500+ - ainnūṟṟu
    6: "அறுநூற்று", // 600+ - aṟunūṟṟu
    7: "எழுநூற்று", // 700+ - eḻunūṟṟu
    8: "எண்ணூற்று", // 800+ - eṇṇūṟṟu
    9: "தொள்ளாயிரத்து", // 900+ - toḷḷāyirattu
  };

  /// Word for thousand. Tamil: "āyiram".
  static const String _thousand = "ஆயிரம்";

  /// Combining suffix for 1000 when followed by units/tens (but not hundreds). Tamil: "āyiratti".
  static const String _thousandCombiningOneSuffix = "ஆயிரத்தி";

  /// General combining suffix for 1000 (and multiples) when followed by hundreds. Tamil: "āyirattu".
  static const String _thousandCombiningGeneralSuffix = "ஆயிரத்து";

  /// Words for exact thousands (1000, 2000,... 10000).
  static const Map<int, String> _exactThousandMap = {
    1: _thousand, // 1000
    2: "இரண்டாயிரம்", // 2000 - iraṇṭāyiram
    3: "மூவாயிரம்", // 3000 - mūvāyiram
    4: "நான்காயிரம்", // 4000 - nāṉkāyiram
    5: "ஐயாயிரம்", // 5000 - aiyāyiram
    6: "ஆறாயிரம்", // 6000 - āṟāyiram
    7: "ஏழாயிரம்", // 7000 - ēḻāyiram
    8: "எண்ணாயிரம்", // 8000 - eṇṇāyiram
    9: "ஒன்பதாயிரம்", // 9000 - oṉpatāyiram
    10: "பத்தாயிரம்", // 10000 - pattāyiram
  };

  /// Combining forms for thousands (2000+, 3000+,... 10000+). Used before hundreds/tens/units.
  static const Map<int, String> _combiningThousandMap = {
    // Note: 1000 uses specific suffixes _thousandCombiningOneSuffix or _thousandCombiningGeneralSuffix
    2: "இரண்டாயிரத்து", // 2000+ - iraṇṭāyirattu
    3: "மூவாயிரத்து", // 3000+ - mūvāyirattu
    4: "நான்காயிரத்து", // 4000+ - nāṉkāyirattu
    5: "ஐயாயிரத்து", // 5000+ - aiyāyirattu
    6: "ஆறாயிரத்து", // 6000+ - āṟāyirattu
    7: "ஏழாயிரத்து", // 7000+ - ēḻāyirattu
    8: "எண்ணாயிரத்து", // 8000+ - eṇṇāyirattu
    9: "ஒன்பதாயிரத்து", // 9000+ - oṉpatāyirattu
    10: "பத்தாயிரத்து", // 10000+ - pattāyirattu
  };

  /// Word for Lakh (100,000). Tamil: "laṭcam".
  static const String _lakh = "லட்சம்";

  /// Combining form for Lakh. Tamil: "laṭcattu".
  static const String _lakhCombining = "லட்சத்து";

  /// Word for Crore (10,000,000). Tamil: "kōṭi".
  static const String _crore = "கோடி";

  /// Combining form for Crore. Tamil: "kōṭiyē".
  static const String _croreCombining = "கோடியே";

  // --- BigInt constants for scale calculations ---
  static final BigInt _bigZero = BigInt.zero;
  static final BigInt _bigOne = BigInt.one;
  static final BigInt _big100 = BigInt.from(100);
  static final BigInt _big1000 = BigInt.from(1000);
  static final BigInt _big100000 = BigInt.from(100000); // Lakh
  static final BigInt _big10000000 = BigInt.from(10000000); // Crore
  static final BigInt _bigCroreCrore = _big10000000 * _big10000000; // 10^14
  static final BigInt _bigLakhCroreCrore = _big100000 * _bigCroreCrore; // 10^19
  static final BigInt _bigCroreCroreCrore =
      _big10000000 * _bigCroreCrore; // 10^21

  /// Processes the given [number] and converts it into Tamil words.
  ///
  /// This is the main entry point for the Tamil conversion.
  /// - Normalizes the input [number].
  /// - Handles special cases like zero, infinity, NaN.
  /// - Manages the negative sign using [TaOptions.negativePrefix].
  /// - Delegates based on [options]: [_handleYearFormat], [_handleCurrency], [_handleStandardNumber].
  /// - Returns the final word representation or fallback error message.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have Tamil-specific options, using defaults if none are provided.
    final TaOptions taOptions =
        options is TaOptions ? options : const TaOptions();

    // Handle special double values before normalization.
    if (number is double) {
      if (number.isInfinite) {
        // Handle infinity, prepending negative prefix if needed.
        return number.isNegative
            ? "$_negativeInfinityPrefix $_infinity"
            : _infinity;
      }
      if (number.isNaN) return fallbackOnError ?? _nan; // Handle NaN
    }

    // Normalize the input number to Decimal for precision.
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null)
      return fallbackOnError ?? _nan; // Handle normalization failure

    // Handle the specific case of zero.
    if (decimalValue == Decimal.zero) {
      if (taOptions.currency) {
        // For currency, use "zero" and the main unit name (plural fallback).
        final String mainUnit = taOptions.currencyInfo.mainUnitPlural ??
            taOptions.currencyInfo.mainUnitSingular;
        return "$_zero $mainUnit";
      } else {
        // Otherwise, just return "zero".
        return _zero;
      }
    }

    // Determine sign and work with the absolute value.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Delegate based on the format specified in options.
    if (taOptions.format == Format.year) {
      // Handle year formatting (may include BC/AD suffixes).
      textResult = _convertInteger(absValue.truncate().toBigInt());
      if (isNegative) {
        textResult += " $_yearSuffixBC"; // Append BC suffix
      } else if (taOptions.includeAD) {
        // Renamed includeAD to includeAD internally
        textResult += " $_yearSuffixAD"; // Append AD/CE suffix if requested
      }
    } else {
      // Handle non-year formats (currency or standard number).
      if (taOptions.currency) {
        textResult = _handleCurrency(absValue, taOptions);
      } else {
        textResult = _handleStandardNumber(absValue, taOptions);
      }
      // Prepend the negative prefix if the original number was negative.
      if (isNegative) {
        textResult = "${taOptions.negativePrefix} $textResult";
      }
    }
    return textResult.trim(); // Trim final result.
  }

  /// Formats the absolute [absValue] as Tamil currency.
  ///
  /// Uses [CurrencyInfo] from [options].
  /// Uses the adjectival form "oru" for one unit/subunit.
  /// Converts main and subunit values using [_convertInteger].
  /// Joins parts with the separator from [CurrencyInfo] or "மற்றும்".
  String _handleCurrency(Decimal absValue, TaOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final Decimal subunitMultiplier =
        Decimal.fromInt(100); // Assume 100 subunits.

    Decimal valueToConvert = absValue; // No rounding specified in options yet.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Round subunit value to nearest integer.
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round(scale: 0).toBigInt();

    // Use adjectival "oru" if main value is 1, otherwise convert normally.
    String mainText =
        (mainValue == _bigOne) ? _oneAdjectival : _convertInteger(mainValue);
    // Get singular or plural form of main unit.
    String mainUnitName = (mainValue == _bigOne)
        ? currencyInfo.mainUnitSingular
        : currencyInfo.mainUnitPlural ??
            currencyInfo.mainUnitSingular; // Fallback to singular

    String result =
        '$mainText $mainUnitName'; // e.g., "ஒரு ரூபாய்", "நூறு ரூபாய்"

    // Add subunit part if it exists.
    if (subunitValue > _bigZero) {
      // Use adjectival "oru" if subunit value is 1.
      String subunitText = (subunitValue == _bigOne)
          ? _oneAdjectival
          : _convertInteger(subunitValue);
      // Get singular or plural form of subunit.
      String subUnitName = (subunitValue == _bigOne)
          ? currencyInfo.subUnitSingular! // Assume non-null if subunit exists
          : currencyInfo.subUnitPlural ??
              currencyInfo.subUnitSingular!; // Fallback

      // Get separator ("மற்றும்" or custom).
      final String separator = currencyInfo.separator ?? _currencySeparator;
      result +=
          ' $separator $subunitText $subUnitName'; // e.g., " மற்றும் ஐம்பது பைசா"
    }

    return result;
  }

  /// Formats the absolute [absValue] as a standard Tamil cardinal number.
  ///
  /// Handles integer and fractional parts. Converts integer part using [_convertInteger].
  /// Converts fractional part digit by digit, joined by spaces, prefixed by the
  /// decimal separator word ("புள்ளி" or "காற்புள்ளி"). Trims trailing zeros from decimals.
  String _handleStandardNumber(Decimal absValue, TaOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Handle 1000 exactly as "ஆயிரம்".
    if (integerPart == _big1000 && fractionalPart == Decimal.zero) {
      return _thousand;
    }

    // Convert integer part (use "zero" if integer is 0 but fractional exists).
    String integerWords =
        (integerPart == _bigZero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    String fractionalWords = '';
    // Process fractional part if it exists.
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word based on options.
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _commaWord;
          break;
        default: // Includes period, point, null
          separatorWord = _pointWordDefault;
          break;
      }
      // Get fractional digits as string.
      String fractionalDigits = absValue.toString().split('.').last;

      // Find the last non-zero digit to trim trailing zeros.
      int lastNonZero = fractionalDigits.length - 1;
      while (lastNonZero >= 0 && fractionalDigits[lastNonZero] == '0') {
        lastNonZero--;
      }

      // Only add fractional words if there are non-zero digits after trimming.
      if (lastNonZero >= 0) {
        fractionalDigits = fractionalDigits.substring(0, lastNonZero + 1);
        // Convert each digit character to its word form.
        List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder20[digitInt] // Use words 0-9
              : '?'; // Handle unexpected characters
        }).toList();
        // Combine separator and digit words.
        fractionalWords =
            ' $separatorWord ${digitWords.join(' ')}'; // e.g., " புள்ளி ஐந்து பூஜ்யம்" -> " புள்ளி ஐந்து"
      }
    } else if (integerPart > _bigZero &&
        absValue.scale > 0 &&
        absValue.isInteger) {
      // Handle cases like Decimal.parse("1.0") - no fractional words needed.
    }

    return '$integerWords$fractionalWords'.trim(); // Combine parts and trim.
  }

  /// Converts a non-negative [BigInt] [n] into its Tamil word representation using the Indian numbering system.
  ///
  /// Breaks the number down by scales (Crore Crore Crore, Lakh Crore Crore, Crore Crore, Crore, Lakh, Thousand).
  /// Recursively calls itself or [_convertBelowThousand] to convert parts.
  /// Uses specific combining forms for scale words (e.g., "kōṭiyē", "laṭcattu", "āyiratti").
  String _convertInteger(BigInt n) {
    if (n < _bigZero) {
      throw ArgumentError("Input must be non-negative for _convertInteger: $n");
    }
    if (n == _bigZero) return _zero; // Base case: Zero

    // Handle 1000 exactly.
    if (n == _big1000) return _thousand;

    List<String> parts = []; // Stores word chunks for each scale.
    BigInt remaining = n; // The part of the number yet to be processed.

    // Define Indian numbering system scales and their combining forms.
    final scales = [
      // Define scales from largest to smallest for processing.
      {
        'divider': _bigCroreCroreCrore,
        'name': "கோடி கோடி கோடி",
        'combining': "கோடியே கோடி கோடி",
      }, // 10^21
      {
        'divider': _bigLakhCroreCrore, // 10^19
        'name': "லட்சம் கோடி கோடி",
        'combining': "லட்சத்து கோடி கோடி",
      },
      {
        'divider': _bigCroreCrore,
        'name': "கோடி கோடி",
        'combining': "கோடியே கோடி"
      }, // 10^14
      {
        'divider': _big10000000,
        'name': _crore,
        'combining': _croreCombining
      }, // 10^7 (Crore)
      {
        'divider': _big100000,
        'name': _lakh,
        'combining': _lakhCombining
      }, // 10^5 (Lakh)
    ];

    // Process scales from Crore Crore Crore down to Lakh.
    for (var scale in scales) {
      final BigInt divider = scale['divider'] as BigInt;
      if (remaining >= divider) {
        BigInt count = remaining ~/ divider; // How many times this scale fits.
        BigInt currentRemainder =
            remaining % divider; // Remainder after this scale.

        // Recursively convert the count for this scale.
        String countText = _convertInteger(count);

        String scaleUnit;
        // Determine whether to use the combining form or the exact name.
        if (currentRemainder > _bigZero) {
          // Use combining form if there's a remainder.
          scaleUnit = scale['combining'] as String? ?? scale['name'] as String;
          // Special case: Use adjectival "oru" for 1 before combining forms, except maybe crore?
          if (count == _bigOne) {
            countText = _oneAdjectival;
            // Apply specific combining forms like "kōṭiyē", "laṭcattu" when count is one.
            if (scale['name'] == _crore) {
              scaleUnit = _croreCombining;
            } else if (scale['name'] == _lakh) {
              scaleUnit = _lakhCombining;
            }
            // For larger combined scales, the combining form might already be correct.
            // else { scaleUnit = scale['name'] as String; } // Reverts to non-combining if needed
          }
        } else {
          // Use exact name if there's no remainder.
          scaleUnit = scale['name'] as String;
          // Use adjectival "oru" for 1 before exact scale names.
          if (count == _bigOne) {
            countText = _oneAdjectival;
          }
        }
        // Add the formatted chunk (e.g., "oru kōṭiyē", "nūṟu laṭcam").
        parts.add("$countText $scaleUnit");
        // Update the remaining value for the next smaller scale.
        remaining %= divider;
      }
    }

    // --- Handle Thousands ---
    BigInt thousands = remaining ~/ _big1000; // Calculate thousands part.
    BigInt currentRemainder = remaining % _big1000; // Remainder < 1000.

    if (thousands > _bigZero) {
      String thousandPart = "";
      int thousandsInt = 0;
      // Check if the thousands count fits within a standard int for map lookups.
      bool thousandsFitsInt =
          thousands <= BigInt.from(0x7FFFFFFFFFFFFFFF); // Max 64-bit signed int
      if (thousandsFitsInt) {
        thousandsInt = thousands.toInt();
      }

      if (thousands == _bigOne) {
        // Case: Exactly 1000 or 1000 + remainder
        if (currentRemainder == _bigZero) {
          thousandPart = _thousand; // "ஆயிரம்"
        } else if (currentRemainder < _big100) {
          // If remainder is < 100, use "ஆயிரத்தி" + unit/ten
          thousandPart = _thousandCombiningOneSuffix; // e.g., "ஆயிரத்தி ஐந்து"
        } else {
          // If remainder is >= 100, use "ஆயிரத்து" + hundred/etc.
          thousandPart =
              _thousandCombiningGeneralSuffix; // e.g., "ஆயிரத்து நூறு"
        }
      } else {
        // Case: Multiple thousands (2000, 3000, ..., 1 lakh etc.)
        if (currentRemainder == _bigZero) {
          // Subcase: Exact multiple of thousand (2000, 10000)
          if (thousandsFitsInt && _exactThousandMap.containsKey(thousandsInt)) {
            // Use specific word if available (e.g., "இரண்டாயிரம்", "பத்தாயிரம்").
            thousandPart = _exactThousandMap[thousandsInt]!;
          } else {
            // Otherwise, convert the count and append "ஆயிரம்".
            thousandPart =
                "${_convertInteger(thousands)} $_thousand"; // e.g., "இருபது ஆயிரம்"
          }
        } else {
          // Subcase: Multiple thousands + remainder (2105, 10500)
          String thousandsText =
              _convertInteger(thousands); // Convert the thousands count.
          String? specificCombiningForm;

          // Check if a specific combining form exists (e.g., "இரண்டாயிரத்து").
          if (thousandsFitsInt &&
              _combiningThousandMap.containsKey(thousandsInt)) {
            specificCombiningForm = _combiningThousandMap[thousandsInt]!;
          }
          // Fallback: Try to build combining form from parts if needed (complex case).
          // Example: "இருபத்தி இரண்டாயிரத்து" - check last part of thousandsText.
          else if (thousandsText.contains(' ')) {
            var words = thousandsText.split(' ');
            var lastWord = words.last;
            if (_wordsToNumMap.containsKey(lastWord)) {
              var lastNum =
                  _wordsToNumMap[lastWord]!; // Get number value of last word
              if (_combiningThousandMap.containsKey(lastNum)) {
                // Replace last word with its combining thousand form.
                words[words.length - 1] = _combiningThousandMap[lastNum]!;
                specificCombiningForm = words.join(' ');
              }
            }
          }

          // Use the specific combining form if found, otherwise use the general suffix.
          if (specificCombiningForm != null) {
            thousandPart = specificCombiningForm;
          } else {
            // Default to "X ஆயிரத்து".
            thousandPart = "$thousandsText $_thousandCombiningGeneralSuffix";
          }
        }
      }
      parts.add(thousandPart); // Add the processed thousand part.
      remaining =
          currentRemainder; // Update remaining for the final < 1000 part.
    }

    // --- Handle Final Remainder < 1000 ---
    if (remaining > _bigZero) {
      if (remaining <= BigInt.from(999)) {
        // Convert the final 0-999 part.
        parts.add(_convertBelowThousand(remaining.toInt()));
      } else {
        // This state should not be reached if logic is correct.
        throw StateError(
            "Invalid remaining state in _convertInteger: $remaining");
      }
    }

    // Join all collected parts, filtering out any empty strings (shouldn't occur).
    return parts.where((part) => part.isNotEmpty).join(' ');
  }

  /// Converts an integer [n] between 0 and 999 into Tamil words.
  /// Handles hundreds place and the remaining 0-99 part using [_convertBelowHundred].
  /// Uses specific combining forms for hundreds.
  String _convertBelowThousand(int n) {
    if (n == 0) return ""; // Return empty for zero.
    if (n < 0 || n > 999) {
      throw ArgumentError(
          "Number must be between 0 and 999 for _convertBelowThousand: $n");
    }

    List<String> words = [];
    int hundredDigit = n ~/ 100; // Get hundreds digit (0-9).
    int remainder = n % 100; // Get remainder (0-99).

    // Process hundreds place.
    if (hundredDigit > 0) {
      if (remainder == 0) {
        // If remainder is 0, use the exact hundreds word (e.g., "நூறு", "இருநூறு").
        words.add(_hundredsMap[hundredDigit]!);
      } else {
        // If remainder exists, use the combining hundreds form (e.g., "நூற்றி", "இருநூற்று").
        words.add(_hundredsCombiningMap[hundredDigit]!);
      }
    }

    // Process the remaining 0-99 part.
    if (remainder > 0) {
      words.add(_convertBelowHundred(remainder));
    }

    // Join the parts (hundreds and tens/units) with a space.
    return words.join(' ');
  }

  /// Converts an integer [n] between 0 and 99 into Tamil words.
  /// Handles 0-19 directly, combines tens and units for 20-99 using specific combining forms.
  String _convertBelowHundred(int n) {
    if (n == 0) return ""; // Return empty for zero.
    if (n < 0 || n >= 100)
      throw ArgumentError("Number must be between 0 and 99: $n");

    // Handle 0-19 directly using the lookup table.
    if (n < 20) return _wordsUnder20[n];

    // Handle 20-99.
    int tenDigit = n ~/ 10; // Get tens digit (2-9).
    int unitDigit = n % 10; // Get units digit (0-9).

    if (unitDigit == 0) {
      // If unit is 0, use the exact tens word (e.g., "இருபது").
      return _wordsTens[tenDigit];
    } else {
      // If unit is non-zero, use the combining tens form + unit word.
      // e.g., "இருபத்தி" + " " + "ஒன்று" -> "இருபத்தி ஒன்று"
      return "${_wordsTensCombining[tenDigit]} ${_wordsUnder20[unitDigit]}";
    }
  }
}
