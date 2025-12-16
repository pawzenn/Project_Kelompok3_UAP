import 'package:get/get.dart';
import '../controllers/location_gps_controller.dart';

class GpsLocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LocationGpsController()); // ← pakai nama kelas yang benar
  }
}
