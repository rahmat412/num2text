import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Norwegian (`Lang.NO`) language version (Bokmål).
class NoOptions extends BaseOptions {
  /// Determines if "e.Kr." (etter Kristus - after Christ, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("f.Kr.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"minus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.nok] (Norwegian Krone).
  final CurrencyInfo currencyInfo;

  /// Specifies the grammatical [Gender] for number words, primarily affecting 'one' ('en' vs 'ett').
  /// - `Gender.masculine` (or `Gender.feminine`): Typically results in "en". (Default)
  /// - `Gender.neuter`: Results in "ett", used before neuter nouns like 'øre' or standalone neuter 'one'.
  /// Defaults to `Gender.masculine` (representing the common gender form "en").
  final Gender gender;

  /// Creates Norwegian (Bokmål)-specific options.
  const NoOptions({
    this.includeAD = false,
    this.negativePrefix = "minus",
    this.currencyInfo = CurrencyInfo.nok,
    this.gender = Gender.masculine,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.comma, // Default word: "komma"
    super.round = false, // Inherited: round the number
  });
}
