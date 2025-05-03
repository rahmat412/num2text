import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Kyrgyz (KY)', () {
    final converter = Num2Text(initialLang: Lang.KY);
    final converterWithFallback =
        Num2Text(initialLang: Lang.KY, fallbackOnError: "Жарамсыз сан");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("нөл"));
      expect(converter.convert(10), equals("он"));
      expect(converter.convert(11), equals("он бир"));
      expect(converter.convert(13), equals("он үч"));
      expect(converter.convert(15), equals("он беш"));
      expect(converter.convert(20), equals("жыйырма"));
      expect(converter.convert(27), equals("жыйырма жети"));
      expect(converter.convert(30), equals("отуз"));
      expect(converter.convert(54), equals("элүү төрт"));
      expect(converter.convert(68), equals("алтымыш сегиз"));
      expect(converter.convert(99), equals("токсон тогуз"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("бир жүз"));
      expect(converter.convert(101), equals("бир жүз бир"));
      expect(converter.convert(105), equals("бир жүз беш"));
      expect(converter.convert(110), equals("бир жүз он"));
      expect(converter.convert(111), equals("бир жүз он бир"));
      expect(converter.convert(123), equals("бир жүз жыйырма үч"));
      expect(converter.convert(200), equals("эки жүз"));
      expect(converter.convert(321), equals("үч жүз жыйырма бир"));
      expect(converter.convert(479), equals("төрт жүз жетимиш тогуз"));
      expect(converter.convert(596), equals("беш жүз токсон алты"));
      expect(converter.convert(681), equals("алты жүз сексен бир"));
      expect(converter.convert(999), equals("тогуз жүз токсон тогуз"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("бир миң"));
      expect(converter.convert(1001), equals("бир миң бир"));
      expect(converter.convert(1011), equals("бир миң он бир"));
      expect(converter.convert(1110), equals("бир миң бир жүз он"));
      expect(converter.convert(1111), equals("бир миң бир жүз он бир"));
      expect(converter.convert(2000), equals("эки миң"));
      expect(converter.convert(2468), equals("эки миң төрт жүз алтымыш сегиз"));
      expect(converter.convert(3579), equals("үч миң беш жүз жетимиш тогуз"));
      expect(converter.convert(10000), equals("он миң"));
      expect(converter.convert(10011), equals("он миң он бир"));
      expect(converter.convert(11100), equals("он бир миң бир жүз"));
      expect(
          converter.convert(12987), equals("он эки миң тогуз жүз сексен жети"));
      expect(
          converter.convert(45623), equals("кырк беш миң алты жүз жыйырма үч"));
      expect(converter.convert(87654),
          equals("сексен жети миң алты жүз элүү төрт"));
      expect(converter.convert(100000), equals("бир жүз миң"));
      expect(converter.convert(123456),
          equals("бир жүз жыйырма үч миң төрт жүз элүү алты"));
      expect(converter.convert(987654),
          equals("тогуз жүз сексен жети миң алты жүз элүү төрт"));
      expect(converter.convert(999999),
          equals("тогуз жүз токсон тогуз миң тогуз жүз токсон тогуз"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("минус бир"));
      expect(converter.convert(-123), equals("минус бир жүз жыйырма үч"));
      expect(converter.convert(-123.456),
          equals("минус бир жүз жыйырма үч точка төрт беш алты"));

      const options1 = KyOptions(negativePrefix: "терс");
      expect(converter.convert(-1, options: options1), equals("терс бир"));
      expect(converter.convert(-123, options: options1),
          equals("терс бир жүз жыйырма үч"));
      expect(converter.convert(-123.456, options: options1),
          equals("терс бир жүз жыйырма үч точка төрт беш алты"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456),
          equals("бир жүз жыйырма үч точка төрт беш алты"));
      expect(converter.convert("1.5"), equals("бир точка беш"));
      expect(converter.convert(1.05), equals("бир точка нөл беш"));
      expect(converter.convert(879.465),
          equals("сегиз жүз жетимиш тогуз точка төрт алты беш"));
      expect(converter.convert(1.5), equals("бир точка беш"));

      const pointOption = KyOptions(decimalSeparator: DecimalSeparator.point);
      expect(converter.convert(1.5, options: pointOption),
          equals("бир точка беш"));

      const commaOption = KyOptions(decimalSeparator: DecimalSeparator.comma);
      expect(
          converter.convert(1.5, options: commaOption), equals("бир үтүр беш"));

      const periodOption = KyOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(1.5, options: periodOption),
          equals("бир точка беш"));
    });

    test('Year Formatting', () {
      const yearOption = KyOptions(format: Format.year);
      expect(converter.convert(123, options: yearOption),
          equals("бир жүз жыйырма үч"));
      expect(converter.convert(498, options: yearOption),
          equals("төрт жүз токсон сегиз"));
      expect(converter.convert(756, options: yearOption),
          equals("жети жүз элүү алты"));
      expect(converter.convert(1900, options: yearOption),
          equals("бир миң тогуз жүз"));
      expect(converter.convert(1999, options: yearOption),
          equals("бир миң тогуз жүз токсон тогуз"));
      expect(converter.convert(2025, options: yearOption),
          equals("эки миң жыйырма беш"));

      const yearOptionAD = KyOptions(format: Format.year, includeAD: true);
      expect(converter.convert(1900, options: yearOptionAD),
          equals("бир миң тогуз жүз б.з."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("бир миң тогуз жүз токсон тогуз б.з."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("эки миң жыйырма беш б.з."));
      expect(converter.convert(-1, options: yearOption), equals("бир б.з.ч."));
      expect(converter.convert(-100, options: yearOption),
          equals("бир жүз б.з.ч."));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("бир жүз б.з.ч."));
      expect(converter.convert(-2025, options: yearOption),
          equals("эки миң жыйырма беш б.з.ч."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("бир миллион б.з.ч."));
    });

    test('Currency', () {
      const currencyOption = KyOptions(currency: true);
      expect(converter.convert(0, options: currencyOption), equals("нөл сом"));
      expect(converter.convert(1, options: currencyOption), equals("бир сом"));
      expect(converter.convert(5, options: currencyOption), equals("беш сом"));
      expect(converter.convert(10, options: currencyOption), equals("он сом"));
      expect(
          converter.convert(11, options: currencyOption), equals("он бир сом"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("бир сом элүү тыйын"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("бир жүз жыйырма үч сом кырк беш тыйын"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("он миллион сом"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("бир тыйын"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("элүү тыйын"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("бир сом бир тыйын"));
      expect(converter.convert(2.50, options: currencyOption),
          equals("эки сом элүү тыйын"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("бир миллион"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("эки миллиард"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("үч триллион"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("төрт квадриллион"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("беш квинтиллион"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("алты секстиллион"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("жети септиллион"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            "тогуз квинтиллион сегиз жүз жетимиш алты квадриллион беш жүз кырк үч триллион эки жүз он миллиард бир жүз жыйырма үч миллион төрт жүз элүү алты миң жети жүз сексен тогуз"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "бир жүз жыйырма үч секстиллион төрт жүз элүү алты квинтиллион жети жүз сексен тогуз квадриллион бир жүз жыйырма үч триллион төрт жүз элүү алты миллиард жети жүз сексен тогуз миллион бир жүз жыйырма үч миң төрт жүз элүү алты"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "тогуз жүз токсон тогуз секстиллион тогуз жүз токсон тогуз квинтиллион тогуз жүз токсон тогуз квадриллион тогуз жүз токсон тогуз триллион тогуз жүз токсон тогуз миллиард тогуз жүз токсон тогуз миллион тогуз жүз токсон тогуз миң тогуз жүз токсон тогуз"),
      );

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("бир триллион эки миллион үч"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals('беш миллион бир миң'));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("бир миллиард бир"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("бир миллиард бир миллион"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("эки миллион бир миң"));
      expect(converter.convert(BigInt.parse('1000987600003')),
          equals("бир триллион тогуз жүз сексен жети миллион алты жүз миң үч"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Сан Эмес"));
      expect(converter.convert(double.infinity), equals("Чексиздик"));
      expect(
          converter.convert(double.negativeInfinity), equals("Терс Чексиздик"));
      expect(converter.convert(null), equals("Сан Эмес"));
      expect(converter.convert('abc'), equals("Сан Эмес"));
      expect(converter.convert([]), equals("Сан Эмес"));
      expect(converter.convert({}), equals("Сан Эмес"));
      expect(converter.convert(Object()), equals("Сан Эмес"));

      expect(converterWithFallback.convert(double.nan), equals("Жарамсыз сан"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Чексиздик"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Терс Чексиздик"));
      expect(converterWithFallback.convert(null), equals("Жарамсыз сан"));
      expect(converterWithFallback.convert('abc'), equals("Жарамсыз сан"));
      expect(converterWithFallback.convert([]), equals("Жарамсыз сан"));
      expect(converterWithFallback.convert({}), equals("Жарамсыз сан"));
      expect(converterWithFallback.convert(Object()), equals("Жарамсыз сан"));
      expect(converterWithFallback.convert(123), equals("бир жүз жыйырма үч"));
    });
  });
}
