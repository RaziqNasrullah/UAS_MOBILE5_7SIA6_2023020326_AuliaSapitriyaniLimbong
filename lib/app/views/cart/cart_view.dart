import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/cart_controller.dart';
import '../../controllers/main_controller.dart';
import '../../models/keranjang_item.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/biaya_calculator.dart';
import '../../utils/formatter.dart';
import '../../widgets/menu_image.dart';
import '../../widgets/qty_stepper.dart';
import '../../widgets/state_views.dart';

/// Keranjang: ubah jumlah (validasi stok), catatan per item, hapus, total reaktif.
class CartView extends GetView<CartController> {
  const CartView({super.key});

  Future<void> _editCatatan(KeranjangItem item) async {
    final textController = TextEditingController(text: item.catatanItem ?? '');
    final hasil = await Get.dialog<String>(
      AlertDialog(
        title: Text('Catatan: ${item.namaMenu}', style: const TextStyle(fontSize: 17)),
        content: TextField(
          controller: textController,
          autofocus: true,
          maxLength: 150,
          maxLines: 2,
          decoration: const InputDecoration(hintText: 'Mis. less sugar, tanpa bawang'),
        ),
        actions: [
          TextButton(onPressed: () => tutup(), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(90, 42)),
            onPressed: () => tutup(textController.text),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (hasil != null && hasil.trim() != (item.catatanItem ?? '')) {
      await controller.updateCatatan(item, hasil);
    }
  }

  Future<void> _hapus(KeranjangItem item) async {
    final ok = await konfirmasi(
      judul: 'Hapus item?',
      pesan: '${item.namaMenu} akan dihapus dari keranjang.',
      labelYa: 'Hapus',
      warnaYa: AppColors.dibatalkan,
    );
    if (ok) await controller.removeItem(item);
  }

  Future<void> _kosongkan() async {
    final ok = await konfirmasi(
      judul: 'Kosongkan keranjang?',
      pesan: 'Semua item di keranjang akan dihapus.',
      labelYa: 'Kosongkan',
      warnaYa: AppColors.dibatalkan,
    );
    if (ok) await controller.clearCart();
  }

  void _belanja() {
    if (Get.isRegistered<MainController>()) {
      Get.until((route) => route.settings.name == AppRoutes.main);
      Get.find<MainController>().changeTab(MainController.tabKatalog);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        actions: [
          Obx(
            () => controller.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Kosongkan keranjang',
                    onPressed: _kosongkan,
                    icon: const Icon(Icons.delete_sweep_outlined),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.isEmpty) return const LoadingView();
        if (controller.errorMessage.value != null && controller.isEmpty) {
          return ErrorState(message: controller.errorMessage.value!, onRetry: controller.fetchCart);
        }
        if (controller.isEmpty) {
          return EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'Keranjang masih kosong',
            message: 'Yuk pilih menu favoritmu dari katalog SweetnFresh.',
            action: ElevatedButton.icon(
              onPressed: _belanja,
              icon: const Icon(Icons.restaurant_menu_rounded),
              label: const Text('Lihat Katalog'),
            ),
          );
        }
        return RefreshIndicator(
          color: AppColors.coral,
          onRefresh: () => controller.fetchCart(silent: true),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: controller.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _CartItemCard(
              item: controller.items[i],
              busy: controller.busyIds.contains(controller.items[i].id),
              onPlus: () => controller.increment(controller.items[i]),
              onMinus: () => controller.decrement(controller.items[i]),
              onCatatan: () => _editCatatan(controller.items[i]),
              onHapus: () => _hapus(controller.items[i]),
            ),
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.isEmpty) return const SizedBox.shrink();
        final kurang = BiayaCalculator.kurangUntukDiskon(controller.subtotal);
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (kurang > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.local_offer_outlined, size: 16, color: AppColors.mint),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Belanja ${Formatter.rupiah(kurang)} lagi untuk diskon 10%',
                            style: const TextStyle(fontSize: 12, color: AppColors.mint, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Total (${controller.totalItem} item)', style: Theme.of(context).textTheme.bodySmall),
                          Text(
                            Formatter.rupiah(controller.subtotal),
                            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.tealDark),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.checkout),
                      icon: const Icon(Icons.payments_outlined),
                      label: const Text('Checkout'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.busy,
    required this.onPlus,
    required this.onMinus,
    required this.onCatatan,
    required this.onHapus,
  });

  final KeranjangItem item;
  final bool busy;
  final VoidCallback onPlus;
  final VoidCallback onMinus;
  final VoidCallback onCatatan;
  final VoidCallback onHapus;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MenuImage(url: item.imageUrl, width: 76, height: 76, borderRadius: 12),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.namaMenu,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text('${Formatter.rupiah(item.harga)} / porsi  -  stok ${item.stok}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Text(
                        'Subtotal ${Formatter.rupiah(item.subtotal)}',
                        style: const TextStyle(color: AppColors.coralDark, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Hapus',
                  onPressed: busy ? null : onHapus,
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.dibatalkan),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: onCatatan,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.edit_note_rounded, size: 18, color: AppColors.mint),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.catatanItem ?? 'Tambah catatan',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontStyle: item.catatanItem == null ? FontStyle.normal : FontStyle.italic,
                                color: item.catatanItem == null ? AppColors.mint : AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                QtyStepper(
                  compact: true,
                  value: item.jumlah,
                  max: item.stok,
                  enabled: !busy,
                  onChanged: (v) => v > item.jumlah ? onPlus() : onMinus(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
