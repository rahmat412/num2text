import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Hausa (HA)', () {
    final converter = Num2Text(initialLang: Lang.HA);
    final converterWithFallback = Num2Text(
      initialLang: Lang.HA,
      fallbackOnError: "Lamba Mara Inganci",
    );

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("sifili"));
      expect(converter.convert(10), equals("goma"));
      expect(converter.convert(11), equals("goma sha ɗaya"));
      expect(converter.convert(13), equals("goma sha uku"));
      expect(converter.convert(15), equals("goma sha biyar"));
      expect(converter.convert(20), equals("ashirin"));
      expect(converter.convert(27), equals("ashirin da bakwai"));
      expect(converter.convert(30), equals("talatin"));
      expect(converter.convert(54), equals("hamsin da huɗu"));
      expect(converter.convert(68), equals("sittin da takwas"));
      expect(converter.convert(99), equals("casa'in da tara"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("ɗari"));
      expect(converter.convert(101), equals("ɗari da ɗaya"));
      expect(converter.convert(105), equals("ɗari da biyar"));
      expect(converter.convert(110), equals("ɗari da goma"));
      expect(converter.convert(111), equals("ɗari da goma sha ɗaya"));
      expect(converter.convert(123), equals("ɗari da ashirin da uku"));
      expect(converter.convert(200), equals("ɗari biyu"));
      expect(converter.convert(321), equals("ɗari uku da ashirin da ɗaya"));
      expect(converter.convert(479), equals("ɗari huɗu da saba'in da tara"));
      expect(converter.convert(596), equals("ɗari biyar da casa'in da shida"));
      expect(converter.convert(681), equals("ɗari shida da tamanin da ɗaya"));
      expect(converter.convert(999), equals("ɗari tara da casa'in da tara"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("dubu"));
      expect(converter.convert(1001), equals("dubu da ɗaya"));
      expect(converter.convert(1011), equals("dubu da goma sha ɗaya"));
      expect(converter.convert(1110), equals("dubu da ɗari da goma"));
      expect(converter.convert(1111), equals("dubu da ɗari da goma sha ɗaya"));
      expect(converter.convert(2000), equals("dubu biyu"));
      expect(converter.convert(2468),
          equals("dubu biyu da ɗari huɗu da sittin da takwas"));
      expect(converter.convert(3579),
          equals("dubu uku da ɗari biyar da saba'in da tara"));
      expect(converter.convert(10000), equals("dubu goma"));
      expect(converter.convert(10011), equals("dubu goma da goma sha ɗaya"));
      expect(converter.convert(11100), equals("dubu goma sha ɗaya da ɗari"));
      expect(converter.convert(12987),
          equals("dubu goma sha biyu da ɗari tara da tamanin da bakwai"));
      expect(converter.convert(45623),
          equals("dubu arba'in da biyar da ɗari shida da ashirin da uku"));
      expect(converter.convert(87654),
          equals("dubu tamanin da bakwai da ɗari shida da hamsin da huɗu"));
      expect(converter.convert(100000), equals("dubu ɗari"));
      expect(
          converter.convert(123456),
          equals(
              "dubu ɗari da ashirin da uku da ɗari huɗu da hamsin da shida"));
      expect(
          converter.convert(987654),
          equals(
              "dubu ɗari tara da tamanin da bakwai da ɗari shida da hamsin da huɗu"));
      expect(
          converter.convert(999999),
          equals(
              "dubu ɗari tara da casa'in da tara da ɗari tara da casa'in da tara"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("korau ɗaya"));
      expect(converter.convert(-123), equals("korau ɗari da ashirin da uku"));
      expect(converter.convert(-123.456),
          equals("korau ɗari da ashirin da uku digo huɗu biyar shida"));
      expect(
          converter.convert(-1,
              options: const HaOptions(negativePrefix: "debe")),
          equals("debe ɗaya"));
      expect(
          converter.convert(-123,
              options: const HaOptions(negativePrefix: "debe")),
          equals("debe ɗari da ashirin da uku"));
      expect(
          converter.convert(-123.456,
              options: const HaOptions(negativePrefix: "debe")),
          equals("debe ɗari da ashirin da uku digo huɗu biyar shida"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456),
          equals("ɗari da ashirin da uku digo huɗu biyar shida"));
      expect(converter.convert(1.5), equals("ɗaya digo biyar"));
      expect(converter.convert(1.05), equals("ɗaya digo sifili biyar"));
      expect(converter.convert(879.465),
          equals("ɗari takwas da saba'in da tara digo huɗu shida biyar"));
      expect(converter.convert(1.5), equals("ɗaya digo biyar"));
      expect(
          converter.convert(1.5,
              options:
                  const HaOptions(decimalSeparator: DecimalSeparator.point)),
          equals("ɗaya digo biyar"));
      expect(
          converter.convert(1.5,
              options:
                  const HaOptions(decimalSeparator: DecimalSeparator.comma)),
          equals("ɗaya waƙafi biyar"));
      expect(
          converter.convert(1.5,
              options:
                  const HaOptions(decimalSeparator: DecimalSeparator.period)),
          equals("ɗaya digo biyar"));
    });

    test('Year Formatting', () {
      expect(
          converter.convert(123, options: const HaOptions(format: Format.year)),
          equals("ɗari da ashirin da uku"));
      expect(
          converter.convert(498, options: const HaOptions(format: Format.year)),
          equals("ɗari huɗu da casa'in da takwas"));
      expect(
          converter.convert(756, options: const HaOptions(format: Format.year)),
          equals("ɗari bakwai da hamsin da shida"));
      expect(
          converter.convert(1900,
              options: const HaOptions(format: Format.year)),
          equals("dubu da ɗari tara"));
      expect(
          converter.convert(1999,
              options: const HaOptions(format: Format.year)),
          equals("dubu da ɗari tara da casa'in da tara"));
      expect(
          converter.convert(2025,
              options: const HaOptions(format: Format.year)),
          equals("dubu biyu da ashirin da biyar"));
      expect(
          converter.convert(1900,
              options: const HaOptions(format: Format.year, includeAD: true)),
          equals("dubu da ɗari tara AD"));
      expect(
          converter.convert(1999,
              options: const HaOptions(format: Format.year, includeAD: true)),
          equals("dubu da ɗari tara da casa'in da tara AD"));
      expect(
          converter.convert(2025,
              options: const HaOptions(format: Format.year, includeAD: true)),
          equals("dubu biyu da ashirin da biyar AD"));
      expect(
          converter.convert(-1, options: const HaOptions(format: Format.year)),
          equals("ɗaya BC"));
      expect(
          converter.convert(-100,
              options: const HaOptions(format: Format.year)),
          equals("ɗari BC"));
      expect(
          converter.convert(-100,
              options: const HaOptions(format: Format.year, includeAD: true)),
          equals("ɗari BC"));
      expect(
          converter.convert(-2025,
              options: const HaOptions(format: Format.year)),
          equals("dubu biyu da ashirin da biyar BC"));
      expect(
          converter.convert(-1000000,
              options: const HaOptions(format: Format.year)),
          equals("miliyan ɗaya BC"));
    });

    test('Currency', () {
      expect(converter.convert(0, options: const HaOptions(currency: true)),
          equals("Naira sifili"));
      expect(converter.convert(1, options: const HaOptions(currency: true)),
          equals("Naira ɗaya"));
      expect(converter.convert(5, options: const HaOptions(currency: true)),
          equals("Naira biyar"));
      expect(converter.convert(10, options: const HaOptions(currency: true)),
          equals("Naira goma"));
      expect(converter.convert(11, options: const HaOptions(currency: true)),
          equals("Naira goma sha ɗaya"));
      expect(converter.convert(1.5, options: const HaOptions(currency: true)),
          equals("Naira ɗaya da kobo hamsin"));
      expect(
          converter.convert(123.45, options: const HaOptions(currency: true)),
          equals("Naira ɗari da ashirin da uku da kobo arba'in da biyar"));
      expect(
          converter.convert(10000000, options: const HaOptions(currency: true)),
          equals("Naira miliyan goma"));
      expect(converter.convert(0.01, options: const HaOptions(currency: true)),
          equals("kobo ɗaya"));
      expect(converter.convert(0.5, options: const HaOptions(currency: true)),
          equals("kobo hamsin"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("miliyan ɗaya"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("biliyan biyu"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("tiriliyan uku"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("kwadiriliyan huɗu"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("kwintiliyan biyar"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("sistiliyan shida"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("septiliyan bakwai"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "kwintiliyan tara kwadiriliyan ɗari takwas da saba'in da shida tiriliyan ɗari biyar da arba'in da uku biliyan ɗari biyu da goma miliyan ɗari da ashirin da uku dubu ɗari huɗu da hamsin da shida da ɗari bakwai da tamanin da tara"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "sistiliyan ɗari da ashirin da uku kwintiliyan ɗari huɗu da hamsin da shida kwadiriliyan ɗari bakwai da tamanin da tara tiriliyan ɗari da ashirin da uku biliyan ɗari huɗu da hamsin da shida miliyan ɗari bakwai da tamanin da tara dubu ɗari da ashirin da uku da ɗari huɗu da hamsin da shida"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "sistiliyan ɗari tara da casa'in da tara kwintiliyan ɗari tara da casa'in da tara kwadiriliyan ɗari tara da casa'in da tara tiriliyan ɗari tara da casa'in da tara biliyan ɗari tara da casa'in da tara miliyan ɗari tara da casa'in da tara dubu ɗari tara da casa'in da tara da ɗari tara da casa'in da tara"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("tiriliyan ɗaya miliyan biyu da uku"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("miliyan biyar da dubu"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("biliyan ɗaya da ɗaya"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("biliyan ɗaya da miliyan ɗaya"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("miliyan biyu da dubu"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "tiriliyan ɗaya miliyan ɗari tara da tamanin da bakwai dubu ɗari shida da uku"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Ba Lamba Ba"));
      expect(converter.convert(double.infinity), equals("Madawwami"));
      expect(converter.convert(double.negativeInfinity),
          equals("Korau Madawwami"));
      expect(converter.convert(null), equals("Ba Lamba Ba"));
      expect(converter.convert('abc'), equals("Ba Lamba Ba"));
      expect(converter.convert([]), equals("Ba Lamba Ba"));
      expect(converter.convert({}), equals("Ba Lamba Ba"));
      expect(converter.convert(Object()), equals("Ba Lamba Ba"));

      expect(converterWithFallback.convert(double.nan),
          equals("Lamba Mara Inganci"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Madawwami"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Korau Madawwami"));
      expect(converterWithFallback.convert(null), equals("Lamba Mara Inganci"));
      expect(
          converterWithFallback.convert('abc'), equals("Lamba Mara Inganci"));
      expect(converterWithFallback.convert([]), equals("Lamba Mara Inganci"));
      expect(converterWithFallback.convert({}), equals("Lamba Mara Inganci"));
      expect(converterWithFallback.convert(Object()),
          equals("Lamba Mara Inganci"));
      expect(
          converterWithFallback.convert(123), equals("ɗari da ashirin da uku"));
    });
  });
}
