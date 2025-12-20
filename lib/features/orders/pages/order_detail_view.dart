import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/order_detail_controller.dart';

class OrderDetailView extends GetView<OrderDetailController> {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final order = controller.order;
    final id = (order['id'] ?? '').toString();
    final total = (order['total'] ?? 0).toString();
    final createdAt = (order['created_at'] ?? '').toString();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
        ),
        title:
            Text('Order #${id.substring(0, id.length >= 8 ? 8 : id.length)}'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: controller.fetchItems,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF22590A),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(18)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${id.substring(0, id.length >= 8 ? 8 : id.length)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Total: Rp$total',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  Text(
                    createdAt,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: controller.items.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada detail pesanan tersedia',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final it = controller.items[i];
                        final product = it['product'] ?? {};
                        final name = (product['name'] ?? it['name'] ?? 'Item')
                            .toString();
                        final qty =
                            (it['qty'] ?? it['quantity'] ?? 1).toString();
                        final price =
                            (it['price'] ?? it['unit_price'] ?? 0).toString();

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                color: Colors.black26,
                                child: (product['image_url'] != null)
                                    ? Image.network(product['image_url'],
                                        fit: BoxFit.cover)
                                    : const Icon(Icons.fastfood,
                                        color: Colors.white54),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name,
                                        style: const TextStyle(
                                            color: Colors.white)),
                                    const SizedBox(height: 6),
                                    Text('Qty: $qty • Rp$price',
                                        style: const TextStyle(
                                            color: Colors.white70)),
                                  ],
                                ),
                              ),
                            ],
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
