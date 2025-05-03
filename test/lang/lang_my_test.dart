import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Burmese (MY)', () {
    final converter = Num2Text(initialLang: Lang.MY);
    final converterWithFallback =
        Num2Text(initialLang: Lang.MY, fallbackOnError: "မမှန်ကန်သော နံပါတ်");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("သုည"));
      expect(converter.convert(10), equals("တစ်ဆယ်"));
      expect(converter.convert(11), equals("တစ်ဆယ့်တစ်"));
      expect(converter.convert(13), equals("တစ်ဆယ့်သုံး"));
      expect(converter.convert(15), equals("တစ်ဆယ့်ငါး"));
      expect(converter.convert(20), equals("နှစ်ဆယ်"));
      expect(converter.convert(27), equals("နှစ်ဆယ့်ခုနစ်"));
      expect(converter.convert(30), equals("သုံးဆယ်"));
      expect(converter.convert(54), equals("ငါးဆယ့်လေး"));
      expect(converter.convert(68), equals("ခြောက်ဆယ့်ရှစ်"));
      expect(converter.convert(99), equals("ကိုးဆယ့်ကိုး"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("တစ်ရာ"));
      expect(converter.convert(101), equals("တစ်ရာ့တစ်"));
      expect(converter.convert(105), equals("တစ်ရာ့ငါး"));
      expect(converter.convert(110), equals("တစ်ရာ့တစ်ဆယ်"));
      expect(converter.convert(111), equals("တစ်ရာ့တစ်ဆယ့်တစ်"));
      expect(converter.convert(123), equals("တစ်ရာ့နှစ်ဆယ့်သုံး"));
      expect(converter.convert(200), equals("နှစ်ရာ"));
      expect(converter.convert(321), equals("သုံးရာ့နှစ်ဆယ့်တစ်"));
      expect(converter.convert(479), equals("လေးရာ့ခုနစ်ဆယ့်ကိုး"));
      expect(converter.convert(596), equals("ငါးရာ့ကိုးဆယ့်ခြောက်"));
      expect(converter.convert(681), equals("ခြောက်ရာ့ရှစ်ဆယ့်တစ်"));
      expect(converter.convert(999), equals("ကိုးရာ့ကိုးဆယ့်ကိုး"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("တစ်ထောင်"));
      expect(converter.convert(1001), equals("တစ်ထောင့်တစ်"));
      expect(converter.convert(1011), equals("တစ်ထောင့်တစ်ဆယ့်တစ်"));
      expect(converter.convert(1110), equals("တစ်ထောင့်တစ်ရာ့တစ်ဆယ်"));
      expect(converter.convert(1111), equals("တစ်ထောင့်တစ်ရာ့တစ်ဆယ့်တစ်"));
      expect(converter.convert(2000), equals("နှစ်ထောင်"));
      expect(converter.convert(2468), equals("နှစ်ထောင့်လေးရာ့ခြောက်ဆယ့်ရှစ်"));
      expect(converter.convert(3579), equals("သုံးထောင့်ငါးရာ့ခုနစ်ဆယ့်ကိုး"));
      expect(converter.convert(10000), equals("တစ်သောင်း"));
      expect(converter.convert(10011), equals("တစ်သောင်း့တစ်ဆယ့်တစ်"));
      expect(converter.convert(11100), equals("တစ်သောင်း့တစ်ထောင့်တစ်ရာ"));
      expect(converter.convert(12987),
          equals("တစ်သောင်း့နှစ်ထောင့်ကိုးရာ့ရှစ်ဆယ့်ခုနစ်"));
      expect(converter.convert(45623),
          equals("လေးသောင်း့ငါးထောင့်ခြောက်ရာ့နှစ်ဆယ့်သုံး"));
      expect(converter.convert(87654),
          equals("ရှစ်သောင်း့ခုနစ်ထောင့်ခြောက်ရာ့ငါးဆယ့်လေး"));
      expect(converter.convert(100000), equals("တစ်သိန်း"));
      expect(converter.convert(123456),
          equals("တစ်သိန်း နှစ်သောင်း့သုံးထောင့်လေးရာ့ငါးဆယ့်ခြောက်"));
      expect(converter.convert(987654),
          equals("ကိုးသိန်း ရှစ်သောင်း့ခုနစ်ထောင့်ခြောက်ရာ့ငါးဆယ့်လေး"));
      expect(converter.convert(999999),
          equals("ကိုးသိန်း ကိုးသောင်း့ကိုးထောင့်ကိုးရာ့ကိုးဆယ့်ကိုး"));
    });

    test('Negative Numbers', () {
      const negOption = MyOptions(negativePrefix: "minus");
      expect(converter.convert(-1), equals("အနုတ် တစ်"));
      expect(converter.convert(-123), equals("အနုတ် တစ်ရာ့နှစ်ဆယ့်သုံး"));
      expect(converter.convert(-123.456),
          equals("အနုတ် တစ်ရာ့နှစ်ဆယ့်သုံး ဒသမ လေး ငါး ခြောက်"));
      expect(converter.convert(-1, options: negOption), equals("minus တစ်"));
      expect(converter.convert(-123, options: negOption),
          equals("minus တစ်ရာ့နှစ်ဆယ့်သုံး"));
      expect(converter.convert(-123.456, options: negOption),
          equals("minus တစ်ရာ့နှစ်ဆယ့်သုံး ဒသမ လေး ငါး ခြောက်"));
    });

    test('Decimals', () {
      const pointOption = MyOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = MyOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = MyOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(123.456),
          equals("တစ်ရာ့နှစ်ဆယ့်သုံး ဒသမ လေး ငါး ခြောက်"));
      expect(converter.convert(1.5), equals("တစ် ဒသမ ငါး"));
      expect(converter.convert(1.05), equals("တစ် ဒသမ သုည ငါး"));
      expect(converter.convert(879.465),
          equals("ရှစ်ရာ့ခုနစ်ဆယ့်ကိုး ဒသမ လေး ခြောက် ငါး"));
      expect(
          converter.convert(1.5, options: pointOption), equals("တစ် ဒသမ ငါး"));
      expect(converter.convert(1.5, options: commaOption),
          equals("တစ် ကော်မာ ငါး"));
      expect(
          converter.convert(1.5, options: periodOption), equals("တစ် ဒသမ ငါး"));
    });

    test('Year Formatting', () {
      const yearOption = MyOptions(format: Format.year);
      const yearOptionAD = MyOptions(format: Format.year);
      expect(converter.convert(123, options: yearOption),
          equals("တစ်ရာ့နှစ်ဆယ့်သုံး"));
      expect(converter.convert(498, options: yearOption),
          equals("လေးရာ့ကိုးဆယ့်ရှစ်"));
      expect(converter.convert(756, options: yearOption),
          equals("ခုနစ်ရာ့ငါးဆယ့်ခြောက်"));
      expect(converter.convert(1900, options: yearOption),
          equals("တစ်ထောင့်ကိုးရာ"));
      expect(converter.convert(1999, options: yearOption),
          equals("တစ်ထောင့်ကိုးရာ့ကိုးဆယ့်ကိုး"));
      expect(converter.convert(2025, options: yearOption),
          equals("နှစ်ထောင့်နှစ်ဆယ့်ငါး"));
      expect(converter.convert(1900, options: yearOptionAD),
          equals("တစ်ထောင့်ကိုးရာ"));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("တစ်ထောင့်ကိုးရာ့ကိုးဆယ့်ကိုး"));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("နှစ်ထောင့်နှစ်ဆယ့်ငါး"));
      expect(converter.convert(-1, options: yearOption), equals("အနုတ် တစ်"));
      expect(
          converter.convert(-100, options: yearOption), equals("အနုတ် တစ်ရာ"));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("အနုတ် တစ်ရာ"));
      expect(converter.convert(-2025, options: yearOption),
          equals("အနုတ် နှစ်ထောင့်နှစ်ဆယ့်ငါး"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("အနုတ် တစ်သန်း"));
    });

    test('Currency', () {
      const currencyOption = MyOptions(currency: true);
      expect(converter.convert(0, options: currencyOption), equals("သုည ကျပ်"));
      expect(converter.convert(1, options: currencyOption), equals("တစ် ကျပ်"));
      expect(converter.convert(5, options: currencyOption), equals("ငါး ကျပ်"));
      expect(converter.convert(10, options: currencyOption),
          equals("တစ်ဆယ် ကျပ်"));
      expect(converter.convert(11, options: currencyOption),
          equals("တစ်ဆယ့်တစ် ကျပ်"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("တစ် ကျပ် ငါးဆယ် ပြား"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("တစ်ရာ့နှစ်ဆယ့်သုံး ကျပ် လေးဆယ့်ငါး ပြား"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("တစ်ကုဋေ ကျပ်"));
      expect(converter.convert(0.5), equals("သုည ဒသမ ငါး"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("ငါးဆယ် ပြား"));
      expect(
          converter.convert(0.01, options: currencyOption), equals("တစ် ပြား"));
      expect(converter.convert(0.10, options: currencyOption),
          equals("တစ်ဆယ် ပြား"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("တစ်သန်း"));
      expect(converter.convert(BigInt.from(10).pow(7)), equals("တစ်ကုဋေ"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("နှစ် ဘီလီယံ"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("သုံး ထရီလီယံ"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("လေး ကွာဒရီလီယံ"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("ငါး ကွင်တီလီယံ"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("ခြောက် ဆက်စတီလီယံ"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("ခုနစ် ဆက်ပတီလီယံ"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            "ကိုး ကွင်တီလီယံ ရှစ်ရာ့ခုနစ်ဆယ့်ခြောက် ကွာဒရီလီယံ ငါးရာ့လေးဆယ့်သုံး ထရီလီယံ နှစ်ရာ့တစ်ဆယ် ဘီလီယံ တစ်ဆယ့်နှစ်ကုဋေ သုံးသန်း လေးသိန်း ငါးသောင်း့ခြောက်ထောင့်ခုနစ်ရာ့ရှစ်ဆယ့်ကိုး"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "တစ်ရာ့နှစ်ဆယ့်သုံး ဆက်စတီလီယံ လေးရာ့ငါးဆယ့်ခြောက် ကွင်တီလီယံ ခုနစ်ရာ့ရှစ်ဆယ့်ကိုး ကွာဒရီလီယံ တစ်ရာ့နှစ်ဆယ့်သုံး ထရီလီယံ လေးရာ့ငါးဆယ့်ခြောက် ဘီလီယံ ခုနစ်ဆယ့်ရှစ်ကုဋေ ကိုးသန်း တစ်သိန်း နှစ်သောင်း့သုံးထောင့်လေးရာ့ငါးဆယ့်ခြောက်"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "ကိုးရာ့ကိုးဆယ့်ကိုး ဆက်စတီလီယံ ကိုးရာ့ကိုးဆယ့်ကိုး ကွင်တီလီယံ ကိုးရာ့ကိုးဆယ့်ကိုး ကွာဒရီလီယံ ကိုးရာ့ကိုးဆယ့်ကိုး ထရီလီယံ ကိုးရာ့ကိုးဆယ့်ကိုး ဘီလီယံ ကိုးဆယ့်ကိုးကုဋေ ကိုးသန်း ကိုးသိန်း ကိုးသောင်း့ကိုးထောင့်ကိုးရာ့ကိုးဆယ့်ကိုး"),
      );

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('တစ် ထရီလီယံ နှစ်သန်း သုံး'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("ငါးသန်း တစ်ထောင်"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("တစ် ဘီလီယံ တစ်"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("တစ် ဘီလီယံ တစ်သန်း"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("နှစ်သန်း တစ်ထောင်"));
      expect(converter.convert(BigInt.parse('1000987600003')),
          equals('တစ် ထရီလီယံ ကိုးဆယ့်ရှစ်ကုဋေ ခုနစ်သန်း ခြောက်သိန်း သုံး'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("နံပါတ်မဟုတ်ပါ"));
      expect(converter.convert(double.infinity), equals("အဆုံးမရှိ"));
      expect(converter.convert(double.negativeInfinity),
          equals("အနုတ် အဆုံးမရှိ"));
      expect(converter.convert(null), equals("နံပါတ်မဟုတ်ပါ"));
      expect(converter.convert('abc'), equals("နံပါတ်မဟုတ်ပါ"));
      expect(converter.convert([]), equals("နံပါတ်မဟုတ်ပါ"));
      expect(converter.convert({}), equals("နံပါတ်မဟုတ်ပါ"));
      expect(converter.convert(Object()), equals("နံပါတ်မဟုတ်ပါ"));

      expect(converterWithFallback.convert(double.nan),
          equals("မမှန်ကန်သော နံပါတ်"));
      expect(
          converterWithFallback.convert(double.infinity), equals("အဆုံးမရှိ"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("အနုတ် အဆုံးမရှိ"));
      expect(converterWithFallback.convert(null), equals("မမှန်ကန်သော နံပါတ်"));
      expect(
          converterWithFallback.convert('abc'), equals("မမှန်ကန်သော နံပါတ်"));
      expect(converterWithFallback.convert([]), equals("မမှန်ကန်သော နံပါတ်"));
      expect(converterWithFallback.convert({}), equals("မမှန်ကန်သော နံပါတ်"));
      expect(converterWithFallback.convert(Object()),
          equals("မမှန်ကန်သော နံပါတ်"));
      expect(converterWithFallback.convert(123), equals("တစ်ရာ့နှစ်ဆယ့်သုံး"));
    });
  });
}
