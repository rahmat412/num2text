import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Czech (`Lang.CS`) language version.
class CsOptions extends BaseOptions {
  /// Determines if "n. l." (našeho letopočtu - of our era, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("př. n. l.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"mínus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.czk] (Czech Koruna).
  final CurrencyInfo currencyInfo;

  /// Specifies the grammatical [Gender] for number words, primarily affecting 'one' and 'two'.
  /// - `Gender.masculine`: "jeden", "dva"
  /// - `Gender.feminine`: "jedna", "dvě" (Default, often used for standalone numbers or feminine nouns like "koruna")
  /// - `Gender.neuter`: "jedno", "dvě"
  /// Defaults to `Gender.feminine`.
  final Gender gender;

  /// Creates Czech-specific options.
  const CsOptions({
    this.includeAD = false,
    this.negativePrefix = "mínus",
    this.currencyInfo = CurrencyInfo.czk,
    this.gender = Gender.feminine,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.comma, // Default word: "celá"
    super.round = false, // Inherited: round the number
  });
}
