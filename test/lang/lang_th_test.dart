import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Thai (TH)', () {
    final converter = Num2Text(initialLang: Lang.TH);
    final converterWithFallback = Num2Text(
      initialLang: Lang.TH,
      fallbackOnError: "รูปแบบไม่ถูกต้อง",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("ศูนย์"));
      expect(converter.convert(1), equals("หนึ่ง"));
      expect(converter.convert(2), equals("สอง"));
      expect(converter.convert(3), equals("สาม"));
      expect(converter.convert(4), equals("สี่"));
      expect(converter.convert(5), equals("ห้า"));
      expect(converter.convert(6), equals("หก"));
      expect(converter.convert(7), equals("เจ็ด"));
      expect(converter.convert(8), equals("แปด"));
      expect(converter.convert(9), equals("เก้า"));
      expect(converter.convert(10), equals("สิบ"));
      expect(converter.convert(11), equals("สิบเอ็ด"));
      expect(converter.convert(12), equals("สิบสอง"));
      expect(converter.convert(20), equals("ยี่สิบ"));
      expect(converter.convert(21), equals("ยี่สิบเอ็ด"));
      expect(converter.convert(99), equals("เก้าสิบเก้า"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("หนึ่งร้อย"));
      expect(converter.convert(101), equals("หนึ่งร้อยเอ็ด"));
      expect(converter.convert(111), equals("หนึ่งร้อยสิบเอ็ด"));
      expect(converter.convert(200), equals("สองร้อย"));
      expect(converter.convert(999), equals("เก้าร้อยเก้าสิบเก้า"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("หนึ่งพัน"));
      expect(converter.convert(1001), equals("หนึ่งพันเอ็ด"));
      expect(converter.convert(1111), equals("หนึ่งพันหนึ่งร้อยสิบเอ็ด"));
      expect(converter.convert(2000), equals("สองพัน"));
      expect(converter.convert(10000), equals("หนึ่งหมื่น"));
      expect(converter.convert(100000), equals("หนึ่งแสน"));
      expect(converter.convert(123456),
          equals("หนึ่งแสนสองหมื่นสามพันสี่ร้อยห้าสิบหก"));
      expect(converter.convert(999999),
          equals("เก้าแสนเก้าหมื่นเก้าพันเก้าร้อยเก้าสิบเก้า"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("ลบหนึ่ง"));
      expect(converter.convert(-123), equals("ลบหนึ่งร้อยยี่สิบสาม"));
      expect(
        converter.convert(-1, options: ThOptions(negativePrefix: "ติดลบ")),
        equals("ติดลบหนึ่ง"),
      );
      expect(
        converter.convert(-123, options: ThOptions(negativePrefix: "ติดลบ")),
        equals("ติดลบหนึ่งร้อยยี่สิบสาม"),
      );
    });

    test('Year Formatting', () {
      const yearOption = ThOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("หนึ่งพันเก้าร้อย"));
      expect(converter.convert(2024, options: yearOption),
          equals("สองพันยี่สิบสี่"));
      expect(
        converter.convert(1900,
            options: ThOptions(format: Format.year, includeAD: true)),
        equals("หนึ่งพันเก้าร้อย ค.ศ."),
      );
      expect(
        converter.convert(2024,
            options: ThOptions(format: Format.year, includeAD: true)),
        equals("สองพันยี่สิบสี่ ค.ศ."),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("หนึ่งร้อย ก่อน ค.ศ."));
      expect(converter.convert(-1, options: yearOption),
          equals("หนึ่ง ก่อน ค.ศ."));
      expect(
        converter.convert(-2024,
            options: ThOptions(format: Format.year, includeAD: true)),
        equals("สองพันยี่สิบสี่ ก่อน ค.ศ."),
      );
    });

    test('Currency', () {
      const currencyOption = ThOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("ศูนย์บาทถ้วน"));
      expect(converter.convert(1, options: currencyOption),
          equals("หนึ่งบาทถ้วน"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("หนึ่งบาทห้าสิบสตางค์"));
      expect(converter.convert(1.25, options: currencyOption),
          equals("หนึ่งบาทยี่สิบห้าสตางค์"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("หนึ่งบาทหนึ่งสตางค์"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("หนึ่งร้อยยี่สิบสามบาทสี่สิบห้าสตางค์"),
      );
      expect(converter.convert(0.75, options: currencyOption),
          equals("เจ็ดสิบห้าสตางค์"));
    });

    test('Decimals', () {
      expect(converter.convert(Decimal.parse('123.456')),
          equals("หนึ่งร้อยยี่สิบสามจุดสี่ห้าหก"));
      expect(converter.convert(Decimal.parse('1.50')), equals("หนึ่งจุดห้า"));
      expect(converter.convert(123.0), equals("หนึ่งร้อยยี่สิบสาม"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("หนึ่งร้อยยี่สิบสาม"));
      expect(
        converter.convert(1.5,
            options: const ThOptions(decimalSeparator: DecimalSeparator.point)),
        equals("หนึ่งจุดห้า"),
      );
      expect(
        converter.convert(1.5,
            options: const ThOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("หนึ่งลูกน้ำห้า"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("อนันต์"));
      expect(converter.convert(double.negativeInfinity), equals("ลบอนันต์"));
      expect(converter.convert(double.nan), equals("ไม่ใช่ตัวเลข"));
      expect(converter.convert(null), equals("ไม่ใช่ตัวเลข"));
      expect(converter.convert('abc'), equals("ไม่ใช่ตัวเลข"));

      expect(converterWithFallback.convert(double.infinity), equals("อนันต์"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("ลบอนันต์"));
      expect(converterWithFallback.convert(double.nan),
          equals("รูปแบบไม่ถูกต้อง"));
      expect(converterWithFallback.convert(null), equals("รูปแบบไม่ถูกต้อง"));
      expect(converterWithFallback.convert('abc'), equals("รูปแบบไม่ถูกต้อง"));
      expect(converterWithFallback.convert(123), equals("หนึ่งร้อยยี่สิบสาม"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("หนึ่งล้าน"));
      expect(
          converter.convert(BigInt.from(1000000000)), equals("หนึ่งพันล้าน"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("หนึ่งล้านล้าน"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("หนึ่งพันล้านล้าน"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("หนึ่งล้านล้านล้าน"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000')),
        equals("หนึ่งพันล้านล้านล้าน"),
      );
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("หนึ่งล้านล้านล้านล้าน"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "หนึ่งแสนสองหมื่นสามพันสี่ร้อยห้าสิบหกล้านเจ็ดแสนแปดหมื่นเก้าพันหนึ่งร้อยยี่สิบสามล้านสี่แสนห้าหมื่นหกพันเจ็ดร้อยแปดสิบเก้าล้านหนึ่งแสนสองหมื่นสามพันสี่ร้อยห้าสิบหก",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "เก้าแสนเก้าหมื่นเก้าพันเก้าร้อยเก้าสิบเก้าล้านเก้าแสนเก้าหมื่นเก้าพันเก้าร้อยเก้าสิบเก้าล้านเก้าแสนเก้าหมื่นเก้าพันเก้าร้อยเก้าสิบเก้าล้านเก้าแสนเก้าหมื่นเก้าพันเก้าร้อยเก้าสิบเก้า",
        ),
      );
    });
  });
}
