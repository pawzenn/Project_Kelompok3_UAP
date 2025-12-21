import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '/core/config/resto_location.dart';
import '/services/location/location_service.dart';

class TrackingController extends GetxController {
  final RxInt statusIndex = 0.obs; // 0 diterima, 1 proses, 2 siap diambil

  // args dari checkout
  final RxMap<String, dynamic> order = <String, dynamic>{}.obs;

  final Rx<LatLng?> userLatLng = Rx<LatLng?>(null);
  final Rx<LatLng?> restoLatLng = Rx<LatLng?>(null);

  final RxList<LatLng> routePoints = <LatLng>[].obs;

  final RxBool isLoadingRoute = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();

    final args = (Get.arguments as Map<String, dynamic>?) ?? {};
    final ord = (args['order'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    order.assignAll(ord);

    final userLat = (args['userLat'] as num?)?.toDouble() ?? 0.0;
    final userLng = (args['userLng'] as num?)?.toDouble() ?? 0.0;
    userLatLng.value = LatLng(userLat, userLng);

    // resto bisa dari order (jika ada), fallback ke konstanta
    final rLat =
        (ord['restaurant_lat'] as num?)?.toDouble() ?? RestoLocation.lat;
    final rLng =
        (ord['restaurant_lng'] as num?)?.toDouble() ?? RestoLocation.lng;
    restoLatLng.value = LatLng(rLat, rLng);

    // status bisa dari order (jika ada), fallback diterima
    statusIndex.value = _parseStatusToIndex(ord['status']);

    loadRoute();
  }

  int _parseStatusToIndex(dynamic status) {
    final s = (status ?? '').toString().toLowerCase().trim();

    if (s.contains('ready') || s.contains('siap')) return 2;
    if (s.contains('process') || s.contains('proses')) return 1;
    if (s.contains('receive') || s.contains('diterima')) return 0;

    return 0;
  }

  Future<void> loadRoute() async {
    final u = userLatLng.value;
    final r = restoLatLng.value;
    if (u == null || r == null) return;

    isLoadingRoute.value = true;
    error.value = '';

    try {
      final pts = await LocationService.fetchRouteOSRM(from: u, to: r);
      routePoints.assignAll(pts.isNotEmpty ? pts : [u, r]);
    } catch (e) {
      routePoints.assignAll([u, r]);
      error.value = 'Gagal mengambil rute, menampilkan garis lurus.';
    } finally {
      isLoadingRoute.value = false;
    }
  }

  void setStatus(int i) {
    if (i < 0) i = 0;
    if (i > 2) i = 2;
    statusIndex.value = i;
  }
}
