import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Bosnian (`Lang.BS`) language version.
class BsOptions extends BaseOptions {
  /// Determines if "n. e." (nove ere - of the new era, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("p. n. e.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"minus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.bam] (Bosnia and Herzegovina Convertible Mark).
  final CurrencyInfo currencyInfo;

  /// Creates Bosnian-specific options.
  const BsOptions({
    this.includeAD = false,
    this.negativePrefix = "minus",
    this.currencyInfo = CurrencyInfo.bam,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.comma, // Default word: "zarez" or "cijelo"
    super.round = false, // Inherited: round the number
  });
}
