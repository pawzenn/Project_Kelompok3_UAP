import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/orders_controller.dart';
import '../../../app/routes/app_routes.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  static const _bg = Color(0xFF1A1A1A);
  static const _greenBg = Color(0xFF22590A);
  static const _gold = Color(0xFFED9A00);
  static const _lime = Color(0xFFE6F06A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Riwayat Pesanan',
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w900,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_lime),
            ),
          );
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
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: controller.fetchOrders,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _greenBg,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.orders.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_rounded,
                      size: 64, color: Colors.white.withOpacity(0.25)),
                  const SizedBox(height: 14),
                  const Text(
                    'Belum ada pesanan',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchOrders,
          color: _lime,
          backgroundColor: _greenBg,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            itemCount: controller.orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) {
              final o = controller.orders[i];

              final id = (o['id'] ?? '').toString();
              final createdAt = (o['created_at'] ?? '').toString();
              final statusRaw = (o['status'] ?? '').toString();

              final totalNum = _asNum(o['total']);
              final totalText = _formatRupiah(totalNum);

              // ✅ tanggal format: dd/MMM/yyyy (tanpa jam/ms)
              final dateText = _formatDateShort(createdAt);

              final statusLabel = _mapStatus(statusRaw);

              // ✅ ambil nama & foto dari MENU PERTAMA yang di-checkout
              final firstItem = _extractFirstItem(o);
              final topName = _extractFirstItemNameFromOrder(o);
              final coverUrl = _extractFirstItemImageFromOrder(o);

              final itemsCount = _extractItemsCount(o);

              return _OrderCardCompact(
                idFull: id,
                idShort: _shortId(id),
                dateText: dateText,
                title: topName,
                totalText: totalText,
                itemsCount: itemsCount,
                statusLabel: statusLabel,
                coverUrl: coverUrl,
                onTap: () => Get.toNamed(
                  AppRoutes.orderDetail,
                  arguments: o,
                ),
                onDetail: () => Get.toNamed(
                  AppRoutes.orderDetail,
                  arguments: o,
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

// ===================== CARD =====================

class _OrderCardCompact extends StatelessWidget {
  final String idFull;
  final String idShort;
  final String dateText;
  final String title;
  final String totalText;
  final int? itemsCount;
  final String statusLabel;
  final String? coverUrl;
  final VoidCallback onTap;
  final VoidCallback onDetail;

  const _OrderCardCompact({
    required this.idFull,
    required this.idShort,
    required this.dateText,
    required this.title,
    required this.totalText,
    required this.itemsCount,
    required this.statusLabel,
    required this.coverUrl,
    required this.onTap,
    required this.onDetail,
  });

  static const _greenBg = Color(0xFF22590A);
  static const _gold = Color(0xFFED9A00);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final coverSize = w < 380 ? 78.0 : 88.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        decoration: BoxDecoration(
          color: _greenBg,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Container(
          decoration: BoxDecoration(
            color: _gold.withOpacity(0.62),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'ID PESANAN',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Montserrat',
                                  fontSize: 12,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: Text(
                      dateText,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // ID row + copy
              Row(
                children: [
                  Expanded(
                    child: Text(
                      idShort,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: idFull));
                      Get.snackbar(
                        'Tersalin',
                        'ID pesanan berhasil disalin',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      child: Icon(
                        Icons.copy_rounded,
                        color: Colors.black.withOpacity(0.28),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // CONTENT ROW
              Row(
                children: [
                  _Cover(size: coverSize, coverUrl: coverUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title, // ✅ nama menu pertama checkout
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        height: 1.14,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        totalText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (itemsCount != null)
                        Text(
                          '${itemsCount!} Menu',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.90),
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // FOOTER
              Row(
                children: [
                  Expanded(
                    child: Text(
                      statusLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: onDetail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB87900),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Detail',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 22),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  final double size;
  final String? coverUrl;
  const _Cover({required this.size, required this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: (coverUrl == null || coverUrl!.isEmpty)
            ? Container(
                color: Colors.white.withOpacity(0.10),
                child: const Center(
                  child: Icon(Icons.fastfood_rounded,
                      color: Colors.white70, size: 34),
                ),
              )
            : Image.network(
                coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.white.withOpacity(0.10),
                  child: const Center(
                    child: Icon(Icons.broken_image_outlined,
                        color: Colors.white70, size: 30),
                  ),
                ),
              ),
      ),
    );
  }
}

// ========================= HELPERS =========================

num _asNum(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v;
  return num.tryParse(v.toString()) ?? 0;
}

String _formatRupiah(num v) {
  final f = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  return f.format(v);
}

// ✅ format: 21/Des/2025
String _formatDateShort(String raw) {
  try {
    final dt = DateTime.parse(raw).toLocal();
    return DateFormat('dd/MMM/yyyy', 'id_ID').format(dt);
  } catch (_) {
    return raw.isEmpty ? '-' : raw;
  }
}

String _mapStatus(String raw) {
  final s = raw.trim().toLowerCase();
  if (s == 'processing' || s == 'process' || s == 'diproses') {
    return 'Sedang diproses';
  }
  if (s == 'received' || s == 'success' || s == 'selesai') {
    return 'Pesanan diterima';
  }
  if (s == 'ready' || s == 'done') {
    return 'Pesanan selesai';
  }
  if (raw.isEmpty) return 'Sedang diproses';
  return raw;
}

String _shortId(String id) {
  if (id.isEmpty) return '—';
  final s = id.replaceAll('-', '');
  return s.length <= 10 ? s.toUpperCase() : s.substring(0, 10).toUpperCase();
}

// ✅ ambil item pertama checkout dari data order
Map? _extractFirstItem(Map o) {
  final candidates = [
    o['items'],
    o['order_items'],
    o['items_json'],
    o['orderItems'],
  ];

  for (final c in candidates) {
    if (c is List && c.isNotEmpty) {
      final first = c.first;
      if (first is Map) return first;
    }
  }
  return null;
}

// ✅ extract nama item dari item map (dan nested product)
String? _extractItemName(Map? item) {
  if (item == null) return null;

  final name =
      (item['name'] ?? item['product_name'] ?? item['title'] ?? '').toString();
  if (name.isNotEmpty) return name;

  final prod = item['product'];
  if (prod is Map) {
    final name2 = (prod['name'] ?? prod['product_name'] ?? prod['title'] ?? '')
        .toString();
    if (name2.isNotEmpty) return name2;
  }
  return null;
}

// ✅ extract image item dari item map (dan nested product)
String? _extractItemImage(Map? item) {
  if (item == null) return null;

  final url = (item['imageUrl'] ??
          item['image_url'] ??
          item['product_image'] ??
          item['productImage'] ??
          item['cover'] ??
          item['image'] ??
          '')
      .toString();
  if (url.isNotEmpty) return url;

  final prod = item['product'];
  if (prod is Map) {
    final url2 = (prod['imageUrl'] ??
            prod['image_url'] ??
            prod['product_image'] ??
            prod['image'] ??
            '')
        .toString();
    if (url2.isNotEmpty) return url2;
  }

  return null;
}

int? _extractItemsCount(Map o) {
  final c =
      o['items'] ?? o['order_items'] ?? o['items_json'] ?? o['orderItems'];
  if (c is List) return c.length;
  return null;
}

Map? _extractFirstCheckoutItem(Map o) {
  // Prioritas: order_items (paling umum), lalu fallback lain kalau kamu beda nama
  final list =
      o['order_items'] ?? o['items'] ?? o['orderItems'] ?? o['items_json'];
  if (list is List && list.isNotEmpty && list.first is Map) return list.first;
  return null;
}

String _extractFirstItemNameFromOrder(Map o) {
  final item = _extractFirstCheckoutItem(o);
  if (item == null) return 'Pesanan';

  // 1) Kalau order_items menyimpan nama langsung
  final direct =
      (item['product_name'] ?? item['name'] ?? item['title'] ?? '').toString();
  if (direct.isNotEmpty) return direct;

  // 2) Kalau ada nested product/products
  final prod = item['product'] ?? item['products'];
  if (prod is Map) {
    final nested = (prod['name'] ?? prod['product_name'] ?? prod['title'] ?? '')
        .toString();
    if (nested.isNotEmpty) return nested;
  }

  return 'Pesanan';
}

String? _extractFirstItemImageFromOrder(Map o) {
  final item = _extractFirstCheckoutItem(o);
  if (item == null) return null;

  // 1) Kalau order_items menyimpan image langsung
  final direct = (item['product_image'] ??
          item['image_url'] ??
          item['imageUrl'] ??
          item['image'] ??
          '')
      .toString();
  if (direct.isNotEmpty) return direct;

  // 2) Kalau ada nested product/products
  final prod = item['product'] ?? item['products'];
  if (prod is Map) {
    final nested = (prod['image_url'] ??
            prod['imageUrl'] ??
            prod['product_image'] ??
            prod['image'] ??
            '')
        .toString();
    if (nested.isNotEmpty) return nested;
  }

  return null;
}
