import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Albanian (`Lang.SQ`) language version.
class SqOptions extends BaseOptions {
  /// Determines if "e.s." (era jonë - our era, AD/CE) or similar suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("p.e.s.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"minus"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.all] (Albanian Lek).
  final CurrencyInfo currencyInfo;

  /// Creates Albanian-specific options.
  const SqOptions({
    this.includeAD = false,
    this.negativePrefix = "minus",
    this.currencyInfo = CurrencyInfo.all,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.comma, // Default word: "presje"
    super.round = false, // Inherited: round the number
  });
}
