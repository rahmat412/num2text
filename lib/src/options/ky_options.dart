import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Kyrgyz (`Lang.KY`) language version.
class KyOptions extends BaseOptions {
  /// Determines if "б.з." (биздин заман - our era, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("б.з.ч.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"минус"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.kgs] (Kyrgyzstani Som).
  final CurrencyInfo currencyInfo;

  /// Creates Kyrgyz-specific options.
  const KyOptions({
    this.includeAD = false,
    this.negativePrefix = "минус",
    this.currencyInfo = CurrencyInfo.kgs,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator
        .period, // Default word: "бүтүн" (bütün) or "чекит" (chekit)
    super.round = false, // Inherited: round the number
  });
}
