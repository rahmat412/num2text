import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Icelandic (IS)', () {
    final converter = Num2Text(initialLang: Lang.IS);
    final converterWithFallback =
        Num2Text(initialLang: Lang.IS, fallbackOnError: "Ógild tala");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("núll"));
      expect(converter.convert(1), equals("einn"));
      expect(converter.convert(10), equals("tíu"));
      expect(converter.convert(11), equals("ellefu"));
      expect(converter.convert(20), equals("tuttugu"));
      expect(converter.convert(21), equals("tuttugu og einn"));
      expect(converter.convert(99), equals("níutíu og níu"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("eitt hundrað"));
      expect(converter.convert(101), equals("eitt hundrað og einn"));
      expect(converter.convert(111), equals("eitt hundrað og ellefu"));
      expect(converter.convert(200), equals("tvö hundrað"));

      expect(converter.convert(999), equals("níu hundrað og níutíu og níu"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("eitt þúsund"));
      expect(converter.convert(1001), equals("eitt þúsund og einn"));
      expect(converter.convert(1111),
          equals("eitt þúsund eitt hundrað og ellefu"));
      expect(converter.convert(2000), equals("tvö þúsund"));
      expect(converter.convert(10000), equals("tíu þúsund"));
      expect(converter.convert(100000), equals("eitt hundrað þúsund"));
      expect(
        converter.convert(123456),
        equals(
            "eitt hundrað og tuttugu og þrjú þúsund fjögur hundrað og fimmtíu og sex"),
      );
      expect(
        converter.convert(999999),
        equals(
            "níu hundrað og níutíu og níu þúsund níu hundrað og níutíu og níu"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("eitt hundrað og tuttugu og þrjú komma fjögur fimm sex"),
      );
      expect(
          converter.convert(Decimal.parse('1.50')), equals("eitt komma fimm"));

      expect(
          converter.convert(123.0), equals("eitt hundrað og tuttugu og þrír"));

      expect(converter.convert(Decimal.parse('123.0')),
          equals("eitt hundrað og tuttugu og þrír"));
      expect(
        converter.convert(1.5,
            options: const IsOptions(decimalSeparator: DecimalSeparator.point)),
        equals("eitt punktur fimm"),
      );
      expect(
        converter.convert(1.5,
            options: const IsOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("eitt komma fimm"),
      );
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("ein milljón"));
      expect(converter.convert(BigInt.from(1000000000)),
          equals("einn milljarður"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("ein billjón"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("einn billjarður"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("ein trilljón"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("einn trilljarður"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("ein kvadrilljón"),
      );

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "eitt hundrað og tuttugu og þrír trilljarðar fjögur hundrað og fimmtíu og sex trilljónir sjö hundrað og áttatíu og níu billjarðar eitt hundrað og tuttugu og þrjár billjónir fjögur hundrað og fimmtíu og sex milljarðar sjö hundrað og áttatíu og níu milljónir eitt hundrað og tuttugu og þrjú þúsund fjögur hundrað og fimmtíu og sex",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "níu hundrað og níutíu og níu trilljarðar níu hundrað og níutíu og níu trilljónir níu hundrað og níutíu og níu billjarðar níu hundrað og níutíu og níu billjónir níu hundrað og níutíu og níu milljarðar níu hundrað og níutíu og níu milljónir níu hundrað og níutíu og níu þúsund níu hundrað og níutíu og níu",
        ),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("mínus einn"));
      expect(converter.convert(-123),
          equals("mínus eitt hundrað og tuttugu og þrír"));
      expect(
        converter.convert(-1, options: IsOptions(negativePrefix: "neikvætt")),
        equals("neikvætt einn"),
      );
      expect(
        converter.convert(-123, options: IsOptions(negativePrefix: "neikvætt")),
        equals("neikvætt eitt hundrað og tuttugu og þrír"),
      );
    });

    test('Year Formatting', () {
      const yearOption = IsOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("nítján hundrað"));

      expect(converter.convert(2024, options: yearOption),
          equals("tvö þúsund tuttugu og fjögur"));
      expect(
        converter.convert(1900,
            options: IsOptions(format: Format.year, includeAD: true)),
        equals("nítján hundrað e.Kr."),
      );
      expect(
        converter.convert(2024,
            options: IsOptions(format: Format.year, includeAD: true)),
        equals("tvö þúsund tuttugu og fjögur e.Kr."),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("hundrað fyrir Krist"));
      expect(converter.convert(-1, options: yearOption),
          equals("eitt fyrir Krist"));
      expect(
        converter.convert(-2024,
            options: IsOptions(format: Format.year, includeAD: true)),
        equals("tvö þúsund tuttugu og fjögur fyrir Krist"),
      );
    });

    test('Currency', () {
      const currencyOption = IsOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("núll krónur"));
      expect(
          converter.convert(1, options: currencyOption), equals("ein króna"));

      expect(converter.convert(1.50, options: currencyOption),
          equals("ein króna"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("eitt hundrað og tuttugu og þrjár krónur"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Óendanlegt"));
      expect(converter.convert(double.negativeInfinity),
          equals("Neikvætt Óendanlegt"));
      expect(converter.convert(double.nan), equals("Ekki tala"));
      expect(converter.convert(null), equals("Ekki tala"));
      expect(converter.convert('abc'), equals("Ekki tala"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Óendanlegt"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Neikvætt Óendanlegt"));
      expect(converterWithFallback.convert(double.nan), equals("Ógild tala"));
      expect(converterWithFallback.convert(null), equals("Ógild tala"));
      expect(converterWithFallback.convert('abc'), equals("Ógild tala"));
      expect(converterWithFallback.convert(123),
          equals("eitt hundrað og tuttugu og þrír"));
    });
  });
}
