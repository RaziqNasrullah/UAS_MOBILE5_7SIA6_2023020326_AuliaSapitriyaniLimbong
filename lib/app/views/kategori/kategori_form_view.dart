import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/kategori_controller.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';

/// Form tambah / ubah kategori (validasi kosong & duplikat).
class KategoriFormView extends GetView<KategoriFormController> {
  const KategoriFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(controller.isEdit ? 'Ubah Kategori' : 'Tambah Kategori')),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              label: 'Nama kategori',
              requiredField: true,
              controller: controller.namaController,
              icon: Icons.category_outlined,
              hint: 'Mis. Makanan Utama',
              maxLength: 50,
              validator: controller.validasiNama,
            ),
            CustomTextField(
              label: 'Deskripsi (opsional)',
              controller: controller.deskripsiController,
              icon: Icons.notes_rounded,
              hint: 'Keterangan singkat kategori',
              maxLines: 3,
              validator: (v) => Validators.maksPanjang(v, 255, 'Deskripsi'),
            ),
            const SizedBox(height: 8),
            Obx(
              () => ElevatedButton.icon(
                onPressed: controller.isSaving.value ? null : controller.simpan,
                icon: controller.isSaving.value
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded),
                label: Text(controller.isEdit ? 'Simpan Perubahan' : 'Simpan Kategori'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
