import 'package:get/get.dart';
import '../../../services/api_service.dart';

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
  // FETCH ORDERS (BACKEND)
  // ======================
  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      error.value = '';

      // optional: ambil semua status, lalu difilter oleh tab UI
      // (biar tab switching ga request ulang)
      final res = await ApiService.fetchAdminOrders();
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
        .where((o) =>
            statusToIndex((o['status'] ?? 'received').toString()) ==
            tabIndex.value)
        .toList();
  }

  void setTab(int i) => tabIndex.value = i;

  // ======================
  // UPDATE STATUS (BACKEND)
  // ======================
  Future<void> advanceStatus(Map<String, dynamic> order) async {
    final currentStatus = (order['status'] ?? 'received').toString();
    if (currentStatus == 'ready') return;

    final nextStatus = indexToStatus(statusToIndex(currentStatus) + 1);

    try {
      // optimistic update
      _updateLocal(order['id'].toString(), nextStatus);

      // backend akan validasi transisi + update supabase + kirim notif
      await ApiService.updateOrderStatus(
        orderId: order['id'].toString(),
        status: nextStatus,
      );

      Get.snackbar('Status', 'Pesanan diubah ke ${statusLabel(nextStatus)}');
    } catch (e) {
      await fetchOrders(); // rollback
      Get.snackbar('Gagal', e.toString());
    }
  }

  void _updateLocal(String id, String status) {
    final idx = orders.indexWhere((o) => o['id'].toString() == id);
    if (idx == -1) return;

    final updated = Map<String, dynamic>.from(orders[idx]);
    updated['status'] = status;
    orders[idx] = updated;
  }
}
