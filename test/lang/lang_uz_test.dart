import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Uzbek (UZ)', () {
    final converter = Num2Text(initialLang: Lang.UZ);
    final converterWithFallback = Num2Text(
      initialLang: Lang.UZ,
      fallbackOnError: "Noto'g'ri raqam",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("nol"));
      expect(converter.convert(1), equals("bir"));
      expect(converter.convert(10), equals("o'n"));
      expect(converter.convert(11), equals("o'n bir"));
      expect(converter.convert(20), equals("yigirma"));
      expect(converter.convert(21), equals("yigirma bir"));
      expect(converter.convert(99), equals("to'qson to'qqiz"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("bir yuz"));
      expect(converter.convert(101), equals("bir yuz bir"));
      expect(converter.convert(111), equals("bir yuz o'n bir"));
      expect(converter.convert(200), equals("ikki yuz"));
      expect(converter.convert(999), equals("to'qqiz yuz to'qson to'qqiz"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("bir ming"));
      expect(converter.convert(1001), equals("bir ming bir"));
      expect(converter.convert(1111), equals("bir ming bir yuz o'n bir"));
      expect(converter.convert(2000), equals("ikki ming"));
      expect(converter.convert(10000), equals("o'n ming"));
      expect(converter.convert(100000), equals("bir yuz ming"));
      expect(converter.convert(123456),
          equals("bir yuz yigirma uch ming to'rt yuz ellik olti"));
      expect(
        converter.convert(999999),
        equals("to'qqiz yuz to'qson to'qqiz ming to'qqiz yuz to'qson to'qqiz"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus bir"));
      expect(converter.convert(-123), equals("minus bir yuz yigirma uch"));
      expect(
        converter.convert(-1, options: UzOptions(negativePrefix: "manfiy")),
        equals("manfiy bir"),
      );
      expect(
        converter.convert(-123, options: UzOptions(negativePrefix: "manfiy")),
        equals("manfiy bir yuz yigirma uch"),
      );
    });

    test('Year Formatting', () {
      const yearOption = UzOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("bir ming to'qqiz yuz"));
      expect(converter.convert(2024, options: yearOption),
          equals("ikki ming yigirma to'rt"));
      expect(
        converter.convert(1900, options: UzOptions(format: Format.year)),
        equals("bir ming to'qqiz yuz"),
      );
      expect(
        converter.convert(2024, options: UzOptions(format: Format.year)),
        equals("ikki ming yigirma to'rt"),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("minus bir yuz"));
      expect(converter.convert(-1, options: yearOption), equals("minus bir"));
      expect(
        converter.convert(-2024, options: UzOptions(format: Format.year)),
        equals("minus ikki ming yigirma to'rt"),
      );
    });

    test('Currency', () {
      const currencyOption = UzOptions(currency: true);
      expect(converter.convert(1.01, options: currencyOption),
          equals("bir soʻm bir tiyin"));
      expect(converter.convert(2.50, options: currencyOption),
          equals("ikki soʻm ellik tiyin"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("bir yuz yigirma uch soʻm qirq besh tiyin"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("bir yuz yigirma uch nuqta to'rt besh olti"),
      );
      expect(
          converter.convert(Decimal.parse('1.50')), equals("bir nuqta besh"));
      expect(converter.convert(123.0), equals("bir yuz yigirma uch"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("bir yuz yigirma uch"));
      expect(
        converter.convert(1.5,
            options: const UzOptions(decimalSeparator: DecimalSeparator.point)),
        equals("bir nuqta besh"),
      );
      expect(
        converter.convert(1.5,
            options: const UzOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("bir vergul besh"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Cheksizlik"));
      expect(converter.convert(double.negativeInfinity),
          equals("Manfiy cheksizlik"));
      expect(converter.convert(double.nan), equals("Raqam emas"));
      expect(converter.convert(null), equals("Raqam emas"));
      expect(converter.convert('abc'), equals("Raqam emas"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Cheksizlik"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Manfiy cheksizlik"));
      expect(
          converterWithFallback.convert(double.nan), equals("Noto'g'ri raqam"));
      expect(converterWithFallback.convert(null), equals("Noto'g'ri raqam"));
      expect(converterWithFallback.convert('abc'), equals("Noto'g'ri raqam"));
      expect(converterWithFallback.convert(123), equals("bir yuz yigirma uch"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("bir million"));
      expect(
          converter.convert(BigInt.from(1000000000)), equals("bir milliard"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("bir trillion"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("bir kvadrillion"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("bir kvintillion"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("bir sekstillion"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("bir septillion"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "bir yuz yigirma uch sekstillion to'rt yuz ellik olti kvintillion yetti yuz sakson to'qqiz kvadrillion bir yuz yigirma uch trillion to'rt yuz ellik olti milliard yetti yuz sakson to'qqiz million bir yuz yigirma uch ming to'rt yuz ellik olti",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "to'qqiz yuz to'qson to'qqiz sekstillion to'qqiz yuz to'qson to'qqiz kvintillion to'qqiz yuz to'qson to'qqiz kvadrillion to'qqiz yuz to'qson to'qqiz trillion to'qqiz yuz to'qson to'qqiz milliard to'qqiz yuz to'qson to'qqiz million to'qqiz yuz to'qson to'qqiz ming to'qqiz yuz to'qson to'qqiz",
        ),
      );
    });
  });
}
