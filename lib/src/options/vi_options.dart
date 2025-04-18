import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Vietnamese (`Lang.VI`) language version.
class ViOptions extends BaseOptions {
  /// Determines if "sau Công Nguyên" (SCN - AD/CE) suffix is added for positive years
  /// when using [Format.year]. BC/BCE ("trước Công Nguyên" - TCN) is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// Determines whether to use "lẻ" (odd/spare) instead of "linh" for connecting hundreds and units (1-9).
  /// Affects numbers like 101, 205, etc.
  ///
  /// Example:
  /// - `true`: "một trăm lẻ một" (one hundred and one)
  /// - `false`: "một trăm linh một" (one hundred zero one) - Default
  final bool useLe;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"âm"` (negative).
  final String negativePrefix;

  /// Specifies the currency details (unit name) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.vnd] (Vietnamese Đồng). Subunits are deprecated.
  final CurrencyInfo currencyInfo;

  /// Creates Vietnamese-specific options.
  const ViOptions({
    this.includeAD = false,
    this.useLe = false,
    this.negativePrefix = "âm",
    this.currencyInfo = CurrencyInfo.vnd,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.comma, // Default word: "phẩy"
    super.round = false, // Inherited: round the number
  });
}
