import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Afrikaans (AF)', () {
    final converter = Num2Text(initialLang: Lang.AF);
    final converterWithFallback = Num2Text(
      initialLang: Lang.AF,
      fallbackOnError: "Ongeldige Nommer",
    );

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("nul"));
      expect(converter.convert(10), equals("tien"));
      expect(converter.convert(11), equals("elf"));
      expect(converter.convert(13), equals("dertien"));
      expect(converter.convert(15), equals("vyftien"));
      expect(converter.convert(20), equals("twintig"));
      expect(converter.convert(27), equals("sewe-en-twintig"));
      expect(converter.convert(30), equals("dertig"));
      expect(converter.convert(54), equals("vier-en-vyftig"));
      expect(converter.convert(68), equals("agt-en-sestig"));
      expect(converter.convert(99), equals("nege-en-neëntig"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("honderd"));
      expect(converter.convert(101), equals("honderd en een"));
      expect(converter.convert(105), equals("honderd en vyf"));
      expect(converter.convert(110), equals("honderd en tien"));
      expect(converter.convert(111), equals("honderd en elf"));
      expect(converter.convert(123), equals("honderd en drie-en-twintig"));
      expect(converter.convert(200), equals("twee honderd"));
      expect(converter.convert(321), equals("drie honderd en een-en-twintig"));
      expect(
          converter.convert(479), equals("vier honderd en nege-en-sewentig"));
      expect(converter.convert(596), equals("vyf honderd en ses-en-neëntig"));
      expect(converter.convert(681), equals("ses honderd en een-en-tagtig"));
      expect(converter.convert(999), equals("nege honderd en nege-en-neëntig"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("een duisend"));
      expect(converter.convert(1001), equals("een duisend en een"));
      expect(converter.convert(1011), equals("een duisend en elf"));
      expect(converter.convert(1110), equals("een duisend honderd en tien"));
      expect(converter.convert(1111), equals("een duisend honderd en elf"));
      expect(converter.convert(2000), equals("twee duisend"));
      expect(converter.convert(2468),
          equals("twee duisend vier honderd en agt-en-sestig"));
      expect(converter.convert(3579),
          equals("drie duisend vyf honderd en nege-en-sewentig"));
      expect(converter.convert(10000), equals("tien duisend"));
      expect(converter.convert(10011), equals("tien duisend en elf"));
      expect(converter.convert(11100), equals("elf duisend honderd"));
      expect(converter.convert(12987),
          equals("twaalf duisend nege honderd en sewe-en-tagtig"));
      expect(converter.convert(45623),
          equals("vyf-en-veertig duisend ses honderd en drie-en-twintig"));
      expect(converter.convert(87654),
          equals("sewe-en-tagtig duisend ses honderd en vier-en-vyftig"));
      expect(converter.convert(100000), equals("honderd duisend"));
      expect(
          converter.convert(123456),
          equals(
              "honderd en drie-en-twintig duisend vier honderd en ses-en-vyftig"));
      expect(
          converter.convert(987654),
          equals(
              "nege honderd en sewe-en-tagtig duisend ses honderd en vier-en-vyftig"));
      expect(
          converter.convert(999999),
          equals(
              "nege honderd en nege-en-neëntig duisend nege honderd en nege-en-neëntig"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus een"));
      expect(
          converter.convert(-123), equals("minus honderd en drie-en-twintig"));
      expect(converter.convert(-123.456),
          equals("minus honderd en drie-en-twintig komma vier vyf ses"));

      const negativeOption = AfOptions(negativePrefix: "negatief");

      expect(converter.convert(-1, options: negativeOption),
          equals("negatief een"));
      expect(converter.convert(-123, options: negativeOption),
          equals("negatief honderd en drie-en-twintig"));
      expect(converter.convert(-123.456, options: negativeOption),
          equals("negatief honderd en drie-en-twintig komma vier vyf ses"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456),
          equals("honderd en drie-en-twintig komma vier vyf ses"));
      expect(converter.convert(1.5), equals("een komma vyf"));
      expect(converter.convert(1.05), equals("een komma nul vyf"));
      expect(converter.convert(879.465),
          equals("agt honderd en nege-en-sewentig komma vier ses vyf"));
      expect(converter.convert(1.5), equals("een komma vyf"));

      const pointOption = AfOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = AfOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = AfOptions(decimalSeparator: DecimalSeparator.period);

      expect(
          converter.convert(1.5, options: pointOption), equals("een punt vyf"));
      expect(converter.convert(1.5, options: commaOption),
          equals("een komma vyf"));
      expect(converter.convert(1.5, options: periodOption),
          equals("een punt vyf"));
    });

    test('Year Formatting', () {
      const yearOption = AfOptions(format: Format.year);

      expect(converter.convert(123, options: yearOption),
          equals("honderd drie-en-twintig"));
      expect(converter.convert(498, options: yearOption),
          equals("vier honderd agt-en-neëntig"));
      expect(converter.convert(756, options: yearOption),
          equals("sewe honderd ses-en-vyftig"));
      expect(converter.convert(1066, options: yearOption),
          equals("tien ses-en-sestig"));
      expect(
          converter.convert(1100, options: yearOption), equals("elf honderd"));
      expect(converter.convert(1900, options: yearOption),
          equals("negentien honderd"));
      expect(converter.convert(1999, options: yearOption),
          equals("negentien nege-en-neëntig"));
      expect(
          converter.convert(2000, options: yearOption), equals("twee duisend"));
      expect(converter.convert(2001, options: yearOption),
          equals("twee duisend en een"));
      expect(converter.convert(2025, options: yearOption),
          equals("twintig vyf-en-twintig"));

      const yearOptionAD = AfOptions(format: Format.year, includeAD: true);

      expect(converter.convert(498, options: yearOptionAD),
          equals("vier honderd agt-en-neëntig n.C."));
      expect(converter.convert(1900, options: yearOptionAD),
          equals("negentien honderd n.C."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("negentien nege-en-neëntig n.C."));
      expect(converter.convert(2000, options: yearOptionAD),
          equals("twee duisend n.C."));
      expect(converter.convert(2001, options: yearOptionAD),
          equals("twee duisend en een n.C."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("twintig vyf-en-twintig n.C."));
      expect(converter.convert(-1, options: yearOption), equals("een v.C."));
      expect(
          converter.convert(-100, options: yearOption), equals("honderd v.C."));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("honderd v.C."));
      expect(converter.convert(-1066, options: yearOption),
          equals("tien ses-en-sestig v.C."));
      expect(converter.convert(-1999, options: yearOption),
          equals("negentien nege-en-neëntig v.C."));
      expect(converter.convert(-2025, options: yearOption),
          equals("twintig vyf-en-twintig v.C."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("een miljoen v.C."));
    });
    test('Currency', () {
      const currencyOption = AfOptions(currency: true);

      expect(converter.convert(0, options: currencyOption), equals("nul Rand"));
      expect(converter.convert(1, options: currencyOption), equals("een Rand"));
      expect(
          converter.convert(2, options: currencyOption), equals("twee Rand"));
      expect(converter.convert(5, options: currencyOption), equals("vyf Rand"));
      expect(
          converter.convert(10, options: currencyOption), equals("tien Rand"));
      expect(
          converter.convert(11, options: currencyOption), equals("elf Rand"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("een Rand en vyftig sent"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("honderd en drie-en-twintig Rand en vyf-en-veertig sent"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("tien miljoen Rand"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("vyftig sent"));
      expect(
          converter.convert(0.01, options: currencyOption), equals("een sent"));
      expect(converter.convert(0.02, options: currencyOption),
          equals("twee sent"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("een Rand en een sent"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("een miljoen"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("twee miljard"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("drie biljoen"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("vier biljard"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("vyf triljoen"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("ses triljard"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("sewe kwadriljoen"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "nege triljoen agt honderd en ses-en-sewentig biljard vyf honderd en drie-en-veertig biljoen twee honderd en tien miljard honderd en drie-en-twintig miljoen vier honderd en ses-en-vyftig duisend sewe honderd en nege-en-tagtig"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "honderd en drie-en-twintig triljard vier honderd en ses-en-vyftig triljoen sewe honderd en nege-en-tagtig biljard honderd en drie-en-twintig biljoen vier honderd en ses-en-vyftig miljard sewe honderd en nege-en-tagtig miljoen honderd en drie-en-twintig duisend vier honderd en ses-en-vyftig"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "nege honderd en nege-en-neëntig triljard nege honderd en nege-en-neëntig triljoen nege honderd en nege-en-neëntig biljard nege honderd en nege-en-neëntig biljoen nege honderd en nege-en-neëntig miljard nege honderd en nege-en-neëntig miljoen nege honderd en nege-en-neëntig duisend nege honderd en nege-en-neëntig"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("een biljoen twee miljoen en drie"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("vyf miljoen een duisend"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("een miljard en een"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("een miljard een miljoen"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("twee miljoen een duisend"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "een biljoen nege honderd en sewe-en-tagtig miljoen ses honderd duisend en drie"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Nie 'n Nommer Nie"));
      expect(converter.convert(double.infinity), equals("Oneindig"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negatief Oneindig"));
      expect(converter.convert(null), equals("Nie 'n Nommer Nie"));
      expect(converter.convert('abc'), equals("Nie 'n Nommer Nie"));
      expect(converter.convert([]), equals("Nie 'n Nommer Nie"));
      expect(converter.convert({}), equals("Nie 'n Nommer Nie"));
      expect(converter.convert(Object()), equals("Nie 'n Nommer Nie"));
      expect(converterWithFallback.convert(double.nan),
          equals("Ongeldige Nommer"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Oneindig"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negatief Oneindig"));
      expect(converterWithFallback.convert(null), equals("Ongeldige Nommer"));
      expect(converterWithFallback.convert('abc'), equals("Ongeldige Nommer"));
      expect(converterWithFallback.convert([]), equals("Ongeldige Nommer"));
      expect(converterWithFallback.convert({}), equals("Ongeldige Nommer"));
      expect(
          converterWithFallback.convert(Object()), equals("Ongeldige Nommer"));
      expect(converterWithFallback.convert(123),
          equals("honderd en drie-en-twintig"));
    });
  });
}
