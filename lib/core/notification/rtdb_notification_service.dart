import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class RTDBNotificationService {
  static final _db = FirebaseDatabase.instance.ref();
  static final _auth = FirebaseAuth.instance;

  static String? _uid() => _auth.currentUser?.uid;

  static Future<void> saveToken(String token) async {
    final uid = _uid();
    if (uid == null) {
      debugPrint('⚠️ saveToken skip: user belum login');
      return;
    }
    await _db.child('user_tokens/$uid').set({
      'fcm': token,
      'updated_at': ServerValue.timestamp,
    });
  }

  static Future<void> saveFromFCM(RemoteMessage m) async {
    final uid = _uid();
    if (uid == null) {
      debugPrint('⚠️ saveFromFCM skip: user belum login');
      return;
    }

    final title =
        m.notification?.title ?? (m.data['title']?.toString() ?? 'Notifikasi');
    final body = m.notification?.body ?? (m.data['body']?.toString() ?? '');
    final type = m.data['type']?.toString() ?? 'general';

    final push = _db.child('notifications/$uid').push();
    await push.set({
      'title': title,
      'body': body,
      'type': type,
      'data': m.data,
      'created_at': ServerValue.timestamp,
      'read': false,
    });
  }
}
