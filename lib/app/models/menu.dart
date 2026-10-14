import '../data/services/api_config.dart';
import '../utils/parse.dart';

/// Model tabel `menu` (+ nama_kategori hasil JOIN).
class Menu {
  const Menu({
    required this.id,
    required this.kategoriId,
    required this.nama,
    required this.harga,
    required this.stok,
    required this.deskripsi,
    this.gambar,
    this.levelPedas = 'Tidak Pedas',
    this.suhuSajian = 'Panas',
    this.estimasiSaji = 10,
    this.isBestSeller = false,
    this.namaKategori = '',
    this.createdAt,
  });

  static const List<String> pilihanLevelPedas = ['Tidak Pedas', 'Sedang', 'Pedas', 'Extra Pedas'];
  static const List<String> pilihanSuhuSajian = ['Panas', 'Dingin', 'Suhu Ruang'];

  final int id;
  final int kategoriId;
  final String nama;
  final double harga;
  final int stok;
  final String deskripsi;
  final String? gambar;
  final String levelPedas;
  final String suhuSajian;
  final int estimasiSaji;
  final bool isBestSeller;
  final String namaKategori;
  final DateTime? createdAt;

  bool get isHabis => stok <= 0;
  String get imageUrl => ApiConfig.imageUrl(gambar);

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
        id: parseInt(json['id']),
        kategoriId: parseInt(json['kategori_id']),
        nama: (json['nama'] ?? '').toString(),
        harga: parseDouble(json['harga']),
        stok: parseInt(json['stok']),
        deskripsi: (json['deskripsi'] ?? '').toString(),
        gambar: parseStringOrNull(json['gambar']),
        levelPedas: parseStringOrNull(json['level_pedas']) ?? 'Tidak Pedas',
        suhuSajian: parseStringOrNull(json['suhu_sajian']) ?? 'Panas',
        estimasiSaji: parseInt(json['estimasi_saji'], 10),
        isBestSeller: parseBool(json['is_best_seller']),
        namaKategori: (json['nama_kategori'] ?? '').toString(),
        createdAt: parseDate(json['created_at']),
      );

  /// Body request create/update.
  Map<String, dynamic> toJson() => {
        if (id > 0) 'id': id,
        'kategori_id': kategoriId,
        'nama': nama,
        'harga': harga,
        'stok': stok,
        'deskripsi': deskripsi,
        'gambar': gambar,
        'level_pedas': levelPedas,
        'suhu_sajian': suhuSajian,
        'estimasi_saji': estimasiSaji,
        'is_best_seller': isBestSeller,
      };

  Menu copyWith({int? stok, String? gambar}) => Menu(
        id: id,
        kategoriId: kategoriId,
        nama: nama,
        harga: harga,
        stok: stok ?? this.stok,
        deskripsi: deskripsi,
        gambar: gambar ?? this.gambar,
        levelPedas: levelPedas,
        suhuSajian: suhuSajian,
        estimasiSaji: estimasiSaji,
        isBestSeller: isBestSeller,
        namaKategori: namaKategori,
        createdAt: createdAt,
      );
}
