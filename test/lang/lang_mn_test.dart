import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Mongolian (MN)', () {
    final converter = Num2Text(initialLang: Lang.MN);
    final converterWithFallback =
        Num2Text(initialLang: Lang.MN, fallbackOnError: "Буруу Утга");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("тэг"));
      expect(converter.convert(10), equals("арав"));
      expect(converter.convert(11), equals("арван нэг"));
      expect(converter.convert(13), equals("арван гурав"));
      expect(converter.convert(15), equals("арван тав"));
      expect(converter.convert(20), equals("хорь"));
      expect(converter.convert(27), equals("хорин долоо"));
      expect(converter.convert(30), equals("гуч"));
      expect(converter.convert(54), equals("тавин дөрөв"));
      expect(converter.convert(68), equals("жаран найм"));
      expect(converter.convert(99), equals("ерэн ес"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("нэг зуу"));
      expect(converter.convert(101), equals("нэг зуун нэг"));
      expect(converter.convert(105), equals("нэг зуун тав"));
      expect(converter.convert(110), equals("нэг зуун арав"));
      expect(converter.convert(111), equals("нэг зуун арван нэг"));
      expect(converter.convert(123), equals("нэг зуун хорин гурав"));
      expect(converter.convert(200), equals("хоёр зуу"));
      expect(converter.convert(321), equals("гурван зуун хорин нэг"));
      expect(converter.convert(479), equals("дөрвөн зуун далан ес"));
      expect(converter.convert(596), equals("таван зуун ерэн зургаа"));
      expect(converter.convert(681), equals("зургаан зуун наян нэг"));
      expect(converter.convert(999), equals("есөн зуун ерэн ес"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("нэг мянга"));
      expect(converter.convert(1001), equals("нэг мянга нэг"));
      expect(converter.convert(1011), equals("нэг мянга арван нэг"));
      expect(converter.convert(1110), equals("нэг мянга нэг зуун арав"));
      expect(converter.convert(1111), equals("нэг мянга нэг зуун арван нэг"));
      expect(converter.convert(2000), equals("хоёр мянга"));
      expect(
          converter.convert(2468), equals("хоёр мянга дөрвөн зуун жаран найм"));
      expect(
          converter.convert(3579), equals("гурван мянга таван зуун далан ес"));
      expect(converter.convert(10000), equals("арван мянга"));
      expect(converter.convert(10011), equals("арван мянга арван нэг"));
      expect(converter.convert(11100), equals("арван нэгэн мянга нэг зуу"));
      expect(converter.convert(12987),
          equals("арван хоёр мянга есөн зуун наян долоо"));
      expect(converter.convert(45623),
          equals("дөчин таван мянга зургаан зуун хорин гурав"));
      expect(converter.convert(87654),
          equals("наян долоон мянга зургаан зуун тавин дөрөв"));
      expect(converter.convert(100000), equals("нэг зуун мянга"));
      expect(converter.convert(123456),
          equals("нэг зуун хорин гурван мянга дөрвөн зуун тавин зургаа"));
      expect(converter.convert(987654),
          equals("есөн зуун наян долоон мянга зургаан зуун тавин дөрөв"));
      expect(converter.convert(999999),
          equals("есөн зуун ерэн есөн мянга есөн зуун ерэн ес"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("хасах нэг"));
      expect(converter.convert(-123), equals("хасах нэг зуун хорин гурав"));
      expect(converter.convert(-123.456),
          equals("хасах нэг зуун хорин гурван цэг дөрөв тав зургаа"));

      const negativeOption = MnOptions(negativePrefix: "сөрөг");

      expect(
          converter.convert(-1, options: negativeOption), equals("сөрөг нэг"));
      expect(converter.convert(-123, options: negativeOption),
          equals("сөрөг нэг зуун хорин гурав"));
      expect(converter.convert(-123.456, options: negativeOption),
          equals("сөрөг нэг зуун хорин гурван цэг дөрөв тав зургаа"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456),
          equals("нэг зуун хорин гурван цэг дөрөв тав зургаа"));
      expect(converter.convert("1.5"), equals("нэг цэг тав"));
      expect(converter.convert(1.05), equals("нэг цэг тэг тав"));
      expect(converter.convert(879.465),
          equals("найман зуун далан есөн цэг дөрөв зургаа тав"));
      expect(converter.convert(1.5), equals("нэг цэг тав"));

      const pointOption = MnOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = MnOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = MnOptions(decimalSeparator: DecimalSeparator.period);

      expect(
          converter.convert(1.5, options: pointOption), equals("нэг цэг тав"));
      expect(converter.convert(1.5, options: commaOption),
          equals("нэг таслал тав"));
      expect(
          converter.convert(1.5, options: periodOption), equals("нэг цэг тав"));
    });

    test('Year Formatting', () {
      const yearOption = MnOptions(format: Format.year);

      expect(converter.convert(123, options: yearOption),
          equals("нэг зуун хорин гурав"));
      expect(converter.convert(498, options: yearOption),
          equals("дөрвөн зуун ерэн найм"));
      expect(converter.convert(756, options: yearOption),
          equals("долоон зуун тавин зургаа"));
      expect(converter.convert(1900, options: yearOption),
          equals("нэг мянга есөн зуу"));
      expect(converter.convert(1999, options: yearOption),
          equals("нэг мянга есөн зуун ерэн ес"));
      expect(converter.convert(2025, options: yearOption),
          equals("хоёр мянга хорин тав"));

      const yearOptionAD = MnOptions(format: Format.year, includeAD: true);

      expect(converter.convert(1900, options: yearOptionAD),
          equals("нэг мянга есөн зуун НТ"));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("нэг мянга есөн зуун ерэн есөн НТ"));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("хоёр мянга хорин таван НТ"));
      expect(converter.convert(-1, options: yearOption), equals("нэгэн НТӨ"));
      expect(
          converter.convert(-100, options: yearOption), equals("нэг зуун НТӨ"));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("нэг зуун НТӨ"));
      expect(converter.convert(-2025, options: yearOption),
          equals("хоёр мянга хорин таван НТӨ"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("нэг сая НТӨ"));
    });

    test('Currency', () {
      const currencyOption = MnOptions(currency: true);

      expect(
          converter.convert(0, options: currencyOption), equals("тэг төгрөг"));
      expect(
          converter.convert(1, options: currencyOption), equals("нэг төгрөг"));
      expect(converter.convert(5, options: currencyOption),
          equals("таван төгрөг"));
      expect(converter.convert(10, options: currencyOption),
          equals("арван төгрөг"));
      expect(converter.convert(11, options: currencyOption),
          equals("арван нэгэн төгрөг"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("нэг төгрөг тавин мөнгө"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("нэг зуун хорин гурван төгрөг дөчин таван мөнгө"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("арван сая төгрөг"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("тавин мөнгө"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("нэг мөнгө"));
      expect(converter.convert(0.1, options: currencyOption),
          equals("арван мөнгө"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("нэг сая"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("хоёр тэрбум"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("гурван их наяд"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("дөрвөн квадриллион"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("таван квинтиллион"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("зургаан секстиллион"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("долоон септиллион"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            "есөн квинтиллион найман зуун далан зургаан квадриллион таван зуун дөчин гурван их наяд хоёр зуун арван тэрбум нэг зуун хорин гурван сая дөрвөн зуун тавин зургаан мянга долоон зуун наян ес"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "нэг зуун хорин гурван секстиллион дөрвөн зуун тавин зургаан квинтиллион долоон зуун наян есөн квадриллион нэг зуун хорин гурван их наяд дөрвөн зуун тавин зургаан тэрбум долоон зуун наян есөн сая нэг зуун хорин гурван мянга дөрвөн зуун тавин зургаа"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "есөн зуун ерэн есөн секстиллион есөн зуун ерэн есөн квинтиллион есөн зуун ерэн есөн квадриллион есөн зуун ерэн есөн их наяд есөн зуун ерэн есөн тэрбум есөн зуун ерэн есөн сая есөн зуун ерэн есөн мянга есөн зуун ерэн ес"),
      );
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("нэг их наяд хоёр сая гурав"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("таван сая нэг мянга"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("нэг тэрбум нэг"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("нэг тэрбум нэг сая"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("хоёр сая нэг мянга"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "нэг их наяд есөн зуун наян долоон сая зургаан зуун мянга гурав"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Тоо Биш"));
      expect(converter.convert(double.infinity), equals("Хязгааргүй"));
      expect(converter.convert(double.negativeInfinity),
          equals("Сөрөг Хязгааргүй"));
      expect(converter.convert(null), equals("Тоо Биш"));
      expect(converter.convert('abc'), equals("Тоо Биш"));
      expect(converter.convert([]), equals("Тоо Биш"));
      expect(converter.convert({}), equals("Тоо Биш"));
      expect(converter.convert(Object()), equals("Тоо Биш"));

      expect(converterWithFallback.convert(double.nan), equals("Буруу Утга"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Хязгааргүй"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Сөрөг Хязгааргүй"));
      expect(converterWithFallback.convert(null), equals("Буруу Утга"));
      expect(converterWithFallback.convert('abc'), equals("Буруу Утга"));
      expect(converterWithFallback.convert([]), equals("Буруу Утга"));
      expect(converterWithFallback.convert({}), equals("Буруу Утга"));
      expect(converterWithFallback.convert(Object()), equals("Буруу Утга"));
      expect(
          converterWithFallback.convert(123), equals("нэг зуун хорин гурав"));
    });
  });
}
