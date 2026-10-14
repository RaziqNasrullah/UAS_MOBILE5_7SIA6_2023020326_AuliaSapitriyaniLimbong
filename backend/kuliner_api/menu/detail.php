<?php
/** GET menu/detail.php?id= */
declare(strict_types=1);
require_once __DIR__ . '/../helpers/response.php';
require_once __DIR__ . '/_shared.php';
requireMethod('GET');

$id = inputInt($_GET, 'id');
if ($id === null || $id <= 0) {
    jsonResponse(false, 'ID menu tidak valid', null, 422);
}
try {
    $menu = ambilMenu(getConnection(), $id);
    if ($menu === null) {
        jsonResponse(false, 'Menu tidak ditemukan', null, 404);
    }
    jsonResponse(true, 'Detail menu berhasil dimuat', $menu);
} catch (PDOException $e) {
    error_log($e->getMessage());
    jsonResponse(false, 'Gagal memuat detail menu', null, 500);
}
