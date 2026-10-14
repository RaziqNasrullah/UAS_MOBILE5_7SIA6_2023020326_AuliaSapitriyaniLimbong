import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/main_controller.dart';
import '../../widgets/cart_badge_icon.dart';
import '../cart/cart_view.dart';
import '../home/home_view.dart';
import '../katalog/katalog_view.dart';
import '../kelola/kelola_view.dart';
import '../pesanan/pesanan_view.dart';

/// Kerangka utama dengan NavigationBar (bottom navigation).
class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: controller.tabIndex.value == MainController.tabBeranda,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) controller.changeTab(MainController.tabBeranda);
        },
        child: Scaffold(
          body: IndexedStack(
            index: controller.tabIndex.value,
            children: const [HomeView(), KatalogView(), CartView(), PesananView(), KelolaView()],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: controller.tabIndex.value,
            onDestinationSelected: controller.changeTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: Icon(Icons.restaurant_menu_outlined),
                selectedIcon: Icon(Icons.restaurant_menu_rounded),
                label: 'Katalog',
              ),
              NavigationDestination(
                icon: CartBadgeIcon(),
                selectedIcon: CartBadgeIcon(icon: Icons.shopping_bag_rounded),
                label: 'Keranjang',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded),
                label: 'Pesanan',
              ),
              NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront_rounded),
                label: 'Kelola',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
