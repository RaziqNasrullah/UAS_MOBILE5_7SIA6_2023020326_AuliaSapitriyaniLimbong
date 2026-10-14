-- =====================================================================
-- Database  : db_kuliner
-- Aplikasi  : Delights - Kedai SweetnFresh
-- Pembuat   : Aulia Sapitriyani Limbong (NIRM 2023020326) - 7SIA6
-- DBMS      : MySQL / MariaDB (XAMPP), engine InnoDB, charset utf8mb4
-- Cara pakai: phpMyAdmin > Import > pilih file ini > Go
-- =====================================================================

DROP DATABASE IF EXISTS db_kuliner;
CREATE DATABASE db_kuliner CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_kuliner;

SET NAMES utf8mb4;
SET time_zone = '+07:00';

-- ---------------------------------------------------------------------
-- Tabel kategori
-- ---------------------------------------------------------------------
CREATE TABLE kategori (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nama        VARCHAR(50)  NOT NULL,
  deskripsi   VARCHAR(255) NULL,
  ikon        VARCHAR(50)  NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_kategori_nama (nama)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabel menu (FK -> kategori). ON DELETE RESTRICT: kategori yang masih
-- punya menu tidak bisa dihapus.
-- ---------------------------------------------------------------------
CREATE TABLE menu (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  kategori_id     INT UNSIGNED NOT NULL,
  nama            VARCHAR(100) NOT NULL,
  harga           DECIMAL(12,2) NOT NULL,
  stok            INT UNSIGNED NOT NULL DEFAULT 0,
  deskripsi       TEXT NOT NULL,
  gambar          VARCHAR(255) NULL,
  level_pedas     ENUM('Tidak Pedas','Sedang','Pedas','Extra Pedas') NOT NULL DEFAULT 'Tidak Pedas',
  suhu_sajian     ENUM('Panas','Dingin','Suhu Ruang') NOT NULL DEFAULT 'Panas',
  estimasi_saji   INT UNSIGNED NOT NULL DEFAULT 10 COMMENT 'menit',
  is_best_seller  TINYINT(1) NOT NULL DEFAULT 0,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_menu_kategori (kategori_id),
  KEY idx_menu_nama (nama),
  CONSTRAINT fk_menu_kategori FOREIGN KEY (kategori_id)
    REFERENCES kategori (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_menu_harga CHECK (harga > 0),
  CONSTRAINT chk_menu_estimasi CHECK (estimasi_saji > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabel keranjang (1 baris per menu, UNIQUE menu_id agar tidak dobel)
-- ---------------------------------------------------------------------
CREATE TABLE keranjang (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  menu_id       INT UNSIGNED NOT NULL,
  jumlah        INT UNSIGNED NOT NULL DEFAULT 1,
  catatan_item  VARCHAR(150) NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_keranjang_menu (menu_id),
  CONSTRAINT fk_keranjang_menu FOREIGN KEY (menu_id)
    REFERENCES menu (id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_keranjang_jumlah CHECK (jumlah >= 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabel pesanan (header transaksi)
-- ---------------------------------------------------------------------
CREATE TABLE pesanan (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nomor_pesanan  VARCHAR(20)  NOT NULL COMMENT 'INV-YYYYMMDD-NNN',
  nama_pemesan   VARCHAR(100) NOT NULL,
  no_hp          VARCHAR(15)  NOT NULL,
  tipe_pesanan   ENUM('Makan di Tempat','Bawa Pulang','Diantar') NOT NULL,
  nomor_meja     VARCHAR(10)  NULL COMMENT 'wajib jika Makan di Tempat',
  alamat         VARCHAR(255) NULL COMMENT 'wajib jika Diantar',
  catatan        VARCHAR(255) NULL,
  subtotal       DECIMAL(12,2) NOT NULL DEFAULT 0,
  biaya_layanan  DECIMAL(12,2) NOT NULL DEFAULT 0,
  ongkir         DECIMAL(12,2) NOT NULL DEFAULT 0,
  diskon         DECIMAL(12,2) NOT NULL DEFAULT 0,
  total          DECIMAL(12,2) NOT NULL DEFAULT 0,
  status         ENUM('Diproses','Selesai','Dibatalkan') NOT NULL DEFAULT 'Diproses',
  tanggal        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_pesanan_nomor (nomor_pesanan),
  KEY idx_pesanan_tanggal (tanggal),
  KEY idx_pesanan_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------------
-- Tabel detail_pesanan (snapshot nama & harga menu saat dibeli)
-- ---------------------------------------------------------------------
CREATE TABLE detail_pesanan (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  pesanan_id    INT UNSIGNED NOT NULL,
  menu_id       INT UNSIGNED NULL,
  nama_menu     VARCHAR(100) NOT NULL,
  harga_satuan  DECIMAL(12,2) NOT NULL,
  jumlah        INT UNSIGNED NOT NULL,
  catatan_item  VARCHAR(150) NULL,
  subtotal      DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (id),
  KEY idx_detail_pesanan (pesanan_id),
  KEY idx_detail_menu (menu_id),
  CONSTRAINT fk_detail_pesanan FOREIGN KEY (pesanan_id)
    REFERENCES pesanan (id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_detail_menu FOREIGN KEY (menu_id)
    REFERENCES menu (id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- DATA SEED
-- =====================================================================
INSERT INTO kategori (id, nama, deskripsi, ikon) VALUES
(1, 'Makanan Utama', 'Rice bowl, nasi goreng, dan mie hangat yang mengenyangkan', 'rice_bowl'),
(2, 'Minuman',       'Minuman segar dingin maupun hangat racikan barista SweetnFresh', 'local_cafe'),
(3, 'Snack',         'Camilan gurih untuk teman ngobrol dan nongkrong', 'fastfood'),
(4, 'Dessert',       'Hidangan manis penutup yang lembut dan segar', 'icecream');

INSERT INTO menu (id, kategori_id, nama, harga, stok, deskripsi, gambar, level_pedas, suhu_sajian, estimasi_saji, is_best_seller) VALUES
-- Makanan Utama
(1,  1, 'Rice Bowl Ayam Sambal Matah', 32000, 25, 'Nasi pulen dengan ayam crispy, sambal matah bawang merah-serai, telur ceplok, dan lalapan segar.', 'rice_bowl_sambal_matah.jpg', 'Pedas', 'Panas', 15, 1),
(2,  1, 'Nasi Goreng Kampung Telur', 28000, 30, 'Nasi goreng bumbu terasi khas kampung dengan telur mata sapi, kerupuk, dan acar timun.', 'nasi_goreng_kampung.jpg', 'Sedang', 'Panas', 12, 0),
(3,  1, 'Mie Goreng Jawa Spesial', 27000, 20, 'Mie kuning dimasak arang dengan kecap manis, suwiran ayam, sawi, dan telur orak-arik.', 'mie_goreng_jawa.jpg', 'Sedang', 'Panas', 15, 0),
(4,  1, 'Chicken Katsu Curry Rice', 35000, 15, 'Ayam katsu renyah disiram kari Jepang kental dengan wortel dan kentang, disajikan bersama nasi hangat.', 'katsu_curry.jpg', 'Tidak Pedas', 'Panas', 18, 1),
(5,  1, 'Ayam Geprek Keju Mozarella', 30000, 0, 'Ayam goreng tepung digeprek sambal bawang lalu ditutup keju mozarella leleh. (Sedang habis)', 'ayam_geprek_mozarella.jpg', 'Extra Pedas', 'Panas', 15, 0),
-- Minuman
(6,  2, 'Es Teh Leci Segar', 15000, 50, 'Teh melati dingin dengan sirup dan buah leci utuh, segar untuk siang yang terik.', 'es_teh_leci.jpg', 'Tidak Pedas', 'Dingin', 5, 1),
(7,  2, 'Kopi Susu Gula Aren', 20000, 40, 'Espresso house blend, susu segar, dan gula aren cair. Creamy dengan manis yang pas.', 'kopi_susu_gula_aren.jpg', 'Tidak Pedas', 'Dingin', 5, 1),
(8,  2, 'Jus Alpukat Cokelat', 22000, 20, 'Jus alpukat mentega kental dengan lelehan cokelat dan susu kental manis.', 'jus_alpukat_cokelat.jpg', 'Tidak Pedas', 'Dingin', 7, 0),
(9,  2, 'Lemon Mint Squash', 18000, 35, 'Perasan lemon segar, daun mint, dan soda dingin yang menyegarkan tenggorokan.', 'lemon_mint_squash.jpg', 'Tidak Pedas', 'Dingin', 5, 0),
(10, 2, 'Hot Matcha Latte', 24000, 25, 'Matcha premium dikocok dengan susu hangat dan sedikit madu.', 'hot_matcha_latte.jpg', 'Tidak Pedas', 'Panas', 6, 0),
-- Snack
(11, 3, 'Kentang Goreng Truffle', 22000, 30, 'Kentang goreng renyah dengan minyak truffle, parmesan, dan peterseli cincang.', 'kentang_truffle.jpg', 'Tidak Pedas', 'Panas', 10, 0),
(12, 3, 'Roti Bakar Cokelat Keju', 20000, 25, 'Roti tebal dipanggang mentega dengan isian cokelat meses dan keju parut melimpah.', 'roti_bakar_cokju.jpg', 'Tidak Pedas', 'Panas', 10, 0),
(13, 3, 'Dimsum Ayam Udang (4 pcs)', 25000, 20, 'Siomay ayam udang kukus homemade dengan saus cocol chili oil.', 'dimsum_ayam_udang.jpg', 'Tidak Pedas', 'Panas', 12, 1),
(14, 3, 'Tahu Cabe Garam', 18000, 25, 'Tahu sutra goreng tepung tipis ditumis bawang putih, cabai rawit, dan daun bawang.', 'tahu_cabe_garam.jpg', 'Pedas', 'Panas', 10, 0),
(15, 3, 'Cireng Bumbu Rujak', 16000, 20, 'Cireng kenyal renyah dengan cocolan bumbu rujak gula merah yang pedas manis.', 'cireng_rujak.jpg', 'Sedang', 'Panas', 8, 0),
-- Dessert
(16, 4, 'Mango Sticky Pudding', 20000, 20, 'Puding santan lembut dengan potongan mangga harum manis dan saus mangga.', 'mango_pudding.jpg', 'Tidak Pedas', 'Dingin', 3, 0),
(17, 4, 'Waffle Strawberry Cream', 28000, 15, 'Waffle hangat renyah dengan whipped cream, stroberi segar, dan saus stroberi.', 'waffle_strawberry.jpg', 'Tidak Pedas', 'Suhu Ruang', 12, 0),
(18, 4, 'Es Krim Sundae Brownies', 26000, 18, 'Dua scoop es krim vanila di atas brownies fudge dengan saus cokelat dan kacang.', 'sundae_brownies.jpg', 'Tidak Pedas', 'Dingin', 5, 0),
(19, 4, 'Panna Cotta Mixed Berry', 22000, 15, 'Panna cotta vanila lembut dengan kompot blueberry dan raspberry.', 'panna_cotta_berry.jpg', 'Tidak Pedas', 'Dingin', 3, 0),
(20, 4, 'Klepon Cake Slice', 24000, 12, 'Bolu pandan lembut berlapis gula aren dan kelapa parut, terinspirasi dari klepon.', 'klepon_cake.jpg', 'Tidak Pedas', 'Suhu Ruang', 3, 0);

-- ---------------------------------------------------------------------
-- Contoh pesanan (tanggal relatif terhadap waktu import agar dashboard
-- 7 hari terakhir langsung terisi). Nilai biaya mengikuti aturan:
-- layanan 2.000, ongkir 8.000 (Diantar), diskon 10% jika subtotal >= 100.000
-- ---------------------------------------------------------------------
SET @d6 = DATE_SUB(NOW(), INTERVAL 6 DAY);
SET @d4 = DATE_SUB(NOW(), INTERVAL 4 DAY);
SET @d2 = DATE_SUB(NOW(), INTERVAL 2 DAY);
SET @d1 = DATE_SUB(NOW(), INTERVAL 1 DAY);
SET @d0 = DATE_SUB(NOW(), INTERVAL 1 HOUR);

INSERT INTO pesanan (id, nomor_pesanan, nama_pemesan, no_hp, tipe_pesanan, nomor_meja, alamat, catatan, subtotal, biaya_layanan, ongkir, diskon, total, status, tanggal) VALUES
(1, CONCAT('INV-', DATE_FORMAT(@d6, '%Y%m%d'), '-001'), 'Rina Marbun',    '081234567890', 'Makan di Tempat', '5',  NULL, 'Meja dekat jendela', 94000, 2000, 0, 0, 96000, 'Selesai', @d6),
(2, CONCAT('INV-', DATE_FORMAT(@d4, '%Y%m%d'), '-001'), 'Dimas Pratama',  '085277889900', 'Diantar', NULL, 'Jl. Sei Batang Hari No. 12, Medan Sunggal', 'Tolong telepon saat sampai', 155000, 2000, 8000, 15500, 149500, 'Selesai', @d4),
(3, CONCAT('INV-', DATE_FORMAT(@d2, '%Y%m%d'), '-001'), 'Sari Hutapea',   '082166554433', 'Bawa Pulang', NULL, NULL, NULL, 40000, 2000, 0, 0, 42000, 'Dibatalkan', @d2),
(4, CONCAT('INV-', DATE_FORMAT(@d1, '%Y%m%d'), '-001'), 'Kevin Sinaga',   '081398765432', 'Bawa Pulang', NULL, NULL, 'Kopi dipisah esnya', 80000, 2000, 0, 0, 82000, 'Selesai', @d1),
(5, CONCAT('INV-', DATE_FORMAT(@d0, '%Y%m%d'), '-001'), 'Putri Nasution', '089612345678', 'Makan di Tempat', '2', NULL, NULL, 97000, 2000, 0, 0, 99000, 'Diproses', @d0);

INSERT INTO detail_pesanan (pesanan_id, menu_id, nama_menu, harga_satuan, jumlah, catatan_item, subtotal) VALUES
(1, 1,  'Rice Bowl Ayam Sambal Matah', 32000, 2, 'Sambal dipisah', 64000),
(1, 6,  'Es Teh Leci Segar',           15000, 2, 'Less sugar',      30000),
(2, 4,  'Chicken Katsu Curry Rice',    35000, 2, NULL,              70000),
(2, 7,  'Kopi Susu Gula Aren',         20000, 3, 'Less ice',        60000),
(2, 13, 'Dimsum Ayam Udang (4 pcs)',   25000, 1, NULL,              25000),
(3, 11, 'Kentang Goreng Truffle',      22000, 1, NULL,              22000),
(3, 9,  'Lemon Mint Squash',           18000, 1, NULL,              18000),
(4, 7,  'Kopi Susu Gula Aren',         20000, 2, 'Es dipisah',      40000),
(4, 12, 'Roti Bakar Cokelat Keju',     20000, 1, NULL,              20000),
(4, 16, 'Mango Sticky Pudding',        20000, 1, NULL,              20000),
(5, 1,  'Rice Bowl Ayam Sambal Matah', 32000, 1, 'Tanpa timun',     32000),
(5, 13, 'Dimsum Ayam Udang (4 pcs)',   25000, 2, NULL,              50000),
(5, 6,  'Es Teh Leci Segar',           15000, 1, NULL,              15000);

-- Keranjang awal dikosongkan agar pengguna mencoba sendiri.
