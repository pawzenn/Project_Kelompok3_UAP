import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/routes/app_routes.dart';

class NotificationRouter {
  /// Panggil ini kalau kamu sudah punya type + refId
  static void go({
    required String type,
    String? refId,
  }) {
    final t = type.trim().toLowerCase();

    if (t == 'order' && (refId ?? '').trim().isNotEmpty) {
      Get.toNamed(
        AppRoutes.orderDetail,
        arguments: {'id': refId},
      );
      return;
    }

    if (t == 'promo') {
      Get.toNamed(AppRoutes.promo);
      return;
    }

    // default fallback
    Get.snackbar(
      'Notifikasi',
      'Notifikasi dibuka',
      snackPosition: SnackPosition.TOP,
    );
  }

  /// Panggil ini dari FCM onMessageOpenedApp / getInitialMessage
  /// data WAJIB dari FCM (message.data)
  static void handleFCMData(Map<String, dynamic> data) {
    debugPrint('➡️ handleFCMData data=$data');

    final type = (data['type'] ?? data['notif_type'] ?? '').toString();
    debugPrint('➡️ parsed type=$type');
    final refId =
        (data['refId'] ?? data['ref_id'] ?? data['order_id'] ?? '').toString();

    if (type.trim().isEmpty) {
      Get.snackbar(
        'Notifikasi',
        'Data notifikasi tidak valid (type kosong)',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    go(type: type, refId: refId);
  }

  /// Panggil ini dari local notification click callback (payload string)
  /// payload bisa bentuk:
  /// 1) JSON string: {"type":"order","refId":"123"}
  /// 2) Map.toString() (yang kamu pakai sekarang) -> kita coba parse best-effort
  static void handlePayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      Get.snackbar('Notifikasi', 'Payload kosong',
          snackPosition: SnackPosition.TOP);
      return;
    }

    // 1) coba parse JSON dulu
    final jsonMap = _tryParseJson(payload);
    if (jsonMap != null) {
      handleFCMData(jsonMap);
      return;
    }

    // 2) fallback parse Map.toString(): {type: order, refId: 123}
    final mapString = _tryParseMapToString(payload);
    if (mapString != null) {
      handleFCMData(mapString);
      return;
    }

    Get.snackbar(
      'Notifikasi',
      'Payload tidak bisa diparse',
      snackPosition: SnackPosition.TOP,
    );
  }

  static Map<String, dynamic>? _tryParseJson(String s) {
    try {
      final decoded = jsonDecode(s);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return decoded.cast<String, dynamic>();
      return null;
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic>? _tryParseMapToString(String s) {
    // contoh: {type: order, refId: 123, foo: bar}
    final trimmed = s.trim();
    if (!trimmed.startsWith('{') || !trimmed.endsWith('}')) return null;

    final inner = trimmed.substring(1, trimmed.length - 1).trim();
    if (inner.isEmpty) return null;

    final result = <String, dynamic>{};

    // split by comma, best-effort
    final parts = inner.split(',');
    for (final raw in parts) {
      final p = raw.trim();
      final idx = p.indexOf(':');
      if (idx <= 0) continue;

      final k = p.substring(0, idx).trim();
      final v = p.substring(idx + 1).trim();

      if (k.isEmpty) continue;
      result[k] = v;
    }

    return result.isEmpty ? null : result;
  }
}
