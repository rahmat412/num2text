import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Hindi (HI)', () {
    final converter = Num2Text(initialLang: Lang.HI);
    final converterWithFallback =
        Num2Text(initialLang: Lang.HI, fallbackOnError: "अमान्य संख्या");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("शून्य"));
      expect(converter.convert(10), equals("दस"));
      expect(converter.convert(11), equals("ग्यारह"));
      expect(converter.convert(13), equals("तेरह"));
      expect(converter.convert(15), equals("पंद्रह"));
      expect(converter.convert(20), equals("बीस"));
      expect(converter.convert(27), equals("सत्ताईस"));
      expect(converter.convert(30), equals("तीस"));
      expect(converter.convert(54), equals("चौवन"));
      expect(converter.convert(68), equals("अड़सठ"));
      expect(converter.convert(99), equals("निन्यानवे"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("एक सौ"));
      expect(converter.convert(101), equals("एक सौ एक"));
      expect(converter.convert(105), equals("एक सौ पाँच"));
      expect(converter.convert(110), equals("एक सौ दस"));
      expect(converter.convert(111), equals("एक सौ ग्यारह"));
      expect(converter.convert(123), equals("एक सौ तेईस"));
      expect(converter.convert(200), equals("दो सौ"));
      expect(converter.convert(321), equals("तीन सौ इक्कीस"));
      expect(converter.convert(479), equals("चार सौ उन्यासी"));
      expect(converter.convert(596), equals("पाँच सौ छियानवे"));
      expect(converter.convert(681), equals("छह सौ इक्यासी"));
      expect(converter.convert(999), equals("नौ सौ निन्यानवे"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("एक हज़ार"));
      expect(converter.convert(1001), equals("एक हज़ार एक"));
      expect(converter.convert(1011), equals("एक हज़ार ग्यारह"));
      expect(converter.convert(1110), equals("एक हज़ार एक सौ दस"));
      expect(converter.convert(1111), equals("एक हज़ार एक सौ ग्यारह"));
      expect(converter.convert(2000), equals("दो हज़ार"));
      expect(converter.convert(2468), equals("दो हज़ार चार सौ अड़सठ"));
      expect(converter.convert(3579), equals("तीन हज़ार पाँच सौ उन्यासी"));
      expect(converter.convert(10000), equals("दस हज़ार"));
      expect(converter.convert(10011), equals("दस हज़ार ग्यारह"));
      expect(converter.convert(11100), equals("ग्यारह हज़ार एक सौ"));
      expect(converter.convert(12987), equals("बारह हज़ार नौ सौ सतासी"));
      expect(converter.convert(45623), equals("पैंतालीस हज़ार छह सौ तेईस"));
      expect(converter.convert(87654), equals("सतासी हज़ार छह सौ चौवन"));
      expect(converter.convert(100000), equals("एक लाख"));
      expect(
          converter.convert(123456), equals("एक लाख तेईस हज़ार चार सौ छप्पन"));
      expect(
          converter.convert(987654), equals("नौ लाख सतासी हज़ार छह सौ चौवन"));
      expect(converter.convert(999999),
          equals("नौ लाख निन्यानवे हज़ार नौ सौ निन्यानवे"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("ऋण एक"));
      expect(converter.convert(-123), equals("ऋण एक सौ तेईस"));
      expect(converter.convert(-123.456),
          equals("ऋण एक सौ तेईस दशमलव चार पाँच छह"));

      const negativeOption = HiOptions(negativePrefix: "घटा");

      expect(converter.convert(-1, options: negativeOption), equals("घटा एक"));
      expect(converter.convert(-123, options: negativeOption),
          equals("घटा एक सौ तेईस"));
      expect(converter.convert(-123.456, options: negativeOption),
          equals("घटा एक सौ तेईस दशमलव चार पाँच छह"));
    });

    test('Decimals', () {
      expect(
          converter.convert(123.456), equals("एक सौ तेईस दशमलव चार पाँच छह"));
      expect(converter.convert(1.5), equals("एक दशमलव पाँच"));
      expect(converter.convert(1.05), equals("एक दशमलव शून्य पाँच"));
      expect(converter.convert(879.465),
          equals("आठ सौ उन्यासी दशमलव चार छह पाँच"));
      expect(converter.convert(1.5), equals("एक दशमलव पाँच"));

      const pointOption = HiOptions(decimalSeparator: DecimalSeparator.point);

      expect(converter.convert(1.5, options: pointOption),
          equals("एक दशमलव पाँच"));

      const commaOption = HiOptions(decimalSeparator: DecimalSeparator.comma);

      expect(converter.convert(1.5, options: commaOption),
          equals("एक अल्पविराम पाँच"));

      const periodOption = HiOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(1.5, options: periodOption),
          equals("एक दशमलव पाँच"));
    });

    test('Year Formatting', () {
      const yearOption = HiOptions(format: Format.year);

      expect(converter.convert(123, options: yearOption), equals("एक सौ तेईस"));
      expect(converter.convert(498, options: yearOption),
          equals("चार सौ अठ्ठानवे"));
      expect(
          converter.convert(756, options: yearOption), equals("सात सौ छप्पन"));
      expect(converter.convert(1900, options: yearOption), equals("उन्नीस सौ"));
      expect(converter.convert(1999, options: yearOption),
          equals("एक हज़ार नौ सौ निन्यानवे"));
      expect(converter.convert(2025, options: yearOption),
          equals("दो हज़ार पच्चीस"));

      const yearOptionAD = HiOptions(format: Format.year, includeAD: true);

      expect(converter.convert(1900, options: yearOptionAD),
          equals("उन्नीस सौ ईस्वी"));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("एक हज़ार नौ सौ निन्यानवे ईस्वी"));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("दो हज़ार पच्चीस ईस्वी"));
      expect(
          converter.convert(-1, options: yearOption), equals("एक ईसा पूर्व"));
      expect(converter.convert(-100, options: yearOption),
          equals("एक सौ ईसा पूर्व"));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("एक सौ ईसा पूर्व"));
      expect(converter.convert(-2025, options: yearOption),
          equals("दो हज़ार पच्चीस ईसा पूर्व"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("दस लाख ईसा पूर्व"));
    });

    test('Currency', () {
      const currencyOption = HiOptions(currency: true);

      expect(
          converter.convert(0, options: currencyOption), equals("शून्य रुपये"));
      expect(converter.convert(1, options: currencyOption), equals("एक रुपया"));
      expect(converter.convert(2, options: currencyOption), equals("दो रुपये"));
      expect(
          converter.convert(5, options: currencyOption), equals("पाँच रुपये"));
      expect(
          converter.convert(10, options: currencyOption), equals("दस रुपये"));
      expect(converter.convert(11, options: currencyOption),
          equals("ग्यारह रुपये"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("एक रुपया और पचास पैसे"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("एक सौ तेईस रुपये और पैंतालीस पैसे"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("एक करोड़ रुपये"));
      expect(
          converter.convert(0.01, options: currencyOption), equals("एक पैसा"));
      expect(
          converter.convert(0.5, options: currencyOption), equals("पचास पैसे"));
      expect(converter.convert(10.01, options: currencyOption),
          equals("दस रुपये और एक पैसा"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(5)), equals("एक लाख"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(7)),
          equals("दो करोड़"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(9)),
          equals("तीन अरब"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(11)),
          equals("चार खरब"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(13)),
          equals("पाँच नील"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(15)),
          equals("छह पद्म"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(17)),
          equals("सात शंख"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "अठ्ठानवे शंख छिहत्तर पद्म चौवन नील बत्तीस खरब दस अरब बारह करोड़ चौंतीस लाख छप्पन हज़ार सात सौ नवासी"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              'बारह लाख चौंतीस हज़ार पाँच सौ सड़सठ शंख नवासी पद्म बारह नील चौंतीस खरब छप्पन अरब अठहत्तर करोड़ इक्यानबे लाख तेईस हज़ार चार सौ छप्पन'));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              'निन्यानवे लाख निन्यानवे हज़ार नौ सौ निन्यानवे शंख निन्यानवे पद्म निन्यानवे नील निन्यानवे खरब निन्यानवे अरब निन्यानवे करोड़ निन्यानवे लाख निन्यानवे हज़ार नौ सौ निन्यानवे'));

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('दस खरब बीस लाख तीन'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("पचास लाख एक हज़ार"));
      expect(
          converter.convert(BigInt.parse('1000000001')), equals("एक अरब एक"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals('एक अरब दस लाख'));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("बीस लाख एक हज़ार"));
      expect(converter.convert(BigInt.parse('1000987600003')),
          equals("दस खरब अठ्ठानवे करोड़ छिहत्तर लाख तीन"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("अमान्य संख्या"));
      expect(converter.convert(double.infinity), equals("अनंत"));
      expect(converter.convert(double.negativeInfinity), equals("ऋण अनंत"));
      expect(converter.convert(null), equals("अमान्य संख्या"));
      expect(converter.convert('abc'), equals("अमान्य संख्या"));
      expect(converter.convert([]), equals("अमान्य संख्या"));
      expect(converter.convert({}), equals("अमान्य संख्या"));
      expect(converter.convert(Object()), equals("अमान्य संख्या"));

      expect(
          converterWithFallback.convert(double.nan), equals("अमान्य संख्या"));
      expect(converterWithFallback.convert(double.infinity), equals("अनंत"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("ऋण अनंत"));
      expect(converterWithFallback.convert(null), equals("अमान्य संख्या"));
      expect(converterWithFallback.convert('abc'), equals("अमान्य संख्या"));
      expect(converterWithFallback.convert([]), equals("अमान्य संख्या"));
      expect(converterWithFallback.convert({}), equals("अमान्य संख्या"));
      expect(converterWithFallback.convert(Object()), equals("अमान्य संख्या"));
      expect(converterWithFallback.convert(123), equals("एक सौ तेईस"));
    });
  });
}
