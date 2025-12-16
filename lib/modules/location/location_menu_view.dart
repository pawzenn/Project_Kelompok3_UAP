import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class LocationMenuView extends StatelessWidget {
  const LocationMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Fitur Lokasi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Pilih fitur lokasi untuk eksplorasi Modul 5:',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _LocationMenuCard(
            title: 'Live Location (Real-Time)',
            subtitle:
                'Lacak posisi secara langsung.\nDipakai untuk eksperimen dinamis (bergerak).',
            icon: Icons.my_location,
            iconColor: colorScheme.primary,
            onTap: () => Get.toNamed(AppRoutes.locationLive),
          ),
          const SizedBox(height: 12),

          _LocationMenuCard(
            title: 'Network Location',
            subtitle:
                'Lokasi berbasis jaringan/Wi-Fi.\nBandingkan indoor vs outdoor.',
            icon: Icons.wifi_tethering,
            iconColor: Colors.blueAccent,
            onTap: () => Get.toNamed(AppRoutes.locationNetwork),
          ),
          const SizedBox(height: 12),

          _LocationMenuCard(
            title: 'GPS Location',
            subtitle:
                'Lokasi berbasis GPS.\nBandingkan akurasi dengan Network.',
            icon: Icons.gps_fixed,
            iconColor: Colors.green,
            onTap: () => Get.toNamed(AppRoutes.locationGps),
          ),
        ],
      ),
    );
  }
}

class _LocationMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _LocationMenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: colorScheme.surfaceVariant.withOpacity(0.8),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
