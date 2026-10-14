<?php
/**
 * POST keranjang/add.php  body: { menu_id, jumlah, catatan_item? }
 * Jika menu sudah ada di keranjang, jumlah ditambahkan (UNIQUE menu_id).
 */
declare(strict_types=1);
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_shared.php';
requireMethod('POST');

$input = getInput();
$menuId = inputInt($input, 'menu_id');
$jumlah = inputInt($input, 'jumlah') ?? 1;
$catatan = validasiCatatan(inputString($input, 'catatan_item'));
if ($menuId === null || $menuId <= 0) {
    jsonResponse(false, 'Menu tidak valid', null, 422);
}
if ($jumlah < 1) {
    jsonResponse(false, 'Jumlah minimal 1', null, 422);
}

try {
    $db = getConnection();
    $db->beginTransaction();
    $stmt = $db->prepare('SELECT id, nama, stok FROM menu WHERE id = ? FOR UPDATE');
    $stmt->execute([$menuId]);
    $menu = $stmt->fetch();
    if (!$menu) {
        $db->rollBack();
        jsonResponse(false, 'Menu tidak ditemukan', null, 404);
    }
    $stok = (int) $menu['stok'];
    if ($stok <= 0) {
        $db->rollBack();
        jsonResponse(false, "Maaf, {$menu['nama']} sedang habis", null, 422);
    }
    $stmt = $db->prepare('SELECT id, jumlah FROM keranjang WHERE menu_id = ? FOR UPDATE');
    $stmt->execute([$menuId]);
    $ada = $stmt->fetch();
    $jumlahBaru = $jumlah + ($ada ? (int) $ada['jumlah'] : 0);
    if ($jumlahBaru > $stok) {
        $db->rollBack();
        $sisa = $stok - ($ada ? (int) $ada['jumlah'] : 0);
        $pesan = $ada
            ? "Stok {$menu['nama']} tersisa $stok porsi dan $ada[jumlah] sudah ada di keranjang" . ($sisa > 0 ? " (maks tambah $sisa)" : '')
            : "Jumlah melebihi stok. Stok {$menu['nama']} tersisa $stok porsi";
        jsonResponse(false, $pesan, ['stok' => $stok], 422);
    }
    if ($ada) {
        $db->prepare('UPDATE keranjang SET jumlah = ?, catatan_item = COALESCE(?, catatan_item) WHERE id = ?')
           ->execute([$jumlahBaru, $catatan, $ada['id']]);
        $id = (int) $ada['id'];
    } else {
        $db->prepare('INSERT INTO keranjang (menu_id, jumlah, catatan_item) VALUES (?, ?, ?)')
           ->execute([$menuId, $jumlah, $catatan]);
        $id = (int) $db->lastInsertId();
    }
    $db->commit();
    jsonResponse(true, "{$menu['nama']} ditambahkan ke keranjang", ambilItemKeranjang($db, $id), $ada ? 200 : 201);
} catch (PDOException $e) {
    if (isset($db) && $db->inTransaction()) {
        $db->rollBack();
    }
    error_log($e->getMessage());
    jsonResponse(false, 'Gagal menambahkan ke keranjang', null, 500);
}
