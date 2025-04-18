import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Indonesian (ID)', () {
    final converter = Num2Text(initialLang: Lang.ID);
    final converterWithFallback = Num2Text(
      initialLang: Lang.ID,
      fallbackOnError: "Nomor Tidak Valid",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("nol"));
      expect(converter.convert(1), equals("satu"));
      expect(converter.convert(10), equals("sepuluh"));
      expect(converter.convert(11), equals("sebelas"));
      expect(converter.convert(12), equals("dua belas"));
      expect(converter.convert(20), equals("dua puluh"));
      expect(converter.convert(21), equals("dua puluh satu"));
      expect(converter.convert(99), equals("sembilan puluh sembilan"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("seratus"));
      expect(converter.convert(101), equals("seratus satu"));
      expect(converter.convert(111), equals("seratus sebelas"));
      expect(converter.convert(200), equals("dua ratus"));
      expect(converter.convert(999),
          equals("sembilan ratus sembilan puluh sembilan"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("seribu"));
      expect(converter.convert(1001), equals("seribu satu"));
      expect(converter.convert(1111), equals("seribu seratus sebelas"));
      expect(converter.convert(2000), equals("dua ribu"));
      expect(converter.convert(10000), equals("sepuluh ribu"));
      expect(converter.convert(100000), equals("seratus ribu"));
      expect(
        converter.convert(123456),
        equals("seratus dua puluh tiga ribu empat ratus lima puluh enam"),
      );
      expect(
        converter.convert(999999),
        equals(
          "sembilan ratus sembilan puluh sembilan ribu sembilan ratus sembilan puluh sembilan",
        ),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus satu"));
      expect(converter.convert(-123), equals("minus seratus dua puluh tiga"));
      expect(
        converter.convert(-1, options: IdOptions(negativePrefix: "negatif")),
        equals("negatif satu"),
      );
      expect(
        converter.convert(-123, options: IdOptions(negativePrefix: "negatif")),
        equals("negatif seratus dua puluh tiga"),
      );
    });

    test('Year Formatting', () {
      const yearOption = IdOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("seribu sembilan ratus"));
      expect(converter.convert(2024, options: yearOption),
          equals("dua ribu dua puluh empat"));
      expect(
        converter.convert(1900,
            options: IdOptions(format: Format.year, includeAD: true)),
        equals("seribu sembilan ratus M"),
      );
      expect(
        converter.convert(2024,
            options: IdOptions(format: Format.year, includeAD: true)),
        equals("dua ribu dua puluh empat M"),
      );
      expect(
          converter.convert(-100, options: yearOption), equals("seratus SM"));
      expect(converter.convert(-1, options: yearOption), equals("satu SM"));
      expect(
        converter.convert(-2024,
            options: IdOptions(format: Format.year, includeAD: true)),
        equals("dua ribu dua puluh empat SM"),
      );
    });

    test('Currency', () {
      const currencyOption = IdOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("nol rupiah"));
      expect(
          converter.convert(1, options: currencyOption), equals("satu rupiah"));
      expect(
        converter.convert(1.50, options: currencyOption),
        equals("satu rupiah dan lima puluh sen"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("seratus dua puluh tiga rupiah dan empat puluh lima sen"),
      );
      expect(converter.convert(1000, options: currencyOption),
          equals("seribu rupiah"));
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("seratus dua puluh tiga koma empat lima enam"),
      );
      expect(
          converter.convert(Decimal.parse('1.50')), equals("satu koma lima"));
      expect(converter.convert(123.0), equals("seratus dua puluh tiga"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("seratus dua puluh tiga"));

      expect(
        converter.convert(1.5,
            options: const IdOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("satu koma lima"),
      );

      expect(
        converter.convert(1.5,
            options:
                const IdOptions(decimalSeparator: DecimalSeparator.period)),
        equals("satu titik lima"),
      );
      expect(
        converter.convert(1.5,
            options: const IdOptions(decimalSeparator: DecimalSeparator.point)),
        equals("satu titik lima"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Tak terhingga"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negatif Tak terhingga"));
      expect(converter.convert(double.nan), equals("Bukan Angka"));
      expect(converter.convert(null), equals("Bukan Angka"));
      expect(converter.convert('abc'), equals("Bukan Angka"));

      expect(converterWithFallback.convert(double.infinity),
          equals("Tak terhingga"));
      expect(
        converterWithFallback.convert(double.negativeInfinity),
        equals("Negatif Tak terhingga"),
      );
      expect(converterWithFallback.convert(double.nan),
          equals("Nomor Tidak Valid"));
      expect(converterWithFallback.convert(null), equals("Nomor Tidak Valid"));
      expect(converterWithFallback.convert('abc'), equals("Nomor Tidak Valid"));
      expect(
          converterWithFallback.convert(123), equals("seratus dua puluh tiga"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("satu juta"));
      expect(converter.convert(BigInt.from(1000000000)), equals("satu miliar"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("satu triliun"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("satu kuadriliun"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("satu kuintiliun"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("satu sekstiliun"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("satu septiliun"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "seratus dua puluh tiga sekstiliun empat ratus lima puluh enam kuintiliun tujuh ratus delapan puluh sembilan kuadriliun seratus dua puluh tiga triliun empat ratus lima puluh enam miliar tujuh ratus delapan puluh sembilan juta seratus dua puluh tiga ribu empat ratus lima puluh enam",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "sembilan ratus sembilan puluh sembilan sekstiliun sembilan ratus sembilan puluh sembilan kuintiliun sembilan ratus sembilan puluh sembilan kuadriliun sembilan ratus sembilan puluh sembilan triliun sembilan ratus sembilan puluh sembilan miliar sembilan ratus sembilan puluh sembilan juta sembilan ratus sembilan puluh sembilan ribu sembilan ratus sembilan puluh sembilan",
        ),
      );
    });
  });
}
