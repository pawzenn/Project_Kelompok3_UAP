import 'package:get/get.dart';
import '../../core/supabase/supabase_service.dart';
import '../../data/models/cart_line.dart';
import '../../data/models/product.dart';

class CartController extends GetxController {
  final supabase = SupabaseService.instance;

  // ==========================
  // CART ITEMS
  // ==========================
  var items = <CartLine>[].obs;

  // ==========================
  // ORDER HISTORY
  // ==========================
  var orderHistory = <Map<String, dynamic>>[].obs;
  var isLoadingHistory = false.obs;
  var historyError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCartFromSupabase();
  }

  // ======================================================
  // LOAD CART DARI SUPABASE (JOIN KE TABLE PRODUCTS)
  // ======================================================
  Future<void> loadCartFromSupabase() async {
    final user = supabase.currentUser;
    if (user == null) return;

    final data = await supabase.client
        .from('cart_items')
        .select('product_id, quantity, products(*)')
        .eq('user_id', user.id);

    items.value = data.map<CartLine>((row) {
      final p = row['products'];

      final product = Product(
        id: p['id'],
        name: p['name'],
        price: (p['price'] as num).toDouble(),
        imageUrl: p['image_url'],
        category: p['category'],
        description: p['description'],
      );

      return CartLine(product: product, quantity: row['quantity']);
    }).toList();
  }

  // ======================================================
  // LOAD ORDER HISTORY DARI SUPABASE
  // ======================================================
  Future<void> loadOrderHistory() async {
    try {
      isLoadingHistory.value = true;
      historyError.value = '';

      final user = supabase.currentUser;
      if (user == null) return;

      final data = await supabase.getOrders(user.id);

      orderHistory.value = data;
    } catch (e) {
      historyError.value = 'Gagal memuat riwayat.';
    } finally {
      isLoadingHistory.value = false;
    }
  }

  // ======================================================
  // ADD PRODUCT (LOCAL + SUPABASE)
  // ======================================================
  Future<void> addProduct(Product product) async {
    final user = supabase.currentUser;
    if (user == null) return;

    final index = items.indexWhere((e) => e.product.id == product.id);

    if (index == -1) {
      items.add(CartLine(product: product, quantity: 1));
      await supabase.upsertCartItem(
        userId: user.id,
        productId: product.id,
        quantity: 1,
      );
    } else {
      items[index].quantity++;
      await supabase.upsertCartItem(
        userId: user.id,
        productId: product.id,
        quantity: items[index].quantity,
      );
    }

    items.refresh();
  }

  // ======================================================
  // REMOVE ONE
  // ======================================================
  Future<void> removeOne(Product product) async {
    final user = supabase.currentUser;
    if (user == null) return;

    final index = items.indexWhere((e) => e.product.id == product.id);

    if (index == -1) return;

    if (items[index].quantity > 1) {
      items[index].quantity--;
      await supabase.upsertCartItem(
        userId: user.id,
        productId: product.id,
        quantity: items[index].quantity,
      );
    } else {
      items.removeAt(index);
      await supabase.deleteCartItem(userId: user.id, productId: product.id);
    }

    items.refresh();
  }

  // ======================================================
  // TOTAL
  // ======================================================
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  double get cartTotal =>
      items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  // ======================================================
  // CHECKOUT
  // ======================================================
  Future<void> checkout() async {
    final user = supabase.currentUser;
    if (user == null) return;

    if (items.isEmpty) return;

    final orderId = await supabase.createOrder(
      userId: user.id,
      total: cartTotal,
    );

    await supabase.insertOrderItems(
      orderId: orderId,
      items: items.map((e) {
        return {
          'product_id': e.product.id,
          'quantity': e.quantity,
          'price': e.product.price,
        };
      }).toList(),
    );

    await supabase.clearCart(user.id);

    items.clear();
  }
}
