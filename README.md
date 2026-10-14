# Delights — Aplikasi Pemesanan Kedai SweetnFresh

<p align="center"><img src="assets/images/logo.png" width="200" alt="Logo Delights"></p>

Aplikasi mobile **Flutter + GetX** untuk katalog & pemesanan makanan/minuman kedai **SweetnFresh**,
dengan backend **REST API PHP native (PDO)** dan database **MySQL/MariaDB XAMPP**.

| | |
|---|---|
| Mahasiswa | Aulia Sapitriyani Limbong — NIRM 2023020326 |
| Kelas | 7SIA6 |
| Package Android | `com.auliasapitriyani.delights` |
| Toolchain | Flutter **3.41.6** (stable) / Dart **3.11.4**, AGP 8.11.1, Kotlin 2.2.20, Gradle 8.14 |

```
Flutter (GetX)  ──HTTP/JSON──►  REST API PHP (C:\xampp\htdocs\kuliner_api)  ──PDO──►  MySQL db_kuliner
```

---

## 1. Clone repository
Kode ada di branch `claude/new-session-6hauu5`. **Wajib menyebut branch**, kalau tidak folder bisa kosong:

```bash
git clone -b claude/new-session-6hauu5 https://github.com/RaziqNasrullah/UAS_MOBILE5_7SIA6_2023020326_AuliaSapitriyaniLimbong.git
cd UAS_MOBILE5_7SIA6_2023020326_AuliaSapitriyaniLimbong
```

## 2. Struktur folder
```
├── lib/
│   ├── main.dart                     # GetMaterialApp + locale id_ID
│   └── app/
│       ├── models/                   # kategori, menu, keranjang_item, pesanan, detail_pesanan, dashboard_summary
│       ├── controllers/              # main, home, katalog, menu_detail, cart, checkout, pesanan, dashboard,
│       │                             # kategori (+form), menu_admin (+form), struk
│       ├── views/                    # satu folder per halaman
│       ├── routes/                   # app_routes.dart (nama route) + app_pages.dart (GetPage)
│       ├── data/services/            # api_config, api_service (http), kategori/menu/keranjang/pesanan/dashboard_service
│       ├── widgets/                  # MenuCard, CategoryChip, CartBadgeIcon, CustomTextField, SummaryCard,
│       │                             # EmptyState/ErrorState, LevelPedasBadge, StatusBadge, QtyStepper, BiayaRow, ...
│       ├── bindings/                 # InitialBinding + binding per halaman
│       ├── theme/                    # app_theme.dart (ThemeData terpusat)
│       └── utils/                    # formatter, validators, biaya_calculator, pdf_generator, app_snackbar, parse
├── backend/kuliner_api/              # REST API PHP -> salin ke C:\xampp\htdocs\kuliner_api
│   ├── config/database.php           # koneksi PDO + konstanta biaya
│   ├── helpers/response.php          # respons JSON seragam {success, message, data}
│   ├── kategori/  menu/  keranjang/  pesanan/  dashboard/
│   └── uploads/                      # 20 gambar menu
├── database/db_kuliner.sql           # skema 5 tabel + data seed (import di phpMyAdmin)
├── docs/                             # kebutuhan, diagram (puml+png), ERD & normalisasi, black box testing, panduan laporan
├── scripts/                          # test_api.sh, zip_source.sh, zip_source.ps1
└── test/                             # unit test & widget test
```

## 3. Setup XAMPP (backend + database)
1. Buka **XAMPP Control Panel** → klik **Start** pada **Apache** dan **MySQL**.
2. Buka `http://localhost/phpmyadmin` → tab **Import** → pilih `database/db_kuliner.sql` → **Go**.
   (File ini otomatis membuat database `db_kuliner`, 5 tabel, 4 kategori, 20 menu, 5 contoh pesanan.)
3. Salin folder `backend/kuliner_api` ke `C:\xampp\htdocs\kuliner_api`:
   ```powershell
   xcopy /E /I /Y backend\kuliner_api C:\xampp\htdocs\kuliner_api
   ```
4. Cek di browser: `http://localhost/kuliner_api/` → harus muncul JSON
   `"API Delights (SweetnFresh) aktif & database terhubung"` dengan `"jumlah_menu": 20`.
5. Default koneksi: host `127.0.0.1`, user `root`, password kosong (ubah di `config/database.php` bila berbeda).

### Contoh request (curl)
PowerShell memakai `curl.exe` (bukan alias `curl`):
```bash
curl http://localhost/kuliner_api/kategori/read.php
curl "http://localhost/kuliner_api/menu/read.php?search=kopi&kategori_id=2"
curl http://localhost/kuliner_api/menu/detail.php?id=1
curl -X POST -H "Content-Type: application/json" -d "{\"nama\":\"Paket Hemat\"}" http://localhost/kuliner_api/kategori/create.php
curl -X POST -H "Content-Type: application/json" -d "{\"menu_id\":7,\"jumlah\":2,\"catatan_item\":\"less sugar\"}" http://localhost/kuliner_api/keranjang/add.php
curl -X POST -H "Content-Type: application/json" -d "{\"nama_pemesan\":\"Aulia\",\"no_hp\":\"081234567890\",\"tipe_pesanan\":\"Makan di Tempat\",\"nomor_meja\":\"5\"}" http://localhost/kuliner_api/pesanan/checkout.php
curl -X POST -H "Content-Type: application/json" -d "{\"id\":5,\"status\":\"Selesai\"}" http://localhost/kuliner_api/pesanan/update_status.php
curl -F "gambar=@foto.jpg" http://localhost/kuliner_api/menu/upload_gambar.php
curl http://localhost/kuliner_api/dashboard/summary.php
```
Uji otomatis semua endpoint (Git Bash; **mengubah data**, import ulang SQL sesudahnya):
`bash scripts/test_api.sh http://localhost/kuliner_api`

| Endpoint | Method | Keterangan |
|---|---|---|
| `kategori/read.php` | GET | daftar kategori + jumlah menu |
| `kategori/create.php`, `update.php`, `delete.php` | POST | validasi kosong & duplikat (409), hapus ditolak jika berisi menu (409) |
| `menu/read.php?search=&kategori_id=&best_seller=1&sort=terbaru&limit=` | GET | JOIN `nama_kategori` |
| `menu/detail.php?id=` | GET | |
| `menu/create.php`, `update.php`, `delete.php` | POST | |
| `menu/upload_gambar.php` | POST multipart (`gambar`, opsional `menu_id`) | JPG/PNG/WEBP maks 2 MB |
| `keranjang/read.php` | GET | |
| `keranjang/add.php`, `update_qty.php`, `update_catatan.php`, `delete.php`, `clear.php` | POST | validasi stok |
| `pesanan/checkout.php` | POST | transaksi, nomor `INV-YYYYMMDD-NNN`, stok berkurang |
| `pesanan/read.php?status=` | GET | urut terbaru |
| `pesanan/detail.php?id=` | GET | |
| `pesanan/update_status.php` | POST | Selesai / Dibatalkan (stok kembali) |
| `dashboard/summary.php` | GET | ringkasan + data grafik |

## 4. Mengatur alamat API (emulator vs HP fisik)
Alamat API ada di **satu file**: `lib/app/data/services/api_config.dart`.

| Perangkat | Base URL |
|---|---|
| Emulator Android | `http://10.0.2.2/kuliner_api` (default) |
| HP fisik (satu Wi-Fi dengan laptop) | `http://<IP-LAN-laptop>/kuliner_api` |

Cara cek IP laptop: buka CMD → `ipconfig` → lihat **IPv4 Address** pada adapter Wi-Fi (mis. `192.168.1.10`).

Tanpa mengubah kode, pakai `--dart-define`:
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10/kuliner_api
flutter build apk --release --dart-define=API_BASE_URL=http://192.168.1.10/kuliner_api
```
**Firewall:** jika HP tidak bisa membuka `http://192.168.1.10/kuliner_api/` di browser HP, izinkan Apache:
Windows Defender Firewall → *Allow an app through firewall* → centang **Apache HTTP Server** (Private & Public),
atau sementara matikan firewall untuk jaringan Private.

HTTP (bukan HTTPS) tetap jalan di APK release karena `AndroidManifest.xml` sudah berisi permission `INTERNET`,
`android:usesCleartextTraffic="true"`, dan `android:networkSecurityConfig="@xml/network_security_config"`.

## 5. Menjalankan aplikasi Flutter
```bash
flutter doctor                      # cek toolchain (Flutter 3.41.6 / Dart 3.11.4)
flutter pub get                     # unduh dependency
flutter emulators                   # daftar emulator
flutter emulators --launch <nama>   # jalankan emulator, mis. Pixel_7_API_34
flutter devices                     # pastikan emulator/HP terdeteksi
flutter run                         # jalankan (debug)
flutter analyze                     # harus: No issues found!
flutter test                        # unit & widget test
flutter clean                       # bersihkan build bila ada error aneh
flutter build apk --release         # build APK release
```
Ikon launcher sudah dibuat. Jika logo diganti: `dart run flutter_launcher_icons`.

## 6. Lokasi & instal APK
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- Instal via kabel (USB debugging aktif): `adb install -r build\app\outputs\flutter-apk\app-release.apk`
- Atau salin file APK ke HP lalu buka (izinkan *Install unknown apps*).
- Aplikasi tampil dengan nama **Delights** dan ikon logo.

## 7. Fitur
| # | Fitur | Lokasi utama |
|---|---|---|
| 1 | Analisis & perancangan | `docs/kebutuhan.md`, `docs/diagram/*.puml|png`, `docs/erd_normalisasi.md` |
| 2 | GetX: `GetMaterialApp`, `GetPage`, `Get.toNamed` + `arguments`, ThemeData, custom widget | `lib/main.dart`, `lib/app/routes/`, `lib/app/theme/`, `lib/app/widgets/` |
| 3 | CRUD kategori + validasi kosong/duplikat (aplikasi & server) | `kategori_controller.dart`, `backend/.../kategori/` |
| 4 | CRUD menu + gambar + level pedas, suhu sajian, estimasi saji, best seller + JOIN | `menu_admin_controller.dart`, `backend/.../menu/` |
| 5 | Pencarian realtime (Obx + debounce 400 ms) & filter ChoiceChip | `katalog_controller.dart`, `katalog_view.dart` |
| 6 | Home (sapaan), Katalog (GridView), Detail + catatan | `views/home`, `views/katalog`, `views/menu_detail` |
| 7 | Keranjang (CartController, validasi stok, total reaktif, badge) | `cart_controller.dart`, `cart_badge_icon.dart` |
| 8 | Checkout (meja/alamat kondisional, INV, biaya, transaksi stok) | `checkout_controller.dart`, `backend/.../pesanan/checkout.php` |
| 9 | Riwayat & detail pesanan, ubah status (batal → stok kembali) | `pesanan_controller.dart`, `update_status.php` |
| 10 | Dashboard + BarChart, LineChart, PieChart (fl_chart) | `dashboard_view.dart`, `dashboard/summary.php` |
| 11 | Struk PDF: preview, simpan, bagikan | `pdf_generator.dart`, `struk_controller.dart` |
| 12 | Error handling, black box testing, unit test, build | `api_service.dart`, `docs/black_box_testing.md`, `test/` |

Aturan biaya (konstanta di `api_config.dart` **dan** `config/database.php`, dihitung ulang di server):
biaya layanan Rp2.000; ongkir Rp8.000 hanya untuk *Diantar*; diskon 10% jika subtotal ≥ Rp100.000;
**total = subtotal + layanan + ongkir − diskon**.

## 8. Status verifikasi
- `flutter analyze` → **No issues found!** (Flutter 3.41.6 / Dart 3.11.4)
- `flutter test` → **33 test lulus** (validator, kalkulasi biaya, parsing model, ApiService, PDF, widget test katalog/keranjang/checkout)
- `bash scripts/test_api.sh` → **52/52 lulus** terhadap PHP 8.3 + MariaDB 10.11
- Alur aplikasi diuji end-to-end terhadap backend asli (lihat `docs/black_box_testing.md` & `docs/screenshots/`)
- ⚠️ **`flutter build apk --release` belum diuji** di lingkungan pengembangan karena Android SDK/`dl.google.com` tidak dapat diunduh.
  Folder `android/` adalah hasil asli `flutter create` Flutter 3.41.6 (AGP 8.11.1, Kotlin 2.2.20, Gradle 8.14, `kotlinOptions`);
  hanya `AndroidManifest.xml`, `res/xml/network_security_config.xml`, dan ikon launcher yang diubah.

## 9. Troubleshooting
| Masalah | Solusi |
|---|---|
| `The current Dart SDK version is ... version solving failed` | Pastikan `flutter --version` = 3.41.6 / Dart 3.11.4. Jangan menaikkan `sdk:` di pubspec. Hapus `pubspec.lock` lalu `flutter pub get`. Jangan `flutter pub add` dari SDK yang lebih baru. |
| Compile error `ZLibDecoder.decodeLazy` dari package `pdf`/`image` | Pastikan constraint `image: ">=4.5.0 <4.11.0"` tetap ada, lalu `flutter pub get`. |
| `Unresolved reference 'compilerOptions'` / Gradle–AGP mismatch | Jangan upgrade ke AGP 9 / Kotlin `compilerOptions`. Gunakan file Gradle bawaan repo (AGP 8.11.1, Kotlin 2.2.20, wrapper 8.14). Jalankan `flutter clean`, hapus folder `android\.gradle`, lalu build ulang. Pastikan JDK 17 (`flutter doctor -v`). |
| Data kosong / "Tidak dapat terhubung ke server" | XAMPP belum aktif (Start Apache & MySQL), folder belum disalin ke `htdocs\kuliner_api`, atau base URL salah (emulator: `10.0.2.2`, HP: IP laptop). Tes URL di browser HP. |
| "Gagal mengakses database" | Database belum di-import atau MySQL mati. Import ulang `database/db_kuliner.sql`. |
| Gambar menu tidak tampil | Folder `uploads/` belum ikut tersalin ke `htdocs\kuliner_api\uploads`. |
| HP tidak bisa akses tetapi emulator bisa | Firewall Windows memblokir Apache; HP & laptop harus satu Wi-Fi (bukan jaringan tamu/isolasi klien). |

## 10. Bahan pengumpulan
1. Source code ZIP tanpa `build/`: `bash scripts/zip_source.sh` (Git Bash) atau
   `powershell -ExecutionPolicy Bypass -File scripts\zip_source.ps1` (Windows).
2. APK: `build/app/outputs/flutter-apk/app-release.apk`.
3. Laporan PDF: ikuti `docs/panduan_laporan.md`.
