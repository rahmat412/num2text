import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text French (FR)', () {
    final converter = Num2Text(initialLang: Lang.FR);
    final converterWithFallback = Num2Text(
      initialLang: Lang.FR,
      fallbackOnError: "Nombre invalide",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("zéro"));
      expect(converter.convert(1), equals("un"));
      expect(converter.convert(10), equals("dix"));
      expect(converter.convert(11), equals("onze"));
      expect(converter.convert(16), equals("seize"));
      expect(converter.convert(17), equals("dix-sept"));
      expect(converter.convert(20), equals("vingt"));
      expect(converter.convert(21), equals("vingt et un"));
      expect(converter.convert(70), equals("soixante-dix"));
      expect(converter.convert(71), equals("soixante et onze"));
      expect(converter.convert(80), equals("quatre-vingts"));
      expect(converter.convert(81), equals("quatre-vingt-un"));
      expect(converter.convert(90), equals("quatre-vingt-dix"));
      expect(converter.convert(91), equals("quatre-vingt-onze"));
      expect(converter.convert(99), equals("quatre-vingt-dix-neuf"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("cent"));
      expect(converter.convert(101), equals("cent un"));
      expect(converter.convert(111), equals("cent onze"));
      expect(converter.convert(121), equals("cent vingt et un"));
      expect(converter.convert(171), equals("cent soixante et onze"));
      expect(converter.convert(180), equals("cent quatre-vingts"));
      expect(converter.convert(181), equals("cent quatre-vingt-un"));
      expect(converter.convert(200), equals("deux cents"));
      expect(converter.convert(201), equals("deux cent un"));
      expect(converter.convert(999), equals("neuf cent quatre-vingt-dix-neuf"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("mille"));
      expect(converter.convert(1001), equals("mille un"));
      expect(converter.convert(1111), equals("mille cent onze"));
      expect(converter.convert(1200), equals("mille deux cents"));
      expect(converter.convert(2000), equals("deux mille"));
      expect(converter.convert(10000), equals("dix mille"));
      expect(converter.convert(100000), equals("cent mille"));
      expect(converter.convert(123456),
          equals("cent vingt-trois mille quatre cent cinquante-six"));
      expect(
        converter.convert(999999),
        equals(
            "neuf cent quatre-vingt-dix-neuf mille neuf cent quatre-vingt-dix-neuf"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("moins un"));
      expect(converter.convert(-123), equals("moins cent vingt-trois"));
      expect(
        converter.convert(-1, options: FrOptions(negativePrefix: "négatif")),
        equals("négatif un"),
      );
      expect(
        converter.convert(-123, options: FrOptions(negativePrefix: "négatif")),
        equals("négatif cent vingt-trois"),
      );
    });

    test('Year Formatting', () {
      const yearOption = FrOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("mille neuf cents"));
      expect(converter.convert(2024, options: yearOption),
          equals("deux mille vingt-quatre"));
      expect(
        converter.convert(1900,
            options: FrOptions(format: Format.year, includeAD: true)),
        equals("mille neuf cents ap. J.-C."),
      );
      expect(
        converter.convert(2024,
            options: FrOptions(format: Format.year, includeAD: true)),
        equals("deux mille vingt-quatre ap. J.-C."),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("cent av. J.-C."));
      expect(
          converter.convert(-1, options: yearOption), equals("un av. J.-C."));

      expect(
        converter.convert(-2024,
            options: FrOptions(format: Format.year, includeAD: true)),
        equals("deux mille vingt-quatre av. J.-C."),
      );
    });

    test('Currency', () {
      const currencyOption = FrOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("zéro euro"));
      expect(converter.convert(1, options: currencyOption), equals("un euro"));
      expect(
          converter.convert(2, options: currencyOption), equals("deux euros"));
      expect(
        converter.convert(1.50, options: currencyOption),
        equals("un euro et cinquante centimes"),
      );
      expect(converter.convert(1.01, options: currencyOption),
          equals("un euro et un centime"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("cent vingt-trois euros et quarante-cinq centimes"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("cent vingt-trois virgule quatre cinq six"),
      );
      expect(
          converter.convert(Decimal.parse('1.50')), equals("un virgule cinq"));
      expect(converter.convert(Decimal.parse('1.05')),
          equals("un virgule zéro cinq"));
      expect(converter.convert(123.0), equals("cent vingt-trois"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("cent vingt-trois"));

      expect(
        converter.convert(1.5,
            options: const FrOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("un virgule cinq"),
      );

      expect(
        converter.convert(1.5,
            options:
                const FrOptions(decimalSeparator: DecimalSeparator.period)),
        equals("un point cinq"),
      );
      expect(
        converter.convert(1.5,
            options: const FrOptions(decimalSeparator: DecimalSeparator.point)),
        equals("un point cinq"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Infini"));
      expect(
          converter.convert(double.negativeInfinity), equals("Moins l'infini"));
      expect(converter.convert(double.nan), equals("N'est pas un nombre"));
      expect(converter.convert(null), equals("N'est pas un nombre"));
      expect(converter.convert('abc'), equals("N'est pas un nombre"));

      expect(converterWithFallback.convert(double.infinity), equals("Infini"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Moins l'infini"));
      expect(
          converterWithFallback.convert(double.nan), equals("Nombre invalide"));
      expect(converterWithFallback.convert(null), equals("Nombre invalide"));
      expect(converterWithFallback.convert('abc'), equals("Nombre invalide"));
      expect(converterWithFallback.convert(123), equals("cent vingt-trois"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("un million"));
      expect(converter.convert(BigInt.from(2000000)), equals("deux millions"));
      expect(converter.convert(BigInt.from(1000000000)), equals("un milliard"));
      expect(
          converter.convert(BigInt.from(2000000000)), equals("deux milliards"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("un billion"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("un billiard"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("un trillion"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("un trilliard"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("un quadrillion"),
      );

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "cent vingt-trois trilliards quatre cent cinquante-six trillions sept cent quatre-vingt-neuf billiards cent vingt-trois billions quatre cent cinquante-six milliards sept cent quatre-vingt-neuf millions cent vingt-trois mille quatre cent cinquante-six",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "neuf cent quatre-vingt-dix-neuf trilliards neuf cent quatre-vingt-dix-neuf trillions neuf cent quatre-vingt-dix-neuf billiards neuf cent quatre-vingt-dix-neuf billions neuf cent quatre-vingt-dix-neuf milliards neuf cent quatre-vingt-dix-neuf millions neuf cent quatre-vingt-dix-neuf mille neuf cent quatre-vingt-dix-neuf",
        ),
      );
    });
  });
}
