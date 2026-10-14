import 'package:get/get.dart';

import '../data/services/api_service.dart';
import '../data/services/keranjang_service.dart';
import '../models/keranjang_item.dart';
import '../models/menu.dart';
import '../utils/app_snackbar.dart';

/// State keranjang global (disimpan di tabel `keranjang` lewat API).
class CartController extends GetxController {
  KeranjangService get _service => Get.find<KeranjangService>();

  final items = <KeranjangItem>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  /// id item yang sedang diproses (untuk menonaktifkan tombol).
  final busyIds = <int>{}.obs;

  /// Total porsi di keranjang (untuk badge).
  int get totalItem => items.fold(0, (sum, e) => sum + e.jumlah);

  /// Total harga seluruh item.
  double get subtotal => items.fold(0.0, (sum, e) => sum + e.subtotal);

  bool get isEmpty => items.isEmpty;

  int jumlahDiKeranjang(int menuId) =>
      items.firstWhereOrNull((e) => e.menuId == menuId)?.jumlah ?? 0;

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  Future<void> fetchCart({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    try {
      final data = await _service.getAll();
      items.assignAll(data);
      errorMessage.value = null;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      if (!silent) AppSnackbar.error(e.message);
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Menambah menu ke keranjang. Mengembalikan true jika berhasil.
  Future<bool> addToCart(Menu menu, {int jumlah = 1, String? catatan}) async {
    if (menu.isHabis) {
      AppSnackbar.warning('${menu.nama} sedang habis');
      return false;
    }
    final sudahAda = jumlahDiKeranjang(menu.id);
    if (sudahAda + jumlah > menu.stok) {
      final sisa = menu.stok - sudahAda;
      AppSnackbar.warning(sisa > 0
          ? 'Stok ${menu.nama} tersisa ${menu.stok}. Di keranjang sudah $sudahAda, maksimal tambah $sisa lagi.'
          : 'Seluruh stok ${menu.nama} (${menu.stok}) sudah ada di keranjang');
      return false;
    }
    try {
      final res = await _service.add(menuId: menu.id, jumlah: jumlah, catatan: catatan);
      _upsert(KeranjangItem.fromJson(res.dataMap));
      AppSnackbar.success(res.message);
      return true;
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
      if (e.statusCode == 422) fetchCart(silent: true);
      return false;
    } catch (e) {
      AppSnackbar.error('Gagal menambahkan ke keranjang: $e');
      return false;
    }
  }

  void increment(KeranjangItem item) {
    if (!item.bisaTambah) {
      AppSnackbar.warning('Jumlah tidak boleh melebihi stok (${item.stok} porsi)');
      return;
    }
    updateQty(item, item.jumlah + 1);
  }

  void decrement(KeranjangItem item) {
    if (!item.bisaKurang) {
      AppSnackbar.info('Jumlah minimal 1. Gunakan tombol hapus untuk menghapus item.');
      return;
    }
    updateQty(item, item.jumlah - 1);
  }

  Future<void> updateQty(KeranjangItem item, int jumlah) async {
    if (jumlah < 1 || jumlah > item.stok || busyIds.contains(item.id)) return;
    busyIds.add(item.id);
    final lama = item;
    _upsert(item.copyWith(jumlah: jumlah)); // optimistic update
    try {
      final res = await _service.updateQty(item.id, jumlah);
      _upsert(KeranjangItem.fromJson(res.dataMap));
    } on ApiException catch (e) {
      _upsert(lama);
      AppSnackbar.error(e.message);
    } catch (e) {
      _upsert(lama);
      AppSnackbar.error('Gagal mengubah jumlah: $e');
    } finally {
      busyIds.remove(item.id);
    }
  }

  Future<void> updateCatatan(KeranjangItem item, String catatan) async {
    final value = catatan.trim();
    try {
      final res = await _service.updateCatatan(item.id, value.isEmpty ? null : value);
      _upsert(KeranjangItem.fromJson(res.dataMap));
      AppSnackbar.success(res.message);
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
    } catch (e) {
      AppSnackbar.error('Gagal menyimpan catatan: $e');
    }
  }

  Future<void> removeItem(KeranjangItem item) async {
    busyIds.add(item.id);
    try {
      final res = await _service.delete(item.id);
      items.removeWhere((e) => e.id == item.id);
      AppSnackbar.success(res.message);
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
    } catch (e) {
      AppSnackbar.error('Gagal menghapus item: $e');
    } finally {
      busyIds.remove(item.id);
    }
  }

  Future<void> clearCart() async {
    try {
      final res = await _service.clear();
      items.clear();
      AppSnackbar.success(res.message);
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
    } catch (e) {
      AppSnackbar.error('Gagal mengosongkan keranjang: $e');
    }
  }

  /// Dipanggil setelah checkout sukses (keranjang sudah dikosongkan server).
  void resetLocal() => items.clear();

  void _upsert(KeranjangItem item) {
    final index = items.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      items[index] = item;
    } else {
      items.add(item);
    }
  }
}
