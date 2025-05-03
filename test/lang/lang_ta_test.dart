import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Tamil (TA)', () {
    final converter = Num2Text(initialLang: Lang.TA);
    final converterWithFallback =
        Num2Text(initialLang: Lang.TA, fallbackOnError: "தவறான எண்");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("பூஜ்ஜியம்"));
      expect(converter.convert(10), equals("பத்து"));
      expect(converter.convert(11), equals("பதினொன்று"));
      expect(converter.convert(13), equals("பதின்மூன்று"));
      expect(converter.convert(15), equals("பதினைந்து"));
      expect(converter.convert(20), equals("இருபது"));
      expect(converter.convert(27), equals("இருபத்தி ஏழு"));
      expect(converter.convert(30), equals("முப்பது"));
      expect(converter.convert(54), equals("ஐம்பத்தி நான்கு"));
      expect(converter.convert(68), equals("அறுபத்தி எட்டு"));
      expect(converter.convert(99), equals("தொண்ணூற்றி ஒன்பது"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("நூறு"));
      expect(converter.convert(101), equals("நூற்றி ஒன்று"));
      expect(converter.convert(105), equals("நூற்றி ஐந்து"));
      expect(converter.convert(110), equals("நூற்றி பத்து"));
      expect(converter.convert(111), equals("நூற்றி பதினொன்று"));
      expect(converter.convert(123), equals("நூற்றி இருபத்தி மூன்று"));
      expect(converter.convert(200), equals("இருநூறு"));
      expect(converter.convert(321), equals("முந்நூற்று இருபத்தி ஒன்று"));
      expect(converter.convert(479), equals("நானூற்று எழுபத்தி ஒன்பது"));
      expect(converter.convert(596), equals("ஐந்நூற்று தொண்ணூற்றி ஆறு"));
      expect(converter.convert(681), equals("அறுநூற்று எண்பத்தி ஒன்று"));
      expect(converter.convert(999), equals("தொள்ளாயிரத்து தொண்ணூற்றி ஒன்பது"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("ஆயிரம்"));
      expect(converter.convert(1001), equals("ஆயிரத்தி ஒன்று"));
      expect(converter.convert(1011), equals("ஆயிரத்தி பதினொன்று"));
      expect(converter.convert(1110), equals("ஆயிரத்து நூற்றி பத்து"));
      expect(converter.convert(1111), equals("ஆயிரத்து நூற்றி பதினொன்று"));
      expect(converter.convert(2000), equals("இரண்டாயிரம்"));
      expect(converter.convert(2468),
          equals("இரண்டாயிரத்து நானூற்று அறுபத்தி எட்டு"));
      expect(converter.convert(3579),
          equals("மூவாயிரத்து ஐந்நூற்று எழுபத்தி ஒன்பது"));
      expect(converter.convert(10000), equals("பத்தாயிரம்"));
      expect(converter.convert(10011), equals("பத்தாயிரத்து பதினொன்று"));
      expect(converter.convert(11100), equals("பதினோறாயிரத்து நூறு"));
      expect(converter.convert(12987),
          equals("பன்னிரண்டாயிரத்து தொள்ளாயிரத்து எண்பத்தி ஏழு"));
      expect(converter.convert(45623),
          equals("நாற்பத்தி ஐயாயிரத்து அறுநூற்று இருபத்தி மூன்று"));
      expect(converter.convert(87654),
          equals("எண்பத்தி ஏழாயிரத்து அறுநூற்று ஐம்பத்தி நான்கு"));
      expect(converter.convert(100000), equals("ஒரு லட்சம்"));
      expect(converter.convert(123456),
          equals("ஒரு லட்சத்து இருபத்தி மூவாயிரத்து நானூற்று ஐம்பத்தி ஆறு"));
      expect(
          converter.convert(987654),
          equals(
              "ஒன்பது லட்சத்து எண்பத்தி ஏழாயிரத்து அறுநூற்று ஐம்பத்தி நான்கு"));
      expect(
          converter.convert(999999),
          equals(
              "ஒன்பது லட்சத்து தொண்ணூற்றி ஒன்பதாயிரத்து தொள்ளாயிரத்து தொண்ணூற்றி ஒன்பது"));
    });

    test('Negative Numbers', () {
      const negativeOption = TaOptions(negativePrefix: "எதிர்மறை");
      expect(converter.convert(-1), equals("கழித்தல் ஒன்று"));
      expect(
          converter.convert(-123), equals("கழித்தல் நூற்றி இருபத்தி மூன்று"));
      expect(converter.convert(-123.456),
          equals("கழித்தல் நூற்றி இருபத்தி மூன்று புள்ளி நான்கு ஐந்து ஆறு"));
      expect(converter.convert(-1, options: negativeOption),
          equals("எதிர்மறை ஒன்று"));
      expect(converter.convert(-123, options: negativeOption),
          equals("எதிர்மறை நூற்றி இருபத்தி மூன்று"));
      expect(
        converter.convert(-123.456, options: negativeOption),
        equals("எதிர்மறை நூற்றி இருபத்தி மூன்று புள்ளி நான்கு ஐந்து ஆறு"),
      );
    });

    test('Decimals', () {
      const commaOption = TaOptions(decimalSeparator: DecimalSeparator.comma);
      const pointOption = TaOptions(decimalSeparator: DecimalSeparator.point);
      const periodOption = TaOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(123.456),
          equals("நூற்றி இருபத்தி மூன்று புள்ளி நான்கு ஐந்து ஆறு"));
      expect(converter.convert(1.5), equals("ஒன்று புள்ளி ஐந்து"));
      expect(converter.convert(1.05), equals("ஒன்று புள்ளி பூஜ்ஜியம் ஐந்து"));
      expect(converter.convert(879.465),
          equals("எண்ணூற்று எழுபத்தி ஒன்பது புள்ளி நான்கு ஆறு ஐந்து"));
      expect(converter.convert(1.5, options: pointOption),
          equals("ஒன்று புள்ளி ஐந்து"));
      expect(converter.convert(1.5, options: commaOption),
          equals("ஒன்று காற்புள்ளி ஐந்து"));
      expect(converter.convert(1.5, options: periodOption),
          equals("ஒன்று புள்ளி ஐந்து"));
    });

    test('Year Formatting', () {
      const yearOption = TaOptions(format: Format.year);
      const yearOptionAD = TaOptions(format: Format.year, includeAD: true);
      expect(converter.convert(123, options: yearOption),
          equals("நூற்றி இருபத்தி மூன்று"));
      expect(converter.convert(498, options: yearOption),
          equals("நானூற்று தொண்ணூற்றி எட்டு"));
      expect(converter.convert(756, options: yearOption),
          equals("எழுநூற்று ஐம்பத்தி ஆறு"));
      expect(converter.convert(1900, options: yearOption),
          equals("ஆயிரத்து தொள்ளாயிரம்"));
      expect(converter.convert(1999, options: yearOption),
          equals("ஆயிரத்து தொள்ளாயிரத்து தொண்ணூற்றி ஒன்பது"));
      expect(converter.convert(2025, options: yearOption),
          equals("இரண்டாயிரத்து இருபத்தி ஐந்து"));
      expect(converter.convert(1900, options: yearOptionAD),
          equals("ஆயிரத்து தொள்ளாயிரம் கி.பி."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("ஆயிரத்து தொள்ளாயிரத்து தொண்ணூற்றி ஒன்பது கி.பி."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("இரண்டாயிரத்து இருபத்தி ஐந்து கி.பி."));
      expect(
          converter.convert(-1, options: yearOption), equals("ஒன்று கி.மு."));
      expect(
          converter.convert(-100, options: yearOption), equals("நூறு கி.மு."));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("நூறு கி.மு."));
      expect(converter.convert(-2025, options: yearOption),
          equals("இரண்டாயிரத்து இருபத்தி ஐந்து கி.மு."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("பத்து லட்சம் கி.மு."));
    });

    test('Currency', () {
      const currencyOption = TaOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("பூஜ்ஜியம் ரூபாய்"));
      expect(
          converter.convert(1, options: currencyOption), equals("ஒரு ரூபாய்"));
      expect(converter.convert(5, options: currencyOption),
          equals("ஐந்து ரூபாய்"));
      expect(converter.convert(10, options: currencyOption),
          equals("பத்து ரூபாய்"));
      expect(converter.convert(11, options: currencyOption),
          equals("பதினொன்று ரூபாய்"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("ஒரு ரூபாய் மற்றும் ஐம்பது பைசா"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("நூற்றி இருபத்தி மூன்று ரூபாய் மற்றும் நாற்பத்தி ஐந்து பைசா"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("ஒரு கோடி ரூபாய்"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("ஐம்பது பைசா"));
      expect(
          converter.convert(0.01, options: currencyOption), equals("ஒரு பைசா"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("ஐந்து பைசா"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("ஒரு ரூபாய் மற்றும் ஒரு பைசா"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(7)), equals("ஒரு கோடி"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(8)),
          equals("இருபது கோடி"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(9)),
          equals("முந்நூறு கோடி"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(10)),
          equals("நான்காயிரம் கோடி"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(11)),
          equals("ஐம்பதாயிரம் கோடி"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(12)),
          equals("ஆறு லட்சம் கோடி"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(13)),
          equals("எழுபது லட்சம் கோடி"));
      expect(converter.convert(BigInt.from(8) * BigInt.from(10).pow(14)),
          equals("எட்டு கோடி கோடி"));
      expect(converter.convert(BigInt.from(9) * BigInt.from(10).pow(15)),
          equals("தொண்ணூறு கோடி கோடி"));
      expect(converter.convert(BigInt.from(1) * BigInt.from(10).pow(16)),
          equals("நூறு கோடி கோடி"));
      expect(converter.convert(BigInt.from(1) * BigInt.from(10).pow(17)),
          equals("ஆயிரம் கோடி கோடி"));
      expect(converter.convert(BigInt.from(1) * BigInt.from(10).pow(18)),
          equals("பத்தாயிரம் கோடி கோடி"));
      expect(converter.convert(BigInt.from(1) * BigInt.from(10).pow(19)),
          equals("ஒரு லட்சம் கோடி கோடி"));
      expect(converter.convert(BigInt.from(1) * BigInt.from(10).pow(20)),
          equals("பத்து லட்சம் கோடி கோடி"));
      expect(converter.convert(BigInt.from(1) * BigInt.from(10).pow(21)),
          equals("ஒரு கோடி கோடி கோடி"));
      expect(converter.convert(BigInt.from(1) * BigInt.from(10).pow(22)),
          equals("பத்து கோடி கோடி கோடி"));
      expect(converter.convert(BigInt.from(1) * BigInt.from(10).pow(23)),
          equals("நூறு கோடி கோடி கோடி"));
      expect(converter.convert(BigInt.from(1) * BigInt.from(10).pow(24)),
          equals("ஆயிரம் கோடி கோடி கோடி"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            'தொண்ணூற்றி எண்ணாயிரத்து எழுநூற்று அறுபத்தி ஐந்து கோடி கோடியே நாற்பத்தி மூன்று லட்சத்து இருபத்தி ஓராயிரத்து பன்னிரண்டு கோடியே முப்பத்தி நான்கு லட்சத்து ஐம்பத்தி ஆறாயிரத்து எழுநூற்று எண்பத்தி ஒன்பது'),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            'நூற்றி இருபத்தி மூன்று கோடி கோடி கோடியே நாற்பத்தி ஐந்து லட்சத்து அறுபத்தி ஏழாயிரத்து எண்ணூற்று தொண்ணூற்றி ஒன்று கோடி கோடியே இருபத்தி மூன்று லட்சத்து நாற்பத்தி ஐயாயிரத்து அறுநூற்று எழுபத்தி எட்டு கோடியே தொண்ணூற்றி ஒன்று லட்சத்து இருபத்தி மூவாயிரத்து நானூற்று ஐம்பத்தி ஆறு'),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            'தொள்ளாயிரத்து தொண்ணூற்றி ஒன்பது கோடி கோடி கோடியே தொண்ணூற்றி ஒன்பது லட்சத்து தொண்ணூற்றி ஒன்பதாயிரத்து தொள்ளாயிரத்து தொண்ணூற்றி ஒன்பது கோடி கோடியே தொண்ணூற்றி ஒன்பது லட்சத்து தொண்ணூற்றி ஒன்பதாயிரத்து தொள்ளாயிரத்து தொண்ணூற்றி ஒன்பது கோடியே தொண்ணூற்றி ஒன்பது லட்சத்து தொண்ணூற்றி ஒன்பதாயிரத்து தொள்ளாயிரத்து தொண்ணூற்றி ஒன்பது'),
      );
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('ஒரு லட்சம் கோடியே இருபது லட்சத்து மூன்று'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("ஐம்பது லட்சத்து ஆயிரம்"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("நூறு கோடியே ஒன்று"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("நூறு கோடியே பத்து லட்சம்"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("இருபது லட்சத்து ஆயிரம்"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              'ஒரு லட்சத்து தொண்ணூற்றி எட்டு கோடியே எழுபத்தி ஆறு லட்சத்து மூன்று'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("எண் அல்ல"));
      expect(converter.convert(double.infinity), equals("முடிவிலி"));
      expect(converter.convert(double.negativeInfinity),
          equals("எதிர்மறை முடிவிலி"));
      expect(converter.convert(null), equals("எண் அல்ல"));
      expect(converter.convert('abc'), equals("எண் அல்ல"));
      expect(converter.convert([]), equals("எண் அல்ல"));
      expect(converter.convert({}), equals("எண் அல்ல"));
      expect(converter.convert(Object()), equals("எண் அல்ல"));
      expect(converterWithFallback.convert(double.nan), equals("தவறான எண்"));
      expect(
          converterWithFallback.convert(double.infinity), equals("முடிவிலி"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("எதிர்மறை முடிவிலி"));
      expect(converterWithFallback.convert(null), equals("தவறான எண்"));
      expect(converterWithFallback.convert('abc'), equals("தவறான எண்"));
      expect(converterWithFallback.convert([]), equals("தவறான எண்"));
      expect(converterWithFallback.convert({}), equals("தவறான எண்"));
      expect(converterWithFallback.convert(Object()), equals("தவறான எண்"));
      expect(
          converterWithFallback.convert(123), equals("நூற்றி இருபத்தி மூன்று"));
    });
  });
}
