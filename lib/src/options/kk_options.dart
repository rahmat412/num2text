import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Kazakh (`Lang.KK`) language version.
class KkOptions extends BaseOptions {
  /// Determines if "ж." (жылы - year) or similar context for AD/CE is added
  /// for positive years when using [Format.year]. BC/BCE ("б.з.б.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"минус"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.kzt] (Kazakhstani Tenge).
  final CurrencyInfo currencyInfo;

  /// Creates Kazakh-specific options.
  const KkOptions({
    this.includeAD = false,
    this.negativePrefix = "минус",
    this.currencyInfo = CurrencyInfo.kzt,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    // Default separator word varies; "бүтін" (bütin) is common. Comma or period usage differs.
    super.decimalSeparator = DecimalSeparator.period,
    super.round = false, // Inherited: round the number
  });
}
