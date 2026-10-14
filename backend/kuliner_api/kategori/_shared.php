<?php
/** Fungsi bantu kategori (validasi & cek duplikat case-insensitive). */
declare(strict_types=1);

function validasiKategori(array $input): array
{
    $nama = inputString($input, 'nama');
    $deskripsi = inputString($input, 'deskripsi');
    $ikon = inputString($input, 'ikon');
    $errors = [];
    if ($nama === null) {
        $errors['nama'] = 'Nama kategori wajib diisi';
    } elseif (mb_strlen($nama) > 50) {
        $errors['nama'] = 'Nama kategori maksimal 50 karakter';
    }
    if ($deskripsi !== null && mb_strlen($deskripsi) > 255) {
        $errors['deskripsi'] = 'Deskripsi maksimal 255 karakter';
    }
    if ($errors) {
        jsonResponse(false, reset($errors), ['errors' => $errors], 422);
    }
    return ['nama' => $nama, 'deskripsi' => $deskripsi, 'ikon' => $ikon];
}

function namaKategoriDipakai(PDO $db, string $nama, ?int $kecualiId = null): bool
{
    $sql = 'SELECT id FROM kategori WHERE LOWER(TRIM(nama)) = LOWER(TRIM(?))';
    $params = [$nama];
    if ($kecualiId !== null) {
        $sql .= ' AND id <> ?';
        $params[] = $kecualiId;
    }
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    return (bool) $stmt->fetchColumn();
}

function ambilKategori(PDO $db, int $id): ?array
{
    $stmt = $db->prepare('SELECT k.*, (SELECT COUNT(*) FROM menu m WHERE m.kategori_id = k.id) AS jumlah_menu
                          FROM kategori k WHERE k.id = ?');
    $stmt->execute([$id]);
    $row = $stmt->fetch();
    return $row ? castRow($row, ['id', 'jumlah_menu']) : null;
}
