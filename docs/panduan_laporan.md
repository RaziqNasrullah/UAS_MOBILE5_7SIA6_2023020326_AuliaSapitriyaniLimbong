# Panduan Penyusunan Laporan UAS — Aplikasi Delights

**Identitas:** Aulia Sapitriyani Limbong — NIRM 2023020326 — Kelas 7SIA6

## Susunan laporan (PDF)
1. **Cover** — judul "Aplikasi Pemesanan Makanan Delights (Kedai SweetnFresh) Berbasis Flutter GetX dan MySQL", logo, identitas, kelas, mata kuliah, tahun.
2. **Bab 1 Pendahuluan** — latar belakang, tujuan, ruang lingkup (12 fitur wajib).
3. **Bab 2 Analisis Kebutuhan** — salin dari [`kebutuhan.md`](kebutuhan.md): aktor, kebutuhan fungsional F-01…F-20, non-fungsional NF-01…NF-09.
4. **Bab 3 Perancangan**
   - Use Case Diagram — `diagram/use_case.png`
   - Activity Diagram checkout — `diagram/activity_checkout.png`
   - ERD + normalisasi 1NF–3NF — `diagram/erd.png` + [`erd_normalisasi.md`](erd_normalisasi.md)
   - Arsitektur 3 lapis: Flutter (GetX) ⇄ HTTP/JSON ⇄ REST API PHP ⇄ PDO ⇄ MySQL
5. **Bab 4 Implementasi**
   - Struktur folder Flutter & backend (lihat README)
   - Potongan kode penting: `GetMaterialApp`/`GetPage` (`lib/app/routes/app_pages.dart`), `ThemeData` (`lib/app/theme/app_theme.dart`), custom widget (`MenuCard`, `CartBadgeIcon`, `QtyStepper`, …), debounce pencarian (`katalog_controller.dart`), `CartController`, transaksi checkout (`backend/kuliner_api/pesanan/checkout.php`), pembuatan PDF (`lib/app/utils/pdf_generator.dart`), query JOIN menu (`menu/_shared.php`)
   - Screenshot setiap halaman (daftar di bawah)
6. **Bab 5 Pengujian** — tabel [`black_box_testing.md`](black_box_testing.md) (perbarui hasil dari HP), hasil `flutter test` & `flutter analyze`, contoh struk PDF hasil export.
7. **Bab 6 Penutup** — kesimpulan & saran.
8. **Lampiran** — link repository GitHub, isi `database/db_kuliner.sql` (ringkas).

## Daftar halaman yang perlu di-screenshot (dari HP/emulator)
Contoh tampilan (dari build web saat pengujian) ada di [`screenshots/`](screenshots/) sebagai acuan.

| No | Halaman | Kondisi yang ditampilkan |
|---|---|---|
| 1 | Ikon launcher | Ikon & nama "Delights" di home screen HP |
| 2 | Beranda | Sapaan sesuai waktu, kategori, best seller, menu terbaru, badge keranjang |
| 3 | Katalog | GridView semua menu (ada label HABIS) |
| 4 | Katalog – filter | ChoiceChip "Minuman" aktif |
| 5 | Katalog – pencarian | Ketik "kopi" (kombinasi dengan filter) |
| 6 | Detail menu | Badge level pedas, suhu, estimasi, catatan & jumlah |
| 7 | Detail menu habis | Tombol "Habis" nonaktif |
| 8 | Snackbar tambah ke keranjang | Pesan sukses + badge bertambah |
| 9 | Keranjang | Catatan item, +/−, subtotal & total |
| 10 | Dialog edit catatan | |
| 11 | Checkout – validasi | Pesan error form kosong |
| 12 | Checkout – Diantar | Field alamat muncul, ongkir & diskon di rincian biaya |
| 13 | Halaman sukses | Nomor INV & total |
| 14 | Preview struk PDF | |
| 15 | Snackbar simpan PDF | Path file di folder Download aplikasi |
| 16 | Riwayat pesanan | Warna status & filter |
| 17 | Detail pesanan | Item + catatan, rincian biaya, tombol aksi |
| 18 | Dialog konfirmasi batalkan | dan snackbar stok dikembalikan |
| 19 | Dashboard | Kartu ringkasan, BarChart, LineChart, PieChart |
| 20 | Kelola Kedai | Menu admin |
| 21 | Kelola Kategori | Daftar + snackbar gagal hapus kategori berisi menu |
| 22 | Form kategori | Error nama kosong & duplikat |
| 23 | Kelola Menu | Daftar dengan nama kategori (JOIN) |
| 24 | Form menu | Gambar dari galeri, dropdown kategori, level pedas, suhu, estimasi, switch best seller |
| 25 | Error server mati | Tampilan "Coba Lagi" saat XAMPP dimatikan |
| 26 | phpMyAdmin | Struktur 5 tabel & relasi (Designer) |
