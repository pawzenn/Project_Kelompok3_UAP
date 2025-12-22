import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxBool isLoading = false.obs;

  // Observable user (boleh dipakai UI lain)
  Rx<User?> firebaseUser = Rx<User?>(null);

  // Role state
  final RxBool isAdmin = false.obs;
  final RxString role = 'user'.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  // =========================
  // ✅ ROLE CHECK VIA BACKEND
  // =========================
  Future<void> refreshRoleFromBackend() async {
    final u = _auth.currentUser;
    if (u == null) {
      isAdmin.value = false;
      role.value = 'user';
      return;
    }

    try {
      // Force refresh token biar claim/admin update kebaca juga
      final token = await u.getIdToken(true);

      final resp = await http.get(
        Uri.parse('${BackendApi.baseUrl}/api/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (resp.statusCode != 200) {
        debugPrint('❌ /api/me failed: ${resp.statusCode} ${resp.body}');
        isAdmin.value = false;
        role.value = 'user';
        return;
      }

      final decoded = jsonDecode(resp.body);
      final bool adminFlag = decoded is Map<String, dynamic>
          ? (decoded['is_admin'] == true)
          : false;

      isAdmin.value = adminFlag;
      role.value = adminFlag ? 'admin' : 'user';

      debugPrint(
          '✅ ROLE VIA BACKEND => isAdmin=$adminFlag email=${u.email} uid=${u.uid}');
    } catch (e) {
      debugPrint('❌ refreshRoleFromBackend error: $e');
      isAdmin.value = false;
      role.value = 'user';
    }
  }

  // =========================
  // ✅ REGISTER (FIREBASE)
  // =========================
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      isLoading.value = true;

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(fullName);
      await userCredential.user?.reload();

      debugPrint('✅ Register berhasil: ${userCredential.user?.email}');
      debugPrint('✅ Display Name: ${userCredential.user?.displayName}');

      // setelah register, cek role via backend
      await refreshRoleFromBackend();
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Error: ${e.code} - ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Email sudah digunakan';
          break;
        case 'weak-password':
          errorMessage = 'Password terlalu lemah';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid';
          break;
        default:
          errorMessage = 'Registrasi gagal: ${e.message}';
      }
      throw errorMessage;
    } catch (e) {
      debugPrint('❌ Error register: $e');
      throw 'Terjadi kesalahan saat registrasi';
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // ✅ LOGIN (FIREBASE)
  // =========================
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final u = _auth.currentUser;
      debugPrint('✅ Login berhasil uid=${u?.uid} email=${u?.email}');

      // ✅ cek role via backend
      await refreshRoleFromBackend();
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Error: ${e.code} - ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Email tidak terdaftar';
          break;
        case 'wrong-password':
          errorMessage = 'Password salah';
          break;
        case 'invalid-email':
          errorMessage = 'Format email tidak valid';
          break;
        case 'user-disabled':
          errorMessage = 'Akun telah dinonaktifkan';
          break;
        default:
          errorMessage = 'Login gagal: ${e.message}';
      }
      throw errorMessage;
    } catch (e) {
      debugPrint('❌ Error login: $e');
      throw 'Terjadi kesalahan saat login';
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // ✅ LOGOUT
  // =========================
  Future<void> logout() async {
    try {
      await _auth.signOut();
      isAdmin.value = false;
      role.value = 'user';
      debugPrint('✅ Logout berhasil');
    } catch (e) {
      debugPrint('❌ Error logout: $e');
      throw 'Gagal logout';
    }
  }
}

// =========================
// ✅ BACKEND BASE URL
// =========================
class BackendApi {
  BackendApi._();

  /// samakan dengan ApiService kamu
  static const String baseUrl =
      'https://projectkelompok3uap-production.up.railway.app';
}
