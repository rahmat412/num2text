import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Romanian (RO)', () {
    final converter = Num2Text(initialLang: Lang.RO);
    final converterWithFallback =
        Num2Text(initialLang: Lang.RO, fallbackOnError: "Număr invalid");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("zero"));
      expect(converter.convert(1), equals("unu"));
      expect(converter.convert(2), equals("doi"));
      expect(converter.convert(10), equals("zece"));
      expect(converter.convert(11), equals("unsprezece"));
      expect(converter.convert(19), equals("nouăsprezece"));
      expect(converter.convert(20), equals("douăzeci"));
      expect(converter.convert(21), equals("douăzeci și unu"));
      expect(converter.convert(99), equals("nouăzeci și nouă"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("o sută"));
      expect(converter.convert(101), equals("o sută unu"));
      expect(converter.convert(111), equals("o sută unsprezece"));
      expect(converter.convert(200), equals("două sute"));
      expect(converter.convert(999), equals("nouă sute nouăzeci și nouă"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("o mie"));
      expect(converter.convert(1001), equals("o mie unu"));
      expect(converter.convert(1111), equals("o mie o sută unsprezece"));
      expect(converter.convert(2000), equals("două mii"));
      expect(converter.convert(10000), equals("zece mii"));
      expect(converter.convert(100000), equals("o sută de mii"));
      expect(
        converter.convert(123456),
        equals("o sută douăzeci și trei de mii patru sute cincizeci și șase"),
      );
      expect(
        converter.convert(999999),
        equals("nouă sute nouăzeci și nouă de mii nouă sute nouăzeci și nouă"),
      );
      expect(converter.convert(21000), equals("douăzeci și una de mii"));
      expect(converter.convert(22000), equals("douăzeci și două de mii"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus unu"));
      expect(converter.convert(-123), equals("minus o sută douăzeci și trei"));
      expect(
        converter.convert(-1, options: RoOptions(negativePrefix: "negativ ")),
        equals("negativ unu"),
      );
      expect(
        converter.convert(-123, options: RoOptions(negativePrefix: "negativ ")),
        equals("negativ o sută douăzeci și trei"),
      );
    });

    test('Year Formatting', () {
      const yearOption = RoOptions(format: Format.year);
      const yearOptionAD = RoOptions(format: Format.year, includeAD: true);
      expect(converter.convert(1900, options: yearOption),
          equals("o mie nouă sute"));
      expect(converter.convert(2024, options: yearOption),
          equals("două mii douăzeci și patru"));
      expect(
        converter.convert(2024, options: yearOptionAD),
        equals("două mii douăzeci și patru d.Hr."),
      );
      expect(
          converter.convert(-100, options: yearOption), equals("o sută î.Hr."));
      expect(converter.convert(-1, options: yearOption), equals("unu î.Hr."));
      expect(
        converter.convert(-2024, options: yearOption),
        equals("două mii douăzeci și patru î.Hr."),
      );
    });

    test('Currency', () {
      const currencyOption = RoOptions(currency: true);
      expect(converter.convert(0, options: currencyOption), equals("zero lei"));
      expect(converter.convert(1, options: currencyOption), equals("un leu"));
      expect(converter.convert(2, options: currencyOption), equals("doi lei"));
      expect(converter.convert(20, options: currencyOption),
          equals("douăzeci de lei"));
      expect(converter.convert(101, options: currencyOption),
          equals("o sută unu lei"));
      expect(converter.convert(120, options: currencyOption),
          equals("o sută douăzeci de lei"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("un leu și un ban"));
      expect(converter.convert(1.02, options: currencyOption),
          equals("un leu și doi bani"));
      expect(
        converter.convert(1.20, options: currencyOption),
        equals("un leu și douăzeci de bani"),
      );
      expect(
        converter.convert(2.50, options: currencyOption),
        equals("doi lei și cincizeci de bani"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("o sută douăzeci și trei de lei și patruzeci și cinci de bani"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("o sută douăzeci și trei virgulă patru cinci șase"),
      );
      expect(converter.convert(Decimal.parse('1.50')),
          equals("unu virgulă cinci"));
      expect(converter.convert(123.0), equals("o sută douăzeci și trei"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("o sută douăzeci și trei"));
      expect(
        converter.convert(1.5,
            options: const RoOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("unu virgulă cinci"),
      );
      expect(
        converter.convert(1.5,
            options:
                const RoOptions(decimalSeparator: DecimalSeparator.period)),
        equals("unu punct cinci"),
      );
      expect(
        converter.convert(1.5,
            options: const RoOptions(decimalSeparator: DecimalSeparator.point)),
        equals("unu punct cinci"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Infinit"));
      expect(converter.convert(double.negativeInfinity),
          equals("Infinit negativ"));
      expect(converter.convert(double.nan), equals("Nu este un număr"));
      expect(converter.convert(null), equals("Nu este un număr"));
      expect(converter.convert('abc'), equals("Nu este un număr"));

      expect(converterWithFallback.convert(double.infinity), equals("Infinit"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Infinit negativ"));
      expect(
          converterWithFallback.convert(double.nan), equals("Număr invalid"));
      expect(converterWithFallback.convert(null), equals("Număr invalid"));
      expect(converterWithFallback.convert('abc'), equals("Număr invalid"));
      expect(converterWithFallback.convert(123),
          equals("o sută douăzeci și trei"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("un milion"));
      expect(converter.convert(BigInt.from(2000000)), equals("două milioane"));
      expect(converter.convert(BigInt.from(1000000000)), equals("un miliard"));
      expect(
          converter.convert(BigInt.from(2000000000)), equals("două miliarde"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("un trilion"));
      expect(converter.convert(BigInt.from(2000000000000)),
          equals("două trilioane"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("un cvadrilion"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("un cvintilion"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("un sextilion"));
      expect(converter.convert(BigInt.parse('1000000000000000000000000')),
          equals("un septilion"));
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
    });
  });
}
