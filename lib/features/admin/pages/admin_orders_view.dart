import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/admin_orders_controller.dart';
import 'admin_order_detail_view.dart';

class AdminOrdersView extends GetView<AdminOrdersController> {
  const AdminOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        title: const Text(
          'Pesanan Masuk',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            onPressed: controller.fetchOrders, // ✅ manual refresh
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFFE6F06A)),
            ),
          );
        }

        final list = controller.filteredOrders;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _Tab(
                    label: 'Diterima',
                    active: controller.tabIndex.value == 0,
                    onTap: () => controller.setTab(0),
                  ),
                  _Tab(
                    label: 'Diproses',
                    active: controller.tabIndex.value == 1,
                    onTap: () => controller.setTab(1),
                  ),
                  _Tab(
                    label: 'Siap',
                    active: controller.tabIndex.value == 2,
                    onTap: () => controller.setTab(2),
                  ),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada pesanan',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final o = list[i];
                        final status = (o['status'] ?? 'received').toString();

                        return GestureDetector(
                          onTap: () async {
                            final result = await Get.dialog<bool>(
                              const AdminOrderDetailView(),
                              arguments: o['id'],
                              barrierColor: Colors.black.withOpacity(0.65),
                            );

                            // ✅ kalau dialog ditutup, refresh list biar pasti update
                            if (result == true) {
                              await controller.fetchOrders();
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22590A),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order ID',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                                Text(
                                  o['id'].toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFE6F06A),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  controller.statusLabel(status),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Rp${o['total']}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: controller.canAdvance(status)
                                          ? () => controller.advanceStatus(o)
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            controller.canAdvance(status)
                                                ? const Color(0xFFE6F06A)
                                                : Colors.white24,
                                        foregroundColor:
                                            const Color(0xFF1C4A0B),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: Text(
                                        controller.canAdvance(status)
                                            ? 'Ubah Status'
                                            : 'Selesai',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 42,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFE6F06A) : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? const Color(0xFF1C4A0B) : Colors.white70,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
