<?php
/** POST kategori/delete.php  body: { id }  - ditolak jika kategori masih punya menu */
declare(strict_types=1);
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_shared.php';
requireMethod('POST');

$id = inputInt(getInput(), 'id');
if ($id === null || $id <= 0) {
    jsonResponse(false, 'ID kategori tidak valid', null, 422);
}
try {
    $db = getConnection();
    $kategori = ambilKategori($db, $id);
    if ($kategori === null) {
        jsonResponse(false, 'Kategori tidak ditemukan', null, 404);
    }
    if ($kategori['jumlah_menu'] > 0) {
        jsonResponse(
            false,
            "Kategori \"{$kategori['nama']}\" tidak dapat dihapus karena masih memiliki {$kategori['jumlah_menu']} menu. Pindahkan atau hapus menunya terlebih dahulu.",
            ['jumlah_menu' => $kategori['jumlah_menu']],
            409
        );
    }
    $db->prepare('DELETE FROM kategori WHERE id = ?')->execute([$id]);
    jsonResponse(true, 'Kategori berhasil dihapus', ['id' => $id]);
} catch (PDOException $e) {
    if ($e->getCode() === '23000') {
        jsonResponse(false, 'Kategori masih dipakai oleh menu sehingga tidak dapat dihapus', null, 409);
    }
    error_log($e->getMessage());
    jsonResponse(false, 'Gagal menghapus kategori', null, 500);
}
