import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Slovenian (SL)', () {
    final converter = Num2Text(initialLang: Lang.SL);
    final converterWithFallback = Num2Text(
      initialLang: Lang.SL,
      fallbackOnError: "Neveljavna številka",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("nič"));
      expect(converter.convert(1), equals("ena"));
      expect(converter.convert(10), equals("deset"));
      expect(converter.convert(11), equals("enajst"));
      expect(converter.convert(20), equals("dvajset"));
      expect(converter.convert(21), equals("enaindvajset"));
      expect(converter.convert(99), equals("devetindevetdeset"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("sto"));
      expect(converter.convert(101), equals("sto ena"));
      expect(converter.convert(111), equals("sto enajst"));
      expect(converter.convert(200), equals("dvesto"));
      expect(converter.convert(999), equals("devetsto devetindevetdeset"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("tisoč"));
      expect(converter.convert(1001), equals("tisoč ena"));
      expect(converter.convert(1111), equals("tisoč sto enajst"));
      expect(converter.convert(2000), equals("dva tisoč"));
      expect(converter.convert(3000), equals("tri tisoč"));
      expect(converter.convert(5000), equals("pet tisoč"));
      expect(converter.convert(10000), equals("deset tisoč"));
      expect(converter.convert(100000), equals("sto tisoč"));
      expect(converter.convert(123456),
          equals("sto triindvajset tisoč štiristo šestinpetdeset"));
      expect(
        converter.convert(999999),
        equals("devetsto devetindevetdeset tisoč devetsto devetindevetdeset"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus ena"));
      expect(converter.convert(-123), equals("minus sto triindvajset"));
      expect(
        converter.convert(-1, options: SlOptions(negativePrefix: "negativno")),
        equals("negativno ena"),
      );
      expect(
        converter.convert(-123,
            options: SlOptions(negativePrefix: "negativno")),
        equals("negativno sto triindvajset"),
      );
    });

    test('Year Formatting', () {
      const yearOption = SlOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("tisoč devetsto"));
      expect(converter.convert(2024, options: yearOption),
          equals("dva tisoč štiriindvajset"));
      expect(converter.convert(-100, options: yearOption), equals("minus sto"));
      expect(converter.convert(-1, options: yearOption), equals("minus ena"));
    });

    test('Currency', () {
      const currencyOption = SlOptions(currency: true);
      expect(converter.convert(1, options: currencyOption), equals("en evro"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("en evro in en cent"));
      expect(converter.convert(2, options: currencyOption), equals("dva evra"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("dva evra in dva centa"));
      expect(
          converter.convert(3, options: currencyOption), equals("trije evri"));
      expect(
          converter.convert(4, options: currencyOption), equals("štirje evri"));
      expect(
          converter.convert(5, options: currencyOption), equals("pet evrov"));
      expect(
        converter.convert(2.50, options: currencyOption),
        equals("dva evra in petdeset centov"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("sto triindvajset evrov in petinštirideset centov"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("sto triindvajset vejica štiri pet šest"),
      );

      expect(
          converter.convert(Decimal.parse('1.50')), equals("ena vejica pet"));
      expect(converter.convert(123.0), equals("sto triindvajset"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("sto triindvajset"));
      expect(
        converter.convert(1.5,
            options: const SlOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("ena vejica pet"),
      );
      expect(
        converter.convert(1.5,
            options:
                const SlOptions(decimalSeparator: DecimalSeparator.period)),
        equals("ena pika pet"),
      );
      expect(
        converter.convert(1.5,
            options: const SlOptions(decimalSeparator: DecimalSeparator.point)),
        equals("ena pika pet"),
      );
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("en milijon"));
      expect(
          converter.convert(BigInt.from(1000000000)), equals("ena milijarda"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("en bilijon"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("ena bilijarda"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("en trilijon"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("ena trilijarda"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("en kvadrilijon"),
      );

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "sto triindvajset trilijard štiristo šestinpetdeset trilijonov sedemsto devetinosemdeset bilijard sto triindvajset bilijonov štiristo šestinpetdeset milijard sedemsto devetinosemdeset milijonov sto triindvajset tisoč štiristo šestinpetdeset",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "devetsto devetindevetdeset trilijard devetsto devetindevetdeset trilijonov devetsto devetindevetdeset bilijard devetsto devetindevetdeset bilijonov devetsto devetindevetdeset milijard devetsto devetindevetdeset milijonov devetsto devetindevetdeset tisoč devetsto devetindevetdeset",
        ),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Neskončnost"));
      expect(converter.convert(double.negativeInfinity),
          equals("Minus neskončnost"));
      expect(converter.convert(double.nan), equals("Ni število"));
      expect(converter.convert(null), equals("Ni število"));
      expect(converter.convert('abc'), equals("Ni število"));

      expect(converterWithFallback.convert(double.infinity),
          equals("Neskončnost"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Minus neskončnost"));
      expect(converterWithFallback.convert(double.nan),
          equals("Neveljavna številka"));
      expect(
          converterWithFallback.convert(null), equals("Neveljavna številka"));
      expect(
          converterWithFallback.convert('abc'), equals("Neveljavna številka"));
      expect(converterWithFallback.convert(123), equals("sto triindvajset"));
    });
  });
}
