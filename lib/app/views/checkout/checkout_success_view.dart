import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/main_controller.dart';
import '../../models/pesanan.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatter.dart';

/// Halaman sukses setelah checkout (data pesanan dari arguments).
class CheckoutSuccessView extends StatelessWidget {
  const CheckoutSuccessView({super.key});

  void _keBeranda() {
    Get.until((route) => route.settings.name == AppRoutes.main);
    if (Get.isRegistered<MainController>()) Get.find<MainController>().changeTab(MainController.tabBeranda);
  }

  @override
  Widget build(BuildContext context) {
    final pesanan = Get.arguments as Pesanan;
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _keBeranda();
      },
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 24),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.3, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
                child: Container(
                  width: 110,
                  height: 110,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.selesai.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle_rounded, color: AppColors.selesai, size: 80),
                ),
              ),
              const SizedBox(height: 20),
              Text('Pesanan Berhasil!', textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                'Terima kasih, ${pesanan.namaPemesan}. Pesananmu sedang diproses oleh dapur SweetnFresh.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted, height: 1.4),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _row('No. Pesanan', pesanan.nomorPesanan, bold: true),
                      _row('Tanggal', Formatter.tanggalJam(pesanan.tanggal)),
                      _row('Tipe', pesanan.keteranganTipe),
                      if (pesanan.alamat != null) _row('Alamat', pesanan.alamat!),
                      _row('Jumlah item', '${pesanan.jumlahItem} porsi'),
                      const Divider(height: 22),
                      _row('Total Bayar', Formatter.rupiah(pesanan.total), bold: true, color: AppColors.coralDark),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.struk, arguments: pesanan),
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Lihat & Cetak Struk'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.pesananDetail, arguments: pesanan.id),
                icon: const Icon(Icons.info_outline_rounded),
                label: const Text('Detail Pesanan'),
              ),
              const SizedBox(height: 4),
              TextButton(onPressed: _keBeranda, child: const Text('Kembali ke Beranda')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AppColors.textMuted))),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500, color: color, fontSize: bold ? 16 : 14),
              ),
            ),
          ],
        ),
      );
}
