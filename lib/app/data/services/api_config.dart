/// Konfigurasi alamat REST API (XAMPP) dan konstanta biaya pesanan.
///
/// Ubah [defaultBaseUrl] sesuai perangkat:
/// - Emulator Android : http://10.0.2.2/kuliner_api
/// - HP fisik         : `http://<IP-LAN-laptop>/kuliner_api` (cek dengan `ipconfig`)
///
/// Atau tanpa mengubah kode:
/// `flutter run --dart-define=API_BASE_URL=http://192.168.1.10/kuliner_api`
class ApiConfig {
  ApiConfig._();

  static const String defaultBaseUrl = 'http://10.0.2.2/kuliner_api';

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: defaultBaseUrl,
  );

  /// Batas waktu setiap request HTTP.
  static const Duration timeout = Duration(seconds: 15);

  /// URL lengkap gambar menu (file disimpan di folder `uploads/` backend).
  static String imageUrl(String? fileName) {
    if (fileName == null || fileName.isEmpty) return '';
    if (fileName.startsWith('http')) return fileName;
    return '$baseUrl/uploads/$fileName';
  }

  // ---- Konstanta biaya (harus sama dengan backend config/database.php) ----
  static const double biayaLayanan = 2000;
  static const double ongkirDiantar = 8000;
  static const double diskonMinSubtotal = 100000;
  static const double diskonPersen = 10;

  // ---- Identitas kedai ----
  static const String namaAplikasi = 'Delights';
  static const String namaKedai = 'SweetnFresh';
  static const String alamatKedai = 'Jl. Gatot Subroto No. 88, Medan';
  static const String teleponKedai = '0812-6000-2026';
}
