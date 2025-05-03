import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Dutch (NL)', () {
    final converter = Num2Text(initialLang: Lang.NL);
    final converterWithFallback = Num2Text(
      initialLang: Lang.NL,
      fallbackOnError: "Ongeldig Nummer",
    );

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("nul"));
      expect(converter.convert(10), equals("tien"));
      expect(converter.convert(11), equals("elf"));
      expect(converter.convert(13), equals("dertien"));
      expect(converter.convert(15), equals("vijftien"));
      expect(converter.convert(20), equals("twintig"));
      expect(converter.convert(27), equals("zevenentwintig"));
      expect(converter.convert(30), equals("dertig"));
      expect(converter.convert(54), equals("vierenvijftig"));
      expect(converter.convert(68), equals("achtenzestig"));
      expect(converter.convert(99), equals("negenennegentig"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("honderd"));
      expect(converter.convert(101), equals("honderd één"));
      expect(converter.convert(105), equals("honderd vijf"));
      expect(converter.convert(110), equals("honderd tien"));
      expect(converter.convert(111), equals("honderd elf"));
      expect(converter.convert(123), equals("honderd drieëntwintig"));
      expect(converter.convert(200), equals("tweehonderd"));
      expect(converter.convert(321), equals("driehonderd eenentwintig"));
      expect(converter.convert(479), equals("vierhonderd negenenzeventig"));
      expect(converter.convert(596), equals("vijfhonderd zesennegentig"));
      expect(converter.convert(681), equals("zeshonderd eenentachtig"));
      expect(converter.convert(999), equals("negenhonderd negenennegentig"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("duizend"));
      expect(converter.convert(1001), equals("duizend één"));
      expect(converter.convert(1011), equals("duizend elf"));
      expect(converter.convert(1110), equals("duizend honderd tien"));
      expect(converter.convert(1111), equals("duizend honderd elf"));
      expect(converter.convert(2000), equals("tweeduizend"));
      expect(converter.convert(2468),
          equals("tweeduizend vierhonderd achtenzestig"));
      expect(converter.convert(3579),
          equals("drieduizend vijfhonderd negenenzeventig"));
      expect(converter.convert(10000), equals("tienduizend"));
      expect(converter.convert(10011), equals("tienduizend elf"));
      expect(converter.convert(11100), equals("elfduizend honderd"));
      expect(converter.convert(12987),
          equals("twaalfduizend negenhonderd zevenentachtig"));
      expect(converter.convert(45623),
          equals("vijfenveertigduizend zeshonderd drieëntwintig"));
      expect(converter.convert(87654),
          equals("zevenentachtigduizend zeshonderd vierenvijftig"));
      expect(converter.convert(100000), equals("honderdduizend"));
      expect(converter.convert(123456),
          equals("honderd drieëntwintigduizend vierhonderd zesenvijftig"));
      expect(
          converter.convert(987654),
          equals(
              "negenhonderd zevenentachtigduizend zeshonderd vierenvijftig"));
      expect(
          converter.convert(999999),
          equals(
              "negenhonderd negenennegentigduizend negenhonderd negenennegentig"));
    });

    test('Negative Numbers', () {
      const negOption = NlOptions(negativePrefix: "negatief ");
      expect(converter.convert(-1), equals("min één"));
      expect(converter.convert(-123), equals("min honderd drieëntwintig"));
      expect(converter.convert(-123.456),
          equals("min honderd drieëntwintig komma vier vijf zes"));
      expect(converter.convert(-1, options: negOption), equals("negatief één"));
      expect(converter.convert(-123, options: negOption),
          equals("negatief honderd drieëntwintig"));
      expect(converter.convert(-123.456, options: negOption),
          equals("negatief honderd drieëntwintig komma vier vijf zes"));
    });

    test('Decimals', () {
      const pointOption = NlOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = NlOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = NlOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(123.456),
          equals("honderd drieëntwintig komma vier vijf zes"));
      expect(converter.convert(1.5), equals("één komma vijf"));
      expect(converter.convert(1.05), equals("één komma nul vijf"));
      expect(converter.convert(879.465),
          equals("achthonderd negenenzeventig komma vier zes vijf"));
      expect(converter.convert(1.5, options: pointOption),
          equals("één punt vijf"));
      expect(converter.convert(1.5, options: commaOption),
          equals("één komma vijf"));
      expect(converter.convert(1.5, options: periodOption),
          equals("één punt vijf"));
    });

    test('Year Formatting', () {
      const yearOption = NlOptions(format: Format.year);
      const yearOptionAD = NlOptions(format: Format.year, includeAD: true);
      expect(converter.convert(123, options: yearOption),
          equals("honderd drieëntwintig"));
      expect(converter.convert(498, options: yearOption),
          equals("vierhonderd achtennegentig"));
      expect(converter.convert(756, options: yearOption),
          equals("zevenhonderd zesenvijftig"));
      expect(converter.convert(1900, options: yearOption),
          equals("negentienhonderd"));
      expect(converter.convert(1999, options: yearOption),
          equals("negentienhonderd negenennegentig"));
      expect(converter.convert(2025, options: yearOption),
          equals("tweeduizend vijfentwintig"));
      expect(converter.convert(1900, options: yearOptionAD),
          equals("negentienhonderd n.Chr."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("negentienhonderd negenennegentig n.Chr."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("tweeduizend vijfentwintig n.Chr."));
      expect(converter.convert(-1, options: yearOption), equals("één v.Chr."));
      expect(converter.convert(-100, options: yearOption),
          equals("honderd v.Chr."));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("honderd v.Chr."));
      expect(converter.convert(-2025, options: yearOption),
          equals("tweeduizend vijfentwintig v.Chr."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("één miljoen v.Chr."));
    });

    test('Currency', () {
      const currencyOption = NlOptions(currency: true);
      expect(converter.convert(0, options: currencyOption), equals("nul euro"));
      expect(converter.convert(1, options: currencyOption), equals("één euro"));
      expect(
          converter.convert(5, options: currencyOption), equals("vijf euro"));
      expect(
          converter.convert(10, options: currencyOption), equals("tien euro"));
      expect(
          converter.convert(11, options: currencyOption), equals("elf euro"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("één euro en vijftig cent"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("honderd drieëntwintig euro en vijfenveertig cent"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("tien miljoen euro"));
      expect(converter.convert(0.5), equals('nul komma vijf'));
      expect(converter.convert(0.5, options: currencyOption),
          equals("vijftig cent"));
      expect(
          converter.convert(0.01, options: currencyOption), equals("één cent"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("één euro en één cent"));
      expect(converter.convert(2.50, options: currencyOption),
          equals("twee euro en vijftig cent"));
      expect(
          converter.convert(2, options: currencyOption), equals("twee euro"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("één miljoen"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("twee miljard"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("drie biljoen"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("vier biljard"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("vijf triljoen"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("zes triljard"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("zeven quadriljoen"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            'negen triljoen achthonderd zesenzeventig biljard vijfhonderd drieënveertig biljoen tweehonderd tien miljard honderd drieëntwintig miljoen vierhonderd zesenvijftigduizend zevenhonderd negenentachtig'),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "honderd drieëntwintig triljard vierhonderd zesenvijftig triljoen zevenhonderd negenentachtig biljard honderd drieëntwintig biljoen vierhonderd zesenvijftig miljard zevenhonderd negenentachtig miljoen honderd drieëntwintigduizend vierhonderd zesenvijftig"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "negenhonderd negenennegentig triljard negenhonderd negenennegentig triljoen negenhonderd negenennegentig biljard negenhonderd negenennegentig biljoen negenhonderd negenennegentig miljard negenhonderd negenennegentig miljoen negenhonderd negenennegentigduizend negenhonderd negenennegentig"),
      );

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("één biljoen twee miljoen drie"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("vijf miljoen duizend"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("één miljard één"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("één miljard één miljoen"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("twee miljoen duizend"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              'één biljoen negenhonderd zevenentachtig miljoen zeshonderdduizend drie'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Geen Getal"));
      expect(converter.convert(double.infinity), equals("Oneindig"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negatieve Oneindigheid"));
      expect(converter.convert(null), equals("Geen Getal"));
      expect(converter.convert('abc'), equals("Geen Getal"));
      expect(converter.convert([]), equals("Geen Getal"));
      expect(converter.convert({}), equals("Geen Getal"));
      expect(converter.convert(Object()), equals("Geen Getal"));

      expect(
          converterWithFallback.convert(double.nan), equals("Ongeldig Nummer"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Oneindig"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negatieve Oneindigheid"));
      expect(converterWithFallback.convert(null), equals("Ongeldig Nummer"));
      expect(converterWithFallback.convert('abc'), equals("Ongeldig Nummer"));
      expect(converterWithFallback.convert([]), equals("Ongeldig Nummer"));
      expect(converterWithFallback.convert({}), equals("Ongeldig Nummer"));
      expect(
          converterWithFallback.convert(Object()), equals("Ongeldig Nummer"));
      expect(
          converterWithFallback.convert(123), equals("honderd drieëntwintig"));
    });
  });
}
