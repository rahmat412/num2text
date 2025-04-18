import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Croatian (`Lang.HR`) language version.
class HrOptions extends BaseOptions {
  /// Determines if "n. e." (nove ere - of the new era, AD/CE) or similar suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("pr. n. e.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD; // Using AD as per original field name

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"minus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, appropriate cases/forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.eurHr] (Euro - Croatian terms, as Croatia uses the Euro).
  final CurrencyInfo currencyInfo;

  /// Creates Croatian-specific options.
  const HrOptions({
    this.includeAD = false,
    this.negativePrefix = "minus",
    this.currencyInfo = CurrencyInfo.eurHr,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.comma, // Default word: "zarez" or "cijelih"
    super.round =
        false, // Inherited: round the number (Test case implies non-rounding)
  });
}
