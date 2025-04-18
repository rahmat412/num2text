import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Ukrainian (UK)', () {
    final converter = Num2Text(initialLang: Lang.UK);
    final converterWithFallback =
        Num2Text(initialLang: Lang.UK, fallbackOnError: "Невірне число");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("нуль"));
      expect(converter.convert(1), equals("один"));
      expect(converter.convert(10), equals("десять"));
      expect(converter.convert(11), equals("одинадцять"));
      expect(converter.convert(20), equals("двадцять"));
      expect(converter.convert(21), equals("двадцять один"));
      expect(converter.convert(99), equals("дев'яносто дев'ять"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("сто"));
      expect(converter.convert(101), equals("сто один"));
      expect(converter.convert(111), equals("сто одинадцять"));
      expect(converter.convert(200), equals("двісті"));
      expect(converter.convert(999), equals("дев'ятсот дев'яносто дев'ять"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("одна тисяча"));
      expect(converter.convert(1001), equals("одна тисяча один"));
      expect(converter.convert(1111), equals("одна тисяча сто одинадцять"));
      expect(converter.convert(2000), equals("дві тисячі"));
      expect(converter.convert(10000), equals("десять тисяч"));
      expect(converter.convert(100000), equals("сто тисяч"));
      expect(
        converter.convert(123456),
        equals("сто двадцять три тисячі чотириста п'ятдесят шість"),
      );
      expect(
        converter.convert(999999),
        equals(
            "дев'ятсот дев'яносто дев'ять тисяч дев'ятсот дев'яносто дев'ять"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("мінус один"));
      expect(converter.convert(-123), equals("мінус сто двадцять три"));
      expect(
        converter.convert(-1, options: UkOptions(negativePrefix: "негативний")),
        equals("негативний один"),
      );
      expect(
        converter.convert(-123,
            options: UkOptions(negativePrefix: "негативний")),
        equals("негативний сто двадцять три"),
      );
    });

    test('Year Formatting', () {
      const yearOption = UkOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("тисяча дев'ятсот"));
      expect(converter.convert(2024, options: yearOption),
          equals("дві тисячі двадцять чотири"));
      expect(
        converter.convert(1900,
            options: UkOptions(format: Format.year, includeAD: true)),
        equals("тисяча дев'ятсот н.е."),
      );
      expect(
        converter.convert(2024,
            options: UkOptions(format: Format.year, includeAD: true)),
        equals("дві тисячі двадцять чотири н.е."),
      );
      expect(
          converter.convert(-100, options: yearOption), equals("сто до н.е."));
      expect(
          converter.convert(-1, options: yearOption), equals("один до н.е."));
      expect(
        converter.convert(-2024,
            options: UkOptions(format: Format.year, includeAD: true)),
        equals("дві тисячі двадцять чотири до н.е."),
      );
    });

    test('Currency', () {
      const currencyOption = UkOptions(currency: true);
      expect(converter.convert(1.01, options: currencyOption),
          equals("одна гривня одна копійка"));
      expect(
        converter.convert(2.50, options: currencyOption),
        equals("дві гривні п'ятдесят копійок"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("сто двадцять три гривні сорок п'ять копійок"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("сто двадцять три кома чотири п'ять шість"),
      );
      expect(
          converter.convert(Decimal.parse('1.50')), equals("одна кома п'ять"));
      expect(converter.convert(123.0), equals("сто двадцять три"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("сто двадцять три"));
      expect(
        converter.convert(1.5,
            options: const UkOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("одна кома п'ять"),
      );
      expect(
        converter.convert(1.5,
            options:
                const UkOptions(decimalSeparator: DecimalSeparator.period)),
        equals("одна крапка п'ять"),
      );
      expect(
        converter.convert(1.5,
            options: const UkOptions(decimalSeparator: DecimalSeparator.point)),
        equals("одна крапка п'ять"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Нескінченність"));
      expect(converter.convert(double.negativeInfinity),
          equals("Негативна нескінченність"));
      expect(converter.convert(double.nan), equals("Не число"));
      expect(converter.convert(null), equals("Не число"));
      expect(converter.convert('abc'), equals("Не число"));

      expect(converterWithFallback.convert(double.infinity),
          equals("Нескінченність"));
      expect(
        converterWithFallback.convert(double.negativeInfinity),
        equals("Негативна нескінченність"),
      );
      expect(
          converterWithFallback.convert(double.nan), equals("Невірне число"));
      expect(converterWithFallback.convert(null), equals("Невірне число"));
      expect(converterWithFallback.convert('abc'), equals("Невірне число"));
      expect(converterWithFallback.convert(123), equals("сто двадцять три"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("один мільйон"));
      expect(
          converter.convert(BigInt.from(1000000000)), equals("один мільярд"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("один трильйон"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("один квадрильйон"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("один квінтильйон"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("один секстильйон"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("один септильйон"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "сто двадцять три секстильйони чотириста п'ятдесят шість квінтильйонів сімсот вісімдесят дев'ять квадрильйонів сто двадцять три трильйони чотириста п'ятдесят шість мільярдів сімсот вісімдесят дев'ять мільйонів сто двадцять три тисячі чотириста п'ятдесят шість",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "дев'ятсот дев'яносто дев'ять секстильйонів дев'ятсот дев'яносто дев'ять квінтильйонів дев'ятсот дев'яносто дев'ять квадрильйонів дев'ятсот дев'яносто дев'ять трильйонів дев'ятсот дев'яносто дев'ять мільярдів дев'ятсот дев'яносто дев'ять мільйонів дев'ятсот дев'яносто дев'ять тисяч дев'ятсот дев'яносто дев'ять",
        ),
      );
    });
  });
}
