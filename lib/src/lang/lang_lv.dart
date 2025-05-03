import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/lv_options.dart';
import '../utils/utils.dart';

/// {@template num2text_lv}
/// Converts numbers to Latvian words (`Lang.LV`).
///
/// Implements [Num2TextBase] for Latvian. Handles various numeric types,
/// converting them into Latvian words following grammatical rules for number
/// agreement and pluralization.
///
/// Features:
/// - Cardinal numbers (e.g., "viens simts divdesmit trīs").
/// - Currency formatting (handles singular/plural forms for units based on number ending).
/// - Year formatting (can add "p.m.ē."/ "m.ē." suffixes).
/// - Negative numbers (prefix "mīnus").
/// - Decimals (using "komats" or "punkts").
/// - Large numbers using standard scale (tūkstotis/tūkstoši, miljons/miljoni...).
///
/// Customization is available via [LvOptions]. Returns fallback string on error.
/// {@endtemplate}
class Num2TextLV implements Num2TextBase {
  // --- Constants ---
  static const String _point = "punkts"; // Decimal point
  static const String _comma = "komats"; // Decimal comma
  static const String _and =
      "un"; // Conjunction "and", default currency separator

  /// Words for numbers 0-19.
  static const List<String> _wordsUnder20 = [
    "nulle",
    "viens",
    "divi",
    "trīs",
    "četri",
    "pieci",
    "seši",
    "septiņi",
    "astoņi",
    "deviņi",
    "desmit",
    "vienpadsmit",
    "divpadsmit",
    "trīspadsmit",
    "četrpadsmit",
    "piecpadsmit",
    "sešpadsmit",
    "septiņpadsmit",
    "astoņpadsmit",
    "deviņpadsmit",
  ];

  /// Words for tens (20, 30,..., 90).
  static const List<String> _wordsTens = [
    "",
    "",
    "divdesmit",
    "trīsdesmit",
    "četrdesmit",
    "piecdesmit",
    "sešdesmit",
    "septiņdesmit",
    "astoņdesmit",
    "deviņdesmit",
  ];

  /// Words for hundreds (100, 200,..., 900).
  static const List<String> _wordsHundreds = [
    "",
    "viens simts",
    "divi simti",
    "trīs simti",
    "četri simti",
    "pieci simti",
    "seši simti",
    "septiņi simti",
    "astoņi simti",
    "deviņi simti",
  ];

  /// Standard scale words (thousand, million...). [Singular, Plural]
  static const Map<int, List<String>> _scaleWords = {
    1: ["tūkstotis", "tūkstoši"], // 10^3
    2: ["miljons", "miljoni"], // 10^6
    3: ["miljards", "miljardi"], // 10^9
    4: ["triljons", "triljoni"], // 10^12
    5: ["kvadriljons", "kvadriljoni"], // 10^15
    6: ["kvintiljons", "kvintiljoni"], // 10^18
    7: ["sekstiljons", "sekstiljoni"], // 10^21
    8: ["septiljons", "septiljoni"], // 10^24
    // Add more scales if needed (oktiljons, noniljons...)
  };

  /// Processes the given [number] into Latvian words.
  ///
  /// {@macro num2text_base_process_intro}
  /// {@macro num2text_base_process_options}
  /// Uses [LvOptions] for customization (currency, year format, decimals, AD/BC).
  /// {@macro num2text_base_process_errors}
  /// Returns [fallbackOnError] or Latvian default "Nav Skaitlis" on failure.
  ///
  /// @param number The number to convert.
  /// @param options Optional [LvOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Latvian words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final LvOptions lvOptions =
        options is LvOptions ? options : const LvOptions();
    final String errorFallback =
        fallbackOnError ?? "Nav Skaitlis"; // Default "Not a Number"

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? "Negatīva Bezgalība" : "Bezgalība";
      if (number.isNaN) return errorFallback;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    if (decimalValue == Decimal.zero) {
      // Zero currency needs special handling (plural unit name).
      if (lvOptions.currency) return _handleCurrency(Decimal.zero, lvOptions);
      return _wordsUnder20[0]; // "nulle"
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String textResult;

    if (lvOptions.format == Format.year) {
      // Years use standard integer conversion; suffixes added here.
      textResult = _convertInteger(absValue.truncate().toBigInt());
      if (isNegative)
        textResult += " p.m.ē."; // pirms mūsu ēras (BC)
      else if (lvOptions.includeAD) textResult += " m.ē."; // mūsu ērā (AD)
    } else {
      if (lvOptions.currency) {
        textResult = _handleCurrency(absValue, lvOptions);
      } else {
        textResult = _handleStandardNumber(absValue, lvOptions);
      }
      if (isNegative) {
        textResult = "${lvOptions.negativePrefix} $textResult";
      }
    }

    return textResult.trim();
  }

  /// Converts a non-negative [Decimal] value to Latvian currency words.
  ///
  /// Uses [LvOptions.currencyInfo]. Handles singular/plural forms for main
  /// and subunits based on Latvian grammar rules (number ending in 1, except 11).
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options ([LvOptions]).
  /// @return Currency value as Latvian words.
  String _handleCurrency(Decimal absValue, LvOptions options) {
    final CurrencyInfo info = options.currencyInfo;
    // Rounding is not applied by default here, assuming precise input or caller handles it.
    final Decimal val = absValue;
    final BigInt mainVal = val.truncate().toBigInt();
    // Calculate subunit value (e.g., cents), rounding ensures correct value for 0.xx amounts.
    final BigInt subVal =
        ((val - val.truncate()) * Decimal.fromInt(100)).round().toBigInt();

    final String? subUnitSingular = info.subUnitSingular;
    final bool hasSubunits =
        subUnitSingular != null; // Check if subunits are defined

    // --- Latvian Pluralization Rule ---
    // Use singular form if the number ends in 1, but IS NOT 11.
    bool useSingular(BigInt value) {
      return (value % BigInt.from(10) == BigInt.one) &&
          (value % BigInt.from(100) != BigInt.from(11));
    }
    // ---

    // Handle case 0.xx (only subunits)
    if (mainVal == BigInt.zero && subVal > BigInt.zero && hasSubunits) {
      final String subunitText = _convertInteger(subVal);
      final String subUnitName = useSingular(subVal)
          ? subUnitSingular // Assured non-null by hasSubunits check
          : (info.subUnitPlural ??
              subUnitSingular); // Fallback to singular if plural is null
      return '$subunitText $subUnitName';
    }

    // Handle case 0.00 or main value > 0
    final String mainText =
        _convertInteger(mainVal); // Handles mainVal == 0 correctly -> "nulle"
    final String mainUnitName = useSingular(mainVal)
        ? info.mainUnitSingular
        : (info.mainUnitPlural ?? info.mainUnitSingular); // Fallback

    String result = '$mainText $mainUnitName';

    // Add subunit part if present and > 0.
    if (hasSubunits && subVal > BigInt.zero) {
      final String subunitText = _convertInteger(subVal);
      final String subUnitName = useSingular(subVal)
          ? subUnitSingular
          : (info.subUnitPlural ?? subUnitSingular);
      final String separator = info.separator ?? _and; // Default separator "un"
      result += ' $separator $subunitText $subUnitName';
    }

    return result;
  }

  /// Converts a non-negative standard [Decimal] number to Latvian words.
  ///
  /// Converts integer part using [_convertInteger].
  /// Converts fractional part digit by digit. Uses [LvOptions.decimalSeparator].
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options ([LvOptions]).
  /// @return Number as Latvian words.
  String _handleStandardNumber(Decimal absValue, LvOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part. Handle case 0.xxxxx -> "nulle..."
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _wordsUnder20[0] // "nulle"
            : _convertInteger(integerPart);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Determine separator word ("komats" or "punkts").
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.point:
        case DecimalSeparator.period:
          separatorWord = _point;
          break;
        case DecimalSeparator.comma:
        default:
          separatorWord = _comma;
          break;
      }

      // Extract fractional digits and remove trailing zeros.
      // toString() gives scientific notation for very small/large Decimals,
      // but substring(2) works for typical fractional parts like 0.5, 0.123.
      String fractionalDigits = fractionalPart.toString().substring(2);
      while (fractionalDigits.endsWith('0') && fractionalDigits.length > 1) {
        fractionalDigits =
            fractionalDigits.substring(0, fractionalDigits.length - 1);
      }

      // If only zeros remained after trimming, clear fractional part.
      if (fractionalDigits == "0" || fractionalDigits.isEmpty) {
        fractionalWords = '';
      } else {
        // Convert each digit to its word form (0-9).
        List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int? digitInt = int.tryParse(digit);
          return (digitInt != null && digitInt >= 0 && digitInt <= 9)
              ? _wordsUnder20[digitInt]
              : '?'; // Placeholder for unexpected characters
        }).toList();
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }

    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords';
  }

  /// Converts a non-negative [BigInt] into Latvian words.
  ///
  /// Handles large numbers by breaking them into chunks of 1000.
  /// Uses singular/plural scale names (_scaleWords) based on the chunk value (1 vs >1).
  ///
  /// @param n The non-negative integer.
  /// @return The integer as Latvian words. Returns "nulle" if n is 0.
  /// @throws ArgumentError if number exceeds defined scales or is negative.
  String _convertInteger(BigInt n) {
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n == BigInt.zero) return _wordsUnder20[0]; // "nulle"

    // Handle numbers under 1000 directly.
    if (n < BigInt.from(1000)) return _convertChunk(n.toInt());

    List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleIndex = 0; // 0=units, 1=thousands, 2=millions...
    BigInt remaining = n;

    // Process number in 3-digit chunks from right to left.
    while (remaining > BigInt.zero) {
      BigInt chunk = remaining % oneThousand;
      remaining ~/= oneThousand;

      if (chunk > BigInt.zero) {
        // Convert the 0-999 chunk.
        String chunkText = _convertChunk(chunk.toInt());
        String scaleWord = "";

        // Get the appropriate scale word (tūkstotis/tūkstoši, miljons/miljoni...)
        if (scaleIndex > 0) {
          List<String>? scaleForms = _scaleWords[scaleIndex];
          if (scaleForms != null) {
            // Use singular scale name if chunk is 1, plural otherwise.
            scaleWord = (chunk == BigInt.one) ? scaleForms[0] : scaleForms[1];
          } else {
            throw ArgumentError(
                "Number too large: scale index $scaleIndex undefined.");
          }
        }

        // Combine chunk text and scale word (if applicable).
        if (scaleWord.isNotEmpty) {
          parts.add("$chunkText $scaleWord");
        } else {
          parts.add(chunkText); // Units chunk has no scale word.
        }
      }
      scaleIndex++;
    }

    // Join parts in reverse order (highest scale first).
    return parts.reversed.join(' ');
  }

  /// Converts an integer between 0 and 999 into Latvian words.
  ///
  /// Handles hundreds, tens, and units.
  ///
  /// @param n Integer chunk (0-999).
  /// @return Chunk as Latvian words. Returns empty string if n is 0.
  /// @throws ArgumentError if n is outside 0-999.
  String _convertChunk(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    List<String> words = [];
    int remainder = n;

    // Handle hundreds.
    if (remainder >= 100) {
      words.add(_wordsHundreds[remainder ~/ 100]);
      remainder %= 100;
    }

    // Handle tens and units (1-99).
    if (remainder > 0) {
      if (remainder < 20) {
        words.add(_wordsUnder20[remainder]); // Use predefined 1-19.
      } else {
        words.add(
            _wordsTens[remainder ~/ 10]); // Add tens word (e.g., "divdesmit").
        int unit = remainder % 10;
        if (unit > 0) {
          words.add(_wordsUnder20[unit]); // Add unit word if needed.
        }
      }
    }

    // Join parts with spaces.
    return words.join(' ');
  }
}
