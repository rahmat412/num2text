import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Arabic (`Lang.AR`) language version.
class ArOptions extends BaseOptions {
  /// Determines if the "م" (milādi - AD/CE) suffix is added for positive years
  /// when using [Format.year]. BC/BCE ("ق.م.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"سالب"` (sālib - negative).
  final String negativePrefix;

  /// Specifies the currency details (unit names, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.sar] (Saudi Riyal). Other regional currencies might require a different [CurrencyInfo].
  final CurrencyInfo currencyInfo;

  /// Specifies the grammatical [Gender] to use for number words, which is crucial in Arabic.
  /// This affects the forms of 1 and 2, and agreement in compound numbers (11-19) and decades.
  /// Choose based on the noun being counted (or default to masculine if unspecified).
  /// Defaults to `Gender.masculine`.
  final Gender gender;

  /// Creates Arabic-specific options.
  const ArOptions({
    this.includeAD = false,
    this.negativePrefix = "سالب",
    this.currencyInfo = CurrencyInfo.sar,
    this.gender = Gender.masculine,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.comma, // Default word: "فاصلة" (fāṣila)
    super.round = false, // Inherited: round the number
  });
}
