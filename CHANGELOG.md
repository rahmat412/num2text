## 0.0.1 - 2025-18-04

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
