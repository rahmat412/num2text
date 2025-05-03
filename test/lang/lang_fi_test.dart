import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Finnish (FI)', () {
    final converter = Num2Text(initialLang: Lang.FI);
    final converterWithFallback =
        Num2Text(initialLang: Lang.FI, fallbackOnError: "Virheellinen Numero");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("nolla"));
      expect(converter.convert(10), equals("kymmenen"));
      expect(converter.convert(11), equals("yksitoista"));
      expect(converter.convert(13), equals("kolmetoista"));
      expect(converter.convert(15), equals("viisitoista"));
      expect(converter.convert(20), equals("kaksikymmentä"));
      expect(converter.convert(27), equals("kaksikymmentäseitsemän"));
      expect(converter.convert(30), equals("kolmekymmentä"));
      expect(converter.convert(54), equals("viisikymmentäneljä"));
      expect(converter.convert(68), equals("kuusikymmentäkahdeksan"));
      expect(converter.convert(99), equals("yhdeksänkymmentäyhdeksän"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("sata"));
      expect(converter.convert(101), equals("satayksi"));
      expect(converter.convert(105), equals("sataviisi"));
      expect(converter.convert(110), equals("satakymmenen"));
      expect(converter.convert(111), equals("satayksitoista"));
      expect(converter.convert(123), equals("satakaksikymmentäkolme"));
      expect(converter.convert(200), equals("kaksisataa"));
      expect(converter.convert(321), equals("kolmesataakaksikymmentäyksi"));
      expect(converter.convert(479),
          equals("neljäsataaseitsemänkymmentäyhdeksän"));
      expect(converter.convert(596), equals("viisisataayhdeksänkymmentäkuusi"));
      expect(converter.convert(681), equals("kuusisataakahdeksankymmentäyksi"));
      expect(converter.convert(999),
          equals("yhdeksänsataayhdeksänkymmentäyhdeksän"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("tuhat"));
      expect(converter.convert(1001), equals("tuhat yksi"));
      expect(converter.convert(1011), equals("tuhat yksitoista"));
      expect(converter.convert(1110), equals("tuhat satakymmenen"));
      expect(converter.convert(1111), equals("tuhat satayksitoista"));
      expect(converter.convert(2000), equals("kaksituhatta"));
      expect(converter.convert(2468),
          equals("kaksituhatta neljäsataakuusikymmentäkahdeksan"));
      expect(converter.convert(3579),
          equals("kolmetuhatta viisisataaseitsemänkymmentäyhdeksän"));
      expect(converter.convert(10000), equals("kymmenentuhatta"));
      expect(converter.convert(10011), equals("kymmenentuhatta yksitoista"));
      expect(converter.convert(11100), equals("yksitoistatuhatta sata"));
      expect(converter.convert(12987),
          equals("kaksitoistatuhatta yhdeksänsataakahdeksankymmentäseitsemän"));
      expect(converter.convert(45623),
          equals("neljäkymmentäviisituhatta kuusisataakaksikymmentäkolme"));
      expect(
          converter.convert(87654),
          equals(
              "kahdeksankymmentäseitsemäntuhatta kuusisataaviisikymmentäneljä"));
      expect(converter.convert(100000), equals("satatuhatta"));
      expect(converter.convert(123456),
          equals("satakaksikymmentäkolmetuhatta neljäsataaviisikymmentäkuusi"));
      expect(
          converter.convert(987654),
          equals(
              "yhdeksänsataakahdeksankymmentäseitsemäntuhatta kuusisataaviisikymmentäneljä"));
      expect(
          converter.convert(999999),
          equals(
              "yhdeksänsataayhdeksänkymmentäyhdeksäntuhatta yhdeksänsataayhdeksänkymmentäyhdeksän"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("miinus yksi"));
      expect(converter.convert(-123), equals("miinus satakaksikymmentäkolme"));
      expect(converter.convert(-123.456),
          equals("miinus satakaksikymmentäkolme pilkku neljä viisi kuusi"));
      expect(
          converter.convert(-1,
              options: const FiOptions(negativePrefix: "negatiivinen")),
          equals("negatiivinen yksi"));
      expect(
          converter.convert(-123,
              options: const FiOptions(negativePrefix: "negatiivinen")),
          equals("negatiivinen satakaksikymmentäkolme"));
      expect(
          converter.convert(-123.456,
              options: const FiOptions(negativePrefix: "negatiivinen")),
          equals(
              "negatiivinen satakaksikymmentäkolme pilkku neljä viisi kuusi"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456),
          equals("satakaksikymmentäkolme pilkku neljä viisi kuusi"));
      expect(converter.convert(1.5), equals("yksi pilkku viisi"));
      expect(converter.convert(1.05), equals("yksi pilkku nolla viisi"));
      expect(
          converter.convert(879.465),
          equals(
              "kahdeksansataaseitsemänkymmentäyhdeksän pilkku neljä kuusi viisi"));
      expect(converter.convert(1.5), equals("yksi pilkku viisi"));
      expect(
          converter.convert(1.5,
              options:
                  const FiOptions(decimalSeparator: DecimalSeparator.point)),
          equals("yksi piste viisi"));
      expect(
          converter.convert(1.5,
              options:
                  const FiOptions(decimalSeparator: DecimalSeparator.comma)),
          equals("yksi pilkku viisi"));
      expect(
          converter.convert(1.5,
              options:
                  const FiOptions(decimalSeparator: DecimalSeparator.period)),
          equals("yksi piste viisi"));
    });

    test('Year Formatting', () {
      expect(
          converter.convert(123, options: const FiOptions(format: Format.year)),
          equals("satakaksikymmentäkolme"));
      expect(
          converter.convert(498, options: const FiOptions(format: Format.year)),
          equals("neljäsataayhdeksänkymmentäkahdeksan"));
      expect(
          converter.convert(756, options: const FiOptions(format: Format.year)),
          equals("seitsemänsataaviisikymmentäkuusi"));
      expect(
          converter.convert(1900,
              options: const FiOptions(format: Format.year)),
          equals("tuhatyhdeksänsataa"));
      expect(
          converter.convert(1999,
              options: const FiOptions(format: Format.year)),
          equals("tuhatyhdeksänsataayhdeksänkymmentäyhdeksän"));
      expect(
          converter.convert(2025,
              options: const FiOptions(format: Format.year)),
          equals("kaksituhattakaksikymmentäviisi"));
      expect(
          converter.convert(1900,
              options: const FiOptions(format: Format.year, includeAD: true)),
          equals("tuhatyhdeksänsataa jKr."));
      expect(
          converter.convert(1999,
              options: const FiOptions(format: Format.year, includeAD: true)),
          equals("tuhatyhdeksänsataayhdeksänkymmentäyhdeksän jKr."));
      expect(
          converter.convert(2025,
              options: const FiOptions(format: Format.year, includeAD: true)),
          equals("kaksituhattakaksikymmentäviisi jKr."));
      expect(
          converter.convert(-1, options: const FiOptions(format: Format.year)),
          equals("yksi eKr."));
      expect(
          converter.convert(-100,
              options: const FiOptions(format: Format.year)),
          equals("sata eKr."));
      expect(
          converter.convert(-100,
              options: const FiOptions(format: Format.year, includeAD: true)),
          equals("sata eKr."));
      expect(
          converter.convert(-2025,
              options: const FiOptions(format: Format.year)),
          equals("kaksituhattakaksikymmentäviisi eKr."));
      expect(
          converter.convert(-1000000,
              options: const FiOptions(format: Format.year)),
          equals("yksi miljoona eKr."));
    });

    test('Currency', () {
      expect(converter.convert(0, options: const FiOptions(currency: true)),
          equals("nolla euroa"));
      expect(converter.convert(1, options: const FiOptions(currency: true)),
          equals("yksi euro"));
      expect(converter.convert(2, options: const FiOptions(currency: true)),
          equals("kaksi euroa"));
      expect(converter.convert(5, options: const FiOptions(currency: true)),
          equals("viisi euroa"));
      expect(converter.convert(10, options: const FiOptions(currency: true)),
          equals("kymmenen euroa"));
      expect(converter.convert(11, options: const FiOptions(currency: true)),
          equals("yksitoista euroa"));
      expect(converter.convert(1.5, options: const FiOptions(currency: true)),
          equals("yksi euro ja viisikymmentä senttiä"));
      expect(
          converter.convert(123.45, options: const FiOptions(currency: true)),
          equals("satakaksikymmentäkolme euroa ja neljäkymmentäviisi senttiä"));
      expect(
          converter.convert(10000000, options: const FiOptions(currency: true)),
          equals("kymmenen miljoonaa euroa"));
      expect(converter.convert(0.01, options: const FiOptions(currency: true)),
          equals("yksi sentti"));
      expect(converter.convert(0.5, options: const FiOptions(currency: true)),
          equals("viisikymmentä senttiä"));
      expect(converter.convert(1.01, options: const FiOptions(currency: true)),
          equals("yksi euro ja yksi sentti"));
      expect(converter.convert(2.02, options: const FiOptions(currency: true)),
          equals("kaksi euroa ja kaksi senttiä"));
    });

    test('Scale Numbers', () {
      expect(
          converter.convert(BigInt.from(10).pow(6)), equals("yksi miljoona"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("kaksi miljardia"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("kolme biljoonaa"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("neljä biljardia"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("viisi triljoonaa"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("kuusi triljardia"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("seitsemän kvadriljoonaa"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "yhdeksän triljoonaa kahdeksansataaseitsemänkymmentäkuusi biljardia viisisataaneljäkymmentäkolme biljoonaa kaksisataakymmenen miljardia satakaksikymmentäkolme miljoonaa neljäsataaviisikymmentäkuusituhatta seitsemänsataakahdeksankymmentäyhdeksän"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "satakaksikymmentäkolme triljardia neljäsataaviisikymmentäkuusi triljoonaa seitsemänsataakahdeksankymmentäyhdeksän biljardia satakaksikymmentäkolme biljoonaa neljäsataaviisikymmentäkuusi miljardia seitsemänsataakahdeksankymmentäyhdeksän miljoonaa satakaksikymmentäkolmetuhatta neljäsataaviisikymmentäkuusi"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "yhdeksänsataayhdeksänkymmentäyhdeksän triljardia yhdeksänsataayhdeksänkymmentäyhdeksän triljoonaa yhdeksänsataayhdeksänkymmentäyhdeksän biljardia yhdeksänsataayhdeksänkymmentäyhdeksän biljoonaa yhdeksänsataayhdeksänkymmentäyhdeksän miljardia yhdeksänsataayhdeksänkymmentäyhdeksän miljoonaa yhdeksänsataayhdeksänkymmentäyhdeksäntuhatta yhdeksänsataayhdeksänkymmentäyhdeksän"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('yksi biljoona kaksi miljoonaa kolme'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("viisi miljoonaa tuhat"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals('yksi miljardi yksi'));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals('yksi miljardi yksi miljoona'));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("kaksi miljoonaa tuhat"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              'yksi biljoona yhdeksänsataakahdeksankymmentäseitsemän miljoonaa kuusisataatuhatta kolme'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Ei Numero"));
      expect(converter.convert(double.infinity), equals("Ääretön"));
      expect(
          converter.convert(double.negativeInfinity), equals("Miinus Ääretön"));
      expect(converter.convert(null), equals("Ei Numero"));
      expect(converter.convert('abc'), equals("Ei Numero"));
      expect(converter.convert([]), equals("Ei Numero"));
      expect(converter.convert({}), equals("Ei Numero"));
      expect(converter.convert(Object()), equals("Ei Numero"));

      expect(converterWithFallback.convert(double.nan),
          equals("Virheellinen Numero"));
      expect(converterWithFallback.convert(double.infinity), equals("Ääretön"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Miinus Ääretön"));
      expect(
          converterWithFallback.convert(null), equals("Virheellinen Numero"));
      expect(
          converterWithFallback.convert('abc'), equals("Virheellinen Numero"));
      expect(converterWithFallback.convert([]), equals("Virheellinen Numero"));
      expect(converterWithFallback.convert({}), equals("Virheellinen Numero"));
      expect(converterWithFallback.convert(Object()),
          equals("Virheellinen Numero"));
      expect(
          converterWithFallback.convert(123), equals("satakaksikymmentäkolme"));
    });
  });
}
