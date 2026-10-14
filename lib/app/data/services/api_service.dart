import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';

/// Error yang sudah diterjemahkan menjadi pesan ramah pengguna.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.data});

  final String message;
  final int? statusCode;
  final dynamic data;

  /// true jika error karena koneksi/server mati (bukan validasi).
  bool get isConnectionError => statusCode == null;

  @override
  String toString() => message;
}

/// Respons seragam backend: { success, message, data }.
class ApiResponse {
  const ApiResponse({required this.success, required this.message, this.data, this.statusCode = 200});

  final bool success;
  final String message;
  final dynamic data;
  final int statusCode;

  List<Map<String, dynamic>> get dataList => data is List
      ? (data as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
      : <Map<String, dynamic>>[];

  Map<String, dynamic> get dataMap => data is Map ? Map<String, dynamic>.from(data as Map) : <String, dynamic>{};
}

/// Wrapper HTTP: timeout, parsing JSON, dan penanganan error terpusat.
class ApiService extends GetxService {
  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String baseUrl;

  Uri _uri(String path, [Map<String, String>? query]) {
    final q = query == null ? null : (Map.of(query)..removeWhere((_, v) => v.isEmpty));
    return Uri.parse('$baseUrl/$path').replace(queryParameters: (q == null || q.isEmpty) ? null : q);
  }

  Future<ApiResponse> get(String path, {Map<String, String>? query}) {
    return _send(() => _client.get(_uri(path, query), headers: {'Accept': 'application/json'}));
  }

  Future<ApiResponse> post(String path, [Map<String, dynamic> body = const {}]) {
    return _send(
      () => _client.post(
        _uri(path),
        headers: {'Content-Type': 'application/json; charset=utf-8', 'Accept': 'application/json'},
        body: jsonEncode(body),
      ),
    );
  }

  /// Upload file (multipart/form-data).
  Future<ApiResponse> upload(String path, {required String field, required String filePath, Map<String, String>? fields}) {
    return _send(() async {
      final request = http.MultipartRequest('POST', _uri(path))
        ..headers['Accept'] = 'application/json'
        ..files.add(await http.MultipartFile.fromPath(field, filePath));
      if (fields != null) request.fields.addAll(fields);
      final streamed = await _client.send(request).timeout(ApiConfig.timeout * 2);
      return http.Response.fromStream(streamed);
    }, timeout: ApiConfig.timeout * 2);
  }

  Future<ApiResponse> _send(Future<http.Response> Function() request, {Duration? timeout}) async {
    http.Response response;
    try {
      response = await request().timeout(timeout ?? ApiConfig.timeout);
    } on TimeoutException {
      throw const ApiException(
        'Server tidak merespons (timeout). Periksa koneksi Wi-Fi dan pastikan XAMPP berjalan.',
      );
    } on SocketException {
      throw ApiException(
        'Tidak dapat terhubung ke server ($baseUrl). Pastikan Apache & MySQL XAMPP aktif dan alamat API benar.',
      );
    } on http.ClientException {
      throw ApiException(
        'Koneksi ke server gagal ($baseUrl). Pastikan HP & laptop satu jaringan dan XAMPP aktif.',
      );
    } on FileSystemException {
      throw const ApiException('File gambar tidak dapat dibaca');
    }
    return parseResponse(response);
  }

  /// Mengubah http.Response menjadi ApiResponse atau melempar ApiException.
  static ApiResponse parseResponse(http.Response response) {
    final body = utf8.decode(response.bodyBytes).trim();
    if (body.isEmpty) {
      throw ApiException('Respons server kosong (HTTP ${response.statusCode})', statusCode: response.statusCode);
    }
    dynamic json;
    try {
      json = jsonDecode(body);
    } on FormatException {
      final pesan = response.statusCode == 404
          ? 'Endpoint API tidak ditemukan (404). Pastikan folder kuliner_api ada di htdocs.'
          : 'Respons server tidak valid (bukan JSON). Periksa error PHP di backend.';
      throw ApiException(pesan, statusCode: response.statusCode);
    }
    if (json is! Map) {
      throw ApiException('Format respons server tidak dikenali', statusCode: response.statusCode);
    }
    final map = Map<String, dynamic>.from(json);
    final success = map['success'] == true;
    final message = (map['message'] ?? '').toString();
    if (!success || response.statusCode >= 400) {
      throw ApiException(
        message.isEmpty ? 'Permintaan gagal (HTTP ${response.statusCode})' : message,
        statusCode: response.statusCode,
        data: map['data'],
      );
    }
    return ApiResponse(success: true, message: message, data: map['data'], statusCode: response.statusCode);
  }

  @override
  void onClose() {
    _client.close();
    super.onClose();
  }
}
