import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Danish (DA)', () {
    final converter = Num2Text(initialLang: Lang.DA);

    final converterWithFallback =
        Num2Text(initialLang: Lang.DA, fallbackOnError: "Ugyldigt Nummer");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("nul"));
      expect(converter.convert(10), equals("ti"));
      expect(converter.convert(11), equals("elleve"));
      expect(converter.convert(13), equals("tretten"));
      expect(converter.convert(15), equals("femten"));
      expect(converter.convert(20), equals("tyve"));
      expect(converter.convert(27), equals("syvogtyve"));
      expect(converter.convert(30), equals("tredive"));
      expect(converter.convert(54), equals("fireoghalvtreds"));
      expect(converter.convert(68), equals("otteogtres"));
      expect(converter.convert(99), equals("nioghalvfems"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("et hundrede"));
      expect(converter.convert(101), equals("et hundrede og et"));
      expect(converter.convert(105), equals("et hundrede og fem"));
      expect(converter.convert(110), equals("et hundrede og ti"));
      expect(converter.convert(111), equals("et hundrede og elleve"));
      expect(converter.convert(123), equals("et hundrede og treogtyve"));
      expect(converter.convert(200), equals("to hundrede"));
      expect(converter.convert(321), equals("tre hundrede og enogtyve"));
      expect(converter.convert(479), equals("fire hundrede og nioghalvfjerds"));
      expect(converter.convert(596), equals("fem hundrede og seksoghalvfems"));
      expect(converter.convert(681), equals("seks hundrede og enogfirs"));
      expect(converter.convert(999), equals("ni hundrede og nioghalvfems"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("et tusind"));
      expect(converter.convert(1001), equals("et tusind og et"));
      expect(converter.convert(1011), equals("et tusind og elleve"));
      expect(converter.convert(1110), equals("et tusind et hundrede og ti"));
      expect(
          converter.convert(1111), equals("et tusind et hundrede og elleve"));
      expect(converter.convert(2000), equals("to tusind"));
      expect(converter.convert(2468),
          equals("to tusind fire hundrede og otteogtres"));
      expect(converter.convert(3579),
          equals("tre tusind fem hundrede og nioghalvfjerds"));
      expect(converter.convert(10000), equals("ti tusind"));
      expect(converter.convert(10011), equals("ti tusind og elleve"));
      expect(converter.convert(11100), equals("elleve tusind et hundrede"));
      expect(converter.convert(12987),
          equals("tolv tusind ni hundrede og syvogfirs"));
      expect(converter.convert(45623),
          equals("femogfyrre tusind seks hundrede og treogtyve"));
      expect(converter.convert(87654),
          equals("syvogfirs tusind seks hundrede og fireoghalvtreds"));
      expect(converter.convert(100000), equals("et hundrede tusind"));
      expect(
          converter.convert(123456),
          equals(
              "et hundrede og treogtyve tusind fire hundrede og seksoghalvtreds"));
      expect(
          converter.convert(987654),
          equals(
              "ni hundrede og syvogfirs tusind seks hundrede og fireoghalvtreds"));
      expect(
          converter.convert(999999),
          equals(
              "ni hundrede og nioghalvfems tusind ni hundrede og nioghalvfems"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus et"));
      expect(converter.convert(-123), equals("minus et hundrede og treogtyve"));
      expect(converter.convert(-123.456),
          equals("minus et hundrede og treogtyve komma fire fem seks"));

      const negativeOptions = DaOptions(negativePrefix: "negativ");

      expect(converter.convert(-1, options: negativeOptions),
          equals("negativ et"));
      expect(converter.convert(-123, options: negativeOptions),
          equals("negativ et hundrede og treogtyve"));
      expect(converter.convert(-123.456, options: negativeOptions),
          equals("negativ et hundrede og treogtyve komma fire fem seks"));
    });

    test('Decimals', () {
      const pointOption = DaOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = DaOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = DaOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(123.456),
          equals("et hundrede og treogtyve komma fire fem seks"));
      expect(converter.convert(1.5), equals("et komma fem"));
      expect(converter.convert(1.05), equals("et komma nul fem"));
      expect(converter.convert(879.465),
          equals("otte hundrede og nioghalvfjerds komma fire seks fem"));
      expect(converter.convert(1.5), equals("et komma fem"));

      expect(converter.convert(1.5, options: pointOption),
          equals("et punktum fem"));
      expect(
          converter.convert(1.5, options: commaOption), equals("et komma fem"));
      expect(converter.convert(1.5, options: periodOption),
          equals("et punktum fem"));
    });

    test('Year Formatting', () {
      const yearOption = DaOptions(format: Format.year);
      const yearOptionAD = DaOptions(format: Format.year, includeAD: true);

      expect(converter.convert(123, options: yearOption),
          equals("et hundrede og treogtyve"));
      expect(converter.convert(498, options: yearOption),
          equals("fire hundrede og otteoghalvfems"));
      expect(converter.convert(756, options: yearOption),
          equals("syv hundrede og seksoghalvtreds"));
      expect(converter.convert(1900, options: yearOption),
          equals("nitten hundrede"));
      expect(converter.convert(1999, options: yearOption),
          equals("nitten hundrede og nioghalvfems"));
      expect(converter.convert(2025, options: yearOption),
          equals("to tusind og femogtyve"));

      expect(converter.convert(1900, options: yearOptionAD),
          equals("nitten hundrede e.Kr."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("nitten hundrede og nioghalvfems e.Kr."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("to tusind og femogtyve e.Kr."));

      expect(converter.convert(-1, options: yearOption), equals("et f.Kr."));
      expect(converter.convert(-100, options: yearOption),
          equals("et hundrede f.Kr."));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("et hundrede f.Kr."));
      expect(converter.convert(-2025, options: yearOption),
          equals("to tusind og femogtyve f.Kr."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("en million f.Kr."));
    });

    test('Currency', () {
      const currencyOption = DaOptions(currency: true);

      expect(
          converter.convert(0, options: currencyOption), equals("nul kroner"));
      expect(converter.convert(1, options: currencyOption), equals("en krone"));
      expect(
          converter.convert(2, options: currencyOption), equals("to kroner"));
      expect(
          converter.convert(5, options: currencyOption), equals("fem kroner"));
      expect(
          converter.convert(10, options: currencyOption), equals("ti kroner"));
      expect(converter.convert(11, options: currencyOption),
          equals("elleve kroner"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("en krone og halvtreds øre"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("et hundrede og treogtyve kroner og femogfyrre øre"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("ti millioner kroner"));
      expect(converter.convert(0.5), equals("nul komma fem"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("halvtreds øre"));
      expect(
          converter.convert(0.01, options: currencyOption), equals("et øre"));
      expect(
          converter.convert(0.05, options: currencyOption), equals("fem øre"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("en krone og et øre"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("to kroner og to øre"));
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
          equals("syv kvadrillioner"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              'ni trillioner otte hundrede og seksoghalvfjerds billiarder fem hundrede og treogfyrre billioner to hundrede og ti milliarder et hundrede og treogtyve millioner fire hundrede og seksoghalvtreds tusind syv hundrede og niogfirs'));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "et hundrede og treogtyve trilliarder fire hundrede og seksoghalvtreds trillioner syv hundrede og niogfirs billiarder et hundrede og treogtyve billioner fire hundrede og seksoghalvtreds milliarder syv hundrede og niogfirs millioner et hundrede og treogtyve tusind fire hundrede og seksoghalvtreds"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "ni hundrede og nioghalvfems trilliarder ni hundrede og nioghalvfems trillioner ni hundrede og nioghalvfems billiarder ni hundrede og nioghalvfems billioner ni hundrede og nioghalvfems milliarder ni hundrede og nioghalvfems millioner ni hundrede og nioghalvfems tusind ni hundrede og nioghalvfems"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('en billion to millioner og tre'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("fem millioner et tusind"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("en milliard og et"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("en milliard en million"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("to millioner et tusind"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              'en billion ni hundrede og syvogfirs millioner seks hundrede tusind og tre'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Ikke Et Tal"));
      expect(converter.convert(double.infinity), equals("Uendelig"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negativ Uendelig"));
      expect(converter.convert(null), equals("Ikke Et Tal"));
      expect(converter.convert('abc'), equals("Ikke Et Tal"));
      expect(converter.convert([]), equals("Ikke Et Tal"));
      expect(converter.convert({}), equals("Ikke Et Tal"));
      expect(converter.convert(Object()), equals("Ikke Et Tal"));

      expect(
          converterWithFallback.convert(double.nan), equals("Ugyldigt Nummer"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Uendelig"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negativ Uendelig"));
      expect(converterWithFallback.convert(null), equals("Ugyldigt Nummer"));
      expect(converterWithFallback.convert('abc'), equals("Ugyldigt Nummer"));
      expect(converterWithFallback.convert([]), equals("Ugyldigt Nummer"));
      expect(converterWithFallback.convert({}), equals("Ugyldigt Nummer"));
      expect(
          converterWithFallback.convert(Object()), equals("Ugyldigt Nummer"));
      expect(converterWithFallback.convert(123),
          equals("et hundrede og treogtyve"));
    });
  });
}
