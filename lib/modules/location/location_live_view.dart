import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../location/controllers/location_live_controller.dart';

class LocationLiveView extends GetView<LocationLiveController> {
  const LocationLiveView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Live Location')),
      body: SafeArea(
        child: Obx(() {
          final isLoading = controller.isLoading.value;
          final error = controller.errorMessage.value;
          final latLng = controller.currentLatLng.value;
          final acc = controller.accuracy.value;
          final time = controller.formattedTime;
          final tracking = controller.isTracking.value;
          final isGps = controller.isGpsMode.value;

          return Column(
            children: [
              // =======================
              // PETA
              // =======================
              Expanded(
                child: FlutterMap(
                  mapController: controller.mapController,
                  options: MapOptions(
                    initialCenter: latLng ?? const LatLng(0, 0),
                    initialZoom: latLng == null ? 2 : 16,
                  ),

                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c'],
                      // PENTING: Tambahkan subdomains
                      userAgentPackageName: 'com.mobile.modul5',
                      maxZoom: 20.0, // Max zoom OpenTopoMap hanya sampai 17
                      retinaMode:
                          MediaQuery.of(Get.context!).devicePixelRatio > 1.0,
                    ),
                    if (latLng != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: latLng,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.person_pin_circle,
                              color: Colors.purple,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // =======================
              // PANEL BAWAH (INFO + TOMBOL)
              // =======================
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoading) const LinearProgressIndicator(),
                    if (error.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        error,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Baris mode + switch dibuat bisa scroll horizontal
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(
                            isGps ? 'Mode: GPS' : 'Mode: Network',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              const Text('Network'),
                              Switch(
                                value: isGps,
                                onChanged: (v) {
                                  controller.isGpsMode.value = v;
                                },
                              ),
                              const Text('GPS'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text('Lat : ${latLng?.latitude.toStringAsFixed(6) ?? '-'}'),
                    Text(
                      'Lng : ${latLng?.longitude.toStringAsFixed(6) ?? '-'}',
                    ),
                    Text('Akurasi: ${acc.toStringAsFixed(2)} m'),
                    Text('Terakhir update: $time'),

                    const SizedBox(height: 12),

                    // Tombol Start/Stop + Ambil Sekali
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () => controller.toggleTracking(),
                            icon: Icon(
                              tracking
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                            ),
                            label: Text(
                              tracking ? 'Stop Tracking' : 'Start Tracking',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () => controller.getOnce(),
                            icon: const Icon(Icons.my_location),
                            label: const Text('Ambil Sekali'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
