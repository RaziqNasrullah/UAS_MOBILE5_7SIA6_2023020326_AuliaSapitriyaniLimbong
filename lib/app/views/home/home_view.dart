import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/cart_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/katalog_controller.dart';
import '../../controllers/main_controller.dart';
import '../../data/services/api_config.dart';
import '../../models/menu.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatter.dart';
import '../../widgets/cart_badge_icon.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/menu_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/state_views.dart';

/// Beranda: sapaan sesuai waktu, kategori, best seller & menu terbaru.
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  void _bukaKatalog([int? kategoriId]) {
    final main = Get.find<MainController>();
    Get.find<KatalogController>().selectKategori(kategoriId);
    main.changeTab(MainController.tabKatalog);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/images/logo_icon.png', width: 40, height: 40),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ApiConfig.namaAplikasi, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19)),
                Text('by ${ApiConfig.namaKedai}',
                    style: TextStyle(fontSize: 11, color: AppColors.coralDark, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
        actions: const [CartBadgeIcon(color: AppColors.tealDark), SizedBox(width: 8)],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.bestSellers.isEmpty) {
          return const LoadingView();
        }
        if (controller.errorMessage.value != null && controller.kategoriList.isEmpty) {
          return ErrorState(message: controller.errorMessage.value!, onRetry: controller.fetchData);
        }
        return RefreshIndicator(
          color: AppColors.coral,
          onRefresh: () => controller.fetchData(silent: true),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _Banner(sapaan: controller.sapaan.value, onTap: () => _bukaKatalog()),
              const SectionHeader(title: 'Kategori'),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.kategoriList.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final k = controller.kategoriList[i];
                    return _KategoriTile(
                      nama: k.nama,
                      jumlah: k.jumlahMenu,
                      icon: ikonKategori(k.ikon, k.nama),
                      onTap: () => _bukaKatalog(k.id),
                    );
                  },
                ),
              ),
              SectionHeader(title: 'Best Seller', actionLabel: 'Lihat semua', onAction: () => _bukaKatalog()),
              _MenuHorizontalList(menus: controller.bestSellers),
              const SectionHeader(title: 'Menu Terbaru'),
              _MenuHorizontalList(menus: controller.menuTerbaru),
            ],
          ),
        );
      }),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.sapaan, required this.onTap});

  final String sapaan;
  final VoidCallback onTap;

  IconData get _icon => switch (sapaan) {
        'Selamat Pagi' => Icons.wb_sunny_rounded,
        'Selamat Siang' => Icons.light_mode_rounded,
        'Selamat Sore' => Icons.wb_twilight_rounded,
        _ => Icons.nightlight_round,
      };

  String get _ajakan => switch (sapaan) {
        'Selamat Pagi' => 'Awali harimu dengan sarapan hangat & kopi susu gula aren.',
        'Selamat Siang' => 'Waktunya makan siang! Rice bowl & es teh leci siap menemani.',
        'Selamat Sore' => 'Ngemil sore pakai dimsum atau waffle, yuk!',
        _ => 'Lapar malam? Pesan hidangan favoritmu sekarang.',
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.coral, AppColors.coralDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: AppColors.coral.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_icon, color: Colors.white, size: 20),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text('$sapaan!',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(_ajakan, style: const TextStyle(color: Colors.white, height: 1.35)),
                  const SizedBox(height: 4),
                  Text(Formatter.tanggalPanjang(DateTime.now()),
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.coralDark,
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: onTap,
                    icon: const Icon(Icons.restaurant_menu_rounded, size: 18),
                    label: const Text('Lihat Menu', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 86,
              height: 86,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              padding: const EdgeInsets.all(6),
              child: Image.asset('assets/images/logo_icon.png'),
            ),
          ],
        ),
      ),
    );
  }
}

class _KategoriTile extends StatelessWidget {
  const _KategoriTile({required this.nama, required this.jumlah, required this.icon, required this.onTap});

  final String nama;
  final int jumlah;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.mint.withValues(alpha: 0.13), shape: BoxShape.circle),
                  child: Icon(icon, color: AppColors.mint, size: 24),
                ),
                const SizedBox(height: 6),
                Text(nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                Text('$jumlah menu', style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuHorizontalList extends StatelessWidget {
  const _MenuHorizontalList({required this.menus});

  final List<Menu> menus;

  @override
  Widget build(BuildContext context) {
    if (menus.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Belum ada menu', style: TextStyle(color: AppColors.textMuted)),
      );
    }
    final cart = Get.find<CartController>();
    return SizedBox(
      height: 262,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: menus.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => MenuCard(
          width: 168,
          menu: menus[i],
          onTap: () => Get.toNamed(AppRoutes.menuDetail, arguments: menus[i]),
          onAdd: () => cart.addToCart(menus[i]),
        ),
      ),
    );
  }
}
