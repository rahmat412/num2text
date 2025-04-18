import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Portuguese (PT)', () {
    final converter = Num2Text(initialLang: Lang.PT);
    final converterWithFallback = Num2Text(
      initialLang: Lang.PT,
      fallbackOnError: "Número Inválido",
    );

    test('Basic Numbers (0-99)', () {
      expect(converter.convert(0), equals("zero"));
      expect(converter.convert(1), equals("um"));
      expect(converter.convert(10), equals("dez"));
      expect(converter.convert(11), equals("onze"));
      expect(converter.convert(16), equals("dezesseis"));
      expect(converter.convert(20), equals("vinte"));
      expect(converter.convert(21), equals("vinte e um"));
      expect(converter.convert(30), equals("trinta"));
      expect(converter.convert(32), equals("trinta e dois"));
      expect(converter.convert(99), equals("noventa e nove"));
    });

    test('Hundreds (100-999)', () {
      expect(converter.convert(100), equals("cem"));
      expect(converter.convert(101), equals("cento e um"));
      expect(converter.convert(111), equals("cento e onze"));
      expect(converter.convert(123), equals("cento e vinte e três"));
      expect(converter.convert(200), equals("duzentos"));
      expect(converter.convert(300), equals("trezentos"));
      expect(converter.convert(400), equals("quatrocentos"));
      expect(converter.convert(500), equals("quinhentos"));
      expect(converter.convert(600), equals("seiscentos"));
      expect(converter.convert(700), equals("setecentos"));
      expect(converter.convert(800), equals("oitocentos"));
      expect(converter.convert(900), equals("novecentos"));
      expect(converter.convert(999), equals("novecentos e noventa e nove"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("mil"));
      expect(converter.convert(1001), equals("mil e um"));
      expect(converter.convert(1100), equals("mil e cem"));
      expect(converter.convert(1111), equals("mil cento e onze"));
      expect(converter.convert(2000), equals("dois mil"));
      expect(converter.convert(10000), equals("dez mil"));
      expect(converter.convert(100000), equals("cem mil"));
      expect(
        converter.convert(123456),
        equals("cento e vinte e três mil quatrocentos e cinquenta e seis"),
      );
      expect(
        converter.convert(999999),
        equals("novecentos e noventa e nove mil novecentos e noventa e nove"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("menos um"));
      expect(converter.convert(-123), equals("menos cento e vinte e três"));
      expect(
        converter.convert(-1,
            options: const PtOptions(negativePrefix: "negativo")),
        equals("negativo um"),
      );
      expect(
        converter.convert(-123,
            options: const PtOptions(negativePrefix: "negativo")),
        equals("negativo cento e vinte e três"),
      );
    });

    test('Year Formatting', () {
      const yearOption = PtOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("mil novecentos"));
      expect(converter.convert(2024, options: yearOption),
          equals("dois mil e vinte e quatro"));

      expect(
        converter.convert(1900,
            options: const PtOptions(format: Format.year, includeAD: true)),
        equals("mil novecentos d.C."),
      );
      expect(
        converter.convert(2024,
            options: const PtOptions(format: Format.year, includeAD: true)),
        equals("dois mil e vinte e quatro d.C."),
      );
      expect(converter.convert(-100, options: yearOption), equals("cem a.C."));
      expect(converter.convert(-1, options: yearOption), equals("um a.C."));
      expect(
        converter.convert(-2024,
            options: const PtOptions(format: Format.year, includeAD: true)),
        equals("dois mil e vinte e quatro a.C."),
      );
    });

    test('Currency (BRL - Brazilian Real)', () {
      const currencyOptionBRL = PtOptions(currency: true);
      expect(converter.convert(0, options: currencyOptionBRL),
          equals("zero reais"));
      expect(
          converter.convert(1, options: currencyOptionBRL), equals("um real"));
      expect(converter.convert(2, options: currencyOptionBRL),
          equals("dois reais"));
      expect(converter.convert(1.00, options: currencyOptionBRL),
          equals("um real"));
      expect(
        converter.convert(1.50, options: currencyOptionBRL),
        equals("um real e cinquenta centavos"),
      );
      expect(
        converter.convert(Decimal.parse('1.50'), options: currencyOptionBRL),
        equals("um real e cinquenta centavos"),
      );
      expect(
        converter.convert(2.05, options: currencyOptionBRL),
        equals("dois reais e cinco centavos"),
      );
      expect(
        converter.convert(0.75, options: currencyOptionBRL),
        equals("setenta e cinco centavos"),
      );
      expect(
        converter.convert(123.45, options: currencyOptionBRL),
        equals("cento e vinte e três reais e quarenta e cinco centavos"),
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
      expect(converter.convert(2, options: currencyOptionEUR),
          equals("dois euros"));
      expect(converter.convert(1.00, options: currencyOptionEUR),
          equals("um euro"));
      expect(
        converter.convert(1.50, options: currencyOptionEUR),
        equals("um euro e cinquenta cêntimos"),
      );
      expect(
        converter.convert(Decimal.parse('1.50'), options: currencyOptionEUR),
        equals("um euro e cinquenta cêntimos"),
      );
      expect(
        converter.convert(2.05, options: currencyOptionEUR),
        equals("dois euros e cinco cêntimos"),
      );
      expect(
        converter.convert(0.75, options: currencyOptionEUR),
        equals("setenta e cinco cêntimos"),
      );
      expect(
        converter.convert(123.45, options: currencyOptionEUR),
        equals("cento e vinte e três euros e quarenta e cinco cêntimos"),
      );
      expect(converter.convert(1000, options: currencyOptionEUR),
          equals("mil euros"));
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("cento e vinte e três vírgula quatro cinco seis"),
      );

      expect(
          converter.convert(Decimal.parse('1.50')), equals("um vírgula cinco"));
      expect(converter.convert(Decimal.parse('1.05')),
          equals("um vírgula zero cinco"));
      expect(converter.convert(1.5), equals("um vírgula cinco"));
      expect(converter.convert(123.0), equals("cento e vinte e três"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("cento e vinte e três"));

      expect(
        converter.convert(1.5,
            options: const PtOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("um vírgula cinco"),
      );
      expect(
        converter.convert(1.5,
            options: const PtOptions(decimalSeparator: DecimalSeparator.point)),
        equals("um ponto cinco"),
      );
      expect(
        converter.convert(1.5,
            options:
                const PtOptions(decimalSeparator: DecimalSeparator.period)),
        equals("um ponto cinco"),
      );
      expect(converter.convert(0.5, options: const PtOptions()),
          equals("zero vírgula cinco"));
    });

    test('Handles infinity and invalid', () {
      expect(
          converterWithFallback.convert(double.nan), equals("Número Inválido"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Infinito"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Menos Infinito"));
      expect(converterWithFallback.convert(null), equals("Número Inválido"));
      expect(converterWithFallback.convert('abc'), equals("Número Inválido"));
      expect(
          converterWithFallback.convert(123), equals("cento e vinte e três"));

      expect(converter.convert(double.nan), equals("Não é um número"));
      expect(converter.convert(double.infinity), equals("Infinito"));
      expect(
          converter.convert(double.negativeInfinity), equals("Menos Infinito"));
      expect(converter.convert(null), equals("Não é um número"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("um milhão"));
      expect(converter.convert(BigInt.from(2000000)), equals("dois milhões"));
      expect(converter.convert(BigInt.from(1000000000)), equals("um bilhão"));
      expect(
          converter.convert(BigInt.from(2000000000)), equals("dois bilhões"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("um trilhão"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("um bilhão e um"));
      expect(converter.convert(BigInt.parse('1000000100')),
          equals("um bilhão e cem"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("um bilhão e um milhão"));
      expect(converter.convert(BigInt.parse('1001001')),
          equals("um milhão mil e um"));
      expect(
        converter.convert(BigInt.parse('2000123')),
        equals("dois milhões cento e vinte e três"),
      );

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "cento e vinte e três sextilhões quatrocentos e cinquenta e seis quintilhões setecentos e oitenta e nove quatrilhões cento e vinte e três trilhões quatrocentos e cinquenta e seis bilhões setecentos e oitenta e nove milhões cento e vinte e três mil quatrocentos e cinquenta e seis",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "novecentos e noventa e nove sextilhões novecentos e noventa e nove quintilhões novecentos e noventa e nove quatrilhões novecentos e noventa e nove trilhões novecentos e noventa e nove bilhões novecentos e noventa e nove milhões novecentos e noventa e nove mil novecentos e noventa e nove",
        ),
      );
    });
  });
}
