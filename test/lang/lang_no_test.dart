import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Norwegian (NO)', () {
    final converter = Num2Text(initialLang: Lang.NO);
    final converterWithFallback =
        Num2Text(initialLang: Lang.NO, fallbackOnError: "Ugyldig nummer");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("null"));

      expect(converter.convert(1), equals("en"));

      expect(
          converter.convert(1, options: const NoOptions(gender: Gender.neuter)),
          equals("ett"));
      expect(converter.convert(10), equals("ti"));
      expect(converter.convert(11), equals("elleve"));
      expect(converter.convert(20), equals("tjue"));
      expect(converter.convert(21), equals("tjueen"));
      expect(converter.convert(99), equals("nittini"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("ett hundre"));

      expect(converter.convert(101), equals("ett hundre og en"));
      expect(converter.convert(111), equals("ett hundre og elleve"));
      expect(converter.convert(200), equals("to hundre"));

      expect(converter.convert(999), equals("ni hundre og nittini"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("ett tusen"));

      expect(converter.convert(1001), equals("ett tusen og en"));

      expect(converter.convert(1111), equals("ett tusen ett hundre og elleve"));
      expect(converter.convert(2000), equals("to tusen"));
      expect(converter.convert(10000), equals("ti tusen"));

      expect(converter.convert(100000), equals("ett hundre tusen"));

      expect(
        converter.convert(123456),
        equals("ett hundre og tjuetre tusen fire hundre og femtiseks"),
      );

      expect(converter.convert(999999),
          equals("ni hundre og nittini tusen ni hundre og nittini"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus en"));

      expect(converter.convert(-123), equals("minus ett hundre og tjuetre"));
      expect(
        converter.convert(-1,
            options: const NoOptions(negativePrefix: "negativ ")),
        equals("negativ en"),
      );
      expect(
        converter.convert(-123,
            options: const NoOptions(negativePrefix: "negativ ")),
        equals("negativ ett hundre og tjuetre"),
      );
    });

    test('Year Formatting', () {
      const yearOption = NoOptions(format: Format.year);
      const yearOptionAD = NoOptions(format: Format.year, includeAD: true);

      expect(converter.convert(1900, options: yearOption),
          equals("nitten hundre"));

      expect(converter.convert(2024, options: yearOption),
          equals("to tusen og tjuefire"));
      expect(converter.convert(2024, options: yearOptionAD),
          equals("to tusen og tjuefire e.Kr."));

      expect(converter.convert(-100, options: yearOption),
          equals("ett hundre f.Kr."));

      expect(converter.convert(-1, options: yearOption), equals("en f.Kr."));
      expect(converter.convert(-2024, options: yearOption),
          equals("to tusen og tjuefire f.Kr."));

      expect(converter.convert(1066, options: yearOption),
          equals("ett tusen og sekstiseks"));
    });

    test('Currency', () {
      const currencyOption = NoOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("null kroner"));

      expect(converter.convert(1, options: currencyOption), equals("en krone"));

      expect(converter.convert(1.01, options: currencyOption),
          equals("en krone og ett øre"));
      expect(converter.convert(2.50, options: currencyOption),
          equals("to kroner og femti øre"));

      expect(
        converter.convert(123.45, options: currencyOption),
        equals("ett hundre og tjuetre kroner og førtifem øre"),
      );
      expect(
          converter.convert(2, options: currencyOption), equals("to kroner"));
      expect(converter.convert(0.50, options: currencyOption),
          equals("null kroner og femti øre"));
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("ett hundre og tjuetre komma fire fem seks"),
      );

      expect(converter.convert(Decimal.parse('1.50')), equals("en komma fem"));

      expect(converter.convert(123.0), equals("ett hundre og tjuetre"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("ett hundre og tjuetre"));

      expect(
        converter.convert(1.5,
            options: const NoOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("en komma fem"),
      );
      expect(
        converter.convert(1.5,
            options:
                const NoOptions(decimalSeparator: DecimalSeparator.period)),
        equals("en punktum fem"),
      );
      expect(
        converter.convert(1.5,
            options: const NoOptions(decimalSeparator: DecimalSeparator.point)),
        equals("en punktum fem"),
      );

      expect(converter.convert(0.5), equals("null komma fem"));
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Uendelig"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negativ uendelig"));
      expect(converter.convert(double.nan), equals("Ikke et tall"));
      expect(converter.convert(null), equals("Ikke et tall"));
      expect(converter.convert('abc'), equals("Ikke et tall"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Uendelig"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negativ uendelig"));
      expect(
          converterWithFallback.convert(double.nan), equals("Ugyldig nummer"));
      expect(converterWithFallback.convert(null), equals("Ugyldig nummer"));
      expect(converterWithFallback.convert('abc'), equals("Ugyldig nummer"));

      expect(
          converterWithFallback.convert(123), equals("ett hundre og tjuetre"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("en million"));
      expect(converter.convert(BigInt.from(1000000000)), equals("en milliard"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("en billion"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("en billiard"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("en trillion"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("en trilliard"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("en kvadrillion"),
      );
      expect(converter.convert(BigInt.from(2000000)), equals("to millioner"));

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "ett hundre og tjuetre trilliarder fire hundre og femtiseks trillioner sju hundre og åttini billiarder ett hundre og tjuetre billioner fire hundre og femtiseks milliarder sju hundre og åttini millioner ett hundre og tjuetre tusen fire hundre og femtiseks",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "ni hundre og nittini trilliarder ni hundre og nittini trillioner ni hundre og nittini billiarder ni hundre og nittini billioner ni hundre og nittini milliarder ni hundre og nittini millioner ni hundre og nittini tusen ni hundre og nittini",
        ),
      );
    });
  });
}
