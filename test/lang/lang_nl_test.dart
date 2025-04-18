import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Dutch (NL)', () {
    final converter = Num2Text(initialLang: Lang.NL);
    final converterWithFallback = Num2Text(
      initialLang: Lang.NL,
      fallbackOnError: "Ongeldig nummer",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("nul"));
      expect(converter.convert(1), equals("één"));
      expect(converter.convert(10), equals("tien"));
      expect(converter.convert(11), equals("elf"));
      expect(converter.convert(12), equals("twaalf"));
      expect(converter.convert(13), equals("dertien"));
      expect(converter.convert(14), equals("veertien"));
      expect(converter.convert(15), equals("vijftien"));
      expect(converter.convert(16), equals("zestien"));
      expect(converter.convert(17), equals("zeventien"));
      expect(converter.convert(18), equals("achtien"));
      expect(converter.convert(19), equals("negentien"));
      expect(converter.convert(20), equals("twintig"));
      expect(converter.convert(21), equals("eenentwintig"));
      expect(converter.convert(30), equals("dertig"));
      expect(converter.convert(40), equals("veertig"));
      expect(converter.convert(50), equals("vijftig"));
      expect(converter.convert(60), equals("zestig"));
      expect(converter.convert(70), equals("zeventig"));
      expect(converter.convert(80), equals("tachtig"));
      expect(converter.convert(90), equals("negentig"));
      expect(converter.convert(99), equals("negenennegentig"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("honderd"));
      expect(converter.convert(101), equals("honderd één"));
      expect(converter.convert(111), equals("honderd elf"));
      expect(converter.convert(200), equals("tweehonderd"));
      expect(converter.convert(999), equals("negenhonderd negenennegentig"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("duizend"));
      expect(converter.convert(1001), equals("duizend één"));
      expect(converter.convert(1111), equals("duizend honderd elf"));
      expect(converter.convert(2000), equals("tweeduizend"));
      expect(converter.convert(10000), equals("tienduizend"));
      expect(converter.convert(100000), equals("honderdduizend"));
      expect(
        converter.convert(123456),
        equals("honderd drieëntwintigduizend vierhonderd zesenvijftig"),
      );
      expect(
        converter.convert(999999),
        equals(
            "negenhonderd negenennegentigduizend negenhonderd negenennegentig"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("min één"));
      expect(converter.convert(-123), equals("min honderd drieëntwintig"));
      expect(
        converter.convert(-1, options: NlOptions(negativePrefix: "negatief")),
        equals("negatief één"),
      );
      expect(
        converter.convert(-123, options: NlOptions(negativePrefix: "negatief")),
        equals("negatief honderd drieëntwintig"),
      );
    });

    test('Year Formatting', () {
      const yearOption = NlOptions(format: Format.year);
      const yearOptionAD = NlOptions(format: Format.year, includeAD: true);
      expect(converter.convert(1900, options: yearOption),
          equals("negentienhonderd"));
      expect(converter.convert(2024, options: yearOption),
          equals("tweeduizend vierentwintig"));
      expect(
        converter.convert(2024, options: yearOptionAD),
        equals("tweeduizend vierentwintig n.Chr."),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("honderd v.Chr."));
      expect(converter.convert(-1, options: yearOption), equals("één v.Chr."));
      expect(
        converter.convert(-2024, options: yearOption),
        equals("tweeduizend vierentwintig v.Chr."),
      );
    });

    test('Currency', () {
      const currencyOption = NlOptions(currency: true);
      expect(converter.convert(0, options: currencyOption), equals("nul euro"));
      expect(converter.convert(1, options: currencyOption), equals("één euro"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("één euro en één cent"));
      expect(converter.convert(2.50, options: currencyOption),
          equals("twee euro en vijftig cent"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("honderd drieëntwintig euro en vijfenveertig cent"),
      );
      expect(
          converter.convert(2, options: currencyOption), equals("twee euro"));
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("honderd drieëntwintig komma vier vijf zes"),
      );
      expect(
          converter.convert(Decimal.parse('1.50')), equals("één komma vijf"));
      expect(converter.convert(123.0), equals("honderd drieëntwintig"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("honderd drieëntwintig"));
      expect(
        converter.convert(1.5,
            options: const NlOptions(decimalSeparator: DecimalSeparator.point)),
        equals("één punt vijf"),
      );
      expect(
        converter.convert(1.5,
            options: const NlOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("één komma vijf"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Oneindig"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negatieve oneindigheid"));
      expect(converter.convert(double.nan), equals("Geen getal"));
      expect(converter.convert(null), equals("Geen getal"));
      expect(converter.convert('abc'), equals("Geen getal"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Oneindig"));
      expect(
        converterWithFallback.convert(double.negativeInfinity),
        equals("Negatieve oneindigheid"),
      );
      expect(
          converterWithFallback.convert(double.nan), equals("Ongeldig nummer"));
      expect(converterWithFallback.convert(null), equals("Ongeldig nummer"));
      expect(converterWithFallback.convert('abc'), equals("Ongeldig nummer"));
      expect(
          converterWithFallback.convert(123), equals("honderd drieëntwintig"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("één miljoen"));
      expect(converter.convert(BigInt.from(1000000000)), equals("één miljard"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("één biljoen"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("één biljard"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("één triljoen"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("één triljard"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("één quadriljoen"),
      );
      expect(converter.convert(BigInt.from(2000000)), equals("twee miljoen"));
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "honderd drieëntwintig triljard vierhonderd zesenvijftig triljoen zevenhonderd negenentachtig biljard honderd drieëntwintig biljoen vierhonderd zesenvijftig miljard zevenhonderd negenentachtig miljoen honderd drieëntwintigduizend vierhonderd zesenvijftig",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "negenhonderd negenennegentig triljard negenhonderd negenennegentig triljoen negenhonderd negenennegentig biljard negenhonderd negenennegentig biljoen negenhonderd negenennegentig miljard negenhonderd negenennegentig miljoen negenhonderd negenennegentigduizend negenhonderd negenennegentig",
        ),
      );
    });
  });
}
