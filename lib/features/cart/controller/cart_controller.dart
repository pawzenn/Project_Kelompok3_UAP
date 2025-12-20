import 'package:get/get.dart';
import '/data/models/cart_item.dart';
import '/data/models/product.dart'; // sesuaikan path Product

class CartController extends GetxController {
  // Key = product.id
  final RxMap<String, CartItem> _items = <String, CartItem>{}.obs;

  List<CartItem> get items => _items.values.toList();

  int get totalQty => _items.values.fold(0, (sum, item) => sum + item.qty);

  int get totalPrice =>
      _items.values.fold(0, (sum, item) => sum + item.subtotal);

  void add(Product p, {int qty = 1}) {
    if (qty <= 0) return;

    try {
      // Debug log - konfirmasi pemanggilan add
      // Akan muncul di console saat tombol ditekan
      print('Cart.add called: ${p.name} (id=${p.id}) qty=$qty');

      final existing = _items[p.id];
      if (existing == null) {
        _items[p.id] = CartItem(product: p, qty: qty);
      } else {
        _items[p.id] = existing.copyWith(qty: existing.qty + qty);
      }
    } catch (e, st) {
      print('Cart.add error: $e\n$st');
      rethrow;
    }
  }

  void increment(String productId) {
    final item = _items[productId];
    if (item == null) return;
    _items[productId] = item.copyWith(qty: item.qty + 1);
  }

  void decrement(String productId) {
    final item = _items[productId];
    if (item == null) return;

    final newQty = item.qty - 1;
    if (newQty <= 0) {
      _items.remove(productId);
    } else {
      _items[productId] = item.copyWith(qty: newQty);
    }
  }

  void remove(String productId) => _items.remove(productId);

  void clear() => _items.clear();
}
