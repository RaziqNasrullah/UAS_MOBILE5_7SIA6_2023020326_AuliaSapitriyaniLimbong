import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/cart_controller.dart';
import '../../controllers/katalog_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cart_badge_icon.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/menu_card.dart';
import '../../widgets/state_views.dart';

/// Katalog menu: GridView + pencarian realtime + filter ChoiceChip kategori.
class KatalogView extends GetView<KatalogController> {
  const KatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Menu'),
        actions: const [CartBadgeIcon(color: AppColors.tealDark), SizedBox(width: 8)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Obx(
              () => TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari menu, mis. "kopi" atau "rice bowl"',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: controller.keyword.value.isEmpty
                      ? null
                      : IconButton(icon: const Icon(Icons.close_rounded), onPressed: controller.clearSearch),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: Obx(
              () => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  CategoryChip(
                    label: 'Semua',
                    icon: Icons.apps_rounded,
                    selected: controller.selectedKategoriId.value == null,
                    onSelected: (_) => controller.selectKategori(null),
                  ),
                  for (final k in controller.kategoriList) ...[
                    const SizedBox(width: 8),
                    CategoryChip(
                      label: k.nama,
                      icon: ikonKategori(k.ikon, k.nama),
                      selected: controller.selectedKategoriId.value == k.id,
                      onSelected: (_) => controller.selectKategori(k.id),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Obx(
            () => Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(controller.infoHasil,
                        style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  if (controller.isLoading.value && controller.menus.isNotEmpty)
                    const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.menus.isEmpty) return const LoadingView();
              if (controller.errorMessage.value != null && controller.menus.isEmpty) {
                return ErrorState(message: controller.errorMessage.value!, onRetry: controller.refreshAll);
              }
              if (controller.menus.isEmpty) {
                return EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Menu tidak ditemukan',
                  message: 'Coba kata kunci lain atau pilih kategori "Semua".',
                  action: OutlinedButton(
                    onPressed: () {
                      controller.clearSearch();
                      controller.selectKategori(null);
                    },
                    child: const Text('Reset pencarian'),
                  ),
                );
              }
              return RefreshIndicator(
                color: AppColors.coral,
                onRefresh: controller.refreshAll,
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisExtent: 262,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: controller.menus.length,
                  itemBuilder: (_, i) {
                    final menu = controller.menus[i];
                    return MenuCard(
                      menu: menu,
                      onTap: () => Get.toNamed(AppRoutes.menuDetail, arguments: menu),
                      onAdd: () => cart.addToCart(menu),
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
