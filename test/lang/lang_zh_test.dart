import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Chinese (ZH)', () {
    final converter = Num2Text(initialLang: Lang.ZH);
    final converterWithFallback =
        Num2Text(initialLang: Lang.ZH, fallbackOnError: "无效数字");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("零"));
      expect(converter.convert(1), equals("一"));
      expect(converter.convert(10), equals("十"));
      expect(converter.convert(11), equals("十一"));
      expect(converter.convert(20), equals("二十"));
      expect(converter.convert(21), equals("二十一"));
      expect(converter.convert(99), equals("九十九"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("一百"));
      expect(converter.convert(101), equals("一百零一"));
      expect(converter.convert(111), equals("一百一十一"));
      expect(converter.convert(200), equals("二百"));
      expect(converter.convert(999), equals("九百九十九"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("一千"));
      expect(converter.convert(1001), equals("一千零一"));
      expect(converter.convert(1111), equals("一千一百一十一"));
      expect(converter.convert(2000), equals("二千"));
      expect(converter.convert(10000), equals("一万"));
      expect(converter.convert(100000), equals("十万"));
      expect(converter.convert(123456), equals("十二万三千四百五十六"));
      expect(converter.convert(999999), equals("九十九万九千九百九十九"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("负一"));
      expect(converter.convert(-123), equals("负一百二十三"));
      expect(converter.convert(-1, options: ZhOptions(negativePrefix: "负数")),
          equals("负数一"));
      expect(converter.convert(-123, options: ZhOptions(negativePrefix: "负数")),
          equals("负数一百二十三"));
    });

    test('Year Formatting', () {
      const yearOption = ZhOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption), equals("一九零零"));
      expect(converter.convert(2024, options: yearOption), equals("二零二四"));
      expect(converter.convert(1900, options: ZhOptions(format: Format.year)),
          equals("一九零零"));
      expect(converter.convert(2024, options: ZhOptions(format: Format.year)),
          equals("二零二四"));
      expect(converter.convert(-100, options: yearOption), equals("负一零零"));
      expect(converter.convert(-1, options: yearOption), equals("负一"));
      expect(converter.convert(-2024, options: ZhOptions(format: Format.year)),
          equals("负二零二四"));
    });

    test('Currency', () {
      const currencyOption = ZhOptions(currency: true);
      expect(converter.convert(1.01, options: currencyOption), equals("一元零一分"));
      expect(converter.convert(2.50, options: currencyOption), equals("二元五角"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("一百二十三元四角五分"));
      expect(converter.convert(0.10, options: currencyOption), equals("一角"));
      expect(converter.convert(0.01, options: currencyOption), equals("一分"));
      expect(converter.convert(123.00, options: currencyOption),
          equals("一百二十三元整"));
    });

    test('Decimals', () {
      expect(converter.convert(Decimal.parse('123.456')), equals("一百二十三点四五六"));
      expect(converter.convert(Decimal.parse('1.50')), equals("一点五"));
      expect(converter.convert(123.0), equals("一百二十三"));
      expect(converter.convert(Decimal.parse('123.0')), equals("一百二十三"));
      expect(
        converter.convert(1.5,
            options: const ZhOptions(decimalSeparator: DecimalSeparator.point)),
        equals("一点五"),
      );
      expect(
        converter.convert(1.5,
            options: const ZhOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("一逗号五"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("无穷大"));
      expect(converter.convert(double.negativeInfinity), equals("负无穷大"));
      expect(converter.convert(double.nan), equals("不是一个数字"));
      expect(converter.convert(null), equals("不是一个数字"));
      expect(converter.convert('abc'), equals("不是一个数字"));

      expect(converterWithFallback.convert(double.infinity), equals("无穷大"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("负无穷大"));
      expect(converterWithFallback.convert(double.nan), equals("无效数字"));
      expect(converterWithFallback.convert(null), equals("无效数字"));
      expect(converterWithFallback.convert('abc'), equals("无效数字"));
      expect(converterWithFallback.convert(123), equals("一百二十三"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("一百万"));
      expect(converter.convert(BigInt.from(100000000)), equals("一亿"));
      expect(converter.convert(BigInt.from(1000000000)), equals("十亿"));
      expect(converter.convert(BigInt.from(1000000000000)), equals("一万亿"));
      expect(converter.convert(BigInt.from(10000000000000)), equals("十万亿"));
      expect(converter.convert(BigInt.from(100000000000000)), equals("一百万亿"));
      expect(converter.convert(BigInt.from(1000000000000000)), equals("一千万亿"));
      expect(converter.convert(BigInt.from(10000000000000000)), equals("一亿亿"));
      expect(converter.convert(BigInt.from(100000000000000000)), equals("十亿亿"));
      expect(
          converter.convert(BigInt.from(1000000000000000000)), equals("一百亿亿"));
      expect(converter.convert(BigInt.parse('10000000000000000000')),
          equals("一千亿亿"));
      expect(converter.convert(BigInt.parse('100000000000000000000')),
          equals("一万亿亿"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("十万亿亿"));
      expect(converter.convert(BigInt.parse('10000000000000000000000')),
          equals("一百万亿亿"));
      expect(converter.convert(BigInt.parse('100000000000000000000000')),
          equals("一千万亿亿"));
      expect(converter.convert(BigInt.parse('1000000000000000000000000')),
          equals("一亿亿亿"));

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals('一千二百三十四万亿亿五千六百七十八亿亿九千一百二十三万亿四千五百六十七亿八千九百一十二万三千四百五十六'),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals('九千九百九十九万亿亿九千九百九十九亿亿九千九百九十九万亿九千九百九十九亿九千九百九十九万九千九百九十九'),
      );
    });
  });
}
