import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Chinese (`Lang.ZH`) language version.
class ZhOptions extends BaseOptions {
  /// Determines if "公元" (gōngyuán - Common Era, AD/CE) is added
  /// when using [Format.year]. BC/BCE ("公元前" - gōngyuánqián) is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix character/word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"负"` (fù - negative).
  final String negativePrefix;

  /// Specifies the currency details (unit names, structure) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.cny] (Chinese Yuan Renminbi). Can be set for HKD, TWD etc.
  final CurrencyInfo currencyInfo;

  /// Creates Chinese-specific options.
  const ZhOptions({
    this.includeAD = false,
    this.negativePrefix = "负",
    this.currencyInfo = CurrencyInfo.cny,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.period, // Default word: "点" (diǎn)
    super.round = false, // Inherited: round the number
  });
}
