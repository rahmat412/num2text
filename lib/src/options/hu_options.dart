import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Hungarian (`Lang.HU`) language version.
class HuOptions extends BaseOptions {
  /// Determines if "i. sz." (időszámításunk szerint - according to our era, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("i. e.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"mínusz"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.huf] (Hungarian Forint). Subunit (fillér) is largely historical.
  final CurrencyInfo currencyInfo;

  /// Creates Hungarian-specific options.
  const HuOptions({
    this.includeAD = false,
    this.negativePrefix = "mínusz",
    this.currencyInfo = CurrencyInfo.huf,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.comma, // Default word: "egész"
    super.round = false, // Inherited: round the number
  });
}
