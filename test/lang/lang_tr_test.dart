import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Turkish (TR)', () {
    final converter = Num2Text(initialLang: Lang.TR);
    final converterWithFallback =
        Num2Text(initialLang: Lang.TR, fallbackOnError: "Geçersiz Sayı");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("sıfır"));
      expect(converter.convert(10), equals("on"));
      expect(converter.convert(11), equals("on bir"));
      expect(converter.convert(13), equals("on üç"));
      expect(converter.convert(15), equals("on beş"));
      expect(converter.convert(20), equals("yirmi"));
      expect(converter.convert(27), equals("yirmi yedi"));
      expect(converter.convert(30), equals("otuz"));
      expect(converter.convert(54), equals("elli dört"));
      expect(converter.convert(68), equals("altmış sekiz"));
      expect(converter.convert(99), equals("doksan dokuz"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("yüz"));
      expect(converter.convert(101), equals("yüz bir"));
      expect(converter.convert(105), equals("yüz beş"));
      expect(converter.convert(110), equals("yüz on"));
      expect(converter.convert(111), equals("yüz on bir"));
      expect(converter.convert(123), equals("yüz yirmi üç"));
      expect(converter.convert(200), equals("iki yüz"));
      expect(converter.convert(321), equals("üç yüz yirmi bir"));
      expect(converter.convert(479), equals("dört yüz yetmiş dokuz"));
      expect(converter.convert(596), equals("beş yüz doksan altı"));
      expect(converter.convert(681), equals("altı yüz seksen bir"));
      expect(converter.convert(999), equals("dokuz yüz doksan dokuz"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("bin"));
      expect(converter.convert(1001), equals("bin bir"));
      expect(converter.convert(1011), equals("bin on bir"));
      expect(converter.convert(1110), equals("bin yüz on"));
      expect(converter.convert(1111), equals("bin yüz on bir"));
      expect(converter.convert(2000), equals("iki bin"));
      expect(converter.convert(2468), equals("iki bin dört yüz altmış sekiz"));
      expect(converter.convert(3579), equals("üç bin beş yüz yetmiş dokuz"));
      expect(converter.convert(10000), equals("on bin"));
      expect(converter.convert(10011), equals("on bin on bir"));
      expect(converter.convert(11100), equals("on bir bin yüz"));
      expect(
          converter.convert(12987), equals("on iki bin dokuz yüz seksen yedi"));
      expect(
          converter.convert(45623), equals("kırk beş bin altı yüz yirmi üç"));
      expect(converter.convert(87654),
          equals("seksen yedi bin altı yüz elli dört"));
      expect(converter.convert(100000), equals("yüz bin"));
      expect(converter.convert(123456),
          equals("yüz yirmi üç bin dört yüz elli altı"));
      expect(converter.convert(987654),
          equals("dokuz yüz seksen yedi bin altı yüz elli dört"));
      expect(converter.convert(999999),
          equals("dokuz yüz doksan dokuz bin dokuz yüz doksan dokuz"));
    });

    test('Negative Numbers', () {
      const negativeOption = TrOptions(negativePrefix: "negatif");
      expect(converter.convert(-1), equals("eksi bir"));
      expect(converter.convert(-123), equals("eksi yüz yirmi üç"));
      expect(converter.convert(-123.456),
          equals("eksi yüz yirmi üç virgül dört beş altı"));
      expect(converter.convert(-1, options: negativeOption),
          equals("negatif bir"));
      expect(converter.convert(-123, options: negativeOption),
          equals("negatif yüz yirmi üç"));
      expect(
        converter.convert(-123.456, options: negativeOption),
        equals("negatif yüz yirmi üç virgül dört beş altı"),
      );
    });

    test('Decimals', () {
      const pointOption = TrOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = TrOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = TrOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(123.456),
          equals("yüz yirmi üç virgül dört beş altı"));
      expect(converter.convert(1.5), equals("bir virgül beş"));
      expect(converter.convert(1.05), equals("bir virgül sıfır beş"));
      expect(converter.convert(879.465),
          equals("sekiz yüz yetmiş dokuz virgül dört altı beş"));
      expect(converter.convert(1.5, options: pointOption),
          equals("bir nokta beş"));
      expect(converter.convert(1.5, options: commaOption),
          equals("bir virgül beş"));
      expect(converter.convert(1.5, options: periodOption),
          equals("bir nokta beş"));
    });

    test('Year Formatting', () {
      const yearOption = TrOptions(format: Format.year);
      const yearOptionAD = TrOptions(format: Format.year, includeAD: true);
      expect(
          converter.convert(123, options: yearOption), equals("yüz yirmi üç"));
      expect(converter.convert(498, options: yearOption),
          equals("dört yüz doksan sekiz"));
      expect(converter.convert(756, options: yearOption),
          equals("yedi yüz elli altı"));
      expect(converter.convert(1900, options: yearOption),
          equals("bin dokuz yüz"));
      expect(converter.convert(1999, options: yearOption),
          equals("bin dokuz yüz doksan dokuz"));
      expect(converter.convert(2025, options: yearOption),
          equals("iki bin yirmi beş"));
      expect(converter.convert(1900, options: yearOptionAD),
          equals("bin dokuz yüz MS"));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("bin dokuz yüz doksan dokuz MS"));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("iki bin yirmi beş MS"));
      expect(converter.convert(-1, options: yearOption), equals("bir MÖ"));
      expect(converter.convert(-100, options: yearOption), equals("yüz MÖ"));
      expect(converter.convert(-100, options: yearOptionAD), equals("yüz MÖ"));
      expect(converter.convert(-2025, options: yearOption),
          equals("iki bin yirmi beş MÖ"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("bir milyon MÖ"));
    });

    test('Currency', () {
      const currencyOption = TrOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("sıfır Türk lirası"));
      expect(converter.convert(1, options: currencyOption),
          equals("bir Türk lirası"));
      expect(converter.convert(5, options: currencyOption),
          equals("beş Türk lirası"));
      expect(converter.convert(10, options: currencyOption),
          equals("on Türk lirası"));
      expect(converter.convert(11, options: currencyOption),
          equals("on bir Türk lirası"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("bir Türk lirası elli kuruş"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("yüz yirmi üç Türk lirası kırk beş kuruş"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("on milyon Türk lirası"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("elli kuruş"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("bir kuruş"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("beş kuruş"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("bir Türk lirası bir kuruş"));
      expect(converter.convert(5.01, options: currencyOption),
          equals("beş Türk lirası bir kuruş"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("bir milyon"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("iki milyar"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("üç trilyon"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("dört katrilyon"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("beş kentilyon"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("altı sekstilyon"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("yedi septilyon"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("bir trilyon iki milyon üç"));
      expect(
          converter.convert(BigInt.parse('5001000')), equals("beş milyon bin"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("bir milyar bir"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("bir milyar bir milyon"));
      expect(
          converter.convert(BigInt.parse('2001000')), equals("iki milyon bin"));
      expect(converter.convert(BigInt.parse('1000987600003')),
          equals("bir trilyon dokuz yüz seksen yedi milyon altı yüz bin üç"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "dokuz kentilyon sekiz yüz yetmiş altı katrilyon beş yüz kırk üç trilyon iki yüz on milyar yüz yirmi üç milyon dört yüz elli altı bin yedi yüz seksen dokuz"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "yüz yirmi üç sekstilyon dört yüz elli altı kentilyon yedi yüz seksen dokuz katrilyon yüz yirmi üç trilyon dört yüz elli altı milyar yedi yüz seksen dokuz milyon yüz yirmi üç bin dört yüz elli altı"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              'dokuz yüz doksan dokuz sekstilyon dokuz yüz doksan dokuz kentilyon dokuz yüz doksan dokuz katrilyon dokuz yüz doksan dokuz trilyon dokuz yüz doksan dokuz milyar dokuz yüz doksan dokuz milyon dokuz yüz doksan dokuz bin dokuz yüz doksan dokuz'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Sayı Değil"));
      expect(converter.convert(double.infinity), equals("Sonsuz"));
      expect(
          converter.convert(double.negativeInfinity), equals("Negatif Sonsuz"));
      expect(converter.convert(null), equals("Sayı Değil"));
      expect(converter.convert('abc'), equals("Sayı Değil"));
      expect(converter.convert([]), equals("Sayı Değil"));
      expect(converter.convert({}), equals("Sayı Değil"));
      expect(converter.convert(Object()), equals("Sayı Değil"));
      expect(
          converterWithFallback.convert(double.nan), equals("Geçersiz Sayı"));
      expect(converterWithFallback.convert(double.infinity), equals("Sonsuz"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negatif Sonsuz"));
      expect(converterWithFallback.convert(null), equals("Geçersiz Sayı"));
      expect(converterWithFallback.convert('abc'), equals("Geçersiz Sayı"));
      expect(converterWithFallback.convert([]), equals("Geçersiz Sayı"));
      expect(converterWithFallback.convert({}), equals("Geçersiz Sayı"));
      expect(converterWithFallback.convert(Object()), equals("Geçersiz Sayı"));
      expect(converterWithFallback.convert(123), equals("yüz yirmi üç"));
    });
  });
}
