import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Filipino (FIL)', () {
    final converter = Num2Text(initialLang: Lang.FIL);
    final converterWithFallback = Num2Text(
      initialLang: Lang.FIL,
      fallbackOnError: "Invalid na Numero",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("sero"));
      expect(converter.convert(1), equals("isa"));
      expect(converter.convert(10), equals("sampu"));
      expect(converter.convert(11), equals("labing-isa"));
      expect(converter.convert(20), equals("dalawampu"));
      expect(converter.convert(21), equals("dalawampu't isa"));
      expect(converter.convert(99), equals("siyamnapu't siyam"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("isang daan"));
      expect(converter.convert(101), equals("isang daan at isa"));
      expect(converter.convert(111), equals("isang daan at labing-isa"));
      expect(converter.convert(200), equals("dalawang daan"));

      expect(
          converter.convert(999), equals("siyam na raan at siyamnapu't siyam"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("isang libo"));
      expect(converter.convert(1001), equals("isang libo at isa"));
      expect(converter.convert(1111),
          equals("isang libo isang daan at labing-isa"));
      expect(converter.convert(2000), equals("dalawang libo"));
      expect(converter.convert(10000), equals("sampung libo"));
      expect(converter.convert(100000), equals("isang daang libo"));

      expect(
        converter.convert(123456),
        equals(
            "isang daan at dalawampu't tatlong libo apat na raan at limampu't anim"),
      );

      expect(
        converter.convert(999999),
        equals(
            "siyam na raan at siyamnapu't siyam na libo siyam na raan at siyamnapu't siyam"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("negatibo isa"));

      expect(converter.convert(-123),
          equals("negatibo isang daan at dalawampu't tatlo"));
      expect(
        converter.convert(-1, options: FilOptions(negativePrefix: "minus")),
        equals("minus isa"),
      );

      expect(
        converter.convert(-123, options: FilOptions(negativePrefix: "minus")),
        equals("minus isang daan at dalawampu't tatlo"),
      );
    });

    test('Year Formatting', () {
      const yearOption = FilOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("labing siyam na raan"));

      expect(
        converter.convert(2024, options: yearOption),
        equals("dalawang libo dalawampu't apat"),
      );
      expect(
        converter.convert(1900,
            options: FilOptions(format: Format.year, includeAD: true)),
        equals("labing siyam na raan AD"),
      );
      expect(
        converter.convert(2024,
            options: FilOptions(format: Format.year, includeAD: true)),
        equals("dalawang libo dalawampu't apat AD"),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("isang daan BC"));
      expect(converter.convert(-1, options: yearOption), equals("isa BC"));
      expect(
        converter.convert(-2024,
            options: FilOptions(format: Format.year, includeAD: true)),
        equals("dalawang libo dalawampu't apat BC"),
      );
    });

    test('Currency', () {
      const currencyOption = FilOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("sero piso"));
      expect(
          converter.convert(1, options: currencyOption), equals("isang piso"));
      expect(
        converter.convert(1.50, options: currencyOption),
        equals("isang piso at limampung sentimo"),
      );

      expect(
        converter.convert(123.45, options: currencyOption),
        equals(
            "isang daan at dalawampu't tatlong piso at apatnapu't limang sentimo"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("isang daan at dalawampu't tatlo punto apat lima anim"),
      );

      expect(
          converter.convert(Decimal.parse('1.50')), equals("isa punto lima"));

      expect(
          converter.convert(123.0), equals("isang daan at dalawampu't tatlo"));

      expect(converter.convert(Decimal.parse('123.0')),
          equals("isang daan at dalawampu't tatlo"));
      expect(
        converter.convert(1.5,
            options:
                const FilOptions(decimalSeparator: DecimalSeparator.point)),
        equals("isa punto lima"),
      );
      expect(
        converter.convert(1.5,
            options:
                const FilOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("isa koma lima"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Infinity"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negative Infinity"));
      expect(converter.convert(double.nan), equals("Hindi isang Numero"));
      expect(converter.convert(null), equals("Hindi isang Numero"));
      expect(converter.convert('abc'), equals("Hindi isang Numero"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Infinity"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negative Infinity"));
      expect(converterWithFallback.convert(double.nan),
          equals("Invalid na Numero"));
      expect(converterWithFallback.convert(null), equals("Invalid na Numero"));
      expect(converterWithFallback.convert('abc'), equals("Invalid na Numero"));

      expect(converterWithFallback.convert(123),
          equals("isang daan at dalawampu't tatlo"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("isang milyon"));
      expect(
          converter.convert(BigInt.from(1000000000)), equals("isang bilyon"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("isang trilyon"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("isang kuwadrilyon"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("isang kwintilyon"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("isang sekstilyon"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("isang septilyon"),
      );

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "isang daan at dalawampu't tatlong sekstilyon apat na raan at limampu't anim na kwintilyon pitong daan at walumpu't siyam na kuwadrilyon isang daan at dalawampu't tatlong trilyon apat na raan at limampu't anim na bilyon pitong daan at walumpu't siyam na milyon isang daan at dalawampu't tatlong libo apat na raan at limampu't anim",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "siyam na raan at siyamnapu't siyam na sekstilyon siyam na raan at siyamnapu't siyam na kwintilyon siyam na raan at siyamnapu't siyam na kuwadrilyon siyam na raan at siyamnapu't siyam na trilyon siyam na raan at siyamnapu't siyam na bilyon siyam na raan at siyamnapu't siyam na milyon siyam na raan at siyamnapu't siyam na libo siyam na raan at siyamnapu't siyam",
        ),
      );
    });
  });
}
