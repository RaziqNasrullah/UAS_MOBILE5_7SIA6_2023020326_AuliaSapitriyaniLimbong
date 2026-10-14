<?php
/**
 * GET dashboard/summary.php
 * - total_pesanan       : semua pesanan (+ rincian per status)
 * - total_pendapatan    : SUM(total) pesanan berstatus Selesai saja
 * - menu_terlaris       : 5 menu dengan SUM(jumlah) terbanyak (pesanan Dibatalkan tidak dihitung)
 * - pendapatan_7_hari   : pendapatan harian (Selesai) 7 hari terakhir
 * - penjualan_kategori  : porsi terjual per kategori (exclude Dibatalkan)
 */
declare(strict_types=1);
require_once __DIR__ . '/../helpers/response.php';
requireMethod('GET');

try {
    $db = getConnection();

    $status = ['Diproses' => 0, 'Selesai' => 0, 'Dibatalkan' => 0];
    foreach ($db->query('SELECT status, COUNT(*) AS jml FROM pesanan GROUP BY status') as $r) {
        $status[$r['status']] = (int) $r['jml'];
    }
    $totalPendapatan = (float) $db->query("SELECT COALESCE(SUM(total), 0) FROM pesanan WHERE status = 'Selesai'")->fetchColumn();
    $porsiTerjual = (int) $db->query("SELECT COALESCE(SUM(d.jumlah), 0) FROM detail_pesanan d
                                      JOIN pesanan p ON p.id = d.pesanan_id WHERE p.status <> 'Dibatalkan'")->fetchColumn();

    $menuTerlaris = $db->query("SELECT MAX(COALESCE(m.nama, d.nama_menu)) AS nama_menu, MAX(d.menu_id) AS menu_id,
                                       SUM(d.jumlah) AS total_terjual, SUM(d.subtotal) AS total_penjualan
                                FROM detail_pesanan d
                                JOIN pesanan p ON p.id = d.pesanan_id
                                LEFT JOIN menu m ON m.id = d.menu_id
                                WHERE p.status <> 'Dibatalkan'
                                GROUP BY COALESCE(CONCAT('m', d.menu_id), CONCAT('n', d.nama_menu))
                                ORDER BY total_terjual DESC, total_penjualan DESC
                                LIMIT 5")->fetchAll();
    $menuTerlaris = array_map(fn($r) => castRow($r, ['menu_id', 'total_terjual'], ['total_penjualan']), $menuTerlaris);

    $harian = [];
    $stmt = $db->query("SELECT DATE(tanggal) AS tgl, SUM(total) AS pendapatan, COUNT(*) AS jumlah
                        FROM pesanan
                        WHERE status = 'Selesai' AND tanggal >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
                        GROUP BY DATE(tanggal)");
    foreach ($stmt as $r) {
        $harian[$r['tgl']] = $r;
    }
    $pendapatan7Hari = [];
    for ($i = 6; $i >= 0; $i--) {
        $tgl = date('Y-m-d', strtotime("-$i day"));
        $pendapatan7Hari[] = [
            'tanggal' => $tgl,
            'pendapatan' => isset($harian[$tgl]) ? (float) $harian[$tgl]['pendapatan'] : 0.0,
            'jumlah_pesanan' => isset($harian[$tgl]) ? (int) $harian[$tgl]['jumlah'] : 0,
        ];
    }

    $perKategori = $db->query("SELECT COALESCE(k.nama, 'Menu Terhapus') AS nama_kategori, SUM(d.jumlah) AS total_terjual
                               FROM detail_pesanan d
                               JOIN pesanan p ON p.id = d.pesanan_id
                               LEFT JOIN menu m ON m.id = d.menu_id
                               LEFT JOIN kategori k ON k.id = m.kategori_id
                               WHERE p.status <> 'Dibatalkan'
                               GROUP BY nama_kategori
                               ORDER BY total_terjual DESC")->fetchAll();
    $perKategori = array_map(fn($r) => castRow($r, ['total_terjual']), $perKategori);

    jsonResponse(true, 'Ringkasan dashboard berhasil dimuat', [
        'total_pesanan' => array_sum($status),
        'pesanan_per_status' => $status,
        'total_pendapatan' => $totalPendapatan,
        'porsi_terjual' => $porsiTerjual,
        'menu_terlaris' => $menuTerlaris,
        'pendapatan_7_hari' => $pendapatan7Hari,
        'penjualan_kategori' => $perKategori,
    ]);
} catch (PDOException $e) {
    error_log($e->getMessage());
    jsonResponse(false, 'Gagal memuat ringkasan dashboard', null, 500);
}
