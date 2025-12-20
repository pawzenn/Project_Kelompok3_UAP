import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/api_service.dart';

class OrdersController extends GetxController {
  final _client = Supabase.instance.client;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // List<Map> biar cepat, nanti kalau mau rapihin bisa jadi model Order
  final RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Prefer server API using Firebase token
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final list = await ApiService.fetchOrders();
          orders.assignAll(list);
          return;
        }
      } catch (e) {
        // continue to fallback
        print('ApiService fetch failed: $e');
      }

      // Fallback: query Supabase client directly (older behavior)
      final res = await _client
          .from('orders')
          .select('id, total, created_at')
          .order('created_at', ascending: false);

      orders.assignAll((res as List).cast<Map<String, dynamic>>());
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
