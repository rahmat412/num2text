import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Azerbaijani (AZ)', () {
    final converter = Num2Text(initialLang: Lang.AZ);
    final converterWithFallback =
        Num2Text(initialLang: Lang.AZ, fallbackOnError: "Yanlış Dəyər");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("sıfır"));
      expect(converter.convert(1), equals("bir"));
      expect(converter.convert(10), equals("on"));
      expect(converter.convert(11), equals("on bir"));
      expect(converter.convert(20), equals("iyirmi"));
      expect(converter.convert(21), equals("iyirmi bir"));
      expect(converter.convert(99), equals("doxsan doqquz"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("yüz"));
      expect(converter.convert(101), equals("yüz bir"));
      expect(converter.convert(111), equals("yüz on bir"));
      expect(converter.convert(200), equals("iki yüz"));
      expect(converter.convert(999), equals("doqquz yüz doxsan doqquz"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("min"));
      expect(converter.convert(1001), equals("min bir"));
      expect(converter.convert(1111), equals("min yüz on bir"));
      expect(converter.convert(2000), equals("iki min"));
      expect(converter.convert(10000), equals("on min"));
      expect(converter.convert(100000), equals("yüz min"));
      expect(converter.convert(123456),
          equals("yüz iyirmi üç min dörd yüz əlli altı"));
      expect(
        converter.convert(999999),
        equals("doqquz yüz doxsan doqquz min doqquz yüz doxsan doqquz"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("mənfi bir"));
      expect(converter.convert(-123), equals("mənfi yüz iyirmi üç"));
      expect(
        converter.convert(-1, options: AzOptions(negativePrefix: "minus")),
        equals("minus bir"),
      );
      expect(
        converter.convert(-123, options: AzOptions(negativePrefix: "minus")),
        equals("minus yüz iyirmi üç"),
      );
    });

    test('Year Formatting', () {
      const yearOption = AzOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("min doqquz yüz"));
      expect(converter.convert(2024, options: yearOption),
          equals("iki min iyirmi dörd"));
      expect(
        converter.convert(1900,
            options: AzOptions(format: Format.year, includeAD: true)),
        equals("min doqquz yüz eramızın"),
      );
      expect(
        converter.convert(2024,
            options: AzOptions(format: Format.year, includeAD: true)),
        equals("iki min iyirmi dörd eramızın"),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("yüz eramızdan əvvəl"));
      expect(converter.convert(-1, options: yearOption),
          equals("bir eramızdan əvvəl"));
      expect(
        converter.convert(-2024,
            options: AzOptions(format: Format.year, includeAD: true)),
        equals("iki min iyirmi dörd eramızdan əvvəl"),
      );
    });

    test('Currency', () {
      const currencyOption = AzOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("sıfır manat"));
      expect(
          converter.convert(1, options: currencyOption), equals("bir manat"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("bir manat əlli qəpik"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("yüz iyirmi üç manat qırx beş qəpik"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("yüz iyirmi üç vergül dörd beş altı"),
      );
      expect(
          converter.convert(Decimal.parse('1.50')), equals("bir vergül beş"));
      expect(converter.convert(123.0), equals("yüz iyirmi üç"));
      expect(
          converter.convert(Decimal.parse('123.0')), equals("yüz iyirmi üç"));
      expect(
        converter.convert(1.5,
            options: const AzOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("bir vergül beş"),
      );
      expect(
        converter.convert(1.5,
            options:
                const AzOptions(decimalSeparator: DecimalSeparator.period)),
        equals("bir nöqtə beş"),
      );
      expect(
        converter.convert(1.5,
            options: const AzOptions(decimalSeparator: DecimalSeparator.point)),
        equals("bir nöqtə beş"),
      );
    });

    test('Infinity and invalid input', () {
      expect(converter.convert(double.infinity), equals("Sonsuzluq"));
      expect(converter.convert(double.negativeInfinity),
          equals("Mənfi Sonsuzluq"));
      expect(converter.convert(double.nan), equals("Ədəd Deyil"));
      expect(converter.convert(null), equals("Ədəd Deyil"));
      expect(converter.convert('abc'), equals("Ədəd Deyil"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Sonsuzluq"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Mənfi Sonsuzluq"));
      expect(converterWithFallback.convert(double.nan), equals("Yanlış Dəyər"));
      expect(converterWithFallback.convert(null), equals("Yanlış Dəyər"));
      expect(converterWithFallback.convert('abc'), equals("Yanlış Dəyər"));
      expect(converterWithFallback.convert(123), equals("yüz iyirmi üç"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("bir milyon"));
      expect(converter.convert(BigInt.from(1000000000)), equals("bir milyard"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("bir trilyon"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("bir kvadrilyon"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("bir kvintilyon"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("bir sekstilyon"));
      expect(converter.convert(BigInt.parse('1000000000000000000000000')),
          equals("bir septilyon"));
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "yüz iyirmi üç sekstilyon dörd yüz əlli altı kvintilyon yeddi yüz səksən doqquz kvadrilyon yüz iyirmi üç trilyon dörd yüz əlli altı milyard yeddi yüz səksən doqquz milyon yüz iyirmi üç min dörd yüz əlli altı",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "doqquz yüz doxsan doqquz sekstilyon doqquz yüz doxsan doqquz kvintilyon doqquz yüz doxsan doqquz kvadrilyon doqquz yüz doxsan doqquz trilyon doqquz yüz doxsan doqquz milyard doqquz yüz doxsan doqquz milyon doqquz yüz doxsan doqquz min doqquz yüz doxsan doqquz",
        ),
      );
    });
  });
}
