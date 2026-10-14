import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../controllers/struk_controller.dart';
import '../../theme/app_theme.dart';

/// Preview struk PDF + simpan ke perangkat + bagikan.
class StrukView extends GetView<StrukController> {
  const StrukView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Struk ${controller.pesanan.nomorPesanan}', style: const TextStyle(fontSize: 17)),
        actions: [
          IconButton(tooltip: 'Bagikan', onPressed: controller.bagikan, icon: const Icon(Icons.share_rounded)),
        ],
      ),
      body: PdfPreview(
        build: (PdfPageFormat _) => controller.buildPdf(),
        pdfFileName: controller.namaFile,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        allowSharing: false,
        allowPrinting: true,
        initialPageFormat: PdfPageFormat.roll80,
        previewPageMargin: const EdgeInsets.all(12),
        scrollViewDecoration: const BoxDecoration(color: AppColors.cream),
        loadingWidget: const CircularProgressIndicator(color: AppColors.coral),
        onError: (_, error) => Center(child: Text('Gagal membuat PDF: $error')),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(
                () => controller.savedPath.value == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('Tersimpan: ${controller.savedPath.value}',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.selesai)),
                      ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: controller.bagikan,
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('Bagikan'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(
                      () => ElevatedButton.icon(
                        onPressed: controller.isSaving.value ? null : controller.simpan,
                        icon: const Icon(Icons.download_rounded),
                        label: Text(controller.isSaving.value ? 'Menyimpan...' : 'Simpan PDF'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
