// ignore_for_file: avoid_print

import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

/// Demonstrates basic usage of the num2text library.
void main() {
  // Create a converter instance
  final num2text = Num2Text(); // Defaults to English

  print('--- English Examples (Lang.EN) ---');
  print('123: ${num2text.convert(123)}');
  print('1001: ${num2text.convert(1001)}');
  print('-45: ${num2text.convert(-45)}');
  print('123.45: ${num2text.convert(123.45)}');
  print('Decimal 1.50: ${num2text.convert(Decimal.parse("1.50"))}');
  print('BigInt 1,000,000: ${num2text.convert(BigInt.parse("1000000"))}');

  print('\n--- English Options ---');
  print(
    '123 (with and): ${num2text.convert(123, options: const EnOptions(includeAnd: true))}',
  );
  print(
    '2024 (year): ${num2text.convert(2024, options: const EnOptions(format: Format.year))}',
  );
  print(
    '1900 (year, AD): ${num2text.convert(1900, options: const EnOptions(format: Format.year, includeAD: true))}',
  );
  print(
    '-50 (year): ${num2text.convert(-50, options: const EnOptions(format: Format.year))}',
  );
  print(
    '99.99 (USD): ${num2text.convert(99.99, options: const EnOptions(currency: true))}',
  ); // Default USD
  print(
    '1.01 (GBP): ${num2text.convert(1.01, options: const EnOptions(currency: true, currencyInfo: CurrencyInfo.gbp, includeAnd: true))}',
  );

  print('\n--- Vietnamese Examples (Lang.VI) ---');
  num2text.setLang(Lang.VI);
  print('987: ${num2text.convert(987)}');
  print(
    '105 (useLe=true): ${num2text.convert(105, options: const ViOptions(useLe: true))}',
  );
  print(
    '25000.5 (VND): ${num2text.convert(25000.5, options: const ViOptions(currency: true))}',
  ); // Subunit ignored for VND
  print(
    '2024 (year): ${num2text.convert(2024, options: const ViOptions(format: Format.year))}',
  );

  print('\n--- Spanish Examples (Lang.ES) ---');
  num2text.setLang(Lang.ES);
  print('38: ${num2text.convert(38)}');
  print(
    '1001: ${num2text.convert(1001)}',
  ); // Note: 'mil uno' vs 'un mil' variations exist
  print(
    '15.50 (EUR): ${num2text.convert(15.50, options: const EsOptions(currency: true, currencyInfo: CurrencyInfo.eurEs))}',
  );

  print('\n--- Polish Examples (Lang.PL) ---');
  num2text.setLang(Lang.PL);
  print(
    '5 (PLN): ${num2text.convert(5, options: const PlOptions(currency: true))}',
  ); // Uses PLN default
  print(
    '2 (PLN): ${num2text.convert(2, options: const PlOptions(currency: true))}',
  );
  print(
    '123.45 (PLN): ${num2text.convert(123.45, options: const PlOptions(currency: true))}',
  );

  print('\n--- Russian Examples (Lang.RU) ---');
  num2text.setLang(Lang.RU);
  print(
    '1 (RUB): ${num2text.convert(1, options: const RuOptions(currency: true))}',
  ); // Uses RUB default
  print(
    '2 (RUB): ${num2text.convert(2, options: const RuOptions(currency: true))}',
  );
  print(
    '5 (RUB): ${num2text.convert(5, options: const RuOptions(currency: true))}',
  );
  print(
    '12.34 (RUB): ${num2text.convert(12.34, options: const RuOptions(currency: true))}',
  );
}
