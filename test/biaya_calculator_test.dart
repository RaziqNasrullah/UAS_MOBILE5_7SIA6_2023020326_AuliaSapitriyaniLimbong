import 'package:delights/app/utils/biaya_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BiayaCalculator', () {
    test('Makan di Tempat < 100rb: tanpa ongkir & tanpa diskon', () {
      final r = BiayaCalculator.hitung(94000, TipePesanan.makanDiTempat);
      expect(r.biayaLayanan, 2000);
      expect(r.ongkir, 0);
      expect(r.diskon, 0);
      expect(r.total, 96000);
    });

    test('Bawa Pulang tanpa ongkir', () {
      final r = BiayaCalculator.hitung(40000, TipePesanan.bawaPulang);
      expect(r.ongkir, 0);
      expect(r.total, 42000);
    });

    test('Diantar >= 100rb: ongkir 8rb & diskon 10%', () {
      final r = BiayaCalculator.hitung(155000, TipePesanan.diantar);
      expect(r.ongkir, 8000);
      expect(r.diskon, 15500);
      expect(r.total, 155000 + 2000 + 8000 - 15500);
    });

    test('tepat 100.000 mendapat diskon', () {
      final r = BiayaCalculator.hitung(100000, TipePesanan.bawaPulang);
      expect(r.diskon, 10000);
      expect(r.total, 92000);
    });

    test('99.999 belum mendapat diskon', () {
      expect(BiayaCalculator.hitung(99999, TipePesanan.bawaPulang).diskon, 0);
      expect(BiayaCalculator.kurangUntukDiskon(99999), 1);
      expect(BiayaCalculator.kurangUntukDiskon(120000), 0);
    });

    test('keranjang kosong total 0', () {
      expect(BiayaCalculator.hitung(0, TipePesanan.diantar).total, 0);
    });
  });
}
