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

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("ნული"));
      expect(converter.convert(1), equals("ერთი"));
      expect(converter.convert(10), equals("ათი"));
      expect(converter.convert(11), equals("თერთმეტი"));
      expect(converter.convert(20), equals("ოცი"));
      expect(converter.convert(21), equals("ოცდაერთი"));
      expect(converter.convert(30), equals("ოცდაათი"));
      expect(converter.convert(40), equals("ორმოცი"));
      expect(converter.convert(50), equals("ორმოცდაათი"));
      expect(converter.convert(60), equals("სამოცი"));
      expect(converter.convert(70), equals("სამოცდაათი"));
      expect(converter.convert(80), equals("ოთხმოცი"));
      expect(converter.convert(90), equals("ოთხმოცდაათი"));
      expect(converter.convert(99), equals("ოთხმოცდაცხრამეტი"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("ასი"));
      expect(converter.convert(101), equals("ას ერთი"));
      expect(converter.convert(111), equals("ას თერთმეტი"));
      expect(converter.convert(200), equals("ორასი"));
      expect(converter.convert(999), equals("ცხრაას ოთხმოცდაცხრამეტი"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("ათასი"));
      expect(converter.convert(1001), equals("ათას ერთი"));
      expect(converter.convert(1111), equals("ათას ას თერთმეტი"));
      expect(converter.convert(2000), equals("ორი ათასი"));
      expect(converter.convert(10000), equals("ათი ათასი"));
      expect(converter.convert(100000), equals("ასი ათასი"));
      expect(converter.convert(123456),
          equals("ას ოცდასამი ათას ოთხას ორმოცდათექვსმეტი"));
      expect(
        converter.convert(999999),
        equals("ცხრაას ოთხმოცდაცხრამეტი ათას ცხრაას ოთხმოცდაცხრამეტი"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("მინუს ერთი"));
      expect(converter.convert(-123), equals("მინუს ას ოცდასამი"));
      expect(
        converter.convert(-1, options: KaOptions(negativePrefix: "უარყოფითი")),
        equals("უარყოფითი ერთი"),
      );
      expect(
        converter.convert(-123,
            options: KaOptions(negativePrefix: "უარყოფითი")),
        equals("უარყოფითი ას ოცდასამი"),
      );
    });

    test('Year Formatting', () {
      const yearOption = KaOptions(format: Format.year);
      expect(
          converter.convert(1900, options: yearOption), equals("ათას ცხრაასი"));
      expect(converter.convert(2024, options: yearOption),
          equals("ორი ათას ოცდაოთხი"));
      expect(
        converter.convert(1900,
            options: KaOptions(format: Format.year, includeAD: true)),
        equals("ათას ცხრაასი ჩვენი წელთაღრიცხვით"),
      );
      expect(
        converter.convert(2024,
            options: KaOptions(format: Format.year, includeAD: true)),
        equals("ორი ათას ოცდაოთხი ჩვენი წელთაღრიცხვით"),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("ასი ჩვენს წელთაღრიცხვამდე"));
      expect(converter.convert(-1, options: yearOption),
          equals("ერთი ჩვენს წელთაღრიცხვამდე"));

      expect(
        converter.convert(-2024,
            options: KaOptions(format: Format.year, includeAD: true)),
        equals("ორი ათას ოცდაოთხი ჩვენს წელთაღრიცხვამდე"),
      );
    });

    test('Currency', () {
      const currencyOption = KaOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("ნული ლარი"));
      expect(
          converter.convert(1, options: currencyOption), equals("ერთი ლარი"));
      expect(
        converter.convert(1.50, options: currencyOption),
        equals("ერთი ლარი და ორმოცდაათი თეთრი"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("ას ოცდასამი ლარი და ორმოცდახუთი თეთრი"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("ას ოცდასამი მძიმე ოთხი ხუთი ექვსი"),
      );
      expect(
          converter.convert(Decimal.parse('1.50')), equals("ერთი მძიმე ხუთი"));
      expect(converter.convert(123.0), equals("ას ოცდასამი"));
      expect(converter.convert(Decimal.parse('123.0')), equals("ას ოცდასამი"));

      expect(
        converter.convert(1.5,
            options: const KaOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("ერთი მძიმე ხუთი"),
      );

      expect(
        converter.convert(1.5,
            options:
                const KaOptions(decimalSeparator: DecimalSeparator.period)),
        equals("ერთი წერტილი ხუთი"),
      );
      expect(
        converter.convert(1.5,
            options: const KaOptions(decimalSeparator: DecimalSeparator.point)),
        equals("ერთი წერტილი ხუთი"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("უსასრულობა"));
      expect(converter.convert(double.negativeInfinity),
          equals("მინუს უსასრულობა"));
      expect(converter.convert(double.nan), equals("არა რიცხვი"));
      expect(converter.convert(null), equals("არა რიცხვი"));
      expect(converter.convert('abc'), equals("არა რიცხვი"));

      expect(
          converterWithFallback.convert(double.infinity), equals("უსასრულობა"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("მინუს უსასრულობა"));
      expect(
          converterWithFallback.convert(double.nan), equals("არასწორი რიცხვი"));
      expect(converterWithFallback.convert(null), equals("არასწორი რიცხვი"));
      expect(converterWithFallback.convert('abc'), equals("არასწორი რიცხვი"));
      expect(converterWithFallback.convert(123), equals("ას ოცდასამი"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("ერთი მილიონი"));
      expect(
          converter.convert(BigInt.from(1000000000)), equals("ერთი მილიარდი"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("ერთი ტრილიონი"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("ერთი კვადრილიონი"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("ერთი კვინტილიონი"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("ერთი სექსტილიონი"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("ერთი სეპტილიონი"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "ას ოცდასამი სექსტილიონი ოთხას ორმოცდათექვსმეტი კვინტილიონი შვიდას ოთხმოცდაცხრა კვადრილიონი ას ოცდასამი ტრილიონი ოთხას ორმოცდათექვსმეტი მილიარდი შვიდას ოთხმოცდაცხრა მილიონი ას ოცდასამი ათას ოთხას ორმოცდათექვსმეტი",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "ცხრაას ოთხმოცდაცხრამეტი სექსტილიონი ცხრაას ოთხმოცდაცხრამეტი კვინტილიონი ცხრაას ოთხმოცდაცხრამეტი კვადრილიონი ცხრაას ოთხმოცდაცხრამეტი ტრილიონი ცხრაას ოთხმოცდაცხრამეტი მილიარდი ცხრაას ოთხმოცდაცხრამეტი მილიონი ცხრაას ოთხმოცდაცხრამეტი ათას ცხრაას ოთხმოცდაცხრამეტი",
        ),
      );
    });
  });
}
