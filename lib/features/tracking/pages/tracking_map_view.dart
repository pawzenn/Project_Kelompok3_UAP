import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../controller/tracking_controller.dart';
import '/core/config/resto_location.dart';

class TrackingMapView extends GetView<TrackingController> {
  const TrackingMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text('Status Pesanan'),
      ),
      body: Obx(() {
        final u = controller.userLatLng.value;
        final r = controller.restoLatLng.value;

        if (u == null || r == null) {
          return const Center(
            child: Text('Data lokasi belum siap',
                style: TextStyle(color: Colors.white70)),
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
            Obx(() => _StatusTile(
                  title: 'Pesanan diterima',
                  subtitle: 'Pesanan kamu sudah masuk ke resto',
                  done: controller.statusIndex.value >= 0,
                  active: controller.statusIndex.value == 0,
                  onTap: () => controller.setStatus(0),
                )),
            Obx(() => _StatusTile(
                  title: 'Proses',
                  subtitle: 'Pesanan sedang diproses',
                  done: controller.statusIndex.value >= 1,
                  active: controller.statusIndex.value == 1,
                  onTap: () => controller.setStatus(1),
                )),
            Obx(() => _StatusTile(
                  title: 'Siap diambil',
                  subtitle: 'Pesanan siap untuk diambil/diantar',
                  done: controller.statusIndex.value >= 2,
                  active: controller.statusIndex.value == 2,
                  onTap: () => controller.setStatus(2),
                )),
            const SizedBox(height: 18),
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

                  // Loading overlay
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

  @override
  Widget build(BuildContext context) {
    final orderId = (order['id'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF22590A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Order #$orderId',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;
  final bool active;
  final VoidCallback onTap;

  const _StatusTile({
    required this.title,
    required this.subtitle,
    required this.done,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = active ? const Color(0xFF22590A) : const Color(0xFF2A2A2A);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              color: done ? const Color(0xFFE7FF7A) : Colors.white38,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
