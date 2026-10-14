import '../data/services/api_config.dart';
import '../utils/parse.dart';

/// Model baris tabel `keranjang` (+ data menu hasil JOIN).
class KeranjangItem {
  const KeranjangItem({
    required this.id,
    required this.menuId,
    required this.jumlah,
    required this.namaMenu,
    required this.harga,
    required this.stok,
    this.catatanItem,
    this.gambar,
    this.namaKategori = '',
    this.levelPedas = 'Tidak Pedas',
  });

  final int id;
  final int menuId;
  final int jumlah;
  final String? catatanItem;
  final String namaMenu;
  final double harga;
  final int stok;
  final String? gambar;
  final String namaKategori;
  final String levelPedas;

  double get subtotal => harga * jumlah;
  String get imageUrl => ApiConfig.imageUrl(gambar);
  bool get bisaTambah => jumlah < stok;
  bool get bisaKurang => jumlah > 1;

  factory KeranjangItem.fromJson(Map<String, dynamic> json) => KeranjangItem(
        id: parseInt(json['id']),
        menuId: parseInt(json['menu_id']),
        jumlah: parseInt(json['jumlah'], 1),
        catatanItem: parseStringOrNull(json['catatan_item']),
        namaMenu: (json['nama_menu'] ?? '').toString(),
        harga: parseDouble(json['harga']),
        stok: parseInt(json['stok']),
        gambar: parseStringOrNull(json['gambar']),
        namaKategori: (json['nama_kategori'] ?? '').toString(),
        levelPedas: parseStringOrNull(json['level_pedas']) ?? 'Tidak Pedas',
      );

  KeranjangItem copyWith({int? jumlah, String? catatanItem, bool hapusCatatan = false}) => KeranjangItem(
        id: id,
        menuId: menuId,
        jumlah: jumlah ?? this.jumlah,
        catatanItem: hapusCatatan ? null : (catatanItem ?? this.catatanItem),
        namaMenu: namaMenu,
        harga: harga,
        stok: stok,
        gambar: gambar,
        namaKategori: namaKategori,
        levelPedas: levelPedas,
      );
}
