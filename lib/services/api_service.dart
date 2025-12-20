import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// TODO: ganti BASE_URL ke alamat servermu (deployed)
const String _BASE_URL = 'https://api.example.com';

class ApiService {
  ApiService._();

  static Future<String?> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  static Future<List<Map<String, dynamic>>> fetchOrders() async {
    final token = await _getIdToken();
    if (token == null) throw Exception('User not logged in');

    final resp = await http.get(
      Uri.parse('$_BASE_URL/api/orders'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resp.statusCode != 200)
      throw Exception('Failed to fetch orders: ${resp.body}');

    final body = jsonDecode(resp.body) as List;
    return body.cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> createOrder({
    required int total,
    required List<Map<String, dynamic>> items,
    String? address,
    String? note,
    String? paymentMethod,
  }) async {
    final token = await _getIdToken();
    if (token == null) throw Exception('User not logged in');

    final body = {
      'total': total,
      'items': items,
      'address': address,
      'note': note,
      'payment_method': paymentMethod,
    };

    final resp = await http.post(
      Uri.parse('$_BASE_URL/api/orders'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode != 200)
      throw Exception('Failed to create order: ${resp.body}');

    return jsonDecode(resp.body) as Map<String, dynamic>;
  }
}
