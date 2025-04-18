import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Latvian (`Lang.LV`) language version.
class LvOptions extends BaseOptions {
  /// Determines if "m.ē." (mūsu ērā - our era, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("p.m.ē.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"mīnus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.eurLv] (Euro - Latvian terms).
  final CurrencyInfo currencyInfo;

  /// Creates Latvian-specific options.
  const LvOptions({
    this.includeAD = false,
    this.negativePrefix = "mīnus",
    this.currencyInfo = CurrencyInfo.eurLv,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.comma, // Default word: "komats"
    super.round = false, // Inherited: round the number
  });
}
