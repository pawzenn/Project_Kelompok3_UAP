import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/supabase/supabase_service.dart';

class AdminOrderDetailView extends StatefulWidget {
  const AdminOrderDetailView({super.key});

  @override
  State<AdminOrderDetailView> createState() => _AdminOrderDetailViewState();
}

class _AdminOrderDetailViewState extends State<AdminOrderDetailView> {
  late final String orderId;

  bool isLoading = true;
  String error = '';

  List<Map<String, dynamic>> items = [];
  int totalQty = 0;
  int subtotal = 0;

  @override
  void initState() {
    super.initState();
    orderId = Get.arguments as String;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      isLoading = true;
      error = '';

      final res = await SupabaseService.instance.client
          .from('order_items')
          .select('name, price, qty')
          .eq('order_id', orderId);

      items = List<Map<String, dynamic>>.from(res);

      totalQty = 0;
      subtotal = 0;

      for (final i in items) {
        final q = (i['qty'] ?? 0) as int;
        final p = (i['price'] ?? 0) as int;
        totalQty += q;
        subtotal += q * p;
      }
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : error.isNotEmpty
                ? Text(error)
                : _Content(
                    orderId: orderId,
                    items: items,
                    totalQty: totalQty,
                    subtotal: subtotal,
                  ),
      ),
    );
  }
}

/* ================= UI ================= */

class _Content extends StatelessWidget {
  final String orderId;
  final List<Map<String, dynamic>> items;
  final int totalQty;
  final int subtotal;

  const _Content({
    required this.orderId,
    required this.items,
    required this.totalQty,
    required this.subtotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
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

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'ID: ${orderId.substring(0, 12).toUpperCase()}',
              style: const TextStyle(
                color: Color(0xFFE09B2D),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ITEMS
          ...items.map((i) {
            final name = i['name'] ?? '-';
            final qty = i['qty'] ?? 0;
            final price = i['price'] ?? 0;
            final total = qty * price;

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
                    _rupiah(total),
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
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
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
