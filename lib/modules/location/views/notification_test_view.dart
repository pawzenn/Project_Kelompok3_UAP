import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/notification_controller.dart';
import '../../../core/notifications/local_notification_service.dart';
import '../../../routes/app_routes.dart';

class NotificationTestView extends GetView<NotificationController> {
  const NotificationTestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ====== TEST 1: Custom Sound ======
          ListTile(
            leading: const Icon(Icons.music_note),
            title: const Text('Custom Sound'),
            trailing: ElevatedButton(
              onPressed: () async {
                // 1) Tampilkan notifikasi lokal dengan suara custom + klik -> Promo
                await LocalNotificationService.showNotification(
                  title: 'Notifikasi Promo',
                  body: 'notifikasi (klik untuk Promo)',
                  playSound: true,
                  routeOnTap: AppRoutes.promo, // ✅ kunci ke Promo
                  arguments: {
                    'type': 'promo',
                    'from': 'notification_test_custom_sound',
                  },
                );

                // 2) Simpan log ke Firebase
                await controller.logTestNotification(
                  type: 'custom_sound',
                  title: 'Custom Sound',
                  body: 'Suara lalapan aktif 🔔',
                  playSound: true,
                  source: 'tester_page',
                );
              },
              child: const Text('Play'),
            ),
          ),

          const SizedBox(height: 16),

          // ====== TEST 2: Instant Notification (tanpa sound) ======
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Instant Notification'),
            trailing: ElevatedButton(
              onPressed: () async {
                // 1) Notifikasi lokal tanpa suara + klik -> Promo
                await LocalNotificationService.showNotification(
                  title: 'Notifikasi Promo',
                  body: 'Notifikasi  (klik untuk Promo)',
                  playSound: false,
                  routeOnTap: AppRoutes.promo, // ✅ kunci ke Promo
                  arguments: {
                    'type': 'promo',
                    'from': 'notification_test_instant',
                  },
                );

                // 2) Simpan log ke Firebase
                await controller.logTestNotification(
                  type: 'instant',
                  title: 'Instant',
                  body: 'Notifikasi langsung muncul',
                  playSound: false,
                  source: 'tester_page',
                );
              },
              child: const Text('Show'),
            ),
          ),
        ],
      ),
    );
  }
}
