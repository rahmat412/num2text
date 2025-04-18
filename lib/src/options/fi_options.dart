import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Finnish (`Lang.FI`) language version.
class FiOptions extends BaseOptions {
  /// Determines if "jKr." (jälkeen Kristuksen - after Christ, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("eKr.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"miinus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names in appropriate cases, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.eurFi] (Euro - Finnish terms).
  final CurrencyInfo currencyInfo;

  /// Creates Finnish-specific options.
  const FiOptions({
    this.includeAD = false,
    this.negativePrefix = "miinus",
    this.currencyInfo = CurrencyInfo.eurFi,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.comma, // Default word: "pilkku"
    super.round = false, // Inherited: round the number
  });
}
