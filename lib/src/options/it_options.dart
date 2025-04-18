import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Italian (`Lang.IT`) language version.
class ItOptions extends BaseOptions {
  /// Determines if "d.C." (dopo Cristo - after Christ, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("a.C.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"meno"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.eurIt] (Euro - Italian terms).
  final CurrencyInfo currencyInfo;

  /// Creates Italian-specific options.
  const ItOptions({
    this.includeAD = false,
    this.negativePrefix = "meno",
    this.currencyInfo = CurrencyInfo.eurIt,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.comma, // Default word: "virgola"
    super.round = false, // Inherited: round the number
  });
}
