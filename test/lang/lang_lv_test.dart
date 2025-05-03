import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Latvian (LV)', () {
    final converter = Num2Text(initialLang: Lang.LV);
    final converterWithFallback = Num2Text(
      initialLang: Lang.LV,
      fallbackOnError: "Nederīga Vērtība",
    );

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("nulle"));
      expect(converter.convert(10), equals("desmit"));
      expect(converter.convert(11), equals("vienpadsmit"));
      expect(converter.convert(13), equals("trīspadsmit"));
      expect(converter.convert(15), equals("piecpadsmit"));
      expect(converter.convert(20), equals("divdesmit"));
      expect(converter.convert(27), equals("divdesmit septiņi"));
      expect(converter.convert(30), equals("trīsdesmit"));
      expect(converter.convert(54), equals("piecdesmit četri"));
      expect(converter.convert(68), equals("sešdesmit astoņi"));
      expect(converter.convert(99), equals("deviņdesmit deviņi"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("viens simts"));
      expect(converter.convert(101), equals("viens simts viens"));
      expect(converter.convert(105), equals("viens simts pieci"));
      expect(converter.convert(110), equals("viens simts desmit"));
      expect(converter.convert(111), equals("viens simts vienpadsmit"));
      expect(converter.convert(123), equals("viens simts divdesmit trīs"));
      expect(converter.convert(200), equals("divi simti"));
      expect(converter.convert(321), equals("trīs simti divdesmit viens"));
      expect(converter.convert(479), equals("četri simti septiņdesmit deviņi"));
      expect(converter.convert(596), equals("pieci simti deviņdesmit seši"));
      expect(converter.convert(681), equals("seši simti astoņdesmit viens"));
      expect(converter.convert(999), equals("deviņi simti deviņdesmit deviņi"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("viens tūkstotis"));
      expect(converter.convert(1001), equals("viens tūkstotis viens"));
      expect(converter.convert(1011), equals("viens tūkstotis vienpadsmit"));
      expect(converter.convert(1110),
          equals("viens tūkstotis viens simts desmit"));
      expect(converter.convert(1111),
          equals("viens tūkstotis viens simts vienpadsmit"));
      expect(converter.convert(2000), equals("divi tūkstoši"));
      expect(converter.convert(2468),
          equals("divi tūkstoši četri simti sešdesmit astoņi"));
      expect(converter.convert(3579),
          equals("trīs tūkstoši pieci simti septiņdesmit deviņi"));
      expect(converter.convert(10000), equals("desmit tūkstoši"));
      expect(converter.convert(10011), equals("desmit tūkstoši vienpadsmit"));
      expect(
          converter.convert(11100), equals("vienpadsmit tūkstoši viens simts"));
      expect(converter.convert(12987),
          equals("divpadsmit tūkstoši deviņi simti astoņdesmit septiņi"));
      expect(converter.convert(45623),
          equals("četrdesmit pieci tūkstoši seši simti divdesmit trīs"));
      expect(converter.convert(87654),
          equals("astoņdesmit septiņi tūkstoši seši simti piecdesmit četri"));
      expect(converter.convert(100000), equals("viens simts tūkstoši"));
      expect(
          converter.convert(123456),
          equals(
              "viens simts divdesmit trīs tūkstoši četri simti piecdesmit seši"));
      expect(
          converter.convert(987654),
          equals(
              "deviņi simti astoņdesmit septiņi tūkstoši seši simti piecdesmit četri"));
      expect(
          converter.convert(999999),
          equals(
              "deviņi simti deviņdesmit deviņi tūkstoši deviņi simti deviņdesmit deviņi"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("mīnus viens"));
      expect(
          converter.convert(-123), equals("mīnus viens simts divdesmit trīs"));
      expect(converter.convert(-123.456),
          equals("mīnus viens simts divdesmit trīs komats četri pieci seši"));

      const negativeOption = LvOptions(negativePrefix: "negatīvs");

      expect(converter.convert(-1, options: negativeOption),
          equals("negatīvs viens"));
      expect(converter.convert(-123, options: negativeOption),
          equals("negatīvs viens simts divdesmit trīs"));
      expect(
          converter.convert(-123.456, options: negativeOption),
          equals(
              "negatīvs viens simts divdesmit trīs komats četri pieci seši"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456),
          equals("viens simts divdesmit trīs komats četri pieci seši"));
      expect(converter.convert("1.5"), equals("viens komats pieci"));
      expect(converter.convert(1.05), equals("viens komats nulle pieci"));
      expect(converter.convert(879.465),
          equals("astoņi simti septiņdesmit deviņi komats četri seši pieci"));
      expect(converter.convert(1.5), equals("viens komats pieci"));

      const pointOption = LvOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = LvOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = LvOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(1.5, options: pointOption),
          equals("viens punkts pieci"));
      expect(converter.convert(1.5, options: commaOption),
          equals("viens komats pieci"));
      expect(converter.convert(1.5, options: periodOption),
          equals("viens punkts pieci"));
    });

    test('Year Formatting', () {
      const yearOption = LvOptions(format: Format.year);

      expect(converter.convert(123, options: yearOption),
          equals("viens simts divdesmit trīs"));
      expect(converter.convert(498, options: yearOption),
          equals("četri simti deviņdesmit astoņi"));
      expect(converter.convert(756, options: yearOption),
          equals("septiņi simti piecdesmit seši"));
      expect(converter.convert(1900, options: yearOption),
          equals("viens tūkstotis deviņi simti"));
      expect(converter.convert(1999, options: yearOption),
          equals("viens tūkstotis deviņi simti deviņdesmit deviņi"));
      expect(converter.convert(2025, options: yearOption),
          equals("divi tūkstoši divdesmit pieci"));

      const yearOptionAD = LvOptions(format: Format.year, includeAD: true);

      expect(converter.convert(1900, options: yearOptionAD),
          equals("viens tūkstotis deviņi simti m.ē."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("viens tūkstotis deviņi simti deviņdesmit deviņi m.ē."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("divi tūkstoši divdesmit pieci m.ē."));
      expect(
          converter.convert(-1, options: yearOption), equals("viens p.m.ē."));
      expect(converter.convert(-100, options: yearOption),
          equals("viens simts p.m.ē."));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("viens simts p.m.ē."));
      expect(converter.convert(-2025, options: yearOption),
          equals("divi tūkstoši divdesmit pieci p.m.ē."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("viens miljons p.m.ē."));
    });

    test('Currency', () {
      const currencyOption = LvOptions(currency: true);

      expect(
          converter.convert(0, options: currencyOption), equals("nulle eiro"));
      expect(
          converter.convert(1, options: currencyOption), equals("viens eiro"));
      expect(
          converter.convert(2, options: currencyOption), equals("divi eiro"));
      expect(
          converter.convert(5, options: currencyOption), equals("pieci eiro"));
      expect(converter.convert(10, options: currencyOption),
          equals("desmit eiro"));
      expect(converter.convert(11, options: currencyOption),
          equals("vienpadsmit eiro"));
      expect(converter.convert(21, options: currencyOption),
          equals("divdesmit viens eiro"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("viens eiro un viens cents"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("divi eiro un divi centi"));
      expect(converter.convert(3.1, options: currencyOption),
          equals("trīs eiro un desmit centi"));
      expect(converter.convert(4.11, options: currencyOption),
          equals("četri eiro un vienpadsmit centi"));
      expect(converter.convert(5.21, options: currencyOption),
          equals("pieci eiro un divdesmit viens cents"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("viens eiro un piecdesmit centi"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("viens simts divdesmit trīs eiro un četrdesmit pieci centi"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("desmit miljoni eiro"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("viens cents"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("piecdesmit centi"));
    });

    test('Scale Numbers', () {
      expect(
          converter.convert(BigInt.from(10).pow(6)), equals("viens miljons"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("divi miljardi"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("trīs triljoni"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("četri kvadriljoni"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("pieci kvintiljoni"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("seši sekstiljoni"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("septiņi septiljoni"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            "deviņi kvintiljoni astoņi simti septiņdesmit seši kvadriljoni pieci simti četrdesmit trīs triljoni divi simti desmit miljardi viens simts divdesmit trīs miljoni četri simti piecdesmit seši tūkstoši septiņi simti astoņdesmit deviņi"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "viens simts divdesmit trīs sekstiljoni četri simti piecdesmit seši kvintiljoni septiņi simti astoņdesmit deviņi kvadriljoni viens simts divdesmit trīs triljoni četri simti piecdesmit seši miljardi septiņi simti astoņdesmit deviņi miljoni viens simts divdesmit trīs tūkstoši četri simti piecdesmit seši"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "deviņi simti deviņdesmit deviņi sekstiljoni deviņi simti deviņdesmit deviņi kvintiljoni deviņi simti deviņdesmit deviņi kvadriljoni deviņi simti deviņdesmit deviņi triljoni deviņi simti deviņdesmit deviņi miljardi deviņi simti deviņdesmit deviņi miljoni deviņi simti deviņdesmit deviņi tūkstoši deviņi simti deviņdesmit deviņi"),
      );
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("viens triljons divi miljoni trīs"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("pieci miljoni viens tūkstotis"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("viens miljards viens"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("viens miljards viens miljons"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("divi miljoni viens tūkstotis"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "viens triljons deviņi simti astoņdesmit septiņi miljoni seši simti tūkstoši trīs"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Nav Skaitlis"));
      expect(converter.convert(double.infinity), equals("Bezgalība"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negatīva Bezgalība"));
      expect(converter.convert(null), equals("Nav Skaitlis"));
      expect(converter.convert('abc'), equals("Nav Skaitlis"));
      expect(converter.convert([]), equals("Nav Skaitlis"));
      expect(converter.convert({}), equals("Nav Skaitlis"));
      expect(converter.convert(Object()), equals("Nav Skaitlis"));

      expect(converterWithFallback.convert(double.nan),
          equals("Nederīga Vērtība"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Bezgalība"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negatīva Bezgalība"));
      expect(converterWithFallback.convert(null), equals("Nederīga Vērtība"));
      expect(converterWithFallback.convert('abc'), equals("Nederīga Vērtība"));
      expect(converterWithFallback.convert([]), equals("Nederīga Vērtība"));
      expect(converterWithFallback.convert({}), equals("Nederīga Vērtība"));
      expect(
          converterWithFallback.convert(Object()), equals("Nederīga Vērtība"));
      expect(converterWithFallback.convert(123),
          equals("viens simts divdesmit trīs"));
    });
  });
}
