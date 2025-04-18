import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';
import 'package:decimal/decimal.dart';

void main() {
  group('Num2Text Lao (LO)', () {
    final converter = Num2Text(initialLang: Lang.LO);
    final converterWithFallback =
        Num2Text(initialLang: Lang.LO, fallbackOnError: "ຄ່າບໍ່ຖືກຕ້ອງ");

    test('Basic Numbers', () {
      expect(converter.convert(0), equals("ສູນ"));
      expect(converter.convert(1), equals("ໜຶ່ງ"));
      expect(converter.convert(10), equals("ສິບ"));
      expect(converter.convert(11), equals("ສິບເອັດ"));
      expect(converter.convert(20), equals("ຊາວ"));
      expect(converter.convert(21), equals("ຊາວເອັດ"));
      expect(converter.convert(99), equals("ເກົ້າສິບເກົ້າ"));
    });

    test('Hundreds', () {
      expect(converter.convert(100), equals("ໜຶ່ງຮ້ອຍ"));
      expect(converter.convert(101), equals("ໜຶ່ງຮ້ອຍເອັດ"));
      expect(converter.convert(111), equals("ໜຶ່ງຮ້ອຍສິບເອັດ"));
      expect(converter.convert(200), equals("ສອງຮ້ອຍ"));
      expect(converter.convert(999), equals("ເກົ້າຮ້ອຍເກົ້າສິບເກົ້າ"));
    });

    test('Thousands', () {
      expect(converter.convert(1000), equals("ໜຶ່ງພັນ"));
      expect(converter.convert(1001), equals("ໜຶ່ງພັນເອັດ"));
      expect(converter.convert(1111), equals("ໜຶ່ງພັນໜຶ່ງຮ້ອຍສິບເອັດ"));
      expect(converter.convert(2000), equals("ສອງພັນ"));
      expect(converter.convert(10000), equals("ໜຶ່ງໝື່ນ"));
      expect(converter.convert(100000), equals("ໜຶ່ງແສນ"));
      expect(converter.convert(123456),
          equals("ໜຶ່ງແສນສອງໝື່ນສາມພັນສີ່ຮ້ອຍຫ້າສິບຫົກ"));
      expect(converter.convert(999999),
          equals("ເກົ້າແສນເກົ້າໝື່ນເກົ້າພັນເກົ້າຮ້ອຍເກົ້າສິບເກົ້າ"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("ລົບ ໜຶ່ງ"));
      expect(converter.convert(-123), equals("ລົບ ໜຶ່ງຮ້ອຍຊາວສາມ"));
      expect(converter.convert(-1, options: LoOptions(negativePrefix: "ລົບ")),
          equals("ລົບ ໜຶ່ງ"));
      expect(
        converter.convert(-123, options: LoOptions(negativePrefix: "ລົບ")),
        equals("ລົບ ໜຶ່ງຮ້ອຍຊາວສາມ"),
      );
    });

    test('Year Formatting', () {
      const yearOption = LoOptions(format: Format.year);
      expect(converter.convert(1900, options: yearOption),
          equals("ໜຶ່ງພັນເກົ້າຮ້ອຍ"));
      expect(
          converter.convert(2024, options: yearOption), equals("ສອງພັນຊາວສີ່"));
      expect(
        converter.convert(1900, options: LoOptions(format: Format.year)),
        equals("ໜຶ່ງພັນເກົ້າຮ້ອຍ"),
      );
      expect(
        converter.convert(2024, options: LoOptions(format: Format.year)),
        equals("ສອງພັນຊາວສີ່"),
      );
      expect(
          converter.convert(-100, options: yearOption), equals("ລົບ ໜຶ່ງຮ້ອຍ"));
      expect(converter.convert(-1, options: yearOption), equals("ລົບ ໜຶ່ງ"));
      expect(
        converter.convert(-2024, options: LoOptions(format: Format.year)),
        equals("ລົບ ສອງພັນຊາວສີ່"),
      );
    });

    test('Currency', () {
      const currencyOption = LoOptions(currency: true);
      expect(converter.convert(0, options: currencyOption), equals("ສູນ ກີບ"));
      expect(converter.convert(1, options: currencyOption), equals("ໜຶ່ງ ກີບ"));
      expect(
          converter.convert(1.50, options: currencyOption), equals("ໜຶ່ງ ກີບ"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("ໜຶ່ງຮ້ອຍຊາວສາມ ກີບ"));
    });

    test('Decimals', () {
      expect(converter.convert(Decimal.parse('123.456')),
          equals("ໜຶ່ງຮ້ອຍຊາວສາມ ຈຸດ ສີ່ ຫ້າ ຫົກ"));
      expect(converter.convert(Decimal.parse('1.50')), equals("ໜຶ່ງ ຈຸດ ຫ້າ"));
      expect(converter.convert(123.0), equals("ໜຶ່ງຮ້ອຍຊາວສາມ"));
      expect(
          converter.convert(Decimal.parse('123.0')), equals("ໜຶ່ງຮ້ອຍຊາວສາມ"));
      expect(
        converter.convert(1.5,
            options: const LoOptions(decimalSeparator: DecimalSeparator.point)),
        equals("ໜຶ່ງ ຈຸດ ຫ້າ"),
      );
      expect(
        converter.convert(1.5,
            options: const LoOptions(decimalSeparator: DecimalSeparator.comma)),
        equals("ໜຶ່ງ ຈຸດ ຫ້າ"),
      );
    });

    test('Handles infinity and invalid', () {
      expect(converter.convert(double.infinity), equals("ອະນັນ"));
      expect(converter.convert(double.negativeInfinity), equals("ລົບອະນັນ"));
      expect(converter.convert(double.nan), equals("ບໍ່ແມ່ນຕົວເລກ"));
      expect(converter.convert(null), equals("ບໍ່ແມ່ນຕົວເລກ"));
      expect(converter.convert('abc'), equals("ບໍ່ແມ່ນຕົວເລກ"));

      expect(converterWithFallback.convert(double.infinity), equals("ອະນັນ"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("ລົບອະນັນ"));
      expect(
          converterWithFallback.convert(double.nan), equals("ຄ່າບໍ່ຖືກຕ້ອງ"));
      expect(converterWithFallback.convert(null), equals("ຄ່າບໍ່ຖືກຕ້ອງ"));
      expect(converterWithFallback.convert('abc'), equals("ຄ່າບໍ່ຖືກຕ້ອງ"));
      expect(converterWithFallback.convert(123), equals("ໜຶ່ງຮ້ອຍຊາວສາມ"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(1000000)), equals("ໜຶ່ງລ້ານ"));
      expect(converter.convert(BigInt.from(1000000000)), equals("ໜຶ່ງຕື້"));
      expect(converter.convert(BigInt.from(1000000000000)),
          equals("ໜຶ່ງລ້ານລ້ານ"));
      expect(converter.convert(BigInt.from(1000000000000000)),
          equals("ໜຶ່ງພັນລ້ານລ້ານ"));
      expect(converter.convert(BigInt.from(1000000000000000000)),
          equals("ໜຶ່ງລ້ານລ້ານລ້ານ"));
      expect(
        converter.convert(BigInt.parse('1000000000000000000000')),
        equals("ໜຶ່ງພັນລ້ານລ້ານລ້ານ"),
      );
      expect(
        converter.convert(BigInt.parse('1000000000000000000000000')),
        equals("ໜຶ່ງລ້ານລ້ານລ້ານລ້ານ"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
          "ໜຶ່ງຮ້ອຍຊາວສາມພັນລ້ານລ້ານລ້ານສີ່ຮ້ອຍຫ້າສິບຫົກລ້ານລ້ານລ້ານເຈັດຮ້ອຍແປດສິບເກົ້າພັນລ້ານລ້ານໜຶ່ງຮ້ອຍຊາວສາມລ້ານລ້ານສີ່ຮ້ອຍຫ້າສິບຫົກຕື້ເຈັດຮ້ອຍແປດສິບເກົ້າລ້ານ"
          "ໜຶ່ງແສນສອງໝື່ນສາມພັນສີ່ຮ້ອຍຫ້າສິບຫົກ",
        ),
      );

      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
          "ເກົ້າຮ້ອຍເກົ້າສິບເກົ້າພັນລ້ານລ້ານລ້ານເກົ້າຮ້ອຍເກົ້າສິບເກົ້າລ້ານລ້ານລ້ານເກົ້າຮ້ອຍເກົ້າສິບເກົ້າພັນລ້ານລ້ານເກົ້າຮ້ອຍເກົ້າສິບເກົ້າລ້ານລ້ານເກົ້າຮ້ອຍເກົ້າສິບເກົ້າຕື້ເກົ້າຮ້ອຍເກົ້າສິບເກົ້າລ້ານ"
          "ເກົ້າແສນເກົ້າໝື່ນເກົ້າພັນເກົ້າຮ້ອຍເກົ້າສິບເກົ້າ",
        ),
      );
    });
  });
}
