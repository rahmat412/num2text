import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Polish (`Lang.PL`) language version.
class PlOptions extends BaseOptions {
  /// Determines if "n.e." (naszej ery - our era, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("p.n.e.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"minus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, complex plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.pln] (Polish Złoty).
  final CurrencyInfo currencyInfo;

  /// Creates Polish-specific options.
  const PlOptions({
    this.includeAD = false,
    this.negativePrefix = "minus",
    this.currencyInfo = CurrencyInfo.pln,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.comma, // Default word: "przecinek" or "całych"
    super.round = false, // Inherited: round the number
  });
}
