import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Serbian (`Lang.SR`) language version.
class SrOptions extends BaseOptions {
  /// Determines if "н. е." (наше ере / naše ere - our era, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("п. н. е.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"minus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, complex plural/case forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.rsd] (Serbian Dinar).
  final CurrencyInfo currencyInfo;

  /// Creates Serbian-specific options.
  const SrOptions({
    this.includeAD = false,
    this.negativePrefix = "minus",
    this.currencyInfo = CurrencyInfo.rsd,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator
        .comma, // Default word: "зарез" / "zarez" or "целих" / "celih"
    super.round = false, // Inherited: round the number
  });
}
