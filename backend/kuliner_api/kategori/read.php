<?php
/** GET kategori/read.php - daftar kategori + jumlah menu tiap kategori */
declare(strict_types=1);
require_once __DIR__ . '/../helpers/response.php';
requireMethod('GET');

try {
    $sql = 'SELECT k.*, COUNT(m.id) AS jumlah_menu
            FROM kategori k
            LEFT JOIN menu m ON m.kategori_id = k.id
            GROUP BY k.id
            ORDER BY k.id ASC';
    $rows = getConnection()->query($sql)->fetchAll();
    $rows = array_map(fn($r) => castRow($r, ['id', 'jumlah_menu']), $rows);
    jsonResponse(true, 'Data kategori berhasil dimuat', $rows);
} catch (PDOException $e) {
    error_log($e->getMessage());
    jsonResponse(false, 'Gagal memuat kategori dari database', null, 500);
}
