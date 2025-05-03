import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Czech (CS)', () {
    final converter = Num2Text(initialLang: Lang.CS);

    final converterWithFallback =
        Num2Text(initialLang: Lang.CS, fallbackOnError: "Neplatné Číslo");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("nula"));
      expect(converter.convert(10), equals("deset"));
      expect(converter.convert(11), equals("jedenáct"));
      expect(converter.convert(13), equals("třináct"));
      expect(converter.convert(15), equals("patnáct"));
      expect(converter.convert(20), equals("dvacet"));
      expect(converter.convert(27), equals("dvacet sedm"));
      expect(converter.convert(30), equals("třicet"));
      expect(converter.convert(54), equals("padesát čtyři"));
      expect(converter.convert(68), equals("šedesát osm"));
      expect(converter.convert(99), equals("devadesát devět"));
    });

    test('Basic Numbers (0 - 99 Masculine)', () {
      const mascOptions = CsOptions(gender: Gender.masculine);

      expect(converter.convert(0, options: mascOptions), equals("nula"));
      expect(converter.convert(1, options: mascOptions), equals("jeden"));
      expect(converter.convert(2, options: mascOptions), equals("dva"));
      expect(converter.convert(10, options: mascOptions), equals("deset"));
      expect(
          converter.convert(21, options: mascOptions), equals("dvacet jeden"));
      expect(converter.convert(22, options: mascOptions), equals("dvacet dva"));
      expect(converter.convert(99, options: mascOptions),
          equals("devadesát devět"));
    });

    test('Basic Numbers (0 - 99 Feminine)', () {
      const femOptions = CsOptions(gender: Gender.feminine);

      expect(converter.convert(0, options: femOptions), equals("nula"));
      expect(converter.convert(1, options: femOptions), equals("jedna"));
      expect(converter.convert(2, options: femOptions), equals("dvě"));
      expect(converter.convert(10, options: femOptions), equals("deset"));
      expect(
          converter.convert(21, options: femOptions), equals("dvacet jedna"));
      expect(converter.convert(22, options: femOptions), equals("dvacet dvě"));
      expect(converter.convert(99, options: femOptions),
          equals("devadesát devět"));
    });

    test('Basic Numbers (0 - 99 Neuter)', () {
      const neutOptions = CsOptions(gender: Gender.neuter);

      expect(converter.convert(0, options: neutOptions), equals("nula"));
      expect(converter.convert(1, options: neutOptions), equals("jedno"));
      expect(converter.convert(2, options: neutOptions), equals("dvě"));
      expect(converter.convert(10, options: neutOptions), equals("deset"));
      expect(
          converter.convert(21, options: neutOptions), equals("dvacet jedno"));
      expect(converter.convert(22, options: neutOptions), equals("dvacet dvě"));
      expect(converter.convert(99, options: neutOptions),
          equals("devadesát devět"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("sto"));
      expect(converter.convert(101), equals("sto jedna"));
      expect(converter.convert(105), equals("sto pět"));
      expect(converter.convert(110), equals("sto deset"));
      expect(converter.convert(111), equals("sto jedenáct"));
      expect(converter.convert(123), equals("sto dvacet tři"));
      expect(converter.convert(200), equals("dvě stě"));
      expect(converter.convert(321), equals("tři sta dvacet jedna"));
      expect(converter.convert(479), equals("čtyři sta sedmdesát devět"));
      expect(converter.convert(596), equals("pět set devadesát šest"));
      expect(converter.convert(681), equals("šest set osmdesát jedna"));
      expect(converter.convert(999), equals("devět set devadesát devět"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("tisíc"));
      expect(converter.convert(1001), equals("tisíc jedna"));
      expect(converter.convert(1011), equals("tisíc jedenáct"));
      expect(converter.convert(1110), equals("tisíc sto deset"));
      expect(converter.convert(1111), equals("tisíc sto jedenáct"));
      expect(converter.convert(2000), equals("dva tisíce"));
      expect(
          converter.convert(2468), equals("dva tisíce čtyři sta šedesát osm"));
      expect(converter.convert(3579),
          equals("tři tisíce pět set sedmdesát devět"));
      expect(converter.convert(10000), equals("deset tisíc"));
      expect(converter.convert(10011), equals("deset tisíc jedenáct"));
      expect(converter.convert(11100), equals("jedenáct tisíc sto"));
      expect(converter.convert(12987),
          equals("dvanáct tisíc devět set osmdesát sedm"));
      expect(converter.convert(45623),
          equals("čtyřicet pět tisíc šest set dvacet tři"));
      expect(converter.convert(87654),
          equals("osmdesát sedm tisíc šest set padesát čtyři"));
      expect(converter.convert(100000), equals("sto tisíc"));
      expect(converter.convert(123456),
          equals("sto dvacet tři tisíc čtyři sta padesát šest"));
      expect(converter.convert(987654),
          equals("devět set osmdesát sedm tisíc šest set padesát čtyři"));
      expect(converter.convert(999999),
          equals("devět set devadesát devět tisíc devět set devadesát devět"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("mínus jedna"));
      expect(converter.convert(-123), equals("mínus sto dvacet tři"));
      expect(converter.convert(-123.456),
          equals("mínus sto dvacet tři celá čtyři pět šest"));

      const negativeOptions = CsOptions(negativePrefix: "záporné");

      expect(converter.convert(-1, options: negativeOptions),
          equals("záporné jedna"));
      expect(converter.convert(-123, options: negativeOptions),
          equals("záporné sto dvacet tři"));
      expect(converter.convert(-123.456, options: negativeOptions),
          equals("záporné sto dvacet tři celá čtyři pět šest"));
    });

    test('Decimals', () {
      const pointOption = CsOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = CsOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = CsOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(123.456),
          equals("sto dvacet tři celá čtyři pět šest"));
      expect(converter.convert(1.5), equals("jedna celá pět"));
      expect(converter.convert(1.05), equals("jedna celá nula pět"));
      expect(converter.convert(879.465),
          equals("osm set sedmdesát devět celá čtyři šest pět"));
      expect(converter.convert(1.5), equals("jedna celá pět"));

      expect(converter.convert(1.5, options: pointOption),
          equals("jedna tečka pět"));
      expect(converter.convert(1.5, options: commaOption),
          equals("jedna celá pět"));
      expect(converter.convert(1.5, options: periodOption),
          equals("jedna tečka pět"));
    });

    test('Year Formatting', () {
      const yearOption = CsOptions(format: Format.year);
      const yearOptionAD = CsOptions(format: Format.year, includeAD: true);

      expect(converter.convert(123, options: yearOption),
          equals("sto dvacet tři"));
      expect(converter.convert(498, options: yearOption),
          equals("čtyři sta devadesát osm"));
      expect(converter.convert(756, options: yearOption),
          equals("sedm set padesát šest"));
      expect(converter.convert(1900, options: yearOption),
          equals("tisíc devět set"));
      expect(converter.convert(1999, options: yearOption),
          equals("tisíc devět set devadesát devět"));
      expect(converter.convert(2025, options: yearOption),
          equals("dva tisíce dvacet pět"));

      expect(converter.convert(1900, options: yearOptionAD),
          equals("tisíc devět set n. l."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("tisíc devět set devadesát devět n. l."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("dva tisíce dvacet pět n. l."));

      expect(converter.convert(-1, options: yearOption),
          equals("jedna př. n. l."));
      expect(converter.convert(-100, options: yearOption),
          equals("sto př. n. l."));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("sto př. n. l."));
      expect(converter.convert(-2025, options: yearOption),
          equals("dva tisíce dvacet pět př. n. l."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("jeden milion př. n. l."));
    });

    test('Currency', () {
      const currencyOption = CsOptions(currency: true);

      expect(converter.convert(0, options: currencyOption),
          equals("nula korun českých"));
      expect(converter.convert(1, options: currencyOption),
          equals("jedna koruna česká"));
      expect(converter.convert(2, options: currencyOption),
          equals("dvě koruny české"));
      expect(converter.convert(3, options: currencyOption),
          equals("tři koruny české"));
      expect(converter.convert(4, options: currencyOption),
          equals("čtyři koruny české"));
      expect(converter.convert(5, options: currencyOption),
          equals("pět korun českých"));
      expect(converter.convert(10, options: currencyOption),
          equals("deset korun českých"));
      expect(converter.convert(11, options: currencyOption),
          equals("jedenáct korun českých"));
      expect(converter.convert(21, options: currencyOption),
          equals("dvacet jedna korun českých"));
      expect(converter.convert(22, options: currencyOption),
          equals("dvacet dvě koruny české"));
      expect(converter.convert(25, options: currencyOption),
          equals("dvacet pět korun českých"));
      expect(converter.convert(100, options: currencyOption),
          equals("sto korun českých"));
      expect(converter.convert(101, options: currencyOption),
          equals("sto jedna korun českých"));
      expect(converter.convert(102, options: currencyOption),
          equals("sto dvě koruny české"));
      expect(converter.convert(105, options: currencyOption),
          equals("sto pět korun českých"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("jedna koruna česká a padesát haléřů"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("sto dvacet tři koruny české a čtyřicet pět haléřů"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("deset milionů korun českých"));
      expect(converter.convert(0.5), equals("nula celá pět"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("padesát haléřů"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("jeden haléř"));
      expect(converter.convert(0.02, options: currencyOption),
          equals("dva haléře"));
      expect(converter.convert(0.03, options: currencyOption),
          equals("tři haléře"));
      expect(converter.convert(0.04, options: currencyOption),
          equals("čtyři haléře"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("pět haléřů"));
      expect(converter.convert(0.11, options: currencyOption),
          equals("jedenáct haléřů"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("jedna koruna česká a jeden haléř"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("dvě koruny české a dva haléře"));
      expect(converter.convert(5.05, options: currencyOption),
          equals("pět korun českých a pět haléřů"));
      expect(converter.convert(11.11, options: currencyOption),
          equals("jedenáct korun českých a jedenáct haléřů"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("jeden milion"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("dvě miliardy"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("tři biliony"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("čtyři biliardy"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("pět trilionů"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("šest triliard"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("sedm kvadrilionů"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "devět trilionů osm set sedmdesát šest biliard pět set čtyřicet tři bilionů dvě stě deset miliard sto dvacet tři milionů čtyři sta padesát šest tisíc sedm set osmdesát devět"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "sto dvacet tři triliard čtyři sta padesát šest trilionů sedm set osmdesát devět biliard sto dvacet tři bilionů čtyři sta padesát šest miliard sedm set osmdesát devět milionů sto dvacet tři tisíc čtyři sta padesát šest"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "devět set devadesát devět triliard devět set devadesát devět trilionů devět set devadesát devět biliard devět set devadesát devět bilionů devět set devadesát devět miliard devět set devadesát devět milionů devět set devadesát devět tisíc devět set devadesát devět"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("jeden bilion dva miliony tři"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("pět milionů tisíc"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("jedna miliarda jedna"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("jedna miliarda jeden milion"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("dva miliony tisíc"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              'jeden bilion devět set osmdesát sedm milionů šest set tisíc tři'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Není Číslo"));
      expect(converter.convert(double.infinity), equals("Nekonečno"));
      expect(converter.convert(double.negativeInfinity),
          equals("Záporné Nekonečno"));
      expect(converter.convert(null), equals("Není Číslo"));
      expect(converter.convert('abc'), equals("Není Číslo"));
      expect(converter.convert([]), equals("Není Číslo"));
      expect(converter.convert({}), equals("Není Číslo"));
      expect(converter.convert(Object()), equals("Není Číslo"));

      expect(
          converterWithFallback.convert(double.nan), equals("Neplatné Číslo"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Nekonečno"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Záporné Nekonečno"));
      expect(converterWithFallback.convert(null), equals("Neplatné Číslo"));
      expect(converterWithFallback.convert('abc'), equals("Neplatné Číslo"));
      expect(converterWithFallback.convert([]), equals("Neplatné Číslo"));
      expect(converterWithFallback.convert({}), equals("Neplatné Číslo"));
      expect(converterWithFallback.convert(Object()), equals("Neplatné Číslo"));
      expect(converterWithFallback.convert(123), equals("sto dvacet tři"));
    });
  });
}
