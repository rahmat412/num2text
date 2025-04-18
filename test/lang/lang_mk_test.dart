import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Macedonian (MK)', () {
    final converter = Num2Text(initialLang: Lang.MK);
    final converterWithFallback =
        Num2Text(initialLang: Lang.MK, fallbackOnError: "Невалиден број");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("нула"));
      expect(converter.convert(1), equals("еден"));
      expect(converter.convert(10), equals("десет"));
      expect(converter.convert(11), equals("единаесет"));
      expect(converter.convert(20), equals("дваесет"));
      expect(converter.convert(21), equals("дваесет и еден"));
      expect(converter.convert(99), equals("деведесет и девет"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("сто"));
      expect(converter.convert(101), equals("сто и еден"));
      expect(converter.convert(111), equals("сто и единаесет"));
      expect(converter.convert(200), equals("двесте"));

      expect(
          converter.convert(999), equals("деветстотини и деведесет и девет"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("илјада"));
      expect(converter.convert(1001), equals("илјада и еден"));
      expect(converter.convert(1111), equals("илјада сто и единаесет"));
      expect(converter.convert(2000), equals("две илјади"));
      expect(converter.convert(10000), equals("десет илјади"));
      expect(converter.convert(100000), equals("сто илјади"));

      expect(
        converter.convert(123456),
        equals("сто и дваесет и три илјади четиристотини и педесет и шест"),
      );
      expect(
        converter.convert(999999),
        equals(
            "деветстотини и деведесет и девет илјади деветстотини и деведесет и девет"),
      );
    });

    test('Year Formatting', () {
      const yearOption = MkOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("илјада деветстотини"));

      expect(converter.convert(2024, options: yearOption),
          equals("две илјади и дваесет и четири"));
      expect(
        converter.convert(1900, options: MkOptions(format: Format.year)),
        equals("илјада деветстотини"),
      );

      expect(
        converter.convert(2024, options: MkOptions(format: Format.year)),
        equals("две илјади и дваесет и четири"),
      );
      expect(converter.convert(-100, options: yearOption), equals("минус сто"));
      expect(converter.convert(-1, options: yearOption), equals("минус еден"));

      expect(
        converter.convert(-2024, options: MkOptions(format: Format.year)),
        equals("минус две илјади и дваесет и четири"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("минус еден"));

      expect(converter.convert(-123), equals("минус сто и дваесет и три"));
      expect(
        converter.convert(-1, options: MkOptions(negativePrefix: "негативен")),
        equals("негативен еден"),
      );

      expect(
        converter.convert(-123,
            options: MkOptions(negativePrefix: "негативен")),
        equals("негативен сто и дваесет и три"),
      );
    });

    test('Currency', () {
      const currencyOption = MkOptions(currency: true);
      expect(converter.convert(1.01, options: currencyOption),
          equals("еден денар и еден дени"));
      expect(converter.convert(2.50, options: currencyOption),
          equals("два денари и педесет дени"));

      expect(
        converter.convert(123.45, options: currencyOption),
        equals("сто и дваесет и три денари и четириесет и пет дени"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("сто и дваесет и три запирка четири пет шест"),
      );

      expect(
          converter.convert(Decimal.parse('1.50')), equals("еден запирка пет"));

      expect(converter.convert(123.0), equals("сто и дваесет и три"));

      expect(converter.convert(Decimal.parse('123.0')),
          equals("сто и дваесет и три"));

      expect(
        converter.convert(1.5,
            options: const MkOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("еден запирка пет"),
      );

      expect(
        converter.convert(1.5,
            options:
                const MkOptions(decimalSeparator: DecimalSeparator.period)),
        equals("еден точка пет"),
      );

      expect(
        converter.convert(1.5,
            options: const MkOptions(decimalSeparator: DecimalSeparator.point)),
        equals("еден точка пет"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Бесконечност"));
      expect(converter.convert(double.negativeInfinity),
          equals("Негативна бесконечност"));
      expect(converter.convert(double.nan), equals("Не е број"));
      expect(converter.convert(null), equals("Не е број"));
      expect(converter.convert('abc'), equals("Не е број"));

      expect(converterWithFallback.convert(double.infinity),
          equals("Бесконечност"));
      expect(
        converterWithFallback.convert(double.negativeInfinity),
        equals("Негативна бесконечност"),
      );
      expect(
          converterWithFallback.convert(double.nan), equals("Невалиден број"));
      expect(converterWithFallback.convert(null), equals("Невалиден број"));
      expect(converterWithFallback.convert('abc'), equals("Невалиден број"));

      expect(converterWithFallback.convert(123), equals("сто и дваесет и три"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("еден милион"));
      expect(
          converter.convert(BigInt.from(1000000000)), equals("една милијарда"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("еден билион"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("една билијарда"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("еден трилион"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("една трилијарда"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("еден квадрилион"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "сто и дваесет и три трилијарди четиристотини и педесет и шест трилиони седумстотини и осумдесет и девет билијарди сто и дваесет и три билиони четиристотини и педесет и шест милијарди седумстотини и осумдесет и девет милиони сто и дваесет и три илјади четиристотини и педесет и шест",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "деветстотини и деведесет и девет трилијарди деветстотини и деведесет и девет трилиони деветстотини и деведесет и девет билијарди деветстотини и деведесет и девет билиони деветстотини и деведесет и девет милијарди деветстотини и деведесет и девет милиони деветстотини и деведесет и девет илјади деветстотини и деведесет и девет",
        ),
      );
    });
  });
}
