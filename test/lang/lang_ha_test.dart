import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Hausa (HA)', () {
    final converter = Num2Text(initialLang: Lang.HA);
    final converterWithFallback = Num2Text(
      initialLang: Lang.HA,
      fallbackOnError: "Lamba Mara Inganci",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("sifili"));
      expect(converter.convert(1), equals("ɗaya"));
      expect(converter.convert(10), equals("goma"));
      expect(converter.convert(11), equals("goma sha ɗaya"));
      expect(converter.convert(20), equals("ashirin"));
      expect(converter.convert(21), equals("ashirin da ɗaya"));
      expect(converter.convert(99), equals("casa'in da tara"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("ɗari"));
      expect(converter.convert(101), equals("ɗari da ɗaya"));
      expect(converter.convert(111), equals("ɗari da goma sha ɗaya"));
      expect(converter.convert(200), equals("ɗari biyu"));
      expect(converter.convert(999), equals("ɗari tara da casa'in da tara"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("dubu"));
      expect(converter.convert(1001), equals("dubu da ɗaya"));
      expect(converter.convert(1111), equals("dubu da ɗari da goma sha ɗaya"));
      expect(converter.convert(2000), equals("dubu biyu"));
      expect(converter.convert(10000), equals("dubu goma"));
      expect(converter.convert(100000), equals("dubu ɗari"));
      expect(
        converter.convert(123456),
        equals("dubu ɗari da ashirin da uku da ɗari huɗu da hamsin da shida"),
      );
      expect(
        converter.convert(999999),
        equals(
            "dubu ɗari tara da casa'in da tara da ɗari tara da casa'in da tara"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("korau ɗaya"));
      expect(converter.convert(-123), equals("korau ɗari da ashirin da uku"));
      expect(
        converter.convert(-1, options: HaOptions(negativePrefix: "debe")),
        equals("debe ɗaya"),
      );
      expect(
        converter.convert(-123, options: HaOptions(negativePrefix: "debe")),
        equals("debe ɗari da ashirin da uku"),
      );
    });

    test('Year Formatting', () {
      const yearOption = HaOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("dubu da ɗari tara"));
      expect(converter.convert(2024, options: yearOption),
          equals("dubu biyu da ashirin da huɗu"));
      expect(
        converter.convert(1900,
            options: HaOptions(format: Format.year, includeAD: true)),
        equals("dubu da ɗari tara AD"),
      );
      expect(
        converter.convert(2024,
            options: HaOptions(format: Format.year, includeAD: true)),
        equals("dubu biyu da ashirin da huɗu AD"),
      );
      expect(converter.convert(-100, options: yearOption), equals("ɗari BC"));
      expect(converter.convert(-1, options: yearOption), equals("ɗaya BC"));
      expect(
        converter.convert(-2024,
            options: HaOptions(format: Format.year, includeAD: true)),
        equals("dubu biyu da ashirin da huɗu BC"),
      );
    });

    test('Currency', () {
      const currencyOption = HaOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("Naira sifili"));
      expect(
          converter.convert(1, options: currencyOption), equals("Naira ɗaya"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("Naira ɗaya da kobo hamsin"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("Naira ɗari da ashirin da uku da kobo arba'in da biyar"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("ɗari da ashirin da uku digo huɗu biyar shida"),
      );
      expect(
          converter.convert(Decimal.parse('1.50')), equals("ɗaya digo biyar"));
      expect(converter.convert(123.0), equals("ɗari da ashirin da uku"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("ɗari da ashirin da uku"));

      expect(
        converter.convert(1.5,
            options: const HaOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("ɗaya waƙafi biyar"),
      );

      expect(
        converter.convert(1.5,
            options:
                const HaOptions(decimalSeparator: DecimalSeparator.period)),
        equals("ɗaya digo biyar"),
      );
      expect(
        converter.convert(1.5,
            options: const HaOptions(decimalSeparator: DecimalSeparator.point)),
        equals("ɗaya digo biyar"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Madawwami"));
      expect(converter.convert(double.negativeInfinity),
          equals("Korau Madawwami"));
      expect(converter.convert(double.nan), equals("Ba Lamba Ba"));
      expect(converter.convert(null), equals("Ba Lamba Ba"));
      expect(converter.convert('abc'), equals("Ba Lamba Ba"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Madawwami"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Korau Madawwami"));
      expect(converterWithFallback.convert(double.nan),
          equals("Lamba Mara Inganci"));
      expect(converterWithFallback.convert(null), equals("Lamba Mara Inganci"));
      expect(
          converterWithFallback.convert('abc'), equals("Lamba Mara Inganci"));
      expect(
          converterWithFallback.convert(123), equals("ɗari da ashirin da uku"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("miliyan ɗaya"));
      expect(
          converter.convert(BigInt.from(1000000000)), equals("biliyan ɗaya"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("tiriliyan ɗaya"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("kwadiriliyan ɗaya"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("kwintiliyan ɗaya"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("sistiliyan ɗaya"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("septiliyan ɗaya"),
      );

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "sistiliyan ɗari da ashirin da uku kwintiliyan ɗari huɗu da hamsin da shida kwadiriliyan ɗari bakwai da tamanin da tara tiriliyan ɗari da ashirin da uku biliyan ɗari huɗu da hamsin da shida miliyan ɗari bakwai da tamanin da tara dubu ɗari da ashirin da uku da ɗari huɗu da hamsin da shida",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "sistiliyan ɗari tara da casa'in da tara kwintiliyan ɗari tara da casa'in da tara kwadiriliyan ɗari tara da casa'in da tara tiriliyan ɗari tara da casa'in da tara biliyan ɗari tara da casa'in da tara miliyan ɗari tara da casa'in da tara dubu ɗari tara da casa'in da tara da ɗari tara da casa'in da tara",
        ),
      );
    });
  });
}
