import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Macedonian (MK)', () {
    final converter = Num2Text(initialLang: Lang.MK);
    final converterWithFallback =
        Num2Text(initialLang: Lang.MK, fallbackOnError: "Невалиден Број");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("нула"));
      expect(converter.convert(1), equals("еден"));
      expect(converter.convert(10), equals("десет"));
      expect(converter.convert(11), equals("единаесет"));
      expect(converter.convert(13), equals("тринаесет"));
      expect(converter.convert(15), equals("петнаесет"));
      expect(converter.convert(20), equals("дваесет"));
      expect(converter.convert(27), equals("дваесет и седум"));
      expect(converter.convert(30), equals("триесет"));
      expect(converter.convert(54), equals("педесет и четири"));
      expect(converter.convert(68), equals("шеесет и осум"));
      expect(converter.convert(99), equals("деведесет и девет"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("сто"));
      expect(converter.convert(101), equals("сто и еден"));
      expect(converter.convert(105), equals("сто и пет"));
      expect(converter.convert(110), equals("сто и десет"));
      expect(converter.convert(111), equals("сто и единаесет"));
      expect(converter.convert(123), equals("сто и дваесет и три"));
      expect(converter.convert(200), equals("двесте"));
      expect(converter.convert(321), equals("триста и дваесет и еден"));
      expect(
          converter.convert(479), equals("четиристотини и седумдесет и девет"));
      expect(converter.convert(596), equals("петстотини и деведесет и шест"));
      expect(converter.convert(681), equals("шестотини и осумдесет и еден"));
      expect(
          converter.convert(999), equals("деветстотини и деведесет и девет"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("илјада"));
      expect(converter.convert(1001), equals("илјада и еден"));
      expect(converter.convert(1011), equals("илјада и единаесет"));
      expect(converter.convert(1110), equals("илјада сто и десет"));
      expect(converter.convert(1111), equals("илјада сто и единаесет"));
      expect(converter.convert(2000), equals("две илјади"));
      expect(converter.convert(2468),
          equals("две илјади четиристотини и шеесет и осум"));
      expect(converter.convert(3579),
          equals("три илјади петстотини и седумдесет и девет"));
      expect(converter.convert(10000), equals("десет илјади"));
      expect(converter.convert(10011), equals("десет илјади и единаесет"));
      expect(converter.convert(11100), equals("единаесет илјади и сто"));
      expect(converter.convert(12987),
          equals("дванаесет илјади деветстотини и осумдесет и седум"));
      expect(converter.convert(45623),
          equals("четириесет и пет илјади шестотини и дваесет и три"));
      expect(converter.convert(87654),
          equals("осумдесет и седум илјади шестотини и педесет и четири"));
      expect(converter.convert(100000), equals("сто илјади"));
      expect(converter.convert(123456),
          equals("сто и дваесет и три илјади четиристотини и педесет и шест"));
      expect(
          converter.convert(987654),
          equals(
              "деветстотини и осумдесет и седум илјади шестотини и педесет и четири"));
      expect(
          converter.convert(999999),
          equals(
              "деветстотини и деведесет и девет илјади деветстотини и деведесет и девет"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("минус еден"));
      expect(converter.convert(-123), equals("минус сто и дваесет и три"));
      expect(converter.convert(-123.456),
          equals("минус сто и дваесет и три запирка четири пет шест"));

      const negativeOption = MkOptions(negativePrefix: "негативен");

      expect(converter.convert(-1, options: negativeOption),
          equals("негативен еден"));
      expect(converter.convert(-123, options: negativeOption),
          equals("негативен сто и дваесет и три"));
      expect(converter.convert(-123.456, options: negativeOption),
          equals("негативен сто и дваесет и три запирка четири пет шест"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456),
          equals("сто и дваесет и три запирка четири пет шест"));
      expect(converter.convert("1.5"), equals("еден запирка пет"));
      expect(converter.convert(1.05), equals("еден запирка нула пет"));
      expect(converter.convert(879.465),
          equals("осумстотини и седумдесет и девет запирка четири шест пет"));
      expect(converter.convert(1.5), equals("еден запирка пет"));

      const pointOption = MkOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = MkOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = MkOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(1.5, options: pointOption),
          equals("еден точка пет"));
      expect(converter.convert(1.5, options: commaOption),
          equals("еден запирка пет"));
      expect(converter.convert(1.5, options: periodOption),
          equals("еден точка пет"));
    });

    test('Year Formatting', () {
      const yearOption = MkOptions(format: Format.year);

      expect(converter.convert(123, options: yearOption),
          equals("сто и дваесет и три"));
      expect(converter.convert(498, options: yearOption),
          equals("четиристотини и деведесет и осум"));
      expect(converter.convert(756, options: yearOption),
          equals("седумстотини и педесет и шест"));
      expect(converter.convert(1900, options: yearOption),
          equals("илјада и деветстотини"));
      expect(converter.convert(1999, options: yearOption),
          equals("илјада деветстотини и деведесет и девет"));
      expect(converter.convert(2025, options: yearOption),
          equals("две илјади и дваесет и пет"));

      const yearOptionAD = MkOptions(format: Format.year, includeAD: true);

      expect(converter.convert(1900, options: yearOptionAD),
          equals("илјада и деветстотини н.е."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("илјада деветстотини и деведесет и девет н.е."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("две илјади и дваесет и пет н.е."));
      expect(converter.convert(-1, options: yearOption), equals("еден п.н.е."));
      expect(
          converter.convert(-100, options: yearOption), equals("сто п.н.е."));
      expect(
          converter.convert(-100, options: yearOptionAD), equals("сто п.н.е."));
      expect(converter.convert(-2025, options: yearOption),
          equals("две илјади и дваесет и пет п.н.е."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("еден милион п.н.е."));
    });

    test('Currency', () {
      const currencyOption = MkOptions(currency: true);

      expect(
          converter.convert(0, options: currencyOption), equals("нула денари"));
      expect(
          converter.convert(1, options: currencyOption), equals("еден денар"));
      expect(
          converter.convert(2, options: currencyOption), equals("два денари"));
      expect(
          converter.convert(5, options: currencyOption), equals("пет денари"));
      expect(converter.convert(10, options: currencyOption),
          equals("десет денари"));
      expect(converter.convert(11, options: currencyOption),
          equals("единаесет денари"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("еден денар и еден дени"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("два денари и два дени"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("еден денар и педесет дени"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("сто и дваесет и три денари и четириесет и пет дени"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("десет милиони денари"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("еден дени"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("педесет дени"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("еден милион"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("две милијарди"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("три билиони"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("четири билијарди"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("пет трилиони"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("шест трилијарди"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("седум квадрилиони"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            "девет трилиони осумстотини и седумдесет и шест билијарди петстотини и четириесет и три билиони двесте и десет милијарди сто и дваесет и три милиони четиристотини и педесет и шест илјади седумстотини и осумдесет и девет"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "сто и дваесет и три трилијарди четиристотини и педесет и шест трилиони седумстотини и осумдесет и девет билијарди сто и дваесет и три билиони четиристотини и педесет и шест милијарди седумстотини и осумдесет и девет милиони сто и дваесет и три илјади четиристотини и педесет и шест"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "деветстотини и деведесет и девет трилијарди деветстотини и деведесет и девет трилиони деветстотини и деведесет и девет билијарди деветстотини и деведесет и девет билиони деветстотини и деведесет и девет милијарди деветстотини и деведесет и девет милиони деветстотини и деведесет и девет илјади деветстотини и деведесет и девет"),
      );
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('еден билион и два милиони и три'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("пет милиони и илјада"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("една милијарда и еден"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("една милијарда и еден милион"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("два милиони и илјада"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              'еден билион деветстотини и осумдесет и седум милиони и шестотини илјади и три'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Не Е Број"));
      expect(converter.convert(double.infinity), equals("Бесконечност"));
      expect(converter.convert(double.negativeInfinity),
          equals("Негативна Бесконечност"));
      expect(converter.convert(null), equals("Не Е Број"));
      expect(converter.convert('abc'), equals("Не Е Број"));
      expect(converter.convert([]), equals("Не Е Број"));
      expect(converter.convert({}), equals("Не Е Број"));
      expect(converter.convert(Object()), equals("Не Е Број"));

      expect(
          converterWithFallback.convert(double.nan), equals("Невалиден Број"));
      expect(converterWithFallback.convert(double.infinity),
          equals("Бесконечност"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Негативна Бесконечност"));
      expect(converterWithFallback.convert(null), equals("Невалиден Број"));
      expect(converterWithFallback.convert('abc'), equals("Невалиден Број"));
      expect(converterWithFallback.convert([]), equals("Невалиден Број"));
      expect(converterWithFallback.convert({}), equals("Невалиден Број"));
      expect(converterWithFallback.convert(Object()), equals("Невалиден Број"));
      expect(converterWithFallback.convert(123), equals("сто и дваесет и три"));
    });
  });
}
