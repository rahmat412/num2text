import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Yoruba (YO)', () {
    final converter = Num2Text(initialLang: Lang.YO);
    final converterWithFallback =
        Num2Text(initialLang: Lang.YO, fallbackOnError: "Nọmba ti ko tọ");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("odo"));
      expect(converter.convert(1), equals("ookan"));
      expect(converter.convert(5), equals("àrún"));
      expect(converter.convert(10), equals("ẹ̀wá"));
      expect(converter.convert(11), equals("ọ̀kanlá"));
      expect(converter.convert(20), equals("ogun"));
      expect(converter.convert(21), equals("ọ̀kànlélógún"));
      expect(converter.convert(99), equals("ọ́kàndínlọ́gọ́rùn-ún"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("ọgọ́rùn-ún"));
      expect(converter.convert(101), equals("ọgọ́rùn-ún ó lé kan"));
      expect(converter.convert(111), equals("ọgọ́rùn-ún ó lé mọ́kànlá"));
      expect(converter.convert(200), equals("igba"));
      expect(converter.convert(999), equals("ẹgbẹ̀rún ó dín kan"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("ẹgbẹ̀rún"));
      expect(converter.convert(1001), equals("ẹgbẹ̀rún ó lé kan"));
      expect(converter.convert(1111),
          equals("ẹgbẹ̀rún ó lé ọgọ́rùn-ún ó lé mọ́kànlá"));
      expect(converter.convert(2000), equals("ẹgbàá"));
      expect(converter.convert(10000), equals("ẹgbàárùn-ún"));
      expect(converter.convert(100000), equals("ẹgbàáàádọ́ta"));
      expect(
        converter.convert(123456),
        equals("ọ̀kẹ́ mẹ́fà ẹgbẹ̀dógún irinwó ó lé mẹ́rìndínlọ́gọ́ta"),
      );

      expect(converter.convert(999999),
          equals("ọ̀kándínlẹ́gbẹ̀rún ẹgbẹ̀rún, ọ̀kándínlẹ́gbẹ̀rún"));
    });
    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("òdì ọ̀kan"));

      expect(
          converter.convert(-123), equals("òdì ọgọ́rùn-ún ó lé mẹ́tàlélógún"));
      expect(converter.convert(-1, options: YoOptions(negativePrefix: "àì")),
          equals("àì ọ̀kan"));
      expect(
        converter.convert(-123, options: YoOptions(negativePrefix: "àì")),
        equals("àì ọgọ́rùn-ún ó lé mẹ́tàlélógún"),
      );
    });

    test('Currency', () {
      const currencyOption = YoOptions(currency: true);
      expect(converter.convert(1.01, options: currencyOption),
          equals("náírà kan àti kọ́bọ̀ kan"));
      expect(
        converter.convert(2.50, options: currencyOption),
        equals("náírà méjì àti àádọ́ta kọ́bọ̀"),
      );

      expect(
        converter.convert(123.45, options: currencyOption),
        equals(
            "ọgọ́rùn-ún ó lé mẹ́tàlélógún náírà àti márùndínláàádọ́ta kọ́bọ̀"),
      );
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("ọgọ́rùn-ún ó lé mẹ́tàlélógún aàmì mẹ́rin márùn-ún mẹ́fà"),
      );

      expect(converter.convert(Decimal.parse('1.50')),
          equals("ọ̀kan aàmì márùn-ún"));

      expect(converter.convert(123.0), equals("ọgọ́rùn-ún ó lé mẹ́tàlélógún"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("ọgọ́rùn-ún ó lé mẹ́tàlélógún"));

      expect(
        converter.convert(1.5,
            options: const YoOptions(decimalSeparator: DecimalSeparator.point)),
        equals("ọ̀kan aàmì márùn-ún"),
      );
      expect(
        converter.convert(1.5,
            options: const YoOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("ọ̀kan kọ́mà márùn-ún"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Àìlópin"));
      expect(converter.convert(double.negativeInfinity), equals("Òdì Àìlópin"));
      expect(converter.convert(double.nan), equals("Kìí ṣe Nọ́mbà"));
      expect(converter.convert(null), equals("Kìí ṣe Nọ́mbà"));
      expect(converter.convert('abc'), equals("Kìí ṣe Nọ́mbà"));

      expect(converterWithFallback.convert(double.infinity), equals("Àìlópin"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Òdì Àìlópin"));
      expect(
          converterWithFallback.convert(double.nan), equals("Nọmba ti ko tọ"));
      expect(converterWithFallback.convert(null), equals("Nọmba ti ko tọ"));
      expect(converterWithFallback.convert('abc'), equals("Nọmba ti ko tọ"));

      expect(converterWithFallback.convert(123),
          equals("ọgọ́rùn-ún ó lé mẹ́tàlélógún"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("mílíọ̀nù kan"));
      expect(
          converter.convert(BigInt.from(1000000000)), equals("bílíọ̀nù kan"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("tirílíọ̀nù kan"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("kuadirílíọ̀nù kan"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("kuintílíọ̀nù kan"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000')),
        equals("sẹkisitílíọ̀nù kan"),
      );
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("sẹpitílíọ̀nù kan"),
      );

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "ọgọ́rùn-ún ó lé mẹ́tàlélógún sẹkisitílíọ̀nù, irinwó ó lé mẹ́rìndínlọ́gọ́ta kuintílíọ̀nù, ẹgbẹ̀rin ó dín mọ́kànlá kuadirílíọ̀nù, ọgọ́rùn-ún ó lé mẹ́tàlélógún tirílíọ̀nù, irinwó ó lé mẹ́rìndínlọ́gọ́ta bílíọ̀nù, ẹgbẹ̀rin ó dín mọ́kànlá mílíọ̀nù, ọgọ́rùn-ún ó lé mẹ́tàlélógún ẹgbẹ̀rún, irinwó ó lé mẹ́rìndínlọ́gọ́ta",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          'ọ̀kándínlẹ́gbẹ̀rún sẹkisitílíọ̀nù, ọ̀kándínlẹ́gbẹ̀rún kuintílíọ̀nù, ọ̀kándínlẹ́gbẹ̀rún kuadirílíọ̀nù, ọ̀kándínlẹ́gbẹ̀rún tirílíọ̀nù, ọ̀kándínlẹ́gbẹ̀rún bílíọ̀nù, ọ̀kándínlẹ́gbẹ̀rún mílíọ̀nù, ọ̀kándínlẹ́gbẹ̀rún ẹgbẹ̀rún, ọ̀kándínlẹ́gbẹ̀rún',
        ),
      );
    });

    test('Year Formatting', () {
      const yearOption = YoOptions(format: Format.year);

      expect(
        converter.convert(1900, options: yearOption),
        equals("ẹgbẹ̀rún kan ó lé ọgọ́rùn-ún mẹ́sàn-án"),
      );
      expect(converter.convert(2024, options: yearOption),
          equals("ẹgbàá ó lé mẹ́rìnlélógún"));
      expect(
        converter.convert(1900, options: YoOptions(format: Format.year)),
        equals("ẹgbẹ̀rún kan ó lé ọgọ́rùn-ún mẹ́sàn-án"),
      );
      expect(
        converter.convert(2024, options: YoOptions(format: Format.year)),
        equals("ẹgbàá ó lé mẹ́rìnlélógún"),
      );
      expect(converter.convert(-100, options: yearOption),
          equals("ọgọ́rùn-ún BC"));
      expect(converter.convert(-1, options: yearOption), equals("ọ̀kan BC"));
      expect(
        converter.convert(-2024, options: YoOptions(format: Format.year)),
        equals("ẹgbàá ó lé mẹ́rìnlélógún BC"),
      );
    });
  });
}
