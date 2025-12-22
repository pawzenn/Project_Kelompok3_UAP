import 'package:get/get.dart';

import '../controller/home_controller.dart';
import '../../cart/controller/cart_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());

    // ✅ SINGLETON cart: dibuat sekali, hidup terus
    if (!Get.isRegistered<CartController>()) {
      Get.put<CartController>(CartController(), permanent: true);
    }
  }
}
