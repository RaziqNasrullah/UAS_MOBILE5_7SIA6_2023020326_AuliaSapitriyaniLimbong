import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/pesanan_controller.dart';
import '../../models/pesanan.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_badge.dart';

/// Riwayat pesanan (urut terbaru) + filter status.
class PesananView extends GetView<PesananController> {
  const PesananView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pesanan')),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: Obx(
              () => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                children: [
                  CategoryChip(
                    label: 'Semua',
                    selected: controller.statusFilter.value == null,
                    onSelected: (_) => controller.setFilter(null),
                  ),
                  for (final s in Pesanan.pilihanStatus) ...[
                    const SizedBox(width: 8),
                    CategoryChip(
                      label: s,
                      selected: controller.statusFilter.value == s,
                      onSelected: (_) => controller.setFilter(s),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.pesananList.isEmpty) return const LoadingView();
              if (controller.errorMessage.value != null && controller.pesananList.isEmpty) {
                return ErrorState(message: controller.errorMessage.value!, onRetry: controller.fetchPesanan);
              }
              if (controller.pesananList.isEmpty) {
                return EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Belum ada pesanan',
                  message: controller.statusFilter.value == null
                      ? 'Pesanan yang kamu buat akan muncul di sini.'
                      : 'Tidak ada pesanan berstatus ${controller.statusFilter.value}.',
                );
              }
              return RefreshIndicator(
                color: AppColors.coral,
                onRefresh: () => controller.fetchPesanan(silent: true),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                  itemCount: controller.pesananList.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _PesananCard(pesanan: controller.pesananList[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PesananCard extends StatelessWidget {
  const _PesananCard({required this.pesanan});

  final Pesanan pesanan;

  IconData get _ikonTipe => switch (pesanan.tipePesanan) {
        'Diantar' => Icons.delivery_dining_rounded,
        'Bawa Pulang' => Icons.takeout_dining_rounded,
        _ => Icons.table_restaurant_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final warna = AppColors.statusColor(pesanan.status);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.pesananDetail, arguments: pesanan.id),
        child: Container(
          decoration: BoxDecoration(border: Border(left: BorderSide(color: warna, width: 5))),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(pesanan.nomorPesanan,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.tealDark)),
                  ),
                  StatusBadge(status: pesanan.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(Formatter.tanggalJam(pesanan.tanggal), style: Theme.of(context).textTheme.bodySmall),
              const Divider(height: 18),
              Row(
                children: [
                  Icon(_ikonTipe, size: 18, color: AppColors.mint),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('${pesanan.namaPemesan}  -  ${pesanan.keteranganTipe}',
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text('${pesanan.jumlahItem} item', style: Theme.of(context).textTheme.bodySmall),
                  const Spacer(),
                  Text(Formatter.rupiah(pesanan.total),
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.coralDark, fontSize: 16)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
