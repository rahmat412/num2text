import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Bosnian (BS)', () {
    final converter = Num2Text(initialLang: Lang.BS);
    final converterWithFallback =
        Num2Text(initialLang: Lang.BS, fallbackOnError: "Nevažeći broj");

    const bsCurrencyOption = BsOptions(currency: true);

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("nula"));
      expect(converter.convert(1), equals("jedan"));
      expect(converter.convert(2), equals("dva"));
      expect(converter.convert(10), equals("deset"));
      expect(converter.convert(11), equals("jedanaest"));
      expect(converter.convert(20), equals("dvadeset"));
      expect(converter.convert(21), equals("dvadeset jedan"));
      expect(converter.convert(99), equals("devedeset devet"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("sto"));
      expect(converter.convert(101), equals("sto jedan"));
      expect(converter.convert(111), equals("sto jedanaest"));
      expect(converter.convert(200), equals("dvjesto"));
      expect(converter.convert(300), equals("tristo"));
      expect(converter.convert(999), equals("devetsto devedeset devet"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("hiljadu"));
      expect(converter.convert(1001), equals("hiljadu jedan"));
      expect(converter.convert(1111), equals("hiljadu sto jedanaest"));

      expect(converter.convert(2000), equals("dvije hiljade"));
      expect(converter.convert(4000), equals("četiri hiljade"));

      expect(converter.convert(5000), equals("pet hiljada"));
      expect(converter.convert(10000), equals("deset hiljada"));
      expect(converter.convert(100000), equals("sto hiljada"));
      expect(converter.convert(123456),
          equals("sto dvadeset tri hiljade četiristo pedeset šest"));
      expect(
        converter.convert(999999),
        equals("devetsto devedeset devet hiljada devetsto devedeset devet"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus jedan"));
      expect(converter.convert(-123), equals("minus sto dvadeset tri"));
      expect(
        converter.convert(-1,
            options: const BsOptions(negativePrefix: "negativno")),
        equals("negativno jedan"),
      );
      expect(
        converter.convert(-123,
            options: const BsOptions(negativePrefix: "negativno")),
        equals("negativno sto dvadeset tri"),
      );
    });

    test('Year Formatting', () {
      const yearOption = BsOptions(format: Format.year);

      expect(converter.convert(1900, options: yearOption),
          equals("hiljadu devetsto"));
      expect(converter.convert(2024, options: yearOption),
          equals("dvije hiljade dvadeset četiri"));
      expect(
        converter.convert(1900,
            options: const BsOptions(format: Format.year, includeAD: true)),
        equals("hiljadu devetsto n. e."),
      );
      expect(
        converter.convert(2024,
            options: const BsOptions(format: Format.year, includeAD: true)),
        equals("dvije hiljade dvadeset četiri n. e."),
      );

      expect(
          converter.convert(-100, options: yearOption), equals("sto p. n. e."));
      expect(
          converter.convert(-1, options: yearOption), equals("jedan p. n. e."));
      expect(
        converter.convert(-2024,
            options: const BsOptions(format: Format.year, includeAD: true)),
        equals("dvije hiljade dvadeset četiri p. n. e."),
      );
    });

    test('Currency (BAM)', () {
      expect(converter.convert(0, options: bsCurrencyOption),
          equals("nula konvertibilnih maraka"));

      expect(converter.convert(1, options: bsCurrencyOption),
          equals("jedna konvertibilna marka"));
      expect(converter.convert(2, options: bsCurrencyOption),
          equals("dvije konvertibilne marke"));
      expect(converter.convert(3, options: bsCurrencyOption),
          equals("tri konvertibilne marke"));
      expect(converter.convert(5, options: bsCurrencyOption),
          equals("pet konvertibilnih maraka"));

      expect(
        converter.convert(1.01, options: bsCurrencyOption),
        equals("jedna konvertibilna marka i jedan fening"),
      );
      expect(
        converter.convert(1.02, options: bsCurrencyOption),
        equals("jedna konvertibilna marka i dva feninga"),
      );
      expect(
        converter.convert(1.05, options: bsCurrencyOption),
        equals("jedna konvertibilna marka i pet feninga"),
      );
      expect(
        converter.convert(1.50, options: bsCurrencyOption),
        equals("jedna konvertibilna marka i pedeset feninga"),
      );
      expect(
        converter.convert(2.01, options: bsCurrencyOption),
        equals("dvije konvertibilne marke i jedan fening"),
      );
      expect(
        converter.convert(2.02, options: bsCurrencyOption),
        equals("dvije konvertibilne marke i dva feninga"),
      );
      expect(
        converter.convert(2.05, options: bsCurrencyOption),
        equals("dvije konvertibilne marke i pet feninga"),
      );
      expect(
        converter.convert(5.01, options: bsCurrencyOption),
        equals("pet konvertibilnih maraka i jedan fening"),
      );

      expect(
        converter.convert(123.45, options: bsCurrencyOption),
        equals("sto dvadeset tri konvertibilne marke i četrdeset pet feninga"),
      );
      expect(
        converter.convert(121.41, options: bsCurrencyOption),
        equals(
            "sto dvadeset jedna konvertibilna marka i četrdeset jedan fening"),
      );
      expect(
        converter.convert(122.42, options: bsCurrencyOption),
        equals(
            "sto dvadeset dvije konvertibilne marke i četrdeset dva feninga"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("sto dvadeset tri zarez četiri pet šest"),
      );

      expect(
          converter.convert(Decimal.parse('1.50')), equals("jedan zarez pet"));
      expect(converter.convert(123.0), equals("sto dvadeset tri"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("sto dvadeset tri"));

      expect(
        converter.convert(
          Decimal.parse('1.5'),
          options: const BsOptions(decimalSeparator: DecimalSeparator.comma),
        ),
        equals("jedan zarez pet"),
      );
      expect(
        converter.convert(
          Decimal.parse('1.5'),
          options: const BsOptions(decimalSeparator: DecimalSeparator.period),
        ),
        equals("jedan tačka pet"),
      );

      expect(
        converter.convert(
          Decimal.parse('1.5'),
          options: const BsOptions(decimalSeparator: DecimalSeparator.point),
        ),
        equals("jedan tačka pet"),
      );
      expect(converter.convert(Decimal.parse('0.5')), equals("nula zarez pet"));
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Beskonačnost"));
      expect(converter.convert(double.negativeInfinity),
          equals("Negativna beskonačnost"));
      expect(converter.convert(double.nan), equals("Nije broj"));
      expect(converter.convert(null), equals("Nije broj"));
      expect(converter.convert('abc'), equals("Nije broj"));

      expect(converterWithFallback.convert(double.infinity),
          equals("Beskonačnost"));
      expect(
        converterWithFallback.convert(double.negativeInfinity),
        equals("Negativna beskonačnost"),
      );
      expect(
          converterWithFallback.convert(double.nan), equals("Nevažeći broj"));
      expect(converterWithFallback.convert(null), equals("Nevažeći broj"));
      expect(converterWithFallback.convert('abc'), equals("Nevažeći broj"));
      expect(converterWithFallback.convert(123), equals("sto dvadeset tri"));
    });

    test('Scale Numbers (Long Scale)', () {
      expect(converter.convert(BigInt.from(1000000)), equals("milion"));
      expect(converter.convert(BigInt.from(2000000)), equals("dva miliona"));
      expect(converter.convert(BigInt.from(5000000)), equals("pet miliona"));

      expect(converter.convert(BigInt.from(1000000000)), equals("milijarda"));
      expect(converter.convert(BigInt.from(2000000000)),
          equals("dvije milijarde"));
      expect(
          converter.convert(BigInt.from(5000000000)), equals("pet milijardi"));

      expect(converter.convert(BigInt.from(1000000000000)), equals("bilion"));
      expect(
          converter.convert(BigInt.from(2000000000000)), equals("dva biliona"));
      expect(
          converter.convert(BigInt.from(5000000000000)), equals("pet biliona"));

      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("bilijarda"));
      expect(converter.convert(BigInt.from(2000000000000000)),
          equals("dvije bilijarde"));
      expect(converter.convert(BigInt.from(5000000000000000)),
          equals("pet bilijardi"));

      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("trilion"));
      expect(converter.convert(BigInt.from(2000000000000000000)),
          equals("dva triliona"));
      expect(converter.convert(BigInt.from(5000000000000000000)),
          equals("pet triliona"));

      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("trilijarda"));
      expect(converter.convert(BigInt.parse('2000000000000000000000')),
          equals("dvije trilijarde"));
      expect(converter.convert(BigInt.parse('5000000000000000000000')),
          equals("pet trilijardi"));

      expect(converter.convert(BigInt.parse('1000000000000000000000000')),
          equals("kvadrilion"));
      expect(
        converter.convert(BigInt.parse('2000000000000000000000000')),
        equals("dva kvadriliona"),
      );
      expect(
        converter.convert(BigInt.parse('5000000000000000000000000')),
        equals("pet kvadriliona"),
      );

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "sto dvadeset tri trilijarde četiristo pedeset šest triliona sedamsto osamdeset devet bilijardi sto dvadeset tri biliona četiristo pedeset šest milijardi sedamsto osamdeset devet miliona sto dvadeset tri hiljade četiristo pedeset šest",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "devetsto devedeset devet trilijardi devetsto devedeset devet triliona devetsto devedeset devet bilijardi devetsto devedeset devet biliona devetsto devedeset devet milijardi devetsto devedeset devet miliona devetsto devedeset devet hiljada devetsto devedeset devet",
        ),
      );
    });
  });
}
