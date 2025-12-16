import 'package:get/get.dart';
import '../../data/models/notification_payload.dart';

class NotificationRouter {
  static void route(NotificationPayload payload) {
    switch (payload.type) {
      case 'order':
        Get.toNamed('/order', arguments: payload.orderId);
        break;
      case 'promo':
        Get.toNamed('/promo', arguments: payload.promoId);
        break;
      default:
        Get.toNamed('/home');
    }
  }
}
