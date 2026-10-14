<?php
/** GET keranjang/read.php - isi keranjang + ringkasan */
declare(strict_types=1);
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_shared.php';
requireMethod('GET');

try {
    $rows = getConnection()->query(KERANJANG_SELECT . ' ORDER BY c.created_at ASC, c.id ASC')->fetchAll();
    $rows = array_map('castKeranjang', $rows);
    jsonResponse(true, 'Keranjang berhasil dimuat', $rows);
} catch (PDOException $e) {
    error_log($e->getMessage());
    jsonResponse(false, 'Gagal memuat keranjang', null, 500);
}
