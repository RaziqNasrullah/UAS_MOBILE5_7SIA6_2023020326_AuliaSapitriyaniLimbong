import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/menu_detail_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/cart_badge_icon.dart';
import '../../widgets/level_pedas_badge.dart';
import '../../widgets/menu_image.dart';
import '../../widgets/qty_stepper.dart';

/// Detail menu: info lengkap, jumlah, catatan, dan tombol Tambah ke Keranjang.
class MenuDetailView extends GetView<MenuDetailController> {
  const MenuDetailView({super.key});

  IconData _ikonSuhu(String suhu) => switch (suhu) {
        'Dingin' => Icons.ac_unit_rounded,
        'Suhu Ruang' => Icons.thermostat_rounded,
        _ => Icons.local_fire_department_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Obx(() {
        final menu = controller.menu.value;
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: AppColors.cream,
              actions: const [CartBadgeIcon(color: AppColors.tealDark), SizedBox(width: 8)],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    MenuImage(url: menu.imageUrl),
                    if (menu.isHabis)
                      Container(
                        color: Colors.black45,
                        alignment: Alignment.center,
                        child: const Text('HABIS',
                            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 3)),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Chip(
                          label: Text(menu.namaKategori),
                          avatar: const Icon(Icons.category_rounded, size: 16, color: AppColors.mint),
                          visualDensity: VisualDensity.compact,
                        ),
                        if (menu.isBestSeller)
                          const Chip(
                            label: Text('Best Seller', style: TextStyle(color: Colors.white)),
                            avatar: Icon(Icons.star_rounded, size: 16, color: Colors.white),
                            backgroundColor: AppColors.coral,
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(menu.nama, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text(Formatter.rupiah(menu.harga),
                        style: const TextStyle(color: AppColors.coralDark, fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.inventory_2_outlined,
                            label: 'Stok',
                            value: menu.isHabis ? 'Habis' : '${menu.stok} porsi',
                            color: menu.isHabis ? AppColors.dibatalkan : AppColors.mint,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _InfoTile(
                            icon: _ikonSuhu(menu.suhuSajian),
                            label: 'Suhu Sajian',
                            value: menu.suhuSajian,
                            color: menu.suhuSajian == 'Dingin' ? Colors.blue : AppColors.coral,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.timer_outlined,
                            label: 'Estimasi',
                            value: '${menu.estimasiSaji} menit',
                            color: AppColors.tealDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text('Level pedas:', style: theme.textTheme.bodySmall),
                        const SizedBox(width: 8),
                        Flexible(child: LevelPedasBadge(level: menu.levelPedas)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Deskripsi', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(menu.deskripsi, style: const TextStyle(height: 1.5)),
                    const SizedBox(height: 20),
                    if (!menu.isHabis) ...[
                      Text('Catatan untuk menu ini (opsional)', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller.catatanController,
                        maxLength: 150,
                        decoration: const InputDecoration(
                          hintText: 'Mis. less sugar, tanpa bawang, sambal dipisah',
                          prefixIcon: Icon(Icons.edit_note_rounded),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('Jumlah', style: theme.textTheme.titleMedium),
                          const Spacer(),
                          QtyStepper(
                            value: controller.qty.value,
                            max: controller.maxQty < 1 ? 1 : controller.maxQty,
                            enabled: controller.maxQty > 0,
                            onChanged: controller.setQty,
                          ),
                        ],
                      ),
                      if (controller.cart.jumlahDiKeranjang(menu.id) > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${controller.cart.jumlahDiKeranjang(menu.id)} porsi sudah ada di keranjang '
                            '(sisa bisa ditambah: ${controller.maxQty})',
                            style: const TextStyle(fontSize: 12, color: AppColors.coralDark),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final menu = controller.menu.value;
        final habis = menu.isHabis;
        final penuh = !habis && controller.maxQty <= 0;
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                if (!habis)
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total', style: theme.textTheme.bodySmall),
                        Text(Formatter.rupiah(controller.totalHarga),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.tealDark)),
                      ],
                    ),
                  ),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: habis || penuh || controller.isAdding.value ? null : controller.addToCart,
                    icon: controller.isAdding.value
                        ? const SizedBox(
                            width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Icon(habis ? Icons.block_rounded : Icons.add_shopping_cart_rounded),
                    label: Text(habis ? 'Habis' : (penuh ? 'Stok di keranjang penuh' : 'Tambah ke Keranjang')),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value, required this.color});

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          Text(value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13)),
        ],
      ),
    );
  }
}
