import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Hebrew (HE)', () {
    final converter = Num2Text(initialLang: Lang.HE);
    final converterWithFallback =
        Num2Text(initialLang: Lang.HE, fallbackOnError: "ערך לא תקין");

    test('Basic Numbers (0 - 99 Masculine)', () {
      expect(
          converter.convert(0,
              options: const HeOptions(gender: Gender.masculine)),
          equals("אפס"));
      expect(
          converter.convert(10,
              options: const HeOptions(gender: Gender.masculine)),
          equals("עשרה"));
      expect(
          converter.convert(11,
              options: const HeOptions(gender: Gender.masculine)),
          equals("אחד עשר"));
      expect(
          converter.convert(13,
              options: const HeOptions(gender: Gender.masculine)),
          equals("שלושה עשר"));
      expect(
          converter.convert(15,
              options: const HeOptions(gender: Gender.masculine)),
          equals("חמישה עשר"));
      expect(
          converter.convert(20,
              options: const HeOptions(gender: Gender.masculine)),
          equals("עשרים"));
      expect(
          converter.convert(27,
              options: const HeOptions(gender: Gender.masculine)),
          equals("עשרים ושבעה"));
      expect(
          converter.convert(30,
              options: const HeOptions(gender: Gender.masculine)),
          equals("שלושים"));
      expect(
          converter.convert(54,
              options: const HeOptions(gender: Gender.masculine)),
          equals("חמישים וארבעה"));
      expect(
          converter.convert(68,
              options: const HeOptions(gender: Gender.masculine)),
          equals("שישים ושמונה"));
      expect(
          converter.convert(99,
              options: const HeOptions(gender: Gender.masculine)),
          equals("תשעים ותשעה"));
    });

    test('Basic Numbers (0 - 99 Feminine)', () {
      expect(
          converter.convert(0,
              options: const HeOptions(gender: Gender.feminine)),
          equals("אפס"));
      expect(
          converter.convert(10,
              options: const HeOptions(gender: Gender.feminine)),
          equals("עשר"));
      expect(
          converter.convert(11,
              options: const HeOptions(gender: Gender.feminine)),
          equals("אחת עשרה"));
      expect(
          converter.convert(13,
              options: const HeOptions(gender: Gender.feminine)),
          equals("שלוש עשרה"));
      expect(
          converter.convert(15,
              options: const HeOptions(gender: Gender.feminine)),
          equals("חמש עשרה"));
      expect(
          converter.convert(20,
              options: const HeOptions(gender: Gender.feminine)),
          equals("עשרים"));
      expect(
          converter.convert(27,
              options: const HeOptions(gender: Gender.feminine)),
          equals("עשרים ושבע"));
      expect(
          converter.convert(30,
              options: const HeOptions(gender: Gender.feminine)),
          equals("שלושים"));
      expect(
          converter.convert(54,
              options: const HeOptions(gender: Gender.feminine)),
          equals("חמישים וארבע"));
      expect(
          converter.convert(68,
              options: const HeOptions(gender: Gender.feminine)),
          equals("שישים ושמונֶה"));
      expect(
          converter.convert(99,
              options: const HeOptions(gender: Gender.feminine)),
          equals("תשעים ותשע"));
    });

    test('Hundreds (100 - 999 Masculine)', () {
      expect(
          converter.convert(100,
              options: const HeOptions(gender: Gender.masculine)),
          equals("מאה"));
      expect(
          converter.convert(101,
              options: const HeOptions(gender: Gender.masculine)),
          equals("מאה ואחד"));
      expect(
          converter.convert(105,
              options: const HeOptions(gender: Gender.masculine)),
          equals("מאה וחמישה"));
      expect(
          converter.convert(110,
              options: const HeOptions(gender: Gender.masculine)),
          equals("מאה ועשרה"));
      expect(
          converter.convert(111,
              options: const HeOptions(gender: Gender.masculine)),
          equals("מאה ואחד עשר"));
      expect(
          converter.convert(123,
              options: const HeOptions(gender: Gender.masculine)),
          equals("מאה ועשרים ושלושה"));
      expect(
          converter.convert(200,
              options: const HeOptions(gender: Gender.masculine)),
          equals("מאתיים"));
      expect(
          converter.convert(321,
              options: const HeOptions(gender: Gender.masculine)),
          equals("שלוש מאות עשרים ואחד"));
      expect(
          converter.convert(479,
              options: const HeOptions(gender: Gender.masculine)),
          equals("ארבע מאות שבעים ותשעה"));
      expect(
          converter.convert(596,
              options: const HeOptions(gender: Gender.masculine)),
          equals("חמש מאות תשעים ושישה"));
      expect(
          converter.convert(681,
              options: const HeOptions(gender: Gender.masculine)),
          equals("שש מאות שמונים ואחד"));
      expect(
          converter.convert(999,
              options: const HeOptions(gender: Gender.masculine)),
          equals("תשע מאות תשעים ותשעה"));
    });

    test('Hundreds (100 - 999 Feminine)', () {
      expect(
          converter.convert(100,
              options: const HeOptions(gender: Gender.feminine)),
          equals("מאה"));
      expect(
          converter.convert(101,
              options: const HeOptions(gender: Gender.feminine)),
          equals("מאה ואחת"));
      expect(
          converter.convert(105,
              options: const HeOptions(gender: Gender.feminine)),
          equals("מאה וחמש"));
      expect(
          converter.convert(110,
              options: const HeOptions(gender: Gender.feminine)),
          equals("מאה ועשר"));
      expect(
          converter.convert(111,
              options: const HeOptions(gender: Gender.feminine)),
          equals("מאה ואחת עשרה"));
      expect(
          converter.convert(123,
              options: const HeOptions(gender: Gender.feminine)),
          equals("מאה ועשרים ושלוש"));
      expect(
          converter.convert(200,
              options: const HeOptions(gender: Gender.feminine)),
          equals("מאתיים"));
      expect(
          converter.convert(321,
              options: const HeOptions(gender: Gender.feminine)),
          equals("שלוש מאות עשרים ואחת"));
      expect(
          converter.convert(479,
              options: const HeOptions(gender: Gender.feminine)),
          equals("ארבע מאות שבעים ותשע"));
      expect(
          converter.convert(596,
              options: const HeOptions(gender: Gender.feminine)),
          equals("חמש מאות תשעים ושש"));
      expect(
          converter.convert(681,
              options: const HeOptions(gender: Gender.feminine)),
          equals("שש מאות שמונים ואחת"));
      expect(
          converter.convert(999,
              options: const HeOptions(gender: Gender.feminine)),
          equals("תשע מאות תשעים ותשע"));
    });

    test('Thousands (1000 - 999999 Masculine)', () {
      expect(
          converter.convert(1000,
              options: const HeOptions(gender: Gender.masculine)),
          equals("אלף"));
      expect(
          converter.convert(1001,
              options: const HeOptions(gender: Gender.masculine)),
          equals("אלף ואחד"));
      expect(
          converter.convert(1011,
              options: const HeOptions(gender: Gender.masculine)),
          equals("אלף ואחד עשר"));
      expect(
          converter.convert(1110,
              options: const HeOptions(gender: Gender.masculine)),
          equals("אלף מאה ועשרה"));
      expect(
          converter.convert(1111,
              options: const HeOptions(gender: Gender.masculine)),
          equals("אלף מאה ואחד עשר"));
      expect(
          converter.convert(2000,
              options: const HeOptions(gender: Gender.masculine)),
          equals("אלפיים"));
      expect(
          converter.convert(2468,
              options: const HeOptions(gender: Gender.masculine)),
          equals("אלפיים וארבע מאות שישים ושמונה"));
      expect(
          converter.convert(3579,
              options: const HeOptions(gender: Gender.masculine)),
          equals("שלושת אלפים וחמש מאות שבעים ותשעה"));
      expect(
          converter.convert(10000,
              options: const HeOptions(gender: Gender.masculine)),
          equals("עשרת אלפים"));
      expect(
          converter.convert(10011,
              options: const HeOptions(gender: Gender.masculine)),
          equals("עשרת אלפים ואחד עשר"));
      expect(
          converter.convert(11100,
              options: const HeOptions(gender: Gender.masculine)),
          equals("אחד עשר אלף ומאה"));
      expect(
          converter.convert(12987,
              options: const HeOptions(gender: Gender.masculine)),
          equals("שנים עשר אלף ותשע מאות שמונים ושבעה"));
      expect(
          converter.convert(45623,
              options: const HeOptions(gender: Gender.masculine)),
          equals("ארבעים וחמישה אלף ושש מאות עשרים ושלושה"));
      expect(
          converter.convert(87654,
              options: const HeOptions(gender: Gender.masculine)),
          equals("שמונים ושבעה אלף ושש מאות חמישים וארבעה"));
      expect(
          converter.convert(100000,
              options: const HeOptions(gender: Gender.masculine)),
          equals("מאה אלף"));
      expect(
          converter.convert(123456,
              options: const HeOptions(gender: Gender.masculine)),
          equals("מאה ועשרים ושלושה אלף וארבע מאות חמישים ושישה"));
      expect(
          converter.convert(987654,
              options: const HeOptions(gender: Gender.masculine)),
          equals("תשע מאות שמונים ושבעה אלף ושש מאות חמישים וארבעה"));
      expect(
          converter.convert(999999,
              options: const HeOptions(gender: Gender.masculine)),
          equals("תשע מאות תשעים ותשעה אלף ותשע מאות תשעים ותשעה"));
    });

    test('Thousands (1000 - 999999 Feminine)', () {
      expect(
          converter.convert(1000,
              options: const HeOptions(gender: Gender.feminine)),
          equals("אלף"));
      expect(
          converter.convert(1001,
              options: const HeOptions(gender: Gender.feminine)),
          equals("אלף ואחת"));
      expect(
          converter.convert(1011,
              options: const HeOptions(gender: Gender.feminine)),
          equals("אלף ואחת עשרה"));
      expect(
          converter.convert(1110,
              options: const HeOptions(gender: Gender.feminine)),
          equals("אלף מאה ועשר"));
      expect(
          converter.convert(1111,
              options: const HeOptions(gender: Gender.feminine)),
          equals("אלף מאה ואחת עשרה"));
      expect(
          converter.convert(2000,
              options: const HeOptions(gender: Gender.feminine)),
          equals("אלפיים"));
      expect(
          converter.convert(2468,
              options: const HeOptions(gender: Gender.feminine)),
          equals("אלפיים וארבע מאות שישים ושמונֶה"));
      expect(
          converter.convert(3579,
              options: const HeOptions(gender: Gender.feminine)),
          equals("שלושת אלפים וחמש מאות שבעים ותשע"));
      expect(
          converter.convert(10000,
              options: const HeOptions(gender: Gender.feminine)),
          equals("עשרת אלפים"));
      expect(
          converter.convert(10011,
              options: const HeOptions(gender: Gender.feminine)),
          equals("עשרת אלפים ואחת עשרה"));
      expect(
          converter.convert(11100,
              options: const HeOptions(gender: Gender.feminine)),
          equals("אחד עשר אלף ומאה"));
      expect(
          converter.convert(12987,
              options: const HeOptions(gender: Gender.feminine)),
          equals("שנים עשר אלף ותשע מאות שמונים ושבע"));
      expect(
          converter.convert(45623,
              options: const HeOptions(gender: Gender.feminine)),
          equals("ארבעים וחמישה אלף ושש מאות עשרים ושלוש"));
      expect(
          converter.convert(87654,
              options: const HeOptions(gender: Gender.feminine)),
          equals("שמונים ושבעה אלף ושש מאות חמישים וארבע"));
      expect(
          converter.convert(100000,
              options: const HeOptions(gender: Gender.feminine)),
          equals("מאה אלף"));
      expect(
          converter.convert(123456,
              options: const HeOptions(gender: Gender.feminine)),
          equals("מאה ועשרים ושלושה אלף וארבע מאות חמישים ושש"));
      expect(
          converter.convert(987654,
              options: const HeOptions(gender: Gender.feminine)),
          equals("תשע מאות שמונים ושבעה אלף ושש מאות חמישים וארבע"));
      expect(
          converter.convert(999999,
              options: const HeOptions(gender: Gender.feminine)),
          equals("תשע מאות תשעים ותשעה אלף ותשע מאות תשעים ותשע"));
    });
    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("מינוס אחד"));
      expect(converter.convert(-123), equals("מינוס מאה ועשרים ושלושה"));
      expect(converter.convert(-123.456),
          equals("מינוס מאה ועשרים ושלושה נקודה ארבע חמש שש"));
      expect(
          converter.convert(-1,
              options: const HeOptions(negativePrefix: "שלילי")),
          equals("שלילי אחד"));
      expect(
          converter.convert(-123,
              options: const HeOptions(negativePrefix: "שלילי")),
          equals("שלילי מאה ועשרים ושלושה"));
      expect(
          converter.convert(-123.456,
              options: const HeOptions(negativePrefix: "שלילי")),
          equals("שלילי מאה ועשרים ושלושה נקודה ארבע חמש שש"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456),
          equals("מאה ועשרים ושלושה נקודה ארבע חמש שש"));
      expect(converter.convert(1.5), equals("אחד נקודה חמש"));
      expect(converter.convert(1.05), equals("אחד נקודה אפס חמש"));
      expect(converter.convert(879.465),
          equals("שמונה מאות שבעים ותשעה נקודה ארבע שש חמש"));
      expect(converter.convert(1.5), equals("אחד נקודה חמש"));
      expect(
          converter.convert(1.5,
              options:
                  const HeOptions(decimalSeparator: DecimalSeparator.point)),
          equals("אחד נקודה חמש"));
      expect(
          converter.convert(1.5,
              options:
                  const HeOptions(decimalSeparator: DecimalSeparator.comma)),
          equals("אחד פסיק חמש"));
      expect(
          converter.convert(1.5,
              options:
                  const HeOptions(decimalSeparator: DecimalSeparator.period)),
          equals("אחד נקודה חמש"));
    });

    test('Year Formatting', () {
      expect(
          converter.convert(123, options: const HeOptions(format: Format.year)),
          equals("מאה ועשרים ושלושה"));
      expect(
          converter.convert(498, options: const HeOptions(format: Format.year)),
          equals("ארבע מאות תשעים ושמונה"));
      expect(
          converter.convert(756, options: const HeOptions(format: Format.year)),
          equals("שבע מאות חמישים ושישה"));
      expect(
          converter.convert(1900,
              options: const HeOptions(format: Format.year)),
          equals("אלף תשע מאות"));
      expect(
          converter.convert(1999,
              options: const HeOptions(format: Format.year)),
          equals("אלף תשע מאות תשעים ותשעה"));
      expect(
          converter.convert(2025,
              options: const HeOptions(format: Format.year)),
          equals('אלפיים ועשרים וחמישה'));
      expect(
          converter.convert(-1, options: const HeOptions(format: Format.year)),
          equals("מינוס אחד"));
      expect(
          converter.convert(-100,
              options: const HeOptions(format: Format.year)),
          equals("מינוס מאה"));
      expect(
          converter.convert(-2025,
              options: const HeOptions(format: Format.year)),
          equals('מינוס אלפיים ועשרים וחמישה'));
      expect(
          converter.convert(-1000000,
              options: const HeOptions(format: Format.year)),
          equals("מינוס מיליון"));
    });

    test('Currency', () {
      expect(converter.convert(0, options: const HeOptions(currency: true)),
          equals("אפס שקלים חדשים"));
      expect(converter.convert(1, options: const HeOptions(currency: true)),
          equals("שקל חדש אחד"));
      expect(converter.convert(2, options: const HeOptions(currency: true)),
          equals("שני שקלים חדשים"));
      expect(converter.convert(5, options: const HeOptions(currency: true)),
          equals("חמישה שקלים חדשים"));
      expect(converter.convert(10, options: const HeOptions(currency: true)),
          equals("עשרה שקלים חדשים"));
      expect(converter.convert(11, options: const HeOptions(currency: true)),
          equals("אחד עשר שקלים חדשים"));
      expect(converter.convert(1.5, options: const HeOptions(currency: true)),
          equals("שקל חדש אחד וחמישים אגורות"));
      expect(
          converter.convert(123.45, options: const HeOptions(currency: true)),
          equals("מאה ועשרים ושלושה שקלים חדשים וארבעים וחמש אגורות"));
      expect(
          converter.convert(10000000, options: const HeOptions(currency: true)),
          equals("עשרה מיליון שקלים חדשים"));
      expect(converter.convert(0.5, options: const HeOptions(currency: true)),
          equals("חמישים אגורות"));
      expect(converter.convert(0.01, options: const HeOptions(currency: true)),
          equals("אגורה אחת"));
      expect(converter.convert(0.02, options: const HeOptions(currency: true)),
          equals("שתי אגורות"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("מיליון"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("שני מיליארד"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("שלושה טריליון"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("ארבעה קוודריליון"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("חמישה קווינטיליון"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("שישה סקסטיליון"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("שבעה ספטיליון"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "תשעה קווינטיליון ושמונה מאות שבעים ושישה קוודריליון וחמש מאות ארבעים ושלושה טריליון ומאתיים ועשרה מיליארד ומאה ועשרים ושלושה מיליון וארבע מאות חמישים ושישה אלף ושבע מאות שמונים ותשעה"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "מאה ועשרים ושלושה סקסטיליון וארבע מאות חמישים ושישה קווינטיליון ושבע מאות שמונים ותשעה קוודריליון ומאה ועשרים ושלושה טריליון וארבע מאות חמישים ושישה מיליארד ושבע מאות שמונים ותשעה מיליון ומאה ועשרים ושלושה אלף וארבע מאות חמישים ושישה"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "תשע מאות תשעים ותשעה סקסטיליון ותשע מאות תשעים ותשעה קווינטיליון ותשע מאות תשעים ותשעה קוודריליון ותשע מאות תשעים ותשעה טריליון ותשע מאות תשעים ותשעה מיליארד ותשע מאות תשעים ותשעה מיליון ותשע מאות תשעים ותשעה אלף ותשע מאות תשעים ותשעה"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('טריליון ושני מיליון ושלושה'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("חמישה מיליון ואלף"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals('מיליארד ואחד'));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals('מיליארד ומיליון'));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("שני מיליון ואלף"));
      expect(converter.convert(BigInt.parse('1000987600003')),
          equals('טריליון ותשע מאות שמונים ושבעה מיליון ושש מאות אלף ושלושה'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("לא מספר"));
      expect(converter.convert(double.infinity), equals("אינסוף"));
      expect(
          converter.convert(double.negativeInfinity), equals("אינסוף שלילי"));
      expect(converter.convert(null), equals("לא מספר"));
      expect(converter.convert('abc'), equals("לא מספר"));
      expect(converter.convert([]), equals("לא מספר"));
      expect(converter.convert({}), equals("לא מספר"));
      expect(converter.convert(Object()), equals("לא מספר"));

      expect(converterWithFallback.convert(double.nan), equals("ערך לא תקין"));
      expect(converterWithFallback.convert(double.infinity), equals("אינסוף"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("אינסוף שלילי"));
      expect(converterWithFallback.convert(null), equals("ערך לא תקין"));
      expect(converterWithFallback.convert('abc'), equals("ערך לא תקין"));
      expect(converterWithFallback.convert([]), equals("ערך לא תקין"));
      expect(converterWithFallback.convert({}), equals("ערך לא תקין"));
      expect(converterWithFallback.convert(Object()), equals("ערך לא תקין"));
      expect(converterWithFallback.convert(123), equals("מאה ועשרים ושלושה"));
    });
  });
}
