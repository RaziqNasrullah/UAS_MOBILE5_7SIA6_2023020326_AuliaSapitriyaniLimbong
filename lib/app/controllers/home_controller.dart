import 'package:get/get.dart';

import '../data/services/api_service.dart';
import '../data/services/kategori_service.dart';
import '../data/services/menu_service.dart';
import '../models/kategori.dart';
import '../models/menu.dart';
import '../utils/formatter.dart';

class HomeController extends GetxController {
  KategoriService get _kategoriService => Get.find<KategoriService>();
  MenuService get _menuService => Get.find<MenuService>();

  final kategoriList = <Kategori>[].obs;
  final bestSellers = <Menu>[].obs;
  final menuTerbaru = <Menu>[].obs;
  final isLoading = true.obs;
  final errorMessage = RxnString();
  final sapaan = Formatter.sapaan().obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    sapaan.value = Formatter.sapaan();
    try {
      final results = await Future.wait([
        _kategoriService.getAll(),
        _menuService.getAll(bestSeller: true),
        _menuService.getAll(sort: 'terbaru', limit: 6),
      ]);
      kategoriList.assignAll(results[0] as List<Kategori>);
      bestSellers.assignAll(results[1] as List<Menu>);
      menuTerbaru.assignAll(results[2] as List<Menu>);
      errorMessage.value = null;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
