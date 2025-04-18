import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Croatian (HR)', () {
    final converter = Num2Text(initialLang: Lang.HR);
    final converterWithFallback =
        Num2Text(initialLang: Lang.HR, fallbackOnError: "Nevažeći broj");

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
      expect(converter.convert(999), equals("devetsto devedeset devet"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("tisuću"));
      expect(converter.convert(1001), equals("tisuću jedan"));
      expect(converter.convert(1111), equals("tisuću sto jedanaest"));
      expect(converter.convert(2000), equals("dvije tisuće"));
      expect(converter.convert(10000), equals("deset tisuća"));
      expect(converter.convert(100000), equals("sto tisuća"));
      expect(converter.convert(123456),
          equals("sto dvadeset tri tisuće četiristo pedeset šest"));
      expect(
        converter.convert(999999),
        equals("devetsto devedeset devet tisuća devetsto devedeset devet"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus jedan"));
      expect(converter.convert(-123), equals("minus sto dvadeset tri"));
      expect(
        converter.convert(-1, options: HrOptions(negativePrefix: "negativan")),
        equals("negativan jedan"),
      );
      expect(
        converter.convert(-123,
            options: HrOptions(negativePrefix: "negativan")),
        equals("negativan sto dvadeset tri"),
      );
    });

    test('Year Formatting', () {
      const yearOption = HrOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("tisuću devetsto"));
      expect(converter.convert(2024, options: yearOption),
          equals("dvije tisuće dvadeset četiri"));
      expect(
        converter.convert(1900,
            options: HrOptions(format: Format.year, includeAD: true)),
        equals("tisuću devetsto nove ere"),
      );
      expect(
        converter.convert(2024,
            options: HrOptions(format: Format.year, includeAD: true)),
        equals("dvije tisuće dvadeset četiri nove ere"),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("sto prije Krista"));
      expect(converter.convert(-1, options: yearOption),
          equals("jedan prije Krista"));

      expect(
        converter.convert(-2024,
            options: HrOptions(format: Format.year, includeAD: true)),
        equals("dvije tisuće dvadeset četiri prije Krista"),
      );
    });

    test('Currency', () {
      const currencyOption = HrOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("nula eura"));
      expect(
          converter.convert(1, options: currencyOption), equals("jedan euro"));
      expect(
        converter.convert(1.50, options: currencyOption),
        equals("jedan euro i pedeset centa"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("sto dvadeset tri eura i četrdeset pet centa"),
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
        converter.convert(1.5,
            options: const HrOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("jedan zarez pet"),
      );

      expect(
        converter.convert(1.5,
            options:
                const HrOptions(decimalSeparator: DecimalSeparator.period)),
        equals("jedan točka pet"),
      );
      expect(
        converter.convert(1.5,
            options: const HrOptions(decimalSeparator: DecimalSeparator.point)),
        equals("jedan točka pet"),
      );
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

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("jedan milijun"));
      expect(converter.convert(BigInt.from(1000000000)),
          equals("jedna milijarda"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("jedan bilijun"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("jedna bilijarda"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("jedan trilijun"));

      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("jedna trilijarda"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("jedan kvadrilijun"),
      );

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "sto dvadeset tri trilijarde "
          "četiristo pedeset šest trilijuna "
          "sedamsto osamdeset devet bilijardi "
          "sto dvadeset tri bilijuna "
          "četiristo pedeset šest milijardi "
          "sedamsto osamdeset devet milijuna "
          "sto dvadeset tri tisuće "
          "četiristo pedeset šest",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "devetsto devedeset devet trilijardi "
          "devetsto devedeset devet trilijuna "
          "devetsto devedeset devet bilijardi "
          "devetsto devedeset devet bilijuna "
          "devetsto devedeset devet milijardi "
          "devetsto devedeset devet milijuna "
          "devetsto devedeset devet tisuća "
          "devetsto devedeset devet",
        ),
      );
    });
  });
}
