<?php
/** POST keranjang/delete.php  body: { id } */
declare(strict_types=1);
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_shared.php';
requireMethod('POST');

$id = inputInt(getInput(), 'id');
if ($id === null || $id <= 0) {
    jsonResponse(false, 'Item keranjang tidak valid', null, 422);
}
try {
    $db = getConnection();
    $item = ambilItemKeranjang($db, $id);
    if ($item === null) {
        jsonResponse(false, 'Item keranjang tidak ditemukan', null, 404);
    }
    $db->prepare('DELETE FROM keranjang WHERE id = ?')->execute([$id]);
    jsonResponse(true, "{$item['nama_menu']} dihapus dari keranjang", ['id' => $id]);
} catch (PDOException $e) {
    error_log($e->getMessage());
    jsonResponse(false, 'Gagal menghapus item keranjang', null, 500);
}
