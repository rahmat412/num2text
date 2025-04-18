import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Burmese (`Lang.MY`) language version.
class MyOptions extends BaseOptions {
  // Note: Burmese traditionally uses the Myanmar Era (ME). AD/CE (ခရစ်နှစ် - Khrit Hnit) is less common.
  // An 'includeEra' or specific era system option might be needed for full support.
  // final bool includeAD; // Not included by default.

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"အနုတ်"` (a nout - minus).
  final String negativePrefix;

  /// Specifies the currency details (unit names) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.mmk] (Myanmar Kyat).
  final CurrencyInfo currencyInfo;

  /// Creates Burmese-specific options.
  const MyOptions({
    // this.includeAD = false,
    this.negativePrefix = "အနုတ်",
    this.currencyInfo = CurrencyInfo.mmk,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.period, // Default word: "ဒသမ" (da tha ma)
    super.round = false, // Inherited: round the number
  });
}
