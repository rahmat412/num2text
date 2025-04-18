import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Malay (MS)', () {
    final converter = Num2Text(initialLang: Lang.MS);
    final converterWithFallback = Num2Text(
      initialLang: Lang.MS,
      fallbackOnError: "Nombor Tidak Sah",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("sifar"));
      expect(converter.convert(1), equals("satu"));
      expect(converter.convert(10), equals("sepuluh"));
      expect(converter.convert(11), equals("sebelas"));
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
      expect(converter.convert(-1), equals("negatif satu"));
      expect(converter.convert(-123), equals("negatif seratus dua puluh tiga"));
      expect(
        converter.convert(-1, options: MsOptions(negativePrefix: "tolak")),
        equals("tolak satu"),
      );
      expect(
        converter.convert(-123, options: MsOptions(negativePrefix: "tolak")),
        equals("tolak seratus dua puluh tiga"),
      );
    });

    test('Year Formatting', () {
      const yearOption = MsOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("seribu sembilan ratus"));
      expect(converter.convert(2024, options: yearOption),
          equals("dua ribu dua puluh empat"));
      expect(
        converter.convert(1900,
            options: MsOptions(format: Format.year, includeAD: true)),
        equals("seribu sembilan ratus M"),
      );
      expect(
        converter.convert(2024,
            options: MsOptions(format: Format.year, includeAD: true)),
        equals("dua ribu dua puluh empat M"),
      );
      expect(
          converter.convert(-100, options: yearOption), equals("seratus SM"));
      expect(converter.convert(-1, options: yearOption), equals("satu SM"));
      expect(
        converter.convert(-2024, options: MsOptions(format: Format.year)),
        equals("dua ribu dua puluh empat SM"),
      );
    });

    test('Currency', () {
      const currencyOption = MsOptions(currency: true);
      expect(converter.convert(1.01, options: currencyOption),
          equals("satu ringgit dan satu sen"));
      expect(
        converter.convert(2.50, options: currencyOption),
        equals("dua ringgit dan lima puluh sen"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("seratus dua puluh tiga ringgit dan empat puluh lima sen"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("seratus dua puluh tiga perpuluhan empat lima enam"),
      );

      expect(converter.convert(Decimal.parse('1.50')),
          equals("satu perpuluhan lima"));
      expect(converter.convert(123.0), equals("seratus dua puluh tiga"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("seratus dua puluh tiga"));
      expect(
        converter.convert(1.5,
            options: const MsOptions(decimalSeparator: DecimalSeparator.point)),
        equals("satu perpuluhan lima"),
      );
      expect(
        converter.convert(1.5,
            options: const MsOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("satu koma lima"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Infiniti"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negatif Infiniti"));
      expect(converter.convert(double.nan), equals("Bukan Nombor"));
      expect(converter.convert(null), equals("Bukan Nombor"));
      expect(converter.convert('abc'), equals("Bukan Nombor"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Infiniti"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negatif Infiniti"));
      expect(converterWithFallback.convert(double.nan),
          equals("Nombor Tidak Sah"));
      expect(converterWithFallback.convert(null), equals("Nombor Tidak Sah"));
      expect(converterWithFallback.convert('abc'), equals("Nombor Tidak Sah"));
      expect(
          converterWithFallback.convert(123), equals("seratus dua puluh tiga"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("satu juta"));
      expect(converter.convert(BigInt.from(1000000000)), equals("satu bilion"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("satu trilion"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("satu kuadrilion"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("satu kuintilion"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("satu sekstilion"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("satu septilion"),
      );

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "seratus dua puluh tiga sekstilion empat ratus lima puluh enam kuintilion tujuh ratus lapan puluh sembilan kuadrilion seratus dua puluh tiga trilion empat ratus lima puluh enam bilion tujuh ratus lapan puluh sembilan juta seratus dua puluh tiga ribu empat ratus lima puluh enam",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "sembilan ratus sembilan puluh sembilan sekstilion sembilan ratus sembilan puluh sembilan kuintilion sembilan ratus sembilan puluh sembilan kuadrilion sembilan ratus sembilan puluh sembilan trilion sembilan ratus sembilan puluh sembilan bilion sembilan ratus sembilan puluh sembilan juta sembilan ratus sembilan puluh sembilan ribu sembilan ratus sembilan puluh sembilan",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999')),
        equals(
          "sembilan ratus sembilan puluh sembilan juta sembilan ratus sembilan puluh sembilan ribu sembilan ratus sembilan puluh sembilan",
        ),
      );
      expect(
          converter.convert(BigInt.parse('1000000000')), equals("satu bilion"));
      expect(
          converter.convert(BigInt.parse('1000001')), equals("satu juta satu"));
    });
  });
}
