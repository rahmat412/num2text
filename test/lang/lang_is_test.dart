import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Icelandic (IS)', () {
    final converter = Num2Text(initialLang: Lang.IS);
    final converterWithFallback =
        Num2Text(initialLang: Lang.IS, fallbackOnError: "Ógild tala");

    test('Basic Numbers (0 - 99 Masculine - Default)', () {
      expect(converter.convert(0), equals("núll"));
      expect(converter.convert(1), equals("einn"));
      expect(converter.convert(2), equals("tveir"));
      expect(converter.convert(3), equals("þrír"));
      expect(converter.convert(4), equals("fjórir"));
      expect(converter.convert(10), equals("tíu"));
      expect(converter.convert(11), equals("ellefu"));
      expect(converter.convert(13), equals("þrettán"));
      expect(converter.convert(15), equals("fimmtán"));
      expect(converter.convert(20), equals("tuttugu"));
      expect(converter.convert(21), equals("tuttugu og einn"));
      expect(converter.convert(22), equals("tuttugu og tveir"));
      expect(converter.convert(23), equals("tuttugu og þrír"));
      expect(converter.convert(24), equals("tuttugu og fjórir"));
      expect(converter.convert(27), equals("tuttugu og sjö"));
      expect(converter.convert(30), equals("þrjátíu"));
      expect(converter.convert(54), equals("fimmtíu og fjórir"));
      expect(converter.convert(68), equals("sextíu og átta"));
      expect(converter.convert(99), equals("níutíu og níu"));
    });

    test('Basic Numbers (0 - 99 Feminine)', () {
      const femOptions = IsOptions(gender: Gender.feminine);
      expect(converter.convert(0, options: femOptions), equals("núll"));
      expect(converter.convert(1, options: femOptions), equals("ein"));
      expect(converter.convert(2, options: femOptions), equals("tvær"));
      expect(converter.convert(3, options: femOptions), equals("þrjár"));
      expect(converter.convert(4, options: femOptions), equals("fjórar"));
      expect(converter.convert(10, options: femOptions), equals("tíu"));
      expect(converter.convert(11, options: femOptions), equals("ellefu"));
      expect(converter.convert(13, options: femOptions), equals("þrettán"));
      expect(converter.convert(15, options: femOptions), equals("fimmtán"));
      expect(converter.convert(20, options: femOptions), equals("tuttugu"));
      expect(
          converter.convert(21, options: femOptions), equals("tuttugu og ein"));
      expect(converter.convert(22, options: femOptions),
          equals("tuttugu og tvær"));
      expect(converter.convert(23, options: femOptions),
          equals("tuttugu og þrjár"));
      expect(converter.convert(24, options: femOptions),
          equals("tuttugu og fjórar"));
      expect(
          converter.convert(27, options: femOptions), equals("tuttugu og sjö"));
      expect(converter.convert(30, options: femOptions), equals("þrjátíu"));
      expect(converter.convert(54, options: femOptions),
          equals("fimmtíu og fjórar"));
      expect(
          converter.convert(68, options: femOptions), equals("sextíu og átta"));
      expect(
          converter.convert(99, options: femOptions), equals("níutíu og níu"));
    });

    test('Basic Numbers (0 - 99 Neuter)', () {
      const neutOptions = IsOptions(gender: Gender.neuter);
      expect(converter.convert(0, options: neutOptions), equals("núll"));
      expect(converter.convert(1, options: neutOptions), equals("eitt"));
      expect(converter.convert(2, options: neutOptions), equals("tvö"));
      expect(converter.convert(3, options: neutOptions), equals("þrjú"));
      expect(converter.convert(4, options: neutOptions), equals("fjögur"));
      expect(converter.convert(10, options: neutOptions), equals("tíu"));
      expect(converter.convert(11, options: neutOptions), equals("ellefu"));
      expect(converter.convert(13, options: neutOptions), equals("þrettán"));
      expect(converter.convert(15, options: neutOptions), equals("fimmtán"));
      expect(converter.convert(20, options: neutOptions), equals("tuttugu"));
      expect(converter.convert(21, options: neutOptions),
          equals("tuttugu og eitt"));
      expect(converter.convert(22, options: neutOptions),
          equals("tuttugu og tvö"));
      expect(converter.convert(23, options: neutOptions),
          equals("tuttugu og þrjú"));
      expect(converter.convert(24, options: neutOptions),
          equals("tuttugu og fjögur"));
      expect(converter.convert(27, options: neutOptions),
          equals("tuttugu og sjö"));
      expect(converter.convert(30, options: neutOptions), equals("þrjátíu"));
      expect(converter.convert(54, options: neutOptions),
          equals("fimmtíu og fjögur"));
      expect(converter.convert(68, options: neutOptions),
          equals("sextíu og átta"));
      expect(
          converter.convert(99, options: neutOptions), equals("níutíu og níu"));
    });

    test('Hundreds (100 - 999 Masculine - Default)', () {
      expect(converter.convert(100), equals("eitt hundrað"));
      expect(converter.convert(101), equals("eitt hundrað og einn"));
      expect(converter.convert(102), equals("eitt hundrað og tveir"));
      expect(converter.convert(103), equals("eitt hundrað og þrír"));
      expect(converter.convert(104), equals("eitt hundrað og fjórir"));
      expect(converter.convert(105), equals("eitt hundrað og fimm"));
      expect(converter.convert(110), equals("eitt hundrað og tíu"));
      expect(converter.convert(111), equals("eitt hundrað og ellefu"));
      expect(converter.convert(123), equals("eitt hundrað og tuttugu og þrír"));
      expect(converter.convert(200), equals("tvö hundruð"));
      expect(converter.convert(321), equals("þrjú hundruð og tuttugu og einn"));
      expect(converter.convert(479), equals("fjögur hundruð og sjötíu og níu"));
      expect(converter.convert(596), equals("fimm hundruð og níutíu og sex"));
      expect(converter.convert(681), equals("sex hundruð og áttatíu og einn"));
      expect(converter.convert(999), equals("níu hundruð og níutíu og níu"));
    });

    test('Hundreds (100 - 999 Feminine)', () {
      const femOptions = IsOptions(gender: Gender.feminine);
      expect(
          converter.convert(100, options: femOptions), equals("eitt hundrað"));
      expect(converter.convert(101, options: femOptions),
          equals("eitt hundrað og ein"));
      expect(converter.convert(102, options: femOptions),
          equals("eitt hundrað og tvær"));
      expect(converter.convert(103, options: femOptions),
          equals("eitt hundrað og þrjár"));
      expect(converter.convert(104, options: femOptions),
          equals("eitt hundrað og fjórar"));
      expect(converter.convert(105, options: femOptions),
          equals("eitt hundrað og fimm"));
      expect(converter.convert(110, options: femOptions),
          equals("eitt hundrað og tíu"));
      expect(converter.convert(111, options: femOptions),
          equals("eitt hundrað og ellefu"));
      expect(converter.convert(123, options: femOptions),
          equals("eitt hundrað og tuttugu og þrjár"));
      expect(
          converter.convert(200, options: femOptions), equals("tvö hundruð"));
      expect(converter.convert(321, options: femOptions),
          equals("þrjú hundruð og tuttugu og ein"));
      expect(converter.convert(479, options: femOptions),
          equals("fjögur hundruð og sjötíu og níu"));
      expect(converter.convert(596, options: femOptions),
          equals("fimm hundruð og níutíu og sex"));
      expect(converter.convert(681, options: femOptions),
          equals("sex hundruð og áttatíu og ein"));
      expect(converter.convert(999, options: femOptions),
          equals("níu hundruð og níutíu og níu"));
    });

    test('Hundreds (100 - 999 Neuter)', () {
      const neutOptions = IsOptions(gender: Gender.neuter);
      expect(
          converter.convert(100, options: neutOptions), equals("eitt hundrað"));
      expect(converter.convert(101, options: neutOptions),
          equals("eitt hundrað og eitt"));
      expect(converter.convert(102, options: neutOptions),
          equals("eitt hundrað og tvö"));
      expect(converter.convert(103, options: neutOptions),
          equals("eitt hundrað og þrjú"));
      expect(converter.convert(104, options: neutOptions),
          equals("eitt hundrað og fjögur"));
      expect(converter.convert(105, options: neutOptions),
          equals("eitt hundrað og fimm"));
      expect(converter.convert(110, options: neutOptions),
          equals("eitt hundrað og tíu"));
      expect(converter.convert(111, options: neutOptions),
          equals("eitt hundrað og ellefu"));
      expect(converter.convert(123, options: neutOptions),
          equals("eitt hundrað og tuttugu og þrjú"));
      expect(
          converter.convert(200, options: neutOptions), equals("tvö hundruð"));
      expect(converter.convert(321, options: neutOptions),
          equals("þrjú hundruð og tuttugu og eitt"));
      expect(converter.convert(479, options: neutOptions),
          equals("fjögur hundruð og sjötíu og níu"));
      expect(converter.convert(596, options: neutOptions),
          equals("fimm hundruð og níutíu og sex"));
      expect(converter.convert(681, options: neutOptions),
          equals("sex hundruð og áttatíu og eitt"));
      expect(converter.convert(999, options: neutOptions),
          equals("níu hundruð og níutíu og níu"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("eitt þúsund"));
      expect(converter.convert(1001), equals("eitt þúsund og einn"));
      expect(converter.convert(1011), equals("eitt þúsund og ellefu"));
      expect(
          converter.convert(1110), equals("eitt þúsund eitt hundrað og tíu"));
      expect(converter.convert(1111),
          equals("eitt þúsund eitt hundrað og ellefu"));
      expect(converter.convert(2000), equals("tvö þúsund"));
      expect(converter.convert(2468),
          equals("tvö þúsund fjögur hundruð og sextíu og átta"));
      expect(converter.convert(3579),
          equals("þrjú þúsund fimm hundruð og sjötíu og níu"));
      expect(converter.convert(10000), equals("tíu þúsund"));
      expect(converter.convert(10011), equals("tíu þúsund og ellefu"));
      expect(converter.convert(11100), equals("ellefu þúsund eitt hundrað"));
      expect(converter.convert(12987),
          equals("tólf þúsund níu hundruð og áttatíu og sjö"));
      expect(converter.convert(45623),
          equals("fjörutíu og fimm þúsund sex hundruð og tuttugu og þrír"));
      expect(converter.convert(87654),
          equals("áttatíu og sjö þúsund sex hundruð og fimmtíu og fjórir"));
      expect(converter.convert(100000), equals("eitt hundrað þúsund"));
      expect(
          converter.convert(123456),
          equals(
              "eitt hundrað og tuttugu og þrjú þúsund fjögur hundruð og fimmtíu og sex"));
      expect(
          converter.convert(987654),
          equals(
              "níu hundruð og áttatíu og sjö þúsund sex hundruð og fimmtíu og fjórir"));
      expect(
          converter.convert(999999),
          equals(
              "níu hundruð og níutíu og níu þúsund níu hundruð og níutíu og níu"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("mínus einn"));
      expect(converter.convert(-123),
          equals("mínus eitt hundrað og tuttugu og þrír"));
      expect(
          converter.convert(Decimal.parse("-123.456")),
          equals(
              "mínus eitt hundrað og tuttugu og þrjú komma fjögur fimm sex"));
      const negativeOptionFem =
          IsOptions(negativePrefix: "neikvætt", gender: Gender.feminine);
      expect(converter.convert(-1, options: negativeOptionFem),
          equals("neikvætt ein"));
      expect(converter.convert(-123, options: negativeOptionFem),
          equals("neikvætt eitt hundrað og tuttugu og þrjár"));
      const negativeOptionNeuter =
          IsOptions(negativePrefix: "neikvætt", gender: Gender.neuter);
      expect(converter.convert(-1, options: negativeOptionNeuter),
          equals("neikvætt eitt"));
      expect(converter.convert(-123, options: negativeOptionNeuter),
          equals("neikvætt eitt hundrað og tuttugu og þrjú"));
      const negativeOptionDefault = IsOptions(negativePrefix: "neikvætt");
      expect(
          converter.convert(Decimal.parse("-123.456"),
              options: negativeOptionDefault),
          equals(
              "neikvætt eitt hundrað og tuttugu og þrjú komma fjögur fimm sex"));
    });

    test('Decimals', () {
      expect(converter.convert(Decimal.parse("123.456")),
          equals("eitt hundrað og tuttugu og þrjú komma fjögur fimm sex"));
      expect(converter.convert(1.5), equals("eitt komma fimm"));
      expect(converter.convert(1.05), equals("eitt komma núll fimm"));
      expect(converter.convert(879.465),
          equals("átta hundruð og sjötíu og níu komma fjögur sex fimm"));
      expect(converter.convert(1.5), equals("eitt komma fimm"));
      const pointOption = IsOptions(decimalSeparator: DecimalSeparator.point);
      expect(converter.convert(1.5, options: pointOption),
          equals("eitt punktur fimm"));
      const commaOption = IsOptions(decimalSeparator: DecimalSeparator.comma);
      expect(converter.convert(1.5, options: commaOption),
          equals("eitt komma fimm"));
      const periodOption = IsOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(1.5, options: periodOption),
          equals("eitt punktur fimm"));
    });

    test('Year Formatting', () {
      const yearOption = IsOptions(format: Format.year);
      expect(converter.convert(123, options: yearOption),
          equals("eitt hundrað og tuttugu og þrjú"));
      expect(converter.convert(498, options: yearOption),
          equals("fjögur hundruð og níutíu og átta"));
      expect(converter.convert(756, options: yearOption),
          equals("sjö hundruð og fimmtíu og sex"));
      expect(converter.convert(1900, options: yearOption),
          equals("nítján hundruð"));
      expect(converter.convert(1999, options: yearOption),
          equals("nítján hundruð og níutíu og níu"));
      expect(converter.convert(2025, options: yearOption),
          equals("tvö þúsund tuttugu og fimm"));
      const yearOptionAD = IsOptions(format: Format.year, includeAD: true);
      expect(converter.convert(1900, options: yearOptionAD),
          equals("nítján hundruð e.Kr.")); // Uses abbreviation
      expect(converter.convert(1999, options: yearOptionAD),
          equals("nítján hundruð og níutíu og níu e.Kr.")); // Uses abbreviation
      expect(converter.convert(2025, options: yearOptionAD),
          equals("tvö þúsund tuttugu og fimm e.Kr.")); // Uses abbreviation
      expect(converter.convert(-1, options: yearOption),
          equals("eitt fyrir Krist"));
      expect(converter.convert(-100, options: yearOption),
          equals("eitt hundrað fyrir Krist"));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("eitt hundrað fyrir Krist"));
      expect(converter.convert(-2025, options: yearOption),
          equals("tvö þúsund tuttugu og fimm fyrir Krist"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("ein milljón fyrir Krist"));
    });

    test('Currency', () {
      const currencyOption = IsOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("núll krónur"));
      expect(
          converter.convert(1, options: currencyOption), equals("ein króna"));
      expect(
          converter.convert(2, options: currencyOption), equals("tvær krónur"));
      expect(converter.convert(3, options: currencyOption),
          equals("þrjár krónur"));
      expect(converter.convert(4, options: currencyOption),
          equals("fjórar krónur"));
      expect(
          converter.convert(5, options: currencyOption), equals("fimm krónur"));
      expect(
          converter.convert(10, options: currencyOption), equals("tíu krónur"));
      expect(converter.convert(11, options: currencyOption),
          equals("ellefu krónur"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("ein króna")); // No subunit for ISK
      expect(
          converter.convert(123.45, options: currencyOption),
          equals(
              "eitt hundrað og tuttugu og þrjár krónur")); // No subunit for ISK
      expect(converter.convert(10000000, options: currencyOption),
          equals("tíu milljónir krónur"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("núll krónur")); // No subunit for ISK
      expect(converter.convert(0.50, options: currencyOption),
          equals("núll krónur")); // No subunit for ISK
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("ein milljón"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("tveir milljarðar"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("þrjár billjónir"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("fjórir billjarðar")); // Correct scale name
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("fimm trilljónir"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("sex trilljarðar")); // Correct scale name
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("sjö kvadrilljónir"));
      expect(
        // Uses correct scale names
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            "níu trilljónir átta hundruð og sjötíu og sex billjarðar fimm hundruð og fjörutíu og þrjár billjónir tvö hundruð og tíu milljarðar eitt hundrað og tuttugu og þrjár milljónir fjögur hundruð og fimmtíu og sex þúsund sjö hundruð og áttatíu og níu"),
      );
      expect(
        // Duplicate test removed
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(// Uses correct scale names
            "eitt hundrað og tuttugu og þrír trilljarðar fjögur hundruð og fimmtíu og sex trilljónir sjö hundruð og áttatíu og níu billjarðar eitt hundrað og tuttugu og þrjár billjónir fjögur hundruð og fimmtíu og sex milljarðar sjö hundruð og áttatíu og níu milljónir eitt hundrað og tuttugu og þrjú þúsund fjögur hundruð og fimmtíu og sex"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(// Uses correct scale names
            "níu hundruð og níutíu og níu trilljarðar níu hundruð og níutíu og níu trilljónir níu hundruð og níutíu og níu billjarðar níu hundruð og níutíu og níu billjónir níu hundruð og níutíu og níu milljarðar níu hundruð og níutíu og níu milljónir níu hundruð og níutíu og níu þúsund níu hundruð og níutíu og níu"),
      );

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('ein billjón tvær milljónir og þrír'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("fimm milljónir eitt þúsund"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("einn milljarður og einn"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("einn milljarður ein milljón"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("tvær milljónir eitt þúsund"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              'ein billjón níu hundruð og áttatíu og sjö milljónir sex hundruð þúsund og þrír'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Ekki Tala"));
      expect(converter.convert(double.infinity), equals("Óendanlegt"));
      expect(converter.convert(double.negativeInfinity),
          equals("Neikvætt Óendanlegt"));
      expect(converter.convert(null), equals("Ekki Tala"));
      expect(converter.convert('abc'), equals("Ekki Tala"));
      expect(converter.convert([]), equals("Ekki Tala"));
      expect(converter.convert({}), equals("Ekki Tala"));
      expect(converter.convert(Object()), equals("Ekki Tala"));

      expect(converterWithFallback.convert(double.nan), equals("Ógild tala"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Óendanlegt"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Neikvætt Óendanlegt"));
      expect(converterWithFallback.convert(null), equals("Ógild tala"));
      expect(converterWithFallback.convert('abc'), equals("Ógild tala"));
      expect(converterWithFallback.convert([]), equals("Ógild tala"));
      expect(converterWithFallback.convert({}), equals("Ógild tala"));
      expect(converterWithFallback.convert(Object()), equals("Ógild tala"));
      expect(converterWithFallback.convert(123),
          equals("eitt hundrað og tuttugu og þrír"));
    });
  });
}
