import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Lithuanian (`Lang.LT`) language version.
class LtOptions extends BaseOptions {
  /// Determines if AD/CE context (usually implied, not suffixed, e.g., "m. e.") is explicitly handled
  /// for positive years when using [Format.year]. BC/BCE ("pr. m. e.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"minus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.eurLt] (Euro - Lithuanian terms).
  final CurrencyInfo currencyInfo;

  /// Creates Lithuanian-specific options.
  const LtOptions({
    this.includeAD = false,
    this.negativePrefix = "minus",
    this.currencyInfo = CurrencyInfo.eurLt,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.comma, // Default word: "kablelis" or "sveikoji dalis"
    super.round = false, // Inherited: round the number
  });
}
