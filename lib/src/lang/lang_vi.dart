import 'package:decimal/decimal.dart';

import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/vi_options.dart';
import '../utils/utils.dart';

/// {@template num2text_vi}
/// Converts numbers to Vietnamese words (`Lang.VI`).
///
/// Implements [Num2TextBase] for Vietnamese. Handles `int`, `double`, `BigInt`, `Decimal`, `String`.
/// Supports cardinal numbers, decimals, negatives, currency (VND default, ignores subunits), years.
/// Implements specific Vietnamese rules:
/// - Special units: "mốt" (1 after tens ≥ 2), "lăm" (5 after tens ≥ 1), "tư" (optional 4).
/// - Connectors: "linh" or "lẻ" (based on [ViOptions.useLe]) for H0X patterns (e.g., một trăm linh một).
/// - Padding: Adds "không trăm" before chunks < 100 following a higher scale word (e.g., một nghìn không trăm linh một).
/// - Scales: Uses standard Vietnamese scale words (nghìn, triệu, tỷ, etc.).
///
/// Behavior is customizable via [ViOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextVI implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "không";
  static const String _ten = "mười";
  static const String _unitOneSpecial =
      "mốt"; // Unit '1' after tens >= 2 (hai mươi mốt)
  static const String _unitFourSpecial =
      "tư"; // Optional '4', often used in years
  static const String _unitFiveSpecial =
      "lăm"; // Unit '5' after tens >= 1 (mười lăm, hai mươi lăm)
  static const String _tensSuffix = "mươi"; // Suffix for tens 20-90 (hai mươi)
  static const String _hundred = "trăm";
  static const String _thousand = "nghìn"; // Or "ngàn" regionally
  static const String _connectorZeroTensDefault =
      "linh"; // Connector for H0X (e.g., trăm linh một)
  static const String _connectorZeroTensAlt =
      "lẻ"; // Alternative connector (trăm lẻ một)
  static const String _paddingZeroHundred =
      "không trăm"; // Padding for 0XX chunks after higher scales
  static const String _pointComma = "phẩy"; // Decimal separator word for ','
  static const String _pointPeriod = "chấm"; // Decimal separator word for '.'
  static const String _scaleMillion = "triệu";
  static const String _scaleBillion = "tỷ";
  static const List<String> _wordsUnder10 = [
    "không",
    "một",
    "hai",
    "ba",
    "bốn",
    "năm",
    "sáu",
    "bảy",
    "tám",
    "chín",
  ];

  /// Processes the given [number] into Vietnamese words.
  ///
  /// {@template num2text_process_intro_vi}
  /// Normalizes various numeric input types (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options_vi}
  /// Uses [ViOptions] for customization (currency, year format, decimals, AD/BC suffix, linh/lẻ choice).
  /// Defaults apply if [options] is null or not [ViOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors_vi}
  /// Handles special values `Infinity`, `NaN`. Returns [fallbackOnError] or a default
  /// Vietnamese error message ("Không Phải Là Số") if conversion fails or input is invalid.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [ViOptions] settings.
  /// @param fallbackOnError Optional custom string for errors.
  /// @return The number as Vietnamese words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final ViOptions viOptions =
        options is ViOptions ? options : const ViOptions();
    final String onError =
        fallbackOnError ?? "Không Phải Là Số"; // Default Vietnamese error

    // Handle non-finite doubles first.
    if (number is double) {
      if (number.isInfinite) return number.isNegative ? "Âm Vô Cực" : "Vô Cực";
      if (number.isNaN) return onError;
    }

    // Normalize input to Decimal for consistent handling.
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null)
      return onError; // Return error if normalization fails.

    // Handle zero specifically.
    if (decimalValue == Decimal.zero) {
      // Return "không đồng" for zero currency, otherwise just "không".
      return viOptions.currency
          ? "$_zero ${viOptions.currencyInfo.mainUnitSingular}"
          : _zero;
    }

    // Determine sign and get absolute value.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    try {
      // Delegate to appropriate handler based on options.
      if (viOptions.format == Format.year) {
        textResult = _handleYearFormat(
            absValue.truncate().toBigInt(), viOptions, isNegative);
      } else {
        // Handle currency or standard number conversion.
        textResult = viOptions.currency
            ? _handleCurrency(absValue, viOptions)
            : _handleStandardNumber(absValue, viOptions);
        // Prepend negative prefix if applicable.
        if (isNegative) {
          textResult = "${viOptions.negativePrefix} $textResult";
        }
      }
    } catch (e) {
      // Catch potential internal errors (e.g., number too large for defined scales).
      return fallbackOnError ?? 'Lỗi chuyển đổi.';
    }
    // Return the final result.
    return textResult;
  }

  /// Converts an integer year to Vietnamese words, optionally adding era suffixes.
  /// Calls the main integer conversion, forcing the use of "tư" for 4.
  ///
  /// @param yearValue Absolute integer year value.
  /// @param options Formatting options ([ViOptions]).
  /// @param isNegative True if the original year was negative (BC).
  /// @return The year formatted as Vietnamese words.
  String _handleYearFormat(
      BigInt yearValue, ViOptions options, bool isNegative) {
    // Convert the year value, specifically requesting "tư" for 4.
    String yearText =
        _convertInteger(yearValue.abs(), useTuForFour: true, options: options);
    // Append era suffixes if needed.
    if (isNegative) {
      yearText += " Trước Công Nguyên"; // BC suffix
    } else if (options.includeAD) {
      yearText += " Sau Công Nguyên"; // AD suffix
    }
    return yearText;
  }

  /// Converts a non-negative [Decimal] value to Vietnamese currency words (VND - Đồng).
  /// This implementation ignores the fractional part, as VND subunits (hào, xu)
  /// are generally not expressed in word form in modern usage.
  ///
  /// @param absValue The absolute currency value.
  /// @param options Formatting options ([ViOptions]).
  /// @return The currency value (integer part only) as Vietnamese words, followed by "đồng".
  String _handleCurrency(Decimal absValue, ViOptions options) {
    // Get the integer part (main currency unit).
    final BigInt mainValue = absValue.truncate().toBigInt();
    // Handle zero case.
    if (mainValue == BigInt.zero) {
      return "$_zero ${options.currencyInfo.mainUnitSingular}";
    }
    // Convert the integer part to words.
    final String mainText = _convertInteger(mainValue, options: options);
    // Append the currency unit name ("đồng").
    return '$mainText ${options.currencyInfo.mainUnitSingular}';
  }

  /// Converts a non-negative standard [Decimal] number to Vietnamese words.
  /// Converts the integer part and the fractional part separately.
  /// Uses the decimal separator word ("phẩy" or "chấm") specified in [ViOptions].
  /// Reads fractional digits individually.
  ///
  /// @param absValue The absolute decimal value.
  /// @param options Formatting options ([ViOptions]).
  /// @return The number formatted as Vietnamese words.
  String _handleStandardNumber(Decimal absValue, ViOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    // Use remainder to get the fractional part accurately.
    final Decimal fractionalPart = absValue.remainder(Decimal.one);

    // Convert the integer part. Use "không" if integer is 0 but fraction exists.
    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, options: options);

    String fractionalWords = '';
    // Process fractional part only if it's non-zero.
    if (fractionalPart > Decimal.zero) {
      String sepWord;
      // Determine separator word based on options.
      switch (options.decimalSeparator) {
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          sepWord = _pointPeriod; // "chấm"
          break;
        default: // Includes comma and null
          sepWord = _pointComma; // "phẩy"
          break;
      }

      // Get fractional digits reliably, handling potential scale issues.
      String fracDigits =
          fractionalPart.toStringAsFixed(fractionalPart.scale).split('.').last;
      // Trim trailing zeros for standard representation (e.g., 1.50 -> "một phẩy năm").
      while (fracDigits.endsWith('0') && fracDigits.isNotEmpty) {
        fracDigits = fracDigits.substring(0, fracDigits.length - 1);
      }

      // If digits remain after trimming...
      if (fracDigits.isNotEmpty) {
        // Convert each digit to its word form.
        final List<String> digitWords = fracDigits
            .split('')
            .map((d) => _wordsUnder10[int.parse(d)])
            .toList();
        // Combine separator and digit words.
        fractionalWords = ' $sepWord ${digitWords.join(' ')}';
      }
    }
    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts an integer from 0 to 999 into Vietnamese words (internal chunk rules).
  /// Handles special units "mốt", "lăm", "tư" based on context.
  /// Adds the connector "linh" or "lẻ" (based on options) ONLY for the H0X case
  /// (Hundreds > 0, Tens = 0, Units > 0), e.g., "một trăm linh một".
  /// It does **not** handle the "không trăm" padding for 0XX chunks; this is done in [_convertInteger].
  ///
  /// @param n The integer chunk (0-999) to convert.
  /// @param options Required [ViOptions] to determine "linh" vs "lẻ".
  /// @param useTuForFour If true, use "tư" instead of "bốn" when applicable (tens >= 2).
  /// @return Vietnamese text representation of the chunk, or empty string if n is 0.
  /// @throws ArgumentError if n is outside the 0-999 range.
  String _convertChunk(int n,
      {required ViOptions options, bool useTuForFour = false}) {
    if (n == 0) return ""; // Zero chunk results in empty string here.
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    List<String> words = []; // Stores word components for this chunk.
    int hundreds = n ~/ 100;
    int remainder = n % 100;
    int tens = remainder ~/ 10;
    int units = remainder % 10;

    // --- Hundreds part ---
    if (hundreds > 0) {
      words.add(_wordsUnder10[hundreds]); // "một", "hai", ...
      words.add(_hundred); // "trăm"
    }

    // --- Tens and Units part ---
    if (remainder > 0) {
      // Determine which connector ("linh" or "lẻ") to use based on options.
      String connector =
          options.useLe ? _connectorZeroTensAlt : _connectorZeroTensDefault;

      // Add connector *only* if H > 0, T = 0, U > 0 (H0X pattern).
      if (hundreds > 0 && tens == 0 && units != 0) {
        words.add(connector); // "trăm linh/lẻ"
      }

      // Tens digit (if > 0)
      if (tens > 0) {
        // "mười" for 10, "X mươi" for 20-90.
        words.add(tens == 1 ? _ten : "${_wordsUnder10[tens]} $_tensSuffix");
      }

      // Units digit (if > 0)
      if (units > 0) {
        String unitWord;
        // Apply special unit rules.
        switch (units) {
          case 1:
            unitWord = (tens >= 2) ? _unitOneSpecial : _wordsUnder10[1];
            break; // "mốt" / "một"
          case 4:
            unitWord = (useTuForFour && tens >= 2)
                ? _unitFourSpecial
                : _wordsUnder10[4];
            break; // "tư" / "bốn"
          case 5:
            unitWord = (tens >= 1) ? _unitFiveSpecial : _wordsUnder10[5];
            break; // "lăm" / "năm"
          default:
            unitWord = _wordsUnder10[units];
            break; // Standard digit word
        }
        words.add(unitWord);
      }
    }
    // Combine parts with spaces, ensuring no double spaces.
    return words.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Converts a non-negative integer ([BigInt]) into Vietnamese words using standard scale.
  /// This is the main recursive function that handles chunking (thousands, millions, billions, etc.),
  /// applies scale words, and inserts necessary padding ("không trăm [linh/lẻ]")
  /// between scale words and subsequent chunks that are less than 100.
  ///
  /// @param n The non-negative integer to convert.
  /// @param useTuForFour If true, instructs [_convertChunk] to use "tư" instead of "bốn" when applicable.
  /// @param options Required [ViOptions] to determine "linh" vs "lẻ" for padding.
  /// @return The integer formatted as Vietnamese words. Returns "không" for 0.
  /// @throws ArgumentError if n is negative or too large for defined scales.
  String _convertInteger(BigInt n,
      {bool useTuForFour = false, required ViOptions options}) {
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n == BigInt.zero) return _zero; // Base case for zero input.

    List<String> resultParts =
        []; // Stores the final word parts (chunks + scales).
    final BigInt thousand = BigInt.from(1000);
    List<int> chunks =
        []; // Stores 3-digit chunks, ordered highest scale first.

    // Split the number into 3-digit chunks from right to left.
    if (n == BigInt.zero) {
      chunks.add(0);
    } else {
      BigInt tempN = n;
      while (tempN > BigInt.zero) {
        // Insert chunk at the beginning to maintain correct order (highest scale first).
        chunks.insert(0, (tempN % thousand).toInt());
        tempN ~/= thousand;
      }
    }

    int totalChunks = chunks.length;
    // Determine the connector word based on options.
    String connector =
        options.useLe ? _connectorZeroTensAlt : _connectorZeroTensDefault;

    // Process chunks from left to right (highest scale first).
    for (int i = 0; i < totalChunks; i++) {
      int chunkValue = chunks[i]; // Current chunk value (0-999).
      int scaleIndex =
          totalChunks - 1 - i; // Scale level (0=units, 1=thousand, ...).

      // Only process non-zero chunks.
      if (chunkValue > 0) {
        // --- Add Padding ("không trăm [linh]") before this chunk if needed ---
        // Padding is required if:
        // 1. This is not the first chunk being processed (i > 0).
        // 2. The current chunk value is less than 100 (meaning it starts with at least one zero).
        if (i > 0 && chunkValue < 100) {
          resultParts.add(_paddingZeroHundred); // Add "không trăm"
          // Add "linh/lẻ" connector if the chunk is 1-9 (00X).
          if (chunkValue < 10) {
            resultParts.add(connector);
          }
        }

        // Convert the current chunk (0-999) to words using internal rules.
        String chunkText = _convertChunk(chunkValue,
            options: options, useTuForFour: useTuForFour);
        // Get the appropriate scale word ("nghìn", "triệu", "tỷ",...).
        String scaleWord = _getScaleWord(scaleIndex);

        // Add the converted chunk text to the result.
        resultParts.add(chunkText);
        // Add the scale word if applicable (not for the units chunk).
        if (scaleWord.isNotEmpty) {
          resultParts.add(scaleWord);
        }
      }
      // Zero chunks are implicitly skipped, but the padding logic handles the space correctly.
    }

    // Join all parts, filter out any potential empty strings, and trim whitespace.
    return resultParts.where((part) => part.isNotEmpty).join(' ').trim();
  }

  /// Determines the correct Vietnamese scale word (nghìn, triệu, tỷ, etc.)
  /// based on the scale index (power of 1000). Handles combined scales like "nghìn tỷ".
  ///
  /// @param scaleIndex The index representing the power of 1000 (0 = units, 1 = 10^3, 2 = 10^6, ...).
  /// @return The appropriate scale word (e.g., "nghìn", "triệu", "tỷ", "nghìn tỷ"), or an empty string for scaleIndex 0.
  String _getScaleWord(int scaleIndex) {
    if (scaleIndex <= 0) return ""; // Units chunk has no scale word.

    // Calculate base scale (thousand, million, billion cycle) and level of 'tỷ'.
    final int baseScaleIndex = (scaleIndex - 1) %
        3; // 0 for thousand, 1 for million, 2 for billion part.
    final int highScaleLevel =
        (scaleIndex - 1) ~/ 3; // Number of times 'tỷ' is repeated.

    String scaleWord;
    // Determine the base scale word.
    switch (baseScaleIndex) {
      case 0:
        scaleWord = _thousand;
        break; // ... nghìn ...
      case 1:
        scaleWord = _scaleMillion;
        break; // ... triệu ...
      case 2:
        scaleWord = _scaleBillion;
        break; // ... tỷ ...
      default:
        scaleWord = "";
        break; // Should not happen.
    }

    // Append repeating 'tỷ' for higher scales (trillion, quadrillion, etc.).
    if (highScaleLevel > 0) {
      // Create the suffix of repeated "tỷ".
      final String higherScaleSuffix =
          List.filled(highScaleLevel, _scaleBillion).join(' ');
      // Combine base scale word with "tỷ" suffix (e.g., "nghìn tỷ", "triệu tỷ", "tỷ tỷ").
      scaleWord = "$scaleWord $higherScaleSuffix".trim();
    }
    return scaleWord;
  }
}
