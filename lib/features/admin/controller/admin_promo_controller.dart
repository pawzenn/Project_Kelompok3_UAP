import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/promo.dart';
import '../../../services/supabase/supabase_service.dart';

class AdminPromoController extends GetxController {
  final isLoading = false.obs;
  final promos = <Promo>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPromos();
  }

  Future<void> loadPromos() async {
    try {
      isLoading.value = true;
      final data =
          await SupabaseService.instance.fetchPromos(onlyActive: false);
      promos.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPromo({
    required String code,
    required String title,
    String? description,
    required String type,
    required int value,
    required int minOrder,
    int? maxDiscount,
    required bool isActive,
  }) async {
    try {
      isLoading.value = true;

      final promo = Promo(
        id: '',
        code: code.trim().toUpperCase(),
        title: title.trim(),
        description:
            (description ?? '').trim().isEmpty ? null : description!.trim(),
        type: type,
        value: value,
        minOrder: minOrder,
        maxDiscount: maxDiscount,
        isActive: isActive,
      );

      final created = await SupabaseService.instance.createPromo(promo);
      promos.insert(0, created);
      Get.snackbar('Promo', 'Promo berhasil ditambahkan',
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('Gagal', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editPromo(Promo promo) async {
    try {
      isLoading.value = true;
      final updated = await SupabaseService.instance.updatePromo(promo);

      final idx = promos.indexWhere((p) => p.id == promo.id);
      if (idx >= 0) promos[idx] = updated;

      Get.snackbar('Promo', 'Promo berhasil diupdate',
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('Gagal', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleActive(Promo promo) async {
    await editPromo(promo.copyWith(isActive: !promo.isActive));
  }

  Future<void> removePromo(Promo promo) async {
    try {
      isLoading.value = true;
      await SupabaseService.instance.deletePromo(promo.id);
      promos.removeWhere((p) => p.id == promo.id);
      Get.snackbar('Promo', 'Promo berhasil dihapus',
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('Gagal', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
