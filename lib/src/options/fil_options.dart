import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Filipino (`Lang.FIL`) language version.
class FilOptions extends BaseOptions {
  /// Determines if "AD" (After Christ / Pagkatapos ni Kristo) suffix is added for positive years
  /// when using [Format.year]. Filipino often uses English abbreviations. BC/BCE is handled internally.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"negatibo"`.
  final String negativePrefix;

  /// Specifies the currency details (unit names, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.php] (Philippine Peso).
  final CurrencyInfo currencyInfo;

  /// Creates Filipino-specific options.
  const FilOptions({
    this.includeAD = false,
    this.negativePrefix = "negatibo",
    this.currencyInfo = CurrencyInfo.php,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator = DecimalSeparator.period, // Default word: "punto"
    super.round = false, // Inherited: round the number
  });
}
