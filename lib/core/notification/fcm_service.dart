import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'local_notification_service.dart';
import 'rtdb_notification_service.dart';
import 'notification_router.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> init({
    void Function(String token)? onToken,
  }) async {
    // 1) permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('🔔 FCM Permission: ${settings.authorizationStatus}');

    // iOS: banner + sound di foreground
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2) ketika notif masuk saat app sedang terbuka (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage m) async {
      debugPrint('📩 onMessage: ${m.messageId} data=${m.data}');

      // tampilkan notif local (banner + suara)
      await LocalNotificationService.showFromFCM(m);

      // simpan ke RTDB untuk riwayat
      await RTDBNotificationService.saveFromFCM(m);
    });

    // 3) ketika user klik notif dan app kebuka dari background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage m) async {
      debugPrint('📬 onMessageOpenedApp: ${m.messageId} data=${m.data}');
      // ✅ routing klik notif dari FCM
      NotificationRouter.handleFCMData(m.data);
    });

    // 4) ketika app dibuka dari kondisi terminate karena notif diklik
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      debugPrint(
          '🚀 getInitialMessage: ${initial.messageId} data=${initial.data}');
      NotificationRouter.handleFCMData(initial.data);
    }

    // 5) token refresh
    _messaging.onTokenRefresh.listen((t) async {
      debugPrint('🔁 FCM token refresh: $t');
      onToken?.call(t);
      await RTDBNotificationService.saveToken(t);
    });

    // 6) ambil token SAFELY (APNs di iOS bisa delay)
    final token = await _getTokenSafelyWithRetry();
    if (token != null && token.isNotEmpty) {
      debugPrint('🔥 FCM TOKEN: $token');
      onToken?.call(token);
      await RTDBNotificationService.saveToken(token);
    } else {
      debugPrint('⚠️ FCM token masih null (APNs belum siap / iOS belum benar)');
    }
  }

  /// iOS butuh APNs token dulu. Jadi kita retry beberapa kali.
  static Future<String?> _getTokenSafelyWithRetry() async {
    const maxTry = 8;
    for (var i = 1; i <= maxTry; i++) {
      try {
        final apns = await _messaging.getAPNSToken();
        debugPrint('🍎 APNs token try#$i: ${apns == null ? "null" : "OK"}');

        final token = await _messaging.getToken();
        if (token != null && token.isNotEmpty) return token;
      } catch (e) {
        debugPrint('❌ getToken try#$i error: $e');
      }
      await Future.delayed(Duration(milliseconds: 600 * i));
    }
    return null;
  }
}
