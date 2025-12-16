import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  late final SupabaseClient client;

  Future<void> init() async {
    await dotenv.load(fileName: ".env");

    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || anonKey == null) {
      throw Exception(
        'SUPABASE_URL atau SUPABASE_ANON_KEY belum diset di .env',
      );
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
    client = Supabase.instance.client;
  }

  // ========== AUTH SEDERHANA (opsional) ==========
  Future<AuthResponse> signUp(String email, String password) {
    return client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? get currentUser => client.auth.currentUser;

  // ========== CART ==========

  Future<void> upsertCartItem({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    await client.from('cart_items').upsert({
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
    });
  }

  Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    final result = await client
        .from('cart_items')
        .select()
        .eq('user_id', userId);

    return List<Map<String, dynamic>>.from(result);
  }

  Future<void> deleteCartItem({
    required String userId,
    required String productId,
  }) async {
    await client
        .from('cart_items')
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }

  Future<void> clearCart(String userId) async {
    await client.from('cart_items').delete().eq('user_id', userId);
  }

  // ========== ORDER ==========

  Future<String> createOrder({
    required String userId,
    required double total,
  }) async {
    final result = await client
        .from('orders')
        .insert({'user_id': userId, 'total_amount': total})
        .select('id')
        .single();

    return result['id'] as String;
  }

  Future<List<Map<String, dynamic>>> getOrders(String userId) async {
    final result = await client
        .from('orders')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(result);
  }

  Future<void> insertOrderItems({
    required String orderId,
    required List<Map<String, dynamic>> items,
  }) async {
    final payload = items
        .map(
          (item) => {
            'order_id': orderId,
            'product_id': item['product_id'],
            'quantity': item['quantity'],
            'price': item['price'],
          },
        )
        .toList();

    await client.from('order_items').insert(payload);
  }
}
