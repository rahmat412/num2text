import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Japanese (JA)', () {
    final converter = Num2Text(initialLang: Lang.JA);
    final converterWithFallback =
        Num2Text(initialLang: Lang.JA, fallbackOnError: "無効な数値");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("ゼロ"));
      expect(converter.convert(10), equals("十"));
      expect(converter.convert(11), equals("十一"));
      expect(converter.convert(13), equals("十三"));
      expect(converter.convert(15), equals("十五"));
      expect(converter.convert(20), equals("二十"));
      expect(converter.convert(27), equals("二十七"));
      expect(converter.convert(30), equals("三十"));
      expect(converter.convert(54), equals("五十四"));
      expect(converter.convert(68), equals("六十八"));
      expect(converter.convert(99), equals("九十九"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("百"));
      expect(converter.convert(101), equals("百一"));
      expect(converter.convert(105), equals("百五"));
      expect(converter.convert(110), equals("百十"));
      expect(converter.convert(111), equals("百十一"));
      expect(converter.convert(123), equals("百二十三"));
      expect(converter.convert(200), equals("二百"));
      expect(converter.convert(300), equals("三百"));
      expect(converter.convert(321), equals("三百二十一"));
      expect(converter.convert(479), equals("四百七十九"));
      expect(converter.convert(596), equals("五百九十六"));
      expect(converter.convert(600), equals("六百"));
      expect(converter.convert(681), equals("六百八十一"));
      expect(converter.convert(800), equals("八百"));
      expect(converter.convert(999), equals("九百九十九"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("千"));
      expect(converter.convert(1001), equals("千一"));
      expect(converter.convert(1011), equals("千十一"));
      expect(converter.convert(1110), equals("千百十"));
      expect(converter.convert(1111), equals("千百十一"));
      expect(converter.convert(2000), equals("二千"));
      expect(converter.convert(2468), equals("二千四百六十八"));
      expect(converter.convert(3000), equals("三千"));
      expect(converter.convert(3579), equals("三千五百七十九"));
      expect(converter.convert(8000), equals("八千"));
      expect(converter.convert(10000), equals("一万"));
      expect(converter.convert(10011), equals("一万十一"));
      expect(converter.convert(11100), equals("一万千百"));
      expect(converter.convert(12987), equals("一万二千九百八十七"));
      expect(converter.convert(45623), equals("四万五千六百二十三"));
      expect(converter.convert(87654), equals("八万七千六百五十四"));
      expect(converter.convert(100000), equals("十万"));
      expect(converter.convert(123456), equals("十二万三千四百五十六"));
      expect(converter.convert(987654), equals("九十八万七千六百五十四"));
      expect(converter.convert(999999), equals("九十九万九千九百九十九"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("マイナス一"));
      expect(converter.convert(-123), equals("マイナス百二十三"));
      expect(
          converter.convert(Decimal.parse("-123.456")), equals("マイナス百二十三点四五六"));
      const negativeOption = JaOptions(negativePrefix: "負");
      expect(converter.convert(-1, options: negativeOption), equals("負一"));
      expect(converter.convert(-123, options: negativeOption), equals("負百二十三"));
      expect(
          converter.convert(Decimal.parse("-123.456"), options: negativeOption),
          equals("負百二十三点四五六"));
    });

    test('Decimals', () {
      expect(converter.convert(Decimal.parse("123.456")), equals("百二十三点四五六"));
      expect(converter.convert(1.5), equals("一点五"));
      expect(converter.convert(1.05), equals("一点〇五"));
      expect(converter.convert(879.465), equals("八百七十九点四六五"));
      expect(converter.convert(1.5), equals("一点五"));
      const pointOption = JaOptions(decimalSeparator: DecimalSeparator.point);
      expect(converter.convert(1.5, options: pointOption), equals("一点五"));
      const commaOption = JaOptions(decimalSeparator: DecimalSeparator.comma);
      expect(converter.convert(1.5, options: commaOption), equals("一コンマ五"));
      const periodOption = JaOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(1.5, options: periodOption), equals("一点五"));
    });

    test('Year Formatting', () {
      const yearOption = JaOptions(format: Format.year);
      expect(converter.convert(123, options: yearOption), equals("百二十三年"));
      expect(converter.convert(498, options: yearOption), equals("四百九十八年"));
      expect(converter.convert(756, options: yearOption), equals("七百五十六年"));
      expect(converter.convert(1900, options: yearOption), equals("千九百年"));
      expect(converter.convert(1999, options: yearOption), equals("千九百九十九年"));
      expect(converter.convert(2025, options: yearOption), equals("二千二十五年"));
      const yearOptionAD = JaOptions(format: Format.year, includeAD: true);
      expect(converter.convert(1900, options: yearOptionAD), equals("西暦千九百年"));
      expect(
          converter.convert(1999, options: yearOptionAD), equals("西暦千九百九十九年"));
      expect(
          converter.convert(2025, options: yearOptionAD), equals("西暦二千二十五年"));
      expect(converter.convert(-1, options: yearOption), equals("紀元前一年"));
      expect(converter.convert(-100, options: yearOption), equals("紀元前百年"));
      expect(converter.convert(-100, options: yearOptionAD), equals("紀元前百年"));
      expect(
          converter.convert(-2025, options: yearOption), equals("紀元前二千二十五年"));
      expect(
          converter.convert(-1000000, options: yearOption), equals("紀元前百万年"));
    });
    test('Currency', () {
      const currencyOption = JaOptions(currency: true);
      expect(converter.convert(0, options: currencyOption), equals("ゼロ円"));
      expect(converter.convert(1, options: currencyOption), equals("一円"));
      expect(converter.convert(5, options: currencyOption), equals("五円"));
      expect(converter.convert(10, options: currencyOption), equals("十円"));
      expect(converter.convert(11, options: currencyOption), equals("十一円"));
      expect(converter.convert(1.5, options: currencyOption), equals("一円"));
      expect(
          converter.convert(123.45, options: currencyOption), equals("百二十三円"));
      expect(
          converter.convert(10000000, options: currencyOption), equals("千万円"));
      expect(converter.convert(0.01, options: currencyOption), equals("ゼロ円"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("百万"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(8)),
          equals("二億"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("三兆"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(16)),
          equals("四京"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(20)),
          equals("五垓"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(24)),
          equals("六秭"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(28)),
          equals("七穣"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals("九百八十七京六千五百四十三兆二千百一億二千三百四十五万六千七百八十九"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals("千二百三十四垓五千六百七十八京九千百二十三兆四千五百六十七億八千九百十二万三千四百五十六"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals("九千九百九十九垓九千九百九十九京九千九百九十九兆九千九百九十九億九千九百九十九万九千九百九十九"),
      );

      expect(
        converter.convert(BigInt.parse('1000002000003')),
        equals("一兆二百万三"),
      );
      expect(
        converter.convert(BigInt.parse('5001000')),
        equals("五百万千"),
      );
      expect(
        converter.convert(BigInt.parse('1000000001')),
        equals("十億一"),
      );
      expect(
        converter.convert(BigInt.parse('1001000000')),
        equals("十億百万"),
      );
      expect(
        converter.convert(BigInt.parse('2001000')),
        equals("二百万千"),
      );
      expect(
        converter.convert(BigInt.parse('1000987600003')),
        equals("一兆九億八千七百六十万三"),
      );
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("非数"));
      expect(converter.convert(double.infinity), equals("無限大"));
      expect(converter.convert(double.negativeInfinity), equals("負の無限大"));
      expect(converter.convert(null), equals("非数"));
      expect(converter.convert('abc'), equals("非数"));
      expect(converter.convert([]), equals("非数"));
      expect(converter.convert({}), equals("非数"));
      expect(converter.convert(Object()), equals("非数"));

      expect(converterWithFallback.convert(double.nan), equals("無効な数値"));
      expect(converterWithFallback.convert(double.infinity), equals("無限大"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("負の無限大"));
      expect(converterWithFallback.convert(null), equals("無効な数値"));
      expect(converterWithFallback.convert('abc'), equals("無効な数値"));
      expect(converterWithFallback.convert([]), equals("無効な数値"));
      expect(converterWithFallback.convert({}), equals("無効な数値"));
      expect(converterWithFallback.convert(Object()), equals("無効な数値"));
      expect(converterWithFallback.convert(123), equals("百二十三"));
    });
  });
}
