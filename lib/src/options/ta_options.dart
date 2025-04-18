import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Tamil (`Lang.TA`) language version.
class TaOptions extends BaseOptions {
  /// Determines if "கி.பி." (ki.pi. - kīṟistu piṟaku - After Christ, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("கி.மு." - ki.mu.) is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"கழித்தல்"` (kaḻittal - subtract/minus).
  final String negativePrefix;

  /// Specifies the currency details (unit names) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.inrTa] (Indian Rupee - Tamil terms). Can be set for LKR, SGD etc.
  final CurrencyInfo currencyInfo;

  /// Creates Tamil-specific options.
  const TaOptions({
    this.includeAD = false,
    this.negativePrefix = "கழித்தல்",
    this.currencyInfo = CurrencyInfo.inrTa,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.period, // Default word: "புள்ளி" (puḷḷi)
    super.round = false, // Inherited: round the number
  });
}
