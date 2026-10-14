import 'package:get/get.dart';

import '../controllers/checkout_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/katalog_controller.dart';
import '../controllers/kategori_controller.dart';
import '../controllers/main_controller.dart';
import '../controllers/menu_admin_controller.dart';
import '../controllers/menu_detail_controller.dart';
import '../controllers/pesanan_controller.dart';
import '../controllers/struk_controller.dart';

/// Halaman utama (bottom navigation): Beranda, Katalog, Keranjang, Pesanan, Kelola.
class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => KatalogController());
    Get.lazyPut(() => PesananController());
  }
}

class MenuDetailBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => MenuDetailController());
}

class CheckoutBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => CheckoutController());
}

class PesananDetailBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => PesananDetailController());
}

class StrukBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => StrukController());
}

class DashboardBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => DashboardController());
}

class KategoriBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => KategoriController());
}

class KategoriFormBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => KategoriFormController());
}

class MenuAdminBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => MenuAdminController());
}

class MenuFormBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => MenuFormController());
}
