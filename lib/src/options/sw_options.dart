import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Swahili (`Lang.SW`) language version.
class SwOptions extends BaseOptions {
  /// Determines if "BK" (Baada ya Kristo - After Christ, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("KK" - Kabla ya Kristo) is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"hasi"` (negative).
  final String negativePrefix;

  /// Specifies the currency details (unit names, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.tzs] (Tanzanian Shilling). Can be set for KES, UGX etc.
  final CurrencyInfo currencyInfo;

  /// Creates Swahili-specific options.
  const SwOptions({
    this.includeAD = false,
    this.negativePrefix = "hasi",
    this.currencyInfo = CurrencyInfo.tzs,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.period, // Default word: "pointi"
    super.round = false, // Inherited: round the number
  });
}
