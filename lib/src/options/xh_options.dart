import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Xhosa (`Lang.XH`) language version.
class XhOptions extends BaseOptions {
  /// Determines if "emva koKristu" (after Christ, AD/CE) or similar suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("phambi koKristu") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"minus"` (loanword, native terms might exist).
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.zarXh] (South African Rand - Xhosa terms).
  final CurrencyInfo currencyInfo;

  /// Creates Xhosa-specific options.
  const XhOptions({
    this.includeAD = false,
    this.negativePrefix = "minus",
    this.currencyInfo = CurrencyInfo.zarXh,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.period, // Default word: "ichaphaza"
    super.round = false, // Inherited: round the number
  });
}
