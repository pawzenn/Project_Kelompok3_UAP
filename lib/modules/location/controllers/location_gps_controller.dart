import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

import '../../location/location_service.dart';

class LocationGpsController extends GetxController {
  final LocationService _service = LocationService.instance;

  final mapController = MapController();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final currentLatLng = Rx<LatLng?>(null);
  final accuracy = 0.0.obs;
  final lastUpdate = Rx<DateTime?>(null);

  final altitude = 0.0.obs;
  final speed = 0.0.obs;

  final mapCenter = LatLng(-6.200000, 106.816667).obs;
  final mapZoom = 14.0.obs;

  String get formattedTime {
    final t = lastUpdate.value;
    if (t == null) return '-';
    return DateFormat('HH:mm:ss').format(t);
  }

  Future<void> fetchGpsLocation() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final pos = await _service.getCurrentPosition(useGps: true);
      final latLng = LatLng(pos.latitude, pos.longitude);
      currentLatLng.value = latLng;
      accuracy.value = pos.accuracy;
      lastUpdate.value = DateTime.now();

      mapController.move(latLng, 16);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
