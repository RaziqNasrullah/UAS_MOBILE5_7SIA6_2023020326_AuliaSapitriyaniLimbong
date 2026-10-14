import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';

/// Ikon keranjang dengan badge jumlah item (reaktif via Obx).
class CartBadgeIcon extends StatelessWidget {
  const CartBadgeIcon({super.key, this.icon = Icons.shopping_bag_outlined, this.onTap, this.color});

  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    final iconWidget = Obx(
      () => Badge(
        isLabelVisible: cart.totalItem > 0,
        backgroundColor: AppColors.coralDark,
        label: Text('${cart.totalItem}', style: const TextStyle(color: Colors.white, fontSize: 10)),
        child: Icon(icon, color: color),
      ),
    );
    if (onTap == null && color == null) {
      // Dipakai di NavigationBar (tanpa tombol)
      return iconWidget;
    }
    return IconButton(
      tooltip: 'Keranjang',
      onPressed: onTap ?? () => Get.toNamed(AppRoutes.cart),
      icon: iconWidget,
    );
  }
}
