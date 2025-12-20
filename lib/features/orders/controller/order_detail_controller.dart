import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderDetailController extends GetxController {
  final Map<String, dynamic> order;
  OrderDetailController({required this.order});

  final _client = Supabase.instance.client;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final orderId = order['id']?.toString() ?? '';
      if (orderId.isEmpty) {
        errorMessage.value = 'Order ID tidak tersedia.';
        return;
      }

      // Attempt to fetch order items and join product data if available
      final res = await _client
          .from('order_items')
          .select('*, product:products(*)')
          .eq('order_id', orderId);

      items.assignAll((res as List).cast<Map<String, dynamic>>());
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
