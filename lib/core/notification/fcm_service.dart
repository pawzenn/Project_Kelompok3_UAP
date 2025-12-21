import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';

class FcmService {
  static final _fcm = FirebaseMessaging.instance;
  static final _db = FirebaseDatabase.instance;

  static Future<void> init(String uid) async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _fcm.getToken();
    if (token == null) return;

    await _db.ref('users/$uid/devices/$token').set({
      'platform': Platform.isIOS ? 'ios' : 'android',
      'updated_at': ServerValue.timestamp,
    });
  }
}
