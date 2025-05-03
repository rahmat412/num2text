import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Yoruba (YO)', () {
    final converter = Num2Text(initialLang: Lang.YO);
    final converterWithFallback =
        Num2Text(initialLang: Lang.YO, fallbackOnError: "Nọ́mbà Tí Kò Tọ́");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("odo"));
      expect(converter.convert(10), equals("ẹ̀wá"));
      expect(converter.convert(11), equals("ọ̀kanlá"));
      expect(converter.convert(13), equals("ẹẹ́tàlá"));
      expect(converter.convert(15), equals("ẹẹ́ẹ̀ẹ́dógún"));
      expect(converter.convert(20), equals("ogun"));
      expect(converter.convert(27), equals("mẹ́tàdínlọ́gbọ̀n"));
      expect(converter.convert(30), equals("ọgbọ̀n"));
      expect(converter.convert(54), equals("ẹ́rìnléláàádọ́ta"));
      expect(converter.convert(68), equals("méjìdínláàádọ́rin"));
      expect(converter.convert(99), equals("ọ́kàndínlọ́gọ́rùn-ún"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("ọgọ́rùn-ún"));
      expect(converter.convert(101), equals("ọgọ́rùn-ún ó lé kan"));
      expect(converter.convert(105), equals("ọgọ́rùn-ún ó lé àrún"));
      expect(converter.convert(110), equals("ọgọ́rùn-ún ó lé mẹ́wàá"));
      expect(converter.convert(111), equals("ọgọ́rùn-ún ó lé mọ́kànlá"));
      expect(converter.convert(123), equals("ọgọ́rùn-ún ó lé mẹ́tàlélógún"));
      expect(converter.convert(200), equals("igba"));
      expect(converter.convert(321), equals("ọ̀ọ́dúnrún ó lé ọ̀kànlélógún"));
      expect(converter.convert(479), equals("irinwó ó lé ọ̀kàndínlọ́gọ́rin"));
      expect(converter.convert(596), equals("ẹgbẹ̀ta ó dín mẹ́rin"));
      expect(converter.convert(681), equals("ẹgbẹ̀ta ó lé ọ̀kànlélọ́gọ́rin"));
      expect(converter.convert(999), equals("ọ̀kándínlẹ́gbẹ̀rún"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("ẹgbẹ̀rún"));
      expect(converter.convert(1001), equals("ẹgbẹ̀rún ó lé kan"));
      expect(converter.convert(1011), equals("ẹgbẹ̀rún ó lé ọ̀kanlá"));
      expect(converter.convert(1110),
          equals("ẹgbẹ̀rún ó lé ọgọ́rùn-ún ó lé mẹ́wàá"));
      expect(converter.convert(1111),
          equals("ẹgbẹ̀rún ó lé ọgọ́rùn-ún ó lé mọ́kànlá"));
      expect(converter.convert(2000), equals("ẹgbàá"));
      expect(converter.convert(2468),
          equals("ẹgbàá ó lé irinwó ó lé méjìdínláàádọ́rin"));
      expect(
          converter.convert(3579),
          equals(
              "ẹgbàá ó lé ẹgbẹ̀rún ó lé ẹẹ́dẹ́gbẹ̀ta ó lé ọ̀kàndínlọ́gọ́rin"));
      expect(converter.convert(10000), equals("ẹgbàárùn-ún"));
      expect(converter.convert(10011), equals("ẹgbàárùn-ún ó lé mọ́kànlá"));
      expect(converter.convert(11100),
          equals("ẹgbàárùn-ún ó lé ẹgbẹ̀rún kan ó lé ọgọ́rùn-ún"));
      expect(converter.convert(12987),
          equals("ẹgbàárùn-ún ó lé ẹgbàá ó lé ẹgbẹ̀rún ó dín ẹẹ́tàlá"));
      expect(converter.convert(45623),
          equals('ẹgbẹ̀rún márùndínláàádọ́ta, ẹgbẹ̀ta ó lé mẹ́tàlélógún'));
      expect(
          converter.convert(87654),
          equals(
              "ẹgbẹ̀rún mẹ́tàdínláàádọ́rùn-ún, ẹgbẹ̀ta ó lé ẹ́rìnléláàádọ́ta"));
      expect(converter.convert(100000), equals("ọ̀kẹ́ márùn-ún"));
      expect(
          converter.convert(123456),
          equals(
              'ẹgbẹ̀rún ọgọ́rùn-ún ó lé mẹ́tàlélógún, irinwó ó lé mẹ́rìndínlọ́gọ́ta'));
      expect(
          converter.convert(987654),
          equals(
              'ẹgbẹ̀rún ẹgbẹ̀rún ó dín ẹẹ́tàlá, ẹgbẹ̀ta ó lé ẹ́rìnléláàádọ́ta'));
      expect(converter.convert(999999),
          equals('ẹgbẹ̀rún ọ̀kándínlẹ́gbẹ̀rún, ọ̀kándínlẹ́gbẹ̀rún'));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("òdì ọ̀kan"));
      expect(
          converter.convert(-123), equals("òdì ọgọ́rùn-ún ó lé mẹ́tàlélógún"));
      expect(
          converter.convert(-123.456),
          equals(
              "òdì ọgọ́rùn-ún ó lé mẹ́tàlélógún ààmì mẹ́rin márùn-ún mẹ́fà"));

      const negativeOption = YoOptions(negativePrefix: "àì");
      expect(
          converter.convert(-1, options: negativeOption), equals("àì ọ̀kan"));
      expect(converter.convert(-123, options: negativeOption),
          equals("àì ọgọ́rùn-ún ó lé mẹ́tàlélógún"));
      expect(converter.convert(-123.456, options: negativeOption),
          equals("àì ọgọ́rùn-ún ó lé mẹ́tàlélógún ààmì mẹ́rin márùn-ún mẹ́fà"));
    });

    test('Decimals', () {
      expect(converter.convert(123.456),
          equals("ọgọ́rùn-ún ó lé mẹ́tàlélógún ààmì mẹ́rin márùn-ún mẹ́fà"));
      expect(converter.convert(1.50), equals("ọ̀kan ààmì márùn-ún"));
      expect(converter.convert(1.05), equals("ọ̀kan ààmì odo márùn-ún"));
      expect(converter.convert(879.465),
          equals("ẹgbẹ̀rin ó lé ọ̀kàndínlọ́gọ́rin ààmì mẹ́rin mẹ́fà márùn-ún"));
      expect(converter.convert(1.5), equals("ọ̀kan ààmì márùn-ún"));

      const pointOption = YoOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = YoOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = YoOptions(decimalSeparator: DecimalSeparator.period);

      expect(converter.convert(1.5, options: pointOption),
          equals("ọ̀kan ààmì márùn-ún"));
      expect(converter.convert(1.5, options: commaOption),
          equals("ọ̀kan kọ́mà márùn-ún"));
      expect(converter.convert(1.5, options: periodOption),
          equals("ọ̀kan ààmì márùn-ún"));
    });

    test('Year Formatting', () {
      const yearOption = YoOptions(format: Format.year);
      expect(converter.convert(123, options: yearOption),
          equals("ọgọ́rùn-ún ó lé mẹ́tàlélógún"));
      expect(converter.convert(498, options: yearOption),
          equals("ẹẹ́dẹ́gbẹ̀ta ó dín méjì"));
      expect(converter.convert(756, options: yearOption),
          equals("ẹgbẹ̀rin ó dín mẹ́rìnlélógójì"));
      expect(converter.convert(1900, options: yearOption),
          equals("ẹgbẹ̀rún ó lé ẹgbẹ̀rún ó dín ọgọ́rùn-ún"));
      expect(converter.convert(1999, options: yearOption),
          equals("ọ̀kàndínlẹ́gbàá"));
      expect(converter.convert(2025, options: yearOption),
          equals("ẹgbàá ó lé mẹ́ẹ̀ẹ́dọ́gbọ̀n"));

      const yearOptionAD = YoOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOptionAD),
          equals("ẹgbẹ̀rún ó lé ẹgbẹ̀rún ó dín ọgọ́rùn-ún"));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("ọ̀kàndínlẹ́gbàá"));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("ẹgbàá ó lé mẹ́ẹ̀ẹ́dọ́gbọ̀n"));

      expect(converter.convert(-1, options: yearOption), equals("ọ̀kan BC"));
      expect(converter.convert(-100, options: yearOption),
          equals("ọgọ́rùn-ún BC"));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("ọgọ́rùn-ún BC"));
      expect(converter.convert(-2025, options: yearOption),
          equals("ẹgbàá ó lé mẹ́ẹ̀ẹ́dọ́gbọ̀n BC"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("mílíọ̀nù kan BC"));
    });

    test('Currency', () {
      const currencyOption = YoOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("odo náírà"));
      expect(
          converter.convert(1, options: currencyOption), equals("náírà kan"));
      expect(converter.convert(5, options: currencyOption),
          equals("náírà márùn-ún"));
      expect(converter.convert(10, options: currencyOption),
          equals("náírà mẹ́wàá"));
      expect(converter.convert(11, options: currencyOption),
          equals("náírà ọ̀kanlá"));
      expect(converter.convert(15, options: currencyOption),
          equals("náírà ẹẹ́ẹ̀ẹ́dógún"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("náírà kan àti kọ́bọ̀ àádọ́ta"));
      expect(
          converter.convert(123.45, options: currencyOption),
          equals(
              "ọgọ́rùn-ún ó lé mẹ́tàlélógún náírà àti kọ́bọ̀ márùndínláàádọ́ta"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("mílíọ̀nù mẹ́wàá náírà"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("kọ́bọ̀ àádọ́ta"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("kọ́bọ̀ kan"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("kọ́bọ̀ márùn-ún"));
      expect(converter.convert(0.10, options: currencyOption),
          equals("kọ́bọ̀ mẹ́wàá"));
      expect(converter.convert(0.11, options: currencyOption),
          equals("kọ́bọ̀ ọ̀kanlá"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("náírà kan àti kọ́bọ̀ kan"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("mílíọ̀nù kan"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("bílíọ̀nù méjì"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("tirílíọ̀nù mẹ́ta"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("kuadirílíọ̀nù mẹ́rin"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("kuintílíọ̀nù márùn-ún"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("sẹkisitílíọ̀nù mẹ́fà"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("sẹpitílíọ̀nù méje"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("tirílíọ̀nù kan, mílíọ̀nù méjì, mẹ́ta"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("mílíọ̀nù márùn-ún, ẹgbẹ̀rún"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("bílíọ̀nù kan, kan"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("bílíọ̀nù kan, mílíọ̀nù"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("mílíọ̀nù méjì, ẹgbẹ̀rún"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "tirílíọ̀nù kan, mílíọ̀nù ẹgbẹ̀rún ó dín ẹẹ́tàlá, ẹgbẹ̀rún ẹgbẹ̀ta, mẹ́ta"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "kuintílíọ̀nù mẹ́sàn-án, kuadirílíọ̀nù ẹgbẹ̀rin ó lé mẹ́rìndínlọ́gọ́rin, tirílíọ̀nù ẹẹ́dẹ́gbẹ̀ta ó lé mẹ́tàlélógójì, bílíọ̀nù igba ó lé mẹ́wàá, mílíọ̀nù ọgọ́rùn-ún ó lé mẹ́tàlélógún, ẹgbẹ̀rún irinwó ó lé mẹ́rìndínlọ́gọ́ta, ẹgbẹ̀rin ó dín ọ̀kanlá"));
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "sẹkisitílíọ̀nù ọgọ́rùn-ún ó lé mẹ́tàlélógún, kuintílíọ̀nù irinwó ó lé mẹ́rìndínlọ́gọ́ta, kuadirílíọ̀nù ẹgbẹ̀rin ó dín ọ̀kanlá, tirílíọ̀nù ọgọ́rùn-ún ó lé mẹ́tàlélógún, bílíọ̀nù irinwó ó lé mẹ́rìndínlọ́gọ́ta, mílíọ̀nù ẹgbẹ̀rin ó dín ọ̀kanlá, ẹgbẹ̀rún ọgọ́rùn-ún ó lé mẹ́tàlélógún, irinwó ó lé mẹ́rìndínlọ́gọ́ta"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            'sẹkisitílíọ̀nù ọ̀kándínlẹ́gbẹ̀rún, kuintílíọ̀nù ọ̀kándínlẹ́gbẹ̀rún, kuadirílíọ̀nù ọ̀kándínlẹ́gbẹ̀rún, tirílíọ̀nù ọ̀kándínlẹ́gbẹ̀rún, bílíọ̀nù ọ̀kándínlẹ́gbẹ̀rún, mílíọ̀nù ọ̀kándínlẹ́gbẹ̀rún, ẹgbẹ̀rún ọ̀kándínlẹ́gbẹ̀rún, ọ̀kándínlẹ́gbẹ̀rún'),
      );
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Kìí ṣe Nọ́mbà"));
      expect(converter.convert(double.infinity), equals("Àìlópin"));
      expect(converter.convert(double.negativeInfinity), equals("Òdì Àìlópin"));
      expect(converter.convert(null), equals("Kìí ṣe Nọ́mbà"));
      expect(converter.convert('abc'), equals("Kìí ṣe Nọ́mbà"));
      expect(converter.convert([]), equals("Kìí ṣe Nọ́mbà"));
      expect(converter.convert({}), equals("Kìí ṣe Nọ́mbà"));
      expect(converter.convert(Object()), equals("Kìí ṣe Nọ́mbà"));

      expect(converterWithFallback.convert(double.nan),
          equals("Nọ́mbà Tí Kò Tọ́"));
      expect(converterWithFallback.convert(double.infinity), equals("Àìlópin"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Òdì Àìlópin"));
      expect(converterWithFallback.convert(null), equals("Nọ́mbà Tí Kò Tọ́"));
      expect(converterWithFallback.convert('abc'), equals("Nọ́mbà Tí Kò Tọ́"));
      expect(converterWithFallback.convert([]), equals("Nọ́mbà Tí Kò Tọ́"));
      expect(converterWithFallback.convert({}), equals("Nọ́mbà Tí Kò Tọ́"));
      expect(
          converterWithFallback.convert(Object()), equals("Nọ́mbà Tí Kò Tọ́"));
      expect(converterWithFallback.convert(123),
          equals("ọgọ́rùn-ún ó lé mẹ́tàlélógún"));
    });
  });
}
