import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Greek (EL)', () {
    final converter = Num2Text(initialLang: Lang.EL);
    final converterWithFallback =
        Num2Text(initialLang: Lang.EL, fallbackOnError: "Μη Έγκυρος Αριθμός");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("μηδέν"));
      expect(converter.convert(10), equals("δέκα"));
      expect(converter.convert(11), equals("έντεκα"));
      expect(converter.convert(13), equals("δεκατρία"));
      expect(converter.convert(15), equals("δεκαπέντε"));
      expect(converter.convert(20), equals("είκοσι"));
      expect(converter.convert(27), equals("είκοσι επτά"));
      expect(converter.convert(30), equals("τριάντα"));
      expect(converter.convert(54), equals("πενήντα τέσσερα"));
      expect(converter.convert(68), equals("εξήντα οκτώ"));
      expect(converter.convert(99), equals("ενενήντα εννέα"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("εκατό"));
      expect(converter.convert(101), equals("εκατόν ένα"));
      expect(converter.convert(105), equals("εκατόν πέντε"));
      expect(converter.convert(110), equals("εκατόν δέκα"));
      expect(converter.convert(111), equals("εκατόν έντεκα"));
      expect(converter.convert(123), equals("εκατόν είκοσι τρία"));
      expect(converter.convert(200), equals("διακόσια"));
      expect(converter.convert(321), equals("τριακόσια είκοσι ένα"));
      expect(converter.convert(479), equals("τετρακόσια εβδομήντα εννέα"));
      expect(converter.convert(596), equals("πεντακόσια ενενήντα έξι"));
      expect(converter.convert(681), equals("εξακόσια ογδόντα ένα"));
      expect(converter.convert(999), equals("εννιακόσια ενενήντα εννέα"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("χίλια"));
      expect(converter.convert(1001), equals("χίλια ένα"));
      expect(converter.convert(1011), equals("χίλια έντεκα"));
      expect(converter.convert(1110), equals("χίλια εκατόν δέκα"));
      expect(converter.convert(1111), equals("χίλια εκατόν έντεκα"));
      expect(converter.convert(2000), equals("δύο χιλιάδες"));
      expect(converter.convert(2468),
          equals("δύο χιλιάδες τετρακόσια εξήντα οκτώ"));
      expect(converter.convert(3579),
          equals("τρεις χιλιάδες πεντακόσια εβδομήντα εννέα"));
      expect(converter.convert(10000), equals("δέκα χιλιάδες"));
      expect(converter.convert(10011), equals("δέκα χιλιάδες έντεκα"));
      expect(converter.convert(11100), equals("έντεκα χιλιάδες εκατό"));
      expect(converter.convert(12987),
          equals("δώδεκα χιλιάδες εννιακόσια ογδόντα επτά"));
      expect(converter.convert(45623),
          equals("σαράντα πέντε χιλιάδες εξακόσια είκοσι τρία"));
      expect(converter.convert(87654),
          equals("ογδόντα επτά χιλιάδες εξακόσια πενήντα τέσσερα"));
      expect(converter.convert(100000), equals("εκατό χιλιάδες"));
      expect(converter.convert(123456),
          equals("εκατόν είκοσι τρεις χιλιάδες τετρακόσια πενήντα έξι"));
      expect(converter.convert(987654),
          equals("εννιακόσιες ογδόντα επτά χιλιάδες εξακόσια πενήντα τέσσερα"));
      expect(
          converter.convert(999999),
          equals(
              "εννιακόσιες ενενήντα εννέα χιλιάδες εννιακόσια ενενήντα εννέα"));
    });

    test('Negative Numbers', () {
      const negativePrefixOption = ElOptions(negativePrefix: "πλην");

      expect(converter.convert(-1), equals("μείον ένα"));
      expect(converter.convert(-123), equals("μείον εκατόν είκοσι τρία"));
      expect(converter.convert(-123.456),
          equals("μείον εκατόν είκοσι τρία κόμμα τέσσερα πέντε έξι"));

      expect(converter.convert(-1, options: negativePrefixOption),
          equals("πλην ένα"));
      expect(converter.convert(-123, options: negativePrefixOption),
          equals("πλην εκατόν είκοσι τρία"));
      expect(converter.convert(-123.456, options: negativePrefixOption),
          equals("πλην εκατόν είκοσι τρία κόμμα τέσσερα πέντε έξι"));
    });

    test('Decimals', () {
      const pointOption = ElOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = ElOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = ElOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(123.456),
          equals("εκατόν είκοσι τρία κόμμα τέσσερα πέντε έξι"));
      expect(converter.convert("1.50"), equals("ένα κόμμα πέντε"));
      expect(converter.convert(1.05), equals("ένα κόμμα μηδέν πέντε"));
      expect(converter.convert(879.465),
          equals("οκτακόσια εβδομήντα εννέα κόμμα τέσσερα έξι πέντε"));
      expect(converter.convert(1.5), equals("ένα κόμμα πέντε"));

      expect(converter.convert(1.5, options: pointOption),
          equals("ένα τελεία πέντε"));
      expect(converter.convert(1.5, options: commaOption),
          equals("ένα κόμμα πέντε"));
      expect(converter.convert(1.5, options: periodOption),
          equals("ένα τελεία πέντε"));
    });

    test('Year Formatting', () {
      const yearOption = ElOptions(format: Format.year);
      const yearOptionAD = ElOptions(format: Format.year, includeAD: true);

      expect(converter.convert(123, options: yearOption),
          equals("εκατόν είκοσι τρία"));
      expect(converter.convert(498, options: yearOption),
          equals("τετρακόσια ενενήντα οκτώ"));
      expect(converter.convert(756, options: yearOption),
          equals("επτακόσια πενήντα έξι"));
      expect(converter.convert(1900, options: yearOption),
          equals("χίλια εννιακόσια"));
      expect(converter.convert(1999, options: yearOption),
          equals("χίλια εννιακόσια ενενήντα εννέα"));
      expect(converter.convert(2025, options: yearOption),
          equals("δύο χιλιάδες είκοσι πέντε"));

      expect(converter.convert(1900, options: yearOptionAD),
          equals("χίλια εννιακόσια μ.Χ."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("χίλια εννιακόσια ενενήντα εννέα μ.Χ."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("δύο χιλιάδες είκοσι πέντε μ.Χ."));
      expect(converter.convert(-1, options: yearOption), equals("ένα π.Χ."));
      expect(
          converter.convert(-100, options: yearOption), equals("εκατό π.Χ."));
      expect(
          converter.convert(-100, options: yearOptionAD), equals("εκατό π.Χ."));
      expect(converter.convert(-2025, options: yearOption),
          equals("δύο χιλιάδες είκοσι πέντε π.Χ."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("ένα εκατομμύριο π.Χ."));
    });

    test('Currency', () {
      const currencyOption = ElOptions(currency: true);

      expect(
          converter.convert(0, options: currencyOption), equals("μηδέν ευρώ"));
      expect(converter.convert(1, options: currencyOption), equals("ένα ευρώ"));
      expect(converter.convert(2, options: currencyOption), equals("δύο ευρώ"));
      expect(
          converter.convert(5, options: currencyOption), equals("πέντε ευρώ"));
      expect(
          converter.convert(10, options: currencyOption), equals("δέκα ευρώ"));
      expect(converter.convert(11, options: currencyOption),
          equals("έντεκα ευρώ"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("ένα ευρώ και πενήντα λεπτά"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("εκατόν είκοσι τρία ευρώ και σαράντα πέντε λεπτά"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("δέκα εκατομμύρια ευρώ"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("πενήντα λεπτά"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("ένα λεπτό"));
      expect(converter.convert(0.02, options: currencyOption),
          equals("δύο λεπτά"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("πέντε λεπτά"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("ένα ευρώ και ένα λεπτό"));
    });

    test('Scale Numbers', () {
      expect(
          converter.convert(BigInt.from(10).pow(6)), equals("ένα εκατομμύριο"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("δύο δισεκατομμύρια"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("τρία τρισεκατομμύρια"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("τέσσερα τετράκις εκατομμύρια"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("πέντε πεντάκις εκατομμύρια"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("έξι εξάκις εκατομμύρια"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("επτά επτάκις εκατομμύρια"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "εννέα πεντάκις εκατομμύρια οκτακόσια εβδομήντα έξι τετράκις εκατομμύρια πεντακόσια σαράντα τρία τρισεκατομμύρια διακόσια δέκα δισεκατομμύρια εκατόν είκοσι τρία εκατομμύρια τετρακόσιες πενήντα έξι χιλιάδες επτακόσια ογδόντα εννέα"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "εκατόν είκοσι τρία εξάκις εκατομμύρια τετρακόσια πενήντα έξι πεντάκις εκατομμύρια επτακόσια ογδόντα εννέα τετράκις εκατομμύρια εκατόν είκοσι τρία τρισεκατομμύρια τετρακόσια πενήντα έξι δισεκατομμύρια επτακόσια ογδόντα εννέα εκατομμύρια εκατόν είκοσι τρεις χιλιάδες τετρακόσια πενήντα έξι"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "εννιακόσια ενενήντα εννέα εξάκις εκατομμύρια εννιακόσια ενενήντα εννέα πεντάκις εκατομμύρια εννιακόσια ενενήντα εννέα τετράκις εκατομμύρια εννιακόσια ενενήντα εννέα τρισεκατομμύρια εννιακόσια ενενήντα εννέα δισεκατομμύρια εννιακόσια ενενήντα εννέα εκατομμύρια εννιακόσιες ενενήντα εννέα χιλιάδες εννιακόσια ενενήντα εννέα"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("ένα τρισεκατομμύριο δύο εκατομμύρια τρία"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("πέντε εκατομμύρια χίλια"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("ένα δισεκατομμύριο ένα"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("ένα δισεκατομμύριο ένα εκατομμύριο"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("δύο εκατομμύρια χίλια"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "ένα τρισεκατομμύριο εννιακόσια ογδόντα επτά εκατομμύρια εξακόσιες χιλιάδες τρία"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Μη Αριθμός"));
      expect(converter.convert(double.infinity), equals("Άπειρο"));
      expect(converter.convert(double.negativeInfinity),
          equals("Αρνητικό Άπειρο"));
      expect(converter.convert(null), equals("Μη Αριθμός"));
      expect(converter.convert('abc'), equals("Μη Αριθμός"));
      expect(converter.convert([]), equals("Μη Αριθμός"));
      expect(converter.convert({}), equals("Μη Αριθμός"));
      expect(converter.convert(Object()), equals("Μη Αριθμός"));

      expect(converterWithFallback.convert(double.nan),
          equals("Μη Έγκυρος Αριθμός"));
      expect(converterWithFallback.convert(double.infinity), equals("Άπειρο"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Αρνητικό Άπειρο"));
      expect(converterWithFallback.convert(null), equals("Μη Έγκυρος Αριθμός"));
      expect(
          converterWithFallback.convert('abc'), equals("Μη Έγκυρος Αριθμός"));
      expect(converterWithFallback.convert([]), equals("Μη Έγκυρος Αριθμός"));
      expect(converterWithFallback.convert({}), equals("Μη Έγκυρος Αριθμός"));
      expect(converterWithFallback.convert(Object()),
          equals("Μη Έγκυρος Αριθμός"));
      expect(converterWithFallback.convert(123), equals("εκατόν είκοσι τρία"));
    });
  });
}
