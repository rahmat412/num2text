import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Armenian (HY)', () {
    final converter = Num2Text(initialLang: Lang.HY);
    final converterWithFallback =
        Num2Text(initialLang: Lang.HY, fallbackOnError: "Անվավեր թիվ");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("զրո"));
      expect(converter.convert(1), equals("մեկ"));
      expect(converter.convert(10), equals("տասը"));
      expect(converter.convert(11), equals("տասնմեկ"));
      expect(converter.convert(20), equals("քսան"));
      expect(converter.convert(21), equals("քսանմեկ"));
      expect(converter.convert(99), equals("իննսունինը"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("հարյուր"));
      expect(converter.convert(101), equals("հարյուր մեկ"));
      expect(converter.convert(111), equals("հարյուր տասնմեկ"));
      expect(converter.convert(200), equals("երկու հարյուր"));
      expect(converter.convert(999), equals("ինը հարյուր իննսունինը"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("հազար"));
      expect(converter.convert(1001), equals("հազար մեկ"));
      expect(converter.convert(1111), equals("հազար հարյուր տասնմեկ"));
      expect(converter.convert(2000), equals("երկու հազար"));
      expect(converter.convert(10000), equals("տասը հազար"));
      expect(converter.convert(100000), equals("հարյուր հազար"));
      expect(converter.convert(123456),
          equals("հարյուր քսաներեք հազար չորս հարյուր հիսունվեց"));
      expect(
        converter.convert(999999),
        equals("ինը հարյուր իննսունինը հազար ինը հարյուր իննսունինը"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("մինուս մեկ"));
      expect(converter.convert(-123), equals("մինուս հարյուր քսաներեք"));
      expect(
        converter.convert(-1, options: HyOptions(negativePrefix: "բացասական")),
        equals("բացասական մեկ"),
      );
      expect(
        converter.convert(-123,
            options: HyOptions(negativePrefix: "բացասական")),
        equals("բացասական հարյուր քսաներեք"),
      );
    });

    test('Year Formatting', () {
      const yearOption = HyOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("հազար ինը հարյուր"));
      expect(converter.convert(2024, options: yearOption),
          equals("երկու հազար քսանչորս"));
      expect(
        converter.convert(1900,
            options: HyOptions(format: Format.year, includeEra: true)),
        equals("հազար ինը հարյուր թ."),
      );
      expect(
        converter.convert(2024,
            options: HyOptions(format: Format.year, includeEra: true)),
        equals("երկու հազար քսանչորս թ."),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("հարյուր մ.թ.ա."));
      expect(converter.convert(-1, options: yearOption), equals("մեկ մ.թ.ա."));

      expect(
        converter.convert(-2024,
            options: HyOptions(format: Format.year, includeEra: true)),
        equals("երկու հազար քսանչորս մ.թ.ա."),
      );
    });

    test('Currency', () {
      const currencyOption = HyOptions(currency: true);
      expect(converter.convert(0, options: currencyOption), equals("զրո դրամ"));
      expect(converter.convert(1, options: currencyOption), equals("մեկ դրամ"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("մեկ դրամ և հիսուն լումա"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("հարյուր քսաներեք դրամ և քառասունհինգ լումա"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("հարյուր քսաներեք ստորակետ չորս հինգ վեց"),
      );
      expect(converter.convert(Decimal.parse('1.50')),
          equals("մեկ ստորակետ հինգ"));
      expect(converter.convert(123.0), equals("հարյուր քսաներեք"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("հարյուր քսաներեք"));

      expect(
        converter.convert(1.5,
            options: const HyOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("մեկ ստորակետ հինգ"),
      );

      expect(
        converter.convert(1.5,
            options:
                const HyOptions(decimalSeparator: DecimalSeparator.period)),
        equals("մեկ կետ հինգ"),
      );
      expect(
        converter.convert(1.5,
            options: const HyOptions(decimalSeparator: DecimalSeparator.point)),
        equals("մեկ կետ հինգ"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Անվերջություն"));
      expect(converter.convert(double.negativeInfinity),
          equals("Բացասական անվերջություն"));
      expect(converter.convert(double.nan), equals("Թիվ չէ"));
      expect(converter.convert(null), equals("Թիվ չէ"));
      expect(converter.convert('abc'), equals("Թիվ չէ"));

      expect(converterWithFallback.convert(double.infinity),
          equals("Անվերջություն"));
      expect(
        converterWithFallback.convert(double.negativeInfinity),
        equals("Բացասական անվերջություն"),
      );
      expect(converterWithFallback.convert(double.nan), equals("Անվավեր թիվ"));
      expect(converterWithFallback.convert(null), equals("Անվավեր թիվ"));
      expect(converterWithFallback.convert('abc'), equals("Անվավեր թիվ"));
      expect(converterWithFallback.convert(123), equals("հարյուր քսաներեք"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("միլիոն"));
      expect(converter.convert(BigInt.from(1000000000)), equals("միլիարդ"));
      expect(converter.convert(BigInt.from(1000000000000)), equals("տրիլիոն"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("կվադրիլիոն"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("կվինտիլիոն"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("սեքստիլիոն"));
      expect(converter.convert(BigInt.parse('1000000000000000000000000')),
          equals("սեպտիլիոն"));

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "հարյուր քսաներեք սեքստիլիոն չորս հարյուր հիսունվեց կվինտիլիոն յոթ հարյուր ութսունինը կվադրիլիոն հարյուր քսաներեք տրիլիոն չորս հարյուր հիսունվեց միլիարդ յոթ հարյուր ութսունինը միլիոն հարյուր քսաներեք հազար չորս հարյուր հիսունվեց",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "ինը հարյուր իննսունինը սեքստիլիոն ինը հարյուր իննսունինը կվինտիլիոն ինը հարյուր իննսունինը կվադրիլիոն ինը հարյուր իննսունինը տրիլիոն ինը հարյուր իննսունինը միլիարդ ինը հարյուր իննսունինը միլիոն ինը հարյուր իննսունինը հազար ինը հարյուր իննսունինը",
        ),
      );
    });
  });
}
