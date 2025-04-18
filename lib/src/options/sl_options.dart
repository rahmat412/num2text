import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Slovenian (`Lang.SL`) language version.
class SlOptions extends BaseOptions {
  /// Determines if "n. št." (našega štetja - our era, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("pr. n. št.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"minus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, dual/plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.eurSl] (Euro - Slovenian terms).
  final CurrencyInfo currencyInfo;

  /// Creates Slovenian-specific options.
  const SlOptions({
    this.includeAD = false,
    this.negativePrefix = "minus",
    this.currencyInfo = CurrencyInfo.eurSl,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.comma, // Default word: "cela" or "vejica"
    super.round = false, // Inherited: round the number
  });
}
