import 'package:shared_preferences/shared_preferences.dart';

class LocalPrefsService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyLastEmail = 'last_email';
  static const String _keyLastUsername = 'last_username';
  static const String _keyIsDarkTheme = 'is_dark_theme';
  static const String _keyUserId = 'user_id';

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // ========= STATUS LOGIN =========

  /// Set flag apakah user sedang login
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyIsLoggedIn, value);
  }

  /// Cek apakah user pernah login dan belum logout
  static Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Simpan email terakhir
  static Future<void> setLastEmail(String email) async {
    final prefs = await _prefs;
    await prefs.setString(_keyLastEmail, email);
  }

  /// Simpan username terakhir
  static Future<void> setLastUsername(String username) async {
    final prefs = await _prefs;
    await prefs.setString(_keyLastUsername, username);
  }

  /// Ambil email terakhir (kalau ada)
  static Future<String?> getLastEmail() async {
    final prefs = await _prefs;
    return prefs.getString(_keyLastEmail);
  }

  /// Ambil username terakhir (kalau ada)
  static Future<String?> getLastUsername() async {
    final prefs = await _prefs;
    return prefs.getString(_keyLastUsername);
  }

  /// Ambil userId terakhir (kalau ada)
  static Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString(_keyUserId);
  }

  // ========= KOMPATIBILITAS DENGAN KODE LOGIN =========

  /// Dipakai di login_supabase.dart
  ///
  /// Simpan:
  /// - status login
  /// - userId
  /// - email
  /// - username
  static Future<void> saveLoginSession({
    required String userId,
    required String email,
    required String username,
  }) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyLastEmail, email);
    await prefs.setString(_keyLastUsername, username);
  }

  /// Dipakai saat logout:
  /// - hapus status login
  /// - hapus userId, email, username
  static Future<void> clearOnLogout() async {
    final prefs = await _prefs;
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyLastEmail);
    await prefs.remove(_keyLastUsername);
  }

  // ========= TEMA GELAP / TERANG =========

  static Future<void> setDarkTheme(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyIsDarkTheme, value);
  }

  static Future<bool> isDarkTheme() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyIsDarkTheme) ?? false;
  }
}
