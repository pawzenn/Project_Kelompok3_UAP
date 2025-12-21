import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiService {
  ApiService._();

  /// Base URL server (Railway)
  static const String _baseUrl =
      'https://projectkelompok3uap-production.up.railway.app';

  static Future<String?> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    // refresh token biar aman kalau token lama expired
    return await user.getIdToken(true);
  }

  static Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// GET /api/orders
  /// Server balikin: { "orders": [ ... ] }
  static Future<List<Map<String, dynamic>>> fetchOrders() async {
    final token = await _getIdToken();
    if (token == null) throw Exception('User not logged in');

    final resp = await http.get(
      Uri.parse('$_baseUrl/api/orders'),
      headers: _headers(token),
    );

    if (resp.statusCode != 200) {
      throw Exception(
          'Failed to fetch orders: ${resp.statusCode} ${resp.body}');
    }

    final decoded = jsonDecode(resp.body);

    // antisipasi kalau server kadang balikin List langsung
    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    }

    if (decoded is Map<String, dynamic>) {
      final orders = decoded['orders'];
      if (orders is List) {
        return orders.cast<Map<String, dynamic>>();
      }
      return <Map<String, dynamic>>[];
    }

    throw Exception('Unexpected response format: ${resp.body}');
  }

  /// POST /api/orders
  /// Minimal server kamu butuh: { address: "...", items: [...] }
  /// (total/note/payment_method boleh kamu kirim, tapi server kamu saat ini nggak pakai)
  static Future<Map<String, dynamic>> createOrder({
    required String address,
    required List<Map<String, dynamic>> items,
    int? total,
    String? note,
    String? paymentMethod,
  }) async {
    final token = await _getIdToken();
    if (token == null) throw Exception('User not logged in');

    final payload = <String, dynamic>{
      'address': address,
      'items': items,
      if (total != null) 'total': total,
      if (note != null) 'note': note,
      if (paymentMethod != null) 'payment_method': paymentMethod,
    };

    final resp = await http.post(
      Uri.parse('$_baseUrl/api/orders'),
      headers: _headers(token),
      body: jsonEncode(payload),
    );

    if (resp.statusCode != 200) {
      throw Exception(
          'Failed to create order: ${resp.statusCode} ${resp.body}');
    }

    final decoded = jsonDecode(resp.body);
    if (decoded is Map<String, dynamic>) return decoded;

    throw Exception('Unexpected response format: ${resp.body}');
  }
}
