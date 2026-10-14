<?php
/** POST kategori/update.php  body: { id, nama, deskripsi?, ikon? } */
declare(strict_types=1);
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_shared.php';
requireMethod('POST');

$input = getInput();
$id = inputInt($input, 'id');
if ($id === null || $id <= 0) {
    jsonResponse(false, 'ID kategori tidak valid', null, 422);
}
$data = validasiKategori($input);
try {
    $db = getConnection();
    if (ambilKategori($db, $id) === null) {
        jsonResponse(false, 'Kategori tidak ditemukan', null, 404);
    }
    if (namaKategoriDipakai($db, $data['nama'], $id)) {
        jsonResponse(false, "Kategori \"{$data['nama']}\" sudah ada. Gunakan nama lain.", null, 409);
    }
    $stmt = $db->prepare('UPDATE kategori SET nama = ?, deskripsi = ?, ikon = COALESCE(?, ikon) WHERE id = ?');
    $stmt->execute([$data['nama'], $data['deskripsi'], $data['ikon'], $id]);
    jsonResponse(true, 'Kategori berhasil diperbarui', ambilKategori($db, $id));
} catch (PDOException $e) {
    if ($e->getCode() === '23000') {
        jsonResponse(false, 'Nama kategori sudah digunakan', null, 409);
    }
    error_log($e->getMessage());
    jsonResponse(false, 'Gagal memperbarui kategori', null, 500);
}
