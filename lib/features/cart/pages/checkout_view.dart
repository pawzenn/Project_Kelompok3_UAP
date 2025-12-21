import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '/services/location/location_service.dart';
import '../../../services/api_service.dart';
import '../../cart/controller/cart_controller.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final cart = Get.find<CartController>();

  final alamatC = TextEditingController();
  final catatanC = TextEditingController();

  final RxString metodeBayar = 'COD'.obs;
  final RxBool isLoadingLokasi = false.obs;

  double? userLat;
  double? userLng;

  @override
  void initState() {
    super.initState();
    _fillAlamatDariLokasi();
  }

  @override
  void dispose() {
    alamatC.dispose();
    catatanC.dispose();
    super.dispose();
  }

  Future<void> _fillAlamatDariLokasi() async {
    try {
      isLoadingLokasi.value = true;

      final pos = await LocationService.getCurrentPosition();
      userLat = pos.latitude;
      userLng = pos.longitude;

      final addr = await LocationService.reverseGeocode(
        lat: pos.latitude,
        lng: pos.longitude,
      );

      alamatC.text = addr;
      setState(() {});
    } catch (e) {
      Get.snackbar(
        'Lokasi',
        'Gagal mengambil lokasi otomatis. Isi alamat manual ya.',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoadingLokasi.value = false;
    }
  }

  void _showPesananBerlangsungPopup(Map<String, dynamic> orderMap) {
    Get.rawSnackbar(
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
      borderRadius: 16,
      backgroundColor: const Color(0xFF22590A),
      duration: const Duration(seconds: 10),
      messageText: Row(
        children: [
          const Icon(Icons.local_shipping, color: Colors.white),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Pesanan berlangsung',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.closeCurrentSnackbar();
              Get.toNamed(
                AppRoutes.tracking,
                arguments: {
                  'order': orderMap,
                  'userLat': userLat,
                  'userLng': userLng,
                },
              );
            },
            child: const Text(
              'Lihat',
              style: TextStyle(
                color: Color(0xFFE7FF7A),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = cart.totalPrice;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text('Checkout'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const Text(
            'Ringkasan Pesanan',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),

          // ✅ FIX: cart.items itu List<CartItem>, jadi pakai .map langsung
          ...cart.items.map((ci) {
            final p = ci.product; // pastikan CartItem punya product
            final qty = ci.qty; // pastikan CartItem punya qty
            final subtotal = p.price * qty;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
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
                      errorBuilder: (_, __, ___) => Container(
                        width: 62,
                        height: 62,
                        color: Colors.black26,
                        child: const Icon(Icons.image_not_supported,
                            color: Colors.white54),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Rp${p.price} • x$qty • Rp$subtotal',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Alamat Pengantaran',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              Obx(() {
                if (isLoadingLokasi.value) {
                  return const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                return TextButton(
                  onPressed: _fillAlamatDariLokasi,
                  child: const Text(
                    'Ambil lokasi',
                    style: TextStyle(color: Color(0xFFE7FF7A)),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 10),

          _InputBox(
            controller: alamatC,
            hint: 'Alamat otomatis dari lokasi kamu...',
            minLines: 2,
            maxLines: 4,
          ),

          const SizedBox(height: 16),

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
            controller: catatanC,
            hint: 'Contoh: pedas sedang, tanpa bawang...',
            minLines: 2,
            maxLines: 4,
          ),

          const SizedBox(height: 16),

          const Text(
            'Metode Pembayaran',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),

          Obx(() => _PayOption(
                label: 'COD (Bayar di Tempat)',
                selected: metodeBayar.value == 'COD',
                onTap: () => metodeBayar.value = 'COD',
              )),
          const SizedBox(height: 10),
          Obx(() => _PayOption(
                label: 'Transfer Bank',
                selected: metodeBayar.value == 'TRANSFER',
                onTap: () => metodeBayar.value = 'TRANSFER',
              )),

          const SizedBox(height: 18),

          SizedBox(
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE7FF7A),
                foregroundColor: const Color(0xFF22590A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () async {
                final alamat = alamatC.text.trim();
                if (alamat.isEmpty) {
                  Get.snackbar('Alamat', 'Alamat wajib diisi');
                  return;
                }
                if (cart.items.isEmpty) {
                  Get.snackbar('Keranjang', 'Keranjang masih kosong');
                  return;
                }

                // ✅ FIX: payload items dari List<CartItem>
                final items = cart.items.map((ci) {
                  final p = ci.product;
                  final qty = ci.qty;
                  return {
                    'product_id': p.id,
                    'qty': qty,
                    'price': p.price,
                  };
                }).toList();

                Get.dialog(
                  const Center(child: CircularProgressIndicator()),
                  barrierDismissible: false,
                );

                try {
                  final resp = await ApiService.createOrder(
                    address: alamat,
                    items: items,
                    total: total,
                    note: catatanC.text.trim(),
                    paymentMethod: metodeBayar.value,
                  );

                  Get.back();
                  cart.clear();

                  final ord = (resp['order'] ?? resp['data'] ?? resp);
                  final Map<String, dynamic> orderMap =
                      (ord is Map<String, dynamic>) ? ord : <String, dynamic>{};

                  Get.offAllNamed(AppRoutes.home);
                  _showPesananBerlangsungPopup(orderMap);
                } catch (e) {
                  Get.back();
                  Get.snackbar('Gagal', e.toString());
                }
              },
              child: Text(
                'Buat Pesanan • Rp$total',
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final int minLines;
  final int maxLines;

  const _InputBox({
    required this.hint,
    required this.controller,
    required this.minLines,
    required this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _PayOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PayOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFFE7FF7A) : Colors.white12,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? const Color(0xFFE7FF7A) : Colors.white38,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white54,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
