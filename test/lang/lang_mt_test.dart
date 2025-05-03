import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Maltese (MT)', () {
    final converter = Num2Text(initialLang: Lang.MT);
    final converterWithFallback =
        Num2Text(initialLang: Lang.MT, fallbackOnError: "Numru Invalidu");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("żero"));
      expect(converter.convert(10), equals("għaxra"));
      expect(converter.convert(11), equals("ħdax"));
      expect(converter.convert(13), equals("tlettax"));
      expect(converter.convert(15), equals("ħmistax"));
      expect(converter.convert(20), equals("għoxrin"));
      expect(converter.convert(27), equals("sebgħa u għoxrin"));
      expect(converter.convert(30), equals("tletin"));
      expect(converter.convert(54), equals("erbgħa u ħamsin"));
      expect(converter.convert(68), equals("tmienja u sittin"));
      expect(converter.convert(99), equals("disgħa u disgħin"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("mitt"));
      expect(converter.convert(101), equals("mitt u wieħed"));
      expect(converter.convert(105), equals("mitt u ħamsa"));
      expect(converter.convert(110), equals("mitt u għaxra"));
      expect(converter.convert(111), equals("mitt u ħdax"));
      expect(converter.convert(123), equals("mitt u tlieta u għoxrin"));
      expect(converter.convert(200), equals("mitejn"));
      expect(converter.convert(321), equals("tliet mija u wieħed u għoxrin"));
      expect(converter.convert(479), equals("erba' mija u disgħa u sebgħin"));
      expect(converter.convert(596), equals("ħames mija u sitta u disgħin"));
      expect(converter.convert(681), equals("sitt mija u wieħed u tmenin"));
      expect(converter.convert(999), equals("disa' mija u disgħa u disgħin"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("elf"));
      expect(converter.convert(1001), equals("elf u wieħed"));
      expect(converter.convert(1011), equals("elf u ħdax"));
      expect(converter.convert(1110), equals("elf u mitt u għaxra"));
      expect(converter.convert(1111), equals("elf u mitt u ħdax"));
      expect(converter.convert(2000), equals("żewġt elef"));
      expect(converter.convert(2468),
          equals("żewġt elef u erba' mija u tmienja u sittin"));
      expect(converter.convert(3579),
          equals("tlitt elef u ħames mija u disgħa u sebgħin"));
      expect(converter.convert(10000), equals("għaxart elef"));
      expect(converter.convert(10011), equals("għaxart elef u ħdax"));
      expect(converter.convert(11100), equals("ħdax-il elf u mitt"));
      expect(converter.convert(12987),
          equals("tnax-il elf u disa' mija u sebgħa u tmenin"));
      expect(converter.convert(45623),
          equals("ħamsa u erbgħin elf u sitt mija u tlieta u għoxrin"));
      expect(converter.convert(87654),
          equals("sebgħa u tmenin elf u sitt mija u erbgħa u ħamsin"));
      expect(converter.convert(100000), equals("mitt elf"));
      expect(converter.convert(123456),
          equals("mitt u tlieta u għoxrin elf u erba' mija u sitta u ħamsin"));
      expect(
          converter.convert(987654),
          equals(
              "disa' mija u sebgħa u tmenin elf u sitt mija u erbgħa u ħamsin"));
      expect(
          converter.convert(999999),
          equals(
              "disa' mija u disgħa u disgħin elf u disa' mija u disgħa u disgħin"));
    });

    test('Negative Numbers', () {
      const negOption = MtOptions(negativePrefix: "negattiv");
      expect(converter.convert(-1), equals("minus wieħed"));
      expect(converter.convert(-123), equals("minus mitt u tlieta u għoxrin"));
      expect(converter.convert(-123.456),
          equals("minus mitt u tlieta u għoxrin punt erbgħa ħamsa sitta"));
      expect(
          converter.convert(-1, options: negOption), equals("negattiv wieħed"));
      expect(converter.convert(-123, options: negOption),
          equals("negattiv mitt u tlieta u għoxrin"));
      expect(converter.convert(-123.456, options: negOption),
          equals("negattiv mitt u tlieta u għoxrin punt erbgħa ħamsa sitta"));
    });

    test('Decimals', () {
      const pointOption = MtOptions(decimalSeparator: DecimalSeparator.point);
      const commaOption = MtOptions(decimalSeparator: DecimalSeparator.comma);
      const periodOption = MtOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(123.456),
          equals("mitt u tlieta u għoxrin punt erbgħa ħamsa sitta"));
      expect(converter.convert(1.5), equals("wieħed punt ħamsa"));
      expect(converter.convert(1.05), equals("wieħed punt żero ħamsa"));
      expect(converter.convert(879.465),
          equals("tmien mija u disgħa u sebgħin punt erbgħa sitta ħamsa"));
      expect(converter.convert(1.5, options: pointOption),
          equals("wieħed punt ħamsa"));
      expect(converter.convert(1.5, options: commaOption),
          equals("wieħed virgola ħamsa"));
      expect(converter.convert(1.5, options: periodOption),
          equals("wieħed punt ħamsa"));
    });

    test('Year Formatting', () {
      const yearOption = MtOptions(format: Format.year);
      const yearOptionAD = MtOptions(format: Format.year, includeAD: true);
      expect(converter.convert(123, options: yearOption),
          equals("mitt u tlieta u għoxrin"));
      expect(converter.convert(498, options: yearOption),
          equals("erba' mija u tmienja u disgħin"));
      expect(converter.convert(756, options: yearOption),
          equals("seba' mija u sitta u ħamsin"));
      expect(converter.convert(1900, options: yearOption),
          equals("elf u disa' mitt"));
      expect(converter.convert(1999, options: yearOption),
          equals("elf u disa' mija u disgħa u disgħin"));
      expect(converter.convert(2025, options: yearOption),
          equals("żewġt elef u ħamsa u għoxrin"));
      expect(converter.convert(1900, options: yearOptionAD),
          equals("elf u disa' mitt WK"));
      expect(converter.convert(1999, options: yearOptionAD),
          equals("elf u disa' mija u disgħa u disgħin WK"));
      expect(converter.convert(2025, options: yearOptionAD),
          equals("żewġt elef u ħamsa u għoxrin WK"));
      expect(converter.convert(-1, options: yearOption), equals("wieħed QK"));
      expect(converter.convert(-100, options: yearOption), equals("mitt QK"));
      expect(converter.convert(-100, options: yearOptionAD), equals("mitt QK"));
      expect(converter.convert(-2025, options: yearOption),
          equals("żewġt elef u ħamsa u għoxrin QK"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("miljun QK"));
    });

    test('Currency', () {
      const currencyOption = MtOptions(currency: true);
      expect(
          converter.convert(0, options: currencyOption), equals("żero ewro"));
      expect(
          converter.convert(1, options: currencyOption), equals("ewro wieħed"));
      expect(
          converter.convert(2, options: currencyOption), equals("żewġ ewro"));
      expect(
          converter.convert(3, options: currencyOption), equals("tliet ewro"));
      expect(
          converter.convert(5, options: currencyOption), equals("ħames ewro"));
      expect(converter.convert(10, options: currencyOption),
          equals("għaxar ewro"));
      expect(converter.convert(11, options: currencyOption),
          equals("ħdax-il ewro"));
      expect(converter.convert(1.01, options: currencyOption),
          equals("ewro wieħed u ċenteżmu wieħed"));
      expect(converter.convert(2.02, options: currencyOption),
          equals("żewġ ewro u żewġ ċenteżmi"));
      expect(converter.convert(3.10, options: currencyOption),
          equals("tliet ewro u għaxar ċenteżmi"));
      expect(converter.convert(4.11, options: currencyOption),
          equals("erba' ewro u ħdax-il ċenteżmu"));
      expect(converter.convert(1.50, options: currencyOption),
          equals("ewro wieħed u ħamsin ċenteżmi"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("mitt u tlieta u għoxrin ewro u ħamsa u erbgħin ċenteżmi"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("għaxar miljuni ewro"));
      expect(converter.convert(0.01, options: currencyOption),
          equals("ċenteżmu wieħed"));
      expect(converter.convert(0.5), equals("żero punt ħamsa"));
      expect(converter.convert(0.5, options: currencyOption),
          equals("ħamsin ċenteżmi"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("miljun"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("żewġ biljuni"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("tliet triljuni"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("erba' kwadriljuni"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("ħames kwintiljuni"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("sitt sestiljuni"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("seba' settiljuni"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            "disa' kwintiljuni tmien mija u sitta u sebgħin kwadriljun ħames mija u tlieta u erbgħin triljun mitejn u għaxra biljun mitt u tlieta u għoxrin miljun u erba' mija u sitta u ħamsin elf u seba' mija u disgħa u tmenin"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "mitt u tlieta u għoxrin sestiljun erba' mija u sitta u ħamsin kwintiljun seba' mija u disgħa u tmenin kwadriljun mitt u tlieta u għoxrin triljun erba' mija u sitta u ħamsin biljun seba' mija u disgħa u tmenin miljun u mitt u tlieta u għoxrin elf u erba' mija u sitta u ħamsin"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "disa' mija u disgħa u disgħin sestiljun disa' mija u disgħa u disgħin kwintiljun disa' mija u disgħa u disgħin kwadriljun disa' mija u disgħa u disgħin triljun disa' mija u disgħa u disgħin biljun disa' mija u disgħa u disgħin miljun u disa' mija u disgħa u disgħin elf u disa' mija u disgħa u disgħin"),
      );

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals("triljun żewġ miljuni u tlieta"));
      expect(converter.convert(BigInt.parse('5001000')),
          equals("ħames miljuni u elf"));
      expect(converter.convert(BigInt.parse('1000000001')),
          equals("biljun u wieħed"));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("biljun u miljun"));
      expect(converter.convert(BigInt.parse('2001000')),
          equals("żewġ miljuni u elf"));
      expect(
          converter.convert(BigInt.parse('1000987600003')),
          equals(
              "triljun disa' mija u sebgħa u tmenin miljun u sitt mitt elf u tlieta"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("Mhux Numru"));
      expect(converter.convert(double.infinity), equals("Infinità"));
      expect(converter.convert(double.negativeInfinity),
          equals("Infinità Negattiva"));
      expect(converter.convert(null), equals("Mhux Numru"));
      expect(converter.convert('abc'), equals("Mhux Numru"));
      expect(converter.convert([]), equals("Mhux Numru"));
      expect(converter.convert({}), equals("Mhux Numru"));
      expect(converter.convert(Object()), equals("Mhux Numru"));

      expect(
          converterWithFallback.convert(double.nan), equals("Numru Invalidu"));
      expect(
          converterWithFallback.convert(double.infinity), equals("Infinità"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("Infinità Negattiva"));
      expect(converterWithFallback.convert(null), equals("Numru Invalidu"));
      expect(converterWithFallback.convert('abc'), equals("Numru Invalidu"));
      expect(converterWithFallback.convert([]), equals("Numru Invalidu"));
      expect(converterWithFallback.convert({}), equals("Numru Invalidu"));
      expect(converterWithFallback.convert(Object()), equals("Numru Invalidu"));
      expect(converterWithFallback.convert(123),
          equals("mitt u tlieta u għoxrin"));
    });
  });
}
