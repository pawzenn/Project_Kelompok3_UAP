import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/cart_controller.dart';
import '../../../app/routes/app_routes.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    // Aman: kalau controller belum ada, bikin sekali
    final CartController cart = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 5, 82, 6),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 5, 82, 6),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
        ),
        title: const Text(
          'Keranjang',
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
        ),
      ),
      body: Obx(() {
        if (cart.items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_cart_outlined,
                      color: Colors.white38, size: 64),
                  const SizedBox(height: 12),
                  const Text(
                    'Keranjang masih kosong',
                    style: TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE6F06A),
                        foregroundColor: const Color(0xFF22590A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Kembali ke Menu',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                itemCount: cart.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final item = cart.items[i];
                  final p = item.product;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 215, 152, 6),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            p.imageUrl,
                            width: 74,
                            height: 74,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 74,
                              height: 74,
                              color: Colors.black26,
                              child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.white54),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Rp${p.price}  ',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Subtotal Rp${item.subtotal}',
                                style: const TextStyle(
                                  color: Color(0xFFE6F06A),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            // Hapus item
                            InkWell(
                              onTap: () => cart.remove(p.id),
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: const Icon(Icons.delete_outline,
                                    color: Colors.white70, size: 19),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Qty control
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _RoundBtn(
                                  icon: Icons.remove,
                                  onTap: () => cart.decrement(p.id),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${item.qty}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _RoundBtn(
                                  icon: Icons.add,
                                  onTap: () => cart.increment(p.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Footer total + checkout
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              decoration: const BoxDecoration(
                color: Color(0xFF22590A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total (${cart.totalQty} item)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Rp${cart.totalPrice}',
                          style: const TextStyle(
                            color: Color(0xFFE6F06A),
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                    color: Colors.white.withOpacity(0.35)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: cart.clear,
                              child: const Text(
                                'Kosongkan',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE6F06A),
                                foregroundColor: const Color(0xFF22590A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () => Get.toNamed(AppRoutes.checkout),
                              child: const Text(
                                'Checkout',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFE6F06A),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(icon, color: const Color(0xFF22590A), size: 20),
      ),
    );
  }
}
