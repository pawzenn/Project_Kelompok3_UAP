import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleTap(response.payload);
      },
    );
  }

  static void _handleTap(String? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final route = data['route'] as String?;
      final args = data['args'];

      if (route != null && route.isNotEmpty) {
        Get.toNamed(route, arguments: args);
      }
    } catch (_) {
      // payload bukan json -> abaikan
    }
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    bool playSound = true,

    /// route tujuan saat notif diklik
    String? routeOnTap,

    /// args untuk page tujuan
    Map<String, dynamic>? arguments,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'lalapan_channel',
      'Lalapan Notification',
      channelDescription: 'Notification for Lalapan App',
      importance: Importance.max,
      priority: Priority.high,
      playSound: playSound,
      sound: playSound
          ? const RawResourceAndroidNotificationSound('bang_ajeyy')
          : null,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final payload = (routeOnTap == null)
        ? null
        : jsonEncode({'route': routeOnTap, 'args': arguments});

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }
}
