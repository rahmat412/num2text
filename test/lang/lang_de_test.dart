import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text German (DE)', () {
    final converter = Num2Text(initialLang: Lang.DE);
    final converterWithFallback =
        Num2Text(initialLang: Lang.DE, fallbackOnError: "Ungültige Zahl");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("null"));
      expect(converter.convert(1), equals("eins"));
      expect(converter.convert(10), equals("zehn"));
      expect(converter.convert(11), equals("elf"));
      expect(converter.convert(20), equals("zwanzig"));
      expect(converter.convert(21), equals("einundzwanzig"));
      expect(converter.convert(99), equals("neunundneunzig"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("einhundert"));
      expect(converter.convert(101), equals("einhunderteins"));
      expect(converter.convert(111), equals("einhundertelf"));
      expect(converter.convert(200), equals("zweihundert"));
      expect(converter.convert(999), equals("neunhundertneunundneunzig"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("eintausend"));
      expect(converter.convert(1001), equals("eintausendeins"));
      expect(converter.convert(1111), equals("eintausendeinhundertelf"));
      expect(converter.convert(2000), equals("zweitausend"));
      expect(converter.convert(10000), equals("zehntausend"));
      expect(converter.convert(100000), equals("einhunderttausend"));
      expect(
        converter.convert(123456),
        equals("einhundertdreiundzwanzigtausendvierhundertsechsundfünfzig"),
      );
      expect(
        converter.convert(999999),
        equals("neunhundertneunundneunzigtausendneunhundertneunundneunzig"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus eins"));
      expect(converter.convert(-123), equals("minus einhundertdreiundzwanzig"));
      expect(
        converter.convert(-1, options: DeOptions(negativePrefix: "negativ")),
        equals("negativ eins"),
      );
      expect(
        converter.convert(-123, options: DeOptions(negativePrefix: "negativ")),
        equals("negativ einhundertdreiundzwanzig"),
      );
    });

    test('Year Formatting', () {
      const yearOption = DeOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("neunzehnhundert"));
      expect(converter.convert(2024, options: yearOption),
          equals("zweitausendvierundzwanzig"));
      expect(
        converter.convert(1900,
            options: DeOptions(format: Format.year, includeAD: true)),
        equals("neunzehnhundert n. Chr."),
      );
      expect(
        converter.convert(2024,
            options: DeOptions(format: Format.year, includeAD: true)),
        equals("zweitausendvierundzwanzig n. Chr."),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("einhundert v. Chr."));
      expect(
          converter.convert(-1, options: yearOption), equals("eins v. Chr."));
      expect(
        converter.convert(-2024,
            options: DeOptions(format: Format.year, includeAD: true)),
        equals("zweitausendvierundzwanzig v. Chr."),
      );
    });

    test('Currency', () {
      const currencyOption = DeOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("null Euro"));
      expect(converter.convert(1, options: currencyOption), equals("ein Euro"));
      expect(
          converter.convert(2, options: currencyOption), equals("zwei Euro"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("ein Euro und fünfzig Cent"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("einhundertdreiundzwanzig Euro und fünfundvierzig Cent"),
      );
      expect(converter.convert(0.99, options: currencyOption),
          equals("neunundneunzig Cent"));
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("einhundertdreiundzwanzig Komma vier fünf sechs"),
      );
      expect(
          converter.convert(Decimal.parse('1.50')), equals("eins Komma fünf"));
      expect(converter.convert(Decimal.parse('1.05')),
          equals("eins Komma null fünf"));
      expect(converter.convert(123.0), equals("einhundertdreiundzwanzig"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("einhundertdreiundzwanzig"));
      expect(
        converter.convert(1.5,
            options: const DeOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("eins Komma fünf"),
      );
      expect(
        converter.convert(1.5,
            options:
                const DeOptions(decimalSeparator: DecimalSeparator.period)),
        equals("eins Punkt fünf"),
      );
      expect(
        converter.convert(1.5,
            options: const DeOptions(decimalSeparator: DecimalSeparator.point)),
        equals("eins Punkt fünf"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Unendlich"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negativ Unendlich"));
      expect(converter.convert(double.nan), equals("Keine Zahl"));
      expect(converter.convert(null), equals("Keine Zahl"));
      expect(converter.convert('abc'), equals("Keine Zahl"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Unendlich"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negativ Unendlich"));
      expect(
          converterWithFallback.convert(double.nan), equals("Ungültige Zahl"));
      expect(converterWithFallback.convert(null), equals("Ungültige Zahl"));
      expect(converterWithFallback.convert('abc'), equals("Ungültige Zahl"));
      expect(converterWithFallback.convert(123),
          equals("einhundertdreiundzwanzig"));
    });

    test('Scale Numbers (Long Scale)', () {
      expect(converter.convert(BigInt.from(1000000)), equals("eine Million"));
      expect(
          converter.convert(BigInt.from(1000000000)), equals("eine Milliarde"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("eine Billion"));
      expect(converter.convert(BigInt.parse('1000000000000000')),
          equals("eine Billiarde"));
      expect(converter.convert(BigInt.parse('1000000000000000000')),
          equals("eine Trillion"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("eine Trilliarde"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("eine Quadrillion"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "einhundertdreiundzwanzig Trilliarden vierhundertsechsundfünfzig Trillionen siebenhundertneunundachtzig Billiarden einhundertdreiundzwanzig Billionen vierhundertsechsundfünfzig Milliarden siebenhundertneunundachtzig Millionen einhundertdreiundzwanzigtausendvierhundertsechsundfünfzig",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "neunhundertneunundneunzig Trilliarden neunhundertneunundneunzig Trillionen neunhundertneunundneunzig Billiarden neunhundertneunundneunzig Billionen neunhundertneunundneunzig Milliarden neunhundertneunundneunzig Millionen neunhundertneunundneunzigtausendneunhundertneunundneunzig",
        ),
      );
    });
  });
}
