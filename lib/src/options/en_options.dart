import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the English (`Lang.EN`) language version.
class EnOptions extends BaseOptions {
  /// Determines if 'and' is used to connect hundreds with the tens/units part.
  /// Typically used in British English.
  ///
  /// Example:
  /// - `true`: "one hundred **and** twenty-three" (British style)
  /// - `false`: "one hundred twenty-three" (American style) - Default
  final bool includeAnd;

  /// Determines if the "AD" (Anno Domini) or "CE" (Common Era) suffix is added for positive years
  /// when using [Format.year]. BC/BCE is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"minus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.usd] (US Dollar). Set to `CurrencyInfo.gbp`, `CurrencyInfo.eur`, etc. for others.
  final CurrencyInfo currencyInfo;

  /// Creates English-specific options.
  const EnOptions({
    this.includeAnd = false,
    this.includeAD = false,
    this.negativePrefix = "minus",
    this.currencyInfo = CurrencyInfo.usd,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.period, // Default word: "point"
    super.round = false, // Inherited: round the number
  });
}
