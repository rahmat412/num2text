import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Ukrainian (UK)', () {
    final converter = Num2Text(initialLang: Lang.UK);
    final converterWithFallback =
        Num2Text(initialLang: Lang.UK, fallbackOnError: "Невірне Число");

    test('Basic Numbers (0 - 99 Masculine/Default)', () {
      expect(converter.convert(0), equals("нуль"));
      expect(converter.convert(1), equals("один"));
      expect(converter.convert(2), equals("два"));
      expect(converter.convert(10), equals("десять"));
      expect(converter.convert(11), equals("одинадцять"));
      expect(converter.convert(13), equals("тринадцять"));
      expect(converter.convert(15), equals("п'ятнадцять"));
      expect(converter.convert(20), equals("двадцять"));
      expect(converter.convert(21), equals("двадцять один"));
      expect(converter.convert(22), equals("двадцять два"));
      expect(converter.convert(27), equals("двадцять сім"));
      expect(converter.convert(30), equals("тридцять"));
      expect(converter.convert(54), equals("п'ятдесят чотири"));
      expect(converter.convert(68), equals("шістдесят вісім"));
      expect(converter.convert(99), equals("дев'яносто дев'ять"));
    });

    test('Basic Numbers (0 - 99 Feminine Gender Option)', () {
      const feminineOption = UkOptions(gender: Gender.feminine);
      expect(converter.convert(1, options: feminineOption), equals("одна"));
      expect(converter.convert(2, options: feminineOption), equals("дві"));
      expect(converter.convert(3, options: feminineOption), equals("три"));
      expect(converter.convert(10, options: feminineOption), equals("десять"));
      expect(
          converter.convert(11, options: feminineOption), equals("одинадцять"));
      expect(converter.convert(21, options: feminineOption),
          equals("двадцять одна"));
      expect(converter.convert(22, options: feminineOption),
          equals("двадцять дві"));
      expect(converter.convert(31, options: feminineOption),
          equals("тридцять одна"));
      expect(converter.convert(32, options: feminineOption),
          equals("тридцять дві"));
      expect(converter.convert(99, options: feminineOption),
          equals("дев'яносто дев'ять"));
    });

    test('Basic Numbers (0 - 99 Neuter Gender Option)', () {
      const neuterOption = UkOptions(gender: Gender.neuter);
      expect(converter.convert(1, options: neuterOption), equals("одне"));
      expect(converter.convert(2, options: neuterOption), equals("два"));
      expect(converter.convert(3, options: neuterOption), equals("три"));
      expect(converter.convert(10, options: neuterOption), equals("десять"));
      expect(
          converter.convert(11, options: neuterOption), equals("одинадцять"));
      expect(converter.convert(21, options: neuterOption),
          equals("двадцять одне"));
      expect(
          converter.convert(22, options: neuterOption), equals("двадцять два"));
      expect(converter.convert(31, options: neuterOption),
          equals("тридцять одне"));
      expect(
          converter.convert(32, options: neuterOption), equals("тридцять два"));
      expect(converter.convert(99, options: neuterOption),
          equals("дев'яносто дев'ять"));
    });

    test('Hundreds (100 - 999 Masculine/Default)', () {
      expect(converter.convert(100), equals("сто"));
      expect(converter.convert(101), equals("сто один"));
      expect(converter.convert(102), equals("сто два"));
      expect(converter.convert(105), equals("сто п'ять"));
      expect(converter.convert(110), equals("сто десять"));
      expect(converter.convert(111), equals("сто одинадцять"));
      expect(converter.convert(121), equals("сто двадцять один"));
      expect(converter.convert(122), equals("сто двадцять два"));
      expect(converter.convert(123), equals("сто двадцять три"));
      expect(converter.convert(200), equals("двісті"));
      expect(converter.convert(321), equals("триста двадцять один"));
      expect(converter.convert(479), equals("чотириста сімдесят дев'ять"));
      expect(converter.convert(596), equals("п'ятсот дев'яносто шість"));
      expect(converter.convert(681), equals("шістсот вісімдесят один"));
      expect(converter.convert(999), equals("дев'ятсот дев'яносто дев'ять"));
    });

    test('Hundreds (100 - 999 Feminine Gender Option)', () {
      const feminineOption = UkOptions(gender: Gender.feminine);
      expect(
          converter.convert(101, options: feminineOption), equals("сто одна"));
      expect(
          converter.convert(102, options: feminineOption), equals("сто дві"));
      expect(
          converter.convert(103, options: feminineOption), equals("сто три"));
      expect(converter.convert(121, options: feminineOption),
          equals("сто двадцять одна"));
      expect(converter.convert(122, options: feminineOption),
          equals("сто двадцять дві"));
      expect(converter.convert(201, options: feminineOption),
          equals("двісті одна"));
      expect(converter.convert(202, options: feminineOption),
          equals("двісті дві"));
      expect(converter.convert(203, options: feminineOption),
          equals("двісті три"));
      expect(converter.convert(999, options: feminineOption),
          equals("дев'ятсот дев'яносто дев'ять"));
    });

    test('Thousands (1000 - 999999) Masculine/Default', () {
      expect(converter.convert(1000), equals("одна тисяча"));
      expect(converter.convert(1001), equals("одна тисяча один"));
      expect(converter.convert(1002), equals("одна тисяча два"));
      expect(converter.convert(1011), equals("одна тисяча одинадцять"));
      expect(converter.convert(1110), equals("одна тисяча сто десять"));
      expect(converter.convert(1111), equals("одна тисяча сто одинадцять"));
      expect(converter.convert(2000), equals("дві тисячі"));
      expect(converter.convert(3000), equals("три тисячі"));
      expect(converter.convert(4000), equals("чотири тисячі"));
      expect(converter.convert(5000), equals("п'ять тисяч"));
      expect(converter.convert(21000), equals("двадцять одна тисяча"));
      expect(converter.convert(22000), equals("двадцять дві тисячі"));
      expect(converter.convert(25000), equals("двадцять п'ять тисяч"));
      expect(converter.convert(2468),
          equals("дві тисячі чотириста шістдесят вісім"));
      expect(converter.convert(3579),
          equals("три тисячі п'ятсот сімдесят дев'ять"));
      expect(converter.convert(10000), equals("десять тисяч"));
      expect(converter.convert(10011), equals("десять тисяч одинадцять"));
      expect(converter.convert(11100), equals("одинадцять тисяч сто"));
      expect(converter.convert(12987),
          equals("дванадцять тисяч дев'ятсот вісімдесят сім"));
      expect(converter.convert(45623),
          equals("сорок п'ять тисяч шістсот двадцять три"));
      expect(converter.convert(87654),
          equals("вісімдесят сім тисяч шістсот п'ятдесят чотири"));
      expect(converter.convert(100000), equals("сто тисяч"));
      expect(converter.convert(123456),
          equals("сто двадцять три тисячі чотириста п'ятдесят шість"));
      expect(converter.convert(987654),
          equals("дев'ятсот вісімдесят сім тисяч шістсот п'ятдесят чотири"));
      expect(
          converter.convert(999999),
          equals(
              "дев'ятсот дев'яносто дев'ять тисяч дев'ятсот дев'яносто дев'ять"));
    });

    test('Negative Numbers', () {
      const negativeOption = UkOptions(negativePrefix: "від'ємний");
      expect(converter.convert(-1), equals("мінус один"));
      expect(converter.convert(-123), equals("мінус сто двадцять три"));
      expect(converter.convert(-123.456),
          equals("мінус сто двадцять три кома чотири п'ять шість"));
      expect(converter.convert(-1, options: negativeOption),
          equals("від'ємний один"));
      expect(converter.convert(-123, options: negativeOption),
          equals("від'ємний сто двадцять три"));
      expect(
        converter.convert(-123.456, options: negativeOption),
        equals("від'ємний сто двадцять три кома чотири п'ять шість"),
      );
    });

    test('Decimals', () {
      const pointOption = UkOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = UkOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = UkOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(123.456),
          equals("сто двадцять три кома чотири п'ять шість"));
      expect(converter.convert(1.5), equals("один кома п'ять"));
      expect(converter.convert(2.5), equals("два кома п'ять"));
      expect(converter.convert(3.5), equals("три кома п'ять"));
      expect(converter.convert(1.05), equals("один кома нуль п'ять"));
      expect(converter.convert(879.465),
          equals("вісімсот сімдесят дев'ять кома чотири шість п'ять"));
      expect(converter.convert(1.5, options: pointOption),
          equals("один крапка п'ять"));
      expect(converter.convert(1.5, options: commaOption),
          equals("один кома п'ять"));
      expect(converter.convert(1.5, options: periodOption),
          equals("один крапка п'ять"));
    });

    test('Year Formatting', () {
      const yearOption = UkOptions(format: Format.year);
      const yearOptionAD = UkOptions(format: Format.year, includeAD: true);
      expect(converter.convert(123, options: yearOption),
          equals("сто двадцять три"));
      expect(converter.convert(498, options: yearOption),
          equals("чотириста дев'яносто вісім"));
      expect(converter.convert(756, options: yearOption),
          equals("сімсот п'ятдесят шість"));
      expect(converter.convert(1000, options: yearOption), equals("тисяча"));
      expect(converter.convert(1900, options: yearOption),
          equals("тисяча дев'ятсот"));
      expect(converter.convert(1999, options: yearOption),
          equals("тисяча дев'ятсот дев'яносто дев'ять"));
      expect(
          converter.convert(2000, options: yearOption), equals("дві тисячі"));
      expect(converter.convert(2025, options: yearOption),
          equals("дві тисячі двадцять п'ять"));
      expect(converter.convert(1900, options: yearOptionAD),
          equals("тисяча дев'ятсот н.е."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("тисяча дев'ятсот дев'яносто дев'ять н.е."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("дві тисячі двадцять п'ять н.е."));
      expect(
          converter.convert(-1, options: yearOption), equals("один до н.е."));
      expect(converter.convert(-100), equals("мінус сто"));
      expect(
          converter.convert(-100, options: yearOption), equals("сто до н.е."));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("сто до н.е."));
      expect(converter.convert(-1000, options: yearOption),
          equals("тисяча до н.е."));
      expect(converter.convert(-2000, options: yearOption),
          equals("дві тисячі до н.е."));
      expect(converter.convert(-2025, options: yearOption),
          equals("дві тисячі двадцять п'ять до н.е."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("мільйон до н.е."));
      expect(converter.convert(-2000000, options: yearOption),
          equals("два мільйони до н.е."));
      expect(converter.convert(-5000000, options: yearOption),
          equals("п'ять мільйонів до н.е."));
    });

    test('Currency', () {
      const currencyOption = UkOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("нуль гривень"));
      expect(
          converter.convert(1, options: currencyOption), equals("одна гривня"));
      expect(
          converter.convert(2, options: currencyOption), equals("дві гривні"));
      expect(
          converter.convert(3, options: currencyOption), equals("три гривні"));
      expect(converter.convert(4, options: currencyOption),
          equals("чотири гривні"));
      expect(converter.convert(5, options: currencyOption),
          equals("п'ять гривень"));
      expect(converter.convert(10, options: currencyOption),
          equals("десять гривень"));
      expect(converter.convert(11, options: currencyOption),
          equals("одинадцять гривень"));
      expect(converter.convert(21, options: currencyOption),
          equals("двадцять одна гривня"));
      expect(converter.convert(22, options: currencyOption),
          equals("двадцять дві гривні"));
      expect(converter.convert(25, options: currencyOption),
          equals("двадцять п'ять гривень"));
      expect(converter.convert(100, options: currencyOption),
          equals("сто гривень"));
      expect(converter.convert(101, options: currencyOption),
          equals("сто одна гривня"));
      expect(converter.convert(102, options: currencyOption),
          equals("сто дві гривні"));
      expect(converter.convert(105, options: currencyOption),
          equals("сто п'ять гривень"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("одна гривня п'ятдесят копійок"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("сто двадцять три гривні сорок п'ять копійок"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("десять мільйонів гривень"));
      expect(converter.convert(1000001, options: currencyOption),
          equals("один мільйон одна гривня"));
      expect(converter.convert(2000002, options: currencyOption),
          equals("два мільйони дві гривні"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("п'ятдесят копійок"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("одна копійка"));
      expect(converter.convert(0.02, options: currencyOption),
          equals("дві копійки"));
      expect(converter.convert(0.03, options: currencyOption),
          equals("три копійки"));
      expect(converter.convert(0.04, options: currencyOption),
          equals("чотири копійки"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("п'ять копійок"));
      expect(converter.convert(0.11, options: currencyOption),
          equals("одинадцять копійок"));
      expect(converter.convert(0.21, options: currencyOption),
          equals("двадцять одна копійка"));
      expect(converter.convert(0.22, options: currencyOption),
          equals("двадцять дві копійки"));
      expect(converter.convert(0.25, options: currencyOption),
          equals("двадцять п'ять копійок"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("одна гривня одна копійка"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("дві гривні дві копійки"));
      expect(converter.convert(5.05, options: currencyOption),
          equals("п'ять гривень п'ять копійок"));
      expect(converter.convert(21.21, options: currencyOption),
          equals("двадцять одна гривня двадцять одна копійка"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("мільйон"));
      expect(converter.convert(BigInt.from(1) * BigInt.from(10).pow(6)),
          equals("мільйон"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(6)),
          equals("два мільйони"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(6)),
          equals("п'ять мільйонів"));
      expect(converter.convert(BigInt.from(1) * BigInt.from(10).pow(9)),
          equals("мільярд"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("два мільярди"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("три трильйони"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("чотири квадрильйони"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("п'ять квінтильйонів"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("шість секстильйонів"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("сім септильйонів"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('один трильйон два мільйони три'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("п'ять мільйонів одна тисяча"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals('один мільярд один'));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("один мільярд один мільйон"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("два мільйони одна тисяча"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "один трильйон дев'ятсот вісімдесят сім мільйонів шістсот тисяч три"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "дев'ять квінтильйонів вісімсот сімдесят шість квадрильйонів п'ятсот сорок три трильйони двісті десять мільярдів сто двадцять три мільйони чотириста п'ятдесят шість тисяч сімсот вісімдесят дев'ять"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "сто двадцять три секстильйони чотириста п'ятдесят шість квінтильйонів сімсот вісімдесят дев'ять квадрильйонів сто двадцять три трильйони чотириста п'ятдесят шість мільярдів сімсот вісімдесят дев'ять мільйонів сто двадцять три тисячі чотириста п'ятдесят шість"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "дев'ятсот дев'яносто дев'ять секстильйонів дев'ятсот дев'яносто дев'ять квінтильйонів дев'ятсот дев'яносто дев'ять квадрильйонів дев'ятсот дев'яносто дев'ять трильйонів дев'ятсот дев'яносто дев'ять мільярдів дев'ятсот дев'яносто дев'ять мільйонів дев'ятсот дев'яносто дев'ять тисяч дев'ятсот дев'яносто дев'ять"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Не Число"));
      expect(converter.convert(double.infinity), equals("Нескінченність"));
      expect(converter.convert(double.negativeInfinity),
          equals("Негативна Нескінченність"));
      expect(converter.convert(null), equals("Не Число"));
      expect(converter.convert('abc'), equals("Не Число"));
      expect(converter.convert([]), equals("Не Число"));
      expect(converter.convert({}), equals("Не Число"));
      expect(converter.convert(Object()), equals("Не Число"));
      expect(
          converterWithFallback.convert(double.nan), equals("Невірне Число"));
      expect(converterWithFallback.convert(double.infinity),
          equals("Нескінченність"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Негативна Нескінченність"));
      expect(converterWithFallback.convert(null), equals("Невірне Число"));
      expect(converterWithFallback.convert('abc'), equals("Невірне Число"));
      expect(converterWithFallback.convert([]), equals("Невірне Число"));
      expect(converterWithFallback.convert({}), equals("Невірне Число"));
      expect(converterWithFallback.convert(Object()), equals("Невірне Число"));
      expect(converterWithFallback.convert(123), equals("сто двадцять три"));
    });
  });
}
