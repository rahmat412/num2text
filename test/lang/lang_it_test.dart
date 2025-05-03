import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Italian (IT)', () {
    final converter = Num2Text(initialLang: Lang.IT);
    final converterWithFallback = Num2Text(
      initialLang: Lang.IT,
      fallbackOnError: "Numero Non Valido",
    );

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("zero"));
      expect(converter.convert(1), equals("uno"));
      expect(converter.convert(8), equals("otto"));
      expect(converter.convert(10), equals("dieci"));
      expect(converter.convert(11), equals("undici"));
      expect(converter.convert(13), equals("tredici"));
      expect(converter.convert(15), equals("quindici"));
      expect(converter.convert(18), equals("diciotto"));
      expect(converter.convert(20), equals("venti"));
      expect(converter.convert(21), equals("ventuno"));
      expect(converter.convert(27), equals("ventisette"));
      expect(converter.convert(28), equals("ventotto"));
      expect(converter.convert(30), equals("trenta"));
      expect(converter.convert(31), equals("trentuno"));
      expect(converter.convert(38), equals("trentotto"));
      expect(converter.convert(54), equals("cinquantaquattro"));
      expect(converter.convert(68), equals("sessantotto"));
      expect(converter.convert(81), equals("ottantuno"));
      expect(converter.convert(88), equals("ottantotto"));
      expect(converter.convert(99), equals("novantanove"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("cento"));
      expect(converter.convert(101), equals("centouno"));
      expect(converter.convert(105), equals("centocinque"));
      expect(converter.convert(108), equals("centotto"));
      expect(converter.convert(110), equals("centodieci"));
      expect(converter.convert(111), equals("centoundici"));
      expect(converter.convert(123), equals("centoventitre"));
      expect(converter.convert(181), equals("centottantuno"));
      expect(converter.convert(188), equals("centottantotto"));
      expect(converter.convert(200), equals("duecento"));
      expect(converter.convert(321), equals("trecentoventuno"));
      expect(converter.convert(479), equals("quattrocentosettantanove"));
      expect(converter.convert(596), equals("cinquecentonovantasei"));
      expect(converter.convert(681), equals("seicentottantuno"));
      expect(converter.convert(800), equals("ottocento"));
      expect(converter.convert(801), equals("ottocentuno"));
      expect(converter.convert(808), equals("ottocentotto"));
      expect(converter.convert(999), equals("novecentonovantanove"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("mille"));
      expect(converter.convert(1001), equals("milleuno"));
      expect(converter.convert(1011), equals("milleundici"));
      expect(converter.convert(1080), equals("milleottanta"));
      expect(converter.convert(1081), equals("milleottantuno"));
      expect(converter.convert(1110), equals("millecentodieci"));
      expect(converter.convert(1111), equals("millecentoundici"));
      expect(converter.convert(1800), equals("milleottocento"));
      expect(converter.convert(1888), equals("milleottocentottantotto"));
      expect(converter.convert(2000), equals("duemila"));
      expect(converter.convert(2468), equals("duemilaquattrocentosessantotto"));
      expect(converter.convert(3579), equals("tremilacinquecentosettantanove"));
      expect(converter.convert(8000), equals("ottomila"));
      expect(converter.convert(8001), equals("ottomilauno"));
      expect(converter.convert(8008), equals("ottomilaotto"));
      expect(converter.convert(10000), equals("diecimila"));
      expect(converter.convert(10011), equals("diecimilaundici"));
      expect(converter.convert(11100), equals("undicimilacento"));
      expect(
          converter.convert(12987), equals("dodicimilanovecentottantasette"));
      expect(converter.convert(45623),
          equals("quarantacinquemilaseicentoventitre"));
      expect(converter.convert(80000), equals("ottantamila"));
      expect(converter.convert(81000), equals("ottantunomila"));
      expect(converter.convert(88000), equals("ottantottomila"));
      expect(converter.convert(87654),
          equals("ottantasettemilaseicentocinquantaquattro"));
      expect(converter.convert(100000), equals("centomila"));
      expect(converter.convert(101000), equals("centounomila"));
      expect(converter.convert(108000), equals("centottomila"));
      expect(converter.convert(123456),
          equals("centoventitremilaquattrocentocinquantasei"));
      expect(converter.convert(987654),
          equals("novecentottantasettemilaseicentocinquantaquattro"));
      expect(converter.convert(999999),
          equals("novecentonovantanovemilanovecentonovantanove"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("meno uno"));
      expect(converter.convert(-123), equals("meno centoventitre"));
      expect(converter.convert(Decimal.parse("-123.456")),
          equals("meno centoventitre virgola quattro cinque sei"));
      const negativeOption = ItOptions(negativePrefix: "negativo");
      expect(converter.convert(-1, options: negativeOption),
          equals("negativo uno"));
      expect(converter.convert(-123, options: negativeOption),
          equals("negativo centoventitre"));
      expect(
          converter.convert(Decimal.parse("-123.456"), options: negativeOption),
          equals("negativo centoventitre virgola quattro cinque sei"));
    });

    test('Decimals', () {
      expect(converter.convert(Decimal.parse("123.456")),
          equals("centoventitre virgola quattro cinque sei"));
      expect(converter.convert(1.5), equals("uno virgola cinque"));
      expect(converter.convert(1.05), equals("uno virgola zero cinque"));
      expect(converter.convert(879.465),
          equals("ottocentosettantanove virgola quattro sei cinque"));
      expect(converter.convert(1.5), equals("uno virgola cinque"));
      expect(converter.convert(0.1), equals("zero virgola uno"));
      expect(converter.convert(0.01), equals("zero virgola zero uno"));
      const pointOption = ItOptions(decimalSeparator: DecimalSeparator.point);
      expect(converter.convert(1.5, options: pointOption),
          equals("uno punto cinque"));
      const commaOption = ItOptions(decimalSeparator: DecimalSeparator.comma);
      expect(converter.convert(1.5, options: commaOption),
          equals("uno virgola cinque"));
      const periodOption = ItOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(1.5, options: periodOption),
          equals("uno punto cinque"));
    });

    test('Year Formatting', () {
      const yearOption = ItOptions(format: Format.year);
      expect(
          converter.convert(123, options: yearOption), equals("centoventitre"));
      expect(converter.convert(498, options: yearOption),
          equals("quattrocentonovantotto"));
      expect(converter.convert(756, options: yearOption),
          equals("settecentocinquantasei"));
      expect(converter.convert(1066, options: yearOption),
          equals("millesessantasei"));
      expect(converter.convert(1800, options: yearOption),
          equals("milleottocento"));
      expect(converter.convert(1900, options: yearOption),
          equals("millenovecento"));
      expect(converter.convert(1999, options: yearOption),
          equals("millenovecentonovantanove"));
      expect(converter.convert(2000, options: yearOption), equals("duemila"));
      expect(converter.convert(2025, options: yearOption),
          equals("duemilaventicinque"));

      const yearOptionAD = ItOptions(format: Format.year, includeAD: true);
      expect(converter.convert(1900, options: yearOptionAD),
          equals("millenovecento d.C."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("millenovecentonovantanove d.C."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("duemilaventicinque d.C."));

      expect(converter.convert(-1, options: yearOption), equals("uno a.C."));
      expect(
          converter.convert(-100, options: yearOption), equals("cento a.C."));
      expect(
          converter.convert(-100, options: yearOptionAD), equals("cento a.C."));
      expect(converter.convert(-44, options: yearOption),
          equals("quarantaquattro a.C."));
      expect(converter.convert(-2025, options: yearOption),
          equals("duemilaventicinque a.C."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("un milione a.C."));
    });

    test('Currency', () {
      const currencyOption = ItOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("zero euro"));
      expect(converter.convert(1, options: currencyOption), equals("un euro"));
      expect(converter.convert(2, options: currencyOption), equals("due euro"));
      expect(
          converter.convert(5, options: currencyOption), equals("cinque euro"));
      expect(
          converter.convert(10, options: currencyOption), equals("dieci euro"));
      expect(converter.convert(11, options: currencyOption),
          equals("undici euro"));
      expect(
          converter.convert(8, options: currencyOption), equals("otto euro"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("un euro e cinquanta centesimi"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("centoventitre euro e quarantacinque centesimi"));
      expect(converter.convert(1000000, options: currencyOption),
          equals("un milione di euro"));
      expect(converter.convert(2000000, options: currencyOption),
          equals("due milioni di euro"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("dieci milioni di euro"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("un centesimo"));
      expect(converter.convert(0.02, options: currencyOption),
          equals("due centesimi"));
      expect(converter.convert(0.10, options: currencyOption),
          equals("dieci centesimi"));
      expect(
          converter.convert(1.00, options: currencyOption), equals("un euro"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("un euro e un centesimo"));
      expect(converter.convert(2.01, options: currencyOption),
          equals("due euro e un centesimo"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("due euro e due centesimi"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("un milione"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(6)),
          equals("due milioni"));
      expect(converter.convert(BigInt.from(10).pow(9)), equals("un miliardo"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("due miliardi"));
      expect(converter.convert(BigInt.from(10).pow(12)), equals("un bilione"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("tre bilioni"));
      expect(converter.convert(BigInt.from(10).pow(15)), equals("un biliardo"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("quattro biliardi"));
      expect(converter.convert(BigInt.from(10).pow(18)), equals("un trilione"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("cinque trilioni"));
      expect(
          converter.convert(BigInt.from(10).pow(21)), equals("un triliardo"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("sei triliardi"));
      expect(
          converter.convert(BigInt.from(10).pow(24)), equals("un quadrilione"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("sette quadrilioni"));

      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            "nove trilioni ottocentosettantasei biliardi cinquecentoquarantatre bilioni duecentodieci miliardi centoventitre milioni quattrocentocinquantaseimilasettecentottantanove"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "centoventitre triliardi quattrocentocinquantasei trilioni settecentottantanove biliardi centoventitre bilioni quattrocentocinquantasei miliardi settecentottantanove milioni centoventitremilaquattrocentocinquantasei"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "novecentonovantanove triliardi novecentonovantanove trilioni novecentonovantanove biliardi novecentonovantanove bilioni novecentonovantanove miliardi novecentonovantanove milioni novecentonovantanovemilanovecentonovantanove"),
      );

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('un bilione due milioni tre'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("cinque milioni mille"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("un miliardo uno"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("un miliardo un milione"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("due milioni mille"));
      expect(converter.convert(BigInt.parse('1000987600003')),
          equals('un bilione novecentottantasette milioni seicentomilatre'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Non Un Numero"));
      expect(converter.convert(double.infinity), equals("Infinito"));
      expect(converter.convert(double.negativeInfinity),
          equals("Infinito Negativo"));
      expect(converter.convert(null), equals("Non Un Numero"));
      expect(converter.convert('abc'), equals("Non Un Numero"));
      expect(converter.convert([]), equals("Non Un Numero"));
      expect(converter.convert({}), equals("Non Un Numero"));
      expect(converter.convert(Object()), equals("Non Un Numero"));

      expect(converterWithFallback.convert(double.nan),
          equals("Numero Non Valido"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Infinito"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Infinito Negativo"));
      expect(converterWithFallback.convert(null), equals("Numero Non Valido"));
      expect(converterWithFallback.convert('abc'), equals("Numero Non Valido"));
      expect(converterWithFallback.convert([]), equals("Numero Non Valido"));
      expect(converterWithFallback.convert({}), equals("Numero Non Valido"));
      expect(
          converterWithFallback.convert(Object()), equals("Numero Non Valido"));
      expect(converterWithFallback.convert(123), equals("centoventitre"));
    });
  });
}
