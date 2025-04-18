import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Afrikaans (`Lang.AF`) language version.
class AfOptions extends BaseOptions {
  /// Determines if 'en' (and) is used to connect hundreds with tens/units.
  ///
  /// Example:
  /// - `true`: "een honderd **en** een" (one hundred and one) - Default
  /// - `false`: "een honderd een" (less common)
  final bool includeAnd;

  /// Determines if the "n.C." (na Christus - AD/CE) suffix is added for positive years
  /// when using [Format.year]. BC years ("v.C.") are typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"minus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.zar] (South African Rand - Afrikaans terms).
  final CurrencyInfo currencyInfo;

  /// Creates Afrikaans-specific options.
  const AfOptions({
    this.includeAnd = true,
    this.includeAD = false,
    this.negativePrefix = "minus",
    this.currencyInfo = CurrencyInfo.zar,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.comma, // Default word: "komma"
    super.round = false, // Inherited: round the number
  });
}
