import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Afrikaans (AF)', () {
    final converter = Num2Text(initialLang: Lang.AF);
    final converterWithFallback = Num2Text(
      initialLang: Lang.AF,
      fallbackOnError: "Ongeldige Nommer",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("nul"));
      expect(converter.convert(1), equals("een"));
      expect(converter.convert(10), equals("tien"));
      expect(converter.convert(11), equals("elf"));
      expect(converter.convert(15), equals("vyftien"));
      expect(converter.convert(20), equals("twintig"));
      expect(converter.convert(21), equals("een-en-twintig"));
      expect(converter.convert(54), equals("vier-en-vyftig"));
      expect(converter.convert(99), equals("nege-en-neëntig"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("een honderd"));
      expect(converter.convert(101), equals("een honderd en een"));
      expect(converter.convert(105), equals("een honderd en vyf"));
      expect(converter.convert(111), equals("een honderd en elf"));
      expect(converter.convert(123), equals("een honderd en drie-en-twintig"));
      expect(converter.convert(200), equals("twee honderd"));
      expect(converter.convert(589), equals("vyf honderd en nege-en-tagtig"));
      expect(converter.convert(999), equals("nege honderd en nege-en-neëntig"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("een duisend"));
      expect(converter.convert(1001), equals("een duisend en een"));
      expect(converter.convert(1111), equals("een duisend een honderd en elf"));
      expect(converter.convert(2000), equals("twee duisend"));
      expect(converter.convert(10000), equals("tien duisend"));
      expect(converter.convert(15600), equals("vyftien duisend ses honderd"));
      expect(converter.convert(100000), equals("een honderd duisend"));
      expect(
        converter.convert(123456),
        equals(
            "een honderd drie-en-twintig duisend vier honderd en ses-en-vyftig"),
      );
      expect(
        converter.convert(999999),
        equals(
            "nege honderd nege-en-neëntig duisend nege honderd en nege-en-neëntig"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus een"));
      expect(converter.convert(-123),
          equals("minus een honderd en drie-en-twintig"));
      expect(
        converter.convert(-1, options: AfOptions(negativePrefix: "negatief")),
        equals("negatief een"),
      );
      expect(
        converter.convert(-123, options: AfOptions(negativePrefix: "negatief")),
        equals("negatief een honderd en drie-en-twintig"),
      );
    });

    test('Year Formatting', () {
      const yearOption = AfOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("negentienhonderd"));
      expect(converter.convert(2024, options: yearOption),
          equals("twee duisend vier-en-twintig"));
      expect(
        converter.convert(1900,
            options: AfOptions(format: Format.year, includeAD: true)),
        equals("negentienhonderd n.C."),
      );
      expect(
        converter.convert(2024,
            options: AfOptions(format: Format.year, includeAD: true)),
        equals("twee duisend vier-en-twintig n.C."),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("een honderd v.C."));
      expect(converter.convert(-1, options: yearOption), equals("een v.C."));
      expect(
        converter.convert(-2024,
            options: AfOptions(format: Format.year, includeAD: true)),
        equals("twee duisend vier-en-twintig v.C."),
      );
    });

    test('Currency', () {
      const currencyOption = AfOptions(currency: true);
      expect(converter.convert(0, options: currencyOption), equals("nul Rand"));
      expect(converter.convert(1, options: currencyOption), equals("een Rand"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("een Rand en vyftig sent"));
      expect(
          converter.convert(2, options: currencyOption), equals("twee Rand"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("een honderd en drie-en-twintig Rand en vyf-en-veertig sent"),
      );
      expect(converter.convert(1000, options: currencyOption),
          equals("een duisend Rand"));
      expect(
        converter.convert(123456.78, options: currencyOption),
        equals(
          "een honderd drie-en-twintig duisend vier honderd en ses-en-vyftig Rand en agt-en-sewentig sent",
        ),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("een honderd en drie-en-twintig komma vier vyf ses"),
      );
      expect(converter.convert(Decimal.parse('1.50')), equals("een komma vyf"));
      expect(converter.convert(Decimal.parse('1.05')),
          equals("een komma nul vyf"));
      expect(
          converter.convert(123.0), equals("een honderd en drie-en-twintig"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("een honderd en drie-en-twintig"));
      expect(
        converter.convert(1.5,
            options: const AfOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("een komma vyf"),
      );
      expect(
        converter.convert(1.5,
            options:
                const AfOptions(decimalSeparator: DecimalSeparator.period)),
        equals("een punt vyf"),
      );
      expect(
        converter.convert(1.5,
            options: const AfOptions(decimalSeparator: DecimalSeparator.point)),
        equals("een punt vyf"),
      );
    });

    test('infinity and invalid input', () {
      expect(converter.convert(double.infinity), equals("Oneindig"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negatief Oneindig"));
      expect(converter.convert(double.nan), equals("Nie 'n Nommer nie"));
      expect(converter.convert(null), equals("Nie 'n Nommer nie"));
      expect(converter.convert('abc'), equals("Nie 'n Nommer nie"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Oneindig"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negatief Oneindig"));
      expect(converterWithFallback.convert(double.nan),
          equals("Ongeldige Nommer"));
      expect(converterWithFallback.convert(null), equals("Ongeldige Nommer"));
      expect(converterWithFallback.convert('abc'), equals("Ongeldige Nommer"));
      expect(converterWithFallback.convert(123),
          equals("een honderd en drie-en-twintig"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("een miljoen"));
      expect(converter.convert(BigInt.from(1000000000)), equals("een miljard"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("een biljoen"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("een biljard"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("een triljoen"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("een triljard"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("een kwadriljoen"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "een honderd drie-en-twintig triljard vier honderd ses-en-vyftig triljoen sewe honderd nege-en-tagtig biljard een honderd drie-en-twintig biljoen vier honderd ses-en-vyftig miljard sewe honderd nege-en-tagtig miljoen een honderd drie-en-twintig duisend vier honderd en ses-en-vyftig",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "nege honderd nege-en-neëntig triljard nege honderd nege-en-neëntig triljoen nege honderd nege-en-neëntig biljard nege honderd nege-en-neëntig biljoen nege honderd nege-en-neëntig miljard nege honderd nege-en-neëntig miljoen nege honderd nege-en-neëntig duisend nege honderd en nege-en-neëntig",
        ),
      );
    });
  });
}
