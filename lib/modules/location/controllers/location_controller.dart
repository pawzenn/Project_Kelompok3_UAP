import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class LocationController extends GetxController {
  Rxn<Position> position = Rxn<Position>();

  @override
  void onInit() {
    super.onInit();
    initLocation();
  }

  Future<void> initLocation() async {
    // Cek izin
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        "Permission",
        "Akses lokasi ditolak permanen. Silakan buka Settings.",
      );
      return;
    }

    // Ambil posisi
    position.value = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
