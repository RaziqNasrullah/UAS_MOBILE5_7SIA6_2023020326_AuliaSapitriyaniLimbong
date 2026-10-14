import 'dart:convert';

import 'package:delights/app/models/pesanan.dart';
import 'package:delights/app/utils/formatter.dart';
import 'package:delights/app/utils/pdf_generator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  final pesanan = Pesanan.fromJson({
    'id': 1,
    'nomor_pesanan': 'INV-20261014-001',
    'nama_pemesan': 'Aulia \u{1F600}', // emoji harus dibuang
    'no_hp': '081234567890',
    'tipe_pesanan': 'Diantar',
    'alamat': 'Jl. Gatot Subroto — Medan',
    'catatan': '“Tolong” cepat',
    'subtotal': 155000,
    'biaya_layanan': 2000,
    'ongkir': 8000,
    'diskon': 15500,
    'total': 149500,
    'status': 'Diproses',
    'tanggal': '2026-10-14 13:05:00',
    'items': [
      {'id': 1, 'menu_id': 4, 'nama_menu': 'Chicken Katsu Curry Rice', 'harga_satuan': 35000, 'jumlah': 2, 'subtotal': 70000},
      {
        'id': 2,
        'menu_id': 7,
        'nama_menu': 'Kopi Susu Gula Aren',
        'harga_satuan': 20000,
        'jumlah': 3,
        'catatan_item': 'Less ice – no sugar',
        'subtotal': 60000,
      },
      {'id': 3, 'menu_id': 13, 'nama_menu': 'Dimsum Ayam Udang (4 pcs)', 'harga_satuan': 25000, 'jumlah': 1, 'subtotal': 25000},
    ],
  });

  test('latin1Safe mengganti tanda baca & membuang emoji', () {
    expect(Formatter.latin1Safe('A — B ‘x’ \u{1F600}'), "A - B 'x' ");
    expect(Formatter.latin1Safe('Café'), 'Café'); // Latin-1 tetap
  });

  test('generate struk PDF valid', () async {
    final bytes = await StrukPdfGenerator.generate(pesanan);
    expect(bytes.length, greaterThan(1000));
    expect(latin1.decode(bytes.sublist(0, 5)), '%PDF-');
    expect(StrukPdfGenerator.namaFile(pesanan), 'Struk_INV-20261014-001.pdf');
  });

  test('Formatter rupiah & sapaan', () {
    expect(Formatter.rupiah(149500), 'Rp149.500');
    expect(Formatter.sapaan(DateTime(2026, 1, 1, 7)), 'Selamat Pagi');
    expect(Formatter.sapaan(DateTime(2026, 1, 1, 12)), 'Selamat Siang');
    expect(Formatter.sapaan(DateTime(2026, 1, 1, 16)), 'Selamat Sore');
    expect(Formatter.sapaan(DateTime(2026, 1, 1, 21)), 'Selamat Malam');
  });
}
