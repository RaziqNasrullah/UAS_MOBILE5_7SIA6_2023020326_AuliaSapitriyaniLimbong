import 'package:get/get.dart';

import '../../models/kategori.dart';
import 'api_service.dart';

class KategoriService extends GetxService {
  ApiService get _api => Get.find<ApiService>();

  Future<List<Kategori>> getAll() async {
    final res = await _api.get('kategori/read.php');
    return res.dataList.map(Kategori.fromJson).toList();
  }

  Future<String> create({required String nama, String? deskripsi, String? ikon}) async {
    final res = await _api.post('kategori/create.php', {'nama': nama, 'deskripsi': deskripsi, 'ikon': ikon});
    return res.message;
  }

  Future<String> update({required int id, required String nama, String? deskripsi, String? ikon}) async {
    final res = await _api.post('kategori/update.php', {'id': id, 'nama': nama, 'deskripsi': deskripsi, 'ikon': ikon});
    return res.message;
  }

  Future<String> delete(int id) async {
    final res = await _api.post('kategori/delete.php', {'id': id});
    return res.message;
  }
}
