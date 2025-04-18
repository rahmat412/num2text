import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Mongolian (MN)', () {
    final converter = Num2Text(initialLang: Lang.MN);
    final converterWithFallback =
        Num2Text(initialLang: Lang.MN, fallbackOnError: "Буруу утга");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("тэг"));
      expect(converter.convert(1), equals("нэг"));
      expect(converter.convert(10), equals("арав"));
      expect(converter.convert(11), equals("арван нэг"));
      expect(converter.convert(20), equals("хорь"));
      expect(converter.convert(21), equals("хорин нэг"));
      expect(converter.convert(99), equals("ерэн ес"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("нэг зуу"));
      expect(converter.convert(101), equals("нэг зуун нэг"));
      expect(converter.convert(111), equals("нэг зуун арван нэг"));
      expect(converter.convert(200), equals("хоёр зуу"));
      expect(converter.convert(999), equals("есөн зуун ерэн ес"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("нэг мянга"));
      expect(converter.convert(1001), equals("нэг мянга нэг"));
      expect(converter.convert(1111), equals("нэг мянга нэг зуун арван нэг"));
      expect(converter.convert(2000), equals("хоёр мянга"));

      expect(converter.convert(10000), equals("арав мянга"));
      expect(converter.convert(100000), equals("нэг зуун мянга"));
      expect(
        converter.convert(123456),
        equals("нэг зуун хорин гурван мянга дөрвөн зуун тавин зургаа"),
      );
      expect(converter.convert(999999),
          equals("есөн зуун ерэн есөн мянга есөн зуун ерэн ес"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("хасах нэг"));

      expect(converter.convert(-123), equals("хасах нэг зуун хорин гурав"));

      expect(
        converter.convert(-1, options: MnOptions(negativePrefix: "сөрөг")),
        equals("сөрөг нэг"),
      );
      expect(
        converter.convert(-123, options: MnOptions(negativePrefix: "сөрөг")),
        equals("сөрөг нэг зуун хорин гурав"),
      );
    });

    test('Year Formatting', () {
      const yearOption = MnOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("нэг мянга есөн зуу"));
      expect(converter.convert(2024, options: yearOption),
          equals("хоёр мянга хорин дөрөв"));
      expect(
        converter.convert(1900,
            options: MnOptions(format: Format.year, includeAD: true)),
        equals("нэг мянга есөн зуу НТ"),
      );
      expect(
        converter.convert(2024,
            options: MnOptions(format: Format.year, includeAD: true)),
        equals("хоёр мянга хорин дөрөв НТ"),
      );
      expect(
          converter.convert(-100, options: yearOption), equals("нэг зуу НТӨ"));
      expect(converter.convert(-1, options: yearOption), equals("нэг НТӨ"));
      expect(
        converter.convert(-2024,
            options: MnOptions(format: Format.year, includeAD: true)),
        equals("хоёр мянга хорин дөрөв НТӨ"),
      );
      expect(
        converter.convert(-2024, options: MnOptions(format: Format.year)),
        equals("хоёр мянга хорин дөрөв НТӨ"),
      );
    });

    test('Currency', () {
      const currencyOption = MnOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("тэг төгрөг"));
      expect(
          converter.convert(1, options: currencyOption), equals("нэг төгрөг"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("нэг төгрөг тавин мөнгө"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("нэг зуун хорин гурван төгрөг дөчин таван мөнгө"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("нэг зуун хорин гурван цэг дөрөв тав зургаа"),
      );
      expect(converter.convert(Decimal.parse('1.50')), equals("нэг цэг тав"));
      expect(converter.convert(123.0), equals("нэг зуун хорин гурав"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("нэг зуун хорин гурав"));
      expect(
        converter.convert(1.5,
            options: const MnOptions(decimalSeparator: DecimalSeparator.point)),
        equals("нэг цэг тав"),
      );
      expect(
        converter.convert(1.5,
            options: const MnOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("нэг таслал тав"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Хязгааргүй"));
      expect(converter.convert(double.negativeInfinity),
          equals("Сөрөг хязгааргүй"));
      expect(converter.convert(double.nan), equals("Тоо биш"));
      expect(converter.convert(null), equals("Тоо биш"));
      expect(converter.convert('abc'), equals("Тоо биш"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Хязгааргүй"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Сөрөг хязгааргүй"));
      expect(converterWithFallback.convert(double.nan), equals("Буруу утга"));
      expect(converterWithFallback.convert(null), equals("Буруу утга"));
      expect(converterWithFallback.convert('abc'), equals("Буруу утга"));
      expect(
          converterWithFallback.convert(123), equals("нэг зуун хорин гурав"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("нэг сая"));
      expect(converter.convert(BigInt.from(1000000000)), equals("нэг тэрбум"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("нэг их наяд"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("нэг квадриллион"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("нэг квинтиллион"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("нэг секстиллион"));

      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("нэг септиллион"),
      );

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "нэг зуун хорин гурван секстиллион дөрвөн зуун тавин зургаан квинтиллион долоон зуун наян есөн квадриллион нэг зуун хорин гурван их наяд дөрвөн зуун тавин зургаан тэрбум долоон зуун наян есөн сая нэг зуун хорин гурван мянга дөрвөн зуун тавин зургаа",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "есөн зуун ерэн есөн секстиллион есөн зуун ерэн есөн квинтиллион есөн зуун ерэн есөн квадриллион есөн зуун ерэн есөн их наяд есөн зуун ерэн есөн тэрбум есөн зуун ерэн есөн сая есөн зуун ерэн есөн мянга есөн зуун ерэн ес",
        ),
      );
    });
  });
}
