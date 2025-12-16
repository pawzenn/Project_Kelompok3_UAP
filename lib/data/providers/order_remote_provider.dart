import 'package:flutter_application_1/core/supabase/supabase_service.dart';

class OrderRemoteProvider {
  final SupabaseService supabaseService;

  OrderRemoteProvider({required this.supabaseService});

  Future<String> createOrder({required String userId, required double total}) {
    return supabaseService.createOrder(userId: userId, total: total);
  }

  Future<void> insertOrderItems({
    required String orderId,
    required List<Map<String, dynamic>> items,
  }) {
    return supabaseService.insertOrderItems(orderId: orderId, items: items);
  }
}
