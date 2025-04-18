import '../concurencies/concurencies_info.dart';
import 'base_options.dart';

/// Options specific to the Hebrew (`Lang.HE`) language version.
class HeOptions extends BaseOptions {
  // Hebrew year formatting doesn't typically use standard AD/BC suffixes.
  // Common usage involves the Hebrew calendar or "לספירה" (Common Era).
  // final bool includeAD; // Kept for potential future use, but default is false.

  /// The prefix word used for negative numbers when *not* using [Format.year].
  /// Defaults to `"מינוס"` (minus).
  /// Note: Grammatical agreement might be needed for alternative prefixes.
  final String negativePrefix;

  /// Specifies the currency details (unit names, grammatical genders, separator) to use when `currency` is `true`.
  /// Defaults to [CurrencyInfo.ils] (Israeli New Shekel).
  final CurrencyInfo currencyInfo;

  /// Specifies the grammatical [Gender] for number words. This is crucial in Hebrew, affecting
  /// forms of 1, 2, and numbers in construct state (e.g., with thousands, millions).
  /// Choose based on the noun being counted (feminine is needed for Shekel subunits - Agorot).
  /// Defaults to `Gender.masculine`.
  final Gender gender;

  /// Creates Hebrew-specific options.
  const HeOptions({
    // this.includeAD = false, // Currently not standard for Hebrew formatting.
    this.negativePrefix = "מינוס", // Corrected to Hebrew "מינוס"
    this.currencyInfo = CurrencyInfo.ils,
    this.gender = Gender.masculine,
    super.currency = false,
    super.format, // Inherited: special format context (e.g., Format.year)
    super.decimalSeparator =
        DecimalSeparator.period, // Default word: "נקודה" (nekuda)
    super.round = true, // Currency formatting often rounds subunits.
  });
}
