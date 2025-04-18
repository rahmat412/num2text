import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Greek (EL)', () {
    final converter = Num2Text(initialLang: Lang.EL);
    final converterWithFallback = Num2Text(
      initialLang: Lang.EL,
      fallbackOnError: "Μη έγκυρος αριθμός",
    );

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("μηδέν"));
      expect(converter.convert(1), equals("ένα"));
      expect(converter.convert(10), equals("δέκα"));
      expect(converter.convert(11), equals("έντεκα"));
      expect(converter.convert(20), equals("είκοσι"));
      expect(converter.convert(21), equals("είκοσι ένα"));
      expect(converter.convert(99), equals("ενενήντα εννέα"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("εκατό"));
      expect(converter.convert(101), equals("εκατόν ένα"));
      expect(converter.convert(111), equals("εκατόν έντεκα"));
      expect(converter.convert(200), equals("διακόσια"));
      expect(converter.convert(999), equals("εννιακόσια ενενήντα εννέα"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("χίλια"));
      expect(converter.convert(1001), equals("χίλια ένα"));
      expect(converter.convert(1111), equals("χίλια εκατόν έντεκα"));
      expect(converter.convert(2000), equals("δύο χιλιάδες"));
      expect(converter.convert(10000), equals("δέκα χιλιάδες"));
      expect(converter.convert(100000), equals("εκατό χιλιάδες"));
      expect(
        converter.convert(123456),
        equals("εκατόν είκοσι τρεις χιλιάδες τετρακόσια πενήντα έξι"),
      );
      expect(
        converter.convert(999999),
        equals("εννιακόσιες ενενήντα εννέα χιλιάδες εννιακόσια ενενήντα εννέα"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("μείον ένα"));
      expect(converter.convert(-123), equals("μείον εκατόν είκοσι τρία"));
      expect(converter.convert(-1, options: ElOptions(negativePrefix: "πλην")),
          equals("πλην ένα"));
      expect(
        converter.convert(-123, options: ElOptions(negativePrefix: "πλην")),
        equals("πλην εκατόν είκοσι τρία"),
      );
    });

    test('Year Formatting', () {
      const yearOption = ElOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("χίλια εννιακόσια"));
      expect(converter.convert(2024, options: yearOption),
          equals("δύο χιλιάδες είκοσι τέσσερα"));
      expect(
        converter.convert(1900,
            options: ElOptions(format: Format.year, includeAD: true)),
        equals("χίλια εννιακόσια μ.Χ."),
      );
      expect(
        converter.convert(2024,
            options: ElOptions(format: Format.year, includeAD: true)),
        equals("δύο χιλιάδες είκοσι τέσσερα μ.Χ."),
      );
      expect(
          converter.convert(-100, options: yearOption), equals("εκατό π.Χ."));
      expect(converter.convert(-1, options: yearOption), equals("ένα π.Χ."));
      expect(
        converter.convert(-2024,
            options: ElOptions(format: Format.year, includeAD: true)),
        equals("δύο χιλιάδες είκοσι τέσσερα π.Χ."),
      );
    });

    test('Currency', () {
      const currencyOption = ElOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("μηδέν ευρώ"));
      expect(converter.convert(1, options: currencyOption), equals("ένα ευρώ"));
      expect(
        converter.convert(1.50, options: currencyOption),
        equals("ένα ευρώ και πενήντα λεπτά"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("εκατόν είκοσι τρία ευρώ και σαράντα πέντε λεπτά"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("εκατόν είκοσι τρία κόμμα τέσσερα πέντε έξι"),
      );
      expect(
          converter.convert(Decimal.parse('1.50')), equals("ένα κόμμα πέντε"));
      expect(converter.convert(123.0), equals("εκατόν είκοσι τρία"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("εκατόν είκοσι τρία"));
      expect(
        converter.convert(1.5,
            options: const ElOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("ένα κόμμα πέντε"),
      );
      expect(
        converter.convert(1.5,
            options:
                const ElOptions(decimalSeparator: DecimalSeparator.period)),
        equals("ένα τελεία πέντε"),
      );
      expect(
        converter.convert(1.5,
            options: const ElOptions(decimalSeparator: DecimalSeparator.point)),
        equals("ένα τελεία πέντε"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Άπειρο"));
      expect(converter.convert(double.negativeInfinity),
          equals("Αρνητικό Άπειρο"));
      expect(converter.convert(double.nan), equals("Μη αριθμός"));
      expect(converter.convert(null), equals("Μη αριθμός"));
      expect(converter.convert('abc'), equals("Μη αριθμός"));

      expect(converterWithFallback.convert(double.infinity), equals("Άπειρο"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Αρνητικό Άπειρο"));
      expect(converterWithFallback.convert(double.nan),
          equals("Μη έγκυρος αριθμός"));
      expect(converterWithFallback.convert(null), equals("Μη έγκυρος αριθμός"));
      expect(
          converterWithFallback.convert('abc'), equals("Μη έγκυρος αριθμός"));
      expect(converterWithFallback.convert(123), equals("εκατόν είκοσι τρία"));
    });

    test('Scale Numbers', () {
      expect(
          converter.convert(BigInt.from(1000000)), equals("ένα εκατομμύριο"));
      expect(converter.convert(BigInt.from(1000000000)),
          equals("ένα δισεκατομμύριο"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("ένα τρισεκατομμύριο"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("ένα τετράκις εκατομμύριο"));
      expect(
        converter.convert(BigInt.from(1000000000000000000)),
        equals("ένα πεντάκις εκατομμύριο"),
      );
      expect(
        converter.convert(BigInt.parse('1000000000000000000000')),
        equals("ένα εξάκις εκατομμύριο"),
      );
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("ένα επτάκις εκατομμύριο"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "εκατόν είκοσι τρία εξάκις εκατομμύρια τετρακόσια πενήντα έξι πεντάκις εκατομμύρια επτακόσια ογδόντα εννέα τετράκις εκατομμύρια εκατόν είκοσι τρία τρισεκατομμύρια τετρακόσια πενήντα έξι δισεκατομμύρια επτακόσια ογδόντα εννέα εκατομμύρια εκατόν είκοσι τρεις χιλιάδες τετρακόσια πενήντα έξι",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "εννιακόσια ενενήντα εννέα εξάκις εκατομμύρια εννιακόσια ενενήντα εννέα πεντάκις εκατομμύρια εννιακόσια ενενήντα εννέα τετράκις εκατομμύρια εννιακόσια ενενήντα εννέα τρισεκατομμύρια εννιακόσια ενενήντα εννέα δισεκατομμύρια εννιακόσια ενενήντα εννέα εκατομμύρια εννιακόσιες ενενήντα εννέα χιλιάδες εννιακόσια ενενήντα εννέα",
        ),
      );
    });
  });
}
