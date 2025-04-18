import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Polish (PL)', () {
    final converter = Num2Text(initialLang: Lang.PL);
    final converterWithFallback = Num2Text(
      initialLang: Lang.PL,
      fallbackOnError: "Nieprawidłowy numer",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("zero"));
      expect(converter.convert(1), equals("jeden"));
      expect(converter.convert(2), equals("dwa"));
      expect(converter.convert(5), equals("pięć"));
      expect(converter.convert(10), equals("dziesięć"));
      expect(converter.convert(11), equals("jedenaście"));
      expect(converter.convert(20), equals("dwadzieścia"));
      expect(converter.convert(21), equals("dwadzieścia jeden"));
      expect(converter.convert(22), equals("dwadzieścia dwa"));
      expect(converter.convert(99), equals("dziewięćdziesiąt dziewięć"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("sto"));
      expect(converter.convert(101), equals("sto jeden"));
      expect(converter.convert(111), equals("sto jedenaście"));
      expect(converter.convert(200), equals("dwieście"));
      expect(converter.convert(999),
          equals("dziewięćset dziewięćdziesiąt dziewięć"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("jeden tysiąc"));
      expect(converter.convert(1001), equals("jeden tysiąc jeden"));
      expect(converter.convert(1111), equals("jeden tysiąc sto jedenaście"));
      expect(converter.convert(2000), equals("dwa tysiące"));
      expect(converter.convert(5000), equals("pięć tysięcy"));
      expect(converter.convert(10000), equals("dziesięć tysięcy"));
      expect(converter.convert(100000), equals("sto tysięcy"));
      expect(
        converter.convert(123456),
        equals("sto dwadzieścia trzy tysiące czterysta pięćdziesiąt sześć"),
      );
      expect(
        converter.convert(125456),
        equals("sto dwadzieścia pięć tysięcy czterysta pięćdziesiąt sześć"),
      );
      expect(
        converter.convert(999999),
        equals(
          "dziewięćset dziewięćdziesiąt dziewięć tysięcy dziewięćset dziewięćdziesiąt dziewięć",
        ),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus jeden"));
      expect(converter.convert(-123), equals("minus sto dwadzieścia trzy"));
      expect(
        converter.convert(-1, options: PlOptions(negativePrefix: "ujemny")),
        equals("ujemny jeden"),
      );
      expect(
        converter.convert(-123, options: PlOptions(negativePrefix: "ujemny")),
        equals("ujemny sto dwadzieścia trzy"),
      );
    });

    test('Year Formatting', () {
      const yearOption = PlOptions(format: Format.year);
      const yearOptionAD = PlOptions(format: Format.year, includeAD: true);

      expect(converter.convert(1900, options: yearOption),
          equals("jeden tysiąc dziewięćset"));
      expect(
        converter.convert(2024, options: yearOption),
        equals("dwa tysiące dwadzieścia cztery"),
      );
      expect(
        converter.convert(2024, options: yearOptionAD),
        equals("dwa tysiące dwadzieścia cztery n.e."),
      );
      expect(
          converter.convert(-100, options: yearOption), equals("sto p.n.e."));
      expect(
          converter.convert(-1, options: yearOption), equals("jeden p.n.e."));
      expect(
        converter.convert(-2024, options: yearOption),
        equals("dwa tysiące dwadzieścia cztery p.n.e."),
      );
      expect(
          converter.convert(-100, options: yearOptionAD), equals("sto p.n.e."));
    });

    test('Currency (PLN)', () {
      const currencyOption = PlOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("zero złotych"));
      expect(
          converter.convert(1, options: currencyOption), equals("jeden złoty"));
      expect(
          converter.convert(2, options: currencyOption), equals("dwa złote"));
      expect(converter.convert(5, options: currencyOption),
          equals("pięć złotych"));
      expect(converter.convert(23, options: currencyOption),
          equals("dwadzieścia trzy złote"));
      expect(
        converter.convert(1.50, options: currencyOption),
        equals("jeden złoty i pięćdziesiąt groszy"),
      );
      expect(converter.convert(2.01, options: currencyOption),
          equals("dwa złote i jeden grosz"));
      expect(converter.convert(5.02, options: currencyOption),
          equals("pięć złotych i dwa grosze"));
      expect(
        converter.convert(21.05, options: currencyOption),
        equals("dwadzieścia jeden złotych i pięć groszy"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("sto dwadzieścia trzy złote i czterdzieści pięć groszy"),
      );

      expect(
        converter.convert(123.456, options: currencyOption),
        equals("sto dwadzieścia trzy złote i czterdzieści sześć groszy"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("sto dwadzieścia trzy przecinek cztery pięć sześć"),
      );

      expect(converter.convert(Decimal.parse('1.50')),
          equals("jeden przecinek pięć"));

      expect(converter.convert(Decimal.parse('1.05')),
          equals("jeden przecinek zero pięć"));
      expect(converter.convert(123.0), equals("sto dwadzieścia trzy"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("sto dwadzieścia trzy"));

      expect(
        converter.convert(1.5,
            options: const PlOptions(decimalSeparator: DecimalSeparator.point)),
        equals("jeden kropka pięć"),
      );

      expect(
        converter.convert(1.5,
            options: const PlOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("jeden przecinek pięć"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("nieskończoność"));
      expect(converter.convert(double.negativeInfinity),
          equals("minus nieskończoność"));
      expect(converter.convert(double.nan), equals("nie liczba"));
      expect(converter.convert(null), equals("nie liczba"));
      expect(converter.convert('abc'), equals("nie liczba"));

      expect(converterWithFallback.convert(double.infinity),
          equals("nieskończoność"));
      expect(
        converterWithFallback.convert(double.negativeInfinity),
        equals("minus nieskończoność"),
      );
      expect(converterWithFallback.convert(double.nan),
          equals("Nieprawidłowy numer"));
      expect(
          converterWithFallback.convert(null), equals("Nieprawidłowy numer"));
      expect(
          converterWithFallback.convert('abc'), equals("Nieprawidłowy numer"));
      expect(
          converterWithFallback.convert(123), equals("sto dwadzieścia trzy"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("jeden milion"));
      expect(
          converter.convert(BigInt.from(1000000000)), equals("jeden miliard"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("jeden bilion"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("jeden biliard"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("jeden trylion"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("jeden tryliard"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("jeden kwadrylion"),
      );
      expect(converter.convert(BigInt.from(2000000)), equals("dwa miliony"));
      expect(converter.convert(BigInt.from(5000000)), equals("pięć milionów"));

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "sto dwadzieścia trzy tryliardy czterysta pięćdziesiąt sześć trylionów siedemset osiemdziesiąt dziewięć biliardów sto dwadzieścia trzy biliony czterysta pięćdziesiąt sześć miliardów siedemset osiemdziesiąt dziewięć milionów sto dwadzieścia trzy tysiące czterysta pięćdziesiąt sześć",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "dziewięćset dziewięćdziesiąt dziewięć tryliardów dziewięćset dziewięćdziesiąt dziewięć trylionów dziewięćset dziewięćdziesiąt dziewięć biliardów dziewięćset dziewięćdziesiąt dziewięć bilionów dziewięćset dziewięćdziesiąt dziewięć miliardów dziewięćset dziewięćdziesiąt dziewięć milionów dziewięćset dziewięćdziesiąt dziewięć tysięcy dziewięćset dziewięćdziesiąt dziewięć",
        ),
      );
      expect(converter.convert(BigInt.parse('1000001')),
          equals("jeden milion jeden"));
    });
  });
}
