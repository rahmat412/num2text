/// Defines grammatical gender, used for number word agreement in some languages.
enum Gender { masculine, feminine, neuter }

/// Defines grammatical case, relevant for word form selection in highly inflected languages.
enum GrammaticalCase { nominative, genitive, dative, accusative }

/// Defines the character symbol used for decimal separation in numeric input/output,
/// influencing which word is used for the separator (e.g., "point", "comma").
enum DecimalSeparator {
  /// Represents a comma (`,`) as the decimal separator. Word might be "comma", "virgule", etc.
  comma,

  /// Represents a period (`.`) as the decimal separator. Word might be "point", "dot", etc.
  period,

  /// Often treated synonymously with `period`, represents (`.`). Word might be "point".
  point,
}

/// Defines specific formatting contexts that might alter the conversion rules.
enum Format {
  /// Format the number as a calendar year (e.g., handling AD/BC, specific year phrasing).
  year,
}

/// Defines script variations (hypothetical).
enum Script { latin, cyrillic, simplified }

/// Defines number system variations (hypothetical).
// enum NumberSystem { native }

/// Base class for language-specific number formatting options.
///
/// Provides common options applicable across multiple languages.
/// Language-specific implementations should extend this class to add their unique options.
abstract class BaseOptions {
  /// If `true`, triggers currency formatting logic within the language converter.
  /// This typically involves using the currency unit names defined in the corresponding
  /// `XxxOptions.currencyInfo` and applying specific currency rules (like subunit handling).
  /// Defaults to `false`.
  final bool currency;

  /// If `true`, the number might be rounded before conversion, typically to the
  /// number of decimal places relevant for the currency's subunit when [currency] is also `true`.
  /// The exact rounding behavior depends on the language implementation.
  /// Defaults to `false`.
  final bool round;

  /// Specifies the expected decimal separator symbol in the input, which determines
  /// the corresponding separator word used in the output (e.g., "point", "comma", "virgule").
  /// If `null`, the language converter might use a default separator. See [DecimalSeparator].
  final DecimalSeparator? decimalSeparator;

  /// Specifies the desired grammatical case for the resulting number words.
  /// Relevant only for languages with significant noun/adjective declension.
  /// If `null`, the default case (usually Nominative) is used. See [GrammaticalCase].
  final GrammaticalCase? caseValue;

  /// Specifies a special formatting context (e.g., year).
  /// If `null`, standard cardinal number conversion is performed. See [Format].
  final Format? format;

  const BaseOptions({
    this.currency = false,
    this.decimalSeparator,
    this.caseValue,
    this.format,
    this.round = false,
  });
}
