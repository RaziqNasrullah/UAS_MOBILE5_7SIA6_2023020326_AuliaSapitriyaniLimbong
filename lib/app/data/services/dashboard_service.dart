import 'package:get/get.dart';

import '../../models/dashboard_summary.dart';
import 'api_service.dart';

class DashboardService extends GetxService {
  ApiService get _api => Get.find<ApiService>();

  Future<DashboardSummary> getSummary() async {
    final res = await _api.get('dashboard/summary.php');
    return DashboardSummary.fromJson(res.dataMap);
  }
}
