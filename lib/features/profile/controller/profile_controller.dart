import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileController extends GetxController {
  final _auth = FirebaseAuth.instance;

  // Observable state
  final isLoading = false.obs;
  final userName = ''.obs;
  final userEmail = ''.obs;
  final userPhone = ''.obs;
  final userAvatar = ''.obs;

  // Theme mode
  final isDarkMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadThemePreference();
  }

  // ✅ LOAD DATA FROM FIREBASE AUTH
  void loadUserData() {
    try {
      final user = _auth.currentUser;

      debugPrint('========== DEBUG FIREBASE USER INFO ==========');
      debugPrint('User ID: ${user?.uid}');
      debugPrint('Email: ${user?.email}');
      debugPrint('Display Name: ${user?.displayName}');
      debugPrint('Phone: ${user?.phoneNumber}');
      debugPrint('Photo URL: ${user?.photoURL}');
      debugPrint('==============================================');

      if (user != null) {
        // ✅ Firebase menggunakan displayName, bukan metadata
        userEmail.value = user.email ?? 'Email tidak tersedia';
        userName.value = user.displayName ?? 'User';
        userPhone.value = user.phoneNumber ?? 'Nomor tidak tersedia';
        userAvatar.value = user.photoURL ?? '';

        debugPrint('✅ Loaded - Name: ${userName.value}');
        debugPrint('✅ Loaded - Email: ${userEmail.value}');
        debugPrint('✅ Loaded - Phone: ${userPhone.value}');
      } else {
        debugPrint('❌ User is NULL - Belum login!');
      }
    } catch (e) {
      debugPrint('❌ Error loading user data: $e');
    }
  }

  void loadThemePreference() {
    isDarkMode.value = true;
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;

    Get.snackbar(
      'Mode Tema',
      isDarkMode.value ? 'Mode Gelap Aktif' : 'Mode Terang Aktif',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF22590A),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  // ✅ LOGOUT FIREBASE
  Future<void> logout() async {
    try {
      isLoading.value = true;

      await _auth.signOut();

      Get.offAllNamed('/login');

      Get.snackbar(
        'Berhasil',
        'Anda telah keluar',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF22590A),
        colorText: const Color(0xFFE6F06A),
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal logout: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ UPDATE PROFILE (OPTIONAL - untuk fitur edit nanti)
  Future<void> updateProfile({
    String? newName,
    String? newPhotoUrl,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        if (newName != null) {
          await user.updateDisplayName(newName);
          userName.value = newName;
        }

        if (newPhotoUrl != null) {
          await user.updatePhotoURL(newPhotoUrl);
          userAvatar.value = newPhotoUrl;
        }

        await user.reload();

        Get.snackbar(
          'Berhasil',
          'Profile berhasil diupdate',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF22590A),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('❌ Error update profile: $e');
      throw 'Gagal update profile';
    }
  }
}
