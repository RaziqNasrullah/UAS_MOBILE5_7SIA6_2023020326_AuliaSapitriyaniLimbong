<?php
/** POST keranjang/update_catatan.php  body: { id, catatan_item } (kosong = hapus catatan) */
declare(strict_types=1);
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_shared.php';
requireMethod('POST');

$input = getInput();
$id = inputInt($input, 'id');
$catatan = validasiCatatan(inputString($input, 'catatan_item'));
if ($id === null || $id <= 0) {
    jsonResponse(false, 'Item keranjang tidak valid', null, 422);
}
try {
    $db = getConnection();
    if (ambilItemKeranjang($db, $id) === null) {
        jsonResponse(false, 'Item keranjang tidak ditemukan', null, 404);
    }
    $db->prepare('UPDATE keranjang SET catatan_item = ? WHERE id = ?')->execute([$catatan, $id]);
    jsonResponse(true, $catatan === null ? 'Catatan dihapus' : 'Catatan disimpan', ambilItemKeranjang($db, $id));
} catch (PDOException $e) {
    error_log($e->getMessage());
    jsonResponse(false, 'Gagal menyimpan catatan', null, 500);
}
