import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Zulu (`Lang.ZU`) language version.
class ZuOptions extends BaseOptions {
  /// Determines if "AD" (Anno Domini / emva kokuzalwa kukaKristu - AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("BC" / ngaphambi kokuzalwa kukaKristu) is handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"okubi"` (negative/bad).
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.zarZu] (South African Rand - Zulu terms).
  final CurrencyInfo currencyInfo;

  /// Creates Zulu-specific options.
  const ZuOptions({
    this.includeAD = false,
    this.negativePrefix = "okubi", // Using native term as default
    this.currencyInfo = CurrencyInfo.zarZu,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator
        .period, // Default word: "iphoyinti" or "ukhefana" for comma
    super.round = false, // Inherited: round the number
  });
}
