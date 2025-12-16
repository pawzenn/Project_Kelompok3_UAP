import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'cart_controller.dart';

class CartHistoryView extends StatelessWidget {
  const CartHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();

    // Load history ketika halaman dibuka
    controller.loadOrderHistory();

    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Pesanan")),
      body: Obx(() {
        if (controller.isLoadingHistory.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.historyError.isNotEmpty) {
          return Center(child: Text(controller.historyError.value));
        }

        if (controller.orderHistory.isEmpty) {
          return const Center(
            child: Text(
              "Belum ada riwayat pesanan",
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.orderHistory.length,
          itemBuilder: (context, index) {
            final order = controller.orderHistory[index];
            final createdAt = DateTime.parse(order['created_at']);

            final date =
                "${createdAt.day.toString().padLeft(2, '0')}-"
                "${createdAt.month.toString().padLeft(2, '0')}-"
                "${createdAt.year}";

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, size: 32),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order #${order['id'].toString().substring(0, 8)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text("Tanggal: $date"),
                      ],
                    ),
                  ),

                  Text(
                    "Rp ${(order['total_amount'] as num).toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
