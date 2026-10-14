<?php
/**
 * POST menu/delete.php  body: { id }
 * Riwayat pesanan tetap aman karena detail_pesanan menyimpan snapshot nama & harga
 * (FK menu_id ON DELETE SET NULL). Item keranjang ikut terhapus (CASCADE).
 */
declare(strict_types=1);
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_shared.php';
requireMethod('POST');

$id = inputInt(getInput(), 'id');
if ($id === null || $id <= 0) {
    jsonResponse(false, 'ID menu tidak valid', null, 422);
}
try {
    $db = getConnection();
    $menu = ambilMenu($db, $id);
    if ($menu === null) {
        jsonResponse(false, 'Menu tidak ditemukan', null, 404);
    }
    $db->prepare('DELETE FROM menu WHERE id = ?')->execute([$id]);
    if ($menu['gambar'] && is_file(UPLOAD_DIR . $menu['gambar'])) {
        @unlink(UPLOAD_DIR . $menu['gambar']);
    }
    jsonResponse(true, "Menu \"{$menu['nama']}\" berhasil dihapus", ['id' => $id]);
} catch (PDOException $e) {
    error_log($e->getMessage());
    jsonResponse(false, 'Gagal menghapus menu', null, 500);
}
