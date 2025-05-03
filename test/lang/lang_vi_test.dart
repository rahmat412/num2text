import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Vietnamese (VI)', () {
    final converter = Num2Text(initialLang: Lang.VI);
    final converterWithFallback =
        Num2Text(initialLang: Lang.VI, fallbackOnError: "Giá Trị Không Hợp Lệ");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("không"));
      expect(converter.convert(10), equals("mười"));
      expect(converter.convert(11), equals("mười một"));
      expect(converter.convert(13), equals("mười ba"));
      expect(converter.convert(15), equals("mười lăm"));
      expect(converter.convert(20), equals("hai mươi"));
      expect(converter.convert(21), equals("hai mươi mốt"));
      expect(converter.convert(25), equals("hai mươi lăm"));
      expect(converter.convert(27), equals("hai mươi bảy"));
      expect(converter.convert(30), equals("ba mươi"));
      expect(converter.convert(54), equals("năm mươi bốn"));
      expect(converter.convert(68), equals("sáu mươi tám"));
      expect(converter.convert(99), equals("chín mươi chín"));
    });

    test('Hundreds (100 - 999) with useLinh', () {
      const options = ViOptions(useLe: false);
      expect(converter.convert(100, options: options), equals("một trăm"));
      expect(converter.convert(101, options: options),
          equals("một trăm linh một"));
      expect(converter.convert(105, options: options),
          equals("một trăm linh năm"));
      expect(converter.convert(110, options: options), equals("một trăm mười"));
      expect(converter.convert(111, options: options),
          equals("một trăm mười một"));
      expect(converter.convert(115, options: options),
          equals("một trăm mười lăm"));
      expect(converter.convert(123, options: options),
          equals("một trăm hai mươi ba"));
      expect(converter.convert(200, options: options), equals("hai trăm"));
      expect(converter.convert(321, options: options),
          equals("ba trăm hai mươi mốt"));
      expect(converter.convert(479, options: options),
          equals("bốn trăm bảy mươi chín"));
      expect(converter.convert(596, options: options),
          equals("năm trăm chín mươi sáu"));
      expect(converter.convert(681, options: options),
          equals("sáu trăm tám mươi mốt"));
      expect(converter.convert(999, options: options),
          equals("chín trăm chín mươi chín"));
    });

    test('Hundreds (100 - 999) with useLe', () {
      const options = ViOptions(useLe: true);
      expect(converter.convert(100, options: options), equals("một trăm"));
      expect(
          converter.convert(101, options: options), equals("một trăm lẻ một"));
      expect(
          converter.convert(105, options: options), equals("một trăm lẻ năm"));
      expect(converter.convert(110, options: options), equals("một trăm mười"));
      expect(converter.convert(111, options: options),
          equals("một trăm mười một"));
      expect(converter.convert(115, options: options),
          equals("một trăm mười lăm"));
      expect(converter.convert(123, options: options),
          equals("một trăm hai mươi ba"));
      expect(converter.convert(200, options: options), equals("hai trăm"));
      expect(converter.convert(321, options: options),
          equals("ba trăm hai mươi mốt"));
      expect(converter.convert(479, options: options),
          equals("bốn trăm bảy mươi chín"));
      expect(converter.convert(596, options: options),
          equals("năm trăm chín mươi sáu"));
      expect(converter.convert(681, options: options),
          equals("sáu trăm tám mươi mốt"));
      expect(converter.convert(999, options: options),
          equals("chín trăm chín mươi chín"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("một nghìn"));
      expect(converter.convert(1001), equals("một nghìn không trăm linh một"));
      expect(converter.convert(1005), equals("một nghìn không trăm linh năm"));
      expect(converter.convert(1011), equals("một nghìn không trăm mười một"));
      expect(converter.convert(1110), equals("một nghìn một trăm mười"));
      expect(converter.convert(1111), equals("một nghìn một trăm mười một"));
      expect(converter.convert(2000), equals("hai nghìn"));
      expect(
          converter.convert(2468), equals("hai nghìn bốn trăm sáu mươi tám"));
      expect(
          converter.convert(3579), equals("ba nghìn năm trăm bảy mươi chín"));
      expect(converter.convert(5000), equals("năm nghìn"));
      expect(converter.convert(10000), equals("mười nghìn"));
      expect(
          converter.convert(10011), equals("mười nghìn không trăm mười một"));
      expect(converter.convert(11100), equals("mười một nghìn một trăm"));
      expect(converter.convert(12987),
          equals("mười hai nghìn chín trăm tám mươi bảy"));
      expect(converter.convert(15000), equals("mười lăm nghìn"));
      expect(converter.convert(45623),
          equals("bốn mươi lăm nghìn sáu trăm hai mươi ba"));
      expect(converter.convert(87654),
          equals("tám mươi bảy nghìn sáu trăm năm mươi bốn"));
      expect(converter.convert(100000), equals("một trăm nghìn"));
      expect(converter.convert(123456),
          equals("một trăm hai mươi ba nghìn bốn trăm năm mươi sáu"));
      expect(converter.convert(987654),
          equals("chín trăm tám mươi bảy nghìn sáu trăm năm mươi bốn"));
      expect(converter.convert(999999),
          equals("chín trăm chín mươi chín nghìn chín trăm chín mươi chín"));
    });

    test('Negative Numbers', () {
      const negativeOption = ViOptions(negativePrefix: "trừ");
      expect(converter.convert(-1), equals("âm một"));
      expect(converter.convert(-123), equals("âm một trăm hai mươi ba"));
      expect(converter.convert(-123.456),
          equals("âm một trăm hai mươi ba phẩy bốn năm sáu"));
      expect(converter.convert(-1, options: negativeOption), equals("trừ một"));
      expect(converter.convert(-123, options: negativeOption),
          equals("trừ một trăm hai mươi ba"));
      expect(
        converter.convert(-123.456, options: negativeOption),
        equals("trừ một trăm hai mươi ba phẩy bốn năm sáu"),
      );
    });

    test('Decimals', () {
      const pointOption = ViOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = ViOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = ViOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(123.456),
          equals("một trăm hai mươi ba phẩy bốn năm sáu"));
      expect(converter.convert(1.5), equals("một phẩy năm"));
      expect(converter.convert(1.05), equals("một phẩy không năm"));
      expect(converter.convert(879.465),
          equals("tám trăm bảy mươi chín phẩy bốn sáu năm"));
      expect(
          converter.convert(1.5, options: pointOption), equals("một chấm năm"));
      expect(
          converter.convert(1.5, options: commaOption), equals("một phẩy năm"));
      expect(converter.convert(1.5, options: periodOption),
          equals("một chấm năm"));
    });

    test('Year Formatting', () {
      const yearOption = ViOptions(format: Format.year);
      const yearOptionAD = ViOptions(format: Format.year, includeAD: true);
      expect(converter.convert(123, options: yearOption),
          equals("một trăm hai mươi ba"));
      expect(converter.convert(498, options: yearOption),
          equals("bốn trăm chín mươi tám"));
      expect(converter.convert(756, options: yearOption),
          equals("bảy trăm năm mươi sáu"));
      expect(converter.convert(1900, options: yearOption),
          equals("một nghìn chín trăm"));
      expect(converter.convert(1999, options: yearOption),
          equals("một nghìn chín trăm chín mươi chín"));
      expect(converter.convert(2024, options: yearOption),
          equals("hai nghìn không trăm hai mươi tư"));
      expect(converter.convert(2025, options: yearOption),
          equals("hai nghìn không trăm hai mươi lăm"));
      expect(converter.convert(1900, options: yearOptionAD),
          equals("một nghìn chín trăm Sau Công Nguyên"));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("một nghìn chín trăm chín mươi chín Sau Công Nguyên"));
      expect(converter.convert(2024, options: yearOptionAD),
          equals("hai nghìn không trăm hai mươi tư Sau Công Nguyên"));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("hai nghìn không trăm hai mươi lăm Sau Công Nguyên"));
      expect(converter.convert(-1, options: yearOption),
          equals("một Trước Công Nguyên"));
      expect(converter.convert(-100, options: yearOption),
          equals("một trăm Trước Công Nguyên"));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("một trăm Trước Công Nguyên"));
      expect(converter.convert(-2025, options: yearOption),
          equals("hai nghìn không trăm hai mươi lăm Trước Công Nguyên"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("một triệu Trước Công Nguyên"));
    });

    test('Currency', () {
      const currencyOption = ViOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("không đồng"));
      expect(converter.convert(1, options: currencyOption), equals("một đồng"));
      expect(converter.convert(5, options: currencyOption), equals("năm đồng"));
      expect(
          converter.convert(10, options: currencyOption), equals("mười đồng"));
      expect(converter.convert(11, options: currencyOption),
          equals("mười một đồng"));
      expect(
          converter.convert(1.5, options: currencyOption), equals("một đồng"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("một trăm hai mươi ba đồng"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("mười triệu đồng"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("không đồng"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("không đồng"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("một triệu"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("hai tỷ"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("ba nghìn tỷ"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("bốn triệu tỷ"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("năm tỷ tỷ"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("sáu nghìn tỷ tỷ"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("bảy triệu tỷ tỷ"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('một nghìn tỷ linh hai triệu linh ba'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("năm triệu một nghìn"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("một tỷ linh một"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("một tỷ một triệu"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("hai triệu một nghìn"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "một nghìn tỷ linh chín trăm tám mươi bảy triệu sáu trăm nghìn không trăm linh ba"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              'chín tỷ tỷ tám trăm bảy mươi sáu triệu tỷ năm trăm bốn mươi ba nghìn tỷ hai trăm mười tỷ một trăm hai mươi ba triệu bốn trăm năm mươi sáu nghìn bảy trăm tám mươi chín'));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              'một trăm hai mươi ba nghìn tỷ tỷ bốn trăm năm mươi sáu tỷ tỷ bảy trăm tám mươi chín triệu tỷ một trăm hai mươi ba nghìn tỷ bốn trăm năm mươi sáu tỷ bảy trăm tám mươi chín triệu một trăm hai mươi ba nghìn bốn trăm năm mươi sáu'));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              'chín trăm chín mươi chín nghìn tỷ tỷ chín trăm chín mươi chín tỷ tỷ chín trăm chín mươi chín triệu tỷ chín trăm chín mươi chín nghìn tỷ chín trăm chín mươi chín tỷ chín trăm chín mươi chín triệu chín trăm chín mươi chín nghìn chín trăm chín mươi chín'));
    });

    test('Edge Cases with Linh/Lẻ', () {
      expect(converter.convert(1000001), equals("một triệu linh một"));
      expect(converter.convert(1001000), equals("một triệu một nghìn"));
      expect(converter.convert(1001001),
          equals("một triệu một nghìn không trăm linh một"));
      expect(converter.convert(1000000001), equals("một tỷ linh một"));
      expect(converter.convert(1000001000), equals("một tỷ linh một nghìn"));
      const leOptions = ViOptions(useLe: true);
      expect(converter.convert(1000001, options: leOptions),
          equals("một triệu lẻ một"));
      expect(converter.convert(1001001, options: leOptions),
          equals("một triệu một nghìn không trăm lẻ một"));
      expect(converter.convert(1000000001, options: leOptions),
          equals("một tỷ lẻ một"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Không Phải Là Số"));
      expect(converter.convert(double.infinity), equals("Vô Cực"));
      expect(converter.convert(double.negativeInfinity), equals("Âm Vô Cực"));
      expect(converter.convert(null), equals("Không Phải Là Số"));
      expect(converter.convert('abc'), equals("Không Phải Là Số"));
      expect(converter.convert([]), equals("Không Phải Là Số"));
      expect(converter.convert({}), equals("Không Phải Là Số"));
      expect(converter.convert(Object()), equals("Không Phải Là Số"));
      expect(converterWithFallback.convert(double.nan),
          equals("Giá Trị Không Hợp Lệ"));
      expect(converterWithFallback.convert(double.infinity), equals("Vô Cực"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Âm Vô Cực"));
      expect(
          converterWithFallback.convert(null), equals("Giá Trị Không Hợp Lệ"));
      expect(
          converterWithFallback.convert('abc'), equals("Giá Trị Không Hợp Lệ"));
      expect(converterWithFallback.convert([]), equals("Giá Trị Không Hợp Lệ"));
      expect(converterWithFallback.convert({}), equals("Giá Trị Không Hợp Lệ"));
      expect(converterWithFallback.convert(Object()),
          equals("Giá Trị Không Hợp Lệ"));
      expect(
          converterWithFallback.convert(123), equals("một trăm hai mươi ba"));
    });
  });
}
