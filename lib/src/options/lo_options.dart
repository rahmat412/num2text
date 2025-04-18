import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Lao (`Lang.LO`) language version.
class LoOptions extends BaseOptions {
  // Note: Lao typically uses the Buddhist Era (BE - พ.ศ./ພ.ສ.). AD/CE (ค.ศ./ຄ.ສ.) is less common.
  // An 'includeEra' or specific era system option could be added for full support.
  // final bool includeAD; // Not included by default as BE is more common.

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"ລົບ"` (lop - subtract/minus).
  final String negativePrefix;

  /// Specifies the currency details (unit names) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.lak] (Lao Kip). Subunit (att) is largely unused.
  final CurrencyInfo currencyInfo;

  /// Creates Lao-specific options.
  const LoOptions({
    // this.includeAD = false,
    this.negativePrefix = "ລົບ",
    this.currencyInfo = CurrencyInfo.lak,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.period, // Default word: "ຈຸດ" (chut)
    super.round = false, // Inherited: round the number
  });
}
