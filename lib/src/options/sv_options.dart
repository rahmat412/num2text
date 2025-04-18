import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Swedish (`Lang.SV`) language version.
class SvOptions extends BaseOptions {
  /// Determines if "e.Kr." (efter Kristus - after Christ, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("f.Kr.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"minus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.sek] (Swedish Krona). Subunit (öre) is largely historical but included.
  final CurrencyInfo currencyInfo;

  /// Creates Swedish-specific options.
  const SvOptions({
    this.includeAD = false,
    this.negativePrefix = "minus",
    this.currencyInfo = CurrencyInfo.sek,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.comma, // Default word: "komma"
    super.round = false, // Inherited: round the number
  });
}
