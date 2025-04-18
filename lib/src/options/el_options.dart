import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Greek (`Lang.EL`) language version.
class ElOptions extends BaseOptions {
  /// Determines if "μ.Χ." (μετά Χριστόν - after Christ, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("π.Χ.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"μείον"` (meíon - minus).
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.eurEl] (Euro - Greek terms).
  final CurrencyInfo currencyInfo;

  /// Creates Greek-specific options.
  const ElOptions({
    this.includeAD = false,
    this.negativePrefix = "μείον",
    this.currencyInfo = CurrencyInfo.eurEl,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.comma, // Default word: "κόμμα" (kómma)
    super.round = false, // Inherited: round the number
  });
}
