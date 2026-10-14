import '../utils/parse.dart';

class MenuTerlaris {
  const MenuTerlaris({required this.namaMenu, required this.totalTerjual, required this.totalPenjualan});

  final String namaMenu;
  final int totalTerjual;
  final double totalPenjualan;

  factory MenuTerlaris.fromJson(Map<String, dynamic> json) => MenuTerlaris(
        namaMenu: (json['nama_menu'] ?? '').toString(),
        totalTerjual: parseInt(json['total_terjual']),
        totalPenjualan: parseDouble(json['total_penjualan']),
      );
}

class PendapatanHarian {
  const PendapatanHarian({required this.tanggal, required this.pendapatan, required this.jumlahPesanan});

  final DateTime tanggal;
  final double pendapatan;
  final int jumlahPesanan;

  factory PendapatanHarian.fromJson(Map<String, dynamic> json) => PendapatanHarian(
        tanggal: parseDate(json['tanggal']) ?? DateTime.now(),
        pendapatan: parseDouble(json['pendapatan']),
        jumlahPesanan: parseInt(json['jumlah_pesanan']),
      );
}

class PenjualanKategori {
  const PenjualanKategori({required this.namaKategori, required this.totalTerjual});

  final String namaKategori;
  final int totalTerjual;

  factory PenjualanKategori.fromJson(Map<String, dynamic> json) => PenjualanKategori(
        namaKategori: (json['nama_kategori'] ?? '').toString(),
        totalTerjual: parseInt(json['total_terjual']),
      );
}

/// Ringkasan dashboard penjualan (endpoint dashboard/summary.php).
class DashboardSummary {
  const DashboardSummary({
    required this.totalPesanan,
    required this.pesananPerStatus,
    required this.totalPendapatan,
    required this.porsiTerjual,
    required this.menuTerlaris,
    required this.pendapatan7Hari,
    required this.penjualanKategori,
  });

  final int totalPesanan;
  final Map<String, int> pesananPerStatus;
  final double totalPendapatan;
  final int porsiTerjual;
  final List<MenuTerlaris> menuTerlaris;
  final List<PendapatanHarian> pendapatan7Hari;
  final List<PenjualanKategori> penjualanKategori;

  static List<T> _list<T>(dynamic raw, T Function(Map<String, dynamic>) f) =>
      raw is List ? raw.whereType<Map>().map((e) => f(Map<String, dynamic>.from(e))).toList() : <T>[];

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final status = <String, int>{};
    final rawStatus = json['pesanan_per_status'];
    if (rawStatus is Map) {
      rawStatus.forEach((k, v) => status[k.toString()] = parseInt(v));
    }
    return DashboardSummary(
      totalPesanan: parseInt(json['total_pesanan']),
      pesananPerStatus: status,
      totalPendapatan: parseDouble(json['total_pendapatan']),
      porsiTerjual: parseInt(json['porsi_terjual']),
      menuTerlaris: _list(json['menu_terlaris'], MenuTerlaris.fromJson),
      pendapatan7Hari: _list(json['pendapatan_7_hari'], PendapatanHarian.fromJson),
      penjualanKategori: _list(json['penjualan_kategori'], PenjualanKategori.fromJson),
    );
  }
}
