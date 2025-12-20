import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/data/models/product.dart';
import '../../cart/controller/cart_controller.dart'; // ✅ SESUAIKAN PATH DI PROJECTMU
import '../../../app/routes/app_routes.dart';

class MenuDetailSheet extends StatefulWidget {
  final Product product;
  const MenuDetailSheet({super.key, required this.product});

  @override
  State<MenuDetailSheet> createState() => _MenuDetailSheetState();
}

class _MenuDetailSheetState extends State<MenuDetailSheet> {
  int qty = 1;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    // ✅ ambil cart controller yang global
    final cart = Get.find<CartController>();

    return Stack(
      children: [
        // BLUR layer supaya daftar menu tetap keliatan
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.black.withOpacity(0.10)),
          ),
        ),

        // SHEET CONTENT
        DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF22590A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // HERO
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            height: 220,
                            width: double.infinity,
                            child: Image.network(
                              'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1400&q=80',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          top: 12,
                          child: IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Foto bulat
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 18,
                            color: Colors.black.withOpacity(0.35),
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(p.imageUrl, fit: BoxFit.cover),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Card detail
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB78B2A).withOpacity(0.55),
                        borderRadius: BorderRadius.circular(26),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.10)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            p.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            p.area ?? 'Deskripsi belum tersedia.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 15,
                              height: 1.55,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Qty control
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _QtyButton(
                                icon: Icons.remove,
                                onTap: () {
                                  if (qty > 1) setState(() => qty--);
                                },
                              ),
                              const SizedBox(width: 18),
                              Container(
                                width: 70,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              const SizedBox(width: 18),
                              _QtyButton(
                                icon: Icons.add,
                                onTap: () => setState(() => qty++),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // ✅ Add to cart (SUDAH BENER)
                          SizedBox(
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
                              onPressed: () {
                                // ✅ ini inti yang sebelumnya belum ada
                                cart.add(p, qty: qty);

                                Get.snackbar(
                                  'Keranjang',
                                  'Berhasil menambahkan ${p.name} x$qty',
                                  snackPosition: SnackPosition.BOTTOM,
                                );

                                // tutup sheet
                                Get.back();

                                // kembali ke halaman daftar menu otomatis (bersihkan stack)
                                Get.offAllNamed(AppRoutes.home);

                                // (opsional) kalau mau langsung buka cart, uncomment:
                                // Get.toNamed(AppRoutes.cart);
                              },
                              child: Text(
                                'Tambah ke Keranjang • Rp${p.price} x$qty',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),
                  ],
                ),
              ),
            );
          },
        ),
      ],
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
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFFE6F06A),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(icon, color: Colors.black, size: 28),
      ),
    );
  }
}
