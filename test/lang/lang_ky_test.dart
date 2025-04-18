import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Kyrgyz (KY)', () {
    final converter = Num2Text(initialLang: Lang.KY);
    final converterWithFallback =
        Num2Text(initialLang: Lang.KY, fallbackOnError: "Жарамсыз сан");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("нөл"));
      expect(converter.convert(1), equals("бир"));
      expect(converter.convert(10), equals("он"));
      expect(converter.convert(11), equals("он бир"));
      expect(converter.convert(20), equals("жыйырма"));
      expect(converter.convert(21), equals("жыйырма бир"));
      expect(converter.convert(99), equals("токсон тогуз"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("бир жүз"));
      expect(converter.convert(101), equals("бир жүз бир"));
      expect(converter.convert(111), equals("бир жүз он бир"));
      expect(converter.convert(200), equals("эки жүз"));
      expect(converter.convert(999), equals("тогуз жүз токсон тогуз"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("бир миң"));
      expect(converter.convert(1001), equals("бир миң бир"));
      expect(converter.convert(1111), equals("бир миң бир жүз он бир"));
      expect(converter.convert(2000), equals("эки миң"));
      expect(converter.convert(10000), equals("он миң"));
      expect(converter.convert(100000), equals("бир жүз миң"));
      expect(converter.convert(123456),
          equals("бир жүз жыйырма үч миң төрт жүз элүү алты"));
      expect(
        converter.convert(999999),
        equals("тогуз жүз токсон тогуз миң тогуз жүз токсон тогуз"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("минус бир"));
      expect(converter.convert(-123), equals("минус бир жүз жыйырма үч"));
      expect(converter.convert(-1, options: KyOptions(negativePrefix: "терс")),
          equals("терс бир"));
      expect(
        converter.convert(-123, options: KyOptions(negativePrefix: "терс")),
        equals("терс бир жүз жыйырма үч"),
      );
    });

    test('Year Formatting', () {
      const yearOption = KyOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("бир миң тогуз жүз"));
      expect(converter.convert(2024, options: yearOption),
          equals("эки миң жыйырма төрт"));
      expect(
        converter.convert(1900,
            options: KyOptions(format: Format.year, includeAD: true)),
        equals("бир миң тогуз жүз б.з."),
      );
      expect(
        converter.convert(2024,
            options: KyOptions(format: Format.year, includeAD: true)),
        equals("эки миң жыйырма төрт б.з."),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("бир жүз б.з.ч."));
      expect(converter.convert(-1, options: yearOption), equals("бир б.з.ч."));
      expect(
        converter.convert(-2024,
            options: KyOptions(format: Format.year, includeAD: true)),
        equals("эки миң жыйырма төрт б.з.ч."),
      );
      expect(
        converter.convert(-2024, options: KyOptions(format: Format.year)),
        equals("эки миң жыйырма төрт б.з.ч."),
      );
    });

    test('Currency', () {
      const currencyOption = KyOptions(currency: true);
      expect(converter.convert(1.01, options: currencyOption),
          equals("бир сом бир тыйын"));
      expect(converter.convert(2.50, options: currencyOption),
          equals("эки сом элүү тыйын"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("бир жүз жыйырма үч сом кырк беш тыйын"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("бир жүз жыйырма үч точка төрт беш алты"),
      );
      expect(converter.convert(Decimal.parse('1.50')), equals("бир точка беш"));
      expect(converter.convert(123.0), equals("бир жүз жыйырма үч"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("бир жүз жыйырма үч"));
      expect(
        converter.convert(1.5,
            options: const KyOptions(decimalSeparator: DecimalSeparator.point)),
        equals("бир точка беш"),
      );
      expect(
        converter.convert(1.5,
            options: const KyOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("бир үтүр беш"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Чексиздик"));
      expect(
          converter.convert(double.negativeInfinity), equals("Терс чексиздик"));
      expect(converter.convert(double.nan), equals("Сан эмес"));
      expect(converter.convert(null), equals("Сан эмес"));
      expect(converter.convert('abc'), equals("Сан эмес"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Чексиздик"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Терс чексиздик"));
      expect(converterWithFallback.convert(double.nan), equals("Жарамсыз сан"));
      expect(converterWithFallback.convert(null), equals("Жарамсыз сан"));
      expect(converterWithFallback.convert('abc'), equals("Жарамсыз сан"));
      expect(converterWithFallback.convert(123), equals("бир жүз жыйырма үч"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("бир миллион"));
      expect(
          converter.convert(BigInt.from(1000000000)), equals("бир миллиард"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("бир триллион"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("бир квадриллион"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("бир квинтиллион"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("бир секстиллион"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("бир септиллион"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "бир жүз жыйырма үч секстиллион төрт жүз элүү алты квинтиллион жети жүз сексен тогуз квадриллион бир жүз жыйырма үч триллион төрт жүз элүү алты миллиард жети жүз сексен тогуз миллион бир жүз жыйырма үч миң төрт жүз элүү алты",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "тогуз жүз токсон тогуз секстиллион тогуз жүз токсон тогуз квинтиллион тогуз жүз токсон тогуз квадриллион тогуз жүз токсон тогуз триллион тогуз жүз токсон тогуз миллиард тогуз жүз токсон тогуз миллион тогуз жүз токсон тогуз миң тогуз жүз токсон тогуз",
        ),
      );
    });
  });
}
