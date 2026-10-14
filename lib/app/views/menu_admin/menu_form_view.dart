import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/menu_admin_controller.dart';
import '../../models/menu.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/level_pedas_badge.dart';
import '../../widgets/menu_image.dart';

/// Form tambah / ubah menu: kategori (FK), harga, stok, deskripsi, gambar,
/// level pedas, suhu sajian, estimasi saji, best seller.
class MenuFormView extends GetView<MenuFormController> {
  const MenuFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600);
    return Scaffold(
      appBar: AppBar(title: Text(controller.isEdit ? 'Ubah Menu' : 'Tambah Menu')),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // ---------- Gambar ----------
            Obx(() {
              final file = controller.pickedImage.value;
              return GestureDetector(
                onTap: controller.pilihGambar,
                child: Container(
                  height: 180,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (file != null)
                        Image.file(file, fit: BoxFit.cover)
                      else if (controller.editing?.gambar != null)
                        MenuImage(url: controller.editing!.imageUrl)
                      else
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 44, color: AppColors.coral),
                            SizedBox(height: 6),
                            Text('Pilih gambar dari galeri', style: TextStyle(color: AppColors.textMuted)),
                          ],
                        ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(minimumSize: const Size(0, 36)),
                          onPressed: controller.pilihGambar,
                          icon: const Icon(Icons.photo_library_rounded, size: 18),
                          label: Text(file == null && controller.editing?.gambar == null ? 'Galeri' : 'Ganti'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 4),
            const Text('Format JPG/PNG/WEBP, maks 2 MB (opsional)',
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
            const SizedBox(height: 14),
            CustomTextField(
              label: 'Nama menu',
              requiredField: true,
              controller: controller.namaController,
              icon: Icons.restaurant_rounded,
              hint: 'Mis. Rice Bowl Ayam Sambal Matah',
              maxLength: 100,
              validator: (v) => Validators.wajib(v, 'Nama menu'),
            ),
            // ---------- Kategori (FK) ----------
            Text.rich(
              const TextSpan(text: 'Kategori', children: [TextSpan(text: ' *', style: TextStyle(color: Colors.red))]),
              style: labelStyle,
            ),
            const SizedBox(height: 6),
            Obx(
              () => DropdownButtonFormField<int>(
                key: ValueKey('kategori-${controller.kategoriList.length}'),
                initialValue: controller.kategoriId.value,
                isExpanded: true,
                hint: Text(controller.isLoadingKategori.value ? 'Memuat kategori...' : 'Pilih kategori'),
                decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined)),
                items: [
                  for (final k in controller.kategoriList) DropdownMenuItem(value: k.id, child: Text(k.nama)),
                ],
                onChanged: (v) => controller.kategoriId.value = v,
                validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Harga (Rp)',
                    requiredField: true,
                    controller: controller.hargaController,
                    icon: Icons.payments_outlined,
                    hint: '25000',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: Validators.harga,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomTextField(
                    label: 'Stok (porsi)',
                    requiredField: true,
                    controller: controller.stokController,
                    icon: Icons.inventory_2_outlined,
                    hint: '20',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: Validators.stok,
                  ),
                ),
              ],
            ),
            CustomTextField(
              label: 'Deskripsi',
              requiredField: true,
              controller: controller.deskripsiController,
              icon: Icons.notes_rounded,
              hint: 'Bahan, rasa, porsi...',
              maxLines: 3,
              validator: (v) => Validators.wajib(v, 'Deskripsi'),
            ),
            // ---------- Atribut khusus kuliner ----------
            Text('Atribut Kuliner', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Text('Level pedas *', style: labelStyle),
            const SizedBox(height: 6),
            Obx(
              () => DropdownButtonFormField<String>(
                key: ValueKey('pedas-${controller.levelPedas.value}'),
                initialValue: controller.levelPedas.value,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.local_fire_department_outlined)),
                items: [
                  for (final l in Menu.pilihanLevelPedas)
                    DropdownMenuItem(value: l, child: LevelPedasBadge(level: l, compact: true)),
                ],
                onChanged: (v) => controller.levelPedas.value = v ?? 'Tidak Pedas',
              ),
            ),
            const SizedBox(height: 14),
            Text('Suhu sajian *', style: labelStyle),
            const SizedBox(height: 6),
            Obx(
              () => DropdownButtonFormField<String>(
                key: ValueKey('suhu-${controller.suhuSajian.value}'),
                initialValue: controller.suhuSajian.value,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.thermostat_rounded)),
                items: [for (final s in Menu.pilihanSuhuSajian) DropdownMenuItem(value: s, child: Text(s))],
                onChanged: (v) => controller.suhuSajian.value = v ?? 'Panas',
              ),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: 'Estimasi waktu saji (menit)',
              requiredField: true,
              controller: controller.estimasiController,
              icon: Icons.timer_outlined,
              hint: '10',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: Validators.estimasiSaji,
            ),
            Obx(
              () => Card(
                child: SwitchListTile(
                  value: controller.isBestSeller.value,
                  onChanged: (v) => controller.isBestSeller.value = v,
                  activeThumbColor: AppColors.coral,
                  secondary: const Icon(Icons.star_rounded, color: AppColors.coral),
                  title: const Text('Best Seller', style: TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: const Text('Tampil di bagian Best Seller pada Beranda'),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Obx(
              () => ElevatedButton.icon(
                onPressed: controller.isSaving.value ? null : controller.simpan,
                icon: controller.isSaving.value
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded),
                label: Text(controller.isSaving.value
                    ? 'Menyimpan...'
                    : (controller.isEdit ? 'Simpan Perubahan' : 'Simpan Menu')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
