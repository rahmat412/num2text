import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Dutch (`Lang.NL`) language version.
class NlOptions extends BaseOptions {
  /// Determines if "n.Chr." (na Christus - after Christ, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("v.Chr.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"min"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.eurNl] (Euro - Dutch terms).
  final CurrencyInfo currencyInfo;

  /// Creates Dutch-specific options.
  const NlOptions({
    this.includeAD = false,
    this.negativePrefix = "min",
    this.currencyInfo = CurrencyInfo.eurNl,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.comma, // Default word: "komma"
    super.round = false, // Inherited: round the number
  });
}
