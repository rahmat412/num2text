import 'package:decimal/decimal.dart'; // Assuming normalization happens before calling process

import 'options/base_options.dart';

/// Abstract base class defining the contract for language-specific number-to-words converters.
///
/// Each supported language **must** provide a concrete implementation of this class
/// (e.g., `Num2TextEN`, `Num2TextFR`) that handles the specific grammatical rules,
/// vocabulary, and formatting options for that language.
///
/// Instances of these implementations are managed by the main [Num2Text] class.
abstract class Num2TextBase {
  /// Converts a given [number] into its cardinal word representation according
  /// to the rules of the specific language implementation.
  ///
  /// This method expects the core conversion logic to reside within its implementation.
  /// It should handle various formatting options provided via [options].
  ///
  /// - [number]: The number to convert. It's recommended that the [Num2Text.convert]
  ///   method normalizes this to a [Decimal] before passing it here, but the
  ///   implementing class should ideally handle potential type variations or throw.
  /// - [options]: An optional [BaseOptions] instance (or a language-specific subclass)
  ///   containing formatting preferences (e.g., currency, year, gender, case).
  ///   The implementation should check `options?.currency`, `options?.format` etc.
  ///   and apply the corresponding logic. If `null`, default formatting applies.
  /// - [fallbackOnError]: An optional string to return if an *uncaught* error occurs
  ///   within this specific `process` implementation. If `null`, the implementation
  ///   might return a default error string or let the exception propagate up.
  ///
  /// Returns the textual representation of the number as a [String].
  /// Returns [fallbackOnError] or a default error string if conversion fails and
  /// cannot be handled gracefully.
  String process(dynamic number, BaseOptions? options, String? fallbackOnError);
}
