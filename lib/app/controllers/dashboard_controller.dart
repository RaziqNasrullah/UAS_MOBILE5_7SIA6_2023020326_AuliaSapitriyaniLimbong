import 'package:get/get.dart';

import '../data/services/api_service.dart';
import '../data/services/dashboard_service.dart';
import '../models/dashboard_summary.dart';

/// Dashboard penjualan: ringkasan + data grafik.
class DashboardController extends GetxController {
  DashboardService get _service => Get.find<DashboardService>();

  final summary = Rxn<DashboardSummary>();
  final isLoading = true.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchSummary();
  }

  Future<void> fetchSummary({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    try {
      summary.value = await _service.getSummary();
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
