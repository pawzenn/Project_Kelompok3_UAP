import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/menu_controller.dart';
import '../../../app/routes/app_routes.dart';
import '../../cart/controller/cart_controller.dart';
import '/data/models/product.dart';

class MenuDetailView extends StatelessWidget {
  const MenuDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MenuDetailController());

    // ambil data dari arguments (kamu kirim dari home/menu)
    final p = Get.arguments;

    // ====== sesuaikan getter ini dengan model kamu ======
    final String name = (p?.name ?? p?['name'] ?? 'Menu').toString();
    final String imageUrl =
        (p?.imageUrl ?? p?['imageUrl'] ?? p?['strMealThumb'] ?? '').toString();
    final desc = p.description ?? 'Deskripsi belum tersedia.';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          Positioned.fill(
            child: imageUrl.isEmpty
                ? Container(color: Colors.black)
                : Image.network(imageUrl, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.35)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  _CircleIcon(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Get.back(),
                  ),
                  const Spacer(),
                  _CircleIcon(
                    icon: Icons.shopping_cart_outlined,
                    onTap: () {
                      // Prepare product object (support both Product or Map args)
                      final args = Get.arguments;
                      final Product product = args is Product
                          ? args
                          : Product(
                              id: (args?['id'] ?? '').toString(),
                              name: (args?.name ?? args?['name'] ?? name)
                                  .toString(),
                              imageUrl: imageUrl,
                              price: int.tryParse(
                                      (args?['price'] ?? '0').toString()) ??
                                  0,
                              description: desc,
                            );

                      final cart = Get.find<CartController>();
                      cart.add(product, qty: 1);

                      Get.snackbar(
                        'Keranjang',
                        'Berhasil menambahkan ${product.name} x1',
                        snackPosition: SnackPosition.BOTTOM,
                      );

                      // Kembali ke halaman daftar menu
                      Get.offAllNamed(AppRoutes.home);
                    },
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 18,
                          spreadRadius: 1,
                          color: Colors.black.withOpacity(0.35),
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 2,
                      ),
                      image: imageUrl.isEmpty
                          ? null
                          : DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                      color: imageUrl.isEmpty ? Colors.white10 : null,
                    ),
                    child: imageUrl.isEmpty
                        ? const Icon(Icons.fastfood,
                            color: Colors.white70, size: 44)
                        : null,
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F06A).withOpacity(0.33),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              desc,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Obx(() {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _QtyButton(
                                    icon: Icons.remove_rounded,
                                    onTap: c.dec,
                                  ),
                                  const SizedBox(width: 14),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.25),
                                      ),
                                    ),
                                    child: Text(
                                      '${c.qty.value}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  _QtyButton(
                                    icon: Icons.add_rounded,
                                    onTap: c.inc,
                                  ),
                                ],
                              );
                            }),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF22590A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  Get.snackbar(
                                    'Keranjang',
                                    'Tambah $name (qty: ${c.qty.value})',
                                  );
                                },
                                child: const Text(
                                  'Tambah ke Keranjang',
                                  style: TextStyle(
                                    color: Color(0xFFE6F06A),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFE6F06A),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF22590A), size: 26),
      ),
    );
  }
}
