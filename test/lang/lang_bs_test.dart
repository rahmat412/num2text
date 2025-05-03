import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Bosnian (BS)', () {
    final converter = Num2Text(initialLang: Lang.BS);

    final converterWithFallback =
        Num2Text(initialLang: Lang.BS, fallbackOnError: "Nevažeći Broj");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("nula"));
      expect(converter.convert(10), equals("deset"));
      expect(converter.convert(11), equals("jedanaest"));
      expect(converter.convert(13), equals("trinaest"));
      expect(converter.convert(15), equals("petnaest"));
      expect(converter.convert(20), equals("dvadeset"));
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
      expect(converter.convert(200), equals("dvjesto"));
      expect(converter.convert(321), equals("tristo dvadeset jedan"));
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
      expect(converter.convert(2000), equals("dvije hiljade"));
      expect(converter.convert(2468),
          equals("dvije hiljade četiristo šezdeset osam"));
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
      expect(converter.convert(-1), equals("minus jedan"));
      expect(converter.convert(-123), equals("minus sto dvadeset tri"));
      expect(converter.convert(-123.456),
          equals("minus sto dvadeset tri zarez četiri pet šest"));

      const negativeOptions = BsOptions(negativePrefix: "negativno");

      expect(converter.convert(-1, options: negativeOptions),
          equals("negativno jedan"));
      expect(converter.convert(-123, options: negativeOptions),
          equals("negativno sto dvadeset tri"));
      expect(converter.convert(-123.456, options: negativeOptions),
          equals("negativno sto dvadeset tri zarez četiri pet šest"));
    });

    test('Decimals', () {
      const pointOption = BsOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = BsOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = BsOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(123.456),
          equals("sto dvadeset tri zarez četiri pet šest"));
      expect(converter.convert(1.5), equals("jedan zarez pet"));
      expect(converter.convert(1.05), equals("jedan zarez nula pet"));
      expect(converter.convert(879.465),
          equals("osamsto sedamdeset devet zarez četiri šest pet"));
      expect(converter.convert(1.5), equals("jedan zarez pet"));

      expect(converter.convert(1.5, options: pointOption),
          equals("jedan tačka pet"));
      expect(converter.convert(1.5, options: commaOption),
          equals("jedan zarez pet"));
      expect(converter.convert(1.5, options: periodOption),
          equals("jedan tačka pet"));
    });

    test('Year Formatting', () {
      const yearOption = BsOptions(format: Format.year);
      const yearOptionAD = BsOptions(format: Format.year, includeAD: true);

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
          equals("dvije hiljade dvadeset pet"));

      expect(converter.convert(1900, options: yearOptionAD),
          equals("hiljadu devetsto n. e."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("hiljadu devetsto devedeset devet n. e."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("dvije hiljade dvadeset pet n. e."));

      expect(
          converter.convert(-1, options: yearOption), equals("jedan p. n. e."));
      expect(
          converter.convert(-100, options: yearOption), equals("sto p. n. e."));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("sto p. n. e."));
      expect(converter.convert(-2025, options: yearOption),
          equals("dvije hiljade dvadeset pet p. n. e."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("milion p. n. e."));
    });

    test('Currency', () {
      const currencyOption = BsOptions(currency: true);

      expect(converter.convert(0, options: currencyOption),
          equals("nula konvertibilnih maraka"));
      expect(converter.convert(1, options: currencyOption),
          equals("jedna konvertibilna marka"));
      expect(converter.convert(2, options: currencyOption),
          equals("dvije konvertibilne marke"));
      expect(converter.convert(3, options: currencyOption),
          equals("tri konvertibilne marke"));
      expect(converter.convert(4, options: currencyOption),
          equals("četiri konvertibilne marke"));
      expect(converter.convert(5, options: currencyOption),
          equals("pet konvertibilnih maraka"));
      expect(converter.convert(10, options: currencyOption),
          equals("deset konvertibilnih maraka"));
      expect(converter.convert(11, options: currencyOption),
          equals("jedanaest konvertibilnih maraka"));
      expect(converter.convert(21, options: currencyOption),
          equals("dvadeset jedna konvertibilna marka"));
      expect(converter.convert(22, options: currencyOption),
          equals("dvadeset dvije konvertibilne marke"));
      expect(converter.convert(25, options: currencyOption),
          equals("dvadeset pet konvertibilnih maraka"));
      expect(converter.convert(100, options: currencyOption),
          equals("sto konvertibilnih maraka"));
      expect(converter.convert(101, options: currencyOption),
          equals("sto jedna konvertibilna marka"));
      expect(converter.convert(102, options: currencyOption),
          equals("sto dvije konvertibilne marke"));
      expect(converter.convert(105, options: currencyOption),
          equals("sto pet konvertibilnih maraka"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("jedna konvertibilna marka i pedeset feninga"));
      expect(
          converter.convert(123.45, options: currencyOption),
          equals(
              "sto dvadeset tri konvertibilne marke i četrdeset pet feninga"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("deset miliona konvertibilnih maraka"));
      expect(converter.convert(0.5), equals("nula zarez pet"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("pedeset feninga"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("jedan fening"));
      expect(converter.convert(0.02, options: currencyOption),
          equals("dva feninga"));
      expect(converter.convert(0.03, options: currencyOption),
          equals("tri feninga"));
      expect(converter.convert(0.04, options: currencyOption),
          equals("četiri feninga"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("pet feninga"));
      expect(converter.convert(0.11, options: currencyOption),
          equals("jedanaest feninga"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("jedna konvertibilna marka i jedan fening"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("dvije konvertibilne marke i dva feninga"));
      expect(converter.convert(5.05, options: currencyOption),
          equals("pet konvertibilnih maraka i pet feninga"));
      expect(converter.convert(11.11, options: currencyOption),
          equals("jedanaest konvertibilnih maraka i jedanaest feninga"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("milion"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("dvije milijarde"));
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
              "devet triliona osamsto sedamdeset šest bilijardi petsto četrdeset tri biliona dvjesto deset milijardi sto dvadeset tri miliona četiristo pedeset šest hiljada sedamsto osamdeset devet"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "sto dvadeset tri trilijarde četiristo pedeset šest triliona sedamsto osamdeset devet bilijardi sto dvadeset tri biliona četiristo pedeset šest milijardi sedamsto osamdeset devet miliona sto dvadeset tri hiljade četiristo pedeset šest"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "devetsto devedeset devet trilijardi devetsto devedeset devet triliona devetsto devedeset devet bilijardi devetsto devedeset devet biliona devetsto devedeset devet milijardi devetsto devedeset devet miliona devetsto devedeset devet hiljada devetsto devedeset devet"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("bilion dva miliona tri"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("pet miliona hiljadu"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("milijarda jedan"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("milijarda milion"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("dva miliona hiljadu"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "bilion devetsto osamdeset sedam miliona šeststo hiljada tri"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Nije Broj"));
      expect(converter.convert(double.infinity), equals("Beskonačnost"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negativna Beskonačnost"));
      expect(converter.convert(null), equals("Nije Broj"));
      expect(converter.convert('abc'), equals("Nije Broj"));
      expect(converter.convert([]), equals("Nije Broj"));
      expect(converter.convert({}), equals("Nije Broj"));
      expect(converter.convert(Object()), equals("Nije Broj"));

      expect(
          converterWithFallback.convert(double.nan), equals("Nevažeći Broj"));
      expect(converterWithFallback.convert(double.infinity),
          equals("Beskonačnost"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negativna Beskonačnost"));
      expect(converterWithFallback.convert(null), equals("Nevažeći Broj"));
      expect(converterWithFallback.convert('abc'), equals("Nevažeći Broj"));
      expect(converterWithFallback.convert([]), equals("Nevažeći Broj"));
      expect(converterWithFallback.convert({}), equals("Nevažeći Broj"));
      expect(converterWithFallback.convert(Object()), equals("Nevažeći Broj"));
      expect(converterWithFallback.convert(123), equals("sto dvadeset tri"));
    });
  });
}
