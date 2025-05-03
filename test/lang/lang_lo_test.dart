import 'package:flutter_test/flutter_test.dart';
import 'package:num2text/num2text.dart';

void main() {
  group('Num2Text Lao (LO)', () {
    final converter = Num2Text(initialLang: Lang.LO);
    final converterWithFallback =
        Num2Text(initialLang: Lang.LO, fallbackOnError: "ຄ່າບໍ່ຖືກຕ້ອງ");

    test('Basic Numbers (0 - 99)', () {
      expect(converter.convert(0), equals("ສູນ"));
      expect(converter.convert(10), equals("ສິບ"));
      expect(converter.convert(11), equals("ສິບເອັດ"));
      expect(converter.convert(13), equals("ສິບສາມ"));
      expect(converter.convert(15), equals("ສິບຫ້າ"));
      expect(converter.convert(20), equals("ຊາວ"));
      expect(converter.convert(27), equals("ຊາວເຈັດ"));
      expect(converter.convert(30), equals("ສາມສິບ"));
      expect(converter.convert(54), equals("ຫ້າສິບສີ່"));
      expect(converter.convert(68), equals("ຫົກສິບແປດ"));
      expect(converter.convert(99), equals("ເກົ້າສິບເກົ້າ"));
    });

    test('Hundreds (100 - 999)', () {
      expect(converter.convert(100), equals("ໜຶ່ງຮ້ອຍ"));
      expect(converter.convert(101), equals("ໜຶ່ງຮ້ອຍເອັດ"));
      expect(converter.convert(105), equals("ໜຶ່ງຮ້ອຍຫ້າ"));
      expect(converter.convert(110), equals("ໜຶ່ງຮ້ອຍສິບ"));
      expect(converter.convert(111), equals("ໜຶ່ງຮ້ອຍສິບເອັດ"));
      expect(converter.convert(123), equals("ໜຶ່ງຮ້ອຍຊາວສາມ"));
      expect(converter.convert(200), equals("ສອງຮ້ອຍ"));
      expect(converter.convert(321), equals("ສາມຮ້ອຍຊາວເອັດ"));
      expect(converter.convert(479), equals("ສີ່ຮ້ອຍເຈັດສິບເກົ້າ"));
      expect(converter.convert(596), equals("ຫ້າຮ້ອຍເກົ້າສິບຫົກ"));
      expect(converter.convert(681), equals("ຫົກຮ້ອຍແປດສິບເອັດ"));
      expect(converter.convert(999), equals("ເກົ້າຮ້ອຍເກົ້າສິບເກົ້າ"));
    });

    test('Thousands (1000 - 999999)', () {
      expect(converter.convert(1000), equals("ໜຶ່ງພັນ"));
      expect(converter.convert(1001), equals("ໜຶ່ງພັນເອັດ"));
      expect(converter.convert(1011), equals("ໜຶ່ງພັນສິບເອັດ"));
      expect(converter.convert(1110), equals("ໜຶ່ງພັນໜຶ່ງຮ້ອຍສິບ"));
      expect(converter.convert(1111), equals("ໜຶ່ງພັນໜຶ່ງຮ້ອຍສິບເອັດ"));
      expect(converter.convert(2000), equals("ສອງພັນ"));
      expect(converter.convert(2468), equals("ສອງພັນສີ່ຮ້ອຍຫົກສິບແປດ"));
      expect(converter.convert(3579), equals("ສາມພັນຫ້າຮ້ອຍເຈັດສິບເກົ້າ"));
      expect(converter.convert(10000), equals("ໜຶ່ງໝື່ນ"));
      expect(converter.convert(10011), equals("ໜຶ່ງໝື່ນສິບເອັດ"));
      expect(converter.convert(11100), equals("ໜຶ່ງໝື່ນໜຶ່ງພັນໜຶ່ງຮ້ອຍ"));
      expect(converter.convert(12987),
          equals("ໜຶ່ງໝື່ນສອງພັນເກົ້າຮ້ອຍແປດສິບເຈັດ"));
      expect(converter.convert(45623), equals("ສີ່ໝື່ນຫ້າພັນຫົກຮ້ອຍຊາວສາມ"));
      expect(
          converter.convert(87654), equals("ແປດໝື່ນເຈັດພັນຫົກຮ້ອຍຫ້າສິບສີ່"));
      expect(converter.convert(100000), equals("ໜຶ່ງແສນ"));
      expect(converter.convert(123456),
          equals("ໜຶ່ງແສນສອງໝື່ນສາມພັນສີ່ຮ້ອຍຫ້າສິບຫົກ"));
      expect(converter.convert(987654),
          equals("ເກົ້າແສນແປດໝື່ນເຈັດພັນຫົກຮ້ອຍຫ້າສິບສີ່"));
      expect(converter.convert(999999),
          equals("ເກົ້າແສນເກົ້າໝື່ນເກົ້າພັນເກົ້າຮ້ອຍເກົ້າສິບເກົ້າ"));
    });

    test('Negative Numbers', () {
      expect(converter.convert(-1), equals("ລົບ ໜຶ່ງ"));
      expect(converter.convert(-123), equals("ລົບ ໜຶ່ງຮ້ອຍຊາວສາມ"));
      expect(converter.convert(-123.456),
          equals("ລົບ ໜຶ່ງຮ້ອຍຊາວສາມ ຈຸດ ສີ່ ຫ້າ ຫົກ"));

      const options1 = LoOptions(negativePrefix: "ติดลบ");
      expect(converter.convert(-1, options: options1), equals("ติดลบ ໜຶ່ງ"));
      expect(converter.convert(-123, options: options1),
          equals("ติดลบ ໜຶ່ງຮ້ອຍຊາວສາມ"));
      expect(converter.convert(-123.456, options: options1),
          equals('ติดลบ ໜຶ່ງຮ້ອຍຊາວສາມ ຈຸດ ສີ່ ຫ້າ ຫົກ'));
    });

    test('Decimals', () {
      expect(
          converter.convert(123.456), equals("ໜຶ່ງຮ້ອຍຊາວສາມ ຈຸດ ສີ່ ຫ້າ ຫົກ"));
      expect(converter.convert("1.5"), equals("ໜຶ່ງ ຈຸດ ຫ້າ"));
      expect(converter.convert(1.05), equals("ໜຶ່ງ ຈຸດ ສູນ ຫ້າ"));
      expect(converter.convert(879.465),
          equals("ແປດຮ້ອຍເຈັດສິບເກົ້າ ຈຸດ ສີ່ ຫົກ ຫ້າ"));
      expect(converter.convert(1.5), equals("ໜຶ່ງ ຈຸດ ຫ້າ"));

      const pointOption = LoOptions(decimalSeparator: DecimalSeparator.point);
      expect(
          converter.convert(1.5, options: pointOption), equals("ໜຶ່ງ ຈຸດ ຫ້າ"));

      const commaOption = LoOptions(decimalSeparator: DecimalSeparator.comma);
      expect(
          converter.convert(1.5, options: commaOption), equals("ໜຶ່ງ ຈຸດ ຫ້າ"));

      const periodOption = LoOptions(decimalSeparator: DecimalSeparator.period);
      expect(converter.convert(1.5, options: periodOption),
          equals("ໜຶ່ງ ຈຸດ ຫ້າ"));
    });

    test('Year Formatting', () {
      const yearOption = LoOptions(format: Format.year);
      expect(converter.convert(123, options: yearOption),
          equals("ໜຶ່ງຮ້ອຍຊາວສາມ"));
      expect(converter.convert(498, options: yearOption),
          equals("ສີ່ຮ້ອຍເກົ້າສິບແປດ"));
      expect(converter.convert(756, options: yearOption),
          equals("ເຈັດຮ້ອຍຫ້າສິບຫົກ"));
      expect(converter.convert(1900, options: yearOption),
          equals("ໜຶ່ງພັນເກົ້າຮ້ອຍ"));
      expect(converter.convert(1999, options: yearOption),
          equals("ໜຶ່ງພັນເກົ້າຮ້ອຍເກົ້າສິບເກົ້າ"));
      expect(
          converter.convert(2025, options: yearOption), equals("ສອງພັນຊາວຫ້າ"));
      expect(converter.convert(-1, options: yearOption), equals("ລົບ ໜຶ່ງ"));
      expect(
          converter.convert(-100, options: yearOption), equals("ລົບ ໜຶ່ງຮ້ອຍ"));
      expect(converter.convert(-2025, options: yearOption),
          equals("ລົບ ສອງພັນຊາວຫ້າ"));
      expect(converter.convert(-1000000, options: yearOption),
          equals("ລົບ ໜຶ່ງລ້ານ"));
    });

    test('Currency', () {
      const currencyOption = LoOptions(currency: true);
      expect(converter.convert(0, options: currencyOption), equals("ສູນ ກີບ"));
      expect(converter.convert(1, options: currencyOption), equals("ໜຶ່ງ ກີບ"));
      expect(converter.convert(5, options: currencyOption), equals("ຫ້າ ກີບ"));
      expect(converter.convert(10, options: currencyOption), equals("ສິບ ກີບ"));
      expect(converter.convert(11, options: currencyOption),
          equals("ສິບເອັດ ກີບ"));
      expect(
          converter.convert(1.50, options: currencyOption), equals("ໜຶ່ງ ກີບ"));
      expect(converter.convert(123.45, options: currencyOption),
          equals("ໜຶ່ງຮ້ອຍຊາວສາມ ກີບ"));
      expect(converter.convert(10000000, options: currencyOption),
          equals("ສິບລ້ານ ກີບ"));
    });

    test('Scale Numbers', () {
      expect(converter.convert(BigInt.from(10).pow(6)), equals("ໜຶ່ງລ້ານ"));
      expect(converter.convert(BigInt.from(2) * BigInt.from(10).pow(9)),
          equals("ສອງຕື້"));
      expect(converter.convert(BigInt.from(3) * BigInt.from(10).pow(12)),
          equals("ສາມລ້ານລ້ານ"));
      expect(converter.convert(BigInt.from(4) * BigInt.from(10).pow(15)),
          equals("ສີ່ພັນລ້ານລ້ານ"));
      expect(converter.convert(BigInt.from(5) * BigInt.from(10).pow(18)),
          equals("ຫ້າລ້ານລ້ານລ້ານ"));
      expect(converter.convert(BigInt.from(6) * BigInt.from(10).pow(21)),
          equals("ຫົກພັນລ້ານລ້ານລ້ານ"));
      expect(converter.convert(BigInt.from(7) * BigInt.from(10).pow(24)),
          equals("ເຈັດລ້ານລ້ານລ້ານລ້ານ"));
      expect(
        converter.convert(BigInt.parse('9876543210123456789')),
        equals(
            "ເກົ້າລ້ານລ້ານລ້ານແປດຮ້ອຍເຈັດສິບຫົກພັນລ້ານລ້ານຫ້າຮ້ອຍສີ່ສິບສາມລ້ານລ້ານສອງຮ້ອຍສິບຕື້ໜຶ່ງຮ້ອຍຊາວສາມລ້ານສີ່ແສນຫ້າໝື່ນຫົກພັນເຈັດຮ້ອຍແປດສິບເກົ້າ"),
      );
      expect(
        converter.convert(BigInt.parse('123456789123456789123456')),
        equals(
            "ໜຶ່ງຮ້ອຍຊາວສາມພັນລ້ານລ້ານລ້ານສີ່ຮ້ອຍຫ້າສິບຫົກລ້ານລ້ານລ້ານເຈັດຮ້ອຍແປດສິບເກົ້າພັນລ້ານລ້ານໜຶ່ງຮ້ອຍຊາວສາມລ້ານລ້ານສີ່ຮ້ອຍຫ້າສິບຫົກຕື້ເຈັດຮ້ອຍແປດສິບເກົ້າລ້ານໜຶ່ງແສນສອງໝື່ນສາມພັນສີ່ຮ້ອຍຫ້າສິບຫົກ"),
      );
      expect(
        converter.convert(BigInt.parse('999999999999999999999999')),
        equals(
            "ເກົ້າຮ້ອຍເກົ້າສິບເກົ້າພັນລ້ານລ້ານລ້ານເກົ້າຮ້ອຍເກົ້າສິບເກົ້າລ້ານລ້ານລ້ານເກົ້າຮ້ອຍເກົ້າສິບເກົ້າພັນລ້ານລ້ານເກົ້າຮ້ອຍເກົ້າສິບເກົ້າລ້ານລ້ານເກົ້າຮ້ອຍເກົ້າສິບເກົ້າຕື້ເກົ້າຮ້ອຍເກົ້າສິບເກົ້າລ້ານເກົ້າແສນເກົ້າໝື່ນເກົ້າພັນເກົ້າຮ້ອຍເກົ້າສິບເກົ້າ"),
      );

      expect(converter.convert(BigInt.parse('1000002000003')),
          equals('ໜຶ່ງລ້ານລ້ານສອງລ້ານສາມ'));
      expect(
          converter.convert(BigInt.parse('5001000')), equals("ຫ້າລ້ານໜຶ່ງພັນ"));
      expect(
          converter.convert(BigInt.parse('1000000001')), equals('ໜຶ່ງຕື້ເອັດ'));
      expect(converter.convert(BigInt.parse('1001000000')),
          equals("ໜຶ່ງຕື້ໜຶ່ງລ້ານ"));
      expect(
          converter.convert(BigInt.parse('2001000')), equals("ສອງລ້ານໜຶ່ງພັນ"));
      expect(converter.convert(BigInt.parse('1000987600003')),
          equals("ໜຶ່ງລ້ານລ້ານເກົ້າຮ້ອຍແປດສິບເຈັດລ້ານຫົກແສນສາມ"));
    });

    test('Infinity And Invalid Input', () {
      expect(converter.convert(double.nan), equals("ບໍ່ແມ່ນຕົວເລກ"));
      expect(converter.convert(double.infinity), equals("ອະສົງໄຂ"));
      expect(converter.convert(double.negativeInfinity), equals("ລົບອະສົງໄຂ"));
      expect(converter.convert(null), equals("ບໍ່ແມ່ນຕົວເລກ"));
      expect(converter.convert('abc'), equals("ບໍ່ແມ່ນຕົວເລກ"));
      expect(converter.convert([]), equals("ບໍ່ແມ່ນຕົວເລກ"));
      expect(converter.convert({}), equals("ບໍ່ແມ່ນຕົວເລກ"));
      expect(converter.convert(Object()), equals("ບໍ່ແມ່ນຕົວເລກ"));

      expect(
          converterWithFallback.convert(double.nan), equals("ຄ່າບໍ່ຖືກຕ້ອງ"));
      expect(converterWithFallback.convert(double.infinity), equals("ອະສົງໄຂ"));
      expect(converterWithFallback.convert(double.negativeInfinity),
          equals("ລົບອະສົງໄຂ"));
      expect(converterWithFallback.convert(null), equals("ຄ່າບໍ່ຖືກຕ້ອງ"));
      expect(converterWithFallback.convert('abc'), equals("ຄ່າບໍ່ຖືກຕ້ອງ"));
      expect(converterWithFallback.convert([]), equals("ຄ່າບໍ່ຖືກຕ້ອງ"));
      expect(converterWithFallback.convert({}), equals("ຄ່າບໍ່ຖືກຕ້ອງ"));
      expect(converterWithFallback.convert(Object()), equals("ຄ່າບໍ່ຖືກຕ້ອງ"));
      expect(converterWithFallback.convert(123), equals("ໜຶ່ງຮ້ອຍຊາວສາມ"));
    });
  });
}
