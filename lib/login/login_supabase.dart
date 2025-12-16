import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/local/local_prefs_services.dart';
import '../data/repositories/auth_repository.dart';

/// Jembatan antara UI (SignIn / SignUp) dengan AuthRepository + LocalPrefs.
class LoginSupabaseService {
  LoginSupabaseService._();

  static final AuthRepository _authRepository = AuthRepository();

  static Future<void> signUp({
    required String email,
    required String username,
    required String password,
  }) async {
    final AuthResponse response = await _authRepository.registerUser(
      email: email,
      username: username,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Registrasi gagal: user tidak terbentuk.');
    }

    // Simpan sesi login lokal (auto login setelah sign up)
    await LocalPrefsService.saveLoginSession(
      userId: user.id,
      email: email.trim(),
      username: username.trim(),
    );
  }

  static Future<void> signIn({
    required String identifier,
    required String password,
  }) async {
    final AuthResponse response = await _authRepository.loginWithIdentifier(
      identifier: identifier,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Login gagal: user tidak terbentuk.');
    }

    // Ambil profil dari tabel profiles untuk dapat email & username
    final profile = await _authRepository.getCurrentProfile();

    final email = (profile?['email'] as String?) ?? identifier.trim();
    final username = (profile?['username'] as String?) ?? '';

    await LocalPrefsService.saveLoginSession(
      userId: user.id,
      email: email,
      username: username,
    );
  }

  /// Logout dari Supabase dan bersihkan sesi lokal.
  static Future<void> signOut() async {
    await _authRepository.signOut();
    await LocalPrefsService.clearOnLogout();
  }
}
