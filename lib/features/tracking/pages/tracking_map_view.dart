import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../controller/tracking_controller.dart';
import '/core/config/resto_location.dart';

class TrackingMapView extends GetView<TrackingController> {
  const TrackingMapView({super.key});

  static const _bgGreen = Color(0xFF22590A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGreen.withOpacity(0.70),
      appBar: AppBar(
        backgroundColor: _bgGreen.withOpacity(0.70),
        elevation: 0,
        title: const Text(
          'Status Pesanan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        final u = controller.userLatLng.value;
        final r = controller.restoLatLng.value;

        if (u == null || r == null) {
          return const Center(
            child: Text(
              'Data lokasi belum siap',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final points = controller.routePoints.isNotEmpty
            ? controller.routePoints.toList()
            : <LatLng>[u, r];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _OrderHeader(order: controller.order),
            const SizedBox(height: 14),
            Container(
              height: 340,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: u,
                  initialZoom: 14,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.lalapan',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: points,
                        strokeWidth: 5,
                        color: const Color(0xFFF2FF00),
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: u,
                        width: 44,
                        height: 44,
                        child: const Icon(Icons.my_location,
                            color: Colors.blue, size: 34),
                      ),
                      Marker(
                        point: r,
                        width: 44,
                        height: 44,
                        child: const Icon(Icons.store,
                            color: Colors.red, size: 36),
                      ),
                    ],
                  ),
                  Obx(() {
                    if (!controller.isLoadingRoute.value)
                      return const SizedBox.shrink();
                    return Positioned.fill(
                      child: Container(
                        color: Colors.black26,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (controller.error.value.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  controller.error.value,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                'Rute: Lokasi kamu → ${RestoLocation.name}',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderHeader({required this.order});

  static const _green = Color(0xFF22590A);
  static const _lime = Color(0xFFF2FF00);

  // LOGIKA ID TETAP SAMA (Logika kamu sebelumnya)
  String _pickOrderId(Map<String, dynamic> o) {
    final v = o['id'] ??
        o['order_id'] ??
        o['orders_id'] ??
        o['orderId'] ??
        o['orderID'];
    final s = (v ?? '').toString().trim();
    return s.isEmpty ? '-' : s;
  }

  // LOGIKA STATUS DENGAN MAPPING (Seperti di Order Detail)
  String _pickStatus(Map<String, dynamic> o) {
    final s = (o['status'] ?? '').toString().toLowerCase().trim();

    if (s == 'received') return 'PESANAN DIPROSES';
    if (s == 'processing') return 'SEDANG DISIAPKAN';
    if (s == 'ready') return 'SIAP DIAMBIL';
    if (s == 'dikirim') return 'DALAM PENGIRIMAN';

    return s.isEmpty ? '-' : s.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final orderId = _pickOrderId(order);
    final status = _pickStatus(order);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID Pesanan: $orderId',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Status: $status',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _lime,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
