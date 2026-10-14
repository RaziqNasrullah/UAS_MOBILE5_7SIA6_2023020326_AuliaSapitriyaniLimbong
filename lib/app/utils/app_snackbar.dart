import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_theme.dart';

/// Pembungkus Get.snackbar agar tampilan pesan sukses/error konsisten.
class AppSnackbar {
  AppSnackbar._();

  static void success(String message, {String title = 'Berhasil'}) =>
      _show(title, message, AppColors.selesai, Icons.check_circle_rounded);

  static void error(String message, {String title = 'Gagal'}) =>
      _show(title, message, AppColors.dibatalkan, Icons.error_rounded);

  static void info(String message, {String title = 'Info'}) =>
      _show(title, message, AppColors.tealDark, Icons.info_rounded);

  static void warning(String message, {String title = 'Perhatian'}) =>
      _show(title, message, AppColors.coralDark, Icons.warning_amber_rounded);

  static void _show(String title, String message, Color color, IconData icon) {
    if (Get.testMode && Get.context == null) return;
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: color,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
      shouldIconPulse: false,
    );
  }
}

/// Dialog konfirmasi sederhana (mengembalikan true jika user menekan tombol konfirmasi).
Future<bool> konfirmasi({
  required String judul,
  required String pesan,
  String labelYa = 'Ya',
  String labelBatal = 'Batal',
  Color? warnaYa,
}) async {
  final hasil = await Get.dialog<bool>(
    AlertDialog(
      title: Text(judul),
      content: Text(pesan),
      actions: [
        TextButton(onPressed: () => tutup(false), child: Text(labelBatal)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: warnaYa ?? AppColors.coral,
            minimumSize: const Size(90, 42),
          ),
          onPressed: () => tutup(true),
          child: Text(labelYa),
        ),
      ],
    ),
  );
  return hasil ?? false;
}

/// Menutup route/dialog teratas.
/// Catatan: Get.back() hanya menutup snackbar jika snackbar sedang tampil,
/// sehingga untuk menutup halaman/dialog dipakai Navigator langsung.
void tutup<T>([T? result]) => Get.key.currentState?.pop<T>(result);
