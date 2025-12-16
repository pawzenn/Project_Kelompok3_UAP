import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/notification_controller.dart';
import '../../../core/notifications/local_notification_service.dart';
import '../../../routes/app_routes.dart';

class NotificationDebugView extends GetView<NotificationController> {
  const NotificationDebugView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Debug'),
        actions: [
          IconButton(
            tooltip: 'Refresh Token',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // kalau controller kamu punya method refresh token, pakai ini
              // kalau belum ada, aman dihapus
              try {
                controller.refreshToken();
              } catch (_) {}
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FCM Token',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Token tampil realtime
            Obx(() {
              final token = controller.token.value;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Text(
                  token.isEmpty ? '(token belum ada)' : token,
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }),

            const SizedBox(height: 10),

            // Button copy token
            Align(
              alignment: Alignment.centerRight,
              child: Obx(() {
                final token = controller.token.value;
                return TextButton.icon(
                  onPressed: token.isEmpty
                      ? null
                      : () async {
                          await Clipboard.setData(ClipboardData(text: token));
                          Get.snackbar(
                            'Copied',
                            'FCM token berhasil di-copy',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy Token'),
                );
              }),
            ),

            const SizedBox(height: 20),

            // Test Local Notification -> Promo
            ElevatedButton.icon(
              onPressed: () {
                LocalNotificationService.showNotification(
                  title: 'Test Lalapan',
                  body: 'Custom sound aktif 🌶️ (klik untuk ke Promo)',
                  routeOnTap: AppRoutes.promo,
                  arguments: {
                    'type': 'promo',
                    'from': 'debug_button',
                    'time': DateTime.now().toIso8601String(),
                  },
                );
              },
              icon: const Icon(Icons.notifications_active),
              label: const Text('Test Local Notification → Promo'),
            ),

            const SizedBox(height: 12),

            // Test Local Notification -> History
            OutlinedButton.icon(
              onPressed: () {
                LocalNotificationService.showNotification(
                  title: 'Riwayat Notifikasi',
                  body: 'Klik untuk buka halaman riwayat',
                  routeOnTap: AppRoutes.notificationHistory,
                  arguments: {
                    'type': 'history',
                    'from': 'debug_button',
                    'time': DateTime.now().toIso8601String(),
                  },
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('Test Local Notification → History'),
            ),

            const SizedBox(height: 12),

            // Buka halaman promo langsung (tanpa notif)
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.promo),
              child: const Text('Buka Promo Page (tanpa notif)'),
            ),
          ],
        ),
      ),
    );
  }
}
