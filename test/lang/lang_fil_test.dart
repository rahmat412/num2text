import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Filipino (FIL)', () {
    final converter = Num2Text(initialLang: Lang.FIL);
    final converterWithFallback =
        Num2Text(initialLang: Lang.FIL, fallbackOnError: "Invalid Na Numero");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("sero"));
      expect(converter.convert(10), equals("sampu"));
      expect(converter.convert(11), equals("labing-isa"));
      expect(converter.convert(13), equals("labintatlo"));
      expect(converter.convert(15), equals("labinlima"));
      expect(converter.convert(20), equals("dalawampu"));
      expect(converter.convert(27), equals("dalawampu't pito"));
      expect(converter.convert(30), equals("tatlumpu"));
      expect(converter.convert(54), equals("limampu't apat"));
      expect(converter.convert(68), equals("animnapu't walo"));
      expect(converter.convert(99), equals("siyamnapu't siyam"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("isang daan"));
      expect(converter.convert(101), equals("isang daan at isa"));
      expect(converter.convert(105), equals("isang daan at lima"));
      expect(converter.convert(110), equals("isang daan at sampu"));
      expect(converter.convert(111), equals("isang daan at labing-isa"));
      expect(converter.convert(123), equals("isang daan at dalawampu't tatlo"));
      expect(converter.convert(200), equals("dalawang daan"));
      expect(converter.convert(321), equals("tatlong daan at dalawampu't isa"));
      expect(converter.convert(479), equals("apat na raan at pitumpu't siyam"));
      expect(converter.convert(596), equals("limang daan at siyamnapu't anim"));
      expect(converter.convert(681), equals("anim na raan at walumpu't isa"));
      expect(
          converter.convert(999), equals("siyam na raan at siyamnapu't siyam"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("isang libo"));
      expect(converter.convert(1001), equals("isang libo at isa"));
      expect(converter.convert(1011), equals("isang libo at labing-isa"));
      expect(converter.convert(1110), equals("isang libo isang daan at sampu"));
      expect(converter.convert(1111),
          equals("isang libo isang daan at labing-isa"));
      expect(converter.convert(2000), equals("dalawang libo"));
      expect(converter.convert(2468),
          equals("dalawang libo apat na raan at animnapu't walo"));
      expect(converter.convert(3579),
          equals("tatlong libo limang daan at pitumpu't siyam"));
      expect(converter.convert(10000), equals("sampung libo"));
      expect(converter.convert(10011), equals("sampung libo at labing-isa"));
      expect(converter.convert(11100), equals("labing-isang libo isang daan"));
      expect(converter.convert(12987),
          equals("labindalawang libo siyam na raan at walumpu't pito"));
      expect(converter.convert(45623),
          equals("apatnapu't limang libo anim na raan at dalawampu't tatlo"));
      expect(converter.convert(87654),
          equals("walumpu't pitong libo anim na raan at limampu't apat"));
      expect(converter.convert(100000), equals("isang daang libo"));
      expect(
          converter.convert(123456),
          equals(
              "isang daan at dalawampu't tatlong libo apat na raan at limampu't anim"));
      expect(
          converter.convert(987654),
          equals(
              "siyam na raan at walumpu't pitong libo anim na raan at limampu't apat"));
      expect(
          converter.convert(999999),
          equals(
              "siyam na raan at siyamnapu't siyam na libo siyam na raan at siyamnapu't siyam"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("negatibo isa"));
      expect(converter.convert(-123),
          equals("negatibo isang daan at dalawampu't tatlo"));
      expect(
          converter.convert(-123.456),
          equals(
              "negatibo isang daan at dalawampu't tatlo punto apat lima anim"));
      expect(
          converter.convert(-1,
              options: const FilOptions(negativePrefix: "minus")),
          equals("minus isa"));
      expect(
          converter.convert(-123,
              options: const FilOptions(negativePrefix: "minus")),
          equals("minus isang daan at dalawampu't tatlo"));
      expect(
          converter.convert(-123.456,
              options: const FilOptions(negativePrefix: "minus")),
          equals("minus isang daan at dalawampu't tatlo punto apat lima anim"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456),
          equals("isang daan at dalawampu't tatlo punto apat lima anim"));
      expect(converter.convert(1.5), equals("isa punto lima"));
      expect(converter.convert(1.05), equals("isa punto sero lima"));
      expect(converter.convert(879.465),
          equals("walong daan at pitumpu't siyam punto apat anim lima"));
      expect(converter.convert(1.5), equals("isa punto lima"));
      expect(
          converter.convert(1.5,
              options:
                  const FilOptions(decimalSeparator: DecimalSeparator.point)),
          equals("isa punto lima"));
      expect(
          converter.convert(1.5,
              options:
                  const FilOptions(decimalSeparator: DecimalSeparator.comma)),
          equals("isa koma lima"));
      expect(
          converter.convert(1.5,
              options:
                  const FilOptions(decimalSeparator: DecimalSeparator.period)),
          equals("isa punto lima"));
    });

    test('Year Formatting', () {
      expect(
          converter.convert(123,
              options: const FilOptions(format: Format.year)),
          equals("isang daan at dalawampu't tatlo"));
      expect(
          converter.convert(498,
              options: const FilOptions(format: Format.year)),
          equals("apat na raan at siyamnapu't walo"));
      expect(
          converter.convert(756,
              options: const FilOptions(format: Format.year)),
          equals("pitong daan at limampu't anim"));
      expect(
          converter.convert(1900,
              options: const FilOptions(format: Format.year)),
          equals("labing siyam na raan"));
      expect(
          converter.convert(1999,
              options: const FilOptions(format: Format.year)),
          equals("labing siyam siyamnapu't siyam"));
      expect(
          converter.convert(2025,
              options: const FilOptions(format: Format.year)),
          equals("dalawang libo dalawampu't lima"));
      expect(
          converter.convert(1900,
              options: const FilOptions(format: Format.year, includeAD: true)),
          equals("labing siyam na raan AD"));
      expect(
          converter.convert(1999,
              options: const FilOptions(format: Format.year, includeAD: true)),
          equals("labing siyam siyamnapu't siyam AD"));
      expect(
          converter.convert(2025,
              options: const FilOptions(format: Format.year, includeAD: true)),
          equals("dalawang libo dalawampu't lima AD"));
      expect(
          converter.convert(-1, options: const FilOptions(format: Format.year)),
          equals("isa BC"));
      expect(
          converter.convert(-100,
              options: const FilOptions(format: Format.year)),
          equals("isang daan BC"));
      expect(
          converter.convert(-100,
              options: const FilOptions(format: Format.year, includeAD: true)),
          equals("isang daan BC"));
      expect(
          converter.convert(-2025,
              options: const FilOptions(format: Format.year)),
          equals("dalawang libo dalawampu't lima BC"));
      expect(
          converter.convert(-1000000,
              options: const FilOptions(format: Format.year)),
          equals("isang milyon BC"));
    });

    test('Currency', () {
      expect(converter.convert(0, options: const FilOptions(currency: true)),
          equals("sero piso"));
      expect(converter.convert(1, options: const FilOptions(currency: true)),
          equals("isang piso"));
      expect(converter.convert(5, options: const FilOptions(currency: true)),
          equals("limang piso"));
      expect(converter.convert(10, options: const FilOptions(currency: true)),
          equals("sampung piso"));
      expect(converter.convert(11, options: const FilOptions(currency: true)),
          equals("labing-isang piso"));
      expect(converter.convert(1.5, options: const FilOptions(currency: true)),
          equals("isang piso at limampung sentimo"));
      expect(
          converter.convert(123.45, options: const FilOptions(currency: true)),
          equals(
              "isang daan at dalawampu't tatlong piso at apatnapu't limang sentimo"));
      expect(
          converter.convert(10000000,
              options: const FilOptions(currency: true)),
          equals("sampung milyong piso"));
      expect(converter.convert(0.01, options: const FilOptions(currency: true)),
          equals("isang sentimo"));
      expect(converter.convert(0.5, options: const FilOptions(currency: true)),
          equals("limampung sentimo"));
      expect(converter.convert(1.01, options: const FilOptions(currency: true)),
          equals("isang piso at isang sentimo"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("isang milyon"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("dalawang bilyon"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("tatlong trilyon"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("apat na kuwadrilyon"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("limang kwintilyon"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("anim na sekstilyon"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("pitong septilyon"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "siyam na kwintilyon walong daan at pitumpu't anim na kuwadrilyon limang daan at apatnapu't tatlong trilyon dalawang daan at sampung bilyon isang daan at dalawampu't tatlong milyon apat na raan at limampu't anim na libo pitong daan at walumpu't siyam"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "isang daan at dalawampu't tatlong sekstilyon apat na raan at limampu't anim na kwintilyon pitong daan at walumpu't siyam na kuwadrilyon isang daan at dalawampu't tatlong trilyon apat na raan at limampu't anim na bilyon pitong daan at walumpu't siyam na milyon isang daan at dalawampu't tatlong libo apat na raan at limampu't anim"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "siyam na raan at siyamnapu't siyam na sekstilyon siyam na raan at siyamnapu't siyam na kwintilyon siyam na raan at siyamnapu't siyam na kuwadrilyon siyam na raan at siyamnapu't siyam na trilyon siyam na raan at siyamnapu't siyam na bilyon siyam na raan at siyamnapu't siyam na milyon siyam na raan at siyamnapu't siyam na libo siyam na raan at siyamnapu't siyam"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("isang trilyon dalawang milyon tatlo"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("limang milyon isang libo"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("isang bilyon isa"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("isang bilyon isang milyon"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("dalawang milyon isang libo"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "isang trilyon siyam na raan at walumpu't pitong milyon anim na raang libo at tatlo"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Hindi Isang Numero"));
      expect(converter.convert(double.infinity), equals("Infinity"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negative Infinity"));
      expect(converter.convert(null), equals("Hindi Isang Numero"));
      expect(converter.convert('abc'), equals("Hindi Isang Numero"));
      expect(converter.convert([]), equals("Hindi Isang Numero"));
      expect(converter.convert({}), equals("Hindi Isang Numero"));
      expect(converter.convert(Object()), equals("Hindi Isang Numero"));

      expect(converterWithFallback.convert(double.nan),
          equals("Invalid Na Numero"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Infinity"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negative Infinity"));
      expect(converterWithFallback.convert(null), equals("Invalid Na Numero"));
      expect(converterWithFallback.convert('abc'), equals("Invalid Na Numero"));
      expect(converterWithFallback.convert([]), equals("Invalid Na Numero"));
      expect(converterWithFallback.convert({}), equals("Invalid Na Numero"));
      expect(
          converterWithFallback.convert(Object()), equals("Invalid Na Numero"));
      expect(converterWithFallback.convert(123),
          equals("isang daan at dalawampu't tatlo"));
    });
  });
}
