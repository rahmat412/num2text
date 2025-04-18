import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Thai (`Lang.TH`) language version.
class ThOptions extends BaseOptions {
  /// Determines if "ค.ศ." (Khrist Sakkarat - Christian Era, AD/CE) suffix or similar is added
  /// for positive years when using [Format.year]. Thai more commonly uses the Buddhist Era (พ.ศ.).
  /// BC/BCE ("ก่อน ค.ศ.") is typically handled internally if AD/CE context is used.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"ลบ"` (lop - subtract/minus).
  final String negativePrefix;

  /// Specifies the currency details (unit names) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.thb] (Thai Baht).
  final CurrencyInfo currencyInfo;

  /// Creates Thai-specific options.
  const ThOptions({
    this.includeAD = false,
    this.negativePrefix = "ลบ",
    this.currencyInfo = CurrencyInfo.thb,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.period, // Default word: "จุด" (jut)
    super.round = false, // Inherited: round the number
  });
}
