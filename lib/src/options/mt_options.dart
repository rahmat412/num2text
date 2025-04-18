import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Maltese (`Lang.MT`) language version.
class MtOptions extends BaseOptions {
  /// Determines if "WK" (Wara Kristu - After Christ, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("QK" - Qabel Kristu) is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"minus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.eurMt] (Euro - Maltese terms).
  final CurrencyInfo currencyInfo;

  /// Creates Maltese-specific options.
  const MtOptions({
    this.includeAD = false,
    this.negativePrefix = "minus",
    this.currencyInfo = CurrencyInfo.eurMt,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.period, // Default word: "punt"
    super.round = false, // Inherited: round the number
  });
}
