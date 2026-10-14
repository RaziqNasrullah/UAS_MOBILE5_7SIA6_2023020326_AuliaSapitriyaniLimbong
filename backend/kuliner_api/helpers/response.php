<?php
/**
 * Helper respons JSON seragam: { success, message, data }
 */
declare(strict_types=1);

require_once __DIR__ . '/../config/database.php';

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept');

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// Semua error/exception yang tidak tertangkap tetap dikembalikan sebagai JSON.
ini_set('display_errors', '0');
set_exception_handler(function (Throwable $e): void {
    $pesan = $e instanceof PDOException
        ? 'Gagal mengakses database. Pastikan MySQL XAMPP aktif dan database db_kuliner sudah di-import.'
        : 'Terjadi kesalahan pada server.';
    error_log('[kuliner_api] ' . $e->getMessage());
    jsonResponse(false, $pesan, null, 500);
});
set_error_handler(function (int $no, string $str, string $file, int $line): bool {
    // Hormati operator @ (error yang sengaja disenyapkan, mis. @getimagesize).
    if (!(error_reporting() & $no)) {
        return false;
    }
    throw new ErrorException($str, 0, $no, $file, $line);
});

/**
 * Mengirim respons JSON lalu menghentikan script.
 */
function jsonResponse(bool $success, string $message, $data = null, int $status = 200): void
{
    http_response_code($status);
    echo json_encode(
        ['success' => $success, 'message' => $message, 'data' => $data],
        JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_PRESERVE_ZERO_FRACTION
    );
    exit;
}

/**
 * Memastikan HTTP method sesuai, jika tidak -> 405.
 */
function requireMethod(string $method): void
{
    $current = $_SERVER['REQUEST_METHOD'] ?? 'GET';
    if (strtoupper($current) !== strtoupper($method)) {
        header('Allow: ' . strtoupper($method));
        jsonResponse(false, "Method $current tidak diizinkan. Gunakan $method.", null, 405);
    }
}

/**
 * Membaca body request (JSON atau form-urlencoded / multipart).
 */
function getInput(): array
{
    $raw = file_get_contents('php://input');
    if ($raw !== false && $raw !== '') {
        $json = json_decode($raw, true);
        if (is_array($json)) {
            return $json;
        }
    }
    return $_POST;
}

/**
 * Mengambil string yang sudah di-trim (null jika kosong).
 */
function inputString(array $input, string $key): ?string
{
    if (!isset($input[$key]) || is_array($input[$key])) {
        return null;
    }
    $value = trim((string) $input[$key]);
    return $value === '' ? null : $value;
}

/**
 * Mengambil integer (null jika bukan angka bulat).
 */
function inputInt(array $input, string $key): ?int
{
    if (!isset($input[$key]) || is_array($input[$key])) {
        return null;
    }
    $value = filter_var($input[$key], FILTER_VALIDATE_INT);
    return $value === false ? null : (int) $value;
}

/**
 * Mengambil angka desimal (null jika bukan angka).
 */
function inputFloat(array $input, string $key): ?float
{
    if (!isset($input[$key]) || is_array($input[$key])) {
        return null;
    }
    $value = filter_var($input[$key], FILTER_VALIDATE_FLOAT);
    return $value === false ? null : (float) $value;
}

/**
 * Mengubah kolom numerik hasil query menjadi tipe angka yang benar.
 */
function castRow(array $row, array $intKeys = [], array $floatKeys = [], array $boolKeys = []): array
{
    foreach ($intKeys as $k) {
        if (array_key_exists($k, $row) && $row[$k] !== null) {
            $row[$k] = (int) $row[$k];
        }
    }
    foreach ($floatKeys as $k) {
        if (array_key_exists($k, $row) && $row[$k] !== null) {
            $row[$k] = (float) $row[$k];
        }
    }
    foreach ($boolKeys as $k) {
        if (array_key_exists($k, $row) && $row[$k] !== null) {
            $row[$k] = (bool) $row[$k];
        }
    }
    return $row;
}
