<?php
/** Fungsi bantu pesanan. */
declare(strict_types=1);

const TIPE_PESANAN = ['Makan di Tempat', 'Bawa Pulang', 'Diantar'];
const STATUS_PESANAN = ['Diproses', 'Selesai', 'Dibatalkan'];

function castPesanan(array $row): array
{
    return castRow($row, ['id', 'jumlah_item'], ['subtotal', 'biaya_layanan', 'ongkir', 'diskon', 'total']);
}

function castDetail(array $row): array
{
    return castRow($row, ['id', 'pesanan_id', 'menu_id', 'jumlah'], ['harga_satuan', 'subtotal']);
}

/** Mengambil pesanan beserta seluruh item detailnya. */
function ambilPesananLengkap(PDO $db, int $id): ?array
{
    $stmt = $db->prepare('SELECT p.*, (SELECT COALESCE(SUM(d.jumlah), 0) FROM detail_pesanan d WHERE d.pesanan_id = p.id) AS jumlah_item
                          FROM pesanan p WHERE p.id = ?');
    $stmt->execute([$id]);
    $pesanan = $stmt->fetch();
    if (!$pesanan) {
        return null;
    }
    $pesanan = castPesanan($pesanan);
    $stmt = $db->prepare('SELECT * FROM detail_pesanan WHERE pesanan_id = ? ORDER BY id ASC');
    $stmt->execute([$id]);
    $pesanan['items'] = array_map('castDetail', $stmt->fetchAll());
    return $pesanan;
}

/** Membuat nomor pesanan INV-YYYYMMDD-NNN (NNN reset setiap hari). Dipanggil di dalam transaksi. */
function buatNomorPesanan(PDO $db): string
{
    $prefix = 'INV-' . date('Ymd') . '-';
    $stmt = $db->prepare('SELECT nomor_pesanan FROM pesanan WHERE nomor_pesanan LIKE ? ORDER BY nomor_pesanan DESC LIMIT 1 FOR UPDATE');
    $stmt->execute([$prefix . '%']);
    $terakhir = $stmt->fetchColumn();
    $urut = $terakhir ? ((int) substr((string) $terakhir, -3)) + 1 : 1;
    return $prefix . str_pad((string) $urut, 3, '0', STR_PAD_LEFT);
}
