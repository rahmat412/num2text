import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Turkish (TR)', () {
    final converter = Num2Text(initialLang: Lang.TR);
    final converterWithFallback =
        Num2Text(initialLang: Lang.TR, fallbackOnError: "Geçersiz Sayı");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("sıfır"));
      expect(converter.convert(1), equals("bir"));
      expect(converter.convert(10), equals("on"));
      expect(converter.convert(11), equals("on bir"));
      expect(converter.convert(20), equals("yirmi"));
      expect(converter.convert(21), equals("yirmi bir"));
      expect(converter.convert(99), equals("doksan dokuz"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("yüz"));
      expect(converter.convert(101), equals("yüz bir"));
      expect(converter.convert(111), equals("yüz on bir"));
      expect(converter.convert(200), equals("iki yüz"));
      expect(converter.convert(999), equals("dokuz yüz doksan dokuz"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("bin"));
      expect(converter.convert(1001), equals("bin bir"));
      expect(converter.convert(1111), equals("bin yüz on bir"));
      expect(converter.convert(2000), equals("iki bin"));
      expect(converter.convert(10000), equals("on bin"));
      expect(converter.convert(100000), equals("yüz bin"));
      expect(converter.convert(123456),
          equals("yüz yirmi üç bin dört yüz elli altı"));
      expect(
        converter.convert(999999),
        equals("dokuz yüz doksan dokuz bin dokuz yüz doksan dokuz"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("eksi bir"));
      expect(converter.convert(-123), equals("eksi yüz yirmi üç"));
      expect(
        converter.convert(-1, options: TrOptions(negativePrefix: "negatif")),
        equals("negatif bir"),
      );
      expect(
        converter.convert(-123, options: TrOptions(negativePrefix: "negatif")),
        equals("negatif yüz yirmi üç"),
      );
    });

    test('Year Formatting', () {
      const yearOption = TrOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("bin dokuz yüz"));
      expect(converter.convert(2024, options: yearOption),
          equals("iki bin yirmi dört"));
      expect(
        converter.convert(1900, options: TrOptions(format: Format.year)),
        equals("bin dokuz yüz"),
      );
      expect(
        converter.convert(2024, options: TrOptions(format: Format.year)),
        equals("iki bin yirmi dört"),
      );
      expect(converter.convert(-100, options: yearOption), equals("eksi yüz"));
      expect(converter.convert(-1, options: yearOption), equals("eksi bir"));
      expect(
        converter.convert(-2024, options: TrOptions(format: Format.year)),
        equals("eksi iki bin yirmi dört"),
      );
    });

    test('Currency', () {
      const currencyOption = TrOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("sıfır Türk lirası"));
      expect(converter.convert(1, options: currencyOption),
          equals("bir Türk lirası"));
      expect(
        converter.convert(1.50, options: currencyOption),
        equals("bir Türk lirası elli kuruş"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("yüz yirmi üç Türk lirası kırk beş kuruş"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("yüz yirmi üç virgül dört beş altı"),
      );
      expect(
          converter.convert(Decimal.parse('1.50')), equals("bir virgül beş"));
      expect(converter.convert(123.0), equals("yüz yirmi üç"));
      expect(converter.convert(Decimal.parse('123.0')), equals("yüz yirmi üç"));
      expect(
        converter.convert(1.5,
            options: const TrOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("bir virgül beş"),
      );
      expect(
        converter.convert(1.5,
            options:
                const TrOptions(decimalSeparator: DecimalSeparator.period)),
        equals("bir nokta beş"),
      );
      expect(
        converter.convert(1.5,
            options: const TrOptions(decimalSeparator: DecimalSeparator.point)),
        equals("bir nokta beş"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Sonsuz"));
      expect(
          converter.convert(double.negativeInfinity), equals("Negatif Sonsuz"));
      expect(converter.convert(double.nan), equals("Sayı Değil"));
      expect(converter.convert(null), equals("Sayı Değil"));
      expect(converter.convert('abc'), equals("Sayı Değil"));

      expect(converterWithFallback.convert(double.infinity), equals("Sonsuz"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negatif Sonsuz"));
      expect(
          converterWithFallback.convert(double.nan), equals("Geçersiz Sayı"));
      expect(converterWithFallback.convert(null), equals("Geçersiz Sayı"));
      expect(converterWithFallback.convert('abc'), equals("Geçersiz Sayı"));
      expect(converterWithFallback.convert(123), equals("yüz yirmi üç"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("bir milyon"));
      expect(converter.convert(BigInt.from(1000000000)), equals("bir milyar"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("bir trilyon"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("bir katrilyon"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("bir kentilyon"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("bir sekstilyon"));
      expect(converter.convert(BigInt.parse('1000000000000000000000000')),
          equals("bir septilyon"));
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          'yüz yirmi üç sekstilyon dört yüz elli altı kentilyon yedi yüz seksen dokuz katrilyon yüz yirmi üç trilyon dört yüz elli altı milyar yedi yüz seksen dokuz milyon yüz yirmi üç bin dört yüz elli altı',
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          'dokuz yüz doksan dokuz sekstilyon dokuz yüz doksan dokuz kentilyon dokuz yüz doksan dokuz katrilyon dokuz yüz doksan dokuz trilyon dokuz yüz doksan dokuz milyar dokuz yüz doksan dokuz milyon dokuz yüz doksan dokuz bin dokuz yüz doksan dokuz',
        ),
      );
    });
  });
}
