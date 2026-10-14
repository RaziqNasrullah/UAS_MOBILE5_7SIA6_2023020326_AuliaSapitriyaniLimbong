import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../data/services/api_service.dart';
import '../data/services/kategori_service.dart';
import '../data/services/menu_service.dart';
import '../models/kategori.dart';
import '../models/menu.dart';
import '../routes/app_routes.dart';
import '../utils/app_snackbar.dart';
import 'kategori_controller.dart';

/// CRUD menu (daftar admin + hapus). Nama kategori berasal dari JOIN di backend.
class MenuAdminController extends GetxController {
  MenuService get _service => Get.find<MenuService>();

  final menus = <Menu>[].obs;
  final keyword = ''.obs;
  final isLoading = true.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    debounce<String>(keyword, (_) => fetchMenus(silent: true), time: const Duration(milliseconds: 400));
    fetchMenus();
  }

  Future<void> fetchMenus({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    try {
      menus.assignAll(await _service.getAll(search: keyword.value));
      errorMessage.value = null;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> bukaForm([Menu? menu]) async {
    final berubah = await Get.toNamed(AppRoutes.menuForm, arguments: menu);
    if (berubah == true) {
      await fetchMenus(silent: true);
      KategoriController.refreshHalamanLain();
    }
  }

  Future<void> hapus(Menu menu) async {
    final ok = await konfirmasi(
      judul: 'Hapus menu?',
      pesan: 'Menu "${menu.nama}" akan dihapus. Riwayat pesanan tetap tersimpan.',
      labelYa: 'Hapus',
      warnaYa: const Color(0xFFD64545),
    );
    if (!ok) return;
    try {
      final pesan = await _service.delete(menu.id);
      menus.removeWhere((m) => m.id == menu.id);
      AppSnackbar.success(pesan);
      KategoriController.refreshHalamanLain();
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
    } catch (e) {
      AppSnackbar.error('Gagal menghapus menu: $e');
    }
  }
}

/// Form tambah / edit menu (termasuk upload gambar dari galeri).
class MenuFormController extends GetxController {
  MenuService get _menuService => Get.find<MenuService>();
  KategoriService get _kategoriService => Get.find<KategoriService>();

  final formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final hargaController = TextEditingController();
  final stokController = TextEditingController();
  final deskripsiController = TextEditingController();
  final estimasiController = TextEditingController(text: '10');

  final kategoriList = <Kategori>[].obs;
  final kategoriId = RxnInt();
  final levelPedas = 'Tidak Pedas'.obs;
  final suhuSajian = 'Panas'.obs;
  final isBestSeller = false.obs;
  final pickedImage = Rxn<File>();
  final isLoadingKategori = true.obs;
  final isSaving = false.obs;

  Menu? editing;
  bool get isEdit => editing != null;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Menu) {
      editing = arg;
      namaController.text = arg.nama;
      hargaController.text = arg.harga.toStringAsFixed(0);
      stokController.text = '${arg.stok}';
      deskripsiController.text = arg.deskripsi;
      estimasiController.text = '${arg.estimasiSaji}';
      kategoriId.value = arg.kategoriId;
      levelPedas.value = arg.levelPedas;
      suhuSajian.value = arg.suhuSajian;
      isBestSeller.value = arg.isBestSeller;
    }
    fetchKategori();
  }

  /// Dropdown kategori diisi dari tabel kategori (FK).
  Future<void> fetchKategori() async {
    isLoadingKategori.value = true;
    try {
      kategoriList.assignAll(await _kategoriService.getAll());
      if (kategoriId.value != null && !kategoriList.any((k) => k.id == kategoriId.value)) {
        kategoriId.value = null;
      }
    } on ApiException catch (e) {
      AppSnackbar.error(e.message, title: 'Gagal memuat kategori');
    } catch (e) {
      AppSnackbar.error('Gagal memuat kategori: $e');
    } finally {
      isLoadingKategori.value = false;
    }
  }

  Future<void> pilihGambar() async {
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 80);
      if (file != null) pickedImage.value = File(file.path);
    } catch (e) {
      AppSnackbar.error('Tidak dapat membuka galeri: $e');
    }
  }

  Future<void> simpan() async {
    if (isSaving.value) return;
    if (!(formKey.currentState?.validate() ?? false)) {
      AppSnackbar.warning('Lengkapi semua field yang wajib diisi');
      return;
    }
    if (kategoriId.value == null) {
      AppSnackbar.warning('Kategori wajib dipilih');
      return;
    }
    isSaving.value = true;
    try {
      String? gambar = editing?.gambar;
      if (pickedImage.value != null) {
        gambar = await _menuService.uploadGambar(pickedImage.value!.path);
      }
      final menu = Menu(
        id: editing?.id ?? 0,
        kategoriId: kategoriId.value!,
        nama: namaController.text.trim(),
        harga: double.parse(hargaController.text.trim().replaceAll('.', '').replaceAll(',', '.')),
        stok: int.parse(stokController.text.trim()),
        deskripsi: deskripsiController.text.trim(),
        gambar: gambar,
        levelPedas: levelPedas.value,
        suhuSajian: suhuSajian.value,
        estimasiSaji: int.parse(estimasiController.text.trim()),
        isBestSeller: isBestSeller.value,
      );
      final hasil = isEdit ? await _menuService.update(menu) : await _menuService.create(menu);
      tutup(true);
      AppSnackbar.success('Menu "${hasil.nama}" berhasil ${isEdit ? 'diperbarui' : 'ditambahkan'}');
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
    } catch (e) {
      AppSnackbar.error('Gagal menyimpan menu: $e');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    namaController.dispose();
    hargaController.dispose();
    stokController.dispose();
    deskripsiController.dispose();
    estimasiController.dispose();
    super.onClose();
  }
}
