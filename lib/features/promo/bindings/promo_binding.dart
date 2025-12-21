import 'package:get/get.dart';
import '../controller/promo_controller.dart';

class PromoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PromoController>(() => PromoController(), fenix: true);
  }
}
