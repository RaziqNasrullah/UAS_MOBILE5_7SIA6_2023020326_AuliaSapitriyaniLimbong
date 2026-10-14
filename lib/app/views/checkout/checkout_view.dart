import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/checkout_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/biaya_calculator.dart';
import '../../utils/formatter.dart';
import '../../utils/validators.dart';
import '../../widgets/biaya_row.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/state_views.dart';

/// Form checkout: data pemesan, tipe pesanan (meja/alamat kondisional), rincian biaya.
class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Obx(() {
        if (controller.cart.isEmpty) {
          return const EmptyState(icon: Icons.shopping_bag_outlined, title: 'Keranjang kosong');
        }
        return Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text('Ringkasan Pesanan', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      for (final item in controller.cart.items)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${item.jumlah}x ', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.coralDark)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.namaMenu, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    if (item.catatanItem != null)
                                      Text('Catatan: ${item.catatanItem}',
                                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                              Text(Formatter.rupiah(item.subtotal)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Data Pemesan', style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              CustomTextField(
                label: 'Nama pemesan',
                requiredField: true,
                controller: controller.namaController,
                icon: Icons.person_outline_rounded,
                hint: 'Nama lengkap',
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.wajib(v, 'Nama pemesan') ?? Validators.maksPanjang(v, 100, 'Nama'),
              ),
              CustomTextField(
                label: 'Nomor HP',
                requiredField: true,
                controller: controller.hpController,
                icon: Icons.phone_android_rounded,
                hint: '08xxxxxxxxxx',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(13)],
                validator: Validators.noHp,
              ),
              Text('Tipe pesanan *', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Card(
                child: RadioGroup<String>(
                  groupValue: controller.tipePesanan.value,
                  onChanged: controller.setTipe,
                  child: Column(
                    children: [
                      for (final tipe in TipePesanan.semua)
                        RadioListTile<String>(
                          value: tipe,
                          dense: true,
                          activeColor: AppColors.coral,
                          title: Text(tipe, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(switch (tipe) {
                            TipePesanan.makanDiTempat => 'Wajib isi nomor meja',
                            TipePesanan.diantar => 'Wajib isi alamat, ongkir ${Formatter.rupiah(8000)}',
                            _ => 'Ambil sendiri di kasir',
                          }),
                          secondary: Icon(switch (tipe) {
                            TipePesanan.makanDiTempat => Icons.table_restaurant_rounded,
                            TipePesanan.diantar => Icons.delivery_dining_rounded,
                            _ => Icons.takeout_dining_rounded,
                          }, color: AppColors.mint),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (controller.butuhMeja)
                CustomTextField(
                  key: const ValueKey('meja'),
                  label: 'Nomor meja',
                  requiredField: true,
                  controller: controller.mejaController,
                  icon: Icons.table_bar_rounded,
                  hint: 'Mis. 5',
                  maxLength: 10,
                  validator: controller.validasiMeja,
                ),
              if (controller.butuhAlamat)
                CustomTextField(
                  key: const ValueKey('alamat'),
                  label: 'Alamat pengantaran',
                  requiredField: true,
                  controller: controller.alamatController,
                  icon: Icons.location_on_outlined,
                  hint: 'Nama jalan, nomor rumah, patokan',
                  maxLines: 3,
                  validator: (v) => controller.validasiAlamat(v) ?? Validators.maksPanjang(v, 255, 'Alamat'),
                ),
              CustomTextField(
                label: 'Catatan pesanan (opsional)',
                controller: controller.catatanController,
                icon: Icons.sticky_note_2_outlined,
                hint: 'Mis. tolong sendok plastik',
                maxLines: 2,
                validator: (v) => Validators.maksPanjang(v, 255, 'Catatan'),
              ),
              Text('Rincian Biaya', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      BiayaRow(label: 'Subtotal (${controller.cart.totalItem} item)', value: controller.rincian.subtotal),
                      BiayaRow(label: 'Biaya layanan', value: controller.rincian.biayaLayanan),
                      BiayaRow(
                        label: 'Ongkir',
                        value: controller.rincian.ongkir,
                        note: controller.butuhAlamat ? null : 'Gratis untuk ${controller.tipePesanan.value}',
                      ),
                      BiayaRow(
                        label: 'Diskon 10%',
                        value: controller.rincian.diskon,
                        isMinus: true,
                        note: controller.rincian.diskon > 0 ? 'Subtotal >= Rp100.000' : 'Min. subtotal Rp100.000',
                      ),
                      const Divider(height: 20),
                      BiayaRow(label: 'Total Bayar', value: controller.rincian.total, isTotal: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(
        () => controller.cart.isEmpty
            ? const SizedBox.shrink()
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                  child: ElevatedButton.icon(
                    onPressed: controller.isSubmitting.value ? null : controller.submit,
                    icon: controller.isSubmitting.value
                        ? const SizedBox(
                            width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_circle_outline_rounded),
                    label: Text(controller.isSubmitting.value
                        ? 'Memproses pesanan...'
                        : 'Buat Pesanan - ${Formatter.rupiah(controller.rincian.total)}'),
                  ),
                ),
              ),
      ),
    );
  }
}
