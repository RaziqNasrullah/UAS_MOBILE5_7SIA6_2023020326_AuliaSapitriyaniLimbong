import 'package:delights/app/models/dashboard_summary.dart';
import 'package:delights/app/models/kategori.dart';
import 'package:delights/app/models/keranjang_item.dart';
import 'package:delights/app/models/menu.dart';
import 'package:delights/app/models/pesanan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Kategori.fromJson', () {
    final k = Kategori.fromJson({'id': '2', 'nama': 'Minuman', 'deskripsi': '', 'jumlah_menu': 5});
    expect(k.id, 2);
    expect(k.nama, 'Minuman');
    expect(k.deskripsi, isNull);
    expect(k.jumlahMenu, 5);
  });

  test('Menu.fromJson toleran terhadap angka berupa String (DECIMAL MySQL)', () {
    final m = Menu.fromJson({
      'id': 1,
      'kategori_id': '1',
      'nama': 'Rice Bowl Ayam Sambal Matah',
      'harga': '32000.00',
      'stok': '0',
      'deskripsi': 'Enak',
      'gambar': 'rice.jpg',
      'level_pedas': 'Pedas',
      'suhu_sajian': 'Panas',
      'estimasi_saji': '15',
      'is_best_seller': '1',
      'nama_kategori': 'Makanan Utama',
      'created_at': '2026-10-14 10:00:00',
    });
    expect(m.harga, 32000);
    expect(m.stok, 0);
    expect(m.isHabis, isTrue);
    expect(m.isBestSeller, isTrue);
    expect(m.estimasiSaji, 15);
    expect(m.namaKategori, 'Makanan Utama');
    expect(m.imageUrl, endsWith('/uploads/rice.jpg'));
    expect(m.createdAt, DateTime(2026, 10, 14, 10));
    expect(m.toJson()['is_best_seller'], isTrue);
  });

  test('KeranjangItem subtotal & batas stok', () {
    final item = KeranjangItem.fromJson({
      'id': 3,
      'menu_id': 7,
      'jumlah': 2,
      'catatan_item': 'less sugar',
      'nama_menu': 'Kopi Susu Gula Aren',
      'harga': 20000.0,
      'stok': 2,
    });
    expect(item.subtotal, 40000);
    expect(item.bisaTambah, isFalse);
    expect(item.bisaKurang, isTrue);
    expect(item.copyWith(hapusCatatan: true).catatanItem, isNull);
  });

  test('Pesanan.fromJson beserta items', () {
    final p = Pesanan.fromJson({
      'id': 9,
      'nomor_pesanan': 'INV-20261014-002',
      'nama_pemesan': 'Aulia',
      'no_hp': '081234567890',
      'tipe_pesanan': 'Makan di Tempat',
      'nomor_meja': '5',
      'alamat': null,
      'subtotal': 64000,
      'biaya_layanan': 2000,
      'ongkir': 0,
      'diskon': 0,
      'total': 66000,
      'status': 'Diproses',
      'tanggal': '2026-10-14 13:05:00',
      'items': [
        {'id': 1, 'menu_id': null, 'nama_menu': 'Menu Lama', 'harga_satuan': '32000.00', 'jumlah': 2, 'subtotal': 64000},
      ],
    });
    expect(p.items, hasLength(1));
    expect(p.items.first.menuId, isNull);
    expect(p.jumlahItem, 2);
    expect(p.bisaDiubah, isTrue);
    expect(p.keteranganTipe, 'Makan di Tempat - Meja 5');
    expect(p.tanggal, DateTime(2026, 10, 14, 13, 5));
  });

  test('DashboardSummary.fromJson', () {
    final s = DashboardSummary.fromJson({
      'total_pesanan': 5,
      'pesanan_per_status': {'Diproses': 1, 'Selesai': 3, 'Dibatalkan': 1},
      'total_pendapatan': 327500.0,
      'porsi_terjual': 18,
      'menu_terlaris': [
        {'nama_menu': 'Kopi Susu Gula Aren', 'total_terjual': '5', 'total_penjualan': '100000'},
      ],
      'pendapatan_7_hari': [
        {'tanggal': '2026-10-08', 'pendapatan': 96000, 'jumlah_pesanan': 1},
      ],
      'penjualan_kategori': [
        {'nama_kategori': 'Minuman', 'total_terjual': 8},
      ],
    });
    expect(s.totalPesanan, 5);
    expect(s.pesananPerStatus['Selesai'], 3);
    expect(s.menuTerlaris.first.totalTerjual, 5);
    expect(s.pendapatan7Hari.first.tanggal, DateTime(2026, 10, 8));
    expect(s.penjualanKategori.first.namaKategori, 'Minuman');
  });
}
