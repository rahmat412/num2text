import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Persian (`Lang.FA`) language version.
class FaOptions extends BaseOptions {
  /// Determines if the "میلادی" (milādi - Gregorian/AD/CE) suffix is added for positive years
  /// when using [Format.year]. BC/BCE ("پیش از میلاد") is typically handled internally.
  /// Note: Persian often uses the Solar Hijri calendar; this option relates to Gregorian years.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"منفی"` (manfi - negative).
  final String negativePrefix;

  /// Specifies the currency details (unit names, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.irr] (Iranian Rial).
  final CurrencyInfo currencyInfo;

  /// Creates Persian-specific options.
  const FaOptions({
    this.includeAD = false,
    this.negativePrefix = "منفی",
    this.currencyInfo = CurrencyInfo.irr,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.comma, // Default word: "ممیز" (momayyez)
    super.round =
        false, // Inherited: round the number (Subunits often handled specially)
  });
}
