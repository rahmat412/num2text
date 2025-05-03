import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Polish (PL)', () {
    final converter = Num2Text(initialLang: Lang.PL);
    final converterWithFallback = Num2Text(
      initialLang: Lang.PL,
      fallbackOnError: "Nieprawidłowy Numer",
    );

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("zero"));
      expect(converter.convert(10), equals("dziesięć"));
      expect(converter.convert(11), equals("jedenaście"));
      expect(converter.convert(13), equals("trzynaście"));
      expect(converter.convert(15), equals("piętnaście"));
      expect(converter.convert(20), equals("dwadzieścia"));
      expect(converter.convert(27), equals("dwadzieścia siedem"));
      expect(converter.convert(30), equals("trzydzieści"));
      expect(converter.convert(54), equals("pięćdziesiąt cztery"));
      expect(converter.convert(68), equals("sześćdziesiąt osiem"));
      expect(converter.convert(99), equals("dziewięćdziesiąt dziewięć"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("sto"));
      expect(converter.convert(101), equals("sto jeden"));
      expect(converter.convert(105), equals("sto pięć"));
      expect(converter.convert(110), equals("sto dziesięć"));
      expect(converter.convert(111), equals("sto jedenaście"));
      expect(converter.convert(123), equals("sto dwadzieścia trzy"));
      expect(converter.convert(200), equals("dwieście"));
      expect(converter.convert(321), equals("trzysta dwadzieścia jeden"));
      expect(
          converter.convert(479), equals("czterysta siedemdziesiąt dziewięć"));
      expect(converter.convert(596), equals("pięćset dziewięćdziesiąt sześć"));
      expect(converter.convert(681), equals("sześćset osiemdziesiąt jeden"));
      expect(converter.convert(999),
          equals("dziewięćset dziewięćdziesiąt dziewięć"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("jeden tysiąc"));
      expect(converter.convert(1001), equals("jeden tysiąc jeden"));
      expect(converter.convert(1011), equals("jeden tysiąc jedenaście"));
      expect(converter.convert(1110), equals("jeden tysiąc sto dziesięć"));
      expect(converter.convert(1111), equals("jeden tysiąc sto jedenaście"));
      expect(converter.convert(2000), equals("dwa tysiące"));
      expect(converter.convert(2468),
          equals("dwa tysiące czterysta sześćdziesiąt osiem"));
      expect(converter.convert(3579),
          equals("trzy tysiące pięćset siedemdziesiąt dziewięć"));
      expect(converter.convert(10000), equals("dziesięć tysięcy"));
      expect(converter.convert(10011), equals("dziesięć tysięcy jedenaście"));
      expect(converter.convert(11100), equals("jedenaście tysięcy sto"));
      expect(converter.convert(12987),
          equals("dwanaście tysięcy dziewięćset osiemdziesiąt siedem"));
      expect(converter.convert(45623),
          equals("czterdzieści pięć tysięcy sześćset dwadzieścia trzy"));
      expect(converter.convert(87654),
          equals("osiemdziesiąt siedem tysięcy sześćset pięćdziesiąt cztery"));
      expect(converter.convert(100000), equals("sto tysięcy"));
      expect(
        converter.convert(123456),
        equals("sto dwadzieścia trzy tysiące czterysta pięćdziesiąt sześć"),
      );
      expect(
          converter.convert(987654),
          equals(
              "dziewięćset osiemdziesiąt siedem tysięcy sześćset pięćdziesiąt cztery"));
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
      expect(converter.convert(-123.456),
          equals("minus sto dwadzieścia trzy przecinek cztery pięć sześć"));
      const options = PlOptions(negativePrefix: "ujemny ");
      expect(converter.convert(-1, options: options), equals("ujemny jeden"));
      expect(converter.convert(-123, options: options),
          equals("ujemny sto dwadzieścia trzy"));
      expect(converter.convert(-123.456, options: options),
          equals("ujemny sto dwadzieścia trzy przecinek cztery pięć sześć"));
    });

    test('Decimals', () {
      expect(
        converter.convert(123.456),
        equals("sto dwadzieścia trzy przecinek cztery pięć sześć"),
      );
      expect(converter.convert(1.5), equals("jeden przecinek pięć"));
      expect(converter.convert(1.05), equals("jeden przecinek zero pięć"));
      expect(
          converter.convert(879.465),
          equals(
              "osiemset siedemdziesiąt dziewięć przecinek cztery sześć pięć"));
      expect(converter.convert(1.5), equals("jeden przecinek pięć"));

      const pointOption = PlOptions(decimalSeparator: DecimalSeparator.point);
      expect(converter.convert(1.5, options: pointOption),
          equals("jeden kropka pięć"));
      const commaOption = PlOptions(decimalSeparator: DecimalSeparator.comma);
      expect(converter.convert(1.5, options: commaOption),
          equals("jeden przecinek pięć"));
      const periodOption = PlOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(1.5, options: periodOption),
          equals("jeden kropka pięć"));
    });

    test('Year Formatting', () {
      const yearOption = PlOptions(format: Format.year);
      expect(converter.convert(123, options: yearOption),
          equals("sto dwadzieścia trzy"));
      expect(converter.convert(498, options: yearOption),
          equals("czterysta dziewięćdziesiąt osiem"));
      expect(converter.convert(756, options: yearOption),
          equals("siedemset pięćdziesiąt sześć"));
      expect(converter.convert(1900, options: yearOption),
          equals("jeden tysiąc dziewięćset"));
      expect(converter.convert(1999, options: yearOption),
          equals("jeden tysiąc dziewięćset dziewięćdziesiąt dziewięć"));
      expect(
        converter.convert(2025, options: yearOption),
        equals("dwa tysiące dwadzieścia pięć"),
      );

      const yearOptionAD = PlOptions(format: Format.year, includeAD: true);
      expect(converter.convert(1900, options: yearOptionAD),
          equals("jeden tysiąc dziewięćset n.e."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("jeden tysiąc dziewięćset dziewięćdziesiąt dziewięć n.e."));
      expect(
        converter.convert(2025, options: yearOptionAD),
        equals("dwa tysiące dwadzieścia pięć n.e."),
      );
      expect(
          converter.convert(-1, options: yearOption), equals("jeden p.n.e."));
      expect(
          converter.convert(-100, options: yearOption), equals("sto p.n.e."));
      expect(
          converter.convert(-100, options: yearOptionAD), equals("sto p.n.e."));
      expect(
        converter.convert(-2025, options: yearOption),
        equals("dwa tysiące dwadzieścia pięć p.n.e."),
      );
      expect(converter.convert(-1000000, options: yearOption),
          equals("jeden milion p.n.e."));
    });

    test('Currency', () {
      const currencyOption = PlOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("zero złotych"));
      expect(
          converter.convert(1, options: currencyOption), equals("jeden złoty"));
      expect(
          converter.convert(2, options: currencyOption), equals("dwa złote"));
      expect(
          converter.convert(3, options: currencyOption), equals("trzy złote"));
      expect(converter.convert(4, options: currencyOption),
          equals("cztery złote"));
      expect(converter.convert(5, options: currencyOption),
          equals("pięć złotych"));
      expect(converter.convert(10, options: currencyOption),
          equals("dziesięć złotych"));
      expect(converter.convert(11, options: currencyOption),
          equals("jedenaście złotych"));
      expect(converter.convert(12, options: currencyOption),
          equals("dwanaście złotych"));
      expect(converter.convert(13, options: currencyOption),
          equals("trzynaście złotych"));
      expect(converter.convert(14, options: currencyOption),
          equals("czternaście złotych"));
      expect(converter.convert(21, options: currencyOption),
          equals("dwadzieścia jeden złotych"));
      expect(converter.convert(24, options: currencyOption),
          equals("dwadzieścia cztery złote"));
      expect(converter.convert(25, options: currencyOption),
          equals("dwadzieścia pięć złotych"));
      expect(
        converter.convert(1.5, options: currencyOption),
        equals("jeden złoty i pięćdziesiąt groszy"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("sto dwadzieścia trzy złote i czterdzieści pięć groszy"),
      );
      expect(converter.convert(10000000, options: currencyOption),
          equals("dziesięć milionów złotych"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("pięćdziesiąt groszy"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("jeden grosz"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("pięć groszy"));
      expect(converter.convert(0.12, options: currencyOption),
          equals("dwanaście groszy"));
      expect(converter.convert(0.21, options: currencyOption),
          equals('dwadzieścia jeden groszy'));
      expect(converter.convert(0.25, options: currencyOption),
          equals("dwadzieścia pięć groszy"));

      expect(converter.convert(2.01, options: currencyOption),
          equals("dwa złote i jeden grosz"));
      expect(converter.convert(5.02, options: currencyOption),
          equals("pięć złotych i dwa grosze"));
      expect(
        converter.convert(21.05, options: currencyOption),
        equals("dwadzieścia jeden złotych i pięć groszy"),
      );
      expect(
        converter.convert(123.456, options: currencyOption),
        equals("sto dwadzieścia trzy złote i czterdzieści sześć groszy"),
      );
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("jeden milion"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("dwa miliardy"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("trzy biliony"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("cztery biliardy"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("pięć trylionów"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("sześć tryliardów"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("siedem kwadrylionów"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
          "dziewięć trylionów osiemset siedemdziesiąt sześć biliardów pięćset czterdzieści trzy biliony dwieście dziesięć miliardów sto dwadzieścia trzy miliony czterysta pięćdziesiąt sześć tysięcy siedemset osiemdziesiąt dziewięć",
        ),
      );
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

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("jeden bilion dwa miliony trzy"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("pięć milionów jeden tysiąc"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("jeden miliard jeden"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("jeden miliard jeden milion"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("dwa miliony jeden tysiąc"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "jeden bilion dziewięćset osiemdziesiąt siedem milionów sześćset tysięcy trzy"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Nie Liczba"));
      expect(converter.convert(double.infinity), equals("Nieskończoność"));
      expect(converter.convert(double.negativeInfinity),
          equals("Minus Nieskończoność"));
      expect(converter.convert(null), equals("Nie Liczba"));
      expect(converter.convert('abc'), equals("Nie Liczba"));
      expect(converter.convert([]), equals("Nie Liczba"));
      expect(converter.convert({}), equals("Nie Liczba"));
      expect(converter.convert(Object()), equals("Nie Liczba"));

      expect(converterWithFallback.convert(double.nan),
          equals("Nieprawidłowy Numer"));
      expect(converterWithFallback.convert(double.infinity),
          equals("Nieskończoność"));
      expect(
        converterWithFallback.convert(double.negativeInfinity),
        equals("Minus Nieskończoność"),
      );
      expect(
          converterWithFallback.convert(null), equals("Nieprawidłowy Numer"));
      expect(
          converterWithFallback.convert('abc'), equals("Nieprawidłowy Numer"));
      expect(converterWithFallback.convert([]), equals("Nieprawidłowy Numer"));
      expect(converterWithFallback.convert({}), equals("Nieprawidłowy Numer"));
      expect(converterWithFallback.convert(Object()),
          equals("Nieprawidłowy Numer"));
      expect(
          converterWithFallback.convert(123), equals("sto dwadzieścia trzy"));
    });
  });
}
