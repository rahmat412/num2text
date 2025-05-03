import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Azerbaijani (AZ)', () {
    final converter = Num2Text(initialLang: Lang.AZ);
    final converterWithFallback = Num2Text(
      initialLang: Lang.AZ,
      fallbackOnError: "Yanlış Dəyər",
    );

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("sıfır"));
      expect(converter.convert(10), equals("on"));
      expect(converter.convert(11), equals("on bir"));
      expect(converter.convert(13), equals("on üç"));
      expect(converter.convert(15), equals("on beş"));
      expect(converter.convert(20), equals("iyirmi"));
      expect(converter.convert(27), equals("iyirmi yeddi"));
      expect(converter.convert(30), equals("otuz"));
      expect(converter.convert(54), equals("əlli dörd"));
      expect(converter.convert(68), equals("altmış səkkiz"));
      expect(converter.convert(99), equals("doxsan doqquz"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("yüz"));
      expect(converter.convert(101), equals("yüz bir"));
      expect(converter.convert(105), equals("yüz beş"));
      expect(converter.convert(110), equals("yüz on"));
      expect(converter.convert(111), equals("yüz on bir"));
      expect(converter.convert(123), equals("yüz iyirmi üç"));
      expect(converter.convert(200), equals("iki yüz"));
      expect(converter.convert(321), equals("üç yüz iyirmi bir"));
      expect(converter.convert(479), equals("dörd yüz yetmiş doqquz"));
      expect(converter.convert(596), equals("beş yüz doxsan altı"));
      expect(converter.convert(681), equals("altı yüz səksən bir"));
      expect(converter.convert(999), equals("doqquz yüz doxsan doqquz"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("min"));
      expect(converter.convert(1001), equals("min bir"));
      expect(converter.convert(1011), equals("min on bir"));
      expect(converter.convert(1110), equals("min yüz on"));
      expect(converter.convert(1111), equals("min yüz on bir"));
      expect(converter.convert(2000), equals("iki min"));
      expect(converter.convert(2468), equals("iki min dörd yüz altmış səkkiz"));
      expect(converter.convert(3579), equals("üç min beş yüz yetmiş doqquz"));
      expect(converter.convert(10000), equals("on min"));
      expect(converter.convert(10011), equals("on min on bir"));
      expect(converter.convert(11100), equals("on bir min yüz"));
      expect(converter.convert(12987),
          equals("on iki min doqquz yüz səksən yeddi"));
      expect(
          converter.convert(45623), equals("qırx beş min altı yüz iyirmi üç"));
      expect(converter.convert(87654),
          equals("səksən yeddi min altı yüz əlli dörd"));
      expect(converter.convert(100000), equals("yüz min"));
      expect(converter.convert(123456),
          equals("yüz iyirmi üç min dörd yüz əlli altı"));
      expect(converter.convert(987654),
          equals("doqquz yüz səksən yeddi min altı yüz əlli dörd"));
      expect(converter.convert(999999),
          equals("doqquz yüz doxsan doqquz min doqquz yüz doxsan doqquz"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("mənfi bir"));
      expect(converter.convert(-123), equals("mənfi yüz iyirmi üç"));
      expect(converter.convert(-123.456),
          equals("mənfi yüz iyirmi üç vergül dörd beş altı"));

      const negativeOption = AzOptions(negativePrefix: "minus");

      expect(
          converter.convert(-1, options: negativeOption), equals("minus bir"));
      expect(converter.convert(-123, options: negativeOption),
          equals("minus yüz iyirmi üç"));
      expect(converter.convert(-123.456, options: negativeOption),
          equals("minus yüz iyirmi üç vergül dörd beş altı"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456),
          equals("yüz iyirmi üç vergül dörd beş altı"));
      expect(converter.convert(1.5), equals("bir vergül beş"));
      expect(converter.convert(1.05), equals("bir vergül sıfır beş"));
      expect(converter.convert(879.465),
          equals("səkkiz yüz yetmiş doqquz vergül dörd altı beş"));
      expect(converter.convert(1.5), equals("bir vergül beş"));

      const pointOption = AzOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = AzOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = AzOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(1.5, options: pointOption),
          equals("bir nöqtə beş"));
      expect(converter.convert(1.5, options: commaOption),
          equals("bir vergül beş"));
      expect(converter.convert(1.5, options: periodOption),
          equals("bir nöqtə beş"));
    });

    test('Year Formatting', () {
      const yearOption = AzOptions(format: Format.year);

      expect(
          converter.convert(123, options: yearOption), equals("yüz iyirmi üç"));
      expect(converter.convert(498, options: yearOption),
          equals("dörd yüz doxsan səkkiz"));
      expect(converter.convert(756, options: yearOption),
          equals("yeddi yüz əlli altı"));
      expect(converter.convert(1900, options: yearOption),
          equals("min doqquz yüz"));
      expect(converter.convert(1999, options: yearOption),
          equals("min doqquz yüz doxsan doqquz"));
      expect(converter.convert(2025, options: yearOption),
          equals("iki min iyirmi beş"));

      const yearOptionAD = AzOptions(format: Format.year, includeAD: true);

      expect(converter.convert(1900, options: yearOptionAD),
          equals("min doqquz yüz e."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("min doqquz yüz doxsan doqquz e."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("iki min iyirmi beş e."));
      expect(converter.convert(-1, options: yearOption), equals("bir e.ə."));
      expect(converter.convert(-100, options: yearOption), equals("yüz e.ə."));
      expect(
          converter.convert(-100, options: yearOptionAD), equals("yüz e.ə."));
      expect(converter.convert(-2025, options: yearOption),
          equals("iki min iyirmi beş e.ə."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("bir milyon e.ə."));
    });

    test('Currency', () {
      const currencyOption = AzOptions(currency: true);

      expect(
          converter.convert(0, options: currencyOption), equals("sıfır manat"));
      expect(
          converter.convert(1, options: currencyOption), equals("bir manat"));
      expect(
          converter.convert(2, options: currencyOption), equals("iki manat"));
      expect(
          converter.convert(5, options: currencyOption), equals("beş manat"));
      expect(
          converter.convert(10, options: currencyOption), equals("on manat"));
      expect(converter.convert(11, options: currencyOption),
          equals("on bir manat"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("bir manat əlli qəpik"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("yüz iyirmi üç manat qırx beş qəpik"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("on milyon manat"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("əlli qəpik"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("bir qəpik"));
      expect(converter.convert(0.02, options: currencyOption),
          equals("iki qəpik"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("bir manat bir qəpik"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("bir milyon"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("iki milyard"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("üç trilyon"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("dörd kvadrilyon"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("beş kvintilyon"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("altı sekstilyon"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("yeddi septilyon"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "doqquz kvintilyon səkkiz yüz yetmiş altı kvadrilyon beş yüz qırx üç trilyon iki yüz on milyard yüz iyirmi üç milyon dörd yüz əlli altı min yeddi yüz səksən doqquz"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "yüz iyirmi üç sekstilyon dörd yüz əlli altı kvintilyon yeddi yüz səksən doqquz kvadrilyon yüz iyirmi üç trilyon dörd yüz əlli altı milyard yeddi yüz səksən doqquz milyon yüz iyirmi üç min dörd yüz əlli altı"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "doqquz yüz doxsan doqquz sekstilyon doqquz yüz doxsan doqquz kvintilyon doqquz yüz doxsan doqquz kvadrilyon doqquz yüz doxsan doqquz trilyon doqquz yüz doxsan doqquz milyard doqquz yüz doxsan doqquz milyon doqquz yüz doxsan doqquz min doqquz yüz doxsan doqquz"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("bir trilyon iki milyon üç"));
      expect(
          converter.convert(BigInt.parse('5001000')), equals("beş milyon min"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("bir milyard bir"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("bir milyard bir milyon"));
      expect(
          converter.convert(BigInt.parse('2001000')), equals("iki milyon min"));
      expect(converter.convert(BigInt.parse('1000987600003')),
          equals("bir trilyon doqquz yüz səksən yeddi milyon altı yüz min üç"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Ədəd Deyil"));
      expect(converter.convert(double.infinity), equals("Sonsuzluq"));
      expect(converter.convert(double.negativeInfinity),
          equals("Mənfi Sonsuzluq"));
      expect(converter.convert(null), equals("Ədəd Deyil"));
      expect(converter.convert('abc'), equals("Ədəd Deyil"));
      expect(converter.convert([]), equals("Ədəd Deyil"));
      expect(converter.convert({}), equals("Ədəd Deyil"));
      expect(converter.convert(Object()), equals("Ədəd Deyil"));
      expect(converterWithFallback.convert(double.nan), equals("Yanlış Dəyər"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Sonsuzluq"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Mənfi Sonsuzluq"));
      expect(converterWithFallback.convert(null), equals("Yanlış Dəyər"));
      expect(converterWithFallback.convert('abc'), equals("Yanlış Dəyər"));
      expect(converterWithFallback.convert([]), equals("Yanlış Dəyər"));
      expect(converterWithFallback.convert({}), equals("Yanlış Dəyər"));
      expect(converterWithFallback.convert(Object()), equals("Yanlış Dəyər"));
      expect(converterWithFallback.convert(123), equals("yüz iyirmi üç"));
    });
  });
}
