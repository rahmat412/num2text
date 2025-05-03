import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Norwegian (NO)', () {
    final converter = Num2Text(initialLang: Lang.NO);
    final converterWithFallback =
        Num2Text(initialLang: Lang.NO, fallbackOnError: "Ugyldig Nummer");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("null"));
      expect(converter.convert(10), equals("ti"));
      expect(converter.convert(11), equals("elleve"));
      expect(converter.convert(13), equals("tretten"));
      expect(converter.convert(15), equals("femten"));
      expect(converter.convert(20), equals("tjue"));
      expect(converter.convert(27), equals("tjuesju"));
      expect(converter.convert(30), equals("tretti"));
      expect(converter.convert(54), equals("femtifire"));
      expect(converter.convert(68), equals("sekstiåtte"));
      expect(converter.convert(99), equals("nittini"));
      expect(
          converter.convert(1, options: const NoOptions(gender: Gender.neuter)),
          equals("ett"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("ett hundre"));
      expect(converter.convert(101), equals("ett hundre og en"));
      expect(converter.convert(105), equals("ett hundre og fem"));
      expect(converter.convert(110), equals("ett hundre og ti"));
      expect(converter.convert(111), equals("ett hundre og elleve"));
      expect(converter.convert(123), equals("ett hundre og tjuetre"));
      expect(converter.convert(200), equals("to hundre"));
      expect(converter.convert(321), equals("tre hundre og tjueen"));
      expect(converter.convert(479), equals("fire hundre og syttini"));
      expect(converter.convert(596), equals("fem hundre og nittiseks"));
      expect(converter.convert(681), equals("seks hundre og åttien"));
      expect(converter.convert(999), equals("ni hundre og nittini"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("ett tusen"));
      expect(converter.convert(1001), equals("ett tusen og en"));
      expect(converter.convert(1011), equals("ett tusen og elleve"));
      expect(converter.convert(1110), equals("ett tusen ett hundre og ti"));
      expect(converter.convert(1111), equals("ett tusen ett hundre og elleve"));
      expect(converter.convert(2000), equals("to tusen"));
      expect(converter.convert(2468),
          equals("to tusen fire hundre og sekstiåtte"));
      expect(
          converter.convert(3579), equals("tre tusen fem hundre og syttini"));
      expect(converter.convert(10000), equals("ti tusen"));
      expect(converter.convert(10011), equals("ti tusen og elleve"));
      expect(converter.convert(11100), equals("elleve tusen ett hundre"));
      expect(
          converter.convert(12987), equals("tolv tusen ni hundre og åttisju"));
      expect(converter.convert(45623),
          equals("førtifem tusen seks hundre og tjuetre"));
      expect(converter.convert(87654),
          equals("åttisju tusen seks hundre og femtifire"));
      expect(converter.convert(100000), equals("ett hundre tusen"));
      expect(converter.convert(123456),
          equals("ett hundre og tjuetre tusen fire hundre og femtiseks"));
      expect(converter.convert(987654),
          equals("ni hundre og åttisju tusen seks hundre og femtifire"));
      expect(converter.convert(999999),
          equals("ni hundre og nittini tusen ni hundre og nittini"));
    });

    test('Negative Numbers', () {
      const negOption = NoOptions(negativePrefix: "negativ ");
      expect(converter.convert(-1), equals("minus en"));
      expect(converter.convert(-123), equals("minus ett hundre og tjuetre"));
      expect(converter.convert(-123.456),
          equals("minus ett hundre og tjuetre komma fire fem seks"));
      expect(converter.convert(-1, options: negOption), equals("negativ en"));
      expect(converter.convert(-123, options: negOption),
          equals("negativ ett hundre og tjuetre"));
      expect(converter.convert(-123.456, options: negOption),
          equals("negativ ett hundre og tjuetre komma fire fem seks"));
    });

    test('Decimals', () {
      const pointOption = NoOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = NoOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = NoOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(123.456),
          equals("ett hundre og tjuetre komma fire fem seks"));
      expect(converter.convert(1.5), equals("en komma fem"));
      expect(converter.convert(1.05), equals("en komma null fem"));
      expect(converter.convert(879.465),
          equals("åtte hundre og syttini komma fire seks fem"));
      expect(converter.convert(1.5, options: pointOption),
          equals("en punktum fem"));
      expect(
          converter.convert(1.5, options: commaOption), equals("en komma fem"));
      expect(converter.convert(1.5, options: periodOption),
          equals("en punktum fem"));
    });

    test('Year Formatting', () {
      const yearOption = NoOptions(format: Format.year);
      const yearOptionAD = NoOptions(format: Format.year, includeAD: true);
      expect(converter.convert(123, options: yearOption),
          equals("ett hundre og tjuetre"));
      expect(converter.convert(498, options: yearOption),
          equals("fire hundre og nittiåtte"));
      expect(converter.convert(756, options: yearOption),
          equals("sju hundre og femtiseks"));
      expect(converter.convert(1900, options: yearOption),
          equals("nitten hundre"));
      expect(converter.convert(1999, options: yearOption),
          equals("nitten hundre og nittini"));
      expect(converter.convert(2025, options: yearOption),
          equals("to tusen og tjuefem"));
      expect(converter.convert(1900, options: yearOptionAD),
          equals("nitten hundre e.Kr."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("nitten hundre og nittini e.Kr."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("to tusen og tjuefem e.Kr."));
      expect(converter.convert(-1, options: yearOption), equals("en f.Kr."));
      expect(converter.convert(-100, options: yearOption),
          equals("ett hundre f.Kr."));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("ett hundre f.Kr."));
      expect(converter.convert(-2025, options: yearOption),
          equals("to tusen og tjuefem f.Kr."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("en million f.Kr."));
    });

    test('Currency', () {
      const currencyOption = NoOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("null kroner"));
      expect(converter.convert(1, options: currencyOption), equals("en krone"));
      expect(
          converter.convert(5, options: currencyOption), equals("fem kroner"));
      expect(
          converter.convert(10, options: currencyOption), equals("ti kroner"));
      expect(converter.convert(11, options: currencyOption),
          equals("elleve kroner"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("en krone og femti øre"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("ett hundre og tjuetre kroner og førtifem øre"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("ti millioner kroner"));
      expect(converter.convert(0.5), equals('null komma fem'));
      expect(
          converter.convert(0.5, options: currencyOption), equals("femti øre"));
      expect(
          converter.convert(0.01, options: currencyOption), equals("ett øre"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("en krone og ett øre"));
      expect(converter.convert(2.50, options: currencyOption),
          equals("to kroner og femti øre"));
      expect(
          converter.convert(2, options: currencyOption), equals("to kroner"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("en million"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("to milliarder"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("tre billioner"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("fire billiarder"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("fem trillioner"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("seks trilliarder"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("sju kvadrillioner"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            "ni trillioner åtte hundre og syttiseks billiarder fem hundre og førtitre billioner to hundre og ti milliarder ett hundre og tjuetre millioner fire hundre og femtiseks tusen sju hundre og åttini"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "ett hundre og tjuetre trilliarder fire hundre og femtiseks trillioner sju hundre og åttini billiarder ett hundre og tjuetre billioner fire hundre og femtiseks milliarder sju hundre og åttini millioner ett hundre og tjuetre tusen fire hundre og femtiseks"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "ni hundre og nittini trilliarder ni hundre og nittini trillioner ni hundre og nittini billiarder ni hundre og nittini billioner ni hundre og nittini milliarder ni hundre og nittini millioner ni hundre og nittini tusen ni hundre og nittini"),
      );

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("en billion to millioner og tre"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("fem millioner og ett tusen"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("en milliard og en"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("en milliard og en million"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("to millioner og ett tusen"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "en billion ni hundre og åttisju millioner seks hundre tusen og tre"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Ikke Et Tall"));
      expect(converter.convert(double.infinity), equals("Uendelig"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negativ Uendelig"));
      expect(converter.convert(null), equals("Ikke Et Tall"));
      expect(converter.convert('abc'), equals("Ikke Et Tall"));
      expect(converter.convert([]), equals("Ikke Et Tall"));
      expect(converter.convert({}), equals("Ikke Et Tall"));
      expect(converter.convert(Object()), equals("Ikke Et Tall"));

      expect(
          converterWithFallback.convert(double.nan), equals("Ugyldig Nummer"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Uendelig"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negativ Uendelig"));
      expect(converterWithFallback.convert(null), equals("Ugyldig Nummer"));
      expect(converterWithFallback.convert('abc'), equals("Ugyldig Nummer"));
      expect(converterWithFallback.convert([]), equals("Ugyldig Nummer"));
      expect(converterWithFallback.convert({}), equals("Ugyldig Nummer"));
      expect(converterWithFallback.convert(Object()), equals("Ugyldig Nummer"));
      expect(
          converterWithFallback.convert(123), equals("ett hundre og tjuetre"));
    });
  });
}
