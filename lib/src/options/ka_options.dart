import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Georgian (`Lang.KA`) language version.
class KaOptions extends BaseOptions {
  /// Determines if "ჩვ. წ." (chveni ts’elthaghritskhvis - of our era, AD/CE) or similar suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("ჩვ. წ.-მდე") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD; // Using AD as per original field name

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"მინუს"` (minus).
  final String negativePrefix;

  /// Specifies the currency details (unit names, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.gel] (Georgian Lari).
  final CurrencyInfo currencyInfo;

  /// Creates Georgian-specific options.
  const KaOptions({
    this.includeAD = false,
    this.negativePrefix = "მინუს",
    this.currencyInfo = CurrencyInfo.gel,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.comma, // Default word: "მთელი" (mteli)
    super.round = false, // Inherited: round the number
  });
}
