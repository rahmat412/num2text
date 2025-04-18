import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Swedish (SV)', () {
    final converter = Num2Text(initialLang: Lang.SV);
    final converterWithFallback = Num2Text(
      initialLang: Lang.SV,
      fallbackOnError: "Ogiltigt nummer",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("noll"));
      expect(converter.convert(1), equals("ett"));
      expect(converter.convert(2), equals("två"));
      expect(converter.convert(10), equals("tio"));
      expect(converter.convert(11), equals("elva"));
      expect(converter.convert(19), equals("nitton"));
      expect(converter.convert(20), equals("tjugo"));
      expect(converter.convert(21), equals("tjugoett"));
      expect(converter.convert(99), equals("nittionio"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("etthundra"));
      expect(converter.convert(101), equals("etthundraett"));
      expect(converter.convert(111), equals("etthundraelva"));
      expect(converter.convert(200), equals("tvåhundra"));
      expect(converter.convert(999), equals("niohundranittionio"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("ettusen"));
      expect(converter.convert(1001), equals("ettusen ett"));
      expect(converter.convert(1111), equals("ettusen etthundraelva"));
      expect(converter.convert(2000), equals("tvåtusen"));
      expect(converter.convert(5000), equals("femtusen"));
      expect(converter.convert(10000), equals("tiotusen"));
      expect(converter.convert(100000), equals("etthundratusen"));
      expect(converter.convert(123456),
          equals("etthundratjugotretusen fyrahundrafemtiosex"));
      expect(converter.convert(999999),
          equals("niohundranittioniotusen niohundranittionio"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus ett"));
      expect(converter.convert(-123), equals("minus etthundratjugotre"));
      expect(
        converter.convert(-1, options: SvOptions(negativePrefix: "negativ")),
        equals("negativ ett"),
      );
      expect(
        converter.convert(-123, options: SvOptions(negativePrefix: "negativ")),
        equals("negativ etthundratjugotre"),
      );
    });

    test('Year Formatting', () {
      const yearOption = SvOptions(format: Format.year);
      expect(
          converter.convert(1900, options: yearOption), equals("nittonhundra"));
      expect(converter.convert(2024, options: yearOption),
          equals("tjugohundratjugofyra"));
      expect(
        converter.convert(1900,
            options: SvOptions(format: Format.year, includeAD: true)),
        equals("nittonhundra e.Kr."),
      );
      expect(
        converter.convert(2024,
            options: SvOptions(format: Format.year, includeAD: true)),
        equals("tjugohundratjugofyra e.Kr."),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("etthundra f.Kr."));
      expect(converter.convert(-1, options: yearOption), equals("ett f.Kr."));
      expect(converter.convert(-2024, options: yearOption),
          equals("tjugohundratjugofyra f.Kr."));
    });

    test('Currency', () {
      const currencyOption = SvOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("noll kronor"));
      expect(converter.convert(1, options: currencyOption), equals("en krona"));
      expect(
          converter.convert(1.00, options: currencyOption), equals("en krona"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("en krona och ett öre"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("en krona och femtio öre"));
      expect(
          converter.convert(2, options: currencyOption), equals("två kronor"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("två kronor och två öre"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("etthundratjugotre kronor och fyrtiofem öre"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("etthundratjugotre komma fyra fem sex"),
      );

      expect(converter.convert(Decimal.parse('1.50')), equals("ett komma fem"));
      expect(converter.convert(Decimal.parse('1.05')),
          equals("ett komma noll fem"));
      expect(converter.convert(123.0), equals("etthundratjugotre"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("etthundratjugotre"));
      expect(
        converter.convert(1.5,
            options: const SvOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("ett komma fem"),
      );
      expect(
        converter.convert(1.5,
            options:
                const SvOptions(decimalSeparator: DecimalSeparator.period)),
        equals("ett punkt fem"),
      );
      expect(
        converter.convert(1.5,
            options: const SvOptions(decimalSeparator: DecimalSeparator.point)),
        equals("ett punkt fem"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Oändlighet"));
      expect(converter.convert(double.negativeInfinity),
          equals("minus Oändlighet"));
      expect(converter.convert(double.nan), equals("Inte ett nummer"));
      expect(converter.convert(null), equals("Inte ett nummer"));
      expect(converter.convert('abc'), equals("Inte ett nummer"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Oändlighet"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("minus Oändlighet"));
      expect(
          converterWithFallback.convert(double.nan), equals("Ogiltigt nummer"));
      expect(converterWithFallback.convert(null), equals("Ogiltigt nummer"));
      expect(converterWithFallback.convert('abc'), equals("Ogiltigt nummer"));
      expect(converterWithFallback.convert(123), equals("etthundratjugotre"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("en miljon"));
      expect(converter.convert(BigInt.from(2000000)), equals("två miljoner"));
      expect(converter.convert(BigInt.from(1000000000)), equals("en miljard"));
      expect(
          converter.convert(BigInt.from(2000000000)), equals("två miljarder"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("en biljon"));
      expect(converter.convert(BigInt.from(2000000000000)),
          equals("två biljoner"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("en biljard"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("en triljon"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("en triljard"));
      expect(converter.convert(BigInt.parse('1000000000000000000000000')),
          equals("en kvadriljon"));

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          'etthundratjugotre triljarder fyrahundrafemtiosex triljoner sjuhundraåttionio biljarder etthundratjugotre biljoner fyrahundrafemtiosex miljarder sjuhundraåttionio miljoner etthundratjugotretusen fyrahundrafemtiosex',
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          'niohundranittionio triljarder niohundranittionio triljoner niohundranittionio biljarder niohundranittionio biljoner niohundranittionio miljarder niohundranittionio miljoner niohundranittioniotusen niohundranittionio',
        ),
      );
    });
  });
}
