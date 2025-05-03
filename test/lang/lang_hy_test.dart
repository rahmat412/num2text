import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Armenian (HY)', () {
    final converter = Num2Text(initialLang: Lang.HY);
    final converterWithFallback =
        Num2Text(initialLang: Lang.HY, fallbackOnError: "Անվավեր թիվ");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("զրո"));
      expect(converter.convert(10), equals("տասը"));
      expect(converter.convert(11), equals("տասնմեկ"));
      expect(converter.convert(13), equals("տասներեք"));
      expect(converter.convert(15), equals("տասնհինգ"));
      expect(converter.convert(20), equals("քսան"));
      expect(converter.convert(27), equals("քսանյոթ"));
      expect(converter.convert(30), equals("երեսուն"));
      expect(converter.convert(54), equals("հիսունչորս"));
      expect(converter.convert(68), equals("վաթսունութ"));
      expect(converter.convert(99), equals("իննսունինը"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("հարյուր"));
      expect(converter.convert(101), equals("հարյուր մեկ"));
      expect(converter.convert(105), equals("հարյուր հինգ"));
      expect(converter.convert(110), equals("հարյուր տասը"));
      expect(converter.convert(111), equals("հարյուր տասնմեկ"));
      expect(converter.convert(123), equals("հարյուր քսաներեք"));
      expect(converter.convert(200), equals("երկու հարյուր"));
      expect(converter.convert(321), equals("երեք հարյուր քսանմեկ"));
      expect(converter.convert(479), equals("չորս հարյուր յոթանասունինը"));
      expect(converter.convert(596), equals("հինգ հարյուր իննսունվեց"));
      expect(converter.convert(681), equals("վեց հարյուր ութսունմեկ"));
      expect(converter.convert(999), equals("ինը հարյուր իննսունինը"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("հազար"));
      expect(converter.convert(1001), equals("հազար մեկ"));
      expect(converter.convert(1011), equals("հազար տասնմեկ"));
      expect(converter.convert(1110), equals("հազար հարյուր տասը"));
      expect(converter.convert(1111), equals("հազար հարյուր տասնմեկ"));
      expect(converter.convert(2000), equals("երկու հազար"));
      expect(converter.convert(2468),
          equals("երկու հազար չորս հարյուր վաթսունութ"));
      expect(converter.convert(3579),
          equals("երեք հազար հինգ հարյուր յոթանասունինը"));
      expect(converter.convert(10000), equals("տասը հազար"));
      expect(converter.convert(10011), equals("տասը հազար տասնմեկ"));
      expect(converter.convert(11100), equals("տասնմեկ հազար հարյուր"));
      expect(converter.convert(12987),
          equals("տասներկու հազար ինը հարյուր ութսունյոթ"));
      expect(converter.convert(45623),
          equals("քառասունհինգ հազար վեց հարյուր քսաներեք"));
      expect(converter.convert(87654),
          equals("ութսունյոթ հազար վեց հարյուր հիսունչորս"));
      expect(converter.convert(100000), equals("հարյուր հազար"));
      expect(converter.convert(123456),
          equals("հարյուր քսաներեք հազար չորս հարյուր հիսունվեց"));
      expect(converter.convert(987654),
          equals("ինը հարյուր ութսունյոթ հազար վեց հարյուր հիսունչորս"));
      expect(converter.convert(999999),
          equals("ինը հարյուր իննսունինը հազար ինը հարյուր իննսունինը"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("մինուս մեկ"));
      expect(converter.convert(-123), equals("մինուս հարյուր քսաներեք"));
      expect(converter.convert(-123.456),
          equals("մինուս հարյուր քսաներեք ստորակետ չորս հինգ վեց"));

      const negativeOption = HyOptions(negativePrefix: "բացասական");

      expect(converter.convert(-1, options: negativeOption),
          equals("բացասական մեկ"));
      expect(converter.convert(-123, options: negativeOption),
          equals("բացասական հարյուր քսաներեք"));
      expect(converter.convert(-123.456, options: negativeOption),
          equals("բացասական հարյուր քսաներեք ստորակետ չորս հինգ վեց"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456),
          equals("հարյուր քսաներեք ստորակետ չորս հինգ վեց"));
      expect(converter.convert(1.5), equals("մեկ ստորակետ հինգ"));
      expect(converter.convert(1.05), equals("մեկ ստորակետ զրո հինգ"));
      expect(converter.convert(879.465),
          equals("ութ հարյուր յոթանասունինը ստորակետ չորս վեց հինգ"));
      expect(converter.convert(1.5), equals("մեկ ստորակետ հինգ"));

      const pointOption = HyOptions(decimalSeparator: DecimalSeparator.point);

      expect(
          converter.convert(1.5, options: pointOption), equals("մեկ կետ հինգ"));

      const commaOption = HyOptions(decimalSeparator: DecimalSeparator.comma);

      expect(converter.convert(1.5, options: commaOption),
          equals("մեկ ստորակետ հինգ"));

      const periodOption = HyOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(1.5, options: periodOption),
          equals("մեկ կետ հինգ"));
    });

    test('Year Formatting', () {
      const yearOption = HyOptions(format: Format.year);

      expect(converter.convert(123, options: yearOption),
          equals("հարյուր քսաներեք"));
      expect(converter.convert(498, options: yearOption),
          equals("չորս հարյուր իննսունութ"));
      expect(converter.convert(756, options: yearOption),
          equals("յոթ հարյուր հիսունվեց"));
      expect(converter.convert(1900, options: yearOption),
          equals("հազար ինը հարյուր"));
      expect(converter.convert(1999, options: yearOption),
          equals("հազար ինը հարյուր իննսունինը"));
      expect(converter.convert(2025, options: yearOption),
          equals("երկու հազար քսանհինգ"));

      const yearOptionEra = HyOptions(format: Format.year, includeEra: true);

      expect(converter.convert(1900, options: yearOptionEra),
          equals("հազար ինը հարյուր թ."));
      expect(converter.convert(1999, options: yearOptionEra),
          equals("հազար ինը հարյուր իննսունինը թ."));
      expect(converter.convert(2025, options: yearOptionEra),
          equals("երկու հազար քսանհինգ թ."));
      expect(converter.convert(-1, options: yearOption), equals("մեկ մ.թ.ա."));
      expect(converter.convert(-100, options: yearOption),
          equals("հարյուր մ.թ.ա."));
      expect(converter.convert(-100, options: yearOptionEra),
          equals("հարյուր մ.թ.ա."));
      expect(converter.convert(-2025, options: yearOption),
          equals("երկու հազար քսանհինգ մ.թ.ա."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("միլիոն մ.թ.ա."));
    });

    test('Currency', () {
      const currencyOption = HyOptions(currency: true);

      expect(converter.convert(0, options: currencyOption), equals("զրո դրամ"));
      expect(converter.convert(1, options: currencyOption), equals("մեկ դրամ"));
      expect(
          converter.convert(5, options: currencyOption), equals("հինգ դրամ"));
      expect(
          converter.convert(10, options: currencyOption), equals("տասը դրամ"));
      expect(converter.convert(11, options: currencyOption),
          equals("տասնմեկ դրամ"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("մեկ դրամ և հիսուն լումա"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("հարյուր քսաներեք դրամ և քառասունհինգ լումա"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("տասը միլիոն դրամ"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("մեկ լումա"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("հիսուն լումա"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("միլիոն"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("երկու միլիարդ"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("երեք տրիլիոն"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("չորս կվադրիլիոն"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("հինգ կվինտիլիոն"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("վեց սեքստիլիոն"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("յոթ սեպտիլիոն"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "ինը կվինտիլիոն ութ հարյուր յոթանասունվեց կվադրիլիոն հինգ հարյուր քառասուներեք տրիլիոն երկու հարյուր տասը միլիարդ հարյուր քսաներեք միլիոն չորս հարյուր հիսունվեց հազար յոթ հարյուր ութսունինը"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "հարյուր քսաներեք սեքստիլիոն չորս հարյուր հիսունվեց կվինտիլիոն յոթ հարյուր ութսունինը կվադրիլիոն հարյուր քսաներեք տրիլիոն չորս հարյուր հիսունվեց միլիարդ յոթ հարյուր ութսունինը միլիոն հարյուր քսաներեք հազար չորս հարյուր հիսունվեց"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "ինը հարյուր իննսունինը սեքստիլիոն ինը հարյուր իննսունինը կվինտիլիոն ինը հարյուր իննսունինը կվադրիլիոն ինը հարյուր իննսունինը տրիլիոն ինը հարյուր իննսունինը միլիարդ ինը հարյուր իննսունինը միլիոն ինը հարյուր իննսունինը հազար ինը հարյուր իննսունինը"));

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("մեկ տրիլիոն երկու միլիոն երեք"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("հինգ միլիոն հազար"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("մեկ միլիարդ մեկ"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("մեկ միլիարդ մեկ միլիոն"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("երկու միլիոն հազար"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "մեկ տրիլիոն ինը հարյուր ութսունյոթ միլիոն վեց հարյուր հազար երեք"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Թիվ չէ"));
      expect(converter.convert(double.infinity), equals("Անվերջություն"));
      expect(converter.convert(double.negativeInfinity),
          equals("Բացասական անվերջություն"));
      expect(converter.convert(null), equals("Թիվ չէ"));
      expect(converter.convert('abc'), equals("Թիվ չէ"));
      expect(converter.convert([]), equals("Թիվ չէ"));
      expect(converter.convert({}), equals("Թիվ չէ"));
      expect(converter.convert(Object()), equals("Թիվ չէ"));

      expect(converterWithFallback.convert(double.nan), equals("Անվավեր թիվ"));
      expect(converterWithFallback.convert(double.infinity),
          equals("Անվերջություն"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Բացասական անվերջություն"));
      expect(converterWithFallback.convert(null), equals("Անվավեր թիվ"));
      expect(converterWithFallback.convert('abc'), equals("Անվավեր թիվ"));
      expect(converterWithFallback.convert([]), equals("Անվավեր թիվ"));
      expect(converterWithFallback.convert({}), equals("Անվավեր թիվ"));
      expect(converterWithFallback.convert(Object()), equals("Անվավեր թիվ"));
      expect(converterWithFallback.convert(123), equals("հարյուր քսաներեք"));
    });
  });
}
