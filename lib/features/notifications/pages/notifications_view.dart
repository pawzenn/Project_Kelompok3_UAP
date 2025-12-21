import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/notification_controller.dart';
import '/core/notification/notification_router.dart';

class NotificationsView extends GetView<NotificationController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        title: const Text('Notifikasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: controller.markAllAsRead,
            tooltip: 'Tandai semua dibaca',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF22590A)),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Text(
              controller.error.value,
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada notifikasi',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: controller.notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final n = controller.notifications[i];

            final title = (n['title'] ?? 'Notifikasi').toString();
            final body = (n['body'] ?? '').toString();
            final read = n['read'] == true;
            final type = (n['type'] ?? '').toString();
            final data = Map<String, dynamic>.from(n['data'] ?? {});
            final id = n['id'] as String;

            return InkWell(
              onTap: () {
                controller.markAsRead(id);
                NotificationRouter.handleFCMData({
                  'type': type,
                  ...data,
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: read
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFF22590A).withOpacity(0.75),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      read
                          ? Icons.notifications_none
                          : Icons.notifications_active,
                      color: read ? Colors.white38 : const Color(0xFFE6F06A),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  read ? FontWeight.w600 : FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            body,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
