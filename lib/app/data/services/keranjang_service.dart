import 'package:get/get.dart';

import '../../models/keranjang_item.dart';
import 'api_service.dart';

class KeranjangService extends GetxService {
  ApiService get _api => Get.find<ApiService>();

  Future<List<KeranjangItem>> getAll() async {
    final res = await _api.get('keranjang/read.php');
    return res.dataList.map(KeranjangItem.fromJson).toList();
  }

  Future<ApiResponse> add({required int menuId, required int jumlah, String? catatan}) =>
      _api.post('keranjang/add.php', {'menu_id': menuId, 'jumlah': jumlah, 'catatan_item': catatan});

  Future<ApiResponse> updateQty(int id, int jumlah) =>
      _api.post('keranjang/update_qty.php', {'id': id, 'jumlah': jumlah});

  Future<ApiResponse> updateCatatan(int id, String? catatan) =>
      _api.post('keranjang/update_catatan.php', {'id': id, 'catatan_item': catatan ?? ''});

  Future<ApiResponse> delete(int id) => _api.post('keranjang/delete.php', {'id': id});

  Future<ApiResponse> clear() => _api.post('keranjang/clear.php');
}
