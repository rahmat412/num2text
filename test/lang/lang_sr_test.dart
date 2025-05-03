import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Serbian (SR)', () {
    final converter = Num2Text(initialLang: Lang.SR);
    final converterWithFallback =
        Num2Text(initialLang: Lang.SR, fallbackOnError: "Nevažeći broj");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("nula"));
      expect(converter.convert(1), equals("jedan"));
      expect(converter.convert(2), equals("dva"));
      expect(converter.convert(3), equals("tri"));
      expect(converter.convert(4), equals("četiri"));
      expect(converter.convert(5), equals("pet"));
      expect(converter.convert(9), equals("devet"));
      expect(converter.convert(10), equals("deset"));
      expect(converter.convert(11), equals("jedanaest"));
      expect(converter.convert(12), equals("dvanaest"));
      expect(converter.convert(13), equals("trinaest"));
      expect(converter.convert(14), equals("četrnaest"));
      expect(converter.convert(15), equals("petnaest"));
      expect(converter.convert(19), equals("devetnaest"));
      expect(converter.convert(20), equals("dvadeset"));
      expect(converter.convert(21), equals("dvadeset jedan"));
      expect(converter.convert(22), equals("dvadeset dva"));
      expect(converter.convert(23), equals("dvadeset tri"));
      expect(converter.convert(24), equals("dvadeset četiri"));
      expect(converter.convert(25), equals("dvadeset pet"));
      expect(converter.convert(27), equals("dvadeset sedam"));
      expect(converter.convert(30), equals("trideset"));
      expect(converter.convert(54), equals("pedeset četiri"));
      expect(converter.convert(68), equals("šezdeset osam"));
      expect(converter.convert(99), equals("devedeset devet"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("sto"));
      expect(converter.convert(101), equals("sto jedan"));
      expect(converter.convert(105), equals("sto pet"));
      expect(converter.convert(110), equals("sto deset"));
      expect(converter.convert(111), equals("sto jedanaest"));
      expect(converter.convert(123), equals("sto dvadeset tri"));
      expect(converter.convert(200), equals("dvesta"));
      expect(converter.convert(321), equals("trista dvadeset jedan"));
      expect(converter.convert(479), equals("četiristo sedamdeset devet"));
      expect(converter.convert(596), equals("petsto devedeset šest"));
      expect(converter.convert(681), equals("šeststo osamdeset jedan"));
      expect(converter.convert(999), equals("devetsto devedeset devet"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("hiljadu"));
      expect(converter.convert(1001), equals("hiljadu jedan"));
      expect(converter.convert(1011), equals("hiljadu jedanaest"));
      expect(converter.convert(1110), equals("hiljadu sto deset"));
      expect(converter.convert(1111), equals("hiljadu sto jedanaest"));
      expect(converter.convert(2000), equals("dve hiljade"));
      expect(converter.convert(2468),
          equals("dve hiljade četiristo šezdeset osam"));
      expect(converter.convert(3579),
          equals("tri hiljade petsto sedamdeset devet"));
      expect(converter.convert(10000), equals("deset hiljada"));
      expect(converter.convert(10011), equals("deset hiljada jedanaest"));
      expect(converter.convert(11100), equals("jedanaest hiljada sto"));
      expect(converter.convert(12987),
          equals("dvanaest hiljada devetsto osamdeset sedam"));
      expect(converter.convert(45623),
          equals("četrdeset pet hiljada šeststo dvadeset tri"));
      expect(converter.convert(87654),
          equals("osamdeset sedam hiljada šeststo pedeset četiri"));
      expect(converter.convert(100000), equals("sto hiljada"));
      expect(converter.convert(123456),
          equals("sto dvadeset tri hiljade četiristo pedeset šest"));
      expect(converter.convert(987654),
          equals("devetsto osamdeset sedam hiljada šeststo pedeset četiri"));
      expect(converter.convert(999999),
          equals("devetsto devedeset devet hiljada devetsto devedeset devet"));
    });

    test('Negative Numbers', () {
      const negativeOption = SrOptions(negativePrefix: "negativan");

      expect(converter.convert(-1), equals("minus jedan"));
      expect(converter.convert(-123), equals("minus sto dvadeset tri"));
      expect(converter.convert(-123.456),
          equals("minus sto dvadeset tri zapeta četiri pet šest"));
      expect(converter.convert(-1, options: negativeOption),
          equals("negativan jedan"));
      expect(converter.convert(-123, options: negativeOption),
          equals("negativan sto dvadeset tri"));
      expect(converter.convert(-123.456, options: negativeOption),
          equals("negativan sto dvadeset tri zapeta četiri pet šest"));
    });

    test('Decimals', () {
      const pointOption = SrOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = SrOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = SrOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(123.456),
          equals("sto dvadeset tri zapeta četiri pet šest"));
      expect(converter.convert(1.50), equals("jedan zapeta pet"));
      expect(converter.convert(1.05), equals("jedan zapeta nula pet"));
      expect(converter.convert(879.465),
          equals("osamsto sedamdeset devet zapeta četiri šest pet"));
      expect(converter.convert(1.5), equals("jedan zapeta pet"));
      expect(converter.convert(1.5, options: pointOption),
          equals("jedan tačka pet"));
      expect(converter.convert(1.5, options: commaOption),
          equals("jedan zapeta pet"));
      expect(converter.convert(1.5, options: periodOption),
          equals("jedan tačka pet"));
    });

    test('Year Formatting', () {
      const yearOption = SrOptions(format: Format.year);
      const yearOptionAD = SrOptions(format: Format.year, includeAD: true);

      expect(converter.convert(123, options: yearOption),
          equals("sto dvadeset tri"));
      expect(converter.convert(498, options: yearOption),
          equals("četiristo devedeset osam"));
      expect(converter.convert(756, options: yearOption),
          equals("sedamsto pedeset šest"));
      expect(converter.convert(1900, options: yearOption),
          equals("hiljadu devetsto"));
      expect(converter.convert(1999, options: yearOption),
          equals("hiljadu devetsto devedeset devet"));
      expect(converter.convert(2025, options: yearOption),
          equals("dve hiljade dvadeset pet"));
      expect(converter.convert(1900, options: yearOptionAD),
          equals("hiljadu devetsto n. e."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("hiljadu devetsto devedeset devet n. e."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("dve hiljade dvadeset pet n. e."));
      expect(
          converter.convert(-1, options: yearOption), equals("jedan p. n. e."));
      expect(
          converter.convert(-100, options: yearOption), equals("sto p. n. e."));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("sto p. n. e."));
      expect(converter.convert(-2025, options: yearOption),
          equals("dve hiljade dvadeset pet p. n. e."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("jedan milion p. n. e."));
    });

    test('Currency', () {
      const currencyOption = SrOptions(currency: true);

      expect(
          converter.convert(0, options: currencyOption), equals("nula dinara"));
      expect(
          converter.convert(1, options: currencyOption), equals("jedan dinar"));
      expect(
          converter.convert(2, options: currencyOption), equals("dva dinara"));
      expect(
          converter.convert(3, options: currencyOption), equals("tri dinara"));
      expect(converter.convert(4, options: currencyOption),
          equals("četiri dinara"));
      expect(
          converter.convert(5, options: currencyOption), equals("pet dinara"));
      expect(converter.convert(10, options: currencyOption),
          equals("deset dinara"));
      expect(converter.convert(11, options: currencyOption),
          equals("jedanaest dinara"));
      expect(converter.convert(21, options: currencyOption),
          equals("dvadeset jedan dinar"));
      expect(converter.convert(22, options: currencyOption),
          equals("dvadeset dva dinara"));
      expect(converter.convert(25, options: currencyOption),
          equals("dvadeset pet dinara"));
      expect(converter.convert(101, options: currencyOption),
          equals("sto jedan dinar"));
      expect(converter.convert(102, options: currencyOption),
          equals("sto dva dinara"));
      expect(converter.convert(105, options: currencyOption),
          equals("sto pet dinara"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("jedan dinar i pedeset para"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("sto dvadeset tri dinara i četrdeset pet para"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("deset miliona dinara"));
      expect(converter.convert(0.50, options: currencyOption),
          equals("pedeset para"));
      expect(converter.convert(0.01), equals("nula zapeta nula jedan"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("jedna para"));
      expect(
          converter.convert(0.02, options: currencyOption), equals("dve pare"));
      expect(
          converter.convert(0.03, options: currencyOption), equals("tri pare"));
      expect(converter.convert(0.04, options: currencyOption),
          equals("četiri pare"));
      expect(
          converter.convert(0.05, options: currencyOption), equals("pet para"));
      expect(converter.convert(0.11, options: currencyOption),
          equals("jedanaest para"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("jedan dinar i jedna para"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("dva dinara i dve pare"));
      expect(converter.convert(5.05, options: currencyOption),
          equals("pet dinara i pet para"));
      expect(converter.convert(21.01, options: currencyOption),
          equals("dvadeset jedan dinar i jedna para"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("jedan milion"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("dve milijarde"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("tri biliona"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("četiri bilijarde"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("pet triliona"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("šest trilijardi"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("sedam kvadriliona"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "devet triliona osamsto sedamdeset šest bilijardi petsto četrdeset tri biliona dvesta deset milijardi sto dvadeset tri miliona četiristo pedeset šest hiljada sedamsto osamdeset devet"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "sto dvadeset tri trilijarde četiristo pedeset šest triliona sedamsto osamdeset devet bilijardi sto dvadeset tri biliona četiristo pedeset šest milijardi sedamsto osamdeset devet miliona sto dvadeset tri hiljade četiristo pedeset šest"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "devetsto devedeset devet trilijardi devetsto devedeset devet triliona devetsto devedeset devet bilijardi devetsto devedeset devet biliona devetsto devedeset devet milijardi devetsto devedeset devet miliona devetsto devedeset devet hiljada devetsto devedeset devet"));

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('jedan bilion dva miliona tri'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("pet miliona hiljadu"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("jedna milijarda jedan"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("jedna milijarda jedan milion"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("dva miliona hiljadu"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              'jedan bilion devetsto osamdeset sedam miliona šeststo hiljada tri'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Nije broj"));
      expect(converter.convert(double.infinity), equals("Beskonačnost"));
      expect(converter.convert(double.negativeInfinity),
          equals("Minus beskonačnost"));
      expect(converter.convert(null), equals("Nije broj"));
      expect(converter.convert('abc'), equals("Nije broj"));
      expect(converter.convert([]), equals("Nije broj"));
      expect(converter.convert({}), equals("Nije broj"));
      expect(converter.convert(Object()), equals("Nije broj"));

      expect(
          converterWithFallback.convert(double.nan), equals("Nevažeći broj"));
      expect(converterWithFallback.convert(double.infinity),
          equals("Beskonačnost"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Minus beskonačnost"));
      expect(converterWithFallback.convert(null), equals("Nevažeći broj"));
      expect(converterWithFallback.convert('abc'), equals("Nevažeći broj"));
      expect(converterWithFallback.convert([]), equals("Nevažeći broj"));
      expect(converterWithFallback.convert({}), equals("Nevažeći broj"));
      expect(converterWithFallback.convert(Object()), equals("Nevažeći broj"));
      expect(converterWithFallback.convert(123), equals("sto dvadeset tri"));
    });
  });
}
