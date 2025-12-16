import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'controllers/location_network_controller.dart';

class LocationNetworkView extends GetView<LocationNetworkController> {
  const LocationNetworkView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network Location')),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final center =
                  controller.currentLatLng.value ??
                  const LatLng(-7.9825, 112.6304);

              return FlutterMap(
                mapController: controller.mapController,
                options: MapOptions(initialCenter: center, initialZoom: 15),
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
                  Obx(() {
                    final pos = controller.currentLatLng.value;
                    if (pos == null) return const MarkerLayer(markers: []);
                    return MarkerLayer(
                      markers: [
                        Marker(
                          point: pos,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            size: 38,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              );
            }),
          ),
          _NetworkInfoPanel(controller: controller),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.fetchNetworkLocation,
        icon: const Icon(Icons.wifi_tethering),
        label: const Text('Ambil Lokasi'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _NetworkInfoPanel extends StatelessWidget {
  final LocationNetworkController controller;

  const _NetworkInfoPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pos = controller.currentLatLng.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              offset: Offset(0, -1),
              color: Colors.black26,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Lat: ${pos?.latitude.toStringAsFixed(6) ?? '-'}'),
            Text('Lng: ${pos?.longitude.toStringAsFixed(6) ?? '-'}'),
            Text('Akurasi: ${controller.accuracy.value.toStringAsFixed(1)} m'),
            Text('Terakhir update: ${controller.formattedTime}'),
            if (controller.errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      );
    });
  }
}
