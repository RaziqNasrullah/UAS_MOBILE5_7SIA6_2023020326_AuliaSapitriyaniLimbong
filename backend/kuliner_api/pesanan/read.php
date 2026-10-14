<?php
/** GET pesanan/read.php?status=Diproses|Selesai|Dibatalkan  (urut terbaru) */
declare(strict_types=1);
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_shared.php';
requireMethod('GET');

$status = inputString($_GET, 'status');
if ($status !== null && !in_array($status, STATUS_PESANAN, true)) {
    jsonResponse(false, 'Status tidak valid', null, 422);
}
try {
    $sql = 'SELECT p.*, COALESCE(SUM(d.jumlah), 0) AS jumlah_item
            FROM pesanan p
            LEFT JOIN detail_pesanan d ON d.pesanan_id = p.id';
    $params = [];
    if ($status !== null) {
        $sql .= ' WHERE p.status = ?';
        $params[] = $status;
    }
    $sql .= ' GROUP BY p.id ORDER BY p.tanggal DESC, p.id DESC';
    $stmt = getConnection()->prepare($sql);
    $stmt->execute($params);
    $rows = array_map('castPesanan', $stmt->fetchAll());
    jsonResponse(true, count($rows) . ' pesanan ditemukan', $rows);
} catch (PDOException $e) {
    error_log($e->getMessage());
    jsonResponse(false, 'Gagal memuat riwayat pesanan', null, 500);
}
