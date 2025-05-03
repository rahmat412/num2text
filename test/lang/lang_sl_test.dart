import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Slovenian (SL)', () {
    final converter = Num2Text(initialLang: Lang.SL);
    final converterWithFallback =
        Num2Text(initialLang: Lang.SL, fallbackOnError: "Neveljavna številka");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("nič"));
      expect(converter.convert(1), equals("ena"));
      expect(converter.convert(2), equals("dve"));
      expect(converter.convert(3), equals("tri"));
      expect(converter.convert(4), equals("štiri"));
      expect(converter.convert(5), equals("pet"));
      expect(converter.convert(9), equals("devet"));
      expect(converter.convert(10), equals("deset"));
      expect(converter.convert(11), equals("enajst"));
      expect(converter.convert(12), equals("dvanajst"));
      expect(converter.convert(13), equals("trinajst"));
      expect(converter.convert(14), equals("štirinajst"));
      expect(converter.convert(15), equals("petnajst"));
      expect(converter.convert(19), equals("devetnajst"));
      expect(converter.convert(20), equals("dvajset"));
      expect(converter.convert(21), equals("enaindvajset"));
      expect(converter.convert(22), equals("dvaindvajset"));
      expect(converter.convert(23), equals("triindvajset"));
      expect(converter.convert(24), equals("štiriindvajset"));
      expect(converter.convert(25), equals("petindvajset"));
      expect(converter.convert(27), equals("sedemindvajset"));
      expect(converter.convert(30), equals("trideset"));
      expect(converter.convert(54), equals("štiriinpetdeset"));
      expect(converter.convert(68), equals("oseminšestdeset"));
      expect(converter.convert(99), equals("devetindevetdeset"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("sto"));
      expect(converter.convert(101), equals("sto ena"));
      expect(converter.convert(105), equals("sto pet"));
      expect(converter.convert(110), equals("sto deset"));
      expect(converter.convert(111), equals("sto enajst"));
      expect(converter.convert(123), equals("sto triindvajset"));
      expect(converter.convert(200), equals("dvesto"));
      expect(converter.convert(321), equals("tristo enaindvajset"));
      expect(converter.convert(479), equals("štiristo devetinsedemdeset"));
      expect(converter.convert(596), equals("petsto šestindevetdeset"));
      expect(converter.convert(681), equals("šeststo enainosemdeset"));
      expect(converter.convert(999), equals("devetsto devetindevetdeset"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("tisoč"));
      expect(converter.convert(1001), equals("tisoč ena"));
      expect(converter.convert(1011), equals("tisoč enajst"));
      expect(converter.convert(1110), equals("tisoč sto deset"));
      expect(converter.convert(1111), equals("tisoč sto enajst"));
      expect(converter.convert(2000), equals("dva tisoč"));
      expect(converter.convert(2468),
          equals("dva tisoč štiristo oseminšestdeset"));
      expect(converter.convert(3579),
          equals("tri tisoč petsto devetinsedemdeset"));
      expect(converter.convert(10000), equals("deset tisoč"));
      expect(converter.convert(10011), equals("deset tisoč enajst"));
      expect(converter.convert(11100), equals("enajst tisoč sto"));
      expect(converter.convert(12987),
          equals("dvanajst tisoč devetsto sedeminosemdeset"));
      expect(converter.convert(45623),
          equals("petinštirideset tisoč šeststo triindvajset"));
      expect(converter.convert(87654),
          equals("sedeminosemdeset tisoč šeststo štiriinpetdeset"));
      expect(converter.convert(100000), equals("sto tisoč"));
      expect(converter.convert(123456),
          equals("sto triindvajset tisoč štiristo šestinpetdeset"));
      expect(converter.convert(987654),
          equals("devetsto sedeminosemdeset tisoč šeststo štiriinpetdeset"));
      expect(
          converter.convert(999999),
          equals(
              "devetsto devetindevetdeset tisoč devetsto devetindevetdeset"));
    });

    test('Negative Numbers', () {
      const negativeOption = SlOptions(negativePrefix: "negativno");

      expect(converter.convert(-1), equals("minus ena"));
      expect(converter.convert(-123), equals("minus sto triindvajset"));
      expect(converter.convert(-123.456),
          equals("minus sto triindvajset vejica štiri pet šest"));
      expect(converter.convert(-1, options: negativeOption),
          equals("negativno ena"));
      expect(converter.convert(-123, options: negativeOption),
          equals("negativno sto triindvajset"));
      expect(converter.convert(-123.456, options: negativeOption),
          equals("negativno sto triindvajset vejica štiri pet šest"));
    });

    test('Decimals', () {
      const pointOption = SlOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = SlOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = SlOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(123.456),
          equals("sto triindvajset vejica štiri pet šest"));
      expect(converter.convert(1.50), equals("ena vejica pet"));
      expect(converter.convert(1.05), equals("ena vejica nič pet"));
      expect(converter.convert(879.465),
          equals("osemsto devetinsedemdeset vejica štiri šest pet"));
      expect(converter.convert(1.5), equals("ena vejica pet"));
      expect(
          converter.convert(1.5, options: pointOption), equals("ena pika pet"));
      expect(converter.convert(1.5, options: commaOption),
          equals("ena vejica pet"));
      expect(converter.convert(1.5, options: periodOption),
          equals("ena pika pet"));
    });

    test('Year Formatting', () {
      const yearOption = SlOptions(format: Format.year);
      const yearOptionAD = SlOptions(format: Format.year, includeAD: true);

      expect(converter.convert(123, options: yearOption),
          equals("sto triindvajset"));
      expect(converter.convert(498, options: yearOption),
          equals("štiristo osemindevetdeset"));
      expect(converter.convert(756, options: yearOption),
          equals("sedemsto šestinpetdeset"));
      expect(converter.convert(1900, options: yearOption),
          equals("tisoč devetsto"));
      expect(converter.convert(1999, options: yearOption),
          equals("tisoč devetsto devetindevetdeset"));
      expect(converter.convert(2025, options: yearOption),
          equals("dva tisoč petindvajset"));
      expect(converter.convert(1900, options: yearOptionAD),
          equals("tisoč devetsto n. št."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("tisoč devetsto devetindevetdeset n. št."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("dva tisoč petindvajset n. št."));
      expect(converter.convert(-1, options: yearOption), equals("minus ena"));
      expect(converter.convert(-100, options: yearOption), equals("minus sto"));
      expect(
          converter.convert(-100, options: yearOptionAD), equals("minus sto"));
      expect(converter.convert(-2025, options: yearOption),
          equals("minus dva tisoč petindvajset"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("minus en milijon"));
    });

    test('Currency', () {
      const currencyOption = SlOptions(currency: true);

      expect(
          converter.convert(0, options: currencyOption), equals("nič evrov"));
      expect(converter.convert(1, options: currencyOption), equals("en evro"));
      expect(converter.convert(2, options: currencyOption), equals("dva evra"));
      expect(
          converter.convert(3, options: currencyOption), equals("trije evri"));
      expect(
          converter.convert(4, options: currencyOption), equals("štirje evri"));
      expect(
          converter.convert(5, options: currencyOption), equals("pet evrov"));
      expect(converter.convert(10, options: currencyOption),
          equals("deset evrov"));
      expect(converter.convert(11, options: currencyOption),
          equals("enajst evrov"));
      expect(converter.convert(21, options: currencyOption),
          equals("enaindvajset evrov"));
      expect(converter.convert(22, options: currencyOption),
          equals("dvaindvajset evrov"));
      expect(converter.convert(101, options: currencyOption),
          equals("sto en evro"));
      expect(converter.convert(102, options: currencyOption),
          equals("sto dva evra"));
      expect(converter.convert(103, options: currencyOption),
          equals("sto trije evri"));
      expect(converter.convert(104, options: currencyOption),
          equals("sto štirje evri"));
      expect(converter.convert(105, options: currencyOption),
          equals("sto pet evrov"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("en evro in petdeset centov"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("sto triindvajset evrov in petinštirideset centov"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("deset milijonov evrov"));
      expect(converter.convert(0.50, options: currencyOption),
          equals("petdeset centov"));
      expect(
          converter.convert(0.01, options: currencyOption), equals("en cent"));
      expect(converter.convert(0.02, options: currencyOption),
          equals("dva centa"));
      expect(converter.convert(0.03, options: currencyOption),
          equals("trije centi"));
      expect(converter.convert(0.04, options: currencyOption),
          equals("štirje centi"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("pet centov"));
      expect(converter.convert(0.11, options: currencyOption),
          equals("enajst centov"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("en evro in en cent"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("dva evra in dva centa"));
      expect(converter.convert(3.03, options: currencyOption),
          equals("trije evri in trije centi"));
      expect(converter.convert(4.04, options: currencyOption),
          equals("štirje evri in štirje centi"));
      expect(converter.convert(5.05, options: currencyOption),
          equals("pet evrov in pet centov"));
      expect(converter.convert(101.01, options: currencyOption),
          equals("sto en evro in en cent"));
      expect(converter.convert(102.02, options: currencyOption),
          equals("sto dva evra in dva centa"));
      expect(converter.convert(103.03, options: currencyOption),
          equals("sto trije evri in trije centi"));
      expect(converter.convert(104.04, options: currencyOption),
          equals("sto štirje evri in štirje centi"));
      expect(converter.convert(105.05, options: currencyOption),
          equals("sto pet evrov in pet centov"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("en milijon"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("dve milijardi"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("trije bilijoni"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("štiri bilijarde"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("pet trilijonov"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("šest trilijard"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("sedem kvadrilijonov"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "devet trilijonov osemsto šestinsedemdeset bilijard petsto triinštirideset bilijonov dvesto deset milijard sto triindvajset milijonov štiristo šestinpetdeset tisoč sedemsto devetinosemdeset"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "sto triindvajset trilijard štiristo šestinpetdeset trilijonov sedemsto devetinosemdeset bilijard sto triindvajset bilijonov štiristo šestinpetdeset milijard sedemsto devetinosemdeset milijonov sto triindvajset tisoč štiristo šestinpetdeset"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "devetsto devetindevetdeset trilijard devetsto devetindevetdeset trilijonov devetsto devetindevetdeset bilijard devetsto devetindevetdeset bilijonov devetsto devetindevetdeset milijard devetsto devetindevetdeset milijonov devetsto devetindevetdeset tisoč devetsto devetindevetdeset"));

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('en bilijon dva milijona tri'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("pet milijonov tisoč"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("ena milijarda ena"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("ena milijarda en milijon"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("dva milijona tisoč"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              'en bilijon devetsto sedeminosemdeset milijonov šeststo tisoč tri'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Ni število"));
      expect(converter.convert(double.infinity), equals("Neskončnost"));
      expect(converter.convert(double.negativeInfinity),
          equals("Minus neskončnost"));
      expect(converter.convert(null), equals("Ni število"));
      expect(converter.convert('abc'), equals("Ni število"));
      expect(converter.convert([]), equals("Ni število"));
      expect(converter.convert({}), equals("Ni število"));
      expect(converter.convert(Object()), equals("Ni število"));

      expect(converterWithFallback.convert(double.nan),
          equals("Neveljavna številka"));
      expect(converterWithFallback.convert(double.infinity),
          equals("Neskončnost"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Minus neskončnost"));
      expect(
          converterWithFallback.convert(null), equals("Neveljavna številka"));
      expect(
          converterWithFallback.convert('abc'), equals("Neveljavna številka"));
      expect(converterWithFallback.convert([]), equals("Neveljavna številka"));
      expect(converterWithFallback.convert({}), equals("Neveljavna številka"));
      expect(converterWithFallback.convert(Object()),
          equals("Neveljavna številka"));
      expect(converterWithFallback.convert(123), equals("sto triindvajset"));
    });
  });
}
