import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/kategori_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/state_views.dart';

/// Daftar kategori (Read) + aksi tambah/ubah/hapus.
class KategoriView extends GetView<KategoriController> {
  const KategoriView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Kategori')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.bukaForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Kategori'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.kategoriList.isEmpty) return const LoadingView();
        if (controller.errorMessage.value != null && controller.kategoriList.isEmpty) {
          return ErrorState(message: controller.errorMessage.value!, onRetry: controller.fetchKategori);
        }
        if (controller.kategoriList.isEmpty) {
          return const EmptyState(icon: Icons.category_outlined, title: 'Belum ada kategori', message: 'Tekan tombol + untuk menambah.');
        }
        return RefreshIndicator(
          color: AppColors.coral,
          onRefresh: () => controller.fetchKategori(silent: true),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: controller.kategoriList.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final k = controller.kategoriList[i];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(14, 6, 4, 6),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.mint.withValues(alpha: 0.14),
                    child: Icon(ikonKategori(k.ikon, k.nama), color: AppColors.mint),
                  ),
                  title: Text(k.nama, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    '${k.jumlahMenu} menu${k.deskripsi == null ? '' : '\n${k.deskripsi}'}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: k.deskripsi != null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Ubah',
                        onPressed: () => controller.bukaForm(k),
                        icon: const Icon(Icons.edit_outlined, color: AppColors.tealDark),
                      ),
                      IconButton(
                        tooltip: 'Hapus',
                        onPressed: () => controller.hapus(k),
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.dibatalkan),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
