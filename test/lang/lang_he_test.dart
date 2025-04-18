import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Hebrew (HE)', () {
    final converter = Num2Text(initialLang: Lang.HE);
    final converterWithFallback =
        Num2Text(initialLang: Lang.HE, fallbackOnError: "ערך לא תקין");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("אפס"));
      expect(converter.convert(1), equals("אחד"));
      expect(converter.convert(10), equals("עשרה"));
      expect(converter.convert(11), equals("אחד עשר"));
      expect(converter.convert(20), equals("עשרים"));
      expect(converter.convert(21), equals("עשרים ואחד"));
      expect(converter.convert(99), equals("תשעים ותשעה"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("מאה"));
      expect(converter.convert(101), equals("מאה ואחד"));
      expect(converter.convert(111), equals("מאה ואחד עשר"));
      expect(converter.convert(200), equals("מאתיים"));
      expect(converter.convert(999), equals("תשע מאות ותשעים ותשעה"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("אלף"));
      expect(converter.convert(1001), equals("אלף ואחד"));
      expect(converter.convert(1111), equals("אלף מאה ואחד עשר"));
      expect(converter.convert(2000), equals("אלפיים"));
      expect(converter.convert(10000), equals("עשרת אלפים"));
      expect(converter.convert(100000), equals("מאה אלף"));

      expect(converter.convert(123456),
          equals("מאה ועשרים ושלושה אלף ארבע מאות וחמישים ושישה"));
      expect(converter.convert(999999),
          equals("תשע מאות ותשעים ותשעה אלף תשע מאות ותשעים ותשעה"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("מינוס אחד"));
      expect(converter.convert(-123), equals("מינוס מאה ועשרים ושלושה"));
      expect(
        converter.convert(-1, options: HeOptions(negativePrefix: "שלילי")),
        equals("שלילי אחד"),
      );
      expect(
        converter.convert(-123, options: HeOptions(negativePrefix: "שלילי")),
        equals("שלילי מאה ועשרים ושלושה"),
      );
    });

    test('Year Formatting', () {
      const yearOption = HeOptions(format: Format.year);
      expect(
          converter.convert(1900, options: yearOption), equals("אלף תשע מאות"));
      expect(converter.convert(2024, options: yearOption),
          equals("אלפיים עשרים וארבעה"));

      expect(converter.convert(-100, options: yearOption), equals("מינוס מאה"));
      expect(converter.convert(-1, options: yearOption), equals("מינוס אחד"));
      expect(converter.convert(-2024, options: yearOption),
          equals("מינוס אלפיים עשרים וארבעה"));
    });

    test('Currency', () {
      const currencyOption = HeOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("אפס שקלים חדשים"));
      expect(
          converter.convert(1, options: currencyOption), equals("שקל חדש אחד"));
      expect(
        converter.convert(1.50, options: currencyOption),
        equals("שקל חדש אחד וחמישים אגורות"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("מאה ועשרים ושלושה שקלים חדשים וארבעים וחמש אגורות"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("מאה ועשרים ושלושה נקודה ארבע חמש שש"),
      );
      expect(converter.convert(Decimal.parse('1.50')), equals("אחד נקודה חמש"));

      expect(converter.convert(123.0), equals("מאה ועשרים ושלושה"));

      expect(converter.convert(Decimal.parse('123.0')),
          equals("מאה ועשרים ושלושה"));

      expect(
        converter.convert(1.5,
            options:
                const HeOptions(decimalSeparator: DecimalSeparator.period)),
        equals("אחד נקודה חמש"),
      );

      expect(
        converter.convert(1.5,
            options: const HeOptions(decimalSeparator: DecimalSeparator.point)),
        equals("אחד נקודה חמש"),
      );

      expect(
        converter.convert(1.5,
            options: const HeOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("אחד פסיק חמש"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("אינסוף"));
      expect(
          converter.convert(double.negativeInfinity), equals("אינסוף שלילי"));
      expect(converter.convert(double.nan), equals("לא מספר"));
      expect(converter.convert(null), equals("לא מספר"));
      expect(converter.convert('abc'), equals("לא מספר"));

      expect(converterWithFallback.convert(double.infinity), equals("אינסוף"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("אינסוף שלילי"));
      expect(converterWithFallback.convert(double.nan), equals("ערך לא תקין"));
      expect(converterWithFallback.convert(null), equals("ערך לא תקין"));
      expect(converterWithFallback.convert('abc'), equals("ערך לא תקין"));
      expect(converterWithFallback.convert(123), equals("מאה ועשרים ושלושה"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("מיליון"));
      expect(converter.convert(BigInt.from(1000000000)), equals("מיליארד"));
      expect(converter.convert(BigInt.from(1000000000000)), equals("טריליון"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("קוודריליון"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("קווינטיליון"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("סקסטיליון"));
      expect(converter.convert(BigInt.parse('1000000000000000000000000')),
          equals("ספטיליון"));
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "מאה ועשרים ושלושה סקסטיליון וארבע מאות וחמישים ושישה קווינטיליון ושבע מאות ושמונים ותשעה קוודריליון ומאה ועשרים ושלושה טריליון וארבע מאות וחמישים ושישה מיליארד ושבע מאות ושמונים ותשעה מיליון ומאה ועשרים ושלושה אלף ארבע מאות וחמישים ושישה",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "תשע מאות ותשעים ותשעה סקסטיליון ותשע מאות ותשעים ותשעה קווינטיליון ותשע מאות ותשעים ותשעה קוודריליון ותשע מאות ותשעים ותשעה טריליון ותשע מאות ותשעים ותשעה מיליארד ותשע מאות ותשעים ותשעה מיליון ותשע מאות ותשעים ותשעה אלף תשע מאות ותשעים ותשעה",
        ),
      );
    });
  });
}
