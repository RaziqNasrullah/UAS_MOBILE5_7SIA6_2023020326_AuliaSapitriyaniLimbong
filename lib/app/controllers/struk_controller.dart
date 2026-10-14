import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../models/pesanan.dart';
import '../utils/app_snackbar.dart';
import '../utils/pdf_generator.dart';

/// Preview, simpan, dan bagikan struk PDF.
class StrukController extends GetxController {
  late final Pesanan pesanan;
  final isSaving = false.obs;
  final savedPath = RxnString();
  Uint8List? _cache;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is! Pesanan) throw ArgumentError('Struk membutuhkan arguments berupa Pesanan');
    pesanan = arg;
  }

  String get namaFile => StrukPdfGenerator.namaFile(pesanan);

  Future<Uint8List> buildPdf() async {
    if (_cache != null) return _cache!;
    Uint8List? logo;
    try {
      logo = (await rootBundle.load('assets/images/logo_icon.png')).buffer.asUint8List();
    } catch (_) {
      logo = null;
    }
    _cache = await StrukPdfGenerator.generate(pesanan, logo: logo);
    return _cache!;
  }

  /// Folder Download milik aplikasi (tidak butuh izin penyimpanan).
  Future<Directory> _folderDownload() async {
    Directory? dir;
    try {
      dir = await getDownloadsDirectory();
    } catch (_) {}
    if (dir == null) {
      try {
        final ext = await getExternalStorageDirectory();
        if (ext != null) dir = Directory('${ext.path}/Download');
      } catch (_) {}
    }
    dir ??= Directory('${(await getApplicationDocumentsDirectory()).path}/Download');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> simpan() async {
    if (isSaving.value) return;
    isSaving.value = true;
    try {
      final bytes = await buildPdf();
      final dir = await _folderDownload();
      final file = File('${dir.path}/$namaFile');
      await file.writeAsBytes(bytes, flush: true);
      savedPath.value = file.path;
      AppSnackbar.success('Struk tersimpan di:\n${file.path}', title: 'PDF disimpan');
    } catch (e) {
      AppSnackbar.error('Gagal menyimpan PDF: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> bagikan() async {
    try {
      await Printing.sharePdf(bytes: await buildPdf(), filename: namaFile);
    } catch (e) {
      AppSnackbar.error('Gagal membagikan PDF: $e');
    }
  }
}
