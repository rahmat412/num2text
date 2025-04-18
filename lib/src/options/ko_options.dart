import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Korean (`Lang.KO`) language version.
class KoOptions extends BaseOptions {
  /// Determines if "서기" (seogi - Western calendar year, AD/CE) is added
  /// when using [Format.year]. BC/BCE ("기원전" - giwonjeon) is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"마이너스"` (mainôseu - minus).
  final String negativePrefix;

  /// Specifies the currency details (unit name) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.krw] (South Korean Won). Subunit (jeon) is deprecated.
  final CurrencyInfo currencyInfo;

  /// Creates Korean-specific options.
  const KoOptions({
    this.includeAD = false,
    this.negativePrefix = "마이너스",
    this.currencyInfo = CurrencyInfo.krw,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.period, // Default word: "점" (jeom)
    super.round = false, // Inherited: round the number
  });
}
