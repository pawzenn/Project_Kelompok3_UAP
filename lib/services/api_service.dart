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
    return await user.getIdToken(true); // refresh token
  }

  static Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static dynamic _decodeBody(http.Response resp) {
    try {
      return jsonDecode(resp.body);
    } catch (_) {
      return resp.body;
    }
  }

  static Exception _httpError(http.Response resp, String message) {
    return Exception('$message: ${resp.statusCode} ${resp.body}');
  }

  // =========================================================
  // USER - ORDERS
  // =========================================================

  /// GET /api/orders
  /// Server balikin: { "orders": [ ... ] } atau List langsung
  static Future<List<Map<String, dynamic>>> fetchOrders() async {
    final token = await _getIdToken();
    if (token == null) throw Exception('User not logged in');

    final resp = await http.get(
      Uri.parse('$_baseUrl/api/orders'),
      headers: _headers(token),
    );

    if (resp.statusCode != 200) {
      throw _httpError(resp, 'Failed to fetch orders');
    }

    final decoded = _decodeBody(resp);

    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    }

    if (decoded is Map<String, dynamic>) {
      final orders = decoded['orders'];
      if (orders is List) return orders.cast<Map<String, dynamic>>();
      return <Map<String, dynamic>>[];
    }

    throw Exception('Unexpected response format: ${resp.body}');
  }

  /// POST /api/orders
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
      throw _httpError(resp, 'Failed to create order');
    }

    final decoded = _decodeBody(resp);

    if (decoded is Map<String, dynamic>) return decoded;

    throw Exception('Unexpected response format: ${resp.body}');
  }

  // =========================================================
  // ADMIN - ORDERS
  // =========================================================

  /// GET /api/admin/orders
  /// opsional query: ?status=received|processing|ready
  static Future<List<Map<String, dynamic>>> fetchAdminOrders({
    String? status,
  }) async {
    final token = await _getIdToken();
    if (token == null) throw Exception('User not logged in');

    final uri = Uri.parse('$_baseUrl/api/admin/orders').replace(
      queryParameters: {
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      },
    );

    final resp = await http.get(uri, headers: _headers(token));

    if (resp.statusCode != 200) {
      throw _httpError(resp, 'Failed to fetch admin orders');
    }

    final decoded = _decodeBody(resp);

    if (decoded is List) {
      return decoded.cast<Map<String, dynamic>>();
    }

    if (decoded is Map<String, dynamic>) {
      final orders = decoded['orders'];
      if (orders is List) return orders.cast<Map<String, dynamic>>();
      return <Map<String, dynamic>>[];
    }

    throw Exception('Unexpected response format: ${resp.body}');
  }

  /// PATCH /api/admin/orders/:id/status
  /// payload: { "status": "received" | "processing" | "ready" }
  static Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final token = await _getIdToken();
    if (token == null) throw Exception('User not logged in');

    final payload = {'status': status};

    final resp = await http.patch(
      Uri.parse('$_baseUrl/api/admin/orders/$orderId/status'),
      headers: _headers(token),
      body: jsonEncode(payload),
    );

    if (resp.statusCode != 200) {
      throw _httpError(resp, 'Failed to update order status');
    }

    final decoded = _decodeBody(resp);
    if (decoded is Map<String, dynamic>) return decoded;

    throw Exception('Unexpected response format: ${resp.body}');
  }

  /// GET /api/admin/orders/:id
  /// dipakai untuk admin_order_detail_view
  static Future<Map<String, dynamic>> fetchAdminOrderDetail({
    required String orderId,
  }) async {
    final token = await _getIdToken();
    if (token == null) throw Exception('User not logged in');

    final resp = await http.get(
      Uri.parse('$_baseUrl/api/admin/orders/$orderId'),
      headers: _headers(token),
    );

    if (resp.statusCode != 200) {
      throw _httpError(resp, 'Failed to fetch order detail');
    }

    final decoded = _decodeBody(resp);
    if (decoded is Map<String, dynamic>) return decoded;

    throw Exception('Unexpected response format: ${resp.body}');
  }
}
