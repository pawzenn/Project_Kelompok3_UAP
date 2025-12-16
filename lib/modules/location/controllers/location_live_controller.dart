import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

import '../../location/location_service.dart';

class LocationLiveController extends GetxController {
  final LocationService _service = LocationService.instance;

  final mapController = MapController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isTracking = false.obs;
  final isGpsMode =
      false.obs; // false = Network, true = GPS (sesuai tugas Eksperimen 3)

  final currentLatLng = Rx<LatLng?>(null);
  final accuracy = 0.0.obs;
  final lastUpdate = Rx<DateTime?>(null);

  StreamSubscription? _sub;

  String get formattedTime {
    final t = lastUpdate.value;
    if (t == null) return '-';
    return DateFormat('HH:mm:ss').format(t);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  Future<void> toggleTracking() async {
    if (isTracking.value) {
      // stop
      await _sub?.cancel();
      _sub = null;
      isTracking.value = false;
      return;
    }

    // start
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final useGps = isGpsMode.value;
      final stream = _service.getPositionStream(useGps: useGps);

      _sub = stream.listen((pos) {
        final latLng = LatLng(pos.latitude, pos.longitude);
        currentLatLng.value = latLng;
        accuracy.value = pos.accuracy;
        lastUpdate.value = DateTime.now();

        // pusatkan peta, pakai zoom saat ini dari kamera
        final currentZoom = mapController.camera.zoom;
        mapController.move(latLng, currentZoom);
      });

      isTracking.value = true;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getOnce() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final pos = await _service.getCurrentPosition(useGps: isGpsMode.value);
      final latLng = LatLng(pos.latitude, pos.longitude);
      currentLatLng.value = latLng;
      accuracy.value = pos.accuracy;
      lastUpdate.value = DateTime.now();

      // pertama kali, zoom boleh fixed misalnya 16
      mapController.move(latLng, 16);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
