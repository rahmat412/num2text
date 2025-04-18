import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Igbo (IG)', () {
    final converter = Num2Text(initialLang: Lang.IG);
    final converterWithFallback = Num2Text(
      initialLang: Lang.IG,
      fallbackOnError: "Ọnụọgụ adịghị mma",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("efu"));
      expect(converter.convert(1), equals("otu"));
      expect(converter.convert(10), equals("iri"));
      expect(converter.convert(11), equals("iri na otu"));
      expect(converter.convert(20), equals("iri abụọ"));
      expect(converter.convert(21), equals("iri abụọ na otu"));
      expect(converter.convert(99), equals("iri itoolu na itoolu"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("narị"));
      expect(converter.convert(101), equals("narị na otu"));
      expect(converter.convert(111), equals("narị na iri na otu"));
      expect(converter.convert(200), equals("narị abụọ"));
      expect(converter.convert(999),
          equals("narị itoolu na iri itoolu na itoolu"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("puku"));

      expect(converter.convert(1001), equals("puku na otu"));

      expect(converter.convert(1111), equals("puku na narị na iri na otu"));

      expect(converter.convert(2000), equals("puku abụọ"));

      expect(converter.convert(10000), equals("puku iri"));

      expect(converter.convert(100000), equals("puku narị"));

      expect(
        converter.convert(123456),
        equals("puku narị na iri abụọ na atọ na narị anọ na iri ise na isii"),
      );

      expect(
        converter.convert(999999),
        equals(
            "puku narị itoolu na iri itoolu na itoolu na narị itoolu na iri itoolu na itoolu"),
      );
    });

    test('Year Formatting', () {
      const yearOption = IgOptions(format: Format.year);

      expect(converter.convert(1900, options: yearOption),
          equals("puku na narị itoolu"));
      expect(converter.convert(2024, options: yearOption),
          equals("puku abụọ na iri abụọ na anọ"));

      expect(
        converter.convert(1900,
            options: IgOptions(format: Format.year, includeAD: true)),
        equals("puku na narị itoolu AD"),
      );
      expect(
        converter.convert(2024,
            options: IgOptions(format: Format.year, includeAD: true)),
        equals("puku abụọ na iri abụọ na anọ AD"),
      );
      expect(converter.convert(-100, options: yearOption), equals("narị BC"));
      expect(converter.convert(-1, options: yearOption), equals("otu BC"));
      expect(
        converter.convert(-2024,
            options: IgOptions(format: Format.year, includeAD: true)),
        equals("puku abụọ na iri abụọ na anọ BC"),
      );
    });

    test('Scale Numbers', () {
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "narị na iri abụọ na atọ puku ijeri ijeri na narị anọ na iri ise na isii ijeri ijeri na narị asaa na iri asatọ na itoolu nde ijeri na narị na iri abụọ na atọ puku ijeri na narị anọ na iri ise na isii ijeri na narị asaa na iri asatọ na itoolu nde na puku narị na iri abụọ na atọ na narị anọ na iri ise na isii",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "narị itoolu na iri itoolu na itoolu puku ijeri ijeri na narị itoolu na iri itoolu na itoolu ijeri ijeri na narị itoolu na iri itoolu na itoolu nde ijeri na narị itoolu na iri itoolu na itoolu puku ijeri na narị itoolu na iri itoolu na itoolu ijeri na narị itoolu na iri itoolu na itoolu nde na puku narị itoolu na iri itoolu na itoolu na narị itoolu na iri itoolu na itoolu",
        ),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("mwepu otu"));
      expect(converter.convert(-123), equals("mwepu narị na iri abụọ na atọ"));

      expect(
        converter.convert(-1, options: IgOptions(negativePrefix: "mwepu")),
        equals("mwepu otu"),
      );
      expect(
        converter.convert(-123, options: IgOptions(negativePrefix: "mwepu")),
        equals("mwepu narị na iri abụọ na atọ"),
      );
    });

    test('Currency', () {
      const currencyOption = IgOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("efu Naira"));

      expect(
          converter.convert(1, options: currencyOption), equals("otu Naira"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("otu Naira na iri ise Kobo"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("narị na iri abụọ na atọ Naira na iri anọ na ise Kobo"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("narị na iri abụọ na atọ ntụpọ anọ ise isii"),
      );
      expect(converter.convert(Decimal.parse('1.50')), equals("otu ntụpọ ise"));
      expect(converter.convert(123.0), equals("narị na iri abụọ na atọ"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("narị na iri abụọ na atọ"));

      expect(
        converter.convert(1.5,
            options: const IgOptions(decimalSeparator: DecimalSeparator.point)),
        equals("otu ntụpọ ise"),
      );
      expect(
        converter.convert(1.5,
            options:
                const IgOptions(decimalSeparator: DecimalSeparator.period)),
        equals("otu ntụpọ ise"),
      );

      expect(
        converter.convert(1.5,
            options: const IgOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("otu rikoma ise"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Anwụ Anwụ"));
      expect(converter.convert(double.negativeInfinity),
          equals("Mwepu Anwụ Anwụ"));
      expect(converter.convert(double.nan), equals("Abụghị Ọnụọgụ"));
      expect(converter.convert(null), equals("Abụghị Ọnụọgụ"));
      expect(converter.convert('abc'), equals("Abụghị Ọnụọgụ"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Anwụ Anwụ"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Mwepu Anwụ Anwụ"));
      expect(converterWithFallback.convert(double.nan),
          equals("Ọnụọgụ adịghị mma"));
      expect(converterWithFallback.convert(null), equals("Ọnụọgụ adịghị mma"));
      expect(converterWithFallback.convert('abc'), equals("Ọnụọgụ adịghị mma"));
      expect(converterWithFallback.convert(123),
          equals("narị na iri abụọ na atọ"));
    });
  });
}
