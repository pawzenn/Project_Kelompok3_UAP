import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../controller/tracking_controller.dart';
import '/core/config/resto_location.dart';

class TrackingMapView extends GetView<TrackingController> {
  const TrackingMapView({super.key});

  static const _bgGreen = Color(0xFF22590A);
  static const _lime = Color(0xFFE6F06A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGreen.withOpacity(0.70),
      appBar: AppBar(
        backgroundColor: _bgGreen.withOpacity(0.70),
        elevation: 0,
        title: const Text('Status Pesanan'),
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
            Obx(() => _OrderHeader(order: controller.order)),
            const SizedBox(height: 18),

            // MAP (tidak diubah)
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

                  // Route polyline
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: points,
                        strokeWidth: 5,
                        color: _lime,
                      ),
                    ],
                  ),

                  // Markers
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: u,
                        width: 44,
                        height: 44,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 34,
                        ),
                      ),
                      Marker(
                        point: r,
                        width: 44,
                        height: 44,
                        child: const Icon(
                          Icons.store,
                          color: Colors.red,
                          size: 36,
                        ),
                      ),
                    ],
                  ),

                  // Loading overlay
                  Obx(() {
                    if (!controller.isLoadingRoute.value) {
                      return const SizedBox.shrink();
                    }
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

  static const _bgGreen = Color(0xFF22590A);
  static const _lime = Color(0xFFE6F06A);

  String _mapStatusLabel(String raw) {
    final s = raw.toLowerCase().trim();

    if (s == 'received') return 'Pesanan masuk';
    if (s == 'processing') return 'Pesanan diproses';
    if (s == 'ready') return 'Pesanan selesai';

    // fallback jika kosong / nilai lain
    if (s.isEmpty) return '-';
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final orderId = (order['id'] ?? '').toString();
    final rawStatus = (order['status'] ?? '').toString();
    final statusLabel = _mapStatusLabel(rawStatus);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bgGreen.withOpacity(0.70),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID Pesanan: ${orderId.isEmpty ? '-' : orderId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Status: $statusLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _lime,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
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
