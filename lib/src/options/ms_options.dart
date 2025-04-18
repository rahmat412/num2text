import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Malay (`Lang.MS`) language version.
class MsOptions extends BaseOptions {
  /// Determines if "M" (Masihi - AD/CE) suffix is added for positive years
  /// when using [Format.year]. BC/BCE ("SM" - Sebelum Masihi) is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"negatif"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.myr] (Malaysian Ringgit). Can be set to SGD, BND if needed.
  final CurrencyInfo currencyInfo;

  /// Creates Malay-specific options.
  const MsOptions({
    this.includeAD = false,
    this.negativePrefix = "negatif",
    this.currencyInfo = CurrencyInfo.myr,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.period, // Default word: "perpuluhan"
    super.round = false, // Inherited: round the number
  });
}
