import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Bengali (`Lang.BN`) language version.
class BnOptions extends BaseOptions {
  /// Determines if the "খ্রিস্টাব্দ" (khrishtabdô - AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("খ্রিস্টপূর্ব") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"ঋণাত্মক"` (ṛiṇātmôk - negative).
  final String negativePrefix;

  /// Specifies the currency details (unit names, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.bdt] (Bangladeshi Taka).
  final CurrencyInfo currencyInfo;

  /// Creates Bengali-specific options.
  const BnOptions({
    this.includeAD = false,
    this.negativePrefix = "ঋণাত্মক",
    this.currencyInfo = CurrencyInfo.bdt,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.period, // Default word: "দশমিক" (dôshômik)
    super.round = false, // Inherited: round the number
  });
}
