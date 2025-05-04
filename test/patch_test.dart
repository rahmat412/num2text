import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Patch Test', () {
    test('Language Switching', () {
      final converter = Num2Text(initialLang: Lang.VI);
      expect(converter.convert(1001000),
          equals("một triệu không trăm linh một nghìn"));
      expect(converter.convert(1000001000),
          equals("một tỷ không trăm linh một nghìn"));
      expect(converter.convert(1000001001),
          equals("một tỷ không trăm linh một nghìn không trăm linh một"));
      expect(converter.convert(1001000000),
          equals("một tỷ không trăm linh một triệu"));
    });
  });
}
