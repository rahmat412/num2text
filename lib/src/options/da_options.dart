import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Danish (`Lang.DA`) language version.
class DaOptions extends BaseOptions {
  /// Determines if "e.Kr." (efter Kristus - after Christ, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("f.Kr.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"minus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.dkk] (Danish Krone).
  final CurrencyInfo currencyInfo;

  /// Creates Danish-specific options.
  const DaOptions({
    this.includeAD = false,
    this.negativePrefix = "minus",
    this.currencyInfo = CurrencyInfo.dkk,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.comma, // Default word: "komma"
    super.round = false, // Inherited: round the number
  });
}
