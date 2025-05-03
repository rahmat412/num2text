import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Indonesian (ID)', () {
    final converter = Num2Text(initialLang: Lang.ID);
    final converterWithFallback = Num2Text(
      initialLang: Lang.ID,
      fallbackOnError: "Nomor Tidak Valid",
    );

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("nol"));
      expect(converter.convert(10), equals("sepuluh"));
      expect(converter.convert(11), equals("sebelas"));
      expect(converter.convert(13), equals("tiga belas"));
      expect(converter.convert(15), equals("lima belas"));
      expect(converter.convert(20), equals("dua puluh"));
      expect(converter.convert(27), equals("dua puluh tujuh"));
      expect(converter.convert(30), equals("tiga puluh"));
      expect(converter.convert(54), equals("lima puluh empat"));
      expect(converter.convert(68), equals("enam puluh delapan"));
      expect(converter.convert(99), equals("sembilan puluh sembilan"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("seratus"));
      expect(converter.convert(101), equals("seratus satu"));
      expect(converter.convert(105), equals("seratus lima"));
      expect(converter.convert(110), equals("seratus sepuluh"));
      expect(converter.convert(111), equals("seratus sebelas"));
      expect(converter.convert(123), equals("seratus dua puluh tiga"));
      expect(converter.convert(200), equals("dua ratus"));
      expect(converter.convert(321), equals("tiga ratus dua puluh satu"));
      expect(
          converter.convert(479), equals("empat ratus tujuh puluh sembilan"));
      expect(converter.convert(596), equals("lima ratus sembilan puluh enam"));
      expect(converter.convert(681), equals("enam ratus delapan puluh satu"));
      expect(converter.convert(999),
          equals("sembilan ratus sembilan puluh sembilan"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("seribu"));
      expect(converter.convert(1001), equals("seribu satu"));
      expect(converter.convert(1011), equals("seribu sebelas"));
      expect(converter.convert(1110), equals("seribu seratus sepuluh"));
      expect(converter.convert(1111), equals("seribu seratus sebelas"));
      expect(converter.convert(2000), equals("dua ribu"));
      expect(converter.convert(2468),
          equals("dua ribu empat ratus enam puluh delapan"));
      expect(converter.convert(3579),
          equals("tiga ribu lima ratus tujuh puluh sembilan"));
      expect(converter.convert(10000), equals("sepuluh ribu"));
      expect(converter.convert(10011), equals("sepuluh ribu sebelas"));
      expect(converter.convert(11100), equals("sebelas ribu seratus"));
      expect(converter.convert(12987),
          equals("dua belas ribu sembilan ratus delapan puluh tujuh"));
      expect(converter.convert(45623),
          equals("empat puluh lima ribu enam ratus dua puluh tiga"));
      expect(converter.convert(87654),
          equals("delapan puluh tujuh ribu enam ratus lima puluh empat"));
      expect(converter.convert(100000), equals("seratus ribu"));
      expect(converter.convert(123456),
          equals("seratus dua puluh tiga ribu empat ratus lima puluh enam"));
      expect(
          converter.convert(987654),
          equals(
              "sembilan ratus delapan puluh tujuh ribu enam ratus lima puluh empat"));
      expect(
          converter.convert(999999),
          equals(
              "sembilan ratus sembilan puluh sembilan ribu sembilan ratus sembilan puluh sembilan"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus satu"));
      expect(converter.convert(-123), equals("minus seratus dua puluh tiga"));
      expect(converter.convert(-123.456),
          equals("minus seratus dua puluh tiga koma empat lima enam"));

      const negativeOption = IdOptions(negativePrefix: "negatif");

      expect(converter.convert(-1, options: negativeOption),
          equals("negatif satu"));
      expect(converter.convert(-123, options: negativeOption),
          equals("negatif seratus dua puluh tiga"));
      expect(converter.convert(-123.456, options: negativeOption),
          equals("negatif seratus dua puluh tiga koma empat lima enam"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456),
          equals("seratus dua puluh tiga koma empat lima enam"));
      expect(converter.convert(1.5), equals("satu koma lima"));
      expect(converter.convert(1.05), equals("satu koma nol lima"));
      expect(converter.convert(879.465),
          equals("delapan ratus tujuh puluh sembilan koma empat enam lima"));
      expect(converter.convert(1.5), equals("satu koma lima"));

      const pointOption = IdOptions(decimalSeparator: DecimalSeparator.point);

      expect(converter.convert(1.5, options: pointOption),
          equals("satu titik lima"));

      const commaOption = IdOptions(decimalSeparator: DecimalSeparator.comma);

      expect(converter.convert(1.5, options: commaOption),
          equals("satu koma lima"));

      const periodOption = IdOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(1.5, options: periodOption),
          equals("satu titik lima"));
    });

    test('Year Formatting', () {
      const yearOption = IdOptions(format: Format.year);

      expect(converter.convert(123, options: yearOption),
          equals("seratus dua puluh tiga"));
      expect(converter.convert(498, options: yearOption),
          equals("empat ratus sembilan puluh delapan"));
      expect(converter.convert(756, options: yearOption),
          equals("tujuh ratus lima puluh enam"));
      expect(converter.convert(1900, options: yearOption),
          equals("seribu sembilan ratus"));
      expect(converter.convert(1999, options: yearOption),
          equals("seribu sembilan ratus sembilan puluh sembilan"));
      expect(converter.convert(2025, options: yearOption),
          equals("dua ribu dua puluh lima"));

      const yearOptionAD = IdOptions(format: Format.year, includeAD: true);

      expect(converter.convert(1900, options: yearOptionAD),
          equals("seribu sembilan ratus M"));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("seribu sembilan ratus sembilan puluh sembilan M"));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("dua ribu dua puluh lima M"));
      expect(converter.convert(-1, options: yearOption), equals("satu SM"));
      expect(
          converter.convert(-100, options: yearOption), equals("seratus SM"));
      expect(
          converter.convert(-100, options: yearOptionAD), equals("seratus SM"));
      expect(converter.convert(-2025, options: yearOption),
          equals("dua ribu dua puluh lima SM"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("satu juta SM"));
    });

    test('Currency', () {
      const currencyOption = IdOptions(currency: true);

      expect(
          converter.convert(0, options: currencyOption), equals("nol rupiah"));
      expect(
          converter.convert(1, options: currencyOption), equals("satu rupiah"));
      expect(
          converter.convert(5, options: currencyOption), equals("lima rupiah"));
      expect(converter.convert(10, options: currencyOption),
          equals("sepuluh rupiah"));
      expect(converter.convert(11, options: currencyOption),
          equals("sebelas rupiah"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("satu rupiah dan lima puluh sen"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("seratus dua puluh tiga rupiah dan empat puluh lima sen"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("sepuluh juta rupiah"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("lima puluh sen"));
      expect(
          converter.convert(0.01, options: currencyOption), equals("satu sen"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("satu rupiah dan satu sen"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("satu juta"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("dua miliar"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("tiga triliun"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("empat kuadriliun"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("lima kuintiliun"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("enam sekstiliun"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("tujuh septiliun"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            "sembilan kuintiliun delapan ratus tujuh puluh enam kuadriliun lima ratus empat puluh tiga triliun dua ratus sepuluh miliar seratus dua puluh tiga juta empat ratus lima puluh enam ribu tujuh ratus delapan puluh sembilan"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "seratus dua puluh tiga sekstiliun empat ratus lima puluh enam kuintiliun tujuh ratus delapan puluh sembilan kuadriliun seratus dua puluh tiga triliun empat ratus lima puluh enam miliar tujuh ratus delapan puluh sembilan juta seratus dua puluh tiga ribu empat ratus lima puluh enam"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "sembilan ratus sembilan puluh sembilan sekstiliun sembilan ratus sembilan puluh sembilan kuintiliun sembilan ratus sembilan puluh sembilan kuadriliun sembilan ratus sembilan puluh sembilan triliun sembilan ratus sembilan puluh sembilan miliar sembilan ratus sembilan puluh sembilan juta sembilan ratus sembilan puluh sembilan ribu sembilan ratus sembilan puluh sembilan"),
      );

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("satu triliun dua juta tiga"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("lima juta seribu"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("satu miliar satu"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("satu miliar satu juta"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("dua juta seribu"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "satu triliun sembilan ratus delapan puluh tujuh juta enam ratus ribu tiga"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Bukan Angka"));
      expect(converter.convert(double.infinity), equals("Tak Terhingga"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negatif Tak Terhingga"));
      expect(converter.convert(null), equals("Bukan Angka"));
      expect(converter.convert('abc'), equals("Bukan Angka"));
      expect(converter.convert([]), equals("Bukan Angka"));
      expect(converter.convert({}), equals("Bukan Angka"));
      expect(converter.convert(Object()), equals("Bukan Angka"));

      expect(converterWithFallback.convert(double.nan),
          equals("Nomor Tidak Valid"));
      expect(converterWithFallback.convert(double.infinity),
          equals("Tak Terhingga"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negatif Tak Terhingga"));
      expect(converterWithFallback.convert(null), equals("Nomor Tidak Valid"));
      expect(converterWithFallback.convert('abc'), equals("Nomor Tidak Valid"));
      expect(converterWithFallback.convert([]), equals("Nomor Tidak Valid"));
      expect(converterWithFallback.convert({}), equals("Nomor Tidak Valid"));
      expect(
          converterWithFallback.convert(Object()), equals("Nomor Tidak Valid"));
      expect(
          converterWithFallback.convert(123), equals("seratus dua puluh tiga"));
    });
  });
}
