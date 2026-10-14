import '../utils/parse.dart';
import 'detail_pesanan.dart';

/// Model tabel `pesanan` (+ daftar item detail_pesanan).
class Pesanan {
  const Pesanan({
    required this.id,
    required this.nomorPesanan,
    required this.namaPemesan,
    required this.noHp,
    required this.tipePesanan,
    required this.subtotal,
    required this.biayaLayanan,
    required this.ongkir,
    required this.diskon,
    required this.total,
    required this.status,
    this.nomorMeja,
    this.alamat,
    this.catatan,
    this.tanggal,
    this.jumlahItem = 0,
    this.items = const [],
  });

  static const List<String> pilihanStatus = ['Diproses', 'Selesai', 'Dibatalkan'];

  final int id;
  final String nomorPesanan;
  final String namaPemesan;
  final String noHp;
  final String tipePesanan;
  final String? nomorMeja;
  final String? alamat;
  final String? catatan;
  final double subtotal;
  final double biayaLayanan;
  final double ongkir;
  final double diskon;
  final double total;
  final String status;
  final DateTime? tanggal;
  final int jumlahItem;
  final List<DetailPesanan> items;

  bool get bisaDiubah => status == 'Diproses';

  /// Keterangan tipe: "Makan di Tempat - Meja 5", "Diantar", dst.
  String get keteranganTipe {
    if (tipePesanan == 'Makan di Tempat' && nomorMeja != null) return '$tipePesanan - Meja $nomorMeja';
    return tipePesanan;
  }

  factory Pesanan.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems.whereType<Map>().map((e) => DetailPesanan.fromJson(Map<String, dynamic>.from(e))).toList()
        : <DetailPesanan>[];
    return Pesanan(
      id: parseInt(json['id']),
      nomorPesanan: (json['nomor_pesanan'] ?? '').toString(),
      namaPemesan: (json['nama_pemesan'] ?? '').toString(),
      noHp: (json['no_hp'] ?? '').toString(),
      tipePesanan: (json['tipe_pesanan'] ?? '').toString(),
      nomorMeja: parseStringOrNull(json['nomor_meja']),
      alamat: parseStringOrNull(json['alamat']),
      catatan: parseStringOrNull(json['catatan']),
      subtotal: parseDouble(json['subtotal']),
      biayaLayanan: parseDouble(json['biaya_layanan']),
      ongkir: parseDouble(json['ongkir']),
      diskon: parseDouble(json['diskon']),
      total: parseDouble(json['total']),
      status: (json['status'] ?? 'Diproses').toString(),
      tanggal: parseDate(json['tanggal']),
      jumlahItem: json['jumlah_item'] != null
          ? parseInt(json['jumlah_item'])
          : items.fold<int>(0, (sum, e) => sum + e.jumlah),
      items: items,
    );
  }
}
