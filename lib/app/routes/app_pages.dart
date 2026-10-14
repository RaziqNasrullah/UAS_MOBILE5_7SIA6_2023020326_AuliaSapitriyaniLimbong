import 'package:get/get.dart';

import '../bindings/app_bindings.dart';
import '../views/cart/cart_view.dart';
import '../views/checkout/checkout_success_view.dart';
import '../views/checkout/checkout_view.dart';
import '../views/dashboard/dashboard_view.dart';
import '../views/kategori/kategori_form_view.dart';
import '../views/kategori/kategori_view.dart';
import '../views/main/main_view.dart';
import '../views/menu_admin/menu_admin_view.dart';
import '../views/menu_admin/menu_form_view.dart';
import '../views/menu_detail/menu_detail_view.dart';
import '../views/pesanan/pesanan_detail_view.dart';
import '../views/struk/struk_view.dart';
import 'app_routes.dart';

/// Daftar GetPage (route + binding).
class AppPages {
  AppPages._();

  static const initial = AppRoutes.main;

  static final pages = <GetPage>[
    GetPage(name: AppRoutes.main, page: () => const MainView(), binding: MainBinding()),
    GetPage(
      name: AppRoutes.menuDetail,
      page: () => const MenuDetailView(),
      binding: MenuDetailBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(name: AppRoutes.cart, page: () => const CartView(), transition: Transition.rightToLeft),
    GetPage(name: AppRoutes.checkout, page: () => const CheckoutView(), binding: CheckoutBinding()),
    GetPage(
      name: AppRoutes.checkoutSukses,
      page: () => const CheckoutSuccessView(),
      transition: Transition.zoom,
    ),
    GetPage(name: AppRoutes.pesananDetail, page: () => const PesananDetailView(), binding: PesananDetailBinding()),
    GetPage(name: AppRoutes.struk, page: () => const StrukView(), binding: StrukBinding()),
    GetPage(name: AppRoutes.dashboard, page: () => const DashboardView(), binding: DashboardBinding()),
    GetPage(name: AppRoutes.kategori, page: () => const KategoriView(), binding: KategoriBinding()),
    GetPage(name: AppRoutes.kategoriForm, page: () => const KategoriFormView(), binding: KategoriFormBinding()),
    GetPage(name: AppRoutes.menuAdmin, page: () => const MenuAdminView(), binding: MenuAdminBinding()),
    GetPage(name: AppRoutes.menuForm, page: () => const MenuFormView(), binding: MenuFormBinding()),
  ];
}
