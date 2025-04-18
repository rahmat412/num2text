import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Spanish (`Lang.ES`) language version.
class EsOptions extends BaseOptions {
  /// Determines if "d.C." (después de Cristo - after Christ, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("a.C.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"menos"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.eurEs] (Euro - Spanish terms). Could be set to `.mxn`, `.cop`, etc. for regional currencies.
  final CurrencyInfo currencyInfo;

  /// Creates Spanish-specific options.
  const EsOptions({
    this.includeAD = false,
    this.negativePrefix = "menos",
    this.currencyInfo = CurrencyInfo.eurEs,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.comma, // Default word: "coma" or "con"
    super.round = false, // Inherited: round the number
  });
}
