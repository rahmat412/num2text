import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Xhosa (XH)', () {
    final converter = Num2Text(initialLang: Lang.XH);
    final converterWithFallback = Num2Text(
      initialLang: Lang.XH,
      fallbackOnError: "Inani elingalunganga",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("zero"));
      expect(converter.convert(1), equals("nye"));
      expect(converter.convert(10), equals("lishumi"));
      expect(converter.convert(11), equals("lishumi elinanye"));
      expect(converter.convert(20), equals("amashumi amabini"));
      expect(converter.convert(21), equals("amashumi amabini ananye"));
      expect(converter.convert(99), equals("amashumi asithoba anesithoba"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("ikhulu"));
      expect(converter.convert(101), equals("ikhulu elinanye"));
      expect(converter.convert(111), equals("ikhulu elineshumi elinanye"));
      expect(converter.convert(200), equals("amakhulu amabini"));

      expect(converter.convert(999),
          equals("amakhulu asithoba anamashumi asithoba anesithoba"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("iwaka elinye"));
      expect(converter.convert(1001), equals("iwaka elinanye"));
      expect(converter.convert(1111),
          equals("iwaka elikhulu elineshumi elinanye"));
      expect(converter.convert(2000), equals("amawaka amabini"));

      expect(converter.convert(10000), equals("amawaka alishumi"));
      expect(converter.convert(100000), equals("ikhulu lamawaka"));
      expect(
        converter.convert(123456),
        equals(
          "ikhulu elinamashumi amabini anesithathu amawaka amakhulu amane anamashumi amahlanu anesithandathu",
        ),
      );

      expect(
        converter.convert(999999),
        equals(
          "amakhulu asithoba anamashumi asithoba anesithoba amawaka amakhulu asithoba anamashumi asithoba anesithoba",
        ),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus nye"));
      expect(converter.convert(-123),
          equals("minus ikhulu elinamashumi amabini anesithathu"));
      expect(
        converter.convert(-1,
            options: const XhOptions(negativePrefix: "negative")),
        equals("negative nye"),
      );
      expect(
        converter.convert(-123,
            options: const XhOptions(negativePrefix: "negative")),
        equals("negative ikhulu elinamashumi amabini anesithathu"),
      );
    });

    test('Year Formatting', () {
      const yearOption = XhOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("iwaka elinethoba amakhulu"));

      expect(
        converter.convert(2024, options: yearOption),
        equals("amawaka amabini anamashumi amabini anesine"),
      );
      expect(
        converter.convert(1900,
            options: const XhOptions(format: Format.year, includeAD: true)),
        equals("iwaka elinethoba amakhulu AD"),
      );

      expect(
        converter.convert(2024,
            options: const XhOptions(format: Format.year, includeAD: true)),
        equals("amawaka amabini anamashumi amabini anesine AD"),
      );
      expect(converter.convert(-100, options: yearOption), equals("ikhulu BC"));
      expect(converter.convert(-1, options: yearOption), equals("nye BC"));

      expect(
        converter.convert(-2024,
            options: const XhOptions(format: Format.year, includeAD: true)),
        equals("amawaka amabini anamashumi amabini anesine BC"),
      );
    });

    test('Currency', () {
      const currencyOption = XhOptions(currency: true);

      expect(converter.convert(0, options: currencyOption),
          equals("zero iiRandi"));

      expect(
          converter.convert(1, options: currencyOption), equals("inye iRandi"));

      expect(converter.convert(2.00, options: currencyOption),
          equals("zimbini iiRandi"));

      expect(
        converter.convert(1.50, options: currencyOption),
        equals("inye iRandi ne amashumi amahlanu iisenti"),
      );

      expect(
        converter.convert(123.45, options: currencyOption),
        equals(
          "ikhulu elinamashumi amabini anesithathu iiRandi ne amashumi amane anesihlanu iisenti",
        ),
      );

      expect(converter.convert(0.01, options: currencyOption),
          equals("inye isenti"));

      expect(converter.convert(0.10, options: currencyOption),
          equals("lishumi iisenti"));
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals(
            "ikhulu elinamashumi amabini anesithathu ichaphaza four five six"),
      );

      expect(converter.convert(Decimal.parse('1.5')),
          equals("nye ichaphaza five"));
      expect(converter.convert(Decimal.parse('1.50')),
          equals("nye ichaphaza five"));
      expect(converter.convert(123.0),
          equals("ikhulu elinamashumi amabini anesithathu"));
      expect(
        converter.convert(Decimal.parse('123.0')),
        equals("ikhulu elinamashumi amabini anesithathu"),
      );
      expect(
        converter.convert(1.5,
            options: const XhOptions(decimalSeparator: DecimalSeparator.point)),
        equals("nye ichaphaza five"),
      );
      expect(
        converter.convert(1.5,
            options:
                const XhOptions(decimalSeparator: DecimalSeparator.period)),
        equals("nye ichaphaza five"),
      );
      expect(
        converter.convert(1.5,
            options: const XhOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("nye ikoma five"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Infinity"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negative Infinity"));
      expect(converter.convert(double.nan), equals("Ayilonani"));
      expect(converter.convert(null), equals("Ayilonani"));
      expect(converter.convert('abc'), equals("Ayilonani"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Infinity"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negative Infinity"));
      expect(converterWithFallback.convert(double.nan),
          equals("Inani elingalunganga"));
      expect(
          converterWithFallback.convert(null), equals("Inani elingalunganga"));
      expect(
          converterWithFallback.convert('abc'), equals("Inani elingalunganga"));
      expect(converterWithFallback.convert(123),
          equals("ikhulu elinamashumi amabini anesithathu"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("nye million"));
      expect(converter.convert(BigInt.from(1000000000)), equals("nye billion"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("nye trillion"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("nye quadrillion"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("nye quintillion"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("nye sextillion"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("nye septillion"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "ikhulu elinamashumi amabini anesithathu sextillion amakhulu amane anamashumi amahlanu anesithandathu quintillion amakhulu asixhenxe anamashumi asibhozo anesithoba quadrillion ikhulu elinamashumi amabini anesithathu trillion amakhulu amane anamashumi amahlanu anesithandathu billion amakhulu asixhenxe anamashumi asibhozo anesithoba million ikhulu elinamashumi amabini anesithathu amawaka amakhulu amane anamashumi amahlanu anesithandathu",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          'amakhulu asithoba anamashumi asithoba anesithoba sextillion amakhulu asithoba anamashumi asithoba anesithoba quintillion amakhulu asithoba anamashumi asithoba anesithoba quadrillion amakhulu asithoba anamashumi asithoba anesithoba trillion amakhulu asithoba anamashumi asithoba anesithoba billion amakhulu asithoba anamashumi asithoba anesithoba million amakhulu asithoba anamashumi asithoba anesithoba amawaka amakhulu asithoba anamashumi asithoba anesithoba',
        ),
      );
    });
  });
}
