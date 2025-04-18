import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Tajik (TG)', () {
    final converter = Num2Text(initialLang: Lang.TG);
    final converterWithFallback = Num2Text(
      initialLang: Lang.TG,
      fallbackOnError: "Рақами Нодуруст",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("нол"));
      expect(converter.convert(1), equals("як"));
      expect(converter.convert(10), equals("даҳ"));
      expect(converter.convert(11), equals("ёздаҳ"));
      expect(converter.convert(20), equals("бист"));
      expect(converter.convert(21), equals("бисту як"));
      expect(converter.convert(99), equals("наваду нӯҳ"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("сад"));
      expect(converter.convert(101), equals("саду як"));
      expect(converter.convert(111), equals("саду ёздаҳ"));
      expect(converter.convert(200), equals("дусад"));
      expect(converter.convert(999), equals("нӯҳсаду наваду нӯҳ"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("як ҳазор"));
      expect(converter.convert(1001), equals("як ҳазору як"));
      expect(converter.convert(1111), equals("як ҳазору саду ёздаҳ"));
      expect(converter.convert(2000), equals("ду ҳазор"));
      expect(converter.convert(10000), equals("даҳ ҳазор"));
      expect(converter.convert(100000), equals("сад ҳазор"));
      expect(converter.convert(123456),
          equals("саду бисту се ҳазору чорсаду панҷоҳу шаш"));
      expect(converter.convert(999999),
          equals("нӯҳсаду наваду нӯҳ ҳазору нӯҳсаду наваду нӯҳ"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("минус як"));
      expect(converter.convert(-123), equals("минус саду бисту се"));
      expect(
        converter.convert(-1, options: TgOptions(negativePrefix: "манфӣ")),
        equals("манфӣ як"),
      );
      expect(
        converter.convert(-123, options: TgOptions(negativePrefix: "манфӣ")),
        equals("манфӣ саду бисту се"),
      );
    });

    test('Year Formatting', () {
      const yearOption = TgOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("ҳазору нӯҳсад"));
      expect(converter.convert(2024, options: yearOption),
          equals("ду ҳазору бисту чор"));
      expect(
        converter.convert(1900,
            options: TgOptions(format: Format.year, includeAD: true)),
        equals("ҳазору нӯҳсади м."),
      );
      expect(
        converter.convert(2024,
            options: TgOptions(format: Format.year, includeAD: true)),
        equals("ду ҳазору бисту чори м."),
      );
      expect(converter.convert(-100, options: yearOption), equals("сади п.м."));
      expect(converter.convert(-1, options: yearOption), equals("яки п.м."));
      expect(
        converter.convert(-2024,
            options: TgOptions(format: Format.year, includeAD: true)),
        equals("ду ҳазору бисту чори п.м."),
      );
    });

    test('Currency', () {
      const currencyOption = TgOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("нол сомонӣ"));
      expect(
          converter.convert(1, options: currencyOption), equals("як сомонӣ"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("як сомонӣ ва панҷоҳ дирам"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("саду бисту се сомонӣ ва чилу панҷ дирам"),
      );
      expect(converter.convert(2.05, options: currencyOption),
          equals("ду сомонӣ ва панҷ дирам"));
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("саду бисту се нуқта чор панҷ шаш"),
      );
      expect(converter.convert(Decimal.parse('1.50')), equals("як нуқта панҷ"));
      expect(converter.convert(123.0), equals("саду бисту се"));
      expect(
          converter.convert(Decimal.parse('123.0')), equals("саду бисту се"));
      expect(
        converter.convert(1.5,
            options: const TgOptions(decimalSeparator: DecimalSeparator.point)),
        equals("як нуқта панҷ"),
      );
      expect(
        converter.convert(1.5,
            options: const TgOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("як вергул панҷ"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Беохир"));
      expect(
          converter.convert(double.negativeInfinity), equals("Минус Беохир"));
      expect(converter.convert(double.nan), equals("Рақам Нест"));
      expect(converter.convert(null), equals("Рақам Нест"));
      expect(converter.convert('abc'), equals("Рақам Нест"));

      expect(converterWithFallback.convert(double.infinity), equals("Беохир"));

      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Минус Беохир"));
      expect(
          converterWithFallback.convert(double.nan), equals("Рақами Нодуруст"));
      expect(converterWithFallback.convert(null), equals("Рақами Нодуруст"));
      expect(converterWithFallback.convert('abc'), equals("Рақами Нодуруст"));

      expect(converterWithFallback.convert(123), equals("саду бисту се"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("як миллион"));
      expect(converter.convert(BigInt.from(1000000000)), equals("як миллиард"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("як триллион"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("як квадриллион"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("як квинтиллион"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("як секстиллион"));
      expect(converter.convert(BigInt.parse('1000000000000000000000000')),
          equals("як септиллион"));
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "саду бисту се секстиллиону чорсаду панҷоҳу шаш квинтиллиону ҳафтсаду ҳаштоду нӯҳ квадриллиону саду бисту се триллиону чорсаду панҷоҳу шаш миллиарду ҳафтсаду ҳаштоду нӯҳ миллиону саду бисту се ҳазору чорсаду панҷоҳу шаш",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "нӯҳсаду наваду нӯҳ секстиллиону нӯҳсаду наваду нӯҳ квинтиллиону нӯҳсаду наваду нӯҳ квадриллиону нӯҳсаду наваду нӯҳ триллиону нӯҳсаду наваду нӯҳ миллиарду нӯҳсаду наваду нӯҳ миллиону нӯҳсаду наваду нӯҳ ҳазору нӯҳсаду наваду нӯҳ",
        ),
      );
    });
  });
}
