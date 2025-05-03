import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Persian (FA)', () {
    final converter = Num2Text(initialLang: Lang.FA);
    final converterWithFallback =
        Num2Text(initialLang: Lang.FA, fallbackOnError: "عدد نامعتبر");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("صفر"));
      expect(converter.convert(10), equals("ده"));
      expect(converter.convert(11), equals("یازده"));
      expect(converter.convert(13), equals("سیزده"));
      expect(converter.convert(15), equals("پانزده"));
      expect(converter.convert(20), equals("بیست"));
      expect(converter.convert(21), equals("بیست و یک"));
      expect(converter.convert(27), equals("بیست و هفت"));
      expect(converter.convert(30), equals("سی"));
      expect(converter.convert(54), equals("پنجاه و چهار"));
      expect(converter.convert(68), equals("شصت و هشت"));
      expect(converter.convert(99), equals("نود و نه"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("صد"));
      expect(converter.convert(101), equals("صد و یک"));
      expect(converter.convert(105), equals("صد و پنج"));
      expect(converter.convert(110), equals("صد و ده"));
      expect(converter.convert(111), equals("صد و یازده"));
      expect(converter.convert(123), equals("صد و بیست و سه"));
      expect(converter.convert(200), equals("دویست"));
      expect(converter.convert(321), equals("سیصد و بیست و یک"));
      expect(converter.convert(479), equals("چهارصد و هفتاد و نه"));
      expect(converter.convert(596), equals("پانصد و نود و شش"));
      expect(converter.convert(681), equals("ششصد و هشتاد و یک"));
      expect(converter.convert(999), equals("نهصد و نود و نه"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("یک هزار"));
      expect(converter.convert(1001), equals("یک هزار و یک"));
      expect(converter.convert(1011), equals("یک هزار و یازده"));
      expect(converter.convert(1110), equals("یک هزار و صد و ده"));
      expect(converter.convert(1111), equals("یک هزار و صد و یازده"));
      expect(converter.convert(2000), equals("دو هزار"));
      expect(converter.convert(2468), equals("دو هزار و چهارصد و شصت و هشت"));
      expect(converter.convert(3579), equals("سه هزار و پانصد و هفتاد و نه"));
      expect(converter.convert(10000), equals("ده هزار"));
      expect(converter.convert(10011), equals("ده هزار و یازده"));
      expect(converter.convert(11100), equals("یازده هزار و صد"));
      expect(
          converter.convert(12987), equals("دوازده هزار و نهصد و هشتاد و هفت"));
      expect(converter.convert(45623),
          equals("چهل و پنج هزار و ششصد و بیست و سه"));
      expect(converter.convert(87654),
          equals("هشتاد و هفت هزار و ششصد و پنجاه و چهار"));
      expect(converter.convert(100000), equals("صد هزار"));
      expect(converter.convert(123456),
          equals("صد و بیست و سه هزار و چهارصد و پنجاه و شش"));
      expect(converter.convert(987654),
          equals("نهصد و هشتاد و هفت هزار و ششصد و پنجاه و چهار"));
      expect(converter.convert(999999),
          equals("نهصد و نود و نه هزار و نهصد و نود و نه"));
    });

    test('Negative Numbers', () {
      const negativePrefixOption = FaOptions(negativePrefix: "زیر صفر");

      expect(converter.convert(-1), equals("منفی یک"));
      expect(converter.convert(-123), equals("منفی صد و بیست و سه"));
      expect(converter.convert(-123.456),
          equals("منفی صد و بیست و سه ممیز چهار پنج شش"));

      expect(converter.convert(-1, options: negativePrefixOption),
          equals("زیر صفر یک"));
      expect(converter.convert(-123, options: negativePrefixOption),
          equals("زیر صفر صد و بیست و سه"));
      expect(converter.convert(-123.456, options: negativePrefixOption),
          equals("زیر صفر صد و بیست و سه ممیز چهار پنج شش"));
    });

    test('Decimals', () {
      const pointOption = FaOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = FaOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = FaOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(123.456),
          equals("صد و بیست و سه ممیز چهار پنج شش"));
      expect(converter.convert(1.5), equals("یک ممیز پنج"));
      expect(converter.convert(1.05), equals("یک ممیز صفر پنج"));
      expect(converter.convert(879.465),
          equals("هشتصد و هفتاد و نه ممیز چهار شش پنج"));
      expect(converter.convert(1.5), equals("یک ممیز پنج"));

      expect(
          converter.convert(1.5, options: pointOption), equals("یک ممیز پنج"));
      expect(
          converter.convert(1.5, options: commaOption), equals("یک ممیز پنج"));
      expect(
          converter.convert(1.5, options: periodOption), equals("یک ممیز پنج"));
    });

    test('Year Formatting', () {
      const yearOption = FaOptions(format: Format.year);
      const yearOptionAD = FaOptions(format: Format.year, includeAD: true);

      expect(converter.convert(123, options: yearOption),
          equals("صد و بیست و سه"));
      expect(converter.convert(498, options: yearOption),
          equals("چهارصد و نود و هشت"));
      expect(converter.convert(756, options: yearOption),
          equals("هفتصد و پنجاه و شش"));
      expect(
          converter.convert(1900, options: yearOption), equals("هزار و نهصد"));
      expect(converter.convert(1999, options: yearOption),
          equals("هزار و نهصد و نود و نه"));
      expect(converter.convert(2025, options: yearOption),
          equals("دو هزار و بیست و پنج"));

      expect(converter.convert(1900, options: yearOptionAD),
          equals("هزار و نهصد میلادی"));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("هزار و نهصد و نود و نه میلادی"));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("دو هزار و بیست و پنج میلادی"));
      expect(converter.convert(-1, options: yearOption),
          equals("یک پیش از میلاد"));
      expect(converter.convert(-100, options: yearOption),
          equals("صد پیش از میلاد"));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("صد پیش از میلاد"));
      expect(converter.convert(-2025, options: yearOption),
          equals("دو هزار و بیست و پنج پیش از میلاد"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("یک میلیون پیش از میلاد"));
    });

    test('Currency', () {
      const currencyOption = FaOptions(currency: true);

      expect(converter.convert(0, options: currencyOption), equals("صفر ریال"));
      expect(converter.convert(1, options: currencyOption), equals("یک ریال"));
      expect(converter.convert(5, options: currencyOption), equals("پنج ریال"));
      expect(converter.convert(10, options: currencyOption), equals("ده ریال"));
      expect(
          converter.convert(11, options: currencyOption), equals("یازده ریال"));
      expect(
          converter.convert(1.5, options: currencyOption), equals("یک ریال"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("صد و بیست و سه ریال"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("ده میلیون ریال"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("یک میلیون"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("دو میلیارد"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("سه تریلیون"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("چهار کوادریلیون"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("پنج کوئینتیلیون"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("شش سکستیلیون"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("هفت سپتیلیون"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "نه کوئینتیلیون و هشتصد و هفتاد و شش کوادریلیون و پانصد و چهل و سه تریلیون و دویست و ده میلیارد و صد و بیست و سه میلیون و چهارصد و پنجاه و شش هزار و هفتصد و هشتاد و نه"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "صد و بیست و سه سکستیلیون و چهارصد و پنجاه و شش کوئینتیلیون و هفتصد و هشتاد و نه کوادریلیون و صد و بیست و سه تریلیون و چهارصد و پنجاه و شش میلیارد و هفتصد و هشتاد و نه میلیون و صد و بیست و سه هزار و چهارصد و پنجاه و شش"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "نهصد و نود و نه سکستیلیون و نهصد و نود و نه کوئینتیلیون و نهصد و نود و نه کوادریلیون و نهصد و نود و نه تریلیون و نهصد و نود و نه میلیارد و نهصد و نود و نه میلیون و نهصد و نود و نه هزار و نهصد و نود و نه"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("یک تریلیون و دو میلیون و سه"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("پنج میلیون و یک هزار"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("یک میلیارد و یک"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("یک میلیارد و یک میلیون"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("دو میلیون و یک هزار"));
      expect(converter.convert(BigInt.parse('1000987600003')),
          equals("یک تریلیون و نهصد و هشتاد و هفت میلیون و ششصد هزار و سه"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("عدد نیست"));
      expect(converter.convert(double.infinity), equals("بی نهایت"));
      expect(
          converter.convert(double.negativeInfinity), equals("منفی بی نهایت"));
      expect(converter.convert(null), equals("عدد نیست"));
      expect(converter.convert('abc'), equals("عدد نیست"));
      expect(converter.convert([]), equals("عدد نیست"));
      expect(converter.convert({}), equals("عدد نیست"));
      expect(converter.convert(Object()), equals("عدد نیست"));

      expect(converterWithFallback.convert(double.nan), equals("عدد نامعتبر"));
      expect(
          converterWithFallback.convert(double.infinity), equals("بی نهایت"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("منفی بی نهایت"));
      expect(converterWithFallback.convert(null), equals("عدد نامعتبر"));
      expect(converterWithFallback.convert('abc'), equals("عدد نامعتبر"));
      expect(converterWithFallback.convert([]), equals("عدد نامعتبر"));
      expect(converterWithFallback.convert({}), equals("عدد نامعتبر"));
      expect(converterWithFallback.convert(Object()), equals("عدد نامعتبر"));
      expect(converterWithFallback.convert(123), equals("صد و بیست و سه"));
    });
  });
}
