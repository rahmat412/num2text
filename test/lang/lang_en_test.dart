import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text English (EN)', () {
    final converter = Num2Text(initialLang: Lang.EN);
    final converterWithFallback =
        Num2Text(initialLang: Lang.EN, fallbackOnError: "Invalid Number");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("zero"));
      expect(converter.convert(10), equals("ten"));
      expect(converter.convert(11), equals("eleven"));
      expect(converter.convert(13), equals("thirteen"));
      expect(converter.convert(15), equals("fifteen"));
      expect(converter.convert(20), equals("twenty"));
      expect(converter.convert(27), equals("twenty-seven"));
      expect(converter.convert(30), equals("thirty"));
      expect(converter.convert(54), equals("fifty-four"));
      expect(converter.convert(68), equals("sixty-eight"));
      expect(converter.convert(99), equals("ninety-nine"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("one hundred"));
      expect(converter.convert(101), equals("one hundred one"));
      expect(converter.convert(105), equals("one hundred five"));
      expect(converter.convert(110), equals("one hundred ten"));
      expect(converter.convert(111), equals("one hundred eleven"));
      expect(converter.convert(123), equals("one hundred twenty-three"));
      expect(converter.convert(200), equals("two hundred"));
      expect(converter.convert(321), equals("three hundred twenty-one"));
      expect(converter.convert(479), equals("four hundred seventy-nine"));
      expect(converter.convert(596), equals("five hundred ninety-six"));
      expect(converter.convert(681), equals("six hundred eighty-one"));
      expect(converter.convert(999), equals("nine hundred ninety-nine"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("one thousand"));
      expect(converter.convert(1001), equals("one thousand one"));
      expect(converter.convert(1011), equals("one thousand eleven"));
      expect(converter.convert(1110), equals("one thousand one hundred ten"));
      expect(
          converter.convert(1111), equals("one thousand one hundred eleven"));
      expect(converter.convert(2000), equals("two thousand"));
      expect(converter.convert(2468),
          equals("two thousand four hundred sixty-eight"));
      expect(converter.convert(3579),
          equals("three thousand five hundred seventy-nine"));
      expect(converter.convert(10000), equals("ten thousand"));
      expect(converter.convert(10011), equals("ten thousand eleven"));
      expect(converter.convert(11100), equals("eleven thousand one hundred"));
      expect(converter.convert(12987),
          equals("twelve thousand nine hundred eighty-seven"));
      expect(converter.convert(45623),
          equals("forty-five thousand six hundred twenty-three"));
      expect(converter.convert(87654),
          equals("eighty-seven thousand six hundred fifty-four"));
      expect(converter.convert(100000), equals("one hundred thousand"));
      expect(converter.convert(123456),
          equals("one hundred twenty-three thousand four hundred fifty-six"));
      expect(converter.convert(987654),
          equals("nine hundred eighty-seven thousand six hundred fifty-four"));
      expect(converter.convert(999999),
          equals("nine hundred ninety-nine thousand nine hundred ninety-nine"));
    });

    test('Negative Numbers', () {
      const negativePrefixOption = EnOptions(negativePrefix: "negative");

      expect(converter.convert(-1), equals("minus one"));
      expect(converter.convert(-123), equals("minus one hundred twenty-three"));
      expect(converter.convert(-123.456),
          equals("minus one hundred twenty-three point four five six"));

      expect(converter.convert(-1, options: negativePrefixOption),
          equals("negative one"));
      expect(converter.convert(-123, options: negativePrefixOption),
          equals("negative one hundred twenty-three"));
      expect(converter.convert(-123.456, options: negativePrefixOption),
          equals("negative one hundred twenty-three point four five six"));
    });

    test('Decimals', () {
      const pointOption = EnOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = EnOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = EnOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(123.456),
          equals("one hundred twenty-three point four five six"));
      expect(converter.convert(1.5), equals("one point five"));
      expect(converter.convert(1.05), equals("one point zero five"));
      expect(converter.convert(879.465),
          equals("eight hundred seventy-nine point four six five"));
      expect(converter.convert(1.5), equals("one point five"));

      expect(converter.convert(1.5, options: pointOption),
          equals("one point five"));
      expect(converter.convert(1.5, options: commaOption),
          equals("one comma five"));
      expect(converter.convert(1.5, options: periodOption),
          equals("one point five"));
    });

    test('Year Formatting', () {
      const yearOption = EnOptions(format: Format.year);
      const yearOptionAD = EnOptions(format: Format.year, includeAD: true);

      expect(converter.convert(123, options: yearOption),
          equals("one hundred twenty-three"));
      expect(converter.convert(498, options: yearOption),
          equals("four hundred ninety-eight"));
      expect(converter.convert(756, options: yearOption),
          equals("seven hundred fifty-six"));
      expect(converter.convert(1900, options: yearOption),
          equals("nineteen hundred"));
      expect(converter.convert(1999, options: yearOption),
          equals("nineteen ninety-nine"));
      expect(converter.convert(2025, options: yearOption),
          equals("twenty twenty-five"));

      expect(converter.convert(1900, options: yearOptionAD),
          equals("nineteen hundred AD"));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("nineteen ninety-nine AD"));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("twenty twenty-five AD"));
      expect(converter.convert(-1, options: yearOption), equals("one BC"));
      expect(converter.convert(-100, options: yearOption),
          equals("one hundred BC"));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("one hundred BC"));
      expect(converter.convert(-2025, options: yearOption),
          equals("twenty twenty-five BC"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("one million BC"));
    });

    test('Currency', () {
      const currencyOptionUS =
          EnOptions(currency: true, currencyInfo: CurrencyInfo.usd);
      const currencyOptionGBP = EnOptions(
          currency: true, currencyInfo: CurrencyInfo.gbp, includeAnd: true);

      expect(converter.convert(0, options: currencyOptionUS),
          equals("zero dollars"));
      expect(converter.convert(1, options: currencyOptionUS),
          equals("one dollar"));
      expect(converter.convert(5, options: currencyOptionUS),
          equals("five dollars"));
      expect(converter.convert(10, options: currencyOptionUS),
          equals("ten dollars"));
      expect(converter.convert(11, options: currencyOptionUS),
          equals("eleven dollars"));
      expect(converter.convert(1.50, options: currencyOptionUS),
          equals("one dollar and fifty cents"));
      expect(converter.convert(123.45, options: currencyOptionUS),
          equals("one hundred twenty-three dollars and forty-five cents"));
      expect(converter.convert(10000000, options: currencyOptionUS),
          equals("ten million dollars"));
      expect(converter.convert(0.01, options: currencyOptionUS),
          equals("one cent"));
      expect(converter.convert(0.5, options: currencyOptionUS),
          equals("fifty cents"));
      expect(converter.convert(1.01, options: currencyOptionUS),
          equals("one dollar and one cent"));

      expect(converter.convert(0, options: currencyOptionGBP),
          equals("zero pounds"));
      expect(converter.convert(1, options: currencyOptionGBP),
          equals("one pound"));
      expect(converter.convert(5, options: currencyOptionGBP),
          equals("five pounds"));
      expect(converter.convert(10, options: currencyOptionGBP),
          equals("ten pounds"));
      expect(converter.convert(11, options: currencyOptionGBP),
          equals("eleven pounds"));
      expect(converter.convert(1.50, options: currencyOptionGBP),
          equals("one pound and fifty pence"));
      expect(converter.convert(123.45, options: currencyOptionGBP),
          equals("one hundred and twenty-three pounds and forty-five pence"));
      expect(converter.convert(10000000, options: currencyOptionGBP),
          equals("ten million pounds"));
      expect(converter.convert(0.01, options: currencyOptionGBP),
          equals("one penny"));
      expect(converter.convert(0.5, options: currencyOptionGBP),
          equals("fifty pence"));
      expect(converter.convert(1.01, options: currencyOptionGBP),
          equals("one pound and one penny"));
      expect(converter.convert(1.02, options: currencyOptionGBP),
          equals("one pound and two pence"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("one million"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("two billion"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("three trillion"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("four quadrillion"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("five quintillion"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("six sextillion"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("seven septillion"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "nine quintillion eight hundred seventy-six quadrillion five hundred forty-three trillion two hundred ten billion one hundred twenty-three million four hundred fifty-six thousand seven hundred eighty-nine"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "one hundred twenty-three sextillion four hundred fifty-six quintillion seven hundred eighty-nine quadrillion one hundred twenty-three trillion four hundred fifty-six billion seven hundred eighty-nine million one hundred twenty-three thousand four hundred fifty-six"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "nine hundred ninety-nine sextillion nine hundred ninety-nine quintillion nine hundred ninety-nine quadrillion nine hundred ninety-nine trillion nine hundred ninety-nine billion nine hundred ninety-nine million nine hundred ninety-nine thousand nine hundred ninety-nine"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("one trillion two million three"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("five million one thousand"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("one billion one"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("one billion one million"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("two million one thousand"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "one trillion nine hundred eighty-seven million six hundred thousand three"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Not A Number"));
      expect(converter.convert(double.infinity), equals("Infinity"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negative Infinity"));
      expect(converter.convert(null), equals("Not A Number"));
      expect(converter.convert('abc'), equals("Not A Number"));
      expect(converter.convert([]), equals("Not A Number"));
      expect(converter.convert({}), equals("Not A Number"));
      expect(converter.convert(Object()), equals("Not A Number"));

      expect(
          converterWithFallback.convert(double.nan), equals("Invalid Number"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Infinity"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negative Infinity"));
      expect(converterWithFallback.convert(null), equals("Invalid Number"));
      expect(converterWithFallback.convert('abc'), equals("Invalid Number"));
      expect(converterWithFallback.convert([]), equals("Invalid Number"));
      expect(converterWithFallback.convert({}), equals("Invalid Number"));
      expect(converterWithFallback.convert(Object()), equals("Invalid Number"));
      expect(converterWithFallback.convert(123),
          equals("one hundred twenty-three"));
    });
  });
}
