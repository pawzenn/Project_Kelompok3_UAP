import 'package:get/get.dart';

import '../controller/admin_orders_controller.dart';
import '../controller/admin_promo_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminOrdersController>(() => AdminOrdersController(),
        fenix: true);
    Get.lazyPut<AdminPromoController>(() => AdminPromoController(),
        fenix: true);
  }
}
