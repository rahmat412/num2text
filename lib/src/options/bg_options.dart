import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Bulgarian (`Lang.BG`) language version.
class BgOptions extends BaseOptions {
  /// Determines if "от новата ера" (of the new era - AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("пр.н.е.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"минус"` (minus).
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.bgn] (Bulgarian Lev).
  final CurrencyInfo currencyInfo;

  /// Creates Bulgarian-specific options.
  const BgOptions({
    this.includeAD = false,
    this.negativePrefix = "минус",
    this.currencyInfo = CurrencyInfo.bgn,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.comma, // Default word: "запетая" (zapetaya)
    super.round = false, // Inherited: round the number
  });
}
