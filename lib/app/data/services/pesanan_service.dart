import 'package:get/get.dart';

import '../../models/pesanan.dart';
import 'api_service.dart';

class PesananService extends GetxService {
  ApiService get _api => Get.find<ApiService>();

  Future<Pesanan> checkout({
    required String namaPemesan,
    required String noHp,
    required String tipePesanan,
    String? nomorMeja,
    String? alamat,
    String? catatan,
  }) async {
    final res = await _api.post('pesanan/checkout.php', {
      'nama_pemesan': namaPemesan,
      'no_hp': noHp,
      'tipe_pesanan': tipePesanan,
      'nomor_meja': nomorMeja,
      'alamat': alamat,
      'catatan': catatan,
    });
    return Pesanan.fromJson(res.dataMap);
  }

  Future<List<Pesanan>> getAll({String? status}) async {
    final res = await _api.get('pesanan/read.php', query: {'status': status ?? ''});
    return res.dataList.map(Pesanan.fromJson).toList();
  }

  Future<Pesanan> getDetail(int id) async {
    final res = await _api.get('pesanan/detail.php', query: {'id': '$id'});
    return Pesanan.fromJson(res.dataMap);
  }

  /// Mengubah status; mengembalikan (pesan, pesanan terbaru).
  Future<(String, Pesanan)> updateStatus(int id, String status) async {
    final res = await _api.post('pesanan/update_status.php', {'id': id, 'status': status});
    return (res.message, Pesanan.fromJson(res.dataMap));
  }
}
