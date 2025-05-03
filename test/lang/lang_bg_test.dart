import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Bulgarian (BG)', () {
    final converter = Num2Text(initialLang: Lang.BG);

    final converterWithFallback = Num2Text(
      initialLang: Lang.BG,
      fallbackOnError: "Невалидно число",
    );

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("нула"));
      expect(converter.convert(10), equals("десет"));
      expect(converter.convert(11), equals("единадесет"));
      expect(converter.convert(13), equals("тринадесет"));
      expect(converter.convert(15), equals("петнадесет"));
      expect(converter.convert(20), equals("двадесет"));
      expect(converter.convert(27), equals("двадесет и седем"));
      expect(converter.convert(30), equals("тридесет"));
      expect(converter.convert(54), equals("петдесет и четири"));
      expect(converter.convert(68), equals("шестдесет и осем"));
      expect(converter.convert(99), equals("деветдесет и девет"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("сто"));
      expect(converter.convert(101), equals("сто и едно"));
      expect(converter.convert(105), equals("сто и пет"));
      expect(converter.convert(110), equals("сто и десет"));
      expect(converter.convert(111), equals("сто и единадесет"));
      expect(converter.convert(123), equals("сто двадесет и три"));
      expect(converter.convert(200), equals("двеста"));
      expect(converter.convert(321), equals("триста двадесет и едно"));
      expect(converter.convert(479), equals("четиристотин седемдесет и девет"));
      expect(converter.convert(596), equals("петстотин деветдесет и шест"));
      expect(converter.convert(681), equals("шестстотин осемдесет и едно"));
      expect(converter.convert(999), equals("деветстотин деветдесет и девет"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("хиляда"));
      expect(converter.convert(1001), equals("хиляда и едно"));
      expect(converter.convert(1011), equals("хиляда и единадесет"));
      expect(converter.convert(1110), equals("хиляда сто и десет"));
      expect(converter.convert(1111), equals("хиляда сто и единадесет"));
      expect(converter.convert(2000), equals("две хиляди"));
      expect(converter.convert(2468),
          equals("две хиляди четиристотин шестдесет и осем"));
      expect(converter.convert(3579),
          equals("три хиляди петстотин седемдесет и девет"));
      expect(converter.convert(10000), equals("десет хиляди"));
      expect(converter.convert(10011), equals("десет хиляди и единадесет"));
      expect(converter.convert(11100), equals("единадесет хиляди и сто"));
      expect(converter.convert(12987),
          equals("дванадесет хиляди деветстотин осемдесет и седем"));
      expect(converter.convert(45623),
          equals("четиридесет и пет хиляди шестстотин двадесет и три"));
      expect(converter.convert(87654),
          equals("осемдесет и седем хиляди шестстотин петдесет и четири"));
      expect(converter.convert(100000), equals("сто хиляди"));
      expect(converter.convert(123456),
          equals("сто двадесет и три хиляди четиристотин петдесет и шест"));
      expect(
          converter.convert(987654),
          equals(
              "деветстотин осемдесет и седем хиляди шестстотин петдесет и четири"));
      expect(
          converter.convert(999999),
          equals(
              "деветстотин деветдесет и девет хиляди деветстотин деветдесет и девет"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("минус едно"));
      expect(converter.convert(-123), equals("минус сто двадесет и три"));
      expect(converter.convert(-123.456),
          equals("минус сто двадесет и три цяло и четири пет шест"));

      const negativeOptions = BgOptions(negativePrefix: "отрицателно");

      expect(converter.convert(-1, options: negativeOptions),
          equals("отрицателно едно"));
      expect(converter.convert(-123, options: negativeOptions),
          equals("отрицателно сто двадесет и три"));
      expect(converter.convert(-123.456, options: negativeOptions),
          equals("отрицателно сто двадесет и три цяло и четири пет шест"));
    });

    test('Decimals', () {
      const pointOption = BgOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = BgOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = BgOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(123.456),
          equals("сто двадесет и три цяло и четири пет шест"));
      expect(converter.convert(1.50), equals("едно цяло и пет"));
      expect(converter.convert(1.05), equals("едно цяло и нула пет"));
      expect(converter.convert(879.465),
          equals("осемстотин седемдесет и девет цяло и четири шест пет"));
      expect(converter.convert(1.5), equals("едно цяло и пет"));

      expect(converter.convert(1.5, options: pointOption),
          equals("едно точка пет"));
      expect(converter.convert(1.5, options: commaOption),
          equals("едно цяло и пет"));
      expect(converter.convert(1.5, options: periodOption),
          equals("едно точка пет"));
    });

    test('Year Formatting', () {
      const yearOption = BgOptions(format: Format.year);
      const yearOptionAD = BgOptions(format: Format.year, includeAD: true);

      expect(converter.convert(123, options: yearOption),
          equals("сто двадесет и три"));
      expect(converter.convert(498, options: yearOption),
          equals("четиристотин деветдесет и осем"));
      expect(converter.convert(756, options: yearOption),
          equals("седемстотин петдесет и шест"));
      expect(converter.convert(1900, options: yearOption),
          equals("хиляда и деветстотин"));
      expect(converter.convert(1999, options: yearOption),
          equals("хиляда деветстотин деветдесет и девет"));
      expect(converter.convert(2025, options: yearOption),
          equals("две хиляди и двадесет и пет"));

      expect(converter.convert(1900, options: yearOptionAD),
          equals("хиляда и деветстотин от новата ера"));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("хиляда деветстотин деветдесет и девет от новата ера"));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("две хиляди и двадесет и пет от новата ера"));

      expect(converter.convert(-1, options: yearOption),
          equals("едно преди новата ера"));
      expect(converter.convert(-100, options: yearOption),
          equals("сто преди новата ера"));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("сто преди новата ера"));
      expect(converter.convert(-2025, options: yearOption),
          equals("две хиляди и двадесет и пет преди новата ера"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("един милион преди новата ера"));
    });

    test('Currency', () {
      const currencyOption = BgOptions(currency: true);

      expect(
          converter.convert(0, options: currencyOption), equals("нула лева"));
      expect(converter.convert(1, options: currencyOption), equals("един лев"));
      expect(converter.convert(2, options: currencyOption), equals("два лева"));
      expect(converter.convert(5, options: currencyOption), equals("пет лева"));
      expect(
          converter.convert(10, options: currencyOption), equals("десет лева"));
      expect(converter.convert(11, options: currencyOption),
          equals("единадесет лева"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("един лев и петдесет стотинки"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("сто двадесет и три лева и четиридесет и пет стотинки"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("десет милиона лева"));
      expect(converter.convert(0.5), equals("нула цяло и пет"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("петдесет стотинки"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("една стотинка"));
      expect(converter.convert(0.02, options: currencyOption),
          equals("две стотинки"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("един лев и една стотинка"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("два лева и две стотинки"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("един милион"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("два милиарда"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("три трилиона"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("четири квадрилиона"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("пет квинтилиона"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("шест секстилиона"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("седем септилиона"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "девет квинтилиона осемстотин седемдесет и шест квадрилиона петстотин четиридесет и три трилиона двеста и десет милиарда сто двадесет и три милиона четиристотин петдесет и шест хиляди седемстотин осемдесет и девет"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "сто двадесет и три секстилиона четиристотин петдесет и шест квинтилиона седемстотин осемдесет и девет квадрилиона сто двадесет и три трилиона четиристотин петдесет и шест милиарда седемстотин осемдесет и девет милиона сто двадесет и три хиляди четиристотин петдесет и шест"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "деветстотин деветдесет и девет секстилиона деветстотин деветдесет и девет квинтилиона деветстотин деветдесет и девет квадрилиона деветстотин деветдесет и девет трилиона деветстотин деветдесет и девет милиарда деветстотин деветдесет и девет милиона деветстотин деветдесет и девет хиляди деветстотин деветдесет и девет"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("един трилион два милиона и три"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("пет милиона хиляда"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("един милиард и едно"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("един милиард един милион"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("два милиона хиляда"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "един трилион деветстотин осемдесет и седем милиона шестстотин хиляди и три"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Не е число"));
      expect(converter.convert(double.infinity), equals("Безкрайност"));
      expect(converter.convert(double.negativeInfinity),
          equals("Отрицателна безкрайност"));
      expect(converter.convert(null), equals("Не е число"));
      expect(converter.convert('abc'), equals("Не е число"));
      expect(converter.convert([]), equals("Не е число"));
      expect(converter.convert({}), equals("Не е число"));
      expect(converter.convert(Object()), equals("Не е число"));

      expect(
          converterWithFallback.convert(double.nan), equals("Невалидно число"));
      expect(converterWithFallback.convert(double.infinity),
          equals("Безкрайност"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Отрицателна безкрайност"));
      expect(converterWithFallback.convert(null), equals("Невалидно число"));
      expect(converterWithFallback.convert('abc'), equals("Невалидно число"));
      expect(converterWithFallback.convert([]), equals("Невалидно число"));
      expect(converterWithFallback.convert({}), equals("Невалидно число"));
      expect(
          converterWithFallback.convert(Object()), equals("Невалидно число"));
      expect(converterWithFallback.convert(123), equals("сто двадесет и три"));
    });
  });
}
