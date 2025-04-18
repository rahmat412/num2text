import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Belarusian (BE)', () {
    final converter = Num2Text(initialLang: Lang.BE);
    final converterWithFallback = Num2Text(
      initialLang: Lang.BE,
      fallbackOnError: "Няправільны лік",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("нуль"));
      expect(converter.convert(1), equals("адзін"));
      expect(converter.convert(10), equals("дзесяць"));
      expect(converter.convert(11), equals("адзінаццаць"));
      expect(converter.convert(20), equals("дваццаць"));
      expect(converter.convert(21), equals("дваццаць адзін"));
      expect(converter.convert(99), equals("дзевяноста дзевяць"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("сто"));
      expect(converter.convert(101), equals("сто адзін"));
      expect(converter.convert(111), equals("сто адзінаццаць"));
      expect(converter.convert(200), equals("дзвесце"));
      expect(converter.convert(999), equals("дзевяцьсот дзевяноста дзевяць"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("тысяча"));
      expect(converter.convert(1001), equals("тысяча адзін"));
      expect(converter.convert(1111), equals("тысяча сто адзінаццаць"));
      expect(converter.convert(2000), equals("дзве тысячы"));
      expect(converter.convert(10000), equals("дзесяць тысяч"));
      expect(converter.convert(100000), equals("сто тысяч"));
      expect(
        converter.convert(123456),
        equals("сто дваццаць тры тысячы чатырыста пяцьдзясят шэсць"),
      );
      expect(
        converter.convert(999999),
        equals(
            "дзевяцьсот дзевяноста дзевяць тысяч дзевяцьсот дзевяноста дзевяць"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("мінус адзін"));
      expect(converter.convert(-123), equals("мінус сто дваццаць тры"));
      expect(
        converter.convert(-1, options: BeOptions(negativePrefix: "адмоўны")),
        equals("адмоўны адзін"),
      );
      expect(
        converter.convert(-123, options: BeOptions(negativePrefix: "адмоўны")),
        equals("адмоўны сто дваццаць тры"),
      );
    });

    test('Year Formatting', () {
      const yearOption = BeOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("тысяча дзевяцьсот"));
      expect(converter.convert(2024, options: yearOption),
          equals("дзве тысячы дваццаць чатыры"));
      expect(
        converter.convert(1900,
            options: BeOptions(format: Format.year, includeAD: true)),
        equals("тысяча дзевяцьсот н.э."),
      );
      expect(
        converter.convert(2024,
            options: BeOptions(format: Format.year, includeAD: true)),
        equals("дзве тысячы дваццаць чатыры н.э."),
      );
      expect(
          converter.convert(-100, options: yearOption), equals("сто да н.э."));
      expect(
          converter.convert(-1, options: yearOption), equals("адзін да н.э."));
      expect(
        converter.convert(-2024,
            options: BeOptions(format: Format.year, includeAD: true)),
        equals("дзве тысячы дваццаць чатыры да н.э."),
      );
    });

    test('Currency', () {
      const currencyOption = BeOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("нуль рублёў"));
      expect(converter.convert(1, options: currencyOption),
          equals("адзін рубель"));
      expect(
          converter.convert(2, options: currencyOption), equals("два рублі"));
      expect(
          converter.convert(5, options: currencyOption), equals("пяць рублёў"));
      expect(
        converter.convert(0.50, options: currencyOption),
        equals("нуль рублёў пяцьдзясят капеек"),
      );
      expect(
        converter.convert(1.50, options: currencyOption),
        equals("адзін рубель пяцьдзясят капеек"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("сто дваццаць тры рублі сорак пяць капеек"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("сто дваццаць тры коска чатыры пяць шэсць"),
      );
      expect(
          converter.convert(Decimal.parse('1.50')), equals("адзін коска пяць"));
      expect(converter.convert(123.0), equals("сто дваццаць тры"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("сто дваццаць тры"));
      expect(
        converter.convert(1.5,
            options: const BeOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("адзін коска пяць"),
      );
      expect(
        converter.convert(1.5,
            options:
                const BeOptions(decimalSeparator: DecimalSeparator.period)),
        equals("адзін кропка пяць"),
      );
      expect(
        converter.convert(1.5,
            options: const BeOptions(decimalSeparator: DecimalSeparator.point)),
        equals("адзін кропка пяць"),
      );
    });

    test('Infinity and invalid input', () {
      expect(converter.convert(double.infinity), equals("Бясконцасць"));
      expect(converter.convert(double.negativeInfinity),
          equals("Мінус бясконцасць"));
      expect(converter.convert(double.nan), equals("Не лік"));
      expect(converter.convert(null), equals("Не лік"));
      expect(converter.convert('abc'), equals("Не лік"));

      expect(converterWithFallback.convert(double.infinity),
          equals("Бясконцасць"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Мінус бясконцасць"));
      expect(
          converterWithFallback.convert(double.nan), equals("Няправільны лік"));
      expect(converterWithFallback.convert(null), equals("Няправільны лік"));
      expect(converterWithFallback.convert('abc'), equals("Няправільны лік"));
      expect(converterWithFallback.convert(123), equals("сто дваццаць тры"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("мільён"));
      expect(converter.convert(BigInt.from(1000000000)), equals("мільярд"));
      expect(converter.convert(BigInt.from(1000000000000)), equals("трыльён"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("квадрыльён"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("квінтыльён"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("секстыльён"));
      expect(converter.convert(BigInt.parse('1000000000000000000000000')),
          equals("септыльён"));
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "сто дваццаць тры секстыльёны чатырыста пяцьдзясят шэсць квінтыльёнаў семсот восемдзесят дзевяць квадрыльёнаў сто дваццаць тры трыльёны чатырыста пяцьдзясят шэсць мільярдаў семсот восемдзесят дзевяць мільёнаў сто дваццаць тры тысячы чатырыста пяцьдзясят шэсць",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "дзевяцьсот дзевяноста дзевяць секстыльёнаў дзевяцьсот дзевяноста дзевяць квінтыльёнаў дзевяцьсот дзевяноста дзевяць квадрыльёнаў дзевяцьсот дзевяноста дзевяць трыльёнаў дзевяцьсот дзевяноста дзевяць мільярдаў дзевяцьсот дзевяноста дзевяць мільёнаў дзевяцьсот дзевяноста дзевяць тысяч дзевяцьсот дзевяноста дзевяць",
        ),
      );
    });
  });
}
