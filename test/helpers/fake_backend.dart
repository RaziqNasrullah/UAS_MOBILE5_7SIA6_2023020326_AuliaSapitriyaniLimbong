import 'dart:convert';

import 'package:delights/app/controllers/cart_controller.dart';
import 'package:delights/app/data/services/api_service.dart';
import 'package:delights/app/data/services/dashboard_service.dart';
import 'package:delights/app/data/services/kategori_service.dart';
import 'package:delights/app/data/services/keranjang_service.dart';
import 'package:delights/app/data/services/menu_service.dart';
import 'package:delights/app/data/services/pesanan_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Backend tiruan (in-memory) untuk widget test, meniru respons kuliner_api.
class FakeBackend {
  final kategori = <Map<String, dynamic>>[
    {'id': 1, 'nama': 'Makanan Utama', 'ikon': 'rice_bowl', 'jumlah_menu': 2},
    {'id': 2, 'nama': 'Minuman', 'ikon': 'local_cafe', 'jumlah_menu': 1},
  ];
  final menu = <Map<String, dynamic>>[
    _menu(1, 1, 'Rice Bowl Ayam Sambal Matah', 32000, 25, 'Pedas', true),
    _menu(2, 1, 'Ayam Geprek Keju Mozarella', 30000, 0, 'Extra Pedas', false),
    _menu(3, 2, 'Kopi Susu Gula Aren', 20000, 2, 'Tidak Pedas', true),
  ];
  final keranjang = <Map<String, dynamic>>[];
  final requests = <String>[];

  static Map<String, dynamic> _menu(int id, int kat, String nama, num harga, int stok, String pedas, bool best) => {
        'id': id,
        'kategori_id': kat,
        'nama': nama,
        'harga': harga,
        'stok': stok,
        'deskripsi': 'Deskripsi $nama',
        'gambar': null,
        'level_pedas': pedas,
        'suhu_sajian': kat == 2 ? 'Dingin' : 'Panas',
        'estimasi_saji': 10,
        'is_best_seller': best,
        'nama_kategori': kat == 1 ? 'Makanan Utama' : 'Minuman',
      };

  http.Response _ok(dynamic data, [String message = 'OK', int code = 200]) =>
      http.Response(jsonEncode({'success': true, 'message': message, 'data': data}), code,
          headers: {'content-type': 'application/json'});

  http.Response _err(String message, int code) =>
      http.Response(jsonEncode({'success': false, 'message': message, 'data': null}), code);

  Future<http.Response> handle(http.Request req) async {
    final path = req.url.path.replaceFirst('/kuliner_api/', '');
    requests.add('${req.method} $path${req.url.hasQuery ? '?${req.url.query}' : ''}');
    final body = req.body.isEmpty ? <String, dynamic>{} : jsonDecode(req.body) as Map<String, dynamic>;
    final q = req.url.queryParameters;
    switch (path) {
      case 'kategori/read.php':
        return _ok(kategori);
      case 'menu/read.php':
        var list = menu.where((m) {
          final s = (q['search'] ?? '').toLowerCase();
          final k = int.tryParse(q['kategori_id'] ?? '');
          return (s.isEmpty || (m['nama'] as String).toLowerCase().contains(s)) &&
              (k == null || m['kategori_id'] == k) &&
              (q['best_seller'] != '1' || m['is_best_seller'] == true);
        }).toList();
        return _ok(list);
      case 'menu/detail.php':
        return _ok(menu.firstWhere((m) => m['id'].toString() == q['id']));
      case 'keranjang/read.php':
        return _ok(keranjang);
      case 'keranjang/add.php':
        final m = menu.firstWhere((m) => m['id'] == body['menu_id']);
        if ((m['stok'] as int) < (body['jumlah'] as int)) return _err('Stok tidak cukup', 422);
        final item = {
          'id': keranjang.length + 1,
          'menu_id': m['id'],
          'jumlah': body['jumlah'],
          'catatan_item': body['catatan_item'],
          'nama_menu': m['nama'],
          'harga': m['harga'],
          'stok': m['stok'],
          'gambar': null,
          'nama_kategori': m['nama_kategori'],
          'level_pedas': m['level_pedas'],
        };
        keranjang.add(item);
        return _ok(item, '${m['nama']} ditambahkan ke keranjang', 201);
      case 'pesanan/read.php':
        return _ok([]);
      default:
        return _err('Endpoint tidak ditemukan', 404);
    }
  }

  /// Mendaftarkan service GetX yang memakai backend tiruan ini.
  void register() {
    Get.testMode = true;
    Get.put<ApiService>(ApiService(client: MockClient(handle), baseUrl: 'http://test/kuliner_api'), permanent: true);
    Get.put(KategoriService(), permanent: true);
    Get.put(MenuService(), permanent: true);
    Get.put(KeranjangService(), permanent: true);
    Get.put(PesananService(), permanent: true);
    Get.put(DashboardService(), permanent: true);
    Get.put(CartController(), permanent: true);
  }
}
