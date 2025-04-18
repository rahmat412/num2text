import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Urdu (UR)', () {
    final converter = Num2Text(initialLang: Lang.UR);
    final converterWithFallback =
        Num2Text(initialLang: Lang.UR, fallbackOnError: "غلط نمبر");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("صفر"));
      expect(converter.convert(1), equals("ایک"));
      expect(converter.convert(2), equals("دو"));
      expect(converter.convert(3), equals("تین"));
      expect(converter.convert(4), equals("چار"));
      expect(converter.convert(5), equals("پانچ"));
      expect(converter.convert(6), equals("چھ"));
      expect(converter.convert(7), equals("سات"));
      expect(converter.convert(8), equals("آٹھ"));
      expect(converter.convert(9), equals("نو"));
      expect(converter.convert(10), equals("دس"));
      expect(converter.convert(11), equals("گیارہ"));
      expect(converter.convert(12), equals("بارہ"));
      expect(converter.convert(13), equals("تیرہ"));
      expect(converter.convert(14), equals("چودہ"));
      expect(converter.convert(15), equals("پندرہ"));
      expect(converter.convert(16), equals("سولہ"));
      expect(converter.convert(17), equals("سترہ"));
      expect(converter.convert(18), equals("اٹھارہ"));
      expect(converter.convert(19), equals("انیس"));
      expect(converter.convert(20), equals("بیس"));
      expect(converter.convert(21), equals("اکیس"));
      expect(converter.convert(30), equals("تیس"));
      expect(converter.convert(40), equals("چالیس"));
      expect(converter.convert(50), equals("پچاس"));
      expect(converter.convert(60), equals("ساٹھ"));
      expect(converter.convert(70), equals("ستر"));
      expect(converter.convert(80), equals("اسی"));
      expect(converter.convert(90), equals("نوے"));
      expect(converter.convert(99), equals("ننانوے"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("ایک سو"));
      expect(converter.convert(101), equals("ایک سو ایک"));
      expect(converter.convert(111), equals("ایک سو گیارہ"));
      expect(converter.convert(200), equals("دو سو"));
      expect(converter.convert(999), equals("نو سو ننانوے"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("ایک ہزار"));
      expect(converter.convert(1001), equals("ایک ہزار ایک"));
      expect(converter.convert(1111), equals("ایک ہزار ایک سو گیارہ"));
      expect(converter.convert(2000), equals("دو ہزار"));
      expect(converter.convert(10000), equals("دس ہزار"));
      expect(converter.convert(100000), equals("ایک لاکھ"));
      expect(
          converter.convert(123456), equals("ایک لاکھ تیئس ہزار چار سو چھپن"));
      expect(converter.convert(999999),
          equals("نو لاکھ ننانوے ہزار نو سو ننانوے"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("منفی ایک"));
      expect(converter.convert(-123), equals("منفی ایک سو تیئس"));
      expect(
        converter.convert(-1, options: UrOptions(negativePrefix: "منفی کا")),
        equals("منفی کا ایک"),
      );
      expect(
        converter.convert(-123, options: UrOptions(negativePrefix: "منفی کا")),
        equals("منفی کا ایک سو تیئس"),
      );
    });

    test('Year Formatting', () {
      const yearOption = UrOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption), equals("انیس سو"));
      expect(converter.convert(2024, options: yearOption),
          equals("دو ہزار چوبیس"));
      expect(converter.convert(1900, options: UrOptions(format: Format.year)),
          equals("انیس سو"));
      expect(
        converter.convert(2024, options: UrOptions(format: Format.year)),
        equals("دو ہزار چوبیس"),
      );
      expect(
          converter.convert(-100, options: yearOption), equals("منفی ایک سو"));
      expect(converter.convert(-1, options: yearOption), equals("منفی ایک"));
      expect(
        converter.convert(-2024, options: UrOptions(format: Format.year)),
        equals("منفی دو ہزار چوبیس"),
      );
    });

    test('Currency', () {
      const currencyOption = UrOptions(currency: true);
      expect(converter.convert(0, options: currencyOption), equals("صفر روپے"));
      expect(
          converter.convert(1, options: currencyOption), equals("ایک روپیہ"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("ایک روپیہ اور پچاس پیسے"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("ایک سو تیئس روپے اور پینتالیس پیسے"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("ایک سو تیئس اعشاریہ چار پانچ چھ"),
      );
      expect(
          converter.convert(Decimal.parse('1.50')), equals("ایک اعشاریہ پانچ"));
      expect(converter.convert(123.0), equals("ایک سو تیئس"));
      expect(converter.convert(Decimal.parse('123.0')), equals("ایک سو تیئس"));
      expect(
        converter.convert(1.5,
            options: const UrOptions(decimalSeparator: DecimalSeparator.point)),
        equals("ایک اعشاریہ پانچ"),
      );
      expect(
        converter.convert(1.5,
            options: const UrOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("ایک کوما پانچ"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("لامحدود"));
      expect(
          converter.convert(double.negativeInfinity), equals("منفی لامحدود"));
      expect(converter.convert(double.nan), equals("نمبر نہیں ہے"));
      expect(converter.convert(null), equals("نمبر نہیں ہے"));
      expect(converter.convert('abc'), equals("نمبر نہیں ہے"));

      expect(converterWithFallback.convert(double.infinity), equals("لامحدود"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("منفی لامحدود"));
      expect(converterWithFallback.convert(double.nan), equals("غلط نمبر"));
      expect(converterWithFallback.convert(null), equals("غلط نمبر"));
      expect(converterWithFallback.convert('abc'), equals("غلط نمبر"));
      expect(converterWithFallback.convert(123), equals("ایک سو تیئس"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(100000)), equals("ایک لاکھ"));
      expect(converter.convert(BigInt.from(1000000)), equals("دس لاکھ"));
      expect(converter.convert(BigInt.from(10000000)), equals("ایک کروڑ"));
      expect(converter.convert(BigInt.from(100000000)), equals("دس کروڑ"));
      expect(converter.convert(BigInt.from(1000000000)), equals("ایک ارب"));
      expect(converter.convert(BigInt.from(10000000000)), equals("دس ارب"));
      expect(converter.convert(BigInt.from(100000000000)), equals("ایک کھرب"));
      expect(converter.convert(BigInt.from(1000000000000)), equals("دس کھرب"));
      expect(converter.convert(BigInt.from(10000000000000)), equals("ایک نیل"));
      expect(converter.convert(BigInt.from(100000000000000)), equals("دس نیل"));
      expect(
          converter.convert(BigInt.from(1000000000000000)), equals("ایک پدم"));
      expect(
          converter.convert(BigInt.from(10000000000000000)), equals("دس پدم"));
      expect(converter.convert(BigInt.from(100000000000000000)),
          equals("ایک سنکھ"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("دس سنکھ"));
      expect(
        converter.convert(BigInt.parse('123456789012345678901234')),
        equals(
          "ایک جلد تیئس انک پینتالیس مہاسنکھ سڑسٹھ سنکھ نواسی پدم ایک نیل تیئس کھرب پینتالیس ارب سڑسٹھ کروڑ نواسی لاکھ ایک ہزار دو سو چونتیس",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "نو جلد ننانوے انک ننانوے مہاسنکھ ننانوے سنکھ ننانوے پدم ننانوے نیل ننانوے کھرب ننانوے ارب ننانوے کروڑ ننانوے لاکھ ننانوے ہزار نو سو ننانوے",
        ),
      );
    });
  });
}
