import '../utils/parse.dart';

/// Model tabel `kategori`.
class Kategori {
  const Kategori({
    required this.id,
    required this.nama,
    this.deskripsi,
    this.ikon,
    this.jumlahMenu = 0,
  });

  final int id;
  final String nama;
  final String? deskripsi;
  final String? ikon;
  final int jumlahMenu;

  factory Kategori.fromJson(Map<String, dynamic> json) => Kategori(
        id: parseInt(json['id']),
        nama: (json['nama'] ?? '').toString(),
        deskripsi: parseStringOrNull(json['deskripsi']),
        ikon: parseStringOrNull(json['ikon']),
        jumlahMenu: parseInt(json['jumlah_menu']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'deskripsi': deskripsi,
        'ikon': ikon,
      };
}
