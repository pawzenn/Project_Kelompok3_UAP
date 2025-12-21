import 'dart:async';

import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/core/config/resto_location.dart';
import '/services/location/location_service.dart';

class TrackingController extends GetxController {
  final RxInt statusIndex = 0.obs; // 0 diterima, 1 proses, 2 siap diambil

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

    final raw = Get.arguments;

    // ✅ Terima 2 format:
    // A) {'order': {...}, 'userLat': ..., 'userLng': ...}
    // B) {...orderData langsung...}
    final Map<String, dynamic> args = (raw is Map)
        ? Map<String, dynamic>.from(raw as Map)
        : <String, dynamic>{};

    final Map<String, dynamic> ord;
    if (args.containsKey('order') && args['order'] is Map) {
      ord = Map<String, dynamic>.from(args['order'] as Map);
    } else {
      ord = args;
    }

    order.assignAll(ord);

    double? _numToDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return num.tryParse(v.toString())?.toDouble();
    }

    final userLat = _numToDouble(args['userLat']) ??
        _numToDouble(args['user_lat']) ??
        _numToDouble(ord['userLat']) ??
        _numToDouble(ord['user_lat']) ??
        _numToDouble(ord['lat']) ??
        0.0;

    final userLng = _numToDouble(args['userLng']) ??
        _numToDouble(args['user_lng']) ??
        _numToDouble(ord['userLng']) ??
        _numToDouble(ord['user_lng']) ??
        _numToDouble(ord['lng']) ??
        0.0;

    userLatLng.value = LatLng(userLat, userLng);

    final rLat = _numToDouble(ord['restaurant_lat']) ?? RestoLocation.lat;
    final rLng = _numToDouble(ord['restaurant_lng']) ?? RestoLocation.lng;
    restoLatLng.value = LatLng(rLat, rLng);

    statusIndex.value = _parseStatusToIndex(ord['status']);

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

  String _pickOrderId(Map<String, dynamic> o) {
    final v = o['id'] ?? o['order_id'] ?? o['orderId'] ?? o['orderID'];
    return (v ?? '').toString().trim();
  }

  Future<void> _startSyncStatusFromSupabase() async {
    final orderId = _pickOrderId(order);
    if (orderId.isEmpty) return;

    await _fetchLatestStatus(orderId);

    _orderSub?.cancel();
    _orderSub = Supabase.instance.client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .listen((rows) {
          if (rows.isEmpty) return;
          final row = rows.first;

          final newStatus = (row['status'] ?? '').toString();
          if (newStatus.isEmpty) return;

          order['status'] = newStatus;
          order.refresh();

          statusIndex.value = _parseStatusToIndex(newStatus);
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
    } catch (_) {}
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
