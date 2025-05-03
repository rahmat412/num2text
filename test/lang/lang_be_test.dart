import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Belarusian (BE)', () {
    final converter = Num2Text(initialLang: Lang.BE);
    final converterWithFallback = Num2Text(
      initialLang: Lang.BE,
      fallbackOnError: "Няправільны лік",
    );

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("нуль"));
      expect(converter.convert(10), equals("дзесяць"));
      expect(converter.convert(11), equals("адзінаццаць"));
      expect(converter.convert(13), equals("трынаццаць"));
      expect(converter.convert(15), equals("пятнаццаць"));
      expect(converter.convert(20), equals("дваццаць"));
      expect(converter.convert(27), equals("дваццаць сем"));
      expect(converter.convert(30), equals("трыццаць"));
      expect(converter.convert(54), equals("пяцьдзясят чатыры"));
      expect(converter.convert(68), equals("шэсцьдзесят восем"));
      expect(converter.convert(99), equals("дзевяноста дзевяць"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("сто"));
      expect(converter.convert(101), equals("сто адзін"));
      expect(converter.convert(105), equals("сто пяць"));
      expect(converter.convert(110), equals("сто дзесяць"));
      expect(converter.convert(111), equals("сто адзінаццаць"));
      expect(converter.convert(123), equals("сто дваццаць тры"));
      expect(converter.convert(200), equals("дзвесце"));
      expect(converter.convert(321), equals("трыста дваццаць адзін"));
      expect(converter.convert(479), equals("чатырыста семдзесят дзевяць"));
      expect(converter.convert(596), equals("пяцьсот дзевяноста шэсць"));
      expect(converter.convert(681), equals("шэсцьсот восемдзесят адзін"));
      expect(converter.convert(999), equals("дзевяцьсот дзевяноста дзевяць"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("адна тысяча"));
      expect(converter.convert(1001), equals("адна тысяча адзін"));
      expect(converter.convert(1011), equals("адна тысяча адзінаццаць"));
      expect(converter.convert(1110), equals("адна тысяча сто дзесяць"));
      expect(converter.convert(1111), equals("адна тысяча сто адзінаццаць"));
      expect(converter.convert(2000), equals("дзве тысячы"));
      expect(converter.convert(2468),
          equals("дзве тысячы чатырыста шэсцьдзесят восем"));
      expect(converter.convert(3579),
          equals("тры тысячы пяцьсот семдзесят дзевяць"));
      expect(converter.convert(10000), equals("дзесяць тысяч"));
      expect(converter.convert(10011), equals("дзесяць тысяч адзінаццаць"));
      expect(converter.convert(11100), equals("адзінаццаць тысяч сто"));
      expect(converter.convert(12987),
          equals("дванаццаць тысяч дзевяцьсот восемдзесят сем"));
      expect(converter.convert(45623),
          equals("сорак пяць тысяч шэсцьсот дваццаць тры"));
      expect(converter.convert(87654),
          equals("восемдзесят сем тысяч шэсцьсот пяцьдзясят чатыры"));
      expect(converter.convert(100000), equals("сто тысяч"));
      expect(converter.convert(123456),
          equals("сто дваццаць тры тысячы чатырыста пяцьдзясят шэсць"));
      expect(
          converter.convert(987654),
          equals(
              "дзевяцьсот восемдзесят сем тысяч шэсцьсот пяцьдзясят чатыры"));
      expect(
          converter.convert(999999),
          equals(
              "дзевяцьсот дзевяноста дзевяць тысяч дзевяцьсот дзевяноста дзевяць"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("мінус адзін"));
      expect(converter.convert(-123), equals("мінус сто дваццаць тры"));
      expect(
          converter.convert(-123.456),
          equals(
              "мінус сто дваццаць тры цэлыя чатырыста пяцьдзясят шэсць тысячных"));

      const BeOptions negativeOptions = BeOptions(negativePrefix: "адмоўны");

      expect(converter.convert(-1, options: negativeOptions),
          equals("адмоўны адзін"));
      expect(converter.convert(-123, options: negativeOptions),
          equals("адмоўны сто дваццаць тры"));
      expect(
          converter.convert(-123.456, options: negativeOptions),
          equals(
              "адмоўны сто дваццаць тры цэлыя чатырыста пяцьдзясят шэсць тысячных"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456),
          equals("сто дваццаць тры цэлыя чатырыста пяцьдзясят шэсць тысячных"));
      expect(converter.convert(1.5), equals("адна цэлая пяць дзясятых"));
      expect(converter.convert(1.05), equals("адна цэлая пяць сотых"));
      expect(
          converter.convert(879.465),
          equals(
              "восемсот семдзесят дзевяць цэлых чатырыста шэсцьдзесят пяць тысячных"));
      expect(converter.convert(1.5), equals("адна цэлая пяць дзясятых"));

      const BeOptions pointSeparatorOptions =
          BeOptions(decimalSeparator: DecimalSeparator.point);
      const BeOptions commaSeparatorOptions =
          BeOptions(decimalSeparator: DecimalSeparator.comma);
      const BeOptions periodSeparatorOptions =
          BeOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(1.5, options: pointSeparatorOptions),
          equals("адзін кропка пяць"));
      expect(converter.convert(1.5, options: commaSeparatorOptions),
          equals("адна цэлая пяць дзясятых"));
      expect(converter.convert(1.5, options: periodSeparatorOptions),
          equals("адзін кропка пяць"));
    });

    test('Year Formatting', () {
      const BeOptions yearOption = BeOptions(format: Format.year);
      expect(converter.convert(123, options: yearOption),
          equals("сто дваццаць трэці"));
      expect(converter.convert(498, options: yearOption),
          equals("чатырыста дзевяноста восьмы"));
      expect(converter.convert(756, options: yearOption),
          equals("семсот пяцьдзясят шосты"));
      expect(converter.convert(1900, options: yearOption),
          equals("адна тысяча дзевяцісоты"));
      expect(converter.convert(1999, options: yearOption),
          equals("адна тысяча дзевяцьсот дзевяноста дзявяты"));
      expect(converter.convert(2025, options: yearOption),
          equals("дзве тысячы дваццаць пяты"));

      const BeOptions yearOptionAD =
          BeOptions(format: Format.year, includeAD: true);

      expect(converter.convert(1900, options: yearOptionAD),
          equals("адна тысяча дзевяцісоты н.э."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("адна тысяча дзевяцьсот дзевяноста дзявяты н.э."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("дзве тысячы дваццаць пяты н.э."));
      expect(
          converter.convert(-1, options: yearOption), equals("першы да н.э."));
      expect(
          converter.convert(-100, options: yearOption), equals("соты да н.э."));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("соты да н.э."));
      expect(converter.convert(-2025, options: yearOption),
          equals("дзве тысячы дваццаць пяты да н.э."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("адзін мільённы да н.э."));
    });

    test('Currency', () {
      const BeOptions currencyOption = BeOptions(currency: true);

      expect(
          converter.convert(0, options: currencyOption), equals("нуль рублёў"));
      expect(converter.convert(1, options: currencyOption),
          equals("адзін рубель"));
      expect(
          converter.convert(2, options: currencyOption), equals("два рублі"));
      expect(
          converter.convert(5, options: currencyOption), equals("пяць рублёў"));
      expect(converter.convert(10, options: currencyOption),
          equals("дзесяць рублёў"));
      expect(converter.convert(11, options: currencyOption),
          equals("адзінаццаць рублёў"));
      expect(converter.convert(21, options: currencyOption),
          equals("дваццаць адзін рубель"));
      expect(converter.convert(22, options: currencyOption),
          equals("дваццаць два рублі"));
      expect(converter.convert(25, options: currencyOption),
          equals("дваццаць пяць рублёў"));
      expect(converter.convert(100, options: currencyOption),
          equals("сто рублёў"));
      expect(converter.convert(101, options: currencyOption),
          equals("сто адзін рубель"));
      expect(converter.convert(102, options: currencyOption),
          equals("сто два рублі"));
      expect(converter.convert(105, options: currencyOption),
          equals("сто пяць рублёў"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("адзін рубель пяцьдзясят капеек"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("сто дваццаць тры рублі сорак пяць капеек"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("дзесяць мільёнаў рублёў"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("пяцьдзясят капеек"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("адна капейка"));
      expect(converter.convert(0.02, options: currencyOption),
          equals("дзве капейкі"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("пяць капеек"));
      expect(converter.convert(0.11, options: currencyOption),
          equals("адзінаццаць капеек"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("адзін рубель адна капейка"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("два рублі дзве капейкі"));
      expect(converter.convert(5.05, options: currencyOption),
          equals("пяць рублёў пяць капеек"));
      expect(converter.convert(21.21, options: currencyOption),
          equals("дваццаць адзін рубель дваццаць адна капейка"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("адзін мільён"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("два мільярды"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("тры трыльёны"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("чатыры квадрыльёны"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("пяць квінтыльёнаў"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("шэсць секстыльёнаў"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("сем септыльёнаў"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "дзевяць квінтыльёнаў восемсот семдзесят шэсць квадрыльёнаў пяцьсот сорак тры трыльёны дзвесце дзесяць мільярдаў сто дваццаць тры мільёны чатырыста пяцьдзясят шэсць тысяч семсот восемдзесят дзевяць"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "сто дваццаць тры секстыльёны чатырыста пяцьдзясят шэсць квінтыльёнаў семсот восемдзесят дзевяць квадрыльёнаў сто дваццаць тры трыльёны чатырыста пяцьдзясят шэсць мільярдаў семсот восемдзесят дзевяць мільёнаў сто дваццаць тры тысячы чатырыста пяцьдзясят шэсць"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "дзевяцьсот дзевяноста дзевяць секстыльёнаў дзевяцьсот дзевяноста дзевяць квінтыльёнаў дзевяцьсот дзевяноста дзевяць квадрыльёнаў дзевяцьсот дзевяноста дзевяць трыльёнаў дзевяцьсот дзевяноста дзевяць мільярдаў дзевяцьсот дзевяноста дзевяць мільёнаў дзевяцьсот дзевяноста дзевяць тысяч дзевяцьсот дзевяноста дзевяць"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("адзін трыльён два мільёны тры"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("пяць мільёнаў адна тысяча"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("адзін мільярд адзін"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("адзін мільярд адзін мільён"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("два мільёны адна тысяча"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "адзін трыльён дзевяцьсот восемдзесят сем мільёнаў шэсцьсот тысяч тры"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Не лік"));
      expect(converter.convert(double.infinity), equals("Бясконцасць"));
      expect(converter.convert(double.negativeInfinity),
          equals("Мінус бясконцасць"));
      expect(converter.convert(null), equals("Не лік"));
      expect(converter.convert('abc'), equals("Не лік"));
      expect(converter.convert([]), equals("Не лік"));
      expect(converter.convert({}), equals("Не лік"));
      expect(converter.convert(Object()), equals("Не лік"));

      expect(
          converterWithFallback.convert(double.nan), equals("Няправільны лік"));
      expect(converterWithFallback.convert(double.infinity),
          equals("Бясконцасць"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Мінус бясконцасць"));
      expect(converterWithFallback.convert(null), equals("Няправільны лік"));
      expect(converterWithFallback.convert('abc'), equals("Няправільны лік"));
      expect(converterWithFallback.convert([]), equals("Няправільны лік"));
      expect(converterWithFallback.convert({}), equals("Няправільны лік"));
      expect(
          converterWithFallback.convert(Object()), equals("Няправільны лік"));
      expect(converterWithFallback.convert(123), equals("сто дваццаць тры"));
    });
  });
}
