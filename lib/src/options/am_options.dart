import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Amharic (`Lang.AM`) language version.
class AmOptions extends BaseOptions {
  /// Determines if the "ዓ.ም." (Amete Mihret - Year of Mercy / Ethiopian Calendar Era) suffix
  /// is added for positive years when using [Format.year]. Note this relates to the Ethiopian calendar era,
  /// often aligned with AD/CE but calculation might differ. BC/BCE might use "ዓ.ዓ.".
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"አሉታዊ"` (alutawi - negative).
  final String negativePrefix;

  /// Specifies the currency details (unit names, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.etb] (Ethiopian Birr).
  final CurrencyInfo currencyInfo;

  /// Creates Amharic-specific options.
  const AmOptions({
    this.includeAD = false,
    this.negativePrefix = "አሉታዊ",
    this.currencyInfo = CurrencyInfo.etb,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.period, // Default word: "ነጥብ" (neṭib)
    super.round = false, // Inherited: round the number
  });
}
