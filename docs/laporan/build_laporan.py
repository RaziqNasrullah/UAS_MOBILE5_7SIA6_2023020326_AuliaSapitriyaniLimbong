"""Membangun Laporan UAS (PDF) aplikasi Delights.

Pemakaian (butuh Python 3 + WeasyPrint: pip install weasyprint):
    python docs/laporan/build_laporan.py
Hasil: docs/Laporan_UAS_Delights_AULIASAPITRIYANILIMBONG_2023020326.pdf
Teks laporan ada di file ini; edit lalu jalankan ulang untuk memperbarui PDF.
"""
from html import escape
from pathlib import Path

HERE = Path(__file__).resolve().parent
DOCS = HERE.parent
OUT = DOCS / "Laporan_UAS_Delights_AULIASAPITRIYANILIMBONG_2023020326.pdf"

NAMA = "AULIA SAPITRIYANI LIMBONG"
NPM = "2023020326"
KELAS = "7SIA6"
REPO = "github.com/RaziqNasrullah/UAS_MOBILE5_7SIA6_2023020326_AuliaSapitriyaniLimbong"

# ----------------------------------------------------------------- helper
_fig = 0
_tab = 0
FIG = {}  # key -> nomor gambar


def fig_no(key):
    return FIG[key]


def figure(key, src, caption, width="100%"):
    global _fig
    _fig += 1
    FIG[key] = _fig
    return (f'<figure class="single"><img src="{src}" style="width:{width}">'
            f'<figcaption>Gambar {_fig}. {caption}</figcaption></figure>')


def shots(items):
    """Grid screenshot 4 kolom. items = [(key, file, caption)]"""
    global _fig
    cells = []
    for key, file, caption in items:
        _fig += 1
        FIG[key] = _fig
        cells.append(f'<figure class="shot"><img src="../screenshots/{file}">'
                     f'<figcaption>Gambar {_fig}. {caption}</figcaption></figure>')
    rows = [cells[i:i + 4] for i in range(0, len(cells), 4)]
    return "".join('<div class="shots">' + "".join(r) + "</div>" for r in rows)


def table(caption, header, rows, widths=None, cls=""):
    global _tab
    _tab += 1
    cols = ""
    if widths:
        cols = "<colgroup>" + "".join(f'<col style="width:{w}">' for w in widths) + "</colgroup>"
    head = "".join(f"<th>{h}</th>" for h in header)
    body = "".join("<tr>" + "".join(f"<td>{c}</td>" for c in r) + "</tr>" for r in rows)
    return (f'<p class="tcap">Tabel {_tab}. {caption}</p>'
            f'<table class="{cls}">{cols}<thead><tr>{head}</tr></thead><tbody>{body}</tbody></table>')


def code(text):
    return f"<pre>{escape(text.strip(chr(10)))}</pre>"


def h1(id_, text):
    return f'<h1 id="{id_}">{text}</h1>'


def h2(id_, text, newpage=False):
    cls = ' class="np"' if newpage else ''
    return f'<h2 id="{id_}"{cls}>{text}</h2>'


# ----------------------------------------------------------------- isi
TOC = [
    ("bab1", "BAB 1 Pendahuluan", [("s11", "1.1 Latar Belakang"), ("s12", "1.2 Tujuan"),
                                   ("s13", "1.3 Identitas Proyek"), ("s14", "1.4 Teknologi yang Digunakan")]),
    ("bab2", "BAB 2 Analisis Kebutuhan Sistem", [("s21", "2.1 Aktor"), ("s22", "2.2 Kebutuhan Fungsional"),
                                                 ("s23", "2.3 Kebutuhan Non-Fungsional")]),
    ("bab3", "BAB 3 Perancangan Sistem", [("s31", "3.1 Use Case Diagram"), ("s32", "3.2 Activity Diagram Proses Checkout"),
                                          ("s33", "3.3 Entity Relationship Diagram (ERD)"), ("s34", "3.4 Normalisasi"),
                                          ("s35", "3.5 Struktur Tabel")]),
    ("bab4", "BAB 4 Implementasi", [("s41", "4.1 Struktur Project Flutter (GetX)"), ("s42", "4.2 Struktur REST API PHP"),
                                    ("s43", "4.3 Routing dan Pengiriman Data Antar Halaman"),
                                    ("s44", "4.4 Implementasi Kunci"), ("s45", "4.5 Tema dan Widget Reusable")]),
    ("bab5", "BAB 5 Tampilan Aplikasi", [("s51", "5.1 Beranda, Katalog, dan Detail Menu"), ("s52", "5.2 Keranjang"),
                                         ("s53", "5.3 Checkout"), ("s54", "5.4 Riwayat dan Detail Pesanan"),
                                         ("s55", "5.5 Kelola Kedai dan Dashboard"), ("s56", "5.6 Kelola Kategori dan Menu")]),
    ("bab6", "BAB 6 Pengujian (Black Box Testing)", [("s61", "6.1 Ringkasan Hasil"), ("s62", "6.2 Pengujian Otomatis Pendukung")]),
    ("bab7", "BAB 7 Contoh Struk PDF", []),
    ("bab8", "BAB 8 Kesimpulan dan Saran", [("s81", "8.1 Kesimpulan"), ("s82", "8.2 Saran"),
                                            ("s83", "8.3 Cara Menjalankan Aplikasi")]),
]


def toc_html():
    out = ['<section class="toc"><h1 class="notoc">Daftar Isi</h1>']
    for id_, title, subs in TOC:
        out.append(f'<a class="t1" href="#{id_}">{title}</a>')
        for sid, st in subs:
            out.append(f'<a class="t2" href="#{sid}">{st}</a>')
    out.append("</section>")
    return "".join(out)


def build_body():
    b = []
    # ============================== BAB 1
    b.append(h1("bab1", "BAB 1 Pendahuluan"))
    b.append(h2("s11", "1.1 Latar Belakang"))
    b.append("""<p>Kafe dan kedai makanan kini semakin ramai dikunjungi, tetapi proses pemesanan di banyak kedai kecil
masih dilakukan secara lisan atau dicatat di kertas. Cara ini membuat pelanggan harus menunggu di kasir, catatan khusus
seperti <i>less sugar</i> atau <i>sambal dipisah</i> mudah terlupa, dan pemilik kedai sulit mengetahui sisa porsi
serta menu yang paling laku.</p>
<p>Untuk menjawab masalah tersebut dibuat <b>Delights</b>, aplikasi mobile pemesanan makanan untuk kedai
<b>SweetnFresh</b>. Pelanggan dapat menjelajah katalog menu, melihat level pedas, suhu sajian, dan estimasi waktu
saji, menambahkan menu ke keranjang beserta catatan per item, lalu checkout untuk makan di tempat, dibawa pulang,
atau diantar. Admin/kasir kedai dapat mengelola kategori dan menu, memproses status pesanan, serta memantau
penjualan melalui dashboard dan grafik.</p>""")
    b.append(h2("s12", "1.2 Tujuan"))
    b.append("""<ul>
<li>Membangun aplikasi Flutter dengan arsitektur <b>GetX</b> untuk state management, routing, dan dependency injection.</li>
<li>Merancang database relasional ternormalisasi (5 tabel) di <b>MySQL XAMPP</b> yang diakses melalui REST API PHP.</li>
<li>Menyediakan alur pemesanan lengkap: katalog &rarr; keranjang (dengan catatan) &rarr; checkout &rarr; struk PDF, dengan stok porsi yang selalu konsisten.</li>
<li>Menyediakan fitur admin/kasir: CRUD kategori &amp; menu, ubah status pesanan, dan dashboard penjualan.</li>
</ul>""")
    b.append(h2("s13", "1.3 Identitas Proyek"))
    b.append(table("Identitas proyek", ["Item", "Keterangan"], [
        ["Nama aplikasi", "Delights &mdash; <i>Your Personal Food Order App</i>"],
        ["Nama kedai", "SweetnFresh"],
        ["Package Android", "com.auliasapitriyani.delights"],
        ["Warna identitas", "#F4845F (coral) dengan pendukung #2F9C95 (mint/teal) dan #FFF4EC (krem), diambil dari logo"],
        ["Penyusun", f"{NAMA} &mdash; NPM {NPM} &mdash; Kelas {KELAS}"],
        ["Repositori", f"{REPO} (branch <code>claude/new-session-6hauu5</code>)"],
    ], ["26%", "74%"]))
    b.append(h2("s14", "1.4 Teknologi yang Digunakan"))
    b.append("""<p>Sistem disusun dalam tiga lapis. Aplikasi Flutter tidak mengakses MySQL secara langsung, melainkan
berkomunikasi lewat REST API PHP yang diletakkan di <code>htdocs/kuliner_api</code>:</p>""")
    b.append(code("Flutter (GetX)  ──HTTP/JSON──►  REST API PHP (XAMPP htdocs/kuliner_api)  ──PDO──►  MySQL (db_kuliner)"))
    b.append(table("Teknologi", ["Lapisan", "Teknologi"], [
        ["Aplikasi mobile", "Flutter 3.41.6 (Dart 3.11.4), GetX 4.7, http, intl, fl_chart (grafik), pdf + printing (struk), path_provider, image_picker, cached_network_image"],
        ["Android build", "AGP 8.11.1, Kotlin 2.2.20, Gradle 8.14, flutter_launcher_icons"],
        ["Backend &amp; database", "PHP 8 + PDO (prepared statement), MySQL/MariaDB XAMPP (InnoDB, utf8mb4)"],
        ["Perancangan", "PlantUML (Use Case, Activity, ERD)"],
    ], ["26%", "74%"]))

    # ============================== BAB 2
    b.append(h1("bab2", "BAB 2 Analisis Kebutuhan Sistem"))
    b.append(h2("s21", "2.1 Aktor"))
    b.append(table("Aktor sistem", ["Aktor", "Peran"], [
        ["Pelanggan", "Menjelajah katalog, mencari &amp; memfilter menu, mengelola keranjang beserta catatan item, checkout, melihat riwayat pesanan, dan mengunduh struk."],
        ["Admin / Kasir Kedai", "Mengelola kategori &amp; menu, mengubah status pesanan (Selesai/Dibatalkan), dan memantau dashboard penjualan."],
    ], ["26%", "74%"]))
    b.append(h2("s22", "2.2 Kebutuhan Fungsional"))
    F = [
        ("Menampilkan beranda: sapaan sesuai waktu (pagi/siang/sore/malam), kategori horizontal, menu best seller, dan menu terbaru.", "Pelanggan"),
        ("Menampilkan katalog menu dalam GridView (gambar, nama, kategori, level pedas, harga).", "Pelanggan"),
        ("Pencarian menu berdasarkan nama secara realtime (debounce 400 ms).", "Pelanggan"),
        ("Filter kategori dengan ChoiceChip termasuk opsi \"Semua\"; dapat dikombinasikan dengan pencarian.", "Pelanggan"),
        ("Detail menu: gambar, kategori, harga, stok, badge level pedas berwarna, suhu sajian, estimasi saji, deskripsi.", "Pelanggan"),
        ("Memilih jumlah dan menulis catatan per item lalu menambahkan ke keranjang; tombol nonaktif bertuliskan \"Habis\" bila stok 0.", "Pelanggan"),
        ("Mengubah jumlah (+/&minus;) di keranjang dengan batas minimal 1 dan maksimal stok; mengedit catatan item.", "Pelanggan"),
        ("Menghapus item dan mengosongkan keranjang.", "Pelanggan"),
        ("Subtotal per item dan total berubah otomatis; badge jumlah item di AppBar &amp; bottom navigation.", "Pelanggan"),
        ("Checkout: nama, nomor HP (08&hellip;, 10&ndash;13 digit), tipe pesanan, nomor meja (wajib bila Makan di Tempat), alamat (wajib bila Diantar), catatan.", "Pelanggan"),
        ("Menghitung subtotal, biaya layanan Rp2.000, ongkir Rp8.000 (Diantar), diskon 10% (subtotal &ge; Rp100.000), dan total.", "Sistem"),
        ("Membuat nomor pesanan otomatis INV-YYYYMMDD-NNN (NNN reset setiap hari) di server.", "Sistem"),
        ("Menyimpan pesanan &amp; detail, mengurangi stok, dan mengosongkan keranjang dalam satu transaksi database.", "Sistem"),
        ("Riwayat pesanan urut terbaru dengan warna status berbeda dan filter status.", "Pelanggan, Admin"),
        ("Detail pesanan: item beserta catatan, rincian biaya, info pemesan, tipe dan meja/alamat.", "Pelanggan, Admin"),
        ("Mengubah status Diproses menjadi Selesai/Dibatalkan; pembatalan mengembalikan stok.", "Admin"),
        ("Struk PDF (logo, nama kedai, no pesanan, tanggal, item, rincian, total): preview, simpan, bagikan.", "Pelanggan, Admin"),
        ("CRUD kategori; nama wajib diisi dan tidak boleh duplikat (case-insensitive) di aplikasi &amp; server.", "Admin"),
        ("Menolak penghapusan kategori yang masih memiliki menu dengan pesan yang jelas.", "Admin"),
        ("CRUD menu: nama, kategori (dropdown FK), harga, stok, deskripsi, gambar galeri, level pedas, suhu sajian, estimasi saji, best seller.", "Admin"),
        ("Daftar menu menampilkan nama kategori hasil query JOIN.", "Admin"),
        ("Dashboard: total pesanan, total pendapatan (Selesai), menu terlaris, BarChart, LineChart, dan PieChart.", "Admin"),
    ]
    b.append(table("Kebutuhan fungsional", ["Kode", "Kebutuhan", "Aktor"],
                   [[f"F-{i+1:02d}", k, a] for i, (k, a) in enumerate(F)], ["9%", "71%", "20%"]))
    b.append(h2("s23", "2.3 Kebutuhan Non-Fungsional"))
    b.append(table("Kebutuhan non-fungsional", ["Kode", "Kategori", "Kebutuhan"], [
        ["NF-01", "Performa", "Timeout request 15 detik (upload 30 detik); pencarian memakai debounce 400 ms; gambar menu di-cache."],
        ["NF-02", "Usability", "Bahasa Indonesia, warna identitas coral #F4845F, indikator loading di setiap proses, pesan sukses/error dengan Get.snackbar, konfirmasi sebelum aksi yang menghapus/membatalkan."],
        ["NF-03", "Usability", "Level pedas ditandai warna berbeda (hijau = tidak pedas, kuning = sedang, oranye = pedas, merah = extra pedas)."],
        ["NF-04", "Keandalan", "Checkout &amp; pembatalan memakai transaksi DB (beginTransaction, SELECT &hellip; FOR UPDATE, commit/rollBack)."],
        ["NF-05", "Keandalan", "Server mati, timeout, respons kosong/bukan JSON, dan stok habis ditangani tanpa crash (try-catch + tombol \"Coba Lagi\")."],
        ["NF-06", "Keamanan", "PDO prepared statement (anti SQL injection); validasi di aplikasi dan server; upload dibatasi JPG/PNG/WEBP &le; 2 MB dan diperiksa dengan getimagesize."],
        ["NF-07", "Integritas data", "Database 3NF dengan FK, UNIQUE, dan CHECK; nama &amp; harga menu disalin ke detail_pesanan (snapshot)."],
        ["NF-08", "Kompatibilitas", "Android 5.0 ke atas (emulator 10.0.2.2 dan HP fisik satu Wi-Fi); HTTP lokal tetap jalan di APK release (usesCleartextTraffic + network_security_config)."],
        ["NF-09", "Maintainability", "Folder GetX terpisah (models, controllers, views, routes, bindings, data/services, widgets, theme, utils); konfigurasi API di api_config.dart."],
        ["NF-10", "Portabilitas", "Base URL dapat diganti tanpa mengubah kode lewat --dart-define=API_BASE_URL."],
    ], ["10%", "18%", "72%"]))

    # ============================== BAB 3
    b.append(h1("bab3", "BAB 3 Perancangan Sistem"))
    b.append(h2("s31", "3.1 Use Case Diagram"))
    b.append("""<p>Terdapat dua aktor. Pelanggan berinteraksi dengan beranda, katalog, keranjang, checkout, riwayat,
dan struk. Admin/Kasir mengelola data master, status pesanan, dan dashboard. Checkout meng-<i>include</i> validasi
stok dan perhitungan biaya, sedangkan pencarian dan filter merupakan <i>extend</i> dari katalog. Pengembalian stok
terjadi sebagai <i>extend</i> ketika pesanan dibatalkan.</p>""")
    b.append(figure("uc", "../diagram/use_case.png", "Use Case Diagram aplikasi Delights", "86%"))
    b.append(h2("s32", "3.2 Activity Diagram Proses Checkout", True))
    b.append("""<p>Diagram aktivitas memakai dua swimlane (Pelanggan/Aplikasi Flutter dan Server REST API) mulai dari
memilih menu sampai struk PDF. Seluruh penyimpanan pesanan dijalankan dalam satu transaksi; bila stok salah satu
item tidak mencukupi, transaksi di-<i>rollback</i>.</p>""")
    b.append(figure("act", "../diagram/activity_checkout.png", "Activity Diagram proses pemesanan / checkout", "44%"))
    b.append(h2("s33", "3.3 Entity Relationship Diagram (ERD)"))
    b.append(figure("erd", "../diagram/erd.png", "ERD database db_kuliner", "80%"))
    b.append(table("Relasi dan kardinalitas", ["Relasi", "Kardinalitas", "Aturan FK", "Penjelasan"], [
        ["kategori &rarr; menu", "1 : N", "ON DELETE RESTRICT", "Kategori yang masih memiliki menu tidak dapat dihapus."],
        ["menu &rarr; keranjang", "1 : 0..1", "ON DELETE CASCADE", "menu_id UNIQUE sehingga satu menu hanya satu baris di keranjang."],
        ["pesanan &rarr; detail_pesanan", "1 : N", "ON DELETE CASCADE", "Satu pesanan berisi satu atau lebih item."],
        ["menu &rarr; detail_pesanan", "1 : N", "ON DELETE SET NULL", "Riwayat tetap utuh walau menu dihapus (nama &amp; harga disalin)."],
    ], ["24%", "13%", "21%", "42%"]))
    b.append(h2("s34", "3.4 Normalisasi"))
    b.append("""<ul>
<li><b>UNF</b> &mdash; satu nota pesanan memuat data pemesan dan daftar menu yang berulang (nama menu, kategori, harga, jumlah) di satu baris.</li>
<li><b>1NF</b> &mdash; grup berulang dipecah sehingga setiap item pesanan menjadi baris tersendiri dan semua kolom bernilai atomik; kunci komposit (nomor_pesanan, nama_menu).</li>
<li><b>2NF</b> &mdash; ketergantungan parsial dihilangkan: atribut yang hanya bergantung pada nomor pesanan dipindah ke <b>pesanan</b>, atribut yang hanya bergantung pada menu dipindah ke <b>menu</b>, sisanya (jumlah, catatan, subtotal) menjadi <b>detail_pesanan</b>.</li>
<li><b>3NF</b> &mdash; ketergantungan transitif (menu &rarr; kategori &rarr; nama kategori) dihilangkan dengan memisahkan tabel <b>kategori</b>; menu cukup menyimpan <code>kategori_id</code> dan nama kategori diambil lewat JOIN. Keranjang disimpan di tabel <b>keranjang</b> yang hanya berisi menu_id, jumlah, dan catatan.</li>
</ul>
<p class="note">Kolom <code>nama_menu</code> dan <code>harga_satuan</code> pada detail_pesanan serta kolom biaya pada pesanan
adalah <i>snapshot</i> historis yang sengaja disimpan agar nilai transaksi lama tidak berubah ketika menu atau aturan biaya diubah.</p>""")
    b.append(h2("s35", "3.5 Struktur Tabel"))
    b.append(table("Struktur tabel database", ["Tabel", "Kolom utama", "Kunci &amp; batasan"], [
        ["kategori", "id, nama, deskripsi, ikon, created_at, updated_at", "PK id; UNIQUE nama"],
        ["menu", "id, kategori_id, nama, harga, stok, deskripsi, gambar, level_pedas, suhu_sajian, estimasi_saji, is_best_seller, created_at, updated_at", "PK id; FK kategori_id (RESTRICT); CHECK harga &gt; 0, estimasi_saji &gt; 0; stok UNSIGNED; level_pedas &amp; suhu_sajian ENUM"],
        ["keranjang", "id, menu_id, jumlah, catatan_item, created_at", "PK id; FK + UNIQUE menu_id (CASCADE); CHECK jumlah &ge; 1"],
        ["pesanan", "id, nomor_pesanan, nama_pemesan, no_hp, tipe_pesanan, nomor_meja, alamat, catatan, subtotal, biaya_layanan, ongkir, diskon, total, status, tanggal", "PK id; UNIQUE nomor_pesanan; tipe &amp; status ENUM"],
        ["detail_pesanan", "id, pesanan_id, menu_id, nama_menu, harga_satuan, jumlah, catatan_item, subtotal", "PK id; FK pesanan_id (CASCADE); FK menu_id (SET NULL)"],
    ], ["17%", "48%", "35%"]))
    b.append("""<p>Data seed berisi <b>4 kategori</b> (Makanan Utama, Minuman, Snack, Dessert) dan <b>20 menu</b> (5 per
kategori) lengkap dengan level pedas, suhu sajian, estimasi saji, dan gambar; satu menu sengaja berstok 0 untuk uji
"Habis", lima menu best seller, serta lima contoh pesanan beberapa hari terakhir agar dashboard langsung terisi.</p>""")

    # ============================== BAB 4
    b.append(h1("bab4", "BAB 4 Implementasi"))
    b.append(h2("s41", "4.1 Struktur Project Flutter (GetX)"))
    b.append(code("""
lib/
├── main.dart              # GetMaterialApp + ThemeData + initialBinding + locale id_ID
└── app/
    ├── models/            # kategori, menu, keranjang_item, pesanan, detail_pesanan, dashboard_summary
    ├── controllers/       # main, home, katalog, menu_detail, cart, checkout, pesanan,
    │                      # dashboard, kategori (+form), menu_admin (+form), struk
    ├── views/             # satu folder per halaman
    ├── routes/            # app_routes.dart (nama route) + app_pages.dart (GetPage)
    ├── bindings/          # InitialBinding + binding per halaman (lazyPut)
    ├── data/services/     # api_config, api_service (http), kategori/menu/keranjang/pesanan/dashboard
    ├── widgets/           # MenuCard, CategoryChip, CartBadgeIcon, CustomTextField, SummaryCard,
    │                      # EmptyState/ErrorState, LevelPedasBadge, StatusBadge, QtyStepper, BiayaRow
    ├── theme/             # app_theme.dart (ThemeData + AppColors)
    └── utils/             # formatter, validators, biaya_calculator, pdf_generator, app_snackbar
"""))
    b.append(h2("s42", "4.2 Struktur REST API PHP"))
    b.append(code("""
kuliner_api/
├── config/database.php    # koneksi PDO + konstanta biaya
├── helpers/response.php   # JSON seragam, CORS, handler error
├── kategori/              # read, create, update, delete
├── menu/                  # read (?search=&kategori_id=), detail, create, update, delete, upload_gambar
├── keranjang/             # read, add, update_qty, update_catatan, delete, clear
├── pesanan/               # checkout, read, detail, update_status
├── dashboard/             # summary
└── uploads/               # gambar menu
"""))
    b.append("""<p>Setiap endpoint mengembalikan format <code>{ "success": true|false, "message": "...", "data": ... }</code>
dengan HTTP status yang sesuai (200/201 sukses, 404 tidak ditemukan, 405 method salah, 409 duplikat/konflik stok,
422 validasi, 500 kesalahan server).</p>""")
    b.append(h2("s43", "4.3 Routing dan Pengiriman Data Antar Halaman"))
    b.append("""<p>Aplikasi memakai <code>GetMaterialApp</code> dengan daftar <code>GetPage</code>. Perpindahan halaman
menggunakan <code>Get.toNamed</code> dan data dikirim melalui <code>arguments</code>:</p>""")
    b.append(table("Route dan arguments", ["Dari", "Ke", "Argumen"], [
        ["Beranda / Katalog", "/menu-detail", "objek Menu"],
        ["Riwayat / Halaman sukses", "/pesanan-detail", "id pesanan (int)"],
        ["Checkout", "/checkout-sukses", "objek Pesanan hasil checkout (Get.offNamed)"],
        ["Halaman sukses / Detail pesanan", "/struk", "objek Pesanan lengkap untuk PDF"],
        ["Kelola Kategori / Kelola Menu", "/kategori-form, /menu-form", "objek yang diedit (null = tambah baru)"],
    ], ["34%", "28%", "38%"]))
    b.append(h2("s44", "4.4 Implementasi Kunci"))
    b.append("""<p><b>Pencarian realtime dan filter.</b> Kata kunci disimpan di variabel <code>.obs</code>; <code>debounce</code>
GetX menunda request selama 400 ms, sedangkan perubahan kategori langsung memuat ulang data. Keduanya dikirim
bersamaan ke server sehingga dapat dikombinasikan.</p>""")
    b.append(code("""
debounce<String>(keyword, (_) => fetchMenus(), time: const Duration(milliseconds: 400));
ever<int?>(selectedKategoriId, (_) => fetchMenus());
"""))
    b.append("""<p><b>Keranjang reaktif.</b> <code>CartController</code> didaftarkan permanen; total item, subtotal, dan badge
dihitung dari <code>items.obs</code> sehingga setiap widget <code>Obx</code> ikut berubah otomatis. Penambahan jumlah
dicek terhadap stok di aplikasi dan diperiksa ulang di server.</p>
<p><b>Checkout dalam satu transaksi.</b> Server mengunci baris keranjang dan menu, memvalidasi ulang stok, membuat
nomor INV, menyimpan pesanan beserta detail, mengurangi stok, lalu mengosongkan keranjang. Bila ada langkah yang
gagal, seluruh perubahan dibatalkan.</p>""")
    b.append(code("""
$db->beginTransaction();
$items = $db->query('SELECT c.menu_id, c.jumlah, c.catatan_item, m.nama, m.harga, m.stok
                     FROM keranjang c JOIN menu m ON m.id = c.menu_id FOR UPDATE')->fetchAll();
// validasi stok ... jika kurang -> $db->rollBack() + HTTP 409
$prefix = 'INV-' . date('Ymd') . '-';                // NNN reset setiap hari
$stmt = $db->prepare('SELECT nomor_pesanan FROM pesanan WHERE nomor_pesanan LIKE ?
                      ORDER BY nomor_pesanan DESC LIMIT 1 FOR UPDATE');
$nomor = $prefix . str_pad((string) $urut, 3, '0', STR_PAD_LEFT);   // INV-20261014-002
// INSERT pesanan, INSERT detail_pesanan, UPDATE menu SET stok = stok - ?, DELETE FROM keranjang
$db->commit();
"""))
    b.append("""<p><b>Aturan biaya.</b> Biaya layanan Rp2.000, ongkir Rp8.000 hanya untuk tipe Diantar, diskon 10% bila
subtotal &ge; Rp100.000; total = subtotal + biaya layanan + ongkir &minus; diskon. Konstanta disimpan di
<code>api_config.dart</code> dan <code>config/database.php</code>, dan nilai akhirnya dihitung ulang di server.</p>
<p><b>Error handling.</b> <code>ApiService</code> membungkus setiap request dengan try-catch untuk timeout, server tidak
terjangkau, respons kosong, dan respons bukan JSON. Pesan diterjemahkan menjadi kalimat yang mudah dipahami lalu
ditampilkan dengan <code>Get.snackbar</code> atau tampilan error dengan tombol "Coba Lagi".</p>""")
    b.append(h2("s45", "4.5 Tema dan Widget Reusable"))
    b.append("""<p>Seluruh tampilan memakai satu <code>ThemeData</code> (<code>AppTheme.light</code>) yang mengatur warna
identitas, AppBar, tombol, input, card, chip, dialog, dan navigation bar. Widget yang dipakai ulang:</p>""")
    b.append(table("Widget reusable", ["Widget", "Fungsi"], [
        ["MenuCard", "Kartu menu di Grid katalog &amp; daftar best seller (gambar, label best seller/HABIS, level pedas, harga, tombol tambah)"],
        ["CategoryChip", "ChoiceChip kategori/status untuk filter"],
        ["CartBadgeIcon", "Ikon keranjang dengan badge jumlah item (Obx) di AppBar &amp; bottom navigation"],
        ["CustomTextField", "TextFormField seragam dengan label, tanda wajib, ikon, dan validator"],
        ["SummaryCard", "Kartu ringkasan angka pada dashboard"],
        ["EmptyState / ErrorState / LoadingView", "Tampilan data kosong, error dengan tombol \"Coba Lagi\", dan loading"],
        ["LevelPedasBadge, StatusBadge, QtyStepper, BiayaRow", "Badge level pedas, label status pesanan, tombol +/&minus; jumlah, baris rincian biaya"],
    ], ["34%", "66%"]))

    # ============================== BAB 5
    b.append(h1("bab5", "BAB 5 Tampilan Aplikasi"))
    b.append("""<p>Screenshot berikut diambil dari antarmuka Delights yang terhubung ke REST API dan database
<code>db_kuliner</code> (data seed dan transaksi uji), dengan ukuran layar ponsel 392 &times; 850 dp.</p>""")
    b.append(h2("s51", "5.1 Beranda, Katalog, dan Detail Menu"))
    b.append(shots([
        ("beranda", "01_beranda.jpg", "Beranda: sapaan, kategori, best seller"),
        ("katalog", "02_katalog.jpg", "Katalog (GridView) + filter \"Semua\""),
        ("filter", "03_filter_kategori.jpg", "Filter kategori \"Minuman\""),
        ("cari", "04_pencarian_filter.jpg", "Pencarian \"kopi\" + filter Minuman"),
        ("detail", "05_detail_menu.jpg", "Detail menu: catatan &amp; jumlah"),
        ("habis", "06_detail_habis.jpg", "Menu stok habis: tombol nonaktif"),
    ]))
    b.append(h2("s52", "5.2 Keranjang"))
    b.append(shots([
        ("tambah", "07_tambah_keranjang_badge.jpg", "Snackbar tambah ke keranjang &amp; badge"),
        ("catatan", "08_dialog_catatan.jpg", "Dialog edit catatan item"),
        ("keranjang", "09_keranjang.jpg", "Keranjang: subtotal, total, info diskon"),
    ]))
    b.append(h2("s53", "5.3 Checkout"))
    b.append(shots([
        ("co_valid", "10_checkout_validasi.jpg", "Validasi form checkout kosong"),
        ("co_antar", "11_checkout_diantar.jpg", "Tipe Diantar: alamat muncul &amp; wajib"),
        ("co_biaya", "12_checkout_rincian_biaya.jpg", "Rincian biaya: ongkir &amp; diskon 10%"),
        ("co_sukses", "13_checkout_sukses.jpg", "Pesanan berhasil (INV-20261014-002)"),
    ]))
    b.append(h2("s54", "5.4 Riwayat dan Detail Pesanan"))
    b.append(shots([
        ("riwayat", "14_riwayat_pesanan.jpg", "Riwayat urut terbaru, status berwarna"),
        ("filter_status", "18_filter_status.jpg", "Filter status \"Dibatalkan\""),
        ("detail_psn", "15_detail_pesanan.jpg", "Detail pesanan: pemesan, item, biaya"),
        ("dlg_batal", "16_dialog_batalkan.jpg", "Konfirmasi batalkan pesanan"),
        ("dibatalkan", "17_pesanan_dibatalkan.jpg", "Pesanan dibatalkan, stok dikembalikan"),
    ]))
    b.append(h2("s55", "5.5 Kelola Kedai dan Dashboard"))
    b.append(shots([
        ("kelola", "22_kelola.jpg", "Menu Kelola Kedai (admin)"),
        ("dash", "19_dashboard.jpg", "Dashboard: kartu ringkasan"),
        ("bar", "20_dashboard_barchart.jpg", "BarChart 5 menu terlaris"),
        ("line", "21_dashboard_linechart.jpg", "LineChart pendapatan 7 hari &amp; PieChart"),
    ]))
    b.append(h2("s56", "5.6 Kelola Kategori dan Menu"))
    b.append(shots([
        ("kat_list", "25_kategori_tambah.jpg", "Daftar kategori + jumlah menu"),
        ("kat_kosong", "31_kategori_form_kosong.jpg", "Validasi nama kategori kosong"),
        ("kat_dup", "24_kategori_duplikat.jpg", "Validasi nama kategori duplikat"),
        ("kat_hapus", "23_kategori_hapus_ditolak.jpg", "Hapus kategori berisi menu ditolak"),
        ("menu_list", "26_menu_admin.jpg", "Daftar menu (nama kategori via JOIN)"),
        ("menu_form", "27_menu_form.jpg", "Form menu: kategori, harga, stok, deskripsi"),
        ("menu_attr", "28_menu_form_bestseller.jpg", "Atribut kuliner &amp; switch best seller"),
        ("menu_ok", "29_menu_tersimpan.jpg", "Menu baru berhasil disimpan"),
        ("server_mati", "30_error_server_mati.jpg", "Server mati: pesan error + \"Coba Lagi\""),
    ]))

    # ============================== BAB 6
    b.append(h1("bab6", "BAB 6 Pengujian (Black Box Testing)"))
    b.append("""<p>Pengujian memakai metode <i>black box</i> dengan teknik <i>equivalence partitioning</i> dan
<i>boundary value</i>. Setiap skenario dijalankan melalui antarmuka aplikasi dan/atau langsung ke endpoint REST API
yang terhubung ke database MySQL; hasilnya dicocokkan dengan isi database (stok, nomor pesanan, status).</p>""")
    G = fig_no
    OK = '<span class="ok">Berhasil</span>'
    PEND = '<span class="pend">Perlu diuji di HP</span>'
    rows = [
        ["Kategori &ndash; validasi kosong", "Simpan kategori dengan nama kosong", "Ditolak: \"Nama kategori wajib diisi\"", f"Form menampilkan pesan wajib diisi (Gambar {G('kat_kosong')}); API membalas HTTP 422. Tidak ada data baru.", OK],
        ["Kategori &ndash; duplikat", "Tambah \"minuman\" (sudah ada \"Minuman\")", "Ditolak: nama sudah ada", f"Pesan <i>Kategori \"minuman\" sudah ada</i> (Gambar {G('kat_dup')}); API membalas 409 (case-insensitive).", OK],
        ["Kategori &ndash; tambah", "Tambah \"Paket Hemat\" + deskripsi", "Data tersimpan &amp; tampil", f"Snackbar \"Kategori berhasil ditambahkan\", muncul dengan 0 menu (Gambar {G('kat_list')}).", OK],
        ["Kategori &ndash; ubah &amp; hapus", "Ubah nama kategori, hapus kategori kosong", "Data berubah / terhapus", "API: update berhasil (200), ubah ke nama yang sudah ada ditolak (409), hapus kategori kosong berhasil.", OK],
        ["Kategori &ndash; hapus berisi menu", "Hapus kategori \"Snack\"", "Ditolak dengan pesan jelas", f"Snackbar <i>Kategori \"Snack\" masih memiliki 5 menu</i> (Gambar {G('kat_hapus')}); API 409.", OK],
        ["Menu &ndash; validasi", "Simpan menu field kosong, harga 0, stok &minus;1, estimasi 0", "Pesan wajib diisi, tidak tersimpan", "API membalas 422 beserta daftar error per field; validator aplikasi lulus unit test.", OK],
        ["Menu &ndash; tambah", "Tambah \"Paket Nasi Goreng + Es Teh\" kategori Paket Hemat, best seller", "Tersimpan dengan FK benar", f"Snackbar sukses (Gambar {G('menu_ok')}); di database kategori_id = Paket Hemat, is_best_seller = 1.", OK],
        ["Menu &ndash; upload gambar", "Upload PNG lalu file teks", "Gambar diterima, file bukan gambar ditolak", "PNG tersimpan sebagai menu_&hellip;png (201); file teks ditolak 422 \"Format gambar harus JPG, PNG, atau WEBP\". Pemilihan dari galeri HP perlu dicoba di perangkat.", OK],
        ["Menu &ndash; hapus", "Hapus menu yang pernah dipesan", "Menu hilang, riwayat utuh", "Menu terhapus (200); detail pesanan lama tetap menampilkan nama menu (snapshot).", OK],
        ["Pencarian realtime", "Ketik \"kopi\" di katalog", "Daftar tersaring tanpa tombol cari", f"Muncul &quot;1 hasil untuk \'kopi\'&quot; (Gambar {G('cari')}); request terkirim setelah jeda 400 ms.", OK],
        ["Filter + kombinasi", "Chip \"Minuman\" lalu cari \"kopi\"", "Hanya menu yang sesuai", f"Filter menampilkan 5 menu Minuman (Gambar {G('filter')}); kombinasi \"kopi\" + Minuman = 1 menu.", OK],
        ["Menu stok habis", "Buka Ayam Geprek Keju Mozarella (stok 0)", "Tombol nonaktif \"Habis\"", f"Label HABIS dan tombol abu-abu \"Habis\" (Gambar {G('habis')}); API menolak tambah ke keranjang (422).", OK],
        ["Tambah ke keranjang", "Kopi Susu &times;3 + catatan \"less sugar\"", "Snackbar sukses, badge bertambah", f"Snackbar \"ditambahkan ke keranjang\" dan badge 4 (Gambar {G('tambah')}); catatan tersimpan di database.", OK],
        ["Qty melebihi stok", "Tambah/ubah jumlah melebihi stok", "Ditolak dengan pesan sisa stok", "Tombol + nonaktif saat jumlah = stok; API menolak jumlah &gt; stok dan jumlah &lt; 1 (422).", OK],
        ["Total reaktif &amp; catatan", "Ubah qty 3&rarr;4, edit catatan item", "Subtotal &amp; total berubah otomatis", f"Subtotal Rp80.000, total Rp115.000; catatan \"saus kari dipisah\" tersimpan (Gambar {G('catatan')}&ndash;{G('keranjang')}).", OK],
        ["Checkout &ndash; form kosong", "Buat Pesanan tanpa nama &amp; HP", "Pesan validasi", f"Pesan wajib diisi pada nama, HP, nomor meja + snackbar \"Periksa kembali\" (Gambar {G('co_valid')}).", OK],
        ["Checkout &ndash; no HP salah", "Isi HP \"62812345\"", "Pesan format HP", "Validator menolak (harus diawali 08, 10&ndash;13 digit); API juga membalas 422.", OK],
        ["Meja/alamat sesuai tipe", "Pilih Diantar", "Field alamat muncul &amp; wajib", f"Field \"Alamat pengantaran *\" muncul, meja hilang, ongkir masuk rincian (Gambar {G('co_antar')}).", OK],
        ["Checkout sukses + stok", "Checkout Kopi Susu 4 + Chicken Katsu 1", "Pesanan tersimpan, stok berkurang, keranjang kosong", f"Halaman sukses INV-20261014-002 (Gambar {G('co_sukses')}); stok Chicken Katsu 15&rarr;14, Kopi Susu 40&rarr;36; keranjang kosong.", OK],
        ["Perhitungan biaya", "Subtotal Rp115.000, Diantar", "Layanan 2.000, ongkir 8.000, diskon 10%", f"Rp115.000 + Rp2.000 + Rp8.000 &minus; Rp11.500 = <b>Rp113.500</b>, sama di aplikasi dan database (Gambar {G('co_biaya')}).", OK],
        ["Nomor INV otomatis", "Beberapa pesanan di hari yang sama", "INV-YYYYMMDD-001, -002, -003", "Berurutan INV-20261014-002, -003; pesanan tanggal lain dimulai lagi dari -001.", OK],
        ["Riwayat urut terbaru", "Buka tab Pesanan", "Terbaru di atas, status berwarna", f"Pesanan terbaru di atas; Diproses kuning, Selesai hijau, Dibatalkan merah; filter status berfungsi (Gambar {G('riwayat')}&ndash;{G('filter_status')}).", OK],
        ["Ubah status &amp; stok kembali", "Batalkan INV-20261014-002", "Status Dibatalkan, stok kembali", f"Snackbar \"stok 2 menu dikembalikan\" (Gambar {G('dibatalkan')}); stok 14&rarr;15 dan 36&rarr;40; ubah lagi ditolak (409).", OK],
        ["Dashboard", "Buka Dashboard Penjualan", "Ringkasan + grafik tampil", f"6 pesanan, pendapatan Rp327.500, terlaris Kopi Susu Gula Aren; BarChart, LineChart, PieChart tampil (Gambar {G('dash')}&ndash;{G('line')}).", OK],
        ["Export struk PDF", "Cetak struk INV-20261014-002", "PDF berisi data kedai, pesanan, item, total", "PDF berisi logo, SweetnFresh, nomor, tanggal, alamat, item + catatan, rincian dan total Rp113.500 (Bab 7).", OK],
        ["Simpan &amp; bagikan PDF", "Tekan Simpan PDF dan Bagikan", "File tersimpan di folder Download aplikasi, share sheet terbuka", "Fitur penyimpanan dan berbagi berjalan di Android; isi kolom ini setelah dicoba di HP.", PEND],
        ["Server mati", "Matikan server lalu buka aplikasi", "Pesan error + \"Coba Lagi\", tidak crash", f"Tampil \"Oops, data gagal dimuat\" dengan tombol \"Coba Lagi\" (Gambar {G('server_mati')}); data muncul kembali setelah server aktif.", OK],
        ["Build &amp; instal APK", "flutter build apk --release lalu instal di HP", "Aplikasi \"Delights\" terpasang dan terhubung ke API via IP LAN", "Isi kolom ini setelah APK dibangun dan diinstal di HP.", PEND],
    ]
    b.append(table("Hasil black box testing", ["No", "Fitur", "Skenario", "Hasil yang Diharapkan", "Hasil Aktual", "Status"],
                   [[str(i + 1)] + r for i, r in enumerate(rows)],
                   ["5%", "15%", "18%", "17%", "33%", "12%"], cls="bb"))
    n_ok = sum(1 for r in rows if r[-1] == OK)
    n_pend = len(rows) - n_ok
    b.append(h2("s61", "6.1 Ringkasan Hasil"))
    b.append(table("Ringkasan black box testing", ["Total skenario", "Berhasil", "Gagal", "Perlu diuji di HP"],
                   [[str(len(rows)), str(n_ok), "0", str(n_pend)]]))
    b.append(h2("s62", "6.2 Pengujian Otomatis Pendukung"))
    b.append("""<p>Selain black box, project dilengkapi pengujian otomatis. <code>flutter test</code> menjalankan
<b>33 test</b> (validator form, kalkulasi biaya termasuk batas diskon Rp100.000, parsing model JSON, penanganan error
API, pembuatan struk PDF, serta widget test katalog, keranjang, dan checkout) dan seluruhnya lulus;
<code>flutter analyze</code> tidak menemukan masalah. Skrip <code>scripts/test_api.sh</code> menguji seluruh endpoint
REST API dengan curl dan memberikan hasil <b>52 dari 52</b> pemeriksaan lulus.</p>""")

    # ============================== BAB 7
    b.append(h1("bab7", "BAB 7 Contoh Struk PDF"))
    b.append("""<p>Struk dibuat dengan package <code>pdf</code> dalam format kertas thermal 80 mm dan ditampilkan memakai
<code>PdfPreview</code> dari package <code>printing</code>. Pengguna dapat menyimpan file ke folder Download aplikasi
(path ditampilkan di snackbar) atau membagikannya. Berikut struk untuk pesanan <b>INV-20261014-002</b> hasil
pengujian checkout.</p>""")
    b.append('<p class="note">Teks struk memakai font bawaan PDF (Latin-1); karakter seperti tanda pisah panjang, kutip '
             'miring, dan emoji dari catatan pelanggan otomatis diganti atau dibuang agar PDF selalu terbaca.</p>')
    b.append(figure("struk", "img/struk_INV-20261014-002.png", "Struk PDF pesanan INV-20261014-002", "35%"))
    b.append(table("Isi struk PDF", ["Isi struk", "Keterangan"], [
        ["Header", "Logo Delights, nama kedai SweetnFresh, alamat dan telepon kedai"],
        ["Info pesanan", "Nomor pesanan, tanggal, nama pemesan, no HP, tipe pesanan, nomor meja/alamat, status"],
        ["Daftar item", "Nama menu, qty &times; harga satuan (snapshot), catatan item, subtotal"],
        ["Rincian biaya", "Subtotal, biaya layanan, ongkir, diskon, TOTAL BAYAR"],
        ["Penutup", "Catatan pesanan (bila ada) dan ucapan terima kasih"],
    ], ["26%", "74%"]))

    # ============================== BAB 8
    b.append(h1("bab8", "BAB 8 Kesimpulan dan Saran"))
    b.append(h2("s81", "8.1 Kesimpulan"))
    b.append(f"""<ul>
<li>Aplikasi <b>Delights</b> berhasil dibangun dengan Flutter dan arsitektur GetX (controller, binding, route, Obx) yang terhubung ke MySQL XAMPP melalui REST API PHP dengan PDO.</li>
<li>Seluruh 12 fitur wajib terpenuhi: analisis &amp; perancangan, setup GetX, CRUD kategori, CRUD menu + relasi, pencarian &amp; filter, beranda/katalog/detail, keranjang, checkout, riwayat, dashboard, struk PDF, serta error handling dan pengujian.</li>
<li>Database dirancang ternormalisasi (3NF) dengan 5 tabel dan foreign key; checkout dan pembatalan berjalan dalam transaksi sehingga stok porsi selalu konsisten.</li>
<li>Atribut khusus tema kuliner (level pedas berwarna, suhu sajian, estimasi saji, best seller) dan catatan per item membantu pelanggan memesan sesuai selera.</li>
<li>Sebanyak {n_ok} dari {len(rows)} skenario black box memberikan hasil sesuai harapan, {n_pend} skenario khusus perangkat Android perlu dikonfirmasi di HP, dan 33 unit/widget test lulus.</li>
</ul>""")
    b.append(h2("s82", "8.2 Saran"))
    b.append("""<ul>
<li>Menambahkan autentikasi (login pelanggan dan admin) agar menu Kelola hanya dapat diakses kasir/pemilik kedai.</li>
<li>Menambahkan keranjang per pengguna dan notifikasi ketika status pesanan berubah.</li>
<li>Menambahkan pembayaran non-tunai (QRIS/e-wallet) dan pelacakan pengantaran.</li>
<li>Menambahkan fitur ulasan dan rating menu untuk membantu pelanggan memilih.</li>
</ul>""")
    b.append(h2("s83", "8.3 Cara Menjalankan Aplikasi"))
    b.append("""<ul>
<li>Jalankan Apache &amp; MySQL di XAMPP, lalu import <code>database/db_kuliner.sql</code> melalui phpMyAdmin.</li>
<li>Salin folder <code>backend/kuliner_api</code> ke <code>C:\\xampp\\htdocs\\kuliner_api</code> lalu buka <code>http://localhost/kuliner_api/</code> untuk memastikan API aktif.</li>
<li>Jalankan <code>flutter pub get</code> lalu <code>flutter run</code> (emulator memakai <code>http://10.0.2.2/kuliner_api</code>; HP fisik memakai <code>--dart-define=API_BASE_URL=http://&lt;IP-laptop&gt;/kuliner_api</code>).</li>
<li>Build APK: <code>flutter build apk --release</code> &rarr; <code>build/app/outputs/flutter-apk/app-release.apk</code>.</li>
</ul>""")
    return "".join(b)


CSS = """
@page { size: A4; margin: 22mm 18mm 20mm 18mm;
  @top-left { content: "Laporan UAS \\2014 Delights (Kedai SweetnFresh)"; font: 8pt 'Liberation Sans'; color:#7b8a90;
              border-bottom: 1.2pt solid #F4845F; padding-bottom: 3mm; vertical-align: bottom; width: 58%; }
  @top-right { content: "AULIA SAPITRIYANI LIMBONG \\00B7 2023020326 \\00B7 7SIA6"; font: 8pt 'Liberation Sans'; color:#7b8a90;
               border-bottom: 1.2pt solid #F4845F; padding-bottom: 3mm; vertical-align: bottom; width: 42%; text-align: right; }
  @bottom-center { content: counter(page); font: 8pt 'Liberation Sans'; color:#7b8a90; } }
@page cover { margin: 0; @top-left { content: none; border: 0 } @top-right { content: none; border: 0 } @bottom-center { content: none } }
@page toc { @bottom-center { content: counter(page); } }
html { font-family: 'Liberation Sans', Arial, sans-serif; font-size: 10.5pt; color: #222; line-height: 1.45; }
.cover { page: cover; height: 297mm; text-align: center; padding-top: 30mm; box-sizing: border-box; }
.cover .t1 { color:#1F5F66; font-size: 19pt; font-weight: bold; letter-spacing: .3pt; }
.cover .t2 { font-size: 12pt; margin-top: 1mm; }
.cover img { width: 70mm; margin: 14mm 0 2mm; }
.cover .sub { font-size: 12pt; line-height: 1.6; margin-top: 4mm; }
.cover table.id { margin: 18mm auto 0; border: 0; width: 95mm; font-size: 11pt; }
.cover table.id td { border: 0; padding: 1.5mm 0; text-align: left; background: none; }
.cover .year { font-size: 13pt; font-weight: bold; margin-top: 24mm; }
.toc { page: toc; break-after: page; }
.toc a { display: block; text-decoration: none; color: #222; }
.toc a::after { content: leader('. ') target-counter(attr(href), page); }
.toc a.t1 { font-weight: bold; margin-top: 3.2mm; font-size: 10.5pt; }
.toc a.t2 { margin-left: 6mm; font-size: 9.2pt; margin-top: .6mm; }
h1 { color: #1F5F66; font-size: 19pt; margin: 0 0 6mm; break-before: page; }
h1.notoc { break-before: auto; }
h2.np { break-before: page; }
h2 { color: #1F5F66; font-size: 13pt; margin: 6mm 0 2.5mm; break-after: avoid; }
p { margin: 0 0 2.5mm; text-align: justify; }
ul { margin: 0 0 3mm; padding-left: 6mm; } li { margin-bottom: 1mm; }
code { font-family: 'DejaVu Sans Mono', monospace; font-size: 8.6pt; }
pre { font-family: 'DejaVu Sans Mono', monospace; font-size: 7.6pt; background: #f6f6f4; border: .6pt solid #e2e2de;
      padding: 3mm; white-space: pre-wrap; margin: 0 0 3.5mm; break-inside: avoid; line-height: 1.35; }
.tcap, figcaption { text-align: center; color: #7b8a90; font-style: italic; font-size: 9pt; margin: 3mm 0 1.5mm; }
table { width: 100%; border-collapse: collapse; font-size: 8.6pt; margin-bottom: 4mm; }
thead { display: table-header-group; }
th { background: #1F5F66; color: #fff; text-align: left; padding: 1.6mm 2mm; font-weight: bold; }
td { border: .5pt solid #d9dcdc; padding: 1.4mm 2mm; vertical-align: top; }
tbody tr:nth-child(even) td { background: #FFF4EC; }
tr { break-inside: avoid; }
table.bb { font-size: 7.8pt; }
.ok { color: #2E9E5B; font-weight: bold; } .pend { color: #E0663F; font-weight: bold; }
.note { font-size: 9pt; color: #555; }
figure.single { text-align: center; margin: 2mm 0 4mm; break-inside: avoid; }
.shots { display: flex; gap: 3.2mm; margin: 2mm 0 3mm; break-inside: avoid; }
figure.shot { width: 40.5mm; margin: 0; break-inside: avoid; }
figure.shot img { width: 100%; border: .6pt solid #d9dcdc; display: block; }
figure.shot figcaption { margin-top: 1.5mm; font-size: 8.3pt; line-height: 1.3; }
"""


def build_html():
    body = build_body()  # dibangun dulu agar nomor gambar terisi
    cover = f"""<section class="cover">
<div class="t1">LAPORAN UJIAN AKHIR SEMESTER</div><div class="t2">Pemrograman Mobile</div>
<img src="../../assets/images/logo.png">
<div class="sub">Aplikasi Pemesanan Makanan &amp; Minuman Kedai <b>SweetnFresh</b><br>
Katalog, Keranjang, dan Pemesanan Menu Kafe<br>berbasis Flutter (GetX) dan MySQL XAMPP</div>
<table class="id"><tr><td colspan="2" style="text-align:center;padding-bottom:4mm">Disusun oleh:</td></tr>
<tr><td style="width:28mm">Nama</td><td>: <b>{NAMA}</b></td></tr>
<tr><td>NPM</td><td>: {NPM}</td></tr><tr><td>Kelas</td><td>: {KELAS}</td></tr></table>
<div class="year">2026</div></section>"""
    return f"""<!doctype html><html lang="id"><head><meta charset="utf-8">
<title>Laporan UAS Delights - {NAMA}</title><style>{CSS}</style></head>
<body>{cover}{toc_html()}{body}</body></html>"""


if __name__ == "__main__":
    from weasyprint import HTML
    html = build_html()
    (HERE / "laporan.html").write_text(html, encoding="utf-8")
    HTML(string=html, base_url=str(HERE)).write_pdf(OUT)
    print("PDF:", OUT)
