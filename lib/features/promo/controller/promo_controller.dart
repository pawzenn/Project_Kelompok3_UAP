import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/promo.dart';
import '../../../services/supabase/supabase_service.dart';

class PromoController extends GetxController {
  // Observable state
  final isLoading = false.obs;
  final promos = <Promo>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPromos();
  }

  // ✅ LOAD PROMO DARI SUPABASE (hanya yang aktif)
  Future<void> loadPromos() async {
    try {
      isLoading.value = true;

      // Ambil hanya promo yang aktif untuk user
      final data = await SupabaseService.instance.fetchPromos(onlyActive: true);
      promos.assignAll(data);

      debugPrint('✅ Loaded ${promos.length} active promos');
    } catch (e) {
      debugPrint('❌ Error loading promos: $e');

      Get.snackbar(
        'Error',
        'Gagal memuat promo: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ VALIDATE PROMO CODE BY CODE (dari Supabase)
  Future<Promo?> validatePromoCode(String code, int orderTotal) async {
    try {
      // Ambil promo dari database by code
      final promo = await SupabaseService.instance.getPromoByCode(code);

      if (promo == null) {
        return null;
      }

      // Check if active
      if (!promo.isActive) {
        return null;
      }

      // Check min order
      if (orderTotal < promo.minOrder) {
        return null;
      }

      // ✅ FIX: Gunakan startAt dan endAt (bukan startDate/endDate)
      final now = DateTime.now();
      if (promo.startAt != null && now.isBefore(promo.startAt!)) {
        return null;
      }
      if (promo.endAt != null && now.isAfter(promo.endAt!)) {
        return null;
      }

      return promo;
    } catch (e) {
      debugPrint('Error validating promo: $e');
      return null;
    }
  }

  // ✅ CALCULATE DISCOUNT
  int calculateDiscount(Promo promo, int orderTotal) {
    if (promo.type == 'percent') {
      int discount = (orderTotal * promo.value / 100).round();

      // Apply max discount if exists
      if (promo.maxDiscount != null && discount > promo.maxDiscount!) {
        discount = promo.maxDiscount!;
      }

      return discount;
    } else {
      // Fixed discount
      return promo.value;
    }
  }

  // ✅ APPLY PROMO (untuk dipanggil dari checkout)
  Future<Map<String, dynamic>?> applyPromo(String code, int orderTotal) async {
    // Validate dengan database
    final promo = await validatePromoCode(code, orderTotal);

    if (promo == null) {
      Get.snackbar(
        'Promo Tidak Valid',
        'Kode promo tidak ditemukan atau tidak memenuhi syarat',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return null;
    }

    final discount = calculateDiscount(promo, orderTotal);

    Get.snackbar(
      'Promo Berhasil! 🎉',
      'Kamu hemat ${_formatRupiah(discount)}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF22590A),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );

    return {
      'promo': promo,
      'discount': discount,
      'finalTotal': orderTotal - discount,
    };
  }

  // Helper format rupiah
  String _formatRupiah(int value) {
    final s = value.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      b.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) b.write('.');
    }
    return 'Rp$b';
  }
}
