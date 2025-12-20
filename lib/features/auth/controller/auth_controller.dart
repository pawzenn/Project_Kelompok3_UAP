import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  AuthController({AuthRepository? repo}) : _repo = repo ?? AuthRepository();

  final AuthRepository _repo;

  final Rxn<User> user = Rxn<User>();
  final RxBool isLoading = false.obs;

  Stream<User?> get _authStream => _repo.authStateChanges();

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_authStream);
  }

  bool get isLoggedIn => user.value != null;

  Future<void> register({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      await _repo.register(email: email.trim(), password: password);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login({required String email, required String password}) async {
    isLoading.value = true;
    try {
      await _repo.login(email: email.trim(), password: password);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _repo.logout();
    } finally {
      isLoading.value = false;
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun dinonaktifkan.';
      case 'user-not-found':
        return 'Akun tidak ditemukan.';
      case 'wrong-password':
        return 'Password salah.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar.';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter).';
      case 'network-request-failed':
        return 'Koneksi bermasalah. Coba lagi.';
      default:
        return e.message ?? 'Terjadi kesalahan autentikasi.';
    }
  }
}
