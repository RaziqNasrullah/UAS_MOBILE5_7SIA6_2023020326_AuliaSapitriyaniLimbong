import 'package:get/get.dart';

import 'cart_controller.dart';
import 'pesanan_controller.dart';

/// Mengatur tab aktif pada bottom navigation.
class MainController extends GetxController {
  static const tabBeranda = 0;
  static const tabKatalog = 1;
  static const tabKeranjang = 2;
  static const tabPesanan = 3;
  static const tabKelola = 4;

  final tabIndex = 0.obs;

  void changeTab(int index) {
    tabIndex.value = index;
    // Muat ulang data yang mungkin berubah saat tab dibuka.
    if (index == tabKeranjang) Get.find<CartController>().fetchCart(silent: true);
    if (index == tabPesanan && Get.isRegistered<PesananController>()) {
      Get.find<PesananController>().fetchPesanan(silent: true);
    }
  }
}
