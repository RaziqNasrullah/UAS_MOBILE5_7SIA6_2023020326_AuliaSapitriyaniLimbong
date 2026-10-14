<?php
/**
 * GET menu/read.php
 * Query opsional: search (nama), kategori_id, best_seller=1, sort=terbaru|nama|harga, limit
 * Nama kategori diambil dengan JOIN ke tabel kategori.
 */
declare(strict_types=1);
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_shared.php';
requireMethod('GET');

$search = inputString($_GET, 'search');
$kategoriId = inputInt($_GET, 'kategori_id');
$bestSeller = isset($_GET['best_seller']) && filter_var($_GET['best_seller'], FILTER_VALIDATE_BOOLEAN);
$sort = $_GET['sort'] ?? 'nama';
$limit = inputInt($_GET, 'limit');

$where = [];
$params = [];
if ($search !== null) {
    $where[] = 'm.nama LIKE ?';
    $params[] = '%' . $search . '%';
}
if ($kategoriId !== null && $kategoriId > 0) {
    $where[] = 'm.kategori_id = ?';
    $params[] = $kategoriId;
}
if ($bestSeller) {
    $where[] = 'm.is_best_seller = 1';
}

$orderBy = match ($sort) {
    'terbaru' => 'm.created_at DESC, m.id DESC',
    'harga' => 'm.harga ASC',
    default => 'k.id ASC, m.nama ASC',
};

$sql = MENU_SELECT . ($where ? ' WHERE ' . implode(' AND ', $where) : '') . " ORDER BY $orderBy";
if ($limit !== null && $limit > 0) {
    $sql .= ' LIMIT ' . min($limit, 100);
}

try {
    $stmt = getConnection()->prepare($sql);
    $stmt->execute($params);
    $rows = array_map('castMenu', $stmt->fetchAll());
    jsonResponse(true, count($rows) . ' menu ditemukan', $rows);
} catch (PDOException $e) {
    error_log($e->getMessage());
    jsonResponse(false, 'Gagal memuat data menu', null, 500);
}
