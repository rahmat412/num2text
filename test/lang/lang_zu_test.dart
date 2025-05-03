import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Zulu (ZU)', () {
    final converter = Num2Text(initialLang: Lang.ZU);
    final converterWithFallback = Num2Text(
        initialLang: Lang.ZU, fallbackOnError: "Inani Elingekho Emthethweni");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("qanda"));
      expect(converter.convert(10), equals("lishumi"));
      expect(converter.convert(11), equals("lishumi nanye"));
      expect(converter.convert(13), equals("lishumi nanthathu"));
      expect(converter.convert(15), equals("lishumi nanhlanu"));
      expect(converter.convert(20), equals("amashumi amabili"));
      expect(converter.convert(27), equals("amashumi amabili nesikhombisa"));
      expect(converter.convert(30), equals("amashumi amathathu"));
      expect(converter.convert(54), equals("amashumi amahlanu nane"));
      expect(converter.convert(68),
          equals("amashumi ayisithupha nesishiyagalombili"));
      expect(converter.convert(99),
          equals("amashumi ayisishiyagalolunye nesishiyagalolunye"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("ikhulu"));
      expect(converter.convert(101), equals("ikhulu nanye"));
      expect(converter.convert(105), equals("ikhulu nanhlanu"));
      expect(converter.convert(110), equals("ikhulu nelishumi"));
      expect(converter.convert(111), equals("ikhulu nelishumi nanye"));
      expect(
          converter.convert(123), equals("ikhulu namashumi amabili nanthathu"));
      expect(converter.convert(200), equals("amakhulu amabili"));
      expect(converter.convert(321),
          equals("amakhulu amathathu namashumi amabili nanye"));
      expect(converter.convert(479),
          equals("amakhulu amane namashumi ayisikhombisa nesishiyagalolunye"));
      expect(converter.convert(596),
          equals("amakhulu amahlanu namashumi ayisishiyagalolunye nesithupha"));
      expect(converter.convert(681),
          equals("amakhulu ayisithupha namashumi ayisishiyagalombili nanye"));
      expect(
          converter.convert(999),
          equals(
              "amakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("inkulungwane"));
      expect(converter.convert(1001), equals("inkulungwane nanye"));
      expect(converter.convert(1011), equals("inkulungwane nelishumi nanye"));
      expect(converter.convert(1110), equals("inkulungwane nekhulu nelishumi"));
      expect(converter.convert(1111),
          equals("inkulungwane nekhulu nelishumi nanye"));
      expect(converter.convert(2000), equals("izinkulungwane ezimbili"));
      expect(
          converter.convert(2468),
          equals(
              "izinkulungwane ezimbili namakhulu amane namashumi ayisithupha nesishiyagalombili"));
      expect(
          converter.convert(3579),
          equals(
              "izinkulungwane ezintathu namakhulu amahlanu namashumi ayisikhombisa nesishiyagalolunye"));
      expect(converter.convert(10000), equals("izinkulungwane eziyishumi"));
      expect(converter.convert(10011),
          equals("izinkulungwane eziyishumi nelishumi nanye"));
      expect(converter.convert(11100),
          equals("izinkulungwane eziyishumi nanye nekhulu"));
      expect(
          converter.convert(12987),
          equals(
              "izinkulungwane eziyishumi nambili namakhulu ayisishiyagalolunye namashumi ayisishiyagalombili nesikhombisa"));
      expect(
          converter.convert(45623),
          equals(
              "izinkulungwane ezingamashumi amane nanhlanu namakhulu ayisithupha namashumi amabili nanthathu"));
      expect(
          converter.convert(87654),
          equals(
              "izinkulungwane ezingamashumi ayisishiyagalombili nesikhombisa namakhulu ayisithupha namashumi amahlanu nane"));
      expect(converter.convert(100000), equals("izinkulungwane eziyikhulu"));
      expect(
          converter.convert(123456),
          equals(
              "izinkulungwane eziyikhulu namashumi amabili nanthathu namakhulu amane namashumi amahlanu nesithupha"));
      expect(
          converter.convert(987654),
          equals(
              "izinkulungwane ezingamakhulu ayisishiyagalolunye namashumi ayisishiyagalombili nesikhombisa namakhulu ayisithupha namashumi amahlanu nane"));
      expect(
          converter.convert(999999),
          equals(
              "izinkulungwane ezingamakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye namakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("okubi nye"));
      expect(converter.convert(-123),
          equals("okubi ikhulu namashumi amabili nanthathu"));
      expect(
          converter.convert(-123.456),
          equals(
              "okubi ikhulu namashumi amabili nanthathu iphoyinti kane hlanu sithupha"));

      const negativeOption = ZuOptions(negativePrefix: "minus");
      expect(
          converter.convert(-1, options: negativeOption), equals("minus nye"));
      expect(converter.convert(-123, options: negativeOption),
          equals("minus ikhulu namashumi amabili nanthathu"));
      expect(
          converter.convert(-123.456, options: negativeOption),
          equals(
              "minus ikhulu namashumi amabili nanthathu iphoyinti kane hlanu sithupha"));
    });

    test('Decimals', () {
      expect(
          converter.convert(123.456),
          equals(
              "ikhulu namashumi amabili nanthathu iphoyinti kane hlanu sithupha"));
      expect(converter.convert(1.50), equals("nye iphoyinti hlanu"));
      expect(converter.convert(1.05), equals("nye iphoyinti qanda hlanu"));
      expect(
          converter.convert(879.465),
          equals(
              "amakhulu ayisishiyagalombili namashumi ayisikhombisa nesishiyagalolunye iphoyinti kane sithupha hlanu"));
      expect(converter.convert(1.5), equals("nye iphoyinti hlanu"));

      const pointOption = ZuOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = ZuOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = ZuOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(1.5, options: pointOption),
          equals("nye iphoyinti hlanu"));
      expect(converter.convert(1.5, options: commaOption),
          equals("nye ukhefana hlanu"));
      expect(converter.convert(1.5, options: periodOption),
          equals("nye iphoyinti hlanu"));
    });

    test('Year Formatting', () {
      const yearOption = ZuOptions(format: Format.year);
      expect(converter.convert(123, options: yearOption),
          equals("ikhulu namashumi amabili nanthathu"));
      expect(
          converter.convert(498, options: yearOption),
          equals(
              "amakhulu amane namashumi ayisishiyagalolunye nesishiyagalombili"));
      expect(converter.convert(756, options: yearOption),
          equals("amakhulu ayisikhombisa namashumi amahlanu nesithupha"));
      expect(converter.convert(1900, options: yearOption),
          equals("inkulungwane namakhulu ayisishiyagalolunye"));
      expect(
          converter.convert(1999, options: yearOption),
          equals(
              "inkulungwane namakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye"));
      expect(converter.convert(2025, options: yearOption),
          equals("izinkulungwane ezimbili namashumi amabili nanhlanu"));

      const yearOptionAD = ZuOptions(format: Format.year, includeAD: true);
      expect(converter.convert(1900, options: yearOptionAD),
          equals("inkulungwane namakhulu ayisishiyagalolunye AD"));
      expect(
          converter.convert(1999, options: yearOptionAD),
          equals(
              "inkulungwane namakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye AD"));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("izinkulungwane ezimbili namashumi amabili nanhlanu AD"));

      expect(converter.convert(-1, options: yearOption), equals("nye BC"));
      expect(converter.convert(-100, options: yearOption), equals("ikhulu BC"));
      expect(
          converter.convert(-100, options: yearOptionAD), equals("ikhulu BC"));
      expect(converter.convert(-2025, options: yearOption),
          equals("izinkulungwane ezimbili namashumi amabili nanhlanu BC"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("isigidi esisodwa BC"));
    });

    test('Currency', () {
      const currencyOption = ZuOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("qanda amaRandi"));
      expect(converter.convert(1, options: currencyOption),
          equals("iRandi elilodwa"));
      expect(converter.convert(2, options: currencyOption),
          equals("amaRandi amabili"));
      expect(converter.convert(5, options: currencyOption),
          equals("amaRandi amahlanu"));
      expect(converter.convert(10, options: currencyOption),
          equals("amaRandi ayishumi"));
      expect(converter.convert(11, options: currencyOption),
          equals("amaRandi ayishumi nanye"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("iRandi elilodwa no amasenti angamashumi amahlanu"));
      expect(
          converter.convert(123.45, options: currencyOption),
          equals(
              "amaRandi ayikhulu namashumi amabili nanthathu no amasenti angamashumi amane nanhlanu"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("izigidi eziyishumi amaRandi"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("amasenti angamashumi amahlanu"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("isenti elilodwa"));
      expect(converter.convert(0.02, options: currencyOption),
          equals("amasenti amabili"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("amasenti amahlanu"));
      expect(converter.convert(0.10, options: currencyOption),
          equals("amasenti ayishumi"));
      expect(converter.convert(0.11, options: currencyOption),
          equals("amasenti ayishumi nanye"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("iRandi elilodwa no isenti elilodwa"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("amaRandi amabili no amasenti amabili"));
      expect(converter.convert(5.05, options: currencyOption),
          equals("amaRandi amahlanu no amasenti amahlanu"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)),
          equals("isigidi esisodwa"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("amabhiliyoni amabili"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("amathriliyoni amathathu"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("amakhwadriliyoni amane"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("amakhwintiliyoni amahlanu"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("amasekstiliyoni ayisithupha"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("amaseptiliyoni ayisikhombisa"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('ithriliyoni elilodwa nezigidi ezimbili nanthathu'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals('izigidi ezinhlanu nenkulungwane'));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals('ibhiliyoni elilodwa nanye'));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals('ibhiliyoni elilodwa nesigidi esisodwa'));
      expect(converter.convert(BigInt.parse('2001000')),
          equals('izigidi ezimbili nenkulungwane'));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              'ithriliyoni elilodwa nezigidi ezingamakhulu ayisishiyagalolunye namashumi ayisishiyagalombili nesikhombisa nezinkulungwane ezingamakhulu ayisithupha nanthathu'));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            "amakhwintiliyoni ayisishiyagalolunye namakhwadriliyoni angamakhulu ayisishiyagalombili namashumi ayisikhombisa nesithupha namathriliyoni angamakhulu amahlanu namashumi amane nanthathu namabhiliyoni angamakhulu amabili nelishumi nezigidi eziyikhulu namashumi amabili nanthathu nezinkulungwane ezingamakhulu amane namashumi amahlanu nesithupha namakhulu ayisikhombisa namashumi ayisishiyagalombili nesishiyagalolunye"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "amasekstiliyoni ayikhulu namashumi amabili nanthathu namakhwintiliyoni angamakhulu amane namashumi amahlanu nesithupha namakhwadriliyoni angamakhulu ayisikhombisa namashumi ayisishiyagalombili nesishiyagalolunye namathriliyoni ayikhulu namashumi amabili nanthathu namabhiliyoni angamakhulu amane namashumi amahlanu nesithupha nezigidi ezingamakhulu ayisikhombisa namashumi ayisishiyagalombili nesishiyagalolunye nezinkulungwane eziyikhulu namashumi amabili nanthathu namakhulu amane namashumi amahlanu nesithupha"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "amasekstiliyoni angamakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye namakhwintiliyoni angamakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye namakhwadriliyoni angamakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye namathriliyoni angamakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye namabhiliyoni angamakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye nezigidi ezingamakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye nezinkulungwane ezingamakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye namakhulu ayisishiyagalolunye namashumi ayisishiyagalolunye nesishiyagalolunye"),
      );
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Akulona Inani"));
      expect(converter.convert(double.infinity), equals("Okungapheli"));
      expect(converter.convert(double.negativeInfinity),
          equals("Okubi Okungapheli"));
      expect(converter.convert(null), equals("Akulona Inani"));
      expect(converter.convert('abc'), equals("Akulona Inani"));
      expect(converter.convert([]), equals("Akulona Inani"));
      expect(converter.convert({}), equals("Akulona Inani"));
      expect(converter.convert(Object()), equals("Akulona Inani"));

      expect(converterWithFallback.convert(double.nan),
          equals("Inani Elingekho Emthethweni"));
      expect(converterWithFallback.convert(double.infinity),
          equals("Okungapheli"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Okubi Okungapheli"));
      expect(converterWithFallback.convert(null),
          equals("Inani Elingekho Emthethweni"));
      expect(converterWithFallback.convert('abc'),
          equals("Inani Elingekho Emthethweni"));
      expect(converterWithFallback.convert([]),
          equals("Inani Elingekho Emthethweni"));
      expect(converterWithFallback.convert({}),
          equals("Inani Elingekho Emthethweni"));
      expect(converterWithFallback.convert(Object()),
          equals("Inani Elingekho Emthethweni"));
      expect(converterWithFallback.convert(123),
          equals("ikhulu namashumi amabili nanthathu"));
    });
  });
}
