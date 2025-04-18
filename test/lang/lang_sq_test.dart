import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Albanian (SQ)', () {
    final converter = Num2Text(initialLang: Lang.SQ);
    final converterWithFallback = Num2Text(
      initialLang: Lang.SQ,
      fallbackOnError: "Numër i pavlefshëm",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("zero"));
      expect(converter.convert(1), equals("një"));
      expect(converter.convert(10), equals("dhjetë"));
      expect(converter.convert(11), equals("njëmbëdhjetë"));
      expect(converter.convert(20), equals("njëzet"));
      expect(converter.convert(21), equals("njëzet e një"));
      expect(converter.convert(99), equals("nëntëdhjetë e nëntë"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("njëqind"));
      expect(converter.convert(101), equals("njëqind e një"));
      expect(converter.convert(111), equals("njëqind e njëmbëdhjetë"));
      expect(converter.convert(200), equals("dyqind"));
      expect(converter.convert(999), equals("nëntëqind e nëntëdhjetë e nëntë"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("një mijë"));
      expect(converter.convert(1001), equals("një mijë e një"));
      expect(
          converter.convert(1111), equals("një mijë e njëqind e njëmbëdhjetë"));
      expect(converter.convert(2000), equals("dy mijë"));
      expect(converter.convert(10000), equals("dhjetë mijë"));
      expect(converter.convert(100000), equals("njëqind mijë"));
      expect(
        converter.convert(123456),
        equals(
            "njëqind e njëzet e tre mijë e katërqind e pesëdhjetë e gjashtë"),
      );
      expect(
        converter.convert(999999),
        equals(
            "nëntëqind e nëntëdhjetë e nëntë mijë e nëntëqind e nëntëdhjetë e nëntë"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus një"));
      expect(converter.convert(-123), equals("minus njëqind e njëzet e tre"));
      expect(
        converter.convert(-1, options: SqOptions(negativePrefix: "negativ")),
        equals("negativ një"),
      );
      expect(
        converter.convert(-123, options: SqOptions(negativePrefix: "negativ")),
        equals("negativ njëqind e njëzet e tre"),
      );
    });

    test('Year Formatting', () {
      const yearOption = SqOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("një mijë e nëntëqind"));
      expect(converter.convert(2024, options: yearOption),
          equals("dy mijë e njëzet e katër"));
      expect(
        converter.convert(1900,
            options: SqOptions(format: Format.year, includeAD: true)),
        equals("një mijë e nëntëqind e.s."),
      );
      expect(
        converter.convert(2024,
            options: SqOptions(format: Format.year, includeAD: true)),
        equals("dy mijë e njëzet e katër e.s."),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("njëqind p.e.s."));
      expect(converter.convert(-1, options: yearOption), equals("një p.e.s."));
      expect(
        converter.convert(-2024,
            options: SqOptions(format: Format.year, includeAD: true)),
        equals("dy mijë e njëzet e katër p.e.s."),
      );
    });

    test('Currency', () {
      const currencyOption = SqOptions(currency: true);
      expect(converter.convert(1, options: currencyOption), equals("një lek"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("një lek e një qindarkë"));
      expect(converter.convert(2, options: currencyOption), equals("dy lekë"));
      expect(
        converter.convert(2.50, options: currencyOption),
        equals("dy lekë e pesëdhjetë qindarka"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("njëqind e njëzet e tre lekë e dyzet e pesë qindarka"),
      );
      expect(converter.convert(0.50, options: currencyOption),
          equals("pesëdhjetë qindarka"));
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("njëqind e njëzet e tre presje katër pesë gjashtë"),
      );
      expect(
          converter.convert(Decimal.parse('1.50')), equals("një presje pesë"));
      expect(converter.convert(123.0), equals("njëqind e njëzet e tre"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("njëqind e njëzet e tre"));
      expect(
        converter.convert(1.5,
            options: const SqOptions(decimalSeparator: DecimalSeparator.point)),
        equals("një pikë pesë"),
      );
      expect(
        converter.convert(1.5,
            options: const SqOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("një presje pesë"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Pafundësi"));
      expect(converter.convert(double.negativeInfinity),
          equals("Minus pafundësi"));
      expect(converter.convert(double.nan), equals("Nuk është numër"));
      expect(converter.convert(null), equals("Nuk është numër"));
      expect(converter.convert('abc'), equals("Nuk është numër"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Pafundësi"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Minus pafundësi"));
      expect(converterWithFallback.convert(double.nan),
          equals("Numër i pavlefshëm"));
      expect(converterWithFallback.convert(null), equals("Numër i pavlefshëm"));
      expect(
          converterWithFallback.convert('abc'), equals("Numër i pavlefshëm"));
      expect(
          converterWithFallback.convert(123), equals("njëqind e njëzet e tre"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("një milion"));
      expect(converter.convert(BigInt.from(1000000000)), equals("një miliard"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("një bilion"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("një biliard"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("një trilion"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("një triliard"));
      expect(converter.convert(BigInt.parse('1000000000000000000000000')),
          equals("një katrilion"));
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          'njëqind e njëzet e tre triliard e katërqind e pesëdhjetë e gjashtë trilion e shtatëqind e tetëdhjetë e nëntë biliard e njëqind e njëzet e tre bilion e katërqind e pesëdhjetë e gjashtë miliard e shtatëqind e tetëdhjetë e nëntë milion e njëqind e njëzet e tre mijë e katërqind e pesëdhjetë e gjashtë',
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          'nëntëqind e nëntëdhjetë e nëntë triliard e nëntëqind e nëntëdhjetë e nëntë trilion e nëntëqind e nëntëdhjetë e nëntë biliard e nëntëqind e nëntëdhjetë e nëntë bilion e nëntëqind e nëntëdhjetë e nëntë miliard e nëntëqind e nëntëdhjetë e nëntë milion e nëntëqind e nëntëdhjetë e nëntë mijë e nëntëqind e nëntëdhjetë e nëntë',
        ),
      );
    });
  });
}
