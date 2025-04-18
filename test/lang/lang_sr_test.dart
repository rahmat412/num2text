import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Serbian (SR)', () {
    final converter = Num2Text(initialLang: Lang.SR);
    final converterWithFallback =
        Num2Text(initialLang: Lang.SR, fallbackOnError: "Nevažeći broj");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("nula"));
      expect(converter.convert(1), equals("jedan"));
      expect(converter.convert(2), equals("dva"));
      expect(converter.convert(3), equals("tri"));
      expect(converter.convert(4), equals("četiri"));
      expect(converter.convert(5), equals("pet"));
      expect(converter.convert(6), equals("šest"));
      expect(converter.convert(7), equals("sedam"));
      expect(converter.convert(8), equals("osam"));
      expect(converter.convert(9), equals("devet"));
      expect(converter.convert(10), equals("deset"));
      expect(converter.convert(11), equals("jedanaest"));
      expect(converter.convert(12), equals("dvanaest"));
      expect(converter.convert(13), equals("trinaest"));
      expect(converter.convert(14), equals("četrnaest"));
      expect(converter.convert(15), equals("petnaest"));
      expect(converter.convert(16), equals("šesnaest"));
      expect(converter.convert(17), equals("sedamnaest"));
      expect(converter.convert(18), equals("osamnaest"));
      expect(converter.convert(19), equals("devetnaest"));
      expect(converter.convert(20), equals("dvadeset"));
      expect(converter.convert(21), equals("dvadeset jedan"));
      expect(converter.convert(99), equals("devedeset devet"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("sto"));
      expect(converter.convert(101), equals("sto jedan"));
      expect(converter.convert(111), equals("sto jedanaest"));
      expect(converter.convert(200), equals("dvesta"));
      expect(converter.convert(300), equals("trista"));
      expect(converter.convert(400), equals("četiristo"));
      expect(converter.convert(500), equals("petsto"));
      expect(converter.convert(600), equals("šeststo"));
      expect(converter.convert(700), equals("sedamsto"));
      expect(converter.convert(800), equals("osamsto"));
      expect(converter.convert(900), equals("devetsto"));
      expect(converter.convert(999), equals("devetsto devedeset devet"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("hiljadu"));
      expect(converter.convert(1001), equals("hiljadu jedan"));
      expect(converter.convert(1111), equals("hiljadu sto jedanaest"));
      expect(converter.convert(2000), equals("dve hiljade"));
      expect(converter.convert(5000), equals("pet hiljada"));
      expect(converter.convert(10000), equals("deset hiljada"));
      expect(converter.convert(100000), equals("sto hiljada"));
      expect(converter.convert(123456),
          equals("sto dvadeset tri hiljade četiristo pedeset šest"));
      expect(
        converter.convert(999999),
        equals("devetsto devedeset devet hiljada devetsto devedeset devet"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus jedan"));
      expect(converter.convert(-123), equals("minus sto dvadeset tri"));
      expect(
        converter.convert(-1, options: SrOptions(negativePrefix: "negativan")),
        equals("negativan jedan"),
      );
      expect(
        converter.convert(-123,
            options: SrOptions(negativePrefix: "negativan")),
        equals("negativan sto dvadeset tri"),
      );
    });

    test('Year Formatting', () {
      const yearOption = SrOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("hiljadu devetsto"));
      expect(converter.convert(2024, options: yearOption),
          equals("dve hiljade dvadeset četiri"));
      expect(
        converter.convert(1900,
            options: SrOptions(format: Format.year, includeAD: true)),
        equals("hiljadu devetsto n. e."),
      );
      expect(
        converter.convert(2024,
            options: SrOptions(format: Format.year, includeAD: true)),
        equals("dve hiljade dvadeset četiri n. e."),
      );
      expect(
          converter.convert(-100, options: yearOption), equals("sto p. n. e."));
      expect(
          converter.convert(-1, options: yearOption), equals("jedan p. n. e."));
      expect(
        converter.convert(-2024, options: SrOptions(format: Format.year)),
        equals("dve hiljade dvadeset četiri p. n. e."),
      );
    });

    test('Currency', () {
      const currencyOption = SrOptions(currency: true);
      expect(
          converter.convert(1, options: currencyOption), equals("jedan dinar"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("jedan dinar i jedna para"));
      expect(
          converter.convert(2, options: currencyOption), equals("dva dinara"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("dva dinara i dve pare"));
      expect(
          converter.convert(5, options: currencyOption), equals("pet dinara"));
      expect(converter.convert(2.50, options: currencyOption),
          equals("dva dinara i pedeset para"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("sto dvadeset tri dinara i četrdeset pet para"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("sto dvadeset tri zapeta četiri pet šest"),
      );
      expect(
          converter.convert(Decimal.parse('1.50')), equals("jedan zapeta pet"));
      expect(converter.convert(Decimal.parse('1.05')),
          equals("jedan zapeta nula pet"));
      expect(converter.convert(123.0), equals("sto dvadeset tri"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("sto dvadeset tri"));
      expect(
        converter.convert(1.5,
            options: const SrOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("jedan zapeta pet"),
      );
      expect(
        converter.convert(1.5,
            options:
                const SrOptions(decimalSeparator: DecimalSeparator.period)),
        equals("jedan tačka pet"),
      );
      expect(
        converter.convert(1.5,
            options: const SrOptions(decimalSeparator: DecimalSeparator.point)),
        equals("jedan tačka pet"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Beskonačnost"));
      expect(converter.convert(double.negativeInfinity),
          equals("Minus beskonačnost"));
      expect(converter.convert(double.nan), equals("Nije broj"));
      expect(converter.convert(null), equals("Nije broj"));
      expect(converter.convert('abc'), equals("Nije broj"));

      expect(converterWithFallback.convert(double.infinity),
          equals("Beskonačnost"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Minus beskonačnost"));
      expect(
          converterWithFallback.convert(double.nan), equals("Nevažeći broj"));
      expect(converterWithFallback.convert(null), equals("Nevažeći broj"));
      expect(converterWithFallback.convert('abc'), equals("Nevažeći broj"));
      expect(converterWithFallback.convert(123), equals("sto dvadeset tri"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("jedan milion"));
      expect(converter.convert(BigInt.from(1000000000)),
          equals("jedna milijarda"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("jedan bilion"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("jedna bilijarda"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("jedan trilion"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("jedna trilijarda"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("jedan kvadrilion"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          'sto dvadeset tri trilijarde četiristo pedeset šest triliona sedamsto osamdeset devet bilijardi sto dvadeset tri biliona četiristo pedeset šest milijardi sedamsto osamdeset devet miliona sto dvadeset tri hiljade četiristo pedeset šest',
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          'devetsto devedeset devet trilijardi devetsto devedeset devet triliona devetsto devedeset devet bilijardi devetsto devedeset devet biliona devetsto devedeset devet milijardi devetsto devedeset devet miliona devetsto devedeset devet hiljada devetsto devedeset devet',
        ),
      );
    });
  });
}
