import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Turkmen (TK)', () {
    final converter = Num2Text(initialLang: Lang.TK);
    final converterWithFallback =
        Num2Text(initialLang: Lang.TK, fallbackOnError: "Nädogry san");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("nol"));
      expect(converter.convert(1), equals("bir"));
      expect(converter.convert(10), equals("on"));
      expect(converter.convert(11), equals("on bir"));
      expect(converter.convert(20), equals("ýigrimi"));
      expect(converter.convert(21), equals("ýigrimi bir"));
      expect(converter.convert(99), equals("dogson dokuz"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("ýüz"));
      expect(converter.convert(101), equals("ýüz bir"));
      expect(converter.convert(111), equals("ýüz on bir"));
      expect(converter.convert(200), equals("iki ýüz"));
      expect(converter.convert(999), equals("dokuz ýüz dogson dokuz"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("bir müň"));
      expect(converter.convert(1001), equals("bir müň bir"));
      expect(converter.convert(1111), equals("bir müň ýüz on bir"));
      expect(converter.convert(2000), equals("iki müň"));
      expect(converter.convert(10000), equals("on müň"));
      expect(converter.convert(100000), equals("ýüz müň"));
      expect(converter.convert(123456),
          equals("ýüz ýigrimi üç müň dört ýüz elli alty"));
      expect(
        converter.convert(999999),
        equals("dokuz ýüz dogson dokuz müň dokuz ýüz dogson dokuz"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus bir"));
      expect(converter.convert(-123), equals("minus ýüz ýigrimi üç"));
      expect(converter.convert(-1, options: TkOptions(negativePrefix: "ýok")),
          equals("ýok bir"));
      expect(
        converter.convert(-123, options: TkOptions(negativePrefix: "ýok")),
        equals("ýok ýüz ýigrimi üç"),
      );
    });

    test('Year Formatting', () {
      const yearOption = TkOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("bir müň dokuz ýüz"));
      expect(converter.convert(2024, options: yearOption),
          equals("iki müň ýigrimi dört"));
      expect(
        converter.convert(1900,
            options: TkOptions(format: Format.year, includeAD: true)),
        equals("bir müň dokuz ýüz AD"),
      );
      expect(
        converter.convert(2024,
            options: TkOptions(format: Format.year, includeAD: true)),
        equals("iki müň ýigrimi dört AD"),
      );
      expect(converter.convert(-100, options: yearOption), equals("ýüz BC"));
      expect(converter.convert(-1, options: yearOption), equals("bir BC"));
      expect(
        converter.convert(-2024,
            options: TkOptions(format: Format.year, includeAD: true)),
        equals("iki müň ýigrimi dört BC"),
      );
    });

    test('Currency', () {
      const currencyOption = TkOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("nol manat"));
      expect(
          converter.convert(1, options: currencyOption), equals("bir manat"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("bir manat"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("ýüz ýigrimi üç manat"));
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("ýüz ýigrimi üç comma dört bäş alty"),
      );
      expect(converter.convert(Decimal.parse('1.50')), equals("bir comma bäş"));
      expect(converter.convert(123.0), equals("ýüz ýigrimi üç"));
      expect(
          converter.convert(Decimal.parse('123.0')), equals("ýüz ýigrimi üç"));
      expect(
        converter.convert(1.5,
            options: const TkOptions(decimalSeparator: DecimalSeparator.point)),
        equals("bir point bäş"),
      );
      expect(
        converter.convert(1.5,
            options: const TkOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("bir comma bäş"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Infinity"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negative Infinity"));
      expect(converter.convert(double.nan), equals("Not a Number"));
      expect(converter.convert(null), equals("Not a Number"));
      expect(converter.convert('abc'), equals("Not a Number"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Infinity"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negative Infinity"));
      expect(converterWithFallback.convert(double.nan), equals("Nädogry san"));
      expect(converterWithFallback.convert(null), equals("Nädogry san"));
      expect(converterWithFallback.convert('abc'), equals("Nädogry san"));
      expect(converterWithFallback.convert(123), equals("ýüz ýigrimi üç"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("bir million"));
      expect(
          converter.convert(BigInt.from(1000000000)), equals("bir milliard"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("bir trillion"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("bir quadrillion"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("bir quintillion"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("bir sextillion"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("bir septillion"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "ýüz ýigrimi üç sextillion dört ýüz elli alty quintillion ýedi ýüz segsen dokuz quadrillion ýüz ýigrimi üç trillion dört ýüz elli alty milliard ýedi ýüz segsen dokuz million ýüz ýigrimi üç müň dört ýüz elli alty",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "dokuz ýüz dogson dokuz sextillion dokuz ýüz dogson dokuz quintillion dokuz ýüz dogson dokuz quadrillion dokuz ýüz dogson dokuz trillion dokuz ýüz dogson dokuz milliard dokuz ýüz dogson dokuz million dokuz ýüz dogson dokuz müň dokuz ýüz dogson dokuz",
        ),
      );
    });
  });
}
