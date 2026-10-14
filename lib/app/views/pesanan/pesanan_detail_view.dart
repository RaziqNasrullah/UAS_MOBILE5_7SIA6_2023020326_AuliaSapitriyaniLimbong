import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/pesanan_controller.dart';
import '../../models/pesanan.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/biaya_row.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_badge.dart';

/// Detail pesanan: item + catatan, rincian biaya, info pemesan, aksi status & cetak struk.
class PesananDetailView extends GetView<PesananDetailController> {
  const PesananDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: Obx(() {
        if (controller.isLoading.value && controller.pesanan.value == null) return const LoadingView();
        final p = controller.pesanan.value;
        if (p == null) {
          return ErrorState(
            message: controller.errorMessage.value ?? 'Pesanan tidak ditemukan',
            onRetry: controller.fetchDetail,
          );
        }
        return RefreshIndicator(
          color: AppColors.coral,
          onRefresh: controller.fetchDetail,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(p.nomorPesanan,
                                style: theme.textTheme.titleLarge?.copyWith(fontSize: 19)),
                          ),
                          StatusBadge(status: p.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(Formatter.tanggalPanjang(p.tanggal), style: theme.textTheme.bodySmall),
                      Text('Pukul ${p.tanggal == null ? '-' : Formatter.tanggalJam(p.tanggal).split(', ').last} WIB',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _Section(
                title: 'Info Pemesan',
                icon: Icons.person_rounded,
                child: Column(
                  children: [
                    _info('Nama', p.namaPemesan),
                    _info('No. HP', p.noHp),
                    _info('Tipe pesanan', p.tipePesanan),
                    if (p.nomorMeja != null) _info('Nomor meja', p.nomorMeja!),
                    if (p.alamat != null) _info('Alamat', p.alamat!),
                    if (p.catatan != null) _info('Catatan', p.catatan!),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Section(
                title: 'Item Pesanan (${p.jumlahItem})',
                icon: Icons.restaurant_rounded,
                child: Column(
                  children: [
                    for (final item in p.items)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.coral.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('${item.jumlah}x',
                                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.coralDark)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.namaMenu, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text('@ ${Formatter.rupiah(item.hargaSatuan)}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  if (item.catatanItem != null)
                                    Text('Catatan: ${item.catatanItem}',
                                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.mint)),
                                ],
                              ),
                            ),
                            Text(Formatter.rupiah(item.subtotal), style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Section(
                title: 'Rincian Biaya',
                icon: Icons.payments_rounded,
                child: Column(
                  children: [
                    BiayaRow(label: 'Subtotal', value: p.subtotal),
                    BiayaRow(label: 'Biaya layanan', value: p.biayaLayanan),
                    BiayaRow(label: 'Ongkir', value: p.ongkir),
                    BiayaRow(label: 'Diskon', value: p.diskon, isMinus: true),
                    const Divider(height: 18),
                    BiayaRow(label: 'Total Bayar', value: p.total, isTotal: true),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _Aksi(pesanan: p, controller: controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _info(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 105, child: Text(label, style: const TextStyle(color: AppColors.textMuted))),
            Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      );
}

class _Aksi extends StatelessWidget {
  const _Aksi({required this.pesanan, required this.controller});

  final Pesanan pesanan;
  final PesananDetailController controller;

  @override
  Widget build(BuildContext context) {
    final updating = controller.isUpdating.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pesanan.bisaDiubah) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dibatalkan,
                    side: const BorderSide(color: AppColors.dibatalkan),
                  ),
                  onPressed: updating ? null : () => controller.ubahStatus('Dibatalkan'),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Batalkan'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.selesai),
                  onPressed: updating ? null : () => controller.ubahStatus('Selesai'),
                  icon: updating
                      ? const SizedBox(
                          width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Selesai'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ] else
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.statusColor(pesanan.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              pesanan.status == 'Dibatalkan'
                  ? 'Pesanan dibatalkan. Stok menu sudah dikembalikan. Status tidak dapat diubah lagi.'
                  : 'Pesanan sudah selesai dan tercatat sebagai pendapatan. Status tidak dapat diubah lagi.',
              style: TextStyle(color: AppColors.statusColor(pesanan.status), fontWeight: FontWeight.w600),
            ),
          ),
        FilledButton.icon(
          onPressed: () => Get.toNamed(AppRoutes.struk, arguments: pesanan),
          icon: const Icon(Icons.print_rounded),
          label: const Text('Cetak Struk (PDF)'),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.icon, required this.child});

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.mint),
                const SizedBox(width: 6),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const Divider(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}
