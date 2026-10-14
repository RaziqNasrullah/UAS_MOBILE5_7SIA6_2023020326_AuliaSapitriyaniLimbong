import 'package:get/get.dart';

import '../../models/menu.dart';
import 'api_service.dart';

class MenuService extends GetxService {
  ApiService get _api => Get.find<ApiService>();

  Future<List<Menu>> getAll({String? search, int? kategoriId, bool bestSeller = false, String? sort, int? limit}) async {
    final res = await _api.get('menu/read.php', query: {
      'search': search?.trim() ?? '',
      'kategori_id': kategoriId?.toString() ?? '',
      'best_seller': bestSeller ? '1' : '',
      'sort': sort ?? '',
      'limit': limit?.toString() ?? '',
    });
    return res.dataList.map(Menu.fromJson).toList();
  }

  Future<Menu> getDetail(int id) async {
    final res = await _api.get('menu/detail.php', query: {'id': '$id'});
    return Menu.fromJson(res.dataMap);
  }

  Future<Menu> create(Menu menu) async {
    final res = await _api.post('menu/create.php', menu.toJson());
    return Menu.fromJson(res.dataMap);
  }

  Future<Menu> update(Menu menu) async {
    final res = await _api.post('menu/update.php', menu.toJson());
    return Menu.fromJson(res.dataMap);
  }

  Future<String> delete(int id) async {
    final res = await _api.post('menu/delete.php', {'id': id});
    return res.message;
  }

  /// Upload gambar, mengembalikan nama file di server.
  Future<String> uploadGambar(String filePath) async {
    final res = await _api.upload('menu/upload_gambar.php', field: 'gambar', filePath: filePath);
    return res.dataMap['gambar'].toString();
  }
}
