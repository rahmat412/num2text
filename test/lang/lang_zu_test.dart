import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Zulu (ZU)', () {
    final converter = Num2Text(initialLang: Lang.ZU);
    final converterWithFallback = Num2Text(
      initialLang: Lang.ZU,
      fallbackOnError: "Inani elingekho emthethweni",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("zero"));
      expect(converter.convert(1), equals("nye"));
      expect(converter.convert(2), equals("bili"));
      expect(converter.convert(3), equals("thathu"));
      expect(converter.convert(4), equals("ne"));
      expect(converter.convert(5), equals("hlanu"));
      expect(converter.convert(6), equals("sithupha"));
      expect(converter.convert(7), equals("khombisa"));
      expect(converter.convert(8), equals("shiyagalombili"));
      expect(converter.convert(9), equals("shiyagalolunye"));
      expect(converter.convert(10), equals("lishumi"));
      expect(converter.convert(11), equals("lishumi nanye"));
      expect(converter.convert(19), equals("lishumi nesishiyagalolunye"));
      expect(converter.convert(20), equals("amashumi amabili"));
      expect(converter.convert(21), equals("amashumi amabili nanye"));
      expect(converter.convert(55), equals("amashumi amahlanu nanhlanu"));
      expect(converter.convert(99),
          equals("amashumi ayisishiyagalolunye nesishiyagalolunye"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("ikhulu"));
      expect(converter.convert(101), equals("ikhulu nanye"));
      expect(converter.convert(110), equals("ikhulu nelishumi"));
      expect(converter.convert(111), equals("ikhulu nelishumi nanye"));
      expect(
          converter.convert(123), equals("ikhulu namashumi amabili nanthathu"));
      expect(converter.convert(200), equals("amakhulu amabili"));
      expect(converter.convert(500), equals("amakhulu amahlanu"));
      expect(converter.convert(900), equals("amakhulu ayisishiyagalolunye"));
      expect(
        converter.convert(999),
        equals(
            "amakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye"),
      );
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("inkulungwane"));
      expect(converter.convert(1001), equals("inkulungwane nanye"));
      expect(converter.convert(1010), equals("inkulungwane nelishumi"));
      expect(converter.convert(1100), equals("inkulungwane nekhulu"));
      expect(converter.convert(1111),
          equals("inkulungwane nekhulu nelishumi nanye"));
      expect(converter.convert(2000), equals("izinkulungwane ezimbili"));
      expect(converter.convert(5000), equals("izinkulungwane ezinhlanu"));
      expect(converter.convert(9000),
          equals("izinkulungwane eziyishiyagalolunye"));
      expect(converter.convert(10000), equals("izinkulungwane eziyishumi"));
      expect(
          converter.convert(11000), equals("izinkulungwane eziyishumi nanye"));
      expect(converter.convert(21000),
          equals("izinkulungwane ezingamashumi amabili nanye"));
      expect(converter.convert(100000), equals("izinkulungwane eziyikhulu"));
      expect(converter.convert(101001),
          equals("izinkulungwane eziyikhulu nanye nanye"));
      expect(
        converter.convert(123456),
        equals(
          "izinkulungwane eziyikhulu namashumi amabili nanthathu namakhulu amane namashumi amahlanu nesithupha",
        ),
      );
      expect(
        converter.convert(999999),
        equals(
          "izinkulungwane ezingamakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye namakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye",
        ),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("okubi nye"));
      expect(converter.convert(-123),
          equals("okubi ikhulu namashumi amabili nanthathu"));
      expect(
        converter.convert(-1, options: ZuOptions(negativePrefix: "minus")),
        equals("minus nye"),
      );
      expect(
        converter.convert(-123, options: ZuOptions(negativePrefix: "minus")),
        equals("minus ikhulu namashumi amabili nanthathu"),
      );
    });

    test('Year Formatting', () {
      const yearOption = ZuOptions(format: Format.year);
      expect(
        converter.convert(1900, options: yearOption),
        equals("inkulungwane namakhulu ayisishiyagalolunye"),
      );
      expect(
        converter.convert(2024, options: yearOption),
        equals("izinkulungwane ezimbili namashumi amabili nane"),
      );
      expect(
        converter.convert(1900,
            options: ZuOptions(format: Format.year, includeAD: true)),
        equals("inkulungwane namakhulu ayisishiyagalolunye AD"),
      );
      expect(
        converter.convert(2024,
            options: ZuOptions(format: Format.year, includeAD: true)),
        equals("izinkulungwane ezimbili namashumi amabili nane AD"),
      );
      expect(converter.convert(-100, options: yearOption), equals("ikhulu BC"));
      expect(converter.convert(-1, options: yearOption), equals("nye BC"));
      expect(
        converter.convert(-2024,
            options: ZuOptions(format: Format.year, includeAD: true)),
        equals("izinkulungwane ezimbili namashumi amabili nane BC"),
      );
    });

    test('Currency', () {
      const currencyOptionZar = ZuOptions(currency: true);
      expect(converter.convert(0, options: currencyOptionZar),
          equals("zero amaRandi"));
      expect(converter.convert(1, options: currencyOptionZar),
          equals("iRandi elilodwa"));
      expect(converter.convert(2, options: currencyOptionZar),
          equals("amaRandi amabili"));
      expect(
        converter.convert(1.50, options: currencyOptionZar),
        equals("iRandi elilodwa no amasenti angamashumi amahlanu"),
      );
      expect(
        converter.convert(0.75, options: currencyOptionZar),
        equals("amasenti angamashumi ayisikhombisa nanhlanu"),
      );
      expect(converter.convert(0.01, options: currencyOptionZar),
          equals("isenti elisodwa"));
      expect(
        converter.convert(123.45, options: currencyOptionZar),
        equals(
          "amaRandi ayikhulu namashumi amabili nanthathu no amasenti angamashumi amane nanhlanu",
        ),
      );
      expect(
        converter.convert(123, options: currencyOptionZar),
        equals("amaRandi ayikhulu namashumi amabili nanthathu"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("ikhulu namashumi amabili nanthathu iphoyinti four five six"),
      );
      expect(converter.convert(Decimal.parse('0.5')),
          equals("zero iphoyinti five"));
      expect(converter.convert(Decimal.parse('1.50')),
          equals("nye iphoyinti five"));
      expect(converter.convert(123.0),
          equals("ikhulu namashumi amabili nanthathu"));
      expect(
        converter.convert(Decimal.parse('123.0')),
        equals("ikhulu namashumi amabili nanthathu"),
      );
      expect(
        converter.convert(1.5,
            options: const ZuOptions(decimalSeparator: DecimalSeparator.point)),
        equals("nye iphoyinti five"),
      );
      expect(
        converter.convert(1.5,
            options:
                const ZuOptions(decimalSeparator: DecimalSeparator.period)),
        equals("nye iphoyinti five"),
      );
      expect(
        converter.convert(1.5,
            options: const ZuOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("nye ikhefu five"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Infinity"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negative Infinity"));
      expect(converter.convert(double.nan), equals("Not a Number"));
      expect(converter.convert(null), equals("Not a Number"));
      expect(converter.convert('abc'), equals("Not a Number"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Infinity"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negative Infinity"));
      expect(converterWithFallback.convert(double.nan),
          equals("Inani elingekho emthethweni"));
      expect(converterWithFallback.convert(null),
          equals("Inani elingekho emthethweni"));
      expect(converterWithFallback.convert('abc'),
          equals("Inani elingekho emthethweni"));
    });

    test('Scale Numbers', () {
      expect(
          converter.convert(BigInt.from(1000000)), equals("isigidi esisodwa"));
      expect(
          converter.convert(BigInt.from(2000000)), equals("izigidi ezimbili"));
      expect(converter.convert(BigInt.from(1001000)),
          equals("isigidi esisodwa nenkulungwane"));
      expect(converter.convert(BigInt.from(1000000000)),
          equals("ibhiliyoni elilodwa"));
      expect(converter.convert(BigInt.from(3000000000)),
          equals("amabhiliyoni amathathu"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("ithriliyoni elilodwa"));
      expect(converter.convert(BigInt.from(4000000000000)),
          equals("amathriliyoni amane"));

      expect(
        converter.convert(BigInt.parse('1001001001')),
        equals("ibhiliyoni elilodwa nesigidi esisodwa nenkulungwane nanye"),
      );
      expect(
        converter.convert(BigInt.parse('2003000004')),
        equals("amabhiliyoni amabili nezigidi ezintathu nane"),
      );
      expect(
        converter.convert(BigInt.parse('1000000000000000')),
        equals("ikhwadriliyoni elilodwa"),
      );
      expect(
        converter.convert(BigInt.parse('2000000000000000000')),
        equals("amakhwintiliyoni amabili"),
      );
      expect(
        converter.convert(BigInt.parse('1000000000000000000000')),
        equals("isekstiliyoni esisodwa"),
      );

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "amasekstiliyoni ayikhulu namashumi amabili nanthathu namakhwintiliyoni angamakhulu amane namashumi amahlanu nesithupha namakhwadriliyoni angamakhulu ayisikhombisa namashumi ayisishiyagalombili nesishiyagalolunye namathriliyoni ayikhulu namashumi amabili nanthathu namabhiliyoni angamakhulu amane namashumi amahlanu nesithupha nezigidi ezingamakhulu ayisikhombisa namashumi ayisishiyagalombili nesishiyagalolunye nezinkulungwane eziyikhulu namashumi amabili nanthathu namakhulu amane namashumi amahlanu nesithupha",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "amasekstiliyoni angamakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye namakhwintiliyoni angamakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye namakhwadriliyoni angamakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye namathriliyoni angamakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye namabhiliyoni angamakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye nezigidi ezingamakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye nezinkulungwane ezingamakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye namakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye",
        ),
      );
    });
  });
}
