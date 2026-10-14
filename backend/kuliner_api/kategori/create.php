<?php
/** POST kategori/create.php  body: { nama, deskripsi?, ikon? } */
declare(strict_types=1);
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_shared.php';
requireMethod('POST');

$data = validasiKategori(getInput());
try {
    $db = getConnection();
    if (namaKategoriDipakai($db, $data['nama'])) {
        jsonResponse(false, "Kategori \"{$data['nama']}\" sudah ada. Gunakan nama lain.", null, 409);
    }
    $stmt = $db->prepare('INSERT INTO kategori (nama, deskripsi, ikon) VALUES (?, ?, ?)');
    $stmt->execute([$data['nama'], $data['deskripsi'], $data['ikon']]);
    jsonResponse(true, 'Kategori berhasil ditambahkan', ambilKategori($db, (int) $db->lastInsertId()), 201);
} catch (PDOException $e) {
    if ($e->getCode() === '23000') {
        jsonResponse(false, 'Nama kategori sudah digunakan', null, 409);
    }
    error_log($e->getMessage());
    jsonResponse(false, 'Gagal menyimpan kategori', null, 500);
}
