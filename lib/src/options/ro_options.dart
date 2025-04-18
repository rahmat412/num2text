import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Romanian (`Lang.RO`) language version.
class RoOptions extends BaseOptions {
  /// Determines if "d.Hr." (după Hristos - after Christ, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("î.Hr.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"minus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.ron] (Romanian Leu).
  final CurrencyInfo currencyInfo;

  /// Creates Romanian-specific options.
  const RoOptions({
    this.includeAD = false,
    this.negativePrefix = "minus",
    this.currencyInfo = CurrencyInfo.ron,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.comma, // Default word: "virgulă"
    super.round = false, // Inherited: round the number
  });
}
