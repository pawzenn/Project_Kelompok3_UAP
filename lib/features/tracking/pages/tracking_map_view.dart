import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../controller/tracking_controller.dart';
import '/core/config/resto_location.dart';

// ✅ Color Scheme
const Color _bgGreen = Color(0xFF144100);
const Color _cardGreen = Color(0xFF22590A);
const Color _gold = Color(0xFFD4941B);
const Color _darkCard = Color(0xFF1A3008);
const Color _lime = Color(0xFFE6F06A);

class TrackingMapView extends GetView<TrackingController> {
  const TrackingMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGreen,
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

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              expandedHeight: 120,
              pinned: true,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      _bgGreen,
                    ],
                  ),
                ),
                child: const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 28, 16, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Status Pesanan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Lacak pesanan kamu real-time',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _OrderHeaderNew(order: controller.order),
                  const SizedBox(height: 18),

                  // ✅ Status tiles (READ ONLY)
                  Obx(() => _StatusTileNew(
                        title: 'Pesanan Diterima',
                        subtitle: 'Pesanan kamu sudah masuk ke resto',
                        icon: Icons.receipt_long_rounded,
                        done: controller.statusIndex.value >= 0,
                        active: controller.statusIndex.value == 0,
                        onTap: null, // ✅ disable
                      )),
                  Obx(() => _StatusTileNew(
                        title: 'Sedang Diproses',
                        subtitle: 'Chef sedang membuatkan pesananmu',
                        icon: Icons.restaurant_rounded,
                        done: controller.statusIndex.value >= 1,
                        active: controller.statusIndex.value == 1,
                        onTap: null, // ✅ disable
                      )),
                  Obx(() => _StatusTileNew(
                        title: 'Siap Diambil',
                        subtitle: 'Pesanan siap untuk diambil/diantar',
                        icon: Icons.check_circle_rounded,
                        done: controller.statusIndex.value >= 2,
                        active: controller.statusIndex.value == 2,
                        onTap: null, // ✅ disable
                      )),

                  const SizedBox(height: 18),

                  // ✅ MAP
                  Container(
                    height: 360,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        FlutterMap(
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
                                  strokeWidth: 6,
                                  color: _gold,
                                ),
                              ],
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: u,
                                  width: 50,
                                  height: 50,
                                  child: _MarkerCircle(
                                    color: Colors.blue,
                                    icon: Icons.person,
                                  ),
                                ),
                                Marker(
                                  point: r,
                                  width: 50,
                                  height: 50,
                                  child: _MarkerCircle(
                                    color: Colors.red,
                                    icon: Icons.store,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // ✅ Loading overlay
                        Obx(() {
                          if (!controller.isLoadingRoute.value) {
                            return const SizedBox.shrink();
                          }
                          return Positioned.fill(
                            child: Container(
                              color: Colors.black54,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _cardGreen,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),

                        // ✅ Live badge
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _Dot(),
                                SizedBox(width: 8),
                                Text(
                                  'Live Tracking',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ✅ Error
                  Obx(() {
                    if (controller.error.value.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade800),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade300),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              controller.error.value,
                              style: TextStyle(color: Colors.red.shade100),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // ✅ Route Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _darkCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _gold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _gold.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.route_rounded,
                            color: _gold,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Rute Pengiriman',
                                style: TextStyle(
                                  color: _gold,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Lokasi kamu → ${RestoLocation.name}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ====================== WIDGETS ======================

class _OrderHeaderNew extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderHeaderNew({required this.order});

  @override
  Widget build(BuildContext context) {
    final orderId = (order['id'] ?? '').toString();
    final shortId = orderId.length > 20
        ? '${orderId.substring(0, 8)}...${orderId.substring(orderId.length - 6)}'
        : orderId;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _gold,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _gold.withValues(alpha: 0.38),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1C4A0B),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: _lime,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order ID',
                  style: TextStyle(
                    color: Color(0xFF1C4A0B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '#$shortId',
                  style: const TextStyle(
                    color: Color(0xFF1C4A0B),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTileNew extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool done;
  final bool active;
  final VoidCallback? onTap; // ✅ nullable

  const _StatusTileNew({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.done,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = active ? _gold : _darkCard;
    final Color borderColor =
        active ? _lime : Colors.white.withValues(alpha: 0.10);

    // ✅ kalau onTap null, tile tidak interaktif
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: active ? 2 : 1),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _lime.withValues(alpha: 0.30),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: active ? 0.28 : 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                done ? Icons.check_circle : icon,
                color: active ? Colors.white : Colors.white70,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 1),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color:
                          Colors.white.withValues(alpha: active ? 0.80 : 0.65),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (active)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.28),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MarkerCircle extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _MarkerCircle({
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
    );
  }
}
