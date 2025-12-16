import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../../routes/app_routes.dart';
import '../../data/models/notification_payload.dart';
import 'local_notification_service.dart';
import 'notification_router.dart';

class FcmService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    // Permission (iOS & Android 13+)
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // iOS: agar notif tampil di foreground
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Token
    await _printTokenSafe();

    // ====== TAP dari TERMINATED (app mati lalu notif diklik) ======
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      final payload = NotificationPayload.fromRemoteMessage(initialMessage);
      // kalau router kamu sudah handle promo/history, biarkan router yang jalan
      NotificationRouter.route(payload);
    }

    // ====== FOREGROUND: tampilkan local notif + payload untuk navigasi ======
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final payload = NotificationPayload.fromRemoteMessage(message);

      // ✅ args Map aman: gabung payload model + message.data
      final argsMap = _buildArgs(payload, message);

      LocalNotificationService.showNotification(
        title: message.notification?.title ?? 'Notifikasi',
        body: message.notification?.body ?? '',
        routeOnTap: _routeFromArgs(argsMap), // promo/history
        arguments: argsMap,
      );
    });

    // ====== TAP saat app BACKGROUND ======
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final payload = NotificationPayload.fromRemoteMessage(message);
      NotificationRouter.route(payload);
    });
  }

  // ================= HELPERS =================

  Future<void> _printTokenSafe() async {
    try {
      if (Platform.isIOS) {
        final apns = await _fcm.getAPNSToken();
        if (apns == null) {
          // ignore: avoid_print
          print('APNS token belum ada (simulator sering). Skip getToken.');
          return;
        }
      }

      final token = await _fcm.getToken();
      // ignore: avoid_print
      print("FCM Token: $token");
    } catch (e) {
      // ignore: avoid_print
      print("FCM Token error: $e");
    }
  }

  /// Build Map arguments yang AMAN untuk local notification payload
  /// - payload.toJson() bisa String/Map
  /// - message.data ikut digabung supaya 'type' kebaca
  Map<String, dynamic> _buildArgs(
    NotificationPayload payload,
    RemoteMessage message,
  ) {
    final Map<String, dynamic> args = {};

    // 1) Ambil dari model payload (kalau ada)
    try {
      final dynamic maybe = payload.toJson();
      if (maybe is String) {
        final decoded = jsonDecode(maybe);
        if (decoded is Map) {
          args.addAll(Map<String, dynamic>.from(decoded));
        } else {
          args['raw'] = maybe;
        }
      } else if (maybe is Map) {
        args.addAll(Map<String, dynamic>.from(maybe));
      }
    } catch (_) {
      // ignore, lanjut ambil dari message.data
    }

    // 2) Gabung data dari FCM (paling sering ada type di sini)
    try {
      args.addAll(Map<String, dynamic>.from(message.data));
    } catch (_) {}

    // 3) Pastikan ada type (default history)
    args.putIfAbsent('type', () => 'history');

    return args;
  }

  /// Tentukan route berdasarkan args['type']
  /// type=promo -> /promo
  /// selain itu -> /notification-history
  String _routeFromArgs(Map<String, dynamic> args) {
    final type = (args['type'] ?? '').toString().toLowerCase();
    if (type == 'promo') return AppRoutes.promo;
    return AppRoutes.notificationHistory;
  }

  /// Background handler (jalan di background isolate)
  static Future<void> backgroundHandler(RemoteMessage message) async {
    final payload = NotificationPayload.fromRemoteMessage(message);

    // Navigasi GetX biasanya tidak jalan di sini.
    // Simpan / catat lewat NotificationRouter sesuai implementasi kamu.
    NotificationRouter.route(payload);
  }
}
