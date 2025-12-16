import 'package:get/get.dart';
import '../controllers/location_live_controller.dart';

class LocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LocationLiveController());
  }
}
