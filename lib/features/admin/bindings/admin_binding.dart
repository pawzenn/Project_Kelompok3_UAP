import 'package:get/get.dart';
import '../controller/admin_orders_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminOrdersController>(() => AdminOrdersController());
  }
}
