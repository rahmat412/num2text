import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Korean (KO)', () {
    final converter = Num2Text(initialLang: Lang.KO);
    final converterWithFallback =
        Num2Text(initialLang: Lang.KO, fallbackOnError: "유효하지 않은 숫자");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("영"));
      expect(converter.convert(10), equals("십"));
      expect(converter.convert(11), equals("십일"));
      expect(converter.convert(13), equals("십삼"));
      expect(converter.convert(15), equals("십오"));
      expect(converter.convert(20), equals("이십"));
      expect(converter.convert(27), equals("이십칠"));
      expect(converter.convert(30), equals("삼십"));
      expect(converter.convert(54), equals("오십사"));
      expect(converter.convert(68), equals("육십팔"));
      expect(converter.convert(99), equals("구십구"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("백"));
      expect(converter.convert(101), equals("백일"));
      expect(converter.convert(105), equals("백오"));
      expect(converter.convert(110), equals("백십"));
      expect(converter.convert(111), equals("백십일"));
      expect(converter.convert(123), equals("백이십삼"));
      expect(converter.convert(200), equals("이백"));
      expect(converter.convert(321), equals("삼백이십일"));
      expect(converter.convert(479), equals("사백칠십구"));
      expect(converter.convert(596), equals("오백구십육"));
      expect(converter.convert(681), equals("육백팔십일"));
      expect(converter.convert(999), equals("구백구십구"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("천"));
      expect(converter.convert(1001), equals("천일"));
      expect(converter.convert(1011), equals("천십일"));
      expect(converter.convert(1110), equals("천백십"));
      expect(converter.convert(1111), equals("천백십일"));
      expect(converter.convert(2000), equals("이천"));
      expect(converter.convert(2468), equals("이천사백육십팔"));
      expect(converter.convert(3579), equals("삼천오백칠십구"));
      expect(converter.convert(10000), equals("만"));
      expect(converter.convert(10011), equals("만십일"));
      expect(converter.convert(11100), equals("만천백"));
      expect(converter.convert(12987), equals("만이천구백팔십칠"));
      expect(converter.convert(45623), equals("사만오천육백이십삼"));
      expect(converter.convert(87654), equals("팔만칠천육백오십사"));
      expect(converter.convert(100000), equals("십만"));
      expect(converter.convert(123456), equals("십이만삼천사백오십육"));
      expect(converter.convert(987654), equals("구십팔만칠천육백오십사"));
      expect(converter.convert(999999), equals("구십구만구천구백구십구"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("마이너스 일"));
      expect(converter.convert(-123), equals("마이너스 백이십삼"));
      expect(converter.convert(-123.456), equals("마이너스 백이십삼 점 사오육"));

      const options1 = KoOptions(negativePrefix: "음수");
      expect(converter.convert(-1, options: options1), equals("음수 일"));
      expect(converter.convert(-123, options: options1), equals("음수 백이십삼"));
      expect(converter.convert(-123.456, options: options1),
          equals("음수 백이십삼 점 사오육"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456), equals("백이십삼 점 사오육"));
      expect(converter.convert("1.5"), equals("일 점 오"));
      expect(converter.convert(1.05), equals("일 점 영오"));
      expect(converter.convert(879.465), equals("팔백칠십구 점 사육오"));
      expect(converter.convert(1.5), equals("일 점 오"));

      const pointOption = KoOptions(decimalSeparator: DecimalSeparator.point);
      expect(converter.convert(1.5, options: pointOption), equals("일 점 오"));

      const commaOption = KoOptions(decimalSeparator: DecimalSeparator.comma);
      expect(converter.convert(1.5, options: commaOption), equals("일 쉼표 오"));

      const periodOption = KoOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(1.5, options: periodOption), equals("일 점 오"));
    });

    test('Year Formatting', () {
      const yearOption = KoOptions(format: Format.year);
      expect(converter.convert(123, options: yearOption), equals("백이십삼"));
      expect(converter.convert(498, options: yearOption), equals("사백구십팔"));
      expect(converter.convert(756, options: yearOption), equals("칠백오십육"));
      expect(converter.convert(1900, options: yearOption), equals("천구백"));
      expect(converter.convert(1999, options: yearOption), equals("천구백구십구"));
      expect(converter.convert(2025, options: yearOption), equals("이천이십오"));

      const yearOptionAD = KoOptions(format: Format.year, includeAD: true);
      expect(converter.convert(1900, options: yearOptionAD), equals("서기 천구백"));
      expect(
          converter.convert(1999, options: yearOptionAD), equals("서기 천구백구십구"));
      expect(
          converter.convert(2025, options: yearOptionAD), equals("서기 이천이십오"));
      expect(converter.convert(-1, options: yearOption), equals("기원전 일"));
      expect(converter.convert(-100, options: yearOption), equals("기원전 백"));
      expect(converter.convert(-100, options: yearOptionAD), equals("기원전 백"));
      expect(
          converter.convert(-2025, options: yearOption), equals("기원전 이천이십오"));
      expect(
          converter.convert(-1000000, options: yearOption), equals("기원전 백만"));
    });

    test('Currency', () {
      const currencyOption = KoOptions(currency: true);
      expect(converter.convert(0, options: currencyOption), equals("영 원"));
      expect(converter.convert(1, options: currencyOption), equals("일 원"));
      expect(converter.convert(5, options: currencyOption), equals("오 원"));
      expect(converter.convert(10, options: currencyOption), equals("십 원"));
      expect(converter.convert(11, options: currencyOption), equals("십일 원"));
      expect(converter.convert(1.50, options: currencyOption), equals("일 원"));
      expect(
          converter.convert(123.45, options: currencyOption), equals("백이십삼 원"));
      expect(
          converter.convert(10000000, options: currencyOption), equals("천만 원"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("백만"));
      expect(converter.convert(BigInt.from(10).pow(8)), equals("억"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("이십억"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("삼조"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(16)),
          equals("사경"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(20)),
          equals("오해"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(24)),
          equals("육자"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals("구백팔십칠경육천오백사십삼조이천백일억이천삼백사십오만육천칠백팔십구"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals("천이백삼십사해오천육백칠십팔경구천백이십삼조사천오백육십칠억팔천구백십이만삼천사백오십육"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals('구천구백구십구해구천구백구십구경구천구백구십구조구천구백구십구억구천구백구십구만구천구백구십구'),
      );

      expect(
          converter.convert(BigInt.parse('1000002000003')), equals("일조이백만삼"));
      expect(converter.convert(BigInt.parse('5001000')), equals("오백만천"));
      expect(converter.convert(BigInt.parse('1000000001')), equals("십억일"));
      expect(converter.convert(BigInt.parse('1001000000')), equals('십억백만'));
      expect(converter.convert(BigInt.parse('2001000')), equals("이백만천"));
      expect(converter.convert(BigInt.parse('1000987600003')),
          equals("일조구억팔천칠백육십만삼"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("숫자가 아님"));
      expect(converter.convert(double.infinity), equals("무한대"));
      expect(converter.convert(double.negativeInfinity), equals("음의 무한대"));
      expect(converter.convert(null), equals("숫자가 아님"));
      expect(converter.convert('abc'), equals("숫자가 아님"));
      expect(converter.convert([]), equals("숫자가 아님"));
      expect(converter.convert({}), equals("숫자가 아님"));
      expect(converter.convert(Object()), equals("숫자가 아님"));

      expect(converterWithFallback.convert(double.nan), equals("유효하지 않은 숫자"));
      expect(converterWithFallback.convert(double.infinity), equals("무한대"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("음의 무한대"));
      expect(converterWithFallback.convert(null), equals("유효하지 않은 숫자"));
      expect(converterWithFallback.convert('abc'), equals("유효하지 않은 숫자"));
      expect(converterWithFallback.convert([]), equals("유효하지 않은 숫자"));
      expect(converterWithFallback.convert({}), equals("유효하지 않은 숫자"));
      expect(converterWithFallback.convert(Object()), equals("유효하지 않은 숫자"));
      expect(converterWithFallback.convert(123), equals("백이십삼"));
    });
  });
}
