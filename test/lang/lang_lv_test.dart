import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Latvian (LV)', () {
    final converter = Num2Text(initialLang: Lang.LV);
    final converterWithFallback = Num2Text(
      initialLang: Lang.LV,
      fallbackOnError: "Nederīga vērtība",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("nulle"));
      expect(converter.convert(1), equals("viens"));
      expect(converter.convert(2), equals("divi"));
      expect(converter.convert(3), equals("trīs"));
      expect(converter.convert(4), equals("četri"));
      expect(converter.convert(5), equals("pieci"));
      expect(converter.convert(6), equals("seši"));
      expect(converter.convert(7), equals("septiņi"));
      expect(converter.convert(8), equals("astoņi"));
      expect(converter.convert(9), equals("deviņi"));
      expect(converter.convert(10), equals("desmit"));
      expect(converter.convert(11), equals("vienpadsmit"));
      expect(converter.convert(12), equals("divpadsmit"));
      expect(converter.convert(13), equals("trīspadsmit"));
      expect(converter.convert(19), equals("deviņpadsmit"));
      expect(converter.convert(20), equals("divdesmit"));
      expect(converter.convert(21), equals("divdesmit viens"));
      expect(converter.convert(32), equals("trīsdesmit divi"));
      expect(converter.convert(48), equals("četrdesmit astoņi"));
      expect(converter.convert(50), equals("piecdesmit"));
      expect(converter.convert(99), equals("deviņdesmit deviņi"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("viens simts"));
      expect(converter.convert(101), equals("viens simts viens"));
      expect(converter.convert(111), equals("viens simts vienpadsmit"));
      expect(converter.convert(200), equals("divi simti"));
      expect(converter.convert(999), equals("deviņi simti deviņdesmit deviņi"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("viens tūkstotis"));
      expect(converter.convert(1001), equals("viens tūkstotis viens"));
      expect(converter.convert(1111),
          equals("viens tūkstotis viens simts vienpadsmit"));
      expect(converter.convert(2000), equals("divi tūkstoši"));
      expect(converter.convert(10000), equals("desmit tūkstoši"));
      expect(converter.convert(100000), equals("viens simts tūkstoši"));
      expect(
        converter.convert(123456),
        equals(
            "viens simts divdesmit trīs tūkstoši četri simti piecdesmit seši"),
      );
      expect(
        converter.convert(999999),
        equals(
            "deviņi simti deviņdesmit deviņi tūkstoši deviņi simti deviņdesmit deviņi"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("mīnus viens"));
      expect(
          converter.convert(-123), equals("mīnus viens simts divdesmit trīs"));
      expect(
        converter.convert(-1, options: LvOptions(negativePrefix: "negatīvs")),
        equals("negatīvs viens"),
      );
      expect(
        converter.convert(-123, options: LvOptions(negativePrefix: "negatīvs")),
        equals("negatīvs viens simts divdesmit trīs"),
      );
    });

    test('Year Formatting', () {
      const yearOption = LvOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("viens tūkstotis deviņi simti"));
      expect(converter.convert(2024, options: yearOption),
          equals("divi tūkstoši divdesmit četri"));
      expect(
        converter.convert(1900, options: LvOptions(format: Format.year)),
        equals("viens tūkstotis deviņi simti"),
      );
      expect(
        converter.convert(2024, options: LvOptions(format: Format.year)),
        equals("divi tūkstoši divdesmit četri"),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("mīnus viens simts"));
      expect(converter.convert(-1, options: yearOption), equals("mīnus viens"));
      expect(
        converter.convert(-2024, options: LvOptions(format: Format.year)),
        equals("mīnus divi tūkstoši divdesmit četri"),
      );
    });

    test('Currency', () {
      const currencyOption = LvOptions(currency: true);
      expect(converter.convert(1.01, options: currencyOption),
          equals("viens eiro un viens cents"));
      expect(
        converter.convert(2.50, options: currencyOption),
        equals("divi eiro un piecdesmit centi"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("viens simts divdesmit trīs eiro un četrdesmit pieci centi"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("viens simts divdesmit trīs komats četri pieci seši"),
      );
      expect(converter.convert(Decimal.parse('1.50')),
          equals("viens komats pieci"));
      expect(converter.convert(123.0), equals("viens simts divdesmit trīs"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("viens simts divdesmit trīs"));
      expect(
        converter.convert(1.5,
            options: const LvOptions(decimalSeparator: DecimalSeparator.point)),
        equals("viens punkts pieci"),
      );
      expect(
        converter.convert(1.5,
            options: const LvOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("viens komats pieci"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Bezgalība"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negatīva bezgalība"));
      expect(converter.convert(double.nan), equals("Nav skaitlis"));
      expect(converter.convert(null), equals("Nav skaitlis"));
      expect(converter.convert('abc'), equals("Nav skaitlis"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Bezgalība"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Negatīva bezgalība"));
      expect(converterWithFallback.convert(double.nan),
          equals("Nederīga vērtība"));
      expect(converterWithFallback.convert(null), equals("Nederīga vērtība"));
      expect(converterWithFallback.convert('abc'), equals("Nederīga vērtība"));
      expect(converterWithFallback.convert(123),
          equals("viens simts divdesmit trīs"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("viens miljons"));
      expect(
          converter.convert(BigInt.from(1000000000)), equals("viens miljards"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("viens triljons"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("viens kvadriljons"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("viens kvintiljons"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000')),
        equals("viens sekstiljons"),
      );
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("viens septiljons"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "viens simts divdesmit trīs sekstiljoni četri simti piecdesmit seši kvintiljoni septiņi simti astoņdesmit deviņi kvadriljoni viens simts divdesmit trīs triljoni četri simti piecdesmit seši miljardi septiņi simti astoņdesmit deviņi miljoni viens simts divdesmit trīs tūkstoši četri simti piecdesmit seši",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "deviņi simti deviņdesmit deviņi sekstiljoni deviņi simti deviņdesmit deviņi kvintiljoni deviņi simti deviņdesmit deviņi kvadriljoni deviņi simti deviņdesmit deviņi triljoni deviņi simti deviņdesmit deviņi miljardi deviņi simti deviņdesmit deviņi miljoni deviņi simti deviņdesmit deviņi tūkstoši deviņi simti deviņdesmit deviņi",
        ),
      );
    });
  });
}
