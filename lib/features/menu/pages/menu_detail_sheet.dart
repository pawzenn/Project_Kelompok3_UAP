import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/data/models/product.dart';
import '../../cart/controller/cart_controller.dart';

class MenuDetailSheet extends StatefulWidget {
  final Product product;
  const MenuDetailSheet({super.key, required this.product});

  @override
  State<MenuDetailSheet> createState() => _MenuDetailSheetState();
}

class _MenuDetailSheetState extends State<MenuDetailSheet>
    with SingleTickerProviderStateMixin {
  int qty = 1;
  bool _isProcessing = false; // ✅ Flag untuk prevent double tap

  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 600), // ✅ Lebih smooth (dari 420ms)
    );

    _fade = CurvedAnimation(
      parent: _anim,
      curve: Curves.easeInOut, // ✅ Lebih smooth
    );
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _anim,
        curve: Curves.easeOutCubic, // ✅ Lebih smooth
      ),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _anim,
      curve: Curves.easeOutCubic, // ✅ Lebih smooth
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _anim.forward();
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _closeFast() async {
    if (!mounted) return;

    // ✅ Animate reverse untuk smooth closing
    await _anim.reverse();

    if (!mounted) return;

    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _addToCart() async {
    // ✅ Prevent double tap
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    final p = widget.product;
    final cart = Get.find<CartController>();

    try {
      // Tambahkan ke cart
      cart.add(p, qty: qty);

      // ✅ Animate reverse untuk smooth closing
      await _anim.reverse();

      // Tutup bottom sheet
      if (!mounted) return;

      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      } else if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Tunggu sebentar untuk memastikan sheet tertutup
      await Future.delayed(const Duration(milliseconds: 200));

      // Tampilkan snackbar
      if (Get.context != null) {
        Get.snackbar(
          'Keranjang',
          'Berhasil menambahkan ${p.name} x$qty',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF22590A),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');
    } finally {
      // Reset flag setelah selesai
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    final w = MediaQuery.of(context).size.width;
    final dialogW = (w * 0.88).clamp(320.0, 440.0);
    final imageSize = (dialogW * 0.48).clamp(150.0, 200.0);
    final overlapDown = imageSize * 0.40;
    final imageTop = -(imageSize * 0.48);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(color: Colors.black.withOpacity(0.18)),
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeFast,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: ScaleTransition(
                  scale: _scale,
                  child: GestureDetector(
                    onTap: () {},
                    child: SizedBox(
                      width: dialogW,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(
                              18,
                              16 + overlapDown + (imageSize * 0.28),
                              18,
                              18,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFED9A00).withOpacity(0.45),
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.18)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.26),
                                  blurRadius: 26,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  p.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    height: 1.05,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(
                                    p.area ?? 'Deskripsi belum tersedia.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.95),
                                      fontSize: 14.5,
                                      height: 1.55,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 22),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _QtyButton(
                                      icon: Icons.remove,
                                      onTap: () {
                                        if (qty > 1 && !_isProcessing) {
                                          setState(() => qty--);
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 14),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.22),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.16),
                                        ),
                                      ),
                                      child: Text(
                                        '$qty',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    _QtyButton(
                                      icon: Icons.add,
                                      onTap: () {
                                        if (!_isProcessing) {
                                          setState(() => qty++);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE6F06A),
                                      foregroundColor: const Color(0xFF22590A),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed:
                                        _isProcessing ? null : _addToCart,
                                    child: _isProcessing
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Color(0xFF22590A),
                                              ),
                                            ),
                                          )
                                        : Text(
                                            'Tambah ke Keranjang • Rp${p.price} x$qty',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                              ],
                            ),
                          ),
                          Positioned(
                            top: imageTop,
                            left: (dialogW - imageSize) / 2,
                            child: Container(
                              width: imageSize,
                              height: imageSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 28,
                                    color: Colors.black.withOpacity(0.35),
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.60),
                                  width: 4,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  p.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.white.withOpacity(0.12),
                                    child: const Center(
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        color: Colors.white70,
                                        size: 34,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.18),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.22),
                                ),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: _closeFast,
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
