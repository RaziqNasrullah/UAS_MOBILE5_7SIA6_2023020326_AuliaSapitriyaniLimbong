import 'package:flutter/material.dart';

import '../models/menu.dart';
import '../theme/app_theme.dart';
import '../utils/formatter.dart';
import 'level_pedas_badge.dart';
import 'menu_image.dart';

/// Kartu menu untuk GridView katalog & daftar horizontal di Home.
class MenuCard extends StatelessWidget {
  const MenuCard({super.key, required this.menu, this.onTap, this.onAdd, this.width});

  final Menu menu;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MenuImage(url: menu.imageUrl),
                    if (menu.isBestSeller)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(20)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded, size: 12, color: Colors.white),
                              SizedBox(width: 2),
                              Text('Best Seller',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    if (menu.isHabis)
                      Container(
                        color: Colors.black.withValues(alpha: 0.45),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.dibatalkan, borderRadius: BorderRadius.circular(20)),
                          child: const Text('HABIS',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1)),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, height: 1.2),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      menu.namaKategori,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    LevelPedasBadge(level: menu.levelPedas, compact: true),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            Formatter.rupiah(menu.harga),
                            style: const TextStyle(color: AppColors.coralDark, fontWeight: FontWeight.w800),
                          ),
                        ),
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: IconButton.filled(
                            padding: EdgeInsets.zero,
                            iconSize: 18,
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.mint,
                              disabledBackgroundColor: Colors.grey.shade300,
                            ),
                            tooltip: menu.isHabis ? 'Habis' : 'Tambah ke keranjang',
                            onPressed: menu.isHabis ? null : onAdd,
                            icon: const Icon(Icons.add_rounded, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
