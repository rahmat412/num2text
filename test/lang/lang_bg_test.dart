import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Bulgarian (BG)', () {
    final converter = Num2Text(initialLang: Lang.BG);
    final converterWithFallback = Num2Text(
      initialLang: Lang.BG,
      fallbackOnError: "Невалидно число",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("нула"));
      expect(converter.convert(1), equals("едно"));
      expect(converter.convert(10), equals("десет"));
      expect(converter.convert(11), equals("единадесет"));
      expect(converter.convert(20), equals("двадесет"));
      expect(converter.convert(21), equals("двадесет и едно"));
      expect(converter.convert(99), equals("деветдесет и девет"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("сто"));
      expect(converter.convert(101), equals("сто и едно"));
      expect(converter.convert(111), equals("сто и единадесет"));
      expect(converter.convert(200), equals("двеста"));
      expect(converter.convert(300), equals("триста"));
      expect(converter.convert(999), equals("деветстотин деветдесет и девет"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("хиляда"));
      expect(converter.convert(1001), equals("хиляда и едно"));
      expect(converter.convert(1111), equals("хиляда сто и единадесет"));
      expect(converter.convert(2000), equals("две хиляди"));
      expect(converter.convert(10000), equals("десет хиляди"));
      expect(converter.convert(100000), equals("сто хиляди"));
      expect(
        converter.convert(123456),
        equals("сто двадесет и три хиляди четиристотин петдесет и шест"),
      );
      expect(
        converter.convert(999999),
        equals(
            "деветстотин деветдесет и девет хиляди деветстотин деветдесет и девет"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("минус едно"));
      expect(converter.convert(-123), equals("минус сто двадесет и три"));
      expect(
        converter.convert(-1,
            options: BgOptions(negativePrefix: "отрицателно")),
        equals("отрицателно едно"),
      );
      expect(
        converter.convert(-123,
            options: BgOptions(negativePrefix: "отрицателно")),
        equals("отрицателно сто двадесет и три"),
      );
    });

    test('Year Formatting', () {
      const yearOption = BgOptions(format: Format.year);

      expect(converter.convert(1900, options: yearOption),
          equals("хиляда и деветстотин"));

      expect(
        converter.convert(2024, options: yearOption),
        equals("две хиляди и двадесет и четири"),
      );

      expect(
        converter.convert(1900,
            options: BgOptions(format: Format.year, includeAD: true)),
        equals("хиляда и деветстотин от новата ера"),
      );

      expect(
        converter.convert(2024,
            options: BgOptions(format: Format.year, includeAD: true)),
        equals("две хиляди и двадесет и четири от новата ера"),
      );

      expect(converter.convert(-100, options: yearOption),
          equals("сто преди новата ера"));

      expect(converter.convert(-1, options: yearOption),
          equals("едно преди новата ера"));

      expect(
        converter.convert(-2024,
            options: BgOptions(format: Format.year, includeAD: true)),
        equals("две хиляди и двадесет и четири преди новата ера"),
      );
    });

    test('Currency', () {
      const currencyOption = BgOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("нула лева"));
      expect(converter.convert(1, options: currencyOption), equals("един лев"));
      expect(converter.convert(2, options: currencyOption), equals("два лева"));
      expect(converter.convert(5, options: currencyOption), equals("пет лева"));
      expect(
        converter.convert(1.50, options: currencyOption),
        equals("един лев и петдесет стотинки"),
      );
      expect(converter.convert(2.01, options: currencyOption),
          equals("два лева и една стотинка"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("сто двадесет и три лева и четиридесет и пет стотинки"),
      );
    });

    group('Decimals', () {
      test('Handles Decimals', () {
        expect(
          converter.convert(Decimal.parse('123.456')),
          equals("сто двадесет и три цяло и четири пет шест"),
        );
        expect(converter.convert(Decimal.parse('1.50')),
            equals("едно цяло и пет"));
        expect(converter.convert(Decimal.parse('1.05')),
            equals("едно цяло и нула пет"));
        expect(converter.convert(123.0), equals("сто двадесет и три"));
        expect(converter.convert(Decimal.parse('123.0')),
            equals("сто двадесет и три"));
        expect(
          converter.convert(
            1.5,
            options: const BgOptions(decimalSeparator: DecimalSeparator.comma),
          ),
          equals("едно цяло и пет"),
        );
        expect(
          converter.convert(
            1.5,
            options: const BgOptions(decimalSeparator: DecimalSeparator.period),
          ),
          equals("едно точка пет"),
        );
        expect(
          converter.convert(
            1.5,
            options: const BgOptions(decimalSeparator: DecimalSeparator.point),
          ),
          equals("едно точка пет"),
        );
      });
    });

    group('Handles infinity and invalid', () {
      test('Handles infinity and invalid input', () {
        expect(converter.convert(double.infinity), equals("Безкрайност"));
        expect(converter.convert(double.negativeInfinity),
            equals("Отрицателна безкрайност"));
        expect(converter.convert(double.nan), equals("Не е число"));
        expect(converter.convert(null), equals("Не е число"));
        expect(converter.convert('abc'), equals("Не е число"));

        expect(converterWithFallback.convert(double.infinity),
            equals("Безкрайност"));
        expect(
          converterWithFallback.convert(double.negativeInfinity),
          equals("Отрицателна безкрайност"),
        );
        expect(converterWithFallback.convert(double.nan),
            equals("Невалидно число"));
        expect(converterWithFallback.convert(null), equals("Невалидно число"));
        expect(converterWithFallback.convert('abc'), equals("Невалидно число"));
        expect(
            converterWithFallback.convert(123), equals("сто двадесет и три"));
      });
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("един милион"));
      expect(converter.convert(BigInt.from(2000000)), equals("два милиона"));
      expect(
          converter.convert(BigInt.from(1000000000)), equals("един милиард"));
      expect(
          converter.convert(BigInt.from(2000000000)), equals("два милиарда"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("един трилион"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("един квадрилион"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("един квинтилион"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("един секстилион"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("един септилион"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "сто двадесет и три секстилиона четиристотин петдесет и шест квинтилиона седемстотин осемдесет и девет квадрилиона сто двадесет и три трилиона четиристотин петдесет и шест милиарда седемстотин осемдесет и девет милиона сто двадесет и три хиляди четиристотин петдесет и шест",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "деветстотин деветдесет и девет секстилиона деветстотин деветдесет и девет квинтилиона деветстотин деветдесет и девет квадрилиона деветстотин деветдесет и девет трилиона деветстотин деветдесет и девет милиарда деветстотин деветдесет и девет милиона деветстотин деветдесет и девет хиляди деветстотин деветдесет и девет",
        ),
      );
    });
  });
}
