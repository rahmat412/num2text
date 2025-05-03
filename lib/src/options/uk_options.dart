import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Ukrainian (`Lang.UK`) language version.
class UkOptions extends BaseOptions {
  /// Determines if "н.е." (нашої ери - of our era, AD/CE) suffix is added
  /// for positive years when using [Format.year]. BC/BCE ("до н.е.") is typically handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"мінус"` (minus).
  final String negativePrefix;

  /// Specifies the currency details (unit names, complex plural forms, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.uah] (Ukrainian Hryvnia).
  final CurrencyInfo currencyInfo;

  /// Specifies the grammatical [Gender] to use for number words, primarily affecting 'один' (one) and 'два' (two).
  /// - `Gender.masculine`: "один", "два" (Default for standard numbers)
  /// - `Gender.feminine`: "одна", "дві" (Used for feminine nouns like "гривня", "тисяча")
  /// - `Gender.neuter`: "одне", "два" (Used for neuter nouns)
  /// If `null`, the converter uses the default (masculine for standard numbers) or infers from context (feminine for currency units).
  /// Defaults to `null`.
  final Gender? gender;

  /// Creates Ukrainian-specific options.
  const UkOptions({
    this.includeAD = false,
    this.negativePrefix = "мінус",
    this.currencyInfo = CurrencyInfo.uah,
    this.gender,
    super.currency = false,
    super.format,
    super.decimalSeparator = DecimalSeparator.comma,
    super.round = false,
  });
}
