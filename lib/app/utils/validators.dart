/// Kumpulan validator form. Mengembalikan pesan error atau null jika valid.
class Validators {
  Validators._();

  static String? wajib(String? value, [String field = 'Field ini']) {
    if (value == null || value.trim().isEmpty) return '$field wajib diisi';
    return null;
  }

  /// Nama kategori: wajib, maks 50 karakter, tidak boleh duplikat (case-insensitive).
  static String? namaKategori(String? value, Iterable<String> namaLain) {
    final wajibErr = wajib(value, 'Nama kategori');
    if (wajibErr != null) return wajibErr;
    final nama = value!.trim();
    if (nama.length > 50) return 'Nama kategori maksimal 50 karakter';
    final duplikat = namaLain.any((n) => n.trim().toLowerCase() == nama.toLowerCase());
    if (duplikat) return 'Kategori "$nama" sudah ada';
    return null;
  }

  /// Harga: wajib, angka, > 0.
  static String? harga(String? value) {
    final wajibErr = wajib(value, 'Harga');
    if (wajibErr != null) return wajibErr;
    final angka = double.tryParse(value!.trim().replaceAll('.', '').replaceAll(',', '.'));
    if (angka == null) return 'Harga harus berupa angka';
    if (angka <= 0) return 'Harga harus lebih dari 0';
    return null;
  }

  /// Stok: wajib, bilangan bulat, >= 0.
  static String? stok(String? value) {
    final wajibErr = wajib(value, 'Stok');
    if (wajibErr != null) return wajibErr;
    final angka = int.tryParse(value!.trim());
    if (angka == null) return 'Stok harus berupa angka bulat';
    if (angka < 0) return 'Stok tidak boleh negatif';
    return null;
  }

  /// Estimasi saji (menit): wajib, bilangan bulat, > 0.
  static String? estimasiSaji(String? value) {
    final wajibErr = wajib(value, 'Estimasi saji');
    if (wajibErr != null) return wajibErr;
    final angka = int.tryParse(value!.trim());
    if (angka == null) return 'Estimasi saji harus berupa angka (menit)';
    if (angka <= 0) return 'Estimasi saji harus lebih dari 0 menit';
    return null;
  }

  /// No HP: wajib, hanya angka, 10-13 digit, diawali 08.
  static String? noHp(String? value) {
    final wajibErr = wajib(value, 'Nomor HP');
    if (wajibErr != null) return wajibErr;
    final hp = value!.trim();
    if (!RegExp(r'^\d+$').hasMatch(hp)) return 'Nomor HP hanya boleh berisi angka';
    if (!hp.startsWith('08')) return 'Nomor HP harus diawali 08';
    if (hp.length < 10 || hp.length > 13) return 'Nomor HP harus 10-13 digit';
    return null;
  }

  static String? maksPanjang(String? value, int maks, [String field = 'Teks']) {
    if (value != null && value.trim().length > maks) return '$field maksimal $maks karakter';
    return null;
  }
}
