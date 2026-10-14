import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/api_config.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// Menu admin / kasir kedai: Dashboard, Kelola Kategori, Kelola Menu.
class KelolaView extends StatelessWidget {
  const KelolaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Kedai')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.mint, AppColors.tealDark]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.storefront_rounded, color: AppColors.tealDark, size: 28),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Admin / Kasir ${ApiConfig.namaKedai}',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                      SizedBox(height: 2),
                      Text('Kelola kategori, menu, status pesanan & pantau penjualan',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _MenuTile(
            icon: Icons.insights_rounded,
            color: AppColors.coral,
            title: 'Dashboard Penjualan',
            subtitle: 'Total pesanan, pendapatan, menu terlaris & grafik',
            onTap: () => Get.toNamed(AppRoutes.dashboard),
          ),
          _MenuTile(
            icon: Icons.category_rounded,
            color: AppColors.mint,
            title: 'Kelola Kategori',
            subtitle: 'Tambah, ubah, hapus kategori menu',
            onTap: () => Get.toNamed(AppRoutes.kategori),
          ),
          _MenuTile(
            icon: Icons.restaurant_menu_rounded,
            color: const Color(0xFFF2A93B),
            title: 'Kelola Menu',
            subtitle: 'Tambah, ubah, hapus menu + gambar & atribut kuliner',
            onTap: () => Get.toNamed(AppRoutes.menuAdmin),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.dns_rounded, color: AppColors.tealDark),
              title: const Text('Alamat Server API', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const SelectableText(ApiConfig.baseUrl),
              trailing: const Icon(Icons.info_outline_rounded, size: 20),
              onTap: () => Get.dialog(
                AlertDialog(
                  title: const Text('Mengubah alamat API'),
                  content: const Text(
                    'Emulator: http://10.0.2.2/kuliner_api\n'
                    'HP fisik: http://<IP-laptop>/kuliner_api\n\n'
                    'Ubah di lib/app/data/services/api_config.dart atau jalankan:\n'
                    'flutter run --dart-define=API_BASE_URL=http://192.168.x.x/kuliner_api',
                  ),
                  actions: [TextButton(onPressed: () => Get.key.currentState?.pop(), child: const Text('Tutup'))],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Delights v1.0.0\nAulia Sapitriyani Limbong - 2023020326 - 7SIA6',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      ),
    );
  }
}
