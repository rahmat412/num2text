import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Uzbek (`Lang.UZ`) language version.
class UzOptions extends BaseOptions {
  /// Determines if "milodiy" (AD/CE) suffix is added for positive years
  /// when using [Format.year]. BC/BCE ("miloddan avvalgi") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"minus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.uzs] (Uzbekistani So'm).
  final CurrencyInfo currencyInfo;

  /// Creates Uzbek-specific options.
  const UzOptions({
    this.includeAD = false,
    this.negativePrefix = "minus",
    this.currencyInfo = CurrencyInfo.uzs,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator
        .period, // Default word: "butun" (whole) or "nuqta" (point)
    super.round = false, // Inherited: round the number
  });
}
