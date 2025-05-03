import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Slovak (SK)', () {
    final converter = Num2Text(initialLang: Lang.SK);
    final converterWithFallback =
        Num2Text(initialLang: Lang.SK, fallbackOnError: "Neplatné číslo");

    test('Basic Numbers (0 - 99 Masculine/Default)', () {
      expect(converter.convert(0), equals("nula"));
      expect(converter.convert(1), equals("jeden"));
      expect(converter.convert(2), equals("dva"));
      expect(converter.convert(3), equals("tri"));
      expect(converter.convert(4), equals("štyri"));
      expect(converter.convert(5), equals("päť"));
      expect(converter.convert(9), equals("deväť"));
      expect(converter.convert(10), equals("desať"));
      expect(converter.convert(11), equals("jedenásť"));
      expect(converter.convert(12), equals("dvanásť"));
      expect(converter.convert(13), equals("trinásť"));
      expect(converter.convert(14), equals("štrnásť"));
      expect(converter.convert(15), equals("pätnásť"));
      expect(converter.convert(19), equals("devätnásť"));
      expect(converter.convert(20), equals("dvadsať"));
      expect(converter.convert(21), equals("dvadsať jeden"));
      expect(converter.convert(22), equals("dvadsať dva"));
      expect(converter.convert(23), equals("dvadsať tri"));
      expect(converter.convert(24), equals("dvadsať štyri"));
      expect(converter.convert(25), equals("dvadsať päť"));
      expect(converter.convert(27), equals("dvadsať sedem"));
      expect(converter.convert(30), equals("tridsať"));
      expect(converter.convert(54), equals("päťdesiat štyri"));
      expect(converter.convert(68), equals("šesťdesiat osem"));
      expect(converter.convert(99), equals("deväťdesiat deväť"));
    });

    test('Basic Numbers (0 - 99 Feminine)', () {
      const options = SkOptions(gender: Gender.feminine);

      expect(converter.convert(0, options: options), equals("nula"));
      expect(converter.convert(1, options: options), equals("jedna"));
      expect(converter.convert(2, options: options), equals("dve"));
      expect(converter.convert(3, options: options), equals("tri"));
      expect(converter.convert(4, options: options), equals("štyri"));
      expect(converter.convert(5, options: options), equals("päť"));
      expect(converter.convert(9, options: options), equals("deväť"));
      expect(converter.convert(10, options: options), equals("desať"));
      expect(converter.convert(11, options: options), equals("jedenásť"));
      expect(converter.convert(12, options: options), equals("dvanásť"));
      expect(converter.convert(13, options: options), equals("trinásť"));
      expect(converter.convert(14, options: options), equals("štrnásť"));
      expect(converter.convert(15, options: options), equals("pätnásť"));
      expect(converter.convert(19, options: options), equals("devätnásť"));
      expect(converter.convert(20, options: options), equals("dvadsať"));
      expect(converter.convert(21, options: options), equals("dvadsať jedna"));
      expect(converter.convert(22, options: options), equals("dvadsať dve"));
      expect(converter.convert(23, options: options), equals("dvadsať tri"));
      expect(converter.convert(24, options: options), equals("dvadsať štyri"));
      expect(converter.convert(25, options: options), equals("dvadsať päť"));
      expect(converter.convert(27, options: options), equals("dvadsať sedem"));
      expect(converter.convert(30, options: options), equals("tridsať"));
      expect(
          converter.convert(54, options: options), equals("päťdesiat štyri"));
      expect(
          converter.convert(68, options: options), equals("šesťdesiat osem"));
      expect(
          converter.convert(99, options: options), equals("deväťdesiat deväť"));
    });

    test('Basic Numbers (0 - 99 Neuter)', () {
      const options = SkOptions(gender: Gender.neuter);

      expect(converter.convert(0, options: options), equals("nula"));
      expect(converter.convert(1, options: options), equals("jedno"));
      expect(converter.convert(2, options: options), equals("dve"));
      expect(converter.convert(3, options: options), equals("tri"));
      expect(converter.convert(4, options: options), equals("štyri"));
      expect(converter.convert(5, options: options), equals("päť"));
      expect(converter.convert(9, options: options), equals("deväť"));
      expect(converter.convert(10, options: options), equals("desať"));
      expect(converter.convert(11, options: options), equals("jedenásť"));
      expect(converter.convert(12, options: options), equals("dvanásť"));
      expect(converter.convert(13, options: options), equals("trinásť"));
      expect(converter.convert(14, options: options), equals("štrnásť"));
      expect(converter.convert(15, options: options), equals("pätnásť"));
      expect(converter.convert(19, options: options), equals("devätnásť"));
      expect(converter.convert(20, options: options), equals("dvadsať"));
      expect(converter.convert(21, options: options), equals("dvadsať jedno"));
      expect(converter.convert(22, options: options), equals("dvadsať dve"));
      expect(converter.convert(23, options: options), equals("dvadsať tri"));
      expect(converter.convert(24, options: options), equals("dvadsať štyri"));
      expect(converter.convert(25, options: options), equals("dvadsať päť"));
      expect(converter.convert(27, options: options), equals("dvadsať sedem"));
      expect(converter.convert(30, options: options), equals("tridsať"));
      expect(
          converter.convert(54, options: options), equals("päťdesiat štyri"));
      expect(
          converter.convert(68, options: options), equals("šesťdesiat osem"));
      expect(
          converter.convert(99, options: options), equals("deväťdesiat deväť"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("sto"));
      expect(converter.convert(101), equals("sto jeden"));
      expect(converter.convert(105), equals("sto päť"));
      expect(converter.convert(110), equals("sto desať"));
      expect(converter.convert(111), equals("sto jedenásť"));
      expect(converter.convert(123), equals("sto dvadsať tri"));
      expect(converter.convert(200), equals("dvesto"));
      expect(converter.convert(321), equals("tristo dvadsať jeden"));
      expect(converter.convert(479), equals("štyristo sedemdesiat deväť"));
      expect(converter.convert(596), equals("päťsto deväťdesiat šesť"));
      expect(converter.convert(681), equals("šesťsto osemdesiat jeden"));
      expect(converter.convert(999), equals("deväťsto deväťdesiat deväť"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("tisíc"));
      expect(converter.convert(1001), equals("tisíc jeden"));
      expect(converter.convert(1011), equals("tisíc jedenásť"));
      expect(converter.convert(1110), equals("tisíc sto desať"));
      expect(converter.convert(1111), equals("tisíc sto jedenásť"));
      expect(converter.convert(2000), equals("dvetisíc"));
      expect(
          converter.convert(2468), equals("dvetisíc štyristo šesťdesiat osem"));
      expect(
          converter.convert(3579), equals("tritisíc päťsto sedemdesiat deväť"));
      expect(converter.convert(10000), equals("desaťtisíc"));
      expect(converter.convert(10011), equals("desaťtisíc jedenásť"));
      expect(converter.convert(11100), equals("jedenásťtisíc sto"));
      expect(converter.convert(12987),
          equals("dvanásťtisíc deväťsto osemdesiat sedem"));
      expect(converter.convert(45623),
          equals("štyridsať päť tisíc šesťsto dvadsať tri"));
      expect(converter.convert(87654),
          equals("osemdesiat sedem tisíc šesťsto päťdesiat štyri"));
      expect(converter.convert(100000), equals("stotisíc"));
      expect(converter.convert(123456),
          equals("sto dvadsať tri tisíc štyristo päťdesiat šesť"));
      expect(converter.convert(987654),
          equals("deväťsto osemdesiat sedem tisíc šesťsto päťdesiat štyri"));
      expect(
          converter.convert(999999),
          equals(
              "deväťsto deväťdesiat deväť tisíc deväťsto deväťdesiat deväť"));
    });

    test('Negative Numbers', () {
      const negativeOption = SkOptions(negativePrefix: "záporné");

      expect(converter.convert(-1), equals("mínus jeden"));
      expect(converter.convert(-123), equals("mínus sto dvadsať tri"));
      expect(converter.convert(-123.456),
          equals("mínus sto dvadsať tri celá štyristo päťdesiat šesť"));
      expect(converter.convert(-1, options: negativeOption),
          equals("záporné jeden"));
      expect(converter.convert(-123, options: negativeOption),
          equals("záporné sto dvadsať tri"));
      expect(converter.convert(-123.456, options: negativeOption),
          equals("záporné sto dvadsať tri celá štyristo päťdesiat šesť"));
    });

    test('Decimals', () {
      const pointOption = SkOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = SkOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = SkOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(0.01), equals("nula celá nula jedna"));
      expect(converter.convert(123.456),
          equals("sto dvadsať tri celá štyristo päťdesiat šesť"));
      expect(converter.convert(1.50), equals("jeden celá päť"));
      expect(converter.convert(1.05), equals("jeden celá nula päť"));
      expect(converter.convert(879.465),
          equals("osemsto sedemdesiat deväť celá štyristo šesťdesiat päť"));
      expect(converter.convert(1.5), equals("jeden celá päť"));
      expect(converter.convert(1.5, options: pointOption),
          equals("jeden bod päť"));
      expect(converter.convert(1.5, options: commaOption),
          equals("jeden celá päť"));
      expect(converter.convert(1.5, options: periodOption),
          equals("jeden bod päť"));
    });

    test('Year Formatting', () {
      const yearOption = SkOptions(format: Format.year);
      const yearOptionAD = SkOptions(format: Format.year, includeAD: true);

      expect(converter.convert(123, options: yearOption),
          equals("sto dvadsať tri"));
      expect(converter.convert(498, options: yearOption),
          equals("štyristo deväťdesiat osem"));
      expect(converter.convert(756, options: yearOption),
          equals("sedemsto päťdesiat šesť"));
      expect(converter.convert(1900, options: yearOption),
          equals("tisíc deväťsto"));
      expect(converter.convert(1999, options: yearOption),
          equals("tisíc deväťsto deväťdesiat deväť"));
      expect(converter.convert(2025, options: yearOption),
          equals("dvetisíc dvadsať päť"));
      expect(converter.convert(1900, options: yearOptionAD),
          equals("tisíc deväťsto n. l."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("tisíc deväťsto deväťdesiat deväť n. l."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("dvetisíc dvadsať päť n. l."));
      expect(converter.convert(-1, options: yearOption), equals("mínus jeden"));
      expect(converter.convert(-100, options: yearOption), equals("mínus sto"));
      expect(
          converter.convert(-100, options: yearOptionAD), equals("mínus sto"));
      expect(converter.convert(-2025, options: yearOption),
          equals("mínus dvetisíc dvadsať päť"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("mínus jeden milión"));
    });

    test('Currency', () {
      const currencyOption = SkOptions(currency: true);

      expect(converter.convert(0, options: currencyOption), equals("nula eur"));
      expect(
          converter.convert(1, options: currencyOption), equals("jedno euro"));
      expect(converter.convert(2, options: currencyOption), equals("dve eurá"));
      expect(converter.convert(3, options: currencyOption), equals("tri eurá"));
      expect(
          converter.convert(4, options: currencyOption), equals("štyri eurá"));
      expect(converter.convert(5, options: currencyOption), equals("päť eur"));
      expect(
          converter.convert(10, options: currencyOption), equals("desať eur"));
      expect(converter.convert(11, options: currencyOption),
          equals("jedenásť eur"));
      expect(converter.convert(21, options: currencyOption),
          equals("dvadsať jedno eur"));
      expect(converter.convert(22, options: currencyOption),
          equals("dvadsať dve eurá"));
      expect(converter.convert(25, options: currencyOption),
          equals("dvadsať päť eur"));
      expect(
          converter.convert(100, options: currencyOption), equals("sto eur"));
      expect(converter.convert(101, options: currencyOption),
          equals("sto jedno eur"));
      expect(converter.convert(102, options: currencyOption),
          equals("sto dve eurá"));
      expect(converter.convert(105, options: currencyOption),
          equals("sto päť eur"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("jedno euro a päťdesiat centov"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("sto dvadsať tri eurá a štyridsať päť centov"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("desať miliónov eur"));
      expect(converter.convert(0.50, options: currencyOption),
          equals("päťdesiat centov"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("jeden cent"));
      expect(converter.convert(0.02, options: currencyOption),
          equals("dva centy"));
      expect(converter.convert(0.03, options: currencyOption),
          equals("tri centy"));
      expect(converter.convert(0.04, options: currencyOption),
          equals("štyri centy"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("päť centov"));
      expect(converter.convert(0.11, options: currencyOption),
          equals("jedenásť centov"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("jedno euro a jeden cent"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("dve eurá a dva centy"));
      expect(converter.convert(5.05, options: currencyOption),
          equals("päť eur a päť centov"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("jeden milión"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("dve miliardy"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("tri bilióny"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("štyri biliardy"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("päť triliónov"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("šesť triliárd"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("sedem kvadriliónov"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "deväť triliónov osemsto sedemdesiat šesť biliárd päťsto štyridsať tri bilióny dvesto desať miliárd sto dvadsať tri milióny štyristo päťdesiat šesť tisíc sedemsto osemdesiat deväť"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "sto dvadsať tri triliardy štyristo päťdesiat šesť triliónov sedemsto osemdesiat deväť biliárd sto dvadsať tri bilióny štyristo päťdesiat šesť miliárd sedemsto osemdesiat deväť miliónov sto dvadsať tri tisíc štyristo päťdesiat šesť"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "deväťsto deväťdesiat deväť triliárd deväťsto deväťdesiat deväť triliónov deväťsto deväťdesiat deväť biliárd deväťsto deväťdesiat deväť biliónov deväťsto deväťdesiat deväť miliárd deväťsto deväťdesiat deväť miliónov deväťsto deväťdesiat deväť tisíc deväťsto deväťdesiat deväť"));

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('jeden bilión dva milióny tri'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("päť miliónov tisíc"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("jedna miliarda jeden"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("jedna miliarda jeden milión"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("dva milióny tisíc"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              'jeden bilión deväťsto osemdesiat sedem miliónov šesťstotisíc tri'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Nie je číslo"));
      expect(converter.convert(double.infinity), equals("Nekonečno"));
      expect(converter.convert(double.negativeInfinity),
          equals("Mínus nekonečno"));
      expect(converter.convert(null), equals("Nie je číslo"));
      expect(converter.convert('abc'), equals("Nie je číslo"));
      expect(converter.convert([]), equals("Nie je číslo"));
      expect(converter.convert({}), equals("Nie je číslo"));
      expect(converter.convert(Object()), equals("Nie je číslo"));

      expect(
          converterWithFallback.convert(double.nan), equals("Neplatné číslo"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Nekonečno"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Mínus nekonečno"));
      expect(converterWithFallback.convert(null), equals("Neplatné číslo"));
      expect(converterWithFallback.convert('abc'), equals("Neplatné číslo"));
      expect(converterWithFallback.convert([]), equals("Neplatné číslo"));
      expect(converterWithFallback.convert({}), equals("Neplatné číslo"));
      expect(converterWithFallback.convert(Object()), equals("Neplatné číslo"));
      expect(converterWithFallback.convert(123), equals("sto dvadsať tri"));
    });
  });
}
