import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Romanian (RO)', () {
    final converter = Num2Text(initialLang: Lang.RO);
    final converterWithFallback =
        Num2Text(initialLang: Lang.RO, fallbackOnError: "Număr Invalid");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("zero"));
      expect(converter.convert(10), equals("zece"));
      expect(converter.convert(11), equals("unsprezece"));
      expect(converter.convert(13), equals("treisprezece"));
      expect(converter.convert(15), equals("cincisprezece"));
      expect(converter.convert(20), equals("douăzeci"));
      expect(converter.convert(27), equals("douăzeci și șapte"));
      expect(converter.convert(30), equals("treizeci"));
      expect(converter.convert(54), equals("cincizeci și patru"));
      expect(converter.convert(68), equals("șaizeci și opt"));
      expect(converter.convert(99), equals("nouăzeci și nouă"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("o sută"));
      expect(converter.convert(101), equals("o sută unu"));
      expect(converter.convert(105), equals("o sută cinci"));
      expect(converter.convert(110), equals("o sută zece"));
      expect(converter.convert(111), equals("o sută unsprezece"));
      expect(converter.convert(123), equals("o sută douăzeci și trei"));
      expect(converter.convert(200), equals("două sute"));
      expect(converter.convert(321), equals("trei sute douăzeci și unu"));
      expect(converter.convert(479), equals("patru sute șaptezeci și nouă"));
      expect(converter.convert(596), equals("cinci sute nouăzeci și șase"));
      expect(converter.convert(681), equals("șase sute optzeci și unu"));
      expect(converter.convert(999), equals("nouă sute nouăzeci și nouă"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("o mie"));
      expect(converter.convert(1001), equals("o mie unu"));
      expect(converter.convert(1011), equals("o mie unsprezece"));
      expect(converter.convert(1110), equals("o mie o sută zece"));
      expect(converter.convert(1111), equals("o mie o sută unsprezece"));
      expect(converter.convert(2000), equals("două mii"));
      expect(converter.convert(2468),
          equals("două mii patru sute șaizeci și opt"));
      expect(converter.convert(3579),
          equals("trei mii cinci sute șaptezeci și nouă"));
      expect(converter.convert(10000), equals("zece mii"));
      expect(converter.convert(10011), equals("zece mii unsprezece"));
      expect(converter.convert(11100), equals("unsprezece mii o sută"));
      expect(converter.convert(12987),
          equals("douăsprezece mii nouă sute optzeci și șapte"));
      expect(converter.convert(21000), equals("douăzeci și una de mii"));
      expect(converter.convert(22000), equals("douăzeci și două de mii"));
      expect(converter.convert(45623),
          equals("patruzeci și cinci de mii șase sute douăzeci și trei"));
      expect(converter.convert(87654),
          equals("optzeci și șapte de mii șase sute cincizeci și patru"));
      expect(converter.convert(100000), equals("o sută de mii"));
      expect(
        converter.convert(123456),
        equals("o sută douăzeci și trei de mii patru sute cincizeci și șase"),
      );
      expect(
          converter.convert(987654),
          equals(
              "nouă sute optzeci și șapte de mii șase sute cincizeci și patru"));
      expect(
        converter.convert(999999),
        equals("nouă sute nouăzeci și nouă de mii nouă sute nouăzeci și nouă"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus unu"));
      expect(converter.convert(-123), equals("minus o sută douăzeci și trei"));
      expect(converter.convert(-123.456),
          equals("minus o sută douăzeci și trei virgulă patru cinci șase"));
      const options = RoOptions(negativePrefix: "negativ ");
      expect(converter.convert(-1, options: options), equals("negativ unu"));
      expect(converter.convert(-123, options: options),
          equals("negativ o sută douăzeci și trei"));
      expect(converter.convert(-123.456, options: options),
          equals("negativ o sută douăzeci și trei virgulă patru cinci șase"));
    });

    test('Decimals', () {
      expect(
        converter.convert(123.456),
        equals("o sută douăzeci și trei virgulă patru cinci șase"),
      );
      expect(converter.convert(1.5), equals("unu virgulă cinci"));
      expect(converter.convert(1.05), equals("unu virgulă zero cinci"));
      expect(converter.convert(879.465),
          equals("opt sute șaptezeci și nouă virgulă patru șase cinci"));
      expect(converter.convert(1.5), equals("unu virgulă cinci"));

      const pointOption = RoOptions(decimalSeparator: DecimalSeparator.point);
      expect(converter.convert(1.5, options: pointOption),
          equals("unu punct cinci"));
      const commaOption = RoOptions(decimalSeparator: DecimalSeparator.comma);
      expect(converter.convert(1.5, options: commaOption),
          equals("unu virgulă cinci"));
      const periodOption = RoOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(1.5, options: periodOption),
          equals("unu punct cinci"));
      expect(converter.convert(0.5), equals("zero virgulă cinci"));
    });

    test('Year Formatting', () {
      const yearOption = RoOptions(format: Format.year);
      expect(converter.convert(123, options: yearOption),
          equals("o sută douăzeci și trei"));
      expect(converter.convert(498, options: yearOption),
          equals("patru sute nouăzeci și opt"));
      expect(converter.convert(756, options: yearOption),
          equals("șapte sute cincizeci și șase"));
      expect(converter.convert(1900, options: yearOption),
          equals("o mie nouă sute"));
      expect(converter.convert(1999, options: yearOption),
          equals("o mie nouă sute nouăzeci și nouă"));
      expect(converter.convert(2025, options: yearOption),
          equals("două mii douăzeci și cinci"));

      const yearOptionAD = RoOptions(format: Format.year, includeAD: true);
      expect(converter.convert(1900, options: yearOptionAD),
          equals("o mie nouă sute d.Hr."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("o mie nouă sute nouăzeci și nouă d.Hr."));
      expect(
        converter.convert(2025, options: yearOptionAD),
        equals("două mii douăzeci și cinci d.Hr."),
      );
      expect(converter.convert(-1, options: yearOption), equals("unu î.Hr."));
      expect(
          converter.convert(-100, options: yearOption), equals("o sută î.Hr."));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("o sută î.Hr."));
      expect(
        converter.convert(-2025, options: yearOption),
        equals("două mii douăzeci și cinci î.Hr."),
      );
      expect(
        converter.convert(-1000000, options: yearOption),
        equals("un milion î.Hr."),
      );
    });

    test('Currency', () {
      const currencyOption = RoOptions(currency: true);
      expect(converter.convert(0, options: currencyOption), equals("zero lei"));
      expect(converter.convert(1, options: currencyOption), equals("un leu"));
      expect(converter.convert(2, options: currencyOption), equals("doi lei"));
      expect(
          converter.convert(5, options: currencyOption), equals("cinci lei"));
      expect(
          converter.convert(10, options: currencyOption), equals("zece lei"));
      expect(converter.convert(11, options: currencyOption),
          equals("unsprezece lei"));
      expect(converter.convert(19, options: currencyOption),
          equals("nouăsprezece lei"));
      expect(converter.convert(20, options: currencyOption),
          equals("douăzeci de lei"));
      expect(converter.convert(21, options: currencyOption),
          equals("douăzeci și unu de lei"));
      expect(converter.convert(101, options: currencyOption),
          equals("o sută unu lei"));
      expect(converter.convert(119, options: currencyOption),
          equals("o sută nouăsprezece lei"));
      expect(converter.convert(120, options: currencyOption),
          equals("o sută douăzeci de lei"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("un leu și cincizeci de bani"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("o sută douăzeci și trei de lei și patruzeci și cinci de bani"),
      );
      expect(converter.convert(10000000, options: currencyOption),
          equals("zece milioane de lei"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("cincizeci de bani"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("un leu și un ban"));
      expect(converter.convert(1.02, options: currencyOption),
          equals("un leu și doi bani"));
      expect(
        converter.convert(1.19, options: currencyOption),
        equals("un leu și nouăsprezece bani"),
      );
      expect(
        converter.convert(1.20, options: currencyOption),
        equals("un leu și douăzeci de bani"),
      );
      expect(
        converter.convert(1.21, options: currencyOption),
        equals("un leu și douăzeci și unu de bani"),
      );
      expect(
        converter.convert(2.50, options: currencyOption),
        equals("doi lei și cincizeci de bani"),
      );
      expect(
          converter.convert(0.01, options: currencyOption), equals("un ban"));
      expect(
          converter.convert(0.02, options: currencyOption), equals("doi bani"));
      expect(converter.convert(0.19, options: currencyOption),
          equals("nouăsprezece bani"));
      expect(converter.convert(0.20, options: currencyOption),
          equals("douăzeci de bani"));
      expect(converter.convert(0.21, options: currencyOption),
          equals("douăzeci și unu de bani"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("un milion"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("două miliarde"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("trei trilioane"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("patru cvadrilioane"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("cinci cvintilioane"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("șase sextilioane"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("șapte septilioane"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
          "nouă cvintilioane opt sute șaptezeci și șase de cvadrilioane cinci sute patruzeci și trei de trilioane două sute zece miliarde o sută douăzeci și trei de milioane patru sute cincizeci și șase de mii șapte sute optzeci și nouă",
        ),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "o sută douăzeci și trei de sextilioane patru sute cincizeci și șase de cvintilioane șapte sute optzeci și nouă de cvadrilioane o sută douăzeci și trei de trilioane patru sute cincizeci și șase de miliarde șapte sute optzeci și nouă de milioane o sută douăzeci și trei de mii patru sute cincizeci și șase",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "nouă sute nouăzeci și nouă de sextilioane nouă sute nouăzeci și nouă de cvintilioane nouă sute nouăzeci și nouă de cvadrilioane nouă sute nouăzeci și nouă de trilioane nouă sute nouăzeci și nouă de miliarde nouă sute nouăzeci și nouă de milioane nouă sute nouăzeci și nouă de mii nouă sute nouăzeci și nouă",
        ),
      );

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("un trilion două milioane trei"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("cinci milioane o mie"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("un miliard unu"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("un miliard un milion"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("două milioane o mie"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "un trilion nouă sute optzeci și șapte de milioane șase sute de mii trei"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Nu Este Un Număr"));
      expect(converter.convert(double.infinity), equals("Infinit"));
      expect(converter.convert(double.negativeInfinity),
          equals("Infinit Negativ"));
      expect(converter.convert(null), equals("Nu Este Un Număr"));
      expect(converter.convert('abc'), equals("Nu Este Un Număr"));
      expect(converter.convert([]), equals("Nu Este Un Număr"));
      expect(converter.convert({}), equals("Nu Este Un Număr"));
      expect(converter.convert(Object()), equals("Nu Este Un Număr"));

      expect(
          converterWithFallback.convert(double.nan), equals("Număr Invalid"));
      expect(converterWithFallback.convert(double.infinity), equals("Infinit"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Infinit Negativ"));
      expect(converterWithFallback.convert(null), equals("Număr Invalid"));
      expect(converterWithFallback.convert('abc'), equals("Număr Invalid"));
      expect(converterWithFallback.convert([]), equals("Număr Invalid"));
      expect(converterWithFallback.convert({}), equals("Număr Invalid"));
      expect(converterWithFallback.convert(Object()), equals("Număr Invalid"));
      expect(converterWithFallback.convert(123),
          equals("o sută douăzeci și trei"));
    });
  });
}
