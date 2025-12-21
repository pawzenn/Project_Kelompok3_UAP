import 'package:get/get.dart';

import '../controller/admin_orders_controller.dart';
import '../pages/admin_shell_view.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminShellController>(() => AdminShellController(),
        fenix: true);
    Get.lazyPut<AdminOrdersController>(() => AdminOrdersController(),
        fenix: true);
  }
}
