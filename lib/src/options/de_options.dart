import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the German (`Lang.DE`) language version.
class DeOptions extends BaseOptions {
  /// Determines if "n. Chr." (nach Christus - after Christ, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("v. Chr.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"minus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.eurDe] (Euro - German terms).
  final CurrencyInfo currencyInfo;

  /// Creates German-specific options.
  const DeOptions({
    this.includeAD = false,
    this.negativePrefix = "minus",
    this.currencyInfo = CurrencyInfo.eurDe,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.comma, // Default word: "Komma"
    super.round = false, // Inherited: round the number
  });
}
