import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/services/api_service.dart';
import '../data/services/kategori_service.dart';
import '../data/services/menu_service.dart';
import '../models/kategori.dart';
import '../models/menu.dart';

/// Katalog menu: pencarian realtime (debounce 400 ms) + filter kategori (ChoiceChip).
class KatalogController extends GetxController {
  KategoriService get _kategoriService => Get.find<KategoriService>();
  MenuService get _menuService => Get.find<MenuService>();

  final searchController = TextEditingController();
  final menus = <Menu>[].obs;
  final kategoriList = <Kategori>[].obs;
  final keyword = ''.obs;
  final selectedKategoriId = RxnInt();
  final isLoading = true.obs;
  final errorMessage = RxnString();

  int _requestId = 0;

  @override
  void onInit() {
    super.onInit();
    // Pencarian realtime: request dikirim 400 ms setelah user berhenti mengetik.
    debounce<String>(keyword, (_) => fetchMenus(), time: const Duration(milliseconds: 400));
    // Filter kategori langsung memuat ulang.
    ever<int?>(selectedKategoriId, (_) => fetchMenus());
    fetchKategori();
    fetchMenus();
  }

  void onSearchChanged(String value) => keyword.value = value;

  void clearSearch() {
    searchController.clear();
    keyword.value = '';
  }

  void selectKategori(int? id) => selectedKategoriId.value = id;

  Future<void> fetchKategori() async {
    try {
      kategoriList.assignAll(await _kategoriService.getAll());
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {}
  }

  Future<void> fetchMenus({bool silent = false}) async {
    final id = ++_requestId;
    if (!silent) isLoading.value = true;
    try {
      final data = await _menuService.getAll(search: keyword.value, kategoriId: selectedKategoriId.value);
      if (id != _requestId) return; // abaikan respons lama
      menus.assignAll(data);
      errorMessage.value = null;
    } on ApiException catch (e) {
      if (id == _requestId) errorMessage.value = e.message;
    } catch (e) {
      if (id == _requestId) errorMessage.value = 'Terjadi kesalahan: $e';
    } finally {
      if (id == _requestId) isLoading.value = false;
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([fetchKategori(), fetchMenus(silent: true)]);
  }

  String get infoHasil {
    final kategori = kategoriList.firstWhereOrNull((k) => k.id == selectedKategoriId.value)?.nama;
    final parts = <String>[
      if (keyword.value.trim().isNotEmpty) '"${keyword.value.trim()}"',
      if (kategori != null) 'kategori $kategori',
    ];
    return parts.isEmpty ? '${menus.length} menu tersedia' : '${menus.length} hasil untuk ${parts.join(' di ')}';
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
