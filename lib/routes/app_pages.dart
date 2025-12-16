import 'package:get/get.dart';

// ===== AUTH / LOGIN =====
import '../login/signin_page.dart';
import '../login/signup_page.dart';

// ===== HOME, CART, PROFILE =====
import '../modules/home/home_view.dart';
import '../modules/home/home_controller.dart';
import '../modules/cart/cart_view.dart';
import '../modules/cart/cart_controller.dart';
import '../modules/profile/profile_view.dart';
import '../modules/profile/profile_controller.dart';

// ===== LOCATION MODULE (MODUL 5) =====
import '../modules/location/location_menu_view.dart';
import '../modules/location/location_live_view.dart';
import '../modules/location/location_network_view.dart';
import '../modules/location/views/location_gps_view.dart';

import '../modules/location/bindings/location_binding.dart';
import '../modules/location/bindings/network_location_binding.dart';
import '../modules/location/bindings/gps_location_binding.dart';

// ===== NOTIFICATION =====
import '../modules/location/views/notification_menu_view.dart';
import '../modules/location/views/notification_history_view.dart';
import '../modules/location/views/notification_test_view.dart';
import '../modules/location/bindings/notification_binding.dart';

// ===== PROMO =====
import '../modules/promo/promo_view.dart';

import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = <GetPage>[
    // ========== AUTH ==========
    GetPage(name: AppRoutes.login, page: () => const SignInPage()),
    GetPage(name: AppRoutes.register, page: () => const SignUpPage()),

    // ========== HOME ==========
    GetPage(
      name: AppRoutes.home,
      page: () => HomeView(),
      binding: BindingsBuilder(() {
        Get.put(HomeController());
        Get.put(CartController(), permanent: true);
      }),
    ),

    // ========== CART ==========
    GetPage(name: AppRoutes.cart, page: () => const CartView()),

    // ========== PROFILE ==========
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.put(ProfileController());
      }),
    ),

    // ========== LOCATION MENU ==========
    GetPage(name: AppRoutes.locationMenu, page: () => const LocationMenuView()),

    // ========== LOCATION: LIVE ==========
    GetPage(
      name: AppRoutes.locationLive,
      page: () => const LocationLiveView(),
      binding: LocationBinding(),
    ),

    // ========== LOCATION: NETWORK ==========
    GetPage(
      name: AppRoutes.locationNetwork,
      page: () => const LocationNetworkView(),
      binding: NetworkLocationBinding(),
    ),

    // ========== LOCATION: GPS ==========
    GetPage(
      name: AppRoutes.locationGps,
      page: () => const LocationGpsView(),
      binding: GpsLocationBinding(),
    ),

    // ========== NOTIFICATION ==========
    GetPage(
      name: AppRoutes.notificationMenu,
      page: () => NotificationMenuView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: AppRoutes.notificationHistory,
      page: () => NotificationHistoryView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: AppRoutes.notificationTest,
      page: () => NotificationTestView(),
      binding: NotificationBinding(),
    ),

    // ========== PROMO ==========
    GetPage(name: AppRoutes.promo, page: () => const PromoView()),
  ];
}
