import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Belarusian (`Lang.BE`) language version.
class BeOptions extends BaseOptions {
  /// Determines if the "н.э." (нашай эры - of our era, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("да н.э.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"мінус"` (minus).
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.byn] (Belarusian Ruble).
  final CurrencyInfo currencyInfo;

  /// Creates Belarusian-specific options.
  const BeOptions({
    this.includeAD = false,
    this.negativePrefix = "мінус",
    this.currencyInfo = CurrencyInfo.byn,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.comma, // Default word: "коска" (koska)
    super.round = false, // Inherited: round the number
  });
}
