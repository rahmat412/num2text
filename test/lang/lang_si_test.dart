import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Sinhala (SI)', () {
    final converter = Num2Text(initialLang: Lang.SI);
    final converterWithFallback =
        Num2Text(initialLang: Lang.SI, fallbackOnError: "අවලංගු අංකය");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("බිංදුව"));
      expect(converter.convert(1), equals("එක"));
      expect(converter.convert(10), equals("දහය"));
      expect(converter.convert(11), equals("එකොළහ"));
      expect(converter.convert(20), equals("විස්ස"));

      expect(converter.convert(21), equals("විසිඑක"));
      expect(converter.convert(99), equals("අනූනවය"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("එකසියය"));

      expect(converter.convert(101), equals("එකසිය එක"));
      expect(converter.convert(111), equals("එකසිය එකොළහ"));
      expect(converter.convert(200), equals("දෙසියය"));
      expect(converter.convert(999), equals("නවසිය අනූනවය"));
    });

    test('Thousands / Lakhs / Millions', () {
      expect(converter.convert(1000), equals("එක් දහස"));
      expect(converter.convert(1001), equals("එක් දහස් එක"));
      expect(converter.convert(1111), equals("එක් දහස් එකසිය එකොළහ"));
      expect(converter.convert(2000), equals("දෙ දහස"));
      expect(converter.convert(10000), equals("දහ දහස"));
      expect(converter.convert(100000), equals("එක් ලක්ෂය"));
      expect(converter.convert(123456),
          equals("එක් ලක්ෂ විසිතුන දහස් හාරසිය පනස්හය"));
      expect(converter.convert(999999),
          equals("නව ලක්ෂ අනූනවය දහස් නවසිය අනූනවය"));

      expect(converter.convert(1000000), equals("මිලියනය"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("සෘණ එක"));

      expect(converter.convert(-123), equals("සෘණ එකසිය විසිතුන"));
      expect(converter.convert(-1, options: SiOptions(negativePrefix: "අඩු ")),
          equals("අඩු එක"));

      expect(
        converter.convert(-123, options: SiOptions(negativePrefix: "අඩු ")),
        equals("අඩු එකසිය විසිතුන"),
      );
    });

    test('Year Formatting', () {
      const yearOption = SiOptions(format: Format.year);
      const yearOptionAD = SiOptions(format: Format.year, includeAD: true);

      expect(converter.convert(1900, options: yearOption),
          equals("එක් දහස් නවසියය"));
      expect(converter.convert(2000, options: yearOption), equals("දෙ දහස"));
      expect(converter.convert(2024, options: yearOption),
          equals("දෙ දහස් විසිහතර"));
      expect(converter.convert(2024, options: yearOptionAD),
          equals("දෙ දහස් විසිහතර ක්‍රි.ව."));
      expect(converter.convert(-100, options: yearOption),
          equals("එකසියය ක්‍රි.පූ."));
      expect(
          converter.convert(-1, options: yearOption), equals("එක ක්‍රි.පූ."));
      expect(converter.convert(-2000, options: yearOption),
          equals("දෙ දහස ක්‍රි.පූ."));
      expect(converter.convert(-2024, options: yearOption),
          equals("දෙ දහස් විසිහතර ක්‍රි.පූ."));
    });

    test('Currency (LKR)', () {
      const currencyOption = SiOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("රුපියල් බිංදුවයි සත බිංදුවයි"));

      expect(converter.convert(1, options: currencyOption), equals("රුපියලයි"));

      expect(converter.convert(2, options: currencyOption),
          equals("රුපියල් දෙකයි"));
      expect(converter.convert(10, options: currencyOption),
          equals("රුපියල් දහයයි"));

      expect(converter.convert(0.01, options: currencyOption), equals("සතයයි"));

      expect(
          converter.convert(0.02, options: currencyOption), equals("සත දෙකයි"));
      expect(
          converter.convert(0.50, options: currencyOption), equals("සත පනහයි"));

      expect(converter.convert(1.01, options: currencyOption),
          equals("රුපියලයි සතයයි"));
      expect(converter.convert(2.50, options: currencyOption),
          equals("රුපියල් දෙකයි සත පනහයි"));
      expect(converter.convert(10.05, options: currencyOption),
          equals("රුපියල් දහයයි සත පහයි"));

      expect(
        converter.convert(123.45, options: currencyOption),
        equals("රුපියල් එකසිය විසිතුනයි සත හතලිස්පහයි"),
      );
      expect(converter.convert(123.00, options: currencyOption),
          equals("රුපියල් එකසිය විසිතුනයි"));
    });

    test('Decimals', () {
      expect(converter.convert(Decimal.parse('123.456')),
          equals("එකසිය විසිතුන දශම හතර පහ හය"));

      expect(converter.convert(Decimal.parse('1.50')), equals("එක දශම පහ"));
      expect(converter.convert(123.0), equals("එකසිය විසිතුන"));
      expect(
          converter.convert(Decimal.parse('123.0')), equals("එකසිය විසිතුන"));
      expect(
        converter.convert(1.5,
            options: const SiOptions(decimalSeparator: DecimalSeparator.point)),
        equals("එක දශම පහ"),
      );
      expect(
        converter.convert(
          Decimal.parse('0.12'),
          options: const SiOptions(decimalSeparator: DecimalSeparator.point),
        ),
        equals("බිංදුව දශම එක දෙක"),
      );
      expect(
        converter.convert(1.5,
            options: const SiOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("එක කොමා පහ"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("අනන්තය"));
      expect(converter.convert(double.negativeInfinity), equals("සෘණ අනන්තය"));
      expect(converter.convert(double.nan), equals("අංකයක් නොවේ"));
      expect(converter.convert(null), equals("අංකයක් නොවේ"));
      expect(converter.convert('abc'), equals("අංකයක් නොවේ"));

      expect(converterWithFallback.convert(double.infinity), equals("අනන්තය"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("සෘණ අනන්තය"));
      expect(converterWithFallback.convert(double.nan), equals("අවලංගු අංකය"));
      expect(converterWithFallback.convert(null), equals("අවලංගු අංකය"));
      expect(converterWithFallback.convert('abc'), equals("අවලංගු අංකය"));

      expect(converterWithFallback.convert(123), equals("එකසිය විසිතුන"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("මිලියනය"));
      expect(converter.convert(BigInt.from(1000001)), equals("මිලියන එක"));
      expect(converter.convert(BigInt.from(2000000)), equals("මිලියන දෙක"));
      expect(converter.convert(BigInt.from(1000000000)), equals("බිලියනය"));
      expect(
          converter.convert(BigInt.from(1000000000000)), equals("ට්‍රිලියනය"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("ක්වඩ්‍රිලියනය"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("ක්වින්ටිලියනය"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("සෙක්ස්ටිලියනය"));
      expect(converter.convert(BigInt.parse('1000000000000000000000000')),
          equals("සෙප්ටිලියනය"));

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "එකසිය විසිතුන සෙක්ස්ටිලියන හාරසිය පනස්හය ක්වින්ටිලියන හත්සිය අසූනවය ක්වඩ්‍රිලියන එකසිය විසිතුන ට්‍රිලියන හාරසිය පනස්හය බිලියන හත්සිය අසූනවය මිලියන එකසිය විසිතුන දහස් හාරසිය පනස්හය",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "නවසිය අනූනවය සෙක්ස්ටිලියන නවසිය අනූනවය ක්වින්ටිලියන නවසිය අනූනවය ක්වඩ්‍රිලියන නවසිය අනූනවය ට්‍රිලියන නවසිය අනූනවය බිලියන නවසිය අනූනවය මිලියන නවසිය අනූනවය දහස් නවසිය අනූනවය",
        ),
      );
    });
  });
}
