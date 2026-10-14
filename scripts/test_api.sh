#!/usr/bin/env bash
# Uji otomatis endpoint REST API kuliner_api dengan curl.
# Pemakaian:  bash scripts/test_api.sh [BASE_URL]
# Default BASE_URL: http://localhost/kuliner_api
# PERINGATAN: script ini MENGUBAH data (menambah/menghapus kategori, menu, pesanan).
#             Import ulang database/db_kuliner.sql setelah pengujian bila perlu.
set -u
BASE="${1:-http://localhost/kuliner_api}"
PASS=0; FAIL=0
TMP="$(mktemp)"

req() { # method path [json]
  local m="$1" p="$2" d="${3:-}"
  if [ "$m" = "GET" ]; then
    CODE=$(curl -s -o "$TMP" -w '%{http_code}' "$BASE/$p")
  else
    CODE=$(curl -s -o "$TMP" -w '%{http_code}' -X "$m" -H 'Content-Type: application/json' -d "$d" "$BASE/$p")
  fi
  BODY=$(cat "$TMP")
}
check() { # nama expected_code [grep_pattern]
  local nama="$1" exp="$2" pat="${3:-}"
  if [ "$CODE" = "$exp" ] && { [ -z "$pat" ] || grep -q -- "$pat" "$TMP"; }; then
    PASS=$((PASS+1)); printf 'PASS  %-55s HTTP %s\n' "$nama" "$CODE"
  else
    FAIL=$((FAIL+1)); printf 'FAIL  %-55s HTTP %s (harap %s) %s\n' "$nama" "$CODE" "$exp" "${BODY:0:160}"
  fi
}
json() { php -r '$d=json_decode(stream_get_contents(STDIN),true); $p=explode(".",$argv[1]); foreach($p as $k){$d=$d[$k]??null;} echo is_scalar($d)?$d:json_encode($d);' "$1" < "$TMP"; }

echo "== Uji API: $BASE"
req GET ""; check "Cek API & koneksi database" 200 '"success":true'

# ---------------- Kategori ----------------
req GET kategori/read.php; check "Kategori read" 200 '"nama":"Makanan Utama"'
req POST kategori/create.php '{"nama":"   "}'; check "Kategori create nama kosong -> 422" 422 'wajib diisi'
req POST kategori/create.php '{"nama":"minuman"}'; check "Kategori create duplikat (case-insensitive) -> 409" 409 'sudah ada'
req POST kategori/create.php '{"nama":"Uji Kategori","deskripsi":"sementara"}'; check "Kategori create valid -> 201" 201 '"nama":"Uji Kategori"'
KID=$(json data.id)
req POST kategori/update.php "{\"id\":$KID,\"nama\":\"SNACK\"}"; check "Kategori update ke nama duplikat -> 409" 409 'sudah ada'
req POST kategori/update.php "{\"id\":$KID,\"nama\":\"Uji Kategori 2\"}"; check "Kategori update valid" 200 'Uji Kategori 2'
req POST kategori/delete.php '{"id":3}'; check "Kategori hapus yang masih punya menu -> 409" 409 'tidak dapat dihapus'
req GET kategori/create.php; check "Method salah (GET ke create) -> 405" 405 'tidak diizinkan'

# ---------------- Menu ----------------
req GET "menu/read.php"; check "Menu read (JOIN nama_kategori)" 200 '"nama_kategori"'
req GET "menu/read.php?search=kopi"; check "Menu search 'kopi'" 200 'Kopi Susu Gula Aren'
req GET "menu/read.php?kategori_id=2&search=lemon"; check "Menu search + filter kategori" 200 'Lemon Mint Squash'
req GET "menu/detail.php?id=9999"; check "Menu detail tidak ada -> 404" 404
req POST menu/create.php "{\"kategori_id\":$KID,\"nama\":\"\",\"harga\":0,\"stok\":-1,\"deskripsi\":\"\",\"level_pedas\":\"Pedas\",\"suhu_sajian\":\"Panas\",\"estimasi_saji\":0}"
check "Menu create field tidak valid -> 422" 422 'errors'
req POST menu/create.php "{\"kategori_id\":$KID,\"nama\":\"Menu Uji\",\"harga\":15000,\"stok\":3,\"deskripsi\":\"Untuk pengujian\",\"level_pedas\":\"Sedang\",\"suhu_sajian\":\"Dingin\",\"estimasi_saji\":7,\"is_best_seller\":true}"
check "Menu create valid -> 201" 201 '"nama_kategori":"Uji Kategori 2"'
MID=$(json data.id)
IMG="$(mktemp --suffix=.png 2>/dev/null || echo /tmp/uji.png)"
php -r '$im=imagecreatetruecolor(40,30); imagefill($im,0,0,imagecolorallocate($im,244,132,95)); imagepng($im,$argv[1]);' "$IMG" 2>/dev/null
CODE=$(curl -s -o "$TMP" -w '%{http_code}' -F "gambar=@$IMG;type=image/png" -F "menu_id=$MID" "$BASE/menu/upload_gambar.php"); BODY=$(cat "$TMP")
check "Upload gambar menu (multipart) -> 201" 201 'menu_'
echo "teks" > "$IMG.txt"
CODE=$(curl -s -o "$TMP" -w '%{http_code}' -F "gambar=@$IMG.txt" "$BASE/menu/upload_gambar.php"); BODY=$(cat "$TMP")
check "Upload file bukan gambar -> 422" 422 'Format gambar'
req POST menu/update.php "{\"id\":$MID,\"kategori_id\":$KID,\"nama\":\"Menu Uji Edit\",\"harga\":16000,\"stok\":3,\"deskripsi\":\"Edit\",\"level_pedas\":\"Pedas\",\"suhu_sajian\":\"Panas\",\"estimasi_saji\":8,\"is_best_seller\":false}"
check "Menu update" 200 'Menu Uji Edit'

# ---------------- Keranjang ----------------
req POST keranjang/clear.php; check "Keranjang clear" 200
req POST keranjang/add.php '{"menu_id":5,"jumlah":1}'; check "Tambah menu stok 0 (habis) -> 422" 422 'habis'
req POST keranjang/add.php "{\"menu_id\":$MID,\"jumlah\":4}"; check "Tambah melebihi stok -> 422" 422 'melebihi stok'
req POST keranjang/add.php "{\"menu_id\":$MID,\"jumlah\":2,\"catatan_item\":\"less sugar\"}"; check "Tambah ke keranjang + catatan -> 201" 201 'less sugar'
CID=$(json data.id)
req POST keranjang/add.php "{\"menu_id\":$MID,\"jumlah\":2}"; check "Tambah lagi (total > stok) -> 422" 422 'tersisa'
req POST keranjang/update_qty.php "{\"id\":$CID,\"jumlah\":4}"; check "Update qty > stok -> 422" 422 'hanya tersisa'
req POST keranjang/update_qty.php "{\"id\":$CID,\"jumlah\":0}"; check "Update qty < 1 -> 422" 422 'minimal 1'
req POST keranjang/update_qty.php "{\"id\":$CID,\"jumlah\":3}"; check "Update qty valid (=stok)" 200 '"jumlah":3'
req POST keranjang/update_catatan.php "{\"id\":$CID,\"catatan_item\":\"tanpa es\"}"; check "Update catatan item" 200 'tanpa es'
req POST keranjang/add.php '{"menu_id":1,"jumlah":2}'; check "Tambah menu kedua" 201
req GET keranjang/read.php; check "Keranjang read (subtotal per item)" 200 '"subtotal"'

# ---------------- Checkout ----------------
req POST pesanan/checkout.php '{"nama_pemesan":"","no_hp":"","tipe_pesanan":""}'; check "Checkout form kosong -> 422" 422 'wajib'
req POST pesanan/checkout.php '{"nama_pemesan":"Uji","no_hp":"62812345","tipe_pesanan":"Bawa Pulang"}'; check "Checkout no HP tidak valid -> 422" 422 'diawali 08'
req POST pesanan/checkout.php '{"nama_pemesan":"Uji","no_hp":"081234567890","tipe_pesanan":"Makan di Tempat"}'; check "Checkout Makan di Tempat tanpa meja -> 422" 422 'Nomor meja'
req POST pesanan/checkout.php '{"nama_pemesan":"Uji","no_hp":"081234567890","tipe_pesanan":"Diantar"}'; check "Checkout Diantar tanpa alamat -> 422" 422 'Alamat'
STOK_SEBELUM=$(curl -s "$BASE/menu/detail.php?id=$MID" | php -r 'echo json_decode(stream_get_contents(STDIN),true)["data"]["stok"];')
req POST pesanan/checkout.php '{"nama_pemesan":"Uji Checkout","no_hp":"081234567890","tipe_pesanan":"Diantar","alamat":"Jl. Uji No. 1","catatan":"tes"}'
check "Checkout sukses -> 201 + nomor INV" 201 '"nomor_pesanan":"INV-'
PID=$(json data.id); NOMOR=$(json data.nomor_pesanan); TOTAL=$(json data.total); DISKON=$(json data.diskon); ONGKIR=$(json data.ongkir)
# subtotal = 3*16000 + 2*32000 = 112000 -> diskon 11200, ongkir 8000, total 112000+2000+8000-11200 = 110800
[ "$TOTAL" = "110800" ] && [ "$DISKON" = "11200" ] && [ "$ONGKIR" = "8000" ] && { PASS=$((PASS+1)); echo "PASS  Perhitungan biaya (subtotal 112000 -> total 110800)"; } || { FAIL=$((FAIL+1)); echo "FAIL  Perhitungan biaya: total=$TOTAL diskon=$DISKON ongkir=$ONGKIR"; }
echo "$NOMOR" | grep -Eq "^INV-$(date +%Y%m%d)-[0-9]{3}$" && { PASS=$((PASS+1)); echo "PASS  Format nomor pesanan $NOMOR"; } || { FAIL=$((FAIL+1)); echo "FAIL  Format nomor pesanan $NOMOR"; }
STOK_SESUDAH=$(curl -s "$BASE/menu/detail.php?id=$MID" | php -r 'echo json_decode(stream_get_contents(STDIN),true)["data"]["stok"];')
[ "$STOK_SESUDAH" = "$((STOK_SEBELUM-3))" ] && { PASS=$((PASS+1)); echo "PASS  Stok berkurang otomatis ($STOK_SEBELUM -> $STOK_SESUDAH)"; } || { FAIL=$((FAIL+1)); echo "FAIL  Stok $STOK_SEBELUM -> $STOK_SESUDAH"; }
req GET keranjang/read.php; check "Keranjang kosong setelah checkout" 200 '"data":\[\]'
req POST pesanan/checkout.php '{"nama_pemesan":"Uji","no_hp":"081234567890","tipe_pesanan":"Bawa Pulang"}'; check "Checkout keranjang kosong -> 422" 422 'kosong'

# Stok tidak cukup saat checkout (stok diubah setelah masuk keranjang) -> rollback
# Checkout kedua di hari yang sama -> nomor urut NNN bertambah 1
req POST keranjang/add.php '{"menu_id":2,"jumlah":2}'
NEXT="${NOMOR%???}$(printf '%03d' $((10#${NOMOR: -3} + 1)))"
req POST pesanan/checkout.php '{"nama_pemesan":"Uji Kedua","no_hp":"081234567891","tipe_pesanan":"Makan di Tempat","nomor_meja":"7"}'
check "Checkout kedua -> nomor urut $NEXT" 201 "\"nomor_pesanan\":\"$NEXT\""
PID2=$(json data.id)

# ---------------- Riwayat & status ----------------
req GET pesanan/read.php; check "Riwayat pesanan (urut terbaru)" 200 "\"id\":$PID2"
FIRST=$(json data.0.id); [ "$FIRST" = "$PID2" ] && { PASS=$((PASS+1)); echo "PASS  Pesanan terbaru di urutan pertama"; } || { FAIL=$((FAIL+1)); echo "FAIL  urutan: first=$FIRST"; }
req GET "pesanan/read.php?status=Selesai"; check "Filter status Selesai" 200 '"status":"Selesai"'
req GET "pesanan/detail.php?id=$PID"; check "Detail pesanan + item & catatan" 200 'tanpa es'
req POST pesanan/update_status.php "{\"id\":$PID,\"status\":\"Dibatalkan\"}"; check "Batalkan pesanan -> stok kembali" 200 'dikembalikan'
STOK_BATAL=$(curl -s "$BASE/menu/detail.php?id=$MID" | php -r 'echo json_decode(stream_get_contents(STDIN),true)["data"]["stok"];')
[ "$STOK_BATAL" = "$STOK_SEBELUM" ] && { PASS=$((PASS+1)); echo "PASS  Stok dikembalikan ($STOK_SESUDAH -> $STOK_BATAL)"; } || { FAIL=$((FAIL+1)); echo "FAIL  Stok setelah batal $STOK_BATAL"; }
req POST pesanan/update_status.php "{\"id\":$PID,\"status\":\"Selesai\"}"; check "Ubah status pesanan yang sudah Dibatalkan -> 409" 409 'tidak dapat diubah'
req POST pesanan/update_status.php "{\"id\":$PID2,\"status\":\"Selesai\"}"; check "Tandai pesanan Selesai" 200 '"status":"Selesai"'

# ---------------- Dashboard ----------------
req GET dashboard/summary.php; check "Dashboard summary" 200 '"menu_terlaris"'

# ---------------- Bersih-bersih data uji ----------------
req POST menu/delete.php "{\"id\":$MID}"; check "Menu delete (riwayat tetap ada)" 200
req GET "pesanan/detail.php?id=$PID"; check "Riwayat tetap ada setelah menu dihapus (snapshot)" 200 'Menu Uji Edit'
req POST kategori/delete.php "{\"id\":$KID}"; check "Kategori delete (kosong)" 200

rm -f "$TMP" "$IMG" "$IMG.txt"
echo "== Selesai: $PASS lulus, $FAIL gagal"
[ "$FAIL" -eq 0 ]
