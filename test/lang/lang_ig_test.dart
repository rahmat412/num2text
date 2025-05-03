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

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("efu"));
      expect(converter.convert(10), equals("iri"));
      expect(converter.convert(11), equals("iri na otu"));
      expect(converter.convert(13), equals("iri na atọ"));
      expect(converter.convert(15), equals("iri na ise"));
      expect(converter.convert(20), equals("iri abụọ"));
      expect(converter.convert(27), equals("iri abụọ na asaa"));
      expect(converter.convert(30), equals("iri atọ"));
      expect(converter.convert(54), equals("iri ise na anọ"));
      expect(converter.convert(68), equals("iri isii na asatọ"));
      expect(converter.convert(99), equals("iri itoolu na itoolu"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("narị"));
      expect(converter.convert(101), equals("narị na otu"));
      expect(converter.convert(105), equals("narị na ise"));
      expect(converter.convert(110), equals("narị na iri"));
      expect(converter.convert(111), equals("narị na iri na otu"));
      expect(converter.convert(123), equals("narị na iri abụọ na atọ"));
      expect(converter.convert(200), equals("narị abụọ"));
      expect(converter.convert(321), equals("narị atọ na iri abụọ na otu"));
      expect(converter.convert(479), equals("narị anọ na iri asaa na itoolu"));
      expect(converter.convert(596), equals("narị ise na iri itoolu na isii"));
      expect(converter.convert(681), equals("narị isii na iri asatọ na otu"));
      expect(converter.convert(999),
          equals("narị itoolu na iri itoolu na itoolu"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("puku"));
      expect(converter.convert(1001), equals("puku na otu"));
      expect(converter.convert(1011), equals("puku na iri na otu"));
      expect(converter.convert(1110), equals("puku na narị na iri"));
      expect(converter.convert(1111), equals("puku na narị na iri na otu"));
      expect(converter.convert(2000), equals("puku abụọ"));
      expect(converter.convert(2468),
          equals("puku abụọ na narị anọ na iri isii na asatọ"));
      expect(converter.convert(3579),
          equals("puku atọ na narị ise na iri asaa na itoolu"));
      expect(converter.convert(10000), equals("puku iri"));
      expect(converter.convert(10011), equals("puku iri na iri na otu"));
      expect(converter.convert(11100), equals("puku iri na otu na narị"));
      expect(converter.convert(12987),
          equals("puku iri na abụọ na narị itoolu na iri asatọ na asaa"));
      expect(converter.convert(45623),
          equals("puku iri anọ na ise na narị isii na iri abụọ na atọ"));
      expect(converter.convert(87654),
          equals("puku iri asatọ na asaa na narị isii na iri ise na anọ"));
      expect(converter.convert(100000), equals("puku narị"));
      expect(
          converter.convert(123456),
          equals(
              "puku narị na iri abụọ na atọ na narị anọ na iri ise na isii"));
      expect(
          converter.convert(987654),
          equals(
              "puku narị itoolu na iri asatọ na asaa na narị isii na iri ise na anọ"));
      expect(
          converter.convert(999999),
          equals(
              "puku narị itoolu na iri itoolu na itoolu na narị itoolu na iri itoolu na itoolu"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("mwepu otu"));
      expect(converter.convert(-123), equals("mwepu narị na iri abụọ na atọ"));
      expect(converter.convert(Decimal.parse("-123.456")),
          equals("mwepu narị na iri abụọ na atọ ntụpọ anọ ise isii"));
      const negativeOption1 = IgOptions(negativePrefix: "mbelata");
      expect(converter.convert(-1, options: negativeOption1),
          equals("mbelata otu"));
      expect(converter.convert(-123, options: negativeOption1),
          equals("mbelata narị na iri abụọ na atọ"));
      expect(
          converter.convert(Decimal.parse("-123.456"),
              options: negativeOption1),
          equals("mbelata narị na iri abụọ na atọ ntụpọ anọ ise isii"));
    });

    test('Decimals', () {
      expect(converter.convert(Decimal.parse("123.456")),
          equals("narị na iri abụọ na atọ ntụpọ anọ ise isii"));
      expect(converter.convert(1.5), equals("otu ntụpọ ise"));
      expect(converter.convert(1.05), equals("otu ntụpọ efu ise"));
      expect(converter.convert(879.465),
          equals("narị asatọ na iri asaa na itoolu ntụpọ anọ isii ise"));
      expect(converter.convert(1.5), equals("otu ntụpọ ise"));
      const pointOption = IgOptions(decimalSeparator: DecimalSeparator.point);
      expect(converter.convert(1.5, options: pointOption),
          equals("otu ntụpọ ise"));
      const commaOption = IgOptions(decimalSeparator: DecimalSeparator.comma);
      expect(converter.convert(1.5, options: commaOption),
          equals("otu rikoma ise"));
      const periodOption = IgOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(1.5, options: periodOption),
          equals("otu ntụpọ ise"));
    });

    test('Year Formatting', () {
      const yearOption = IgOptions(format: Format.year);
      expect(converter.convert(123, options: yearOption),
          equals("narị na iri abụọ na atọ"));
      expect(converter.convert(498, options: yearOption),
          equals("narị anọ na iri itoolu na asatọ"));
      expect(converter.convert(756, options: yearOption),
          equals("narị asaa na iri ise na isii"));
      expect(converter.convert(1900, options: yearOption),
          equals("puku na narị itoolu"));
      expect(converter.convert(1999, options: yearOption),
          equals("puku na narị itoolu na iri itoolu na itoolu"));
      expect(converter.convert(2025, options: yearOption),
          equals("puku abụọ na iri abụọ na ise"));
      const yearOptionAD = IgOptions(format: Format.year, includeAD: true);
      expect(converter.convert(1900, options: yearOptionAD),
          equals("puku na narị itoolu AD"));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("puku na narị itoolu na iri itoolu na itoolu AD"));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("puku abụọ na iri abụọ na ise AD"));
      expect(converter.convert(-1, options: yearOption), equals("otu BC"));
      expect(converter.convert(-100, options: yearOption), equals("narị BC"));
      expect(converter.convert(-100, options: yearOptionAD), equals("narị BC"));
      expect(converter.convert(-2025, options: yearOption),
          equals("puku abụọ na iri abụọ na ise BC"));
      expect(
          converter.convert(-1000000, options: yearOption), equals("nde BC"));
    });

    test('Currency', () {
      const currencyOption = IgOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("efu Naira"));
      expect(
          converter.convert(1, options: currencyOption), equals("otu Naira"));
      expect(
          converter.convert(5, options: currencyOption), equals("ise Naira"));
      expect(
          converter.convert(10, options: currencyOption), equals("iri Naira"));
      expect(converter.convert(11, options: currencyOption),
          equals("iri na otu Naira"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("otu Naira na iri ise Kobo"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("narị na iri abụọ na atọ Naira na iri anọ na ise Kobo"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("nde iri Naira"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("iri ise Kobo"));
      expect(
          converter.convert(0.01, options: currencyOption), equals("otu Kobo"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("otu Naira na otu Kobo"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("nde"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("ijeri abụọ"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("puku ijeri atọ"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("nde ijeri anọ"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("ijeri ijeri ise"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("puku ijeri ijeri isii"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("nde ijeri ijeri asaa"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            "ijeri ijeri itoolu na nde ijeri narị asatọ na iri asaa na isii na puku ijeri narị ise na iri anọ na atọ na ijeri narị abụọ na iri na nde narị na iri abụọ na atọ na puku narị anọ na iri ise na isii na narị asaa na iri asatọ na itoolu"),
      );
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "puku ijeri ijeri narị na iri abụọ na atọ na ijeri ijeri narị anọ na iri ise na isii na nde ijeri narị asaa na iri asatọ na itoolu na puku ijeri narị na iri abụọ na atọ na ijeri narị anọ na iri ise na isii na nde narị asaa na iri asatọ na itoolu na puku narị na iri abụọ na atọ na narị anọ na iri ise na isii"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "puku ijeri ijeri narị itoolu na iri itoolu na itoolu na ijeri ijeri narị itoolu na iri itoolu na itoolu na nde ijeri narị itoolu na iri itoolu na itoolu na puku ijeri narị itoolu na iri itoolu na itoolu na ijeri narị itoolu na iri itoolu na itoolu na nde narị itoolu na iri itoolu na itoolu na puku narị itoolu na iri itoolu na itoolu na narị itoolu na iri itoolu na itoolu"));

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('puku ijeri na nde abụọ na atọ'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("nde ise na puku otu"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("ijeri na otu"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("ijeri na nde otu"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("nde abụọ na puku otu"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              'puku ijeri na nde narị itoolu na iri asatọ na asaa na puku narị isii na atọ'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Abụghị Ọnụọgụ"));
      expect(converter.convert(double.infinity), equals("Anwụ Anwụ"));
      expect(converter.convert(double.negativeInfinity),
          equals("Mwepu Anwụ Anwụ"));
      expect(converter.convert(null), equals("Abụghị Ọnụọgụ"));
      expect(converter.convert('abc'), equals("Abụghị Ọnụọgụ"));
      expect(converter.convert([]), equals("Abụghị Ọnụọgụ"));
      expect(converter.convert({}), equals("Abụghị Ọnụọgụ"));
      expect(converter.convert(Object()), equals("Abụghị Ọnụọgụ"));

      expect(converterWithFallback.convert(double.nan),
          equals("Ọnụọgụ adịghị mma"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Anwụ Anwụ"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Mwepu Anwụ Anwụ"));
      expect(converterWithFallback.convert(null), equals("Ọnụọgụ adịghị mma"));
      expect(converterWithFallback.convert('abc'), equals("Ọnụọgụ adịghị mma"));
      expect(converterWithFallback.convert([]), equals("Ọnụọgụ adịghị mma"));
      expect(converterWithFallback.convert({}), equals("Ọnụọgụ adịghị mma"));
      expect(
          converterWithFallback.convert(Object()), equals("Ọnụọgụ adịghị mma"));
      expect(converterWithFallback.convert(123),
          equals("narị na iri abụọ na atọ"));
    });
  });
}
