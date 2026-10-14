<?php
/** POST menu/update.php  body: { id, ...field sama dengan create } */
declare(strict_types=1);
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_shared.php';
requireMethod('POST');

$input = getInput();
$id = inputInt($input, 'id');
if ($id === null || $id <= 0) {
    jsonResponse(false, 'ID menu tidak valid', null, 422);
}
try {
    $db = getConnection();
    $lama = ambilMenu($db, $id);
    if ($lama === null) {
        jsonResponse(false, 'Menu tidak ditemukan', null, 404);
    }
    $d = validasiMenu($db, $input, $lama['gambar']);
    $gambar = $d['gambar'] ?? $lama['gambar'];
    $stmt = $db->prepare('UPDATE menu SET kategori_id = ?, nama = ?, harga = ?, stok = ?, deskripsi = ?, gambar = ?,
                          level_pedas = ?, suhu_sajian = ?, estimasi_saji = ?, is_best_seller = ? WHERE id = ?');
    $stmt->execute([
        $d['kategori_id'], $d['nama'], $d['harga'], $d['stok'], $d['deskripsi'], $gambar,
        $d['level_pedas'], $d['suhu_sajian'], $d['estimasi_saji'], $d['is_best_seller'], $id,
    ]);
    // Jika jumlah di keranjang melebihi stok baru, sesuaikan agar tetap valid.
    if ($d['stok'] === 0) {
        $db->prepare('DELETE FROM keranjang WHERE menu_id = ?')->execute([$id]);
    } else {
        $db->prepare('UPDATE keranjang SET jumlah = LEAST(jumlah, ?) WHERE menu_id = ?')->execute([$d['stok'], $id]);
    }
    // Hapus file gambar lama bila diganti.
    if ($lama['gambar'] && $gambar !== $lama['gambar'] && is_file(UPLOAD_DIR . $lama['gambar'])) {
        @unlink(UPLOAD_DIR . $lama['gambar']);
    }
    jsonResponse(true, 'Menu berhasil diperbarui', ambilMenu($db, $id));
} catch (PDOException $e) {
    error_log($e->getMessage());
    jsonResponse(false, 'Gagal memperbarui menu', null, 500);
}
