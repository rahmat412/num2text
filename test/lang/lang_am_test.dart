import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Amharic (AM)', () {
    final converter = Num2Text(initialLang: Lang.AM);
    final converterWithFallback = Num2Text(
      initialLang: Lang.AM,
      fallbackOnError: "ልክ ያልሆነ ቁጥር",
    );

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("ዜሮ"));
      expect(converter.convert(10), equals("አስር"));
      expect(converter.convert(11), equals("አስራ አንድ"));
      expect(converter.convert(13), equals("አስራ ሶስት"));
      expect(converter.convert(15), equals("አስራ አምስት"));
      expect(converter.convert(20), equals("ሃያ"));
      expect(converter.convert(27), equals("ሃያ ሰባት"));
      expect(converter.convert(30), equals("ሰላሳ"));
      expect(converter.convert(54), equals("ሃምሳ አራት"));
      expect(converter.convert(68), equals("ስልሳ ስምንት"));
      expect(converter.convert(99), equals("ዘጠና ዘጠኝ"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("መቶ"));
      expect(converter.convert(101), equals("መቶ አንድ"));
      expect(converter.convert(105), equals("መቶ አምስት"));
      expect(converter.convert(110), equals("መቶ አስር"));
      expect(converter.convert(111), equals("መቶ አስራ አንድ"));
      expect(converter.convert(123), equals("መቶ ሃያ ሶስት"));
      expect(converter.convert(200), equals("ሁለት መቶ"));
      expect(converter.convert(321), equals("ሶስት መቶ ሃያ አንድ"));
      expect(converter.convert(479), equals("አራት መቶ ሰባ ዘጠኝ"));
      expect(converter.convert(596), equals("አምስት መቶ ዘጠና ስድስት"));
      expect(converter.convert(681), equals("ስድስት መቶ ሰማንያ አንድ"));
      expect(converter.convert(999), equals("ዘጠኝ መቶ ዘጠና ዘጠኝ"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("አንድ ሺህ"));
      expect(converter.convert(1001), equals("አንድ ሺህ አንድ"));
      expect(converter.convert(1011), equals("አንድ ሺህ አስራ አንድ"));
      expect(converter.convert(1110), equals("አንድ ሺህ መቶ አስር"));
      expect(converter.convert(1111), equals("አንድ ሺህ መቶ አስራ አንድ"));
      expect(converter.convert(2000), equals("ሁለት ሺህ"));
      expect(converter.convert(2468), equals("ሁለት ሺህ አራት መቶ ስልሳ ስምንት"));
      expect(converter.convert(3579), equals("ሶስት ሺህ አምስት መቶ ሰባ ዘጠኝ"));
      expect(converter.convert(10000), equals("አስር ሺህ"));
      expect(converter.convert(10011), equals("አስር ሺህ አስራ አንድ"));
      expect(converter.convert(11100), equals("አስራ አንድ ሺህ መቶ"));
      expect(converter.convert(12987), equals("አስራ ሁለት ሺህ ዘጠኝ መቶ ሰማንያ ሰባት"));
      expect(converter.convert(45623), equals("አርባ አምስት ሺህ ስድስት መቶ ሃያ ሶስት"));
      expect(converter.convert(87654), equals("ሰማንያ ሰባት ሺህ ስድስት መቶ ሃምሳ አራት"));
      expect(converter.convert(100000), equals("መቶ ሺህ"));
      expect(converter.convert(123456), equals("መቶ ሃያ ሶስት ሺህ አራት መቶ ሃምሳ ስድስት"));
      expect(converter.convert(987654),
          equals("ዘጠኝ መቶ ሰማንያ ሰባት ሺህ ስድስት መቶ ሃምሳ አራት"));
      expect(converter.convert(999999),
          equals("ዘጠኝ መቶ ዘጠና ዘጠኝ ሺህ ዘጠኝ መቶ ዘጠና ዘጠኝ"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("አሉታዊ አንድ"));
      expect(converter.convert(-123), equals("አሉታዊ መቶ ሃያ ሶስት"));
      expect(converter.convert(-123.456),
          equals("አሉታዊ መቶ ሃያ ሶስት ነጥብ አራት አምስት ስድስት"));

      const negativeOption = AmOptions(negativePrefix: "የሳልብ");

      expect(
          converter.convert(-1, options: negativeOption), equals("የሳልብ አንድ"));
      expect(converter.convert(-123, options: negativeOption),
          equals("የሳልብ መቶ ሃያ ሶስት"));
      expect(converter.convert(-123.456, options: negativeOption),
          equals("የሳልብ መቶ ሃያ ሶስት ነጥብ አራት አምስት ስድስት"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456), equals("መቶ ሃያ ሶስት ነጥብ አራት አምስት ስድስት"));
      expect(converter.convert(1.5), equals("አንድ ነጥብ አምስት"));
      expect(converter.convert(1.05), equals("አንድ ነጥብ ዜሮ አምስት"));
      expect(converter.convert(879.465),
          equals("ስምንት መቶ ሰባ ዘጠኝ ነጥብ አራት ስድስት አምስት"));
      expect(converter.convert(1.5), equals("አንድ ነጥብ አምስት"));

      const pointOption = AmOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = AmOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = AmOptions(decimalSeparator: DecimalSeparator.period);

      expect(
          converter.convert(1.5, options: pointOption), equals("አንድ ነጥብ አምስት"));
      expect(
          converter.convert(1.5, options: commaOption), equals("አንድ ኮማ አምስት"));
      expect(converter.convert(1.5, options: periodOption),
          equals("አንድ ነጥብ አምስት"));
    });

    test('Year Formatting', () {
      const yearOption = AmOptions(format: Format.year);

      expect(converter.convert(123, options: yearOption), equals("መቶ ሃያ ሶስት"));
      expect(converter.convert(498, options: yearOption),
          equals("አራት መቶ ዘጠና ስምንት"));
      expect(converter.convert(756, options: yearOption),
          equals("ሰባት መቶ ሃምሳ ስድስት"));
      expect(converter.convert(1900, options: yearOption),
          equals("አንድ ሺህ ዘጠኝ መቶ"));
      expect(converter.convert(1999, options: yearOption),
          equals("አንድ ሺህ ዘጠኝ መቶ ዘጠና ዘጠኝ"));
      expect(converter.convert(2025, options: yearOption),
          equals("ሁለት ሺህ ሃያ አምስት"));

      const yearOptionAD = AmOptions(format: Format.year, includeAD: true);

      expect(converter.convert(1900, options: yearOptionAD),
          equals("አንድ ሺህ ዘጠኝ መቶ ዓ.ም"));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("አንድ ሺህ ዘጠኝ መቶ ዘጠና ዘጠኝ ዓ.ም"));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("ሁለት ሺህ ሃያ አምስት ዓ.ም"));
      expect(converter.convert(-1, options: yearOption), equals("አንድ ዓ.ዓ"));
      expect(converter.convert(-100, options: yearOption), equals("መቶ ዓ.ዓ"));
      expect(converter.convert(-100, options: yearOptionAD), equals("መቶ ዓ.ዓ"));
      expect(converter.convert(-2025, options: yearOption),
          equals("ሁለት ሺህ ሃያ አምስት ዓ.ዓ"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("አንድ ሚሊዮን ዓ.ዓ"));
    });

    test('Currency', () {
      const currencyOption = AmOptions(currency: true);

      expect(converter.convert(0, options: currencyOption), equals("ዜሮ ብር"));
      expect(converter.convert(1, options: currencyOption), equals("አንድ ብር"));
      expect(converter.convert(2, options: currencyOption), equals("ሁለት ብር"));
      expect(converter.convert(5, options: currencyOption), equals("አምስት ብር"));
      expect(converter.convert(10, options: currencyOption), equals("አስር ብር"));
      expect(
          converter.convert(11, options: currencyOption), equals("አስራ አንድ ብር"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("አንድ ብር ከሃምሳ ሳንቲም"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("መቶ ሃያ ሶስት ብር ከአርባ አምስት ሳንቲም"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("አስር ሚሊዮን ብር"));
      expect(
          converter.convert(0.5, options: currencyOption), equals("ሃምሳ ሳንቲም"));
      expect(
          converter.convert(0.01, options: currencyOption), equals("አንድ ሳንቲም"));
      expect(
          converter.convert(0.02, options: currencyOption), equals("ሁለት ሳንቲም"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("አንድ ብር ከአንድ ሳንቲም"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("አንድ ሚሊዮን"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("ሁለት ቢሊዮን"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("ሶስት ትሪሊዮን"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("አራት ኳድሪሊዮን"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("አምስት ኩንቲሊዮን"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("ስድስት ሴክስቲሊዮን"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("ሰባት ሴፕቲሊዮን"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "ዘጠኝ ኩንቲሊዮን ስምንት መቶ ሰባ ስድስት ኳድሪሊዮን አምስት መቶ አርባ ሶስት ትሪሊዮን ሁለት መቶ አስር ቢሊዮን መቶ ሃያ ሶስት ሚሊዮን አራት መቶ ሃምሳ ስድስት ሺህ ሰባት መቶ ሰማንያ ዘጠኝ"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              "መቶ ሃያ ሶስት ሴክስቲሊዮን አራት መቶ ሃምሳ ስድስት ኩንቲሊዮን ሰባት መቶ ሰማንያ ዘጠኝ ኳድሪሊዮን መቶ ሃያ ሶስት ትሪሊዮን አራት መቶ ሃምሳ ስድስት ቢሊዮን ሰባት መቶ ሰማንያ ዘጠኝ ሚሊዮን መቶ ሃያ ሶስት ሺህ አራት መቶ ሃምሳ ስድስት"));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              "ዘጠኝ መቶ ዘጠና ዘጠኝ ሴክስቲሊዮን ዘጠኝ መቶ ዘጠና ዘጠኝ ኩንቲሊዮን ዘጠኝ መቶ ዘጠና ዘጠኝ ኳድሪሊዮን ዘጠኝ መቶ ዘጠና ዘጠኝ ትሪሊዮን ዘጠኝ መቶ ዘጠና ዘጠኝ ቢሊዮን ዘጠኝ መቶ ዘጠና ዘጠኝ ሚሊዮን ዘጠኝ መቶ ዘጠና ዘጠኝ ሺህ ዘጠኝ መቶ ዘጠና ዘጠኝ"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("አንድ ትሪሊዮን ሁለት ሚሊዮን ሶስት"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("አምስት ሚሊዮን አንድ ሺህ"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("አንድ ቢሊዮን አንድ"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("አንድ ቢሊዮን አንድ ሚሊዮን"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("ሁለት ሚሊዮን አንድ ሺህ"));
      expect(converter.convert(BigInt.parse('1000987600003')),
          equals("አንድ ትሪሊዮን ዘጠኝ መቶ ሰማንያ ሰባት ሚሊዮን ስድስት መቶ ሺህ ሶስት"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("ቁጥር አይደለም"));
      expect(converter.convert(double.infinity), equals("ወሰን የሌለው"));
      expect(
          converter.convert(double.negativeInfinity), equals("አሉታዊ ወሰን የሌለው"));
      expect(converter.convert(null), equals("ቁጥር አይደለም"));
      expect(converter.convert('abc'), equals("ቁጥር አይደለም"));
      expect(converter.convert([]), equals("ቁጥር አይደለም"));
      expect(converter.convert({}), equals("ቁጥር አይደለም"));
      expect(converter.convert(Object()), equals("ቁጥር አይደለም"));
      expect(converterWithFallback.convert(double.nan), equals("ልክ ያልሆነ ቁጥር"));
      expect(
          converterWithFallback.convert(double.infinity), equals("ወሰን የሌለው"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("አሉታዊ ወሰን የሌለው"));
      expect(converterWithFallback.convert(null), equals("ልክ ያልሆነ ቁጥር"));
      expect(converterWithFallback.convert('abc'), equals("ልክ ያልሆነ ቁጥር"));
      expect(converterWithFallback.convert([]), equals("ልክ ያልሆነ ቁጥር"));
      expect(converterWithFallback.convert({}), equals("ልክ ያልሆነ ቁጥር"));
      expect(converterWithFallback.convert(Object()), equals("ልክ ያልሆነ ቁጥር"));
      expect(converterWithFallback.convert(123), equals("መቶ ሃያ ሶስት"));
    });
  });
}
