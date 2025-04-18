import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ms_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ms}
/// The Malay language (`Lang.MS`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Malay word representation following standard Malay grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [MsOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers using the
/// short scale system (juta, bilion, trilion, etc.).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [MsOptions].
/// {@endtemplate}
class Num2TextMS implements Num2TextBase {
  // --- Constants ---

  /// The word for the decimal separator when using a period (`.`) ("perpuluhan").
  static const String _point = "perpuluhan";

  /// The word for the decimal separator when using a comma (`,`) ("koma").
  static const String _comma = "koma";

  /// The suffix for negative years ("Sebelum Masihi" - Before Christ).
  static const String _yearSuffixBC = "SM";

  /// The suffix for positive years ("Masihi" - AD/CE). Added only if [MsOptions.includeAD] is true.
  static const String _yearSuffixAD = "M";

  /// Word forms for digits 0-9.
  static const List<String> _wordsUnits = [
    "sifar", // 0
    "satu", // 1
    "dua", // 2
    "tiga", // 3
    "empat", // 4
    "lima", // 5
    "enam", // 6
    "tujuh", // 7
    "lapan", // 8
    "sembilan", // 9
  ];

  /// The word for ten ("sepuluh").
  static const String _ten = "sepuluh";

  /// The word for eleven ("sebelas").
  static const String _eleven = "sebelas";

  /// The word for one hundred ("seratus").
  static const String _hundred = "seratus";

  /// The word for one thousand ("seribu").
  static const String _thousand = "seribu";

  /// Word forms for tens 20-90 ("dua puluh", "tiga puluh", ...).
  /// Index corresponds to the tens digit (index 2 = 20, index 9 = 90).
  static const List<String> _wordsTens = [
    "", // 0
    "", // 10 - Handled by _ten
    "dua puluh", // 20
    "tiga puluh", // 30
    "empat puluh", // 40
    "lima puluh", // 50
    "enam puluh", // 60
    "tujuh puluh", // 70
    "lapan puluh", // 80
    "sembilan puluh", // 90
  ];

  /// Scale words (million, billion, etc.) using the short scale system.
  /// Key: Scale level index (2 = 10^6, 3 = 10^9...).
  /// Value: Scale word name.
  static const Map<int, String> _scaleWords = {
    2: "juta", // Million (10^6)
    3: "bilion", // Billion (10^9)
    4: "trilion", // Trillion (10^12)
    5: "kuadrilion", // Quadrillion (10^15)
    6: "kuintilion", // Quintillion (10^18)
    7: "sekstilion", // Sextillion (10^21)
    8: "septilion", // Septillion (10^24)
    // Add more if needed
  };

  /// {@macro num2text_base_process}
  /// Converts the given [number] into its Malay word representation.
  ///
  /// Handles `int`, `double`, `BigInt`, `Decimal`, and numeric `String` inputs.
  /// Uses [MsOptions] to customize behavior like currency formatting ([MsOptions.currency], [MsOptions.currencyInfo]),
  /// year formatting ([Format.year]), decimal separator ([MsOptions.decimalSeparator]),
  /// and negative prefix ([MsOptions.negativePrefix]).
  /// If `options` is not an instance of [MsOptions], default settings are used.
  ///
  /// Returns the word representation (e.g., "seratus dua puluh tiga", "negatif sepuluh perpuluhan lima", "satu juta").
  /// If the input is invalid (`null`, `NaN`, `Infinity`, non-numeric string), it returns
  /// [fallbackOnError] if provided, otherwise a default error message like "Bukan Nombor".
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have Malay-specific options, using defaults if none are provided.
    final MsOptions msOptions =
        options is MsOptions ? options : const MsOptions();

    // Handle special non-finite double values early.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? "Negatif Infiniti"
            : "Infiniti"; // Localized infinity
      }
      if (number.isNaN)
        return fallbackOnError ?? "Bukan Nombor"; // Not a Number
    }

    // Normalize the input to a Decimal for precise calculations.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Return error if normalization failed (invalid input type or format).
    if (decimalValue == null) return fallbackOnError ?? "Bukan Nombor";

    // Handle the specific case of zero.
    if (decimalValue == Decimal.zero) {
      if (msOptions.currency) {
        // Currency format for zero (e.g., "sifar ringgit"). Use singular unit name.
        return "${_wordsUnits[0]} ${msOptions.currencyInfo.mainUnitSingular}";
      } else {
        // Standard "sifar". Also covers year 0.
        return _wordsUnits[0];
      }
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for the core conversion logic.
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    // --- Dispatch based on format options ---
    if (msOptions.format == Format.year) {
      // Year format needs the integer part.
      // Years are read as cardinal numbers.
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), msOptions);
      // Note: Year format handles BC/AD suffixes internally, so negative prefix is not added here.
    } else {
      // Handle currency or standard number format.
      if (msOptions.currency) {
        textResult = _handleCurrency(absValue, msOptions);
      } else {
        textResult = _handleStandardNumber(absValue, msOptions);
      }
      // Prepend the negative prefix if applicable (not for years).
      if (isNegative) {
        textResult = "${msOptions.negativePrefix} $textResult";
      }
    }
    return textResult; // Trimming happens within helper functions if needed.
  }

  /// Formats an integer as a calendar year, optionally adding BC/AD suffixes.
  /// Years are read as cardinal numbers.
  ///
  /// [year]: The integer year value (can be negative).
  /// [options]: Malay options, checks `includeAD`.
  /// Returns the year in words, e.g., "seribu sembilan ratus sembilan puluh sembilan", "lima ratus SM".
  String _handleYearFormat(int year, MsOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;
    // Handle year 0.
    if (absYear == 0) return _wordsUnits[0]; // "sifar"

    // Convert the absolute year value as a standard integer.
    String yearText = _convertInteger(BigInt.from(absYear));

    // Append era suffixes based on the year's sign and options.
    if (isNegative) {
      yearText += " $_yearSuffixBC"; // Always add "SM" for negative years.
    } else if (options.includeAD) {
      // Add "M" for positive years *only if* requested via options.
      yearText += " $_yearSuffixAD";
    }
    return yearText;
  }

  /// Formats a [Decimal] value as a currency amount in words.
  /// Handles main units (e.g., Ringgit) and subunits (e.g., Sen).
  /// Uses the separator defined in [CurrencyInfo] (defaults to space if null).
  /// Rounding is NOT applied here by default, relies on BaseOptions.round.
  ///
  /// [absValue]: The non-negative currency amount.
  /// [options]: Malay options containing currency details.
  /// Returns the currency amount in words, e.g., "satu ringgit dan lima puluh sen", "dua ringgit".
  String _handleCurrency(Decimal absValue, MsOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;

    // Note: Rounding is not explicitly done here, assuming it's handled upstream if options.round is true.
    final Decimal valueToConvert = absValue;
    // Separate main and subunit values.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Calculate subunit value (e.g., 0.50 becomes 50).
    final BigInt subunitValue =
        (fractionalPart * Decimal.fromInt(100)).truncate().toBigInt();

    // Convert main value part. Handle case where main is zero but subunits exist.
    String mainText = (mainValue == BigInt.zero && subunitValue > BigInt.zero)
        ? _wordsUnits[0] // "sifar" if main is zero but subunits exist.
        : _convertInteger(mainValue); // Convert non-zero main value.

    // Get the main unit name (typically singular in Malay).
    String mainUnitName =
        currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;

    // Combine main number and unit name.
    String result = '$mainText $mainUnitName';

    // Add subunit part if it exists and a subunit name is provided.
    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      // Convert subunit value.
      String subunitText = _convertInteger(subunitValue);
      // Get subunit name (typically singular).
      String subUnitName = currencyInfo.subUnitSingular!;
      // Get separator (e.g., "dan"), add spaces if needed, default to space if null.
      String separator =
          currencyInfo.separator != null ? " ${currencyInfo.separator!} " : " ";
      // Append separator and subunit part.
      result += '$separator$subunitText $subUnitName';
    }
    // Handle the case of exactly zero value (0.00).
    else if (mainValue == BigInt.zero && subunitValue == BigInt.zero) {
      result = "${_wordsUnits[0]} $mainUnitName"; // e.g., "sifar ringgit"
    }

    return result;
  }

  /// Formats a standard [Decimal] number (non-currency, non-year) into words.
  /// Handles both the integer and fractional parts.
  /// The fractional part is read digit by digit after the separator word ("perpuluhan" or "koma").
  ///
  /// [absValue]: The non-negative number.
  /// [options]: Malay options, used for `decimalSeparator`.
  /// Returns the number in words, e.g., "seratus dua puluh tiga perpuluhan empat lima".
  String _handleStandardNumber(Decimal absValue, MsOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert the integer part. Use "sifar" if integer is zero but there's a fractional part.
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _wordsUnits[0] // Handle 0.5 -> "sifar perpuluhan..."
            : _convertInteger(integerPart);

    String fractionalWords = '';
    // Process fractional part only if it's greater than zero.
    if (fractionalPart > Decimal.zero) {
      // Determine the separator word.
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _comma;
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period:
        default: // Default to point/"perpuluhan" for Malay.
          separatorWord = _point;
          break;
      }

      // Get fractional digits as string.
      String fractionalDigitsString = absValue.toString().split('.').last;

      // --- Trailing Zero Logic ---
      // Check if the default separator is used (point/period or null).
      // bool useDefaultSeparator = (options.decimalSeparator == null ||
      //     options.decimalSeparator == DecimalSeparator.point ||
      //     options.decimalSeparator == DecimalSeparator.period);

      // This logic attempts to remove trailing zeros ONLY if using the default separator.
      // It seems overly complex and potentially incorrect. A simpler approach is often preferred:
      // just read the digits present in the string representation after the decimal point.
      // Standard Decimal.toString() often handles reasonable representations.
      // Let's simplify: Read digits as they appear. If trailing zeros are unwanted,
      // the input Decimal should ideally be constructed without them or normalized beforehand.
      // Example: Decimal.parse("1.50").toString() is "1.50". Reading this gives "...lima sifar".
      // Decimal.parse("1.5").toString() is "1.5". Reading this gives "...lima".

      // Simpler approach: Read all digits present.
      List<String> digitWords = fractionalDigitsString.split('').map((digit) {
        final int digitInt = int.parse(digit);
        // Map the digit to its word using _wordsUnits.
        return _wordsUnits[digitInt];
      }).toList();

      // Combine separator and digit words.
      fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
    }
    // This block seems intended for cases like Decimal('1.0') - integer with scale > 0.
    // However, fractionalPart > Decimal.zero check already handles this. This block can be removed.
    // else if (integerPart > BigInt.zero && absValue.scale > 0 && absValue.isInteger) {
    //   // No fractional words needed for integers.
    // }

    // Combine integer and fractional parts, trimming whitespace.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] integer into its Malay word representation.
  /// Breaks the number into 3-digit chunks and applies scale words (ribu, juta, bilion, etc.).
  /// Handles special cases like "seribu" (1000).
  ///
  /// [n]: The non-negative integer to convert. Must not be negative.
  /// Returns the integer in words, e.g., "satu juta dua ratus tiga puluh empat ribu lima ratus enam puluh tujuh".
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _wordsUnits[0]; // Base case: zero.
    // Ensure input is non-negative.
    if (n < BigInt.zero)
      throw ArgumentError("Negative numbers handled externally");

    // Special case for exactly one thousand.
    if (n == BigInt.from(1000)) return _thousand; // "seribu"

    // Handle numbers less than 1000 directly using the chunk converter.
    if (n < BigInt.from(1000)) return _convertChunk(n.toInt());

    List<String> parts = []; // Stores word parts for each scale level.
    final BigInt oneThousand = BigInt.from(1000);
    int scaleLevel = 0; // 0=units chunk, 1=thousands chunk, 2=millions chunk...
    BigInt remaining = n;

    // Process the number in chunks of 1000 from right to left.
    while (remaining > BigInt.zero) {
      // Get the current 3-digit chunk (0-999).
      BigInt chunk = remaining % oneThousand;
      remaining ~/= oneThousand; // Move to the next higher chunk.

      // Only process non-zero chunks.
      if (chunk > BigInt.zero) {
        String chunkText;
        String? scaleWordSuffix; // The scale word like "ribu", "juta".

        // Determine scale word and format the chunk text.
        if (scaleLevel == 1) {
          // Thousands level
          if (chunk == BigInt.one) {
            // Special case: "seribu" (one thousand). Chunk text is replaced entirely.
            chunkText = _thousand;
            scaleWordSuffix = null; // "ribu" is included in "_thousand".
          } else {
            // 2000-999000: Convert chunk + "ribu".
            chunkText = _convertChunk(chunk.toInt());
            scaleWordSuffix = "ribu";
          }
        } else if (scaleLevel > 1) {
          // Millions, billions, etc.
          // Convert the chunk normally.
          chunkText = _convertChunk(chunk.toInt());
          // Get the scale word (juta, bilion...).
          scaleWordSuffix = _scaleWords[scaleLevel];
          if (scaleWordSuffix == null) {
            // Safety check for numbers larger than defined scales.
            throw ArgumentError("Number too large (scale level $scaleLevel)");
          }
        } else {
          // Base chunk (scaleLevel 0)
          // Convert the chunk normally, no scale suffix.
          chunkText = _convertChunk(chunk.toInt());
          scaleWordSuffix = null;
        }

        // Combine the chunk text and its scale suffix (if any).
        String currentPart = chunkText;
        if (scaleWordSuffix != null) {
          currentPart += " $scaleWordSuffix";
        }
        parts.add(currentPart); // Add the complete part for this scale level.
      }
      scaleLevel++; // Move to the next scale level.
    }

    // Join the parts in reverse order (highest scale first) with spaces.
    return parts.reversed.join(' ').trim();
  }

  /// Converts a number between 0 and 999 into its Malay word representation.
  /// Handles special cases "seratus", "sepuluh", "sebelas", and "X belas".
  ///
  /// [n]: The number to convert (must be 0-999).
  /// Returns the chunk in words, e.g., "seratus", "dua puluh satu", "tiga belas".
  String _convertChunk(int n) {
    // Return empty string for zero within a larger number context.
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    List<String> words = []; // Stores word parts for this chunk.
    int remainder = n;

    // --- Process Hundreds ---
    if (remainder >= 100) {
      // Handle "seratus" (100) vs "dua ratus", "tiga ratus", etc.
      words.add((remainder ~/ 100 == 1)
          ? _hundred
          : "${_wordsUnits[remainder ~/ 100]} ratus");
      remainder %= 100; // Update remainder (0-99).
    }

    // --- Process Tens and Units (0-99) ---
    if (remainder > 0) {
      // Add space if hundreds were processed. (Malay often omits 'dan' here).
      // if (words.isNotEmpty) { /* Optional: add space or "dan" */ }

      if (remainder < 10) {
        // 1-9: Use unit words directly.
        words.add(_wordsUnits[remainder]);
      } else if (remainder == 10) {
        // 10: Special word "sepuluh".
        words.add(_ten);
      } else if (remainder == 11) {
        // 11: Special word "sebelas".
        words.add(_eleven);
      } else if (remainder < 20) {
        // 12-19: Use "X belas" structure.
        words.add(
            "${_wordsUnits[remainder % 10]} belas"); // e.g., "dua belas", "tiga belas"
      } else {
        // 20-99: Use "X puluh Y" structure.
        words.add(
            _wordsTens[remainder ~/ 10]); // Add "dua puluh", "tiga puluh", etc.
        if (remainder % 10 > 0) {
          // Add the unit word if present.
          words.add(_wordsUnits[remainder % 10]);
        }
      }
    }

    // Join the collected word parts (hundreds, tens, units) with spaces.
    return words.join(' ');
  }
}
