import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Uzbek (UZ)', () {
    final converter = Num2Text(initialLang: Lang.UZ);
    final converterWithFallback =
        Num2Text(initialLang: Lang.UZ, fallbackOnError: "Noto'g'ri Raqam");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("nol"));
      expect(converter.convert(10), equals("oʻn"));
      expect(converter.convert(11), equals("oʻn bir"));
      expect(converter.convert(13), equals("oʻn uch"));
      expect(converter.convert(15), equals("oʻn besh"));
      expect(converter.convert(20), equals("yigirma"));
      expect(converter.convert(27), equals("yigirma yetti"));
      expect(converter.convert(30), equals("oʻttiz"));
      expect(converter.convert(54), equals("ellik toʻrt"));
      expect(converter.convert(68), equals("oltmish sakkiz"));
      expect(converter.convert(99), equals("toʻqson toʻqqiz"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("bir yuz"));
      expect(converter.convert(101), equals("bir yuz bir"));
      expect(converter.convert(105), equals("bir yuz besh"));
      expect(converter.convert(110), equals("bir yuz oʻn"));
      expect(converter.convert(111), equals("bir yuz oʻn bir"));
      expect(converter.convert(123), equals("bir yuz yigirma uch"));
      expect(converter.convert(200), equals("ikki yuz"));
      expect(converter.convert(321), equals("uch yuz yigirma bir"));
      expect(converter.convert(479), equals("toʻrt yuz yetmish toʻqqiz"));
      expect(converter.convert(596), equals("besh yuz toʻqson olti"));
      expect(converter.convert(681), equals("olti yuz sakson bir"));
      expect(converter.convert(999), equals("toʻqqiz yuz toʻqson toʻqqiz"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("bir ming"));
      expect(converter.convert(1001), equals("bir ming bir"));
      expect(converter.convert(1011), equals("bir ming oʻn bir"));
      expect(converter.convert(1110), equals("bir ming bir yuz oʻn"));
      expect(converter.convert(1111), equals("bir ming bir yuz oʻn bir"));
      expect(converter.convert(2000), equals("ikki ming"));
      expect(converter.convert(2468),
          equals("ikki ming toʻrt yuz oltmish sakkiz"));
      expect(
          converter.convert(3579), equals("uch ming besh yuz yetmish toʻqqiz"));
      expect(converter.convert(10000), equals("oʻn ming"));
      expect(converter.convert(10011), equals("oʻn ming oʻn bir"));
      expect(converter.convert(11100), equals("oʻn bir ming bir yuz"));
      expect(converter.convert(12987),
          equals("oʻn ikki ming toʻqqiz yuz sakson yetti"));
      expect(converter.convert(45623),
          equals("qirq besh ming olti yuz yigirma uch"));
      expect(converter.convert(87654),
          equals("sakson yetti ming olti yuz ellik toʻrt"));
      expect(converter.convert(100000), equals("bir yuz ming"));
      expect(converter.convert(123456),
          equals("bir yuz yigirma uch ming toʻrt yuz ellik olti"));
      expect(converter.convert(987654),
          equals("toʻqqiz yuz sakson yetti ming olti yuz ellik toʻrt"));
      expect(
          converter.convert(999999),
          equals(
              "toʻqqiz yuz toʻqson toʻqqiz ming toʻqqiz yuz toʻqson toʻqqiz"));
    });

    test('Negative Numbers', () {
      const negativeOption = UzOptions(negativePrefix: "manfiy");
      expect(converter.convert(-1), equals("minus bir"));
      expect(converter.convert(-123), equals("minus bir yuz yigirma uch"));
      expect(converter.convert(-123.456),
          equals("minus bir yuz yigirma uch nuqta toʻrt besh olti"));
      expect(
          converter.convert(-1, options: negativeOption), equals("manfiy bir"));
      expect(converter.convert(-123, options: negativeOption),
          equals("manfiy bir yuz yigirma uch"));
      expect(
        converter.convert(-123.456, options: negativeOption),
        equals("manfiy bir yuz yigirma uch nuqta toʻrt besh olti"),
      );
    });

    test('Decimals', () {
      const pointOption = UzOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = UzOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = UzOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(123.456),
          equals("bir yuz yigirma uch nuqta toʻrt besh olti"));
      expect(converter.convert(1.5), equals("bir nuqta besh"));
      expect(converter.convert(1.05), equals("bir nuqta nol besh"));
      expect(converter.convert(879.465),
          equals("sakkiz yuz yetmish toʻqqiz nuqta toʻrt olti besh"));
      expect(converter.convert(1.5, options: pointOption),
          equals("bir nuqta besh"));
      expect(converter.convert(1.5, options: commaOption),
          equals("bir vergul besh"));
      expect(converter.convert(1.5, options: periodOption),
          equals("bir nuqta besh"));
    });

    test('Year Formatting', () {
      const yearOption = UzOptions(format: Format.year);
      const yearOptionAD = UzOptions(format: Format.year, includeAD: true);
      expect(converter.convert(123, options: yearOption),
          equals("bir yuz yigirma uch"));
      expect(converter.convert(498, options: yearOption),
          equals("toʻrt yuz toʻqson sakkiz"));
      expect(converter.convert(756, options: yearOption),
          equals("yetti yuz ellik olti"));
      expect(converter.convert(1900, options: yearOption),
          equals("bir ming toʻqqiz yuz"));
      expect(converter.convert(1999, options: yearOption),
          equals("bir ming toʻqqiz yuz toʻqson toʻqqiz"));
      expect(converter.convert(2025, options: yearOption),
          equals("ikki ming yigirma besh"));
      expect(converter.convert(1900, options: yearOptionAD),
          equals("bir ming toʻqqiz yuz milodiy"));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("bir ming toʻqqiz yuz toʻqson toʻqqiz milodiy"));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("ikki ming yigirma besh milodiy"));
      expect(converter.convert(-1, options: yearOption),
          equals("bir miloddan avvalgi"));
      expect(converter.convert(-100, options: yearOption),
          equals("bir yuz miloddan avvalgi"));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("bir yuz miloddan avvalgi"));
      expect(converter.convert(-2025, options: yearOption),
          equals("ikki ming yigirma besh miloddan avvalgi"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("bir million miloddan avvalgi"));
    });

    test('Currency', () {
      const currencyOption = UzOptions(currency: true);
      expect(converter.convert(0, options: currencyOption), equals("nol soʻm"));
      expect(converter.convert(1, options: currencyOption), equals("bir soʻm"));
      expect(
          converter.convert(5, options: currencyOption), equals("besh soʻm"));
      expect(
          converter.convert(10, options: currencyOption), equals("oʻn soʻm"));
      expect(converter.convert(11, options: currencyOption),
          equals("oʻn bir soʻm"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("bir soʻm ellik tiyin"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("bir yuz yigirma uch soʻm qirq besh tiyin"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("oʻn million soʻm"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("ellik tiyin"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("bir tiyin"));
      expect(converter.convert(0.05, options: currencyOption),
          equals("besh tiyin"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("bir soʻm bir tiyin"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("bir million"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("ikki milliard"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("uch trillion"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("toʻrt kvadrillion"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("besh kvintillion"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("olti sekstillion"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("yetti septillion"));
      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("bir trillion ikki million uch"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("besh million bir ming"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("bir milliard bir"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("bir milliard bir million"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("ikki million bir ming"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "bir trillion toʻqqiz yuz sakson yetti million olti yuz ming uch"));
      expect(
          converter.convert(BigInt.parse('9876543210123456789')),
          equals(
              "toʻqqiz kvintillion sakkiz yuz yetmish olti kvadrillion besh yuz qirq uch trillion ikki yuz oʻn milliard bir yuz yigirma uch million toʻrt yuz ellik olti ming yetti yuz sakson toʻqqiz"));
      expect(
          converter.convert(BigInt.parse('123456789123456789123456')),
          equals(
              'bir yuz yigirma uch sekstillion toʻrt yuz ellik olti kvintillion yetti yuz sakson toʻqqiz kvadrillion bir yuz yigirma uch trillion toʻrt yuz ellik olti milliard yetti yuz sakson toʻqqiz million bir yuz yigirma uch ming toʻrt yuz ellik olti'));
      expect(
          converter.convert(BigInt.parse('999999999999999999999999')),
          equals(
              'toʻqqiz yuz toʻqson toʻqqiz sekstillion toʻqqiz yuz toʻqson toʻqqiz kvintillion toʻqqiz yuz toʻqson toʻqqiz kvadrillion toʻqqiz yuz toʻqson toʻqqiz trillion toʻqqiz yuz toʻqson toʻqqiz milliard toʻqqiz yuz toʻqson toʻqqiz million toʻqqiz yuz toʻqson toʻqqiz ming toʻqqiz yuz toʻqson toʻqqiz'));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Raqam Emas"));
      expect(converter.convert(double.infinity), equals("Cheksizlik"));
      expect(converter.convert(double.negativeInfinity),
          equals("Manfiy Cheksizlik"));
      expect(converter.convert(null), equals("Raqam Emas"));
      expect(converter.convert('abc'), equals("Raqam Emas"));
      expect(converter.convert([]), equals("Raqam Emas"));
      expect(converter.convert({}), equals("Raqam Emas"));
      expect(converter.convert(Object()), equals("Raqam Emas"));
      expect(
          converterWithFallback.convert(double.nan), equals("Noto'g'ri Raqam"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Cheksizlik"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Manfiy Cheksizlik"));
      expect(converterWithFallback.convert(null), equals("Noto'g'ri Raqam"));
      expect(converterWithFallback.convert('abc'), equals("Noto'g'ri Raqam"));
      expect(converterWithFallback.convert([]), equals("Noto'g'ri Raqam"));
      expect(converterWithFallback.convert({}), equals("Noto'g'ri Raqam"));
      expect(
          converterWithFallback.convert(Object()), equals("Noto'g'ri Raqam"));
      expect(converterWithFallback.convert(123), equals("bir yuz yigirma uch"));
    });
  });
}
