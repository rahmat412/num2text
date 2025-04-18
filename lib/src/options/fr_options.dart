import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the French (`Lang.FR`) language version.
class FrOptions extends BaseOptions {
  /// Determines if "ap. J.-C." (après Jésus-Christ - after Jesus Christ, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("av. J.-C.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"moins"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.eurFr] (Euro - French terms).
  final CurrencyInfo currencyInfo;

  /// Creates French-specific options.
  const FrOptions({
    this.includeAD = false,
    this.negativePrefix = "moins",
    this.currencyInfo = CurrencyInfo.eurFr,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.comma, // Default word: "virgule"
    super.round = false, // Inherited: round the number
  });
}
