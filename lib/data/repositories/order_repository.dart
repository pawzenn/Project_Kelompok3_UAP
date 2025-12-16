import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_application_1/data/providers/order_remote_provider.dart';
import 'package:flutter_application_1/data/repositories/cart_repository.dart';

class OrderRepository {
  final OrderRemoteProvider orderRemoteProvider;
  final CartRepository cartRepository;

  OrderRepository({
    required this.orderRemoteProvider,
    required this.cartRepository,
  });

  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// items: List<Map<String, dynamic>> dengan minimal:
  /// { 'product_id': String, 'quantity': int, 'price': double }
  Future<void> checkout({
    required String userId,
    required List<Map<String, dynamic>> items,
  }) async {
    if (!await _isOnline()) {
      throw OfflineException('Checkout hanya bisa dilakukan saat online');
    }

    if (items.isEmpty) {
      throw Exception('Keranjang masih kosong');
    }

    // hitung total
    final total = items.fold<double>(
      0,
      (sum, item) =>
          sum + (item['price'] as double) * (item['quantity'] as int),
    );

    // 1. buat order header
    final orderId = await orderRemoteProvider.createOrder(
      userId: userId,
      total: total,
    );

    // 2. buat detail order_items
    await orderRemoteProvider.insertOrderItems(orderId: orderId, items: items);

    // 3. kosongkan keranjang user
    await cartRepository.clearCart(userId);
  }
}
