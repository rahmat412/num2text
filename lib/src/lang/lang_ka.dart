import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/ka_options.dart';
import '../utils/utils.dart';

/// {@template num2text_ka}
/// The Georgian language (Lang.KA) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Georgian (ქართული) word representation following Georgian grammar rules.
///
/// Capabilities include handling cardinal numbers, currency (using [KaOptions.currencyInfo] - defaults to GEL),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers using Georgian scale words
/// (ათასი, მილიონი, etc.). It correctly uses the Georgian vigesimal (base-20) system for numbers under 100
/// and applies stem forms for hundred/thousand where appropriate.
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [KaOptions].
/// {@endtemplate}
class Num2TextKA implements Num2TextBase {
  // --- Constants for Georgian Words ---

  /// The Georgian word for zero: "ნული" (nuli).
  static const String _zero = "ნული";

  /// The Georgian word for the decimal separator comma: "მძიმე" (mdzime).
  /// Used when [DecimalSeparator.comma] is selected.
  static const String _pointComma = "მძიმე";

  /// The Georgian word for the decimal separator period or point: "წერტილი" (ts'ert'ili).
  /// Used when [DecimalSeparator.period] or [DecimalSeparator.point] is selected.
  static const String _pointPeriod = "წერტილი";

  /// The default separator word between the main unit and subunits in currency: " და " ( da - and ).
  /// Used if [CurrencyInfo.separator] is null. Note the spaces for proper joining.
  static const String _currencySeparatorDefault = " და ";

  /// The stem form of the Georgian word for thousand: "ათას" (atas).
  /// Used when 'thousand' is followed by smaller units (e.g., 1001: "ათას ერთი").
  static const String _thousandStem = "ათას";

  /// The full Georgian word for thousand: "ათასი" (atasi).
  /// Used for 1000 and multiples when not followed by smaller units (e.g., 1000: "ათასი").
  static const String _thousand = "ათასი";

  /// The stem form of the Georgian word for hundred: "ას" (as).
  /// Used when 'hundred' is followed by smaller units (e.g., 101: "ას ერთი").
  static const String _hundredStem = "ას";

  /// The full Georgian word for hundred: "ასი" (asi).
  /// Used for 100 and multiples when not followed by smaller units (e.g., 100: "ასი").
  static const String _hundred = "ასი";

  /// The Georgian suffix for positive years in AD/CE: " ჩვენი წელთაღრიცხვით" ( chveni ts'elt'aghric'khvit - of our era ).
  /// Appended when [Format.year] is used and [KaOptions.includeAD] is true. Note leading space.
  static const String _yearSuffixAD = " ჩვენი წელთაღრიცხვით";

  /// The Georgian suffix for negative years in BC/BCE: " ჩვენს წელთაღრიცხვამდე" ( chvens ts'elt'aghric'khvamde - before our era ).
  /// Appended when [Format.year] is used and the year is negative. Note leading space.
  static const String _yearSuffixBC = " ჩვენს წელთაღრიცხვამდე";

  /// The Georgian word for infinity: "უსასრულობა" (usasruloba).
  static const String _infinity = "უსასრულობა";

  /// The Georgian text returned for Not-a-Number (NaN) or invalid numeric inputs if no custom fallback is provided ("არა რიცხვი").
  static const String _nan = "არა რიცხვი";

  /// Maps unit digits (1 to 19) to their Georgian word representations.
  static const Map<int, String> _units = {
    1: "ერთი", // erti
    2: "ორი", // ori
    3: "სამი", // sami
    4: "ოთხი", // otkhi
    5: "ხუთი", // khuti
    6: "ექვსი", // ekvsi
    7: "შვიდი", // shvidi
    8: "რვა", // rva
    9: "ცხრა", // tskhra
    10: "ათი", // ati
    11: "თერთმეტი", // tertmet'i
    12: "თორმეტი", // tormet'i
    13: "ცამეტი", // tsamet'i
    14: "თოთხმეტი", // totkhmet'i
    15: "თხუთმეტი", // tkhutmet'i
    16: "თექვსმეტი", // tekvsmet'i
    17: "ჩვიდმეტი", // chvidmet'i
    18: "თვრამეტი", // tvramet'i
    19: "ცხრამეტი", // tskhramet'i
  };

  /// Maps base-20 tens (20, 40, 60, 80) to their full Georgian word representations.
  static const Map<int, String> _tens = {
    20: "ოცი", // otsi
    40: "ორმოცი", // ormotsi
    60: "სამოცი", // samotsi
    80: "ოთხმოცი", // otkhmotsi
  };

  /// Maps base-20 tens (20, 40, 60, 80) to their stem forms used in compound numbers (e.g., "ოცდა" - otsda for 21-39).
  /// These are combined with units using "და" (da - and).
  static const Map<int, String> _tensStems = {
    20: "ოც", // ots
    40: "ორმოც", // ormots
    60: "სამოც", // samots
    80: "ოთხმოც", // otkhmots
  };

  /// Maps digits 2-9 to their prefixes used for forming hundreds (e.g., "ორ" + "ასი" = "ორასი" - 200).
  /// 'ასი' itself is used for 100.
  static const Map<int, String> _hundredsPrefix = {
    2: "ორ", // or
    3: "სამ", // sam
    4: "ოთხ", // otkh
    5: "ხუთ", // khut
    6: "ექვს", // ekvs
    7: "შვიდ", // shvid
    8: "რვა", // rva
    9: "ცხრა", // tskhra
  };

  /// Defines the scale words (thousand, million, billion, etc.) used for large numbers in Georgian.
  /// Index corresponds to the power of 1000.
  static const List<String> _scaleWords = [
    "", // Units (10^0)
    _thousand, // Thousand (10^3) - Note: Special stem logic applies via _convertInteger
    "მილიონი", // Milioni (Million - 10^6)
    "მილიარდი", // Miliardi (Billion - 10^9)
    "ტრილიონი", // T'rilioni (Trillion - 10^12)
    "კვადრილიონი", // K'vadriilioni (Quadrillion - 10^15)
    "კვინტილიონი", // K'vint'ilioni (Quintillion - 10^18)
    "სექსტილიონი", // Sekst'ilioni (Sextillion - 10^21)
    "სეპტილიონი", // Sept'ilioni (Septillion - 10^24)
    // Add more scale words as needed
  ];

  /// Processes the given number for conversion into Georgian words.
  ///
  /// Main entry point that normalizes the input, handles special cases (zero, NaN, infinity),
  /// determines the sign, and delegates to specific formatting handlers based on [KaOptions].
  ///
  /// - [number]: The number to be converted (can be `int`, `double`, `BigInt`, `Decimal`, `String`).
  /// - [options]: Optional [KaOptions] to customize output (currency, year, decimals). Defaults are used if null or not [KaOptions].
  /// - [fallbackOnError]: Optional string returned on conversion failure. Defaults to "არა რიცხვი".
  ///
  /// Returns the Georgian word representation or an error string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure correct options type or use defaults.
    final KaOptions kaOptions =
        options is KaOptions ? options : const KaOptions();
    // Determine error fallback string.
    final String errorFallback = fallbackOnError ?? _nan;

    // Handle special double values.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? '${kaOptions.negativePrefix} $_infinity'
            : _infinity;
      }
      if (number.isNaN) {
        return errorFallback;
      }
    }

    // Normalize to Decimal.
    final Decimal? decimalValue = Utils.normalizeNumber(number);
    if (decimalValue == null) return errorFallback;

    // Handle zero.
    if (decimalValue == Decimal.zero) {
      if (kaOptions.currency) {
        // Use plural for zero currency, fallback to singular if needed.
        return "$_zero ${kaOptions.currencyInfo.mainUnitPlural ?? kaOptions.currencyInfo.mainUnitSingular}";
      }
      return _zero;
    }

    // Determine sign and get absolute value.
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;
    // Apply formatting based on options.
    if (kaOptions.format == Format.year) {
      // Handle year formatting.
      textResult =
          _handleYearFormat(decimalValue.truncate().toBigInt(), kaOptions);
    } else {
      // Handle currency or standard number formatting.
      if (kaOptions.currency) {
        textResult = _handleCurrency(absValue, kaOptions);
      } else {
        textResult = _handleStandardNumber(absValue, kaOptions);
      }
      // Prepend negative prefix if needed.
      if (isNegative) {
        textResult = "${kaOptions.negativePrefix} $textResult";
      }
    }
    return textResult;
  }

  /// Formats an integer as a year in Georgian, optionally adding era suffixes (BC/AD).
  ///
  /// - [year]: The year value as a BigInt (can be negative for BC).
  /// - [options]: [KaOptions] containing formatting preferences (specifically `includeAD`).
  ///
  /// Returns the year value in Georgian words, with era suffixes appended as appropriate.
  String _handleYearFormat(BigInt year, KaOptions options) {
    final bool isNegative = year < BigInt.zero;
    final BigInt absYear = isNegative ? -year : year;

    // Convert the absolute year value to words.
    String yearText = _convertInteger(absYear);

    // Add era suffixes.
    if (isNegative) {
      yearText += _yearSuffixBC; // Add BC suffix.
    } else if (options.includeAD) {
      yearText += _yearSuffixAD; // Add AD suffix if requested.
    }
    return yearText;
  }

  /// Formats a non-negative decimal number as currency in Georgian (Lari and Tetri).
  ///
  /// Uses [CurrencyInfo] from [KaOptions] for unit names and separator.
  ///
  /// - [absValue]: The absolute decimal value of the currency amount (non-negative).
  /// - [options]: [KaOptions] including currency settings ([currencyInfo], `round`).
  ///
  /// Returns the currency amount in Georgian words.
  String _handleCurrency(Decimal absValue, KaOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final bool round = options.round;
    const int decimalPlaces = 2; // Standard for Lari/Tetri.
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round if requested.
    Decimal valueToConvert =
        round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main and subunit values.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    final BigInt subunitValue =
        (fractionalPart * subunitMultiplier).truncate().toBigInt();

    // Convert main unit value to words.
    String mainText = _convertInteger(mainValue);
    // Determine main unit name (singular/plural).
    String mainUnitName = (mainValue == BigInt.one)
        ? currencyInfo.mainUnitSingular
        : currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;

    // Start building result.
    String result = '$mainText $mainUnitName';

    // Add subunit part if applicable.
    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      // Convert subunit value to words.
      String subunitText = _convertInteger(subunitValue);
      // Determine subunit name (singular/plural).
      String subUnitName = (subunitValue == BigInt.one)
          ? currencyInfo.subUnitSingular!
          : currencyInfo.subUnitPlural ?? currencyInfo.subUnitSingular!;

      // Get separator, use default if null.
      String separator =
          (currencyInfo.separator ?? _currencySeparatorDefault).trim();

      // Append subunit part.
      result += ' $separator $subunitText $subUnitName';
    }
    return result;
  }

  /// Formats a non-negative standard number (integer or decimal) in Georgian.
  ///
  /// Converts integer and fractional parts separately.
  ///
  /// - [absValue]: The absolute decimal value (non-negative).
  /// - [options]: [KaOptions] for formatting preferences (specifically `decimalSeparator`).
  ///
  /// Returns the standard number in Georgian words.
  String _handleStandardNumber(Decimal absValue, KaOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();

    // Convert integer part. Use "ნული" if integer is 0 but decimal exists.
    String integerWords =
        (integerPart == BigInt.zero && fractionalPart > Decimal.zero)
            ? _zero
            : _convertInteger(integerPart);

    // Convert fractional part if it exists.
    String fractionalWords = '';
    if (fractionalPart > Decimal.zero) {
      fractionalWords = _convertFractional(absValue, options);
    }

    // Combine parts.
    return '$integerWords$fractionalWords'.trim();
  }

  /// Converts the fractional part of a decimal number to Georgian words.
  ///
  /// Uses the decimal separator word specified in [KaOptions].
  ///
  /// - [value]: The full decimal number.
  /// - [options]: [KaOptions] specifying the `decimalSeparator`.
  ///
  /// Returns the fractional part in Georgian words (e.g., " მძიმე ხუთი ექვსი").
  String _convertFractional(Decimal value, KaOptions options) {
    // Determine the decimal separator word.
    String separatorWord;
    switch (options.decimalSeparator) {
      case DecimalSeparator.period:
      case DecimalSeparator.point:
        separatorWord = _pointPeriod; // "წერტილი"
        break;
      case DecimalSeparator.comma:
      default: // Default to comma
        separatorWord = _pointComma; // "მძიმე"
        break;
    }
    // Extract fractional digits.
    String fractionalDigits = value.toString().split('.').last;
    // Remove trailing zeros.
    fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');
    if (fractionalDigits.isEmpty)
      return ""; // Return empty if only zeros after decimal

    // Convert each digit to its word.
    List<String> digitWords = fractionalDigits.split('').map((digit) {
      final int digitInt = int.parse(digit);
      return (digitInt == 0
          ? _zero // "ნული" for 0
          : _units[digitInt]!); // Word from _units map for 1-9
    }).toList();

    // Join with spaces and prepend separator.
    return ' $separatorWord ${digitWords.join(' ')}';
  }

  /// Converts a non-negative integer (BigInt) to Georgian words, handling scales.
  ///
  /// Processes the number in chunks of 1000, applying scale words (ათასი, მილიონი, etc.).
  /// Uses stem form "ათას" when appropriate.
  ///
  /// - [n]: The non-negative integer to convert.
  ///
  /// Returns the integer `n` in Georgian words.
  /// Throws [ArgumentError] if `n` is negative or too large for defined scales.
  String _convertInteger(BigInt n) {
    if (n == BigInt.zero) return _zero;
    if (n < BigInt.zero)
      throw ArgumentError("Integer must be non-negative: $n");

    List<String> parts = [];
    BigInt originalN = n; // Keep original for thousand stem check.
    BigInt remaining = n;
    int scaleIndex = 0;

    while (remaining > BigInt.zero) {
      int chunk = (remaining % BigInt.from(1000)).toInt();
      remaining ~/= BigInt.from(1000);

      if (chunk > 0) {
        String chunkText = _convertChunk(chunk);
        String scaleWordText = "";

        if (scaleIndex > 0) {
          // Scales: thousand, million, etc.
          if (scaleIndex >= _scaleWords.length) {
            throw ArgumentError(
                "Number too large for defined scales: $originalN");
          }
          String currentScaleWord = _scaleWords[scaleIndex];

          if (scaleIndex == 1) {
            // Thousand scale
            // Check if lower chunk exists (units/tens/hundreds part of original number)
            bool hasLowerChunk = originalN % BigInt.from(1000) != BigInt.zero;
            // Use stem "ათას" if followed by lower chunk, otherwise full "ათასი"
            String thousandForm = hasLowerChunk ? _thousandStem : _thousand;

            if (chunk == 1) {
              scaleWordText = thousandForm; // e.g., "ათას" or "ათასი"
            } else {
              scaleWordText = "$chunkText $thousandForm"; // e.g., "ორი ათასი"
            }
          } else {
            // Million, Billion, etc. scales
            if (chunk == 1) {
              // Prepend "ერთი" for one million, one billion, etc.
              scaleWordText = "${_units[1]!} $currentScaleWord";
            } else {
              scaleWordText =
                  "$chunkText $currentScaleWord"; // e.g., "ორი მილიონი"
            }
          }
        } else {
          // Base scale (units)
          scaleWordText = chunkText;
        }
        // Insert at the beginning to build from largest scale down.
        parts.insert(0, scaleWordText);
      }
      scaleIndex++;
    }
    // Join parts with spaces.
    return parts.join(' ');
  }

  /// Converts a number chunk (0-999) to Georgian words.
  ///
  /// Handles hundreds and numbers under 100 using [_convertUnder100].
  /// Uses stem form "ას" when appropriate.
  ///
  /// - [n]: The number chunk (0-999).
  ///
  /// Returns the Georgian word representation of the chunk. Empty string for 0.
  /// Throws [ArgumentError] if `n` is outside the range [0, 999].
  String _convertChunk(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000)
      throw ArgumentError("Chunk must be between 0 and 999: $n");

    // Handle numbers under 100 directly.
    if (n < 100) return _convertUnder100(n);

    // Handle hundreds (100-999).
    int hundredDigit = n ~/ 100;
    int remainder = n % 100;
    String remainderText = _convertUnder100(remainder);
    // Use stem form "ას" if there's a non-zero remainder.
    bool useStem = remainder > 0;

    String hundredText;
    if (hundredDigit == 1) {
      // 100: "ასი" or "ას"
      hundredText = useStem ? _hundredStem : _hundred;
    } else {
      // 200-900: Prefix + "ასი" or "ას"
      String prefix = _hundredsPrefix[hundredDigit]!;
      hundredText = useStem ? "$prefix$_hundredStem" : "$prefix$_hundred";
    }

    // Combine hundred part and remainder part.
    return remainderText.isEmpty ? hundredText : "$hundredText $remainderText";
  }

  /// Converts a number under 100 (0-99) to Georgian words using the vigesimal system.
  ///
  /// - [n]: The number (0-99).
  ///
  /// Returns the Georgian word representation. Empty string for 0.
  /// Throws [ArgumentError] if `n` is outside the range [0, 99].
  String _convertUnder100(int n) {
    if (n == 0) return "";
    if (n < 0 || n >= 100)
      throw ArgumentError("Number must be between 0 and 99: $n");

    // Numbers 1-19 have unique names.
    if (n <= 19) return _units[n]!;

    // Base-20 tens (20, 40, 60, 80) have unique names.
    if (_tens.containsKey(n)) return _tens[n]!;

    // Construct numbers between base-20 tens (e.g., 21-39, 41-59...).
    int base;
    if (n > 80) {
      base = 80; // 81-99 -> base 80 (ოთხმოცი)
    } else if (n > 60) {
      base = 60; // 61-79 -> base 60 (სამოცი)
    } else if (n > 40) {
      base = 40; // 41-59 -> base 40 (ორმოცი)
    } else {
      base = 20; // 21-39 -> base 20 (ოცი)
    }

    int remainder = n - base;
    String baseStem = _tensStems[base]!; // Get stem (e.g., "ოც").
    String unitWord = _units[remainder]!; // Get unit word (e.g., "ერთი").

    // Combine stem + "და" + unit word (e.g., "ოც" + "და" + "ერთი" = "ოცდაერთი").
    return "$baseStemდა$unitWord";
  }
}
