# Black Box Testing — Aplikasi Delights

## Lingkungan & metode pengujian
Pengujian di bawah **benar-benar dijalankan** pada 14 Oktober 2026 dengan tiga cara (kolom *Hasil Aktual* menyebut caranya):

| Kode | Cara pengujian | Keterangan |
|---|---|---|
| **[API]** | `bash scripts/test_api.sh` (curl) ke backend PHP 8.3 + MariaDB 10.11 (setara XAMPP) | 52 pemeriksaan, **52 lulus** |
| **[UI]** | Aplikasi Flutter yang sama (build web, Chromium, viewport 392×850) dijalankan terhadap backend & database asli, lalu diklik langkah demi langkah dan dicek isi database | Screenshot di [`screenshots/`](screenshots/) |
| **[Test]** | `flutter test` — 33 unit & widget test | **33 lulus** |

> ⚠️ **Belum diuji di HP/emulator Android.** Lingkungan pengembangan tidak dapat mengunduh Android SDK, sehingga APK belum dibangun dan belum dijalankan di perangkat.
> Mahasiswa wajib mengulang skenario bertanda **(HP)** di emulator/HP lalu memperbarui kolom *Hasil Aktual* & *Status* (mis. tambahkan screenshot dari HP).
> Fitur yang bergantung pada Android (pilih gambar dari galeri, simpan PDF ke folder Download, preview PDF native, bagikan) belum bisa diverifikasi.

## Tabel pengujian

| No | Fitur | Skenario | Hasil yang Diharapkan | Hasil Aktual | Status |
|---|---|---|---|---|---|
| 1 | Kategori | Simpan kategori dengan nama kosong | Muncul pesan "Nama kategori wajib diisi", data tidak tersimpan | [UI] pesan muncul di bawah field; [API] HTTP 422 "Nama kategori wajib diisi" | Lulus |
| 2 | Kategori | Tambah kategori "minuman" (sudah ada "Minuman") | Ditolak: kategori sudah ada (cek tidak peka huruf besar/kecil) | [UI] pesan `Kategori "minuman" sudah ada`; [API] HTTP 409 (juga saat update ke "SNACK") | Lulus |
| 3 | Kategori | Tambah kategori baru "Paket Hemat" + deskripsi | Tersimpan, muncul di daftar dengan "0 menu", snackbar sukses | [UI] snackbar "Kategori berhasil ditambahkan", baris baru id 5 di tabel `kategori` | Lulus |
| 4 | Kategori | Ubah nama kategori | Nama berubah di daftar & katalog | [API] update "Uji Kategori" → "Uji Kategori 2" HTTP 200 | Lulus (UI: HP) |
| 5 | Kategori | Hapus kategori "Snack" yang masih punya 5 menu | Ditolak dengan pesan jelas | [UI] snackbar merah "Kategori "Snack" masih memiliki 5 menu…"; [API] HTTP 409 | Lulus |
| 6 | Kategori | Hapus kategori kosong | Terhapus setelah konfirmasi | [API] HTTP 200, baris terhapus | Lulus (UI: HP) |
| 7 | Menu | Simpan menu dengan field kosong / harga 0 / stok −1 / estimasi 0 | Ditolak, pesan per field | [API] HTTP 422 berisi daftar `errors`; [Test] validator harga/stok/estimasi | Lulus |
| 8 | Menu | Tambah menu "Paket Nasi Goreng + Es Teh" kategori Paket Hemat, harga 30000, stok 12, best seller ON | Tersimpan dengan FK kategori benar; daftar menampilkan nama kategori (JOIN) | [UI] snackbar sukses; DB: `kategori_id` → "Paket Hemat", `is_best_seller`=1 | Lulus |
| 9 | Menu | Upload gambar menu (JPG/PNG) lalu edit menu | Gambar tersimpan di `uploads/`, kolom `gambar` terisi | [API] multipart HTTP 201 `menu_…png`; upload file teks ditolak HTTP 422 "Format gambar harus JPG, PNG, atau WEBP" | Lulus (galeri: HP) |
| 10 | Menu | Hapus menu yang pernah dipesan | Menu hilang, riwayat pesanan tetap utuh (snapshot) | [API] HTTP 200; detail pesanan lama tetap menampilkan "Menu Uji Edit" | Lulus |
| 11 | Pencarian | Ketik "kopi" di katalog | Hasil difilter realtime (±400 ms setelah berhenti mengetik) | [UI] tampil "1 hasil untuk "kopi""; [Test] request baru dikirim setelah debounce 400 ms | Lulus |
| 12 | Filter | Pilih ChoiceChip "Minuman", lalu kombinasikan dengan kata kunci | Hanya menu kategori Minuman yang cocok | [UI] "5 hasil untuk kategori Minuman", lalu "1 hasil untuk "kopi" di kategori Minuman"; [API] `?kategori_id=2&search=lemon` | Lulus |
| 13 | Detail menu | Buka menu dengan stok 0 (Ayam Geprek Keju Mozarella) | Label HABIS, tombol nonaktif bertuliskan "Habis" | [UI] overlay HABIS & tombol abu-abu "Habis"; [Test] `onPressed == null`; [API] add ke keranjang HTTP 422 "sedang habis" | Lulus |
| 14 | Keranjang | Tambah Kopi Susu Gula Aren jumlah 3 dengan catatan "less sugar" | Masuk keranjang dengan catatan, badge bertambah | [UI] snackbar sukses, badge 4 (setelah +1 Chicken Katsu), DB `catatan_item`="less sugar" | Lulus |
| 15 | Keranjang | Tambah/ubah jumlah melebihi stok | Ditolak dengan pesan sisa stok | [API] add melebihi stok 422, update_qty > stok 422 "hanya tersisa…", qty 0 → 422; [UI] tombol + nonaktif saat jumlah = stok | Lulus |
| 16 | Keranjang | Ubah jumlah (+/−), edit catatan, hapus item | Subtotal & total berubah otomatis, catatan tersimpan | [UI] qty 3→4 subtotal Rp80.000, total Rp115.000; catatan "saus kari dipisah" tersimpan di DB | Lulus |
| 17 | Checkout | Tekan "Buat Pesanan" dengan form kosong | Pesan wajib isi pada nama, no HP, nomor meja | [UI] 3 pesan error + snackbar "Periksa kembali…"; [API] HTTP 422 | Lulus |
| 18 | Checkout | Nomor HP "62812345" / "0812-345" | Ditolak: harus angka 10–13 digit diawali 08 | [Test] validator noHp; [API] HTTP 422 "Nomor HP harus angka 10-13 digit dan diawali 08" | Lulus |
| 19 | Checkout | Tipe Makan di Tempat tanpa meja / Diantar tanpa alamat | Field meja/alamat muncul sesuai tipe dan wajib diisi | [UI] memilih "Diantar" memunculkan field alamat & menyembunyikan meja; [API] 422 untuk keduanya | Lulus |
| 20 | Checkout | Checkout sukses tipe Diantar (4× Kopi Susu + 1× Chicken Katsu) | Pesanan & detail tersimpan, stok berkurang, keranjang kosong, pindah ke halaman sukses | [UI] halaman "Pesanan Berhasil!" INV-20261014-002; DB stok Chicken Katsu 15→14, Kopi Susu 40→36, keranjang 0 baris | Lulus |
| 21 | Biaya | Subtotal Rp115.000 Diantar | Layanan 2.000, ongkir 8.000, diskon 11.500, total 113.500 | [UI]+DB: subtotal 115000, ongkir 8000, diskon 11500, total 113500; [Test] 6 kasus kalkulator (termasuk batas 99.999/100.000) | Lulus |
| 22 | Nomor INV | Dua checkout di hari yang sama | Format `INV-YYYYMMDD-NNN`, NNN bertambah & reset tiap hari | [API] INV-20261014-002 lalu INV-20261014-003; seed hari sebelumnya mulai lagi dari -001 | Lulus |
| 23 | Checkout | Stok berubah/tidak cukup saat checkout | Transaksi di-rollback, muncul pesan stok tidak cukup | [API] validasi ulang `FOR UPDATE` di server; menu di keranjang yang stoknya 0 dihapus otomatis saat menu di-update | Lulus (API) |
| 24 | Riwayat | Buka tab Pesanan | Urut terbaru di atas, status berwarna berbeda, filter status berfungsi | [UI] INV-20261014-002 paling atas; Diproses kuning, Selesai hijau, Dibatalkan merah; filter "Dibatalkan" hanya 2 pesanan | Lulus |
| 25 | Status | Batalkan pesanan Diproses | Konfirmasi muncul, status Dibatalkan, stok kembali | [UI] dialog konfirmasi → snackbar "dibatalkan, stok 2 menu dikembalikan"; DB stok 14→15 & 36→40 | Lulus |
| 26 | Status | Ubah lagi pesanan yang sudah Selesai/Dibatalkan | Ditolak | [UI] tombol aksi disembunyikan + keterangan; [API] HTTP 409 "tidak dapat diubah lagi" | Lulus |
| 27 | Dashboard | Buka Dashboard Penjualan | Total pesanan, pendapatan (hanya Selesai), menu terlaris, BarChart, LineChart, PieChart | [UI] 6 pesanan, Rp327.500, terlaris Kopi Susu Gula Aren (5 porsi), ketiga grafik tampil | Lulus |
| 28 | Struk PDF | Cetak struk pesanan | PDF berisi logo, SweetnFresh, nomor, tanggal, tipe & alamat, item + catatan, rincian biaya, total | [Test] PDF valid (`%PDF-`), karakter non-Latin-1 dibersihkan; PDF dari data asli dirender dan diperiksa ([contoh](screenshots/struk_contoh.png)) | Lulus |
| 29 | Struk PDF | Preview, Simpan ke perangkat, Bagikan | Preview tampil, file tersimpan di folder Download aplikasi (path di snackbar), share sheet terbuka | Belum dapat diuji (butuh Android) | **Belum diuji (HP)** |
| 30 | Error handling | Server/XAMPP dimatikan lalu buka aplikasi | Tampil pesan koneksi gagal + tombol "Coba Lagi" | [UI] "Oops, data gagal dimuat… Pastikan HP & laptop satu jaringan dan XAMPP aktif." + tombol Coba Lagi; setelah server hidup data tampil | Lulus |
| 31 | Error handling | Respons kosong / bukan JSON / method salah | Pesan jelas, aplikasi tidak crash | [Test] ApiService: kosong → "Respons server kosong", HTML → "bukan JSON", SocketException → pesan koneksi; [API] GET ke create.php → 405 | Lulus |
| 32 | Deployment | `flutter build apk --release`, instal di HP, akses API via IP LAN | APK terpasang dengan nama & ikon Delights, data tampil | Belum dapat diuji (Android SDK tidak tersedia di lingkungan pengembangan) | **Belum diuji (HP)** |

**Ringkasan:** 30 skenario lulus (beberapa bagian UI-nya perlu dikonfirmasi ulang di HP), 2 skenario belum diuji karena membutuhkan perangkat Android.
