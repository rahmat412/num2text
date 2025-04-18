import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Finnish (FI)', () {
    final converter = Num2Text(initialLang: Lang.FI);
    final converterWithFallback = Num2Text(
      initialLang: Lang.FI,
      fallbackOnError: "Virheellinen arvo",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("nolla"));
      expect(converter.convert(1), equals("yksi"));
      expect(converter.convert(10), equals("kymmenen"));
      expect(converter.convert(11), equals("yksitoista"));
      expect(converter.convert(20), equals("kaksikymmentä"));
      expect(converter.convert(21), equals("kaksikymmentäyksi"));
      expect(converter.convert(99), equals("yhdeksänkymmentäyhdeksän"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("sata"));
      expect(converter.convert(101), equals("satayksi"));
      expect(converter.convert(111), equals("satayksitoista"));
      expect(converter.convert(200), equals("kaksisataa"));
      expect(converter.convert(999),
          equals("yhdeksänsataayhdeksänkymmentäyhdeksän"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("tuhat"));
      expect(converter.convert(1001), equals("tuhat yksi"));
      expect(converter.convert(1111), equals("tuhat satayksitoista"));
      expect(converter.convert(2000), equals("kaksituhatta"));
      expect(converter.convert(10000), equals("kymmenentuhatta"));
      expect(converter.convert(100000), equals("satatuhatta"));
      expect(
        converter.convert(123456),
        equals("satakaksikymmentäkolmetuhatta neljäsataaviisikymmentäkuusi"),
      );
      expect(
        converter.convert(999999),
        equals(
          "yhdeksänsataayhdeksänkymmentäyhdeksäntuhatta yhdeksänsataayhdeksänkymmentäyhdeksän",
        ),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("miinus yksi"));
      expect(converter.convert(-123), equals("miinus satakaksikymmentäkolme"));
      expect(
        converter.convert(-1,
            options: FiOptions(negativePrefix: "negatiivinen")),
        equals("negatiivinen yksi"),
      );
      expect(
        converter.convert(-123,
            options: FiOptions(negativePrefix: "negatiivinen")),
        equals("negatiivinen satakaksikymmentäkolme"),
      );
    });

    test('Year Formatting', () {
      const yearOption = FiOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("tuhatyhdeksänsataa"));
      expect(
        converter.convert(2024, options: yearOption),
        equals("kaksituhattakaksikymmentäneljä"),
      );
      expect(
        converter.convert(1900,
            options: FiOptions(format: Format.year, includeAD: true)),
        equals("tuhatyhdeksänsataa jKr."),
      );
      expect(
        converter.convert(2024,
            options: FiOptions(format: Format.year, includeAD: true)),
        equals("kaksituhattakaksikymmentäneljä jKr."),
      );
      expect(converter.convert(-100, options: yearOption), equals("sata eKr."));
      expect(converter.convert(-1, options: yearOption), equals("yksi eKr."));
      expect(
        converter.convert(-2024,
            options: FiOptions(format: Format.year, includeAD: true)),
        equals("kaksituhattakaksikymmentäneljä eKr."),
      );
    });

    test('Currency', () {
      const currencyOption = FiOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("nolla euroa"));
      expect(
          converter.convert(1, options: currencyOption), equals("yksi euro"));
      expect(
        converter.convert(1.50, options: currencyOption),
        equals("yksi euro ja viisikymmentä senttiä"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("satakaksikymmentäkolme euroa ja neljäkymmentäviisi senttiä"),
      );
      expect(
          converter.convert(2, options: currencyOption), equals("kaksi euroa"));
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("satakaksikymmentäkolme pilkku neljä viisi kuusi"),
      );

      expect(converter.convert(Decimal.parse('1.50')),
          equals("yksi pilkku viisi"));
      expect(converter.convert(123.0), equals("satakaksikymmentäkolme"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("satakaksikymmentäkolme"));

      expect(
        converter.convert(1.5,
            options:
                const FiOptions(decimalSeparator: DecimalSeparator.period)),
        equals("yksi piste viisi"),
      );

      expect(converter.convert(1.5), equals("yksi pilkku viisi"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("yksi miljoona"));
      expect(
          converter.convert(BigInt.from(2000000)), equals("kaksi miljoonaa"));
      expect(
          converter.convert(BigInt.from(1000000000)), equals("yksi miljardi"));
      expect(converter.convert(BigInt.from(3000000000)),
          equals("kolme miljardia"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("yksi biljoona"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("yksi biljardi"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("yksi triljoona"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("yksi triljardi"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("yksi kvadriljoona"),
      );

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "satakaksikymmentäkolme triljardia neljäsataaviisikymmentäkuusi triljoonaa seitsemänsataakahdeksankymmentäyhdeksän biljardia satakaksikymmentäkolme biljoonaa neljäsataaviisikymmentäkuusi miljardia seitsemänsataakahdeksankymmentäyhdeksän miljoonaa satakaksikymmentäkolmetuhatta neljäsataaviisikymmentäkuusi",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "yhdeksänsataayhdeksänkymmentäyhdeksän triljardia yhdeksänsataayhdeksänkymmentäyhdeksän triljoonaa yhdeksänsataayhdeksänkymmentäyhdeksän biljardia yhdeksänsataayhdeksänkymmentäyhdeksän biljoonaa yhdeksänsataayhdeksänkymmentäyhdeksän miljardia yhdeksänsataayhdeksänkymmentäyhdeksän miljoonaa yhdeksänsataayhdeksänkymmentäyhdeksäntuhatta yhdeksänsataayhdeksänkymmentäyhdeksän",
        ),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Ääretön"));
      expect(
          converter.convert(double.negativeInfinity), equals("Miinus ääretön"));
      expect(converter.convert(double.nan), equals("Ei numero"));
      expect(converter.convert(null), equals("Ei numero"));
      expect(converter.convert('abc'), equals("Ei numero"));

      expect(converterWithFallback.convert(double.infinity), equals("Ääretön"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Miinus ääretön"));
      expect(converterWithFallback.convert(double.nan),
          equals("Virheellinen arvo"));
      expect(converterWithFallback.convert(null), equals("Virheellinen arvo"));
      expect(converterWithFallback.convert('abc'), equals("Virheellinen arvo"));
      expect(
          converterWithFallback.convert(123), equals("satakaksikymmentäkolme"));
    });
  });
}
