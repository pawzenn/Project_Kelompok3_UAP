import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class NotificationMenuView extends StatelessWidget {
  const NotificationMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Menu')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Riwayat Notifikasi'),
            onTap: () => Get.toNamed(AppRoutes.notificationHistory),
          ),
          ListTile(
            leading: const Icon(Icons.science),
            title: const Text('Test Notifikasi'),
            onTap: () => Get.toNamed(AppRoutes.notificationTest),
          ),
        ],
      ),
    );
  }
}
