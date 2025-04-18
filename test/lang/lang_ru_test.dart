import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Russian (RU)', () {
    final converter = Num2Text(initialLang: Lang.RU);
    final converterWithFallback = Num2Text(
      initialLang: Lang.RU,
      fallbackOnError: "Недопустимое число",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("ноль"));
      expect(converter.convert(1), equals("один"));
      expect(converter.convert(2), equals("два"));

      expect(converter.convert(10), equals("десять"));
      expect(converter.convert(11), equals("одиннадцать"));
      expect(converter.convert(20), equals("двадцать"));
      expect(converter.convert(21), equals("двадцать один"));
      expect(converter.convert(99), equals("девяносто девять"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("сто"));
      expect(converter.convert(101), equals("сто один"));
      expect(converter.convert(111), equals("сто одиннадцать"));
      expect(converter.convert(200), equals("двести"));
      expect(converter.convert(999), equals("девятьсот девяносто девять"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("одна тысяча"));
      expect(converter.convert(1001), equals("одна тысяча один"));
      expect(converter.convert(1111), equals("одна тысяча сто одиннадцать"));
      expect(converter.convert(2000), equals("две тысячи"));
      expect(converter.convert(5000), equals("пять тысяч"));
      expect(converter.convert(10000), equals("десять тысяч"));
      expect(converter.convert(100000), equals("сто тысяч"));
      expect(converter.convert(121000), equals("сто двадцать одна тысяча"));
      expect(converter.convert(122000), equals("сто двадцать две тысячи"));
      expect(converter.convert(125000), equals("сто двадцать пять тысяч"));
      expect(
        converter.convert(123456),
        equals("сто двадцать три тысячи четыреста пятьдесят шесть"),
      );
      expect(
        converter.convert(999999),
        equals("девятьсот девяносто девять тысяч девятьсот девяносто девять"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("минус один"));
      expect(converter.convert(-123), equals("минус сто двадцать три"));
    });

    test('Year Formatting', () {
      const yearOption = RuOptions(format: Format.year);
      const yearOptionAD = RuOptions(format: Format.year, includeAD: true);
      expect(converter.convert(1900, options: yearOption),
          equals("тысяча девятисотый"));
      expect(converter.convert(2024, options: yearOption),
          equals("две тысячи двадцать четвёртый"));
      expect(
        converter.convert(2024, options: yearOptionAD),
        equals("две тысячи двадцать четвёртый н. э."),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("сотый до н. э."));
      expect(converter.convert(-1, options: yearOption),
          equals("первый до н. э."));
      expect(
        converter.convert(-2024, options: yearOption),
        equals("две тысячи двадцать четвёртый до н. э."),
      );
    });

    test('Currency (RUB)', () {
      const currencyOption = RuOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("ноль рублей ноль копеек"));
      expect(
          converter.convert(1, options: currencyOption), equals("один рубль"));
      expect(
          converter.convert(2, options: currencyOption), equals("два рубля"));
      expect(
          converter.convert(5, options: currencyOption), equals("пять рублей"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("одна копейка"));
      expect(converter.convert(0.02, options: currencyOption),
          equals("две копейки"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("пять копеек"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("один рубль одна копейка"));
      expect(
        converter.convert(2.50, options: currencyOption),
        equals("два рубля пятьдесят копеек"),
      );
      expect(
        converter.convert(5.22, options: currencyOption),
        equals("пять рублей двадцать две копейки"),
      );
      expect(
        converter.convert(21.05, options: currencyOption),
        equals("двадцать один рубль пять копеек"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("сто двадцать три рубля сорок пять копеек"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("сто двадцать три запятая четыре пять шесть"),
      );

      expect(converter.convert(Decimal.parse('1.50')),
          equals("один запятая пять"));

      expect(converter.convert(123.0), equals("сто двадцать три"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("сто двадцать три"));

      expect(
        converter.convert(1.5,
            options: const RuOptions(decimalSeparator: DecimalSeparator.point)),
        equals("один точка пять"),
      );

      expect(
        converter.convert(1.5,
            options:
                const RuOptions(decimalSeparator: DecimalSeparator.period)),
        equals("один точка пять"),
      );

      expect(
        converter.convert(1.5,
            options: const RuOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("один запятая пять"),
      );

      expect(converter.convert(1.5), equals("один запятая пять"));
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Бесконечность"));
      expect(converter.convert(double.negativeInfinity),
          equals("Минус бесконечность"));
      expect(converter.convert(double.nan), equals("Не число"));
      expect(converter.convert(null), equals("Не число"));
      expect(converter.convert('abc'), equals("Не число"));

      expect(converterWithFallback.convert(double.infinity),
          equals("Бесконечность"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Минус бесконечность"));
      expect(converterWithFallback.convert(double.nan),
          equals("Недопустимое число"));
      expect(converterWithFallback.convert(null), equals("Недопустимое число"));
      expect(
          converterWithFallback.convert('abc'), equals("Недопустимое число"));
      expect(converterWithFallback.convert(123), equals("сто двадцать три"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("один миллион"));
      expect(converter.convert(BigInt.from(2000000)), equals("два миллиона"));
      expect(converter.convert(BigInt.from(5000000)), equals("пять миллионов"));
      expect(
          converter.convert(BigInt.from(1000000000)), equals("один миллиард"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("один триллион"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("один квадриллион"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("один квинтиллион"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("один секстиллион"));

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "сто двадцать три секстиллиона четыреста пятьдесят шесть квинтиллионов семьсот восемьдесят девять квадриллионов сто двадцать три триллиона четыреста пятьдесят шесть миллиардов семьсот восемьдесят девять миллионов сто двадцать три тысячи четыреста пятьдесят шесть",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "девятьсот девяносто девять секстиллионов девятьсот девяносто девять квинтиллионов девятьсот девяносто девять квадриллионов девятьсот девяносто девять триллионов девятьсот девяносто девять миллиардов девятьсот девяносто девять миллионов девятьсот девяносто девять тысяч девятьсот девяносто девять",
        ),
      );
    });
  });
}
