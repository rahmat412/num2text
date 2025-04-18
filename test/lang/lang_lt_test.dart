import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Lithuanian (LT)', () {
    final converter = Num2Text(initialLang: Lang.LT);
    final converterWithFallback = Num2Text(
      initialLang: Lang.LT,
      fallbackOnError: "Neteisingas skaičius",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("nulis"));
      expect(converter.convert(1), equals("vienas"));
      expect(converter.convert(2), equals("du"));
      expect(converter.convert(3), equals("trys"));
      expect(converter.convert(4), equals("keturi"));
      expect(converter.convert(5), equals("penki"));
      expect(converter.convert(6), equals("šeši"));
      expect(converter.convert(7), equals("septyni"));
      expect(converter.convert(8), equals("aštuoni"));
      expect(converter.convert(9), equals("devyni"));
      expect(converter.convert(10), equals("dešimt"));
      expect(converter.convert(11), equals("vienuolika"));
      expect(converter.convert(12), equals("dvylika"));
      expect(converter.convert(13), equals("trylika"));
      expect(converter.convert(14), equals("keturiolika"));
      expect(converter.convert(15), equals("penkiolika"));
      expect(converter.convert(16), equals("šešiolika"));
      expect(converter.convert(17), equals("septyniolika"));
      expect(converter.convert(18), equals("aštuoniolika"));
      expect(converter.convert(19), equals("devyniolika"));
      expect(converter.convert(20), equals("dvidešimt"));
      expect(converter.convert(21), equals("dvidešimt vienas"));
      expect(converter.convert(30), equals("trisdešimt"));
      expect(converter.convert(40), equals("keturiasdešimt"));
      expect(converter.convert(50), equals("penkiasdešimt"));
      expect(converter.convert(60), equals("šešiasdešimt"));
      expect(converter.convert(70), equals("septyniasdešimt"));
      expect(converter.convert(80), equals("aštuoniasdešimt"));
      expect(converter.convert(90), equals("devyniasdešimt"));
      expect(converter.convert(99), equals("devyniasdešimt devyni"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("vienas šimtas"));
      expect(converter.convert(101), equals("vienas šimtas vienas"));
      expect(converter.convert(111), equals("vienas šimtas vienuolika"));
      expect(converter.convert(200), equals("du šimtai"));
      expect(converter.convert(999),
          equals("devyni šimtai devyniasdešimt devyni"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("vienas tūkstantis"));
      expect(converter.convert(1001), equals("vienas tūkstantis vienas"));
      expect(converter.convert(1111),
          equals("vienas tūkstantis vienas šimtas vienuolika"));
      expect(converter.convert(2000), equals("du tūkstančiai"));
      expect(converter.convert(10000), equals("dešimt tūkstančių"));
      expect(converter.convert(100000), equals("vienas šimtas tūkstančių"));
      expect(
        converter.convert(123456),
        equals(
            "vienas šimtas dvidešimt trys tūkstančiai keturi šimtai penkiasdešimt šeši"),
      );
      expect(
        converter.convert(999999),
        equals(
          "devyni šimtai devyniasdešimt devyni tūkstančiai devyni šimtai devyniasdešimt devyni",
        ),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus vienas"));
      expect(converter.convert(-123),
          equals("minus vienas šimtas dvidešimt trys"));
      expect(
        converter.convert(-1, options: LtOptions(negativePrefix: "neigiamas")),
        equals("neigiamas vienas"),
      );
      expect(
        converter.convert(-123,
            options: LtOptions(negativePrefix: "neigiamas")),
        equals("neigiamas vienas šimtas dvidešimt trys"),
      );
    });

    test('Year Formatting', () {
      const yearOption = LtOptions(format: Format.year);
      expect(
        converter.convert(1900, options: yearOption),
        equals("vienas tūkstantis devyni šimtai"),
      );
      expect(
        converter.convert(2024, options: yearOption),
        equals("du tūkstančiai dvidešimt keturi"),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("minus vienas šimtas"));
      expect(
          converter.convert(-1, options: yearOption), equals("minus vienas"));
    });

    test('Currency', () {
      const currencyOption = LtOptions(currency: true);
      expect(
        converter.convert(1.01, options: currencyOption),
        equals("vienas euras vienas centas"),
      );
      expect(
        converter.convert(2.50, options: currencyOption),
        equals("du eurai penkiasdešimt centų"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals(
            "vienas šimtas dvidešimt trys eurai keturiasdešimt penki centai"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("vienas šimtas dvidešimt trys kablelis keturi penki šeši"),
      );
      expect(converter.convert(Decimal.parse('1.50')),
          equals("vienas kablelis penki"));
      expect(converter.convert(123.0), equals("vienas šimtas dvidešimt trys"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("vienas šimtas dvidešimt trys"));
      expect(
        converter.convert(1.5,
            options: const LtOptions(decimalSeparator: DecimalSeparator.point)),
        equals("vienas taškas penki"),
      );
      expect(
        converter.convert(1.5,
            options: const LtOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("vienas kablelis penki"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Begalybė"));
      expect(converter.convert(double.negativeInfinity),
          equals("Neigiama begalybė"));
      expect(converter.convert(double.nan), equals("Ne skaičius"));
      expect(converter.convert(null), equals("Ne skaičius"));
      expect(converter.convert('abc'), equals("Ne skaičius"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Begalybė"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Neigiama begalybė"));
      expect(converterWithFallback.convert(double.nan),
          equals("Neteisingas skaičius"));
      expect(
          converterWithFallback.convert(null), equals("Neteisingas skaičius"));
      expect(
          converterWithFallback.convert('abc'), equals("Neteisingas skaičius"));
      expect(converterWithFallback.convert(123),
          equals("vienas šimtas dvidešimt trys"));
    });

    test('Scale Numbers', () {
      expect(
          converter.convert(BigInt.from(1000000)), equals("vienas milijonas"));
      expect(converter.convert(BigInt.from(1000000000)),
          equals("vienas milijardas"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("vienas trilijonas"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("vienas kvadrilijonas"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("vienas kvintilijonas"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000')),
        equals("vienas sekstilijonas"),
      );
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("vienas septilijonas"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "vienas šimtas dvidešimt trys sekstilijonai keturi šimtai penkiasdešimt šeši kvintilijonai septyni šimtai aštuoniasdešimt devyni kvadrilijonai vienas šimtas dvidešimt trys trilijonai keturi šimtai penkiasdešimt šeši milijardai septyni šimtai aštuoniasdešimt devyni milijonai vienas šimtas dvidešimt trys tūkstančiai keturi šimtai penkiasdešimt šeši",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "devyni šimtai devyniasdešimt devyni sekstilijonai devyni šimtai devyniasdešimt devyni kvintilijonai devyni šimtai devyniasdešimt devyni kvadrilijonai devyni šimtai devyniasdešimt devyni trilijonai devyni šimtai devyniasdešimt devyni milijardai devyni šimtai devyniasdešimt devyni milijonai devyni šimtai devyniasdešimt devyni tūkstančiai devyni šimtai devyniasdešimt devyni",
        ),
      );
    });
  });
}
