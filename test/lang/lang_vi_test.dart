import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Vietnamese (VI)', () {
    final converter = Num2Text(initialLang: Lang.VI);
    final converterWithFallback = Num2Text(
      initialLang: Lang.VI,
      fallbackOnError: "Giá trị không hợp lệ",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("không"));
      expect(converter.convert(1), equals("một"));
      expect(converter.convert(4), equals("bốn"));
      expect(converter.convert(5), equals("năm"));
      expect(converter.convert(10), equals("mười"));
      expect(converter.convert(11), equals("mười một"));
      expect(converter.convert(15), equals("mười lăm"));
      expect(converter.convert(20), equals("hai mươi"));
      expect(converter.convert(21), equals("hai mươi mốt"));
      expect(converter.convert(25), equals("hai mươi lăm"));
      expect(converter.convert(99), equals("chín mươi chín"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("một trăm"));
      expect(converter.convert(101), equals("một trăm linh một"));
      expect(converter.convert(105), equals("một trăm linh năm"));
      expect(converter.convert(111), equals("một trăm mười một"));
      expect(converter.convert(115), equals("một trăm mười lăm"));
      expect(converter.convert(200), equals("hai trăm"));
      expect(converter.convert(999), equals("chín trăm chín mươi chín"));
    });

    test('Hundreds with useLe option', () {
      expect(
        converter.convert(101, options: const ViOptions(useLe: true)),
        equals("một trăm lẻ một"),
      );
      expect(
        converter.convert(105, options: const ViOptions(useLe: true)),
        equals("một trăm lẻ năm"),
      );
      expect(
        converter.convert(111, options: const ViOptions(useLe: true)),
        equals("một trăm mười một"),
      );
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("một nghìn"));
      expect(converter.convert(1001), equals("một nghìn không trăm linh một"));
      expect(converter.convert(1005), equals("một nghìn không trăm linh năm"));
      expect(converter.convert(1111), equals("một nghìn một trăm mười một"));
      expect(converter.convert(2000), equals("hai nghìn"));
      expect(converter.convert(5000), equals("năm nghìn"));
      expect(converter.convert(10000), equals("mười nghìn"));
      expect(converter.convert(15000), equals("mười lăm nghìn"));
      expect(converter.convert(100000), equals("một trăm nghìn"));
      expect(converter.convert(123456),
          equals("một trăm hai mươi ba nghìn bốn trăm năm mươi sáu"));
      expect(
        converter.convert(999999),
        equals("chín trăm chín mươi chín nghìn chín trăm chín mươi chín"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("âm một"));
      expect(converter.convert(-123), equals("âm một trăm hai mươi ba"));
      expect(converter.convert(-1, options: ViOptions(negativePrefix: "trừ")),
          equals("trừ một"));
      expect(
        converter.convert(-123, options: ViOptions(negativePrefix: "trừ")),
        equals("trừ một trăm hai mươi ba"),
      );
    });

    test('Year Formatting', () {
      const yearOption = ViOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("một nghìn chín trăm"));
      expect(
        converter.convert(2024, options: yearOption),
        equals("hai nghìn không trăm hai mươi tư"),
      );
      expect(
        converter.convert(1900,
            options: ViOptions(format: Format.year, includeAD: true)),
        equals("một nghìn chín trăm Sau Công Nguyên"),
      );
      expect(
        converter.convert(2024,
            options: ViOptions(format: Format.year, includeAD: true)),
        equals("hai nghìn không trăm hai mươi tư Sau Công Nguyên"),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("một trăm Trước Công Nguyên"));
      expect(converter.convert(-1, options: yearOption),
          equals("một Trước Công Nguyên"));
      expect(
        converter.convert(-2024,
            options: ViOptions(format: Format.year, includeAD: true)),
        equals("hai nghìn không trăm hai mươi tư Trước Công Nguyên"),
      );
    });

    test('Currency', () {
      const currencyOption = ViOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("không đồng"));
      expect(converter.convert(1, options: currencyOption), equals("một đồng"));
      expect(
          converter.convert(1.50, options: currencyOption), equals("một đồng"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("một trăm hai mươi ba đồng"),
      );
      expect(converter.convert(1000, options: currencyOption),
          equals("một nghìn đồng"));
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("một trăm hai mươi ba phẩy bốn năm sáu"),
      );
      expect(converter.convert(Decimal.parse('1.50')), equals("một phẩy năm"));
      expect(converter.convert(Decimal.parse('1.05')),
          equals("một phẩy không năm"));
      expect(converter.convert(123.0), equals("một trăm hai mươi ba"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("một trăm hai mươi ba"));
      expect(
        converter.convert(1.5,
            options: const ViOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("một phẩy năm"),
      );
      expect(
        converter.convert(1.5,
            options:
                const ViOptions(decimalSeparator: DecimalSeparator.period)),
        equals("một chấm năm"),
      );
      expect(
        converter.convert(1.5,
            options: const ViOptions(decimalSeparator: DecimalSeparator.point)),
        equals("một chấm năm"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Vô cực"));
      expect(converter.convert(double.negativeInfinity), equals("Âm vô cực"));
      expect(converter.convert(double.nan), equals("Không phải là số"));
      expect(converter.convert(null), equals("Không phải là số"));
      expect(converter.convert('abc'), equals("Không phải là số"));

      expect(converterWithFallback.convert(double.infinity), equals("Vô cực"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Âm vô cực"));
      expect(converterWithFallback.convert(double.nan),
          equals("Giá trị không hợp lệ"));
      expect(
          converterWithFallback.convert(null), equals("Giá trị không hợp lệ"));
      expect(
          converterWithFallback.convert('abc'), equals("Giá trị không hợp lệ"));
      expect(
          converterWithFallback.convert(123), equals("một trăm hai mươi ba"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("một triệu"));
      expect(converter.convert(BigInt.from(1000000000)), equals("một tỷ"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("một nghìn tỷ"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("một triệu tỷ"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("một tỷ tỷ"));
      expect(
        converter.convert(BigInt.parse('123456789123456789')),
        equals(
          "một trăm hai mươi ba triệu tỷ bốn trăm năm mươi sáu nghìn tỷ bảy trăm tám mươi chín tỷ một trăm hai mươi ba triệu bốn trăm năm mươi sáu nghìn bảy trăm tám mươi chín",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999')),
        equals(
          "chín trăm chín mươi chín triệu tỷ chín trăm chín mươi chín nghìn tỷ chín trăm chín mươi chín tỷ chín trăm chín mươi chín triệu chín trăm chín mươi chín nghìn chín trăm chín mươi chín",
        ),
      );
    });
  });
}
