import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/menu_admin_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/level_pedas_badge.dart';
import '../../widgets/menu_image.dart';
import '../../widgets/state_views.dart';

/// Daftar menu untuk admin (nama kategori hasil JOIN) + tambah/ubah/hapus.
class MenuAdminView extends GetView<MenuAdminController> {
  const MenuAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Menu')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.bukaForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Menu'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              onChanged: (v) => controller.keyword.value = v,
              decoration: const InputDecoration(hintText: 'Cari nama menu', prefixIcon: Icon(Icons.search_rounded)),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.menus.isEmpty) return const LoadingView();
              if (controller.errorMessage.value != null && controller.menus.isEmpty) {
                return ErrorState(message: controller.errorMessage.value!, onRetry: controller.fetchMenus);
              }
              if (controller.menus.isEmpty) {
                return const EmptyState(icon: Icons.no_food_outlined, title: 'Belum ada menu');
              }
              return RefreshIndicator(
                color: AppColors.coral,
                onRefresh: () => controller.fetchMenus(silent: true),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  itemCount: controller.menus.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final m = controller.menus[i];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => controller.bukaForm(m),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              MenuImage(url: m.imageUrl, width: 70, height: 70, borderRadius: 12),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(m.nama,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w700)),
                                    Text(
                                      '${m.namaKategori}  -  ${Formatter.rupiah(m.harga)}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        LevelPedasBadge(level: m.levelPedas, compact: true),
                                        Text(
                                          m.isHabis ? 'Stok habis' : 'Stok ${m.stok}',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: m.isHabis ? AppColors.dibatalkan : AppColors.selesai,
                                          ),
                                        ),
                                        if (m.isBestSeller)
                                          const Icon(Icons.star_rounded, size: 16, color: AppColors.coral),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    tooltip: 'Ubah',
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => controller.bukaForm(m),
                                    icon: const Icon(Icons.edit_outlined, color: AppColors.tealDark),
                                  ),
                                  IconButton(
                                    tooltip: 'Hapus',
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => controller.hapus(m),
                                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.dibatalkan),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
