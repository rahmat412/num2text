import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Danish (DA)', () {
    final converter = Num2Text(initialLang: Lang.DA);
    final converterWithFallback = Num2Text(
      initialLang: Lang.DA,
      fallbackOnError: "Ugyldigt nummer",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("nul"));
      expect(converter.convert(1), equals("et"));
      expect(converter.convert(10), equals("ti"));
      expect(converter.convert(11), equals("elleve"));
      expect(converter.convert(20), equals("tyve"));
      expect(converter.convert(21), equals("enogtyve"));
      expect(converter.convert(99), equals("nioghalvfems"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("et hundrede"));
      expect(converter.convert(101), equals("et hundrede og et"));
      expect(converter.convert(111), equals("et hundrede og elleve"));
      expect(converter.convert(200), equals("to hundrede"));
      expect(converter.convert(999), equals("ni hundrede og nioghalvfems"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("et tusind"));
      expect(converter.convert(1001), equals("et tusind og et"));
      expect(
          converter.convert(1111), equals("et tusind et hundrede og elleve"));
      expect(converter.convert(2000), equals("to tusind"));
      expect(converter.convert(10000), equals("ti tusind"));
      expect(converter.convert(100000), equals("et hundrede tusind"));
      expect(
        converter.convert(123456),
        equals(
            "et hundrede og treogtyve tusind fire hundrede og seksoghalvtreds"),
      );
      expect(
        converter.convert(999999),
        equals(
            "ni hundrede og nioghalvfems tusind ni hundrede og nioghalvfems"),
      );
      expect(converter.convert(101000), equals("et hundrede og et tusind"));
      expect(
          converter.convert(101001), equals("et hundrede og et tusind og et"));
      expect(converter.convert(100101),
          equals("et hundrede tusind et hundrede og et"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus et"));
      expect(converter.convert(-123), equals("minus et hundrede og treogtyve"));
      expect(
        converter.convert(-1, options: DaOptions(negativePrefix: "negativ")),
        equals("negativ et"),
      );
      expect(
        converter.convert(-123, options: DaOptions(negativePrefix: "negativ")),
        equals("negativ et hundrede og treogtyve"),
      );
    });

    test('Year Formatting', () {
      const yearOption = DaOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("nitten hundrede"));
      expect(converter.convert(2024, options: yearOption),
          equals("to tusind og fireogtyve"));
      expect(
        converter.convert(1900,
            options: DaOptions(format: Format.year, includeAD: true)),
        equals("nitten hundrede e.Kr."),
      );
      expect(
        converter.convert(2024,
            options: DaOptions(format: Format.year, includeAD: true)),
        equals("to tusind og fireogtyve e.Kr."),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("et hundrede f.Kr."));
      expect(converter.convert(-1, options: yearOption), equals("et f.Kr."));
      expect(
        converter.convert(-2024,
            options: DaOptions(format: Format.year, includeAD: true)),
        equals("to tusind og fireogtyve f.Kr."),
      );
    });

    test('Currency', () {
      const currencyOption = DaOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("nul kroner"));
      expect(converter.convert(1, options: currencyOption), equals("en krone"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("en krone og halvtreds øre"));

      expect(
        converter.convert(123.45, options: currencyOption),
        equals("et hundrede og treogtyve kroner og femogfyrre øre"),
      );
      expect(
          converter.convert(2, options: currencyOption), equals("to kroner"));
    });

    group('Decimals', () {
      test('Handles Decimals', () {
        expect(
          converter.convert(Decimal.parse('123.456')),
          equals("et hundrede og treogtyve komma fire fem seks"),
        );
        expect(
            converter.convert(Decimal.parse('1.50')), equals("et komma fem"));

        expect(converter.convert(123.0), equals("et hundrede og treogtyve"));

        expect(converter.convert(Decimal.parse('123.0')),
            equals("et hundrede og treogtyve"));
        expect(
          converter.convert(
            1.5,
            options: const DaOptions(decimalSeparator: DecimalSeparator.comma),
          ),
          equals("et komma fem"),
        );
        expect(
          converter.convert(
            1.5,
            options: const DaOptions(decimalSeparator: DecimalSeparator.period),
          ),
          equals("et punktum fem"),
        );
        expect(
          converter.convert(
            1.5,
            options: const DaOptions(decimalSeparator: DecimalSeparator.point),
          ),
          equals("et punktum fem"),
        );
      });
    });

    group('Handles infinity and invalid', () {
      test('Handles infinity and invalid input', () {
        expect(converter.convert(double.infinity), equals("Uendelig"));
        expect(converter.convert(double.negativeInfinity),
            equals("Negativ Uendelig"));
        expect(converter.convert(double.nan), equals("Ikke et tal"));
        expect(converter.convert(null), equals("Ikke et tal"));
        expect(converter.convert('abc'), equals("Ikke et tal"));

        expect(
            converterWithFallback.convert(double.infinity), equals("Uendelig"));
        expect(converterWithFallback.convert(double.negativeInfinity),
            equals("Negativ Uendelig"));
        expect(converterWithFallback.convert(double.nan),
            equals("Ugyldigt nummer"));
        expect(converterWithFallback.convert(null), equals("Ugyldigt nummer"));
        expect(converterWithFallback.convert('abc'), equals("Ugyldigt nummer"));

        expect(converterWithFallback.convert(123),
            equals("et hundrede og treogtyve"));
      });
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("en million"));
      expect(converter.convert(BigInt.from(2000000)), equals("to millioner"));
      expect(converter.convert(BigInt.from(1000000000)), equals("en milliard"));
      expect(
          converter.convert(BigInt.from(2000000000)), equals("to milliarder"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("en billion"));
      expect(converter.convert(BigInt.from(2000000000000)),
          equals("to billioner"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("en billiard"));
      expect(converter.convert(BigInt.from(2000000000000000)),
          equals("to billiarder"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("en trillion"));
      expect(converter.convert(BigInt.from(2000000000000000000)),
          equals("to trillioner"));

      expect(
        converter.convert(BigInt.parse('123456789123456789')),
        equals(
          "et hundrede og treogtyve billiarder fire hundrede og seksoghalvtreds billioner syv hundrede og niogfirs milliarder et hundrede og treogtyve millioner fire hundrede og seksoghalvtreds tusind syv hundrede og niogfirs",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999')),
        equals(
          "ni hundrede og nioghalvfems billiarder ni hundrede og nioghalvfems billioner ni hundrede og nioghalvfems milliarder ni hundrede og nioghalvfems millioner ni hundrede og nioghalvfems tusind ni hundrede og nioghalvfems",
        ),
      );

      expect(converter.convert(BigInt.parse('1000000000000000001')),
          equals("en trillion og et"));
    });
  });
}
