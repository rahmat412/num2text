import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Tajik (TG)', () {
    final converter = Num2Text(initialLang: Lang.TG);
    final converterWithFallback =
        Num2Text(initialLang: Lang.TG, fallbackOnError: "Рақами Нодуруст");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("нол"));
      expect(converter.convert(10), equals("даҳ"));
      expect(converter.convert(11), equals("ёздаҳ"));
      expect(converter.convert(13), equals("сездаҳ"));
      expect(converter.convert(15), equals("понздаҳ"));
      expect(converter.convert(20), equals("бист"));
      expect(converter.convert(27), equals("бисту ҳафт"));
      expect(converter.convert(30), equals("сӣ"));
      expect(converter.convert(54), equals("панҷоҳу чор"));
      expect(converter.convert(68), equals("шасту ҳашт"));
      expect(converter.convert(99), equals("наваду нӯҳ"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("сад"));
      expect(converter.convert(101), equals("саду як"));
      expect(converter.convert(105), equals("саду панҷ"));
      expect(converter.convert(110), equals("саду даҳ"));
      expect(converter.convert(111), equals("саду ёздаҳ"));
      expect(converter.convert(123), equals("саду бисту се"));
      expect(converter.convert(200), equals("дусад"));
      expect(converter.convert(321), equals("сесаду бисту як"));
      expect(converter.convert(479), equals("чорсаду ҳафтоду нӯҳ"));
      expect(converter.convert(596), equals("панҷсаду наваду шаш"));
      expect(converter.convert(681), equals("шашсаду ҳаштоду як"));
      expect(converter.convert(999), equals("нӯҳсаду наваду нӯҳ"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("як ҳазор"));
      expect(converter.convert(1001), equals("як ҳазору як"));
      expect(converter.convert(1011), equals("як ҳазору ёздаҳ"));
      expect(converter.convert(1110), equals("як ҳазору саду даҳ"));
      expect(converter.convert(1111), equals("як ҳазору саду ёздаҳ"));
      expect(converter.convert(2000), equals("ду ҳазор"));
      expect(converter.convert(2468), equals("ду ҳазору чорсаду шасту ҳашт"));
      expect(converter.convert(3579), equals("се ҳазору панҷсаду ҳафтоду нӯҳ"));
      expect(converter.convert(10000), equals("даҳ ҳазор"));
      expect(converter.convert(10011), equals("даҳ ҳазору ёздаҳ"));
      expect(converter.convert(11100), equals("ёздаҳ ҳазору сад"));
      expect(converter.convert(12987),
          equals("дувоздаҳ ҳазору нӯҳсаду ҳаштоду ҳафт"));
      expect(converter.convert(45623),
          equals("чилу панҷ ҳазору шашсаду бисту се"));
      expect(converter.convert(87654),
          equals("ҳаштоду ҳафт ҳазору шашсаду панҷоҳу чор"));
      expect(converter.convert(100000), equals("сад ҳазор"));
      expect(converter.convert(123456),
          equals("саду бисту се ҳазору чорсаду панҷоҳу шаш"));
      expect(converter.convert(987654),
          equals("нӯҳсаду ҳаштоду ҳафт ҳазору шашсаду панҷоҳу чор"));
      expect(converter.convert(999999),
          equals("нӯҳсаду наваду нӯҳ ҳазору нӯҳсаду наваду нӯҳ"));
    });

    test('Negative Numbers', () {
      const manfiOption = TgOptions(negativePrefix: "манфӣ");
      expect(converter.convert(-1), equals("минус як"));
      expect(converter.convert(-123), equals("минус саду бисту се"));
      expect(converter.convert(-123.456),
          equals("минус саду бисту се нуқта чор панҷ шаш"));
      expect(converter.convert(-1, options: manfiOption), equals("манфӣ як"));
      expect(converter.convert(-123, options: manfiOption),
          equals("манфӣ саду бисту се"));
      expect(
        converter.convert(-123.456, options: manfiOption),
        equals("манфӣ саду бисту се нуқта чор панҷ шаш"),
      );
    });

    test('Decimals', () {
      const pointOption = TgOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = TgOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = TgOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(123.456),
          equals("саду бисту се нуқта чор панҷ шаш"));
      expect(converter.convert(1.5), equals("як нуқта панҷ"));
      expect(converter.convert(1.05), equals("як нуқта сифр панҷ"));
      expect(converter.convert(879.465),
          equals("ҳаштсаду ҳафтоду нӯҳ нуқта чор шаш панҷ"));
      expect(converter.convert(1.5, options: pointOption),
          equals("як нуқта панҷ"));
      expect(converter.convert(1.5, options: commaOption),
          equals("як вергул панҷ"));
      expect(converter.convert(1.5, options: periodOption),
          equals("як нуқта панҷ"));
    });

    test('Year Formatting', () {
      const yearOption = TgOptions(format: Format.year);
      const yearOptionAD = TgOptions(format: Format.year, includeAD: true);
      expect(
          converter.convert(123, options: yearOption), equals("саду бисту се"));
      expect(converter.convert(498, options: yearOption),
          equals("чорсаду наваду ҳашт"));
      expect(converter.convert(756, options: yearOption),
          equals("ҳафтсаду панҷоҳу шаш"));
      expect(converter.convert(1900, options: yearOption),
          equals("ҳазору нӯҳсад"));
      expect(converter.convert(1999, options: yearOption),
          equals("ҳазору нӯҳсаду наваду нӯҳ"));
      expect(converter.convert(2025, options: yearOption),
          equals("ду ҳазору бисту панҷ"));
      expect(converter.convert(1900, options: yearOptionAD),
          equals("ҳазору нӯҳсади м."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("ҳазору нӯҳсаду наваду нӯҳи м."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("ду ҳазору бисту панҷи м."));
      expect(converter.convert(-1, options: yearOption), equals("яки п.м."));
      expect(converter.convert(-100, options: yearOption), equals("сади п.м."));
      expect(
          converter.convert(-100, options: yearOptionAD), equals("сади п.м."));
      expect(converter.convert(-2025, options: yearOption),
          equals("ду ҳазору бисту панҷи п.м."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("як миллиони п.м."));
    });

    test('Currency', () {
      const currencyOption = TgOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("нол сомонӣ"));
      expect(
          converter.convert(1, options: currencyOption), equals("як сомонӣ"));
      expect(
          converter.convert(5, options: currencyOption), equals("панҷ сомонӣ"));
      expect(
          converter.convert(10, options: currencyOption), equals("даҳ сомонӣ"));
      expect(converter.convert(11, options: currencyOption),
          equals("ёздаҳ сомонӣ"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("як сомонӣ ва панҷоҳ дирам"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("саду бисту се сомонӣ ва чилу панҷ дирам"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("даҳ миллион сомонӣ"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("панҷоҳ дирам"));
      expect(
          converter.convert(0.01, options: currencyOption), equals("як дирам"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("панҷ дирам"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("як сомонӣ ва як дирам"));
      expect(converter.convert(2.05, options: currencyOption),
          equals("ду сомонӣ ва панҷ дирам"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("як миллион"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("ду миллиард"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("се триллион"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("чор квадриллион"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("панҷ квинтиллион"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("шаш секстиллион"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("ҳафт септиллион"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            "нӯҳ квинтиллиону ҳаштсаду ҳафтоду шаш квадриллиону панҷсаду чилу се триллиону дусаду даҳ миллиарду саду бисту се миллиону чорсаду панҷоҳу шаш ҳазору ҳафтсаду ҳаштоду нӯҳ"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "саду бисту се секстиллиону чорсаду панҷоҳу шаш квинтиллиону ҳафтсаду ҳаштоду нӯҳ квадриллиону саду бисту се триллиону чорсаду панҷоҳу шаш миллиарду ҳафтсаду ҳаштоду нӯҳ миллиону саду бисту се ҳазору чорсаду панҷоҳу шаш"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "нӯҳсаду наваду нӯҳ секстиллиону нӯҳсаду наваду нӯҳ квинтиллиону нӯҳсаду наваду нӯҳ квадриллиону нӯҳсаду наваду нӯҳ триллиону нӯҳсаду наваду нӯҳ миллиарду нӯҳсаду наваду нӯҳ миллиону нӯҳсаду наваду нӯҳ ҳазору нӯҳсаду наваду нӯҳ"),
      );
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('як триллиону ду миллиону се'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("панҷ миллиону як ҳазор"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("як миллиарду як"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("як миллиарду як миллион"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("ду миллиону як ҳазор"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "як триллиону нӯҳсаду ҳаштоду ҳафт миллиону шашсад ҳазору се"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Рақам Нест"));
      expect(converter.convert(double.infinity), equals("Беохир"));
      expect(
          converter.convert(double.negativeInfinity), equals("Минус Беохир"));
      expect(converter.convert(null), equals("Рақам Нест"));
      expect(converter.convert('abc'), equals("Рақам Нест"));
      expect(converter.convert([]), equals("Рақам Нест"));
      expect(converter.convert({}), equals("Рақам Нест"));
      expect(converter.convert(Object()), equals("Рақам Нест"));
      expect(
          converterWithFallback.convert(double.nan), equals("Рақами Нодуруст"));
      expect(converterWithFallback.convert(double.infinity), equals("Беохир"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Минус Беохир"));
      expect(converterWithFallback.convert(null), equals("Рақами Нодуруст"));
      expect(converterWithFallback.convert('abc'), equals("Рақами Нодуруст"));
      expect(converterWithFallback.convert([]), equals("Рақами Нодуруст"));
      expect(converterWithFallback.convert({}), equals("Рақами Нодуруст"));
      expect(
          converterWithFallback.convert(Object()), equals("Рақами Нодуруст"));
      expect(converterWithFallback.convert(123), equals("саду бисту се"));
    });
  });
}
