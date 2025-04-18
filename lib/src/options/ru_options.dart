import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Russian (`Lang.RU`) language version.
class RuOptions extends BaseOptions {
  /// Determines if "н. э." (нашей эры - our era, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("до н. э.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"минус"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, complex plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.rub] (Russian Ruble).
  final CurrencyInfo currencyInfo;

  /// Creates Russian-specific options.
  const RuOptions({
    this.includeAD = false,
    this.negativePrefix = "минус",
    this.currencyInfo = CurrencyInfo.rub,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator
        .comma, // Default word: "целых" (tselykh) or "запятая" (zapyataya)
    super.round = false, // Inherited: round the number
  });
}
