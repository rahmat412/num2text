import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Lithuanian (LT)', () {
    final converter = Num2Text(initialLang: Lang.LT);
    final converterWithFallback = Num2Text(
      initialLang: Lang.LT,
      fallbackOnError: "Neteisingas Skaičius",
    );

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("nulis"));
      expect(converter.convert(1), equals("vienas"));
      expect(converter.convert(9), equals("devyni"));
      expect(converter.convert(10), equals("dešimt"));
      expect(converter.convert(11), equals("vienuolika"));
      expect(converter.convert(13), equals("trylika"));
      expect(converter.convert(15), equals("penkiolika"));
      expect(converter.convert(19), equals("devyniolika"));
      expect(converter.convert(20), equals("dvidešimt"));
      expect(converter.convert(21), equals("dvidešimt vienas"));
      expect(converter.convert(27), equals("dvidešimt septyni"));
      expect(converter.convert(30), equals("trisdešimt"));
      expect(converter.convert(54), equals("penkiasdešimt keturi"));
      expect(converter.convert(68), equals("šešiasdešimt aštuoni"));
      expect(converter.convert(99), equals("devyniasdešimt devyni"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("šimtas"));
      expect(converter.convert(101), equals("šimtas vienas"));
      expect(converter.convert(105), equals("šimtas penki"));
      expect(converter.convert(110), equals("šimtas dešimt"));
      expect(converter.convert(111), equals("šimtas vienuolika"));
      expect(converter.convert(123), equals("šimtas dvidešimt trys"));
      expect(converter.convert(200), equals("du šimtai"));
      expect(converter.convert(321), equals("trys šimtai dvidešimt vienas"));
      expect(converter.convert(479),
          equals("keturi šimtai septyniasdešimt devyni"));
      expect(
          converter.convert(596), equals("penki šimtai devyniasdešimt šeši"));
      expect(
          converter.convert(681), equals("šeši šimtai aštuoniasdešimt vienas"));
      expect(converter.convert(999),
          equals("devyni šimtai devyniasdešimt devyni"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("tūkstantis"));
      expect(converter.convert(1001), equals("tūkstantis vienas"));
      expect(converter.convert(1011), equals("tūkstantis vienuolika"));
      expect(converter.convert(1110), equals("tūkstantis šimtas dešimt"));
      expect(converter.convert(1111), equals("tūkstantis šimtas vienuolika"));
      expect(converter.convert(2000), equals("du tūkstančiai"));
      expect(converter.convert(2468),
          equals("du tūkstančiai keturi šimtai šešiasdešimt aštuoni"));
      expect(converter.convert(3579),
          equals("trys tūkstančiai penki šimtai septyniasdešimt devyni"));
      expect(converter.convert(10000), equals("dešimt tūkstančių"));
      expect(converter.convert(10011), equals("dešimt tūkstančių vienuolika"));
      expect(converter.convert(11100), equals("vienuolika tūkstančių šimtas"));
      expect(converter.convert(12987),
          equals("dvylika tūkstančių devyni šimtai aštuoniasdešimt septyni"));
      expect(converter.convert(21000), equals("dvidešimt vienas tūkstantis"));
      expect(
          converter.convert(45623),
          equals(
              "keturiasdešimt penki tūkstančiai šeši šimtai dvidešimt trys"));
      expect(
          converter.convert(87654),
          equals(
              "aštuoniasdešimt septyni tūkstančiai šeši šimtai penkiasdešimt keturi"));
      expect(converter.convert(100000), equals("šimtas tūkstančių"));
      expect(
          converter.convert(123456),
          equals(
              "šimtas dvidešimt trys tūkstančiai keturi šimtai penkiasdešimt šeši"));
      expect(
          converter.convert(987654),
          equals(
              "devyni šimtai aštuoniasdešimt septyni tūkstančiai šeši šimtai penkiasdešimt keturi"));
      expect(
          converter.convert(999999),
          equals(
              "devyni šimtai devyniasdešimt devyni tūkstančiai devyni šimtai devyniasdešimt devyni"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus vienas"));
      expect(converter.convert(-123), equals("minus šimtas dvidešimt trys"));
      expect(converter.convert(Decimal.parse("-123.456")),
          equals("minus šimtas dvidešimt trys kablelis keturi penki šeši"));
      const negativeOption = LtOptions(negativePrefix: "neigiamas");
      expect(converter.convert(-1, options: negativeOption),
          equals("neigiamas vienas"));
      expect(converter.convert(-123, options: negativeOption),
          equals("neigiamas šimtas dvidešimt trys"));
      expect(
          converter.convert(Decimal.parse("-123.456"), options: negativeOption),
          equals("neigiamas šimtas dvidešimt trys kablelis keturi penki šeši"));
    });

    test('Decimals', () {
      expect(converter.convert(Decimal.parse("123.456")),
          equals("šimtas dvidešimt trys kablelis keturi penki šeši"));
      expect(converter.convert("1.5"), equals("vienas kablelis penki"));
      expect(converter.convert(1.05), equals("vienas kablelis nulis penki"));
      expect(
          converter.convert(879.465),
          equals(
              "aštuoni šimtai septyniasdešimt devyni kablelis keturi šeši penki"));
      expect(converter.convert(1.5), equals("vienas kablelis penki"));
      const pointOption = LtOptions(decimalSeparator: DecimalSeparator.point);
      expect(converter.convert(1.5, options: pointOption),
          equals("vienas taškas penki"));
      const commaOption = LtOptions(decimalSeparator: DecimalSeparator.comma);
      expect(converter.convert(1.5, options: commaOption),
          equals("vienas kablelis penki"));
      const periodOption = LtOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(1.5, options: periodOption),
          equals("vienas taškas penki"));
    });

    test('Year Formatting', () {
      const yearOption = LtOptions(format: Format.year);
      expect(converter.convert(123, options: yearOption),
          equals("šimtas dvidešimt treti"));
      expect(converter.convert(498, options: yearOption),
          equals("keturi šimtai devyniasdešimt aštunti"));
      expect(converter.convert(756, options: yearOption),
          equals("septyni šimtai penkiasdešimt šešti"));
      expect(converter.convert(1900, options: yearOption),
          equals("tūkstantis devyni šimtai"));
      expect(converter.convert(1999, options: yearOption),
          equals("tūkstantis devyni šimtai devyniasdešimt devinti"));
      expect(converter.convert(2025, options: yearOption),
          equals("du tūkstančiai dvidešimt penkti"));

      const yearOptionAD = LtOptions(format: Format.year, includeAD: true);
      expect(converter.convert(1900, options: yearOptionAD),
          equals("tūkstantis devyni šimtai m. e."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("tūkstantis devyni šimtai devyniasdešimt devinti m. e."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("du tūkstančiai dvidešimt penkti m. e."));

      expect(converter.convert(-1, options: yearOption),
          equals("pirmieji pr. m. e."));
      expect(converter.convert(-100, options: yearOption),
          equals("šimtas pr. m. e."));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("šimtas pr. m. e."));
      expect(converter.convert(-2025, options: yearOption),
          equals("du tūkstančiai dvidešimt penkti pr. m. e."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("milijonas pr. m. e."));
    });

    test('Currency', () {
      const currencyOption = LtOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("nulis eurų"));
      expect(converter.convert(1, options: currencyOption),
          equals("vienas euras"));
      expect(converter.convert(2, options: currencyOption), equals("du eurai"));
      expect(
          converter.convert(5, options: currencyOption), equals("penki eurai"));
      expect(converter.convert(10, options: currencyOption),
          equals("dešimt eurų"));
      expect(converter.convert(11, options: currencyOption),
          equals("vienuolika eurų"));
      expect(converter.convert(12, options: currencyOption),
          equals("dvylika eurų"));
      expect(converter.convert(20, options: currencyOption),
          equals("dvidešimt eurų"));
      expect(converter.convert(21, options: currencyOption),
          equals("dvidešimt vienas euras"));
      expect(converter.convert(22, options: currencyOption),
          equals("dvidešimt du eurai"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("vienas euras vienas centas"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("du eurai du centai"));
      expect(converter.convert(3.10, options: currencyOption),
          equals("trys eurai dešimt centų"));
      expect(converter.convert(4.11, options: currencyOption),
          equals("keturi eurai vienuolika centų"));
      expect(converter.convert(5.20, options: currencyOption),
          equals("penki eurai dvidešimt centų"));
      expect(converter.convert(6.21, options: currencyOption),
          equals("šeši eurai dvidešimt vienas centas"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("vienas euras penkiasdešimt centų"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("šimtas dvidešimt trys eurai keturiasdešimt penki centai"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("dešimt milijonų eurų"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("vienas centas"));
      expect(converter.convert(0.50, options: currencyOption),
          equals("penkiasdešimt centų"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("milijonas"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(6)),
          equals("du milijonai"));
      expect(converter.convert(BigInt.from(10).pow(9)), equals("milijardas"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("du milijardai"));
      expect(converter.convert(BigInt.from(10).pow(12)), equals("trilijonas"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("trys trilijonai"));
      expect(
          converter.convert(BigInt.from(10).pow(15)), equals("kvadrilijonas"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("keturi kvadrilijonai"));
      expect(
          converter.convert(BigInt.from(10).pow(18)), equals("kvintilijonas"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("penki kvintilijonai"));
      expect(
          converter.convert(BigInt.from(10).pow(21)), equals("sekstilijonas"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("šeši sekstilijonai"));
      expect(
          converter.convert(BigInt.from(10).pow(24)), equals("septilijonas"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("septyni septilijonai"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('trilijonas du milijonai trys'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals('penki milijonai tūkstantis'));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals('milijardas vienas'));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals('milijardas milijonas'));
      expect(converter.convert(BigInt.parse('2001000')),
          equals('du milijonai tūkstantis'));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              'trilijonas devyni šimtai aštuoniasdešimt septyni milijonai šeši šimtai tūkstančių trys'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Ne Skaičius"));
      expect(converter.convert(double.infinity), equals("Begalybė"));
      expect(converter.convert(double.negativeInfinity),
          equals("Neigiama Begalybė"));
      expect(converter.convert(null), equals("Ne Skaičius"));
      expect(converter.convert('abc'), equals("Ne Skaičius"));
      expect(converter.convert([]), equals("Ne Skaičius"));
      expect(converter.convert({}), equals("Ne Skaičius"));
      expect(converter.convert(Object()), equals("Ne Skaičius"));

      expect(converterWithFallback.convert(double.nan),
          equals("Neteisingas Skaičius"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Begalybė"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Neigiama Begalybė"));
      expect(
          converterWithFallback.convert(null), equals("Neteisingas Skaičius"));
      expect(
          converterWithFallback.convert('abc'), equals("Neteisingas Skaičius"));
      expect(converterWithFallback.convert([]), equals("Neteisingas Skaičius"));
      expect(converterWithFallback.convert({}), equals("Neteisingas Skaičius"));
      expect(converterWithFallback.convert(Object()),
          equals("Neteisingas Skaičius"));
      expect(
          converterWithFallback.convert(123), equals("šimtas dvidešimt trys"));
    });
  });
}
