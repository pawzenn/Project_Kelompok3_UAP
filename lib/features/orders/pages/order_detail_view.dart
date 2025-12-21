import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/order_detail_controller.dart';

class OrderDetailView extends GetView<OrderDetailController> {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
        ),
        title: Obx(() {
          final id = (controller.order['id'] ?? '').toString();
          return Text(
            'Order #${id.length >= 8 ? id.substring(0, 8) : id}',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          );
        }),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF22590A)),
          );
        }

        final order = controller.order;
        final id = (order['id'] ?? '').toString();
        final total = (order['total'] ?? 0).toString();
        final createdAt = (order['created_at'] ?? '').toString();

        // 1. Ambil status asli dari backend
        final rawStatus =
            (order['status'] ?? '').toString().toLowerCase().trim();

        // 2. Logika Mapping Status (Ubah tampilan di View)
        String displayStatus = rawStatus;
        if (rawStatus == 'received') {
          displayStatus =
              'pesanan diproses'; // Kita "paksa" tampilannya di sini
        }

        return Column(
          children: [
            // Header Info Pesanan (Warna Hijau)
            _buildOrderHeader(id, total, createdAt, displayStatus),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ✅ LOGIKA MAPS: Muncul jika status 'received' atau 'processing'
                  if (rawStatus == 'received' ||
                      rawStatus == 'processing' ||
                      rawStatus == 'ready' ||
                      rawStatus == 'dikirim')
                    _buildMapTrackingSection(order),

                  const SizedBox(height: 24),
                  const Text(
                    "Item Pesanan",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  // Daftar Item
                  if (controller.items.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text("Tidak ada detail item",
                            style: TextStyle(color: Colors.white30)),
                      ),
                    )
                  else
                    ...controller.items.map((it) {
                      final product = it['product'] ?? {};
                      return _buildProductItem(it, product);
                    }).toList(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // Widget Header Hijau (Status sudah di-mapping)
  Widget _buildOrderHeader(
      String id, String total, String createdAt, String displayStatus) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF22590A),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order #${id.length >= 8 ? id.substring(0, 8) : id}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Total: Rp$total',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(createdAt.split('T')[0], // Potong string agar tanggal saja
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(displayStatus.toUpperCase(),
                    style: const TextStyle(
                        color: Color(0xFFE6F06A),
                        fontWeight: FontWeight.bold,
                        fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ WIDGET MAPS: Langsung Muncul & Bisa Diklik
  Widget _buildMapTrackingSection(Map orderData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          "Lacak Pengiriman",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Get.toNamed('/map-view', arguments: orderData),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF252525),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
              // Tambahkan efek bayangan tipis
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5))
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Icon dan Teks di Tengah Peta
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_rounded,
                            color: Colors.green.withOpacity(0.4), size: 50),
                        const SizedBox(height: 10),
                        const Text("Ketuk untuk Buka Peta Live",
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  // Label Status di dalam Peta
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22590A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle,
                              color: Colors.greenAccent, size: 10),
                          SizedBox(width: 6),
                          Text("Sistem Tracking Aktif",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget Item Produk
  Widget _buildProductItem(Map it, Map product) {
    final name = (product['name'] ?? it['name'] ?? 'Item').toString();
    final qty = (it['qty'] ?? it['quantity'] ?? 1).toString();
    final price = (it['price'] ?? it['unit_price'] ?? 0).toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
                color: Colors.black26, borderRadius: BorderRadius.circular(10)),
            child: (product['image_url'] != null)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      product['image_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.fastfood, color: Colors.white24),
                    ))
                : const Icon(Icons.fastfood, color: Colors.white54),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                const SizedBox(height: 5),
                Text('$qty x Rp$price',
                    style:
                        const TextStyle(color: Colors.white60, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
