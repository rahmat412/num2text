import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Urdu (`Lang.UR`) language version.
class UrOptions extends BaseOptions {
  /// Determines if "عیسوی" (īsvī - AD/CE) suffix is added for positive years
  /// when using [Format.year]. BC/BCE ("قبل مسیح" - qabl-e masīh) is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"منفی"` (manfi - negative).
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.pkr] (Pakistani Rupee).
  final CurrencyInfo currencyInfo;

  /// Creates Urdu-specific options.
  const UrOptions({
    this.includeAD = false,
    this.negativePrefix = "منفی",
    this.currencyInfo = CurrencyInfo.pkr,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.period, // Default word: "اعشاریہ" (ashāriya)
    super.round = false, // Inherited: round the number
  });
}
