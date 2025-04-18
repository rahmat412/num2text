import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Portuguese (`Lang.PT`) language version.
class PtOptions extends BaseOptions {
  /// Controls the explicit use of 'e' (and). Portuguese grammar often inserts 'e' automatically,
  /// especially between hundreds and tens/units, and before the last group.
  /// Setting this might influence specific edge cases if default behavior needs override.
  /// Defaults to `true` (reflecting common usage).
  final bool includeAnd;

  /// Determines if "d.C." (depois de Cristo - after Christ, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("a.C.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"menos"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.brl] (Brazilian Real). Use [CurrencyInfo.eurPt] for European Portuguese Euro.
  final CurrencyInfo currencyInfo;

  /// Creates Portuguese-specific options.
  const PtOptions({
    this.includeAnd = true,
    this.includeAD = false,
    this.negativePrefix = "menos",
    this.currencyInfo = CurrencyInfo.brl,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.comma, // Default word: "vírgula" or "inteiros"
    super.round = false, // Inherited: round the number
  });
}
