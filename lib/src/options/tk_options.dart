import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Turkmen (`Lang.TK`) language version.
class TkOptions extends BaseOptions {
  /// Determines if "AD" (AD/CE) suffix is added for positive years
  /// when using [Format.year]. BC/BCE ("BC") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"minus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.tmt] (Turkmenistani Manat).
  final CurrencyInfo currencyInfo;

  /// Creates Turkmen-specific options.
  const TkOptions({
    this.includeAD = false,
    this.negativePrefix = "minus",
    this.currencyInfo = CurrencyInfo.tmt,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.comma, // Default word: "comma"
    super.round =
        false, // Inherited: round the number (Test cases imply ignoring subunits)
  });
}
