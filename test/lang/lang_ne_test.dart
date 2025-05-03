import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Nepali (NE)', () {
    final converter = Num2Text(initialLang: Lang.NE);
    final converterWithFallback =
        Num2Text(initialLang: Lang.NE, fallbackOnError: "अमान्य संख्या");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("शून्य"));
      expect(converter.convert(10), equals("दस"));
      expect(converter.convert(11), equals("एघार"));
      expect(converter.convert(13), equals("तेह्र"));
      expect(converter.convert(15), equals("पन्ध्र"));
      expect(converter.convert(20), equals("बीस"));
      expect(converter.convert(27), equals("सत्ताइस"));
      expect(converter.convert(30), equals("तीस"));
      expect(converter.convert(54), equals("चौवन्न"));
      expect(converter.convert(68), equals("अठसठ्ठी"));
      expect(converter.convert(99), equals("उनान्सय"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("एक सय"));
      expect(converter.convert(101), equals("एक सय एक"));
      expect(converter.convert(105), equals("एक सय पाँच"));
      expect(converter.convert(110), equals("एक सय दस"));
      expect(converter.convert(111), equals("एक सय एघार"));
      expect(converter.convert(123), equals("एक सय तेइस"));
      expect(converter.convert(200), equals("दुई सय"));
      expect(converter.convert(321), equals("तीन सय एक्काइस"));
      expect(converter.convert(479), equals("चार सय उनासी"));
      expect(converter.convert(596), equals("पाँच सय छयानब्बे"));
      expect(converter.convert(681), equals("छ सय एकासी"));
      expect(converter.convert(999), equals("नौ सय उनान्सय"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("एक हजार"));
      expect(converter.convert(1001), equals("एक हजार एक"));
      expect(converter.convert(1011), equals("एक हजार एघार"));
      expect(converter.convert(1110), equals("एक हजार एक सय दस"));
      expect(converter.convert(1111), equals("एक हजार एक सय एघार"));
      expect(converter.convert(2000), equals("दुई हजार"));
      expect(converter.convert(2468), equals("दुई हजार चार सय अठसठ्ठी"));
      expect(converter.convert(3579), equals("तीन हजार पाँच सय उनासी"));
      expect(converter.convert(10000), equals("दस हजार"));
      expect(converter.convert(10011), equals("दस हजार एघार"));
      expect(converter.convert(11100), equals("एघार हजार एक सय"));
      expect(converter.convert(12987), equals("बाह्र हजार नौ सय सतासी"));
      expect(converter.convert(45623), equals("पैंतालिस हजार छ सय तेइस"));
      expect(converter.convert(87654), equals("सतासी हजार छ सय चौवन्न"));
      expect(converter.convert(100000), equals("एक लाख"));
      expect(
          converter.convert(123456), equals("एक लाख तेइस हजार चार सय छपन्न"));
      expect(
          converter.convert(987654), equals("नौ लाख सतासी हजार छ सय चौवन्न"));
      expect(converter.convert(999999),
          equals("नौ लाख उनान्सय हजार नौ सय उनान्सय"));
    });

    test('Negative Numbers', () {
      const negOption = NeOptions(negativePrefix: "ऋण");
      expect(converter.convert(-1), equals("माइनस एक"));
      expect(converter.convert(-123), equals("माइनस एक सय तेइस"));
      expect(converter.convert(-123.456),
          equals("माइनस एक सय तेइस दशमलव चार पाँच छ"));
      expect(converter.convert(-1, options: negOption), equals("ऋण एक"));
      expect(
          converter.convert(-123, options: negOption), equals("ऋण एक सय तेइस"));
      expect(converter.convert(-123.456, options: negOption),
          equals("ऋण एक सय तेइस दशमलव चार पाँच छ"));
    });

    test('Decimals', () {
      const pointOption = NeOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = NeOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = NeOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(123.456), equals("एक सय तेइस दशमलव चार पाँच छ"));
      expect(converter.convert(1.5), equals("एक दशमलव पाँच"));
      expect(converter.convert(1.05), equals("एक दशमलव शून्य पाँच"));
      expect(
          converter.convert(879.465), equals("आठ सय उनासी दशमलव चार छ पाँच"));
      expect(converter.convert(1.5, options: pointOption),
          equals("एक दशमलव पाँच"));
      expect(converter.convert(1.5, options: commaOption),
          equals("एक अल्पविराम पाँच"));
      expect(converter.convert(1.5, options: periodOption),
          equals("एक दशमलव पाँच"));
    });

    test('Year Formatting', () {
      const yearOption = NeOptions(format: Format.year);
      const yearOptionAD = NeOptions(format: Format.year, includeAD: true);
      expect(converter.convert(123, options: yearOption), equals("एक सय तेइस"));
      expect(converter.convert(498, options: yearOption),
          equals("चार सय अन्ठानब्बे"));
      expect(
          converter.convert(756, options: yearOption), equals("सात सय छपन्न"));
      expect(
          converter.convert(1900, options: yearOption), equals("उन्नाइस सय"));
      expect(converter.convert(1999, options: yearOption),
          equals("उन्नाइस सय उनान्सय"));
      expect(converter.convert(2025, options: yearOption),
          equals("दुई हजार पच्चीस"));
      expect(converter.convert(1900, options: yearOptionAD),
          equals("उन्नाइस सय ईस्वी"));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("उन्नाइस सय उनान्सय ईस्वी"));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("दुई हजार पच्चीस ईस्वी"));
      expect(converter.convert(-1, options: yearOption), equals("एक ई.पू."));
      expect(
          converter.convert(-100, options: yearOption), equals("एक सय ई.पू."));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("एक सय ई.पू."));
      expect(converter.convert(-2025, options: yearOption),
          equals("दुई हजार पच्चीस ई.पू."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("दस लाख ई.पू."));
    });

    test('Currency', () {
      const currencyOption = NeOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("शून्य रुपैयाँ"));
      expect(
          converter.convert(1, options: currencyOption), equals("एक रुपैयाँ"));
      expect(converter.convert(5, options: currencyOption),
          equals("पाँच रुपैयाँ"));
      expect(
          converter.convert(10, options: currencyOption), equals("दस रुपैयाँ"));
      expect(converter.convert(11, options: currencyOption),
          equals("एघार रुपैयाँ"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("एक रुपैयाँ र पचास पैसा"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("एक सय तेइस रुपैयाँ र पैंतालिस पैसा"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("एक करोड रुपैयाँ"));
      expect(converter.convert(0.5), equals("शून्य दशमलव पाँच"));
      expect(
          converter.convert(0.5, options: currencyOption), equals("पचास पैसा"));
      expect(
          converter.convert(0.01, options: currencyOption), equals("एक पैसा"));
      expect(
          converter.convert(0.02, options: currencyOption), equals("दुई पैसा"));
      expect(converter.convert(0.75, options: currencyOption),
          equals("पचहत्तर पैसा"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("दस लाख"));
      expect(converter.convert(BigInt.from(10).pow(7)), equals("एक करोड"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("दुई अर्ब"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(11)),
          equals("तीन खर्ब"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(13)),
          equals("चार नील"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(15)),
          equals("पाँच पद्म"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(17)),
          equals("छ शंख"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(19)),
          equals('सात महाशंख'));
      expect(
        converter.convert(BigInt.parse('98765432101234567')),
        equals(
            "अन्ठानब्बे पद्म छयहत्तर नील चौवन्न खर्ब बत्तीस अर्ब दस करोड बाह्र लाख चौँतीस हजार पाँच सय सड्सठी"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            'एक मध्य तेइस जल्ध पैंतालिस महाशंख सड्सठी शंख उनान्नब्बे पद्म बाह्र नील चौँतीस खर्ब छपन्न अर्ब अठहत्तर करोड एकानब्बे लाख तेइस हजार चार सय छपन्न'),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            'नौ मध्य उनान्सय जल्ध उनान्सय महाशंख उनान्सय शंख उनान्सय पद्म उनान्सय नील उनान्सय खर्ब उनान्सय अर्ब उनान्सय करोड उनान्सय लाख उनान्सय हजार नौ सय उनान्सय'),
      );

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('दस खर्ब बीस लाख तीन'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("पचास लाख एक हजार"));
      expect(
          converter.convert(BigInt.parse('1000000001')), equals("एक अर्ब एक"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals('एक अर्ब दस लाख'));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("बीस लाख एक हजार"));
      expect(converter.convert(BigInt.parse('1000987600003')),
          equals('दस खर्ब अन्ठानब्बे करोड छयहत्तर लाख तीन'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("संख्या होइन"));
      expect(converter.convert(double.infinity), equals("अनन्त"));
      expect(converter.convert(double.negativeInfinity), equals("माइनस अनन्त"));
      expect(converter.convert(null), equals("संख्या होइन"));
      expect(converter.convert('abc'), equals("संख्या होइन"));
      expect(converter.convert([]), equals("संख्या होइन"));
      expect(converter.convert({}), equals("संख्या होइन"));
      expect(converter.convert(Object()), equals("संख्या होइन"));

      expect(
          converterWithFallback.convert(double.nan), equals("अमान्य संख्या"));
      expect(converterWithFallback.convert(double.infinity), equals("अनन्त"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("माइनस अनन्त"));
      expect(converterWithFallback.convert(null), equals("अमान्य संख्या"));
      expect(converterWithFallback.convert('abc'), equals("अमान्य संख्या"));
      expect(converterWithFallback.convert([]), equals("अमान्य संख्या"));
      expect(converterWithFallback.convert({}), equals("अमान्य संख्या"));
      expect(converterWithFallback.convert(Object()), equals("अमान्य संख्या"));
      expect(converterWithFallback.convert(123), equals("एक सय तेइस"));
    });
  });
}
