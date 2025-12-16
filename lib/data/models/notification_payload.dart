import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPayload {
  final String type;
  final String? orderId;
  final String? promoId;

  NotificationPayload({required this.type, this.orderId, this.promoId});

  factory NotificationPayload.fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    return NotificationPayload(
      type: data['type'] ?? 'default',
      orderId: data['orderId'],
      promoId: data['promoId'],
    );
  }

  String toJson() =>
      jsonEncode({'type': type, 'orderId': orderId, 'promoId': promoId});
}
