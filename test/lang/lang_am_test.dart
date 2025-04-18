import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Amharic (AM)', () {
    final converter = Num2Text(initialLang: Lang.AM);
    final converterWithFallback =
        Num2Text(initialLang: Lang.AM, fallbackOnError: "ልክ ያልሆነ ቁጥር");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("ዜሮ"));
      expect(converter.convert(1), equals("አንድ"));
      expect(converter.convert(10), equals("አስር"));
      expect(converter.convert(11), equals("አስራ አንድ"));
      expect(converter.convert(20), equals("ሃያ"));
      expect(converter.convert(21), equals("ሃያ አንድ"));
      expect(converter.convert(99), equals("ዘጠና ዘጠኝ"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("መቶ"));
      expect(converter.convert(101), equals("መቶ አንድ"));
      expect(converter.convert(111), equals("መቶ አስራ አንድ"));
      expect(converter.convert(200), equals("ሁለት መቶ"));
      expect(converter.convert(999), equals("ዘጠኝ መቶ ዘጠና ዘጠኝ"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("ሺህ"));
      expect(converter.convert(1001), equals("ሺህ አንድ"));
      expect(converter.convert(1111), equals("ሺህ መቶ አስራ አንድ"));
      expect(converter.convert(2000), equals("ሁለት ሺህ"));
      expect(converter.convert(10000), equals("አስር ሺህ"));
      expect(converter.convert(100000), equals("መቶ ሺህ"));
      expect(converter.convert(123456), equals("መቶ ሃያ ሶስት ሺህ አራት መቶ ሃምሳ ስድስት"));
      expect(converter.convert(999999),
          equals("ዘጠኝ መቶ ዘጠና ዘጠኝ ሺህ ዘጠኝ መቶ ዘጠና ዘጠኝ"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("አሉታዊ አንድ"));
      expect(converter.convert(-123), equals("አሉታዊ መቶ ሃያ ሶስት"));
      expect(converter.convert(-1, options: AmOptions(negativePrefix: "የሳልብ")),
          equals("የሳልብ አንድ"));
      expect(
        converter.convert(-123, options: AmOptions(negativePrefix: "የሳልብ")),
        equals("የሳልብ መቶ ሃያ ሶስት"),
      );
    });

    test('Year Formatting', () {
      const yearOption = AmOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption), equals("ሺህ ዘጠኝ መቶ"));
      expect(converter.convert(2024, options: yearOption),
          equals("ሁለት ሺህ ሃያ አራት"));
      expect(
        converter.convert(1900,
            options: AmOptions(format: Format.year, includeAD: true)),
        equals("ሺህ ዘጠኝ መቶ ዓ.ም"),
      );
      expect(
        converter.convert(2024,
            options: AmOptions(format: Format.year, includeAD: true)),
        equals("ሁለት ሺህ ሃያ አራት ዓ.ም"),
      );
      expect(converter.convert(-100, options: yearOption), equals("መቶ ዓ.ዓ"));
      expect(converter.convert(-1, options: yearOption), equals("አንድ ዓ.ዓ"));
      expect(
        converter.convert(-2024,
            options: AmOptions(format: Format.year, includeAD: true)),
        equals("ሁለት ሺህ ሃያ አራት ዓ.ዓ"),
      );
    });

    test('Currency', () {
      const currencyOption = AmOptions(currency: true);
      expect(converter.convert(0, options: currencyOption), equals("ዜሮ ብር"));
      expect(converter.convert(1, options: currencyOption), equals("አንድ ብር"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("አንድ ብር ከሃምሳ ሳንቲም"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("መቶ ሃያ ሶስት ብር ከአርባ አምስት ሳንቲም"),
      );
    });

    test('Decimals', () {
      expect(converter.convert(Decimal.parse('123.456')),
          equals("መቶ ሃያ ሶስት ነጥብ አራት አምስት ስድስት"));
      expect(converter.convert(Decimal.parse('1.50')), equals("አንድ ነጥብ አምስት"));
      expect(converter.convert(123.0), equals("መቶ ሃያ ሶስት"));
      expect(converter.convert(Decimal.parse('123.0')), equals("መቶ ሃያ ሶስት"));
      expect(
        converter.convert(1.5,
            options: const AmOptions(decimalSeparator: DecimalSeparator.point)),
        equals("አንድ ነጥብ አምስት"),
      );
      expect(
        converter.convert(1.5,
            options:
                const AmOptions(decimalSeparator: DecimalSeparator.period)),
        equals("አንድ ነጥብ አምስት"),
      );
      expect(
        converter.convert(1.5,
            options: const AmOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("አንድ ኮማ አምስት"),
      );
    });

    test('infinity and invalid input', () {
      expect(converter.convert(double.infinity), equals("ወሰን የሌለው"));
      expect(
          converter.convert(double.negativeInfinity), equals("አሉታዊ ወሰን የሌለው"));
      expect(converter.convert(double.nan), equals("ቁጥር አይደለም"));
      expect(converter.convert(null), equals("ቁጥር አይደለም"));
      expect(converter.convert('abc'), equals("ቁጥር አይደለም"));

      expect(
          converterWithFallback.convert(double.infinity), equals("ወሰን የሌለው"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("አሉታዊ ወሰን የሌለው"));
      expect(converterWithFallback.convert(double.nan), equals("ልክ ያልሆነ ቁጥር"));
      expect(converterWithFallback.convert(null), equals("ልክ ያልሆነ ቁጥር"));
      expect(converterWithFallback.convert('abc'), equals("ልክ ያልሆነ ቁጥር"));
      expect(converterWithFallback.convert(123), equals("መቶ ሃያ ሶስት"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("አንድ ሚሊዮን"));
      expect(converter.convert(BigInt.from(1000000000)), equals("አንድ ቢሊዮን"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("አንድ ትሪሊዮን"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("አንድ ኳድሪሊዮን"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("አንድ ኩንቲሊዮን"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("አንድ ሴክስቲሊዮን"));
      expect(converter.convert(BigInt.parse('1000000000000000000000000')),
          equals("አንድ ሴፕቲሊዮን"));
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "መቶ ሃያ ሶስት ሴክስቲሊዮን አራት መቶ ሃምሳ ስድስት ኩንቲሊዮን ሰባት መቶ ሰማንያ ዘጠኝ ኳድሪሊዮን መቶ ሃያ ሶስት ትሪሊዮን አራት መቶ ሃምሳ ስድስት ቢሊዮን ሰባት መቶ ሰማንያ ዘጠኝ ሚሊዮን መቶ ሃያ ሶስት ሺህ አራት መቶ ሃምሳ ስድስት",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "ዘጠኝ መቶ ዘጠና ዘጠኝ ሴክስቲሊዮን ዘጠኝ መቶ ዘጠና ዘጠኝ ኩንቲሊዮን ዘጠኝ መቶ ዘጠና ዘጠኝ ኳድሪሊዮን ዘጠኝ መቶ ዘጠና ዘጠኝ ትሪሊዮን ዘጠኝ መቶ ዘጠና ዘጠኝ ቢሊዮን ዘጠኝ መቶ ዘጠና ዘጠኝ ሚሊዮን ዘጠኝ መቶ ዘጠና ዘጠኝ ሺህ ዘጠኝ መቶ ዘጠና ዘጠኝ",
        ),
      );
    });
  });
}
