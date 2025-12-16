import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'cart_controller.dart';
import 'cart_history_view.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Keranjang"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Get.to(() => const CartHistoryView()),
          ),
        ],
      ),

      // ============================
      // ISI HALAMAN
      // ============================
      body: Obx(() {
        if (controller.items.isEmpty) {
          return const Center(
            child: Text(
              "Keranjang masih kosong",
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return Column(
          children: [
            // ============================================
            // LIST PRODUK DALAM KERANJANG
            // ============================================
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: controller.items.length,
                itemBuilder: (context, index) {
                  final item = controller.items[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // GAMBAR PRODUK
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: item.product.imageUrl != null
                              ? Image.network(
                                  item.product.imageUrl!,
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.fastfood, size: 48),
                        ),

                        const SizedBox(width: 12),

                        // NAMA + HARGA
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Rp ${item.product.price.toStringAsFixed(0)}",
                              ),
                            ],
                          ),
                        ),

                        // TOMBOL MIN
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => controller.removeOne(item.product),
                        ),

                        // QTY
                        Text(
                          item.quantity.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // TOMBOL PLUS
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => controller.addProduct(item.product),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ============================================
            // TOTAL & CHECKOUT BUTTON
            // ============================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // TOTAL
                  Obx(() {
                    return Text(
                      "Total: Rp ${controller.cartTotal.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }),

                  // BUTTON CHECKOUT
                  ElevatedButton(
                    onPressed: () async {
                      await controller.checkout();
                      Get.snackbar(
                        "Sukses",
                        "Pesanan berhasil dibuat.",
                        snackPosition: SnackPosition.TOP,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("Checkout"),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
