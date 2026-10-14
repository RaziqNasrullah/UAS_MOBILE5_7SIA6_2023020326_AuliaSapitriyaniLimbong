<?php
/**
 * POST menu/upload_gambar.php  (multipart/form-data, field: gambar)
 * Mengembalikan nama file yang tersimpan di folder uploads/.
 * Opsional field menu_id: langsung memperbarui kolom gambar menu tersebut.
 */
declare(strict_types=1);
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_shared.php';
requireMethod('POST');

if (!isset($_FILES['gambar']) || !is_array($_FILES['gambar'])) {
    jsonResponse(false, 'File gambar belum dipilih (field "gambar")', null, 422);
}
$file = $_FILES['gambar'];
if ($file['error'] !== UPLOAD_ERR_OK) {
    $pesan = in_array($file['error'], [UPLOAD_ERR_INI_SIZE, UPLOAD_ERR_FORM_SIZE], true)
        ? 'Ukuran gambar terlalu besar (maks 2 MB)'
        : 'Upload gambar gagal (kode ' . $file['error'] . ')';
    jsonResponse(false, $pesan, null, 422);
}
if ($file['size'] > UPLOAD_MAX_BYTES) {
    jsonResponse(false, 'Ukuran gambar terlalu besar (maks 2 MB)', null, 422);
}
$info = @getimagesize($file['tmp_name']);
$ekstensi = [IMAGETYPE_JPEG => 'jpg', IMAGETYPE_PNG => 'png', IMAGETYPE_WEBP => 'webp'];
if ($info === false || !isset($ekstensi[$info[2]])) {
    jsonResponse(false, 'Format gambar harus JPG, PNG, atau WEBP', null, 422);
}
if (!is_dir(UPLOAD_DIR)) {
    mkdir(UPLOAD_DIR, 0775, true);
}
$namaFile = 'menu_' . date('YmdHis') . '_' . bin2hex(random_bytes(4)) . '.' . $ekstensi[$info[2]];
if (!move_uploaded_file($file['tmp_name'], UPLOAD_DIR . $namaFile)) {
    jsonResponse(false, 'Gagal menyimpan file gambar di server', null, 500);
}

$menuId = inputInt($_POST, 'menu_id');
try {
    if ($menuId !== null && $menuId > 0) {
        $db = getConnection();
        $lama = ambilMenu($db, $menuId);
        if ($lama === null) {
            @unlink(UPLOAD_DIR . $namaFile);
            jsonResponse(false, 'Menu tidak ditemukan', null, 404);
        }
        $db->prepare('UPDATE menu SET gambar = ? WHERE id = ?')->execute([$namaFile, $menuId]);
        if ($lama['gambar'] && is_file(UPLOAD_DIR . $lama['gambar'])) {
            @unlink(UPLOAD_DIR . $lama['gambar']);
        }
    }
    jsonResponse(true, 'Gambar berhasil diupload', ['gambar' => $namaFile], 201);
} catch (PDOException $e) {
    error_log($e->getMessage());
    jsonResponse(false, 'Gambar terupload tetapi gagal memperbarui menu', null, 500);
}
