<?php
/** Fungsi bantu keranjang. */
declare(strict_types=1);

const KERANJANG_SELECT = 'SELECT c.id, c.menu_id, c.jumlah, c.catatan_item, c.created_at,
                                 m.nama AS nama_menu, m.harga, m.stok, m.gambar, m.level_pedas,
                                 m.suhu_sajian, m.estimasi_saji, k.nama AS nama_kategori,
                                 (m.harga * c.jumlah) AS subtotal
                          FROM keranjang c
                          JOIN menu m ON m.id = c.menu_id
                          JOIN kategori k ON k.id = m.kategori_id';

function castKeranjang(array $row): array
{
    return castRow($row, ['id', 'menu_id', 'jumlah', 'stok', 'estimasi_saji'], ['harga', 'subtotal']);
}

function ambilItemKeranjang(PDO $db, int $id): ?array
{
    $stmt = $db->prepare(KERANJANG_SELECT . ' WHERE c.id = ?');
    $stmt->execute([$id]);
    $row = $stmt->fetch();
    return $row ? castKeranjang($row) : null;
}

function validasiCatatan(?string $catatan): ?string
{
    if ($catatan !== null && mb_strlen($catatan) > 150) {
        jsonResponse(false, 'Catatan item maksimal 150 karakter', null, 422);
    }
    return $catatan;
}
