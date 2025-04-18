import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Khmer (KM)', () {
    final converter = Num2Text(initialLang: Lang.KM);
    final converterWithFallback = Num2Text(
      initialLang: Lang.KM,
      fallbackOnError: "តម្លៃមិនត្រឹមត្រូវ",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("សូន្យ"));
      expect(converter.convert(1), equals("មួយ"));
      expect(converter.convert(2), equals("ពីរ"));
      expect(converter.convert(3), equals("បី"));
      expect(converter.convert(4), equals("បួន"));
      expect(converter.convert(5), equals("ប្រាំ"));
      expect(converter.convert(6), equals("ប្រាំមួយ"));
      expect(converter.convert(7), equals("ប្រាំពីរ"));
      expect(converter.convert(8), equals("ប្រាំបី"));
      expect(converter.convert(9), equals("ប្រាំបួន"));
      expect(converter.convert(10), equals("ដប់"));
      expect(converter.convert(11), equals("ដប់មួយ"));
      expect(converter.convert(12), equals("ដប់ពីរ"));
      expect(converter.convert(20), equals("ម្ភៃ"));
      expect(converter.convert(21), equals("ម្ភៃមួយ"));
      expect(converter.convert(99), equals("កៅសិបប្រាំបួន"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("មួយរយ"));
      expect(converter.convert(101), equals("មួយរយមួយ"));
      expect(converter.convert(111), equals("មួយរយដប់មួយ"));
      expect(converter.convert(200), equals("ពីររយ"));
      expect(converter.convert(999), equals("ប្រាំបួនរយកៅសិបប្រាំបួន"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("មួយពាន់"));

      expect(converter.convert(1001), equals("មួយពាន់ មួយ"));

      expect(converter.convert(1111), equals("មួយពាន់ មួយរយដប់មួយ"));
      expect(converter.convert(2000), equals("ពីរពាន់"));
      expect(converter.convert(10000), equals("មួយម៉ឺន"));
      expect(converter.convert(100000), equals("មួយសែន"));

      expect(converter.convert(123456),
          equals("មួយសែន ពីរម៉ឺន បីពាន់ បួនរយហាសិបប្រាំមួយ"));

      expect(
        converter.convert(999999),
        equals("ប្រាំបួនសែន ប្រាំបួនម៉ឺន ប្រាំបួនពាន់ ប្រាំបួនរយកៅសិបប្រាំបួន"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("ដក មួយ"));
      expect(converter.convert(-123), equals("ដក មួយរយម្ភៃបី"));
      expect(
        converter.convert(-1, options: KmOptions(negativePrefix: "អវិជ្ជមាន")),
        equals("អវិជ្ជមាន មួយ"),
      );
      expect(
        converter.convert(-123,
            options: KmOptions(negativePrefix: "អវិជ្ជមាន")),
        equals("អវិជ្ជមាន មួយរយម្ភៃបី"),
      );
    });

    test('Year Formatting', () {
      const yearOption = KmOptions(format: Format.year);

      expect(converter.convert(1900, options: yearOption),
          equals("មួយពាន់ ប្រាំបួនរយ"));

      expect(converter.convert(2024, options: yearOption),
          equals("ពីរពាន់ ម្ភៃបួន"));
      expect(
        converter.convert(1900,
            options: KmOptions(format: Format.year, includeAD: true)),
        equals("មួយពាន់ ប្រាំបួនរយ គ.ស"),
      );
      expect(
        converter.convert(2024,
            options: KmOptions(format: Format.year, includeAD: true)),
        equals("ពីរពាន់ ម្ភៃបួន គ.ស"),
      );
      expect(
          converter.convert(-100, options: yearOption), equals("មួយរយ ម.គ.ស"));
      expect(converter.convert(-1, options: yearOption), equals("មួយ ម.គ.ស"));
      expect(
        converter.convert(-2024,
            options: KmOptions(format: Format.year, includeAD: true)),
        equals("ពីរពាន់ ម្ភៃបួន ម.គ.ស"),
      );
      expect(
        converter.convert(-2024, options: KmOptions(format: Format.year)),
        equals("ពីរពាន់ ម្ភៃបួន ម.គ.ស"),
      );
    });

    test('Currency', () {
      const currencyOption = KmOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("សូន្យ រៀល"));
      expect(converter.convert(1, options: currencyOption), equals("មួយ រៀល"));

      expect(
          converter.convert(1.50, options: currencyOption), equals("មួយ រៀល"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("មួយរយម្ភៃបី រៀល"));
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("មួយរយម្ភៃបី ចុច បួន ប្រាំ ប្រាំមួយ"),
      );

      expect(converter.convert(Decimal.parse('1.50')), equals("មួយ ចុច ប្រាំ"));
      expect(converter.convert(123.0), equals("មួយរយម្ភៃបី"));
      expect(converter.convert(Decimal.parse('123.0')), equals("មួយរយម្ភៃបី"));
      expect(
        converter.convert(1.5,
            options: const KmOptions(decimalSeparator: DecimalSeparator.point)),
        equals("មួយ ចុច ប្រាំ"),
      );
      expect(
        converter.convert(1.5,
            options: const KmOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("មួយ ក្បៀស ប្រាំ"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("ភាពមិនចេះចប់"));
      expect(converter.convert(double.negativeInfinity),
          equals("អវិជ្ជមានភាពមិនចេះចប់"));
      expect(converter.convert(double.nan), equals("មិនមែនជាលេខ"));
      expect(converter.convert(null), equals("មិនមែនជាលេខ"));
      expect(converter.convert('abc'), equals("មិនមែនជាលេខ"));

      expect(converterWithFallback.convert(double.infinity),
          equals("ភាពមិនចេះចប់"));
      expect(
        converterWithFallback.convert(double.negativeInfinity),
        equals("អវិជ្ជមានភាពមិនចេះចប់"),
      );
      expect(converterWithFallback.convert(double.nan),
          equals("តម្លៃមិនត្រឹមត្រូវ"));
      expect(converterWithFallback.convert(null), equals("តម្លៃមិនត្រឹមត្រូវ"));
      expect(
          converterWithFallback.convert('abc'), equals("តម្លៃមិនត្រឹមត្រូវ"));
      expect(converterWithFallback.convert(123), equals("មួយរយម្ភៃបី"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("មួយលាន"));
      expect(converter.convert(BigInt.from(1000000000)), equals("មួយពាន់លាន"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("មួយលានលាន"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("មួយពាន់លានលាន"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("មួយលានលានលាន"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("មួយពាន់លានលានលាន"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("មួយលានលានលានលាន"),
      );

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "មួយរយម្ភៃបីពាន់លានលានលាន បួនរយហាសិបប្រាំមួយលានលានលាន ប្រាំពីររយប៉ែតសិបប្រាំបួនពាន់លានលាន មួយរយម្ភៃបីលានលាន បួនរយហាសិបប្រាំមួយពាន់លាន ប្រាំពីររយប៉ែតសិបប្រាំបួនលាន មួយសែន ពីរម៉ឺន បីពាន់ បួនរយហាសិបប្រាំមួយ",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "ប្រាំបួនរយកៅសិបប្រាំបួនពាន់លានលានលាន ប្រាំបួនរយកៅសិបប្រាំបួនលានលានលាន ប្រាំបួនរយកៅសិបប្រាំបួនពាន់លានលាន ប្រាំបួនរយកៅសិបប្រាំបួនលានលាន ប្រាំបួនរយកៅសិបប្រាំបួនពាន់លាន ប្រាំបួនរយកៅសិបប្រាំបួនលាន ប្រាំបួនសែន ប្រាំបួនម៉ឺន ប្រាំបួនពាន់ ប្រាំបួនរយកៅសិបប្រាំបួន",
        ),
      );
    });
  });
}
