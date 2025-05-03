import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Arabic (AR)', () {
    final converter = Num2Text(initialLang: Lang.AR);
    final converterWithFallback =
        Num2Text(initialLang: Lang.AR, fallbackOnError: "رقم غير صالح");

    test('Basic Numbers (0 - 99 Masculine)', () {
      expect(converter.convert(0), equals("صفر"));
      expect(converter.convert(1), equals("واحد"));
      expect(converter.convert(2), equals("اثنان"));
      expect(converter.convert(10), equals("عشرة"));
      expect(converter.convert(11), equals("أحد عشر"));
      expect(converter.convert(13), equals("ثلاثة عشر"));
      expect(converter.convert(15), equals("خمسة عشر"));
      expect(converter.convert(20), equals("عشرون"));
      expect(converter.convert(27), equals("سبعة وعشرون"));
      expect(converter.convert(30), equals("ثلاثون"));
      expect(converter.convert(54), equals("أربعة وخمسون"));
      expect(converter.convert(68), equals("ثمانية وستون"));
      expect(converter.convert(99), equals("تسعة وتسعون"));
    });

    test('Basic Numbers (0 - 99 Feminine)', () {
      const femOptions = ArOptions(gender: Gender.feminine);
      expect(converter.convert(0, options: femOptions), equals("صفر"));
      expect(converter.convert(1, options: femOptions), equals("واحدة"));
      expect(converter.convert(2, options: femOptions), equals("اثنتان"));
      expect(converter.convert(10, options: femOptions), equals("عشر"));
      expect(converter.convert(11, options: femOptions), equals("إحدى عشرة"));
      expect(converter.convert(13, options: femOptions), equals("ثلاث عشرة"));
      expect(converter.convert(15, options: femOptions), equals("خمس عشرة"));
      expect(converter.convert(20, options: femOptions), equals("عشرون"));
      expect(converter.convert(27, options: femOptions), equals("سبع وعشرون"));
      expect(converter.convert(30, options: femOptions), equals("ثلاثون"));
      expect(converter.convert(54, options: femOptions), equals("أربع وخمسون"));
      expect(converter.convert(68, options: femOptions), equals("ثمان وستون"));
      expect(converter.convert(99, options: femOptions), equals("تسع وتسعون"));
    });

    test('Hundreds (100 - 999 Masculine)', () {
      expect(converter.convert(100), equals("مئة"));
      expect(converter.convert(101), equals("مئة وواحد"));
      expect(converter.convert(105), equals("مئة وخمسة"));
      expect(converter.convert(110), equals("مئة وعشرة"));
      expect(converter.convert(111), equals("مئة وأحد عشر"));
      expect(converter.convert(123), equals("مئة وثلاثة وعشرون"));
      expect(converter.convert(200), equals("مئتان"));
      expect(converter.convert(300), equals("ثلاثمئة"));
      expect(converter.convert(321), equals("ثلاثمئة وواحد وعشرون"));
      expect(converter.convert(479), equals("أربعمئة وتسعة وسبعون"));
      expect(converter.convert(596), equals("خمسمئة وستة وتسعون"));
      expect(converter.convert(681), equals("ستمئة وواحد وثمانون"));
      expect(converter.convert(999), equals("تسعمئة وتسعة وتسعون"));
    });

    test('Hundreds (100 - 999 Feminine)', () {
      const femOptions = ArOptions(gender: Gender.feminine);
      expect(converter.convert(100, options: femOptions), equals("مئة"));
      expect(converter.convert(101, options: femOptions), equals("مئة وواحدة"));
      expect(converter.convert(105, options: femOptions), equals("مئة وخمس"));
      expect(converter.convert(110, options: femOptions), equals("مئة وعشر"));
      expect(converter.convert(111, options: femOptions),
          equals("مئة وإحدى عشرة"));
      expect(converter.convert(123, options: femOptions),
          equals("مئة وثلاث وعشرون"));
      expect(converter.convert(200, options: femOptions), equals("مئتان"));
      expect(converter.convert(300, options: femOptions), equals("ثلاثمئة"));
      expect(converter.convert(321, options: femOptions),
          equals("ثلاثمئة وإحدى وعشرون"));
      expect(converter.convert(479, options: femOptions),
          equals("أربعمئة وتسع وسبعون"));
      expect(converter.convert(596, options: femOptions),
          equals("خمسمئة وست وتسعون"));
      expect(converter.convert(681, options: femOptions),
          equals("ستمئة وإحدى وثمانون"));
      expect(converter.convert(999, options: femOptions),
          equals("تسعمئة وتسع وتسعون"));
    });

    test('Thousands (1000 - 999999 Masculine)', () {
      expect(converter.convert(1000), equals("ألف"));
      expect(converter.convert(1001), equals("ألف وواحد"));
      expect(converter.convert(1011), equals("ألف وأحد عشر"));
      expect(converter.convert(1110), equals("ألف ومئة وعشرة"));
      expect(converter.convert(1111), equals("ألف ومئة وأحد عشر"));
      expect(converter.convert(2000), equals("ألفان"));
      expect(converter.convert(2468), equals("ألفان وأربعمئة وثمانية وستون"));
      expect(converter.convert(3579), equals("ثلاث آلاف وخمسمئة وتسعة وسبعون"));
      expect(converter.convert(10000), equals("عشر آلاف"));
      expect(converter.convert(10011), equals("عشر آلاف وأحد عشر"));
      expect(converter.convert(11100), equals("أحد عشر ألفًا ومئة"));
      expect(converter.convert(12987),
          equals("اثنا عشر ألفًا وتسعمئة وسبعة وثمانون"));
      expect(converter.convert(45623),
          equals("خمسة وأربعون ألفًا وستمئة وثلاثة وعشرون"));
      expect(converter.convert(87654),
          equals("سبعة وثمانون ألفًا وستمئة وأربعة وخمسون"));
      expect(converter.convert(100000), equals("مئة ألف"));
      expect(converter.convert(123456),
          equals("مئة وثلاثة وعشرون ألفًا وأربعمئة وستة وخمسون"));
      expect(converter.convert(987654),
          equals("تسعمئة وسبعة وثمانون ألفًا وستمئة وأربعة وخمسون"));
      expect(converter.convert(999999),
          equals("تسعمئة وتسعة وتسعون ألفًا وتسعمئة وتسعة وتسعون"));
    });

    test('Thousands (1000 - 999999 Feminine)', () {
      const femOptions = ArOptions(gender: Gender.feminine);

      expect(converter.convert(1000, options: femOptions), equals("ألف"));
      expect(
          converter.convert(1001, options: femOptions), equals("ألف وواحدة"));
      expect(converter.convert(1011, options: femOptions),
          equals("ألف وإحدى عشرة"));
      expect(converter.convert(1110, options: femOptions),
          equals("ألف ومئة وعشر"));
      expect(converter.convert(1111, options: femOptions),
          equals("ألف ومئة وإحدى عشرة"));
      expect(converter.convert(2000, options: femOptions), equals("ألفان"));
      expect(converter.convert(2468, options: femOptions),
          equals("ألفان وأربعمئة وثمان وستون"));
      expect(converter.convert(3000, options: femOptions), equals("ثلاث آلاف"));
      expect(converter.convert(3579, options: femOptions),
          equals("ثلاث آلاف وخمسمئة وتسع وسبعون"));
      expect(converter.convert(10000, options: femOptions), equals("عشر آلاف"));
      expect(converter.convert(10011, options: femOptions),
          equals("عشر آلاف وإحدى عشرة"));
      expect(converter.convert(11000, options: femOptions),
          equals("أحد عشر ألفًا"));
      expect(converter.convert(11100, options: femOptions),
          equals("أحد عشر ألفًا ومئة"));
      expect(converter.convert(12987, options: femOptions),
          equals("اثنا عشر ألفًا وتسعمئة وسبع وثمانون"));
      expect(converter.convert(45623, options: femOptions),
          equals("خمسة وأربعون ألفًا وستمئة وثلاث وعشرون"));
      expect(converter.convert(87654, options: femOptions),
          equals("سبعة وثمانون ألفًا وستمئة وأربع وخمسون"));
      expect(converter.convert(100000, options: femOptions), equals("مئة ألف"));
      expect(converter.convert(123456, options: femOptions),
          equals("مئة وثلاثة وعشرون ألفًا وأربعمئة وست وخمسون"));
      expect(converter.convert(987654, options: femOptions),
          equals("تسعمئة وسبعة وثمانون ألفًا وستمئة وأربع وخمسون"));
      expect(converter.convert(999999, options: femOptions),
          equals("تسعمئة وتسعة وتسعون ألفًا وتسعمئة وتسع وتسعون"));
    });
    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("سالب واحد"));
      expect(converter.convert(-123), equals("سالب مئة وثلاثة وعشرون"));
      expect(converter.convert(-123.456),
          equals("سالب مئة وثلاثة وعشرون فاصلة أربعة خمسة ستة"));
      const negativeOption = ArOptions(negativePrefix: "ناقص");
      expect(
          converter.convert(-1, options: negativeOption), equals("ناقص واحد"));
      expect(converter.convert(-123, options: negativeOption),
          equals("ناقص مئة وثلاثة وعشرون"));
      expect(converter.convert(-123.456, options: negativeOption),
          equals("ناقص مئة وثلاثة وعشرون فاصلة أربعة خمسة ستة"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456),
          equals("مئة وثلاثة وعشرون فاصلة أربعة خمسة ستة"));
      expect(converter.convert(1.5), equals("واحد فاصلة خمسة"));
      expect(converter.convert(1.05), equals("واحد فاصلة صفر خمسة"));
      expect(converter.convert(879.465),
          equals("ثمانمئة وتسعة وسبعون فاصلة أربعة ستة خمسة"));
      expect(converter.convert(123.0), equals("مئة وثلاثة وعشرون"));
      const pointOption = ArOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = ArOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = ArOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(1.5, options: pointOption),
          equals("واحد نقطة خمسة"));
      expect(converter.convert(1.5, options: commaOption),
          equals("واحد فاصلة خمسة"));
      expect(converter.convert(1.5, options: periodOption),
          equals("واحد نقطة خمسة"));
    });

    test('Year Formatting', () {
      const yearOption = ArOptions(format: Format.year);
      expect(converter.convert(123, options: yearOption),
          equals("مئة وثلاثة وعشرون"));
      expect(converter.convert(498, options: yearOption),
          equals("أربعمئة وثمانية وتسعون"));
      expect(converter.convert(756, options: yearOption),
          equals("سبعمئة وستة وخمسون"));
      expect(
          converter.convert(1900, options: yearOption), equals("ألف وتسعمئة"));
      expect(converter.convert(1999, options: yearOption),
          equals("ألف وتسعمئة وتسعة وتسعون"));
      expect(converter.convert(2025, options: yearOption),
          equals("ألفان وخمسة وعشرون"));
      const yearOptionAD = ArOptions(format: Format.year, includeAD: true);
      expect(converter.convert(1900, options: yearOptionAD),
          equals("ألف وتسعمئة م"));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("ألف وتسعمئة وتسعة وتسعون م"));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("ألفان وخمسة وعشرون م"));
      expect(converter.convert(-1, options: yearOption), equals("واحد ق.م"));
      expect(converter.convert(-100, options: yearOption), equals("مئة ق.م"));
      expect(converter.convert(-100, options: yearOptionAD), equals("مئة ق.م"));
      expect(converter.convert(-2025, options: yearOption),
          equals("ألفان وخمسة وعشرون ق.م"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("مليون ق.م"));
    });

    test('Currency (SAR)', () {
      const currencyOption =
          ArOptions(currency: true, currencyInfo: CurrencyInfo.sar);
      expect(converter.convert(0, options: currencyOption),
          equals("صفر ريال سعودي"));
      expect(converter.convert(1, options: currencyOption),
          equals("ريال سعودي واحد"));
      expect(converter.convert(2, options: currencyOption),
          equals("ريالان سعوديان"));
      expect(converter.convert(3, options: currencyOption),
          equals("ثلاث ريالات سعودية"));
      expect(converter.convert(5, options: currencyOption),
          equals("خمس ريالات سعودية"));
      expect(converter.convert(10, options: currencyOption),
          equals("عشر ريالات سعودية"));
      expect(converter.convert(11, options: currencyOption),
          equals("أحد عشر ريالاً سعودياً"));
      expect(converter.convert(21, options: currencyOption),
          equals("واحد وعشرون ريالاً سعودياً"));
      expect(converter.convert(22, options: currencyOption),
          equals("اثنان وعشرون ريالاً سعودياً"));
      expect(converter.convert(25, options: currencyOption),
          equals("خمسة وعشرون ريالاً سعودياً"));
      expect(converter.convert(100, options: currencyOption),
          equals("مئة ريال سعودي"));
      expect(converter.convert(101, options: currencyOption),
          equals("مئة ريال سعودي وواحد"));
      expect(converter.convert(102, options: currencyOption),
          equals("مئة ريال سعودي واثنان"));
      expect(converter.convert(103, options: currencyOption),
          equals("مئة وثلاث ريالات سعودية"));
      expect(converter.convert(110, options: currencyOption),
          equals("مئة وعشر ريالات سعودية"));
      expect(converter.convert(111, options: currencyOption),
          equals("مئة وأحد عشر ريالاً سعودياً"));
      expect(converter.convert(200, options: currencyOption),
          equals("مئتا ريال سعودي"));
      expect(converter.convert(300, options: currencyOption),
          equals("ثلاثمئة ريال سعودي"));
      expect(converter.convert(1000, options: currencyOption),
          equals("ألف ريال سعودي"));
      expect(converter.convert(2000, options: currencyOption),
          equals("ألفا ريال سعودي"));
      expect(converter.convert(3000, options: currencyOption),
          equals("ثلاث آلاف ريال سعودي"));
      expect(converter.convert(10000, options: currencyOption),
          equals("عشر آلاف ريال سعودي"));
      expect(converter.convert(11000, options: currencyOption),
          equals("أحد عشر ألفًا ريال سعودي"));
      expect(converter.convert(1000000, options: currencyOption),
          equals("مليون ريال سعودي"));
      expect(converter.convert(2000000, options: currencyOption),
          equals("مليونا ريال سعودي"));
      expect(converter.convert(3000000, options: currencyOption),
          equals("ثلاث ملايين ريال سعودي"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("ريال سعودي واحد وخمسون هللة"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("مئة وثلاثة وعشرون ريالاً سعودياً وخمس وأربعون هللة"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("خمسون هللة"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("هللة واحدة"));
      expect(
          converter.convert(0.02, options: currencyOption), equals("هللتان"));
      expect(converter.convert(0.03, options: currencyOption),
          equals("ثلاثة هللات"));
      expect(converter.convert(0.10, options: currencyOption),
          equals("عشرة هللات"));
      expect(converter.convert(0.11, options: currencyOption),
          equals("إحدى عشرة هللة"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("ريال سعودي واحد وهللة واحدة"));
      expect(converter.convert(1.02, options: currencyOption),
          equals("ريال سعودي واحد وهللتان"));
      expect(converter.convert(2.03, options: currencyOption),
          equals("ريالان سعوديان وثلاثة هللات"));
      expect(converter.convert(3.11, options: currencyOption),
          equals("ثلاث ريالات سعودية وإحدى عشرة هللة"));
    });

    test('Scale Numbers (Masculine)', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("مليون"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(6)),
          equals("مليونان"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(6)),
          equals("ثلاث ملايين"));
      expect(converter.convert(BigInt.from(11) * BigInt.from(10).pow(6)),
          equals("أحد عشر مليونًا"));
      expect(converter.convert(BigInt.from(10).pow(9)), equals("مليار"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("ملياران"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(9)),
          equals("ثلاث مليارات"));
      expect(converter.convert(BigInt.from(10).pow(12)), equals("تريليون"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(12)),
          equals("تريليونان"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("ثلاث تريليونات"));
      expect(converter.convert(BigInt.from(10).pow(15)), equals("كوادريليون"));
      expect(converter.convert(BigInt.from(10).pow(18)), equals("كوينتيليون"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("سكستيليون"));
      expect(converter.convert(BigInt.parse('1000000000000000000000000')),
          equals("سبتيليون"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            "تسع كوينتيليونات وثمانمئة وستة وسبعون كوادريليونًا وخمسمئة وثلاثة وأربعون تريليونًا ومئتان وعشرة مليارات ومئة وثلاثة وعشرون مليونًا وأربعمئة وستة وخمسون ألفًا وسبعمئة وتسعة وثمانون"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "مئة وثلاثة وعشرون سكستيليونًا وأربعمئة وستة وخمسون كوينتيليونًا وسبعمئة وتسعة وثمانون كوادريليونًا ومئة وثلاثة وعشرون تريليونًا وأربعمئة وستة وخمسون مليارًا وسبعمئة وتسعة وثمانون مليونًا ومئة وثلاثة وعشرون ألفًا وأربعمئة وستة وخمسون"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "تسعمئة وتسعة وتسعون سكستيليونًا وتسعمئة وتسعة وتسعون كوينتيليونًا وتسعمئة وتسعة وتسعون كوادريليونًا وتسعمئة وتسعة وتسعون تريليونًا وتسعمئة وتسعة وتسعون مليارًا وتسعمئة وتسعة وتسعون مليونًا وتسعمئة وتسعة وتسعون ألفًا وتسعمئة وتسعة وتسعون"),
      );
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("تريليون ومليونان وثلاثة"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("خمس ملايين وألف"));
      expect(
          converter.convert(BigInt.parse('1000000001')), equals("مليار وواحد"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("مليار ومليون"));
      expect(
          converter.convert(BigInt.parse('2001000')), equals("مليونان وألف"));
      expect(converter.convert(BigInt.parse('1000987600003')),
          equals("تريليون وتسعمئة وسبعة وثمانون مليونًا وستمئة ألف وثلاثة"));
    });
    test('Scale Numbers (Feminine)', () {
      const femOptions = ArOptions(gender: Gender.feminine);

      expect(converter.convert(BigInt.from(10).pow(6), options: femOptions),
          equals("مليون"));
      expect(
          converter.convert(BigInt.from(2) * BigInt.from(10).pow(6),
              options: femOptions),
          equals("مليونان"));
      expect(
          converter.convert(BigInt.from(3) * BigInt.from(10).pow(6),
              options: femOptions),
          equals("ثلاث ملايين"));
      expect(
          converter.convert(BigInt.from(11) * BigInt.from(10).pow(6),
              options: femOptions),
          equals("أحد عشر مليونًا"));
      expect(converter.convert(BigInt.from(10).pow(9), options: femOptions),
          equals("مليار"));
      expect(
          converter.convert(BigInt.from(2) * BigInt.from(10).pow(9),
              options: femOptions),
          equals("ملياران"));
      expect(
          converter.convert(BigInt.from(3) * BigInt.from(10).pow(9),
              options: femOptions),
          equals("ثلاث مليارات"));
      expect(converter.convert(BigInt.from(10).pow(12), options: femOptions),
          equals("تريليون"));
      expect(
          converter.convert(BigInt.from(2) * BigInt.from(10).pow(12),
              options: femOptions),
          equals("تريليونان"));
      expect(
          converter.convert(BigInt.from(3) * BigInt.from(10).pow(12),
              options: femOptions),
          equals("ثلاث تريليونات"));

      expect(
        converter.convert(BigInt.parse('9876543210123456789'),
            options: femOptions),
        equals(
            "تسع كوينتيليونات وثمانمئة وستة وسبعون كوادريليونًا وخمسمئة وثلاثة وأربعون تريليونًا ومئتان وعشرة مليارات ومئة وثلاثة وعشرون مليونًا وأربعمئة وستة وخمسون ألفًا وسبعمئة وتسع وثمانون"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456'),
            options: femOptions),
        equals(
            "مئة وثلاثة وعشرون سكستيليونًا وأربعمئة وستة وخمسون كوينتيليونًا وسبعمئة وتسعة وثمانون كوادريليونًا ومئة وثلاثة وعشرون تريليونًا وأربعمئة وستة وخمسون مليارًا وسبعمئة وتسعة وثمانون مليونًا ومئة وثلاثة وعشرون ألفًا وأربعمئة وست وخمسون"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999'),
            options: femOptions),
        equals(
            "تسعمئة وتسعة وتسعون سكستيليونًا وتسعمئة وتسعة وتسعون كوينتيليونًا وتسعمئة وتسعة وتسعون كوادريليونًا وتسعمئة وتسعة وتسعون تريليونًا وتسعمئة وتسعة وتسعون مليارًا وتسعمئة وتسعة وتسعون مليونًا وتسعمئة وتسعة وتسعون ألفًا وتسعمئة وتسع وتسعون"),
      );
      expect(
          converter.convert(BigInt.parse('1000002000003'), options: femOptions),
          equals("تريليون ومليونان وثلاث"));
      expect(converter.convert(BigInt.parse('5001000'), options: femOptions),
          equals("خمس ملايين وألف"));
      expect(converter.convert(BigInt.parse('1000000001'), options: femOptions),
          equals("مليار وواحدة"));
      expect(converter.convert(BigInt.parse('1001000000'), options: femOptions),
          equals("مليار ومليون"));
      expect(converter.convert(BigInt.parse('2001000'), options: femOptions),
          equals("مليونان وألف"));
      expect(
          converter.convert(BigInt.parse('1000987600003'), options: femOptions),
          equals("تريليون وتسعمئة وسبعة وثمانون مليونًا وستمئة ألف وثلاث"));
    });
    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("ليس رقماً"));
      expect(converter.convert(double.infinity), equals("لانهاية"));
      expect(
          converter.convert(double.negativeInfinity), equals("سالب لانهاية"));
      expect(converter.convert(null), equals("ليس رقماً"));
      expect(converter.convert('abc'), equals("ليس رقماً"));
      expect(converter.convert([]), equals("ليس رقماً"));
      expect(converter.convert({}), equals("ليس رقماً"));
      expect(converter.convert(Object()), equals("ليس رقماً"));
      expect(converterWithFallback.convert(double.nan), equals("رقم غير صالح"));
      expect(converterWithFallback.convert(double.infinity), equals("لانهاية"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("سالب لانهاية"));
      expect(converterWithFallback.convert(null), equals("رقم غير صالح"));
      expect(converterWithFallback.convert('abc'), equals("رقم غير صالح"));
      expect(converterWithFallback.convert([]), equals("رقم غير صالح"));
      expect(converterWithFallback.convert({}), equals("رقم غير صالح"));
      expect(converterWithFallback.convert(Object()), equals("رقم غير صالح"));
      expect(converterWithFallback.convert(123), equals("مئة وثلاثة وعشرون"));
    });
  });
}
