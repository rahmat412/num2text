import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Bengali (BN)', () {
    final converter = Num2Text(initialLang: Lang.BN);
    final converterWithFallback =
        Num2Text(initialLang: Lang.BN, fallbackOnError: "অবৈধ সংখ্যা");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("শূন্য"));
      expect(converter.convert(1), equals("এক"));
      expect(converter.convert(10), equals("দশ"));
      expect(converter.convert(11), equals("এগারো"));
      expect(converter.convert(20), equals("বিশ"));
      expect(converter.convert(21), equals("একুশ"));
      expect(converter.convert(99), equals("নিরানব্বই"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("একশ"));
      expect(converter.convert(101), equals("একশ এক"));
      expect(converter.convert(111), equals("একশ এগারো"));
      expect(converter.convert(200), equals("দুইশ"));
      expect(converter.convert(999), equals("নয়শ নিরানব্বই"));
    });

    test('Thousands, Lakhs, Crores', () {
      expect(converter.convert(1000), equals("এক হাজার"));
      expect(converter.convert(1001), equals("এক হাজার এক"));
      expect(converter.convert(1111), equals("এক হাজার একশ এগারো"));
      expect(converter.convert(2000), equals("দুই হাজার"));
      expect(converter.convert(10000), equals("দশ হাজার"));
      expect(converter.convert(100000), equals("এক লক্ষ"));
      expect(converter.convert(123456),
          equals("এক লক্ষ তেইশ হাজার চারশ ছাপ্পান্ন"));
      expect(converter.convert(999999),
          equals("নয় লক্ষ নিরানব্বই হাজার নয়শ নিরানব্বই"));
      expect(converter.convert(1000000), equals("দশ লক্ষ"));
      expect(converter.convert(10000000), equals("এক কোটি"));
      expect(
        converter.convert(12345678),
        equals("এক কোটি তেইশ লক্ষ পঁয়তাল্লিশ হাজার ছয়শ আটাত্তর"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("ঋণাত্মক এক"));
      expect(converter.convert(-123), equals("ঋণাত্মক একশ তেইশ"));
      expect(
        converter.convert(-1,
            options: const BnOptions(negativePrefix: "বিয়োগ")),
        equals("বিয়োগ এক"),
      );
      expect(
        converter.convert(-123,
            options: const BnOptions(negativePrefix: "বিয়োগ")),
        equals("বিয়োগ একশ তেইশ"),
      );
    });

    test('Year Formatting', () {
      const yearOption = BnOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption), equals("উনিশশ"));
      expect(converter.convert(2024, options: yearOption),
          equals("দুই হাজার চব্বিশ"));
      expect(
        converter.convert(1900,
            options: const BnOptions(format: Format.year, includeAD: true)),
        equals("উনিশশ খ্রিস্টাব্দ"),
      );
      expect(
        converter.convert(2024,
            options: const BnOptions(format: Format.year, includeAD: true)),
        equals("দুই হাজার চব্বিশ খ্রিস্টাব্দ"),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("একশ খ্রিস্টপূর্ব"));
      expect(converter.convert(-1, options: yearOption),
          equals("এক খ্রিস্টপূর্ব"));
      expect(
        converter.convert(-2024,
            options: const BnOptions(format: Format.year, includeAD: true)),
        equals("দুই হাজার চব্বিশ খ্রিস্টপূর্ব"),
      );
    });

    test('Currency', () {
      const currencyOption = BnOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("শূন্য টাকা"));
      expect(converter.convert(1, options: currencyOption), equals("এক টাকা"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("এক টাকা পঞ্চাশ পয়সা"));
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("একশ তেইশ টাকা পঁয়তাল্লিশ পয়সা"),
      );
    });

    group('Decimals', () {
      test('Handles Decimals', () {
        expect(converter.convert(Decimal.parse('123.456')),
            equals("একশ তেইশ দশমিক চার পাঁচ ছয়"));

        expect(
            converter.convert(Decimal.parse('1.50')), equals("এক দশমিক পাঁচ"));
        expect(converter.convert(123.0), equals("একশ তেইশ"));
        expect(converter.convert(Decimal.parse('123.0')), equals("একশ তেইশ"));
        expect(
          converter.convert(
            1.5,
            options: const BnOptions(decimalSeparator: DecimalSeparator.period),
          ),
          equals("এক দশমিক পাঁচ"),
        );
        expect(
          converter.convert(
            1.5,
            options: const BnOptions(decimalSeparator: DecimalSeparator.point),
          ),
          equals("এক দশমিক পাঁচ"),
        );
        expect(
          converter.convert(
            1.5,
            options: const BnOptions(decimalSeparator: DecimalSeparator.comma),
          ),
          equals("এক কমা পাঁচ"),
        );
      });
    });

    group('Handles infinity and invalid', () {
      test('Handles infinity and invalid input', () {
        expect(converter.convert(double.infinity), equals("অসীম"));
        expect(
            converter.convert(double.negativeInfinity), equals("ঋণাত্মক অসীম"));
        expect(converter.convert(double.nan), equals("সংখ্যা নয়"));
        expect(converter.convert(null), equals("সংখ্যা নয়"));
        expect(converter.convert('abc'), equals("সংখ্যা নয়"));

        expect(converterWithFallback.convert(double.infinity), equals("অসীম"));
        expect(converterWithFallback.convert(double.negativeInfinity),
            equals("ঋণাত্মক অসীম"));
        expect(
            converterWithFallback.convert(double.nan), equals("অবৈধ সংখ্যা"));
        expect(converterWithFallback.convert(null), equals("অবৈধ সংখ্যা"));
        expect(converterWithFallback.convert('abc'), equals("অবৈধ সংখ্যা"));
        expect(converterWithFallback.convert(123), equals("একশ তেইশ"));
      });
    });

    test('Scale Numbers (Lakh, Crore)', () {
      expect(converter.convert(BigInt.from(100000)), equals("এক লক্ষ"));
      expect(converter.convert(BigInt.from(1000000)), equals("দশ লক্ষ"));
      expect(converter.convert(BigInt.from(10000000)), equals("এক কোটি"));
      expect(converter.convert(BigInt.from(100000000)), equals("দশ কোটি"));
      expect(converter.convert(BigInt.from(1000000000)), equals("একশ কোটি"));
      expect(
          converter.convert(BigInt.from(10000000000)), equals("এক হাজার কোটি"));
      expect(converter.convert(BigInt.from(100000000000)),
          equals("দশ হাজার কোটি"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("এক লক্ষ কোটি"));
      expect(
        converter.convert(BigInt.parse('123456789123')),
        equals(
            "বারো হাজার তিনশ পঁয়তাল্লিশ কোটি সাতষট্টি লক্ষ উননব্বই হাজার একশ তেইশ"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999')),
        equals(
            "নিরানব্বই হাজার নয়শ নিরানব্বই কোটি নিরানব্বই লক্ষ নিরানব্বই হাজার নয়শ নিরানব্বই"),
      );
    });
  });
}
