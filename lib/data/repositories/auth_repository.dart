import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_service.dart';

/// Repository yang mengurus semua interaksi Auth + tabel `profiles` di Supabase.
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository({SupabaseClient? client})
    // 👇 perbaikan di sini: pakai instance, bukan static
    : _client = client ?? SupabaseService.instance.client;

  /// Registrasi user baru:
  /// - Buat akun di Supabase Auth (email + password)
  /// - Insert ke tabel `profiles` (id, email, username)
  Future<AuthResponse> registerUser({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      // 1) Registrasi di Supabase Auth
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Registrasi gagal: user tidak terbentuk.');
      }

      // 2) Insert ke tabel profiles
      await _client.from('profiles').insert({
        'id': user.id,
        'email': email.trim(),
        'username': username.trim(),
      });

      return response;
    } on AuthException catch (e) {
      // Error dari auth (email sudah dipakai, password lemah, dll)
      throw Exception(e.message);
    } on PostgrestException catch (e) {
      // Error dari database (username/email duplikat, dsb)
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan saat registrasi: $e');
    }
  }

  /// Login dengan identifier (boleh email ATAU username) + password.
  ///
  /// - Jika identifier berisi '@' → dianggap email.
  /// - Jika tidak → dianggap username, diubah ke email lewat tabel `profiles`.
  Future<AuthResponse> loginWithIdentifier({
    required String identifier,
    required String password,
  }) async {
    try {
      final trimmed = identifier.trim();
      String emailToUse = trimmed;

      // Kalau bukan email, kita anggap username → cari email-nya dulu.
      if (!trimmed.contains('@')) {
        final email = await _getEmailByUsername(trimmed);
        if (email == null) {
          throw Exception('Username tidak ditemukan.');
        }
        emailToUse = email;
      }

      final response = await _client.auth.signInWithPassword(
        email: emailToUse,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login gagal: user tidak ditemukan.');
      }

      return response;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan saat login: $e');
    }
  }

  /// Ambil email dari tabel profiles berdasarkan username.
  Future<String?> _getEmailByUsername(String username) async {
    try {
      final result = await _client
          .from('profiles')
          .select('email')
          .eq('username', username.trim())
          .maybeSingle();

      if (result == null) return null;
      return result['email'] as String?;
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengambil email dari username: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil email: $e');
    }
  }

  /// Ambil profile current user dari tabel `profiles`.
  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final result = await _client
          .from('profiles')
          .select('id, email, username')
          .eq('id', user.id)
          .maybeSingle();

      if (result == null) return null;
      return Map<String, dynamic>.from(result);
    } on PostgrestException catch (e) {
      throw Exception('Gagal mengambil profil user: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil profil user: $e');
    }
  }

  /// User yang sedang login saat ini (kalau ada).
  User? get currentUser => _client.auth.currentUser;

  /// Logout dari Supabase Auth.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan saat logout: $e');
    }
  }
}
