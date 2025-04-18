import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Italian (IT)', () {
    final converter = Num2Text(initialLang: Lang.IT);
    final converterWithFallback = Num2Text(
      initialLang: Lang.IT,
      fallbackOnError: "Numero non valido",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("zero"));
      expect(converter.convert(1), equals("uno"));
      expect(converter.convert(10), equals("dieci"));
      expect(converter.convert(11), equals("undici"));
      expect(converter.convert(20), equals("venti"));
      expect(converter.convert(21), equals("ventuno"));
      expect(converter.convert(99), equals("novantanove"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("cento"));
      expect(converter.convert(101), equals("centuno"));
      expect(converter.convert(111), equals("centoundici"));
      expect(converter.convert(200), equals("duecento"));
      expect(converter.convert(999), equals("novecentonovantanove"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("mille"));
      expect(converter.convert(1001), equals("milleuno"));
      expect(converter.convert(1111), equals("millecentoundici"));
      expect(converter.convert(2000), equals("duemila"));
      expect(converter.convert(10000), equals("diecimila"));
      expect(converter.convert(100000), equals("centomila"));
      expect(converter.convert(123456),
          equals("centoventitremilaquattrocentocinquantasei"));
      expect(converter.convert(999999),
          equals("novecentonovantanovemilanovecentonovantanove"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("meno uno"));
      expect(converter.convert(-123), equals("meno centoventitre"));
      expect(
        converter.convert(-1, options: ItOptions(negativePrefix: "negativo")),
        equals("negativo uno"),
      );
      expect(
        converter.convert(-123, options: ItOptions(negativePrefix: "negativo")),
        equals("negativo centoventitre"),
      );
    });

    test('Year Formatting', () {
      const yearOption = ItOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("millenovecento"));
      expect(converter.convert(2024, options: yearOption),
          equals("duemilaventiquattro"));
      expect(
        converter.convert(1900, options: ItOptions(format: Format.year)),
        equals("millenovecento"),
      );
      expect(
        converter.convert(2024, options: ItOptions(format: Format.year)),
        equals("duemilaventiquattro"),
      );
      expect(
          converter.convert(-100, options: yearOption), equals("meno cento"));
      expect(converter.convert(-1, options: yearOption), equals("meno uno"));
      expect(
        converter.convert(-2024, options: ItOptions(format: Format.year)),
        equals("meno duemilaventiquattro"),
      );
    });

    test('Currency', () {
      const currencyOption = ItOptions(currency: true);
      expect(converter.convert(1.01, options: currencyOption),
          equals("un euro e un centesimo"));
      expect(
        converter.convert(2.50, options: currencyOption),
        equals("due euro e cinquanta centesimi"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("centoventitre euro e quarantacinque centesimi"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("centoventitre virgola quattro cinque sei"),
      );
      expect(converter.convert(Decimal.parse('1.50')),
          equals("uno virgola cinque"));
      expect(converter.convert(123.0), equals("centoventitre"));
      expect(
          converter.convert(Decimal.parse('123.0')), equals("centoventitre"));
      expect(
        converter.convert(1.5,
            options: const ItOptions(decimalSeparator: DecimalSeparator.point)),
        equals("uno punto cinque"),
      );
      expect(
        converter.convert(1.5,
            options: const ItOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("uno virgola cinque"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Infinito"));
      expect(converter.convert(double.negativeInfinity),
          equals("Infinito negativo"));
      expect(converter.convert(double.nan), equals("Non un numero"));
      expect(converter.convert(null), equals("Non un numero"));
      expect(converter.convert('abc'), equals("Non un numero"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Infinito"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Infinito negativo"));
      expect(converterWithFallback.convert(double.nan),
          equals("Numero non valido"));
      expect(converterWithFallback.convert(null), equals("Numero non valido"));
      expect(converterWithFallback.convert('abc'), equals("Numero non valido"));
      expect(converterWithFallback.convert(123), equals("centoventitre"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("un milione"));
      expect(converter.convert(BigInt.from(1000000000)), equals("un miliardo"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("un milione di milioni"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("un milione di miliardi"));
      expect(
        converter.convert(BigInt.from(1000000000000000000)),
        equals("un milione di milioni di milioni"),
      );
      expect(
        converter.convert(BigInt.parse('1000000000000000000000')),
        equals("un milione di milioni di miliardi"),
      );
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("un milione di milioni di milioni di milioni"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "centoventitremilioni di milioni di miliardiquattrocentocinquantaseimilioni di milioni di milionisettecentoottantanovemilioni di miliardicentoventitremilioni di milioniquattrocentocinquantaseimiliardisettecentoottantanovemilionicentoventitremilaquattrocentocinquantasei",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "novecentonovantanovemilioni di milioni di miliardinovecentonovantanovemilioni di milioni di milioninovecentonovantanovemilioni di miliardinovecentonovantanovemilioni di milioninovecentonovantanovemiliardinovecentonovantanovemilioninovecentonovantanovemilanovecentonovantanove",
        ),
      );
    });
  });
}
