import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Slovak (SK)', () {
    final converter = Num2Text(initialLang: Lang.SK);
    final converterWithFallback =
        Num2Text(initialLang: Lang.SK, fallbackOnError: "Neplatné číslo");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("nula"));
      expect(converter.convert(1), equals("jeden"));
      expect(converter.convert(10), equals("desať"));
      expect(converter.convert(11), equals("jedenásť"));
      expect(converter.convert(20), equals("dvadsať"));
      expect(converter.convert(21), equals("dvadsať jeden"));
      expect(converter.convert(99), equals("deväťdesiat deväť"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("sto"));
      expect(converter.convert(101), equals("sto jeden"));
      expect(converter.convert(111), equals("sto jedenásť"));
      expect(converter.convert(200), equals("dvesto"));
      expect(converter.convert(999), equals("deväťsto deväťdesiat deväť"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("tisíc"));
      expect(converter.convert(1001), equals("tisíc jeden"));
      expect(converter.convert(1111), equals("tisíc sto jedenásť"));
      expect(converter.convert(2000), equals("dvetisíc"));
      expect(converter.convert(10000), equals("desaťtisíc"));
      expect(converter.convert(100000), equals("stotisíc"));
      expect(converter.convert(123456),
          equals("stodvadsaťtritisíc štyristo päťdesiat šesť"));
      expect(
        converter.convert(999999),
        equals("deväťstodeväťdesiatdeväťtisíc deväťsto deväťdesiat deväť"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("mínus jeden"));
      expect(converter.convert(-123), equals("mínus sto dvadsať tri"));
      expect(
        converter.convert(-1, options: SkOptions(negativePrefix: "záporné")),
        equals("záporné jeden"),
      );
      expect(
        converter.convert(-123, options: SkOptions(negativePrefix: "záporné")),
        equals("záporné sto dvadsať tri"),
      );
    });

    test('Year Formatting', () {
      const yearOption = SkOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("tisíc deväťsto"));
      expect(converter.convert(2024, options: yearOption),
          equals("dvetisíc dvadsať štyri"));
      expect(converter.convert(-100, options: yearOption), equals("mínus sto"));
      expect(converter.convert(-1, options: yearOption), equals("mínus jeden"));
      expect(
        converter.convert(-2024, options: SkOptions(format: Format.year)),
        equals("mínus dvetisíc dvadsať štyri"),
      );
    });

    test('Currency', () {
      const currencyOption = SkOptions(currency: true);
      expect(
          converter.convert(1, options: currencyOption), equals("jedno euro"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("jedno euro a jeden cent"));
      expect(converter.convert(2, options: currencyOption), equals("dve eurá"));
      expect(
        converter.convert(2.50, options: currencyOption),
        equals("dve eurá a päťdesiat centov"),
      );
      expect(converter.convert(3, options: currencyOption), equals("tri eurá"));
      expect(
          converter.convert(4, options: currencyOption), equals("štyri eurá"));
      expect(converter.convert(5, options: currencyOption), equals("päť eur"));
      expect(
          converter.convert(10, options: currencyOption), equals("desať eur"));

      expect(
        converter.convert(123.45, options: currencyOption),
        equals("sto dvadsať tri eurá a štyridsať päť centov"),
      );

      expect(converter.convert(1.02, options: currencyOption),
          equals("jedno euro a dva centy"));
      expect(converter.convert(1.05, options: currencyOption),
          equals("jedno euro a päť centov"));

      expect(converter.convert(0, options: currencyOption), equals("nula eur"));
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("sto dvadsať tri celá štyristo päťdesiat šesť"),
      );

      expect(
          converter.convert(Decimal.parse('1.50')), equals("jeden celá päť"));
      expect(converter.convert(Decimal.parse('1.5')), equals("jeden celá päť"));
      expect(converter.convert(123.0), equals("sto dvadsať tri"));
      expect(
          converter.convert(Decimal.parse('123.0')), equals("sto dvadsať tri"));

      expect(
        converter.convert(1.5,
            options: const SkOptions(decimalSeparator: DecimalSeparator.point)),
        equals("jeden bod päť"),
      );
      expect(
        converter.convert(1.5,
            options:
                const SkOptions(decimalSeparator: DecimalSeparator.period)),
        equals("jeden bod päť"),
      );
      expect(
        converter.convert(1.5,
            options: const SkOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("jeden celá päť"),
      );

      expect(converter.convert(Decimal.parse('0.5')), equals("nula celá päť"));
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Nekonečno"));
      expect(converter.convert(double.negativeInfinity),
          equals("Mínus nekonečno"));
      expect(converter.convert(double.nan), equals("Nie je číslo"));
      expect(converter.convert(null), equals("Nie je číslo"));
      expect(converter.convert('abc'), equals("Nie je číslo"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Nekonečno"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Mínus nekonečno"));
      expect(
          converterWithFallback.convert(double.nan), equals("Neplatné číslo"));
      expect(converterWithFallback.convert(null), equals("Neplatné číslo"));
      expect(converterWithFallback.convert('abc'), equals("Neplatné číslo"));
      expect(converterWithFallback.convert(123), equals("sto dvadsať tri"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("jeden milión"));
      expect(
          converter.convert(BigInt.from(1000000000)), equals("jedna miliarda"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("jeden bilión"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("jedna biliarda"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("jeden trilión"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("jedna triliarda"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("jeden kvadrilión"),
      );

      expect(converter.convert(BigInt.from(2000000)), equals("dva milióny"));
      expect(
          converter.convert(BigInt.from(3000000000)), equals("tri miliardy"));
      expect(converter.convert(BigInt.from(4000000000000)),
          equals("štyri bilióny"));

      expect(converter.convert(BigInt.from(5000000)), equals("päť miliónov"));
      expect(
          converter.convert(BigInt.from(10000000000)), equals("desať miliárd"));
      expect(converter.convert(BigInt.from(11000000000000)),
          equals("jedenásť biliónov"));

      expect(converter.convert(BigInt.parse('1000001')),
          equals("jeden milión jeden"));
      expect(converter.convert(BigInt.parse('1001000')),
          equals("jeden milión tisíc"));
      expect(converter.convert(BigInt.parse('1001001')),
          equals("jeden milión tisíc jeden"));
      expect(converter.convert(BigInt.parse('2002002')),
          equals("dva milióny dvetisíc dva"));
      expect(converter.convert(BigInt.parse('5001001')),
          equals("päť miliónov tisíc jeden"));

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "sto dvadsať tri triliardy štyristo päťdesiat šesť triliónov sedemsto osemdesiat deväť biliárd sto dvadsať tri bilióny štyristo päťdesiat šesť miliárd sedemsto osemdesiat deväť miliónov stodvadsaťtritisíc štyristo päťdesiat šesť",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "deväťsto deväťdesiat deväť triliárd deväťsto deväťdesiat deväť triliónov deväťsto deväťdesiat deväť biliárd deväťsto deväťdesiat deväť biliónov deväťsto deväťdesiat deväť miliárd deväťsto deväťdesiat deväť miliónov deväťstodeväťdesiatdeväťtisíc deväťsto deväťdesiat deväť",
        ),
      );
    });
  });
}
