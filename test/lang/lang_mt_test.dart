import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Maltese (MT)', () {
    final converter = Num2Text(initialLang: Lang.MT);
    final converterWithFallback =
        Num2Text(initialLang: Lang.MT, fallbackOnError: "Numru Invalidu");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("żero"));
      expect(converter.convert(1), equals("wieħed"));
      expect(converter.convert(10), equals("għaxra"));
      expect(converter.convert(11), equals("ħdax"));
      expect(converter.convert(20), equals("għoxrin"));
      expect(converter.convert(21), equals("wieħed u għoxrin"));
      expect(converter.convert(99), equals("disgħa u disgħin"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("mitt"));
      expect(converter.convert(101), equals("mitt u wieħed"));
      expect(converter.convert(111), equals("mitt u ħdax"));
      expect(converter.convert(200), equals("mitejn"));
      expect(converter.convert(999), equals("disa' mitt u disgħa u disgħin"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("elf"));
      expect(converter.convert(1001), equals("elf u wieħed"));
      expect(converter.convert(1111), equals("elf u mitt u ħdax"));
      expect(converter.convert(2000), equals("żewġt elef"));
      expect(converter.convert(3000), equals("tlitt elef"));
      expect(converter.convert(4000), equals("erbat elef"));
      expect(converter.convert(7000), equals("sebat elef"));
      expect(converter.convert(10000), equals("għaxart elef"));
      expect(converter.convert(11000), equals("ħdax-il elf"));
      expect(converter.convert(100000), equals("mitt elf"));
      expect(
        converter.convert(123456),
        equals("mitt u tlieta u għoxrin elf u erba' mitt u sitta u ħamsin"),
      );
      expect(
        converter.convert(999999),
        equals(
            "disa' mitt u disgħa u disgħin elf u disa' mitt u disgħa u disgħin"),
      );
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("minus wieħed"));
      expect(converter.convert(-123), equals("minus mitt u tlieta u għoxrin"));
      expect(
        converter.convert(-1,
            options: const MtOptions(negativePrefix: "negattiv")),
        equals("negattiv wieħed"),
      );
      expect(
        converter.convert(-123,
            options: const MtOptions(negativePrefix: "negattiv")),
        equals("negattiv mitt u tlieta u għoxrin"),
      );
    });

    test('Year Formatting', () {
      const yearOption = MtOptions(format: Format.year);
      const yearOptionAD = MtOptions(format: Format.year, includeAD: true);

      expect(converter.convert(1900, options: yearOption),
          equals("elf u disa' mitt"));
      expect(converter.convert(2024, options: yearOption),
          equals("żewġt elef u erbgħa u għoxrin"));
      expect(
        converter.convert(2024, options: yearOptionAD),
        equals("żewġt elef u erbgħa u għoxrin WK"),
      );
      expect(converter.convert(-100, options: yearOption), equals("mitt QK"));
      expect(converter.convert(-1, options: yearOption), equals("wieħed QK"));
      expect(
        converter.convert(-2024, options: yearOption),
        equals("żewġt elef u erbgħa u għoxrin QK"),
      );
    });

    test('Currency', () {
      const currencyOption = MtOptions(currency: true);
      const currencyOptionRound = MtOptions(currency: true, round: true);

      expect(
          converter.convert(0, options: currencyOption), equals("żero ewro"));

      expect(
          converter.convert(1, options: currencyOption), equals("ewro wieħed"));

      expect(
        converter.convert(1.50, options: currencyOption),
        equals("ewro wieħed u ħamsin ċenteżmi"),
      );
      expect(
        converter.convert(1.01, options: currencyOption),
        equals("ewro wieħed u ċenteżmu wieħed"),
      );
      expect(
        converter.convert(1.02, options: currencyOption),
        equals("ewro wieħed u żewġ ċenteżmi"),
      );
      expect(
        converter.convert(123.45, options: currencyOption),
        equals("mitt u tlieta u għoxrin ewro u ħamsa u erbgħin ċenteżmi"),
      );

      expect(
          converter.convert(2, options: currencyOption), equals("żewġ ewro"));

      expect(
        converter.convert(123.456, options: currencyOptionRound),
        equals("mitt u tlieta u għoxrin ewro u sitta u erbgħin ċenteżmi"),
      );
      expect(converter.convert(1.999, options: currencyOptionRound),
          equals("żewġ ewro"));
    });

    test('Decimals', () {
      expect(
        converter.convert(Decimal.parse('123.456')),
        equals("mitt u tlieta u għoxrin punt erbgħa ħamsa sitta"),
      );

      expect(converter.convert(Decimal.parse('1.50')),
          equals("wieħed punt ħamsa"));

      expect(converter.convert(Decimal.parse('1.05')),
          equals("wieħed punt żero ħamsa"));

      expect(converter.convert(123.0), equals("mitt u tlieta u għoxrin"));
      expect(converter.convert(Decimal.parse('123.0')),
          equals("mitt u tlieta u għoxrin"));
      expect(
        converter.convert(1.5,
            options: const MtOptions(decimalSeparator: DecimalSeparator.point)),
        equals("wieħed punt ħamsa"),
      );
      expect(
        converter.convert(1.5,
            options:
                const MtOptions(decimalSeparator: DecimalSeparator.period)),
        equals("wieħed punt ħamsa"),
      );
      expect(
        converter.convert(1.5,
            options: const MtOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("wieħed virgola ħamsa"),
      );
      expect(converter.convert(0.5), equals("żero punt ħamsa"));
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("Infinità"));
      expect(converter.convert(double.negativeInfinity),
          equals("Infinità Negattiva"));
      expect(converter.convert(double.nan), equals("Mhux Numru"));
      expect(converter.convert(null), equals("Mhux Numru"));
      expect(converter.convert('abc'), equals("Mhux Numru"));

      expect(
          converterWithFallback.convert(double.infinity), equals("Infinità"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Infinità Negattiva"));
      expect(
          converterWithFallback.convert(double.nan), equals("Numru Invalidu"));
      expect(converterWithFallback.convert(null), equals("Numru Invalidu"));
      expect(converterWithFallback.convert('abc'), equals("Numru Invalidu"));
      expect(converterWithFallback.convert(123),
          equals("mitt u tlieta u għoxrin"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("miljun"));
      expect(converter.convert(BigInt.from(1000000000)), equals("biljun"));
      expect(converter.convert(BigInt.from(1000000000000)), equals("triljun"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("kwadriljun"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("kwintiljun"));
      expect(converter.convert(BigInt.parse('1000000000000000000000')),
          equals("sestiljun"));
      expect(converter.convert(BigInt.parse('1000000000000000000000000')),
          equals("settiljun"));

      expect(converter.convert(BigInt.from(2000000)), equals("żewġ miljuni"));
      expect(converter.convert(BigInt.from(3000000)), equals("tliet miljuni"));
      expect(
          converter.convert(BigInt.from(10000000)), equals("għaxar miljuni"));
      expect(
          converter.convert(BigInt.from(11000000)), equals("ħdax-il miljun"));

      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "mitt u tlieta u għoxrin sestiljun, erba' mitt u sitta u ħamsin kwintiljun, seba' mitt u disgħa u tmenin kwadriljun, mitt u tlieta u għoxrin triljun, erba' mitt u sitta u ħamsin biljun, seba' mitt u disgħa u tmenin miljun u mitt u tlieta u għoxrin elf u erba' mitt u sitta u ħamsin",
        ),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "disa' mitt u disgħa u disgħin sestiljun, disa' mitt u disgħa u disgħin kwintiljun, disa' mitt u disgħa u disgħin kwadriljun, disa' mitt u disgħa u disgħin triljun, disa' mitt u disgħa u disgħin biljun, disa' mitt u disgħa u disgħin miljun u disa' mitt u disgħa u disgħin elf u disa' mitt u disgħa u disgħin",
        ),
      );
      expect(
        converter.convert(BigInt.parse('1001001001')),
        equals("biljun, miljun u elf u wieħed"),
      );
      expect(
        converter.convert(BigInt.parse('2002002')),
        equals("żewġ miljuni u żewġt elef u tnejn"),
      );
      expect(
          converter.convert(BigInt.from(1000001)), equals("miljun u wieħed"));
      expect(converter.convert(BigInt.from(1000100)), equals("miljun u mitt"));
    });
  });
}
