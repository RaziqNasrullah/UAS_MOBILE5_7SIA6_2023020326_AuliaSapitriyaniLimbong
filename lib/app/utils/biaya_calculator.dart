import '../data/services/api_config.dart';

/// Tipe pesanan yang tersedia.
class TipePesanan {
  TipePesanan._();
  static const String makanDiTempat = 'Makan di Tempat';
  static const String bawaPulang = 'Bawa Pulang';
  static const String diantar = 'Diantar';
  static const List<String> semua = [makanDiTempat, bawaPulang, diantar];
}

/// Hasil perhitungan biaya pesanan.
class RincianBiaya {
  const RincianBiaya({
    required this.subtotal,
    required this.biayaLayanan,
    required this.ongkir,
    required this.diskon,
  });

  final double subtotal;
  final double biayaLayanan;
  final double ongkir;
  final double diskon;

  double get total => subtotal + biayaLayanan + ongkir - diskon;
}

/// Kalkulasi biaya pesanan (sama persis dengan fungsi hitungBiaya() di backend):
/// - Biaya layanan Rp2.000
/// - Ongkir Rp8.000 hanya untuk "Diantar"
/// - Diskon 10% jika subtotal >= Rp100.000
/// - Total = subtotal + biaya layanan + ongkir - diskon
class BiayaCalculator {
  BiayaCalculator._();

  static RincianBiaya hitung(double subtotal, String tipePesanan) {
    if (subtotal <= 0) {
      return const RincianBiaya(subtotal: 0, biayaLayanan: 0, ongkir: 0, diskon: 0);
    }
    final ongkir = tipePesanan == TipePesanan.diantar ? ApiConfig.ongkirDiantar : 0.0;
    final diskon = subtotal >= ApiConfig.diskonMinSubtotal
        ? (subtotal * ApiConfig.diskonPersen / 100).roundToDouble()
        : 0.0;
    return RincianBiaya(
      subtotal: subtotal,
      biayaLayanan: ApiConfig.biayaLayanan,
      ongkir: ongkir,
      diskon: diskon,
    );
  }

  /// Sisa belanja agar mendapat diskon (0 jika sudah memenuhi).
  static double kurangUntukDiskon(double subtotal) {
    final kurang = ApiConfig.diskonMinSubtotal - subtotal;
    return kurang > 0 ? kurang : 0;
  }
}
