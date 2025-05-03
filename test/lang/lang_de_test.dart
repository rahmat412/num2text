import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text German (DE)', () {
    final converter = Num2Text(initialLang: Lang.DE);
    final converterWithFallback =
        Num2Text(initialLang: Lang.DE, fallbackOnError: "Ungültige Zahl");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("null"));
      expect(converter.convert(10), equals("zehn"));
      expect(converter.convert(11), equals("elf"));
      expect(converter.convert(13), equals("dreizehn"));
      expect(converter.convert(15), equals("fünfzehn"));
      expect(converter.convert(20), equals("zwanzig"));
      expect(converter.convert(27), equals("siebenundzwanzig"));
      expect(converter.convert(30), equals("dreißig"));
      expect(converter.convert(54), equals("vierundfünfzig"));
      expect(converter.convert(68), equals("achtundsechzig"));
      expect(converter.convert(99), equals("neunundneunzig"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("einhundert"));
      expect(converter.convert(101), equals("einhunderteins"));
      expect(converter.convert(105), equals("einhundertfünf"));
      expect(converter.convert(110), equals("einhundertzehn"));
      expect(converter.convert(111), equals("einhundertelf"));
      expect(converter.convert(123), equals("einhundertdreiundzwanzig"));
      expect(converter.convert(200), equals("zweihundert"));
      expect(converter.convert(321), equals("dreihunderteinundzwanzig"));
      expect(converter.convert(479), equals("vierhundertneunundsiebzig"));
      expect(converter.convert(596), equals("fünfhundertsechsundneunzig"));
      expect(converter.convert(681), equals("sechshunderteinundachtzig"));
      expect(converter.convert(999), equals("neunhundertneunundneunzig"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("eintausend"));
      expect(converter.convert(1001), equals("eintausendeins"));
      expect(converter.convert(1011), equals("eintausendelf"));
      expect(converter.convert(1110), equals("eintausendeinhundertzehn"));
      expect(converter.convert(1111), equals("eintausendeinhundertelf"));
      expect(converter.convert(2000), equals("zweitausend"));
      expect(converter.convert(2468),
          equals("zweitausendvierhundertachtundsechzig"));
      expect(converter.convert(3579),
          equals("dreitausendfünfhundertneunundsiebzig"));
      expect(converter.convert(10000), equals("zehntausend"));
      expect(converter.convert(10011), equals("zehntausendelf"));
      expect(converter.convert(11100), equals("elftausendeinhundert"));
      expect(converter.convert(12987),
          equals("zwölftausendneunhundertsiebenundachtzig"));
      expect(converter.convert(45623),
          equals("fünfundvierzigtausendsechshundertdreiundzwanzig"));
      expect(converter.convert(87654),
          equals("siebenundachtzigtausendsechshundertvierundfünfzig"));
      expect(converter.convert(100000), equals("einhunderttausend"));
      expect(converter.convert(123456),
          equals("einhundertdreiundzwanzigtausendvierhundertsechsundfünfzig"));
      expect(
          converter.convert(987654),
          equals(
              "neunhundertsiebenundachtzigtausendsechshundertvierundfünfzig"));
      expect(converter.convert(999999),
          equals("neunhundertneunundneunzigtausendneunhundertneunundneunzig"));
    });

    test('Negative Numbers', () {
      const negativePrefixOption = DeOptions(negativePrefix: "negativ");

      expect(converter.convert(-1), equals("minus eins"));
      expect(converter.convert(-123), equals("minus einhundertdreiundzwanzig"));
      expect(converter.convert(-123.456),
          equals("minus einhundertdreiundzwanzig Komma vier fünf sechs"));

      expect(converter.convert(-1, options: negativePrefixOption),
          equals("negativ eins"));
      expect(converter.convert(-123, options: negativePrefixOption),
          equals("negativ einhundertdreiundzwanzig"));
      expect(converter.convert(-123.456, options: negativePrefixOption),
          equals("negativ einhundertdreiundzwanzig Komma vier fünf sechs"));
    });

    test('Decimals', () {
      const pointOption = DeOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = DeOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = DeOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(123.456),
          equals("einhundertdreiundzwanzig Komma vier fünf sechs"));
      expect(converter.convert(1.5), equals("eins Komma fünf"));
      expect(converter.convert(1.05), equals("eins Komma null fünf"));
      expect(converter.convert(879.465),
          equals("achthundertneunundsiebzig Komma vier sechs fünf"));
      expect(converter.convert(1.5), equals("eins Komma fünf"));

      expect(converter.convert(1.5, options: pointOption),
          equals("eins Punkt fünf"));
      expect(converter.convert(1.5, options: commaOption),
          equals("eins Komma fünf"));
      expect(converter.convert(1.5, options: periodOption),
          equals("eins Punkt fünf"));
    });

    test('Year Formatting', () {
      const yearOption = DeOptions(format: Format.year);
      const yearOptionAD = DeOptions(format: Format.year, includeAD: true);

      expect(converter.convert(123, options: yearOption),
          equals("einhundertdreiundzwanzig"));
      expect(converter.convert(498, options: yearOption),
          equals("vierhundertachtundneunzig"));
      expect(converter.convert(756, options: yearOption),
          equals("siebenhundertsechsundfünfzig"));
      expect(converter.convert(1900, options: yearOption),
          equals("neunzehnhundert"));
      expect(converter.convert(1999, options: yearOption),
          equals("neunzehnhundertneunundneunzig"));
      expect(converter.convert(2025, options: yearOption),
          equals("zweitausendfünfundzwanzig"));

      expect(converter.convert(1900, options: yearOptionAD),
          equals("neunzehnhundert n. Chr."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("neunzehnhundertneunundneunzig n. Chr."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("zweitausendfünfundzwanzig n. Chr."));
      expect(
          converter.convert(-1, options: yearOption), equals("eins v. Chr."));
      expect(converter.convert(-100, options: yearOption),
          equals("einhundert v. Chr."));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("einhundert v. Chr."));
      expect(converter.convert(-2025, options: yearOption),
          equals("zweitausendfünfundzwanzig v. Chr."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("eine Million v. Chr."));
    });

    test('Currency', () {
      const currencyOption = DeOptions(currency: true);

      expect(
          converter.convert(0, options: currencyOption), equals("null Euro"));
      expect(converter.convert(1, options: currencyOption), equals("ein Euro"));
      expect(
          converter.convert(2, options: currencyOption), equals("zwei Euro"));
      expect(
          converter.convert(5, options: currencyOption), equals("fünf Euro"));
      expect(
          converter.convert(10, options: currencyOption), equals("zehn Euro"));
      expect(
          converter.convert(11, options: currencyOption), equals("elf Euro"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("ein Euro und fünfzig Cent"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("einhundertdreiundzwanzig Euro und fünfundvierzig Cent"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("zehn Millionen Euro"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("fünfzig Cent"));
      expect(
          converter.convert(0.01, options: currencyOption), equals("ein Cent"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("fünf Cent"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("ein Euro und ein Cent"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("zwei Euro und zwei Cent"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("eine Million"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("zwei Milliarden"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("drei Billionen"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("vier Billiarden"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("fünf Trillionen"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("sechs Trilliarden"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("sieben Quadrillionen"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "neun Trillionen achthundertsechsundsiebzig Billiarden fünfhundertdreiundvierzig Billionen zweihundertzehn Milliarden einhundertdreiundzwanzig Millionen vierhundertsechsundfünfzigtausendsiebenhundertneunundachtzig"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "einhundertdreiundzwanzig Trilliarden vierhundertsechsundfünfzig Trillionen siebenhundertneunundachtzig Billiarden einhundertdreiundzwanzig Billionen vierhundertsechsundfünfzig Milliarden siebenhundertneunundachtzig Millionen einhundertdreiundzwanzigtausendvierhundertsechsundfünfzig"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "neunhundertneunundneunzig Trilliarden neunhundertneunundneunzig Trillionen neunhundertneunundneunzig Billiarden neunhundertneunundneunzig Billionen neunhundertneunundneunzig Milliarden neunhundertneunundneunzig Millionen neunhundertneunundneunzigtausendneunhundertneunundneunzig"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("eine Billion zwei Millionen drei"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("fünf Millionen eintausend"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("eine Milliarde eins"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("eine Milliarde eine Million"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("zwei Millionen eintausend"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              'eine Billion neunhundertsiebenundachtzig Millionen sechshunderttausenddrei'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Keine Zahl"));
      expect(converter.convert(double.infinity), equals("Unendlich"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negativ Unendlich"));
      expect(converter.convert(null), equals("Keine Zahl"));
      expect(converter.convert('abc'), equals("Keine Zahl"));
      expect(converter.convert([]), equals("Keine Zahl"));
      expect(converter.convert({}), equals("Keine Zahl"));
      expect(converter.convert(Object()), equals("Keine Zahl"));

      expect(
          converterWithFallback.convert(double.nan), equals("Ungültige Zahl"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Unendlich"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negativ Unendlich"));
      expect(converterWithFallback.convert(null), equals("Ungültige Zahl"));
      expect(converterWithFallback.convert('abc'), equals("Ungültige Zahl"));
      expect(converterWithFallback.convert([]), equals("Ungültige Zahl"));
      expect(converterWithFallback.convert({}), equals("Ungültige Zahl"));
      expect(converterWithFallback.convert(Object()), equals("Ungültige Zahl"));
      expect(converterWithFallback.convert(123),
          equals("einhundertdreiundzwanzig"));
    });
  });
}
