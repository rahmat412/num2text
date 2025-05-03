import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Urdu (UR)', () {
    final converter = Num2Text(initialLang: Lang.UR);
    final converterWithFallback =
        Num2Text(initialLang: Lang.UR, fallbackOnError: "غلط نمبر");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("صفر"));
      expect(converter.convert(10), equals("دس"));
      expect(converter.convert(11), equals("گیارہ"));
      expect(converter.convert(13), equals("تیرہ"));
      expect(converter.convert(15), equals("پندرہ"));
      expect(converter.convert(20), equals("بیس"));
      expect(converter.convert(27), equals("ستائیس"));
      expect(converter.convert(30), equals("تیس"));
      expect(converter.convert(54), equals("چون"));
      expect(converter.convert(68), equals("اڑسٹھ"));
      expect(converter.convert(99), equals("ننانوے"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("ایک سو"));
      expect(converter.convert(101), equals("ایک سو ایک"));
      expect(converter.convert(105), equals("ایک سو پانچ"));
      expect(converter.convert(110), equals("ایک سو دس"));
      expect(converter.convert(111), equals("ایک سو گیارہ"));
      expect(converter.convert(123), equals("ایک سو تیئس"));
      expect(converter.convert(200), equals("دو سو"));
      expect(converter.convert(321), equals("تین سو اکیس"));
      expect(converter.convert(479), equals("چار سو اناسی"));
      expect(converter.convert(596), equals("پانچ سو چھیانوے"));
      expect(converter.convert(681), equals("چھ سو اکیاسی"));
      expect(converter.convert(999), equals("نو سو ننانوے"));
    });

    test('Thousands (1000 - 99999)', () {
      expect(converter.convert(1000), equals("ایک ہزار"));
      expect(converter.convert(1001), equals("ایک ہزار ایک"));
      expect(converter.convert(1011), equals("ایک ہزار گیارہ"));
      expect(converter.convert(1110), equals("ایک ہزار ایک سو دس"));
      expect(converter.convert(1111), equals("ایک ہزار ایک سو گیارہ"));
      expect(converter.convert(2000), equals("دو ہزار"));
      expect(converter.convert(2468), equals("دو ہزار چار سو اڑسٹھ"));
      expect(converter.convert(3579), equals("تین ہزار پانچ سو اناسی"));
      expect(converter.convert(10000), equals("دس ہزار"));
      expect(converter.convert(10011), equals("دس ہزار گیارہ"));
      expect(converter.convert(11100), equals("گیارہ ہزار ایک سو"));
      expect(converter.convert(12987), equals("بارہ ہزار نو سو ستاسی"));
      expect(converter.convert(45623), equals("پینتالیس ہزار چھ سو تیئس"));
      expect(converter.convert(87654), equals("ستاسی ہزار چھ سو چون"));
      expect(converter.convert(99999), equals("ننانوے ہزار نو سو ننانوے"));
    });

    test('Lakhs and Crores (100000 - 999999999)', () {
      expect(converter.convert(100000), equals("ایک لاکھ"));
      expect(
          converter.convert(123456), equals("ایک لاکھ تیئس ہزار چار سو چھپن"));
      expect(converter.convert(987654), equals("نو لاکھ ستاسی ہزار چھ سو چون"));
      expect(converter.convert(999999),
          equals("نو لاکھ ننانوے ہزار نو سو ننانوے"));
      expect(converter.convert(1000000), equals("دس لاکھ"));
      expect(converter.convert(10000000), equals("ایک کروڑ"));
      expect(converter.convert(12345678),
          equals('ایک کروڑ تیئس لاکھ پینتالیس ہزار چھ سو اٹھتر'));
      expect(converter.convert(999999999),
          equals("ننانوے کروڑ ننانوے لاکھ ننانوے ہزار نو سو ننانوے"));
    });

    test('Negative Numbers', () {
      const negativeOption = UrOptions(negativePrefix: "منفی کا");
      expect(converter.convert(-1), equals("منفی ایک"));
      expect(converter.convert(-123), equals("منفی ایک سو تیئس"));
      expect(converter.convert(-123.456),
          equals("منفی ایک سو تیئس اعشاریہ چار پانچ چھ"));
      expect(converter.convert(-1, options: negativeOption),
          equals("منفی کا ایک"));
      expect(converter.convert(-123, options: negativeOption),
          equals("منفی کا ایک سو تیئس"));
      expect(
        converter.convert(-123.456, options: negativeOption),
        equals("منفی کا ایک سو تیئس اعشاریہ چار پانچ چھ"),
      );
    });

    test('Decimals', () {
      const pointOption = UrOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = UrOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = UrOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(123.456),
          equals("ایک سو تیئس اعشاریہ چار پانچ چھ"));
      expect(converter.convert(1.5), equals("ایک اعشاریہ پانچ"));
      expect(converter.convert(1.05), equals("ایک اعشاریہ صفر پانچ"));
      expect(converter.convert(879.465),
          equals("آٹھ سو اناسی اعشاریہ چار چھ پانچ"));
      expect(converter.convert(1.5, options: pointOption),
          equals("ایک اعشاریہ پانچ"));
      expect(converter.convert(1.5, options: commaOption),
          equals("ایک کوما پانچ"));
      expect(converter.convert(1.5, options: periodOption),
          equals("ایک اعشاریہ پانچ"));
    });

    test('Year Formatting', () {
      const yearOption = UrOptions(format: Format.year);
      const yearOptionAD = UrOptions(format: Format.year, includeAD: true);
      expect(
          converter.convert(123, options: yearOption), equals("ایک سو تیئس"));
      expect(converter.convert(498, options: yearOption),
          equals("چار سو اٹھانوے"));
      expect(
          converter.convert(756, options: yearOption), equals("سات سو چھپن"));
      expect(converter.convert(1900, options: yearOption), equals("انیس سو"));
      expect(converter.convert(1999, options: yearOption),
          equals("انیس سو ننانوے"));
      expect(
          converter.convert(2025, options: yearOption), equals("دو ہزار پچیس"));
      expect(converter.convert(1900, options: yearOptionAD),
          equals("انیس سو عیسوی"));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("انیس سو ننانوے عیسوی"));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("دو ہزار پچیس عیسوی"));
      expect(
          converter.convert(-1, options: yearOption), equals("ایک قبل مسیح"));
      expect(converter.convert(-100, options: yearOption),
          equals("ایک سو قبل مسیح"));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("ایک سو قبل مسیح"));
      expect(converter.convert(-2025, options: yearOption),
          equals("دو ہزار پچیس قبل مسیح"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("دس لاکھ قبل مسیح"));
    });

    test('Currency', () {
      const currencyOption = UrOptions(currency: true);
      expect(converter.convert(0, options: currencyOption), equals("صفر روپے"));
      expect(
          converter.convert(1, options: currencyOption), equals("ایک روپیہ"));
      expect(converter.convert(2, options: currencyOption), equals("دو روپے"));
      expect(
          converter.convert(5, options: currencyOption), equals("پانچ روپے"));
      expect(converter.convert(10, options: currencyOption), equals("دس روپے"));
      expect(
          converter.convert(11, options: currencyOption), equals("گیارہ روپے"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("ایک روپیہ اور پچاس پیسے"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("ایک سو تیئس روپے اور پینتالیس پیسے"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("ایک کروڑ روپے"));
      expect(
          converter.convert(0.5, options: currencyOption), equals("پچاس پیسے"));
      expect(
          converter.convert(0.01, options: currencyOption), equals("ایک پیسہ"));
      expect(
          converter.convert(0.02, options: currencyOption), equals("دو پیسے"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("پانچ پیسے"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("ایک روپیہ اور ایک پیسہ"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("دو روپے اور دو پیسے"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(7)), equals("ایک کروڑ"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("دو ارب"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(11)),
          equals("تین کھرب"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(13)),
          equals("چار نیل"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(15)),
          equals("پانچ پدم"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(17)),
          equals("چھ سنکھ"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(19)),
          equals("سات مہاسنکھ"));
      expect(converter.convert(BigInt.from(8) * BigInt.from(10).pow(21)),
          equals("آٹھ انک"));
      expect(converter.convert(BigInt.from(9) * BigInt.from(10).pow(23)),
          equals("نو جلد"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('دس کھرب بیس لاکھ تین'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("پچاس لاکھ ایک ہزار"));
      expect(
          converter.convert(BigInt.parse('1000000001')), equals("ایک ارب ایک"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals('ایک ارب دس لاکھ'));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("بیس لاکھ ایک ہزار"));
      expect(converter.convert(BigInt.parse('1000987600003')),
          equals('دس کھرب اٹھانوے کروڑ چھہتر لاکھ تین'));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "اٹھانوے سنکھ چھہتر پدم چون نیل بتیس کھرب دس ارب بارہ کروڑ چونتیس لاکھ چھپن ہزار سات سو نواسی"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              'ایک جلد تیئس انک پینتالیس مہاسنکھ سڑسٹھ سنکھ نواسی پدم بارہ نیل چونتیس کھرب چھپن ارب اٹھتر کروڑ اکانوے لاکھ تیئس ہزار چار سو چھپن'));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "نو جلد ننانوے انک ننانوے مہاسنکھ ننانوے سنکھ ننانوے پدم ننانوے نیل ننانوے کھرب ننانوے ارب ننانوے کروڑ ننانوے لاکھ ننانوے ہزار نو سو ننانوے"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("نمبر نہیں ہے"));
      expect(converter.convert(double.infinity), equals("لامحدود"));
      expect(
          converter.convert(double.negativeInfinity), equals("منفی لامحدود"));
      expect(converter.convert(null), equals("نمبر نہیں ہے"));
      expect(converter.convert('abc'), equals("نمبر نہیں ہے"));
      expect(converter.convert([]), equals("نمبر نہیں ہے"));
      expect(converter.convert({}), equals("نمبر نہیں ہے"));
      expect(converter.convert(Object()), equals("نمبر نہیں ہے"));
      expect(converterWithFallback.convert(double.nan), equals("غلط نمبر"));
      expect(converterWithFallback.convert(double.infinity), equals("لامحدود"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("منفی لامحدود"));
      expect(converterWithFallback.convert(null), equals("غلط نمبر"));
      expect(converterWithFallback.convert('abc'), equals("غلط نمبر"));
      expect(converterWithFallback.convert([]), equals("غلط نمبر"));
      expect(converterWithFallback.convert({}), equals("غلط نمبر"));
      expect(converterWithFallback.convert(Object()), equals("غلط نمبر"));
      expect(converterWithFallback.convert(123), equals("ایک سو تیئس"));
    });
  });
}
