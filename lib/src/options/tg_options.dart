import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Tajik (`Lang.TG`) language version.
class TgOptions extends BaseOptions {
  /// Determines if "м." (милодӣ - milodī, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("п.м." - пеш аз милод) is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"минус"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.tjs] (Tajikistani Somoni).
  final CurrencyInfo currencyInfo;

  /// Creates Tajik-specific options.
  const TgOptions({
    this.includeAD = false,
    this.negativePrefix = "минус",
    this.currencyInfo = CurrencyInfo.tjs,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    // Default word varies; "бутун" (butun) or "вергул" (vergul) for comma.
    super.decimalSeparator = DecimalSeparator.point,
    super.round = false, // Inherited: round the number
  });
}
