import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/services/api_service.dart';
import '../data/services/menu_service.dart';
import '../models/menu.dart';
import '../utils/app_snackbar.dart';
import 'cart_controller.dart';

/// Detail menu: jumlah pesanan & catatan per item sebelum masuk keranjang.
class MenuDetailController extends GetxController {
  MenuService get _menuService => Get.find<MenuService>();
  CartController get cart => Get.find<CartController>();

  late final Rx<Menu> menu;
  final qty = 1.obs;
  final isAdding = false.obs;
  final catatanController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is! Menu) {
      throw ArgumentError('MenuDetail membutuhkan arguments berupa Menu');
    }
    menu = arg.obs;
    _refreshStok();
  }

  /// Sisa porsi yang masih bisa ditambahkan (stok - yang sudah di keranjang).
  int get maxQty {
    final sisa = menu.value.stok - cart.jumlahDiKeranjang(menu.value.id);
    return sisa < 0 ? 0 : sisa;
  }

  double get totalHarga => menu.value.harga * qty.value;

  void setQty(int value) {
    if (value < 1) return;
    if (value > maxQty) {
      AppSnackbar.warning('Jumlah tidak boleh melebihi stok tersedia ($maxQty porsi)');
      return;
    }
    qty.value = value;
  }

  Future<void> _refreshStok() async {
    try {
      final terbaru = await _menuService.getDetail(menu.value.id);
      menu.value = terbaru;
      if (qty.value > maxQty && maxQty > 0) qty.value = maxQty;
    } on ApiException catch (_) {
      // data dari arguments tetap ditampilkan
    } catch (_) {}
  }

  Future<void> addToCart() async {
    if (isAdding.value) return;
    isAdding.value = true;
    final ok = await cart.addToCart(menu.value, jumlah: qty.value, catatan: catatanController.text.trim());
    isAdding.value = false;
    if (ok) {
      qty.value = 1;
      catatanController.clear();
    }
  }

  @override
  void onClose() {
    catatanController.dispose();
    super.onClose();
  }
}
