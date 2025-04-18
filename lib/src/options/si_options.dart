import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Sinhala (`Lang.SI`) language version.
class SiOptions extends BaseOptions {
  /// Determines if the appropriate era suffix ("ක්‍රි.ව." for AD/CE or "ක්‍රි.පූ." for BC/BCE)
  /// is added when using [Format.year]. The correct suffix based on the year's sign
  /// is typically handled internally when `format` is [Format.year].
  /// Setting this to `true` ensures the positive year suffix ("ක්‍රි.ව.") is shown explicitly.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using specific formats like [Format.year].
  /// Defaults to `"සෘණ"` (sruṇa - negative).
  /// Example: `-123` becomes `"සෘණ එකසිය විසිතුන"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.lkr] (Sri Lankan Rupee).
  final CurrencyInfo currencyInfo;

  /// Creates Sinhala-specific options.
  const SiOptions({
    this.includeAD = false,
    this.negativePrefix = "සෘණ",
    this.currencyInfo = CurrencyInfo.lkr,
    // --- Inherited options ---
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.period, // Default word: "දශම" (dashama)
    super.round = false, // Inherited: round the number
    // Note: GrammaticalCase and Gender are not typically required for Sinhala number conversion.
    super.caseValue,
  });
}
