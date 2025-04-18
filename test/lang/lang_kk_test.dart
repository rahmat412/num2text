import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Kazakh (KK)', () {
    final converter = Num2Text(initialLang: Lang.KK);
    final converterWithFallback =
        Num2Text(initialLang: Lang.KK, fallbackOnError: "Жарамсыз сан");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("нөл"));
      expect(converter.convert(1), equals("бір"));
      expect(converter.convert(10), equals("он"));
      expect(converter.convert(11), equals("он бір"));
      expect(converter.convert(20), equals("жиырма"));
      expect(converter.convert(21), equals("жиырма бір"));
      expect(converter.convert(99), equals("тоқсан тоғыз"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("бір жүз"));
      expect(converter.convert(101), equals("бір жүз бір"));
      expect(converter.convert(111), equals("бір жүз он бір"));
      expect(converter.convert(200), equals("екі жүз"));
      expect(converter.convert(999), equals("тоғыз жүз тоқсан тоғыз"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("бір мың"));
      expect(converter.convert(1001), equals("бір мың бір"));
      expect(converter.convert(1111), equals("бір мың бір жүз он бір"));
      expect(converter.convert(2000), equals("екі мың"));
      expect(converter.convert(10000), equals("он мың"));
      expect(converter.convert(100000), equals("бір жүз мың"));
      expect(converter.convert(123456),
          equals("бір жүз жиырма үш мың төрт жүз елу алты"));
      expect(
        converter.convert(999999),
        equals("тоғыз жүз тоқсан тоғыз мың тоғыз жүз тоқсан тоғыз"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("минус бір"));
      expect(converter.convert(-123), equals("минус бір жүз жиырма үш"));
      expect(
        converter.convert(-1, options: KkOptions(negativePrefix: "теріс")),
        equals("теріс бір"),
      );
      expect(
        converter.convert(-123, options: KkOptions(negativePrefix: "теріс")),
        equals("теріс бір жүз жиырма үш"),
      );
    });

    test('Year Formatting', () {
      const yearOption = KkOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("бір мың тоғыз жүз"));
      expect(converter.convert(2024, options: yearOption),
          equals("екі мың жиырма төрт"));

      expect(
        converter.convert(1900, options: KkOptions(format: Format.year)),
        equals("бір мың тоғыз жүз"),
      );
      expect(
        converter.convert(2024, options: KkOptions(format: Format.year)),
        equals("екі мың жиырма төрт"),
      );

      expect(converter.convert(-100, options: yearOption),
          equals("минус бір жүз"));
      expect(converter.convert(-1, options: yearOption), equals("минус бір"));

      expect(
        converter.convert(-2024, options: KkOptions(format: Format.year)),
        equals("минус екі мың жиырма төрт"),
      );
    });

    test('Currency', () {
      const currencyOption = KkOptions(currency: true);
      expect(converter.convert(1.01, options: currencyOption),
          equals("бір теңге бір тиын"));
      expect(converter.convert(2.50, options: currencyOption),
          equals("екі теңге елу тиын"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("бір жүз жиырма үш теңге қырық бес тиын"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("бір жүз жиырма үш нүкте төрт бес алты"),
      );
      expect(converter.convert(Decimal.parse('1.50')), equals("бір нүкте бес"));
      expect(converter.convert(123.0), equals("бір жүз жиырма үш"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("бір жүз жиырма үш"));
      expect(
        converter.convert(1.5,
            options: const KkOptions(decimalSeparator: DecimalSeparator.point)),
        equals("бір нүкте бес"),
      );
      expect(
        converter.convert(1.5,
            options: const KkOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("бір үтір бес"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Шексіздік"));
      expect(converter.convert(double.negativeInfinity),
          equals("Теріс шексіздік"));
      expect(converter.convert(double.nan), equals("Сан емес"));
      expect(converter.convert(null), equals("Сан емес"));
      expect(converter.convert('abc'), equals("Сан емес"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Шексіздік"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Теріс шексіздік"));
      expect(converterWithFallback.convert(double.nan), equals("Жарамсыз сан"));
      expect(converterWithFallback.convert(null), equals("Жарамсыз сан"));
      expect(converterWithFallback.convert('abc'), equals("Жарамсыз сан"));
      expect(converterWithFallback.convert(123), equals("бір жүз жиырма үш"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("бір миллион"));
      expect(
          converter.convert(BigInt.from(1000000000)), equals("бір миллиард"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("бір триллион"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("бір квадриллион"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("бір квинтиллион"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("бір секстиллион"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("бір септиллион"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "бір жүз жиырма үш секстиллион төрт жүз елу алты квинтиллион жеті жүз сексен тоғыз квадриллион бір жүз жиырма үш триллион төрт жүз елу алты миллиард жеті жүз сексен тоғыз миллион бір жүз жиырма үш мың төрт жүз елу алты",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "тоғыз жүз тоқсан тоғыз секстиллион тоғыз жүз тоқсан тоғыз квинтиллион тоғыз жүз тоқсан тоғыз квадриллион тоғыз жүз тоқсан тоғыз триллион тоғыз жүз тоқсан тоғыз миллиард тоғыз жүз тоқсан тоғыз миллион тоғыз жүз тоқсан тоғыз мың тоғыз жүз тоқсан тоғыз",
        ),
      );
    });
  });
}
