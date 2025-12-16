import 'package:flutter_application_1/core/supabase/supabase_service.dart';

class CartRemoteProvider {
  final SupabaseService supabaseService;

  CartRemoteProvider({required this.supabaseService});

  Future<void> upsertCartItem({
    required String userId,
    required String productId,
    required int quantity,
  }) {
    return supabaseService.upsertCartItem(
      userId: userId,
      productId: productId,
      quantity: quantity,
    );
  }

  Future<List<Map<String, dynamic>>> getCartItems(String userId) {
    return supabaseService.getCartItems(userId);
  }

  Future<void> deleteCartItem({
    required String userId,
    required String productId,
  }) {
    return supabaseService.deleteCartItem(userId: userId, productId: productId);
  }

  Future<void> clearCart(String userId) {
    return supabaseService.clearCart(userId);
  }
}
