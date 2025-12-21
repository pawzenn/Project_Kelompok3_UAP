import 'package:get/get.dart';
import '../../../services/supabase/supabase_service.dart';

class AdminOrdersController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  /// 0 = received, 1 = processing, 2 = ready
  final RxInt tabIndex = 0.obs;

  final RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  // ======================
  // FETCH ORDERS
  // ======================
  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      error.value = '';

      final res = await SupabaseService.instance.client
          .from('orders')
          .select('id, total, status, created_at');

      orders.assignAll(List<Map<String, dynamic>>.from(res));
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ======================
  // STATUS HELPERS
  // ======================
  int statusToIndex(String status) {
    switch (status) {
      case 'processing':
        return 1;
      case 'ready':
        return 2;
      default:
        return 0;
    }
  }

  String indexToStatus(int index) {
    if (index == 1) return 'processing';
    if (index == 2) return 'ready';
    return 'received';
  }

  String statusLabel(String status) {
    if (status == 'processing') return 'Pesanan Diproses';
    if (status == 'ready') return 'Siap Diambil';
    return 'Pesanan Diterima';
  }

  bool canAdvance(String status) => status != 'ready';

  // ======================
  // FILTER BY TAB
  // ======================
  List<Map<String, dynamic>> get filteredOrders {
    return orders
        .where((o) => statusToIndex(o['status']) == tabIndex.value)
        .toList();
  }

  void setTab(int i) => tabIndex.value = i;

  // ======================
  // UPDATE STATUS
  // ======================
  Future<void> advanceStatus(Map<String, dynamic> order) async {
    final currentStatus = order['status'] as String;
    if (currentStatus == 'ready') return;

    final nextStatus = indexToStatus(statusToIndex(currentStatus) + 1);

    try {
      // optimistic update
      _updateLocal(order['id'], nextStatus);

      await SupabaseService.instance.client
          .from('orders')
          .update({'status': nextStatus}).eq('id', order['id']);

      Get.snackbar(
        'Status',
        'Pesanan diubah ke ${statusLabel(nextStatus)}',
      );
    } catch (e) {
      await fetchOrders(); // rollback
      Get.snackbar('Gagal', e.toString());
    }
  }

  void _updateLocal(String id, String status) {
    final idx = orders.indexWhere((o) => o['id'] == id);
    if (idx == -1) return;

    final updated = Map<String, dynamic>.from(orders[idx]);
    updated['status'] = status;
    orders[idx] = updated;
  }
}
