import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Hungarian (HU)', () {
    final converter = Num2Text(initialLang: Lang.HU);
    final converterWithFallback =
        Num2Text(initialLang: Lang.HU, fallbackOnError: "Érvénytelen szám");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("nulla"));
      expect(converter.convert(10), equals("tíz"));
      expect(converter.convert(11), equals("tizenegy"));
      expect(converter.convert(13), equals("tizenhárom"));
      expect(converter.convert(15), equals("tizenöt"));
      expect(converter.convert(20), equals("húsz"));
      expect(converter.convert(27), equals("huszonhét"));
      expect(converter.convert(30), equals("harminc"));
      expect(converter.convert(54), equals("ötvennégy"));
      expect(converter.convert(68), equals("hatvannyolc"));
      expect(converter.convert(99), equals("kilencvenkilenc"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("száz"));
      expect(converter.convert(101), equals("százegy"));
      expect(converter.convert(105), equals("százöt"));
      expect(converter.convert(110), equals("száztíz"));
      expect(converter.convert(111), equals("száztizenegy"));
      expect(converter.convert(123), equals("százhuszonhárom"));
      expect(converter.convert(200), equals("kétszáz"));
      expect(converter.convert(321), equals("háromszázhuszonegy"));
      expect(converter.convert(479), equals("négyszázhetvenkilenc"));
      expect(converter.convert(596), equals("ötszázkilencvenhat"));
      expect(converter.convert(681), equals("hatszáznyolcvanegy"));
      expect(converter.convert(999), equals("kilencszázkilencvenkilenc"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("ezer"));
      expect(converter.convert(1001), equals("ezeregy"));
      expect(converter.convert(1011), equals("ezertizenegy"));
      expect(converter.convert(1110), equals("ezerszáztíz"));
      expect(converter.convert(1111), equals("ezerszáztizenegy"));
      expect(converter.convert(2000), equals("kétezer"));
      expect(converter.convert(2468), equals("kétezer-négyszázhatvannyolc"));
      expect(converter.convert(3579), equals("háromezer-ötszázhetvenkilenc"));
      expect(converter.convert(10000), equals("tízezer"));
      expect(converter.convert(10011), equals("tízezer-tizenegy"));
      expect(converter.convert(11100), equals("tizenegyezer-száz"));
      expect(converter.convert(12987),
          equals("tizenkétezer-kilencszáznyolcvanhét"));
      expect(
          converter.convert(45623), equals("negyvenötezer-hatszázhuszonhárom"));
      expect(
          converter.convert(87654), equals("nyolcvanhétezer-hatszázötvennégy"));
      expect(converter.convert(100000), equals("százezer"));
      expect(converter.convert(123456),
          equals("százhuszonháromezer-négyszázötvenhat"));
      expect(converter.convert(987654),
          equals("kilencszáznyolcvanhétezer-hatszázötvennégy"));
      expect(converter.convert(999999),
          equals("kilencszázkilencvenkilencezer-kilencszázkilencvenkilenc"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("mínusz egy"));
      expect(converter.convert(-123), equals("mínusz százhuszonhárom"));
      expect(converter.convert(-123.456),
          equals("mínusz százhuszonhárom egész négy öt hat"));

      const negativeOption = HuOptions(negativePrefix: "negatív");

      expect(converter.convert(-1, options: negativeOption),
          equals("negatív egy"));
      expect(converter.convert(-123, options: negativeOption),
          equals("negatív százhuszonhárom"));
      expect(converter.convert(-123.456, options: negativeOption),
          equals("negatív százhuszonhárom egész négy öt hat"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456),
          equals("százhuszonhárom egész négy öt hat"));
      expect(converter.convert(1.5), equals("egy egész öt"));
      expect(converter.convert(1.05), equals("egy egész nulla öt"));
      expect(converter.convert(879.465),
          equals("nyolcszázhetvenkilenc egész négy hat öt"));
      expect(converter.convert(1.5), equals("egy egész öt"));

      const pointOption = HuOptions(decimalSeparator: DecimalSeparator.point);

      expect(
          converter.convert(1.5, options: pointOption), equals("egy pont öt"));

      const commaOption = HuOptions(decimalSeparator: DecimalSeparator.comma);

      expect(
          converter.convert(1.5, options: commaOption), equals("egy egész öt"));

      const periodOption = HuOptions(decimalSeparator: DecimalSeparator.period);

      expect(
          converter.convert(1.5, options: periodOption), equals("egy pont öt"));
    });

    test('Year Formatting', () {
      const yearOption = HuOptions(format: Format.year);

      expect(converter.convert(123, options: yearOption),
          equals("százhuszonhárom"));
      expect(converter.convert(498, options: yearOption),
          equals("négyszázkilencvennyolc"));
      expect(converter.convert(756, options: yearOption),
          equals("hétszázötvenhat"));
      expect(converter.convert(1900, options: yearOption),
          equals("ezerkilencszáz"));
      expect(converter.convert(1999, options: yearOption),
          equals("ezerkilencszázkilencvenkilenc"));
      expect(converter.convert(2025, options: yearOption),
          equals("kétezer-huszonöt"));

      const yearOptionAD = HuOptions(format: Format.year, includeAD: true);

      expect(converter.convert(1900, options: yearOptionAD),
          equals("ezerkilencszáz i. sz."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("ezerkilencszázkilencvenkilenc i. sz."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("kétezer-huszonöt i. sz."));
      expect(converter.convert(-1, options: yearOption), equals("egy i. e."));
      expect(
          converter.convert(-100, options: yearOption), equals("száz i. e."));
      expect(
          converter.convert(-100, options: yearOptionAD), equals("száz i. e."));
      expect(converter.convert(-2025, options: yearOption),
          equals("kétezer-huszonöt i. e."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("egymillió i. e."));
    });

    test('Currency', () {
      const currencyOption = HuOptions(currency: true);

      expect(converter.convert(0, options: currencyOption),
          equals("nulla forint"));
      expect(
          converter.convert(1, options: currencyOption), equals("egy forint"));
      expect(
          converter.convert(5, options: currencyOption), equals("öt forint"));
      expect(
          converter.convert(10, options: currencyOption), equals("tíz forint"));
      expect(converter.convert(11, options: currencyOption),
          equals("tizenegy forint"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("egy forint ötven fillér"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("százhuszonhárom forint negyvenöt fillér"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("tízmillió forint"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("egy fillér"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("ötven fillér"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("egymillió"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("kétmilliárd"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("három billió"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("négy billiárd"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("öt trillió"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("hat trilliárd"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("hét kvadrillió"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              'kilenc trillió nyolcszázhetvenhat billiárd ötszáznegyvenhárom billió kétszáztízmilliárd százhuszonhárom millió négyszázötvenhatezer-hétszáznyolcvankilenc'));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "százhuszonhárom trilliárd négyszázötvenhat trillió hétszáznyolcvankilenc billiárd százhuszonhárom billió négyszázötvenhat milliárd hétszáznyolcvankilenc millió százhuszonháromezer-négyszázötvenhat"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "kilencszázkilencvenkilenc trilliárd kilencszázkilencvenkilenc trillió kilencszázkilencvenkilenc billiárd kilencszázkilencvenkilenc billió kilencszázkilencvenkilenc milliárd kilencszázkilencvenkilenc millió kilencszázkilencvenkilencezer-kilencszázkilencvenkilenc"));

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('egybillió kétmillió-három'));
      expect(
          converter.convert(BigInt.parse('5001000')), equals("öt millió ezer"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("egymilliárd-egy"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("egymilliárd egymillió"));
      expect(
          converter.convert(BigInt.parse('2001000')), equals("kétmillió ezer"));
      expect(converter.convert(BigInt.parse('1000987600003')),
          equals("egybillió kilencszáznyolcvanhét millió hatszázezer-három"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Nem szám"));
      expect(converter.convert(double.infinity), equals("Végtelen"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negatív végtelen"));
      expect(converter.convert(null), equals("Nem szám"));
      expect(converter.convert('abc'), equals("Nem szám"));
      expect(converter.convert([]), equals("Nem szám"));
      expect(converter.convert({}), equals("Nem szám"));
      expect(converter.convert(Object()), equals("Nem szám"));

      expect(converterWithFallback.convert(double.nan),
          equals("Érvénytelen szám"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Végtelen"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negatív végtelen"));
      expect(converterWithFallback.convert(null), equals("Érvénytelen szám"));
      expect(converterWithFallback.convert('abc'), equals("Érvénytelen szám"));
      expect(converterWithFallback.convert([]), equals("Érvénytelen szám"));
      expect(converterWithFallback.convert({}), equals("Érvénytelen szám"));
      expect(
          converterWithFallback.convert(Object()), equals("Érvénytelen szám"));
      expect(converterWithFallback.convert(123), equals("százhuszonhárom"));
    });
  });
}
