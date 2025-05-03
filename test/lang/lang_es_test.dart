import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Spanish (ES)', () {
    final converter = Num2Text(initialLang: Lang.ES);
    final converterWithFallback =
        Num2Text(initialLang: Lang.ES, fallbackOnError: "Número Inválido");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("cero"));
      expect(converter.convert(10), equals("diez"));
      expect(converter.convert(11), equals("once"));
      expect(converter.convert(13), equals("trece"));
      expect(converter.convert(15), equals("quince"));
      expect(converter.convert(16), equals("dieciséis"));
      expect(converter.convert(20), equals("veinte"));
      expect(converter.convert(21), equals("veintiuno"));
      expect(converter.convert(22), equals("veintidós"));
      expect(converter.convert(27), equals("veintisiete"));
      expect(converter.convert(30), equals("treinta"));
      expect(converter.convert(31), equals("treinta y uno"));
      expect(converter.convert(54), equals("cincuenta y cuatro"));
      expect(converter.convert(68), equals("sesenta y ocho"));
      expect(converter.convert(99), equals("noventa y nueve"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("cien"));
      expect(converter.convert(101), equals("ciento uno"));
      expect(converter.convert(105), equals("ciento cinco"));
      expect(converter.convert(110), equals("ciento diez"));
      expect(converter.convert(111), equals("ciento once"));
      expect(converter.convert(123), equals("ciento veintitrés"));
      expect(converter.convert(200), equals("doscientos"));
      expect(converter.convert(321), equals("trescientos veintiuno"));
      expect(converter.convert(479), equals("cuatrocientos setenta y nueve"));
      expect(converter.convert(500), equals("quinientos"));
      expect(converter.convert(596), equals("quinientos noventa y seis"));
      expect(converter.convert(681), equals("seiscientos ochenta y uno"));
      expect(converter.convert(700), equals("setecientos"));
      expect(converter.convert(900), equals("novecientos"));
      expect(converter.convert(999), equals("novecientos noventa y nueve"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("mil"));
      expect(converter.convert(1001), equals("mil uno"));
      expect(converter.convert(1011), equals("mil once"));
      expect(converter.convert(1110), equals("mil ciento diez"));
      expect(converter.convert(1111), equals("mil ciento once"));
      expect(converter.convert(2000), equals("dos mil"));
      expect(converter.convert(2468),
          equals("dos mil cuatrocientos sesenta y ocho"));
      expect(converter.convert(3579),
          equals("tres mil quinientos setenta y nueve"));
      expect(converter.convert(10000), equals("diez mil"));
      expect(converter.convert(10011), equals("diez mil once"));
      expect(converter.convert(11100), equals("once mil cien"));
      expect(converter.convert(12987),
          equals("doce mil novecientos ochenta y siete"));
      expect(converter.convert(45623),
          equals("cuarenta y cinco mil seiscientos veintitrés"));
      expect(converter.convert(87654),
          equals("ochenta y siete mil seiscientos cincuenta y cuatro"));
      expect(converter.convert(100000), equals("cien mil"));
      expect(converter.convert(123456),
          equals("ciento veintitrés mil cuatrocientos cincuenta y seis"));
      expect(
          converter.convert(987654),
          equals(
              "novecientos ochenta y siete mil seiscientos cincuenta y cuatro"));
      expect(
          converter.convert(999999),
          equals(
              "novecientos noventa y nueve mil novecientos noventa y nueve"));
    });

    test('Negative Numbers', () {
      const negativePrefixOption = EsOptions(negativePrefix: "negativo");

      expect(converter.convert(-1), equals("menos uno"));
      expect(converter.convert(-123), equals("menos ciento veintitrés"));
      expect(converter.convert(-123.456),
          equals("menos ciento veintitrés coma cuatro cinco seis"));

      expect(converter.convert(-1, options: negativePrefixOption),
          equals("negativo uno"));
      expect(converter.convert(-123, options: negativePrefixOption),
          equals("negativo ciento veintitrés"));
      expect(converter.convert(-123.456, options: negativePrefixOption),
          equals("negativo ciento veintitrés coma cuatro cinco seis"));
    });

    test('Decimals', () {
      const pointOption = EsOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = EsOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = EsOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(123.456),
          equals("ciento veintitrés coma cuatro cinco seis"));
      expect(converter.convert("1.50"), equals("uno coma cinco"));
      expect(converter.convert(1.05), equals("uno coma cero cinco"));
      expect(converter.convert(879.465),
          equals("ochocientos setenta y nueve coma cuatro seis cinco"));
      expect(converter.convert(1.5), equals("uno coma cinco"));

      expect(converter.convert(1.5, options: pointOption),
          equals("uno punto cinco"));
      expect(converter.convert(1.5, options: commaOption),
          equals("uno coma cinco"));
      expect(converter.convert(1.5, options: periodOption),
          equals("uno punto cinco"));
    });

    test('Year Formatting', () {
      const yearOption = EsOptions(format: Format.year);
      const yearOptionAD = EsOptions(format: Format.year, includeAD: true);

      expect(converter.convert(123, options: yearOption),
          equals("ciento veintitrés"));
      expect(converter.convert(498, options: yearOption),
          equals("cuatrocientos noventa y ocho"));
      expect(converter.convert(756, options: yearOption),
          equals("setecientos cincuenta y seis"));
      expect(converter.convert(1900, options: yearOption),
          equals("mil novecientos"));
      expect(converter.convert(1999, options: yearOption),
          equals("mil novecientos noventa y nueve"));
      expect(converter.convert(2025, options: yearOption),
          equals("dos mil veinticinco"));

      expect(converter.convert(1900, options: yearOptionAD),
          equals("mil novecientos d.C."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("mil novecientos noventa y nueve d.C."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("dos mil veinticinco d.C."));
      expect(converter.convert(-1, options: yearOption), equals("uno a.C."));
      expect(converter.convert(-100, options: yearOption), equals("cien a.C."));
      expect(
          converter.convert(-100, options: yearOptionAD), equals("cien a.C."));
      expect(converter.convert(-2025, options: yearOption),
          equals("dos mil veinticinco a.C."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("un millón a.C."));
    });

    test('Currency', () {
      const currencyOption = EsOptions(currency: true);

      expect(
          converter.convert(0, options: currencyOption), equals("cero euros"));
      expect(converter.convert(1, options: currencyOption), equals("un euro"));
      expect(
          converter.convert(2, options: currencyOption), equals("dos euros"));
      expect(
          converter.convert(5, options: currencyOption), equals("cinco euros"));
      expect(
          converter.convert(10, options: currencyOption), equals("diez euros"));
      expect(
          converter.convert(11, options: currencyOption), equals("once euros"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("un euro con cincuenta céntimos"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("ciento veintitrés euros con cuarenta y cinco céntimos"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("diez millones euros"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("un céntimo"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("cincuenta céntimos"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("un euro con un céntimo"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("dos euros con dos céntimos"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("un millón"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("dos mil millones"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("tres billones"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("cuatro mil billones"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("cinco trillones"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("seis mil trillones"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("siete cuatrillones"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "nueve trillones ochocientos setenta y seis mil quinientos cuarenta y tres billones doscientos diez mil ciento veintitrés millones cuatrocientos cincuenta y seis mil setecientos ochenta y nueve"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "ciento veintitrés mil cuatrocientos cincuenta y seis trillones setecientos ochenta y nueve mil ciento veintitrés billones cuatrocientos cincuenta y seis mil setecientos ochenta y nueve millones ciento veintitrés mil cuatrocientos cincuenta y seis"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "novecientos noventa y nueve mil novecientos noventa y nueve trillones novecientos noventa y nueve mil novecientos noventa y nueve billones novecientos noventa y nueve mil novecientos noventa y nueve millones novecientos noventa y nueve mil novecientos noventa y nueve"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("un billón dos millones tres"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("cinco millones mil"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals('mil millones uno'));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("mil un millones"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("dos millones mil"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "un billón novecientos ochenta y siete millones seiscientos mil tres"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("No Es Un Número"));
      expect(converter.convert(double.infinity), equals("Infinito"));
      expect(
          converter.convert(double.negativeInfinity), equals("Menos Infinito"));
      expect(converter.convert(null), equals("No Es Un Número"));
      expect(converter.convert('abc'), equals("No Es Un Número"));
      expect(converter.convert([]), equals("No Es Un Número"));
      expect(converter.convert({}), equals("No Es Un Número"));
      expect(converter.convert(Object()), equals("No Es Un Número"));

      expect(
          converterWithFallback.convert(double.nan), equals("Número Inválido"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Infinito"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Menos Infinito"));
      expect(converterWithFallback.convert(null), equals("Número Inválido"));
      expect(converterWithFallback.convert('abc'), equals("Número Inválido"));
      expect(converterWithFallback.convert([]), equals("Número Inválido"));
      expect(converterWithFallback.convert({}), equals("Número Inválido"));
      expect(
          converterWithFallback.convert(Object()), equals("Número Inválido"));
      expect(converterWithFallback.convert(123), equals("ciento veintitrés"));
    });
  });
}
