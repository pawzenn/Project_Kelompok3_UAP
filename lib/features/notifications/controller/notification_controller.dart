import 'dart:async';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class NotificationController extends GetxController {
  final _db = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;

  final RxList<Map<String, dynamic>> notifications =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  StreamSubscription<DatabaseEvent>? _sub;

  String? get _uid => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    _startListening();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  void _startListening() {
    final uid = _uid;
    if (uid == null) {
      error.value = 'User belum login';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;

    final ref = _db.child('notifications/$uid');

    _sub = ref.onValue.listen((event) {
      final snap = event.snapshot;
      final List<Map<String, dynamic>> temp = [];

      if (snap.exists && snap.value is Map) {
        final map = Map<String, dynamic>.from(snap.value as Map);

        map.forEach((key, value) {
          final v = Map<String, dynamic>.from(value);
          v['id'] = key; // simpan pushId
          temp.add(v);
        });

        // urutkan terbaru di atas
        temp.sort((a, b) {
          final ta = (a['created_at'] ?? 0) as int;
          final tb = (b['created_at'] ?? 0) as int;
          return tb.compareTo(ta);
        });
      }

      notifications.assignAll(temp);
      isLoading.value = false;
    }, onError: (e) {
      error.value = e.toString();
      isLoading.value = false;
    });
  }

  Future<void> markAsRead(String notifId) async {
    final uid = _uid;
    if (uid == null) return;

    await _db.child('notifications/$uid/$notifId').update({'read': true});
  }

  Future<void> markAllAsRead() async {
    final uid = _uid;
    if (uid == null) return;

    final updates = <String, dynamic>{};
    for (final n in notifications) {
      if (n['read'] != true) {
        updates['${n['id']}/read'] = true;
      }
    }

    if (updates.isNotEmpty) {
      await _db.child('notifications/$uid').update(updates);
    }
  }
}
