import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Yoruba (`Lang.YO`) language version.
class YoOptions extends BaseOptions {
  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"òdì"` (opposite/negative).
  final String negativePrefix;

  /// Specifies the currency details (unit names, potentially complex vigesimal structure) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.ngnYo] (Nigerian Naira - Yoruba terms).
  final CurrencyInfo currencyInfo;

  /// Creates Yoruba-specific options.
  const YoOptions({
    // this.includeAD = false,
    this.negativePrefix = "òdì", // Corrected default with accent
    this.currencyInfo = CurrencyInfo.ngnYo,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.period, // Default word: "ààmì"
    super.round = false, // Inherited: round the number
  });
}
