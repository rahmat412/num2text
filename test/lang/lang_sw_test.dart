import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Swahili (SW)', () {
    final converter = Num2Text(initialLang: Lang.SW);
    final converterWithFallback =
        Num2Text(initialLang: Lang.SW, fallbackOnError: "Nambari Batili");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("sifuri"));
      expect(converter.convert(10), equals("kumi"));
      expect(converter.convert(11), equals("kumi na moja"));
      expect(converter.convert(13), equals("kumi na tatu"));
      expect(converter.convert(15), equals("kumi na tano"));
      expect(converter.convert(20), equals("ishirini"));
      expect(converter.convert(27), equals("ishirini na saba"));
      expect(converter.convert(30), equals("thelathini"));
      expect(converter.convert(54), equals("hamsini na nne"));
      expect(converter.convert(68), equals("sitini na nane"));
      expect(converter.convert(99), equals("tisini na tisa"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("mia moja"));
      expect(converter.convert(101), equals("mia moja na moja"));
      expect(converter.convert(105), equals("mia moja na tano"));
      expect(converter.convert(110), equals("mia moja na kumi"));
      expect(converter.convert(111), equals("mia moja na kumi na moja"));
      expect(converter.convert(123), equals("mia moja na ishirini na tatu"));
      expect(converter.convert(200), equals("mia mbili"));
      expect(converter.convert(321), equals("mia tatu na ishirini na moja"));
      expect(converter.convert(479), equals("mia nne na sabini na tisa"));
      expect(converter.convert(596), equals("mia tano na tisini na sita"));
      expect(converter.convert(681), equals("mia sita na themanini na moja"));
      expect(converter.convert(999), equals("mia tisa na tisini na tisa"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("elfu moja"));
      expect(converter.convert(1001), equals("elfu moja na moja"));
      expect(converter.convert(1011), equals("elfu moja na kumi na moja"));
      expect(converter.convert(1110), equals("elfu moja na mia moja na kumi"));
      expect(converter.convert(1111),
          equals("elfu moja na mia moja na kumi na moja"));
      expect(converter.convert(2000), equals("elfu mbili"));
      expect(converter.convert(2468),
          equals("elfu mbili na mia nne na sitini na nane"));
      expect(converter.convert(3579),
          equals("elfu tatu na mia tano na sabini na tisa"));
      expect(converter.convert(10000), equals("elfu kumi"));
      expect(converter.convert(10011), equals("elfu kumi na kumi na moja"));
      expect(converter.convert(11100), equals("elfu kumi na moja na mia moja"));
      expect(converter.convert(12987),
          equals("elfu kumi na mbili na mia tisa na themanini na saba"));
      expect(converter.convert(45623),
          equals("elfu arobaini na tano na mia sita na ishirini na tatu"));
      expect(converter.convert(87654),
          equals("elfu themanini na saba na mia sita na hamsini na nne"));
      expect(converter.convert(100000), equals("laki moja"));
      expect(
          converter.convert(123456),
          equals(
              "laki moja na elfu ishirini na tatu na mia nne na hamsini na sita"));
      expect(
          converter.convert(987654),
          equals(
              "laki tisa na elfu themanini na saba na mia sita na hamsini na nne"));
      expect(
          converter.convert(999999),
          equals(
              "laki tisa na elfu tisini na tisa na mia tisa na tisini na tisa"));
    });

    test('Negative Numbers', () {
      const minusOption = SwOptions(negativePrefix: "minus");
      expect(converter.convert(-1), equals("hasi moja"));
      expect(
          converter.convert(-123), equals("hasi mia moja na ishirini na tatu"));
      expect(converter.convert(-123.456),
          equals("hasi mia moja na ishirini na tatu pointi nne tano sita"));
      expect(converter.convert(-1, options: minusOption), equals("minus moja"));
      expect(converter.convert(-123, options: minusOption),
          equals("minus mia moja na ishirini na tatu"));
      expect(
        converter.convert(-123.456, options: minusOption),
        equals("minus mia moja na ishirini na tatu pointi nne tano sita"),
      );
    });

    test('Decimals', () {
      const commaOption = SwOptions(decimalSeparator: DecimalSeparator.comma);
      const pointOption = SwOptions(decimalSeparator: DecimalSeparator.point);
      const periodOption = SwOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(123.456),
          equals("mia moja na ishirini na tatu pointi nne tano sita"));
      expect(converter.convert(1.5), equals("moja pointi tano"));
      expect(converter.convert(1.05), equals("moja pointi sifuri tano"));
      expect(converter.convert(879.465),
          equals("mia nane na sabini na tisa pointi nne sita tano"));
      expect(converter.convert(1.5, options: pointOption),
          equals("moja pointi tano"));
      expect(converter.convert(1.5, options: commaOption),
          equals("moja koma tano"));
      expect(converter.convert(1.5, options: periodOption),
          equals("moja pointi tano"));
    });

    test('Year Formatting', () {
      const yearOption = SwOptions(format: Format.year);
      const yearOptionAD = SwOptions(format: Format.year, includeAD: true);
      expect(converter.convert(123, options: yearOption),
          equals("mia moja na ishirini na tatu"));
      expect(converter.convert(498, options: yearOption),
          equals("mia nne na tisini na nane"));
      expect(converter.convert(756, options: yearOption),
          equals("mia saba na hamsini na sita"));
      expect(converter.convert(1900, options: yearOption),
          equals("elfu moja mia tisa"));
      expect(converter.convert(1999, options: yearOption),
          equals("elfu moja mia tisa na tisini na tisa"));
      expect(converter.convert(2025, options: yearOption),
          equals("elfu mbili ishirini na tano"));
      expect(converter.convert(1900, options: yearOptionAD),
          equals("elfu moja mia tisa BK"));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("elfu moja mia tisa na tisini na tisa BK"));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("elfu mbili ishirini na tano BK"));
      expect(converter.convert(-1, options: yearOption), equals("moja KK"));
      expect(
          converter.convert(-100, options: yearOption), equals("mia moja KK"));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("mia moja KK"));
      expect(converter.convert(-2025, options: yearOption),
          equals("elfu mbili ishirini na tano KK"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("milioni moja KK"));
    });

    test('Currency', () {
      const currencyOption = SwOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("shilingi sifuri"));
      expect(converter.convert(1, options: currencyOption),
          equals("shilingi moja"));
      expect(converter.convert(5, options: currencyOption),
          equals("shilingi tano"));
      expect(converter.convert(10, options: currencyOption),
          equals("shilingi kumi"));
      expect(converter.convert(11, options: currencyOption),
          equals("shilingi kumi na moja"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("shilingi moja na senti hamsini"));
      expect(
          converter.convert(123.45, options: currencyOption),
          equals(
              "shilingi mia moja na ishirini na tatu na senti arobaini na tano"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("shilingi milioni kumi"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("senti hamsini"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("senti moja"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("senti tano"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("shilingi moja na senti moja"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("milioni moja"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("bilioni mbili"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("trilioni tatu"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("kwadrilioni nne"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("kwintilioni tano"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("sekstilioni sita"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("septilioni saba"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            'kwintilioni tisa na kwadrilioni mia nane na sabini na sita na trilioni mia tano na arobaini na tatu na bilioni mia mbili na kumi na milioni mia moja na ishirini na tatu na laki nne na elfu hamsini na sita na mia saba na themanini na tisa'),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "sekstilioni mia moja na ishirini na tatu na kwintilioni mia nne na hamsini na sita na kwadrilioni mia saba na themanini na tisa na trilioni mia moja na ishirini na tatu na bilioni mia nne na hamsini na sita na milioni mia saba na themanini na tisa na laki moja na elfu ishirini na tatu na mia nne na hamsini na sita"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "sekstilioni mia tisa na tisini na tisa na kwintilioni mia tisa na tisini na tisa na kwadrilioni mia tisa na tisini na tisa na trilioni mia tisa na tisini na tisa na bilioni mia tisa na tisini na tisa na milioni mia tisa na tisini na tisa na laki tisa na elfu tisini na tisa na mia tisa na tisini na tisa"),
      );
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('trilioni moja na milioni mbili na tatu'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("milioni tano na elfu moja"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("bilioni moja na moja"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("bilioni moja na milioni moja"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("milioni mbili na elfu moja"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "trilioni moja na milioni mia tisa na themanini na saba na laki sita na tatu"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Si Nambari"));
      expect(converter.convert(double.infinity), equals("Ukomo"));
      expect(converter.convert(double.negativeInfinity), equals("Hasi Ukomo"));
      expect(converter.convert(null), equals("Si Nambari"));
      expect(converter.convert('abc'), equals("Si Nambari"));
      expect(converter.convert([]), equals("Si Nambari"));
      expect(converter.convert({}), equals("Si Nambari"));
      expect(converter.convert(Object()), equals("Si Nambari"));
      expect(
          converterWithFallback.convert(double.nan), equals("Nambari Batili"));
      expect(converterWithFallback.convert(double.infinity), equals("Ukomo"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Hasi Ukomo"));
      expect(converterWithFallback.convert(null), equals("Nambari Batili"));
      expect(converterWithFallback.convert('abc'), equals("Nambari Batili"));
      expect(converterWithFallback.convert([]), equals("Nambari Batili"));
      expect(converterWithFallback.convert({}), equals("Nambari Batili"));
      expect(converterWithFallback.convert(Object()), equals("Nambari Batili"));
      expect(converterWithFallback.convert(123),
          equals("mia moja na ishirini na tatu"));
    });
  });
}
