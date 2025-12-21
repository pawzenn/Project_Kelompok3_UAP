import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../controller/order_detail_controller.dart';

class OrderDetailView extends GetView<OrderDetailController> {
  const OrderDetailView({super.key});

  // ✅ Color Scheme
  static const Color _bgGreen = Color(0xFF144100);
  static const Color _cardGreen = Color(0xFF22590A);
  static const Color _gold =
      Color(0xFFD4941B); // Orange gold seperti di screenshot
  static const Color _darkCard = Color(0xFF1A3008);

  String _mapStatus(String raw) {
    final s = raw.toLowerCase().trim();
    if (s == 'received') return 'Pesanan Masuk';
    if (s == 'processing') return 'Sedang Diproses';
    if (s == 'ready') return 'Siap Diambil';
    if (s == 'delivered') return 'Selesai';
    if (s.isEmpty) return '-';
    return raw;
  }

  String _shortId(String id) {
    if (id.isEmpty) return '-';
    if (id.length > 16) {
      return '${id.substring(0, 8)}...${id.substring(id.length - 4)}';
    }
    return id;
  }

  @override
  Widget build(BuildContext context) {
    final initialId = (controller.order['id'] ?? '').toString();

    return Scaffold(
      backgroundColor: _bgGreen,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(_gold),
            ),
          );
        }

        final order = controller.order;
        final id = (order['id'] ?? '').toString();
        final total = (order['total'] ?? 0).toString();
        final createdAt = (order['created_at'] ?? '').toString();
        final rawStatus = (order['status'] ?? '').toString();
        final rawStatusLower = rawStatus.toLowerCase().trim();
        final displayStatus = _mapStatus(rawStatus);

        return CustomScrollView(
          slivers: [
            // ✅ Sticky Header dengan gradient
            SliverAppBar(
              backgroundColor: Colors.transparent,
              expandedHeight: 200,
              pinned: true,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon:
                      const Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.5),
                        _bgGreen,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                      child: _buildHeaderContent(
                          id, total, createdAt, displayStatus),
                    ),
                  ),
                ),
              ),
            ),

            // ✅ Content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Map Tracking Section
                  if (rawStatusLower == 'received' ||
                      rawStatusLower == 'processing' ||
                      rawStatusLower == 'ready' ||
                      rawStatusLower == 'delivered')
                    _buildMapTrackingSection(order),

                  const SizedBox(height: 24),

                  // Section Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _gold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.shopping_bag_rounded,
                          color: _gold,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Item Pesanan",
                        style: TextStyle(
                          color: _gold,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Items List
                  if (controller.items.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: _darkCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Center(
                        child: Column(
                          children: [
                            Icon(Icons.inbox_rounded,
                                color: Colors.white24, size: 48),
                            SizedBox(height: 12),
                            Text(
                              "Tidak ada detail item",
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...controller.items.map((it) {
                      final product = it['product'] ?? {};
                      return _buildProductItem(it, product);
                    }),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeaderContent(
      String id, String total, String createdAt, String displayStatus) {
    final dateOnly =
        createdAt.contains('T') ? createdAt.split('T')[0] : createdAt;
    final timeOnly =
        createdAt.contains('T') ? createdAt.split('T')[1].substring(0, 5) : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Order ID
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _gold, // Solid gold
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _gold.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFF1C4A0B),
                size: 1,
              ),
              const SizedBox(width: 8),
              Text(
                'Order #${_shortId(id)}',
                style: const TextStyle(
                  color: Color(0xFF1C4A0B),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Total & Status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Total
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${_formatPrice(total)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _cardGreen,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _gold.withOpacity(0.3)),
              ),
              child: Text(
                displayStatus.toUpperCase(),
                style: const TextStyle(
                  color: _gold,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Date & Time
        Row(
          children: [
            Icon(Icons.access_time_rounded, color: Colors.white54, size: 14),
            const SizedBox(width: 6),
            Text(
              '$dateOnly • $timeOnly',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMapTrackingSection(Map orderData) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: _gold, // Solid gold
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _gold.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(AppRoutes.tracking, arguments: orderData),
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background Pattern
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: CustomPaint(
                      painter: _MapPatternPainter(),
                    ),
                  ),
                ),
              ),

              // Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.map_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Lacak Pengiriman Real-time",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.my_location_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Ketuk untuk membuka peta",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Live Badge
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C4A0B),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Live Tracking",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductItem(Map it, Map product) {
    final name = (product['name'] ?? it['name'] ?? 'Item').toString();
    final qty = (it['qty'] ?? it['quantity'] ?? 1).toString();
    final price = (it['price'] ?? it['unit_price'] ?? 0).toString();
    final imageUrl = product['image_url'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _gold.withOpacity(0.2)),
            ),
            clipBehavior: Clip.antiAlias,
            child: (imageUrl != null && imageUrl.toString().isNotEmpty)
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.fastfood_rounded,
                      color: Colors.white24,
                      size: 32,
                    ),
                  )
                : const Icon(
                    Icons.fastfood_rounded,
                    color: Colors.white38,
                    size: 32,
                  ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _gold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$qty×',
                        style: const TextStyle(
                          color: _gold,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rp ${_formatPrice(price)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(String price) {
    final int? numPrice = int.tryParse(price);
    if (numPrice == null) return price;
    return numPrice.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}

// ✅ Custom Painter untuk background pattern
class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw grid pattern
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
