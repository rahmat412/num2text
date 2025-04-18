import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Khmer (`Lang.KM`) language version.
class KmOptions extends BaseOptions {
  /// Determines if "គ.ស." (Khrist Sakkarat - Christian Era, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("មុន គ.ស.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"ដក"` (dák - subtract/minus).
  final String negativePrefix;

  /// Specifies the currency details (unit names) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.khr] (Cambodian Riel).
  final CurrencyInfo currencyInfo;

  /// Creates Khmer-specific options.
  const KmOptions({
    this.includeAD = false,
    this.negativePrefix = "ដក",
    this.currencyInfo = CurrencyInfo.khr,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator
        .period, // Default word: "ចុច" (chŏh) or "ក្បៀស" (kbiĕh) for comma
    super.round = false, // Inherited: round the number
  });
}
