import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/api_service.dart';

class AdminOrderDetailView extends StatefulWidget {
  const AdminOrderDetailView({super.key});

  @override
  State<AdminOrderDetailView> createState() => _AdminOrderDetailViewState();
}

class _AdminOrderDetailViewState extends State<AdminOrderDetailView> {
  late final String orderId;

  bool isLoading = true;
  String error = '';

  // data utama
  Map<String, dynamic> order = {};

  // items
  List<Map<String, dynamic>> items = [];
  int totalQty = 0;
  int subtotal = 0;

  @override
  void initState() {
    super.initState();
    orderId = (Get.arguments ?? '').toString();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      setState(() {
        isLoading = true;
        error = '';
      });

      final res = await ApiService.fetchAdminOrderDetail(orderId: orderId);

      // backend kamu: { order: {...} }
      final ord = (res['order'] is Map<String, dynamic>)
          ? Map<String, dynamic>.from(res['order'])
          : <String, dynamic>{};

      // items dari select "order_items(*)"
      final rawItems = (ord['order_items'] as List?) ?? [];

      final parsedItems =
          rawItems.map((e) => Map<String, dynamic>.from(e as Map)).toList();

      int tq = 0;
      int sub = 0;

      for (final i in parsedItems) {
        final q = _toInt(i['qty']);
        final p = _toInt(i['price']);
        tq += q;
        sub += q * p;
      }

      setState(() {
        order = ord;
        items = parsedItems;
        totalQty = tq;
        subtotal = sub;
      });
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  String _statusLabel(String status) {
    final s = (status).toLowerCase().trim();
    if (s == 'processing') return 'Pesanan Diproses';
    if (s == 'ready') return 'Siap Diambil';
    return 'Pesanan Diterima';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : error.isNotEmpty
                ? _ErrorBox(error: error, onRetry: _loadDetail)
                : _Content(
                    order: order,
                    items: items,
                    totalQty: totalQty,
                    subtotal: subtotal,
                    statusLabel: _statusLabel,
                  ),
      ),
    );
  }
}

/* ================= UI ================= */

class _Content extends StatelessWidget {
  final Map<String, dynamic> order;
  final List<Map<String, dynamic>> items;
  final int totalQty;
  final int subtotal;
  final String Function(String) statusLabel;

  const _Content({
    required this.order,
    required this.items,
    required this.totalQty,
    required this.subtotal,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final orderId = (order['id'] ?? '').toString();
    final status = (order['status'] ?? 'received').toString();
    final total = _toInt(order['total']);

    final shortId = orderId.length > 12
        ? orderId.substring(0, 12).toUpperCase()
        : orderId.toUpperCase();

    return Container(
      width: 360,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFD6D85D),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'DETAIL PESANAN',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ID + STATUS
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ID: $shortId',
                style: const TextStyle(
                  color: Color(0xFFE09B2D),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                statusLabel(status),
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ITEMS
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Item belum tersedia',
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              ...items.map((i) {
                final name = (i['name'] ?? i['product_name'] ?? '-').toString();
                final qty = _toInt(i['qty']);
                final price = _toInt(i['price']);
                final lineTotal = qty * price;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Text(
                        '${qty}x',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        _rupiah(lineTotal),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: Color(0xFFE09B2D),
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const Divider(height: 22),

            // FOOTER
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total item:',
                    style: TextStyle(
                      color: Color(0xFFE09B2D),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  totalQty.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Subtotal:',
                    style: TextStyle(
                      color: Color(0xFFE09B2D),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  _rupiah(subtotal),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total (DB):',
                    style: TextStyle(
                      color: Color(0xFFE09B2D),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  _rupiah(total),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // CLOSE
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22590A),
                  foregroundColor: const Color(0xFFE6F06A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Get.back(result: true),
                child: const Text(
                  'Tutup',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}

class _ErrorBox extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorBox({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 38, color: Colors.red),
          const SizedBox(height: 10),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

/* ================= UTIL ================= */

String _rupiah(int v) {
  return v.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (m) => '.',
      );
}
