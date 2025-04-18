import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Spanish (ES)', () {
    final converter = Num2Text(initialLang: Lang.ES);
    final converterWithFallback = Num2Text(
      initialLang: Lang.ES,
      fallbackOnError: "Número inválido",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("cero"));
      expect(converter.convert(1), equals("uno"));
      expect(converter.convert(10), equals("diez"));
      expect(converter.convert(11), equals("once"));
      expect(converter.convert(16), equals("dieciséis"));
      expect(converter.convert(20), equals("veinte"));
      expect(converter.convert(21), equals("veintiuno"));
      expect(converter.convert(22), equals("veintidós"));
      expect(converter.convert(30), equals("treinta"));
      expect(converter.convert(31), equals("treinta y uno"));
      expect(converter.convert(99), equals("noventa y nueve"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("cien"));
      expect(converter.convert(101), equals("ciento uno"));
      expect(converter.convert(111), equals("ciento once"));
      expect(converter.convert(200), equals("doscientos"));
      expect(converter.convert(500), equals("quinientos"));
      expect(converter.convert(700), equals("setecientos"));
      expect(converter.convert(900), equals("novecientos"));
      expect(converter.convert(999), equals("novecientos noventa y nueve"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("mil"));
      expect(converter.convert(1001), equals("mil uno"));
      expect(converter.convert(1111), equals("mil ciento once"));
      expect(converter.convert(2000), equals("dos mil"));
      expect(converter.convert(10000), equals("diez mil"));
      expect(converter.convert(100000), equals("cien mil"));
      expect(
        converter.convert(123456),
        equals("ciento veintitrés mil cuatrocientos cincuenta y seis"),
      );
      expect(
        converter.convert(999999),
        equals("novecientos noventa y nueve mil novecientos noventa y nueve"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("menos uno"));
      expect(converter.convert(-123), equals("menos ciento veintitrés"));
      expect(
        converter.convert(-1, options: EsOptions(negativePrefix: "negativo")),
        equals("negativo uno"),
      );
      expect(
        converter.convert(-123, options: EsOptions(negativePrefix: "negativo")),
        equals("negativo ciento veintitrés"),
      );
    });

    test('Year Formatting', () {
      const yearOption = EsOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("mil novecientos"));
      expect(converter.convert(2024, options: yearOption),
          equals("dos mil veinticuatro"));
      expect(
        converter.convert(1900,
            options: EsOptions(format: Format.year, includeAD: true)),
        equals("mil novecientos d.C."),
      );
      expect(
        converter.convert(2024,
            options: EsOptions(format: Format.year, includeAD: true)),
        equals("dos mil veinticuatro d.C."),
      );
      expect(converter.convert(-100, options: yearOption), equals("cien a.C."));
      expect(converter.convert(-1, options: yearOption), equals("uno a.C."));

      expect(
        converter.convert(-2024,
            options: EsOptions(format: Format.year, includeAD: true)),
        equals("dos mil veinticuatro a.C."),
      );
    });

    test('Currency', () {
      const currencyOption = EsOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("cero euros"));
      expect(converter.convert(1, options: currencyOption), equals("un euro"));
      expect(
          converter.convert(2, options: currencyOption), equals("dos euros"));
      expect(
        converter.convert(1.50, options: currencyOption),
        equals("un euro con cincuenta céntimos"),
      );
      expect(converter.convert(1.01, options: currencyOption),
          equals("un euro con un céntimo"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("ciento veintitrés euros con cuarenta y cinco céntimos"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("ciento veintitrés coma cuatro cinco seis"),
      );
      expect(
          converter.convert(Decimal.parse('1.50')), equals("uno coma cinco"));
      expect(converter.convert(Decimal.parse('1.05')),
          equals("uno coma cero cinco"));
      expect(converter.convert(123.0), equals("ciento veintitrés"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("ciento veintitrés"));

      expect(
        converter.convert(1.5,
            options: const EsOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("uno coma cinco"),
      );

      expect(
        converter.convert(1.5,
            options:
                const EsOptions(decimalSeparator: DecimalSeparator.period)),
        equals("uno punto cinco"),
      );
      expect(
        converter.convert(1.5,
            options: const EsOptions(decimalSeparator: DecimalSeparator.point)),
        equals("uno punto cinco"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Infinito"));
      expect(
          converter.convert(double.negativeInfinity), equals("Menos Infinito"));
      expect(converter.convert(double.nan), equals("No es un número"));
      expect(converter.convert(null), equals("No es un número"));
      expect(converter.convert('abc'), equals("No es un número"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Infinito"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Menos Infinito"));
      expect(
          converterWithFallback.convert(double.nan), equals("Número inválido"));
      expect(converterWithFallback.convert(null), equals("Número inválido"));
      expect(converterWithFallback.convert('abc'), equals("Número inválido"));
      expect(converterWithFallback.convert(123), equals("ciento veintitrés"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("un millón"));
      expect(converter.convert(BigInt.from(2000000)), equals("dos millones"));

      expect(
          converter.convert(BigInt.from(1000000000)), equals("mil millones"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("un billón"));
      expect(converter.convert(BigInt.from(2000000000000)),
          equals("dos billones"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("mil billones"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("un trillón"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("mil trillones"));

      expect(
        converter.convert(BigInt.parse('123456789123456')),
        equals(
          "ciento veintitrés billones cuatrocientos cincuenta y seis mil setecientos ochenta y nueve millones ciento veintitrés mil cuatrocientos cincuenta y seis",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "novecientos noventa y nueve mil novecientos noventa y nueve trillones novecientos noventa y nueve mil novecientos noventa y nueve billones novecientos noventa y nueve mil novecientos noventa y nueve millones novecientos noventa y nueve mil novecientos noventa y nueve",
        ),
      );
    });
  });
}
