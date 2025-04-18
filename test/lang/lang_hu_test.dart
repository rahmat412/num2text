import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Hungarian (HU)', () {
    final converter = Num2Text(initialLang: Lang.HU);
    final converterWithFallback = Num2Text(
      initialLang: Lang.HU,
      fallbackOnError: "Érvénytelen szám",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("nulla"));
      expect(converter.convert(1), equals("egy"));
      expect(converter.convert(10), equals("tíz"));
      expect(converter.convert(11), equals("tizenegy"));
      expect(converter.convert(20), equals("húsz"));
      expect(converter.convert(21), equals("huszonegy"));
      expect(converter.convert(99), equals("kilencvenkilenc"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("száz"));
      expect(converter.convert(101), equals("százegy"));
      expect(converter.convert(111), equals("száztizenegy"));
      expect(converter.convert(200), equals("kétszáz"));
      expect(converter.convert(999), equals("kilencszázkilencvenkilenc"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("ezer"));
      expect(converter.convert(1001), equals("ezeregy"));
      expect(converter.convert(1111), equals("ezerszáztizenegy"));
      expect(converter.convert(2000), equals("kétezer"));
      expect(converter.convert(10000), equals("tízezer"));
      expect(converter.convert(100000), equals("százezer"));

      expect(converter.convert(123456),
          equals("százhuszonháromezer-négyszázötvenhat"));
      expect(
        converter.convert(999999),
        equals("kilencszázkilencvenkilencezer-kilencszázkilencvenkilenc"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("mínusz egy"));
      expect(converter.convert(-123), equals("mínusz százhuszonhárom"));
      expect(
        converter.convert(-1, options: HuOptions(negativePrefix: "negatív")),
        equals("negatív egy"),
      );
      expect(
        converter.convert(-123, options: HuOptions(negativePrefix: "negatív")),
        equals("negatív százhuszonhárom"),
      );
    });

    test('Year Formatting', () {
      const yearOption = HuOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("ezerkilencszáz"));
      expect(converter.convert(2024, options: yearOption),
          equals("kétezer-huszonnégy"));
      expect(
        converter.convert(1900,
            options: HuOptions(format: Format.year, includeAD: true)),
        equals("ezerkilencszáz i.sz."),
      );
      expect(
        converter.convert(2024,
            options: HuOptions(format: Format.year, includeAD: true)),
        equals("kétezer-huszonnégy i.sz."),
      );

      expect(converter.convert(-100, options: yearOption), equals("száz i.e."));
      expect(converter.convert(-1, options: yearOption), equals("egy i.e."));
      expect(
        converter.convert(-2024,
            options: HuOptions(format: Format.year, includeAD: true)),
        equals("kétezer-huszonnégy i.e."),
      );
    });

    test('Currency', () {
      const currencyOption = HuOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("nulla forint"));
      expect(
          converter.convert(1, options: currencyOption), equals("egy forint"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("egy forint ötven fillér"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("százhuszonhárom forint negyvenöt fillér"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("százhuszonhárom egész négy öt hat"),
      );
      expect(converter.convert(Decimal.parse('1.50')), equals("egy egész öt"));
      expect(converter.convert(123.0), equals("százhuszonhárom"));
      expect(
          converter.convert(Decimal.parse('123.0')), equals("százhuszonhárom"));

      expect(
        converter.convert(1.5,
            options: const HuOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("egy egész öt"),
      );

      expect(
        converter.convert(1.5,
            options:
                const HuOptions(decimalSeparator: DecimalSeparator.period)),
        equals("egy pont öt"),
      );
      expect(
        converter.convert(1.5,
            options: const HuOptions(decimalSeparator: DecimalSeparator.point)),
        equals("egy pont öt"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Végtelen"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negatív végtelen"));
      expect(converter.convert(double.nan), equals("Nem szám"));
      expect(converter.convert(null), equals("Nem szám"));
      expect(converter.convert('abc'), equals("Nem szám"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Végtelen"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negatív végtelen"));
      expect(converterWithFallback.convert(double.nan),
          equals("Érvénytelen szám"));
      expect(converterWithFallback.convert(null), equals("Érvénytelen szám"));
      expect(converterWithFallback.convert('abc'), equals("Érvénytelen szám"));
      expect(converterWithFallback.convert(123), equals("százhuszonhárom"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("egymillió"));
      expect(converter.convert(BigInt.from(1000000000)), equals("egymilliárd"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("egybillió"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("egybilliárd"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("egytrillió"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("egytrilliárd"));
      expect(converter.convert(BigInt.parse('1000000000000000000000000')),
          equals("egykvadrillió"));

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "százhuszonhárom trilliárd négyszázötvenhat trillió hétszáznyolcvankilenc billiárd százhuszonhárom billió négyszázötvenhat milliárd hétszáznyolcvankilenc millió százhuszonháromezer-négyszázötvenhat",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "kilencszázkilencvenkilenc trilliárd kilencszázkilencvenkilenc trillió kilencszázkilencvenkilenc billiárd kilencszázkilencvenkilenc billió kilencszázkilencvenkilenc milliárd kilencszázkilencvenkilenc millió kilencszázkilencvenkilencezer-kilencszázkilencvenkilenc",
        ),
      );
    });
  });
}
