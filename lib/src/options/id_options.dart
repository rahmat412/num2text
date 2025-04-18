import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Indonesian (`Lang.ID`) language version.
class IdOptions extends BaseOptions {
  /// Determines if "M" (Masehi - AD/CE) suffix is added for positive years
  /// when using [Format.year]. BC/BCE ("SM") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"minus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.idr] (Indonesian Rupiah). Subunit (sen) is largely historical.
  final CurrencyInfo currencyInfo;

  /// Creates Indonesian-specific options.
  const IdOptions({
    this.includeAD = false,
    this.negativePrefix = "minus",
    this.currencyInfo = CurrencyInfo.idr,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.comma, // Default word: "koma"
    super.round = false, // Inherited: round the number
  });
}
