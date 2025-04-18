import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Japanese (JA)', () {
    final converter = Num2Text(initialLang: Lang.JA);
    final converterWithFallback =
        Num2Text(initialLang: Lang.JA, fallbackOnError: "無効な数値");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("ゼロ"));
      expect(converter.convert(1), equals("一"));
      expect(converter.convert(10), equals("十"));
      expect(converter.convert(11), equals("十一"));
      expect(converter.convert(20), equals("二十"));
      expect(converter.convert(21), equals("二十一"));
      expect(converter.convert(99), equals("九十九"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("百"));
      expect(converter.convert(101), equals("百一"));
      expect(converter.convert(111), equals("百十一"));
      expect(converter.convert(200), equals("二百"));
      expect(converter.convert(300), equals("三百"));
      expect(converter.convert(600), equals("六百"));
      expect(converter.convert(800), equals("八百"));
      expect(converter.convert(999), equals("九百九十九"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("千"));
      expect(converter.convert(1001), equals("千一"));
      expect(converter.convert(1111), equals("千百十一"));
      expect(converter.convert(2000), equals("二千"));
      expect(converter.convert(3000), equals("三千"));
      expect(converter.convert(8000), equals("八千"));
      expect(converter.convert(10000), equals("一万"));
      expect(converter.convert(100000), equals("十万"));
      expect(converter.convert(123456), equals("十二万三千四百五十六"));
      expect(converter.convert(999999), equals("九十九万九千九百九十九"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("マイナス一"));
      expect(converter.convert(-123), equals("マイナス百二十三"));
      expect(converter.convert(-1, options: JaOptions(negativePrefix: "負の")),
          equals("負の一"));
      expect(converter.convert(-123, options: JaOptions(negativePrefix: "負の")),
          equals("負の百二十三"));
    });

    test('Year Formatting', () {
      const yearOption = JaOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption), equals("千九百年"));
      expect(converter.convert(2024, options: yearOption), equals("二千二十四年"));
      expect(
        converter.convert(1900,
            options: JaOptions(format: Format.year, includeAD: true)),
        equals("西暦千九百年"),
      );
      expect(
        converter.convert(2024,
            options: JaOptions(format: Format.year, includeAD: true)),
        equals("西暦二千二十四年"),
      );
      expect(converter.convert(-100, options: yearOption), equals("紀元前百年"));
      expect(converter.convert(-1, options: yearOption), equals("紀元前一年"));
      expect(
        converter.convert(-2024,
            options: JaOptions(format: Format.year, includeAD: true)),
        equals("紀元前二千二十四年"),
      );
    });
    test('Currency', () {
      const currencyOption = JaOptions(currency: true);
      expect(converter.convert(0, options: currencyOption), equals("ゼロ円"));
      expect(converter.convert(1, options: currencyOption), equals("一円"));
      expect(converter.convert(1.50, options: currencyOption), equals("一円"));
      expect(
          converter.convert(123.45, options: currencyOption), equals("百二十三円"));
      expect(converter.convert(10000, options: currencyOption), equals("一万円"));
    });

    test('Decimals', () {
      expect(converter.convert(Decimal.parse('123.456')), equals("百二十三点四五六"));
      expect(converter.convert(Decimal.parse('1.50')), equals("一点五"));
      expect(converter.convert(123.0), equals("百二十三"));
      expect(converter.convert(Decimal.parse('123.0')), equals("百二十三"));

      expect(
        converter.convert(1.5,
            options: const JaOptions(decimalSeparator: DecimalSeparator.point)),
        equals("一点五"),
      );
      expect(
        converter.convert(1.5,
            options:
                const JaOptions(decimalSeparator: DecimalSeparator.period)),
        equals("一点五"),
      );

      expect(
        converter.convert(1.5,
            options: const JaOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("一コンマ五"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("無限大"));
      expect(converter.convert(double.negativeInfinity), equals("負の無限大"));
      expect(converter.convert(double.nan), equals("非数"));
      expect(converter.convert(null), equals("非数"));
      expect(converter.convert('abc'), equals("非数"));

      expect(converterWithFallback.convert(double.infinity), equals("無限大"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("負の無限大"));
      expect(converterWithFallback.convert(double.nan), equals("無効な数値"));
      expect(converterWithFallback.convert(null), equals("無効な数値"));
      expect(converterWithFallback.convert('abc'), equals("無効な数値"));
      expect(converterWithFallback.convert(123), equals("百二十三"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("百万"));
      expect(converter.convert(BigInt.from(100000000)), equals("一億"));
      expect(converter.convert(BigInt.from(1000000000)), equals("十億"));
      expect(converter.convert(BigInt.from(1000000000000)), equals("一兆"));
      expect(converter.convert(BigInt.parse('1000000000000000')), equals("千兆"));
      expect(
          converter.convert(BigInt.parse('10000000000000000')), equals("一京"));
      expect(
          converter.convert(BigInt.parse('1000000000000000000')), equals("百京"));
      expect(converter.convert(BigInt.parse('10000000000000000000')),
          equals("千京"));
      expect(converter.convert(BigInt.parse('100000000000000000000')),
          equals("一垓"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("十垓"));
      expect(converter.convert(BigInt.parse('1000000000000000000000000')),
          equals("一秭"));

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals("千二百三十四垓五千六百七十八京九千百二十三兆四千五百六十七億八千九百十二万三千四百五十六"),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals("九千九百九十九垓九千九百九十九京九千九百九十九兆九千九百九十九億九千九百九十九万九千九百九十九"),
      );
    });
  });
}
