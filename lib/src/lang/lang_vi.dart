import 'package:decimal/decimal.dart';

import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/vi_options.dart';
import '../utils/utils.dart';

/// {@template num2text_vi}
/// Converts numbers to Vietnamese words (`Lang.VI`).
///
/// Implements [Num2TextBase] for Vietnamese. Handles `int`, `double`, `BigInt`, `Decimal`, `String`.
/// Supports cardinal numbers, decimals, negatives, currency (VND default, no subunits), years.
/// Handles specific Vietnamese rules ("mốt", "lăm", "tư", "linh/lẻ").
/// Customizable via [ViOptions]. Returns a fallback string on error.
/// {@endtemplate}
class Num2TextVI implements Num2TextBase {
  // --- Constants ---
  static const String _zero = "không";
  static const String _ten = "mười";
  static const String _unitOneSpecial =
      "mốt"; // For 1 after tens >= 2 (e.g., 21)
  static const String _unitFourSpecial =
      "tư"; // Optional for 4 (often in years)
  static const String _unitFiveSpecial =
      "lăm"; // For 5 after tens >= 1 (e.g., 15, 25)
  static const String _tensSuffix = "mươi"; // Suffix for tens 20-90
  static const String _hundred = "trăm";
  static const String _thousand = "nghìn";
  static const String _connectorZeroTensDefault =
      "linh"; // Connector like 101 ("một trăm linh một")
  static const String _connectorZeroTensAlt =
      "lẻ"; // Alternative connector ("một trăm lẻ một")
  static const String _pointComma = "phẩy"; // For decimal ','
  static const String _pointPeriod = "chấm"; // For decimal '.'
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
  /// Normalizes input (`int`, `double`, `BigInt`, `Decimal`, `String`) to [Decimal].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_options_vi}
  /// Uses [ViOptions] for customization (currency, year format, decimals, AD/BC, linh/lẻ).
  /// Defaults apply if [options] is null or not [ViOptions].
  /// {@endtemplate}
  ///
  /// {@template num2text_process_errors_vi}
  /// Handles `Infinity`, `NaN`. Returns [fallbackOnError] or default Vietnamese error message on failure.
  /// {@endtemplate}
  ///
  /// @param number The number to convert.
  /// @param options Optional [ViOptions] settings.
  /// @param fallbackOnError Optional error string.
  /// @return The number as Vietnamese words or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final ViOptions viOptions =
        options is ViOptions ? options : const ViOptions();
    final String onError = fallbackOnError ?? "Không Phải Là Số";

    if (number is double) {
      if (number.isInfinite) return number.isNegative ? "Âm Vô Cực" : "Vô Cực";
      if (number.isNaN) return onError;
    }

    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return onError;

    if (decimalValue == Decimal.zero) {
      return viOptions.currency
          ? "$_zero ${viOptions.currencyInfo.mainUnitSingular}"
          : _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    try {
      if (viOptions.format == Format.year) {
        textResult = _handleYearFormat(
            absValue.truncate().toBigInt(), viOptions, isNegative);
      } else {
        textResult = viOptions.currency
            ? _handleCurrency(absValue, viOptions)
            : _handleStandardNumber(absValue, viOptions);
        if (isNegative) {
          textResult = "${viOptions.negativePrefix} $textResult";
        }
      }
    } catch (e) {
      // Catch internal errors (e.g., number too large for scales).
      return fallbackOnError ?? 'Lỗi chuyển đổi.';
    }
    return textResult;
  }

  /// Converts an integer year to Vietnamese words, optionally adding era suffixes.
  /// Uses "tư" for 4 in years.
  ///
  /// @param yearValue Absolute integer year value.
  /// @param options Formatting options.
  /// @param isNegative True if original year was negative (BC).
  /// @return The year as Vietnamese words.
  String _handleYearFormat(
      BigInt yearValue, ViOptions options, bool isNegative) {
    // Use "tư" for 4 when formatting years.
    String yearText =
        _convertInteger(yearValue.abs(), useTuForFour: true, options: options);

    if (isNegative) {
      yearText += " Trước Công Nguyên"; // BC
    } else if (options.includeAD) {
      yearText += " Sau Công Nguyên"; // AD
    }
    return yearText;
  }

  /// Converts a non-negative [Decimal] to Vietnamese currency words (VND - Đồng).
  /// Ignores fractional part (no subunits used).
  ///
  /// @param absValue Absolute currency value.
  /// @param options Formatting options.
  /// @return Currency value as Vietnamese words.
  String _handleCurrency(Decimal absValue, ViOptions options) {
    // Vietnamese Đồng doesn't typically use subunits (hào/xu).
    final BigInt mainValue = absValue.truncate().toBigInt();
    if (mainValue == BigInt.zero)
      return "$_zero ${options.currencyInfo.mainUnitSingular}";

    final String mainText = _convertInteger(mainValue, options: options);
    return '$mainText ${options.currencyInfo.mainUnitSingular}'; // e.g., "một nghìn đồng"
  }

  /// Converts a non-negative standard [Decimal] number to Vietnamese words.
  /// Converts integer and fractional parts. Uses [ViOptions.decimalSeparator] word.
  /// Fractional part converted digit by digit.
  ///
  /// @param absValue Absolute decimal value.
  /// @param options Formatting options.
  /// @return Number as Vietnamese words.
  String _handleStandardNumber(Decimal absValue, ViOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue.remainder(Decimal.one);

    final String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart, options: options);

    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      String sepWord;
      switch (options.decimalSeparator) {
        // Default to comma
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          sepWord = _pointPeriod;
          break;
        default:
          sepWord = _pointComma;
          break;
      }

      String fracDigits = fractionalPart.toString().substring(2); // Remove "0."
      // Trim potential trailing zeros (less common with Decimal, but safe).
      while (fracDigits.endsWith('0') && fracDigits.isNotEmpty) {
        fracDigits = fracDigits.substring(0, fracDigits.length - 1);
      }

      if (fracDigits.isNotEmpty) {
        final List<String> digitWords = fracDigits.split('').map((d) {
          return _wordsUnder10[int.parse(d)];
        }).toList();
        fractionalWords = ' $sepWord ${digitWords.join(' ')}';
      }
    }
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts a non-negative integer into Vietnamese words using standard scale.
  /// Handles chunking, scale words, and special Vietnamese rules like padding with "không trăm".
  ///
  /// @param n Non-negative integer.
  /// @param useTuForFour If true, use "tư" instead of "bốn" where applicable.
  /// @param options Formatting options like `useLe`.
  /// @return Integer as Vietnamese words. Returns "không" for 0.
  /// @throws ArgumentError if n is negative or too large.
  String _convertInteger(BigInt n,
      {bool useTuForFour = false, required ViOptions options}) {
    if (n < BigInt.zero) throw ArgumentError("Input must be non-negative: $n");
    if (n == BigInt.zero) return _zero;

    List<String> resultParts = [];
    BigInt tempN = n;
    final BigInt thousand = BigInt.from(1000);
    List<int> chunks = []; // Chunks from left to right

    if (tempN == BigInt.zero)
      chunks.add(0);
    else {
      while (tempN > BigInt.zero) {
        chunks.insert(0, (tempN % thousand).toInt());
        tempN ~/= thousand;
      }
    }

    int totalChunks = chunks.length;
    bool lastChunkWasZero = false; // Track if the preceding chunk was zero
    String connector =
        options.useLe ? _connectorZeroTensAlt : _connectorZeroTensDefault;

    for (int i = 0; i < totalChunks; i++) {
      int chunkValue = chunks[i];
      int scaleIndex = totalChunks - 1 - i; // 0=units, 1=thousands...

      if (chunkValue > 0) {
        String chunkText = _convertChunk(chunkValue,
            options: options, useTuForFour: useTuForFour);
        String scaleWord = _getScaleWord(scaleIndex);

        // Add connector ("linh"/"lẻ") if the previous chunk was zero and this isn't the first chunk.
        if (lastChunkWasZero && resultParts.isNotEmpty) {
          resultParts.add(connector);
        }

        // Add padding ("không trăm [linh]") for units chunk < 100 if needed.
        // Required if: units chunk, value < 100, NOT preceded by zero, not the only chunk.
        if (scaleIndex == 0 &&
            chunkValue < 100 &&
            !lastChunkWasZero &&
            totalChunks > 1) {
          String padding = "$_zero $_hundred";
          // Add connector within padding only if value < 10 (e.g., "không trăm linh một")
          if (chunkValue < 10) padding += " $connector";
          chunkText = "$padding $chunkText";
        }

        resultParts.add(chunkText);
        if (scaleWord.isNotEmpty) resultParts.add(scaleWord);
        lastChunkWasZero = false; // This chunk was non-zero
      } else {
        // Mark if a zero chunk occurs *after* the first non-zero chunk.
        if (resultParts.isNotEmpty) lastChunkWasZero = true;
      }
    }
    return resultParts.where((part) => part.isNotEmpty).join(' ').trim();
  }

  /// Determines the correct scale word (nghìn, triệu, tỷ, etc.) based on chunk index.
  /// Handles scales up to "tỷ tỷ tỷ ..." (quintillion and beyond).
  ///
  /// @param scaleIndex The index of the scale (0 for units, 1 for thousands, 2 for millions...).
  /// @return The appropriate scale word, or empty string for the units chunk.
  String _getScaleWord(int scaleIndex) {
    if (scaleIndex <= 0) return ""; // No scale word for the units chunk.

    final int baseScaleIndex =
        (scaleIndex - 1) % 3; // 0=thousand, 1=million, 2=billion cycle
    final int highScaleLevel =
        (scaleIndex - 1) ~/ 3; // Counts how many 'tỷ' groups are needed

    String scaleWord;
    switch (baseScaleIndex) {
      case 0:
        scaleWord = _thousand;
        break;
      case 1:
        scaleWord = _scaleMillion;
        break;
      case 2:
        scaleWord = _scaleBillion;
        break;
      default:
        scaleWord = "";
        break; // Should not happen
    }

    // Append 'tỷ' for higher scales (trillion, quadrillion, etc.)
    if (highScaleLevel > 0) {
      final String higherScaleSuffix =
          List.filled(highScaleLevel, _scaleBillion).join(' ');
      scaleWord = "$scaleWord $higherScaleSuffix".trim();
    }
    return scaleWord;
  }

  /// Converts an integer from 0 to 999 into Vietnamese words.
  /// Handles special rules for "mốt", "lăm", "tư", and "linh/lẻ" based on context and options.
  ///
  /// @param n Number (0-999).
  /// @param options Formatting options.
  /// @param useTuForFour If true, use "tư" instead of "bốn".
  /// @return Vietnamese text. Returns empty string for 0.
  /// @throws ArgumentError if n is outside 0-999.
  String _convertChunk(int n,
      {required ViOptions options, bool useTuForFour = false}) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    List<String> words = [];
    int hundreds = n ~/ 100;
    int remainder = n % 100;
    int tens = remainder ~/ 10;
    int units = remainder % 10;

    // Hundreds part
    if (hundreds > 0) {
      words.add(_wordsUnder10[hundreds]);
      words.add(_hundred);
    }

    // Tens and Units part
    if (remainder > 0) {
      bool hundredPresent = hundreds > 0;
      // Add connector ("linh" or "lẻ") if hundred exists and tens is zero.
      if (hundredPresent && tens == 0) {
        words.add(
            options.useLe ? _connectorZeroTensAlt : _connectorZeroTensDefault);
      }

      // Tens digit
      if (tens > 0) {
        words.add(tens == 1 ? _ten : "${_wordsUnder10[tens]} $_tensSuffix");
      }

      // Units digit (handling special cases)
      if (units > 0) {
        String unitWord;
        switch (units) {
          case 1:
            unitWord = (tens >= 2) ? _unitOneSpecial : _wordsUnder10[1];
            break;
          case 4:
            unitWord =
                (useTuForFour && (tens >= 2 || (tens == 0 && hundredPresent)))
                    ? _unitFourSpecial
                    : _wordsUnder10[4];
            break;
          case 5:
            unitWord = (tens >= 1) ? _unitFiveSpecial : _wordsUnder10[5];
            break;
          default:
            unitWord = _wordsUnder10[units];
            break;
        }
        words.add(unitWord);
      }
    }
    return words.join(' ');
  }
}
