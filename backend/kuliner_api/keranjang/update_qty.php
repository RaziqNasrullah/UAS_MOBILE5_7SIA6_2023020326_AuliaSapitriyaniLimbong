<?php
/** POST keranjang/update_qty.php  body: { id, jumlah } - validasi 1 <= jumlah <= stok */
declare(strict_types=1);
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_shared.php';
requireMethod('POST');

$input = getInput();
$id = inputInt($input, 'id');
$jumlah = inputInt($input, 'jumlah');
if ($id === null || $id <= 0) {
    jsonResponse(false, 'Item keranjang tidak valid', null, 422);
}
if ($jumlah === null || $jumlah < 1) {
    jsonResponse(false, 'Jumlah minimal 1. Gunakan tombol hapus untuk menghapus item.', null, 422);
}
try {
    $db = getConnection();
    $item = ambilItemKeranjang($db, $id);
    if ($item === null) {
        jsonResponse(false, 'Item keranjang tidak ditemukan', null, 404);
    }
    if ($jumlah > $item['stok']) {
        jsonResponse(false, "Stok {$item['nama_menu']} hanya tersisa {$item['stok']} porsi", ['stok' => $item['stok']], 422);
    }
    $db->prepare('UPDATE keranjang SET jumlah = ? WHERE id = ?')->execute([$jumlah, $id]);
    jsonResponse(true, 'Jumlah diperbarui', ambilItemKeranjang($db, $id));
} catch (PDOException $e) {
    error_log($e->getMessage());
    jsonResponse(false, 'Gagal memperbarui jumlah', null, 500);
}
