import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Burmese (MY)', () {
    final converter = Num2Text(initialLang: Lang.MY);
    final converterWithFallback = Num2Text(
      initialLang: Lang.MY,
      fallbackOnError: "မမှန်ကန်သောနံပါတ်",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("သုည"));
      expect(converter.convert(1), equals("တစ်"));
      expect(converter.convert(10), equals("တစ်ဆယ်"));
      expect(converter.convert(11), equals("တစ်ဆယ့်တစ်"));
      expect(converter.convert(20), equals("နှစ်ဆယ်"));
      expect(converter.convert(21), equals("နှစ်ဆယ့်တစ်"));
      expect(converter.convert(99), equals("ကိုးဆယ့်ကိုး"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("တစ်ရာ"));
      expect(converter.convert(101), equals("တစ်ရာ့တစ်"));
      expect(converter.convert(111), equals("တစ်ရာ့တစ်ဆယ့်တစ်"));
      expect(converter.convert(200), equals("နှစ်ရာ"));
      expect(converter.convert(999), equals("ကိုးရာ့ကိုးဆယ့်ကိုး"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("တစ်ထောင်"));
      expect(converter.convert(1001), equals("တစ်ထောင့်တစ်"));
      expect(converter.convert(1111), equals("တစ်ထောင့်တစ်ရာ့တစ်ဆယ့်တစ်"));
      expect(converter.convert(2000), equals("နှစ်ထောင်"));
      expect(converter.convert(10000), equals("တစ်သောင်း"));
      expect(converter.convert(100000), equals("တစ်သိန်း"));

      expect(
        converter.convert(123456),
        equals("တစ်သိန်း နှစ် သောင်း သုံးထောင့်လေးရာ့ငါးဆယ့်ခြောက်"),
      );

      expect(
        converter.convert(999999),
        equals("ကိုး သိန်း ကိုး သောင်း ကိုးထောင့်ကိုးရာ့ကိုးဆယ့်ကိုး"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("အနုတ် တစ်"));
      expect(converter.convert(-123), equals("အနုတ် တစ်ရာ့နှစ်ဆယ့်သုံး"));

      expect(converter.convert(-1, options: MyOptions(negativePrefix: "ऋण")),
          equals("ऋण တစ်"));
      expect(
        converter.convert(-123, options: MyOptions(negativePrefix: "ऋण")),
        equals("ऋण တစ်ရာ့နှစ်ဆယ့်သုံး"),
      );
    });

    test('Year Formatting', () {
      const yearOption = MyOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("တစ်ထောင့်ကိုးရာ"));
      expect(converter.convert(2024, options: yearOption),
          equals("နှစ်ထောင့်နှစ်ဆယ့်လေး"));
      expect(
          converter.convert(-100, options: yearOption), equals("အနုတ် တစ်ရာ"));
      expect(converter.convert(-1, options: yearOption), equals("အနုတ် တစ်"));
      expect(
        converter.convert(-2024, options: MyOptions(format: Format.year)),
        equals("အနုတ် နှစ်ထောင့်နှစ်ဆယ့်လေး"),
      );
    });

    test('Currency', () {
      const currencyOption = MyOptions(currency: true);
      expect(converter.convert(0, options: currencyOption), equals("သုည ကျပ်"));
      expect(converter.convert(1, options: currencyOption), equals("တစ် ကျပ်"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("တစ် ကျပ် တစ် ပြား"));
      expect(converter.convert(2.50, options: currencyOption),
          equals("နှစ် ကျပ် ငါးဆယ် ပြား"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("တစ်ရာ့နှစ်ဆယ့်သုံး ကျပ် လေးဆယ့်ငါး ပြား"),
      );
      expect(
          converter.convert(2, options: currencyOption), equals("နှစ် ကျပ်"));
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("တစ်ရာ့နှစ်ဆယ့်သုံး ဒသမ လေး ငါး ခြောက်"),
      );
      expect(converter.convert(Decimal.parse('1.50')), equals("တစ် ဒသမ ငါး"));
      expect(converter.convert(123.0), equals("တစ်ရာ့နှစ်ဆယ့်သုံး"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("တစ်ရာ့နှစ်ဆယ့်သုံး"));
      expect(
        converter.convert(1.5,
            options: const MyOptions(decimalSeparator: DecimalSeparator.point)),
        equals("တစ် ဒသမ ငါး"),
      );
      expect(
        converter.convert(1.5,
            options: const MyOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("တစ် ကော်မာ ငါး"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("အဆုံးမရှိ"));
      expect(converter.convert(double.negativeInfinity),
          equals("အနုတ် အဆုံးမရှိ"));
      expect(converter.convert(double.nan), equals("နံပါတ်မဟုတ်ပါ"));
      expect(converter.convert(null), equals("နံပါတ်မဟုတ်ပါ"));
      expect(converter.convert('abc'), equals("နံပါတ်မဟုတ်ပါ"));

      expect(
          converterWithFallback.convert(double.infinity), equals("အဆုံးမရှိ"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("အနုတ် အဆုံးမရှိ"));
      expect(converterWithFallback.convert(double.nan),
          equals("မမှန်ကန်သောနံပါတ်"));
      expect(converterWithFallback.convert(null), equals("မမှန်ကန်သောနံပါတ်"));
      expect(converterWithFallback.convert('abc'), equals("မမှန်ကန်သောနံပါတ်"));
      expect(converterWithFallback.convert(123), equals("တစ်ရာ့နှစ်ဆယ့်သုံး"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("တစ်သန်း"));
      expect(converter.convert(BigInt.from(10000000)), equals("တစ်ကုဋေ"));
      expect(converter.convert(BigInt.from(1000000000)), equals("တစ်ဘီလီယံ"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("တစ်ထရီလီယံ"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("တစ်ကွာဒရီလီယံ"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("တစ်ကွင်တီလီယံ"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("တစ်ဆက်စတီလီယံ"));
      expect(converter.convert(BigInt.parse('1000000000000000000000000')),
          equals("တစ်ဆက်ပတီလီယံ"));

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "တစ်ရာ့နှစ်ဆယ့်သုံး ဆက်စတီလီယံ လေးရာ့ငါးဆယ့်ခြောက် ကွင်တီလီယံ ခုနစ်ရာ့ရှစ်ဆယ့်ကိုး ကွာဒရီလီယံ တစ်ရာ့နှစ်ဆယ့်သုံး ထရီလီယံ လေးရာ့ငါးဆယ့်ခြောက် ဘီလီယံ ခုနစ်ဆယ့်ရှစ် ကုဋေ ကိုး သန်း တစ်သိန်း နှစ် သောင်း သုံးထောင့်လေးရာ့ငါးဆယ့်ခြောက်",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "ကိုးရာ့ကိုးဆယ့်ကိုး ဆက်စတီလီယံ ကိုးရာ့ကိုးဆယ့်ကိုး ကွင်တီလီယံ ကိုးရာ့ကိုးဆယ့်ကိုး ကွာဒရီလီယံ ကိုးရာ့ကိုးဆယ့်ကိုး ထရီလီယံ ကိုးရာ့ကိုးဆယ့်ကိုး ဘီလီယံ ကိုးဆယ့်ကိုး ကုဋေ ကိုး သန်း ကိုး သိန်း ကိုး သောင်း ကိုးထောင့်ကိုးရာ့ကိုးဆယ့်ကိုး",
        ),
      );
    });
  });
}
