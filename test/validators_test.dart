import 'package:delights/app/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.namaKategori', () {
    const existing = ['Makanan Utama', 'Minuman', 'Snack', 'Dessert'];

    test('kosong ditolak', () {
      expect(Validators.namaKategori('', existing), 'Nama kategori wajib diisi');
      expect(Validators.namaKategori('   ', existing), 'Nama kategori wajib diisi');
      expect(Validators.namaKategori(null, existing), 'Nama kategori wajib diisi');
    });

    test('duplikat ditolak (case-insensitive & trim)', () {
      expect(Validators.namaKategori('minuman', existing), contains('sudah ada'));
      expect(Validators.namaKategori('  SNACK ', existing), contains('sudah ada'));
    });

    test('nama baru valid', () {
      expect(Validators.namaKategori('Paket Hemat', existing), isNull);
    });

    test('lebih dari 50 karakter ditolak', () {
      expect(Validators.namaKategori('a' * 51, existing), contains('maksimal 50'));
    });
  });

  group('Validators.noHp', () {
    test('valid: diawali 08, 10-13 digit', () {
      expect(Validators.noHp('0812345678'), isNull); // 10 digit
      expect(Validators.noHp('0812345678901'), isNull); // 13 digit
    });

    test('tidak valid', () {
      expect(Validators.noHp(''), 'Nomor HP wajib diisi');
      expect(Validators.noHp('0812-3456-789'), 'Nomor HP hanya boleh berisi angka');
      expect(Validators.noHp('6281234567890'), 'Nomor HP harus diawali 08');
      expect(Validators.noHp('081234567'), 'Nomor HP harus 10-13 digit');
      expect(Validators.noHp('08123456789012'), 'Nomor HP harus 10-13 digit');
    });
  });

  group('Validators menu', () {
    test('harga harus > 0', () {
      expect(Validators.harga(''), 'Harga wajib diisi');
      expect(Validators.harga('abc'), 'Harga harus berupa angka');
      expect(Validators.harga('0'), 'Harga harus lebih dari 0');
      expect(Validators.harga('25000'), isNull);
    });

    test('stok angka bulat >= 0', () {
      expect(Validators.stok(''), 'Stok wajib diisi');
      expect(Validators.stok('2.5'), 'Stok harus berupa angka bulat');
      expect(Validators.stok('-1'), 'Stok tidak boleh negatif');
      expect(Validators.stok('0'), isNull);
    });

    test('estimasi saji > 0', () {
      expect(Validators.estimasiSaji('0'), 'Estimasi saji harus lebih dari 0 menit');
      expect(Validators.estimasiSaji('x'), 'Estimasi saji harus berupa angka (menit)');
      expect(Validators.estimasiSaji('12'), isNull);
    });
  });
}
