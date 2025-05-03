import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Turkmen (TK)', () {
    final converter = Num2Text(initialLang: Lang.TK);
    final converterWithFallback =
        Num2Text(initialLang: Lang.TK, fallbackOnError: "Nädogry San");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("nol"));
      expect(converter.convert(10), equals("on"));
      expect(converter.convert(11), equals("on bir"));
      expect(converter.convert(13), equals("on üç"));
      expect(converter.convert(15), equals("on bäş"));
      expect(converter.convert(20), equals("ýigrimi"));
      expect(converter.convert(27), equals("ýigrimi ýedi"));
      expect(converter.convert(30), equals("otuz"));
      expect(converter.convert(54), equals("elli dört"));
      expect(converter.convert(68), equals("altmyş sekiz"));
      expect(converter.convert(99), equals("togsan dokuz"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("ýüz"));
      expect(converter.convert(101), equals("ýüz bir"));
      expect(converter.convert(105), equals("ýüz bäş"));
      expect(converter.convert(110), equals("ýüz on"));
      expect(converter.convert(111), equals("ýüz on bir"));
      expect(converter.convert(123), equals("ýüz ýigrimi üç"));
      expect(converter.convert(200), equals("iki ýüz"));
      expect(converter.convert(321), equals("üç ýüz ýigrimi bir"));
      expect(converter.convert(479), equals("dört ýüz ýetmiş dokuz"));
      expect(converter.convert(596), equals("bäş ýüz togsan alty"));
      expect(converter.convert(681), equals("alty ýüz segsen bir"));
      expect(converter.convert(999), equals("dokuz ýüz togsan dokuz"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("bir müň"));
      expect(converter.convert(1001), equals("bir müň bir"));
      expect(converter.convert(1011), equals("bir müň on bir"));
      expect(converter.convert(1110), equals("bir müň ýüz on"));
      expect(converter.convert(1111), equals("bir müň ýüz on bir"));
      expect(converter.convert(2000), equals("iki müň"));
      expect(converter.convert(2468), equals("iki müň dört ýüz altmyş sekiz"));
      expect(converter.convert(3579), equals("üç müň bäş ýüz ýetmiş dokuz"));
      expect(converter.convert(10000), equals("on müň"));
      expect(converter.convert(10011), equals("on müň on bir"));
      expect(converter.convert(11100), equals("on bir müň ýüz"));
      expect(
          converter.convert(12987), equals("on iki müň dokuz ýüz segsen ýedi"));
      expect(
          converter.convert(45623), equals("kyrk bäş müň alty ýüz ýigrimi üç"));
      expect(converter.convert(87654),
          equals("segsen ýedi müň alty ýüz elli dört"));
      expect(converter.convert(100000), equals("ýüz müň"));
      expect(converter.convert(123456),
          equals("ýüz ýigrimi üç müň dört ýüz elli alty"));
      expect(converter.convert(987654),
          equals("dokuz ýüz segsen ýedi müň alty ýüz elli dört"));
      expect(converter.convert(999999),
          equals("dokuz ýüz togsan dokuz müň dokuz ýüz togsan dokuz"));
    });

    test('Negative Numbers', () {
      const yokOption = TkOptions(negativePrefix: "ýok");
      expect(converter.convert(-1), equals("minus bir"));
      expect(converter.convert(-123), equals("minus ýüz ýigrimi üç"));
      expect(converter.convert(-123.456),
          equals("minus ýüz ýigrimi üç comma dört bäş alty"));
      expect(converter.convert(-1, options: yokOption), equals("ýok bir"));
      expect(converter.convert(-123, options: yokOption),
          equals("ýok ýüz ýigrimi üç"));
      expect(
        converter.convert(-123.456, options: yokOption),
        equals("ýok ýüz ýigrimi üç comma dört bäş alty"),
      );
    });

    test('Decimals', () {
      const pointOption = TkOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = TkOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = TkOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(123.456),
          equals("ýüz ýigrimi üç comma dört bäş alty"));
      expect(converter.convert(1.5), equals("bir comma bäş"));
      expect(converter.convert(1.05), equals("bir comma nol bäş"));
      expect(converter.convert(879.465),
          equals("sekiz ýüz ýetmiş dokuz comma dört alty bäş"));
      expect(converter.convert(1.5, options: pointOption),
          equals("bir point bäş"));
      expect(converter.convert(1.5, options: commaOption),
          equals("bir comma bäş"));
      expect(converter.convert(1.5, options: periodOption),
          equals("bir point bäş"));
    });

    test('Year Formatting', () {
      const yearOption = TkOptions(format: Format.year);
      const yearOptionAD = TkOptions(format: Format.year, includeAD: true);
      expect(converter.convert(123, options: yearOption),
          equals("ýüz ýigrimi üç"));
      expect(converter.convert(498, options: yearOption),
          equals("dört ýüz togsan sekiz"));
      expect(converter.convert(756, options: yearOption),
          equals("ýedi ýüz elli alty"));
      expect(converter.convert(1900, options: yearOption),
          equals("bir müň dokuz ýüz"));
      expect(converter.convert(1999, options: yearOption),
          equals("bir müň dokuz ýüz togsan dokuz"));
      expect(converter.convert(2025, options: yearOption),
          equals("iki müň ýigrimi bäş"));
      expect(converter.convert(1900, options: yearOptionAD),
          equals("bir müň dokuz ýüz b.e."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("bir müň dokuz ýüz togsan dokuz b.e."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("iki müň ýigrimi bäş b.e."));
      expect(converter.convert(-1, options: yearOption), equals("bir b.e.öň"));
      expect(
          converter.convert(-100, options: yearOption), equals("ýüz b.e.öň"));
      expect(
          converter.convert(-100, options: yearOptionAD), equals("ýüz b.e.öň"));
      expect(converter.convert(-2025, options: yearOption),
          equals("iki müň ýigrimi bäş b.e.öň"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("bir million b.e.öň"));
    });

    test('Currency', () {
      const currencyOption = TkOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("nol manat"));
      expect(
          converter.convert(1, options: currencyOption), equals("bir manat"));
      expect(
          converter.convert(5, options: currencyOption), equals("bäş manat"));
      expect(
          converter.convert(10, options: currencyOption), equals("on manat"));
      expect(converter.convert(11, options: currencyOption),
          equals("on bir manat"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("bir manat elli teňňe"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("ýüz ýigrimi üç manat kyrk bäş teňňe"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("on million manat"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("elli teňňe"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("bir teňňe"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("bäş teňňe"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("bir manat bir teňňe"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("bir million"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("iki milliard"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("üç trillion"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("dört kwadrillion"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("bäş kwintillion"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("alty sekstillion"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("ýedi septillion"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            "dokuz kwintillion sekiz ýüz ýetmiş alty kwadrillion bäş ýüz kyrk üç trillion iki ýüz on milliard ýüz ýigrimi üç million dört ýüz elli alty müň ýedi ýüz segsen dokuz"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "ýüz ýigrimi üç sekstillion dört ýüz elli alty kwintillion ýedi ýüz segsen dokuz kwadrillion ýüz ýigrimi üç trillion dört ýüz elli alty milliard ýedi ýüz segsen dokuz million ýüz ýigrimi üç müň dört ýüz elli alty"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "dokuz ýüz togsan dokuz sekstillion dokuz ýüz togsan dokuz kwintillion dokuz ýüz togsan dokuz kwadrillion dokuz ýüz togsan dokuz trillion dokuz ýüz togsan dokuz milliard dokuz ýüz togsan dokuz million dokuz ýüz togsan dokuz müň dokuz ýüz togsan dokuz"),
      );
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('bir trillion iki million üç'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("bäş million bir müň"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("bir milliard bir"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("bir milliard bir million"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("iki million bir müň"));
      expect(converter.convert(BigInt.parse('1000987600003')),
          equals("bir trillion dokuz ýüz segsen ýedi million alty ýüz müň üç"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("San Däl"));
      expect(converter.convert(double.infinity), equals("Tükeniksizlik"));
      expect(converter.convert(double.negativeInfinity),
          equals("Minus Tükeniksizlik"));
      expect(converter.convert(null), equals("San Däl"));
      expect(converter.convert('abc'), equals("San Däl"));
      expect(converter.convert([]), equals("San Däl"));
      expect(converter.convert({}), equals("San Däl"));
      expect(converter.convert(Object()), equals("San Däl"));
      expect(converterWithFallback.convert(double.nan), equals("Nädogry San"));
      expect(converterWithFallback.convert(double.infinity),
          equals("Tükeniksizlik"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Minus Tükeniksizlik"));
      expect(converterWithFallback.convert(null), equals("Nädogry San"));
      expect(converterWithFallback.convert('abc'), equals("Nädogry San"));
      expect(converterWithFallback.convert([]), equals("Nädogry San"));
      expect(converterWithFallback.convert({}), equals("Nädogry San"));
      expect(converterWithFallback.convert(Object()), equals("Nädogry San"));
      expect(converterWithFallback.convert(123), equals("ýüz ýigrimi üç"));
    });
  });
}
