import 'package:get/get.dart';

import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/pages/auth_gate_page.dart';
import '../../features/auth/pages/welcome_screen.dart';
import '../../features/auth/pages/signin_page.dart';
import '../../features/auth/pages/signup_page.dart';

import '../../features/home/pages/home_view.dart';
import '../../features/home/bindings/home_binding.dart';

// ✅ TAMBAH IMPORT INI
import '../../features/cart/pages/cart_view.dart';
import '../../features/cart/pages/checkout_view.dart';
import '../../features/cart/bindings/cart_binding.dart';
import '../../features/orders/page/orders_view.dart';
import '../../features/orders/bindings/orders_binding.dart';

import 'app_routes.dart';
import '../../features/orders/pages/order_detail_view.dart';
import '../../features/orders/controller/order_detail_controller.dart';

class AppPages {
  AppPages._();

  static final routes = <GetPage>[
    GetPage(name: AppRoutes.welcome, page: () => const WelcomeScreen()),

    GetPage(
      name: AppRoutes.authGate,
      page: () => const AuthGatePage(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.login,
      page: () => const SignInPage(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: AppRoutes.register,
      page: () => const SignUpPage(),
      binding: AuthBinding(),
    ),

    // ✅ HOME harus pakai HomeBinding, bukan AuthBinding
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),

    GetPage(
      name: AppRoutes.cart,
      page: () => const CartView(),
      binding: CartBinding(),
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () => const CheckoutView(),
      binding: CartBinding(),
    ),

    GetPage(
      name: AppRoutes.orders,
      page: () => const OrdersView(),
      binding: OrdersBinding(),
    ),

    GetPage(
      name: AppRoutes.orderDetail,
      page: () => const OrderDetailView(),
      binding: BindingsBuilder(() {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        Get.put(OrderDetailController(order: args));
      }),
    ),
  ];
}
