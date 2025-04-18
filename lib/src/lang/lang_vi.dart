import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/vi_options.dart';
import '../utils/utils.dart';

/// {@template num2text_vi}
/// The Vietnamese language (`Lang.VI`) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Vietnamese word representation following standard Vietnamese grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [ViOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (up to tỷ tỷ - quintillion).
/// Special Vietnamese rules like "mốt" (for 1 after tens >= 2), "lăm" (for 5 after tens >= 1),
/// optional "tư" (for 4), and "linh"/"lẻ" connectors are handled.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [ViOptions].
/// {@endtemplate}
class Num2TextVI implements Num2TextBase {
  // --- Constants for Vietnamese Number Words ---

  /// The word for zero ("không").
  static const String _zero = "không";

  /// The word for ten ("mười").
  static const String _ten = "mười";

  /// The special suffix for one when following a tens digit >= 2 ("mốt").
  /// Example: 21 is "hai mươi mốt".
  static const String _unitOneSpecial = "mốt";

  /// The alternative word for four ("tư"). Often used in dates or optionally when following tens >= 2.
  /// Controlled by `useTuForFour` flag, typically set for year formatting.
  /// Example: Year 2024 is "hai nghìn không trăm hai mươi tư". Number 24 can be "hai mươi tư".
  static const String _unitFourSpecial = "tư";

  /// The special suffix for five when following a tens digit >= 1 ("lăm").
  /// Example: 15 is "mười lăm", 25 is "hai mươi lăm".
  static const String _unitFiveSpecial = "lăm";

  /// The suffix for tens digits from 2 to 9 ("mươi").
  /// Example: 20 is "hai mươi".
  static const String _tensSuffix = "mươi";

  /// The word for hundred ("trăm").
  static const String _hundred = "trăm";

  /// The word for thousand ("nghìn").
  static const String _thousand = "nghìn";

  /// The default connector word used between hundreds and units when the tens digit is zero ("linh").
  /// Example: 101 is "một trăm linh một". See also [_connectorZeroTensAlt].
  static const String _connectorZeroTensDefault = "linh";

  /// The alternative connector word used between hundreds and units when the tens digit is zero ("lẻ").
  /// Controlled by the `useLe` option in [ViOptions]. Example: 101 can be "một trăm lẻ một".
  static const String _connectorZeroTensAlt = "lẻ";

  /// The word used for the decimal point when the separator is a comma (",") ("phẩy").
  static const String _pointComma = "phẩy";

  /// The word used for the decimal point when the separator is a period (".") ("chấm").
  static const String _pointPeriod = "chấm";

  /// The scale word for million (10^6) ("triệu").
  static const String _scaleMillion = "triệu";

  /// The scale word for billion (10^9) ("tỷ").
  static const String _scaleBillion = "tỷ";

  /// A list of words for digits 0 through 9.
  static const List<String> _wordsUnder10 = [
    "không", // 0
    "một", // 1
    "hai", // 2
    "ba", // 3
    "bốn", // 4
    "năm", // 5
    "sáu", // 6
    "bảy", // 7
    "tám", // 8
    "chín", // 9
  ];

  /// Processes the given [number] and converts it into Vietnamese words.
  ///
  /// Handles normalization, special values (infinity, NaN), zero, negativity,
  /// and delegates to specific formatting methods based on [options].
  ///
  /// - [number]: The number to convert (can be `int`, `double`, `BigInt`, `Decimal`, or `String`).
  /// - [options]: Optional [ViOptions] to customize the conversion (e.g., currency, year format).
  ///              If null or not [ViOptions], default options are used.
  /// - [fallbackOnError]: A custom string to return if the input is invalid or conversion fails.
  ///                      If `null`, default Vietnamese error messages are used.
  ///
  /// Returns the Vietnamese word representation of the number, or an error/fallback string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have Vietnamese-specific options or use defaults.
    final ViOptions viOptions =
        options is ViOptions ? options : const ViOptions();

    // Handle special double values first.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? "Âm vô cực"
            : "Vô cực"; // Negative/Positive Infinity
      }
      if (number.isNaN) {
        // Use fallback if provided, otherwise default Vietnamese "Not a Number" message.
        return fallbackOnError ?? "Không phải là số";
      }
    }

    // Normalize the input number to Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // If normalization fails (e.g., invalid string), return fallback or default message.
    if (decimalValue == null) {
      return fallbackOnError ?? "Không phải là số";
    }

    // Handle zero separately for simplicity and correct currency format.
    if (decimalValue == Decimal.zero) {
      return viOptions.currency
          ? "$_zero ${viOptions.currencyInfo.mainUnitSingular}"
          : _zero;
    }

    // Determine sign and work with the absolute value.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    try {
      // Dispatch to specific handlers based on format options.
      if (viOptions.format == Format.year) {
        // Year format requires special handling of eras (BC/AD).
        // Years are usually integers, so truncate.
        textResult = _handleYearFormat(
            absValue.truncate().toBigInt(), viOptions, isNegative);
      } else {
        // Standard number or currency format.
        if (viOptions.currency) {
          textResult = _handleCurrency(absValue, viOptions);
        } else {
          textResult = _handleStandardNumber(absValue, viOptions);
        }
        // Prepend negative prefix if the original number was negative.
        if (isNegative) {
          textResult = "${viOptions.negativePrefix} $textResult";
        }
      }
    } catch (e) {
      // Catch potential errors during internal conversion logic.
      // Consider logging the error 'e' here if needed for debugging.
      return fallbackOnError ?? 'Error occurred during conversion.';
    }
    return textResult;
  }

  /// Formats a number as a year, potentially adding era suffixes.
  ///
  /// - [yearValue]: The absolute value of the year (as BigInt).
  /// - [options]: The Vietnamese options, specifically `includeAD` and `useLe` (influences year formatting).
  /// - [isNegative]: Indicates if the original year was negative (BC/BCE).
  ///
  /// Returns the year in Vietnamese words, with "Trước Công Nguyên" (BC/BCE)
  /// for negative years, or "Sau Công Nguyên" (AD/CE) for positive years
  /// if `options.includeAD` is true. Uses "tư" for 4 in years.
  String _handleYearFormat(
      BigInt yearValue, ViOptions options, bool isNegative) {
    // Convert the absolute year value to words. Use "tư" for 4 in years.
    String yearText =
        _convertInteger(yearValue, useTuForFour: true, options: options);

    // Append era suffixes based on sign and options.
    if (isNegative) {
      // Always add BC/BCE suffix for negative years.
      yearText += " Trước Công Nguyên";
    } else if (options.includeAD) {
      // Only add AD/CE suffix for positive years if includeAD is true.
      yearText += " Sau Công Nguyên";
    }
    return yearText;
  }

  /// Formats a number as Vietnamese currency (VND - đồng).
  ///
  /// Ignores the fractional part, as subunits (hào, xu) are deprecated and not typically spoken.
  ///
  /// - [absValue]: The absolute value of the amount (must be non-negative).
  /// - [options]: The Vietnamese options containing currency info ([CurrencyInfo.vnd]).
  ///
  /// Returns the amount in words followed by the currency unit ("đồng").
  String _handleCurrency(Decimal absValue, ViOptions options) {
    // Vietnamese currency typically doesn't verbalize subunits.
    // We only convert the integer part.
    final BigInt mainValue = absValue.truncate().toBigInt();
    final CurrencyInfo currencyInfo = options.currencyInfo;

    // Handle zero case (already done in `process`, but added for robustness).
    if (mainValue == BigInt.zero) {
      return "$_zero ${currencyInfo.mainUnitSingular}";
    }

    // Convert the integer part and append the currency name.
    final String mainText = _convertInteger(mainValue, options: options);
    return '$mainText ${currencyInfo.mainUnitSingular}'; // e.g., "một nghìn đồng"
  }

  /// Formats a standard number, including integer and fractional parts.
  ///
  /// - [absValue]: The absolute value of the number (must be non-negative).
  /// - [options]: The Vietnamese options controlling the decimal separator word (`decimalSeparator`).
  ///
  /// Returns the number in words, including the decimal part if present.
  /// Example: 123.45 -> "một trăm hai mươi ba phẩy bốn năm"
  String _handleStandardNumber(Decimal absValue, ViOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    // Use remainder() to get the fractional part accurately.
    final Decimal fractionalPart = absValue.remainder(Decimal.one);

    // Convert the integer part. Handle case where integer is zero but fraction exists.
    String integerWords;
    if (integerPart == BigInt.zero && fractionalPart > Decimal.zero) {
      // If only fractional part exists (e.g., 0.5), integer part is "không".
      // Case of exactly 0 is handled earlier.
      integerWords = _zero;
    } else {
      integerWords = _convertInteger(integerPart, options: options);
    }

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      // Determine the word for the decimal separator based on options.
      final String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          separatorWord = _pointPeriod; // "chấm"
          break;
        case DecimalSeparator.comma:
        default: // Default to comma for Vietnamese standard "phẩy"
          separatorWord = _pointComma; // "phẩy"
          break;
      }

      // Extract fractional digits. Use toString() which naturally handles precision.
      // Remove the leading "0." from the fractional part's string representation.
      String fractionalString = fractionalPart.toString(); // e.g., "0.123"
      String fractionalDigits = fractionalString.substring(2); // "123"
      // While toString() often removes trailing zeros for Decimal, double check.
      while (fractionalDigits.endsWith('0')) {
        fractionalDigits =
            fractionalDigits.substring(0, fractionalDigits.length - 1);
      }

      // Convert each fractional digit to its word form.
      if (fractionalDigits.isNotEmpty) {
        final List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int digitInt = int.parse(digit);
          return _wordsUnder10[digitInt]; // Convert digit using the base list
        }).toList();
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      } else {
        // If fraction was like .00, and integer part was also zero, return just "không".
        if (integerPart == BigInt.zero) return _zero;
        // Otherwise, just return the integer part (e.g., for 123.0).
      }
    }

    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer (BigInt) into Vietnamese words.
  ///
  /// Handles large numbers by breaking them into chunks of thousands (3 digits).
  /// Applies rules for zero padding ("không trăm linh") between chunks if needed.
  ///
  /// - [n]: The non-negative integer to convert.
  /// - [useTuForFour]: Whether to use "tư" instead of "bốn" for 4 (typically for years).
  /// - [options]: Vietnamese options, specifically `useLe`.
  ///
  /// Returns the integer in Vietnamese words.
  /// Throws [ArgumentError] if input `n` is negative.
  String _convertInteger(BigInt n,
      {bool useTuForFour = false, required ViOptions options}) {
    if (n < BigInt.zero) {
      // This function assumes non-negative input; sign is handled by the caller.
      throw ArgumentError(
          "Integer must be non-negative for _convertInteger: $n");
    }
    if (n == BigInt.zero) return _zero; // Base case: 0

    final List<String> parts =
        []; // Stores text for each scale level (thousand, million, ...)
    int scaleIndex =
        0; // 0: units chunk, 1: thousands chunk, 2: millions chunk, ...
    final BigInt thousand = BigInt.from(1000);

    // Determine the number of 3-digit chunks needed.
    int numChunks = 0;
    BigInt tempN = n;
    if (tempN == BigInt.zero) {
      numChunks = 1; // Handle the unlikely case of n=0 being passed here.
    } else {
      while (tempN > BigInt.zero) {
        tempN ~/= thousand;
        numChunks++;
      }
    }

    // Process the number in chunks of three digits (0-999), from right to left.
    tempN = n; // Reset tempN for processing
    while (scaleIndex < numChunks) {
      // Extract the current chunk (0-999).
      final BigInt chunkValue = tempN % thousand;
      tempN ~/= thousand; // Move to the next chunk for the next iteration

      // Process chunk only if it's non-zero. Zero chunks are skipped,
      // but the gap might require a "linh" later if surrounded by non-zero chunks.
      // Exception: Process the first chunk (units) even if it's zero if the whole number is < 1000.
      if (chunkValue > BigInt.zero || (scaleIndex == 0 && n < thousand)) {
        // Check if this is the most significant (leftmost) chunk being processed.
        // This check depends on tempN; if tempN is zero, this is the last non-zero chunk.
        final bool isMostSignificantChunk = (tempN == BigInt.zero);

        // Determine if padding ("không trăm linh") is needed for chunks < 100
        // that are *not* the most significant chunk. This handles cases like 1,000,005.
        final bool shouldPad = !isMostSignificantChunk &&
            chunkValue < BigInt.from(100) &&
            chunkValue > BigInt.zero;

        // Convert the 3-digit chunk to words.
        final String chunkText = _convertChunk(
          chunkValue.toInt(),
          options: options,
          useTuForFour: useTuForFour,
          leadingZeroPadding: shouldPad,
        );

        // Determine the scale word (nghìn, triệu, tỷ, etc.).
        String scaleWord = "";
        if (scaleIndex > 0) {
          // Scale repeats every 3 levels (thousand, million, billion).
          final int baseScaleIndex = (scaleIndex - 1) % 3;
          // Higher level repetition (tỷ tỷ, triệu tỷ, etc.).
          final int highScaleLevel = (scaleIndex - 1) ~/ 3;

          switch (baseScaleIndex) {
            case 0:
              scaleWord = _thousand;
              break; // 10^3
            case 1:
              scaleWord = _scaleMillion;
              break; // 10^6
            case 2:
              scaleWord = _scaleBillion;
              break; // 10^9
          }

          // Append higher scale suffixes (e.g., "tỷ tỷ" for 10^18).
          // Each highScaleLevel adds another "tỷ".
          if (highScaleLevel > 0) {
            final String higherScaleSuffix =
                List.filled(highScaleLevel, _scaleBillion).join(' ');
            scaleWord = "$scaleWord $higherScaleSuffix"
                .trim(); // e.g., "nghìn tỷ", "triệu tỷ tỷ"
          }
        }

        // Add the converted chunk and scale word to the parts list (building right-to-left).
        if (chunkText.isNotEmpty) {
          parts.insert(
              0, scaleWord.isNotEmpty ? "$chunkText $scaleWord" : chunkText);
        } else if (scaleIndex > 0 && parts.isNotEmpty && !shouldPad) {
          // If a middle chunk was zero, but previous parts exist, insert "linh"
          // to bridge the gap (e.g., 1,000,000,001 -> "một tỷ linh một").
          // Only insert if padding wasn't already applied.
          // Check if the last added part needs a preceding zero.
          if (parts.first !=
              (options.useLe
                  ? _connectorZeroTensAlt
                  : _connectorZeroTensDefault)) {
            parts.insert(
                0,
                (options.useLe
                    ? _connectorZeroTensAlt
                    : _connectorZeroTensDefault));
          }
        }
      } else if (scaleIndex > 0 && parts.isNotEmpty && tempN > BigInt.zero) {
        // This chunk is zero, but it's not the leftmost chunk, AND previous parts exist.
        // Mark the potential need for a zero connector.
        // Insert "linh" if the *last* inserted part doesn't represent a zero itself.
        if (parts.first !=
            (options.useLe
                ? _connectorZeroTensAlt
                : _connectorZeroTensDefault)) {
          parts.insert(
              0,
              (options.useLe
                  ? _connectorZeroTensAlt
                  : _connectorZeroTensDefault));
        }
      }

      scaleIndex++;
    }

    // Post-processing: Clean up potentially redundant "linh" or "lẻ" at the beginning
    if (parts.isNotEmpty &&
        (parts.first == _connectorZeroTensDefault ||
            parts.first == _connectorZeroTensAlt)) {
      parts.removeAt(0);
    }

    // Join the parts.
    return parts.join(' ').trim();
  }

  /// Converts a three-digit chunk (0-999) into Vietnamese words.
  ///
  /// Handles hundreds, tens, and units, including special Vietnamese rules:
  /// - "mốt" for 1 after tens >= 2.
  /// - "lăm" for 5 after tens >= 1.
  /// - Optional "tư" for 4.
  /// - "linh" or "lẻ" connector between hundreds and units when tens are zero.
  /// - Optional "không trăm linh" padding for intermediate chunks < 100.
  ///
  /// - [n]: The number chunk (0-999).
  /// - [options]: Vietnamese options, specifically `useLe`.
  /// - [useTuForFour]: Whether to use "tư" instead of "bốn" for 4.
  /// - [leadingZeroPadding]: If true, adds "không trăm [linh|lẻ]" padding for numbers < 10
  ///                         or "không trăm" for numbers < 100 when they are intermediate chunks.
  ///
  /// Returns the three-digit chunk in Vietnamese words.
  /// Throws [ArgumentError] if input `n` is outside the valid range 0-999.
  String _convertChunk(
    int n, {
    required ViOptions options,
    bool useTuForFour = false,
    bool leadingZeroPadding = false,
  }) {
    if (n < 0 || n >= 1000) {
      throw ArgumentError("Chunk must be between 0 and 999: $n");
    }

    // Handle zero chunk. If padding is needed, it's handled below.
    if (n == 0) return "";

    final List<String> words = [];
    int remainder = n;

    // --- Hundreds Place ---
    int hundredsDigit = remainder ~/ 100;
    // Handle padding for intermediate chunks < 100.
    if (leadingZeroPadding && n < 100) {
      words.add(_wordsUnder10[0]); // "không"
      words.add(_hundred); // "trăm"
      // If padding a single digit (1-9), also add the connector.
      if (n < 10) {
        words.add(
          options.useLe ? _connectorZeroTensAlt : _connectorZeroTensDefault,
        ); // "linh" or "lẻ"
      }
      // For padded 10-99, the connector isn't needed after "không trăm".
    } else if (hundredsDigit > 0) {
      // Standard hundreds digit processing.
      words.add(_wordsUnder10[hundredsDigit]);
      words.add(_hundred);
    }
    remainder %= 100; // Get the remaining tens and units.

    // --- Tens and Units Place ---
    if (remainder > 0) {
      final int tensDigit = remainder ~/ 10;
      final int unitsDigit = remainder % 10;

      // Determine if a hundred part exists (either real or padded).
      final bool hasHundredPart =
          hundredsDigit > 0 || (leadingZeroPadding && n < 100);

      // Add "linh" or "lẻ" connector ONLY if:
      // - A hundred part exists (real or padded "không trăm").
      // - The tens digit is zero.
      // - The units digit is non-zero.
      // - AND we are NOT in the specific padding case for single digits (1-9) where the connector was already added.
      if (hasHundredPart &&
          tensDigit == 0 &&
          unitsDigit > 0 &&
          !(leadingZeroPadding && n < 10)) {
        words.add(
            options.useLe ? _connectorZeroTensAlt : _connectorZeroTensDefault);
      }

      // Add tens part (mười, hai mươi, etc.).
      if (tensDigit > 0) {
        if (tensDigit == 1) {
          words.add(_ten); // "mười"
        } else {
          words.add(_wordsUnder10[tensDigit]);
          words.add(_tensSuffix); // "mươi"
        }
      }

      // Add units part (một, hai, ..., mốt, lăm, tư).
      if (unitsDigit > 0) {
        String unitWord;
        switch (unitsDigit) {
          case 1:
            // Use "mốt" if tens >= 2 (e.g., 21, 31), otherwise use "một".
            // Also use "một" if tens = 0 (e.g., 101) regardless of padding.
            unitWord = (tensDigit >= 2) ? _unitOneSpecial : _wordsUnder10[1];
            break;
          case 4:
            // Use "tư" if:
            // 1. `useTuForFour` is true (typically for years) AND (tens >= 2 OR (tens = 0 AND hundred part exists)).
            // This covers "hai mươi tư", "một trăm linh tư", etc.
            final bool preferTu = useTuForFour &&
                (tensDigit >= 2 || (tensDigit == 0 && hasHundredPart));
            unitWord = preferTu ? _unitFourSpecial : _wordsUnder10[4];
            break;
          case 5:
            // Use "lăm" if tens >= 1 (e.g., 15, 25), otherwise use "năm" (e.g., 105, 5).
            unitWord = (tensDigit >= 1) ? _unitFiveSpecial : _wordsUnder10[5];
            break;
          default:
            // Standard digit word for 2, 3, 6, 7, 8, 9.
            unitWord = _wordsUnder10[unitsDigit];
            break;
        }
        words.add(unitWord);
      }
    }

    return words.join(' ');
  }
}
