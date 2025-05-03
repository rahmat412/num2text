import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Georgian (KA)', () {
    final converter = Num2Text(initialLang: Lang.KA);
    final converterWithFallback = Num2Text(
      initialLang: Lang.KA,
      fallbackOnError: "არასწორი რიცხვი",
    );

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("ნული"));
      expect(converter.convert(10), equals("ათი"));
      expect(converter.convert(11), equals("თერთმეტი"));
      expect(converter.convert(13), equals("ცამეტი"));
      expect(converter.convert(15), equals("თხუთმეტი"));
      expect(converter.convert(20), equals("ოცი"));
      expect(converter.convert(27), equals("ოცდაშვიდი"));
      expect(converter.convert(30), equals("ოცდაათი"));
      expect(converter.convert(40), equals("ორმოცი"));
      expect(converter.convert(50), equals("ორმოცდაათი"));
      expect(converter.convert(54), equals("ორმოცდათოთხმეტი"));
      expect(converter.convert(60), equals("სამოცი"));
      expect(converter.convert(68), equals("სამოცდარვა"));
      expect(converter.convert(70), equals("სამოცდაათი"));
      expect(converter.convert(80), equals("ოთხმოცი"));
      expect(converter.convert(90), equals("ოთხმოცდაათი"));
      expect(converter.convert(99), equals("ოთხმოცდაცხრამეტი"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("ასი"));
      expect(converter.convert(101), equals("ას ერთი"));
      expect(converter.convert(105), equals("ას ხუთი"));
      expect(converter.convert(110), equals("ას ათი"));
      expect(converter.convert(111), equals("ას თერთმეტი"));
      expect(converter.convert(123), equals("ას ოცდასამი"));
      expect(converter.convert(200), equals("ორასი"));
      expect(converter.convert(321), equals("სამას ოცდაერთი"));
      expect(converter.convert(479), equals("ოთხას სამოცდაცხრამეტი"));
      expect(converter.convert(596), equals("ხუთას ოთხმოცდათექვსმეტი"));
      expect(converter.convert(681), equals("ექვსას ოთხმოცდაერთი"));
      expect(converter.convert(999), equals("ცხრაას ოთხმოცდაცხრამეტი"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("ათასი"));
      expect(converter.convert(1001), equals("ათას ერთი"));
      expect(converter.convert(1011), equals("ათას თერთმეტი"));
      expect(converter.convert(1110), equals("ათას ას ათი"));
      expect(converter.convert(1111), equals("ათას ას თერთმეტი"));
      expect(converter.convert(2000), equals("ორი ათასი"));
      expect(converter.convert(2468), equals("ორი ათას ოთხას სამოცდარვა"));
      expect(
          converter.convert(3579), equals("სამი ათას ხუთას სამოცდაცხრამეტი"));
      expect(converter.convert(10000), equals("ათი ათასი"));
      expect(converter.convert(10011), equals("ათი ათას თერთმეტი"));
      expect(converter.convert(11100), equals("თერთმეტი ათას ასი"));
      expect(converter.convert(12987),
          equals("თორმეტი ათას ცხრაას ოთხმოცდაშვიდი"));
      expect(
          converter.convert(45623), equals("ორმოცდახუთი ათას ექვსას ოცდასამი"));
      expect(converter.convert(87654),
          equals("ოთხმოცდაშვიდი ათას ექვსას ორმოცდათოთხმეტი"));
      expect(converter.convert(100000), equals("ასი ათასი"));
      expect(converter.convert(123456),
          equals("ას ოცდასამი ათას ოთხას ორმოცდათექვსმეტი"));
      expect(converter.convert(987654),
          equals("ცხრაას ოთხმოცდაშვიდი ათას ექვსას ორმოცდათოთხმეტი"));
      expect(converter.convert(999999),
          equals("ცხრაას ოთხმოცდაცხრამეტი ათას ცხრაას ოთხმოცდაცხრამეტი"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("მინუს ერთი"));
      expect(converter.convert(-123), equals("მინუს ას ოცდასამი"));
      expect(converter.convert(Decimal.parse("-123.456")),
          equals("მინუს ას ოცდასამი მძიმე ოთხი ხუთი ექვსი"));
      const negativeOption = KaOptions(negativePrefix: "უარყოფითი");
      expect(converter.convert(-1, options: negativeOption),
          equals("უარყოფითი ერთი"));
      expect(converter.convert(-123, options: negativeOption),
          equals("უარყოფითი ას ოცდასამი"));
      expect(
          converter.convert(Decimal.parse("-123.456"), options: negativeOption),
          equals("უარყოფითი ას ოცდასამი მძიმე ოთხი ხუთი ექვსი"));
    });

    test('Decimals', () {
      expect(converter.convert(Decimal.parse("123.456")),
          equals("ას ოცდასამი მძიმე ოთხი ხუთი ექვსი"));
      expect(converter.convert(1.5), equals("ერთი მძიმე ხუთი"));
      expect(converter.convert(1.05), equals("ერთი მძიმე ნული ხუთი"));
      expect(converter.convert(879.465),
          equals("რვაას სამოცდაცხრამეტი მძიმე ოთხი ექვსი ხუთი"));
      expect(converter.convert(1.5), equals("ერთი მძიმე ხუთი"));
      const pointOption = KaOptions(decimalSeparator: DecimalSeparator.point);
      expect(converter.convert(1.5, options: pointOption),
          equals("ერთი წერტილი ხუთი"));
      const commaOption = KaOptions(decimalSeparator: DecimalSeparator.comma);
      expect(converter.convert(1.5, options: commaOption),
          equals("ერთი მძიმე ხუთი"));
      const periodOption = KaOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(1.5, options: periodOption),
          equals("ერთი წერტილი ხუთი"));
    });

    test('Year Formatting', () {
      const yearOption = KaOptions(format: Format.year);
      expect(
          converter.convert(123, options: yearOption), equals("ას ოცდასამი"));
      expect(converter.convert(498, options: yearOption),
          equals("ოთხას ოთხმოცდათვრამეტი"));
      expect(converter.convert(756, options: yearOption),
          equals("შვიდას ორმოცდათექვსმეტი"));
      expect(
          converter.convert(1900, options: yearOption), equals("ათას ცხრაასი"));
      expect(converter.convert(1999, options: yearOption),
          equals("ათას ცხრაას ოთხმოცდაცხრამეტი"));
      expect(converter.convert(2025, options: yearOption),
          equals("ორი ათას ოცდახუთი"));
      const yearOptionAD = KaOptions(format: Format.year, includeAD: true);
      expect(converter.convert(1900, options: yearOptionAD),
          equals("ათას ცხრაასი ჩვ. წ."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("ათას ცხრაას ოთხმოცდაცხრამეტი ჩვ. წ."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("ორი ათას ოცდახუთი ჩვ. წ."));
      expect(converter.convert(-1, options: yearOption),
          equals("ერთი ჩვ. წ.-მდე"));
      expect(converter.convert(-100, options: yearOption),
          equals("ასი ჩვ. წ.-მდე"));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("ასი ჩვ. წ.-მდე"));
      expect(converter.convert(-2025, options: yearOption),
          equals("ორი ათას ოცდახუთი ჩვ. წ.-მდე"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("ერთი მილიონი ჩვ. წ.-მდე"));
    });

    test('Currency', () {
      const currencyOption = KaOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("ნული ლარი"));
      expect(
          converter.convert(1, options: currencyOption), equals("ერთი ლარი"));
      expect(
          converter.convert(5, options: currencyOption), equals("ხუთი ლარი"));
      expect(
          converter.convert(10, options: currencyOption), equals("ათი ლარი"));
      expect(converter.convert(11, options: currencyOption),
          equals("თერთმეტი ლარი"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("ერთი ლარი და ორმოცდაათი თეთრი"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("ას ოცდასამი ლარი და ორმოცდახუთი თეთრი"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("ათი მილიონი ლარი"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("ორმოცდაათი თეთრი"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("ერთი თეთრი"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("ერთი ლარი და ერთი თეთრი"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("ერთი მილიონი"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("ორი მილიარდი"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("სამი ტრილიონი"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("ოთხი კვადრილიონი"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("ხუთი კვინტილიონი"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("ექვსი სექსტილიონი"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("შვიდი სეპტილიონი"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            "ცხრა კვინტილიონი რვაას სამოცდათექვსმეტი კვადრილიონი ხუთას ორმოცდასამი ტრილიონი ორას ათი მილიარდი ას ოცდასამი მილიონი ოთხას ორმოცდათექვსმეტი ათას შვიდას ოთხმოცდაცხრა"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "ას ოცდასამი სექსტილიონი ოთხას ორმოცდათექვსმეტი კვინტილიონი შვიდას ოთხმოცდაცხრა კვადრილიონი ას ოცდასამი ტრილიონი ოთხას ორმოცდათექვსმეტი მილიარდი შვიდას ოთხმოცდაცხრა მილიონი ას ოცდასამი ათას ოთხას ორმოცდათექვსმეტი"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "ცხრაას ოთხმოცდაცხრამეტი სექსტილიონი ცხრაას ოთხმოცდაცხრამეტი კვინტილიონი ცხრაას ოთხმოცდაცხრამეტი კვადრილიონი ცხრაას ოთხმოცდაცხრამეტი ტრილიონი ცხრაას ოთხმოცდაცხრამეტი მილიარდი ცხრაას ოთხმოცდაცხრამეტი მილიონი ცხრაას ოთხმოცდაცხრამეტი ათას ცხრაას ოთხმოცდაცხრამეტი"),
      );

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('ერთი ტრილიონი ორი მილიონი სამი'));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("ხუთი მილიონი ათასი"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("ერთი მილიარდი ერთი"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("ერთი მილიარდი ერთი მილიონი"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("ორი მილიონი ათასი"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              'ერთი ტრილიონი ცხრაას ოთხმოცდაშვიდი მილიონი ექვსასი ათას სამი'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("არა რიცხვი"));
      expect(converter.convert(double.infinity), equals("უსასრულობა"));
      expect(converter.convert(double.negativeInfinity),
          equals("მინუს უსასრულობა"));
      expect(converter.convert(null), equals("არა რიცხვი"));
      expect(converter.convert('abc'), equals("არა რიცხვი"));
      expect(converter.convert([]), equals("არა რიცხვი"));
      expect(converter.convert({}), equals("არა რიცხვი"));
      expect(converter.convert(Object()), equals("არა რიცხვი"));

      expect(
          converterWithFallback.convert(double.nan), equals("არასწორი რიცხვი"));
      expect(
          converterWithFallback.convert(double.infinity), equals("უსასრულობა"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("მინუს უსასრულობა"));
      expect(converterWithFallback.convert(null), equals("არასწორი რიცხვი"));
      expect(converterWithFallback.convert('abc'), equals("არასწორი რიცხვი"));
      expect(converterWithFallback.convert([]), equals("არასწორი რიცხვი"));
      expect(converterWithFallback.convert({}), equals("არასწორი რიცხვი"));
      expect(
          converterWithFallback.convert(Object()), equals("არასწორი რიცხვი"));
      expect(converterWithFallback.convert(123), equals("ას ოცდასამი"));
    });
  });
}
