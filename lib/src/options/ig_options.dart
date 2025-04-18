import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Igbo (`Lang.IG`) language version.
class IgOptions extends BaseOptions {
  /// Determines if "AD" (Anno Domini / Mgbe Kraịst gaseous) suffix is added for positive years
  /// when using [Format.year]. BC/BCE ("Tupu Kraịst") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"mwepu"` (subtraction/minus).
  final String negativePrefix;

  /// Specifies the currency details (unit names, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.ngnIg] (Nigerian Naira - Igbo terms).
  final CurrencyInfo currencyInfo;

  /// Creates Igbo-specific options.
  const IgOptions({
    this.includeAD = false,
    this.negativePrefix = "mwepu",
    this.currencyInfo = CurrencyInfo.ngnIg,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.period, // Default word: "ntụpọ"
    super.round = false, // Inherited: round the number
  });
}
