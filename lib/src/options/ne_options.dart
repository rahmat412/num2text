import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Nepali (`Lang.NE`) language version.
class NeOptions extends BaseOptions {
  /// Determines if "ईस्वी" (īsvī - AD/CE) suffix is added for positive years
  /// when using [Format.year]. BC/BCE ("ईसा पूर्व") is typically handled internally.
  /// Note: Nepal primarily uses the Vikrami Samvat calendar.
  /// Defaults to `false`.
  final bool includeAD;

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"माइनस"` (māinas). Could also be "ऋण" (ṛṇa - negative).
  final String negativePrefix;

  /// Specifies the currency details (unit names, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.npr] (Nepalese Rupee).
  final CurrencyInfo currencyInfo;

  /// Creates Nepali-specific options.
  const NeOptions({
    this.includeAD = false,
    this.negativePrefix = "माइनस",
    this.currencyInfo = CurrencyInfo.npr,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.period, // Default word: "दशमलव" (daśamlav)
    super.round = false, // Inherited: round the number
  });
}
