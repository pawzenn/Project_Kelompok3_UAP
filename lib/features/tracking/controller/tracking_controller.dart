import 'dart:async';

import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  StreamSubscription<List<Map<String, dynamic>>>? _orderSub;

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

    // status dari order (jika ada), fallback diterima
    statusIndex.value = _parseStatusToIndex(ord['status']);

    // ✅ TAMBAHAN: sinkron status dari Supabase berdasarkan order.id
    _startSyncStatusFromSupabase();

    loadRoute();
  }

  @override
  void onClose() {
    _orderSub?.cancel();
    super.onClose();
  }

  int _parseStatusToIndex(dynamic status) {
    final s = (status ?? '').toString().toLowerCase().trim();

    if (s.contains('ready') || s.contains('siap')) return 2;
    if (s.contains('process') || s.contains('proses')) return 1;
    if (s.contains('receive') || s.contains('diterima')) return 0;

    return 0;
  }

  // =========================================================
  // ✅ SUPABASE STATUS SYNC (FETCH + REALTIME)
  // =========================================================
  String _pickOrderId(Map<String, dynamic> o) {
    final v = o['id'] ?? o['order_id'] ?? o['orderId'] ?? o['orderID'];
    final s = (v ?? '').toString().trim();
    return s;
  }

  Future<void> _startSyncStatusFromSupabase() async {
    final orderId = _pickOrderId(order);
    if (orderId.isEmpty) return;

    // 1) Fetch sekali biar status langsung terisi
    await _fetchLatestStatus(orderId);

    // 2) Subscribe realtime biar auto update
    _orderSub?.cancel();
    _orderSub = Supabase.instance.client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .listen((rows) {
          if (rows.isEmpty) return;
          final row = rows.first;

          final newStatus = (row['status'] ?? '').toString();

          // update order map + refresh biar UI Obx langsung berubah
          order['status'] = newStatus;
          order.refresh();

          // update step index juga (kalau kamu masih pakai statusIndex di tempat lain)
          statusIndex.value = _parseStatusToIndex(newStatus);
        }, onError: (e) {
          // tidak ganggu UI, hanya catat error ringan
          // print('Realtime status error: $e');
        });
  }

  Future<void> _fetchLatestStatus(String orderId) async {
    try {
      final row = await Supabase.instance.client
          .from('orders')
          .select('status')
          .eq('id', orderId)
          .maybeSingle();

      if (row == null) return;

      final newStatus = (row['status'] ?? '').toString();
      if (newStatus.isEmpty) return;

      order['status'] = newStatus;
      order.refresh();

      statusIndex.value = _parseStatusToIndex(newStatus);
    } catch (e) {
      // print('Fetch status error: $e');
    }
  }

  // =========================================================

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
