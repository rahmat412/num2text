import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Croatian (HR)', () {
    final converter = Num2Text(initialLang: Lang.HR);
    final converterWithFallback =
        Num2Text(initialLang: Lang.HR, fallbackOnError: "Nevažeći broj");

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
      expect(converter.convert(681), equals("šesto osamdeset jedan"));
      expect(converter.convert(999), equals("devetsto devedeset devet"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("tisuću"));
      expect(converter.convert(1001), equals("tisuću jedan"));
      expect(converter.convert(1011), equals("tisuću jedanaest"));
      expect(converter.convert(1110), equals("tisuću sto deset"));
      expect(converter.convert(1111), equals("tisuću sto jedanaest"));
      expect(converter.convert(2000), equals("dvije tisuće"));
      expect(converter.convert(2468),
          equals("dvije tisuće četiristo šezdeset osam"));
      expect(converter.convert(3579),
          equals("tri tisuće petsto sedamdeset devet"));
      expect(converter.convert(10000), equals("deset tisuća"));
      expect(converter.convert(10011), equals("deset tisuća jedanaest"));
      expect(converter.convert(11100), equals("jedanaest tisuća sto"));
      expect(converter.convert(12987),
          equals("dvanaest tisuća devetsto osamdeset sedam"));
      expect(converter.convert(45623),
          equals("četrdeset pet tisuća šesto dvadeset tri"));
      expect(converter.convert(87654),
          equals("osamdeset sedam tisuća šesto pedeset četiri"));
      expect(converter.convert(100000), equals("sto tisuća"));
      expect(converter.convert(123456),
          equals("sto dvadeset tri tisuće četiristo pedeset šest"));
      expect(converter.convert(987654),
          equals("devetsto osamdeset sedam tisuća šesto pedeset četiri"));
      expect(converter.convert(999999),
          equals("devetsto devedeset devet tisuća devetsto devedeset devet"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus jedan"));
      expect(converter.convert(-123), equals("minus sto dvadeset tri"));
      expect(converter.convert(-123.456),
          equals("minus sto dvadeset tri zarez četiri pet šest"));

      const negativeOption = HrOptions(negativePrefix: "negativan");

      expect(converter.convert(-1, options: negativeOption),
          equals("negativan jedan"));
      expect(converter.convert(-123, options: negativeOption),
          equals("negativan sto dvadeset tri"));
      expect(converter.convert(-123.456, options: negativeOption),
          equals("negativan sto dvadeset tri zarez četiri pet šest"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456),
          equals("sto dvadeset tri zarez četiri pet šest"));
      expect(converter.convert(1.5), equals("jedan zarez pet"));
      expect(converter.convert(1.05), equals("jedan zarez nula pet"));
      expect(converter.convert(879.465),
          equals("osamsto sedamdeset devet zarez četiri šest pet"));
      expect(converter.convert(1.5), equals("jedan zarez pet"));

      const pointOption = HrOptions(decimalSeparator: DecimalSeparator.point);

      expect(converter.convert(1.5, options: pointOption),
          equals("jedan točka pet"));

      const commaOption = HrOptions(decimalSeparator: DecimalSeparator.comma);

      expect(converter.convert(1.5, options: commaOption),
          equals("jedan zarez pet"));

      const periodOption = HrOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(1.5, options: periodOption),
          equals("jedan točka pet"));
    });

    test('Year Formatting', () {
      const yearOption = HrOptions(format: Format.year);

      expect(converter.convert(123, options: yearOption),
          equals("sto dvadeset tri"));
      expect(converter.convert(498, options: yearOption),
          equals("četiristo devedeset osam"));
      expect(converter.convert(756, options: yearOption),
          equals("sedamsto pedeset šest"));
      expect(converter.convert(1900, options: yearOption),
          equals("tisuću devetsto"));
      expect(converter.convert(1999, options: yearOption),
          equals("tisuću devetsto devedeset devet"));
      expect(converter.convert(2025, options: yearOption),
          equals("dvije tisuće dvadeset pet"));

      const yearOptionAD = HrOptions(format: Format.year, includeAD: true);

      expect(converter.convert(1900, options: yearOptionAD),
          equals("tisuću devetsto nove ere"));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("tisuću devetsto devedeset devet nove ere"));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("dvije tisuće dvadeset pet nove ere"));
      expect(converter.convert(-1, options: yearOption),
          equals("jedan prije Krista"));
      expect(converter.convert(-100, options: yearOption),
          equals("sto prije Krista"));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("sto prije Krista"));
      expect(converter.convert(-2025, options: yearOption),
          equals("dvije tisuće dvadeset pet prije Krista"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("jedan milijun prije Krista"));
    });

    test('Currency', () {
      const currencyOption = HrOptions(currency: true);

      expect(
          converter.convert(0, options: currencyOption), equals("nula eura"));
      expect(
          converter.convert(1, options: currencyOption), equals("jedan euro"));
      expect(converter.convert(2, options: currencyOption), equals("dva eura"));
      expect(converter.convert(3, options: currencyOption), equals("tri eura"));
      expect(
          converter.convert(4, options: currencyOption), equals("četiri eura"));
      expect(converter.convert(5, options: currencyOption), equals("pet eura"));
      expect(
          converter.convert(10, options: currencyOption), equals("deset eura"));
      expect(converter.convert(11, options: currencyOption),
          equals("jedanaest eura"));
      expect(converter.convert(21, options: currencyOption),
          equals("dvadeset jedan euro"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("jedan euro i pedeset centi"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("sto dvadeset tri eura i četrdeset pet centi"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("deset milijuna eura"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("pedeset centi"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("jedan cent"));
      expect(converter.convert(0.02, options: currencyOption),
          equals("dva centi"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("pet centi"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("jedan euro i jedan cent"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("dva eura i dva centi"));
    });

    test('Scale Numbers', () {
      expect(
          converter.convert(BigInt.from(10).pow(6)), equals("jedan milijun"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("dvije milijarde"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("tri bilijuna"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("četiri bilijarde"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("pet trilijuna"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("šest trilijardi"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("sedam kvadrilijuna"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "devet trilijuna osamsto sedamdeset šest bilijardi petsto četrdeset tri bilijuna dvjesto deset milijardi sto dvadeset tri milijuna četiristo pedeset šest tisuća sedamsto osamdeset devet"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "sto dvadeset tri trilijarde četiristo pedeset šest trilijuna sedamsto osamdeset devet bilijardi sto dvadeset tri bilijuna četiristo pedeset šest milijardi sedamsto osamdeset devet milijuna sto dvadeset tri tisuće četiristo pedeset šest"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              'devetsto devedeset devet trilijardi devetsto devedeset devet trilijuna devetsto devedeset devet bilijardi devetsto devedeset devet bilijuna devetsto devedeset devet milijardi devetsto devedeset devet milijuna devetsto devedeset devet tisuća devetsto devedeset devet'));

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("jedan bilijun dva milijuna tri"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("pet milijuna tisuću"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("jedna milijarda jedan"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("jedna milijarda jedan milijun"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("dva milijuna tisuću"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "jedan bilijun devetsto osamdeset sedam milijuna šesto tisuća tri"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Nije broj"));
      expect(converter.convert(double.infinity), equals("Beskonačnost"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negativna beskonačnost"));
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
          equals("Negativna beskonačnost"));
      expect(converterWithFallback.convert(null), equals("Nevažeći broj"));
      expect(converterWithFallback.convert('abc'), equals("Nevažeći broj"));
      expect(converterWithFallback.convert([]), equals("Nevažeći broj"));
      expect(converterWithFallback.convert({}), equals("Nevažeći broj"));
      expect(converterWithFallback.convert(Object()), equals("Nevažeći broj"));
      expect(converterWithFallback.convert(123), equals("sto dvadeset tri"));
    });
  });
}
