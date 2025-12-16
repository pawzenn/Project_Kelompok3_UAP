import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/notification_controller.dart';

class NotificationHistoryView extends GetView<NotificationController> {
  const NotificationHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Notifikasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshLogs,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingHistory.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.history.isEmpty) {
          return const Center(
            child: Text('Belum ada notifikasi yang tersimpan.'),
          );
        }

        return ListView.builder(
          itemCount: controller.history.length,
          itemBuilder: (context, index) {
            final item = controller.history[index];

            final String title = item['title'] ?? '';
            final String body = item['body'] ?? '';
            final bool playSound = item['playSound'] == true;
            final String type = item['type'] ?? '-';
            final int? ts = item['createdAt'] as int?;
            final DateTime? dt = ts != null
                ? DateTime.fromMillisecondsSinceEpoch(ts)
                : null;
            final String time = dt != null
                ? DateFormat('dd/MM HH:mm:ss').format(dt)
                : '-';

            return ListTile(
              leading: Icon(playSound ? Icons.music_note : Icons.notifications),
              title: Text(title),
              subtitle: Text('$body\n$type • $time'),
              isThreeLine: true,
            );
          },
        );
      }),
    );
  }
}
