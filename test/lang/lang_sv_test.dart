import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Swedish (SV)', () {
    final converter = Num2Text(initialLang: Lang.SV);
    final converterWithFallback = Num2Text(
      initialLang: Lang.SV,
      fallbackOnError: "Ogiltigt Nummer",
    );

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("noll"));
      expect(converter.convert(1), equals("ett"));
      expect(converter.convert(2), equals("två"));
      expect(converter.convert(3), equals("tre"));
      expect(converter.convert(4), equals("fyra"));
      expect(converter.convert(5), equals("fem"));
      expect(converter.convert(9), equals("nio"));
      expect(converter.convert(10), equals("tio"));
      expect(converter.convert(11), equals("elva"));
      expect(converter.convert(12), equals("tolv"));
      expect(converter.convert(13), equals("tretton"));
      expect(converter.convert(14), equals("fjorton"));
      expect(converter.convert(15), equals("femton"));
      expect(converter.convert(19), equals("nitton"));
      expect(converter.convert(20), equals("tjugo"));
      expect(converter.convert(21), equals("tjugoett"));
      expect(converter.convert(22), equals("tjugotvå"));
      expect(converter.convert(23), equals("tjugotre"));
      expect(converter.convert(24), equals("tjugofyra"));
      expect(converter.convert(25), equals("tjugofem"));
      expect(converter.convert(27), equals("tjugosju"));
      expect(converter.convert(30), equals("trettio"));
      expect(converter.convert(54), equals("femtiofyra"));
      expect(converter.convert(68), equals("sextioåtta"));
      expect(converter.convert(99), equals("nittionio"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("etthundra"));
      expect(converter.convert(101), equals("etthundraett"));
      expect(converter.convert(105), equals("etthundrafem"));
      expect(converter.convert(110), equals("etthundratio"));
      expect(converter.convert(111), equals("etthundraelva"));
      expect(converter.convert(123), equals("etthundratjugotre"));
      expect(converter.convert(200), equals("tvåhundra"));
      expect(converter.convert(321), equals("trehundratjugoett"));
      expect(converter.convert(479), equals("fyrahundrasjuttionio"));
      expect(converter.convert(596), equals("femhundranittiosex"));
      expect(converter.convert(681), equals("sexhundraåttioett"));
      expect(converter.convert(999), equals("niohundranittionio"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("ettusen"));
      expect(converter.convert(1001), equals("ettusen ett"));
      expect(converter.convert(1011), equals("ettusen elva"));
      expect(converter.convert(1110), equals("ettusen etthundratio"));
      expect(converter.convert(1111), equals("ettusen etthundraelva"));
      expect(converter.convert(2000), equals("två tusen"));
      expect(converter.convert(2468), equals("två tusen fyrahundrasextioåtta"));
      expect(converter.convert(3579), equals("tre tusen femhundrasjuttionio"));
      expect(converter.convert(10000), equals("tiotusen"));
      expect(converter.convert(10011), equals("tiotusen elva"));
      expect(converter.convert(11100), equals("elvatusen etthundra"));
      expect(converter.convert(12987), equals("tolvtusen niohundraåttiosju"));
      expect(
          converter.convert(45623), equals("fyrtiofemtusen sexhundratjugotre"));
      expect(converter.convert(87654),
          equals("åttiosjutusen sexhundrafemtiofyra"));
      expect(converter.convert(100000), equals("etthundratusen"));
      expect(converter.convert(123456),
          equals("etthundratjugotretusen fyrahundrafemtiosex"));
      expect(converter.convert(987654),
          equals("niohundraåttiosjutusen sexhundrafemtiofyra"));
      expect(converter.convert(999999),
          equals("niohundranittioniotusen niohundranittionio"));
    });

    test('Negative Numbers', () {
      const negativeOption = SvOptions(negativePrefix: "negativ");

      expect(converter.convert(-1), equals("minus ett"));
      expect(converter.convert(-123), equals("minus etthundratjugotre"));
      expect(converter.convert(-123.456),
          equals("minus etthundratjugotre komma fyra fem sex"));
      expect(converter.convert(-1, options: negativeOption),
          equals("negativ ett"));
      expect(converter.convert(-123, options: negativeOption),
          equals("negativ etthundratjugotre"));
      expect(converter.convert(-123.456, options: negativeOption),
          equals("negativ etthundratjugotre komma fyra fem sex"));
    });

    test('Decimals', () {
      const pointOption = SvOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = SvOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = SvOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(123.456),
          equals("etthundratjugotre komma fyra fem sex"));
      expect(converter.convert(1.50), equals("ett komma fem"));
      expect(converter.convert(1.05), equals("ett komma noll fem"));
      expect(converter.convert(879.465),
          equals("åttahundrasjuttionio komma fyra sex fem"));
      expect(converter.convert(1.5), equals("ett komma fem"));
      expect(converter.convert(1.5, options: pointOption),
          equals("ett punkt fem"));
      expect(converter.convert(1.5, options: commaOption),
          equals("ett komma fem"));
      expect(converter.convert(1.5, options: periodOption),
          equals("ett punkt fem"));
    });

    test('Year Formatting', () {
      const yearOption = SvOptions(format: Format.year);
      const yearOptionAD = SvOptions(format: Format.year, includeAD: true);

      expect(converter.convert(123, options: yearOption),
          equals("etthundratjugotre"));
      expect(converter.convert(498, options: yearOption),
          equals("fyrahundranittioåtta"));
      expect(converter.convert(756, options: yearOption),
          equals("sjuhundrafemtiosex"));
      expect(
          converter.convert(1900, options: yearOption), equals("nittonhundra"));
      expect(converter.convert(1999, options: yearOption),
          equals("nittonhundranittionio"));
      expect(converter.convert(2025, options: yearOption),
          equals("tjugohundratjugofem"));
      expect(converter.convert(1900, options: yearOptionAD),
          equals("nittonhundra e.Kr."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("nittonhundranittionio e.Kr."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("tjugohundratjugofem e.Kr."));
      expect(converter.convert(-1, options: yearOption), equals("ett f.Kr."));
      expect(converter.convert(-100, options: yearOption),
          equals("etthundra f.Kr."));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("etthundra f.Kr."));
      expect(converter.convert(-2025, options: yearOption),
          equals("tjugohundratjugofem f.Kr."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("en miljon f.Kr."));
    });

    test('Currency', () {
      const currencyOption = SvOptions(currency: true);

      expect(
          converter.convert(0, options: currencyOption), equals("noll kronor"));
      expect(converter.convert(1, options: currencyOption), equals("en krona"));
      expect(
          converter.convert(2, options: currencyOption), equals("två kronor"));
      expect(
          converter.convert(5, options: currencyOption), equals("fem kronor"));
      expect(
          converter.convert(10, options: currencyOption), equals("tio kronor"));
      expect(converter.convert(11, options: currencyOption),
          equals("elva kronor"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("en krona och femtio öre"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("etthundratjugotre kronor och fyrtiofem öre"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("tio miljoner kronor"));
      expect(converter.convert(0.50, options: currencyOption),
          equals("femtio öre"));
      expect(converter.convert(0.01), equals("noll komma noll ett"));
      expect(
          converter.convert(0.01, options: currencyOption), equals("ett öre"));
      expect(
          converter.convert(0.02, options: currencyOption), equals("två öre"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("en krona och ett öre"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("två kronor och två öre"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("en miljon"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("två miljarder"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("tre biljoner"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("fyra biljarder"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("fem triljoner"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("sex triljarder"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("sju kvadriljoner"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "nio triljoner åttahundrasjuttiosex biljarder femhundrafyrtiotre biljoner tvåhundratio miljarder etthundratjugotre miljoner fyrahundrafemtiosextusen sjuhundraåttionio"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "etthundratjugotre triljarder fyrahundrafemtiosex triljoner sjuhundraåttionio biljarder etthundratjugotre biljoner fyrahundrafemtiosex miljarder sjuhundraåttionio miljoner etthundratjugotretusen fyrahundrafemtiosex"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "niohundranittionio triljarder niohundranittionio triljoner niohundranittionio biljarder niohundranittionio biljoner niohundranittionio miljarder niohundranittionio miljoner niohundranittioniotusen niohundranittionio"));

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('en biljon två miljoner tre'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("fem miljoner ettusen"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("en miljard ett"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("en miljard en miljon"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("två miljoner ettusen"));
      expect(converter.convert(BigInt.parse('1000987600003')),
          equals("en biljon niohundraåttiosju miljoner sexhundratusen tre"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Inte Ett Nummer"));
      expect(converter.convert(double.infinity), equals("Oändlighet"));
      expect(converter.convert(double.negativeInfinity),
          equals("Minus Oändlighet"));
      expect(converter.convert(null), equals("Inte Ett Nummer"));
      expect(converter.convert('abc'), equals("Inte Ett Nummer"));
      expect(converter.convert([]), equals("Inte Ett Nummer"));
      expect(converter.convert({}), equals("Inte Ett Nummer"));
      expect(converter.convert(Object()), equals("Inte Ett Nummer"));

      expect(
          converterWithFallback.convert(double.nan), equals("Ogiltigt Nummer"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Oändlighet"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Minus Oändlighet"));
      expect(converterWithFallback.convert(null), equals("Ogiltigt Nummer"));
      expect(converterWithFallback.convert('abc'), equals("Ogiltigt Nummer"));
      expect(converterWithFallback.convert([]), equals("Ogiltigt Nummer"));
      expect(converterWithFallback.convert({}), equals("Ogiltigt Nummer"));
      expect(
          converterWithFallback.convert(Object()), equals("Ogiltigt Nummer"));
      expect(converterWithFallback.convert(123), equals("etthundratjugotre"));
    });
  });
}
