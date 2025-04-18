import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Icelandic (`Lang.IS`) language version.
class IsOptions extends BaseOptions {
  /// Determines if "e.Kr." (eftir Krist - after Christ, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("f.Kr.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"mínus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.isk] (Icelandic Króna). Subunits (aurar) are deprecated.
  final CurrencyInfo currencyInfo;

  /// Creates Icelandic-specific options.
  const IsOptions({
    this.includeAD = false,
    this.negativePrefix = "mínus",
    this.currencyInfo = CurrencyInfo.isk,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.comma, // Default word: "komma"
    super.round = false, // Inherited: round the number
  });
}
