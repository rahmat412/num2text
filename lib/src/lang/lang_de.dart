import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart';
import '../num2text_base.dart';
import '../options/base_options.dart';
import '../options/de_options.dart';
import '../utils/utils.dart';

/// Internal helper class providing information about large number scales (Million, Milliarde, etc.).
class _ScaleInfo {
  /// The singular form of the scale word (e.g., "Million").
  final String singular;

  /// The plural form of the scale word (e.g., "Millionen").
  final String plural;

  /// Indicates if the scale word is grammatically feminine.
  /// Affects the form of "one" used before it ("eine" vs "ein").
  final bool isFeminine;

  const _ScaleInfo(this.singular, this.plural, this.isFeminine);
}

/// {@template num2text_de}
/// The German language (Lang.DE) implementation for converting numbers to words.
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their German word representation following German grammatical rules (e.g., "einundzwanzig").
///
/// Capabilities include handling cardinal numbers, currency (using [DeOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers (long scale: Million, Milliarde).
/// Distinguishes between "eins" (standalone one) and "ein/eine" (attributive one).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [DeOptions].
/// {@endtemplate}
class Num2TextDE implements Num2TextBase {
  // --- Constants ---

  /// German word for zero.
  static const String _zero = "null";

  /// German word for "hundred".
  static const String _hundred = "hundert";

  /// German word for "thousand".
  static const String _thousand = "tausend";

  /// German word for "one" when preceding a noun or scale word (non-feminine).
  static const String _oneSingular = "ein";

  /// German word for "one" when preceding a feminine noun or scale word.
  static const String _oneFeminine = "eine";

  /// German word for "one" when it stands alone or ends a number group (e.g., 21 -> einundzwanzig ends in 'g', not 's').
  static const String _oneStandalone = "eins";

  /// German word for the decimal separator "point".
  static const String _point = "Punkt";

  /// German word for the decimal separator "comma".
  static const String _comma = "Komma";

  /// German word for "and", used in numbers like "einundzwanzig".
  static const String _and = "und";

  /// Suffix for years BC (Before Christ).
  static const String _yearSuffixBC = "v. Chr.";

  /// Suffix for years AD/CE (Anno Domini / Common Era).
  static const String _yearSuffixAD = "n. Chr.";

  /// Word for positive infinity.
  static const String _infinityPositive = "Unendlich";

  /// Word for negative infinity.
  static const String _infinityNegative = "Negativ Unendlich";

  /// Word for "Not a Number".
  static const String _notANumber = "Keine Zahl";

  /// Words for numbers 0-19. Note: Index 1 is "eins" (standalone form).
  static const List<String> _wordsUnder20 = [
    "null",
    "eins",
    "zwei",
    "drei",
    "vier",
    "fünf",
    "sechs",
    "sieben",
    "acht",
    "neun",
    "zehn",
    "elf",
    "zwölf",
    "dreizehn",
    "vierzehn",
    "fünfzehn",
    "sechzehn", // Note: sechs -> sech
    "siebzehn", // Note: sieben -> sieb
    "achtzehn",
    "neunzehn",
  ];

  /// Words for tens (20, 30,... 90). Index corresponds to tens digit (index 2 = "zwanzig").
  static const List<String> _wordsTens = [
    "", // 0 - unused
    "", // 10 - handled by _wordsUnder20
    "zwanzig",
    "dreißig", // Note: drei -> dreißig (ß)
    "vierzig",
    "fünfzig",
    "sechzig", // Note: sechs -> sech
    "siebzig", // Note: sieben -> sieb
    "achtzig",
    "neunzig",
  ];

  /// Definitions for large number scales (long scale used in German).
  /// Key: power of 10 (e.g., 6 for Million).
  /// Value: [_ScaleInfo] containing singular, plural, and gender information.
  static const Map<int, _ScaleInfo> _scaleWords = {
    6: _ScaleInfo("Million", "Millionen", true), // Feminine
    9: _ScaleInfo("Milliarde", "Milliarden", true), // Feminine
    12: _ScaleInfo("Billion", "Billionen", true), // Feminine
    15: _ScaleInfo("Billiarde", "Billiarden", true), // Feminine
    18: _ScaleInfo("Trillion", "Trillionen", true), // Feminine
    21: _ScaleInfo("Trilliarde", "Trilliarden", true), // Feminine
    24: _ScaleInfo("Quadrillion", "Quadrillionen", true), // Feminine
    // Add more scales here if needed (Quintillion, etc.) following the long scale pattern
  };

  /// Sorted list of scale powers (descending) for processing large numbers efficiently.
  static final List<int> _sortedScalePowers = _scaleWords.keys.toList()
    ..sort((a, b) => b.compareTo(a));

  /// {@macro num2text_base_process}
  ///
  /// [number]: The number to convert (can be `int`, `double`, `BigInt`, `Decimal`, `String`).
  /// [options]: Optional [DeOptions] to customize formatting (e.g., currency, year).
  /// [fallbackOnError]: Optional string to return if conversion fails (e.g., for invalid input).
  ///                    If null, default error messages are used.
  /// Returns the German word representation of the number, or an error/fallback string.
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    final DeOptions deOptions =
        options is DeOptions ? options : const DeOptions();
    final String errorMsg = fallbackOnError ?? _notANumber;

    // Handle special double values first
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative ? _infinityNegative : _infinityPositive;
      }
      if (number.isNaN) {
        return errorMsg;
      }
    }

    // Normalize the input number to Decimal
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Handle invalid or null input
    if (decimalValue == null) {
      return errorMsg;
    }

    // Handle zero separately
    if (decimalValue == Decimal.zero) {
      // Currency format requires unit even for zero
      if (deOptions.currency) {
        // For zero, use the plural form of the currency unit (e.g., "Euro")
        final String zeroUnit = deOptions.currencyInfo.mainUnitPlural ??
            deOptions.currencyInfo.mainUnitSingular;
        return "$_zero $zeroUnit";
      } else {
        return _zero;
      }
    }

    // Determine sign and use absolute value for core conversion
    final bool isNegative = decimalValue.isNegative;
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;

    String textResult;

    // Delegate based on format options
    if (deOptions.format == Format.year) {
      // Year format has specific rules (e.g., 1900 -> neunzehnhundert) and handles its own sign (BC/AD)
      textResult = _handleYearFormat(
          decimalValue.truncate().toBigInt().toInt(), deOptions);
    } else if (deOptions.currency) {
      // Currency format separates main and subunits
      textResult = _handleCurrency(absValue, deOptions);
      // Apply negative prefix if needed (currency handles absolute value)
      if (isNegative) {
        textResult = "${deOptions.negativePrefix} $textResult";
      }
    } else {
      // Standard number format (integers, decimals)
      textResult = _handleStandardNumber(absValue, deOptions);
      // Apply negative prefix if needed (standard handles absolute value)
      if (isNegative) {
        textResult = "${deOptions.negativePrefix} $textResult";
      }
    }

    return textResult;
  }

  /// Handles number conversion specifically for the year format.
  ///
  /// German years between 1100 and 1999 are often read differently
  /// (e.g., 1984 -> "neunzehnhundertvierundachtzig").
  /// Adds "v. Chr." (BC) or "n. Chr." (AD/CE) suffixes based on sign and options.
  ///
  /// [year]: The integer year value.
  /// [options]: The [DeOptions] containing format settings.
  /// Returns the German word representation of the year.
  String _handleYearFormat(int year, DeOptions options) {
    final bool isNegative = year < 0;
    final int absYear = isNegative ? -year : year;
    final BigInt bigAbsYear = BigInt.from(absYear);

    String yearText;

    if (absYear == 0) {
      yearText = _zero; // Technically year 0 doesn't exist, but handle input
    } else if (absYear >= 1100 && absYear < 2000) {
      // Special format: "nineteen hundred eighty-four" style
      final int highPartInt = absYear ~/ 100; // e.g., 19
      final int lowPartInt = absYear % 100; // e.g., 84
      // The high part (e.g., 19) never ends in "eins"
      final String highText = _convertInteger(
        BigInt.from(highPartInt),
        standaloneOneApplies: false,
      );

      if (lowPartInt == 0) {
        // e.g., 1900 -> "neunzehnhundert"
        yearText = "$highText$_hundred";
      } else {
        // e.g., 1984 -> "neunzehnhundert" + "vierundachtzig"
        // The lower part (84) uses standard conversion, potentially ending in "eins"
        final String lowText = _convertInteger(BigInt.from(lowPartInt),
            standaloneOneApplies: true);
        yearText = "$highText$_hundred$lowText";
      }
    } else {
      // Standard conversion for other years (e.g., 1066, 2024)
      // The whole year might end in "eins"
      yearText = _convertInteger(bigAbsYear, standaloneOneApplies: true);
    }

    // Add Era Suffixes
    if (isNegative) {
      yearText += " $_yearSuffixBC";
    } else if (options.includeAD && absYear > 0) {
      yearText += " $_yearSuffixAD";
    }

    return yearText;
  }

  /// Handles number conversion specifically for currency format.
  ///
  /// Separates the number into main units (e.g., Euro) and subunits (e.g., Cent).
  /// Uses singular/plural forms from [CurrencyInfo]. Uses "ein" for 1 main unit.
  ///
  /// [absValue]: The absolute decimal value of the currency amount.
  /// [options]: The [DeOptions] containing currency settings and [CurrencyInfo].
  /// Returns the German word representation of the currency amount.
  String _handleCurrency(Decimal absValue, DeOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    const int decimalPlaces = 2; // Standard for most currencies
    final Decimal subunitMultiplier = Decimal.fromInt(100);

    // Round the value if specified (typically to 2 decimal places for currency)
    final Decimal valueToConvert =
        options.round ? absValue.round(scale: decimalPlaces) : absValue;

    // Separate main and subunit values
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    // Calculate subunits carefully to avoid floating-point issues
    final BigInt subunitValue =
        ((valueToConvert - Decimal.fromBigInt(mainValue)) * subunitMultiplier)
            .round(scale: 0)
            .toBigInt();

    // Case 1: Only subunits (e.g., 0.99 Euro -> "neunundneunzig Cent")
    if (mainValue == BigInt.zero && subunitValue > BigInt.zero) {
      // Subunit part can end in "eins"
      final String subunitText =
          _convertInteger(subunitValue, standaloneOneApplies: true);
      // Determine subunit name (singular/plural)
      final String subUnitName = (subunitValue == BigInt.one)
          ? currencyInfo.subUnitSingular!
          : currencyInfo.subUnitPlural ?? currencyInfo.subUnitSingular!;
      return '$subunitText $subUnitName';
    }

    // Case 2: Zero value (e.g., 0 Euro -> "null Euro")
    if (mainValue == BigInt.zero && subunitValue == BigInt.zero) {
      // Use plural main unit for zero, if available, otherwise singular
      final String mainUnitName =
          currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;
      return "$_zero $mainUnitName";
    }

    // Case 3: Main value present (with or without subunits)
    final List<String> parts = [];

    // Convert main value
    // Use "ein" for 1 Euro, not "eins"
    final String mainText =
        _convertInteger(mainValue, standaloneOneApplies: false);
    // Determine main unit name (singular/plural)
    final String mainUnitName = (mainValue == BigInt.one)
        ? currencyInfo.mainUnitSingular
        : currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;
    parts.add('$mainText $mainUnitName');

    // Add subunits if present
    if (subunitValue > BigInt.zero) {
      // Use "eins" for 1 Cent (standalone)
      final String subunitText =
          _convertInteger(subunitValue, standaloneOneApplies: true);
      // Determine subunit name (singular/plural)
      final String subUnitName = (subunitValue == BigInt.one)
          ? currencyInfo.subUnitSingular!
          : currencyInfo.subUnitPlural ?? currencyInfo.subUnitSingular!;

      // Add separator (e.g., "und") if defined
      if (currencyInfo.separator != null) {
        parts.add(currencyInfo.separator!);
      } else {
        parts.add(_and); // Default separator
      }
      parts.add('$subunitText $subUnitName');
    }

    return parts.join(' ');
  }

  /// Handles standard number conversion (integers and decimals).
  ///
  /// Converts the integer part and the fractional part separately
  /// and joins them with the appropriate decimal separator word.
  /// Handles the "eins" vs "ein" distinction correctly.
  ///
  /// [absValue]: The absolute decimal value of the number.
  /// [options]: The [DeOptions] containing decimal separator preference.
  /// Returns the German word representation of the number.
  String _handleStandardNumber(Decimal absValue, DeOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();

    // Determine if the integer part, if it ends in 1, should use "eins".
    // Applies if the integer part *is* 1, or ends in 1 *and* is not part of a compound like 21, 31...
    final bool standaloneOneApplies = _isStandaloneOne(integerPart);

    // Convert the integer part
    // Handle case where integer part is zero but decimal part exists (e.g., 0.5 -> "null Komma fünf")
    final String integerWords =
        (integerPart == BigInt.zero && absValue != Decimal.zero)
            ? _zero
            : _convertInteger(integerPart,
                standaloneOneApplies: standaloneOneApplies);

    String fractionalWords = '';

    // Convert the fractional part if it exists
    if (!absValue.isInteger) {
      // Determine the separator word ("Komma" or "Punkt")
      final String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.period:
        case DecimalSeparator.point:
          separatorWord = _point;
          break;
        case DecimalSeparator.comma:
        default: // Default to comma for German
          separatorWord = _comma;
          break;
      }

      // Get fractional digits as string, remove leading '0.'
      String digitsStr = absValue.toString();
      int dotIndex = digitsStr.indexOf('.');
      if (dotIndex != -1) {
        digitsStr = digitsStr.substring(dotIndex + 1);
      } else {
        digitsStr = ""; // Should not happen if !isInteger, but safeguard
      }

      // Trim trailing zeros
      digitsStr = digitsStr.replaceAll(RegExp(r'0+$'), '');

      if (digitsStr.isNotEmpty) {
        // Convert each digit to its word form
        final List<String> digitWords = [];
        for (int i = 0; i < digitsStr.length; i++) {
          final int? digitInt = int.tryParse(digitsStr[i]);
          if (digitInt != null && digitInt >= 0 && digitInt <= 9) {
            // Digits after decimal point are read individually using "eins" for 1
            digitWords.add(_wordsUnder20[digitInt]);
          } else {
            digitWords.add('?'); // Should not happen with normalized input
          }
        }
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }

    // Combine integer and fractional parts
    return '$integerWords$fractionalWords'.trim();
  }

  /// Determines if the number '1' should be represented as standalone "eins".
  ///
  /// This is true if the number is exactly 1, or if it ends in 1
  /// BUT is not part of a teen number (11-19) or a compound number
  /// like 21, 31, 41, etc. (where it becomes "einund...").
  ///
  /// [n]: The integer number to check.
  /// Returns `true` if "eins" should be used, `false` if "ein" should be used.
  bool _isStandaloneOne(BigInt n) {
    if (n <= BigInt.zero) return false; // Only applies to positive numbers
    if (n == BigInt.one) return true;

    final BigInt lastDigit = n % BigInt.from(10);
    final BigInt tensAndUnits = n % BigInt.from(100);

    // If it doesn't end in 1, "eins" is not applicable.
    if (lastDigit != BigInt.one) return false;

    // Check if it's part of a teen number (11). 11 is handled directly.
    if (tensAndUnits == BigInt.from(11)) return false; // "elf" uses neither

    // Check if it's part of a compound "und" number (21, 31, ..., 91)
    if (tensAndUnits > BigInt.from(20) && lastDigit == BigInt.one) {
      return false; // "einund..." uses "ein"
    }

    // If it ends in 1 and is not a teen or compound "und" number (e.g., 101, 1001)
    return true;
  }

  /// Converts a non-negative integer ([BigInt]) into German words.
  ///
  /// Main recursive function for integer conversion, handling scales.
  /// It determines whether the number "one" should be rendered as "eins" (standalone)
  /// or "ein/eine" (attributive) based on the context.
  ///
  /// [n]: The non-negative integer to convert.
  /// [standaloneOneApplies]: Whether the "eins" rule applies if `n` is or ends in 1
  ///                         in the final, least significant part of the number.
  /// Returns the German word representation of the integer.
  /// @throws ArgumentError if `n` is negative.
  String _convertInteger(BigInt n, {required bool standaloneOneApplies}) {
    if (n < BigInt.zero) {
      // This function expects non-negative input; sign is handled by the caller.
      throw ArgumentError(
          "Internal error: _convertInteger called with negative input: $n");
    }
    if (n == BigInt.zero) return _zero;

    // Base case: 1 requires special handling based on context
    if (n == BigInt.one) {
      return standaloneOneApplies ? _oneStandalone : _oneSingular;
    }

    // Handle numbers less than 1 million by dedicated function
    if (n < BigInt.from(1000000)) {
      return _convertUnderMillion(n.toInt(),
          standaloneOneApplies: standaloneOneApplies);
    }

    // Handle large numbers using scales (Million, Milliarde, etc.)
    final List<String> resultParts = [];
    BigInt remaining = n;
    bool firstSegment = true; // To avoid leading space

    // Iterate through scales from largest to smallest
    for (final int power in _sortedScalePowers) {
      final BigInt scaleDivisor = BigInt.from(10).pow(power);

      if (remaining >= scaleDivisor) {
        // How many of this scale unit? (e.g., 123 Billion)
        final BigInt count = remaining ~/ scaleDivisor;
        final _ScaleInfo scaleInfo = _scaleWords[power]!;

        // Convert the count (e.g., 123)
        final String countText;
        if (count == BigInt.one) {
          // Use "eine" for feminine scales (Million, Milliarde...)
          // Use "ein" for hypothetical non-feminine scales
          countText = scaleInfo.isFeminine ? _oneFeminine : _oneSingular;
        } else {
          // For counts > 1 (e.g., "zwei Millionen"), the count part itself never ends in standalone "eins".
          countText = _convertInteger(count, standaloneOneApplies: false);
        }

        // Get the scale word (singular or plural)
        final String scaleWord =
            (count == BigInt.one) ? scaleInfo.singular : scaleInfo.plural;

        // Add space if not the first part
        if (!firstSegment) {
          resultParts.add(" ");
        }
        resultParts.add("$countText $scaleWord");
        firstSegment = false;

        // Update the remainder
        remaining %= scaleDivisor;
      }
    }

    // Convert the remaining part (less than the smallest scale, i.e., < 1 Million)
    if (remaining > BigInt.zero) {
      if (!firstSegment) {
        resultParts.add(" ");
      }
      // The final remaining part might end in standalone "eins", use the passed flag.
      resultParts.add(
        _convertUnderMillion(remaining.toInt(),
            standaloneOneApplies: standaloneOneApplies),
      );
    }

    return resultParts.join('');
  }

  /// Converts an integer between 0 and 999,999 into German words.
  ///
  /// Helper for [_convertInteger]. Separates thousands and the remaining part.
  ///
  /// [n]: The integer to convert (0 <= n < 1,000,000).
  /// [standaloneOneApplies]: Whether the "eins" rule applies if the number ends in 1.
  /// Returns the German word representation.
  /// @throws ArgumentError if `n` is out of range.
  String _convertUnderMillion(int n, {required bool standaloneOneApplies}) {
    if (n == 0) return ""; // Return empty string, not "null"
    if (n < 0 || n >= 1000000) {
      throw ArgumentError(
        "Internal error: _convertUnderMillion called with out-of-range input: $n",
      );
    }

    // Handle 1 according to the "eins" rule passed down
    if (n == 1) return standaloneOneApplies ? _oneStandalone : _oneSingular;

    final List<String> parts = [];
    int remainder = n;

    // Handle thousands part
    if (remainder >= 1000) {
      final int thousandsPart = remainder ~/ 1000;
      // The thousands part (e.g., "einhundertdreiundzwanzig" in 123456)
      // never ends in a standalone "eins". It's always followed by "tausend".
      parts.add(_convertChunk(thousandsPart, standaloneOneApplies: false));
      parts.add(_thousand);
      remainder %= 1000;
    }

    // Handle remaining part (0-999)
    if (remainder > 0) {
      // This is the final chunk, so the "eins" rule applies here.
      parts.add(
          _convertChunk(remainder, standaloneOneApplies: standaloneOneApplies));
    }

    // Join parts (no spaces needed, handled by chunk logic)
    return parts.join('');
  }

  /// Converts an integer between 0 and 999 into German words.
  ///
  /// Base building block. Handles hundreds, tens, and units ("einundzwanzig" structure).
  ///
  /// [n]: The integer chunk to convert (0 <= n < 1000).
  /// [standaloneOneApplies]: Whether the "eins" rule applies if `n` is or ends in 1.
  /// Returns the German word representation.
  /// @throws ArgumentError if `n` is out of range.
  String _convertChunk(int n, {required bool standaloneOneApplies}) {
    if (n == 0) return "";
    if (n < 0 || n >= 1000) {
      throw ArgumentError(
          "Internal error: _convertChunk called with out-of-range input: $n");
    }

    // Handle 1 according to the rule
    if (n == 1) {
      return standaloneOneApplies ? _oneStandalone : _oneSingular;
    }

    final List<String> words = [];
    int remainder = n;

    // Handle hundreds part
    if (remainder >= 100) {
      final int hundredsDigit = remainder ~/ 100;
      // Use "ein" for 100, not "eins"
      words.add(
          hundredsDigit == 1 ? _oneSingular : _wordsUnder20[hundredsDigit]);
      words.add(_hundred);
      remainder %= 100;
    }

    // Handle remaining part (0-99)
    if (remainder > 0) {
      if (remainder == 1) {
        // Apply the "eins" rule for the final 1
        words.add(standaloneOneApplies ? _oneStandalone : _oneSingular);
      } else if (remainder < 20) {
        // Use direct lookup for 2-19
        words.add(_wordsUnder20[remainder]);
      } else {
        // Handle 20-99: Structure is "Unit + und + Ten" (e.g., einundzwanzig)
        final int unit = remainder % 10;
        final String tensWord = _wordsTens[remainder ~/ 10];

        if (unit > 0) {
          // Unit part uses "ein" for 1 (e.g., einundzwanzig), never standalone "eins"
          words.add(unit == 1 ? _oneSingular : _wordsUnder20[unit]);
          words.add(_and);
        }
        words.add(tensWord);
      }
    }

    // Join parts without spaces (concatenated structure in German)
    return words.join('');
  }
}
