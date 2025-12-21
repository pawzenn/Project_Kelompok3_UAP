import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'notification_router.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Permission iOS bisa kamu handle di FCMService (requestPermission),
    // jadi di sini boleh false (aman).
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) {
        debugPrint('🔔 notif clicked payload=${resp.payload}');
        // ✅ Routing dari payload local notif
        NotificationRouter.handlePayload(resp.payload);
      },
    );
  }

  static Future<void> showFromFCM(RemoteMessage m) async {
    final title =
        m.notification?.title ?? (m.data['title']?.toString() ?? 'Notifikasi');
    final body = m.notification?.body ?? (m.data['body']?.toString() ?? '');

    // ✅ payload dibikin JSON (stabil)
    final payload = jsonEncode({
      'type': (m.data['type'] ?? m.data['notif_type'] ?? 'general').toString(),
      'refId': (m.data['refId'] ?? m.data['ref_id'] ?? m.data['order_id'] ?? '')
          .toString(),
      'title': title,
      'body': body,
    });

    final androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default',
      channelDescription: 'Notifikasi umum',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      // ✅ android notif sound harus dari res/raw (tanpa ekstensi)
      sound: const RawResourceAndroidNotificationSound('bang_aje'),
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
      // ✅ iOS notif sound harus ada di Runner bundle
      sound: 'bang_aje.mp3',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }
}
