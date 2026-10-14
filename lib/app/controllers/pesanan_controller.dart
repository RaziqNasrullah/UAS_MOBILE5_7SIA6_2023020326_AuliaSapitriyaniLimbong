import 'dart:ui' show Color;

import 'package:get/get.dart';

import '../data/services/api_service.dart';
import '../data/services/pesanan_service.dart';
import '../models/pesanan.dart';
import '../utils/app_snackbar.dart';
import 'home_controller.dart';
import 'katalog_controller.dart';

/// Riwayat pesanan (urut terbaru) + filter status.
class PesananController extends GetxController {
  PesananService get _service => Get.find<PesananService>();

  final pesananList = <Pesanan>[].obs;
  final statusFilter = RxnString();
  final isLoading = true.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    ever<String?>(statusFilter, (_) => fetchPesanan());
    fetchPesanan();
  }

  void setFilter(String? status) => statusFilter.value = status;

  Future<void> fetchPesanan({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    try {
      pesananList.assignAll(await _service.getAll(status: statusFilter.value));
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

/// Detail satu pesanan + aksi ubah status.
class PesananDetailController extends GetxController {
  PesananService get _service => Get.find<PesananService>();

  late final int pesananId;
  final pesanan = Rxn<Pesanan>();
  final isLoading = true.obs;
  final isUpdating = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    pesananId = arg is int ? arg : int.tryParse('$arg') ?? 0;
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    isLoading.value = true;
    try {
      pesanan.value = await _service.getDetail(pesananId);
      errorMessage.value = null;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> ubahStatus(String status) async {
    final p = pesanan.value;
    if (p == null || !p.bisaDiubah) {
      AppSnackbar.warning('Pesanan yang sudah ${p?.status} tidak dapat diubah lagi');
      return;
    }
    final batal = status == 'Dibatalkan';
    final ok = await konfirmasi(
      judul: batal ? 'Batalkan pesanan?' : 'Tandai pesanan selesai?',
      pesan: batal
          ? 'Pesanan ${p.nomorPesanan} akan dibatalkan dan stok menu dikembalikan. Status tidak dapat diubah lagi.'
          : 'Pesanan ${p.nomorPesanan} akan ditandai Selesai dan dihitung sebagai pendapatan. Status tidak dapat diubah lagi.',
      labelYa: batal ? 'Ya, Batalkan' : 'Ya, Selesai',
      warnaYa: batal ? const Color(0xFFD64545) : const Color(0xFF2E9E5B),
    );
    if (!ok) return;
    isUpdating.value = true;
    try {
      final (pesan, terbaru) = await _service.updateStatus(p.id, status);
      pesanan.value = terbaru;
      AppSnackbar.success(pesan);
      if (Get.isRegistered<PesananController>()) Get.find<PesananController>().fetchPesanan(silent: true);
      if (batal) {
        if (Get.isRegistered<KatalogController>()) Get.find<KatalogController>().fetchMenus(silent: true);
        if (Get.isRegistered<HomeController>()) Get.find<HomeController>().fetchData(silent: true);
      }
    } on ApiException catch (e) {
      AppSnackbar.error(e.message);
      if (e.statusCode == 409) fetchDetail();
    } catch (e) {
      AppSnackbar.error('Gagal mengubah status: $e');
    } finally {
      isUpdating.value = false;
    }
  }
}
