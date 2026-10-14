<?php
/**
 * POST menu/create.php
 * body: { kategori_id, nama, harga, stok, deskripsi, gambar?, level_pedas, suhu_sajian, estimasi_saji, is_best_seller }
 * gambar = nama file hasil menu/upload_gambar.php
 */
declare(strict_types=1);
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_shared.php';
requireMethod('POST');

try {
    $db = getConnection();
    $d = validasiMenu($db, getInput());
    $stmt = $db->prepare('INSERT INTO menu (kategori_id, nama, harga, stok, deskripsi, gambar, level_pedas, suhu_sajian, estimasi_saji, is_best_seller)
                          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
    $stmt->execute([
        $d['kategori_id'], $d['nama'], $d['harga'], $d['stok'], $d['deskripsi'], $d['gambar'],
        $d['level_pedas'], $d['suhu_sajian'], $d['estimasi_saji'], $d['is_best_seller'],
    ]);
    jsonResponse(true, 'Menu berhasil ditambahkan', ambilMenu($db, (int) $db->lastInsertId()), 201);
} catch (PDOException $e) {
    error_log($e->getMessage());
    jsonResponse(false, 'Gagal menyimpan menu', null, 500);
}
