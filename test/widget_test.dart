import 'package:delights/app/controllers/cart_controller.dart';
import 'package:delights/app/controllers/checkout_controller.dart';
import 'package:delights/app/routes/app_pages.dart';
import 'package:delights/app/theme/app_theme.dart';
import 'package:delights/app/widgets/level_pedas_badge.dart';
import 'package:delights/app/widgets/menu_card.dart';
import 'package:delights/app/widgets/qty_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'helpers/fake_backend.dart';

void main() {
  late FakeBackend backend;

  setUpAll(() => initializeDateFormatting('id_ID'));

  setUp(() {
    Get.reset();
    backend = FakeBackend();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    backend.register();
    await tester.pumpWidget(GetMaterialApp(
      theme: AppTheme.light,
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('Beranda menampilkan sapaan, kategori & best seller', (tester) async {
    await pumpApp(tester);
    expect(find.textContaining('Selamat'), findsOneWidget);
    expect(find.text('Makanan Utama'), findsWidgets);
    expect(find.text('Best Seller'), findsWidgets);
    expect(find.text('Rice Bowl Ayam Sambal Matah'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Katalog: GridView, filter ChoiceChip & pencarian realtime (debounce)', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Katalog').last);
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(MenuCard), findsNWidgets(3));
    expect(find.text('HABIS'), findsOneWidget);

    // Filter kategori Minuman
    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Minuman'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Minuman'));
    await tester.pumpAndSettle();
    expect(find.byType(MenuCard), findsOneWidget);
    expect(find.text('Kopi Susu Gula Aren'), findsOneWidget);

    // Kembali ke Semua lalu cari "ayam" -> request dikirim setelah debounce 400ms
    await tester.scrollUntilVisible(find.widgetWithText(ChoiceChip, 'Semua'), -100,
        scrollable: find.descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable)).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Semua'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'ayam');
    await tester.pump(const Duration(milliseconds: 100));
    expect(backend.requests.where((r) => r.contains('search=ayam')), isEmpty);
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();
    expect(backend.requests.where((r) => r.contains('search=ayam')), hasLength(1));
    expect(find.byType(MenuCard), findsNWidgets(2));
  });

  testWidgets('Detail menu habis: tombol nonaktif bertuliskan "Habis"', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Katalog').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ayam Geprek Keju Mozarella'));
    await tester.pumpAndSettle();
    expect(find.byType(LevelPedasBadge), findsOneWidget);
    final button = find.widgetWithText(ElevatedButton, 'Habis');
    expect(button, findsOneWidget);
    expect(tester.widget<ElevatedButton>(button).onPressed, isNull);
  });

  testWidgets('Tambah ke keranjang dengan catatan -> badge bertambah', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Katalog').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kopi Susu Gula Aren'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'less sugar');
    final plus = find.descendant(of: find.byType(QtyStepper), matching: find.byIcon(Icons.add_rounded));
    await tester.ensureVisible(plus);
    await tester.pumpAndSettle();
    await tester.tap(plus); // qty 2 (= stok)
    await tester.pump();
    await tester.tap(find.text('Tambah ke Keranjang'));
    await tester.pumpAndSettle();
    expect(Get.find<CartController>().totalItem, 2);
    expect(backend.keranjang.single['catatan_item'], 'less sugar');
    // stok sudah penuh di keranjang
    expect(find.text('Stok di keranjang penuh'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('Checkout: validasi form kosong & nomor meja wajib', (tester) async {
    backend.keranjang.add({
      'id': 1, 'menu_id': 1, 'jumlah': 4, 'catatan_item': null, 'nama_menu': 'Rice Bowl Ayam Sambal Matah',
      'harga': 32000, 'stok': 25, 'gambar': null, 'nama_kategori': 'Makanan Utama', 'level_pedas': 'Pedas',
    });
    await pumpApp(tester);
    await tester.tap(find.text('Keranjang').last);
    await tester.pumpAndSettle();
    expect(find.text('Subtotal Rp128.000'), findsOneWidget);
    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();
    // subtotal 128.000 -> diskon 12.800, total = 128.000 + 2.000 - 12.800
    expect(find.textContaining('Rp117.200'), findsWidgets);
    await tester.tap(find.textContaining('Buat Pesanan'));
    await tester.pumpAndSettle();
    expect(find.text('Nama pemesan wajib diisi'), findsOneWidget);
    expect(find.text('Nomor HP wajib diisi'), findsOneWidget);
    expect(find.text('Nomor meja wajib diisi untuk Makan di Tempat'), findsOneWidget);
    // Pilih Diantar -> field alamat muncul, ongkir masuk total
    await tester.pump(const Duration(seconds: 4)); // tunggu snackbar hilang
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Diantar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Diantar'));
    await tester.pumpAndSettle();
    expect(Get.find<CheckoutController>().tipePesanan.value, 'Diantar');
    await tester.scrollUntilVisible(find.textContaining('Alamat pengantaran'), 150,
        scrollable: find.byType(Scrollable).first);
    expect(find.textContaining('Alamat pengantaran'), findsOneWidget);
    expect(find.textContaining('Nomor meja'), findsNothing);
    expect(find.textContaining('Rp125.200'), findsWidgets);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
