import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Persian (FA)', () {
    final converter = Num2Text(initialLang: Lang.FA);
    final converterWithFallback =
        Num2Text(initialLang: Lang.FA, fallbackOnError: "عدد نامعتبر");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("صفر"));
      expect(converter.convert(1), equals("یک"));
      expect(converter.convert(10), equals("ده"));
      expect(converter.convert(11), equals("یازده"));
      expect(converter.convert(20), equals("بیست"));
      expect(converter.convert(21), equals("بیست و یک"));
      expect(converter.convert(99), equals("نود و نه"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("صد"));
      expect(converter.convert(101), equals("صد و یک"));
      expect(converter.convert(111), equals("صد و یازده"));
      expect(converter.convert(200), equals("دویست"));
      expect(converter.convert(999), equals("نهصد و نود و نه"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("یک هزار"));
      expect(converter.convert(1001), equals("یک هزار و یک"));
      expect(converter.convert(1111), equals("یک هزار و صد و یازده"));
      expect(converter.convert(2000), equals("دو هزار"));
      expect(converter.convert(10000), equals("ده هزار"));
      expect(converter.convert(100000), equals("صد هزار"));
      expect(converter.convert(123456),
          equals("صد و بیست و سه هزار و چهارصد و پنجاه و شش"));
      expect(converter.convert(999999),
          equals("نهصد و نود و نه هزار و نهصد و نود و نه"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("منفی یک"));
      expect(converter.convert(-123), equals("منفی صد و بیست و سه"));
      expect(
        converter.convert(-1, options: FaOptions(negativePrefix: "زیر صفر")),
        equals("زیر صفر یک"),
      );
      expect(
        converter.convert(-123, options: FaOptions(negativePrefix: "زیر صفر")),
        equals("زیر صفر صد و بیست و سه"),
      );
    });

    test('Year Formatting', () {
      const yearOption = FaOptions(format: Format.year);
      expect(
          converter.convert(1900, options: yearOption), equals("هزار و نهصد"));
      expect(converter.convert(2024, options: yearOption),
          equals("دو هزار و بیست و چهار"));
      expect(
        converter.convert(1900,
            options: FaOptions(format: Format.year, includeAD: true)),
        equals("هزار و نهصد میلادی"),
      );
      expect(
        converter.convert(2024,
            options: FaOptions(format: Format.year, includeAD: true)),
        equals("دو هزار و بیست و چهار میلادی"),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("صد پیش از میلاد"));
      expect(converter.convert(-1, options: yearOption),
          equals("یک پیش از میلاد"));

      expect(
        converter.convert(-2024,
            options: FaOptions(format: Format.year, includeAD: true)),
        equals("دو هزار و بیست و چهار پیش از میلاد"),
      );
    });

    test('Currency', () {
      const currencyOption = FaOptions(currency: true);

      expect(converter.convert(0, options: currencyOption), equals("صفر ریال"));
      expect(converter.convert(1, options: currencyOption), equals("یک ریال"));

      expect(
          converter.convert(1.50, options: currencyOption), equals("یک ریال"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("صد و بیست و سه ریال"));
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("صد و بیست و سه ممیز چهار پنج شش"),
      );

      expect(converter.convert(Decimal.parse('1.50')), equals("یک ممیز پنج"));
      expect(converter.convert(123.0), equals("صد و بیست و سه"));
      expect(
          converter.convert(Decimal.parse('123.0')), equals("صد و بیست و سه"));

      expect(
        converter.convert(1.5,
            options: const FaOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("یک ممیز پنج"),
      );
      expect(
        converter.convert(1.5,
            options:
                const FaOptions(decimalSeparator: DecimalSeparator.period)),
        equals("یک ممیز پنج"),
      );
      expect(
        converter.convert(1.5,
            options: const FaOptions(decimalSeparator: DecimalSeparator.point)),
        equals("یک ممیز پنج"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("بی نهایت"));
      expect(
          converter.convert(double.negativeInfinity), equals("منفی بی نهایت"));
      expect(converter.convert(double.nan), equals("عدد نیست"));
      expect(converter.convert(null), equals("عدد نیست"));
      expect(converter.convert('abc'), equals("عدد نیست"));

      expect(
          converterWithFallback.convert(double.infinity), equals("بی نهایت"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("منفی بی نهایت"));
      expect(converterWithFallback.convert(double.nan), equals("عدد نامعتبر"));
      expect(converterWithFallback.convert(null), equals("عدد نامعتبر"));
      expect(converterWithFallback.convert('abc'), equals("عدد نامعتبر"));
      expect(converterWithFallback.convert(123), equals("صد و بیست و سه"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("یک میلیون"));
      expect(converter.convert(BigInt.from(1000000000)), equals("یک میلیارد"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("یک تریلیون"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("یک کوادریلیون"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("یک کوئینتیلیون"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("یک سکستیلیون"));
      expect(converter.convert(BigInt.parse('1000000000000000000000000')),
          equals("یک سپتیلیون"));

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "صد و بیست و سه سکستیلیون و چهارصد و پنجاه و شش کوئینتیلیون و هفتصد و هشتاد و نه کوادریلیون و صد و بیست و سه تریلیون و چهارصد و پنجاه و شش میلیارد و هفتصد و هشتاد و نه میلیون و صد و بیست و سه هزار و چهارصد و پنجاه و شش",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "نهصد و نود و نه سکستیلیون و نهصد و نود و نه کوئینتیلیون و نهصد و نود و نه کوادریلیون و نهصد و نود و نه تریلیون و نهصد و نود و نه میلیارد و نهصد و نود و نه میلیون و نهصد و نود و نه هزار و نهصد و نود و نه",
        ),
      );
    });
  });
}
