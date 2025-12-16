import 'package:firebase_database/firebase_database.dart';

class NotificationRepository {
  NotificationRepository._();

  /// Singleton
  static final NotificationRepository instance = NotificationRepository._();

  /// Referensi ke node "notifications"
  final DatabaseReference _ref = FirebaseDatabase.instance.ref('Notification');

  /// Simpan 1 log notifikasi ke Realtime Database
  Future<void> logNotification({
    required String type,
    required String title,
    required String body,
    required bool playSound,
    required String source,
  }) async {
    await _ref.push().set({
      'type': type,
      'title': title,
      'body': body,
      'playSound': playSound,
      'source': source,
      // Timestamp server (ms sejak epoch)
      'createdAt': ServerValue.timestamp,
    });
  }

  /// Ambil daftar riwayat notifikasi (max 100 terakhir)
  Future<List<Map<String, dynamic>>> fetchHistory() async {
    final snapshot = await _ref
        .orderByChild('createdAt')
        .limitToLast(100)
        .get();

    final List<Map<String, dynamic>> result = [];

    for (final child in snapshot.children) {
      final value = child.value;
      if (value is Map) {
        final map = Map<String, dynamic>.from(value);
        // simpan juga id dokumennya (key node)
        map['id'] = child.key;
        result.add(map);
      }
    }

    // urutkan terbaru di atas
    result.sort((a, b) {
      final aTs = (a['createdAt'] ?? 0) as int;
      final bTs = (b['createdAt'] ?? 0) as int;
      return bTs.compareTo(aTs);
    });

    return result;
  }
}
