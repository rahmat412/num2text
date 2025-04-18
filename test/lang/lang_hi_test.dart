import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Hindi (HI)', () {
    final converter = Num2Text(initialLang: Lang.HI);
    final converterWithFallback =
        Num2Text(initialLang: Lang.HI, fallbackOnError: "अमान्य संख्या");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("शून्य"));
      expect(converter.convert(1), equals("एक"));
      expect(converter.convert(10), equals("दस"));
      expect(converter.convert(11), equals("ग्यारह"));
      expect(converter.convert(20), equals("बीस"));
      expect(converter.convert(21), equals("इक्कीस"));
      expect(converter.convert(99), equals("निन्यानवे"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("एक सौ"));
      expect(converter.convert(101), equals("एक सौ एक"));
      expect(converter.convert(111), equals("एक सौ ग्यारह"));
      expect(converter.convert(200), equals("दो सौ"));
      expect(converter.convert(999), equals("नौ सौ निन्यानवे"));
    });

    test('Thousands and Lakhs', () {
      expect(converter.convert(1000), equals("एक हज़ार"));
      expect(converter.convert(1001), equals("एक हज़ार एक"));
      expect(converter.convert(1111), equals("एक हज़ार एक सौ ग्यारह"));
      expect(converter.convert(2000), equals("दो हज़ार"));
      expect(converter.convert(10000), equals("दस हज़ार"));
      expect(converter.convert(100000), equals("एक लाख"));
      expect(
          converter.convert(123456), equals("एक लाख तेईस हज़ार चार सौ छप्पन"));
      expect(converter.convert(999999),
          equals("नौ लाख निन्यानवे हज़ार नौ सौ निन्यानवे"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("ऋण एक"));
      expect(converter.convert(-123), equals("ऋण एक सौ तेईस"));
      expect(converter.convert(-1, options: HiOptions(negativePrefix: "घटा")),
          equals("घटा एक"));
      expect(
        converter.convert(-123, options: HiOptions(negativePrefix: "घटा")),
        equals("घटा एक सौ तेईस"),
      );
    });

    test('Year Formatting', () {
      const yearOption = HiOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption), equals("उन्नीस सौ"));
      expect(converter.convert(2024, options: yearOption),
          equals("दो हज़ार चौबीस"));
      expect(
        converter.convert(1900,
            options: HiOptions(format: Format.year, includeAD: true)),
        equals("उन्नीस सौ ईस्वी"),
      );
      expect(
        converter.convert(2024,
            options: HiOptions(format: Format.year, includeAD: true)),
        equals("दो हज़ार चौबीस ईस्वी"),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("एक सौ ईसा पूर्व"));
      expect(
          converter.convert(-1, options: yearOption), equals("एक ईसा पूर्व"));
      expect(
        converter.convert(-2024,
            options: HiOptions(format: Format.year, includeAD: true)),
        equals("दो हज़ार चौबीस ईसा पूर्व"),
      );
    });

    test('Currency', () {
      const currencyOption = HiOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("शून्य रुपये"));
      expect(converter.convert(1, options: currencyOption), equals("एक रुपया"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("एक रुपया और पचास पैसे"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("एक सौ तेईस रुपये और पैंतालीस पैसे"),
      );
      expect(converter.convert(2, options: currencyOption), equals("दो रुपये"));
      expect(converter.convert(10.01, options: currencyOption),
          equals("दस रुपये और एक पैसा"));
    });

    test('Decimals', () {
      expect(converter.convert(Decimal.parse('123.456')),
          equals("एक सौ तेईस दशमलव चार पाँच छह"));

      expect(converter.convert(Decimal.parse('1.50')), equals("एक दशमलव पाँच"));
      expect(converter.convert(123.0), equals("एक सौ तेईस"));
      expect(converter.convert(Decimal.parse('123.0')), equals("एक सौ तेईस"));

      expect(
        converter.convert(1.5,
            options: const HiOptions(decimalSeparator: DecimalSeparator.point)),
        equals("एक दशमलव पाँच"),
      );
      expect(
        converter.convert(1.5,
            options:
                const HiOptions(decimalSeparator: DecimalSeparator.period)),
        equals("एक दशमलव पाँच"),
      );

      expect(
        converter.convert(1.5,
            options: const HiOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("एक अल्पविराम पाँच"),
      );
    });

    test('Scale Numbers (Indian System)', () {
      expect(converter.convert(BigInt.from(100000)), equals("एक लाख"));
      expect(converter.convert(BigInt.from(10000000)), equals("एक करोड़"));
      expect(converter.convert(BigInt.from(1000000000)), equals("एक अरब"));
      expect(converter.convert(BigInt.from(100000000000)), equals("एक खरब"));
      expect(converter.convert(BigInt.from(10000000000000)), equals("एक नील"));
      expect(
          converter.convert(BigInt.from(1000000000000000)), equals("एक पद्म"));
      expect(
          converter.convert(BigInt.from(100000000000000000)), equals("एक शंख"));

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "बारह हज़ार तीन सौ पैंतालीस शंख सड़सठ शंख नवासी पद्म बारह नील चौंतीस खरब छप्पन अरब अठहत्तर करोड़ इक्यानबे लाख तेईस हज़ार चार सौ छप्पन",
        ),
      );
      expect(
        converter.convert(BigInt.parse('9999999999999999999')),
        equals(
          "निन्यानवे शंख निन्यानवे पद्म निन्यानवे नील निन्यानवे खरब निन्यानवे अरब निन्यानवे करोड़ निन्यानवे लाख निन्यानवे हज़ार नौ सौ निन्यानवे",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "निन्यानवे हज़ार नौ सौ निन्यानवे शंख निन्यानवे शंख निन्यानवे पद्म निन्यानवे नील निन्यानवे खरब निन्यानवे अरब निन्यानवे करोड़ निन्यानवे लाख निन्यानवे हज़ार नौ सौ निन्यानवे",
        ),
      );
      expect(converter.convert(BigInt.parse('1000000000000000000')),
          equals("दस शंख"));
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("अनंत"));
      expect(converter.convert(double.negativeInfinity), equals("ऋण अनंत"));
      expect(converter.convert(double.nan), equals("अमान्य संख्या"));
      expect(converter.convert(null), equals("अमान्य संख्या"));
      expect(converter.convert('abc'), equals("अमान्य संख्या"));

      expect(converterWithFallback.convert(double.infinity), equals("अनंत"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("ऋण अनंत"));
      expect(
          converterWithFallback.convert(double.nan), equals("अमान्य संख्या"));
      expect(converterWithFallback.convert(null), equals("अमान्य संख्या"));
      expect(converterWithFallback.convert('abc'), equals("अमान्य संख्या"));
      expect(converterWithFallback.convert(123), equals("एक सौ तेईस"));
    });
  });
}
