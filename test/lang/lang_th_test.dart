import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Thai (TH)', () {
    final converter = Num2Text(initialLang: Lang.TH);
    final converterWithFallback =
        Num2Text(initialLang: Lang.TH, fallbackOnError: "รูปแบบไม่ถูกต้อง");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("ศูนย์"));
      expect(converter.convert(10), equals("สิบ"));
      expect(converter.convert(11), equals("สิบเอ็ด"));
      expect(converter.convert(13), equals("สิบสาม"));
      expect(converter.convert(15), equals("สิบห้า"));
      expect(converter.convert(20), equals("ยี่สิบ"));
      expect(converter.convert(27), equals("ยี่สิบเจ็ด"));
      expect(converter.convert(30), equals("สามสิบ"));
      expect(converter.convert(54), equals("ห้าสิบสี่"));
      expect(converter.convert(68), equals("หกสิบแปด"));
      expect(converter.convert(99), equals("เก้าสิบเก้า"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("หนึ่งร้อย"));
      expect(converter.convert(101), equals("หนึ่งร้อยเอ็ด"));
      expect(converter.convert(105), equals("หนึ่งร้อยห้า"));
      expect(converter.convert(110), equals("หนึ่งร้อยสิบ"));
      expect(converter.convert(111), equals("หนึ่งร้อยสิบเอ็ด"));
      expect(converter.convert(123), equals("หนึ่งร้อยยี่สิบสาม"));
      expect(converter.convert(200), equals("สองร้อย"));
      expect(converter.convert(321), equals("สามร้อยยี่สิบเอ็ด"));
      expect(converter.convert(479), equals("สี่ร้อยเจ็ดสิบเก้า"));
      expect(converter.convert(596), equals("ห้าร้อยเก้าสิบหก"));
      expect(converter.convert(681), equals("หกร้อยแปดสิบเอ็ด"));
      expect(converter.convert(999), equals("เก้าร้อยเก้าสิบเก้า"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("หนึ่งพัน"));
      expect(converter.convert(1001), equals("หนึ่งพันเอ็ด"));
      expect(converter.convert(1011), equals("หนึ่งพันสิบเอ็ด"));
      expect(converter.convert(1110), equals("หนึ่งพันหนึ่งร้อยสิบ"));
      expect(converter.convert(1111), equals("หนึ่งพันหนึ่งร้อยสิบเอ็ด"));
      expect(converter.convert(2000), equals("สองพัน"));
      expect(converter.convert(2468), equals("สองพันสี่ร้อยหกสิบแปด"));
      expect(converter.convert(3579), equals("สามพันห้าร้อยเจ็ดสิบเก้า"));
      expect(converter.convert(10000), equals("หนึ่งหมื่น"));
      expect(converter.convert(10011), equals("หนึ่งหมื่นสิบเอ็ด"));
      expect(converter.convert(11100), equals("หนึ่งหมื่นหนึ่งพันหนึ่งร้อย"));
      expect(converter.convert(12987),
          equals("หนึ่งหมื่นสองพันเก้าร้อยแปดสิบเจ็ด"));
      expect(converter.convert(45623), equals("สี่หมื่นห้าพันหกร้อยยี่สิบสาม"));
      expect(
          converter.convert(87654), equals("แปดหมื่นเจ็ดพันหกร้อยห้าสิบสี่"));
      expect(converter.convert(100000), equals("หนึ่งแสน"));
      expect(converter.convert(123456),
          equals("หนึ่งแสนสองหมื่นสามพันสี่ร้อยห้าสิบหก"));
      expect(converter.convert(987654),
          equals("เก้าแสนแปดหมื่นเจ็ดพันหกร้อยห้าสิบสี่"));
      expect(converter.convert(999999),
          equals("เก้าแสนเก้าหมื่นเก้าพันเก้าร้อยเก้าสิบเก้า"));
    });

    test('Negative Numbers', () {
      const tidlobOption = ThOptions(negativePrefix: "ติดลบ");
      expect(converter.convert(-1), equals("ลบหนึ่ง"));
      expect(converter.convert(-123), equals("ลบหนึ่งร้อยยี่สิบสาม"));
      expect(converter.convert(-123.456),
          equals("ลบหนึ่งร้อยยี่สิบสามจุดสี่ห้าหก"));
      expect(
          converter.convert(-1, options: tidlobOption), equals("ติดลบหนึ่ง"));
      expect(converter.convert(-123, options: tidlobOption),
          equals("ติดลบหนึ่งร้อยยี่สิบสาม"));
      expect(
        converter.convert(-123.456, options: tidlobOption),
        equals("ติดลบหนึ่งร้อยยี่สิบสามจุดสี่ห้าหก"),
      );
    });

    test('Decimals', () {
      const commaOption = ThOptions(decimalSeparator: DecimalSeparator.comma);
      const pointOption = ThOptions(decimalSeparator: DecimalSeparator.point);
      const periodOption = ThOptions(decimalSeparator: DecimalSeparator.period);
      expect(
          converter.convert(123.456), equals("หนึ่งร้อยยี่สิบสามจุดสี่ห้าหก"));
      expect(converter.convert(1.5), equals("หนึ่งจุดห้า"));
      expect(converter.convert(1.05), equals("หนึ่งจุดศูนย์ห้า"));
      expect(
          converter.convert(879.465), equals("แปดร้อยเจ็ดสิบเก้าจุดสี่หกห้า"));
      expect(
          converter.convert(1.5, options: pointOption), equals("หนึ่งจุดห้า"));
      expect(converter.convert(1.5, options: commaOption),
          equals("หนึ่งลูกน้ำห้า"));
      expect(
          converter.convert(1.5, options: periodOption), equals("หนึ่งจุดห้า"));
    });

    test('Year Formatting', () {
      const yearOption = ThOptions(format: Format.year);
      const yearOptionAD = ThOptions(format: Format.year, includeAD: true);
      expect(converter.convert(123, options: yearOption),
          equals("หนึ่งร้อยยี่สิบสาม"));
      expect(converter.convert(498, options: yearOption),
          equals("สี่ร้อยเก้าสิบแปด"));
      expect(converter.convert(756, options: yearOption),
          equals("เจ็ดร้อยห้าสิบหก"));
      expect(converter.convert(1900, options: yearOption),
          equals("หนึ่งพันเก้าร้อย"));
      expect(converter.convert(1999, options: yearOption),
          equals("หนึ่งพันเก้าร้อยเก้าสิบเก้า"));
      expect(converter.convert(2025, options: yearOption),
          equals("สองพันยี่สิบห้า"));
      expect(converter.convert(1900, options: yearOptionAD),
          equals("หนึ่งพันเก้าร้อย ค.ศ."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("หนึ่งพันเก้าร้อยเก้าสิบเก้า ค.ศ."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("สองพันยี่สิบห้า ค.ศ."));
      expect(converter.convert(-1, options: yearOption),
          equals("หนึ่ง ก่อน ค.ศ."));
      expect(converter.convert(-100, options: yearOption),
          equals("หนึ่งร้อย ก่อน ค.ศ."));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("หนึ่งร้อย ก่อน ค.ศ."));
      expect(converter.convert(-2025, options: yearOption),
          equals("สองพันยี่สิบห้า ก่อน ค.ศ."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("หนึ่งล้าน ก่อน ค.ศ."));
    });

    test('Currency', () {
      const currencyOption = ThOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("ศูนย์บาทถ้วน"));
      expect(converter.convert(1, options: currencyOption),
          equals("หนึ่งบาทถ้วน"));
      expect(
          converter.convert(5, options: currencyOption), equals("ห้าบาทถ้วน"));
      expect(
          converter.convert(10, options: currencyOption), equals("สิบบาทถ้วน"));
      expect(converter.convert(11, options: currencyOption),
          equals("สิบเอ็ดบาทถ้วน"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("หนึ่งบาทห้าสิบสตางค์"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("หนึ่งร้อยยี่สิบสามบาทสี่สิบห้าสตางค์"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("สิบล้านบาทถ้วน"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("หนึ่งสตางค์"));
      expect(converter.convert(0.25, options: currencyOption),
          equals("ยี่สิบห้าสตางค์"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("ห้าสิบสตางค์"));
      expect(converter.convert(0.75, options: currencyOption),
          equals("เจ็ดสิบห้าสตางค์"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("หนึ่งบาทหนึ่งสตางค์"));
      expect(converter.convert(1.25, options: currencyOption),
          equals("หนึ่งบาทยี่สิบห้าสตางค์"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("หนึ่งล้าน"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(7)),
          equals("ยี่สิบล้าน"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(8)),
          equals("สามร้อยล้าน"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(9)),
          equals("สี่พันล้าน"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(10)),
          equals("ห้าหมื่นล้าน"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(11)),
          equals("หกแสนล้าน"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(12)),
          equals("เจ็ดล้านล้าน"));
      expect(converter.convert(BigInt.from(8) * BigInt.from(10).pow(18)),
          equals("แปดล้านล้านล้าน"));
      expect(converter.convert(BigInt.from(9) * BigInt.from(10).pow(24)),
          equals("เก้าล้านล้านล้านล้าน"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            'เก้าล้านล้านล้านแปดแสนเจ็ดหมื่นหกพันห้าร้อยสี่สิบสามล้านล้านสองแสนหนึ่งหมื่นหนึ่งร้อยยี่สิบสามล้านสี่แสนห้าหมื่นหกพันเจ็ดร้อยแปดสิบเก้า'),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "หนึ่งแสนสองหมื่นสามพันสี่ร้อยห้าสิบหกล้านล้านล้านเจ็ดแสนแปดหมื่นเก้าพันหนึ่งร้อยยี่สิบสามล้านล้านสี่แสนห้าหมื่นหกพันเจ็ดร้อยแปดสิบเก้าล้านหนึ่งแสนสองหมื่นสามพันสี่ร้อยห้าสิบหก"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "เก้าแสนเก้าหมื่นเก้าพันเก้าร้อยเก้าสิบเก้าล้านล้านล้านเก้าแสนเก้าหมื่นเก้าพันเก้าร้อยเก้าสิบเก้าล้านล้านเก้าแสนเก้าหมื่นเก้าพันเก้าร้อยเก้าสิบเก้าล้านเก้าแสนเก้าหมื่นเก้าพันเก้าร้อยเก้าสิบเก้า"),
      );
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("หนึ่งล้านล้านสองล้านสาม"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("ห้าล้านหนึ่งพัน"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("หนึ่งพันล้านหนึ่ง"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("หนึ่งพันเอ็ดล้าน"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("สองล้านหนึ่งพัน"));
      expect(converter.convert(BigInt.parse('1000987600003')),
          equals("หนึ่งล้านล้านเก้าร้อยแปดสิบเจ็ดล้านหกแสนสาม"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("ไม่ใช่ตัวเลข"));
      expect(converter.convert(double.infinity), equals("อนันต์"));
      expect(converter.convert(double.negativeInfinity), equals("ลบอนันต์"));
      expect(converter.convert(null), equals("ไม่ใช่ตัวเลข"));
      expect(converter.convert('abc'), equals("ไม่ใช่ตัวเลข"));
      expect(converter.convert([]), equals("ไม่ใช่ตัวเลข"));
      expect(converter.convert({}), equals("ไม่ใช่ตัวเลข"));
      expect(converter.convert(Object()), equals("ไม่ใช่ตัวเลข"));
      expect(converterWithFallback.convert(double.nan),
          equals("รูปแบบไม่ถูกต้อง"));
      expect(converterWithFallback.convert(double.infinity), equals("อนันต์"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("ลบอนันต์"));
      expect(converterWithFallback.convert(null), equals("รูปแบบไม่ถูกต้อง"));
      expect(converterWithFallback.convert('abc'), equals("รูปแบบไม่ถูกต้อง"));
      expect(converterWithFallback.convert([]), equals("รูปแบบไม่ถูกต้อง"));
      expect(converterWithFallback.convert({}), equals("รูปแบบไม่ถูกต้อง"));
      expect(
          converterWithFallback.convert(Object()), equals("รูปแบบไม่ถูกต้อง"));
      expect(converterWithFallback.convert(123), equals("หนึ่งร้อยยี่สิบสาม"));
    });
  });
}
