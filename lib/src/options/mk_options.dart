import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Macedonian (`Lang.MK`) language version.
class MkOptions extends BaseOptions {
  /// Determines if "н.е." (наша ера - our era, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("п.н.е.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"минус"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.mkd] (Macedonian Denar).
  final CurrencyInfo currencyInfo;

  /// Creates Macedonian-specific options.
  const MkOptions({
    this.includeAD = false,
    this.negativePrefix = "минус",
    this.currencyInfo = CurrencyInfo.mkd,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.comma, // Default word: "запирка" (zapirka)
    super.round = false, // Inherited: round the number
  });
}
