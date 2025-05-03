import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Bengali (BN)', () {
    final converter = Num2Text(initialLang: Lang.BN);

    final converterWithFallback =
        Num2Text(initialLang: Lang.BN, fallbackOnError: "অবৈধ সংখ্যা");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("শূন্য"));
      expect(converter.convert(10), equals("দশ"));
      expect(converter.convert(11), equals("এগারো"));
      expect(converter.convert(13), equals("তেরো"));
      expect(converter.convert(15), equals("পনেরো"));
      expect(converter.convert(20), equals("বিশ"));
      expect(converter.convert(27), equals("সাতাশ"));
      expect(converter.convert(30), equals("ত্রিশ"));
      expect(converter.convert(54), equals("চুয়ান্ন"));
      expect(converter.convert(68), equals("আটষট্টি"));
      expect(converter.convert(99), equals("নিরানব্বই"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("একশ"));
      expect(converter.convert(101), equals("একশ এক"));
      expect(converter.convert(105), equals("একশ পাঁচ"));
      expect(converter.convert(110), equals("একশ দশ"));
      expect(converter.convert(111), equals("একশ এগারো"));
      expect(converter.convert(123), equals("একশ তেইশ"));
      expect(converter.convert(200), equals("দুইশ"));
      expect(converter.convert(321), equals("তিনশ একুশ"));
      expect(converter.convert(479), equals("চারশ উনআশি"));
      expect(converter.convert(596), equals("পাঁচশ ছিয়ানব্বই"));
      expect(converter.convert(681), equals("ছয়শ একাশি"));
      expect(converter.convert(999), equals("নয়শ নিরানব্বই"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("এক হাজার"));
      expect(converter.convert(1001), equals("এক হাজার এক"));
      expect(converter.convert(1011), equals("এক হাজার এগারো"));
      expect(converter.convert(1110), equals("এক হাজার একশ দশ"));
      expect(converter.convert(1111), equals("এক হাজার একশ এগারো"));
      expect(converter.convert(2000), equals("দুই হাজার"));
      expect(converter.convert(2468), equals("দুই হাজার চারশ আটষট্টি"));
      expect(converter.convert(3579), equals("তিন হাজার পাঁচশ উনআশি"));
      expect(converter.convert(10000), equals("দশ হাজার"));
      expect(converter.convert(10011), equals("দশ হাজার এগারো"));
      expect(converter.convert(11100), equals("এগারো হাজার একশ"));
      expect(converter.convert(12987), equals("বারো হাজার নয়শ সাতাশি"));
      expect(converter.convert(45623), equals("পঁয়তাল্লিশ হাজার ছয়শ তেইশ"));
      expect(converter.convert(87654), equals("সাতাশি হাজার ছয়শ চুয়ান্ন"));
      expect(converter.convert(100000), equals("এক লক্ষ"));
      expect(converter.convert(123456),
          equals("এক লক্ষ তেইশ হাজার চারশ ছাপ্পান্ন"));
      expect(converter.convert(987654),
          equals("নয় লক্ষ সাতাশি হাজার ছয়শ চুয়ান্ন"));
      expect(converter.convert(999999),
          equals("নয় লক্ষ নিরানব্বই হাজার নয়শ নিরানব্বই"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("ঋণাত্মক এক"));
      expect(converter.convert(-123), equals("ঋণাত্মক একশ তেইশ"));
      expect(converter.convert(-123.456),
          equals("ঋণাত্মক একশ তেইশ দশমিক চার পাঁচ ছয়"));

      const negativeOptions = BnOptions(negativePrefix: "বিয়োগ");

      expect(
          converter.convert(-1, options: negativeOptions), equals("বিয়োগ এক"));
      expect(converter.convert(-123, options: negativeOptions),
          equals("বিয়োগ একশ তেইশ"));
      expect(converter.convert(-123.456, options: negativeOptions),
          equals("বিয়োগ একশ তেইশ দশমিক চার পাঁচ ছয়"));
    });

    test('Decimals', () {
      const pointOption = BnOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = BnOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = BnOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(123.456), equals("একশ তেইশ দশমিক চার পাঁচ ছয়"));
      expect(converter.convert(1.5), equals("এক দশমিক পাঁচ"));
      expect(converter.convert(1.05), equals("এক দশমিক শূন্য পাঁচ"));
      expect(converter.convert(879.465), equals("আটশ উনআশি দশমিক চার ছয় পাঁচ"));
      expect(converter.convert(1.5), equals("এক দশমিক পাঁচ"));

      expect(converter.convert(1.5, options: pointOption),
          equals("এক দশমিক পাঁচ"));
      expect(
          converter.convert(1.5, options: commaOption), equals("এক কমা পাঁচ"));
      expect(converter.convert(1.5, options: periodOption),
          equals("এক দশমিক পাঁচ"));
    });

    test('Year Formatting', () {
      const yearOption = BnOptions(format: Format.year);
      const yearOptionAD = BnOptions(format: Format.year, includeAD: true);

      expect(converter.convert(123, options: yearOption), equals("একশ তেইশ"));
      expect(
          converter.convert(498, options: yearOption), equals("চারশ আটানব্বই"));
      expect(converter.convert(756, options: yearOption),
          equals("সাতশ ছাপ্পান্ন"));
      expect(converter.convert(1900, options: yearOption), equals("উনিশশ"));
      expect(converter.convert(1999, options: yearOption),
          equals("উনিশশ নিরানব্বই"));
      expect(converter.convert(2025, options: yearOption),
          equals("দুই হাজার পঁচিশ"));

      expect(converter.convert(1900, options: yearOptionAD),
          equals("উনিশশ খ্রিস্টাব্দ"));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("উনিশশ নিরানব্বই খ্রিস্টাব্দ"));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("দুই হাজার পঁচিশ খ্রিস্টাব্দ"));

      expect(converter.convert(-1, options: yearOption),
          equals("এক খ্রিস্টপূর্ব"));
      expect(converter.convert(-100, options: yearOption),
          equals("একশ খ্রিস্টপূর্ব"));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("একশ খ্রিস্টপূর্ব"));
      expect(converter.convert(-2025, options: yearOption),
          equals("দুই হাজার পঁচিশ খ্রিস্টপূর্ব"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("দশ লক্ষ খ্রিস্টপূর্ব"));
    });

    test('Currency', () {
      const currencyOption = BnOptions(currency: true);

      expect(
          converter.convert(0, options: currencyOption), equals("শূন্য টাকা"));
      expect(converter.convert(1, options: currencyOption), equals("এক টাকা"));
      expect(
          converter.convert(5, options: currencyOption), equals("পাঁচ টাকা"));
      expect(converter.convert(10, options: currencyOption), equals("দশ টাকা"));
      expect(
          converter.convert(11, options: currencyOption), equals("এগারো টাকা"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("এক টাকা পঞ্চাশ পয়সা"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("একশ তেইশ টাকা পঁয়তাল্লিশ পয়সা"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("এক কোটি টাকা"));
      expect(converter.convert(0.5), equals("শূন্য দশমিক পাঁচ"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("পঞ্চাশ পয়সা"));
      expect(
          converter.convert(0.01, options: currencyOption), equals("এক পয়সা"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("পাঁচ পয়সা"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("এক টাকা এক পয়সা"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("দশ লক্ষ"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("দুইশ কোটি"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(11)),
          equals("ত্রিশ হাজার কোটি"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(13)),
          equals("চল্লিশ লক্ষ কোটি"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(15)),
          equals("পঞ্চাশ কোটি কোটি"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(17)),
          equals("ছয় হাজার কোটি কোটি"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(19)),
          equals("সাত লক্ষ কোটি কোটি"));
      expect(converter.convert(BigInt.from(8) * BigInt.from(10).pow(21)),
          equals("আট কোটি কোটি কোটি"));
      expect(converter.convert(BigInt.from(9) * BigInt.from(10).pow(23)),
          equals("নয়শ কোটি কোটি কোটি"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "আটানব্বই হাজার সাতশ পঁয়ষট্টি কোটি তেতাল্লিশ লক্ষ একুশ হাজার বারো কোটি চৌত্রিশ লক্ষ ছাপ্পান্ন হাজার সাতশ উননব্বই"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              'একশ তেইশ কোটি পঁয়তাল্লিশ লক্ষ সাতষট্টি হাজার আটশ একানব্বই কোটি তেইশ লক্ষ পঁয়তাল্লিশ হাজার ছয়শ আটাত্তর কোটি একানব্বই লক্ষ তেইশ হাজার চারশ ছাপ্পান্ন'));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              'নয়শ নিরানব্বই কোটি নিরানব্বই লক্ষ নিরানব্বই হাজার নয়শ নিরানব্বই কোটি নিরানব্বই লক্ষ নিরানব্বই হাজার নয়শ নিরানব্বই কোটি নিরানব্বই লক্ষ নিরানব্বই হাজার নয়শ নিরানব্বই'));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("এক লক্ষ কোটি বিশ লক্ষ তিন"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("পঞ্চাশ লক্ষ এক হাজার"));
      expect(
          converter.convert(BigInt.parse('1000000001')), equals("একশ কোটি এক"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("একশ কোটি দশ লক্ষ"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("বিশ লক্ষ এক হাজার"));
      expect(converter.convert(BigInt.parse('1000987600003')),
          equals("এক লক্ষ আটানব্বই কোটি ছিয়াত্তর লক্ষ তিন"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("সংখ্যা নয়"));
      expect(converter.convert(double.infinity), equals("অসীম"));
      expect(
          converter.convert(double.negativeInfinity), equals("ঋণাত্মক অসীম"));
      expect(converter.convert(null), equals("সংখ্যা নয়"));
      expect(converter.convert('abc'), equals("সংখ্যা নয়"));
      expect(converter.convert([]), equals("সংখ্যা নয়"));
      expect(converter.convert({}), equals("সংখ্যা নয়"));
      expect(converter.convert(Object()), equals("সংখ্যা নয়"));

      expect(converterWithFallback.convert(double.nan), equals("অবৈধ সংখ্যা"));
      expect(converterWithFallback.convert(double.infinity), equals("অসীম"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("ঋণাত্মক অসীম"));
      expect(converterWithFallback.convert(null), equals("অবৈধ সংখ্যা"));
      expect(converterWithFallback.convert('abc'), equals("অবৈধ সংখ্যা"));
      expect(converterWithFallback.convert([]), equals("অবৈধ সংখ্যা"));
      expect(converterWithFallback.convert({}), equals("অবৈধ সংখ্যা"));
      expect(converterWithFallback.convert(Object()), equals("অবৈধ সংখ্যা"));
      expect(converterWithFallback.convert(123), equals("একশ তেইশ"));
    });
  });
}
