import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Turkish (`Lang.TR`) language version.
class TrOptions extends BaseOptions {
  /// Determines if "MS" (Milattan Sonra - After الميلاد, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("MÖ" - Milattan Önce) is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"eksi"` (minus/negative).
  final String negativePrefix;

  /// Specifies the currency details (unit names) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.tryTr] (Turkish Lira).
  final CurrencyInfo currencyInfo;

  /// Creates Turkish-specific options.
  const TrOptions({
    this.includeAD = false,
    this.negativePrefix = "eksi",
    this.currencyInfo = CurrencyInfo.tryTr,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.comma, // Default word: "virgül"
    super.round = false, // Inherited: round the number
  });
}
