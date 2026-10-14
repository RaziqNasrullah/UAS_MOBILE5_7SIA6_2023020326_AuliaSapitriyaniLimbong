import 'dart:io';

import 'package:delights/app/data/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('respons sukses diparsing', () async {
    final api = ApiService(
      baseUrl: 'http://test/kuliner_api',
      client: MockClient((req) async {
        expect(req.url.toString(), 'http://test/kuliner_api/menu/read.php?search=kopi');
        return http.Response('{"success":true,"message":"1 menu ditemukan","data":[{"id":7}]}', 200);
      }),
    );
    final res = await api.get('menu/read.php', query: {'search': 'kopi', 'kategori_id': ''});
    expect(res.message, '1 menu ditemukan');
    expect(res.dataList.first['id'], 7);
  });

  test('error 409 dari server menjadi ApiException dengan pesan server', () async {
    final api = ApiService(
      baseUrl: 'http://test',
      client: MockClient((_) async => http.Response('{"success":false,"message":"Kategori sudah ada","data":null}', 409)),
    );
    await expectLater(
      api.post('kategori/create.php', {'nama': 'Snack'}),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Kategori sudah ada').having((e) => e.statusCode, 'code', 409)),
    );
  });

  test('respons bukan JSON', () async {
    final api = ApiService(
      baseUrl: 'http://test',
      client: MockClient((_) async => http.Response('<b>Fatal error</b>', 500)),
    );
    await expectLater(
      api.get('menu/read.php'),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('bukan JSON'))),
    );
  });

  test('respons kosong', () async {
    final api = ApiService(baseUrl: 'http://test', client: MockClient((_) async => http.Response('', 200)));
    await expectLater(
      api.get('menu/read.php'),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('kosong'))),
    );
  });

  test('server mati (SocketException) -> pesan koneksi', () async {
    final api = ApiService(
      baseUrl: 'http://10.0.2.2/kuliner_api',
      client: MockClient((_) async => throw const SocketException('Connection refused')),
    );
    await expectLater(
      api.get('menu/read.php'),
      throwsA(isA<ApiException>()
          .having((e) => e.message, 'message', contains('Tidak dapat terhubung'))
          .having((e) => e.isConnectionError, 'isConnectionError', isTrue)),
    );
  });
}
