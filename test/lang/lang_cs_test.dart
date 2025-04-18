import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Czech (CS)', () {
    final converter = Num2Text(initialLang: Lang.CS);
    final converterWithFallback =
        Num2Text(initialLang: Lang.CS, fallbackOnError: "Neplatné číslo");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("nula"));
      expect(converter.convert(1), equals("jedna"));
      expect(converter.convert(1, options: CsOptions(gender: Gender.masculine)),
          equals("jeden"));
      expect(converter.convert(10), equals("deset"));
      expect(converter.convert(11), equals("jedenáct"));
      expect(converter.convert(20), equals("dvacet"));
      expect(converter.convert(21), equals("dvacet jedna"));
      expect(
        converter.convert(21, options: CsOptions(gender: Gender.masculine)),
        equals("dvacet jeden"),
      );
      expect(converter.convert(99), equals("devadesát devět"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("sto"));
      expect(converter.convert(101), equals("sto jedna"));
      expect(converter.convert(111), equals("sto jedenáct"));
      expect(converter.convert(200), equals("dvě stě"));
      expect(converter.convert(999), equals("devět set devadesát devět"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("tisíc"));
      expect(converter.convert(1001), equals("tisíc jedna"));
      expect(converter.convert(1111), equals("tisíc sto jedenáct"));
      expect(converter.convert(2000), equals("dva tisíce"));
      expect(converter.convert(10000), equals("deset tisíc"));
      expect(converter.convert(100000), equals("sto tisíc"));

      expect(converter.convert(123456),
          equals("sto dvacet tři tisíc čtyři sta padesát šest"));
      expect(
        converter.convert(999999),
        equals("devět set devadesát devět tisíc devět set devadesát devět"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("mínus jedna"));
      expect(converter.convert(-123), equals("mínus sto dvacet tři"));
      expect(
        converter.convert(-1, options: CsOptions(negativePrefix: "záporné")),
        equals("záporné jedna"),
      );
      expect(
        converter.convert(-123, options: CsOptions(negativePrefix: "záporné")),
        equals("záporné sto dvacet tři"),
      );
    });

    test('Year Formatting', () {
      const yearOption = CsOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("tisíc devět set"));
      expect(converter.convert(2024, options: yearOption),
          equals("dva tisíce dvacet čtyři"));
      expect(
        converter.convert(1900,
            options: CsOptions(format: Format.year, includeAD: true)),
        equals("tisíc devět set n. l."),
      );
      expect(
        converter.convert(2024,
            options: CsOptions(format: Format.year, includeAD: true)),
        equals("dva tisíce dvacet čtyři n. l."),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("sto př. n. l."));
      expect(converter.convert(-1, options: yearOption),
          equals("jedna př. n. l."));
      expect(
        converter.convert(-2024,
            options: CsOptions(format: Format.year, includeAD: true)),
        equals("dva tisíce dvacet čtyři př. n. l."),
      );
    });

    group('Currency (CZK)', () {
      test('Handles CZK Currency', () {
        const currencyOption = CsOptions(currency: true);
        expect(converter.convert(0, options: currencyOption),
            equals("nula korun českých"));
        expect(converter.convert(1, options: currencyOption),
            equals("jedna koruna česká"));
        expect(converter.convert(2, options: currencyOption),
            equals("dvě koruny české"));
        expect(converter.convert(5, options: currencyOption),
            equals("pět korun českých"));
        expect(
          converter.convert(1.50, options: currencyOption),
          equals("jedna koruna česká a padesát haléřů"),
        );
        expect(
          converter.convert(2.01, options: currencyOption),
          equals("dvě koruny české a jeden haléř"),
        );
        expect(
          converter.convert(2.02, options: currencyOption),
          equals("dvě koruny české a dva haléře"),
        );
        expect(
          converter.convert(2.05, options: currencyOption),
          equals("dvě koruny české a pět haléřů"),
        );
        expect(
          converter.convert(123.45, options: currencyOption),
          equals("sto dvacet tři korun českých a čtyřicet pět haléřů"),
        );

        expect(converter.convert(3, options: currencyOption),
            equals("tři koruny české"));
      });
    });

    group('Decimals', () {
      test('Handles Decimals', () {
        expect(
          converter.convert(Decimal.parse('123.456')),
          equals("sto dvacet tři celá čtyři pět šest"),
        );
        expect(
            converter.convert(Decimal.parse('1.50')), equals("jedna celá pět"));
        expect(converter.convert(123.0), equals("sto dvacet tři"));
        expect(converter.convert(Decimal.parse('123.0')),
            equals("sto dvacet tři"));
        expect(
          converter.convert(
            1.5,
            options: const CsOptions(decimalSeparator: DecimalSeparator.comma),
          ),
          equals("jedna celá pět"),
        );
        expect(
          converter.convert(
            1.5,
            options: const CsOptions(decimalSeparator: DecimalSeparator.period),
          ),
          equals("jedna tečka pět"),
        );
        expect(
          converter.convert(1.5,
              options: CsOptions(decimalSeparator: DecimalSeparator.point)),
          equals("jedna tečka pět"),
        );

        expect(
          converter.convert(Decimal.parse('1.5'),
              options: CsOptions(gender: Gender.masculine)),
          equals("jeden celá pět"),
        );
      });
    });

    group('Handles infinity and invalid', () {
      test('Handles infinity and invalid input', () {
        expect(converter.convert(double.infinity), equals("Nekonečno"));
        expect(converter.convert(double.negativeInfinity),
            equals("Záporné nekonečno"));
        expect(converter.convert(double.nan), equals("Není číslo"));
        expect(converter.convert(null), equals("Není číslo"));
        expect(converter.convert('abc'), equals("Není číslo"));

        expect(converterWithFallback.convert(double.infinity),
            equals("Nekonečno"));
        expect(converterWithFallback.convert(double.negativeInfinity),
            equals("Záporné nekonečno"));
        expect(converterWithFallback.convert(double.nan),
            equals("Neplatné číslo"));
        expect(converterWithFallback.convert(null), equals("Neplatné číslo"));
        expect(converterWithFallback.convert('abc'), equals("Neplatné číslo"));
        expect(converterWithFallback.convert(123), equals("sto dvacet tři"));
      });
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("jeden milion"));
      expect(
          converter.convert(BigInt.from(1000000000)), equals("jedna miliarda"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("jeden bilion"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("jedna biliarda"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("jeden trilion"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("jedna triliarda"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("jeden kvadrilion"),
      );

      expect(
        converter.convert(BigInt.parse('123456789123456789')),
        equals(
          "sto dvacet tři biliard čtyři sta padesát šest bilionů sedm set osmdesát devět miliard sto dvacet tři milionů čtyři sta padesát šest tisíc sedm set osmdesát devět",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999')),
        equals(
          "devět set devadesát devět biliard devět set devadesát devět bilionů devět set devadesát devět miliard devět set devadesát devět milionů devět set devadesát devět tisíc devět set devadesát devět",
        ),
      );

      expect(converter.convert(BigInt.from(2000000)), equals("dva miliony"));
      expect(
          converter.convert(BigInt.from(3000000000)), equals("tři miliardy"));
    });
  });
}
