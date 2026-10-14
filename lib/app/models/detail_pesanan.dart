import '../utils/parse.dart';

/// Model tabel `detail_pesanan` (snapshot nama & harga saat dibeli).
class DetailPesanan {
  const DetailPesanan({
    required this.id,
    required this.namaMenu,
    required this.hargaSatuan,
    required this.jumlah,
    required this.subtotal,
    this.pesananId = 0,
    this.menuId,
    this.catatanItem,
  });

  final int id;
  final int pesananId;
  final int? menuId;
  final String namaMenu;
  final double hargaSatuan;
  final int jumlah;
  final String? catatanItem;
  final double subtotal;

  factory DetailPesanan.fromJson(Map<String, dynamic> json) => DetailPesanan(
        id: parseInt(json['id']),
        pesananId: parseInt(json['pesanan_id']),
        menuId: parseIntOrNull(json['menu_id']),
        namaMenu: (json['nama_menu'] ?? '').toString(),
        hargaSatuan: parseDouble(json['harga_satuan']),
        jumlah: parseInt(json['jumlah']),
        catatanItem: parseStringOrNull(json['catatan_item']),
        subtotal: parseDouble(json['subtotal']),
      );
}
