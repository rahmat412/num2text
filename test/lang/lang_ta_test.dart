import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Tamil (TA)', () {
    final converter = Num2Text(initialLang: Lang.TA);
    final converterWithFallback =
        Num2Text(initialLang: Lang.TA, fallbackOnError: "தவறான எண்");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("பூஜ்ஜியம்"));
      expect(converter.convert(1), equals("ஒன்று"));
      expect(converter.convert(10), equals("பத்து"));
      expect(converter.convert(11), equals("பதினொன்று"));
      expect(converter.convert(20), equals("இருபது"));
      expect(converter.convert(21), equals("இருபத்தி ஒன்று"));
      expect(converter.convert(99), equals("தொண்ணூற்றி ஒன்பது"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("நூறு"));
      expect(converter.convert(101), equals("நூற்றி ஒன்று"));
      expect(converter.convert(111), equals("நூற்றி பதினொன்று"));
      expect(converter.convert(200), equals("இருநூறு"));
      expect(converter.convert(999), equals("தொள்ளாயிரத்து தொண்ணூற்றி ஒன்பது"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("ஆயிரம்"));
      expect(converter.convert(1001), equals("ஆயிரத்தி ஒன்று"));
      expect(converter.convert(1111), equals("ஆயிரத்து நூற்றி பதினொன்று"));
      expect(converter.convert(2000), equals("இரண்டாயிரம்"));
      expect(converter.convert(10000), equals("பத்தாயிரம்"));
      expect(converter.convert(100000), equals("ஒரு லட்சம்"));
      expect(converter.convert(1000000), equals("பத்து லட்சம்"));
      expect(converter.convert(10000000), equals("ஒரு கோடி"));
      expect(converter.convert(100000000), equals("பத்து கோடி"));
      expect(converter.convert(1000000000), equals("நூறு கோடி"));
      expect(converter.convert(10000000000), equals("ஆயிரம் கோடி"));
      expect(converter.convert(100000000000), equals("பத்தாயிரம் கோடி"));
      expect(converter.convert(1000000000000), equals("ஒரு லட்சம் கோடி"));

      expect(
        converter.convert(123456),
        equals("ஒரு லட்சத்து இருபத்தி மூவாயிரத்து நானூற்று ஐம்பத்தி ஆறு"),
      );
      expect(
        converter.convert(1234567),
        equals(
            "பன்னிரண்டு லட்சத்து முப்பத்தி நான்காயிரத்து ஐந்நூற்று அறுபத்தி ஏழு"),
      );
      expect(
        converter.convert(12345678),
        equals(
            "ஒரு கோடியே இருபத்தி மூன்று லட்சத்து நாற்பத்தி ஐயாயிரத்து அறுநூற்று எழுபத்தி எட்டு"),
      );
      expect(
        converter.convert(123456789),
        equals(
          "பன்னிரண்டு கோடியே முப்பத்தி நான்கு லட்சத்து ஐம்பத்தி ஆறாயிரத்து எழுநூற்று எண்பத்தி ஒன்பது",
        ),
      );
      expect(
        converter.convert(999999),
        equals(
            "ஒன்பது லட்சத்து தொண்ணூற்றி ஒன்பதாயிரத்து தொள்ளாயிரத்து தொண்ணூற்றி ஒன்பது"),
      );
      expect(
        converter.convert(9999999),
        equals(
          "தொண்ணூற்றி ஒன்பது லட்சத்து தொண்ணூற்றி ஒன்பதாயிரத்து தொள்ளாயிரத்து தொண்ணூற்றி ஒன்பது",
        ),
      );
      expect(
        converter.convert(999999999),
        equals(
          "தொண்ணூற்றி ஒன்பது கோடியே தொண்ணூற்றி ஒன்பது லட்சத்து தொண்ணூற்றி ஒன்பதாயிரத்து தொள்ளாயிரத்து தொண்ணூற்றி ஒன்பது",
        ),
      );
    });

    test('Scale Numbers (Indian System)', () {
      expect(converter.convert(BigInt.parse('10000000000000')),
          equals("பத்து லட்சம் கோடி"));
      expect(converter.convert(BigInt.parse('100000000000000')),
          equals("ஒரு கோடி கோடி"));
      expect(converter.convert(BigInt.parse('1000000000000000')),
          equals("பத்து கோடி கோடி"));
      expect(converter.convert(BigInt.parse('10000000000000000')),
          equals("நூறு கோடி கோடி"));
      expect(converter.convert(BigInt.parse('100000000000000000')),
          equals("ஆயிரம் கோடி கோடி"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000')),
        equals("பத்தாயிரம் கோடி கோடி"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          'நூற்றி இருபத்தி மூன்று கோடியே கோடி கோடி நாற்பத்தி ஐந்து லட்சத்து கோடி கோடி அறுபத்தி ஏழாயிரத்து எண்ணூற்று தொண்ணூற்றி ஒன்று கோடியே கோடி இருபத்தி மூன்று லட்சத்து நாற்பத்தி ஐயாயிரத்து அறுநூற்று எழுபத்தி எட்டு கோடியே தொண்ணூற்றி ஒன்று லட்சத்து இருபத்தி மூவாயிரத்து நானூற்று ஐம்பத்தி ஆறு',
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          'தொள்ளாயிரத்து தொண்ணூற்றி ஒன்பது கோடியே கோடி கோடி தொண்ணூற்றி ஒன்பது லட்சத்து கோடி கோடி தொண்ணூற்றி ஒன்பதாயிரத்து தொள்ளாயிரத்து தொண்ணூற்றி ஒன்பது கோடியே கோடி தொண்ணூற்றி ஒன்பது லட்சத்து தொண்ணூற்றி ஒன்பதாயிரத்து தொள்ளாயிரத்து தொண்ணூற்றி ஒன்பது கோடியே தொண்ணூற்றி ஒன்பது லட்சத்து தொண்ணூற்றி ஒன்பதாயிரத்து தொள்ளாயிரத்து தொண்ணூற்றி ஒன்பது',
        ),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("கழித்தல் ஒன்று"));
      expect(
          converter.convert(-123), equals("கழித்தல் நூற்றி இருபத்தி மூன்று"));
      expect(
        converter.convert(-1,
            options: const TaOptions(negativePrefix: "எதிர்மறை")),
        equals("எதிர்மறை ஒன்று"),
      );
      expect(
        converter.convert(-123,
            options: const TaOptions(negativePrefix: "எதிர்மறை")),
        equals("எதிர்மறை நூற்றி இருபத்தி மூன்று"),
      );
    });

    test('Year Formatting', () {
      const yearOption = TaOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("ஆயிரத்து தொள்ளாயிரம்"));
      expect(converter.convert(2024, options: yearOption),
          equals("இரண்டாயிரத்து இருபத்தி நான்கு"));
      expect(
        converter.convert(1900,
            options: const TaOptions(format: Format.year, includeAD: true)),
        equals("ஆயிரத்து தொள்ளாயிரம் கி.பி."),
      );
      expect(
        converter.convert(2024,
            options: const TaOptions(format: Format.year, includeAD: true)),
        equals("இரண்டாயிரத்து இருபத்தி நான்கு கி.பி."),
      );
      expect(
          converter.convert(-100, options: yearOption), equals("நூறு கி.மு."));
      expect(
          converter.convert(-1, options: yearOption), equals("ஒன்று கி.மு."));
      expect(
        converter.convert(-2024, options: const TaOptions(format: Format.year)),
        equals("இரண்டாயிரத்து இருபத்தி நான்கு கி.மு."),
      );
    });

    test('Currency', () {
      const currencyOption = TaOptions(currency: true);

      expect(converter.convert(0, options: currencyOption),
          equals("பூஜ்ஜியம் ரூபாய்"));
      expect(
          converter.convert(1, options: currencyOption), equals("ஒரு ரூபாய்"));
      expect(
        converter.convert(1.01, options: currencyOption),
        equals("ஒரு ரூபாய் மற்றும் ஒரு பைசா"),
      );
      expect(
        converter.convert(1.50, options: currencyOption),
        equals("ஒரு ரூபாய் மற்றும் ஐம்பது பைசா"),
      );
      expect(converter.convert(2, options: currencyOption),
          equals("இரண்டு ரூபாய்"));
      expect(
        converter.convert(2.50, options: currencyOption),
        equals("இரண்டு ரூபாய் மற்றும் ஐம்பது பைசா"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("நூற்றி இருபத்தி மூன்று ரூபாய் மற்றும் நாற்பத்தி ஐந்து பைசா"),
      );

      expect(
        converter.convert(1234567.89, options: currencyOption),
        equals(
          "பன்னிரண்டு லட்சத்து முப்பத்தி நான்காயிரத்து ஐந்நூற்று அறுபத்தி ஏழு ரூபாய் மற்றும் எண்பத்தி ஒன்பது பைசா",
        ),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("நூற்றி இருபத்தி மூன்று புள்ளி நான்கு ஐந்து ஆறு"),
      );
      expect(converter.convert(Decimal.parse('1.50')),
          equals("ஒன்று புள்ளி ஐந்து"));
      expect(converter.convert(123.0), equals("நூற்றி இருபத்தி மூன்று"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("நூற்றி இருபத்தி மூன்று"));
      expect(
        converter.convert(1.5,
            options: const TaOptions(decimalSeparator: DecimalSeparator.point)),
        equals("ஒன்று புள்ளி ஐந்து"),
      );
      expect(
        converter.convert(1.5,
            options: const TaOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("ஒன்று காற்புள்ளி ஐந்து"),
      );

      expect(converter.convert(Decimal.parse('0.12')),
          equals("பூஜ்ஜியம் புள்ளி ஒன்று இரண்டு"));
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("முடிவிலி"));
      expect(converter.convert(double.negativeInfinity),
          equals("எதிர்மறை முடிவிலி"));
      expect(converter.convert(double.nan), equals("எண் அல்ல"));
      expect(converter.convert(null), equals("எண் அல்ல"));
      expect(converter.convert('abc'), equals("எண் அல்ல"));

      expect(
          converterWithFallback.convert(double.infinity), equals("முடிவிலி"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("எதிர்மறை முடிவிலி"));
      expect(converterWithFallback.convert(double.nan), equals("தவறான எண்"));
      expect(converterWithFallback.convert(null), equals("தவறான எண்"));
      expect(converterWithFallback.convert('abc'), equals("தவறான எண்"));
      expect(
          converterWithFallback.convert(123), equals("நூற்றி இருபத்தி மூன்று"));
    });
  });
}
