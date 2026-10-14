import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../data/services/api_service.dart';
import '../data/services/dashboard_service.dart';
import '../data/services/kategori_service.dart';
import '../data/services/keranjang_service.dart';
import '../data/services/menu_service.dart';
import '../data/services/pesanan_service.dart';

/// Dependency global: service API & CartController (permanen).
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<KategoriService>(KategoriService(), permanent: true);
    Get.put<MenuService>(MenuService(), permanent: true);
    Get.put<KeranjangService>(KeranjangService(), permanent: true);
    Get.put<PesananService>(PesananService(), permanent: true);
    Get.put<DashboardService>(DashboardService(), permanent: true);
    Get.put<CartController>(CartController(), permanent: true);
  }
}
