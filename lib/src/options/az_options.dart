import 'base_options.dart';
import '../concurencies/concurencies_info.dart';

/// Options specific to the Azerbaijani (`Lang.AZ`) language version.
class AzOptions extends BaseOptions {
  /// Determines if "e." or "eramızın" (of our era - AD/CE) suffix is added for positive years
  /// when using [Format.year]. BC/BCE ("e.ə.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"mənfi"` (negative).
  final String negativePrefix;

  /// Specifies the currency details (unit names, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.azn] (Azerbaijani Manat).
  final CurrencyInfo currencyInfo;

  /// Creates Azerbaijani-specific options.
  const AzOptions({
    this.includeAD = false,
    this.negativePrefix = "mənfi",
    this.currencyInfo = CurrencyInfo.azn,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.comma, // Default word: "vergül"
    super.round = false, // Inherited: round the number
  });
}
