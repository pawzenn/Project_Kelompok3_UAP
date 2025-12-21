import 'package:get/get.dart';

class NotificationRouter {
  static void handle(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'promo':
        Get.toNamed('/promo');
        break;
      case 'order_status':
        Get.toNamed('/orders/${data['order_id']}');
        break;
    }
  }
}
