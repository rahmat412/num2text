import 'package:decimal/decimal.dart';

/// Provides utility functions commonly used within the number conversion process.
class Utils {
  /// Normalizes various numeric input types into a standard [Decimal] instance
  /// for consistent and precise internal calculations.
  ///
  /// Handles the following input types:
  /// - [int]: Converted directly using `Decimal.fromInt()`.
  /// - [double]: Converted via `toString()` and `Decimal.parse()` to mitigate potential
  ///   binary precision issues inherent in direct double-to-decimal conversion.
  ///   Returns `null` if the double is `NaN` or `infinity`.
  /// - [BigInt]: Converted directly using `Decimal.fromBigInt()`.
  /// - [String]: Trimmed and parsed using `Decimal.tryParse()`. Returns `null` if parsing fails.
  /// - [Decimal]: Returned directly without modification.
  ///
  /// Returns the normalized [Decimal] value.
  ///
  /// Returns `null` if the input [number] is:
  /// - `null`
  /// - Not one of the handled types (e.g., `bool`, `List`, `Map`)
  /// - A `double` representing `NaN` or `infinity`
  /// - A `String` that cannot be successfully parsed into a `Decimal`.
  static Decimal? normalizeNumber(dynamic number) {
    if (number == null) return null;

    // Direct handling for common types
    if (number is Decimal) return number;
    if (number is int) return Decimal.fromInt(number);
    if (number is BigInt) return Decimal.fromBigInt(number);

    if (number is double) {
      // Handle non-finite doubles explicitly before attempting string conversion.
      if (number.isNaN || number.isInfinite) {
        // Cannot represent NaN or Infinity as Decimal.
        return null;
      }
      // Using toString() is generally safer for preserving the intended decimal value
      // as represented in code, compared to direct double-to-decimal which uses
      // the potentially imprecise binary representation.
      try {
        // Parse the string representation.
        return Decimal.parse(number.toString());
      } catch (_) {
        // Catch potential format exceptions from toString()/parse(), although unlikely for finite doubles.
        return null;
      }
    }

    if (number is String) {
      // Attempt to parse the trimmed string. tryParse handles invalid formats gracefully by returning null.
      return Decimal.tryParse(number.trim());
    }

    // If the type wasn't handled above, it's considered invalid for normalization.
    return null;
  }
}

/// Extension methods providing convenient helpers for the [Decimal] class.
extension DecimalExt on Decimal {
  /// Returns `true` if the decimal value is strictly less than zero (`< 0`).
  bool get isNegative => this < Decimal.zero;

  // Add more Decimal extensions if needed, e.g., isInteger, precision checks.
}

/// Extension methods providing convenient helpers for the [String] class.
extension StringExt on String {
  /// Converts the string to Title Case.
  ///
  /// Example: `"hello world"` becomes `"Hello World"`.
  ///
  /// Splits the string by spaces, capitalizes the first letter of each non-empty word,
  /// converts the rest of the word to lowercase, and joins them back with single spaces.
  ///
  /// Note: This is a basic implementation. It might not produce ideal results for:
  /// - Strings with leading/trailing/multiple spaces (though it handles empty words).
  /// - Proper nouns requiring specific capitalization.
  /// - Acronyms (e.g., "USA" becomes "Usa").
  /// - Hyphenated words (e.g., "well-being" becomes "Well-being").
  String get toTitleCase {
    // Handle empty string edge case.
    if (isEmpty) return "";

    return split(' ')
        // Filter out empty strings resulting from multiple spaces.
        .where((word) => word.isNotEmpty)
        .map((word) {
      // Capitalize first letter, lowercase the rest.
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    })
        // Join words back with a single space.
        .join(' ');
  }

  // Add more String extensions if needed.
}
