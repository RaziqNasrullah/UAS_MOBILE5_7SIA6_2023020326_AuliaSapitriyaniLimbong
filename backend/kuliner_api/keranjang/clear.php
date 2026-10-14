<?php
/** POST keranjang/clear.php - mengosongkan keranjang */
declare(strict_types=1);
require_once __DIR__ . '/../helpers/response.php';
requireMethod('POST');

try {
    $jumlah = getConnection()->exec('DELETE FROM keranjang');
    jsonResponse(true, 'Keranjang dikosongkan', ['dihapus' => (int) $jumlah]);
} catch (PDOException $e) {
    error_log($e->getMessage());
    jsonResponse(false, 'Gagal mengosongkan keranjang', null, 500);
}
