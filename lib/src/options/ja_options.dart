import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Japanese (`Lang.JA`) language version.
class JaOptions extends BaseOptions {
  /// Determines if "西暦" (seireki - Western calendar year, AD/CE) is added
  /// when using [Format.year]. BC/BCE ("紀元前" - kigenzen) is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"マイナス"` (mainasu - minus).
  final String negativePrefix;

  /// Specifies the currency details (unit name) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.jpy] (Japanese Yen). Subunit (sen) is deprecated.
  final CurrencyInfo currencyInfo;

  /// Creates Japanese-specific options.
  const JaOptions({
    this.includeAD = false,
    this.negativePrefix = "マイナス",
    this.currencyInfo = CurrencyInfo.jpy,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.period, // Default word: "点" (ten)
    super.round = false, // Inherited: round the number
  });
}
