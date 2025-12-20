import 'product.dart';

class CartItem {
  final Product product;
  final int qty;

  const CartItem({
    required this.product,
    required this.qty,
  });

  CartItem copyWith({int? qty}) => CartItem(
        product: product,
        qty: qty ?? this.qty,
      );

  int get subtotal => product.price * qty;
}
