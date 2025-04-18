import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/si_options.dart';
import '../utils/utils.dart';

/// {@template num2text_si}
/// The Sinhala language (`Lang.SI`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Sinhala word representation following standard Sinhala grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [SiOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (including
/// the Indian numbering system concepts like Lakh for 100,000, Million, Billion etc. up to Septillion).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [SiOptions].
/// {@endtemplate}
class Num2TextSI implements Num2TextBase {
  // --- Core Number Words ---

  /// The word for zero.
  static const String _zero = "බිංදුව";

  /// The words for digits 1-9. Index 0 is unused.
  static const List<String> _units = [
    "", // 0 - unused
    "එක", // 1
    "දෙක", // 2
    "තුන", // 3
    "හතර", // 4
    "පහ", // 5
    "හය", // 6
    "හත", // 7
    "අට", // 8
    "නවය", // 9
  ];

  /// The words for numbers 10-19.
  static const List<String> _teens = [
    "දහය", // 10
    "එකොළහ", // 11
    "දොළහ", // 12
    "දහතුන", // 13
    "දාහතර", // 14
    "පහළොව", // 15
    "දහසය", // 16
    "දහහත", // 17
    "දහඅට", // 18
    "දහනවය", // 19
  ];

  /// The prefixes used for tens (20, 30,... 90) when followed by a unit digit (e.g., "විසි" in "විසිඑක").
  /// Index 0 and 1 are unused.
  static const List<String> _tensPrefix = [
    "", // 0 - unused
    "", // 10 - unused (covered by teens)
    "විසි", // 20
    "තිස්", // 30
    "හතලිස්", // 40
    "පනස්", // 50
    "හැට", // 60
    "හැත්තෑ", // 70
    "අසූ", // 80
    "අනූ", // 90
  ];

  /// The words for exact tens (20, 30,... 90).
  /// Index 0 and 1 are unused.
  static const List<String> _exactTens = [
    "", // 0 - unused
    "", // 10 - unused (covered by teens)
    "විස්ස", // 20
    "තිහ", // 30
    "හතළිහ", // 40
    "පනහ", // 50
    "හැට", // 60
    "හැත්තෑව", // 70
    "අසූව", // 80
    "අනූව", // 90
  ];

  // --- Combined Forms & Suffixes ---

  /// Suffix for exact hundreds (e.g., "එකසියය").
  static const String _hundredSingularSuffix = "සියය";

  /// Suffix for hundreds when combined with tens/units (e.g., "එකසිය").
  static const String _hundredCombinedSuffix = "සිය";

  /// Word for one thousand when it's the exact number or part of a larger construct like Lakhs.
  static const String _thousandSingular = "දහස";

  /// Word for thousand when combined with other parts (e.g., "දෙ දහස්").
  static const String _thousandCombined = "දහස්";

  /// Word for one Lakh (100,000) when it's the exact number.
  static const String _lakhSingular = "ලක්ෂය";

  /// Word for Lakh when combined with other parts (e.g., "දෙ ලක්ෂ").
  static const String _lakhCombined = "ලක්ෂ";

  /// Combined form for "one" used before hundred/lakh/etc. (e.g., "එකසිය").
  static const String _unitOneCombined = "එක";

  /// Combined form for "two" used before hundred/lakh/etc. (e.g., "දෙසිය").
  static const String _unitTwoCombined = "දෙ";

  /// Combined form for "one" used before thousand (e.g., "එක් දහස").
  static const String _unitOneThousandCombined = "එක්";

  /// Combined form for "two" used before thousand (e.g., "දෙ දහස").
  static const String _unitTwoThousandCombined = "දෙ";

  /// Combined forms for 3-9 used before hundred/lakh (e.g., "තුන්සිය").
  /// Index 0, 1, 2 are unused.
  static const List<String> _unitsHundredCombined = [
    "", // 0
    "", // 1
    "", // 2
    "තුන්", // 3
    "හාර", // 4
    "පන්", // 5
    "හ", // 6
    "හත්", // 7
    "අට", // 8
    "නව", // 9
  ];

  /// Combined form for "ten" used before thousand (e.g., "දහ දහස").
  static const String _tenThousandCombined = "දහ";

  /// Suffix added to currency amounts (e.g., "රුපියලයි").
  static const String _currencySuffix = "යි";

  /// Suffix for years Before Christ (BC/BCE).
  static const String _yearSuffixBC = "ක්‍රි.පූ.";

  /// Suffix for years Anno Domini (AD/CE). Used only when [SiOptions.includeAD] is true.
  static const String _yearSuffixAD = "ක්‍රි.ව.";

  /// Word for the decimal point when using [DecimalSeparator.period] or [DecimalSeparator.point].
  static const String _decimalPointWord = "දශම";

  /// Word for the decimal point when using [DecimalSeparator.comma].
  static const String _decimalCommaWord = "කොමා";

  // --- Scale Words (International Short Scale) ---

  /// Names of number scales (Million, Billion, etc.). Index 0 and 1 are unused.
  static const List<String> _scaleWords = [
    "", // 0 - Base unit
    "", // 1 - Thousand (handled separately)
    "මිලියන", // 10^6
    "බිලියන", // 10^9
    "ට්‍රිලියන", // 10^12
    "ක්වඩ්‍රිලියන", // 10^15
    "ක්වින්ටිලියන", // 10^18
    "සෙක්ස්ටිලියන", // 10^21
    "සෙප්ටිලියන", // 10^24
    // Add more scales here if needed
  ];

  /// Suffix added to scale words when the number is exactly that scale power (e.g., "මිලියනය").
  static const String _scaleSingularSuffix = "ය";

  // --- Internal Constants ---

  /// BigInt representation of 1000.
  final BigInt _thousand = BigInt.from(1000);

  /// BigInt representation of 10.
  final BigInt _ten = BigInt.from(10);

  /// BigInt representation of 100,000 (Lakh).
  final BigInt _lakh = BigInt.from(100000);

  /// BigInt representation of 1,000,000 (Million).
  final BigInt _million = BigInt.from(1000000);

  /// Processes the given [number] and converts it to its Sinhala word representation.
  ///
  /// Handles `int`, `double`, `BigInt`, `Decimal`, and numeric `String` inputs.
  /// Uses [options] of type [SiOptions] to customize the output (e.g., currency, year format).
  /// Returns [fallbackOnError] or a default error message if conversion fails.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure options are of the correct type or use default.
    final SiOptions siOptions =
        options is SiOptions ? options : const SiOptions();
    final String effectiveFallback =
        fallbackOnError ?? "අංකයක් නොවේ"; // Default fallback

    // Handle special double values first.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? "${siOptions.negativePrefix.trim()} අනන්තය"
            : "අනන්තය";
      }
      if (number.isNaN) {
        return effectiveFallback;
      }
    }

    // Normalize the input number to a Decimal.
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) {
      return effectiveFallback;
    }

    // Handle zero separately.
    if (decimalValue == Decimal.zero) {
      if (siOptions.currency) {
        // Format zero currency according to LKR rules.
        final CurrencyInfo currencyInfo = siOptions.currencyInfo;
        return "${currencyInfo.mainUnitPlural ?? ''} $_zero$_currencySuffix ${currencyInfo.subUnitPlural ?? ''} $_zero$_currencySuffix"
            .trim();
      }
      return _zero;
    }

    // Determine sign and work with the absolute value.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    // Branch based on formatting options.
    if (siOptions.format == Format.year) {
      // Year formatting handles its own negative sign via BC/AD suffixes.
      if (!absValue.isInteger) {
        return effectiveFallback; // Cannot format non-integer year
      }
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), siOptions);
    } else if (siOptions.currency) {
      // Currency formatting handles the value and LKR specifics.
      textResult = _handleCurrency(absValue, siOptions);
    } else {
      // Standard cardinal number conversion.
      final BigInt integerPart = absValue.truncate().toBigInt();

      // Use special logic for the Lakh range [100,000, 999,999].
      if (integerPart >= _lakh && integerPart < _million) {
        textResult = _convertLakhRange(integerPart);
      } else {
        // Use general integer conversion for other ranges.
        textResult = _convertInteger(integerPart);
      }

      // Add fractional part if present.
      textResult += _convertFractionalPart(absValue, siOptions);
    }

    // Add negative prefix if needed (except for years, which use BC).
    if (isNegative && siOptions.format != Format.year && !siOptions.currency) {
      textResult = "${siOptions.negativePrefix.trim()} $textResult";
    }
    return textResult.trim();
  }

  /// Formats an integer as a year, adding BC/AD suffixes.
  ///
  /// [year]: The integer year to format.
  /// [options]: The [SiOptions] containing formatting preferences.
  /// Returns the year as a Sinhala string.
  String _handleYearFormat(int year, SiOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;

    // Handle year zero if necessary (though generally not used).
    if (absYear == 0) return _zero;

    // Convert the absolute year value to words.
    String yearText = _convertInteger(BigInt.from(absYear));

    // Add appropriate era suffix.
    if (isNegative) {
      yearText += " $_yearSuffixBC"; // Add BC for negative years.
    } else if (options.includeAD) {
      yearText +=
          " $_yearSuffixAD"; // Add AD for positive years only if requested.
    }
    return yearText;
  }

  /// Formats a [Decimal] value as Sri Lankan Rupees (LKR).
  ///
  /// [absValue]: The absolute (non-negative) decimal value to format.
  /// [options]: The [SiOptions] containing currency settings and rounding preference.
  /// Returns the currency value as a Sinhala string.
  String _handleCurrency(Decimal absValue, SiOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo; // Defaults to LKR
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value to 2 decimal places (cents) if requested.
    final Decimal valueToConvert =
        options.round ? absValue.round(scale: 2) : absValue;

    // Separate main unit (Rupees) and subunit (Cents).
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Calculate subunit value, rounding to handle potential precision issues.
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).round(scale: 0).toBigInt();

    String mainText = "";
    String subText = "";

    // Convert main unit (Rupees).
    if (mainValue > BigInt.zero) {
      if (mainValue == BigInt.one) {
        // Singular form for 1 Rupee.
        mainText =
            "${currencyInfo.mainUnitSingular}$_currencySuffix"; // "රුපියලයි"
      } else {
        // Plural form for 2+ Rupees.
        String mainNumText;
        // Use Lakh range conversion if applicable.
        if (mainValue >= _lakh && mainValue < _million) {
          mainNumText = _convertLakhRange(mainValue);
        } else {
          mainNumText = _convertInteger(mainValue);
        }
        mainText =
            "${currencyInfo.mainUnitPlural ?? ''} $mainNumText$_currencySuffix"; // "රුපියල් [number]යි"
      }
    }

    // Convert subunit (Cents).
    if (subunitValue > BigInt.zero) {
      if (subunitValue == BigInt.one) {
        // Singular form for 1 Cent.
        subText =
            "${currencyInfo.subUnitSingular ?? ''}$_currencySuffix"; // "සතයයි"
      } else {
        // Plural form for 2+ Cents.
        final String subNumText = _convertInteger(subunitValue);
        subText =
            "${currencyInfo.subUnitPlural ?? ''} $subNumText$_currencySuffix"; // "සත [number]යි"
      }
    }

    // Combine the parts.
    if (mainText.isNotEmpty && subText.isNotEmpty) return '$mainText $subText';
    if (mainText.isNotEmpty) return mainText; // Only Rupees
    if (subText.isNotEmpty) return subText; // Only Cents

    // If both are zero, return the zero currency format.
    return "${currencyInfo.mainUnitPlural ?? ''} $_zero$_currencySuffix ${currencyInfo.subUnitPlural ?? ''} $_zero$_currencySuffix"
        .trim();
  }

  /// Converts the fractional (decimal) part of a [Decimal] number to words.
  ///
  /// [absValue]: The absolute (non-negative) decimal value.
  /// [options]: The [SiOptions] containing the desired decimal separator word.
  /// Returns the fractional part as a Sinhala string (e.g., " දශම හතර පහ"),
  /// or an empty string if there is no fractional part.
  String _convertFractionalPart(Decimal absValue, SiOptions options) {
    final Decimal fractionalPart = absValue - absValue.truncate();

    if (fractionalPart > Decimal.zero) {
      // Determine the separator word based on options.
      final String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _decimalCommaWord; // "කොමා"
          break;
        case DecimalSeparator.period:
        case DecimalSeparator.point: // Treat point same as period
        default:
          separatorWord = _decimalPointWord; // "දශම"
          break;
      }

      // Extract digits after the decimal point.
      String fractionalDigits = absValue.toString().split('.').last;

      // Remove trailing zeros as they are usually not spoken.
      fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      // If only zeros were present, return empty.
      if (fractionalDigits.isEmpty) return "";

      // Convert each digit individually.
      final List<String> digitWords = fractionalDigits.split('').map((digit) {
        final int? digitInt = int.tryParse(digit);
        // Check if digit is valid before accessing _units
        return (digitInt != null && digitInt >= 0 && digitInt < _units.length)
            ? (digitInt == 0 ? _zero : _units[digitInt])
            : '?'; // Placeholder for invalid characters
      }).toList();

      return ' $separatorWord ${digitWords.join(' ')}';
    }
    return ""; // No fractional part.
  }

  /// Converts a non-negative [BigInt] integer to its Sinhala word representation.
  ///
  /// Handles numbers from zero up to the defined scales (Septillion).
  /// This method is used for numbers >= 1 Million or < 1 Lakh.
  /// For numbers in the Lakh range [100,000, 999,999], use [_convertLakhRange].
  ///
  /// [n]: The non-negative integer to convert.
  /// Throws [ArgumentError] if the number is negative or too large for defined scales.
  /// Returns the integer as a Sinhala string.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero) {
      // This function expects non-negative input. Negatives handled in `process`.
      throw ArgumentError("Integer must be non-negative for conversion: $n");
    }
    if (n == BigInt.zero) return _zero;

    // Use Lakh range converter if applicable.
    if (n >= _lakh && n < _million) {
      return _convertLakhRange(n);
    }

    final List<String> parts = [];
    BigInt remaining = n;
    int scaleIndex = 0; // 0: units, 1: thousands, 2: millions, ...
    final BigInt originalN = n; // Keep original value for checks

    while (remaining > BigInt.zero) {
      // Process the number in chunks of 1000.
      final BigInt chunk = remaining % _thousand;
      final BigInt chunkRemaining =
          remaining ~/= _thousand; // Update remaining for next loop

      if (chunk > BigInt.zero) {
        String chunkText = "";
        String scaleWord = "";
        final bool chunkIsOne = chunk == BigInt.one;
        final bool chunkIsTwo = chunk == BigInt.two;
        final bool chunkIsTen = chunk == _ten;

        final bool isHighestChunk = chunkRemaining == BigInt.zero;

        // Determine the scale word (thousand, million, billion, etc.).
        if (scaleIndex > 0) {
          if (scaleIndex == 1) {
            // Thousands: special singular/plural logic.
            final bool useSingularThousand =
                (originalN % _thousand == BigInt.zero) &&
                    !chunkIsOne &&
                    !chunkIsTwo;

            if (chunkIsOne && isHighestChunk && originalN == _thousand) {
              scaleWord = _thousandSingular; // "එක් දහස" needs singular
            } else if (chunkIsTwo &&
                isHighestChunk &&
                originalN == BigInt.from(2000)) {
              scaleWord = _thousandSingular; // "දෙ දහස" needs singular
            } else {
              scaleWord = useSingularThousand
                  ? _thousandSingular
                  : _thousandCombined; // "දහස" or "දහස්"
            }
          } else if (scaleIndex < _scaleWords.length) {
            // Standard scale words (million, billion...).
            scaleWord = _scaleWords[scaleIndex];
          } else {
            // Number exceeds defined scales.
            throw ArgumentError("Number too large for defined scales.");
          }
        }

        // Flag for reversing order for numbers like "මිලියන දෙක"
        bool reverseOrder = false;
        if (isHighestChunk &&
            scaleIndex >= 2 &&
            chunk > BigInt.zero &&
            chunk < _ten &&
            !chunkIsOne) {
          reverseOrder = true; // e.g., 2 million, 3 billion
        }

        // Convert the 3-digit chunk number to words.
        if (scaleIndex == 1) {
          // Special combined forms for thousands.
          if (chunkIsOne) {
            chunkText = _unitOneThousandCombined; // "එක්"
          } else if (chunkIsTwo) {
            chunkText = _unitTwoThousandCombined; // "දෙ"
          } else if (chunkIsTen) {
            chunkText = _tenThousandCombined; // "දහ"
          } else {
            chunkText =
                _convertChunk(chunk.toInt()); // Standard 3-digit conversion
          }
        } else if (chunkIsOne && scaleIndex >= 2) {
          // Handle exact scales (1 Million, 1 Billion...).
          final BigInt exactScaleValue = _thousand.pow(scaleIndex);
          if (isHighestChunk && originalN == exactScaleValue) {
            chunkText =
                "$scaleWord$_scaleSingularSuffix"; // "මිලියනය", "බිලියනය"
            scaleWord = ""; // Scale word is now part of chunkText
          } else {
            // Chunk is "one" but not the only part (e.g., 1,000,001), just use scale word later.
            chunkText = ""; // Implied "one"
          }
        } else if (reverseOrder) {
          // For "මිලියන දෙක", convert only the digit "දෙක".
          chunkText = _units[chunk.toInt()];
        } else {
          // Standard 3-digit conversion for the chunk.
          chunkText = _convertChunk(chunk.toInt());
        }

        // Combine chunk text and scale word.
        String combinedPart;
        if (reverseOrder) {
          // Order: Scale word + Number word (e.g., "මිලියන දෙක")
          combinedPart = scaleWord;
          if (chunkText.isNotEmpty) combinedPart += ' $chunkText';
        } else {
          // Order: Number word + Scale word (e.g., "එකසිය විසිතුන දහස්")
          combinedPart = chunkText;
          if (scaleWord.isNotEmpty) {
            if (combinedPart.isNotEmpty) {
              combinedPart += ' $scaleWord';
            } else {
              // Handles cases like "1,000,001" where chunkText is empty but scaleWord is needed.
              combinedPart = scaleWord;
            }
          }
        }

        // Add the processed part to the beginning of the list.
        if (combinedPart.isNotEmpty) {
          parts.insert(0, combinedPart);
        }
      }
      scaleIndex++; // Move to the next scale.
    }
    return parts.join(' ').trim(); // Join all parts with spaces.
  }

  /// Converts a [BigInt] integer specifically within the Lakh range [100,000, 999,999].
  ///
  /// This range has unique structuring in Sinhala (e.g., combining Lakhs and Thousands).
  /// For numbers outside this range, use [_convertInteger].
  ///
  /// [n]: The integer within the Lakh range to convert.
  /// Returns the integer as a Sinhala string.
  String _convertLakhRange(BigInt n) {
    // Fallback to general conversion if outside the specific range.
    if (n < _lakh || n >= _million) {
      return _convertInteger(n);
    }

    final List<String> words = [];
    BigInt remainder = n;

    // --- Lakhs Part ---
    final BigInt lakhs = remainder ~/ _lakh;
    remainder %= _lakh; // Remainder for thousands/hundreds

    String lakhNumText = "";
    final int lakhsInt = lakhs.toInt();

    // Use specific combined forms for Lakh counts (1-9).
    switch (lakhsInt) {
      case 1:
        lakhNumText = _unitOneThousandCombined;
        break; // Use "එක්" for One Lakh
      case 2:
        lakhNumText = _unitTwoThousandCombined;
        break; // Use "දෙ" for Two Lakhs
      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
      case 8:
      case 9:
        lakhNumText = _unitsHundredCombined[lakhsInt];
        break; // Use "තුන්", "හාර", etc.
      default:
        // For 10+ Lakhs (although this function targets < 1 Million), use chunk conversion.
        lakhNumText = _convertChunk(lakhsInt);
        break;
    }
    // Add Lakh word (singular if exact, combined otherwise).
    words.add(
        '$lakhNumText${remainder == BigInt.zero ? " $_lakhSingular" : " $_lakhCombined"}');

    // --- Thousands Part ---
    if (remainder >= _thousand) {
      final BigInt thousands = remainder ~/ _thousand;
      remainder %= _thousand; // Remainder for hundreds/tens/units
      final bool isExactThousands =
          remainder == BigInt.zero; // Is it exactly X thousand?

      String thousandNumText;
      // Use specific combined forms for Thousand counts.
      if (thousands == BigInt.one) {
        thousandNumText = _unitOneThousandCombined; // "එක්"
      } else if (thousands == BigInt.two) {
        thousandNumText = _unitTwoThousandCombined; // "දෙ"
      } else if (thousands == _ten) {
        thousandNumText = _tenThousandCombined; // "දහ"
      } else {
        thousandNumText =
            _convertChunk(thousands.toInt()); // Standard conversion
      }
      // Add Thousand word (singular if exact, combined otherwise).
      words.add(
        '$thousandNumText${isExactThousands ? " $_thousandSingular" : " $_thousandCombined"}',
      );
    }

    // --- Hundreds/Tens/Units Part ---
    if (remainder > BigInt.zero) {
      // Convert the remaining part (0-999).
      words.add(_convertChunk(remainder.toInt()));
    }

    return words.join(' '); // Join all parts with spaces.
  }

  /// Converts a three-digit integer (0-999) into its Sinhala word representation.
  ///
  /// [n]: The integer chunk (0-999) to convert.
  /// Throws [ArgumentError] if n is outside the range 0-999.
  /// Returns the chunk as a Sinhala string, or an empty string if n is 0.
  String _convertChunk(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }

    String hundredPart = "";
    String tenUnitPart = "";
    int remainder = n;

    // --- Hundreds ---
    if (remainder >= 100) {
      final int hundredsDigit = remainder ~/ 100;
      // Use specific combined forms for hundreds digit.
      switch (hundredsDigit) {
        case 1:
          hundredPart = _unitOneCombined;
          break; // "එක"
        case 2:
          hundredPart = _unitTwoCombined;
          break; // "දෙ"
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
          hundredPart = _unitsHundredCombined[hundredsDigit];
          break; // "තුන්", "හාර", etc.
        default:
          hundredPart = "?"; // Should not happen
      }
      remainder %= 100; // Get the remaining tens/units part.

      // Add the correct hundred suffix (singular or combined).
      hundredPart += (remainder == 0)
          ? _hundredSingularSuffix
          : _hundredCombinedSuffix; // "සියය" or "සිය"
    }

    // --- Tens and Units ---
    if (remainder > 0) {
      if (remainder < 10) {
        // 1-9
        tenUnitPart = _units[remainder];
      } else if (remainder < 20) {
        // 10-19
        tenUnitPart = _teens[remainder - 10];
      } else {
        // 20-99
        final int tensDigit = remainder ~/ 10;
        final int unitDigit = remainder % 10;
        if (unitDigit == 0) {
          // Exact tens (20, 30,... 90).
          tenUnitPart = _exactTens[tensDigit];
        } else {
          // Combined tens (21, 35,... 99).
          tenUnitPart = _tensPrefix[tensDigit] +
              _units[unitDigit]; // e.g., "විසි" + "එක" = "විසිඑක"
        }
      }
    }

    // Combine hundred and tens/units parts with a space if both exist.
    if (hundredPart.isNotEmpty && tenUnitPart.isNotEmpty) {
      return '$hundredPart $tenUnitPart';
    }

    // Return whichever part is non-empty.
    return hundredPart.isNotEmpty ? hundredPart : tenUnitPart;
  }
}
