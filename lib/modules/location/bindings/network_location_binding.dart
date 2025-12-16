import 'package:get/get.dart';
import '../controllers/location_network_controller.dart';

class NetworkLocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LocationNetworkController()); // ← pakai nama class yang benar
  }
}
