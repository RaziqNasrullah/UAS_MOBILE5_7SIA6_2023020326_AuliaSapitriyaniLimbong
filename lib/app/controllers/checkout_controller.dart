import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/services/api_service.dart';
import '../data/services/pesanan_service.dart';
import '../routes/app_routes.dart';
import '../utils/app_snackbar.dart';
import '../utils/biaya_calculator.dart';
import 'cart_controller.dart';
import 'home_controller.dart';
import 'katalog_controller.dart';
import 'pesanan_controller.dart';

/// Form checkout & perhitungan biaya pesanan.
class CheckoutController extends GetxController {
  PesananService get _service => Get.find<PesananService>();
  CartController get cart => Get.find<CartController>();

  final formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final hpController = TextEditingController();
  final mejaController = TextEditingController();
  final alamatController = TextEditingController();
  final catatanController = TextEditingController();

  final tipePesanan = TipePesanan.makanDiTempat.obs;
  final isSubmitting = false.obs;

  bool get butuhMeja => tipePesanan.value == TipePesanan.makanDiTempat;
  bool get butuhAlamat => tipePesanan.value == TipePesanan.diantar;

  /// Rincian biaya reaktif (bergantung pada isi keranjang & tipe pesanan).
  RincianBiaya get rincian => BiayaCalculator.hitung(cart.subtotal, tipePesanan.value);

  void setTipe(String? tipe) {
    if (tipe != null) tipePesanan.value = tipe;
  }

  String? validasiMeja(String? v) =>
      butuhMeja && (v == null || v.trim().isEmpty) ? 'Nomor meja wajib diisi untuk Makan di Tempat' : null;

  String? validasiAlamat(String? v) =>
      butuhAlamat && (v == null || v.trim().isEmpty) ? 'Alamat wajib diisi untuk pesanan Diantar' : null;

  Future<void> submit() async {
    if (isSubmitting.value) return;
    if (cart.isEmpty) {
      AppSnackbar.warning('Keranjang masih kosong');
      return;
    }
    if (!(formKey.currentState?.validate() ?? false)) {
      AppSnackbar.warning('Periksa kembali data pemesan yang belum lengkap / tidak valid');
      return;
    }
    isSubmitting.value = true;
    try {
      final pesanan = await _service.checkout(
        namaPemesan: namaController.text.trim(),
        noHp: hpController.text.trim(),
        tipePesanan: tipePesanan.value,
        nomorMeja: butuhMeja ? mejaController.text.trim() : null,
        alamat: butuhAlamat ? alamatController.text.trim() : null,
        catatan: catatanController.text.trim().isEmpty ? null : catatanController.text.trim(),
      );
      cart.resetLocal();
      _refreshDataLain();
      AppSnackbar.success('Pesanan ${pesanan.nomorPesanan} berhasil dibuat');
      Get.offNamed(AppRoutes.checkoutSukses, arguments: pesanan);
    } on ApiException catch (e) {
      AppSnackbar.error(e.message, title: 'Checkout gagal');
      // Stok berubah -> muat ulang keranjang agar user bisa menyesuaikan.
      if (e.statusCode == 409 || e.statusCode == 422) cart.fetchCart(silent: true);
    } catch (e) {
      AppSnackbar.error('Terjadi kesalahan: $e', title: 'Checkout gagal');
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Stok menu berubah setelah checkout -> segarkan halaman lain.
  void _refreshDataLain() {
    if (Get.isRegistered<HomeController>()) Get.find<HomeController>().fetchData(silent: true);
    if (Get.isRegistered<KatalogController>()) Get.find<KatalogController>().fetchMenus(silent: true);
    if (Get.isRegistered<PesananController>()) Get.find<PesananController>().fetchPesanan(silent: true);
  }

  @override
  void onClose() {
    namaController.dispose();
    hpController.dispose();
    mejaController.dispose();
    alamatController.dispose();
    catatanController.dispose();
    super.onClose();
  }
}
