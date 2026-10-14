import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/services/api_service.dart';
import '../data/services/kategori_service.dart';
import '../models/kategori.dart';
import '../routes/app_routes.dart';
import '../utils/app_snackbar.dart';
import '../utils/validators.dart';
import 'home_controller.dart';
import 'katalog_controller.dart';

/// CRUD kategori (daftar + hapus).
class KategoriController extends GetxController {
  KategoriService get _service => Get.find<KategoriService>();

  final kategoriList = <Kategori>[].obs;
  final isLoading = true.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchKategori();
  }

  Future<void> fetchKategori({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    try {
      kategoriList.assignAll(await _service.getAll());
      errorMessage.value = null;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> bukaForm([Kategori? kategori]) async {
    final berubah = await Get.toNamed(AppRoutes.kategoriForm, arguments: kategori);
    if (berubah == true) {
      await fetchKategori(silent: true);
      refreshHalamanLain();
    }
  }

  Future<void> hapus(Kategori kategori) async {
    if (kategori.jumlahMenu > 0) {
      AppSnackbar.error(
        'Kategori "${kategori.nama}" masih memiliki ${kategori.jumlahMenu} menu. Pindahkan atau hapus menunya terlebih dahulu.',
        title: 'Tidak dapat dihapus',
      );
      return;
    }
    final ok = await konfirmasi(
      judul: 'Hapus kategori?',
      pesan: 'Kategori "${kategori.nama}" akan dihapus permanen.',
      labelYa: 'Hapus',
      warnaYa: const Color(0xFFD64545),
    );
    if (!ok) return;
    try {
      final pesan = await _service.delete(kategori.id);
      kategoriList.removeWhere((k) => k.id == kategori.id);
      AppSnackbar.success(pesan);
      refreshHalamanLain();
    } on ApiException catch (e) {
      AppSnackbar.error(e.message, title: 'Tidak dapat dihapus');
    } catch (e) {
      AppSnackbar.error('Gagal menghapus kategori: $e');
    }
  }

  static void refreshHalamanLain() {
    if (Get.isRegistered<HomeController>()) Get.find<HomeController>().fetchData(silent: true);
    if (Get.isRegistered<KatalogController>()) Get.find<KatalogController>().refreshAll();
  }
}

/// Form tambah / edit kategori.
class KategoriFormController extends GetxController {
  KategoriService get _service => Get.find<KategoriService>();

  final formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final deskripsiController = TextEditingController();
  final isSaving = false.obs;

  Kategori? editing;
  List<String> _namaLain = [];

  bool get isEdit => editing != null;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Kategori) {
      editing = arg;
      namaController.text = arg.nama;
      deskripsiController.text = arg.deskripsi ?? '';
    }
    _loadNamaLain();
  }

  /// Nama kategori lain untuk validasi duplikat di sisi aplikasi.
  Future<void> _loadNamaLain() async {
    List<Kategori> list;
    if (Get.isRegistered<KategoriController>() && Get.find<KategoriController>().kategoriList.isNotEmpty) {
      list = Get.find<KategoriController>().kategoriList;
    } else {
      try {
        list = await _service.getAll();
      } catch (_) {
        list = [];
      }
    }
    _namaLain = list.where((k) => k.id != editing?.id).map((k) => k.nama).toList();
  }

  String? validasiNama(String? value) => Validators.namaKategori(value, _namaLain);

  Future<void> simpan() async {
    if (isSaving.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    isSaving.value = true;
    try {
      final nama = namaController.text.trim();
      final deskripsi = deskripsiController.text.trim().isEmpty ? null : deskripsiController.text.trim();
      final pesan = isEdit
          ? await _service.update(id: editing!.id, nama: nama, deskripsi: deskripsi)
          : await _service.create(nama: nama, deskripsi: deskripsi);
      tutup(true);
      AppSnackbar.success(pesan);
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
    } catch (e) {
      AppSnackbar.error('Gagal menyimpan kategori: $e');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    namaController.dispose();
    deskripsiController.dispose();
    super.onClose();
  }
}
