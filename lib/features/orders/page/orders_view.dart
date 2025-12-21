import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/orders_controller.dart';
import '../../../app/routes/app_routes.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  static const _bg = Color(0xFF1A1A1A);
  static const _greenBg =
      Color(0xFF22590A); // Tetap dipertahankan untuk RefreshIndicator
  static const _gold = Color(0xFFED9A00);
  static const _lime = Color(0xFFE6F06A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 28, 74, 8),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 28, 74, 8),
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
              final dateText = _formatDateShort(createdAt);
              final statusLabel = _mapStatus(statusRaw);
              final itemsCount = _extractItemsCount(o);

              return _OrderCardCompact(
                idFull: id,
                idShort: _shortId(id),
                dateText: dateText,
                totalText: totalText,
                itemsCount: itemsCount,
                statusLabel: statusLabel,
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
  final String totalText;
  final int? itemsCount;
  final String statusLabel;
  final VoidCallback onTap;
  final VoidCallback onDetail;

  const _OrderCardCompact({
    required this.idFull,
    required this.idShort,
    required this.dateText,
    required this.totalText,
    required this.itemsCount,
    required this.statusLabel,
    required this.onTap,
    required this.onDetail,
  });

  static const _gold = Color(0xFFED9A00);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          // ✅ Sekarang langsung menggunakan warna gold (background hijau dihapus)
          color: _gold.withOpacity(0.85),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER (ID & Tanggal)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ID PESANAN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  dateText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // ID Short + Copy Button
            Row(
              children: [
                Expanded(
                  child: Text(
                    idShort,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                      fontSize: 22,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.copy_rounded,
                      color: Colors.white.withOpacity(0.6), size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: idFull));
                    Get.snackbar('Tersalin', 'ID pesanan berhasil disalin',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.white,
                        colorText: Colors.black);
                  },
                ),
              ],
            ),

            const Divider(color: Colors.white24, height: 24),

            // FOOTER (Total Harga & Status)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      totalText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    if (itemsCount != null)
                      Text(
                        '$itemsCount Menu',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                ElevatedButton(
                  onPressed: onDetail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black26,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Detail',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Status Label at bottom
            Text(
              statusLabel.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================= HELPERS =========================
// (Fungsi helper tetap dipertahankan namun pemanggilan cover/image dihapus di build)

num _asNum(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v;
  return num.tryParse(v.toString()) ?? 0;
}

String _formatRupiah(num v) {
  final f =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
  return f.format(v);
}

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
  if (s == 'processing' || s == 'process' || s == 'diproses')
    return 'Sedang diproses';
  if (s == 'received' || s == 'success' || s == 'selesai')
    return 'Pesanan diterima';
  if (s == 'ready' || s == 'done') return 'Pesanan selesai';
  return raw.isEmpty ? 'Sedang diproses' : raw;
}

String _shortId(String id) {
  if (id.isEmpty) return '—';
  final s = id.replaceAll('-', '');
  return s.length <= 10 ? s.toUpperCase() : s.substring(0, 10).toUpperCase();
}

int? _extractItemsCount(Map o) {
  final c =
      o['order_items'] ?? o['items'] ?? o['orderItems'] ?? o['items_json'];
  if (c is List) return c.length;
  return null;
}
