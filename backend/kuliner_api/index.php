<?php
/**
 * Halaman cek API: http://localhost/kuliner_api/
 */
declare(strict_types=1);
require_once __DIR__ . '/helpers/response.php';

$dbOk = true;
$jumlahMenu = null;
try {
    $jumlahMenu = (int) getConnection()->query('SELECT COUNT(*) FROM menu')->fetchColumn();
} catch (Throwable $e) {
    $dbOk = false;
}

jsonResponse(true, $dbOk ? 'API Delights (SweetnFresh) aktif & database terhubung' : 'API aktif, tetapi database belum terhubung', [
    'aplikasi' => 'Delights',
    'kedai' => 'SweetnFresh',
    'database' => $dbOk ? DB_NAME . ' (terhubung)' : 'TIDAK TERHUBUNG - cek MySQL XAMPP & import database/db_kuliner.sql',
    'jumlah_menu' => $jumlahMenu,
    'waktu_server' => date('Y-m-d H:i:s'),
    'endpoint' => [
        'GET  kategori/read.php',
        'POST kategori/create.php | update.php | delete.php',
        'GET  menu/read.php?search=&kategori_id=&best_seller=1&limit=',
        'GET  menu/detail.php?id=',
        'POST menu/create.php | update.php | delete.php | upload_gambar.php',
        'GET  keranjang/read.php',
        'POST keranjang/add.php | update_qty.php | update_catatan.php | delete.php | clear.php',
        'POST pesanan/checkout.php | update_status.php',
        'GET  pesanan/read.php?status= | pesanan/detail.php?id=',
        'GET  dashboard/summary.php',
    ],
]);
