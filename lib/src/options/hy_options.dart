import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Armenian (`Lang.HY`) language version.
class HyOptions extends BaseOptions {
  /// Determines if era suffixes ("թ." for AD/CE, "մ.թ.ա." for BC/BCE) are added
  /// when using [Format.year]. "թ." stands for թվական (t’vakan - year/date),
  /// "մ.թ.ա." stands for մեր թվարկությունից առաջ (mer t’varkut’yunits’ arraj - before our era).
  /// Defaults to `false`.
  final bool includeEra; // Named 'includeEra' as per original

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"մինուս"` (minus).
  final String negativePrefix;

  /// Specifies the currency details (unit names, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.amd] (Armenian Dram).
  final CurrencyInfo currencyInfo;

  /// Creates Armenian-specific options.
  const HyOptions({
    this.includeEra = false,
    this.negativePrefix = "մինուս",
    this.currencyInfo = CurrencyInfo.amd,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.comma, // Default word: "ամբողջ" (amboghj)
    super.round = false, // Inherited: round the number
  });
}
