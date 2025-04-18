import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Ukrainian (`Lang.UK`) language version.
class UkOptions extends BaseOptions {
  /// Determines if "н.е." (нашої ери - our era, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("до н.е.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"мінус"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, complex plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.uah] (Ukrainian Hryvnia).
  final CurrencyInfo currencyInfo;

  /// Creates Ukrainian-specific options.
  const UkOptions({
    this.includeAD = false,
    this.negativePrefix = "мінус",
    this.currencyInfo = CurrencyInfo.uah,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator
        .comma, // Default word: "цілих" (tsilykh) or "кома" (koma)
    super.round = false, // Inherited: round the number
  });
}
