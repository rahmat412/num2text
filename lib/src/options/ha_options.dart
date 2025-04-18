import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Hausa (`Lang.HA`) language version.
class HaOptions extends BaseOptions {
  /// Determines if "AD" (Anno Domini / Bayan Yesu) suffix is added for positive years
  /// when using [Format.year]. BC/BCE ("Kafin Yesu") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"korau"` (negative/less).
  final String negativePrefix;

  /// Specifies the currency details (unit names, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.ngnHa] (Nigerian Naira - Hausa terms).
  final CurrencyInfo currencyInfo;

  /// Creates Hausa-specific options.
  const HaOptions({
    this.includeAD = false,
    this.negativePrefix = "korau",
    this.currencyInfo = CurrencyInfo.ngnHa,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.period, // Default word: "digo"
    super.round = false, // Inherited: round the number
  });
}
