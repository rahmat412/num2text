import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Khmer (KM)', () {
    final converter = Num2Text(initialLang: Lang.KM);
    final converterWithFallback = Num2Text(
      initialLang: Lang.KM,
      fallbackOnError: "តម្លៃមិនត្រឹមត្រូវ",
    );

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("សូន្យ"));
      expect(converter.convert(10), equals("ដប់"));
      expect(converter.convert(11), equals("ដប់មួយ"));
      expect(converter.convert(13), equals("ដប់បី"));
      expect(converter.convert(15), equals("ដប់ប្រាំ"));
      expect(converter.convert(20), equals("ម្ភៃ"));
      expect(converter.convert(27), equals("ម្ភៃប្រាំពីរ"));
      expect(converter.convert(30), equals("សាមសិប"));
      expect(converter.convert(54), equals("ហាសិបបួន"));
      expect(converter.convert(68), equals("ហុកសិបប្រាំបី"));
      expect(converter.convert(99), equals("កៅសិបប្រាំបួន"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("មួយរយ"));
      expect(converter.convert(101), equals("មួយរយមួយ"));
      expect(converter.convert(105), equals("មួយរយប្រាំ"));
      expect(converter.convert(110), equals("មួយរយដប់"));
      expect(converter.convert(111), equals("មួយរយដប់មួយ"));
      expect(converter.convert(123), equals("មួយរយម្ភៃបី"));
      expect(converter.convert(200), equals("ពីររយ"));
      expect(converter.convert(321), equals("បីរយម្ភៃមួយ"));
      expect(converter.convert(479), equals("បួនរយចិតសិបប្រាំបួន"));
      expect(converter.convert(596), equals("ប្រាំរយកៅសិបប្រាំមួយ"));
      expect(converter.convert(681), equals("ប្រាំមួយរយប៉ែតសិបមួយ"));
      expect(converter.convert(999), equals("ប្រាំបួនរយកៅសិបប្រាំបួន"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("មួយពាន់"));
      expect(converter.convert(1001), equals("មួយពាន់មួយ"));
      expect(converter.convert(1011), equals("មួយពាន់ដប់មួយ"));
      expect(converter.convert(1110), equals("មួយពាន់មួយរយដប់"));
      expect(converter.convert(1111), equals("មួយពាន់មួយរយដប់មួយ"));
      expect(converter.convert(2000), equals("ពីរពាន់"));
      expect(converter.convert(2468), equals("ពីរពាន់បួនរយហុកសិបប្រាំបី"));
      expect(converter.convert(3579), equals("បីពាន់ប្រាំរយចិតសិបប្រាំបួន"));
      expect(converter.convert(10000), equals("មួយម៉ឺន"));
      expect(converter.convert(10011), equals("មួយម៉ឺនដប់មួយ"));
      expect(converter.convert(11100), equals("មួយម៉ឺនមួយពាន់មួយរយ"));
      expect(converter.convert(12987),
          equals("មួយម៉ឺនពីរពាន់ប្រាំបួនរយប៉ែតសិបប្រាំពីរ"));
      expect(
          converter.convert(45623), equals("បួនម៉ឺនប្រាំពាន់ប្រាំមួយរយម្ភៃបី"));
      expect(converter.convert(87654),
          equals("ប្រាំបីម៉ឺនប្រាំពីរពាន់ប្រាំមួយរយហាសិបបួន"));
      expect(converter.convert(100000), equals("មួយសែន"));
      expect(converter.convert(123456),
          equals("មួយសែនពីរម៉ឺនបីពាន់បួនរយហាសិបប្រាំមួយ"));
      expect(converter.convert(987654),
          equals("ប្រាំបួនសែនប្រាំបីម៉ឺនប្រាំពីរពាន់ប្រាំមួយរយហាសិបបួន"));
      expect(converter.convert(999999),
          equals("ប្រាំបួនសែនប្រាំបួនម៉ឺនប្រាំបួនពាន់ប្រាំបួនរយកៅសិបប្រាំបួន"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("ដក មួយ"));
      expect(converter.convert(-123), equals("ដក មួយរយម្ភៃបី"));
      expect(converter.convert(-123.456),
          equals("ដក មួយរយម្ភៃបី ចុច បួន ប្រាំ ប្រាំមួយ"));

      const options1 = KmOptions(negativePrefix: "អវិជ្ជមាន");
      expect(converter.convert(-1, options: options1), equals("អវិជ្ជមាន មួយ"));
      expect(converter.convert(-123, options: options1),
          equals("អវិជ្ជមាន មួយរយម្ភៃបី"));
      expect(converter.convert(-123.456, options: options1),
          equals("អវិជ្ជមាន មួយរយម្ភៃបី ចុច បួន ប្រាំ ប្រាំមួយ"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456),
          equals("មួយរយម្ភៃបី ចុច បួន ប្រាំ ប្រាំមួយ"));
      expect(converter.convert("1.5"), equals("មួយ ចុច ប្រាំ"));
      expect(converter.convert(1.05), equals("មួយ ចុច សូន្យ ប្រាំ"));
      expect(converter.convert(879.465),
          equals("ប្រាំបីរយចិតសិបប្រាំបួន ចុច បួន ប្រាំមួយ ប្រាំ"));
      expect(converter.convert(1.5), equals("មួយ ចុច ប្រាំ"));

      const pointOption = KmOptions(decimalSeparator: DecimalSeparator.point);
      expect(converter.convert(1.5, options: pointOption),
          equals("មួយ ចុច ប្រាំ"));

      const commaOption = KmOptions(decimalSeparator: DecimalSeparator.comma);
      expect(converter.convert(1.5, options: commaOption),
          equals("មួយ ក្បៀស ប្រាំ"));

      const periodOption = KmOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(1.5, options: periodOption),
          equals("មួយ ចុច ប្រាំ"));
    });

    test('Year Formatting', () {
      const yearOption = KmOptions(format: Format.year);
      expect(
          converter.convert(123, options: yearOption), equals("មួយរយម្ភៃបី"));
      expect(converter.convert(498, options: yearOption),
          equals("បួនរយកៅសិបប្រាំបី"));
      expect(converter.convert(756, options: yearOption),
          equals("ប្រាំពីររយហាសិបប្រាំមួយ"));
      expect(converter.convert(1900, options: yearOption),
          equals("មួយពាន់ប្រាំបួនរយ"));
      expect(converter.convert(1999, options: yearOption),
          equals("មួយពាន់ប្រាំបួនរយកៅសិបប្រាំបួន"));
      expect(converter.convert(2025, options: yearOption),
          equals("ពីរពាន់ម្ភៃប្រាំ"));

      const yearOptionAD = KmOptions(format: Format.year, includeAD: true);
      expect(converter.convert(1900, options: yearOptionAD),
          equals("មួយពាន់ប្រាំបួនរយ គ.ស."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("មួយពាន់ប្រាំបួនរយកៅសិបប្រាំបួន គ.ស."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("ពីរពាន់ម្ភៃប្រាំ គ.ស."));
      expect(
          converter.convert(-1, options: yearOption), equals("មួយ មុន គ.ស."));
      expect(converter.convert(-100, options: yearOption),
          equals("មួយរយ មុន គ.ស."));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("មួយរយ មុន គ.ស."));
      expect(converter.convert(-2025, options: yearOption),
          equals("ពីរពាន់ម្ភៃប្រាំ មុន គ.ស."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("មួយលាន មុន គ.ស."));
    });

    test('Currency', () {
      const currencyOption = KmOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("សូន្យ រៀល"));
      expect(converter.convert(1, options: currencyOption), equals("មួយ រៀល"));
      expect(
          converter.convert(5, options: currencyOption), equals("ប្រាំ រៀល"));
      expect(converter.convert(10, options: currencyOption), equals("ដប់ រៀល"));
      expect(
          converter.convert(11, options: currencyOption), equals("ដប់មួយ រៀល"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("មួយ រៀល ហាសិប សេន"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("មួយរយម្ភៃបី រៀល សែសិបប្រាំ សេន"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("ដប់លាន រៀល"));
      expect(
          converter.convert(0.5, options: currencyOption), equals("ហាសិប សេន"));
      expect(
          converter.convert(0.01, options: currencyOption), equals("មួយ សេន"));
      expect(
          converter.convert(0.02, options: currencyOption), equals("ពីរ សេន"));
      expect(
          converter.convert(0.03, options: currencyOption), equals("បី សេន"));
      expect(
          converter.convert(0.10, options: currencyOption), equals("ដប់ សេន"));
      expect(converter.convert(0.11, options: currencyOption),
          equals("ដប់មួយ សេន"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("មួយលាន"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("ពីរពាន់លាន"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("បីលានលាន"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("បួនពាន់លានលាន"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("ប្រាំលានលានលាន"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("ប្រាំមួយពាន់លានលានលាន"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("ប្រាំពីរលានលានលានលាន"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "ប្រាំបួនលានលានលាន ប្រាំបីរយចិតសិបប្រាំមួយពាន់លានលាន ប្រាំរយសែសិបបីលានលាន ពីររយដប់ពាន់លាន មួយរយម្ភៃបីលាន បួនសែនប្រាំម៉ឺនប្រាំមួយពាន់ប្រាំពីររយប៉ែតសិបប្រាំបួន"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "មួយរយម្ភៃបីពាន់លានលានលាន បួនរយហាសិបប្រាំមួយលានលានលាន ប្រាំពីររយប៉ែតសិបប្រាំបួនពាន់លានលាន មួយរយម្ភៃបីលានលាន បួនរយហាសិបប្រាំមួយពាន់លាន ប្រាំពីររយប៉ែតសិបប្រាំបួនលាន មួយសែនពីរម៉ឺនបីពាន់បួនរយហាសិបប្រាំមួយ"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              'ប្រាំបួនរយកៅសិបប្រាំបួនពាន់លានលានលាន ប្រាំបួនរយកៅសិបប្រាំបួនលានលានលាន ប្រាំបួនរយកៅសិបប្រាំបួនពាន់លានលាន ប្រាំបួនរយកៅសិបប្រាំបួនលានលាន ប្រាំបួនរយកៅសិបប្រាំបួនពាន់លាន ប្រាំបួនរយកៅសិបប្រាំបួនលាន ប្រាំបួនសែនប្រាំបួនម៉ឺនប្រាំបួនពាន់ប្រាំបួនរយកៅសិបប្រាំបួន'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("មិនមែនជាលេខ"));
      expect(converter.convert(double.infinity), equals("អនន្ត"));
      expect(
          converter.convert(double.negativeInfinity), equals("អនន្តអវិជ្ជមាន"));
      expect(converter.convert(null), equals("មិនមែនជាលេខ"));
      expect(converter.convert('abc'), equals("មិនមែនជាលេខ"));
      expect(converter.convert([]), equals("មិនមែនជាលេខ"));
      expect(converter.convert({}), equals("មិនមែនជាលេខ"));
      expect(converter.convert(Object()), equals("មិនមែនជាលេខ"));

      expect(converterWithFallback.convert(double.nan),
          equals("តម្លៃមិនត្រឹមត្រូវ"));
      expect(converterWithFallback.convert(double.infinity), equals("អនន្ត"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("អនន្តអវិជ្ជមាន"));
      expect(converterWithFallback.convert(null), equals("តម្លៃមិនត្រឹមត្រូវ"));
      expect(
          converterWithFallback.convert('abc'), equals("តម្លៃមិនត្រឹមត្រូវ"));
      expect(converterWithFallback.convert([]), equals("តម្លៃមិនត្រឹមត្រូវ"));
      expect(converterWithFallback.convert({}), equals("តម្លៃមិនត្រឹមត្រូវ"));
      expect(converterWithFallback.convert(Object()),
          equals("តម្លៃមិនត្រឹមត្រូវ"));
      expect(converterWithFallback.convert(123), equals("មួយរយម្ភៃបី"));
    });
  });
}
