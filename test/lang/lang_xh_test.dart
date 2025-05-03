import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Xhosa (XH)', () {
    final converter = Num2Text(initialLang: Lang.XH);
    final converterWithFallback =
        Num2Text(initialLang: Lang.XH, fallbackOnError: "Inani Elingalunganga");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("zero"));
      expect(converter.convert(1), equals("nye"));
      expect(converter.convert(9), equals("sithoba"));
      expect(converter.convert(10), equals("lishumi"));
      expect(converter.convert(11), equals("lishumi elinanye"));
      expect(converter.convert(13), equals("lishumi elinesithathu"));
      expect(converter.convert(15), equals("lishumi elinesihlanu"));
      expect(converter.convert(19), equals("lishumi elinesithoba"));
      expect(converter.convert(20), equals("amashumi amabini"));
      expect(converter.convert(21), equals("amashumi amabini ananye"));
      expect(converter.convert(27), equals("amashumi amabini anesixhenxe"));
      expect(converter.convert(30), equals("amashumi amathathu"));
      expect(converter.convert(54), equals("amashumi amahlanu anesine"));
      expect(converter.convert(68), equals("amashumi amathandathu anesibhozo"));
      expect(converter.convert(99), equals("amashumi asithoba anesithoba"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("ikhulu"));
      expect(converter.convert(101), equals("ikhulu elinanye"));
      expect(converter.convert(105), equals("ikhulu elinesihlanu"));
      expect(converter.convert(110), equals("ikhulu elineshumi"));
      expect(converter.convert(111), equals("ikhulu elineshumi elinanye"));
      expect(converter.convert(123),
          equals("ikhulu elinamashumi amabini anesithathu"));
      expect(converter.convert(199),
          equals("ikhulu elinamashumi asithoba anesithoba"));
      expect(converter.convert(200), equals("amakhulu amabini"));
      expect(converter.convert(202), equals("amakhulu amabini anesibini"));
      expect(converter.convert(321),
          equals("amakhulu amathathu anamashumi amabini ananye"));
      expect(converter.convert(479),
          equals("amakhulu amane anamashumi asixhenxe anesithoba"));
      expect(converter.convert(596),
          equals("amakhulu amahlanu anamashumi asithoba anesithandathu"));
      expect(converter.convert(681),
          equals("amakhulu amathandathu anamashumi asibhozo ananye"));
      expect(converter.convert(999),
          equals("amakhulu asithoba anamashumi asithoba anesithoba"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("iwaka elinye"));
      expect(converter.convert(1001), equals("iwaka elinanye"));
      expect(converter.convert(1011), equals("iwaka elineshumi elinanye"));
      expect(converter.convert(1100), equals("iwaka elinekhulu"));
      expect(converter.convert(1110), equals("iwaka elinekhulu elineshumi"));
      expect(converter.convert(1111),
          equals("iwaka elinekhulu elineshumi elinanye"));
      expect(converter.convert(2000), equals("amawaka amabini"));
      expect(converter.convert(2024),
          equals("amawaka amabini anamashumi amabini anesine"));
      expect(
          converter.convert(2468),
          equals(
              "amawaka amabini anamakhulu amane anamashumi amathandathu anesibhozo"));
      expect(
          converter.convert(3579),
          equals(
              "amawaka amathathu anamakhulu amahlanu anamashumi asixhenxe anesithoba"));
      expect(converter.convert(9000), equals("amawaka asithoba"));
      expect(
          converter.convert(9999),
          equals(
              "amawaka asithoba anamakhulu asithoba anamashumi asithoba anesithoba"));
      expect(converter.convert(10000), equals("amawaka alishumi"));
      expect(converter.convert(10011),
          equals("amawaka alishumi aneshumi elinanye"));
      expect(converter.convert(11100),
          equals("amawaka alishumi elinanye anekhulu"));
      expect(
          converter.convert(12987),
          equals(
              "amawaka alishumi elinambini anamakhulu asithoba anamashumi asibhozo anesixhenxe"));
      expect(
          converter.convert(45623),
          equals(
              "amashumi amane anesihlanu amawaka anamakhulu amathandathu anamashumi amabini anesithathu"));
      expect(
          converter.convert(87654),
          equals(
              "amashumi asibhozo anesixhenxe amawaka anamakhulu amathandathu anamashumi amahlanu anesine"));
      expect(converter.convert(100000), equals("ikhulu lamawaka"));
      expect(converter.convert(100001), equals("ikhulu lamawaka elinanye"));
      expect(
          converter.convert(123456),
          equals(
              "ikhulu elinamashumi amabini anesithathu amawaka anamakhulu amane anamashumi amahlanu anesithandathu"));
      expect(
          converter.convert(987654),
          equals(
              "amakhulu asithoba anamashumi asibhozo anesixhenxe amawaka anamakhulu amathandathu anamashumi amahlanu anesine"));
      expect(
          converter.convert(999999),
          equals(
              "amakhulu asithoba anamashumi asithoba anesithoba amawaka anamakhulu asithoba anamashumi asithoba anesithoba"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus nye"));
      expect(converter.convert(-123),
          equals("minus ikhulu elinamashumi amabini anesithathu"));
      expect(
          converter.convert(-123.456),
          equals(
              "minus ikhulu elinamashumi amabini anesithathu ichaphaza four five six"));

      const negativeOption = XhOptions(negativePrefix: "negative");
      expect(converter.convert(-1, options: negativeOption),
          equals("negative nye"));
      expect(converter.convert(-123, options: negativeOption),
          equals("negative ikhulu elinamashumi amabini anesithathu"));
      expect(
        converter.convert(-123.456, options: negativeOption),
        equals(
            "negative ikhulu elinamashumi amabini anesithathu ichaphaza four five six"),
      );
    });

    test('Decimals', () {
      expect(converter.convert(0.5), equals("zero ichaphaza five"));
      expect(converter.convert(0.05), equals("zero ichaphaza zero five"));
      expect(
          converter.convert(123.456),
          equals(
              "ikhulu elinamashumi amabini anesithathu ichaphaza four five six"));
      expect(converter.convert(1.5), equals("nye ichaphaza five"));
      expect(converter.convert(1.05), equals("nye ichaphaza zero five"));
      expect(
          converter.convert(879.465),
          equals(
              "amakhulu asibhozo anamashumi asixhenxe anesithoba ichaphaza four six five"));

      const pointOption = XhOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = XhOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = XhOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(1.5, options: pointOption),
          equals("nye ichaphaza five"));
      expect(converter.convert(1.5, options: commaOption),
          equals("nye ikoma five"));
      expect(converter.convert(1.5, options: periodOption),
          equals("nye ichaphaza five"));
    });

    test('Year Formatting', () {
      const yearOption = XhOptions(format: Format.year);
      expect(converter.convert(0, options: yearOption), equals("zero"));
      expect(converter.convert(123, options: yearOption),
          equals("ikhulu elinamashumi amabini anesithathu"));
      expect(converter.convert(498, options: yearOption),
          equals("amakhulu amane anamashumi asithoba anesibhozo"));
      expect(converter.convert(756, options: yearOption),
          equals("amakhulu asixhenxe anamashumi amahlanu anesithandathu"));
      expect(
          converter.convert(1000, options: yearOption), equals("iwaka elinye"));
      expect(converter.convert(1900, options: yearOption),
          equals("iwaka elinamakhulu asithoba"));
      expect(converter.convert(1999, options: yearOption),
          equals("iwaka elinamakhulu asithoba anamashumi asithoba anesithoba"));
      expect(converter.convert(2000, options: yearOption),
          equals("amawaka amabini"));
      expect(converter.convert(2025, options: yearOption),
          equals("amawaka amabini anamashumi amabini anesihlanu"));

      const yearOptionAD = XhOptions(format: Format.year, includeAD: true);
      expect(converter.convert(0, options: yearOptionAD), equals("zero"));
      expect(converter.convert(1, options: yearOptionAD), equals("nye AD"));
      expect(converter.convert(1900, options: yearOptionAD),
          equals("iwaka elinamakhulu asithoba AD"));
      expect(
          converter.convert(1999, options: yearOptionAD),
          equals(
              "iwaka elinamakhulu asithoba anamashumi asithoba anesithoba AD"));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("amawaka amabini anamashumi amabini anesihlanu AD"));

      expect(converter.convert(-1, options: yearOption), equals("nye BC"));
      expect(converter.convert(-100, options: yearOption), equals("ikhulu BC"));
      expect(
          converter.convert(-100, options: yearOptionAD), equals("ikhulu BC"));
      expect(
          converter.convert(-1999, options: yearOption),
          equals(
              "iwaka elinamakhulu asithoba anamashumi asithoba anesithoba BC"));
      expect(converter.convert(-2025, options: yearOption),
          equals("amawaka amabini anamashumi amabini anesihlanu BC"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("nye isigidi BC"));
    });

    test('Currency', () {
      const currencyOption = XhOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("zero iiRandi"));
      expect(
          converter.convert(1, options: currencyOption), equals("nye iRandi"));
      expect(converter.convert(2, options: currencyOption),
          equals("zimbini iiRandi"));
      expect(converter.convert(5, options: currencyOption),
          equals("zintlanu iiRandi"));
      expect(converter.convert(9, options: currencyOption),
          equals("zithoba iiRandi"));
      expect(converter.convert(10, options: currencyOption),
          equals("lishumi iiRandi"));
      expect(converter.convert(11, options: currencyOption),
          equals("lishumi elinanye iiRandi"));
      expect(converter.convert(20, options: currencyOption),
          equals("amashumi amabini iiRandi"));
      expect(converter.convert(99, options: currencyOption),
          equals("amashumi asithoba anesithoba iiRandi"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("nye iRandi ne amashumi amahlanu iisenti"));
      expect(
          converter.convert(123.45, options: currencyOption),
          equals(
              "ikhulu elinamashumi amabini anesithathu iiRandi ne amashumi amane anesihlanu iisenti"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("lishumi lezigidi iiRandi"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("amashumi amahlanu iisenti"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("nye isenti"));
      expect(converter.convert(0.02, options: currencyOption),
          equals("zimbini iisenti"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("zintlanu iisenti"));
      expect(converter.convert(0.10, options: currencyOption),
          equals("lishumi iisenti"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("nye iRandi ne nye isenti"));
      expect(converter.convert(1.02, options: currencyOption),
          equals("nye iRandi ne zimbini iisenti"));
      expect(converter.convert(2.01, options: currencyOption),
          equals("zimbini iiRandi ne nye isenti"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("zimbini iiRandi ne zimbini iisenti"));
      expect(converter.convert(5.15, options: currencyOption),
          equals("zintlanu iiRandi ne lishumi elinesihlanu iisenti"));
    });

    test('Scale Numbers', () {
      // expect(converter.convert(BigInt.from(10).pow(6)), equals("nye isigidi"));
      // expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(6)), equals("zimbini izigidi"));
      // expect(converter.convert(BigInt.from(10).pow(9)), equals("nye ibhiliyoni"));
      // expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
      //     equals("zimbini iibhiliyoni"));
      // expect(converter.convert(BigInt.from(10).pow(12)), equals("nye ithriliyoni"));
      // expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
      //     equals("zintathu iithriliyoni"));
      // expect(converter.convert(BigInt.from(10).pow(15)), equals("nye ikhwadriliyoni"));
      // expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
      //     equals("zine iikhwadriliyoni"));
      // expect(converter.convert(BigInt.from(10).pow(18)), equals("nye ikhwintiliyoni"));
      // expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
      //     equals("zintlanu iikhwintiliyoni"));
      // expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
      //     equals("zintandathu iisekstiliyoni"));
      // expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
      //     equals("zisixhenxe iiseptiliyoni"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('nye ithriliyoni zimbini izigidi nesithathu'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals('zintlanu izigidi nelinye iwaka'));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("nye ibhiliyoni enanye"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("nye ibhiliyoni nesigidi esinye"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("zimbini izigidi nelinye iwaka"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              'nye ithriliyoni amakhulu asithoba anamashumi asibhozo anesixhenxe izigidi namakhulu amathandathu amawaka anesithathu'));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              'zithoba iikhwintiliyoni namakhulu asibhozo anamashumi asixhenxe anesithandathu iikhwadriliyoni namakhulu amahlanu anamashumi amane anesithathu iithriliyoni namakhulu amabini aneshumi iibhiliyoni ikhulu elinamashumi amabini anesithathu izigidi namakhulu amane anamashumi amahlanu anesithandathu amawaka anamakhulu asixhenxe anamashumi asibhozo anesithoba'));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              'ikhulu elinamashumi amabini anesithathu iisekstiliyoni namakhulu amane anamashumi amahlanu anesithandathu iikhwintiliyoni namakhulu asixhenxe anamashumi asibhozo anesithoba iikhwadriliyoni nekhulu elinamashumi amabini anesithathu iithriliyoni namakhulu amane anamashumi amahlanu anesithandathu iibhiliyoni amakhulu asixhenxe anamashumi asibhozo anesithoba izigidi nekhulu elinamashumi amabini anesithathu amawaka anamakhulu amane anamashumi amahlanu anesithandathu'));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              'amakhulu asithoba anamashumi asithoba anesithoba iisekstiliyoni namakhulu asithoba anamashumi asithoba anesithoba iikhwintiliyoni namakhulu asithoba anamashumi asithoba anesithoba iikhwadriliyoni namakhulu asithoba anamashumi asithoba anesithoba iithriliyoni namakhulu asithoba anamashumi asithoba anesithoba iibhiliyoni amakhulu asithoba anamashumi asithoba anesithoba izigidi namakhulu asithoba anamashumi asithoba anesithoba amawaka anamakhulu asithoba anamashumi asithoba anesithoba'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Ayilonani"));
      expect(converter.convert(double.infinity), equals("Infinity"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negative Infinity"));
      expect(converter.convert(null), equals("Ayilonani"));
      expect(converter.convert('abc'), equals("Ayilonani"));
      expect(converter.convert([]), equals("Ayilonani"));
      expect(converter.convert({}), equals("Ayilonani"));
      expect(converter.convert(Object()), equals("Ayilonani"));

      expect(converterWithFallback.convert(double.nan),
          equals("Inani Elingalunganga"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Infinity"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negative Infinity"));
      expect(
          converterWithFallback.convert(null), equals("Inani Elingalunganga"));
      expect(
          converterWithFallback.convert('abc'), equals("Inani Elingalunganga"));
      expect(converterWithFallback.convert([]), equals("Inani Elingalunganga"));
      expect(converterWithFallback.convert({}), equals("Inani Elingalunganga"));
      expect(converterWithFallback.convert(Object()),
          equals("Inani Elingalunganga"));
      expect(converterWithFallback.convert(123),
          equals("ikhulu elinamashumi amabini anesithathu"));
    });
  });
}
