import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Mongolian (`Lang.MN`) language version.
class MnOptions extends BaseOptions {
  /// Determines if "НТ" (Нийтийн Тоолол - Common Era, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("НТӨ") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"хасах"` (khasakh - subtract/minus).
  final String negativePrefix;

  /// Specifies the currency details (unit names) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.mnt] (Mongolian Tögrög). Subunit (möngö) is largely unused.
  final CurrencyInfo currencyInfo;

  /// Creates Mongolian-specific options.
  const MnOptions({
    this.includeAD = false,
    this.negativePrefix = "хасах",
    this.currencyInfo = CurrencyInfo.mnt,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.period, // Default word: "цэг" (tseg)
    super.round = false, // Inherited: round the number
  });
}
