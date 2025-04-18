import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Swahili (SW)', () {
    final converter = Num2Text(initialLang: Lang.SW);
    final converterWithFallback =
        Num2Text(initialLang: Lang.SW, fallbackOnError: "Nambari batili");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("sifuri"));
      expect(converter.convert(1), equals("moja"));
      expect(converter.convert(10), equals("kumi"));
      expect(converter.convert(11), equals("kumi na moja"));
      expect(converter.convert(20), equals("ishirini"));
      expect(converter.convert(21), equals("ishirini na moja"));
      expect(converter.convert(99), equals("tisini na tisa"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("mia moja"));
      expect(converter.convert(101), equals("mia moja na moja"));
      expect(converter.convert(111), equals("mia moja na kumi na moja"));
      expect(converter.convert(200), equals("mia mbili"));

      expect(converter.convert(999), equals("mia tisa na tisini na tisa"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("elfu moja"));
      expect(converter.convert(1001), equals("elfu moja na moja"));

      expect(converter.convert(1111),
          equals("elfu moja na mia moja na kumi na moja"));
      expect(converter.convert(2000), equals("elfu mbili"));
      expect(converter.convert(10000), equals("elfu kumi"));
      expect(converter.convert(100000), equals("laki moja"));

      expect(
        converter.convert(123456),
        equals(
            "laki moja na elfu ishirini na tatu na mia nne na hamsini na sita"),
      );

      expect(
        converter.convert(999999),
        equals(
            "laki tisa na elfu tisini na tisa na mia tisa na tisini na tisa"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("hasi moja"));

      expect(
          converter.convert(-123), equals("hasi mia moja na ishirini na tatu"));
      expect(
        converter.convert(-1, options: SwOptions(negativePrefix: "minus")),
        equals("minus moja"),
      );

      expect(
        converter.convert(-123, options: SwOptions(negativePrefix: "minus")),
        equals("minus mia moja na ishirini na tatu"),
      );
    });

    test('Year Formatting', () {
      const yearOption = SwOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("elfu moja mia tisa"));
      expect(converter.convert(2024, options: yearOption),
          equals("elfu mbili ishirini na nne"));
      expect(
        converter.convert(1900,
            options: SwOptions(format: Format.year, includeAD: true)),
        equals("elfu moja mia tisa BK"),
      );
      expect(
        converter.convert(2024,
            options: SwOptions(format: Format.year, includeAD: true)),
        equals("elfu mbili ishirini na nne BK"),
      );
      expect(
          converter.convert(-100, options: yearOption), equals("mia moja KK"));
      expect(converter.convert(-1, options: yearOption), equals("moja KK"));
      expect(
        converter.convert(-2024, options: SwOptions(format: Format.year)),
        equals("elfu mbili ishirini na nne KK"),
      );
    });

    test('Currency', () {
      const currencyOption = SwOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("shilingi sifuri"));
      expect(converter.convert(1, options: currencyOption),
          equals("shilingi moja"));
      expect(
        converter.convert(1.01, options: currencyOption),
        equals("shilingi moja na senti moja"),
      );
      expect(
        converter.convert(2.50, options: currencyOption),
        equals("shilingi mbili na senti hamsini"),
      );

      expect(
        converter.convert(123.45, options: currencyOption),
        equals(
            "shilingi mia moja na ishirini na tatu na senti arobaini na tano"),
      );
      expect(converter.convert(0.45, options: currencyOption),
          equals("senti arobaini na tano"));
      expect(
        converter.convert(120, options: currencyOption),
        equals("shilingi mia moja na ishirini"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("mia moja na ishirini na tatu pointi nne tano sita"),
      );

      expect(
          converter.convert(Decimal.parse('1.50')), equals("moja pointi tano"));

      expect(converter.convert(123.0), equals("mia moja na ishirini na tatu"));

      expect(converter.convert(Decimal.parse('123.0')),
          equals("mia moja na ishirini na tatu"));
      expect(converter.convert(0.5), equals("sifuri pointi tano"));

      expect(
        converter.convert(1.5,
            options: const SwOptions(decimalSeparator: DecimalSeparator.point)),
        equals("moja pointi tano"),
      );
      expect(
        converter.convert(1.5,
            options:
                const SwOptions(decimalSeparator: DecimalSeparator.period)),
        equals("moja pointi tano"),
      );
      expect(
        converter.convert(1.5,
            options: const SwOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("moja koma tano"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Ukomo"));
      expect(converter.convert(double.negativeInfinity), equals("Hasi ukomo"));
      expect(converter.convert(double.nan), equals("Si nambari"));
      expect(converter.convert(null), equals("Si nambari"));
      expect(converter.convert('abc'), equals("Si nambari"));

      expect(converterWithFallback.convert(double.infinity), equals("Ukomo"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Hasi ukomo"));
      expect(
          converterWithFallback.convert(double.nan), equals("Nambari batili"));
      expect(converterWithFallback.convert(null), equals("Nambari batili"));
      expect(converterWithFallback.convert('abc'), equals("Nambari batili"));

      expect(converterWithFallback.convert(123),
          equals("mia moja na ishirini na tatu"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("milioni moja"));
      expect(
          converter.convert(BigInt.from(1000000000)), equals("bilioni moja"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("trilioni moja"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("kwadrilioni moja"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("kwintilioni moja"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("sekstilioni moja"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("septilioni moja"),
      );

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "sekstilioni mia moja na ishirini na tatu na kwintilioni mia nne na hamsini na sita na kwadrilioni mia saba na themanini na tisa na trilioni mia moja na ishirini na tatu na bilioni mia nne na hamsini na sita na milioni mia saba na themanini na tisa na laki moja na elfu ishirini na tatu na mia nne na hamsini na sita",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "sekstilioni mia tisa na tisini na tisa na kwintilioni mia tisa na tisini na tisa na kwadrilioni mia tisa na tisini na tisa na trilioni mia tisa na tisini na tisa na bilioni mia tisa na tisini na tisa na milioni mia tisa na tisini na tisa na laki tisa na elfu tisini na tisa na mia tisa na tisini na tisa",
        ),
      );
    });
  });
}
