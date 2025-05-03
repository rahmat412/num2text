import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Kazakh (KK)', () {
    final converter = Num2Text(initialLang: Lang.KK);
    final converterWithFallback =
        Num2Text(initialLang: Lang.KK, fallbackOnError: "Жарамсыз сан");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("нөл"));
      expect(converter.convert(10), equals("он"));
      expect(converter.convert(11), equals("он бір"));
      expect(converter.convert(13), equals("он үш"));
      expect(converter.convert(15), equals("он бес"));
      expect(converter.convert(20), equals("жиырма"));
      expect(converter.convert(27), equals("жиырма жеті"));
      expect(converter.convert(30), equals("отыз"));
      expect(converter.convert(54), equals("елу төрт"));
      expect(converter.convert(68), equals("алпыс сегіз"));
      expect(converter.convert(99), equals("тоқсан тоғыз"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("бір жүз"));
      expect(converter.convert(101), equals("бір жүз бір"));
      expect(converter.convert(105), equals("бір жүз бес"));
      expect(converter.convert(110), equals("бір жүз он"));
      expect(converter.convert(111), equals("бір жүз он бір"));
      expect(converter.convert(123), equals("бір жүз жиырма үш"));
      expect(converter.convert(200), equals("екі жүз"));
      expect(converter.convert(321), equals("үш жүз жиырма бір"));
      expect(converter.convert(479), equals("төрт жүз жетпіс тоғыз"));
      expect(converter.convert(596), equals("бес жүз тоқсан алты"));
      expect(converter.convert(681), equals("алты жүз сексен бір"));
      expect(converter.convert(999), equals("тоғыз жүз тоқсан тоғыз"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("бір мың"));
      expect(converter.convert(1001), equals("бір мың бір"));
      expect(converter.convert(1011), equals("бір мың он бір"));
      expect(converter.convert(1110), equals("бір мың бір жүз он"));
      expect(converter.convert(1111), equals("бір мың бір жүз он бір"));
      expect(converter.convert(2000), equals("екі мың"));
      expect(converter.convert(2468), equals('екі мың төрт жүз алпыс сегіз'));
      expect(converter.convert(3579), equals('үш мың бес жүз жетпіс тоғыз'));
      expect(converter.convert(10000), equals("он мың"));
      expect(converter.convert(10011), equals("он мың он бір"));
      expect(converter.convert(11100), equals("он бір мың бір жүз"));
      expect(
          converter.convert(12987), equals("он екі мың тоғыз жүз сексен жеті"));
      expect(
          converter.convert(45623), equals("қырық бес мың алты жүз жиырма үш"));
      expect(converter.convert(87654),
          equals("сексен жеті мың алты жүз елу төрт"));
      expect(converter.convert(100000), equals("бір жүз мың"));
      expect(converter.convert(123456),
          equals("бір жүз жиырма үш мың төрт жүз елу алты"));
      expect(converter.convert(987654),
          equals("тоғыз жүз сексен жеті мың алты жүз елу төрт"));
      expect(converter.convert(999999),
          equals("тоғыз жүз тоқсан тоғыз мың тоғыз жүз тоқсан тоғыз"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("минус бір"));
      expect(converter.convert(-123), equals("минус бір жүз жиырма үш"));
      expect(converter.convert(-123.456),
          equals("минус бір жүз жиырма үш нүкте төрт бес алты"));

      const options1 = KkOptions(negativePrefix: "теріс");
      expect(converter.convert(-1, options: options1), equals("теріс бір"));
      expect(converter.convert(-123, options: options1),
          equals("теріс бір жүз жиырма үш"));
      expect(converter.convert(-123.456, options: options1),
          equals("теріс бір жүз жиырма үш нүкте төрт бес алты"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456),
          equals("бір жүз жиырма үш нүкте төрт бес алты"));
      expect(converter.convert("1.5"), equals("бір нүкте бес"));
      expect(converter.convert(1.05), equals("бір нүкте нөл бес"));
      expect(converter.convert(879.465),
          equals("сегіз жүз жетпіс тоғыз нүкте төрт алты бес"));
      expect(converter.convert(1.5), equals("бір нүкте бес"));

      const pointOption = KkOptions(decimalSeparator: DecimalSeparator.point);
      expect(converter.convert(1.5, options: pointOption),
          equals("бір нүкте бес"));

      const commaOption = KkOptions(decimalSeparator: DecimalSeparator.comma);
      expect(
          converter.convert(1.5, options: commaOption), equals("бір үтір бес"));

      const periodOption = KkOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(1.5, options: periodOption),
          equals("бір нүкте бес"));
    });

    test('Year Formatting', () {
      const yearOption = KkOptions(format: Format.year);
      expect(converter.convert(123, options: yearOption),
          equals("бір жүз жиырма үш"));
      expect(converter.convert(498, options: yearOption),
          equals("төрт жүз тоқсан сегіз"));
      expect(converter.convert(756, options: yearOption),
          equals("жеті жүз елу алты"));
      expect(converter.convert(1900, options: yearOption),
          equals("бір мың тоғыз жүз"));
      expect(converter.convert(1999, options: yearOption),
          equals("бір мың тоғыз жүз тоқсан тоғыз"));
      expect(converter.convert(2025, options: yearOption),
          equals("екі мың жиырма бес"));

      const yearOptionAD = KkOptions(format: Format.year, includeAD: true);
      expect(converter.convert(1900, options: yearOptionAD),
          equals("бір мың тоғыз жүз ж."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("бір мың тоғыз жүз тоқсан тоғыз ж."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("екі мың жиырма бес ж."));
      expect(converter.convert(-1, options: yearOption), equals("минус бір"));
      expect(converter.convert(-100, options: yearOption),
          equals("минус бір жүз"));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("минус бір жүз"));
      expect(converter.convert(-2025, options: yearOption),
          equals("минус екі мың жиырма бес"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("минус бір миллион"));
    });

    test('Currency', () {
      const currencyOption = KkOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("нөл теңге"));
      expect(
          converter.convert(1, options: currencyOption), equals("бір теңге"));
      expect(
          converter.convert(5, options: currencyOption), equals("бес теңге"));
      expect(
          converter.convert(10, options: currencyOption), equals("он теңге"));
      expect(converter.convert(11, options: currencyOption),
          equals("он бір теңге"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("бір теңге елу тиын"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("бір жүз жиырма үш теңге қырық бес тиын"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("он миллион теңге"));
      expect(
          converter.convert(0.01, options: currencyOption), equals("бір тиын"));
      expect(
          converter.convert(0.5, options: currencyOption), equals("елу тиын"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("бір теңге бір тиын"));
      expect(converter.convert(2.50, options: currencyOption),
          equals("екі теңге елу тиын"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("бір миллион"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("екі миллиард"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("үш триллион"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("төрт квадриллион"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("бес квинтиллион"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("алты секстиллион"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("жеті септиллион"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            "тоғыз квинтиллион сегіз жүз жетпіс алты квадриллион бес жүз қырық үш триллион екі жүз он миллиард бір жүз жиырма үш миллион төрт жүз елу алты мың жеті жүз сексен тоғыз"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "бір жүз жиырма үш секстиллион төрт жүз елу алты квинтиллион жеті жүз сексен тоғыз квадриллион бір жүз жиырма үш триллион төрт жүз елу алты миллиард жеті жүз сексен тоғыз миллион бір жүз жиырма үш мың төрт жүз елу алты"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "тоғыз жүз тоқсан тоғыз секстиллион тоғыз жүз тоқсан тоғыз квинтиллион тоғыз жүз тоқсан тоғыз квадриллион тоғыз жүз тоқсан тоғыз триллион тоғыз жүз тоқсан тоғыз миллиард тоғыз жүз тоқсан тоғыз миллион тоғыз жүз тоқсан тоғыз мың тоғыз жүз тоқсан тоғыз"),
      );

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("бір триллион екі миллион үш"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("бес миллион бір мың"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("бір миллиард бір"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("бір миллиард бір миллион"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("екі миллион бір мың"));
      expect(converter.convert(BigInt.parse('1000987600003')),
          equals("бір триллион тоғыз жүз сексен жеті миллион алты жүз мың үш"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Сан емес"));
      expect(converter.convert(double.infinity), equals("Шексіздік"));
      expect(converter.convert(double.negativeInfinity),
          equals("Теріс шексіздік"));
      expect(converter.convert(null), equals("Сан емес"));
      expect(converter.convert('abc'), equals("Сан емес"));
      expect(converter.convert([]), equals("Сан емес"));
      expect(converter.convert({}), equals("Сан емес"));
      expect(converter.convert(Object()), equals("Сан емес"));

      expect(converterWithFallback.convert(double.nan), equals("Жарамсыз сан"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Шексіздік"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Теріс шексіздік"));
      expect(converterWithFallback.convert(null), equals("Жарамсыз сан"));
      expect(converterWithFallback.convert('abc'), equals("Жарамсыз сан"));
      expect(converterWithFallback.convert([]), equals("Жарамсыз сан"));
      expect(converterWithFallback.convert({}), equals("Жарамсыз сан"));
      expect(converterWithFallback.convert(Object()), equals("Жарамсыз сан"));
      expect(converterWithFallback.convert(123), equals("бір жүз жиырма үш"));
    });
  });
}
