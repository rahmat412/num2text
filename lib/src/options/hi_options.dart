import 'base_options.dart';
import '../concurencies/concurencies_info.dart';

/// Options specific to the Hindi (`Lang.HI`) language version.
class HiOptions extends BaseOptions {
  /// Determines if the "ईस्वी" (īsvī - AD/CE) suffix is added for positive years
  /// when using [Format.year]. BC/BCE ("ईसा पूर्व") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD; // Using AD as per original field name

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"ऋण"` (ṛṇa - debt/negative).
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.inrHi] (Indian Rupee - Hindi terms).
  final CurrencyInfo currencyInfo;

  /// Creates Hindi-specific options.
  const HiOptions({
    this.includeAD = false,
    this.negativePrefix = "ऋण",
    this.currencyInfo = CurrencyInfo.inrHi,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.period, // Default word: "दशमलव" (dashamlav)
    super.round = false, // Inherited: round the number
  });
}
