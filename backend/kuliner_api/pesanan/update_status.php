<?php
/**
 * POST pesanan/update_status.php  body: { id, status: Selesai|Dibatalkan }
 * Hanya pesanan berstatus Diproses yang bisa diubah. Jika Dibatalkan,
 * stok menu dikembalikan di dalam transaksi yang sama.
 */
declare(strict_types=1);
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_shared.php';
requireMethod('POST');

$input = getInput();
$id = inputInt($input, 'id');
$status = inputString($input, 'status');
if ($id === null || $id <= 0) {
    jsonResponse(false, 'ID pesanan tidak valid', null, 422);
}
if (!in_array($status, ['Selesai', 'Dibatalkan'], true)) {
    jsonResponse(false, 'Status baru harus Selesai atau Dibatalkan', null, 422);
}
try {
    $db = getConnection();
    $db->beginTransaction();
    $stmt = $db->prepare('SELECT id, nomor_pesanan, status FROM pesanan WHERE id = ? FOR UPDATE');
    $stmt->execute([$id]);
    $pesanan = $stmt->fetch();
    if (!$pesanan) {
        $db->rollBack();
        jsonResponse(false, 'Pesanan tidak ditemukan', null, 404);
    }
    if ($pesanan['status'] !== 'Diproses') {
        $db->rollBack();
        jsonResponse(false, "Pesanan {$pesanan['nomor_pesanan']} sudah {$pesanan['status']} dan tidak dapat diubah lagi", null, 409);
    }
    $stokKembali = 0;
    if ($status === 'Dibatalkan') {
        $stmt = $db->prepare('UPDATE menu m
                              JOIN (SELECT menu_id, SUM(jumlah) AS qty FROM detail_pesanan
                                    WHERE pesanan_id = ? AND menu_id IS NOT NULL GROUP BY menu_id) d
                                ON d.menu_id = m.id
                              SET m.stok = m.stok + d.qty');
        $stmt->execute([$id]);
        $stokKembali = $stmt->rowCount();
    }
    $db->prepare('UPDATE pesanan SET status = ? WHERE id = ?')->execute([$status, $id]);
    $db->commit();
    $pesan = $status === 'Dibatalkan'
        ? "Pesanan {$pesanan['nomor_pesanan']} dibatalkan, stok $stokKembali menu dikembalikan"
        : "Pesanan {$pesanan['nomor_pesanan']} ditandai Selesai";
    jsonResponse(true, $pesan, ambilPesananLengkap($db, $id));
} catch (PDOException $e) {
    if (isset($db) && $db->inTransaction()) {
        $db->rollBack();
    }
    error_log($e->getMessage());
    jsonResponse(false, 'Gagal mengubah status pesanan', null, 500);
}
