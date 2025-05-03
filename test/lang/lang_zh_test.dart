import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Chinese (ZH)', () {
    final converter = Num2Text(initialLang: Lang.ZH);
    final converterWithFallback =
        Num2Text(initialLang: Lang.ZH, fallbackOnError: "无效数字");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("零"));
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
      expect(converter.convert(100), equals("一百"));
      expect(converter.convert(101), equals("一百零一"));
      expect(converter.convert(105), equals("一百零五"));
      expect(converter.convert(110), equals("一百一十"));
      expect(converter.convert(111), equals("一百一十一"));
      expect(converter.convert(123), equals("一百二十三"));
      expect(converter.convert(200), equals("二百"));
      expect(converter.convert(321), equals("三百二十一"));
      expect(converter.convert(479), equals("四百七十九"));
      expect(converter.convert(596), equals("五百九十六"));
      expect(converter.convert(681), equals("六百八十一"));
      expect(converter.convert(999), equals("九百九十九"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("一千"));
      expect(converter.convert(1001), equals("一千零一"));
      expect(converter.convert(1011), equals("一千零十一"));
      expect(converter.convert(1110), equals("一千一百一十"));
      expect(converter.convert(1111), equals("一千一百一十一"));
      expect(converter.convert(2000), equals("两千"));
      expect(converter.convert(2468), equals("两千四百六十八"));
      expect(converter.convert(3579), equals("三千五百七十九"));
      expect(converter.convert(10000), equals("一万"));
      expect(converter.convert(10011), equals("一万零十一"));
      expect(converter.convert(11100), equals("一万一千一百"));
      expect(converter.convert(12987), equals("一万两千九百八十七"));
      expect(converter.convert(45623), equals("四万五千六百二十三"));
      expect(converter.convert(87654), equals("八万七千六百五十四"));
      expect(converter.convert(100000), equals("十万"));
      expect(converter.convert(123456), equals("十二万三千四百五十六"));
      expect(converter.convert(987654), equals("九十八万七千六百五十四"));
      expect(converter.convert(999999), equals("九十九万九千九百九十九"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("负一"));
      expect(converter.convert(-123), equals("负一百二十三"));
      expect(converter.convert(-123.456), equals("负一百二十三点四五六"));

      const negativeOption = ZhOptions(negativePrefix: "负数");
      expect(converter.convert(-1, options: negativeOption), equals("负数一"));
      expect(
          converter.convert(-123, options: negativeOption), equals("负数一百二十三"));
      expect(converter.convert(-123.456, options: negativeOption),
          equals("负数一百二十三点四五六"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456), equals("一百二十三点四五六"));
      expect(converter.convert(1.50), equals("一点五"));
      expect(converter.convert(1.05), equals("一点零五"));
      expect(converter.convert(879.465), equals("八百七十九点四六五"));
      expect(converter.convert(1.5), equals("一点五"));

      const pointOption = ZhOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = ZhOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = ZhOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(1.5, options: pointOption), equals("一点五"));
      expect(converter.convert(1.5, options: commaOption), equals("一逗号五"));
      expect(converter.convert(1.5, options: periodOption), equals("一点五"));
    });

    test('Year Formatting', () {
      const yearOption = ZhOptions(format: Format.year);
      expect(converter.convert(123, options: yearOption), equals("一二三"));
      expect(converter.convert(498, options: yearOption), equals("四九八"));
      expect(converter.convert(756, options: yearOption), equals("七五六"));
      expect(converter.convert(1900, options: yearOption), equals("一九零零"));
      expect(converter.convert(1999, options: yearOption), equals("一九九九"));
      expect(converter.convert(2025, options: yearOption), equals("二零二五"));

      const yearOptionAD = ZhOptions(format: Format.year, includeAD: true);
      expect(converter.convert(1900, options: yearOptionAD), equals("公元一九零零"));
      expect(converter.convert(1999, options: yearOptionAD), equals("公元一九九九"));
      expect(converter.convert(2025, options: yearOptionAD), equals("公元二零二五"));

      expect(converter.convert(-1, options: yearOption), equals("公元前一"));
      expect(converter.convert(-100, options: yearOption), equals("公元前一零零"));
      expect(converter.convert(-100, options: yearOptionAD), equals("公元前一零零"));
      expect(converter.convert(-2025, options: yearOption), equals("公元前二零二五"));
      expect(
          converter.convert(-1000000, options: yearOption), equals("公元前一百万"));
    });

    test('Currency', () {
      const currencyOption = ZhOptions(currency: true);
      expect(converter.convert(0, options: currencyOption), equals("零元整"));
      expect(converter.convert(1, options: currencyOption), equals("一元整"));
      expect(converter.convert(5, options: currencyOption), equals("五元整"));
      expect(converter.convert(10, options: currencyOption), equals("十元整"));
      expect(converter.convert(11, options: currencyOption), equals("十一元整"));
      expect(converter.convert(1.50, options: currencyOption), equals("一元五角"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("一百二十三元四角五分"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("一千万元整"));
      expect(converter.convert(0.5, options: currencyOption), equals("五角"));
      expect(converter.convert(0.01, options: currencyOption), equals("一分"));
      expect(converter.convert(0.10, options: currencyOption), equals("一角"));
      expect(converter.convert(0.11, options: currencyOption), equals("一角一分"));
      expect(converter.convert(1.01, options: currencyOption), equals("一元零一分"));
      expect(converter.convert(1.10, options: currencyOption), equals("一元一角"));
      expect(converter.convert(2.05, options: currencyOption), equals("两元零五分"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("一百万"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(8)),
          equals("两亿"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("三万亿"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(16)),
          equals("四亿亿"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(20)),
          equals("五万亿亿"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(24)),
          equals("六亿亿亿"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("一万亿零二百万零三"));
      expect(converter.convert(BigInt.parse('5001000')), equals("五百万零一千"));
      expect(converter.convert(BigInt.parse('1000000001')), equals("十亿零一"));
      expect(converter.convert(BigInt.parse('1001000000')), equals("十亿零一百万"));
      expect(converter.convert(BigInt.parse('2001000')), equals("二百万零一千"));
      expect(converter.convert(BigInt.parse('1000987600003')),
          equals("一万亿零九亿八千七百六十万零三"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals('九百八十七亿亿六千五百四十三万亿两千一百零一亿两千三百四十五万六千七百八十九'),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals("一千二百三十四万亿亿五千六百七十八亿亿九千一百二十三万亿四千五百六十七亿八千九百一十二万三千四百五十六"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals("九千九百九十九万亿亿九千九百九十九亿亿九千九百九十九万亿九千九百九十九亿九千九百九十九万九千九百九十九"),
      );
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("不是一个数字"));
      expect(converter.convert(double.infinity), equals("无穷大"));
      expect(converter.convert(double.negativeInfinity), equals("负无穷大"));
      expect(converter.convert(null), equals("不是一个数字"));
      expect(converter.convert('abc'), equals("不是一个数字"));
      expect(converter.convert([]), equals("不是一个数字"));
      expect(converter.convert({}), equals("不是一个数字"));
      expect(converter.convert(Object()), equals("不是一个数字"));

      expect(converterWithFallback.convert(double.nan), equals("无效数字"));
      expect(converterWithFallback.convert(double.infinity), equals("无穷大"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("负无穷大"));
      expect(converterWithFallback.convert(null), equals("无效数字"));
      expect(converterWithFallback.convert('abc'), equals("无效数字"));
      expect(converterWithFallback.convert([]), equals("无效数字"));
      expect(converterWithFallback.convert({}), equals("无效数字"));
      expect(converterWithFallback.convert(Object()), equals("无效数字"));
      expect(converterWithFallback.convert(123), equals("一百二十三"));
    });
  });
}
