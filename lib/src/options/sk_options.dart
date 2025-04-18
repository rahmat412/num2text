import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Slovak (`Lang.SK`) language version.
class SkOptions extends BaseOptions {
  /// Determines if "n. l." (nášho letopočtu - our era, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("pred n. l.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"mínus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, complex plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.eurSk] (Euro - Slovak terms).
  final CurrencyInfo currencyInfo;

  /// Specifies the grammatical [Gender] for number words 'one' and 'two', and potentially for currency units.
  /// - `Gender.masculine`: "jeden", "dva" (Default for standalone numbers, maybe some currencies)
  /// - `Gender.feminine`: "jedna", "dve" (Used for feminine nouns)
  /// - `Gender.neuter`: "jedno", "dve" (Used for neuter nouns like 'euro')
  /// If `null`, the converter might infer based on context (e.g., currency info) or default to masculine.
  final Gender? gender;

  /// Creates Slovak-specific options.
  const SkOptions({
    this.includeAD = false,
    this.negativePrefix = "mínus",
    this.currencyInfo = CurrencyInfo.eurSk,
    this.gender, // Allow setting gender explicitly
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.comma, // Default word: "celá"
    super.round = false, // Inherited: round the number
  });

  /// Creates a copy of this options object but with the given fields replaced with the new values.
  SkOptions copyWith({
    bool? includeAD,
    String? negativePrefix,
    CurrencyInfo? currencyInfo,
    Gender? gender, // Use Gender? to allow null
    bool? currency,
    Format? format,
    DecimalSeparator? decimalSeparator,
    bool? round,
  }) {
    return SkOptions(
      includeAD: includeAD ?? this.includeAD,
      negativePrefix: negativePrefix ?? this.negativePrefix,
      currencyInfo: currencyInfo ?? this.currencyInfo,
      // Handle nullable gender: if new gender is provided, use it. Otherwise, keep the old one.
      gender: gender ?? this.gender,
      currency: currency ?? super.currency,
      format: format ?? super.format,
      decimalSeparator: decimalSeparator ?? super.decimalSeparator,
      round: round ?? super.round,
    );
  }
}
