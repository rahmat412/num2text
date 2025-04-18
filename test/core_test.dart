import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Core Functionality', () {
    test('Language Switching', () {
      final converter = Num2Text(initialLang: Lang.EN);
      expect(converter.convert(123), equals('one hundred twenty-three'));
      expect(converter.currentLang, Lang.EN);

      converter.setLang(Lang.VI);
      expect(converter.convert(123), equals('một trăm hai mươi ba'));
      expect(converter.currentLang, Lang.VI);

      converter.setLang(Lang.EN);
      expect(converter.convert(123), equals('one hundred twenty-three'));
      expect(converter.currentLang, Lang.EN);
    });

    test('Error Handling and Fallback', () {
      final converter = Num2Text(fallbackOnError: 'ERROR');
      final Object object = Object();
      expect(converter.convert('abc'), equals('ERROR'));
      expect(converter.convert(null), equals('ERROR'));
      expect(converter.convert(Object()), equals('ERROR'));
      expect(converter.convert(double.infinity), equals('Infinity'));
      expect(converter.convert(double.negativeInfinity),
          equals('Negative Infinity'));

      final converter2 = Num2Text();
      expect(converter2.convert('abc'), equals('Not a Number'));
      expect(converter2.convert(true), equals('Not a Number'));
      expect(converter2.convert(object), equals('Not a Number'));
      expect(converter.convert(double.infinity), equals('Infinity'));
      expect(converter.convert(double.negativeInfinity),
          equals('Negative Infinity'));
    });

    test('Constructor Language Validation', () {
      expect(() => Num2Text(initialLang: Lang.EN), returnsNormally);
      expect(() => Num2Text(initialLang: Lang.VI), returnsNormally);
      // expect(() => Num2Text(initialLang: Lang.MISSING), throwsArgumentError);
    });

    test('setLang Language Validation', () {
      final converter = Num2Text();
      expect(() => converter.setLang(Lang.EN), returnsNormally);
      expect(() => converter.setLang(Lang.VI), returnsNormally);
      // expect(() => converter.setLang(Lang.MISSING), throwsArgumentError);
    });
  });
}
