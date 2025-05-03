import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Russian (RU)', () {
    final converter = Num2Text(initialLang: Lang.RU);
    final converterWithFallback = Num2Text(
      initialLang: Lang.RU,
      fallbackOnError: "Недопустимое число",
    );

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("ноль"));
      expect(converter.convert(10), equals("десять"));
      expect(converter.convert(11), equals("одиннадцать"));
      expect(converter.convert(13), equals("тринадцать"));
      expect(converter.convert(15), equals("пятнадцать"));
      expect(converter.convert(20), equals("двадцать"));
      expect(converter.convert(27), equals("двадцать семь"));
      expect(converter.convert(30), equals("тридцать"));
      expect(converter.convert(54), equals("пятьдесят четыре"));
      expect(converter.convert(68), equals("шестьдесят восемь"));
      expect(converter.convert(99), equals("девяносто девять"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("сто"));
      expect(converter.convert(101), equals("сто один"));
      expect(converter.convert(105), equals("сто пять"));
      expect(converter.convert(110), equals("сто десять"));
      expect(converter.convert(111), equals("сто одиннадцать"));
      expect(converter.convert(123), equals("сто двадцать три"));
      expect(converter.convert(200), equals("двести"));
      expect(converter.convert(321), equals("триста двадцать один"));
      expect(converter.convert(479), equals("четыреста семьдесят девять"));
      expect(converter.convert(596), equals("пятьсот девяносто шесть"));
      expect(converter.convert(681), equals("шестьсот восемьдесят один"));
      expect(converter.convert(999), equals("девятьсот девяносто девять"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("одна тысяча"));
      expect(converter.convert(1001), equals("одна тысяча один"));
      expect(converter.convert(1011), equals("одна тысяча одиннадцать"));
      expect(converter.convert(1110), equals("одна тысяча сто десять"));
      expect(converter.convert(1111), equals("одна тысяча сто одиннадцать"));
      expect(converter.convert(2000), equals("две тысячи"));
      expect(converter.convert(2468),
          equals("две тысячи четыреста шестьдесят восемь"));
      expect(converter.convert(3579),
          equals("три тысячи пятьсот семьдесят девять"));
      expect(converter.convert(10000), equals("десять тысяч"));
      expect(converter.convert(10011), equals("десять тысяч одиннадцать"));
      expect(converter.convert(11100), equals("одиннадцать тысяч сто"));
      expect(converter.convert(12987),
          equals("двенадцать тысяч девятьсот восемьдесят семь"));
      expect(converter.convert(45623),
          equals("сорок пять тысяч шестьсот двадцать три"));
      expect(converter.convert(87654),
          equals("восемьдесят семь тысяч шестьсот пятьдесят четыре"));
      expect(converter.convert(100000), equals("сто тысяч"));
      expect(converter.convert(123456),
          equals("сто двадцать три тысячи четыреста пятьдесят шесть"));
      expect(converter.convert(987654),
          equals("девятьсот восемьдесят семь тысяч шестьсот пятьдесят четыре"));
      expect(
          converter.convert(999999),
          equals(
              "девятьсот девяносто девять тысяч девятьсот девяносто девять"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("минус один"));
      expect(converter.convert(-123), equals("минус сто двадцать три"));
      expect(converter.convert(-123.456),
          equals("минус сто двадцать три запятая четыре пять шесть"));
      const options = RuOptions(negativePrefix: "отрицательный");
      expect(converter.convert(-1, options: options),
          equals("отрицательный один"));
      expect(converter.convert(-123, options: options),
          equals("отрицательный сто двадцать три"));
      expect(
        converter.convert(-123.456, options: options),
        equals("отрицательный сто двадцать три запятая четыре пять шесть"),
      );
    });

    test('Decimals', () {
      expect(converter.convert(123.456),
          equals("сто двадцать три запятая четыре пять шесть"));
      expect(converter.convert(1.5), equals("один запятая пять"));
      expect(converter.convert(1.05), equals("один запятая ноль пять"));
      expect(converter.convert(879.465),
          equals("восемьсот семьдесят девять запятая четыре шесть пять"));
      expect(converter.convert(1.5), equals("один запятая пять"));
      const pointOption = RuOptions(decimalSeparator: DecimalSeparator.point);
      expect(converter.convert(1.5, options: pointOption),
          equals("один точка пять"));
      const commaOption = RuOptions(decimalSeparator: DecimalSeparator.comma);
      expect(converter.convert(1.5, options: commaOption),
          equals("один запятая пять"));
      const periodOption = RuOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(1.5, options: periodOption),
          equals("один точка пять"));
    });

    test('Year Formatting', () {
      const yearOption = RuOptions(format: Format.year);
      expect(converter.convert(123, options: yearOption),
          equals("сто двадцать третий"));
      expect(converter.convert(498, options: yearOption),
          equals("четыреста девяносто восьмой"));
      expect(converter.convert(756, options: yearOption),
          equals("семьсот пятьдесят шестой"));
      expect(converter.convert(1900, options: yearOption),
          equals("тысяча девятисотый"));
      expect(converter.convert(1999, options: yearOption),
          equals("тысяча девятьсот девяносто девятый"));
      expect(converter.convert(2025, options: yearOption),
          equals("две тысячи двадцать пятый"));
      const yearOptionAD = RuOptions(format: Format.year, includeAD: true);
      expect(converter.convert(1900, options: yearOptionAD),
          equals("тысяча девятисотый н. э."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("тысяча девятьсот девяносто девятый н. э."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("две тысячи двадцать пятый н. э."));
      expect(converter.convert(-1, options: yearOption),
          equals("первый до н. э."));
      expect(converter.convert(-100, options: yearOption),
          equals("сотый до н. э."));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("сотый до н. э."));
      expect(converter.convert(-2025, options: yearOption),
          equals("две тысячи двадцать пятый до н. э."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("миллионный до н. э."));
    });

    test('Currency', () {
      const currencyOption = RuOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("ноль рублей ноль копеек"));
      expect(
          converter.convert(1, options: currencyOption), equals("один рубль"));
      expect(
          converter.convert(2, options: currencyOption), equals("два рубля"));
      expect(
          converter.convert(3, options: currencyOption), equals("три рубля"));
      expect(converter.convert(4, options: currencyOption),
          equals("четыре рубля"));
      expect(
          converter.convert(5, options: currencyOption), equals("пять рублей"));
      expect(converter.convert(10, options: currencyOption),
          equals("десять рублей"));
      expect(converter.convert(11, options: currencyOption),
          equals("одиннадцать рублей"));
      expect(converter.convert(21, options: currencyOption),
          equals("двадцать один рубль"));
      expect(converter.convert(22, options: currencyOption),
          equals("двадцать два рубля"));
      expect(converter.convert(25, options: currencyOption),
          equals("двадцать пять рублей"));
      expect(converter.convert(100, options: currencyOption),
          equals("сто рублей"));
      expect(converter.convert(101, options: currencyOption),
          equals("сто один рубль"));
      expect(converter.convert(102, options: currencyOption),
          equals("сто два рубля"));
      expect(converter.convert(105, options: currencyOption),
          equals("сто пять рублей"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("один рубль пятьдесят копеек"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("сто двадцать три рубля сорок пять копеек"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("десять миллионов рублей"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("пятьдесят копеек"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("одна копейка"));
      expect(converter.convert(0.02, options: currencyOption),
          equals("две копейки"));
      expect(converter.convert(0.03, options: currencyOption),
          equals("три копейки"));
      expect(converter.convert(0.04, options: currencyOption),
          equals("четыре копейки"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("пять копеек"));
      expect(converter.convert(0.11, options: currencyOption),
          equals("одиннадцать копеек"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("один рубль одна копейка"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("два рубля две копейки"));
      expect(converter.convert(5.05, options: currencyOption),
          equals("пять рублей пять копеек"));
      expect(converter.convert(21.01, options: currencyOption),
          equals("двадцать один рубль одна копейка"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("один миллион"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("два миллиарда"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("три триллиона"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("четыре квадриллиона"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("пять квинтиллионов"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("шесть секстиллионов"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("семь септиллионов"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            "девять квинтиллионов восемьсот семьдесят шесть квадриллионов пятьсот сорок три триллиона двести десять миллиардов сто двадцать три миллиона четыреста пятьдесят шесть тысяч семьсот восемьдесят девять"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "сто двадцать три секстиллиона четыреста пятьдесят шесть квинтиллионов семьсот восемьдесят девять квадриллионов сто двадцать три триллиона четыреста пятьдесят шесть миллиардов семьсот восемьдесят девять миллионов сто двадцать три тысячи четыреста пятьдесят шесть"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "девятьсот девяносто девять секстиллионов девятьсот девяносто девять квинтиллионов девятьсот девяносто девять квадриллионов девятьсот девяносто девять триллионов девятьсот девяносто девять миллиардов девятьсот девяносто девять миллионов девятьсот девяносто девять тысяч девятьсот девяносто девять"),
      );

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("один триллион два миллиона три"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("пять миллионов одна тысяча"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("один миллиард один"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("один миллиард один миллион"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("два миллиона одна тысяча"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "один триллион девятьсот восемьдесят семь миллионов шестьсот тысяч три"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Не Число"));
      expect(converter.convert(double.infinity), equals("Бесконечность"));
      expect(converter.convert(double.negativeInfinity),
          equals("Минус бесконечность"));
      expect(converter.convert(null), equals("Не Число"));
      expect(converter.convert('abc'), equals("Не Число"));
      expect(converter.convert([]), equals("Не Число"));
      expect(converter.convert({}), equals("Не Число"));
      expect(converter.convert(Object()), equals("Не Число"));

      expect(converterWithFallback.convert(double.nan),
          equals("Недопустимое число"));
      expect(converterWithFallback.convert(double.infinity),
          equals("Бесконечность"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Минус бесконечность"));
      expect(converterWithFallback.convert(null), equals("Недопустимое число"));
      expect(
          converterWithFallback.convert('abc'), equals("Недопустимое число"));
      expect(converterWithFallback.convert([]), equals("Недопустимое число"));
      expect(converterWithFallback.convert({}), equals("Недопустимое число"));
      expect(converterWithFallback.convert(Object()),
          equals("Недопустимое число"));
      expect(converterWithFallback.convert(123), equals("сто двадцать три"));
    });
  });
}
