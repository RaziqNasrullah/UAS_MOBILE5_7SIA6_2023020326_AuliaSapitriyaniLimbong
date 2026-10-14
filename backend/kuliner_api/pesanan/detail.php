<?php
/** GET pesanan/detail.php?id= - pesanan + item */
declare(strict_types=1);
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_shared.php';
requireMethod('GET');

$id = inputInt($_GET, 'id');
if ($id === null || $id <= 0) {
    jsonResponse(false, 'ID pesanan tidak valid', null, 422);
}
try {
    $pesanan = ambilPesananLengkap(getConnection(), $id);
    if ($pesanan === null) {
        jsonResponse(false, 'Pesanan tidak ditemukan', null, 404);
    }
    jsonResponse(true, 'Detail pesanan berhasil dimuat', $pesanan);
} catch (PDOException $e) {
    error_log($e->getMessage());
    jsonResponse(false, 'Gagal memuat detail pesanan', null, 500);
}
