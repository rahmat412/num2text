import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Nepali (NE)', () {
    final converter = Num2Text(initialLang: Lang.NE);
    final converterWithFallback =
        Num2Text(initialLang: Lang.NE, fallbackOnError: "अमान्य संख्या");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("शून्य"));
      expect(converter.convert(1), equals("एक"));
      expect(converter.convert(10), equals("दस"));
      expect(converter.convert(11), equals("एघार"));
      expect(converter.convert(19), equals("उन्नाइस"));
      expect(converter.convert(20), equals("बीस"));
      expect(converter.convert(21), equals("एक्काइस"));
      expect(converter.convert(99), equals("उनान्सय"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("एक सय"));
      expect(converter.convert(101), equals("एक सय एक"));
      expect(converter.convert(111), equals("एक सय एघार"));
      expect(converter.convert(200), equals("दुई सय"));
      expect(converter.convert(999), equals("नौ सय उनान्सय"));
    });

    test('Thousands / Lakhs / Crores', () {
      expect(converter.convert(1000), equals("एक हजार"));
      expect(converter.convert(1001), equals("एक हजार एक"));
      expect(converter.convert(1111), equals("एक हजार एक सय एघार"));
      expect(converter.convert(2000), equals("दुई हजार"));
      expect(converter.convert(10000), equals("दस हजार"));
      expect(converter.convert(100000), equals("एक लाख"));
      expect(
          converter.convert(123456), equals("एक लाख तेइस हजार चार सय छपन्न"));
      expect(converter.convert(999999),
          equals("नौ लाख उनान्सय हजार नौ सय उनान्सय"));
      expect(converter.convert(1000000), equals("दस लाख"));
      expect(converter.convert(10000000), equals("एक करोड"));
      expect(converter.convert(12345678),
          equals("एक करोड तेइस लाख पैंतालिस हजार छ सय अठहत्तर"));
      expect(converter.convert(99999999),
          equals("नौ करोड उनान्सय लाख उनान्सय हजार नौ सय उनान्सय"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("माइनस एक"));
      expect(converter.convert(-123), equals("माइनस एक सय तेइस"));

      expect(converter.convert(-1, options: NeOptions(negativePrefix: "ऋण")),
          equals("ऋण एक"));
      expect(
        converter.convert(-123, options: NeOptions(negativePrefix: "ऋण")),
        equals("ऋण एक सय तेइस"),
      );
    });

    test('Year Formatting', () {
      const yearOption = NeOptions(format: Format.year);
      const yearOptionAD = NeOptions(format: Format.year, includeAD: true);

      expect(
          converter.convert(1900, options: yearOption), equals("उन्नाइस सय"));
      expect(converter.convert(2024, options: yearOption),
          equals("दुई हजार चौबीस"));
      expect(converter.convert(2024, options: yearOptionAD),
          equals("दुई हजार चौबीस ईस्वी"));
      expect(
          converter.convert(-100, options: yearOption), equals("एक सय ई.पू."));
      expect(converter.convert(-1, options: yearOption), equals("एक ई.पू."));
      expect(converter.convert(-2024, options: yearOption),
          equals("दुई हजार चौबीस ई.पू."));
    });

    test('Currency (NPR)', () {
      const currencyOption = NeOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("शून्य रुपैयाँ"));
      expect(
          converter.convert(1, options: currencyOption), equals("एक रुपैयाँ"));
      expect(
          converter.convert(2, options: currencyOption), equals("दुई रुपैयाँ"));
      expect(
          converter.convert(0.01, options: currencyOption), equals("एक पैसा"));
      expect(
          converter.convert(0.02, options: currencyOption), equals("दुई पैसा"));
      expect(converter.convert(0.50, options: currencyOption),
          equals("पचास पैसा"));

      expect(converter.convert(1.50, options: currencyOption),
          equals("एक रुपैयाँ र पचास पैसा"));

      expect(
        converter.convert(123.45, options: currencyOption),
        equals("एक सय तेइस रुपैयाँ र पैंतालिस पैसा"),
      );

      expect(
        converter.convert(Decimal.parse('0.75'), options: currencyOption),
        equals("पचहत्तर पैसा"),
      );

      expect(converter.convert(500, options: currencyOption),
          equals("पाँच सय रुपैयाँ"));
    });

    test('Decimals', () {
      expect(converter.convert(Decimal.parse('123.456')),
          equals("एक सय तेइस दशमलव चार पाँच छ"));
      expect(converter.convert(Decimal.parse('1.50')), equals("एक दशमलव पाँच"));

      expect(converter.convert(Decimal.parse('1.5')), equals("एक दशमलव पाँच"));

      expect(converter.convert(123.0), equals("एक सय तेइस"));

      expect(converter.convert(Decimal.parse('123.0')), equals("एक सय तेइस"));

      expect(
        converter.convert(1.5,
            options:
                const NeOptions(decimalSeparator: DecimalSeparator.period)),
        equals("एक दशमलव पाँच"),
      );
      expect(
        converter.convert(1.5,
            options: const NeOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("एक अल्पविराम पाँच"),
      );

      expect(
          converter.convert(Decimal.parse('0.5')), equals("शून्य दशमलव पाँच"));
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("अनन्त"));
      expect(converter.convert(double.negativeInfinity), equals("माइनस अनन्त"));
      expect(converter.convert(double.nan), equals("संख्या होइन"));
      expect(converter.convert(null), equals("संख्या होइन"));
      expect(converter.convert('abc'), equals("संख्या होइन"));

      expect(converterWithFallback.convert(double.infinity), equals("अनन्त"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("माइनस अनन्त"));
      expect(
          converterWithFallback.convert(double.nan), equals("अमान्य संख्या"));
      expect(converterWithFallback.convert(null), equals("अमान्य संख्या"));
      expect(converterWithFallback.convert('abc'), equals("अमान्य संख्या"));
      expect(converterWithFallback.convert(123), equals("एक सय तेइस"));
    });

    test('Scale Numbers (Arba, Kharba, etc.)', () {
      expect(converter.convert(BigInt.parse('1000000')), equals("दस लाख"));
      expect(converter.convert(BigInt.parse('10000000')), equals("एक करोड"));

      expect(converter.convert(BigInt.parse('1000000000')), equals("एक अर्ब"));
      expect(
          converter.convert(BigInt.parse('100000000000')), equals("एक खर्ब"));
      expect(
          converter.convert(BigInt.parse('10000000000000')), equals("एक नील"));
      expect(converter.convert(BigInt.parse('1000000000000000')),
          equals("एक पद्म"));
      expect(converter.convert(BigInt.parse('100000000000000000')),
          equals("एक शंख"));

      expect(
        converter.convert(BigInt.parse('123456789123456')),
        equals(
            "बाह्र नील चौँतीस खर्ब छपन्न अर्ब अठहत्तर करोड एकानब्बे लाख तेइस हजार चार सय छपन्न"),
      );

      expect(
        converter.convert(BigInt.parse('123456789123456789')),
        equals(
          "एक शंख तेइस पद्म पैंतालिस नील सड्सठी खर्ब उनान्नब्बे अर्ब बाह्र करोड चौँतीस लाख छपन्न हजार सात सय उनान्नब्बे",
        ),
      );
    });
  });
}
