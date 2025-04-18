import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text English (EN)', () {
    final converter = Num2Text(initialLang: Lang.EN);
    final converterWithFallback =
        Num2Text(initialLang: Lang.EN, fallbackOnError: "Invalid Number");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("zero"));
      expect(converter.convert(1), equals("one"));
      expect(converter.convert(10), equals("ten"));
      expect(converter.convert(11), equals("eleven"));
      expect(converter.convert(20), equals("twenty"));
      expect(converter.convert(21), equals("twenty-one"));
      expect(converter.convert(99), equals("ninety-nine"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("one hundred"));
      expect(converter.convert(101), equals("one hundred one"));
      expect(converter.convert(111), equals("one hundred eleven"));
      expect(converter.convert(200), equals("two hundred"));
      expect(converter.convert(999), equals("nine hundred ninety-nine"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("one thousand"));
      expect(converter.convert(1001), equals("one thousand one"));
      expect(
          converter.convert(1111), equals("one thousand one hundred eleven"));
      expect(converter.convert(2000), equals("two thousand"));
      expect(converter.convert(10000), equals("ten thousand"));
      expect(converter.convert(100000), equals("one hundred thousand"));
      expect(
        converter.convert(123456),
        equals("one hundred twenty-three thousand four hundred fifty-six"),
      );
      expect(
        converter.convert(999999),
        equals("nine hundred ninety-nine thousand nine hundred ninety-nine"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus one"));
      expect(converter.convert(-123), equals("minus one hundred twenty-three"));
      expect(
        converter.convert(-1, options: EnOptions(negativePrefix: "negative")),
        equals("negative one"),
      );
      expect(
        converter.convert(-123, options: EnOptions(negativePrefix: "negative")),
        equals("negative one hundred twenty-three"),
      );
    });

    test('Year Formatting', () {
      const yearOption = EnOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("nineteen hundred"));
      expect(converter.convert(2024, options: yearOption),
          equals("twenty twenty-four"));
      expect(
        converter.convert(1900,
            options: EnOptions(format: Format.year, includeAD: true)),
        equals("nineteen hundred AD"),
      );
      expect(
        converter.convert(2024,
            options: EnOptions(format: Format.year, includeAD: true)),
        equals("twenty twenty-four AD"),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("one hundred BC"));
      expect(converter.convert(-1, options: yearOption), equals("one BC"));

      expect(
        converter.convert(-2024,
            options: EnOptions(format: Format.year, includeAD: true)),
        equals("twenty twenty-four BC"),
      );
    });

    test('Currency', () {
      const currencyOption = EnOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("zero dollars"));
      expect(
          converter.convert(1, options: currencyOption), equals("one dollar"));
      expect(
        converter.convert(1.50, options: currencyOption),
        equals("one dollar and fifty cents"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("one hundred twenty-three dollars and forty-five cents"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("one hundred twenty-three point four five six"),
      );
      expect(
          converter.convert(Decimal.parse('1.50')), equals("one point five"));
      expect(converter.convert(123.0), equals("one hundred twenty-three"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("one hundred twenty-three"));

      expect(
        converter.convert(1.5,
            options:
                const EnOptions(decimalSeparator: DecimalSeparator.period)),
        equals("one point five"),
      );

      expect(
        converter.convert(1.5,
            options: const EnOptions(decimalSeparator: DecimalSeparator.point)),
        equals("one point five"),
      );

      expect(
        converter.convert(1.5,
            options: const EnOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("one comma five"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.nan), equals("Not a Number"));
      expect(converter.convert(double.infinity), equals("Infinity"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negative Infinity"));
      expect(converter.convert(null), equals("Not a Number"));
      expect(converter.convert('abc'), equals("Not a Number"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Infinity"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negative Infinity"));
      expect(
          converterWithFallback.convert(double.nan), equals("Invalid Number"));
      expect(converterWithFallback.convert(null), equals("Invalid Number"));
      expect(converterWithFallback.convert('abc'), equals("Invalid Number"));
      expect(converterWithFallback.convert(123),
          equals("one hundred twenty-three"));
    });

    test('British Style (includeAnd)', () {
      expect(
        converter.convert(123, options: const EnOptions(includeAnd: true)),
        equals("one hundred and twenty-three"),
      );
      expect(
        converter.convert(101, options: const EnOptions(includeAnd: true)),
        equals("one hundred and one"),
      );
      expect(
        converter.convert(1111, options: const EnOptions(includeAnd: true)),
        equals("one thousand one hundred and eleven"),
      );

      expect(
        converter.convert(Decimal.parse('123.456'),
            options: const EnOptions(includeAnd: true)),
        equals("one hundred and twenty-three point four five six"),
      );
      expect(
        converter.convert(Decimal.parse('1.50'),
            options: const EnOptions(includeAnd: true)),
        equals("one point five"),
      );
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("one million"));
      expect(converter.convert(BigInt.from(1000000000)), equals("one billion"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("one trillion"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("one quadrillion"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("one quintillion"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("one sextillion"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("one septillion"),
      );

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "one hundred twenty-three sextillion four hundred fifty-six quintillion seven hundred eighty-nine quadrillion one hundred twenty-three trillion four hundred fifty-six billion seven hundred eighty-nine million one hundred twenty-three thousand four hundred fifty-six",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "nine hundred ninety-nine sextillion nine hundred ninety-nine quintillion nine hundred ninety-nine quadrillion nine hundred ninety-nine trillion nine hundred ninety-nine billion nine hundred ninety-nine million nine hundred ninety-nine thousand nine hundred ninety-nine",
        ),
      );
    });
  });
}
