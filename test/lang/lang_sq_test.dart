import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Albanian (SQ)', () {
    final converter = Num2Text(initialLang: Lang.SQ);
    final converterWithFallback =
        Num2Text(initialLang: Lang.SQ, fallbackOnError: "Numër i pavlefshëm");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("zero"));
      expect(converter.convert(1), equals("një"));
      expect(converter.convert(2), equals("dy"));
      expect(converter.convert(3), equals("tre"));
      expect(converter.convert(4), equals("katër"));
      expect(converter.convert(5), equals("pesë"));
      expect(converter.convert(9), equals("nëntë"));
      expect(converter.convert(10), equals("dhjetë"));
      expect(converter.convert(11), equals("njëmbëdhjetë"));
      expect(converter.convert(12), equals("dymbëdhjetë"));
      expect(converter.convert(13), equals("trembëdhjetë"));
      expect(converter.convert(14), equals("katërmbëdhjetë"));
      expect(converter.convert(15), equals("pesëmbëdhjetë"));
      expect(converter.convert(19), equals("nëntëmbëdhjetë"));
      expect(converter.convert(20), equals("njëzet"));
      expect(converter.convert(21), equals("njëzet e një"));
      expect(converter.convert(22), equals("njëzet e dy"));
      expect(converter.convert(23), equals("njëzet e tre"));
      expect(converter.convert(24), equals("njëzet e katër"));
      expect(converter.convert(25), equals("njëzet e pesë"));
      expect(converter.convert(27), equals("njëzet e shtatë"));
      expect(converter.convert(30), equals("tridhjetë"));
      expect(converter.convert(54), equals("pesëdhjetë e katër"));
      expect(converter.convert(68), equals("gjashtëdhjetë e tetë"));
      expect(converter.convert(99), equals("nëntëdhjetë e nëntë"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("njëqind"));
      expect(converter.convert(101), equals("njëqind e një"));
      expect(converter.convert(105), equals("njëqind e pesë"));
      expect(converter.convert(110), equals("njëqind e dhjetë"));
      expect(converter.convert(111), equals("njëqind e njëmbëdhjetë"));
      expect(converter.convert(123), equals("njëqind e njëzet e tre"));
      expect(converter.convert(200), equals("dyqind"));
      expect(converter.convert(321), equals("treqind e njëzet e një"));
      expect(
          converter.convert(479), equals("katërqind e shtatëdhjetë e nëntë"));
      expect(
          converter.convert(596), equals("pesëqind e nëntëdhjetë e gjashtë"));
      expect(converter.convert(681), equals("gjashtëqind e tetëdhjetë e një"));
      expect(converter.convert(999), equals("nëntëqind e nëntëdhjetë e nëntë"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("një mijë"));
      expect(converter.convert(1001), equals("një mijë e një"));
      expect(converter.convert(1011), equals("një mijë e njëmbëdhjetë"));
      expect(converter.convert(1110), equals("një mijë e njëqind e dhjetë"));
      expect(
          converter.convert(1111), equals("një mijë e njëqind e njëmbëdhjetë"));
      expect(converter.convert(2000), equals("dy mijë"));
      expect(converter.convert(2468),
          equals("dy mijë e katërqind e gjashtëdhjetë e tetë"));
      expect(converter.convert(3579),
          equals("tre mijë e pesëqind e shtatëdhjetë e nëntë"));
      expect(converter.convert(10000), equals("dhjetë mijë"));
      expect(converter.convert(10011), equals("dhjetë mijë e njëmbëdhjetë"));
      expect(converter.convert(11100), equals("njëmbëdhjetë mijë e njëqind"));
      expect(converter.convert(12987),
          equals("dymbëdhjetë mijë e nëntëqind e tetëdhjetë e shtatë"));
      expect(converter.convert(45623),
          equals("dyzet e pesë mijë e gjashtëqind e njëzet e tre"));
      expect(
          converter.convert(87654),
          equals(
              "tetëdhjetë e shtatë mijë e gjashtëqind e pesëdhjetë e katër"));
      expect(converter.convert(100000), equals("njëqind mijë"));
      expect(
          converter.convert(123456),
          equals(
              "njëqind e njëzet e tre mijë e katërqind e pesëdhjetë e gjashtë"));
      expect(
          converter.convert(987654),
          equals(
              "nëntëqind e tetëdhjetë e shtatë mijë e gjashtëqind e pesëdhjetë e katër"));
      expect(
          converter.convert(999999),
          equals(
              "nëntëqind e nëntëdhjetë e nëntë mijë e nëntëqind e nëntëdhjetë e nëntë"));
    });

    test('Negative Numbers', () {
      const negativeOption = SqOptions(negativePrefix: "negativ");

      expect(converter.convert(-1), equals("minus një"));
      expect(converter.convert(-123), equals("minus njëqind e njëzet e tre"));
      expect(converter.convert(-123.456),
          equals("minus njëqind e njëzet e tre presje katër pesë gjashtë"));
      expect(converter.convert(-1, options: negativeOption),
          equals("negativ një"));
      expect(converter.convert(-123, options: negativeOption),
          equals("negativ njëqind e njëzet e tre"));
      expect(converter.convert(-123.456, options: negativeOption),
          equals("negativ njëqind e njëzet e tre presje katër pesë gjashtë"));
    });

    test('Decimals', () {
      const pointOption = SqOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = SqOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = SqOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(123.456),
          equals("njëqind e njëzet e tre presje katër pesë gjashtë"));
      expect(converter.convert(1.50), equals("një presje pesë"));
      expect(converter.convert(1.05), equals("një presje zero pesë"));
      expect(converter.convert(879.465),
          equals("tetëqind e shtatëdhjetë e nëntë presje katër gjashtë pesë"));
      expect(converter.convert(1.5), equals("një presje pesë"));
      expect(converter.convert(1.5, options: pointOption),
          equals("një pikë pesë"));
      expect(converter.convert(1.5, options: commaOption),
          equals("një presje pesë"));
      expect(converter.convert(1.5, options: periodOption),
          equals("një pikë pesë"));
    });

    test('Year Formatting', () {
      const yearOption = SqOptions(format: Format.year);
      const yearOptionAD = SqOptions(format: Format.year, includeAD: true);

      expect(converter.convert(123, options: yearOption),
          equals("njëqind e njëzet e tre"));
      expect(converter.convert(498, options: yearOption),
          equals("katërqind e nëntëdhjetë e tetë"));
      expect(converter.convert(756, options: yearOption),
          equals("shtatëqind e pesëdhjetë e gjashtë"));
      expect(converter.convert(1900, options: yearOption),
          equals("një mijë e nëntëqind"));
      expect(converter.convert(1999, options: yearOption),
          equals("një mijë e nëntëqind e nëntëdhjetë e nëntë"));
      expect(converter.convert(2025, options: yearOption),
          equals("dy mijë e njëzet e pesë"));
      expect(converter.convert(1900, options: yearOptionAD),
          equals("një mijë e nëntëqind e.s."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("një mijë e nëntëqind e nëntëdhjetë e nëntë e.s."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("dy mijë e njëzet e pesë e.s."));
      expect(converter.convert(-1, options: yearOption), equals("një p.e.s."));
      expect(converter.convert(-100, options: yearOption),
          equals("njëqind p.e.s."));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("njëqind p.e.s."));
      expect(converter.convert(-2025, options: yearOption),
          equals("dy mijë e njëzet e pesë p.e.s."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("një milion p.e.s."));
    });

    test('Currency', () {
      const currencyOption = SqOptions(currency: true);

      expect(converter.convert(0, options: currencyOption),
          equals("zero lekë e zero qindarka"));
      expect(converter.convert(1, options: currencyOption), equals("një lek"));
      expect(converter.convert(2, options: currencyOption), equals("dy lekë"));
      expect(
          converter.convert(5, options: currencyOption), equals("pesë lekë"));
      expect(converter.convert(10, options: currencyOption),
          equals("dhjetë lekë"));
      expect(converter.convert(11, options: currencyOption),
          equals("njëmbëdhjetë lekë"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("një lek e pesëdhjetë qindarka"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("njëqind e njëzet e tre lekë e dyzet e pesë qindarka"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("dhjetë milion lekë"));
      expect(converter.convert(0.50, options: currencyOption),
          equals("pesëdhjetë qindarka"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("një qindarkë"));
      expect(converter.convert(0.02, options: currencyOption),
          equals("dy qindarka"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("pesë qindarka"));
      expect(converter.convert(0.11, options: currencyOption),
          equals("njëmbëdhjetë qindarka"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("një lek e një qindarkë"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("dy lekë e dy qindarka"));
      expect(converter.convert(5.05, options: currencyOption),
          equals("pesë lekë e pesë qindarka"));
      expect(converter.convert(11.11, options: currencyOption),
          equals("njëmbëdhjetë lekë e njëmbëdhjetë qindarka"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("një milion"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("dy miliard"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("tre bilion"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("katër biliard"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("pesë trilion"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("gjashtë triliard"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("shtatë katrilion"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "nëntë trilion e tetëqind e shtatëdhjetë e gjashtë biliard e pesëqind e dyzet e tre bilion e dyqind e dhjetë miliard e njëqind e njëzet e tre milion e katërqind e pesëdhjetë e gjashtë mijë e shtatëqind e tetëdhjetë e nëntë"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "njëqind e njëzet e tre triliard e katërqind e pesëdhjetë e gjashtë trilion e shtatëqind e tetëdhjetë e nëntë biliard e njëqind e njëzet e tre bilion e katërqind e pesëdhjetë e gjashtë miliard e shtatëqind e tetëdhjetë e nëntë milion e njëqind e njëzet e tre mijë e katërqind e pesëdhjetë e gjashtë"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "nëntëqind e nëntëdhjetë e nëntë triliard e nëntëqind e nëntëdhjetë e nëntë trilion e nëntëqind e nëntëdhjetë e nëntë biliard e nëntëqind e nëntëdhjetë e nëntë bilion e nëntëqind e nëntëdhjetë e nëntë miliard e nëntëqind e nëntëdhjetë e nëntë milion e nëntëqind e nëntëdhjetë e nëntë mijë e nëntëqind e nëntëdhjetë e nëntë"));

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('një bilion e dy milion e tre'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("pesë milion e një mijë"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("një miliard e një"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("një miliard e një milion"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("dy milion e një mijë"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              'një bilion e nëntëqind e tetëdhjetë e shtatë milion e gjashtëqind mijë e tre'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Nuk është numër"));
      expect(converter.convert(double.infinity), equals("Pafundësi"));
      expect(converter.convert(double.negativeInfinity),
          equals("Minus pafundësi"));
      expect(converter.convert(null), equals("Nuk është numër"));
      expect(converter.convert('abc'), equals("Nuk është numër"));
      expect(converter.convert([]), equals("Nuk është numër"));
      expect(converter.convert({}), equals("Nuk është numër"));
      expect(converter.convert(Object()), equals("Nuk është numër"));

      expect(converterWithFallback.convert(double.nan),
          equals("Numër i pavlefshëm"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Pafundësi"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Minus pafundësi"));
      expect(converterWithFallback.convert(null), equals("Numër i pavlefshëm"));
      expect(
          converterWithFallback.convert('abc'), equals("Numër i pavlefshëm"));
      expect(converterWithFallback.convert([]), equals("Numër i pavlefshëm"));
      expect(converterWithFallback.convert({}), equals("Numër i pavlefshëm"));
      expect(converterWithFallback.convert(Object()),
          equals("Numër i pavlefshëm"));
      expect(
          converterWithFallback.convert(123), equals("njëqind e njëzet e tre"));
    });
  });
}
