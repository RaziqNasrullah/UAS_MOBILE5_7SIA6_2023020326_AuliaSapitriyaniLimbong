<?php
/** Fungsi bantu menu: query JOIN, validasi, casting. */
declare(strict_types=1);

const LEVEL_PEDAS = ['Tidak Pedas', 'Sedang', 'Pedas', 'Extra Pedas'];
const SUHU_SAJIAN = ['Panas', 'Dingin', 'Suhu Ruang'];

const MENU_SELECT = 'SELECT m.*, k.nama AS nama_kategori
                     FROM menu m
                     JOIN kategori k ON m.kategori_id = k.id';

function castMenu(array $row): array
{
    return castRow($row, ['id', 'kategori_id', 'stok', 'estimasi_saji'], ['harga'], ['is_best_seller']);
}

function ambilMenu(PDO $db, int $id): ?array
{
    $stmt = $db->prepare(MENU_SELECT . ' WHERE m.id = ?');
    $stmt->execute([$id]);
    $row = $stmt->fetch();
    return $row ? castMenu($row) : null;
}

function validasiMenu(PDO $db, array $input, ?string $gambarLama = null): array
{
    $errors = [];
    $nama = inputString($input, 'nama');
    $kategoriId = inputInt($input, 'kategori_id');
    $harga = inputFloat($input, 'harga');
    $stok = inputInt($input, 'stok');
    $deskripsi = inputString($input, 'deskripsi');
    $gambar = inputString($input, 'gambar');
    $levelPedas = inputString($input, 'level_pedas');
    $suhuSajian = inputString($input, 'suhu_sajian');
    $estimasi = inputInt($input, 'estimasi_saji');
    $bestSeller = filter_var($input['is_best_seller'] ?? false, FILTER_VALIDATE_BOOLEAN);

    if ($nama === null) {
        $errors['nama'] = 'Nama menu wajib diisi';
    } elseif (mb_strlen($nama) > 100) {
        $errors['nama'] = 'Nama menu maksimal 100 karakter';
    }
    if ($kategoriId === null || $kategoriId <= 0) {
        $errors['kategori_id'] = 'Kategori wajib dipilih';
    } else {
        $cek = $db->prepare('SELECT COUNT(*) FROM kategori WHERE id = ?');
        $cek->execute([$kategoriId]);
        if (!(int) $cek->fetchColumn()) {
            $errors['kategori_id'] = 'Kategori tidak ditemukan';
        }
    }
    if ($harga === null || $harga <= 0) {
        $errors['harga'] = 'Harga wajib berupa angka lebih dari 0';
    }
    if ($stok === null || $stok < 0) {
        $errors['stok'] = 'Stok wajib berupa angka bulat minimal 0';
    }
    if ($deskripsi === null) {
        $errors['deskripsi'] = 'Deskripsi wajib diisi';
    }
    if ($levelPedas === null || !in_array($levelPedas, LEVEL_PEDAS, true)) {
        $errors['level_pedas'] = 'Level pedas tidak valid';
    }
    if ($suhuSajian === null || !in_array($suhuSajian, SUHU_SAJIAN, true)) {
        $errors['suhu_sajian'] = 'Suhu sajian tidak valid';
    }
    if ($estimasi === null || $estimasi <= 0) {
        $errors['estimasi_saji'] = 'Estimasi saji wajib berupa angka lebih dari 0 menit';
    }
    if ($gambar !== null && $gambar !== $gambarLama && (basename($gambar) !== $gambar || !is_file(UPLOAD_DIR . $gambar))) {
        $errors['gambar'] = 'File gambar tidak ditemukan, silakan upload ulang';
    }
    if ($errors) {
        jsonResponse(false, reset($errors), ['errors' => $errors], 422);
    }
    return [
        'kategori_id' => $kategoriId,
        'nama' => $nama,
        'harga' => $harga,
        'stok' => $stok,
        'deskripsi' => $deskripsi,
        'gambar' => $gambar,
        'level_pedas' => $levelPedas,
        'suhu_sajian' => $suhuSajian,
        'estimasi_saji' => $estimasi,
        'is_best_seller' => $bestSeller ? 1 : 0,
    ];
}
