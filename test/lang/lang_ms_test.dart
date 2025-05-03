import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Malay (MS)', () {
    final converter = Num2Text(initialLang: Lang.MS);
    final converterWithFallback =
        Num2Text(initialLang: Lang.MS, fallbackOnError: "Nombor Tidak Sah");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("sifar"));
      expect(converter.convert(10), equals("sepuluh"));
      expect(converter.convert(11), equals("sebelas"));
      expect(converter.convert(13), equals("tiga belas"));
      expect(converter.convert(15), equals("lima belas"));
      expect(converter.convert(20), equals("dua puluh"));
      expect(converter.convert(27), equals("dua puluh tujuh"));
      expect(converter.convert(30), equals("tiga puluh"));
      expect(converter.convert(54), equals("lima puluh empat"));
      expect(converter.convert(68), equals("enam puluh lapan"));
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
      expect(converter.convert(681), equals("enam ratus lapan puluh satu"));
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
          equals("dua ribu empat ratus enam puluh lapan"));
      expect(converter.convert(3579),
          equals("tiga ribu lima ratus tujuh puluh sembilan"));
      expect(converter.convert(10000), equals("sepuluh ribu"));
      expect(converter.convert(10011), equals("sepuluh ribu sebelas"));
      expect(converter.convert(11100), equals("sebelas ribu seratus"));
      expect(converter.convert(12987),
          equals("dua belas ribu sembilan ratus lapan puluh tujuh"));
      expect(converter.convert(45623),
          equals("empat puluh lima ribu enam ratus dua puluh tiga"));
      expect(converter.convert(87654),
          equals("lapan puluh tujuh ribu enam ratus lima puluh empat"));
      expect(converter.convert(100000), equals("seratus ribu"));
      expect(converter.convert(123456),
          equals("seratus dua puluh tiga ribu empat ratus lima puluh enam"));
      expect(
          converter.convert(987654),
          equals(
              "sembilan ratus lapan puluh tujuh ribu enam ratus lima puluh empat"));
      expect(
          converter.convert(999999),
          equals(
              "sembilan ratus sembilan puluh sembilan ribu sembilan ratus sembilan puluh sembilan"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("negatif satu"));
      expect(converter.convert(-123), equals("negatif seratus dua puluh tiga"));
      expect(converter.convert(-123.456),
          equals("negatif seratus dua puluh tiga perpuluhan empat lima enam"));

      const negativeOption = MsOptions(negativePrefix: "tolak");

      expect(
          converter.convert(-1, options: negativeOption), equals("tolak satu"));
      expect(converter.convert(-123, options: negativeOption),
          equals("tolak seratus dua puluh tiga"));
      expect(converter.convert(-123.456, options: negativeOption),
          equals("tolak seratus dua puluh tiga perpuluhan empat lima enam"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456),
          equals("seratus dua puluh tiga perpuluhan empat lima enam"));
      expect(converter.convert("1.5"), equals("satu perpuluhan lima"));
      expect(converter.convert(1.05), equals("satu perpuluhan sifar lima"));
      expect(
          converter.convert(879.465),
          equals(
              "lapan ratus tujuh puluh sembilan perpuluhan empat enam lima"));
      expect(converter.convert(1.5), equals("satu perpuluhan lima"));

      const pointOption = MsOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = MsOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = MsOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(1.5, options: pointOption),
          equals("satu perpuluhan lima"));
      expect(converter.convert(1.5, options: commaOption),
          equals("satu koma lima"));
      expect(converter.convert(1.5, options: periodOption),
          equals("satu perpuluhan lima"));
    });

    test('Year Formatting', () {
      const yearOption = MsOptions(format: Format.year);

      expect(converter.convert(123, options: yearOption),
          equals("seratus dua puluh tiga"));
      expect(converter.convert(498, options: yearOption),
          equals("empat ratus sembilan puluh lapan"));
      expect(converter.convert(756, options: yearOption),
          equals("tujuh ratus lima puluh enam"));
      expect(converter.convert(1900, options: yearOption),
          equals("seribu sembilan ratus"));
      expect(converter.convert(1999, options: yearOption),
          equals("seribu sembilan ratus sembilan puluh sembilan"));
      expect(converter.convert(2025, options: yearOption),
          equals("dua ribu dua puluh lima"));

      const yearOptionAD = MsOptions(format: Format.year, includeAD: true);

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
      const currencyOption = MsOptions(currency: true);

      expect(converter.convert(0, options: currencyOption),
          equals("sifar ringgit"));
      expect(converter.convert(1, options: currencyOption),
          equals("satu ringgit"));
      expect(converter.convert(5, options: currencyOption),
          equals("lima ringgit"));
      expect(converter.convert(10, options: currencyOption),
          equals("sepuluh ringgit"));
      expect(converter.convert(11, options: currencyOption),
          equals("sebelas ringgit"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("satu ringgit dan lima puluh sen"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("seratus dua puluh tiga ringgit dan empat puluh lima sen"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("sepuluh juta ringgit"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("lima puluh sen"));
      expect(
          converter.convert(0.01, options: currencyOption), equals("satu sen"));
      expect(converter.convert(0.1, options: currencyOption),
          equals("sepuluh sen"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("satu juta"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("dua bilion"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("tiga trilion"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("empat kuadrilion"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("lima kuintilion"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("enam sekstilion"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("tujuh septilion"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            "sembilan kuintilion lapan ratus tujuh puluh enam kuadrilion lima ratus empat puluh tiga trilion dua ratus sepuluh bilion seratus dua puluh tiga juta empat ratus lima puluh enam ribu tujuh ratus lapan puluh sembilan"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "seratus dua puluh tiga sekstilion empat ratus lima puluh enam kuintilion tujuh ratus lapan puluh sembilan kuadrilion seratus dua puluh tiga trilion empat ratus lima puluh enam bilion tujuh ratus lapan puluh sembilan juta seratus dua puluh tiga ribu empat ratus lima puluh enam"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "sembilan ratus sembilan puluh sembilan sekstilion sembilan ratus sembilan puluh sembilan kuintilion sembilan ratus sembilan puluh sembilan kuadrilion sembilan ratus sembilan puluh sembilan trilion sembilan ratus sembilan puluh sembilan bilion sembilan ratus sembilan puluh sembilan juta sembilan ratus sembilan puluh sembilan ribu sembilan ratus sembilan puluh sembilan"),
      );
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("satu trilion dua juta tiga"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("lima juta seribu"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("satu bilion satu"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("satu bilion satu juta"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("dua juta seribu"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "satu trilion sembilan ratus lapan puluh tujuh juta enam ratus ribu tiga"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Bukan Nombor"));
      expect(converter.convert(double.infinity), equals("Infiniti"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negatif Infiniti"));
      expect(converter.convert(null), equals("Bukan Nombor"));
      expect(converter.convert('abc'), equals("Bukan Nombor"));
      expect(converter.convert([]), equals("Bukan Nombor"));
      expect(converter.convert({}), equals("Bukan Nombor"));
      expect(converter.convert(Object()), equals("Bukan Nombor"));

      expect(converterWithFallback.convert(double.nan),
          equals("Nombor Tidak Sah"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Infiniti"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negatif Infiniti"));
      expect(converterWithFallback.convert(null), equals("Nombor Tidak Sah"));
      expect(converterWithFallback.convert('abc'), equals("Nombor Tidak Sah"));
      expect(converterWithFallback.convert([]), equals("Nombor Tidak Sah"));
      expect(converterWithFallback.convert({}), equals("Nombor Tidak Sah"));
      expect(
          converterWithFallback.convert(Object()), equals("Nombor Tidak Sah"));
      expect(
          converterWithFallback.convert(123), equals("seratus dua puluh tiga"));
    });
  });
}
