import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ms_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ms}
/// Converts numbers to Malay words (`Lang.MS`).
///
/// Implements [Num2TextBase] for Malay, handling various numeric types.
/// Supports cardinal numbers, decimals, negatives, currency, and years.
/// Uses the short scale system (juta, bilion, etc.).
/// Features special Malay word forms like "seribu", "seratus", "sebelas", "X belas".
/// Customizable via [MsOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextMS implements Num2TextBase {
  // --- Constants ---
  static const String _point = "perpuluhan"; // Decimal separator "."
  static const String _comma = "koma"; // Decimal separator ","
  static const String _yearSuffixBC = "SM"; // Before Christ ("Sebelum Masihi")
  static const String _yearSuffixAD = "M"; // AD/CE ("Masihi")
  static const String _notANumber = "Bukan Nombor"; // Default NaN message
  static const String _infinity = "Infiniti";
  static const String _negativeInfinity = "Negatif Infiniti";

  /// Digits 0-9.
  static const List<String> _wordsUnits = [
    "sifar",
    "satu",
    "dua",
    "tiga",
    "empat",
    "lima",
    "enam",
    "tujuh",
    "lapan",
    "sembilan",
  ];

  static const String _ten = "sepuluh"; // 10
  static const String _eleven = "sebelas"; // 11
  static const String _hundred = "seratus"; // 100 (prefix form)
  static const String _thousand = "seribu"; // 1000 (prefix form)

  /// Tens 20-90 ("dua puluh", ...). Index matches tens digit.
  static const List<String> _wordsTens = [
    "",
    "",
    "dua puluh",
    "tiga puluh",
    "empat puluh",
    "lima puluh",
    "enam puluh",
    "tujuh puluh",
    "lapan puluh",
    "sembilan puluh",
  ];

  /// Scale words (short scale). Key: Scale level (2=10^6, 3=10^9,...).
  static const Map<int, String> _scaleWords = {
    2: "juta",
    3: "bilion",
    4: "trilion",
    5: "kuadrilion",
    6: "kuintilion",
    7: "sekstilion",
    8: "septilion",
  };

  /// {@macro num2text_base_process}
  /// Converts the given [number] into Malay words.
  ///
  /// Handles `int`, `double`, `BigInt`, `Decimal`, and numeric `String`.
  /// Uses [MsOptions] for customization (currency, year format, decimals, AD/BC).
  /// Returns [fallbackOnError] or a default error message on failure.
  ///
  /// @param number The number to convert.
  /// @param options Optional [MsOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Malay words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final MsOptions msOptions =
        options is MsOptions ? options : const MsOptions();
    final String errorDefault = fallbackOnError ?? _notANumber;

    if (number is double) {
      if (number.isInfinite)
        return number.isNegative ? _negativeInfinity : _infinity;
      if (number.isNaN) return errorDefault;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorDefault;

    if (decimalValue == Decimal.zero) {
      return msOptions.currency
          ? "${_wordsUnits[0]} ${msOptions.currencyInfo.mainUnitSingular}" // e.g., "sifar ringgit"
          : _wordsUnits[0]; // "sifar"
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    // Dispatch based on format.
    if (msOptions.format == Format.year) {
      // Year format handles negativity (BC suffix) internally.
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), msOptions);
    } else {
      if (msOptions.currency) {
        textResult = _handleCurrency(absValue, msOptions);
      } else {
        textResult = _handleStandardNumber(absValue, msOptions);
      }
      // Apply negative prefix for non-year formats.
      if (isNegative) {
        textResult = "${msOptions.negativePrefix} $textResult";
      }
    }
    return textResult.trim(); // Ensure no leading/trailing spaces.
  }

  /// Converts an integer year to Malay words, optionally adding suffixes.
  ///
  /// Years are read as cardinal numbers.
  ///
  /// @param year The integer year (can be negative for BC).
  /// @param options Checks `includeAD` option.
  /// @return The year in words (e.g., "seribu sembilan ratus lapan puluh empat", "lima ratus SM").
  String _handleYearFormat(int year, MsOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;

    if (absYear == 0) return _wordsUnits[0]; // Year 0 is "sifar".

    // Convert the absolute year value as a standard integer.
    String yearText = _convertInteger(BigInt.from(absYear));

    // Append suffixes.
    if (isNegative) {
      yearText += " $_yearSuffixBC"; // Always add "SM" for negative years.
    } else if (options.includeAD) {
      yearText += " $_yearSuffixAD"; // Add "M" only if option is set.
    }
    return yearText;
  }

  /// Converts a non-negative [Decimal] to Malay currency words.
  ///
  /// Uses [MsOptions.currencyInfo]. Separates main and subunits (e.g., ringgit, sen).
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Malay words.
  String _handleCurrency(Decimal absValue, MsOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    // Assume 2 decimal places for subunits (e.g., sen). Rounding is not applied here by default.
    final Decimal valueToConvert = absValue;
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    // Calculate subunit value (e.g., cents). Assumes 100 subunits per main unit.
    final BigInt subunitValue = (fractionalPart.abs() * Decimal.fromInt(100))
        .round(scale: 0)
        .toBigInt();

    List<String> parts = [];

    // --- Main Unit Part ---
    if (mainValue > BigInt.zero) {
      String mainText = _convertInteger(mainValue);
      // Use singular/plural - Malay typically uses singular form after number.
      String mainUnitName = currencyInfo.mainUnitSingular;
      parts.add("$mainText $mainUnitName");
    }

    // --- Subunit Part ---
    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      String subunitText = _convertInteger(subunitValue);
      String subUnitName = currencyInfo.subUnitSingular!;
      String separator = "";
      // Add separator if main part exists.
      if (parts.isNotEmpty) {
        separator = currencyInfo.separator?.isNotEmpty ?? false
            ? " ${currencyInfo.separator!} " // Use custom separator with spaces.
            : " "; // Default separator is just a space.
      }
      parts.add("$separator$subunitText $subUnitName");
    }

    // --- Zero Case ---
    // If both parts are zero (original value was 0 or rounded to 0).
    if (mainValue == BigInt.zero && subunitValue == BigInt.zero) {
      return "${_wordsUnits[0]} ${currencyInfo.mainUnitSingular}"; // e.g., "sifar ringgit"
    }

    return parts.join("").trim(); // Join parts (already includes separator).
  }

  /// Converts a non-negative standard [Decimal] number to Malay words.
  ///
  /// Handles integer and fractional parts. Fractional part read digit by digit.
  ///
  /// @param absValue The non-negative number.
  /// @param options Used for `decimalSeparator`.
  /// @return Number in words (e.g., "seratus dua puluh tiga perpuluhan empat lima").
  String _handleStandardNumber(Decimal absValue, MsOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part. Use "sifar" if integer is 0 but fraction exists (e.g., 0.5).
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _wordsUnits[0]
            : _convertInteger(integerPart);

    String fractionalWords = '';
    // Process fractional part if it's greater than zero.
    if (fractionalPart > Decimal.zero) {
      // Determine separator word.
      String separatorWord =
          (options.decimalSeparator == DecimalSeparator.comma)
              ? _comma
              : _point; // Default to "perpuluhan".

      // Get fractional digits string.
      String fractionalDigitsString = absValue.toString().split('.').last;

      // Convert each digit to its word form.
      List<String> digitWords = fractionalDigitsString.split('').map((digit) {
        return _wordsUnits[int.parse(digit)];
      }).toList();

      fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
    }

    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative [BigInt] integer into Malay words.
  ///
  /// Uses 3-digit chunking and applies scale words (ribu, juta, bilion, etc.).
  /// Handles special cases like "seribu".
  ///
  /// @param n The non-negative integer.
  /// @return The integer as Malay words.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _wordsUnits[0];
    if (n < BigInt.zero)
      throw ArgumentError("Negative numbers handled externally");

    // Special case for 1000.
    if (n == BigInt.from(1000)) return _thousand;

    if (n < BigInt.from(1000)) return _convertChunk(n.toInt());

    List<String> parts = [];
    final BigInt oneThousand = BigInt.from(1000);
    int scaleLevel = 0; // 0: units, 1: thousands, 2: millions,...
    BigInt remaining = n;

    while (remaining > BigInt.zero) {
      BigInt chunk = remaining % oneThousand; // Current 0-999 chunk.
      remaining ~/= oneThousand;

      if (chunk > BigInt.zero) {
        String chunkText;
        String? scaleWordSuffix; // e.g., "ribu", "juta"

        // Determine scale word and format chunk text.
        if (scaleLevel == 1) {
          // Thousands scale
          if (chunk == BigInt.one) {
            // Use "seribu" directly instead of converting chunk "satu".
            chunkText = _thousand;
            scaleWordSuffix = null; // "ribu" is part of "seribu".
          } else {
            chunkText = _convertChunk(chunk.toInt());
            scaleWordSuffix = "ribu";
          }
        } else if (scaleLevel > 1) {
          // Millions, billions, etc.
          chunkText = _convertChunk(chunk.toInt());
          scaleWordSuffix = _scaleWords[scaleLevel];
          if (scaleWordSuffix == null)
            throw ArgumentError("Number too large (scale level $scaleLevel)");
        } else {
          // Base chunk (scaleLevel 0)
          chunkText = _convertChunk(chunk.toInt());
          scaleWordSuffix = null;
        }

        // Combine chunk text and scale suffix.
        String currentPart = chunkText;
        if (scaleWordSuffix != null) {
          currentPart += " $scaleWordSuffix";
        }
        parts.add(currentPart);
      }
      scaleLevel++;
    }

    // Join parts from highest scale down.
    return parts.reversed.join(' ').trim();
  }

  /// Converts an integer from 0 to 999 into Malay words.
  ///
  /// Handles hundreds, tens, units. Includes special forms:
  /// "seratus", "sepuluh", "sebelas", "X belas".
  ///
  /// @param n The integer chunk (0-999).
  /// @return The chunk as Malay words, or empty string if n is 0.
  String _convertChunk(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    List<String> words = [];
    int remainder = n;

    // --- Hundreds ---
    if (remainder >= 100) {
      // Use "seratus" for 100, "dua ratus" etc. otherwise.
      words.add((remainder ~/ 100 == 1)
          ? _hundred
          : "${_wordsUnits[remainder ~/ 100]} ratus");
      remainder %= 100;
    }

    // --- Tens and Units ---
    if (remainder > 0) {
      if (remainder < 10) {
        words.add(_wordsUnits[remainder]); // 1-9
      } else if (remainder == 10) {
        words.add(_ten); // 10
      } else if (remainder == 11) {
        words.add(_eleven); // 11
      } else if (remainder < 20) {
        // 12-19: "dua belas", "tiga belas", ...
        words.add("${_wordsUnits[remainder % 10]} belas");
      } else {
        // 20-99: "dua puluh", "dua puluh satu", ...
        words.add(_wordsTens[remainder ~/ 10]); // Add the tens part.
        if (remainder % 10 > 0) {
          words.add(
              _wordsUnits[remainder % 10]); // Add the unit part if non-zero.
        }
      }
    }

    return words.join(' ');
  }
}
