import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Sinhala (SI)', () {
    final converter = Num2Text(initialLang: Lang.SI);
    final converterWithFallback =
        Num2Text(initialLang: Lang.SI, fallbackOnError: "අවලංගු අංකය");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("බිංදුව"));
      expect(converter.convert(1), equals("එකයි"));
      expect(converter.convert(5), equals("පහයි"));
      expect(converter.convert(10), equals("දහයයි"));
      expect(converter.convert(11), equals("එකොළහයි"));
      expect(converter.convert(13), equals("දහතුනයි"));
      expect(converter.convert(15), equals("පහළොවයි"));
      expect(converter.convert(19), equals("දහනවයයි"));
      expect(converter.convert(20), equals("විස්සයි"));
      expect(converter.convert(27), equals("විසිහතයි"));
      expect(converter.convert(30), equals("තිහයි"));
      expect(converter.convert(31), equals("තිස්එකයි"));
      expect(converter.convert(40), equals("හතළිහයි"));
      expect(converter.convert(54), equals("පනස්හතරයි"));
      expect(converter.convert(68), equals("හැටඅටයි"));
      expect(converter.convert(70), equals("හැත්තෑවයි"));
      expect(converter.convert(82), equals("අසූදෙකයි"));
      expect(converter.convert(90), equals("අනූවයි"));
      expect(converter.convert(99), equals("අනූනවයයි"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("එකසියයයි"));
      expect(converter.convert(101), equals("එකසිය එකයි"));
      expect(converter.convert(105), equals("එකසිය පහයි"));
      expect(converter.convert(110), equals("එකසිය දහයයි"));
      expect(converter.convert(111), equals("එකසිය එකොළහයි"));
      expect(converter.convert(123), equals("එකසිය විසිතුනයි"));
      expect(converter.convert(200), equals("දෙසියයයි"));
      expect(converter.convert(321), equals("තුන්සිය විසිඑකයි"));
      expect(converter.convert(479), equals("හාරසිය හැත්තෑනවයයි"));
      expect(converter.convert(596), equals("පන්සිය අනූහයයි"));
      expect(converter.convert(681), equals("හයසිය අසූඑකයි"));
      expect(converter.convert(700), equals("හත්සියයයි"));
      expect(converter.convert(850), equals("අටසිය පනහයි"));
      expect(converter.convert(999), equals("නවසිය අනූනවයයි"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("දහස"));
      expect(converter.convert(1001), equals("දහස් එකයි"));
      expect(converter.convert(1011), equals("දහස් එකොළහයි"));
      expect(converter.convert(1110), equals("දහස් එකසිය දහයයි"));
      expect(converter.convert(1111), equals("දහස් එකසිය එකොළහයි"));
      expect(converter.convert(2000), equals("දෙ දහසයි"));
      expect(converter.convert(2468), equals("දෙ දහස් හාරසිය හැටඅටයි"));
      expect(converter.convert(3579), equals("තුන් දහස් පන්සිය හැත්තෑනවයයි"));
      expect(converter.convert(9000), equals("නව දහසයි"));
      expect(converter.convert(9876), equals("නව දහස් අටසිය හැත්තෑහයයි"));
      expect(converter.convert(10000), equals("දහ දහසයි"));
      expect(converter.convert(10011), equals("දහ දහස් එකොළහයි"));
      expect(converter.convert(11100), equals("එකොළොස් දහස් එකසියයයි"));
      expect(converter.convert(12987), equals("දොළොස් දහස් නවසිය අසූහතයි"));
      expect(
          converter.convert(45623), equals("හතලිස්පන් දහස් හයසිය විසිතුනයි"));
      expect(converter.convert(87654), equals("අසූහත දහස් හයසිය පනස්හතරයි"));
      expect(converter.convert(99999), equals("අනූනව දහස් නවසිය අනූනවයයි"));
      expect(converter.convert(100000), equals("ලක්ෂය"));
      expect(converter.convert(100001), equals("ලක්ෂ එකයි"));
      expect(converter.convert(110000), equals("එක් ලක්ෂ දහ දහසයි"));
      expect(converter.convert(123456),
          equals("එක් ලක්ෂ විසිතුන් දහස් හාරසිය පනස්හයයි"));
      expect(converter.convert(500000), equals("ලක්ෂ පහයි"));
      expect(converter.convert(987654),
          equals("නව ලක්ෂ අසූහත දහස් හයසිය පනස්හතරයි"));
      expect(converter.convert(999999),
          equals("නව ලක්ෂ අනූනව දහස් නවසිය අනූනවයයි"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("සෘණ එකයි"));
      expect(converter.convert(-123), equals("සෘණ එකසිය විසිතුනයි"));
      expect(converter.convert(-123.456),
          equals("සෘණ එකසිය විසිතුනයි දශම හතර පහ හය"));
      const options = SiOptions(negativePrefix: "අඩු");
      expect(converter.convert(-1, options: options), equals("අඩු එකයි"));
      expect(converter.convert(-123, options: options),
          equals("අඩු එකසිය විසිතුනයි"));
      expect(
        converter.convert(-123.456, options: options),
        equals("අඩු එකසිය විසිතුනයි දශම හතර පහ හය"),
      );
    });

    test('Decimals', () {
      expect(
          converter.convert(123.456), equals("එකසිය විසිතුනයි දශම හතර පහ හය"));
      expect(converter.convert(1.5), equals("එකයි දශම පහ"));
      expect(converter.convert(1.05), equals("එකයි දශම බිංදුව පහ"));
      expect(converter.convert(879.465),
          equals("අටසිය හැත්තෑනවයයි දශම හතර හය පහ"));
      expect(converter.convert(1.5), equals("එකයි දශම පහ"));
      expect(converter.convert(0.123), equals("බිංදුව දශම එක දෙක තුන"));
      expect(converter.convert(0.001), equals("බිංදුව දශම බිංදුව බිංදුව එක"));

      const pointOption = SiOptions(decimalSeparator: DecimalSeparator.point);
      expect(
          converter.convert(1.5, options: pointOption), equals("එකයි දශම පහ"));
      const commaOption = SiOptions(decimalSeparator: DecimalSeparator.comma);
      expect(
          converter.convert(1.5, options: commaOption), equals("එකයි කොමා පහ"));
      const periodOption = SiOptions(decimalSeparator: DecimalSeparator.period);
      expect(
          converter.convert(1.5, options: periodOption), equals("එකයි දශම පහ"));
    });

    test('Year Formatting', () {
      const yearOption = SiOptions(format: Format.year);
      expect(
          converter.convert(123, options: yearOption), equals("එකසිය විසිතුන"));
      expect(
          converter.convert(498, options: yearOption), equals("හාරසිය අනූඅට"));
      expect(
          converter.convert(756, options: yearOption), equals("හත්සිය පනස්හය"));
      expect(converter.convert(1000, options: yearOption), equals("දහස"));
      expect(converter.convert(1900, options: yearOption),
          equals("එක් දහස් නවසියය"));
      expect(converter.convert(1999, options: yearOption),
          equals("එක් දහස් නවසිය අනූනවය"));
      expect(converter.convert(2000, options: yearOption), equals("දෙ දහස"));
      expect(converter.convert(2025, options: yearOption),
          equals("දෙ දහස් විසිපහ"));

      const yearOptionAD = SiOptions(format: Format.year, includeAD: true);
      expect(converter.convert(1900, options: yearOptionAD),
          equals("එක් දහස් නවසියය ක්‍රි.ව."));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("එක් දහස් නවසිය අනූනවය ක්‍රි.ව."));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("දෙ දහස් විසිපහ ක්‍රි.ව."));
      expect(
          converter.convert(-1, options: yearOption), equals("එක ක්‍රි.පූ."));
      expect(converter.convert(-100, options: yearOption),
          equals("එකසියය ක්‍රි.පූ."));
      expect(converter.convert(-100, options: yearOptionAD),
          equals("එකසියය ක්‍රි.පූ."));
      expect(converter.convert(-1999, options: yearOption),
          equals("එක් දහස් නවසිය අනූනවය ක්‍රි.පූ."));
      expect(converter.convert(-2025, options: yearOption),
          equals("දෙ දහස් විසිපහ ක්‍රි.පූ."));
      expect(converter.convert(-1000000, options: yearOption),
          equals("මිලියනය ක්‍රි.පූ."));
    });

    test('Currency', () {
      const currencyOption = SiOptions(currency: true);
      expect(converter.convert(0, options: currencyOption),
          equals("රුපියල් බිංදුවයි සත බිංදුවයි"));
      expect(converter.convert(1, options: currencyOption), equals("රුපියලයි"));
      expect(converter.convert(2, options: currencyOption),
          equals("රුපියල් දෙකයි"));
      expect(converter.convert(5, options: currencyOption),
          equals("රුපියල් පහයි"));
      expect(converter.convert(10, options: currencyOption),
          equals("රුපියල් දහයයි"));
      expect(converter.convert(11, options: currencyOption),
          equals("රුපියල් එකොළහයි"));
      expect(converter.convert(20, options: currencyOption),
          equals("රුපියල් විස්සයි"));
      expect(converter.convert(100, options: currencyOption),
          equals("රුපියල් එකසියයයි"));
      expect(converter.convert(1000, options: currencyOption),
          equals("රුපියල් දහසයි"));
      expect(converter.convert(1.5, options: currencyOption),
          equals("රුපියලයි සත පනහයි"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("රුපියල් එකසිය විසිතුනයි සත හතලිස්පහයි"));
      expect(converter.convert(100000, options: currencyOption),
          equals("රුපියල් ලක්ෂයයි"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("රුපියල් මිලියන දහයයි"));
      expect(
          converter.convert(0.5, options: currencyOption), equals("සත පනහයි"));
      expect(converter.convert(0.01, options: currencyOption), equals("සතයයි"));
      expect(
          converter.convert(0.02, options: currencyOption), equals("සත දෙකයි"));
      expect(
          converter.convert(0.05, options: currencyOption), equals("සත පහයි"));
      expect(converter.convert(0.11, options: currencyOption),
          equals("සත එකොළහයි"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("රුපියලයි සතයයි"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("රුපියල් දෙකයි සත දෙකයි"));
      expect(converter.convert(5.05, options: currencyOption),
          equals("රුපියල් පහයි සත පහයි"));
      expect(converter.convert(11.11, options: currencyOption),
          equals("රුපියල් එකොළහයි සත එකොළහයි"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("මිලියනය"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(6)),
          equals("මිලියන දෙකයි"));
      expect(converter.convert(BigInt.from(10).pow(9)), equals("බිලියනය"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("බිලියන දෙකයි"));
      expect(converter.convert(BigInt.from(10).pow(12)), equals("ට්‍රිලියනය"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("ට්‍රිලියන තුනයි"));
      expect(
          converter.convert(BigInt.from(10).pow(15)), equals("ක්වඩ්‍රිලියනය"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("ක්වඩ්‍රිලියන හතරයි"));
      expect(
          converter.convert(BigInt.from(10).pow(18)), equals("ක්වින්ටිලියනය"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("ක්වින්ටිලියන පහයි"));
      expect(
          converter.convert(BigInt.from(10).pow(21)), equals("සෙක්ස්ටිලියනය"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("සෙක්ස්ටිලියන හයයි"));
      expect(converter.convert(BigInt.from(10).pow(24)), equals("සෙප්ටිලියනය"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("සෙප්ටිලියන හතයි"));

      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            "ක්වින්ටිලියන නවයයි ක්වඩ්‍රිලියන අටසිය හැත්තෑහයයි ට්‍රිලියන පන්සිය හතලිස්තුනයි බිලියන දෙසිය දහයයි මිලියන එකසිය විසිතුනයි දහස් හාරසිය පනස්හයයි හත්සිය අසූනවයයි"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "සෙක්ස්ටිලියන එකසිය විසිතුනයි ක්වින්ටිලියන හාරසිය පනස්හයයි ක්වඩ්‍රිලියන හත්සිය අසූනවයයි ට්‍රිලියන එකසිය විසිතුනයි බිලියන හාරසිය පනස්හයයි මිලියන හත්සිය අසූනවයයි දහස් එකසිය විසිතුනයි හාරසිය පනස්හයයි"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "සෙක්ස්ටිලියන නවසිය අනූනවයයි ක්වින්ටිලියන නවසිය අනූනවයයි ක්වඩ්‍රිලියන නවසිය අනූනවයයි ට්‍රිලියන නවසිය අනූනවයයි බිලියන නවසිය අනූනවයයි මිලියන නවසිය අනූනවයයි දහස් නවසිය අනූනවයයි නවසිය අනූනවයයි"),
      );

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("ට්‍රිලියනයයි මිලියන දෙකයි තුනයි"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("මිලියන පහයි දහස"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("බිලියනයයි එකයි"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("බිලියනයයි මිලියනයයි"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("මිලියන දෙකයි දහස"));
      expect(converter.convert(BigInt.parse('1000987600003')),
          equals("ට්‍රිලියනයයි මිලියන නවසිය අසූහතයි දහස් හයසියයයි තුනයි"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("අංකයක් නොවේ"));
      expect(converter.convert(double.infinity), equals("අනන්තය"));
      expect(converter.convert(double.negativeInfinity), equals("සෘණ අනන්තය"));
      expect(converter.convert(null), equals("අංකයක් නොවේ"));
      expect(converter.convert('abc'), equals("අංකයක් නොවේ"));
      expect(converter.convert([]), equals("අංකයක් නොවේ"));
      expect(converter.convert({}), equals("අංකයක් නොවේ"));
      expect(converter.convert(Object()), equals("අංකයක් නොවේ"));

      expect(converterWithFallback.convert(double.nan), equals("අවලංගු අංකය"));
      expect(converterWithFallback.convert(double.infinity), equals("අනන්තය"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("සෘණ අනන්තය"));
      expect(converterWithFallback.convert(null), equals("අවලංගු අංකය"));
      expect(converterWithFallback.convert('abc'), equals("අවලංගු අංකය"));
      expect(converterWithFallback.convert([]), equals("අවලංගු අංකය"));
      expect(converterWithFallback.convert({}), equals("අවලංගු අංකය"));
      expect(converterWithFallback.convert(Object()), equals("අවලංගු අංකය"));
      expect(converterWithFallback.convert(123), equals("එකසිය විසිතුනයි"));
    });
  });
}
