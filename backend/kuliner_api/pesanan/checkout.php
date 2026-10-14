<?php
/**
 * POST pesanan/checkout.php
 * body: { nama_pemesan, no_hp, tipe_pesanan, nomor_meja?, alamat?, catatan? }
 * Item diambil dari tabel keranjang. Seluruh proses berjalan dalam SATU transaksi:
 * kunci baris menu (FOR UPDATE) -> validasi stok -> insert pesanan & detail
 * -> kurangi stok -> kosongkan keranjang -> commit (rollback jika gagal).
 */
declare(strict_types=1);
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_shared.php';
requireMethod('POST');

$input = getInput();
$nama = inputString($input, 'nama_pemesan');
$noHp = inputString($input, 'no_hp');
$tipe = inputString($input, 'tipe_pesanan');
$meja = inputString($input, 'nomor_meja');
$alamat = inputString($input, 'alamat');
$catatan = inputString($input, 'catatan');

$errors = [];
if ($nama === null) {
    $errors['nama_pemesan'] = 'Nama pemesan wajib diisi';
} elseif (mb_strlen($nama) > 100) {
    $errors['nama_pemesan'] = 'Nama pemesan maksimal 100 karakter';
}
if ($noHp === null) {
    $errors['no_hp'] = 'Nomor HP wajib diisi';
} elseif (!preg_match('/^08\d{8,11}$/', $noHp)) {
    $errors['no_hp'] = 'Nomor HP harus angka 10-13 digit dan diawali 08';
}
if ($tipe === null || !in_array($tipe, TIPE_PESANAN, true)) {
    $errors['tipe_pesanan'] = 'Tipe pesanan wajib dipilih';
}
if ($tipe === 'Makan di Tempat' && $meja === null) {
    $errors['nomor_meja'] = 'Nomor meja wajib diisi untuk Makan di Tempat';
}
if ($tipe === 'Diantar' && $alamat === null) {
    $errors['alamat'] = 'Alamat pengantaran wajib diisi untuk pesanan Diantar';
}
if ($meja !== null && mb_strlen($meja) > 10) {
    $errors['nomor_meja'] = 'Nomor meja maksimal 10 karakter';
}
if ($errors) {
    jsonResponse(false, reset($errors), ['errors' => $errors], 422);
}
// Simpan hanya data yang relevan dengan tipe pesanan.
if ($tipe !== 'Makan di Tempat') {
    $meja = null;
}
if ($tipe !== 'Diantar') {
    $alamat = null;
}

try {
    $db = getConnection();
    $db->beginTransaction();

    // 1. Ambil isi keranjang & kunci baris menu terkait.
    $items = $db->query('SELECT c.id AS keranjang_id, c.menu_id, c.jumlah, c.catatan_item,
                                m.nama, m.harga, m.stok
                         FROM keranjang c
                         JOIN menu m ON m.id = c.menu_id
                         ORDER BY c.id ASC
                         FOR UPDATE')->fetchAll();
    if (!$items) {
        $db->rollBack();
        jsonResponse(false, 'Keranjang masih kosong', null, 422);
    }

    // 2. Validasi ulang stok di server.
    $kurang = [];
    $subtotal = 0.0;
    foreach ($items as $it) {
        if ((int) $it['jumlah'] > (int) $it['stok']) {
            $kurang[] = ['menu_id' => (int) $it['menu_id'], 'nama' => $it['nama'], 'stok' => (int) $it['stok'], 'diminta' => (int) $it['jumlah']];
        }
        $subtotal += (float) $it['harga'] * (int) $it['jumlah'];
    }
    if ($kurang) {
        $db->rollBack();
        $daftar = implode(', ', array_map(fn($k) => "{$k['nama']} (sisa {$k['stok']})", $kurang));
        jsonResponse(false, "Stok tidak cukup: $daftar. Silakan sesuaikan keranjang.", ['stok_kurang' => $kurang], 409);
    }

    // 3. Hitung biaya di server (tidak percaya nilai dari klien).
    $biaya = hitungBiaya($subtotal, $tipe);
    $nomor = buatNomorPesanan($db);

    // 4. Simpan header pesanan.
    $stmt = $db->prepare('INSERT INTO pesanan (nomor_pesanan, nama_pemesan, no_hp, tipe_pesanan, nomor_meja, alamat, catatan,
                                               subtotal, biaya_layanan, ongkir, diskon, total, status, tanggal)
                          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'Diproses\', NOW())');
    $stmt->execute([
        $nomor, $nama, $noHp, $tipe, $meja, $alamat, $catatan,
        $biaya['subtotal'], $biaya['biaya_layanan'], $biaya['ongkir'], $biaya['diskon'], $biaya['total'],
    ]);
    $pesananId = (int) $db->lastInsertId();

    // 5. Simpan detail (snapshot nama & harga) dan kurangi stok.
    $insDetail = $db->prepare('INSERT INTO detail_pesanan (pesanan_id, menu_id, nama_menu, harga_satuan, jumlah, catatan_item, subtotal)
                               VALUES (?, ?, ?, ?, ?, ?, ?)');
    $kurangiStok = $db->prepare('UPDATE menu SET stok = stok - ? WHERE id = ? AND stok >= ?');
    foreach ($items as $it) {
        $qty = (int) $it['jumlah'];
        $insDetail->execute([
            $pesananId, $it['menu_id'], $it['nama'], $it['harga'], $qty, $it['catatan_item'], (float) $it['harga'] * $qty,
        ]);
        $kurangiStok->execute([$qty, $it['menu_id'], $qty]);
        if ($kurangiStok->rowCount() !== 1) {
            throw new RuntimeException('Stok berubah saat checkout');
        }
    }

    // 6. Kosongkan keranjang.
    $db->exec('DELETE FROM keranjang');
    $db->commit();

    jsonResponse(true, "Pesanan $nomor berhasil dibuat", ambilPesananLengkap($db, $pesananId), 201);
} catch (Throwable $e) {
    if (isset($db) && $db->inTransaction()) {
        $db->rollBack();
    }
    error_log('[checkout] ' . $e->getMessage());
    $pesan = $e instanceof RuntimeException ? 'Stok berubah saat checkout, silakan coba lagi' : 'Checkout gagal, pesanan dibatalkan (rollback)';
    jsonResponse(false, $pesan, null, 500);
}
