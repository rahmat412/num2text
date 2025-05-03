import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Portuguese (PT)', () {
    final converter = Num2Text(initialLang: Lang.PT);
    final converterWithFallback = Num2Text(
      initialLang: Lang.PT,
      fallbackOnError: "Número Inválido",
    );

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("zero"));
      expect(converter.convert(10), equals("dez"));
      expect(converter.convert(11), equals("onze"));
      expect(converter.convert(13), equals("treze"));
      expect(converter.convert(15), equals("quinze"));
      expect(converter.convert(20), equals("vinte"));
      expect(converter.convert(27), equals("vinte e sete"));
      expect(converter.convert(30), equals("trinta"));
      expect(converter.convert(54), equals("cinquenta e quatro"));
      expect(converter.convert(68), equals("sessenta e oito"));
      expect(converter.convert(99), equals("noventa e nove"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("cem"));
      expect(converter.convert(101), equals("cento e um"));
      expect(converter.convert(105), equals("cento e cinco"));
      expect(converter.convert(110), equals("cento e dez"));
      expect(converter.convert(111), equals("cento e onze"));
      expect(converter.convert(123), equals("cento e vinte e três"));
      expect(converter.convert(200), equals("duzentos"));
      expect(converter.convert(321), equals("trezentos e vinte e um"));
      expect(converter.convert(479), equals("quatrocentos e setenta e nove"));
      expect(converter.convert(596), equals("quinhentos e noventa e seis"));
      expect(converter.convert(681), equals("seiscentos e oitenta e um"));
      expect(converter.convert(999), equals("novecentos e noventa e nove"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("mil"));
      expect(converter.convert(1001), equals("mil e um"));
      expect(converter.convert(1011), equals("mil e onze"));
      expect(converter.convert(1110), equals("mil cento e dez"));
      expect(converter.convert(1111), equals("mil cento e onze"));
      expect(converter.convert(2000), equals("dois mil"));
      expect(converter.convert(2468),
          equals("dois mil quatrocentos e sessenta e oito"));
      expect(converter.convert(3579),
          equals("três mil quinhentos e setenta e nove"));
      expect(converter.convert(10000), equals("dez mil"));
      expect(converter.convert(10011), equals("dez mil e onze"));
      expect(converter.convert(11100), equals("onze mil e cem"));
      expect(converter.convert(12987),
          equals("doze mil novecentos e oitenta e sete"));
      expect(converter.convert(45623),
          equals("quarenta e cinco mil seiscentos e vinte e três"));
      expect(converter.convert(87654),
          equals("oitenta e sete mil seiscentos e cinquenta e quatro"));
      expect(converter.convert(100000), equals("cem mil"));
      expect(
        converter.convert(123456),
        equals("cento e vinte e três mil quatrocentos e cinquenta e seis"),
      );
      expect(
          converter.convert(987654),
          equals(
              "novecentos e oitenta e sete mil seiscentos e cinquenta e quatro"));
      expect(
        converter.convert(999999),
        equals("novecentos e noventa e nove mil novecentos e noventa e nove"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("menos um"));
      expect(converter.convert(-123), equals("menos cento e vinte e três"));
      expect(converter.convert(-123.456),
          equals("menos cento e vinte e três vírgula quatro cinco seis"));
      const options = PtOptions(negativePrefix: "negativo ");
      expect(converter.convert(-1, options: options), equals("negativo um"));
      expect(converter.convert(-123, options: options),
          equals("negativo cento e vinte e três"));
      expect(converter.convert(-123.456, options: options),
          equals("negativo cento e vinte e três vírgula quatro cinco seis"));
    });

    test('Decimals', () {
      expect(
        converter.convert(123.456),
        equals("cento e vinte e três vírgula quatro cinco seis"),
      );
      expect(converter.convert(1.5), equals("um vírgula cinco"));
      expect(converter.convert(1.05), equals("um vírgula zero cinco"));
      expect(converter.convert(879.465),
          equals("oitocentos e setenta e nove vírgula quatro seis cinco"));
      expect(converter.convert(1.5), equals("um vírgula cinco"));

      const pointOption = PtOptions(decimalSeparator: DecimalSeparator.point);
      expect(converter.convert(1.5, options: pointOption),
          equals("um ponto cinco"));
      const commaOption = PtOptions(decimalSeparator: DecimalSeparator.comma);
      expect(converter.convert(1.5, options: commaOption),
          equals("um vírgula cinco"));
      const periodOption = PtOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(1.5, options: periodOption),
          equals("um ponto cinco"));
    });

    test('Year Formatting', () {
      const yearOption = PtOptions(format: Format.year);
      expect(converter.convert(123, options: yearOption),
          equals("cento e vinte e três"));
      expect(converter.convert(498, options: yearOption),
          equals("quatrocentos e noventa e oito"));
      expect(converter.convert(756, options: yearOption),
          equals("setecentos e cinquenta e seis"));
      expect(converter.convert(1900, options: yearOption),
          equals("mil novecentos"));
      expect(converter.convert(1999, options: yearOption),
          equals("mil novecentos e noventa e nove"));
      expect(converter.convert(2025, options: yearOption),
          equals("dois mil e vinte e cinco"));

      const yearOptionAD = PtOptions(format: Format.year, includeAD: true);
      expect(
        converter.convert(1900, options: yearOptionAD),
        equals("mil novecentos d.C."),
      );
      expect(
        converter.convert(1999, options: yearOptionAD),
        equals("mil novecentos e noventa e nove d.C."),
      );
      expect(
        converter.convert(2025, options: yearOptionAD),
        equals("dois mil e vinte e cinco d.C."),
      );
      expect(converter.convert(-1, options: yearOption), equals("um a.C."));
      expect(converter.convert(-100, options: yearOption), equals("cem a.C."));
      expect(
        converter.convert(-100, options: yearOptionAD),
        equals("cem a.C."),
      );
      expect(
        converter.convert(-2025, options: yearOption),
        equals("dois mil e vinte e cinco a.C."),
      );
      expect(
        converter.convert(-1000000, options: yearOption),
        equals("um milhão a.C."),
      );
    });

    test('Currency (BRL - Brazilian Real)', () {
      const currencyOptionBRL = PtOptions(currency: true);
      expect(converter.convert(0, options: currencyOptionBRL),
          equals("zero reais"));
      expect(
          converter.convert(1, options: currencyOptionBRL), equals("um real"));
      expect(converter.convert(5, options: currencyOptionBRL),
          equals("cinco reais"));
      expect(converter.convert(10, options: currencyOptionBRL),
          equals("dez reais"));
      expect(converter.convert(11, options: currencyOptionBRL),
          equals("onze reais"));
      expect(
        converter.convert(1.5, options: currencyOptionBRL),
        equals("um real e cinquenta centavos"),
      );
      expect(
        converter.convert(123.45, options: currencyOptionBRL),
        equals("cento e vinte e três reais e quarenta e cinco centavos"),
      );
      expect(converter.convert(10000000, options: currencyOptionBRL),
          equals("dez milhões de reais"));
      expect(converter.convert(0.01, options: currencyOptionBRL),
          equals("um centavo"));
      expect(converter.convert(0.5, options: currencyOptionBRL),
          equals("cinquenta centavos"));
      expect(converter.convert(2, options: currencyOptionBRL),
          equals("dois reais"));
      expect(converter.convert(1.00, options: currencyOptionBRL),
          equals("um real"));
      expect(
        converter.convert(2.05, options: currencyOptionBRL),
        equals("dois reais e cinco centavos"),
      );
      expect(
        converter.convert(0.75, options: currencyOptionBRL),
        equals("setenta e cinco centavos"),
      );
      expect(converter.convert(1000, options: currencyOptionBRL),
          equals("mil reais"));
    });

    test('Currency (EUR - European Portuguese)', () {
      const currencyOptionEUR =
          PtOptions(currency: true, currencyInfo: CurrencyInfo.eurPt);
      expect(converter.convert(0, options: currencyOptionEUR),
          equals("zero euros"));
      expect(
          converter.convert(1, options: currencyOptionEUR), equals("um euro"));
      expect(converter.convert(5, options: currencyOptionEUR),
          equals("cinco euros"));
      expect(converter.convert(10, options: currencyOptionEUR),
          equals("dez euros"));
      expect(converter.convert(11, options: currencyOptionEUR),
          equals("onze euros"));
      expect(
        converter.convert(1.5, options: currencyOptionEUR),
        equals("um euro e cinquenta cêntimos"),
      );
      expect(
        converter.convert(123.45, options: currencyOptionEUR),
        equals("cento e vinte e três euros e quarenta e cinco cêntimos"),
      );
      expect(converter.convert(10000000, options: currencyOptionEUR),
          equals("dez milhões de euros"));
      expect(converter.convert(0.01, options: currencyOptionEUR),
          equals("um cêntimo"));
      expect(converter.convert(0.5, options: currencyOptionEUR),
          equals("cinquenta cêntimos"));
      expect(converter.convert(2, options: currencyOptionEUR),
          equals("dois euros"));
      expect(converter.convert(1.00, options: currencyOptionEUR),
          equals("um euro"));
      expect(
        converter.convert(2.05, options: currencyOptionEUR),
        equals("dois euros e cinco cêntimos"),
      );
      expect(
        converter.convert(0.75, options: currencyOptionEUR),
        equals("setenta e cinco cêntimos"),
      );
      expect(converter.convert(1000, options: currencyOptionEUR),
          equals("mil euros"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("um milhão"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("dois bilhões"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("três trilhões"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("quatro quatrilhões"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("cinco quintilhões"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("seis sextilhões"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("sete septilhões"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            "nove quintilhões oitocentos e setenta e seis quatrilhões quinhentos e quarenta e três trilhões duzentos e dez bilhões cento e vinte e três milhões quatrocentos e cinquenta e seis mil setecentos e oitenta e nove"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "cento e vinte e três sextilhões quatrocentos e cinquenta e seis quintilhões setecentos e oitenta e nove quatrilhões cento e vinte e três trilhões quatrocentos e cinquenta e seis bilhões setecentos e oitenta e nove milhões cento e vinte e três mil quatrocentos e cinquenta e seis"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "novecentos e noventa e nove sextilhões novecentos e noventa e nove quintilhões novecentos e noventa e nove quatrilhões novecentos e noventa e nove trilhões novecentos e noventa e nove bilhões novecentos e noventa e nove milhões novecentos e noventa e nove mil novecentos e noventa e nove"),
      );

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("um trilhão dois milhões e três"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("cinco milhões e mil"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("um bilhão e um"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("um bilhão e um milhão"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("dois milhões e mil"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "um trilhão novecentos e oitenta e sete milhões seiscentos mil e três"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Não É Um Número"));
      expect(converter.convert(double.infinity), equals("Infinito"));
      expect(
          converter.convert(double.negativeInfinity), equals("Menos Infinito"));
      expect(converter.convert(null), equals("Não É Um Número"));
      expect(converter.convert('abc'), equals("Não É Um Número"));
      expect(converter.convert([]), equals("Não É Um Número"));
      expect(converter.convert({}), equals("Não É Um Número"));
      expect(converter.convert(Object()), equals("Não É Um Número"));

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
      expect(
          converterWithFallback.convert(123), equals("cento e vinte e três"));
    });
  });
}
