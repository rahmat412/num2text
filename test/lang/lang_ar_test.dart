import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Arabic (AR)', () {
    final converter = Num2Text(initialLang: Lang.AR);
    final converterWithFallback =
        Num2Text(initialLang: Lang.AR, fallbackOnError: "رقم غير صالح");

    test('Basic Numbers (Masculine)', () {
      expect(converter.convert(0), equals("صفر"));
      expect(converter.convert(1), equals("واحد"));
      expect(converter.convert(2), equals("اثنان"));
      expect(converter.convert(3), equals("ثلاثة"));
      expect(converter.convert(10), equals("عشرة"));
      expect(converter.convert(11), equals("أحد عشر"));
      expect(converter.convert(12), equals("اثنا عشر"));
      expect(converter.convert(13), equals("ثلاثة عشر"));
      expect(converter.convert(20), equals("عشرون"));
      expect(converter.convert(21), equals("واحد وعشرون"));
      expect(converter.convert(22), equals("اثنان وعشرون"));
      expect(converter.convert(23), equals("ثلاثة وعشرون"));
      expect(converter.convert(99), equals("تسعة وتسعون"));
    });
    test('Basic Numbers (Feminine)', () {
      const femOptions = ArOptions(gender: Gender.feminine);
      expect(converter.convert(1, options: femOptions), equals("واحدة"));
      expect(converter.convert(2, options: femOptions), equals("اثنتان"));
      expect(converter.convert(3, options: femOptions), equals("ثلاث"));
      expect(converter.convert(10, options: femOptions), equals("عشر"));
      expect(converter.convert(11, options: femOptions), equals("إحدى عشرة"));
      expect(converter.convert(12, options: femOptions), equals("اثنتا عشرة"));
      expect(converter.convert(13, options: femOptions), equals("ثلاث عشرة"));
      expect(converter.convert(20, options: femOptions), equals("عشرون"));
      expect(converter.convert(21, options: femOptions), equals("إحدى وعشرون"));
      expect(
          converter.convert(22, options: femOptions), equals("اثنتان وعشرون"));
      expect(converter.convert(23, options: femOptions), equals("ثلاث وعشرون"));
      expect(converter.convert(99, options: femOptions), equals("تسع وتسعون"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("مئة"));
      expect(converter.convert(101), equals("مئة وواحد"));
      expect(converter.convert(111), equals("مئة وأحد عشر"));
      expect(converter.convert(200), equals("مئتان"));
      expect(converter.convert(300), equals("ثلاثمئة"));
      expect(converter.convert(999), equals("تسعمئة وتسعة وتسعون"));
    });

    test('Thousands (Masculine/Default)', () {
      expect(converter.convert(1000), equals("ألف"));
      expect(converter.convert(1001), equals("ألف وواحد"));
      expect(converter.convert(1111), equals("ألف ومئة وأحد عشر"));
      expect(converter.convert(2000), equals("ألفان"));
      expect(converter.convert(3000), equals("ثلاثة آلاف"));
      expect(converter.convert(10000), equals("عشرة آلاف"));
      expect(converter.convert(100000), equals("مئة ألف"));
      expect(converter.convert(123456),
          equals("مئة وثلاثة وعشرون ألفًا وأربعمئة وستة وخمسون"));
      expect(converter.convert(999999),
          equals("تسعمئة وتسعة وتسعون ألفًا وتسعمئة وتسعة وتسعون"));
    });

    test('Thousands (Feminine)', () {
      const femOptions = ArOptions(gender: Gender.feminine);
      expect(converter.convert(1000, options: femOptions), equals("ألف"));
      expect(
          converter.convert(1001, options: femOptions), equals("ألف وواحدة"));
      expect(converter.convert(1111, options: femOptions),
          equals("ألف ومئة وإحدى عشرة"));
      expect(converter.convert(2000, options: femOptions), equals("ألفان"));
      expect(
          converter.convert(3000, options: femOptions), equals("ثلاثة آلاف"));
      expect(
          converter.convert(10000, options: femOptions), equals("عشرة آلاف"));
      expect(converter.convert(100000, options: femOptions), equals("مئة ألف"));
      expect(
        converter.convert(121456, options: femOptions),
        equals("مئة وإحدى وعشرون ألفًا وأربعمئة وست وخمسون"),
      );
      expect(
        converter.convert(122456, options: femOptions),
        equals("مئة واثنتان وعشرون ألفًا وأربعمئة وست وخمسون"),
      );
      expect(
        converter.convert(999999, options: femOptions),
        equals("تسعمئة وتسع وتسعون ألفًا وتسعمئة وتسع وتسعون"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("سالب واحد"));
      expect(converter.convert(-123), equals("سالب مئة وثلاثة وعشرون"));
      expect(
        converter.convert(-1, options: ArOptions(negativePrefix: "ناقص")),
        equals("ناقص واحد"),
      );
      expect(
        converter.convert(-123, options: ArOptions(negativePrefix: "ناقص")),
        equals("ناقص مئة وثلاثة وعشرون"),
      );
    });

    test('Year Formatting', () {
      const yearOption = ArOptions(format: Format.year);
      expect(
          converter.convert(1900, options: yearOption), equals("ألف وتسعمئة"));
      expect(converter.convert(2024, options: yearOption),
          equals("ألفان وأربعة وعشرون"));
      expect(
        converter.convert(1900,
            options: ArOptions(format: Format.year, includeAD: true)),
        equals("ألف وتسعمئة م"),
      );
      expect(
        converter.convert(2024,
            options: ArOptions(format: Format.year, includeAD: true)),
        equals("ألفان وأربعة وعشرون م"),
      );
      expect(converter.convert(-100, options: yearOption), equals("مئة ق.م"));
      expect(converter.convert(-1, options: yearOption), equals("واحد ق.م"));
      expect(
        converter.convert(-2024,
            options: ArOptions(format: Format.year, includeAD: true)),
        equals("ألفان وأربعة وعشرون ق.م"),
      );
    });

    test('Currency', () {
      const currencyOption = ArOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("صفر ريال سعودي"));
      expect(converter.convert(1, options: currencyOption),
          equals("واحد ريال سعودي"));
      expect(converter.convert(2, options: currencyOption),
          equals("اثنان ريال سعودي"));
      expect(converter.convert(3, options: currencyOption),
          equals("ثلاثة ريالات سعودية"));
      expect(converter.convert(10, options: currencyOption),
          equals("عشرة ريالات سعودية"));
      expect(converter.convert(11, options: currencyOption),
          equals("أحد عشر ريالاً سعوديًا"));
      expect(
        converter.convert(1.50, options: currencyOption),
        equals("واحد ريال سعودي وخمسون هللة"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("مئة وثلاثة وعشرون ريالاً سعوديًا وخمس وأربعون هللة"),
      );
      expect(
        converter.convert(123.05, options: currencyOption),
        equals("مئة وثلاثة وعشرون ريالاً سعوديًا وخمسة هللات"),
      );
      expect(
        converter.convert(123.02, options: currencyOption),
        equals("مئة وثلاثة وعشرون ريالاً سعوديًا وهللتان"),
      );
      expect(
        converter.convert(123.01, options: currencyOption),
        equals("مئة وثلاثة وعشرون ريالاً سعوديًا وهللة"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("مئة وثلاثة وعشرون فاصلة أربعة خمسة ستة"),
      );
      expect(
          converter.convert(Decimal.parse('1.50')), equals("واحد فاصلة خمسة"));
      expect(converter.convert(123.0), equals("مئة وثلاثة وعشرون"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("مئة وثلاثة وعشرون"));
      expect(
        converter.convert(1.5,
            options: const ArOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("واحد فاصلة خمسة"),
      );
      expect(
        converter.convert(1.5,
            options:
                const ArOptions(decimalSeparator: DecimalSeparator.period)),
        equals("واحد نقطة خمسة"),
      );
      expect(
        converter.convert(1.5,
            options: const ArOptions(decimalSeparator: DecimalSeparator.point)),
        equals("واحد نقطة خمسة"),
      );
    });

    test('infinity and invalid input', () {
      expect(converter.convert(double.infinity), equals("لانهاية"));
      expect(
          converter.convert(double.negativeInfinity), equals("سالب لانهاية"));
      expect(converter.convert(double.nan), equals("ليس رقماً"));
      expect(converter.convert(null), equals("ليس رقماً"));
      expect(converter.convert('abc'), equals("ليس رقماً"));

      expect(converterWithFallback.convert(double.infinity), equals("لانهاية"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("سالب لانهاية"));
      expect(converterWithFallback.convert(double.nan), equals("رقم غير صالح"));
      expect(converterWithFallback.convert(null), equals("رقم غير صالح"));
      expect(converterWithFallback.convert('abc'), equals("رقم غير صالح"));
      expect(converterWithFallback.convert(123), equals("مئة وثلاثة وعشرون"));
    });

    test('Scale Numbers (Masculine/Default)', () {
      expect(converter.convert(BigInt.from(1000000)), equals("مليون"));
      expect(converter.convert(BigInt.from(1000000000)), equals("مليار"));
      expect(converter.convert(BigInt.from(1000000000000)), equals("تريليون"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("كوادريليون"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("كوينتيليون"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("سكستيليون"));
      expect(converter.convert(BigInt.parse('1000000000000000000000000')),
          equals("سبتيليون"));
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "مئة وثلاثة وعشرون سكستيليونًا وأربعمئة وستة وخمسون كوينتيليونًا وسبعمئة وتسعة وثمانون كوادريليونًا ومئة وثلاثة وعشرون تريليونًا وأربعمئة وستة وخمسون مليارًا وسبعمئة وتسعة وثمانون مليونًا ومئة وثلاثة وعشرون ألفًا وأربعمئة وستة وخمسون",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "تسعمئة وتسعة وتسعون سكستيليونًا وتسعمئة وتسعة وتسعون كوينتيليونًا وتسعمئة وتسعة وتسعون كوادريليونًا وتسعمئة وتسعة وتسعون تريليونًا وتسعمئة وتسعة وتسعون مليارًا وتسعمئة وتسعة وتسعون مليونًا وتسعمئة وتسعة وتسعون ألفًا وتسعمئة وتسعة وتسعون",
        ),
      );
    });

    test('Scale Numbers (Feminine Context)', () {
      const femOptions = ArOptions(gender: Gender.feminine);
      expect(converter.convert(BigInt.from(1000000), options: femOptions),
          equals("مليون"));
      expect(converter.convert(BigInt.from(1000000000), options: femOptions),
          equals("مليار"));
      expect(
        converter.convert(BigInt.parse('123456789123456789123456'),
            options: femOptions),
        equals(
          "مئة وثلاث وعشرون سكستيليونًا وأربعمئة وست وخمسون كوينتيليونًا وسبعمئة وتسع وثمانون كوادريليونًا ومئة وثلاث وعشرون تريليونًا وأربعمئة وست وخمسون مليارًا وسبعمئة وتسع وثمانون مليونًا ومئة وثلاث وعشرون ألفًا وأربعمئة وست وخمسون",
        ),
      );
    });
  });
}
