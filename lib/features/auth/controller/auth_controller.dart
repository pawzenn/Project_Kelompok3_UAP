import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../services/api_service.dart';

class AuthController extends GetxController {
  final _auth = FirebaseAuth.instance;

  final isLoading = false.obs;

  // Observable user
  final Rx<User?> firebaseUser = Rx<User?>(null);

  // ✅ role dari BACKEND
  final RxBool isAdmin = false.obs;
  final RxString role = 'user'.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  /// ✅ ambil role dari backend: GET /api/me
  Future<void> refreshRoleFromBackend() async {
    final u = _auth.currentUser;
    if (u == null) {
      isAdmin.value = false;
      role.value = 'user';
      return;
    }

    try {
      final me = await ApiService.getMe();
      final adminFlag = me['is_admin'] == true;

      isAdmin.value = adminFlag;
      role.value = adminFlag ? 'admin' : 'user';

      debugPrint('✅ /api/me => $me');
    } catch (e) {
      // kalau backend error, default aman = user
      isAdmin.value = false;
      role.value = 'user';
      debugPrint('❌ refreshRoleFromBackend error: $e');
    }
  }

  // ✅ REGISTER WITH FIREBASE
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

      // setelah register, default user
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

  // ✅ LOGIN WITH FIREBASE
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

      debugPrint('✅ Login berhasil');

      // ✅ cek role setelah login
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

  // ✅ LOGOUT
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
