import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/cart_controller.dart';
import '/services/api_service.dart';
import '../../../app/routes/app_routes.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    final alamatC = TextEditingController();
    final catatanC = TextEditingController();
    final metodeBayar = 'COD'.obs;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
        ),
      ),
      body: Obx(() {
        if (cart.items.isEmpty) {
          return const Center(
            child: Text(
              'Keranjang kosong',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Ringkasan Pesanan =====
              const Text(
                'Ringkasan Pesanan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),

              ...cart.items.map((item) {
                final p = item.product;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22590A),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          p.imageUrl,
                          width: 62,
                          height: 62,
                          fit: BoxFit.cover,
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
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Rp${p.price} • x${item.qty} • Rp${item.subtotal}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 18),

              // ===== Alamat =====
              const Text(
                'Alamat Pengantaran',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),

              _InputBox(
                hint: 'Masukkan alamat lengkap...',
                controller: alamatC,
                minLines: 2,
                maxLines: 4,
              ),

              const SizedBox(height: 16),

              // ===== Catatan =====
              const Text(
                'Catatan untuk Penjual',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),

              _InputBox(
                hint: 'Contoh: pedas sedang, tanpa bawang...',
                controller: catatanC,
                minLines: 2,
                maxLines: 4,
              ),

              const SizedBox(height: 18),

              // ===== Metode Pembayaran =====
              const Text(
                'Metode Pembayaran',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),

              Obx(() => Column(
                    children: [
                      _PayTile(
                        label: 'COD (Bayar di Tempat)',
                        value: 'COD',
                        groupValue: metodeBayar.value,
                        onChanged: (v) => metodeBayar.value = v,
                      ),
                      _PayTile(
                        label: 'Transfer Bank',
                        value: 'TRANSFER',
                        groupValue: metodeBayar.value,
                        onChanged: (v) => metodeBayar.value = v,
                      ),
                      _PayTile(
                        label: 'E-Wallet',
                        value: 'EWALLET',
                        groupValue: metodeBayar.value,
                        onChanged: (v) => metodeBayar.value = v,
                      ),
                    ],
                  )),

              const SizedBox(height: 10),

              // ===== Total =====
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total (${cart.totalQty} item)',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w800,
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
              ),
            ],
          ),
        );
      }),
      bottomSheet: Obx(() {
        if (cart.items.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: const BoxDecoration(
            color: Color(0xFF22590A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: SafeArea(
            top: false,
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
                onPressed: () async {
                  final alamat = alamatC.text.trim();
                  if (alamat.isEmpty) {
                    Get.snackbar('Oops', 'Alamat wajib diisi');
                    return;
                  }

                  final items = cart.items
                      .map((item) => {
                            'product_id': item.product.id,
                            'qty': item.qty,
                            'price': item.product.price,
                          })
                      .toList();

                  // show loading
                  Get.dialog(const Center(child: CircularProgressIndicator()),
                      barrierDismissible: false);

                  try {
                    final resp = await ApiService.createOrder(
                      total: cart.totalPrice,
                      items: items.cast<Map<String, dynamic>>(),
                      address: alamat,
                      note: catatanC.text.trim(),
                      paymentMethod: metodeBayar.value,
                    );

                    // success
                    Get.back(); // close dialog
                    cart.clear();
                    Get.offAllNamed(AppRoutes.home);
                    Get.snackbar('Sukses', 'Pesanan berhasil dibuat');
                  } catch (e) {
                    Get.back(); // close dialog
                    Get.snackbar('Error', e.toString());
                  }
                },
                child: Obx(() => Text(
                      'Buat Pesanan • Rp${cart.totalPrice}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    )),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int minLines;
  final int maxLines;

  const _InputBox({
    required this.controller,
    required this.hint,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _PayTile extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _PayTile({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = groupValue == value;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE6F06A).withOpacity(0.14)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xFFE6F06A).withOpacity(0.7)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? const Color(0xFFE6F06A) : Colors.white54,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
