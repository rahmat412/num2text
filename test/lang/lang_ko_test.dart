import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Korean (KO)', () {
    final converter = Num2Text(initialLang: Lang.KO);
    final converterWithFallback =
        Num2Text(initialLang: Lang.KO, fallbackOnError: "유효하지 않은 숫자");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("영"));
      expect(converter.convert(1), equals("일"));
      expect(converter.convert(10), equals("십"));
      expect(converter.convert(11), equals("십일"));
      expect(converter.convert(20), equals("이십"));
      expect(converter.convert(21), equals("이십일"));
      expect(converter.convert(99), equals("구십구"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("백"));
      expect(converter.convert(101), equals("백일"));
      expect(converter.convert(111), equals("백십일"));
      expect(converter.convert(200), equals("이백"));
      expect(converter.convert(999), equals("구백구십구"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("천"));
      expect(converter.convert(1001), equals("천일"));
      expect(converter.convert(1111), equals("천백십일"));
      expect(converter.convert(2000), equals("이천"));
      expect(converter.convert(10000), equals("만"));
      expect(converter.convert(100000), equals("십만"));
      expect(converter.convert(123456), equals("십이만삼천사백오십육"));
      expect(converter.convert(999999), equals("구십구만구천구백구십구"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("마이너스일"));
      expect(converter.convert(-123), equals("마이너스백이십삼"));
      expect(converter.convert(-1, options: KoOptions(negativePrefix: "음수")),
          equals("음수일"));
      expect(converter.convert(-123, options: KoOptions(negativePrefix: "음수")),
          equals("음수백이십삼"));
    });

    test('Year Formatting', () {
      const yearOption = KoOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption), equals("천구백"));
      expect(converter.convert(2024, options: yearOption), equals("이천이십사"));

      expect(
        converter.convert(1900,
            options: KoOptions(format: Format.year, includeAD: true)),
        equals("서기 천구백"),
      );
      expect(
        converter.convert(2024,
            options: KoOptions(format: Format.year, includeAD: true)),
        equals("서기 이천이십사"),
      );

      expect(converter.convert(-100, options: yearOption), equals("기원전 백"));
      expect(converter.convert(-1, options: yearOption), equals("기원전 일"));

      expect(
        converter.convert(-100,
            options: KoOptions(format: Format.year, includeAD: true)),
        equals("기원전 백"),
      );
      expect(
        converter.convert(-1,
            options: KoOptions(format: Format.year, includeAD: true)),
        equals("기원전 일"),
      );
      expect(
        converter.convert(-2024,
            options: KoOptions(format: Format.year, includeAD: true)),
        equals("기원전 이천이십사"),
      );
      expect(
        converter.convert(-2024, options: KoOptions(format: Format.year)),
        equals("기원전 이천이십사"),
      );
    });

    test('Currency', () {
      const currencyOption = KoOptions(currency: true);
      expect(converter.convert(0, options: currencyOption), equals("영 원"));
      expect(converter.convert(1, options: currencyOption), equals("일 원"));

      expect(converter.convert(1.50, options: currencyOption), equals("일 원"));
      expect(
          converter.convert(123.45, options: currencyOption), equals("백이십삼 원"));
    });

    test('Decimals', () {
      expect(converter.convert(Decimal.parse('123.456')), equals("백이십삼 점 사오육"));
      expect(converter.convert(Decimal.parse('1.50')), equals("일 점 오"));
      expect(converter.convert(123.0), equals("백이십삼"));
      expect(converter.convert(Decimal.parse('123.0')), equals("백이십삼"));

      expect(
        converter.convert(
          Decimal.parse('1.5'),
          options: const KoOptions(decimalSeparator: DecimalSeparator.point),
        ),
        equals("일 점 오"),
      );
      expect(
        converter.convert(
          Decimal.parse('1.5'),
          options: const KoOptions(decimalSeparator: DecimalSeparator.comma),
        ),
        equals("일 쉼표 오"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("무한대"));
      expect(converter.convert(double.negativeInfinity), equals("음의 무한대"));
      expect(converter.convert(double.nan), equals("숫자가 아님"));
      expect(converter.convert(null), equals("숫자가 아님"));
      expect(converter.convert('abc'), equals("숫자가 아님"));

      expect(converterWithFallback.convert(double.infinity), equals("무한대"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("음의 무한대"));
      expect(converterWithFallback.convert(double.nan), equals("유효하지 않은 숫자"));
      expect(converterWithFallback.convert(null), equals("유효하지 않은 숫자"));
      expect(converterWithFallback.convert('abc'), equals("유효하지 않은 숫자"));
      expect(converterWithFallback.convert(123), equals("백이십삼"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("백만"));
      expect(converter.convert(BigInt.from(100000000)), equals("억"));
      expect(converter.convert(BigInt.from(1000000000)), equals("십억"));
      expect(converter.convert(BigInt.from(1000000000000)), equals("조"));
      expect(converter.convert(BigInt.from(1000000000000000)), equals("천조"));
      expect(converter.convert(BigInt.from(10000000000000000)), equals("경"));
      expect(converter.convert(BigInt.from(1000000000000000000)), equals("백경"));
      expect(converter.convert(BigInt.parse('100000000000000000000')),
          equals("해"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("십해"));
      expect(converter.convert(BigInt.parse('1000000000000000000000000')),
          equals("자"));
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals("천이백삼십사해오천육백칠십팔경구천백이십삼조사천오백육십칠억팔천구백십이만삼천사백오십육"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals("구천구백구십구해구천구백구십구경구천구백구십구조구천구백구십구억구천구백구십구만구천구백구십구"),
      );

      expect(converter.convert(10000), equals("만"));
    });
  });
}
