<?php
/**
 * Konfigurasi koneksi database & konstanta biaya pesanan.
 * Default XAMPP: host 127.0.0.1, user root, password kosong.
 */
declare(strict_types=1);

date_default_timezone_set('Asia/Jakarta');

define('DB_HOST', getenv('DB_HOST') ?: '127.0.0.1');
define('DB_PORT', getenv('DB_PORT') ?: '3306');
define('DB_NAME', getenv('DB_NAME') ?: 'db_kuliner');
define('DB_USER', getenv('DB_USER') ?: 'root');
define('DB_PASS', getenv('DB_PASS') !== false ? (string) getenv('DB_PASS') : '');

// Konstanta biaya (harus sama dengan lib/app/data/services/api_config.dart)
const BIAYA_LAYANAN = 2000;
const ONGKIR_DIANTAR = 8000;
const DISKON_MIN_SUBTOTAL = 100000;
const DISKON_PERSEN = 10;

// Upload gambar menu
const UPLOAD_DIR = __DIR__ . '/../uploads/';
const UPLOAD_MAX_BYTES = 2 * 1024 * 1024; // 2 MB

/**
 * Membuat koneksi PDO (prepared statement asli, mode exception).
 */
function getConnection(): PDO
{
    static $pdo = null;
    if ($pdo instanceof PDO) {
        return $pdo;
    }
    $dsn = sprintf('mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4', DB_HOST, DB_PORT, DB_NAME);
    $pdo = new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
    $pdo->exec("SET time_zone = '+07:00'");
    return $pdo;
}

/**
 * Menghitung rincian biaya pesanan.
 * Total = subtotal + biaya layanan + ongkir - diskon
 */
function hitungBiaya(float $subtotal, string $tipePesanan): array
{
    $ongkir = $tipePesanan === 'Diantar' ? ONGKIR_DIANTAR : 0;
    $diskon = $subtotal >= DISKON_MIN_SUBTOTAL ? round($subtotal * DISKON_PERSEN / 100) : 0;
    $biayaLayanan = $subtotal > 0 ? BIAYA_LAYANAN : 0;
    return [
        'subtotal' => $subtotal,
        'biaya_layanan' => (float) $biayaLayanan,
        'ongkir' => (float) $ongkir,
        'diskon' => (float) $diskon,
        'total' => (float) ($subtotal + $biayaLayanan + $ongkir - $diskon),
    ];
}
