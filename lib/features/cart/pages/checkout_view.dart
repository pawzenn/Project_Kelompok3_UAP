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
  // ✅ pastikan pakai instance yang sama
  final CartController cart = Get.isRegistered<CartController>()
      ? Get.find<CartController>()
      : Get.put(CartController());

  final alamatC = TextEditingController();
  final catatanC = TextEditingController();
  final promoC = TextEditingController();

  final RxString metodeBayar = 'COD'.obs;
  final RxBool isLoadingLokasi = false.obs;

  double? userLat;
  double? userLng;

  // THEME
  static const _bg = Color(0xFF22590A);
  static const _lime = Color(0xFFF2FF00);
  static const _gold = Color(0xFFED9A00);
  static const _dark = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _fillAlamatDariLokasi();
  }

  @override
  void dispose() {
    alamatC.dispose();
    catatanC.dispose();
    promoC.dispose();
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

  Future<bool> _confirmHapusItemSaatQty1(String nama) async {
    final res = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF202020),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Hapus item?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: Text(
          'Qty "$nama" sudah 1. Jika dikurangi, item akan dihapus dari pesanan.',
          style: const TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Batal',
              style:
                  TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _lime,
              foregroundColor: _bg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus',
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
      barrierDismissible: true,
    );
    return res ?? false;
  }

  Future<void> _showTransferDialog() async {
    await Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF202020),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Transfer Bank BRI',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Silakan transfer ke rekening berikut:',
              style: TextStyle(color: Colors.white70, height: 1.35),
            ),
            SizedBox(height: 10),
            SelectableText(
              'BRI: 1234-01-000000-53-9\na.n. Lalapan Bang Ajey',
              style: TextStyle(
                color: _lime,
                fontWeight: FontWeight.w900,
                height: 1.35,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _lime,
              foregroundColor: _bg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Get.back(),
            child: const Text('Oke',
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showQrisDialog() async {
    await Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF202020),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'QRIS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.qr_code_2_rounded,
                    size: 160, color: Colors.black),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Scan QR untuk membayar.\nKlik Oke setelah pembayaran.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, height: 1.35),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _lime,
              foregroundColor: _bg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Get.back(),
            child: const Text('Oke',
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    Get.snackbar(
      'Pembayaran',
      'Pembayaran berhasil',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: _bg,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dark,
      appBar: AppBar(
        backgroundColor: _dark,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_rounded, color: _lime),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(color: _lime, fontWeight: FontWeight.w900),
        ),
      ),

      // ✅ penting: Obx membungkus semua yang baca cart.items dan cart.totalPrice
      body: Obx(() {
        final total = cart.totalPrice;

        return Container(
          decoration: BoxDecoration(
            color: _bg.withOpacity(0.70),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            children: [
              const Text(
                'Pesanan Saya',
                style: TextStyle(
                  color: _lime,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),

              if (cart.items.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.10)),
                  ),
                  child: const Text(
                    'Keranjang masih kosong',
                    style: TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.w800),
                  ),
                )
              else
                ...cart.items.map((ci) {
                  final p = ci.product;
                  final qty = ci.qty;
                  final subtotal = p.price * qty;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _bg.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.10)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.28),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            p.imageUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 64,
                              height: 64,
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
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _lime,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Rp${p.price} • x$qty • Rp$subtotal',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // ✅ qty control - sinkron dengan CartView + CartController
                              Row(
                                children: [
                                  _QtyBtn(
                                    icon: Icons.remove_rounded,
                                    onTap: () async {
                                      if (ci.qty <= 1) {
                                        final ok =
                                            await _confirmHapusItemSaatQty1(
                                                p.name);
                                        if (!ok) return;
                                        cart.remove(p.id);
                                        return;
                                      }
                                      cart.decrement(p.id);
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color:
                                              Colors.white.withOpacity(0.10)),
                                    ),
                                    child: Text(
                                      '$qty',
                                      style: const TextStyle(
                                        color: _lime,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  _QtyBtn(
                                    icon: Icons.add_rounded,
                                    onTap: () => cart.increment(p.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

              const SizedBox(height: 16),

              // ✅ KODE PROMO
              const Text(
                'Kode Promo',
                style: TextStyle(
                  color: _lime,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              _PromoBox(controller: promoC),

              const SizedBox(height: 16),

              // ✅ ALAMAT
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Alamat Pengantaran',
                    style: TextStyle(
                      color: _lime,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  Obx(() {
                    if (isLoadingLokasi.value) {
                      return const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: _lime),
                      );
                    }
                    return TextButton(
                      onPressed: _fillAlamatDariLokasi,
                      child: const Text(
                        'Ambil lokasi',
                        style: TextStyle(
                            color: _lime, fontWeight: FontWeight.w900),
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

              // ✅ CATATAN
              const Text(
                'Catatan untuk Penjual',
                style: TextStyle(
                  color: _lime,
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

              // ✅ METODE BAYAR
              const Text(
                'Metode Pembayaran',
                style: TextStyle(
                  color: _lime,
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
              const SizedBox(height: 10),
              Obx(() => _PayOption(
                    label: 'QRIS',
                    selected: metodeBayar.value == 'QRIS',
                    onTap: () => metodeBayar.value = 'QRIS',
                  )),

              const SizedBox(height: 18),

              // ✅ BUTTON BUAT PESANAN (LOGIKA TETAP)
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _lime,
                    foregroundColor: _bg,
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

                    // ✅ POPUP pembayaran sesuai pilihan
                    if (metodeBayar.value == 'TRANSFER') {
                      await _showTransferDialog();
                    } else if (metodeBayar.value == 'QRIS') {
                      await _showQrisDialog();
                    }

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
                      const Center(
                          child: CircularProgressIndicator(color: _lime)),
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
                          (ord is Map<String, dynamic>)
                              ? ord
                              : <String, dynamic>{};

                      Get.offAllNamed(AppRoutes.home);
                      _showPesananBerlangsungPopup(orderMap);
                    } catch (e) {
                      Get.back();
                      Get.snackbar('Gagal', e.toString());
                    }
                  },
                  child: Text(
                    'Buat Pesanan • Rp$total',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ===================== COMPONENTS =====================

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyBtn({required this.icon, required this.onTap});

  static const _lime = Color(0xFFF2FF00);
  static const _bg = Color(0xFF22590A);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _lime,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: _bg, size: 24),
      ),
    );
  }
}

class _PromoBox extends StatelessWidget {
  final TextEditingController controller;
  const _PromoBox({required this.controller});

  static const _gold = Color(0xFFED9A00);
  static const _bg = Color(0xFF22590A);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _gold.withOpacity(0.90),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: _bg, fontWeight: FontWeight.w900),
        decoration: const InputDecoration(
          hintText: 'Masukkan kode promo...',
          hintStyle: TextStyle(color: _bg),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.local_offer_rounded, color: _bg),
        ),
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

  static const _lime = Color(0xFFF2FF00);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.black.withOpacity(0.20),
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _lime, width: 1.5),
        ),
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

  static const _lime = Color(0xFFF2FF00);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.20),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? _lime : Colors.white.withOpacity(0.12),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? _lime : Colors.white38,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? _lime : Colors.white70,
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
