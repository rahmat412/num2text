## 0.0.4

- **fix(vi):** Corrected the implementation of the "linh"/"lẻ" rule for Vietnamese (`Lang.VI`) to accurately handle the "không trăm linh/lẻ" padding for chunks less than 100 following higher scale words (e.g., `1001` is now correctly "một nghìn không trăm linh một"). Aligned logic with strict grammatical rules based on reference examples.
- **test(vi):** Updated Vietnamese test expectations to reflect the strict "không trăm linh/lẻ" rule, resolving previous inconsistencies caused by simplification assumptions.

## 0.0.3

- **Enhanced core conversion logic, resulting in improved output accuracy for many numbers and languages.**
- **Improved and expanded the test suite.**
- _Note: While accuracy is improved, the library is still under development and may not be 100% accurate for all complex cases or languages (as detailed in `note.md`)._

## 0.0.2

- fix: Resolved pub.dev static analysis issues.
- chore: Improved overall code health and formatting based on linter suggestions.

## 0.0.1

- **Initial release of the `num2text` library.**
- Core functionality for converting numbers (`int`, `double`, `BigInt`, `String`, `Decimal`) to words.
- Support for **69 languages** via the `Lang` enum.
- Language-specific options classes (e.g., `EnOptions`, `ViOptions`) for customization.
- Support for:
  - Cardinal number conversion (up to 24 digits).
  - Currency formatting (`currency: true` option and `CurrencyInfo`).
  - Year formatting (`format: Format.year`).
  - Decimal number formatting (integer and fractional parts).
  - Negative number handling.
  - Large numbers using standard scales (thousand, million, billion, etc.).
- Basic error handling and optional fallback string.
- Includes utility functions for number normalization.
- Comprehensive tests for each supported language located in `test/lang/`.
