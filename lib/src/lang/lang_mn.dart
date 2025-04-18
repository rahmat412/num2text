import 'package:decimal/decimal.dart';

import '../concurencies/concurencies_info.dart'; // Defines currency structures.
import '../num2text_base.dart'; // Base class contract.
import '../options/base_options.dart'; // Base options and enums like Format, DecimalSeparator.
import '../options/mn_options.dart'; // Mongolian-specific options.
import '../utils/utils.dart'; // Utilities like number normalization.

/// {@template num2text_mn}
/// The Mongolian language (`Lang.MN`) implementation for converting numbers to words (using Cyrillic script).
///
/// Implements the [Num2TextBase] contract, accepting various numeric inputs (`int`, `double`,
/// `BigInt`, `Decimal`, `String`) via its `process` method. It converts these inputs
/// into their Mongolian word representation following standard Mongolian grammar and vocabulary.
///
/// Capabilities include handling cardinal numbers, currency (using [MnOptions.currencyInfo]),
/// year formatting ([Format.year]), negative numbers, decimals, and large numbers using the
/// short scale system (сая, тэрбум, их наяд, etc.). It handles vowel harmony implicitly through the defined word forms
/// and applies appropriate word forms based on whether a number word precedes another significant word (scale, unit, etc.).
/// Invalid inputs result in a fallback message.
///
/// Behavior can be customized using [MnOptions].
/// {@endtemplate}
class Num2TextMN implements Num2TextBase {
  // --- Constants ---

  /// The word for the decimal separator when using a period (`.`) ("цэг" - tseg).
  static const String _decimalPointWord = "цэг";

  /// The word for the decimal separator when using a comma (`,`) ("таслал" - taslal).
  static const String _decimalCommaWord = "таслал";

  /// The word for zero ("тэг").
  static const String _zero = "тэг";

  /// The word for positive infinity ("Хязгааргүй" - Khyazgaargüi).
  static const String _infinity = "Хязгааргүй";

  /// The word for negative infinity ("Сөрөг хязгааргүй" - Sörög khyazgaargüi).
  static const String _negativeInfinity = "Сөрөг хязгааргүй";

  /// Default error message for invalid number input ("Тоо биш" - Too bish).
  static const String _notANumber = "Тоо биш";

  /// The suffix for negative years ("Нийтийн Тооллын Өмнөх" - Before Common Era).
  static const String _yearSuffixBC = "НТӨ";

  /// The suffix for positive years ("Нийтийн Тоолол" - Common Era). Added only if [MnOptions.includeAD] is true.
  static const String _yearSuffixAD = "НТ";

  /// Base forms for units 1-9.
  static const List<String> _units = [
    "", // 0 - Not used directly
    "нэг", // 1 - neg
    "хоёр", // 2 - khoyor
    "гурав", // 3 - gurav
    "дөрөв", // 4 - döröv
    "тав", // 5 - tav
    "зургаа", // 6 - zurgaa
    "долоо", // 7 - doloo
    "найм", // 8 - naim
    "ес", // 9 - yes
  ];

  /// Modified forms for units 3-9, used when followed by a word starting with a consonant
  /// or when preceding certain grammatical contexts (like scale words, "зуун").
  /// Typically involves adding a final 'н'.
  static const Map<int, String> _unitsModified = {
    3: "гурван", // gurvan
    4: "дөрвөн", // dörvön
    5: "таван", // tavan
    6: "зургаан", // zurgaan
    7: "долоон", // doloon
    8: "найман", // naiman
    9: "есөн", // yesön
  };

  /// Word forms for teens 10-19.
  static const List<String> _teens = [
    "арав", // 10 - arav
    "арван нэг", // 11 - arvan neg
    "арван хоёр", // 12 - arvan khoyor
    "арван гурав", // 13 - arvan gurav
    "арван дөрөв", // 14 - arvan döröv
    "арван тав", // 15 - arvan tav
    "арван зургаа", // 16 - arvan zurgaa
    "арван долоо", // 17 - arvan doloo
    "арван найм", // 18 - arvan naim
    "арван ес", // 19 - arvan yes
  ];

  /// Standalone forms for tens 10-90 (used when they are the final part of a chunk).
  /// Index corresponds to the tens digit (index 1 = 10, index 9 = 90).
  static const List<String> _tensStandalone = [
    "", // 0
    "арав", // 10 - arav
    "хорь", // 20 - khor'
    "гуч", // 30 - guch
    "дөч", // 40 - döch
    "тавь", // 50 - tav'
    "жар", // 60 - jar
    "дал", // 70 - dal
    "ная", // 80 - naya
    "ер", // 90 - yer
  ];

  /// Combined forms for tens 10-90 (used when followed by a unit digit 1-9).
  /// Index corresponds to the tens digit.
  static const List<String> _tensCombined = [
    "", // 0
    "арван", // 10 - arvan (used in teens)
    "хорин", // 20 - khorin
    "гучин", // 30 - guchin
    "дөчин", // 40 - döchin
    "тавин", // 50 - tavin
    "жаран", // 60 - jaran
    "далан", // 70 - dalan
    "наян", // 80 - nayan
    "ерэн", // 90 - yeren
  ];

  /// Standalone word for hundred ("зуу"), used when it's the exact value or the end of a number.
  static const String _hundredStandalone = "зуу"; // zuu

  /// Combined word for hundred ("зуун"), used when followed by tens/units or another context.
  static const String _hundredCombined = "зуун"; // zuun

  /// Scale words (thousand, million, etc.) using the short scale system.
  /// Key: Scale level (1=10^3, 2=10^6, 3=10^9...).
  /// Value: Scale word name.
  static const Map<int, String> _scaleWords = {
    1: "мянга", // myanga (thousand, 10^3)
    2: "сая", // saya (million, 10^6)
    3: "тэрбум", // terbum (billion, 10^9)
    4: "их наяд", // ikh nayad (trillion, 10^12)
    5: "квадриллион", // quadrillion (10^15 - loanword)
    6: "квинтиллион", // quintillion (10^18 - loanword)
    7: "секстиллион", // sextillion (10^21 - loanword)
    8: "септиллион", // septillion (10^24 - loanword)
    // Add more if needed
  };

  /// Helper function to get the correct unit word (1-9), applying modification if needed.
  /// Modification (adding 'н') applies when the unit is followed by context (scale word, "зуун", etc.).
  ///
  /// [digit]: The unit digit (1-9).
  /// [needsModification]: True if the context requires the modified form (e.g., "гурван зуун").
  /// Returns the appropriate Mongolian word for the unit digit.
  String _getUnitWord(int digit, {required bool needsModification}) {
    if (digit < 1 || digit > 9) return ""; // Handle invalid digits gracefully.

    // Only digits 3-9 have distinct modified forms.
    bool canBeModified = digit >= 3;
    // Return modified form if needed and possible, otherwise return base form.
    return (needsModification && canBeModified)
        ? (_unitsModified[digit] ??
            _units[
                digit]) // Use modified, fallback to base if somehow not in map.
        : _units[digit]; // Use base form.
  }

  /// {@macro num2text_base_process}
  /// Converts the given [number] into its Mongolian word representation.
  ///
  /// Handles `int`, `double`, `BigInt`, `Decimal`, and numeric `String` inputs.
  /// Uses [MnOptions] to customize behavior like currency formatting ([MnOptions.currency], [MnOptions.currencyInfo]),
  /// year formatting ([Format.year]), decimal separator ([MnOptions.decimalSeparator]),
  /// and negative prefix ([MnOptions.negativePrefix]).
  /// If `options` is not an instance of [MnOptions], default settings are used.
  ///
  /// Returns the word representation (e.g., "нэг зуун хорин гурав", "хасах арав цэг тав", "нэг сая").
  /// If the input is invalid (`null`, `NaN`, `Infinity`, non-numeric string), it returns
  /// [fallbackOnError] if provided, otherwise a default error message like "Тоо биш".
  @override
  String process(
      dynamic number, BaseOptions? options, String? fallbackOnError) {
    // Ensure we have Mongolian-specific options, using defaults if none are provided.
    final MnOptions mnOptions =
        options is MnOptions ? options : const MnOptions();
    // Use the provided fallback or the default Mongolian error message.
    final String errorDefault = fallbackOnError ?? _notANumber;

    // Handle special non-finite double values early.
    if (number is double) {
      if (number.isInfinite) {
        return number.isNegative
            ? _negativeInfinity
            : _infinity; // Localized infinity
      }
      if (number.isNaN) return errorDefault;
    }

    // Normalize the input to a Decimal for precise calculations.
    final Decimal? decimalValue = Utils.normalizeNumber(number);

    // Return error if normalization failed (invalid input type or format).
    if (decimalValue == null) return errorDefault;

    // Handle the specific case of zero.
    if (decimalValue == Decimal.zero) {
      if (mnOptions.currency) {
        // Currency format for zero (e.g., "тэг төгрөг"). Use singular/base unit name.
        final currencyName = mnOptions.currencyInfo.mainUnitPlural ??
            mnOptions.currencyInfo.mainUnitSingular;
        return "$_zero $currencyName";
      }
      // Standard "тэг". Also covers year 0.
      return _zero;
    }

    final bool isNegative = decimalValue.isNegative;
    // Work with the absolute value for the core conversion logic.
    final Decimal absValue = isNegative ? -decimalValue : decimalValue;
    String resultText;

    // --- Dispatch based on format options ---
    if (mnOptions.format == Format.year) {
      // Year format needs the integer part.
      int yearInt = absValue.truncate().toBigInt().toInt();
      // Years are read as cardinal numbers, context does not follow.
      resultText = _convertInteger(BigInt.from(yearInt), contextFollows: false);
    } else if (mnOptions.currency) {
      // Handle currency format.
      resultText = _handleCurrency(absValue, mnOptions);
    } else {
      // Handle standard number format.
      resultText = _handleStandardNumber(absValue, mnOptions);
    }

    // --- Add prefixes/suffixes ---
    if (mnOptions.format == Format.year) {
      // Check original sign for year suffix.
      bool originalIsNegative =
          number is int ? number < 0 : decimalValue.isNegative;
      if (originalIsNegative) {
        resultText += " $_yearSuffixBC"; // Add BC suffix.
      } else if (mnOptions.includeAD) {
        resultText += " $_yearSuffixAD"; // Add AD suffix if requested.
      }
    } else if (isNegative) {
      // Add negative prefix for non-year formats.
      resultText = "${mnOptions.negativePrefix} $resultText";
    }

    return resultText.trim(); // Trim final result.
  }

  /// Formats a [Decimal] value as a currency amount in words.
  /// Handles main units and subunits based on [MnOptions.currencyInfo].
  /// Applies rounding if [MnOptions.round] is true.
  /// Mongolian currency typically doesn't use complex plurals; singular form is used.
  /// Number words might change form based on following the unit name (`contextFollows: true`).
  ///
  /// [absValue]: The non-negative currency amount.
  /// [options]: Mongolian options containing currency details and rounding preference.
  /// Returns the currency amount in words, e.g., "нэг зуун төгрөг", "тавин мөнгө".
  String _handleCurrency(Decimal absValue, MnOptions options) {
    final CurrencyInfo currencyInfo = options.currencyInfo;
    final Decimal multiplier =
        Decimal.fromInt(100); // Standard 100 subunits per main unit.

    Decimal valueToConvert = absValue;
    // Apply rounding to 2 decimal places if requested.
    if (options.round) {
      valueToConvert = absValue.round(scale: 2);
    }

    // Separate main and subunit values.
    final BigInt mainValue = valueToConvert.truncate().toBigInt();
    final Decimal fractionalPart = valueToConvert - valueToConvert.truncate();
    final BigInt subunitValue =
        (fractionalPart * multiplier).truncate().toBigInt();

    // Convert main value to words. Context follows (the unit name).
    String mainText = _convertInteger(mainValue, contextFollows: true);

    // Get the main unit name (usually singular form in Mongolian).
    String mainUnitName =
        currencyInfo.mainUnitPlural ?? currencyInfo.mainUnitSingular;

    // Combine main number and unit.
    String result = '$mainText $mainUnitName';

    // Add subunit part if it exists and subunit name is defined.
    if (subunitValue > BigInt.zero && currencyInfo.subUnitSingular != null) {
      // Convert subunit value to words. Context follows (the subunit name).
      String subunitText = _convertInteger(subunitValue, contextFollows: true);
      String subUnitName = currencyInfo.subUnitSingular!;

      // Append subunit part (no "and" separator typically).
      result += ' $subunitText $subUnitName';
    }
    return result;
  }

  /// Formats a standard [Decimal] number (non-currency, non-year) into words.
  /// Handles both the integer and fractional parts. Determines if context follows the integer part.
  /// The fractional part is read digit by digit after the separator word ("цэг" or "таслал").
  ///
  /// [absValue]: The non-negative number.
  /// [options]: Mongolian options, used for `decimalSeparator`.
  /// Returns the number in words, e.g., "нэг зуун хорин гурван цэг дөрөв тав".
  String _handleStandardNumber(Decimal absValue, MnOptions options) {
    final BigInt integerPart = absValue.truncate().toBigInt();
    final Decimal fractionalPart = absValue - absValue.truncate();
    // Does a fractional part actually exist and need to be spoken?
    bool fractionExistsAndSpoken = fractionalPart > Decimal.zero;

    // Convert the integer part. Context follows if there is a fractional part to speak.
    String integerWords = (integerPart == BigInt.zero &&
            fractionExistsAndSpoken)
        ? _zero // Handle 0.5 -> "тэг цэг тав"
        : _convertInteger(integerPart, contextFollows: fractionExistsAndSpoken);

    String fractionalWords = '';
    if (fractionExistsAndSpoken) {
      // Determine the separator word.
      String separatorWord;
      switch (options.decimalSeparator) {
        case DecimalSeparator.comma:
          separatorWord = _decimalCommaWord;
          break;
        case DecimalSeparator.point:
        case DecimalSeparator.period:
        default: // Default to point for Mongolian context.
          separatorWord = _decimalPointWord;
          break;
      }

      // Get fractional digits.
      String fractionalDigits = absValue.toString().split('.').last;

      // Remove trailing zeros as they are usually not spoken.
      fractionalDigits = fractionalDigits.replaceAll(RegExp(r'0+$'), '');

      // If all digits were zeros, don't speak the fractional part.
      if (fractionalDigits.isEmpty) {
        fractionalWords = '';
        // Re-evaluate integer context if fraction becomes empty.
        if (integerPart != BigInt.zero) {
          integerWords = _convertInteger(integerPart, contextFollows: false);
        }
      } else {
        // Convert each remaining digit to its base word form.
        List<String> digitWords = fractionalDigits.split('').map((digit) {
          final int digitInt = int.parse(digit);
          // Use base unit words (0 = тэг).
          return digitInt == 0 ? _zero : _units[digitInt];
        }).toList();
        // Combine separator and digit words.
        fractionalWords = ' $separatorWord ${digitWords.join(' ')}';
      }
    }
    // This handles cases like Decimal('1.0') which might have scale but no fractional part > 0.
    // We need to ensure the integer part is converted without contextFollows=true in such cases.
    else if (integerPart > BigInt.zero &&
        absValue.scale > 0 &&
        absValue.isInteger) {
      integerWords = _convertInteger(integerPart, contextFollows: false);
    }

    // Combine integer and fractional parts.
    return '$integerWords$fractionalWords';
  }

  /// Converts a non-negative [BigInt] integer into its Mongolian word representation.
  /// Breaks the number into 3-digit chunks and applies scale words.
  /// Propagates the `contextFollows` flag to handle word form variations.
  ///
  /// [n]: The non-negative integer to convert.
  /// [contextFollows]: True if this number is followed by another significant word (scale word, unit, fractional part).
  /// Returns the integer in words, e.g., "нэг сая хоёр зуун гучин дөрвөн мянга таван зуу".
  String _convertInteger(BigInt n, {required bool contextFollows}) {
    if (n < BigInt.zero)
      throw ArgumentError("Integer must be non-negative: $n");
    if (n == BigInt.zero) return _zero; // Base case: zero.

    // Handle numbers less than 1000 directly.
    if (n < BigInt.from(1000)) {
      // Pass the contextFollows flag down.
      return _convertChunk(n.toInt(), isFollowedByContext: contextFollows);
    }

    List<String> parts = []; // Stores word parts for each scale level.
    final BigInt oneThousand = BigInt.from(1000);
    int scaleLevel = 0; // 0=units, 1=thousands, 2=millions...
    BigInt remaining = n;

    // Process the number in chunks of 1000 from right to left.
    while (remaining > BigInt.zero) {
      // Get the current 3-digit chunk (0-999).
      int chunkInt = (remaining % oneThousand).toInt();
      remaining ~/= oneThousand; // Move to the next higher chunk.

      if (chunkInt > 0) {
        // Determine if the current chunk needs modified forms.
        // It needs modification if it's *not* the absolute lowest chunk AND it's not the final part of the whole number.
        // OR if the absolute lowest chunk *is* followed by external context (like currency or decimal).
        bool chunkIsFollowed =
            (scaleLevel > 0) || (scaleLevel == 0 && contextFollows);

        // Convert the 3-digit chunk.
        String chunkText =
            _convertChunk(chunkInt, isFollowedByContext: chunkIsFollowed);

        // Get the scale word (мянга, сая, etc.) if applicable.
        String? scaleWord = _scaleWords[scaleLevel];
        if (scaleWord != null && scaleLevel > 0) {
          // Combine chunk text and scale word.
          parts.add("$chunkText $scaleWord");
        } else if (scaleLevel == 0) {
          // Add the base chunk text (0-999).
          parts.add(chunkText);
        }
      }
      scaleLevel++; // Move to the next scale level.
    }

    // Join the parts in reverse order (highest scale first) with spaces.
    return parts.reversed.join(' ');
  }

  /// Converts a number between 0 and 999 into its Mongolian word representation.
  /// Handles variations in hundreds ("зуу" vs "зуун") and tens ("хорь" vs "хорин")
  /// based on whether they are followed by other parts or context.
  ///
  /// [n]: The number to convert (must be 0-999).
  /// [isFollowedByContext]: True if this chunk is followed by a scale word or external context (currency, decimal).
  /// Returns the chunk in words, e.g., "зуун хорин гурав", "таван зуу", "хорь".
  String _convertChunk(int n, {required bool isFollowedByContext}) {
    if (n == 0) return ""; // Empty string for zero within a larger number.
    if (n < 0 || n >= 1000) throw ArgumentError("Chunk must be 0-999: $n");

    List<String> words = []; // Stores word parts for this chunk.
    int remainder = n;

    // --- Process Hundreds ---
    if (remainder >= 100) {
      int hundredDigit = remainder ~/ 100; // Get the hundreds digit (1-9).
      // Get the unit word for the digit (e.g., "нэг", "хоёр", "гурван"...).
      // Needs modification because it precedes "зуу(н)".
      String hundredPrefix =
          _getUnitWord(hundredDigit, needsModification: true);

      int unitsAndTens = remainder % 100; // The remaining 0-99 part.
      // Determine if hundred word is combined ("зуун") or standalone ("зуу").
      // Use combined form if followed by units/tens OR external context.
      String hundredWord = (unitsAndTens > 0 || isFollowedByContext)
          ? _hundredCombined
          : _hundredStandalone;

      // Add the prefix and the hundred word (e.g., "нэг зуун", "гурван зуу").
      words.add("$hundredPrefix $hundredWord");
      remainder %= 100; // Update remainder.
    }

    // --- Process Tens and Units (0-99) ---
    if (remainder > 0) {
      if (remainder < 10) {
        // 1-9: Get the unit word, apply modification based on external context.
        String unitWord =
            _getUnitWord(remainder, needsModification: isFollowedByContext);
        words.add(unitWord);
      } else if (remainder < 20) {
        // 10-19: Use the specific teen words. These don't usually change.
        words.add(_teens[remainder - 10]);
      } else {
        // 20-99:
        int tenDigit = remainder ~/ 10;
        int unitDigit = remainder % 10;

        // Determine if tens word is standalone or combined.
        // Use standalone if it's the end of the chunk AND not followed by external context.
        bool useStandaloneTen = (unitDigit == 0 && !isFollowedByContext);
        String tenWord = useStandaloneTen
            ? _tensStandalone[tenDigit]
            : _tensCombined[tenDigit];
        words.add(tenWord); // Add "хорь"/"хорин", "гуч"/"гучин", etc.

        if (unitDigit > 0) {
          // If there's a unit digit, add its word.
          // Apply modification based on external context.
          String unitWord =
              _getUnitWord(unitDigit, needsModification: isFollowedByContext);
          words.add(unitWord);
        }
      }
    }
    // Join the parts (hundreds, tens, units) with spaces.
    return words.join(' ');
  }
}
